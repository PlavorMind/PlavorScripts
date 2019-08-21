#MediaWiki upgrader
#Upgrades MediaWiki.

param
([string]$core_branch="wmf/1.34.0-wmf.19", #Branch for MediaWiki core
[string]$extra_branch="master", #Branch for extensions and skins
[string]$mediawiki_dir="__DEFAULT__", #Directory that MediaWiki is installed
[string]$private_data_dir="__DEFAULT__") #Directory that contains private data for PlavorMind wikis

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($mediawiki_dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$mediawiki_dir="/plavormind/web/wiki/mediawiki"}
elseif ($IsWindows)
  {$mediawiki_dir="C:/plavormind/web/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

if ($private_data_dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$private_data_dir="/plavormind/web_data/mediawiki"}
elseif ($IsWindows)
  {$private_data_dir="C:/plavormind/web_data/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

."${PSScriptRoot}/download.ps1" -core_branch $core_branch -dir "${tempdir}/MediaWiki_upgrade" -extensions_branch $extra_branch -skins_branch $extra_branch
Move-Item "${tempdir}/MediaWiki_upgrade" "${tempdir}/MediaWiki" -Force

if (Test-Path "${mediawiki_dir}/data")
{"Copying existing data directory"
Copy-Item "${mediawiki_dir}/data" "${tempdir}/MediaWiki/" -Force -Recurse}
if (Test-Path "${mediawiki_dir}/LocalSettings.php")
{"Copying existing LocalSettings.php file"
Copy-Item "${mediawiki_dir}/LocalSettings.php" "${tempdir}/MediaWiki/" -Force}
"Deleting core cache directory"
Remove-Item "${tempdir}/MediaWiki/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse

."${PSScriptRoot}/run_script_globally.ps1" -dir "${tempdir}/MediaWiki" -script "update.php --doshared --quick"
$mediawiki_dir_temp=$mediawiki_dir
."${PSScriptRoot}/maintain.ps1" -mediawiki_dir "${tempdir}/MediaWiki" -private_data_dir $private_data_dir
$mediawiki_dir=$mediawiki_dir_temp

if (Test-Path $mediawiki_dir)
{"Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki" $mediawiki_dir -Force

if ($IsLinux)
{"Changing ownership of MediaWiki directory"
chown "www-data" $mediawiki_dir -R
"Changing permissions of MediaWiki directory"
chmod 755 $mediawiki_dir -R
chmod 700 $private_data_dir -R}
