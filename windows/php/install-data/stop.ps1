#Stops PHP CGI/FastCGI.

Param([Parameter()]$x) #Parameter added just for making the -Verbose parameter work and does nothing

if (Get-Process "php-cgi" -ErrorAction Ignore)
{Write-Verbose "Stopping PHP CGI/FastCGI"
Stop-Process -Force -Name "php-cgi"}
else
{Write-Error "PHP CGI/FastCGI is not running."}
