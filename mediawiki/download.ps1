#Downloads MediaWiki with some extensions and skins.

Param
([string]$composer_path, #Path to Composer
[string]$core_branch="master", #Branch for MediaWiki core
[Parameter(Position=0)][string]$dir, #Directory to download MediaWiki
[string]$extensions_branch="master", #Branch for extensions
[string]$php_path, #Path to PHP
[string]$skins_branch="master") #Branch for skins

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

if (!(Test-Path $composer_path))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

$composer_extensions=
@("AbuseFilter",
"AntiSpoof",
"Flow",
"TemplateStyles")
$composer_skins=@()
$extensions=
@(#"AbuseFilter",
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
#"Echo",
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
"WikiEditor",

"SecureLinkFixer")
$skins=
@("Liberty",
"Medik",
"MinervaNeue",
"Vector",

"PlavorBuma",
"Timeless")

Write-Verbose "Creating a temporary directory for extracting"
New-Item "${tempdir}/mediawiki-extracts" -Force -ItemType Directory

Write-Verbose "Downloading MediaWiki"
Invoke-WebRequest "https://github.com/wikimedia/mediawiki/archive/${core_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki.zip"
if (Test-Path "${tempdir}/mediawiki.zip")
{Write-Verbose "Extracting"
Expand-Archive "${tempdir}/mediawiki.zip" "${tempdir}/mediawiki-extracts/" -Force
Write-Verbose "Deleting a file that is no longer needed"
Remove-Item "${tempdir}/mediawiki.zip" -Force
Move-Item "${tempdir}/mediawiki-extracts/*" "${tempdir}/mediawiki" -Force}
else
{Write-Error "Cannot download MediaWiki." -Category ConnectionError
exit}

Write-Verbose "Updating dependencies with Composer"
.$php_path $composer_path update --ignore-platform-reqs --no-cache --no-dev --working-dir="${tempdir}/mediawiki"

Write-Verbose "Emptying extensions and skins directory"
Remove-Item "${tempdir}/mediawiki/extensions/*" -Force -Recurse
Remove-Item "${tempdir}/mediawiki/skins/*" -Force -Recurse

foreach ($extension in $extensions)
{Write-Verbose "Downloading ${extension} extension"
switch ($extension)
  {"Discord"
    {Invoke-WebRequest "https://github.com/jaydenkieran/mw-discord/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-extension.zip"}
  "DiscordNotifications"
    {Invoke-WebRequest "https://github.com/kulttuuri/DiscordNotifications/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-extension.zip"}
  "Highlightjs_Integration"
    {Invoke-WebRequest "https://github.com/Nicolas01/Highlightjs_Integration/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-extension.zip"}
  "NativeSvgHandler"
    {Invoke-WebRequest "https://github.com/StarCitizenTools/mediawiki-extensions-NativeSvgHandler/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-extension.zip"}
  "PlavorMindTools"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorMindTools/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-extension.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-extensions-${extension}/archive/${extensions_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-extension.zip"}
  }
if (Test-Path "${tempdir}/mediawiki-extension.zip")
  {Write-Verbose "Extracting"
  Expand-Archive "${tempdir}/mediawiki-extension.zip" "${tempdir}/mediawiki-extracts/" -Force
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/mediawiki-extension.zip" -Force
  Write-Verbose "Moving ${extension} extension directory"
  Move-Item "${tempdir}/mediawiki-extracts/*" "${tempdir}/mediawiki/extensions/${extension}" -Force}
else
  {Write-Error "Cannot download ${extension} extension." -Category ConnectionError}
}

foreach ($extension in $composer_extensions)
{if (Test-Path "${tempdir}/mediawiki/extensions/${extension}")
  {Write-Verbose "Updating dependencies for ${extension} extension with Composer"
  .$php_path $composer_path update --no-cache --no-dev --working-dir="${tempdir}/mediawiki/extensions/${extension}"}
}

foreach ($skin in $skins)
{Write-Verbose "Downloading ${skin} skin"
switch ($skin)
  {"Liberty"
    {Invoke-WebRequest "https://gitlab.com/librewiki/Liberty-MW-Skin/-/archive/master/Liberty-MW-Skin-master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-skin.zip"}
  "Medik"
    {Invoke-WebRequest "https://bitbucket.org/wikiskripta/medik/get/master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-skin.zip"}
  "PlavorBuma"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorBuma/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-skin.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-skins-${skin}/archive/${skins_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki-skin.zip"}
  }
if (Test-Path "${tempdir}/mediawiki-skin.zip")
  {Write-Verbose "Extracting"
  Expand-Archive "${tempdir}/mediawiki-skin.zip" "${tempdir}/mediawiki-extracts/" -Force
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/mediawiki-skin.zip" -Force
  Write-Verbose "Moving ${skin} skin directory"
  Move-Item "${tempdir}/mediawiki-extracts/*" "${tempdir}/mediawiki/skins/${skin}" -Force}
else
  {Write-Error "Cannot download ${skin} skin." -Category ConnectionError}
}

foreach ($skin in $composer_skins)
{if (Test-Path "${tempdir}/mediawiki/skins/${skin}")
  {Write-Verbose "Updating dependencies for ${skin} skin with Composer"
  .$php_path $composer_path update --no-cache --no-dev --working-dir="${tempdir}/mediawiki/skins/${skin}"}
}

Write-Verbose "Deleting a directory that is no longer needed"
Remove-Item "${tempdir}/mediawiki-extracts" -Force -Recurse

Write-Verbose "Deleting files that are unnecessary for running"
Remove-Item "${tempdir}/mediawiki/CODE_OF_CONDUCT.md" -Force
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
Write-Verbose "Moving MediaWiki directory from temporary directory to destination directory"
Move-Item "${tempdir}/mediawiki" $dir -Force
