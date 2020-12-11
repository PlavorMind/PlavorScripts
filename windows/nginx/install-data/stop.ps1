#Stops nginx.

if (Test-Path "${PSScriptRoot}/logs/nginx.pid")
{$nginx_pid=Get-Content "${PSScriptRoot}/logs/nginx.pid" -Force
if (Get-Process -ErrorAction Ignore -Id $nginx_pid)
  {Write-Verbose "Stopping nginx"
  ."${PSScriptRoot}/nginx.exe" -s stop}
else
  {Write-Error "nginx is not running."}
}
else
{Write-Error "nginx is not running."}
