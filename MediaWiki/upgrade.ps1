#MediaWiki upgrader
#Upgrades MediaWiki.

param
([string]$core_branch="wmf/1.34.0-wmf.8", #Branch for MediaWiki core
[string]$dir="__DEFAULT__", #Directory that MediaWiki is installed
[string]$extra_branch="master") #Branch for extensions and skins

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$dir="/plavormind/web/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

$dir_temp=$dir
."${PSScriptRoot}/download.ps1" -core_branch $core_branch -dir "${tempdir}/MediaWiki_upgrade" -extensions_branch $extra_branch -skins_branch $extra_branch
$dir=$dir_temp
Move-Item "${tempdir}/MediaWiki_upgrade" "${tempdir}/MediaWiki" -Force

if (Test-Path "${dir}/data")
{"Copying existing data directory"
Copy-Item "${dir}/data" "${tempdir}/MediaWiki/" -Force -Recurse}
if (Test-Path "${dir}/LocalSettings.php")
{"Copying existing LocalSettings.php file"
Copy-Item "${dir}/LocalSettings.php" "${tempdir}/MediaWiki/" -Force}
"Deleting core cache directory"
Remove-Item "${tempdir}/MediaWiki/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse

$wikis=Get-ChildItem "${tempdir}/MediaWiki/data" -Directory -Force -Name
foreach ($wiki in $wikis)
{"Running update.php for ${wiki}"
php "${tempdir}/MediaWiki/maintenance/update.php" --doshared --quick --wiki $wiki}

."${PSScriptRoot}/cleanup.ps1" -mediawiki_dir "${tempdir}/MediaWiki"

if (Test-Path $dir)
{"Renaming existing MediaWiki directory"
Move-Item $dir "${dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki" $dir -Force

if ($IsLinux)
{"Changing ownership of MediaWiki directory"
chown "www-data" $dir -R
"Changing permissions of MediaWiki directory"
chmod 755 $dir -R}
