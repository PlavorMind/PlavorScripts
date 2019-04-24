#PHP installer
#Installs PHP with APCu extension.

param
([string]$apcu_archive="https://windows.php.net/downloads/pecl/releases/apcu/5.1.17/php_apcu-5.1.17-7.3-nts-vc15-x64.zip", #URL or file path to APCu archive
[string]$dir="C:/PHP", #Directory to install PHP
[string]$imagick_archive="https://windows.php.net/downloads/pecl/releases/imagick/3.4.4rc2/php_imagick-3.4.4rc2-7.3-nts-vc15-x64.zip", #URL or file path to imagick archive
[string]$php_archive="https://windows.php.net/downloads/snaps/php-7.3/r191e153/php-7.3-nts-windows-vc15-x64-r191e153.zip") #URL or file path to PHP archive

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/../../modules/SetTempDir.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

."${PSScriptRoot}/../../modules/FileURLDetector.ps1" -path $php_archive
if ($fud_output)
{Expand-Archive $fud_output "${tempdir}/PHP" -Force
if ($fud_web)
  {Remove-Item $fud_output -Force}
}
else
{"Cannot download or find PHP archive."
exit}

."${PSScriptRoot}/../../modules/FileURLDetector.ps1" -path $apcu_archive
if ($fud_output)
{Expand-Archive $fud_output "${tempdir}/APCu" -Force
if ($fud_web)
  {Remove-Item $fud_output -Force}
}
else
{"Cannot download or find APCu archive."
exit}

."${PSScriptRoot}/../../modules/FileURLDetector.ps1" -path $imagick_archive
if ($fud_output)
{Expand-Archive $fud_output "${tempdir}/imagick" -Force
if ($fud_web)
  {Remove-Item $fud_output -Force}
}
else
{"Cannot download or find imagick archive."
exit}

"Moving APCu"
Move-Item "${tempdir}/APCu/php_apcu.dll" "${tempdir}/PHP/ext/" -Force
"Deleting a temporary directory"
Remove-Item "${tempdir}/APCu" -Force -Recurse

"Moving imagick"
Move-Item "${tempdir}/imagick/php_imagick.dll" "${tempdir}/PHP/ext/" -Force
Move-Item "${tempdir}/imagick/*.dll" "${tempdir}/PHP/" -Force
"Deleting a temporary directory"
Remove-Item "${tempdir}/imagick" -Force -Recurse

."${PSScriptRoot}/../../filter_php_ini.ps1" -savepath "${tempdir}/PHP/php.ini"
if (!($fpi_success))
{"Cannot filter php.ini file."
exit}

"Copying additional files"
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
