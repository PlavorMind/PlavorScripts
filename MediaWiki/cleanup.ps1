#Cleanup wikis
#Runs some maintenance tasks for PlavorMind wikis.

param
([string]$mediawiki_dir="__DEFAULT__", #Directory that MediaWiki is installed
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

if (Test-Path $mediawiki_dir)
{$wikis=Get-ChildItem "${mediawiki_dir}/data" -Directory -Force -Name
foreach ($wiki in $wikis)
  {"Running runJobs.php for ${wiki}"
  php "${mediawiki_dir}/maintenance/runJobs.php" --wiki $wiki

  if (Test-Path "${private_data_dir}/${wiki}/cache")
    {"Emptying cache directory"
    Remove-Item "${private_data_dir}/${wiki}/cache/*" -Force -Recurse}

  if (Test-Path "${private_data_dir}/${wiki}/files/thumb")
    {"Deleting thumb directory"
    Remove-Item "${private_data_dir}/${wiki}/files/thumb" -Force -Recurse}
  }

if (Test-Path "${private_data_dir}/databases/locks")
  {"Deleting locks directory"
  Remove-Item "${private_data_dir}/databases/locks" -Force -Recurse}
}
else
{"Cannot find MediaWiki directory."}
