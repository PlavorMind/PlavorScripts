#MediaWiki downloader
#Downloads MediaWiki with some extensions and skins.

param
([string]$core_branch="master", #Branch for MediaWiki core
[string]$dir="__DEFAULT__", #Directory to download MediaWiki
[string]$extensions_branch="master", #Branch for extensions
[string]$skins_branch="master") #Branch for skins

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($dir -eq "__DEFAULT__")
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
Invoke-WebRequest "https://github.com/wikimedia/mediawiki/archive/${core_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/MediaWiki.zip"
if (Test-Path "${tempdir}/MediaWiki.zip")
{"Extracting"
Expand-Archive "${tempdir}/MediaWiki.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/MediaWiki.zip" -Force
"Renaming MediaWiki directory"
Move-Item "${tempdir}/mediawiki-*" "${tempdir}/MediaWiki" -Force}
else
{"Cannot download MediaWiki archive."
exit}

"Updating dependencies"
composer update --no-dev --working-dir="${tempdir}/MediaWiki"

"Emptying extensions and skins directory"
Remove-Item "${tempdir}/MediaWiki/extensions/*" -Force -Recurse
Remove-Item "${tempdir}/MediaWiki/skins/*" -Force -Recurse

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
  Expand-Archive "${tempdir}/${extension}.zip" "${tempdir}/MediaWiki/extensions/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${extension}.zip" -Force
  "Renaming ${extension} extension directory"
  switch ($extension)
    {"DiscordNotifications"
      {Move-Item "${tempdir}/MediaWiki/extensions/DiscordNotifications-master" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    "Highlightjs_Integration"
      {Move-Item "${tempdir}/MediaWiki/extensions/Highlightjs_Integration-master" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    "PlavorMindTools"
      {Move-Item "${tempdir}/MediaWiki/extensions/PlavorMindTools-Main" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    "SimpleMathJax"
      {Move-Item "${tempdir}/MediaWiki/extensions/SimpleMathJax-master" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    default
      {Move-Item "${tempdir}/MediaWiki/extensions/mediawiki-extensions-${extension}-*" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    }
  }
else
  {"Cannot download ${extension} extension archive."}
}

#Patch for StructuredDiscussions
if (Test-Path "${tempdir}/MediaWiki/extensions/Flow")
{"Applying patch for StructuredDiscussions"
Invoke-WebRequest "https://raw.githubusercontent.com/PlavorMind/StructuredDiscussions-patch/Main/TalkpageManager.php" -DisableKeepAlive -OutFile "${tempdir}/MediaWiki/extensions/Flow/includes/TalkpageManager.php"}

foreach ($extension in $composer_extensions)
{if (Test-Path "${tempdir}/MediaWiki/extensions/${extension}")
  {"Updating dependencies for ${extension} extension"
  composer update --no-dev --working-dir="${tempdir}/MediaWiki/extensions/${extension}"}
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
  Expand-Archive "${tempdir}/${skin}.zip" "${tempdir}/MediaWiki/skins/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${skin}.zip" -Force
  "Renaming ${skin} skin directory"
  switch ($skin)
    {"Liberty"
      {Move-Item "${tempdir}/MediaWiki/skins/Liberty-MW-Skin-master" "${tempdir}/MediaWiki/skins/${skin}" -Force}
    "PlavorBuma"
      {Move-Item "${tempdir}/MediaWiki/skins/PlavorBuma-Main" "${tempdir}/MediaWiki/skins/${skin}" -Force}
    default
      {Move-Item "${tempdir}/MediaWiki/skins/mediawiki-skins-${skin}-*" "${tempdir}/MediaWiki/skins/${skin}" -Force}
    }
  }
else
  {"Cannot download ${skin} skin archive."}
}

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/MediaWiki/docs" -Force -Recurse
Remove-Item "${tempdir}/MediaWiki/maintenance/README" -Force
Remove-Item "${tempdir}/MediaWiki/resources/assets/file-type-icons/COPYING" -Force
Remove-Item "${tempdir}/MediaWiki/resources/assets/licenses/public-domain.png" -Force
Remove-Item "${tempdir}/MediaWiki/resources/assets/licenses/README" -Force
Remove-Item "${tempdir}/MediaWiki/CODE_OF_CONDUCT.md" -Force
Remove-Item "${tempdir}/MediaWiki/CREDITS" -Force
Remove-Item "${tempdir}/MediaWiki/FAQ" -Force
Remove-Item "${tempdir}/MediaWiki/HISTORY" -Force
Remove-Item "${tempdir}/MediaWiki/INSTALL" -Force
Remove-Item "${tempdir}/MediaWiki/README" -Force
Remove-Item "${tempdir}/MediaWiki/RELEASE-NOTES-*" -Force
Remove-Item "${tempdir}/MediaWiki/SECURITY" -Force
Remove-Item "${tempdir}/MediaWiki/UPGRADE" -Force

if (Test-Path $dir)
{"Renaming existing MediaWiki directory"
Move-Item $dir "${dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki" $dir -Force
