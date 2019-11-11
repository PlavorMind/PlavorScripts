#Disables some unnecessary services.

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!(Test-AdminPermission))
{"This script must be run as administrator on Windows."
exit}

"Stopping Connected User Experiences and Telemetry service"
Stop-Service "DiagTrack" -Force -NoWait
"Disabling"
Set-Service "DiagTrack" -Force -StartupType Disabled

"Stopping Diagnostic Policy Service service"
Stop-Service "DPS" -Force -NoWait
"Disabling"
Set-Service "DPS" -Force -StartupType Disabled

"Stopping Downloaded Maps Manager service"
Stop-Service "MapsBroker" -Force -NoWait
"Disabling"
Set-Service "MapsBroker" -Force -StartupType Disabled

"Stopping Program Compatibility Assistant Service service"
Stop-Service "PcaSvc" -Force -NoWait
"Disabling"
Set-Service "PcaSvc" -Force -StartupType Disabled

"Stopping Secondary Logon service"
Stop-Service "seclogon" -Force -NoWait
"Disabling"
Set-Service "seclogon" -Force -StartupType Disabled

"Stopping Windows Error Reporting Service service"
Stop-Service "WerSvc" -Force -NoWait
"Disabling"
Set-Service "WerSvc" -Force -StartupType Disabled

"Stopping Windows Image Acquisition (WIA) service"
Stop-Service "stisvc" -Force -NoWait
"Disabling"
Set-Service "stisvc" -Force -StartupType Disabled