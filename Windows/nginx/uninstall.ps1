#nginx uninstaller
#Uninstalls nginx.

param([string]$dir="C:/nginx") #Directory that nginx is installed

."${PSScriptRoot}/../../init_script.ps1"

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{"Cannot find nginx."
exit}

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}

"Deleting nginx directory"
Remove-Item $dir -Force -Recurse