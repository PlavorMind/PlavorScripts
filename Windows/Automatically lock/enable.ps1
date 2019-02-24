#Enable automatically lock
#Enables automatically lock when signing in.
#Useful if you use automatic login.

param([switch]$allusers) #Apply to all users if this parameter is set

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

if ($allusers)
{$path="C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}
else
{$path="${env:APPDATA}/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}

."${PSScriptRoot}/../../modules/CreateShortcut.ps1" -arguments "user32.dll,LockWorkStation" -path $path -target "C:/Windows/System32/rundll32.exe"
