#Start CGI/FastCGI
#Starts PHP CGI/FastCGI.

param([string]$bind="127.0.0.1:90") #Bind path for CGI/FastCGI

if (Get-Process "php-cgi" -ErrorAction Ignore)
{"PHP CGI/FastCGI is already running."}
else
{while (!(Test-Path "${PSScriptRoot}/stop_php_cgi"))
  {"Starting PHP CGI/FastCGI"
  ."${PSScriptRoot}/php-cgi.exe" -b $bind}
Remove-Item "${PSScriptRoot}/stop_php_cgi" -Force}
