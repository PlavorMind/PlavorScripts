# Enables automatically locking on sign in. Useful when using automatic login.

if (Test-Path "$PSScriptRoot/../../init-script.ps1") {
  ."$PSScriptRoot/../../init-script.ps1" | Out-Null
}
else {
  throw 'Cannot find init-script.ps1 file.'
}

if (!$IsWindows) {
  throw 'This script does not support operating systems other than Windows.'
}

$path = "$Env:APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"

if (Test-Path $path) {
  Write-Warning 'Automatically locking on sign in is already enabled.'
  return
}

'Enabling automatically locking on sign in'
New-Shortcut $path 'C:/Windows/System32/rundll32.exe' 'user32.dll, LockWorkStation'
