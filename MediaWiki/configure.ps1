#Initialize MediaWiki
#Initializes MediaWiki directories.

param
([string]$core_branch="wmf/1.34.0-wmf.11", #Branch for MediaWiki core
[string]$extra_branch="master", #Branch for extensions and skins
[string]$mediawiki_dir="__DEFAULT__", #Directory to configure for MediaWiki
[string]$private_data_dir="__DEFAULT__") #Directory to configure for private data

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

."${PSScriptRoot}/download.ps1" -core_branch $core_branch -dir "${tempdir}/MediaWiki_install" -extensions_branch $extra_branch -skins_branch $extra_branch
Move-Item "${tempdir}/MediaWiki_install" "${tempdir}/MediaWiki" -Force

"Moving configuration files"
Move-Item "${tempdir}/Configurations-Main/MediaWiki/*" "${tempdir}/MediaWiki/" -Force
"Deleting core cache directory"
Remove-Item "${tempdir}/MediaWiki/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse

if (Test-Path "${PSScriptRoot}/additional_files/data")
{"Copying additional files for data directory"
Copy-Item "${PSScriptRoot}/additional_files/data/*" "${tempdir}/MediaWiki/data/" -Force -Recurse}
if (Test-Path "${PSScriptRoot}/additional_files/private_data")
{"Copying additional files for private data directory"
Copy-Item "${PSScriptRoot}/additional_files/private_data" "${tempdir}/" -Force -Recurse}

$mediawiki_dir_temp=$mediawiki_dir
$private_data_dir_temp=$private_data_dir
."${PSScriptRoot}/run_script_globally.ps1" -dir "${tempdir}/MediaWiki" -script "update.php --doshared --quick"
."${PSScriptRoot}/maintain.ps1" -mediawiki_dir "${tempdir}/MediaWiki" -private_data_dir "${tempdir}/private_data"
$mediawiki_dir=$mediawiki_dir_temp
$private_data_dir=$private_data_dir_temp

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse

if (Test-Path $mediawiki_dir)
{"Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}_old" -Force}
if (Test-Path $private_data_dir)
{"Renaming existing MediaWiki directory"
Move-Item $private_data_dir "${private_data_dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki" $mediawiki_dir -Force
if (Test-Path "${tempdir}/private_data")
{"Moving private data directory"
Move-Item "${tempdir}/private_data" $private_data_dir -Force}

if ($IsLinux)
{"Changing ownership of MediaWiki directory"
chown "www-data" $mediawiki_dir -R
"Changing permissions of MediaWiki directory"
chmod 755 $mediawiki_dir -R
chmod 700 $private_data_dir -R}
