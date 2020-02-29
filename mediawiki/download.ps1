#Downloads MediaWiki with some extensions and skins.

Param
([string]$composer_local_json="https://raw.githubusercontent.com/PlavorMind/Configurations/master/mediawiki/composer.local.json", #File path or URL to composer.local.json file
[string]$composer_path, #Path to Composer
[string]$core_branch="master", #Branch for MediaWiki core
[Parameter(Position=0)][string]$dir, #Directory to download MediaWiki
[string]$extensions_branch="master", #Branch for extensions
[string]$php_path, #Path to PHP
[string]$skins_branch="master") #Branch for skins

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="${PlaScrDefaultBaseDirectory}/composer.phar"}
elseif ($IsWindows)
  {$composer_path="${PlaScrDefaultBaseDirectory}/php-ts/data/composer.phar"}
else
  {Write-Error "Cannot detect default Composer path." -Category NotSpecified
  exit}
}
if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}

if (!(Test-Path $composer_path))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

$composer_extensions=
@("AbuseFilter",
"AntiSpoof",
"CheckUser",
"Flow",
"TemplateStyles")
$composer_skins=@()
$extensions=
@("AbuseFilter",
"AntiSpoof",
"Babel",
"CentralAuth",
"CheckUser",
"Cite",
"CodeEditor",
"CodeMirror",
"CollapsibleVector",
"CommonsMetadata",
"ConfirmEdit",
"DeletePagesForGood",
"Discord",
"DiscordNotifications",
"DiscussionTools",
"Echo",
#"Flow",
"GlobalBlocking",
"GlobalCssJs"
"GlobalPreferences",
"GlobalUserPage",
"Highlightjs_Integration",
"InputBox",
"Interwiki",
"Josa",
"MassEditRegex",
"Math",
"MinimumNameLength",
"MultimediaViewer",
"NativeSvgHandler",
"Nuke",
"PageImages",
"ParserFunctions",
"PerformanceInspector",
"PlavorMindTools",
"Popups",
"ProtectionIndicator",
"Renameuser",
"ReplaceText",
"RevisionSlider",
"Scribunto",
"StaffPowers",
"StalkerLog",
"SyntaxHighlight_GeSHi",
"TemplateData",
"TemplateStyles",
"TemplateWizard",
"TextExtracts",
"TitleBlacklist",
"TwoColConflict",
"UploadsLink",
"UserMerge",
"VisualEditor",
"Wikibase",
"WikiEditor",

"SecureLinkFixer")
$skins=
@("Citizen",
"Liberty",
"Medik",
"Metrolook",
"MinervaNeue",
"Vector",

"PlavorBuma",
"Timeless")

Write-Verbose "Downloading MediaWiki"
Expand-ArchiveSmart "https://github.com/wikimedia/mediawiki/archive/${core_branch}.zip" "${PlaScrTempDirectory}/mediawiki"
if (!(Test-Path "${PlaScrTempDirectory}/mediawiki"))
{Write-Error "Cannot download MediaWiki." -Category ConnectionError
exit}

Write-Verbose "Emptying extensions and skins directory"
Remove-Item "${PlaScrTempDirectory}/mediawiki/extensions/*" -Force -Recurse
Remove-Item "${PlaScrTempDirectory}/mediawiki/skins/*" -Force -Recurse

foreach ($extension in $extensions)
{Write-Verbose "Downloading ${extension} extension"
switch ($extension)
  {"Discord"
    {Expand-ArchiveSmart "https://github.com/jaydenkieran/mw-discord/archive/master.zip" "${PlaScrTempDirectory}/mediawiki/extensions/${extension}"}
  "DiscordNotifications"
    {Expand-ArchiveSmart "https://github.com/kulttuuri/DiscordNotifications/archive/master.zip" "${PlaScrTempDirectory}/mediawiki/extensions/${extension}"}
  "Highlightjs_Integration"
    {Expand-ArchiveSmart "https://github.com/Nicolas01/Highlightjs_Integration/archive/master.zip" "${PlaScrTempDirectory}/mediawiki/extensions/${extension}"}
  "NativeSvgHandler"
    {Expand-ArchiveSmart "https://github.com/StarCitizenTools/mediawiki-extensions-NativeSvgHandler/archive/master.zip" "${PlaScrTempDirectory}/mediawiki/extensions/${extension}"}
  "PlavorMindTools"
    {Expand-ArchiveSmart "https://github.com/PlavorMind/PlavorMindTools/archive/master.zip" "${PlaScrTempDirectory}/mediawiki/extensions/${extension}"}
  Default
    {Expand-ArchiveSmart "https://github.com/wikimedia/mediawiki-extensions-${extension}/archive/${extensions_branch}.zip" "${PlaScrTempDirectory}/mediawiki/extensions/${extension}"}
  }
if (!(Test-Path "${PlaScrTempDirectory}/mediawiki/extensions/${extension}"))
  {Write-Error "Cannot download ${extension} extension." -Category ConnectionError}
}

