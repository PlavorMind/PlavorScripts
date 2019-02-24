#PHP uninstaller
#Uninstalls PHP.

param([string]$dir="C:/PHP")

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{"Cannot find PHP."
exit}

"Stopping PHP-related processes"
if (Get-Process "php" -ErrorAction Ignore)
{Stop-Process -Force -Name "php"}
if (Get-Process "php-cgi" -ErrorAction Ignore)
{Stop-Process -Force -Name "php-cgi"}
if (Get-Process "php-win" -ErrorAction Ignore)
{Stop-Process -Force -Name "php-win"}
if (Get-Process "phpdbg" -ErrorAction Ignore)
{Stop-Process -Force -Name "phpdbg"}

"Deleting PHP directory"
Remove-Item $dir -Force -Recurse
