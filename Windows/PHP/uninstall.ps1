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
Stop-Process -Force -Name "php"
Stop-Process -Force -Name "php-cgi"
Stop-Process -Force -Name "php-win"
Stop-Process -Force -Name "phpdbg"

"Deleting PHP directory"
Remove-Item $dir -Force -Recurse