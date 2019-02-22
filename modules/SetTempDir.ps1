#SetTempDir
#Sets $tempdir variable to temporary directory.

if ($isLinux)
{$tempdir="/tmp"}
elseif ($isWindows)
{$tempdir=$env:TEMP}
else
{New-Item "${PSScriptRoot}/../temp" -Force -ItemType Directory
$tempdir="${PSScriptRoot}/../temp"}