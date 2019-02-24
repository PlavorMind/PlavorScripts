#Disable automatically lock
#Disables automatically lock when signing in.

param([switch]$allusers) #Apply to all users if this parameter is set

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

if ($allusers)
{$path="C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}
else
{$path="${env:appdata}/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}

if (Test-Path $path)
{Remove-Item $path -Force}
else
{"Automatically lock is not enabled."}
