#OSVariables
#Sets variables used to detecting operating system and temporary directory.

if (!$isLinux -and !$isMacOS -and !$isWindows)
{$isLinux=$false
$isMacOS=$false
$isWindows=$true}

if ($isLinux)
{$tempdir="/tmp"}
elseif ($isMacOS)
{$tempdir="/private/tmp"}
elseif ($isWindows)
{$tempdir=$Env:TEMP}

#Seperate this to avoid non-used variable problem
if (!$tempdir)
{"Cannot detect temporary directory."}
