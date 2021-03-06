#Enables or disables some Windows features.

Param([Parameter()]$x) #Parameter added just for making the -Verbose parameter work and does nothing

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

Write-Verbose "Disabling Media Features (root) feature"
Disable-WindowsOptionalFeature -FeatureName "MediaPlayback" -NoRestart -Online

Write-Verbose "Disabling Media Features/Windows Media Player feature"
Disable-WindowsOptionalFeature -FeatureName "WindowsMediaPlayer" -NoRestart -Online

Write-Verbose "Disabling Microsoft XPS Document Writer feature"
Disable-WindowsOptionalFeature -FeatureName "Printing-XPSServices-Features" -NoRestart -Online

Write-Verbose "Disabling Print and Document Services (root) feature"
Disable-WindowsOptionalFeature -FeatureName "Printing-Foundation-Features" -NoRestart -Online

Write-Verbose "Disabling Print and Document Services/Internet Printing Client feature"
Disable-WindowsOptionalFeature -FeatureName "Printing-Foundation-InternetPrinting-Client" -NoRestart -Online

Write-Verbose "Disabling Remote Differential Compression API Support feature"
Disable-WindowsOptionalFeature -FeatureName "MSRDC-Infrastructure" -NoRestart -Online

Write-Verbose "Disabling SMB Direct feature"
Disable-WindowsOptionalFeature -FeatureName "SmbDirect" -NoRestart -Online

Write-Verbose "Disabling Windows PowerShell 2.0 (root) feature"
Disable-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart -Online

Write-Verbose "Disabling Windows PowerShell 2.0/Windows PowerShell 2.0 Engine feature"
Disable-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart -Online

Write-Verbose "Enabling Windows Subsystem for Linux feature"
Enable-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -Online

Write-Verbose "Disabling Work Folders Client feature"
Disable-WindowsOptionalFeature -FeatureName "WorkFolders-Client" -NoRestart -Online
