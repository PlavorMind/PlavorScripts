#Runs some MediaWiki maintenance scripts.

Param
([switch]$init, #Run scripts to initialize MediaWiki
[Parameter(Position=0)][string]$mediawiki_dir, #MediaWiki directory
[string]$php_path, #Path to PHP
[string]$private_data_dir, #Private data directory
[switch]$update, #Run update.php script
[string]$wiki) #Specify wiki ID to run scripts otherwise will run globally

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$mediawiki_dir)
{if ($IsLinux)
  {$mediawiki_dir="/plavormind/web/public/wiki/mediawiki"}
elseif ($IsWindows)
  {$mediawiki_dir="C:/plavormind/web/public/wiki/mediawiki"}
else
  {Write-Error "Cannot detect default MediaWiki directory." -Category NotSpecified
  exit}
}

if (!$php_path)
{if ($IsWindows)
  {$php_path="C:/plavormind/php-ts/php.exe"}
else
  {Write-Error "Cannot detect default PHP path." -Category NotSpecified
  exit}
}

if (!$private_data_dir)
{if ($IsLinux)
  {$private_data_dir="/plavormind/web/data/mediawiki"}
elseif ($IsWindows)
  {$private_data_dir="C:/plavormind/web/data/mediawiki"}
else
  {Write-Error "Cannot detect default private data directory." -Category NotSpecified
  exit}
}

if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

if (Test-Path $mediawiki_dir)
{if ($wiki)
  {$target_wikis=@($wiki)}
else
  {$target_wikis=Get-ChildItem "${mediawiki_dir}/data" -Directory -Force -Name}
foreach ($target_wiki in $target_wikis)
  {if ($init -or $update)
    {Write-Verbose "Running update.php for ${target_wiki}"
    .$php_path "${mediawiki_dir}/maintenance/update.php" --doshared --quick --wiki $target_wiki}

  if ($init)
    {Write-Verbose "Running emptyUserGroup.php for ${target_wiki}"
    .$php_path "${mediawiki_dir}/maintenance/emptyUserGroup.php" "bureaucrat" --wiki $target_wiki
    .$php_path "${mediawiki_dir}/maintenance/emptyUserGroup.php" "interface-admin" --wiki $target_wiki
    .$php_path "${mediawiki_dir}/maintenance/emptyUserGroup.php" "sysop" --wiki $target_wiki}

  Write-Verbose "Running purgeExpiredUserrights.php for ${target_wiki}"
  .$php_path "${mediawiki_dir}/maintenance/purgeExpiredUserrights.php" --wiki $target_wiki
  Write-Verbose "Running pruneFileCache.php for ${target_wiki}"
  .$php_path "${mediawiki_dir}/maintenance/pruneFileCache.php" --agedays 0 --wiki $target_wiki
  Write-Verbose "Running runJobs.php for ${target_wiki}"
  .$php_path "${mediawiki_dir}/maintenance/runJobs.php" --wiki $target_wiki}
}
else
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled}
