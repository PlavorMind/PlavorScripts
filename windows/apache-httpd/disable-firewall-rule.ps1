#Disables the firewall rule for allowing connections to Apache HTTP Server

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

if (Get-NetFirewallRule -ErrorAction Ignore -Name "apache-httpd")
{Write-Verbose "Disabling the firewall rule"
Disable-NetFirewallRule -Name "apache-httpd"}
else
{Write-Error "Cannot find the firewall rule." -Category ObjectNotFound}
