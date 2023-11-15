if ($PSVersionTable.PSVersion.Major -lt 7) {
  throw 'PlavorScripts does not support PowerShell 6 or older.'
}
elseif ($IsMacOS) {
  throw 'PlavorScripts does not support macOS.'
}
elseif ($IsWindows -and ([Environment]::OSVersion.Version.Major -lt 10)) {
  throw 'PlavorScripts does not support Windows NT 6.3 (Windows 8.1) or older.'
}
elseif (![Environment]::Is64BitOperatingSystem) {
  throw 'PlavorScripts does not support 32-bit operating systems.'
}

$PlaScrDirectory = $PSScriptRoot

if ($IsLinux) {
  $PlaScrDefaultBaseDirectory = '/plavormind'
  $PlaScrDefaultPHPPath = '/usr/bin/php'
  $PlaScrTempDirectory = '/tmp'
}
elseif ($IsWindows) {
  $PlaScrDefaultBaseDirectory = 'C:/plavormind'
  $PlaScrDefaultPHPPath = "$PlaScrDefaultBaseDirectory/php/app/php.exe"
  $PlaScrTempDirectory = $env:TEMP
}

$env:POWERSHELL_TELEMETRY_OPTOUT = 1

. "$PlaScrDirectory/src/common-functions.ps1"
. "$PlaScrDirectory/src/legacy-functions.ps1"

return $true

# Suppress warnings on VSCodium
$PlaScrDefaultPHPPath > $null
$PlaScrTempDirectory > $null
