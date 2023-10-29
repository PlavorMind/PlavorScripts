<#
.description
Extracts an archive.
#>
function Expand-ArchiveEnhanced {
  param (
    # Path to save extracted items
    [Parameter(Mandatory, Position = 1)]
    [string]$DestinationPath,

    # Path to the archive
    [Parameter(Mandatory, Position = 0)]
    [string]$Path
  )

  if (!(Test-Path $Path)) {
    Write-Error 'Cannot find the archive.' -Category ObjectNotFound
    return
  }

  try {
    $normalizedPath = Convert-Path $Path -ErrorAction Stop
  }
  catch {
    Write-Error $_
    return
  }

  if ($normalizedPath -match '\.tar(\.[gx]z)?$') {
    Write-Verbose 'Creating a directory for extracting'

    try {
      New-Item $DestinationPath -ErrorAction Stop -Force -ItemType Directory
    }
    catch {
      Write-Error $_
      return
    }

    $extraParameters = $VerbosePreference -eq 'Continue' ? @('-v') : @()
    $normalizedDestinationPath = Convert-Path $DestinationPath
    $PSNativeCommandUseErrorActionPreference = $true
    Write-Verbose "Extracting $Path archive"
    tar -C $normalizedDestinationPath -f $normalizedPath -mx @extraParameters
  }
  elseif ((Split-Path $normalizedPath -Extension) -eq '.zip') {
    Write-Verbose "Extracting $Path archive"
    Expand-Archive $normalizedPath $DestinationPath -Force
  }
  else {
    Write-Error 'Expand-ArchiveEnhanced does not support extracting this type of the archive.' -Category NotImplemented
  }

  # Suppress a warning on VSCodium
  $PSNativeCommandUseErrorActionPreference > $null
}

<#
.description
Downloads a file from a specified URL.
#>
function Get-FileFromURL {
  param (
    # Path to save the downloaded file
    [Parameter(Mandatory, Position = 1)]
    [string]$Path,

    # URL to download a file from
    [Parameter(Mandatory, Position = 0)]
    [string]$URL
  )

  $ProgressPreference = 'SilentlyContinue'
  Write-Verbose "Downloading a file from $URL"
  Invoke-WebRequest $URL -HttpVersion 3.0 -MaximumRetryCount 2 -OutFile $Path -RetryIntervalSec 3
}

<#
.description
Creates a shortcut. This function only supports Windows.
#>
function New-Shortcut {
  param (
    # Parameters to use when using the shortcut
    [Parameter(Position = 2)]
    [string]$Parameters,

    # Path to create a shourtcut
    [Parameter(Mandatory, Position = 0)]
    [string]$Path,

    # Path to the target of the shortcut
    [Parameter(Mandatory, Position = 1)]
    [string]$Target
  )

  if (!$IsWindows) {
    Write-Error 'New-Shortcut does not support operating systems other than Windows.'
    return
  }
  elseif (!(Test-Path $Target)) {
    Write-Error 'Cannot find the target.' -Category ObjectNotFound
    return
  }

  # -ComObject parameter must be specified otherwise New-Object causes an error.
  $shortcut = (New-Object -ComObject 'WScript.Shell').CreateShortcut($Path)

  try {
    $shortcut.TargetPath = Convert-Path $Target -ErrorAction Stop
  }
  catch {
    Write-Error $_
    return
  }

  if ($Parameters -ne '') {
    $shortcut.Arguments = $Parameters
  }

  $targetDisplay = $Parameters -eq '' ? $Target : "$Target $Parameters"
  Write-Verbose "Creating a shortcut to $targetDisplay at $Path"
  $shortcut.Save()
}

<#
.description
Returns if a user has administrator permission on Windows, or root permission on Linux.
#>
function Test-AdminPermission {
  if ($IsLinux) {
    return (id --user) -eq 0
  }
  elseif ($IsWindows) {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }
}

<#
.description
Returns if the PC is connected to the internet.
#>
function Test-InternetConnection {
  Write-Verbose 'Checking the internet connection by making a request to https://example.com/'

  try {
    Invoke-WebRequest 'https://example.com/' -HttpVersion 3.0 -TimeoutSec 2 > $null
  }
  catch {
    return $false
  }

  return $true
}