foreach ($skin in $skins)
{Write-Verbose "Downloading ${skin} skin"
switch ($skin)
  {"Citizen"
    {Expand-ArchiveSmart "https://github.com/StarCitizenTools/mediawiki-skins-Citizen/archive/master.zip" "${PlaScrTempDirectory}/mediawiki/skins/${skin}"}
  "Liberty"
    {Expand-ArchiveSmart "https://gitlab.com/librewiki/Liberty-MW-Skin/-/archive/master/Liberty-MW-Skin-master.zip" "${PlaScrTempDirectory}/mediawiki/skins/${skin}"}
  "Medik"
    {Expand-ArchiveSmart "https://bitbucket.org/wikiskripta/medik/get/master.zip" "${PlaScrTempDirectory}/mediawiki/skins/${skin}"}
  "PlavorBuma"
    {Expand-ArchiveSmart "https://github.com/PlavorMind/PlavorBuma/archive/master.zip" "${PlaScrTempDirectory}/mediawiki/skins/${skin}"}
  Default
    {Expand-ArchiveSmart "https://github.com/wikimedia/mediawiki-skins-${skin}/archive/${skins_branch}.zip" "${PlaScrTempDirectory}/mediawiki/skins/${skin}"}
  }
if (!(Test-Path "${PlaScrTempDirectory}/mediawiki/skins/${skin}"))
  {Write-Error "Cannot download ${skin} skin." -Category ConnectionError}
}

$output=Get-FilePathFromURL $composer_local_json
if ($output)
{if ($output -like "${PlaScrTempDirectory}*")
  {Write-Verbose "Moving composer.local.json file"
  Move-Item $output "${PlaScrTempDirectory}/mediawiki/composer.local.json" -Force}
else
  {Write-Verbose "Copying composer.local.json file"
  Copy-Item $output "${PlaScrTempDirectory}/mediawiki/composer.local.json" -Force}
}
else
{Write-Error "Cannot download or find composer.local.json file." -Category ObjectNotFound}

Write-Verbose "Updating dependencies with Composer"
.$php_path $composer_path update --no-cache --no-dev --working-dir="${PlaScrTempDirectory}/mediawiki"
foreach ($extension in $composer_extensions)
{if (Test-Path "${PlaScrTempDirectory}/mediawiki/extensions/${extension}")
  {Write-Verbose "Updating dependencies for ${extension} extension with Composer"
  .$php_path $composer_path update --no-cache --no-dev --working-dir="${PlaScrTempDirectory}/mediawiki/extensions/${extension}"}
}
foreach ($skin in $composer_skins)
{if (Test-Path "${PlaScrTempDirectory}/mediawiki/skins/${skin}")
  {Write-Verbose "Updating dependencies for ${skin} skin with Composer"
  .$php_path $composer_path update --no-cache --no-dev --working-dir="${PlaScrTempDirectory}/mediawiki/skins/${skin}"}
}

Write-Verbose "Deleting files and a directory that are unnecessary for running"
Remove-Item "${tempdir}/mediawiki/CODE_OF_CONDUCT.md" -Force
Remove-Item "${tempdir}/mediawiki/composer.local.json-sample" -Force
Remove-Item "${tempdir}/mediawiki/FAQ" -Force
Remove-Item "${tempdir}/mediawiki/HISTORY" -Force
Remove-Item "${tempdir}/mediawiki/INSTALL" -Force
Remove-Item "${tempdir}/mediawiki/README" -Force
Remove-Item "${tempdir}/mediawiki/RELEASE-NOTES-*" -Force
Remove-Item "${tempdir}/mediawiki/SECURITY" -Force
Remove-Item "${tempdir}/mediawiki/UPGRADE" -Force
Remove-Item "${tempdir}/mediawiki/docs" -Force -Recurse
Remove-Item "${tempdir}/mediawiki/maintenance/README" -Force
Remove-Item "${tempdir}/mediawiki/resources/assets/file-type-icons/COPYING" -Force
Remove-Item "${tempdir}/mediawiki/resources/assets/licenses/public-domain.png" -Force
Remove-Item "${tempdir}/mediawiki/resources/assets/licenses/README" -Force

if (Test-Path $dir)
{Write-Warning "Renaming existing MediaWiki directory"
Move-Item $dir "${dir}-old" -Force}
Write-Verbose "Moving MediaWiki directory to destination directory"
Move-Item "${PlaScrTempDirectory}/mediawiki" $dir -Force
