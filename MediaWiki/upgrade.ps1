#MediaWiki upgrader
#Upgrades MediaWiki.

param
([string]$core_branch="wmf/1.34.0-wmf.7", #Branch for MediaWiki core
[string]$dir, #Directory that MediaWiki is installed
[string]$extensions_branch="master", #Branch for extensions
[switch]$plavormind, #Configure wiki directories based on PlavorMind configurations if this parameter is set
[string]$skins_branch="master") #Branch for skins

."${PSScriptRoot}/../init_script.ps1"

if (!$dir)
{if ($IsLinux)
  {$dir="/web/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/nginx/web/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

$wikis=@("exit")

$dir_temp=$dir
."${PSScriptRoot}/download.ps1" -core_branch $core_branch -dir "${tempdir}/MediaWiki_upgrade" -extensions_branch $extensions_branch -skins_branch $skins_branch
$dir=$dir_temp
Move-Item "${tempdir}/MediaWiki_upgrade" "${tempdir}/MediaWiki" -Force

if ($plavormind)
{if (Test-Path "${dir}/data")
  {"Copying existing data directory"
  Copy-Item "${dir}/data" "${tempdir}/MediaWiki/" -Force -Recurse}
if (Test-Path "${dir}/private_data")
  {"Copying existing private_data directory"
  Copy-Item "${dir}/private_data" "${tempdir}/MediaWiki/" -Force -Recurse
  if (Test-Path "${tempdir}/MediaWiki/private_data/databases/locks")
    {"Deleting locks directory"
    Remove-Item "${tempdir}/MediaWiki/private_data/databases/locks" -Force -Recurse}
  foreach ($wiki in $wikis)
    {if (Test-Path "${tempdir}/MediaWiki/private_data/${wiki}/cache")
      {"Emptying cache directory"
      Remove-Item "${tempdir}/MediaWiki/private_data/${wiki}/cache/*" -Force -Recurse}
    if (Test-Path "${tempdir}/MediaWiki/private_data/${wiki}/files/thumb")
      {"Deleting thumb directory"
      Remove-Item "${tempdir}/MediaWiki/private_data/${wiki}/files/thumb" -Force -Recurse}
    }
  }
"Deleting core cache directory"
Remove-Item "${tempdir}/MediaWiki/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse}
elseif (Test-Path "${dir}/images")
{"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse
"Copying existing images directory"
Copy-Item "${dir}/images" "${tempdir}/MediaWiki/images" -Force -Recurse}
if (Test-Path "${dir}/LocalSettings.php")
{"Copying existing LocalSettings.php file"
Copy-Item "${dir}/LocalSettings.php" "${tempdir}/MediaWiki/LocalSettings.php" -Force}

if ($plavormind)
{foreach ($wiki in $wikis)
  {"Running update.php for ${wiki}"
  php "${tempdir}/MediaWiki/maintenance/update.php" --doshared --quick --wiki $wiki
  "Running runJobs.php for ${wiki}"
  php "${tempdir}/MediaWiki/maintenance/runJobs.php" --wiki $wiki}
}
else
{"Running update.php"
php "${tempdir}/MediaWiki/maintenance/update.php" --doshared --quick
"Running runJobs.php"
php "${tempdir}/MediaWiki/maintenance/runJobs.php"}

if (Test-Path $dir)
{"Renaming existing MediaWiki directory"
Move-Item $dir "${dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki" $dir -Force

if ($IsLinux)
{"Changing ownership of MediaWiki directory"
chown "www-data" $dir -R
"Changing permissions of MediaWiki directory"
chmod 755 $dir -R
chmod 700 "${dir}/private_data" -R}
