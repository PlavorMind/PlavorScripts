#Enables the firewall rule for allowing connections to Apache HTTP Server

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

if (Get-NetFirewallRule -ErrorAction Ignore -Name "apache-httpd")
{Write-Verbose "Enabling the firewall rule"
Enable-NetFirewallRule -Name "apache-httpd"}
else
{Write-Error "Cannot find the firewall rule." -Category ObjectNotFound}
