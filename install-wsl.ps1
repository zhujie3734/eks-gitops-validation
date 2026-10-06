# Run in an Administrator PowerShell terminal.
$ErrorActionPreference = 'Stop'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Open PowerShell as Administrator, then run this script.' }
wsl --install -d Ubuntu
if ($LASTEXITCODE -ne 0) { throw 'WSL installation failed.' }
Write-Host 'Restart Windows if requested, then open Ubuntu and complete username/password initialization.'
