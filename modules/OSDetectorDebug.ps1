#OSDetectorDebug
#Sets variables used to detecting operating system for PowerShell 5.

if (!$isLinux -and !$isMacOS -and !$isWindows)
{$isLinux=$false
$isMacOS=$false
$isWindows=$true}
