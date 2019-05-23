#MediaWiki installer
#Installs MediaWiki.

param
([string]$core_branch="wmf/1.34.0-wmf.6", #Branch for MediaWiki core
[string]$dir, #Directory to install MediaWiki
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

"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
{"Extracting"
Expand-Archive "${tempdir}/Configurations.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/Configurations.zip" -Force}
else
{"Cannot download Configurations repository archive."
exit}

$dir_temp=$dir
."${PSScriptRoot}/download.ps1" -core_branch $core_branch -dir "${tempdir}/MediaWiki_install" -extensions_branch $extensions_branch -skins_branch $skins_branch
$dir=$dir_temp
Move-Item "${tempdir}/MediaWiki_install" "${tempdir}/MediaWiki" -Force

if ($plavormind)
{"Moving configuration files" #Need test
Move-Item "${tempdir}/Configurations-Main/MediaWiki/*" "${tempdir}/MediaWiki/" -Force
if (Test-Path "${PSScriptRoot}/data")
  {"Copying files in data directory"
  Copy-Item "${PSScriptRoot}/data/*" "${tempdir}/MediaWiki/data/" -Force -Recurse}
if (Test-Path "${PSScriptRoot}/private_data")
  {"Copying private_data directory"
  Copy-Item "${PSScriptRoot}/private_data" "${tempdir}/MediaWiki/" -Force -Recurse}
"Deleting core cache directory"
Remove-Item "${tempdir}/MediaWiki/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse}

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse

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