#Downloads MediaWiki with some extensions and skins.

Param
([string]$core_branch="master", #Branch for MediaWiki core
[Parameter(Position=0)][string]$dir, #Directory to download MediaWiki
[string]$extensions_branch="master", #Branch for extensions
[string]$skins_branch="master") #Branch for skins

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$dir)
{if ($IsLinux)
  {$dir="/plavormind/web/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

$composer_extensions=@("AbuseFilter","AntiSpoof","Flow","TemplateStyles")
$extensions=
@(#"AbuseFilter",
"AntiSpoof",
"Babel",
"CentralAuth",
"ChangeAuthor",
"CheckUser",
"Cite",
"CodeEditor",
"CodeMirror",
"CollapsibleVector",
"CommonsMetadata",
"ConfirmEdit",
"DeletePagesForGood",
"DiscordNotifications",
#"Echo",
#"Flow",
"GlobalBlocking",
"GlobalPreferences",
"GlobalUserPage",
"Highlightjs_Integration",
"Interwiki",
"MinimumNameLength",
"MultimediaViewer",
"Nuke",
"PageImages",
"ParserFunctions",
"PerformanceInspector",
"PlavorMindTools",
"Popups",
"Renameuser",
"ReplaceText",
"RevisionSlider",
"SecurePoll",
"SimpleMathJax",
"StaffPowers",
"StalkerLog",
"SyntaxHighlight_GeSHi",
"TemplateData",
"TemplateStyles",
"TemplateWizard",
"TextExtracts",
"TitleBlacklist",
"TwoColConflict",
"UserMerge",
"UserPageEditProtection",
"WikiEditor")
$skins=@("Liberty","Timeless","PlavorBuma","Vector")

"Downloading MediaWiki archive"
Invoke-WebRequest "https://github.com/wikimedia/mediawiki/archive/${core_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/mediawiki.zip"
if (Test-Path "${tempdir}/mediawiki.zip")
{"Extracting"
Expand-Archive "${tempdir}/mediawiki.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/mediawiki.zip" -Force
"Renaming MediaWiki directory"
Move-Item "${tempdir}/mediawiki-*" "${tempdir}/mediawiki" -Force}
else
{"Cannot download MediaWiki archive."
exit}

"Updating dependencies"
composer update --no-dev --working-dir="${tempdir}/mediawiki"

"Emptying extensions and skins directory"
Remove-Item "${tempdir}/mediawiki/extensions/*" -Force -Recurse
Remove-Item "${tempdir}/mediawiki/skins/*" -Force -Recurse

foreach ($extension in $extensions)
{"Downloading ${extension} extension archive"
switch ($extension)
  {"DiscordNotifications"
    {Invoke-WebRequest "https://github.com/kulttuuri/DiscordNotifications/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  "Highlightjs_Integration"
    {Invoke-WebRequest "https://github.com/Nicolas01/Highlightjs_Integration/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  "PlavorMindTools"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorMindTools/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  "SimpleMathJax"
    {Invoke-WebRequest "https://github.com/jmnote/SimpleMathJax/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-extensions-${extension}/archive/${extensions_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  }
if (Test-Path "${tempdir}/${extension}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${extension}.zip" "${tempdir}/mediawiki/extensions/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${extension}.zip" -Force
  "Renaming ${extension} extension directory"
  switch ($extension)
    {"DiscordNotifications"
      {Move-Item "${tempdir}/mediawiki/extensions/DiscordNotifications-master" "${tempdir}/mediawiki/extensions/${extension}" -Force}
    "Highlightjs_Integration"
      {Move-Item "${tempdir}/mediawiki/extensions/Highlightjs_Integration-master" "${tempdir}/mediawiki/extensions/${extension}" -Force}
    "PlavorMindTools"
      {Move-Item "${tempdir}/mediawiki/extensions/PlavorMindTools-Main" "${tempdir}/mediawiki/extensions/${extension}" -Force}
    "SimpleMathJax"
      {Move-Item "${tempdir}/mediawiki/extensions/SimpleMathJax-master" "${tempdir}/mediawiki/extensions/${extension}" -Force}
    default
      {Move-Item "${tempdir}/mediawiki/extensions/mediawiki-extensions-${extension}-*" "${tempdir}/mediawiki/extensions/${extension}" -Force}
    }
  }
else
  {"Cannot download ${extension} extension archive."}
}

foreach ($extension in $composer_extensions)
{if (Test-Path "${tempdir}/mediawiki/extensions/${extension}")
  {"Updating dependencies for ${extension} extension"
  composer update --no-dev --working-dir="${tempdir}/mediawiki/extensions/${extension}"}
}

foreach ($skin in $skins)
{"Downloading ${skin} skin archive"
switch ($skin)
  {"Liberty"
    {Invoke-WebRequest "https://gitlab.com/librewiki/Liberty-MW-Skin/-/archive/master/Liberty-MW-Skin-master.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin}.zip"}
  "PlavorBuma"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorBuma/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-skins-${skin}/archive/${skins_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin}.zip"}
  }
if (Test-Path "${tempdir}/${skin}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${skin}.zip" "${tempdir}/mediawiki/skins/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${skin}.zip" -Force
  "Renaming ${skin} skin directory"
  switch ($skin)
    {"Liberty"
      {Move-Item "${tempdir}/mediawiki/skins/Liberty-MW-Skin-master" "${tempdir}/mediawiki/skins/${skin}" -Force}
    "PlavorBuma"
      {Move-Item "${tempdir}/mediawiki/skins/PlavorBuma-Main" "${tempdir}/mediawiki/skins/${skin}" -Force}
    default
      {Move-Item "${tempdir}/mediawiki/skins/mediawiki-skins-${skin}-*" "${tempdir}/mediawiki/skins/${skin}" -Force}
    }
  }
else
  {"Cannot download ${skin} skin archive."}
}

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/mediawiki/docs" -Force -Recurse
Remove-Item "${tempdir}/mediawiki/maintenance/README" -Force
Remove-Item "${tempdir}/mediawiki/resources/assets/file-type-icons/COPYING" -Force
Remove-Item "${tempdir}/mediawiki/resources/assets/licenses/public-domain.png" -Force
Remove-Item "${tempdir}/mediawiki/resources/assets/licenses/README" -Force
Remove-Item "${tempdir}/mediawiki/CODE_OF_CONDUCT.md" -Force
Remove-Item "${tempdir}/mediawiki/FAQ" -Force
Remove-Item "${tempdir}/mediawiki/HISTORY" -Force
Remove-Item "${tempdir}/mediawiki/INSTALL" -Force
Remove-Item "${tempdir}/mediawiki/README" -Force
Remove-Item "${tempdir}/mediawiki/RELEASE-NOTES-*" -Force
Remove-Item "${tempdir}/mediawiki/SECURITY" -Force
Remove-Item "${tempdir}/mediawiki/UPGRADE" -Force

if (Test-Path $dir)
{"Renaming existing MediaWiki directory"
Move-Item $dir "${dir}-old" -Force}
"Moving MediaWiki directory"
Move-Item "${tempdir}/mediawiki" $dir -Force
