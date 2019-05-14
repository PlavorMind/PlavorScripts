#MediaWiki upgrader
#Upgrades MediaWiki.

param
([string]$core_branch="wmf/1.34.0-wmf.3", #Branch for MediaWiki core
[string]$dir="/web/wiki/mediawiki", #Directory that MediaWiki is installed
[string]$extensions_branch="master", #Branch for extensions
[switch]$plavormind, #Configure wiki directories based on PlavorMind configurations if this parameter is set
[string]$skins_branch="master") #Branch for skins

."${PSScriptRoot}/../modules/SetTempDir.ps1"

$dir_temp=$dir
."${PSScriptRoot}/download.ps1" -core_branch $core_branch -dir "${tempdir}/MediaWiki_upgrade" -extension_DeleteUserPages -extensions_branch $extensions_branch -skins_branch $skins_branch
$dir=$dir_temp

if ($plavormind)
{if (Test-Path "${dir}/data")
  {"Copying existing data directory"
  Copy-Item "${dir}/data" "${tempdir}/MediaWiki_upgrade/" -Force -Recurse}
if (Test-Path "${dir}/private_data")
  {"Copying existing private_data directory"
  Copy-Item "${dir}/private_data" "${tempdir}/MediaWiki_upgrade/" -Force -Recurse}
"Deleting core cache directory"
Remove-Item "${tempdir}/MediaWiki_upgrade/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki_upgrade/images" -Force -Recurse}
elseif (Test-Path "${dir}/images")
{"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki_upgrade/images" -Force -Recurse
"Copying existing images directory"
Copy-Item "${dir}/images" "${tempdir}/MediaWiki_upgrade/images" -Force -Recurse}
if (Test-Path "${dir}/LocalSettings.php")
{"Copying existing LocalSettings.php file"
Copy-Item "${dir}/LocalSettings.php" "${tempdir}/MediaWiki_upgrade/LocalSettings.php" -Force}

"Running update.php"
php "${tempdir}/MediaWiki_upgrade/maintenance/update.php" --doshared --quick
"Running runJobs.php"
php "${tempdir}/MediaWiki_upgrade/maintenance/runJobs.php"

if (Test-Path $dir)
{"Renaming existing MediaWiki directory"
Move-Item $dir "${dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki_upgrade" $dir -Force

if ($IsLinux)
{"Changing ownership of MediaWiki directory"
chown "www-data" $dir -R
"Changing permissions of MediaWiki directory"
chmod 755 $dir -R
chmod 700 "${dir}/private_data" -R}