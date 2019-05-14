#Stop CGI/FastCGI
#Stops PHP CGI/FastCGI.

if (Get-Process "php-cgi" -ErrorAction Ignore)
{"Stopping PHP CGI/FastCGI"
"" > "${PSScriptRoot}/stop_php_cgi"
Stop-Process -Force -Name "php-cgi"}
else
{"PHP CGI/FastCGI is not running."}