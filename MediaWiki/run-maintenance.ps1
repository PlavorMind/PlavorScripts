#Runs some MediaWiki maintenance scripts.

Param
([Parameter(Position=0)][string]$dir, #Directory that MediaWiki is installed
[string]$php_path, #Path to PHP
[switch]$update, #Run update.php script if this parameter is set
[string]$wiki) #Specify wiki ID to run scripts otherwise will run globally

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$dir)
{if ($IsLinux)
  {$dir="/plavormind/web/public/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web/public/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

if (!$php_path)
{if ($IsWindows)
  {$php_path="C:/plavormind/php-nts/php.exe"}
else
  {"Cannot detect default PHP path."
  exit}
}

if (!(Test-Path $php_path))
{"Cannot find PHP."
exit}

if (Test-Path $dir)
{if ($wiki)
  {$target_wikis=@($wiki)}
else
  {$target_wikis=Get-ChildItem "${dir}/data" -Directory -Force -Name}
foreach ($target_wiki in $target_wikis)
  {if ($update)
    {"Running update.php for ${target_wiki}"
    .$php_path "${dir}/maintenance/update.php" --quick --wiki $target_wiki}

  "Running purgeExpiredUserrights.php for ${target_wiki}"
  .$php_path "${dir}/maintenance/purgeExpiredUserrights.php" --wiki $target_wiki
  "Running pruneFileCache.php for ${target_wiki}"
  .$php_path "${dir}/maintenance/pruneFileCache.php" --agedays 0 --wiki $target_wiki
  "Running runJobs.php for ${target_wiki}"
  .$php_path "${dir}/maintenance/runJobs.php" --wiki $target_wiki}
}
else
{"Cannot find MediaWiki directory."}
