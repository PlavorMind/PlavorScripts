#Starts PHP CGI/FastCGI.

Param([Parameter(Position=0)][string]$bind="127.0.0.1:9000") #Bind path for CGI/FastCGI

if (Get-Process "php-cgi" -ErrorAction Ignore)
{"PHP CGI/FastCGI is already running."}
else
{while (!(Test-Path "${PSScriptRoot}/stop-php-cgi"))
  {"Starting PHP CGI/FastCGI"
  ."${PSScriptRoot}/php-cgi.exe" -b $bind}
Remove-Item "${PSScriptRoot}/stop-php-cgi" -Force}
