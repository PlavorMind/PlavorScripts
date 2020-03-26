#Disables the scheduled task for starting PHP CGI/FastCGI automatically

Param([Parameter()]$x) #Parameter added just for making the -Verbose parameter work and does nothing

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{if (!(."${PSScriptRoot}/../../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

if (Get-ScheduledTask "PHP CGI FastCGI" -ErrorAction Ignore)
{Write-Verbose "Disabling the scheduled task"
Disable-ScheduledTask "PHP CGI FastCGI"}
else
{Write-Error "Cannot find the scheduled task." -Category ObjectNotFound}
