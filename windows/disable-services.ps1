#Disables some unnecessary services.

Param([Parameter()]$vb) #Parameter added just for making the -Verbose parameter work and does nothing

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

Write-Verbose "Stopping Connected User Experiences and Telemetry service"
Stop-Service "DiagTrack" -Force -NoWait
Write-Verbose "Disabling"
Set-Service "DiagTrack" -Force -StartupType Disabled

Write-Verbose "Stopping Diagnostic Policy Service service"
Stop-Service "DPS" -Force -NoWait
Write-Verbose "Disabling"
Set-Service "DPS" -Force -StartupType Disabled

Write-Verbose "Stopping Downloaded Maps Manager service"
Stop-Service "MapsBroker" -Force -NoWait
Write-Verbose "Disabling"
Set-Service "MapsBroker" -Force -StartupType Disabled

Write-Verbose "Stopping Program Compatibility Assistant Service service"
Stop-Service "PcaSvc" -Force -NoWait
Write-Verbose "Disabling"
Set-Service "PcaSvc" -Force -StartupType Disabled

Write-Verbose "Stopping Secondary Logon service"
Stop-Service "seclogon" -Force -NoWait
Write-Verbose "Disabling"
Set-Service "seclogon" -Force -StartupType Disabled

Write-Verbose "Stopping Windows Error Reporting Service service"
Stop-Service "WerSvc" -Force -NoWait
Write-Verbose "Disabling"
Set-Service "WerSvc" -Force -StartupType Disabled

Write-Verbose "Stopping Windows Image Acquisition (WIA) service"
Stop-Service "stisvc" -Force -NoWait
Write-Verbose "Disabling"
Set-Service "stisvc" -Force -StartupType Disabled
