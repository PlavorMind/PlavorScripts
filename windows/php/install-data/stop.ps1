#Stops PHP CGI/FastCGI.

if (Get-Process "php-cgi" -ErrorAction Ignore)
{Write-Verbose "Stopping PHP CGI/FastCGI"
Stop-Process -Force -Name "php-cgi"}
else
{Write-Error "PHP CGI/FastCGI is not running."}
