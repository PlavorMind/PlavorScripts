#Uninstalls Apache HTTP Server.

Param
([Parameter(Position=0)][string]$dir="C:/plavormind/apache-httpd", #Apache HTTP Server directory
[switch]$portable) #Whether to uninstall in portable mode

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!($portable -or (Test-AdminPermission)))
{Write-Error "This script must be run as administrator unless you uninstall in portable mode." -Category PermissionDenied
exit}

if (!(Test-Path $dir))
{Write-Error "Cannot find Apache HTTP Server." -Category NotInstalled
exit}

if (!$portable)
{Write-Verbose "Stopping service"
."${dir}/bin/httpd.exe" -k stop
Write-Verbose "Uninstalling service"
."${dir}/bin/httpd.exe" -k uninstall}

if (Test-Path "${dir}/logs/httpd.pid")
{$apache_httpd_pid=Get-Content "${dir}/logs/httpd.pid" -Force
if (Get-Process -ErrorAction Ignore -Id $apache_httpd_pid)
  {Write-Verbose "Stopping Apache HTTP Server"
  Stop-Process $apache_httpd_pid
  Start-Sleep 5}
}

Write-Verbose "Deleting Apache HTTP Server directory"
Remove-Item $dir -Force -Recurse