#SetTempDir
#Sets $tempdir variable to temporary directory.

."${PSScriptRoot}/OSVariables.ps1"

if ($isLinux)
{$tempdir="/tmp"}
elseif ($isWindows)
{$tempdir=$Env:TEMP}
else
{New-Item "${PSScriptRoot}/../temp" -Force -ItemType Directory
$tempdir="${PSScriptRoot}/../temp"}
