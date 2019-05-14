#Enable automatically lock
#Enables automatically lock when signing in.
#Useful if you use automatic login.

param([switch]$allusers) #Apply to all users if this parameter is set

."${PSScriptRoot}/../../init_script.ps1"

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if ($allusers)
{$path="C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}
else
{$path="${Env:APPDATA}/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}

"Enabling automatically lock"
if (!(New-Shortcut -Arguments "user32.dll,LockWorkStation" -Path $path -TargetPath "C:/Windows/System32/rundll32.exe"))
{"Cannot enable automatically lock."}