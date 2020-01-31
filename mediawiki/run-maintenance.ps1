#Runs some MediaWiki maintenance scripts.

Param
([Parameter(Position=0)][string]$dir, #Directory that MediaWiki is installed
[switch]$init, #Run scripts to initialize MediaWiki if this parameter is set
[string]$php_path, #Path to PHP
[switch]$update, #Run update.php script if this parameter is set
[string]$wiki) #Specify wiki ID to run scripts otherwise will run globally

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$dir)
{if ($IsLinux)
  {$dir="/plavormind/web/public/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web/public/wiki/mediawiki"}
else
  {Write-Error "Cannot detect default directory." -Category NotSpecified
  exit}
}

if (!$php_path)
{if ($IsWindows)
  {$php_path="C:/plavormind/php-ts/php.exe"}
else
  {Write-Error "Cannot detect default PHP path." -Category NotSpecified
  exit}
}

if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

if (Test-Path $dir)
{if ($wiki)
  {$target_wikis=@($wiki)}
else
  {$target_wikis=Get-ChildItem "${dir}/data" -Directory -Force -Name}
foreach ($target_wiki in $target_wikis)
  {if ($init -or $update)
    {Write-Verbose "Running update.php for ${target_wiki}"
    .$php_path "${dir}/maintenance/update.php" --doshared --quick --wiki $target_wiki}

  if ($init)
    {Write-Verbose "Running emptyUserGroup.php for ${target_wiki}"
    .$php_path "${dir}/maintenance/emptyUserGroup.php" "bureaucrat" --wiki $target_wiki
    .$php_path "${dir}/maintenance/emptyUserGroup.php" "interface-admin" --wiki $target_wiki
    .$php_path "${dir}/maintenance/emptyUserGroup.php" "sysop" --wiki $target_wiki}

  Write-Verbose "Running purgeExpiredUserrights.php for ${target_wiki}"
  .$php_path "${dir}/maintenance/purgeExpiredUserrights.php" --wiki $target_wiki
  Write-Verbose "Running pruneFileCache.php for ${target_wiki}"
  .$php_path "${dir}/maintenance/pruneFileCache.php" --agedays 0 --wiki $target_wiki
  Write-Verbose "Running runJobs.php for ${target_wiki}"
  .$php_path "${dir}/maintenance/runJobs.php" --wiki $target_wiki}
}
else
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled}
