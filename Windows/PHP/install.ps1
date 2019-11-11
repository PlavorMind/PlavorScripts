#Installs PHP with APCu extension.

Param
([string]$apcu_archive="https://windows.php.net/downloads/pecl/snaps/apcu/5.1.18/php_apcu-5.1.18-7.4-nts-vc15-x64.zip", #URL or file path to APCu archive
[Parameter(Position=0)][string]$dir="C:/plavormind/php-nts", #Directory to install PHP
[string]$php_archive="https://windows.php.net/downloads/snaps/php-7.4/rce41795/php-7.4-nts-windows-vc15-x64-rce41795.zip") #URL or file path to PHP archive

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

#Check processes to avoid errors
if (Get-Process "php" -ErrorAction Ignore)
{"PHP is currently running."
exit}
if (Get-Process "php-cgi" -ErrorAction Ignore)
{"PHP CGI/FastCGI is currently running."
exit}
if (Get-Process "php-win" -ErrorAction Ignore)
{"php-win.exe is currently running."
exit}
if (Get-Process "phpdbg" -ErrorAction Ignore)
{"phpdbg.exe is currently running."
exit}

$output=Get-FilePathFromUri $php_archive
if ($output)
{Expand-Archive $output "${tempdir}/php" -Force
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else 
{"Cannot download or find PHP archive."
exit}

$output=Get-FilePathFromUri $apcu_archive
if ($output)
{Expand-Archive $output "${tempdir}/apcu" -Force
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else 
{"Cannot download or find APCu archive."
exit}

"Downloading CA certificate"
Invoke-WebRequest "https://curl.haxx.se/ca/cacert.pem" -DisableKeepAlive -OutFile "${tempdir}/cacert"
if (!(Test-Path "${tempdir}/cacert"))
{"Cannot download CA certificate."}

"Moving APCu"
Move-Item "${tempdir}/apcu/php_apcu.dll" "${tempdir}/php/ext/" -Force
"Deleting a temporary directory"
Remove-Item "${tempdir}/apcu" -Force -Recurse

if (Test-Path "${tempdir}/cacert")
{"Creating data directory"
New-Item "${tempdir}/php/data" -Force -ItemType Directory
"Moving CA certificate"
Move-Item "${tempdir}/cacert" "${tempdir}/php/data/cacert.pem" -Force}

if (Test-Path "${PSScriptRoot}/../../filter-php-ini.ps1")
{."${PSScriptRoot}/../../filter-php-ini.ps1" -destpath "${tempdir}/php/php.ini"
if (!(Test-Path "${tempdir}/php/php.ini"))
  {exit}
}
else
{"Cannot find filter php.ini script."
exit}

"Copying install data"
Copy-Item "${PSScriptRoot}/install-data/start.ps1" "${tempdir}/php/" -Force
Copy-Item "${PSScriptRoot}/install-data/stop.ps1" "${tempdir}/php/" -Force

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/php/license.txt" -Force
Remove-Item "${tempdir}/php/news.txt" -Force
Remove-Item "${tempdir}/php/php.ini-development" -Force
Remove-Item "${tempdir}/php/php.ini-production" -Force
Remove-Item "${tempdir}/php/readme-redist-bins.txt" -Force
Remove-Item "${tempdir}/php/snapshot.txt" -Force

"Uninstalling existing PHP"
."${PSScriptRoot}/uninstall.ps1" $dir
"Moving PHP directory"
Move-Item "${tempdir}/php" $dir -Force

if (Test-AdminPermission)
{."${PSScriptRoot}/create-task.ps1" "${dir}/start.ps1"}