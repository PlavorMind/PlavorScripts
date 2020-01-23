#Enables the scheduled task for starting PHP CGI/FastCGI automatically

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

if (Get-ScheduledTask "PHP CGI FastCGI" -ErrorAction Ignore)
{Write-Verbose "Enabling the scheduled task"
Enable-ScheduledTask "PHP CGI FastCGI"}
else
{Write-Error "Cannot find the scheduled task." -Category ObjectNotFound}
