#Maintain wikis
#Runs some maintenance tasks for PlavorMind wikis.

param
([string]$mediawiki_dir="__DEFAULT__", #Directory that MediaWiki is installed
[string]$private_data_dir="__DEFAULT__") #Directory that contains private data for PlavorMind wikis

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
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
{."${PSScriptRoot}/run_script_globally.ps1" -dir $mediawiki_dir -script "purgeExpiredUserrights.php"
."${PSScriptRoot}/run_script_globally.ps1" -dir $mediawiki_dir -script "pruneFileCache.php --agedays 0"
."${PSScriptRoot}/run_script_globally.ps1" -dir $mediawiki_dir -script "purgeOldText.php --purge"
."${PSScriptRoot}/run_script_globally.ps1" -dir $mediawiki_dir -script "runJobs.php"

if (Test-Path "${private_data_dir}/databases/locks")
  {"Deleting locks directory"
  Remove-Item "${private_data_dir}/databases/locks" -Force -Recurse}

$wikis=Get-ChildItem "${mediawiki_dir}/data" -Directory -Force -Name
foreach ($wiki in $wikis)
  {if (Test-Path "${private_data_dir}/${wiki}/cache")
    {"Deleting cache directory"
    Remove-Item "${private_data_dir}/${wiki}/cache" -Force -Recurse}

  if (Test-Path "${private_data_dir}/${wiki}/files/thumb")
    {"Deleting thumb directory"
    Remove-Item "${private_data_dir}/${wiki}/files/thumb" -Force -Recurse}
  }
}
else
{"Cannot find MediaWiki directory."}