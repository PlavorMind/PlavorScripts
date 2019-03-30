#Uninstall UWP apps
#Uninstalls some unnecessary UWP apps that cannot be uninstalled through UI.

."${PSScriptRoot}/../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Removing Alarms & Clock app"
Get-AppxPackage "Microsoft.WindowsAlarms" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Camera app"
Get-AppxPackage "Microsoft.WindowsCamera" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Connect app"
Get-AppxPackage "Windows.MiracastView" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Game bar app"
Get-AppxPackage "Microsoft.XboxGameOverlay" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Get Help app"
Get-AppxPackage "Microsoft.GetHelp" -AllUsers | Remove-AppxPackage -AllUsers

"Removing HEIF Image Extensions app"
Get-AppxPackage "Microsoft.HEIFImageExtension" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Maps app"
Get-AppxPackage "Microsoft.WindowsMaps" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Messaging app"
Get-AppxPackage "Microsoft.Messaging" -AllUsers | Remove-AppxPackage -AllUsers

"Removing People app"
Get-AppxPackage "Microsoft.People" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Photos app"
Get-AppxPackage "Microsoft.Windows.Photos" -AllUsers | Remove-AppxPackage -AllUsers

"Removing VP9 Video Extensions app"
Get-AppxPackage "Microsoft.VP9VideoExtensions" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Webp Image Extensions app"
Get-AppxPackage "Microsoft.WebpImageExtension" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Xbox Game Speech Window app"
Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" -AllUsers | Remove-AppxPackage -AllUsers

"Removing Your Phone app"
Get-AppxPackage "Microsoft.YourPhone" -AllUsers | Remove-AppxPackage -AllUsers
