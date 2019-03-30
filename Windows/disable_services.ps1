#Disable services
#Disables some unnecessary services

"Stopping Connected User Experiences and Telemetry service"
Stop-Service "DiagTrack" -Force -NoWait
"Disabling"
Set-Service "DiagTrack" -StartupType Disabled

"Stopping Diagnostic Policy Service service"
Stop-Service "DPS" -Force -NoWait
"Disabling"
Set-Service "DPS" -StartupType Disabled

"Stopping Downloaded Maps Manager service"
Stop-Service "MapsBroker" -Force -NoWait
"Disabling"
Set-Service "MapsBroker" -StartupType Disabled

"Stopping Program Compatibility Assistant Service service"
Stop-Service "PcaSvc" -Force -NoWait
"Disabling"
Set-Service "PcaSvc" -StartupType Disabled

"Stopping Secondary Logon service"
Stop-Service "seclogon" -Force -NoWait
"Disabling"
Set-Service "seclogon" -StartupType Disabled

"Stopping Windows Error Reporting Service service"
Stop-Service "WerSvc" -Force -NoWait
"Disabling"
Set-Service "WerSvc" -StartupType Disabled

"Stopping Windows Image Acquisition (WIA) service"
Stop-Service "stisvc" -Force -NoWait
"Disabling"
Set-Service "stisvc" -StartupType Disabled