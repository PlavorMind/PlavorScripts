#CreateShortcut
#Creates a shortcut.

param
([string]$arguments="", #Arguments of a shortcut
[string]$path, #Path of a shortcut
[string]$target) #Target of a shortcut

."${PSScriptRoot}/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

$shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($path)
$shortcut.Arguments=$arguments
$shortcut.TargetPath=$target
$shortcut.Save()