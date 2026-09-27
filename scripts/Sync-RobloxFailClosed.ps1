# Blocks Roblox from every adapter except Proton. Fails closed when Proton is off
# and when a Roblox update changes the executable path.
# Requires an elevated Windows PowerShell. Re-run with -Install once so a
# scheduled task keeps the rules current.

[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'
$RuleGroup = 'roblox-protonvpn'
$TaskName = 'roblox-protonvpn-fail-closed'
$LogPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'last-sync.log'

if ($PSVersionTable.PSEdition -eq 'Core') {
    $windowsPowerShell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
    if ($Install) { $argList += '-Install' }
    if ($Remove) { $argList += '-Remove' }
    & $windowsPowerShell @argList
    exit $LASTEXITCODE
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
    if ($Install) { $argList += '-Install' }
    if ($Remove) { $argList += '-Remove' }
    Start-Process -FilePath (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe') -ArgumentList $argList -Verb RunAs -Wait
    exit $LASTEXITCODE
}

Start-Transcript -Path $LogPath -Force | Out-Null

function Get-RobloxExecutables {
    $roots = @(
        (Join-Path $env:LOCALAPPDATA 'Roblox'),
        (Join-Path $env:ProgramFiles 'Roblox'),
        (Join-Path ${env:ProgramFiles(x86)} 'Roblox')
    )
    $files = foreach ($root in $roots) {
        if (Test-Path -LiteralPath $root) {
            Get-ChildItem -LiteralPath $root -Filter 'Roblox*.exe' -Recurse -File -ErrorAction SilentlyContinue
        }
    }
    @($files | Sort-Object -Property FullName -Unique)
}

function Test-ProtonAdapter {
    param($Adapter)
    $text = '{0} {1}' -f $Adapter.Name, $Adapter.InterfaceDescription
    return $text -match 'Proton'
}

function Get-LeakAdapters {
    @(Get-NetAdapter | Where-Object { -not (Test-ProtonAdapter $_) })
}

function Remove-FailClosedRules {
    $existing = @(Get-NetFirewallRule -Group $RuleGroup -ErrorAction SilentlyContinue)
    if ($existing.Count -gt 0) {
        $existing | Remove-NetFirewallRule
    }
}

function Sync-FailClosedRules {
    Remove-FailClosedRules

    $executables = Get-RobloxExecutables
    $leakAdapters = Get-LeakAdapters
    $protonAdapters = @(Get-NetAdapter | Where-Object { Test-ProtonAdapter $_ })

    Write-Output ('Proton adapters left open: {0}' -f ($(if ($protonAdapters.Count) { $protonAdapters.Name -join ', ' } else { 'none (Roblox stays blocked)' })))
    Write-Output ('Adapters Roblox cannot use: {0}' -f ($(if ($leakAdapters.Count) { ($leakAdapters | ForEach-Object { '{0} [{1}]' -f $_.Name, $_.Status }) -join ', ' } else { 'none' })))

    if ($executables.Count -eq 0) {
        Write-Output 'No Roblox executables under the usual install folders. The task will keep checking.'
        return
    }
    if ($leakAdapters.Count -eq 0) {
        Write-Output 'No non-Proton adapters found. No block rules were created.'
        return
    }

    $aliases = @($leakAdapters.Name)
    foreach ($file in $executables) {
        New-NetFirewallRule `
            -DisplayName ("roblox-protonvpn block " + $file.Name) `
            -Group $RuleGroup `
            -Direction Outbound `
            -Action Block `
            -Program $file.FullName `
            -InterfaceAlias $aliases `
            -Profile Any `
            -Enabled True | Out-Null
        Write-Output ('Blocked {0}' -f $file.FullName)
    }
}

function Install-FailClosedTask {
    $argument = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $PSCommandPath
    $action = New-ScheduledTaskAction -Execute (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe') -Argument $argument
    $logon = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $repeat = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Days 9999)
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -MultipleInstances IgnoreNew `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger @($logon, $repeat) -Settings $settings -Principal $principal -Force | Out-Null
    Write-Output ('Scheduled task {0} is registered. It refreshes the block every minute and at logon.' -f $TaskName)
}

function Uninstall-FailClosedTask {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($task) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Output ('Removed scheduled task {0}' -f $TaskName)
    }
}

if ($Remove) {
    Remove-FailClosedRules
    Uninstall-FailClosedTask
    Write-Output 'Fail-closed Roblox rules removed.'
    Stop-Transcript | Out-Null
    exit 0
}

Sync-FailClosedRules
if ($Install) {
    Install-FailClosedTask
}

Stop-Transcript | Out-Null
exit 0
