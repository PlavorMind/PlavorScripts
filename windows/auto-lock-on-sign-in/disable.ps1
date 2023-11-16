# Disables automatically locking on sign in.

$ErrorActionPreference = 'Stop'

if (Test-Path "$PSScriptRoot/../../init-script.ps1") {
  . "$PSScriptRoot/../../init-script.ps1" > $null
}
else {
  throw 'Cannot find init-script.ps1 file.'
}

if (!$IsWindows) {
  throw 'This script does not support operating systems other than Windows.'
}

$path = "$env:APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"

if (!(Test-Path $path)) {
  throw 'Automatically locking on sign in is not enabled.'
}

'Disabling automatically locking on sign in'
Remove-Item $path -Force
