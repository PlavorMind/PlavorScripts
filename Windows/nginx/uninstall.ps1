#Uninstalls nginx.

Param([Parameter(Position=0)][string]$dir="C:/plavormind/nginx") #Directory that nginx is installed

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{"Cannot find nginx."
exit}

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}

if (Test-AdminPermission)
{."${PSScriptRoot}/delete-task.ps1"}

"Deleting nginx directory"
Remove-Item $dir -Force -Recurse
