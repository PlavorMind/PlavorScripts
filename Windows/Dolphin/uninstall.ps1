#Dolphin uninstaller
#Uninstalls Dolphin.

param
([switch]$delete_userdata, #Delete Dolphin user data if this parameter is set
[string]$dir="C:/Program Files/Dolphin") #Directory that Dolphin is installed

."${PSScriptRoot}/../../init_script.ps1"

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{"Cannot find Dolphin."
exit}

"Stopping Dolphin process"
if (Get-Process "Dolphin" -ErrorAction Ignore)
{Stop-Process -Force -Name "Dolphin"}
if (Get-Process "DSPTool" -ErrorAction Ignore)
{Stop-Process -Force -Name "DSPTool"}
if (Get-Process "Updater" -ErrorAction Ignore)
{Stop-Process -Force -Name "Updater"}

"Deleting Dolphin directory"
Remove-Item $dir -Force -Recurse

"Deleting shortcuts"
if (Test-Path "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Dolphin.lnk")
{Remove-Item "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Dolphin.lnk" -Force}
if (Test-Path "C:/Users/Public/Desktop/Dolphin.lnk")
{Remove-Item "C:/Users/Public/Desktop/Dolphin.lnk" -Force}

if ($delete_userdata)
{"Deleting Dolphin user data"
if (Test-Path "${Env:USERPROFILE}/Documents/Dolphin Emulator")
  {Remove-Item "${Env:USERPROFILE}/Documents/Dolphin Emulator" -Force -Recurse}
if (Test-Path "${Env:USERPROFILE}/OneDrive/Documents/Dolphin Emulator")
  {Remove-Item "${Env:USERPROFILE}/OneDrive/Documents/Dolphin Emulator" -Force -Recurse}
}