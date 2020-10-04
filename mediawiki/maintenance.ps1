#Runs some maintenance task for MediaWiki.

Param
([string]$data_dir, #Data directory
[switch]$init, #Run scripts to initialize MediaWiki
[Parameter(Position=0)][string]$mediawiki_dir, #MediaWiki directory
[string]$php_path, #Path of PHP
[switch]$update, #Run update.php script
[string]$wiki) #Specify wiki ID to run scripts otherwise will run globally

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$data_dir)
{$data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}
if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}

if (!(Test-Path $mediawiki_dir))
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

if ($wiki)
{$target_wikis=@($wiki)}
else
{$target_wikis=Get-ChildItem "${data_dir}/per-wiki" -Directory -Force -Name}

foreach ($target_wiki in $target_wikis)
{if ($init -or $update)
  {Write-Verbose "Running update.php for ${target_wiki}"
  .$php_path "${mediawiki_dir}/maintenance/update.php" --doshared --quick --wiki $target_wiki}

if ($init)
  {Write-Verbose "Running emptyUserGroup.php for ${target_wiki}"
  .$php_path "${mediawiki_dir}/maintenance/emptyUserGroup.php" "bureaucrat" --wiki $target_wiki
  .$php_path "${mediawiki_dir}/maintenance/emptyUserGroup.php" "interface-admin" --wiki $target_wiki
  .$php_path "${mediawiki_dir}/maintenance/emptyUserGroup.php" "sysop" --wiki $target_wiki}

Write-Verbose "Running pruneFileCache.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/pruneFileCache.php" --agedays 0 --wiki $target_wiki
Write-Verbose "Running purgeExpiredBlocks.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/purgeExpiredBlocks.php" --wiki $target_wiki
Write-Verbose "Running purgeExpiredUserrights.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/purgeExpiredUserrights.php" --wiki $target_wiki
Write-Verbose "Running purgeExpiredWatchlistItems.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/purgeExpiredWatchlistItems.php" --wiki $target_wiki
Write-Verbose "Running purgeParserCache.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/purgeParserCache.php" --age 0 --wiki $target_wiki
Write-Verbose "Running runJobs.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/runJobs.php" --wiki $target_wiki}
