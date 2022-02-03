# Disables automatically locking on sign in.

if (Test-Path "${PSScriptRoot}/../../init-script.ps1") {
  ."${PSScriptRoot}/../../init-script.ps1" | Out-Null
}
else {
  throw 'Cannot find init-script.ps1 file.'
}

if (!$IsWindows) {
  throw 'This script does not support operating systems other than Windows.'
}

if (Test-Path "${Env:APPDATA}/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk") {
  'Disabling automatically locking on sign in'
  Remove-Item "${Env:APPDATA}/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk" -Force
}
else {
  Write-Error 'Automatically locking on sign in is not enabled.' -Category NotEnabled
}
