#Uninstalls some unnecessary UWP apps.

Param([Parameter()]$vb) #Parameter added just for making the -Verbose parameter work and does nothing

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

#This may take a few seconds to run
$apps=Get-ProvisionedAppxPackage -Online

Write-Verbose "Removing MSN Weather"
$apps | Where-Object "DisplayName" -EQ "Microsoft.BingWeather" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Get Help"
$apps | Where-Object "DisplayName" -EQ "Microsoft.GetHelp" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Microsoft Tips"
$apps | Where-Object "DisplayName" -EQ "Microsoft.Getstarted" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing 3D Viewer"
$apps | Where-Object "DisplayName" -EQ "Microsoft.Microsoft3DViewer" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Office"
$apps | Where-Object "DisplayName" -EQ "Microsoft.MicrosoftOfficeHub" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Microsoft Solitaire Collection"
$apps | Where-Object "DisplayName" -EQ "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Microsoft Sticky Notes"
$apps | Where-Object "DisplayName" -EQ "Microsoft.MicrosoftStickyNotes" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Mixed Reality Portal"
$apps | Where-Object "DisplayName" -EQ "Microsoft.MixedReality.Portal" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Paint 3D"
$apps | Where-Object "DisplayName" -EQ "Microsoft.MSPaint" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing OneNote"
$apps | Where-Object "DisplayName" -EQ "Microsoft.Office.OneNote" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Microsoft People"
$apps | Where-Object "DisplayName" -EQ "Microsoft.People" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Skype"
$apps | Where-Object "DisplayName" -EQ "Microsoft.SkypeApp" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Microsoft Pay"
$apps | Where-Object "DisplayName" -EQ "Microsoft.Wallet" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Web Media Extensions"
$apps | Where-Object "DisplayName" -EQ "Microsoft.WebMediaExtensions" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Microsoft Photos"
$apps | Where-Object "DisplayName" -EQ "Microsoft.Windows.Photos" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Windows Alarms & Clock"
$apps | Where-Object "DisplayName" -EQ "Microsoft.WindowsAlarms" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Windows Calculator"
$apps | Where-Object "DisplayName" -EQ "Microsoft.WindowsCalculator" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Windows Camera"
$apps | Where-Object "DisplayName" -EQ "Microsoft.WindowsCamera" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Feedback Hub"
$apps | Where-Object "DisplayName" -EQ "Microsoft.WindowsFeedbackHub" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Windows Maps"
$apps | Where-Object "DisplayName" -EQ "Microsoft.WindowsMaps" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Windows Voice Recorder"
$apps | Where-Object "DisplayName" -EQ "Microsoft.WindowsSoundRecorder" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Xbox Live in-game experience"
$apps | Where-Object "DisplayName" -EQ "Microsoft.Xbox.TCUI" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Xbox Console Companion"
$apps | Where-Object "DisplayName" -EQ "Microsoft.XboxApp" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Xbox Game Bar Plugin"
$apps | Where-Object "DisplayName" -EQ "Microsoft.XboxGameOverlay" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Xbox Game Bar"
$apps | Where-Object "DisplayName" -EQ "Microsoft.XboxGamingOverlay" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Xbox Identity Provider"
$apps | Where-Object "DisplayName" -EQ "Microsoft.XboxIdentityProvider" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Your Phone"
$apps | Where-Object "DisplayName" -EQ "Microsoft.YourPhone" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Groove Music"
$apps | Where-Object "DisplayName" -EQ "Microsoft.ZuneMusic" | Remove-AppxProvisionedPackage -AllUsers -Online

Write-Verbose "Removing Movies & TV"
$apps | Where-Object "DisplayName" -EQ "Microsoft.ZuneVideo" | Remove-AppxProvisionedPackage -AllUsers -Online
