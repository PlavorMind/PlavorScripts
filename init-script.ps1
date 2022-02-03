if ($PSVersionTable.PSVersion.Major -lt 7) {
  throw 'PlavorScripts does not support PowerShell 6 or older.'
}

if ($IsMacOS) {
  throw 'PlavorScripts does not support macOS.'
}
elseif ($IsWindows -and ([Environment]::OSVersion.Version.Major -lt 10)) {
  throw 'PlavorScripts does not support Windows NT 6.3 (Windows 8.1) or older.'
}

if (![Environment]::Is64BitOperatingSystem) {
  throw 'PlavorScripts does not support 32-bit operating systems.'
}

# Initialize variables
$PlaScrDirectory = $PSScriptRoot

if ($IsLinux) {
  $PlaScrDefaultBaseDirectory = '/plavormind'
  $PlaScrDefaultPHPPath = '/usr/bin/php'
  $PlaScrTempDirectory = '/tmp'
}
elseif ($IsWindows) {
  $PlaScrDefaultBaseDirectory = 'C:/plavormind'
  $PlaScrDefaultPHPPath = "${PlaScrDefaultBaseDirectory}/php/php.exe"
  $PlaScrTempDirectory = $Env:TEMP
}

# Initialize environment variables
$Env:POWERSHELL_TELEMETRY_OPTOUT = 1

."${PlaScrDirectory}/src/common-functions.ps1"
."${PlaScrDirectory}/src/legacy-functions.ps1"

# Suppress warnings in VSCodium
$PlaScrDefaultPHPPath | Out-Null
$PlaScrDirectory | Out-Null
$PlaScrTempDirectory | Out-Null

return $true
