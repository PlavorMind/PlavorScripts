#Install MediaWiki
#Wrapper for install.php with some predefined parameters.

param
([string]$mediawiki_dir="__DEFAULT__", #Directory to configure for MediaWiki
[string]$private_data_dir="__DEFAULT__", #Directory to configure for private data
[string]$user="PlavorSeol", #User to create during installation and add to the steward group
[string]$wiki, #Wiki ID
[string]$wiki_name="") #Wiki name

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

if (Test-Path $mediawiki_dir)
{"Creating data directory"
New-Item "${mediawiki_dir}/data" -Force -ItemType Directory
"Creating data directory for ${wiki}"
New-Item "${mediawiki_dir}/data/${wiki}" -Force -ItemType Directory
"Creating private data directory"
New-Item $private_data_dir -Force -ItemType Directory
"Creating private data directory for ${wiki}"
New-Item "${private_data_dir}/${wiki}" -Force -ItemType Directory
"Creating deleted_files directory for ${wiki}"
New-Item "${private_data_dir}/${wiki}/deleted_files" -Force -ItemType Directory
"Creating files directory for ${wiki}"
New-Item "${private_data_dir}/${wiki}/files" -Force -ItemType Directory

if (Test-Path "${mediawiki_dir}/LocalSettings.php")
  {"Renaming LocalSettings.php file temporarily"
  Move-Item "${mediawiki_dir}/LocalSettings.php" "${mediawiki_dir}/LocalSettings_temp.php" -Force}

"Running installation script"
php "${mediawiki_dir}/maintenance/install.php" --confpath "${private_data_dir}/${wiki}" --dbname "${wiki}_wiki" --dbpath "${private_data_dir}/databases" --installdbpass "" --passfile "" $user

if (Test-Path "${mediawiki_dir}/LocalSettings.php")
  {"Restoring LocalSettings.php file"
  Move-Item "${mediawiki_dir}/LocalSettings_temp.php" "${mediawiki_dir}/LocalSettings.php" -Force}

."${PSScriptRoot}/init_maintenance.ps1" -dir $mediawiki_dir -steward $user -wiki $wiki}
else
{"Cannot find MediaWiki directory."}
