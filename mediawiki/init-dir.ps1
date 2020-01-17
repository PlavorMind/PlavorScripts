#Initializes directories for MediaWiki.

Param
([string]$composer_path, #Path to Composer
[string]$core_branch="wmf/1.35.0-wmf.15", #Branch for MediaWiki core
[string]$extra_branch="master", #Branch for extensions and skins
[Parameter(Position=0)][string]$mediawiki_dir, #Directory to configure for MediaWiki
[string]$php_path, #Path to PHP
[string]$private_data_dir) #Directory to configure for private data

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="/plavormind/composer.phar"}
elseif ($IsWindows)
  {$composer_path="C:/plavormind/php-ts/data/composer.phar"}
else
  {Write-Error "Cannot detect default Composer path." -Category NotSpecified
  exit}
}

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

if (!(Test-Path $composer_path))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

Write-Verbose "Downloading configurations"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/config.zip"
if ("${tempdir}/config.zip")
{Write-Verbose "Extracting"
Expand-Archive "${tempdir}/config.zip" $tempdir -Force
Write-Verbose "Deleting a file and directory that are no longer needed"
Remove-Item "${tempdir}/config.zip" -Force
Move-Item "${tempdir}/Configurations-Main/mediawiki" "${tempdir}/mediawiki-config" -Force
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse}
else
{Write-Error "Cannot download configurations." -Category ConnectionError
exit}

."${PSScriptRoot}/download.ps1" "${tempdir}/mw-install" -composer_path $composer_path -core_branch $core_branch -extensions_branch $extra_branch -php_path $php_path -skins_branch $extra_branch
Move-Item "${tempdir}/mw-install" "${tempdir}/mediawiki" -Force

Write-Verbose "Applying configurations"
Move-Item "${tempdir}/mediawiki-config/*" "${tempdir}/mediawiki/" -Force
Remove-Item "${tempdir}/mediawiki-config" -Force -Recurse
Write-Verbose "Deleting cache directory"
Remove-Item "${tempdir}/mediawiki/cache" -Force -Recurse
Write-Verbose "Deleting images directory"
Remove-Item "${tempdir}/mediawiki/images" -Force -Recurse

if (Test-Path "${PSScriptRoot}/additional-files/data")
{Write-Verbose "Copying additional files for data directory"
Copy-Item "${PSScriptRoot}/additional-files/data/*" "${tempdir}/mediawiki/data/" -Force -Recurse}

if (Test-Path $mediawiki_dir)
{Write-Warning "Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}-old" -Force}
if (Test-Path $private_data_dir)
{Write-Warning "Renaming existing private data directory"
Move-Item $private_data_dir "${private_data_dir}-old" -Force}
Write-Verbose "Moving MediaWiki directory from temporary directory to destination directory"
Move-Item "${tempdir}/mediawiki" $mediawiki_dir -Force
#Copy additional files for private data here because this is just copying a entire directory to seperated location from MediaWiki directory.
if (Test-Path "${PSScriptRoot}/additional-files/private-data")
{Write-Verbose "Copying additional files for private data directory"
Copy-Item "${PSScriptRoot}/additional-files/private-data" $private_data_dir -Force -Recurse}
