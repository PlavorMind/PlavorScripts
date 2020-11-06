#Downloads MediaWiki.

Param
([string]$branch="master", #Branch for MediaWiki
[Parameter(Position=0)][string]$dir) #Directory to download MediaWiki

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}

Write-Verbose "Downloading MediaWiki"
Expand-ArchiveSmart "https://github.com/wikimedia/mediawiki/archive/${branch}.zip" "${PlaScrTempDirectory}/mediawiki"
if (!(Test-Path "${PlaScrTempDirectory}/mediawiki"))
{Write-Error "Cannot download MediaWiki." -Category ConnectionError
exit}

Write-Verbose "Downloading external dependencies"
if (Test-Path "${PlaScrTempDirectory}/mediawiki/vendor")
{Remove-Item "${PlaScrTempDirectory}/mediawiki/vendor" -Force -Recurse}
Expand-ArchiveSmart "https://github.com/wikimedia/mediawiki-vendor/archive/${branch}.zip" "${PlaScrTempDirectory}/mediawiki/vendor"
if (!(Test-Path "${PlaScrTempDirectory}/mediawiki/vendor"))
{Write-Error "Cannot download external dependencies." -Category ConnectionError
exit}

Write-Verbose "Deleting files and directories that are unnecessary for running"
Remove-Item "${PlaScrTempDirectory}/mediawiki/CODE_OF_CONDUCT.md" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/composer.local.json-sample" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/FAQ" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/HISTORY" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/INSTALL" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/README.md" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/SECURITY" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/docs" -Force -Recurse
Remove-Item "${PlaScrTempDirectory}/mediawiki/extensions/*" -Force -Recurse
Remove-Item "${PlaScrTempDirectory}/mediawiki/maintenance/README" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/resources/assets/file-type-icons/COPYING" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/resources/assets/licenses/public-domain.png" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/resources/assets/licenses/README" -Force
Remove-Item "${PlaScrTempDirectory}/mediawiki/skins/*" -Force -Recurse

if (Test-Path $dir)
{Write-Warning "Renaming existing MediaWiki directory"
Move-Item $dir "${dir}-old" -Force}
Write-Verbose "Moving MediaWiki directory to destination directory"
Move-Item "${PlaScrTempDirectory}/mediawiki" $dir -Force
