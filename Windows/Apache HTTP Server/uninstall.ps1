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
{."${dir}/bin/httpd.exe" -k stop
."${dir}/bin/httpd.exe" -k uninstall}

Remove-Item $dir -Force -Recurse