#CreateShortcut
#Creates a shortcut.

param
([string]$arguments="", #Arguments of a shortcut
[string]$path, #Path of a shortcut
[string]$target) #Target of a shortcut

if (Test-Path "${PSScriptRoot}/OSVariables.ps1")
{."${PSScriptRoot}/OSVariables.ps1"}
else
{"Cannot find OSVariables module."
exit}

if (!$isWindows)
{"Your operating system is not supported."
exit}

$shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($path)
$shortcut.Arguments=$arguments
$shortcut.TargetPath=$target
$shortcut.Save()
