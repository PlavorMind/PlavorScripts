#PHP installer
#Installs PHP with APCu extension.

param
([string]$apcu_archive="https://windows.php.net/downloads/pecl/snaps/apcu/5.1.15/php_apcu-5.1.15-7.3-nts-vc15-x64.zip",
[string]$dir="C:/PHP",
[string]$php_archive="https://windows.php.net/downloads/snaps/php-7.3/r5c221bc/php-7.3-nts-windows-vc15-x64-r5c221bc.zip")

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

"Moving APCu"
Move-Item "${tempdir}/APCu/php_apcu.dll" "${tempdir}/PHP/ext/php_apcu.dll" -Force
"Deleting a temporary directory"
Remove-Item "${tempdir}/APCu" -Force -Recurse

."${PSScriptRoot}/../../filter_php_ini.ps1" -savepath "${tempdir}/PHP/php.ini"
if (!($fpi_success))
{"Cannot filter php.ini file."
exit}

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