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
    Write-Output 'Expected them under %LOCALAPPDATA%\Roblox.'
    exit 0
}

$files | Select-Object Name, LastWriteTime, FullName | Format-Table -AutoSize
Write-Output ''
Write-Output 'Fail-closed mode blocks these paths on non-Proton adapters. Run Sync-RobloxFailClosed.ps1 -Install once.'
