param([switch]$ConfirmDestroy)
if (-not $ConfirmDestroy) { throw 'Deletes all windows-lab data. Re-run with -ConfirmDestroy.' }
& "$PSScriptRoot/lab.ps1" down --confirm
