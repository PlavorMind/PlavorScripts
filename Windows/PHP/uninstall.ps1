#Uninstalls PHP.

Param([Parameter(Position=0)][string]$dir="C:/plavormind/php-nts") #Directory that PHP is installed

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{"Cannot find PHP."
exit}

"Stopping PHP-related processes"
if (Test-Path "${dir}/stop.ps1")
{."${dir}/stop.ps1"}
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

"Deleting PHP directory"
Remove-Item $dir -Force -Recurse
