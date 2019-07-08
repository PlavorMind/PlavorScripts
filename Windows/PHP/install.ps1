#PHP installer
#Installs PHP with APCu and imagick extension.

param
([string]$apcu_archive="https://windows.php.net/downloads/pecl/releases/apcu/5.1.17/php_apcu-5.1.17-7.3-nts-vc15-x64.zip", #URL or file path to APCu archive
[string]$dir="C:/plavormind/php", #Directory to install PHP
[string]$php_archive="https://windows.php.net/downloads/snaps/php-7.3/re3c701e/php-7.3-nts-windows-vc15-x64-re3c701e.zip") #URL or file path to PHP archive

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
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

$output=FileURLDetector $php_archive
if ($output)
{Expand-Archive $output "${tempdir}/PHP" -Force
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else 
{"Cannot download or find PHP archive."
exit}

$output=FileURLDetector $apcu_archive
if ($output)
{Expand-Archive $output "${tempdir}/APCu" -Force
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else 
{"Cannot download or find APCu archive."
exit}

"Moving APCu"
Move-Item "${tempdir}/APCu/php_apcu.dll" "${tempdir}/PHP/ext/" -Force
"Deleting a temporary directory"
Remove-Item "${tempdir}/APCu" -Force -Recurse

"Creating data directory"
New-Item "${tempdir}/PHP/data" -Force -ItemType Directory

"Downloading CA certificate"
Invoke-WebRequest "https://curl.haxx.se/ca/cacert.pem" -DisableKeepAlive -OutFile "${tempdir}/PHP/data/cacert.pem"
if (!(Test-Path "${tempdir}/PHP/data/cacert.pem"))
{"Cannot download CA certificate."
exit}

if (Test-Path "${PSScriptRoot}/../../filter_php_ini.ps1")
{."${PSScriptRoot}/../../filter_php_ini.ps1" -destpath "${tempdir}/PHP/php.ini"
if (!(Test-Path "${tempdir}/PHP/php.ini"))
  {exit}
}
else
{"Cannot find filter php.ini script."
exit}

"Copying install data"
Copy-Item "${PSScriptRoot}/install_data/start.ps1" "${tempdir}/PHP/" -Force
Copy-Item "${PSScriptRoot}/install_data/stop.ps1" "${tempdir}/PHP/" -Force

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/PHP/install.txt" -Force
Remove-Item "${tempdir}/PHP/license.txt" -Force
Remove-Item "${tempdir}/PHP/news.txt" -Force
Remove-Item "${tempdir}/PHP/php.gif" -Force
Remove-Item "${tempdir}/PHP/php.ini-development" -Force
Remove-Item "${tempdir}/PHP/php.ini-production" -Force
Remove-Item "${tempdir}/PHP/readme-redist-bins.txt" -Force
Remove-Item "${tempdir}/PHP/snapshot.txt" -Force

"Uninstalling existing PHP"
."${PSScriptRoot}/uninstall.ps1" -dir $dir

"Moving PHP directory"
Move-Item "${tempdir}/PHP" $dir -Force

."${PSScriptRoot}/create_task.ps1" -path "${dir}/start.ps1"
