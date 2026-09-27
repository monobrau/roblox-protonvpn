# Lists Roblox executables to add in Proton VPN split tunneling (Include mode).
$ErrorActionPreference = 'SilentlyContinue'

$roots = @(
    (Join-Path $env:LOCALAPPDATA 'Roblox'),
    (Join-Path $env:ProgramFiles 'Roblox'),
    (Join-Path ${env:ProgramFiles(x86)} 'Roblox')
)

$files = foreach ($root in $roots) {
    if (Test-Path -LiteralPath $root) {
        Get-ChildItem -LiteralPath $root -Filter 'Roblox*.exe' -Recurse -File
    }
}

$files = @($files | Sort-Object FullName -Unique)

if ($files.Count -eq 0) {
    Write-Output 'No Roblox executables under the usual install folders.'
    Write-Output 'Install Roblox, then run this again and add the printed paths in Proton VPN Include mode.'
    exit 0
}

$files | Select-Object Name, LastWriteTime, FullName | Format-Table -AutoSize
Write-Output ''
Write-Output 'Add these paths in Proton VPN: Split tunneling, Include mode. Re-run after Roblox updates.'
