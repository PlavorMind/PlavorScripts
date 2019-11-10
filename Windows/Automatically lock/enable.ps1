#Enables automatically lock when signing in. Useful when using automatic login.

Param([switch]$allusers) #Apply to all users if this parameter is set

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if ($allusers)
{if (!(Test-AdminPermission))
  {"This script must be run as administrator to apply to all users."
  exit}
$path="C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}
else
{$path="${Env:APPDATA}/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}

if (Test-Path $path)
{"Automatically lock is already enabled."}
else
{"Enabling automatically lock"
New-Shortcut $path "C:/Windows/System32/rundll32.exe" -Arguments "user32.dll,LockWorkStation"}
