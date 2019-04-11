#Set Windows features
#Enables or disables some Windows features.

."${PSScriptRoot}/../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Disabling Media Features (Root) feature"
Disable-WindowsOptionalFeature -FeatureName "MediaPlayback" -NoRestart -Online

"Disabling Media Features/Windows Media Player feature"
Disable-WindowsOptionalFeature -FeatureName "WindowsMediaPlayer" -NoRestart -Online

"Disabling Microsoft XPS Document Writer feature"
Disable-WindowsOptionalFeature -FeatureName "Printing-XPSServices-Features" -NoRestart -Online

"Disabling Print and Document Services (Root) feature"
Disable-WindowsOptionalFeature -FeatureName "Printing-Foundation-Features" -NoRestart -Online

"Disabling Print and Document Services/Internet Printing Client feature"
Disable-WindowsOptionalFeature -FeatureName "Printing-Foundation-InternetPrinting-Client" -NoRestart -Online

"Disabling Print and Document Services/Windows Fax and Scan feature"
Disable-WindowsOptionalFeature -FeatureName "FaxServicesClientPackage" -NoRestart -Online

"Disabling Remote Differential Compression API Support feature"
Disable-WindowsOptionalFeature -FeatureName "MSRDC-Infrastructure" -NoRestart -Online

"Disabling SMB Direct feature"
Disable-WindowsOptionalFeature -FeatureName "SmbDirect" -NoRestart -Online

"Disabling Windows PowerShell 2.0 (Root) feature"
Disable-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart -Online

"Disabling Windows PowerShell 2.0/Windows PowerShell 2.0 Engine feature"
Disable-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart -Online

"Enabling Windows Subsystem for Linux feature"
Enable-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -Online

"Disabling Work Folders Client feature"
Disable-WindowsOptionalFeature -FeatureName "WorkFolders-Client" -NoRestart -Online