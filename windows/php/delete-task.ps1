#Deletes task for starting PHP CGI/FastCGI automatically.

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

Write-Verbose "Deleting task for starting PHP CGI/FastCGI automatically"
Unregister-ScheduledTask "PHP-CGI" -Confirm:$false
