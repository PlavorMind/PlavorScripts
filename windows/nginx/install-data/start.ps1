#Starts nginx. Restarts it if it is already running.

Param([Parameter()]$x) #Parameter added just for making the -Verbose parameter work and does nothing

if (Test-Path "${PSScriptRoot}/logs/nginx.pid")
{$nginx_pid=Get-Content "${PSScriptRoot}/logs/nginx.pid" -Force
if (Get-Process -ErrorAction Ignore -Id $nginx_pid)
  {Write-Verbose "Stopping nginx"
  ."${PSScriptRoot}/nginx.exe" -s stop}
}

Write-Verbose "Starting nginx"
Start-Process "${PSScriptRoot}/nginx.exe" -WorkingDirectory $PSScriptRoot
