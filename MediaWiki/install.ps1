#Install MediaWiki
#Wrapper for install.php with some predefined parameters.

param
([string]$mediawiki_dir="__DEFAULT__", #Directory to configure for MediaWiki
[string]$private_data_dir="__DEFAULT__", #Directory to configure for private data
[string]$user="PlavorSeol", #User to create during installation and add to the steward group
[string]$wiki, #Wiki ID
[string]$wiki_name) #Wiki name

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

if (Test-Path "${mediawiki_dir}/maintenance/install.php")
{New-Item "${mediawiki_dir}/data/${wiki}" -Force -ItemType Directory
New-Item "${private_data_dir}/${wiki}" -Force -ItemType Directory
New-Item "${private_data_dir}/${wiki}/deleted_files" -Force -ItemType Directory
New-Item "${private_data_dir}/${wiki}/files" -Force -ItemType Directory

if (!(Test-Path "${mediawiki_dir}/data/${wiki}/settings.php"))
  {"<?php `$wgSitename=`"${wiki_name}`"; ?>">"${mediawiki_dir}/data/${wiki}/settings.php"}
if (!(Test-Path "${mediawiki_dir}/data/${wiki}/extra_settings.php"))
  {"<?php ?>">"${mediawiki_dir}/data/${wiki}/extra_settings.php"}

php "${mediawiki_dir}/maintenance/install.php" --confpath "${private_data_dir}/${wiki}/LocalSettings.php" --dbname "${wiki}_wiki" --dbpassfile "${PSScriptRoot}/additional_files/database_password.txt" --dbpath "${private_data_dir}/databases" --dbserver "localhost" --dbtype "mysql" --installdbuser "root" --lang "en" --passfile "${PSScriptRoot}/additional_files/user_password.txt" --scriptpath "/mediawiki" $wiki_name $user

."${PSScriptRoot}/init_maintenance.ps1" -dir "${tempdir}/MediaWiki" -steward $user -wiki $wiki}
else
{"Cannot find install.php file."}