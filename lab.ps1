param(
  [ValidateSet('setup','up','build','release','publish','verify','down','status','ui','password','validate','test-gitops','use-github')]
  [string]$Action = 'status',
  [Parameter(ValueFromRemainingArguments = $true)] [string[]]$ExtraArgs
)
$ErrorActionPreference = 'Stop'
$state = Join-Path $PSScriptRoot '.state'
New-Item -ItemType Directory -Force $state | Out-Null
$keeperFile = Join-Path $state 'keeper.pid'
$keeperOk = $false
if (Test-Path $keeperFile) {
  $keeperId = [int](Get-Content $keeperFile)
  $process = Get-CimInstance Win32_Process -Filter "ProcessId=$keeperId"
  $keeperOk = $process -and $process.Name -eq 'wsl.exe' -and $process.CommandLine -like '*sleep infinity*'
}
if (-not $keeperOk) {
  $process = Start-Process wsl.exe -ArgumentList '-d','Ubuntu','-u','root','--exec','sleep','infinity' -WindowStyle Hidden -PassThru
  $process.Id | Set-Content $keeperFile
}
$linuxPath = & wsl -d Ubuntu -u root --exec wslpath -a ($PSScriptRoot.Replace('\','/'))
if ($LASTEXITCODE -ne 0) { throw 'Cannot access Ubuntu.' }
& wsl -d Ubuntu -u root --exec bash "$linuxPath/scripts/dispatch.sh" $Action @ExtraArgs
if ($LASTEXITCODE -ne 0) { throw "Lab action failed: $Action (exit $LASTEXITCODE)" }
