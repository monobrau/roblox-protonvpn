# Shows whether running Roblox sockets sit on a Proton VPN adapter.
$ErrorActionPreference = 'SilentlyContinue'

$procs = @(Get-Process -Name 'Roblox*' | Where-Object { $_.ProcessName -like 'Roblox*' })
if ($procs.Count -eq 0) {
    Write-Output 'No Roblox processes are running. Start a game, then run this again.'
    exit 0
}

$addresses = @{}
Get-NetIPAddress -AddressFamily IPv4 | ForEach-Object {
    if (-not $addresses.ContainsKey($_.IPAddress)) {
        $addresses[$_.IPAddress] = $_.InterfaceAlias
    }
}

function Get-RouteLabel([string]$LocalAddress) {
    if ([string]::IsNullOrWhiteSpace($LocalAddress) -or $LocalAddress -eq '0.0.0.0') {
        return 'unbound'
    }
    $alias = $addresses[$LocalAddress]
    if (-not $alias) {
        return 'unknown'
    }
    if ($alias -match 'Proton|WireGuard|Wintun|TAP') {
        return "vpn ($alias)"
    }
    return "direct ($alias)"
}

$rows = foreach ($proc in $procs) {
    $udp = @(Get-NetUDPEndpoint -OwningProcess $proc.Id)
    $tcp = @(Get-NetTCPConnection -OwningProcess $proc.Id)
    foreach ($endpoint in ($udp + $tcp)) {
        [pscustomobject]@{
            Process = $proc.ProcessName
            Pid     = $proc.Id
            Proto   = if ($endpoint.PSObject.Properties.Name -contains 'State') { 'TCP' } else { 'UDP' }
            Local   = $endpoint.LocalAddress
            Remote  = $endpoint.RemoteAddress
            Route   = Get-RouteLabel $endpoint.LocalAddress
        }
    }
}

if (-not $rows) {
    Write-Output 'Roblox is running, but no sockets were readable. Open PowerShell as administrator and run this again.'
    $procs | Select-Object ProcessName, Id, Path | Format-Table -AutoSize
    exit 0
}

$rows |
    Sort-Object Process, Proto, Remote |
    Format-Table -AutoSize
