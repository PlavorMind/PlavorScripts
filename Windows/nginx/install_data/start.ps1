#Starts nginx. Restarts it if it is already running.

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}

"Starting nginx"
Start-Process "${PSScriptRoot}/nginx.exe" -WorkingDirectory $PSScriptRoot
