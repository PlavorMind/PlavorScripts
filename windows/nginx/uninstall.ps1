#Uninstalls nginx.

Param
([Parameter(Position=0)][string]$dir, #nginx directory
[switch]$portable) #Uninstall in portable mode

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{if (!(."${PSScriptRoot}/../../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/nginx"}

if (!($portable -or (Test-AdminPermission)))
{Write-Error "This script must be run as administrator unless you uninstall in portable mode." -Category PermissionDenied
exit}

if (!(Test-Path $dir))
{Write-Error "Cannot find nginx." -Category NotInstalled
exit}

if (Test-Path "${dir}/logs/nginx.pid")
{$nginx_pid=Get-Content "${dir}/logs/nginx.pid" -Force
if (Get-Process -ErrorAction Ignore -Id $nginx_pid)
  {Write-Verbose "Stopping nginx"
  ."${dir}/nginx.exe" -s stop
  Start-Sleep 5}
}

if (!$portable)
{if (Get-NetFirewallRule -ErrorAction Ignore -Name "nginx")
  {Write-Verbose "Deleting the firewall rule"
  Remove-NetFirewallRule -Name "nginx"}

if (Get-ScheduledTask "nginx" -ErrorAction Ignore)
  {Write-Verbose "Deleting the scheduled task"
  Unregister-ScheduledTask "nginx" -Confirm:$false}
}

Write-Verbose "Deleting nginx directory"
Remove-Item $dir -Force -Recurse
