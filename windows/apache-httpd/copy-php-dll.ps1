#Copys DLL files from PHP directory to Apache HTTP Server directory.
#Some DLL files must be copied from PHP directory to Apache HTTP Server directory to load some PHP extensions.

Param
([Parameter(Position=1)][string]$apache_httpd_dir="C:/plavormind/apache-httpd", #Apache HTTP Server directory
[Parameter(Position=0)][string]$php_dir="C:/plavormind/php") #PHP directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{if (!(."${PSScriptRoot}/../../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!(Test-Path $apache_httpd_dir))
{Write-Error "Cannot find Apache HTTP Server directory." -Category ObjectNotFound
exit}
if (!(Test-Path $php_dir))
{Write-Error "Cannot find PHP directory." -Category ObjectNotFound
exit}

Write-Verbose "Copying DLL files"
Copy-Item "${php_dir}/icudt66.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/icuin66.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/icuio66.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/icuuc66.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/libssh2.dll" "${apache_httpd_dir}/bin/" -Force
Copy-Item "${php_dir}/libsqlite3.dll" "${apache_httpd_dir}/bin/" -Force
