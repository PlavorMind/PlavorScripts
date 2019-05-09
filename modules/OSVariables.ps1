#OSVariables
#Sets variables used to detecting operating system and temporary directory if they aren't set.
#This module is for backward compatiblity.

if (!$isLinux -and !$isMacOS -and !$isWindows)
{$isLinux=$false
$isMacOS=$false
$isWindows=$true}

if ($isLinux)
{$tempdir="/tmp"}
elseif ($isWindows)
{$tempdir=$Env:TEMP}
else
{New-Item "${PSScriptRoot}/../temp" -Force -ItemType Directory
$tempdir="${PSScriptRoot}/../temp"}
