#OSVariables
#Sets variables used to detecting operating system if they aren't set.
#This module is for backward compatiblity.

if (!$isLinux -and !$isMacOS -and !$isWindows)
{$isLinux=$false
$isMacOS=$false
$isWindows=$true}
