#Starts PHP CGI/FastCGI. Restarts it if it is already running.

Param([Parameter(Position=0)][string]$bind="127.0.0.1:9000") #Bind path for CGI/FastCGI

if (Get-Process "php-cgi" -ErrorAction Ignore)
{Write-Verbose "Stopping PHP CGI/FastCGI"
Stop-Process -Force -Name "php-cgi"}

$Env:PHP_FCGI_MAX_REQUESTS=0
Write-Verbose "Starting PHP CGI/FastCGI"
."${PSScriptRoot}/php-cgi.exe" -b $bind
