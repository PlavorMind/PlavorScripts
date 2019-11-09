#Uninstalls some unnecessary UWP apps that cannot be uninstalled through UI.

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!(Test-AdminPermission))
{"This script must be run as administrator on Windows."
exit}

"Removing Alarms & Clock app"
Get-AppxPackage "Microsoft.WindowsAlarms" -AllUsers | Remove-AppxPackage

"Removing Camera app"
Get-AppxPackage "Microsoft.WindowsCamera" -AllUsers | Remove-AppxPackage

"Removing Connect app"
Get-AppxPackage "Windows.MiracastView" -AllUsers | Remove-AppxPackage

"Removing Game bar app"
Get-AppxPackage "Microsoft.XboxGameOverlay" -AllUsers | Remove-AppxPackage

"Removing Get Help app"
Get-AppxPackage "Microsoft.GetHelp" -AllUsers | Remove-AppxPackage

"Removing HEIF Image Extensions app"
Get-AppxPackage "Microsoft.HEIFImageExtension" -AllUsers | Remove-AppxPackage

"Removing Maps app"
Get-AppxPackage "Microsoft.WindowsMaps" -AllUsers | Remove-AppxPackage

"Removing Messaging app"
Get-AppxPackage "Microsoft.Messaging" -AllUsers | Remove-AppxPackage

"Removing People app"
Get-AppxPackage "Microsoft.People" -AllUsers | Remove-AppxPackage

"Removing Photos app"
Get-AppxPackage "Microsoft.Windows.Photos" -AllUsers | Remove-AppxPackage

"Removing VP9 Video Extensions app"
Get-AppxPackage "Microsoft.VP9VideoExtensions" -AllUsers | Remove-AppxPackage

"Removing Webp Image Extensions app"
Get-AppxPackage "Microsoft.WebpImageExtension" -AllUsers | Remove-AppxPackage

"Removing Xbox Game Speech Window app"
Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" -AllUsers | Remove-AppxPackage

"Removing Your Phone app"
Get-AppxPackage "Microsoft.YourPhone" -AllUsers | Remove-AppxPackage
