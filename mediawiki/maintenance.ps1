#Runs some maintenance task for MediaWiki.

Param
([switch]$flow_init, #Run scripts to initialize Flow
[switch]$init, #Run scripts to initialize MediaWiki
[Parameter(Position=0)][string]$mediawiki_dir, #MediaWiki directory
[string]$php_path, #Path of PHP
[string]$private_data_dir, #Private data directory
[switch]$update, #Run update.php script
[string]$wiki) #Specify wiki ID to run scripts otherwise will run globally

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}
if (!$private_data_dir)
{$private_data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}

if (!(Test-Path $mediawiki_dir))
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

if ($wiki)
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

if ($flow_init)
  {if (Test-Path "${mediawiki_dir}/extensions/Flow")
    {Write-Verbose "Running emptyUserGroup.php for ${target_wiki}"
    .$php_path "${mediawiki_dir}/maintenance/emptyUserGroup.php" "flow-bot" --wiki $target_wiki
    Write-Verbose "Running populateContentModel.php for ${target_wiki}"
    .$php_path "${mediawiki_dir}/maintenance/populateContentModel.php" --ns=all --table=archive --wiki $target_wiki
    .$php_path "${mediawiki_dir}/maintenance/populateContentModel.php" --ns=all --table=page --wiki $target_wiki
    .$php_path "${mediawiki_dir}/maintenance/populateContentModel.php" --ns=all --table=revision --wiki $target_wiki}
  else
    {Write-Warning "Skipped running scripts to initialize Flow: Cannot find Flow."}
  }

Write-Verbose "Running purgeExpiredUserrights.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/purgeExpiredUserrights.php" --wiki $target_wiki
Write-Verbose "Running pruneFileCache.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/pruneFileCache.php" --agedays 0 --wiki $target_wiki
Write-Verbose "Running runJobs.php for ${target_wiki}"
.$php_path "${mediawiki_dir}/maintenance/runJobs.php" --wiki $target_wiki}
