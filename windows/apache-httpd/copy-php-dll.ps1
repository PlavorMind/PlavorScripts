#Copys DLL files from PHP directory to Apache HTTP Server directory.
#Some DLL files must be copied from PHP directory to Apache HTTP Server directory to load some PHP extensions.

Param
([Parameter(Position=1)][string]$apache_httpd_dir="C:/plavormind/apache-httpd", #Apache HTTP Server directory
[Parameter(Position=0)][string]$php_dir="C:/plavormind/php-ts") #PHP directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!(Test-Path $php_dir))
{Write-Error "Cannot find PHP directory." -Category ObjectNotFound
exit}
if (!(Test-Path $apache_httpd_dir))
{Write-Error "Cannot find Apache HTTP Server directory." -Category ObjectNotFound
exit}

Write-Verbose "Copying DLL files"
Copy-Item "${php_dir}/icudt65.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/icuin65.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/icuio65.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/icuuc65.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/libssh2.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/libsqlite3.dll" "${apache_httpd_dir}/bin/" -Force