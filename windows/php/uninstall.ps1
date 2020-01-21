#Uninstalls PHP.

Param([Parameter(Position=0)][string]$dir="C:/plavormind/php-ts") #Directory that PHP is installed

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

Write-Verbose "Stopping PHP processes"
if (Get-Process "php" -ErrorAction Ignore)
{Stop-Process -Force -Name "php"}
if (Get-Process "php-cgi" -ErrorAction Ignore)
{Stop-Process -Force -Name "php-cgi"}
if (Get-Process "php-win" -ErrorAction Ignore)
{Stop-Process -Force -Name "php-win"}
if (Get-Process "phpdbg" -ErrorAction Ignore)
{Stop-Process -Force -Name "phpdbg"}

if (Test-AdminPermission)
{."${PSScriptRoot}/delete-task.ps1"}
else
{Write-Warning "Skipped deleting task: This script must be run as administrator to delete task."}

Write-Verbose "Deleting PHP directory"
Remove-Item $dir -Force -Recurse
