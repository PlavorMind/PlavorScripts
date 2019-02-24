#Dolphin uninstaller
#Uninstalls Dolphin.

param([switch]$delete_userdata,[string]$dir="C:/Program Files/Dolphin")

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

if (!(Test-Path $dir))
{"Cannot find Dolphin."
exit}

Stop-Process -Force -Name "Dolphin"
Stop-Process -Force -Name "DSPTool"
Stop-Process -Force -Name "Updater"

Remove-Item $dir -Force -Recurse

if (Test-Path "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Dolphin.lnk")
{Remove-Item "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Dolphin.lnk" -Force}
if (Test-Path "C:/Users/Public/Desktop/Dolphin.lnk")
{Remove-Item "C:/Users/Public/Desktop/Dolphin.lnk" -Force}

if ($delete_userdata)
{if (Test-Path "${env:userprofile}/Documents/Dolphin Emulator")
  {Remove-Item "${env:userprofile}/Documents/Dolphin Emulator" -Force -Recurse}
if (Test-Path "${env:userprofile}/OneDrive/Documents/Dolphin Emulator")
  {Remove-Item "${env:userprofile}/OneDrive/Documents/Dolphin Emulator" -Force -Recurse}
}
