#Uninstall UWP apps
#Uninstalls some unnecessary UWP apps that cannot be uninstalled through UI.

if (Test-Path "${PSScriptRoot}/init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

Write-Information "Removing Alarms & Clock app"
Get-AppxPackage "Microsoft.WindowsAlarms" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Camera app"
Get-AppxPackage "Microsoft.WindowsCamera" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Connect app"
Get-AppxPackage "Windows.MiracastView" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Game bar app"
Get-AppxPackage "Microsoft.XboxGameOverlay" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Get Help app"
Get-AppxPackage "Microsoft.GetHelp" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing HEIF Image Extensions app"
Get-AppxPackage "Microsoft.HEIFImageExtension" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Maps app"
Get-AppxPackage "Microsoft.WindowsMaps" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Messaging app"
Get-AppxPackage "Microsoft.Messaging" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing People app"
Get-AppxPackage "Microsoft.People" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Photos app"
Get-AppxPackage "Microsoft.Windows.Photos" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing VP9 Video Extensions app"
Get-AppxPackage "Microsoft.VP9VideoExtensions" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Webp Image Extensions app"
Get-AppxPackage "Microsoft.WebpImageExtension" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Xbox Game Speech Window app"
Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" -AllUsers | Remove-AppxPackage -AllUsers
Write-Information "Removing Your Phone app"
Get-AppxPackage "Microsoft.YourPhone" -AllUsers | Remove-AppxPackage -AllUsers
