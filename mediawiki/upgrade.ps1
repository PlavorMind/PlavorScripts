# Upgrades MediaWiki.
# Hacky fix

Param
# Path of Composer
([string]$composer_path,
# Branch for MediaWiki core
[string]$core_branch,
# Data directory
[string]$data_dir,
# Branch for extensions and skins
[string]$extra_branch = 'master',
# File path or URL of JSON file for downloading extensions and skins
[string]$extras_json = "${HOME}/OneDrive/Documents/mediawiki-extras.json",
# MediaWiki directory
[Parameter(Position=0)][string]$mediawiki_dir,
# Path of PHP
[string]$php_path)

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
  {."${PSScriptRoot}/../init-script.ps1" | Out-Null}
else
  {throw 'Cannot find init-script.ps1 file.'}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="${PlaScrDefaultBaseDirectory}/composer.phar"}
elseif ($IsWindows)
  {$composer_path="${PlaScrDefaultBaseDirectory}/composer/composer.phar"}
else
  {Write-Error "Cannot detect default Composer path." -Category NotSpecified
  exit}
}
if (!$data_dir)
{$data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}
if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}

if (!(Test-Path $composer_path))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

if (!$core_branch)
{$wikimedia_mediawiki_version=Invoke-RestMethod "https://noc.wikimedia.org/conf/wikiversions.json" -DisableKeepAlive
if ($wikimedia_mediawiki_version)
  {$core_branch=($wikimedia_mediawiki_version."mediawikiwiki").Replace("php-","wmf/")}
else
  {Write-Error "Cannot detect branch for MediaWiki core."
  exit}
}

."${PSScriptRoot}/download.ps1" "${PlaScrTempDirectory}/mw-upgrade" -branch $core_branch
if (Test-Path "${PlaScrTempDirectory}/mw-upgrade")
{Move-Item "${PlaScrTempDirectory}/mw-upgrade" "${PlaScrTempDirectory}/mediawiki" -Force
$mediawiki_dir_temp=$mediawiki_dir
."${PSScriptRoot}/download-extras.ps1" "${PlaScrTempDirectory}/mediawiki" $extras_json -composer_local_json "${mediawiki_dir}/composer.local.json" -composer_path $composer_path -extension_branch $extra_branch -php_path $php_path -skin_branch $extra_branch
$mediawiki_dir=$mediawiki_dir_temp}
else
{exit}

if (Test-Path "${mediawiki_dir}/LocalSettings.php")
{Write-Verbose "Copying existing LocalSettings.php file"
Copy-Item "${mediawiki_dir}/LocalSettings.php" "${PlaScrTempDirectory}/mediawiki/" -Force}
Write-Verbose "Deleting cache directory"
Remove-Item "${PlaScrTempDirectory}/mediawiki/cache" -Force -Recurse
Write-Verbose "Deleting images directory"
Remove-Item "${PlaScrTempDirectory}/mediawiki/images" -Force -Recurse

if (Test-Path $mediawiki_dir)
{Write-Warning "Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}-old" -Force}
Write-Verbose "Moving MediaWiki directory to destination directory"
Move-Item "${PlaScrTempDirectory}/mediawiki" $mediawiki_dir -Force

."${PSScriptRoot}/maintenance.ps1" $mediawiki_dir -data_dir $data_dir -php_path $php_path -update
