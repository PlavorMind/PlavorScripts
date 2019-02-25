#Start nginx
#Starts nginx. Restarts it if it is already running.

."${PSScriptRoot}/stop.ps1"
"Starting nginx"
Start-Process "${PSScriptRoot}/nginx.exe" -WorkingDirectory $PSScriptRoot
