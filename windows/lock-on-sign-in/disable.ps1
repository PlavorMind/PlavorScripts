# Disables automatically locking on sign in.

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
  'Disabling automatically locking on sign in'
  Remove-Item $path -Force
}
else {
  Write-Error 'Automatically locking on sign in is not enabled.' -Category NotEnabled
}
