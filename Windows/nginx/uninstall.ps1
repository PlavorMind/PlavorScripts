#nginx uninstaller
#Uninstalls nginx.

param([string]$dir="C:/nginx")

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{"Cannot find nginx."
exit}

"Stopping nginx and PHP CGI/FastCGI"
Stop-Process -Force -Name "nginx"
Stop-Process -Force -Name "php-cgi"

"Deleting nginx directory"
Remove-Item "$dir" -Force -Recurse
