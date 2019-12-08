#Uninstalls Apache HTTP Server.

Param([Parameter(Position=0)][string]$dir="C:/plavormind/apache-httpd") #Apache HTTP Server directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{Write-Error "Cannot find Apache HTTP Server." -Category NotInstalled
exit}

if (Test-AdminPermission)
{Write-Verbose "Stopping service"
."${dir}/bin/httpd.exe" -k stop
Write-Verbose "Uninstalling service"
."${dir}/bin/httpd.exe" -k uninstall}
else
{Write-Warning "Skipped uninstalling service: This script must be run as administrator to uninstall service."}

Write-Verbose "Deleting Apache HTTP Server directory"
Remove-Item $dir -Force -Recurse
