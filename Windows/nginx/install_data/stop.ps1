#Stop nginx
#Stops nginx.

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}
else
{"nginx is not running."}