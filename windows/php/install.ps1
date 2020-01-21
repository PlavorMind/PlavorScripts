#Installs PHP with some other software that depends on it.

Param
([string]$apcu_archive="https://windows.php.net/downloads/pecl/releases/apcu/5.1.18/php_apcu-5.1.18-7.4-ts-vc15-x64.zip", #URL or file path to APCu archive
[Parameter(Position=0)][string]$dir="C:/plavormind/php-ts", #Directory to install PHP
[string]$php_archive="https://windows.php.net/downloads/snaps/php-7.4/r7e9e093/php-7.4-ts-windows-vc15-x64-r7e9e093.zip") #URL or file path to PHP archive

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

$output=Get-FilePathFromUri $php_archive
if ($output)
{Write-Verbose "Extracting PHP"
Expand-Archive $output "${tempdir}/php" -Force
if ($output -like "${tempdir}*")
  {Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item $output -Force}
}
else 
{Write-Error "Cannot download or find PHP." -Category ObjectNotFound
exit}

$output=Get-FilePathFromUri $apcu_archive
if ($output)
{Write-Verbose "Extracting APCu"
Expand-Archive $output "${tempdir}/apcu" -Force
Write-Verbose "Deleting a file and directory that is no longer needed"
if ($output -like "${tempdir}*")
  {Remove-Item $output -Force}
Move-Item "${tempdir}/apcu/php_apcu.dll" "${tempdir}/php/ext/" -Force
Remove-Item "${tempdir}/apcu" -Force -Recurse}
else 
{Write-Error "Cannot download or find APCu." -Category ObjectNotFound
exit}

Write-Verbose "Downloading CA certificate"
Invoke-WebRequest "https://curl.haxx.se/ca/cacert.pem" -DisableKeepAlive -OutFile "${tempdir}/cacert"
if (!(Test-Path "${tempdir}/cacert"))
{Write-Error "Cannot download CA certificate." -Category ConnectionError}

Write-Verbose "Downloading Composer"
Invoke-WebRequest "https://getcomposer.org/composer.phar" -DisableKeepAlive -OutFile "${tempdir}/composer"
if (!(Test-Path "${tempdir}/composer"))
{Write-Error "Cannot download Composer." -Category ConnectionError}

if (Test-Path "${PSScriptRoot}/../../filter-php-ini.ps1")
{."${PSScriptRoot}/../../filter-php-ini.ps1" -destpath "${tempdir}/php/php.ini"
if (!(Test-Path "${tempdir}/php/php.ini"))
  {exit}
}
else
{Write-Error "Cannot find filter-php-ini.ps1 script." -Category ObjectNotFound
exit}

Write-Verbose "Configuring PHP directory"
New-Item "${tempdir}/php/data" -Force -ItemType Directory
if (Test-Path "${tempdir}/cacert")
{Move-Item "${tempdir}/cacert" "${tempdir}/php/data/cacert.pem" -Force}
if (Test-Path "${tempdir}/composer")
{Move-Item "${tempdir}/composer" "${tempdir}/php/data/composer.phar" -Force}

Write-Verbose "Copying install data"
Copy-Item "${PSScriptRoot}/install-data/start.ps1" "${tempdir}/php/" -Force
Copy-Item "${PSScriptRoot}/install-data/stop.ps1" "${tempdir}/php/" -Force

Write-Verbose "Deleting files that are unnecessary for running"
Remove-Item "${tempdir}/php/license.txt" -Force
Remove-Item "${tempdir}/php/news.txt" -Force
Remove-Item "${tempdir}/php/php.ini-development" -Force
Remove-Item "${tempdir}/php/php.ini-production" -Force
Remove-Item "${tempdir}/php/README.md" -Force
Remove-Item "${tempdir}/php/readme-redist-bins.txt" -Force
Remove-Item "${tempdir}/php/snapshot.txt" -Force
Remove-Item "${tempdir}/php/logs" -Force -Recurse

if (Test-Path $dir)
{Write-Warning "Uninstalling existing PHP"
."${PSScriptRoot}/uninstall.ps1" $dir}
Write-Verbose "Moving PHP directory from temporary directory to destination directory"
Move-Item "${tempdir}/php" $dir -Force
