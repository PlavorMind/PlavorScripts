<#
.description
Extracts an archive.
#>
function Expand-ArchiveEnhanced {
  param (
    # Path to save extracted items
    [Parameter(Mandatory = $true, Position = 1)][string]$DestinationPath,
    # Archive path
    [Parameter(Mandatory = $true, Position = 0)][string]$Path
  )

  if (!(Test-Path $Path)) {
    Write-Error 'Cannot find the archive.' -Category ObjectNotFound
    return
  }

  if ($Path -match '\.tar(\.[gx]z)?$') {
    $additional_parameters = @()

    if ($VerbosePreference -eq 'Continue') {
      $additional_parameters += '-v'
    }

    switch ($Matches[1]) {
      '.gz' {
        $additional_parameters += '-z'
      }
      '.xz' {
        $additional_parameters += '-J'
      }
    }

    Write-Verbose "Extracting $Path archive"
    tar -C $DestinationPath -f $Path -mx @additional_parameters
  }
  elseif ((Split-Path $Path -Extension) -eq '.zip') {
    Write-Verbose "Extracting $Path archive"
    Expand-Archive $Path $DestinationPath -Force
  }
  else {
    Write-Error 'Expand-ArchiveEnhanced does not support extracting this type of archive.' -Category NotImplemented
  }
}

<#
.description
Downloads a file from specified URL.
#>
function Get-FileFromURL {
  param (
    # Path to save downloaded file
    [Parameter(Mandatory = $true, Position = 1)][string]$Path,
    # URL to download a file
    [Parameter(Mandatory = $true, Position = 0)][string]$URL
  )

  $ProgressPreference_temp = $ProgressPreference
  $ProgressPreference = 'SilentlyContinue'
  Write-Verbose "Downloading a file from $URL"
  Invoke-WebRequest $URL -MaximumRetryCount 2 -OutFile $Path -RetryIntervalSec 3
  $ProgressPreference = $ProgressPreference_temp
}

<#
.description
Creates a shortcut. This function only supports Windows.
#>
function New-Shortcut {
  param (
    # Parameters to use when using the shortcut
    [Parameter(Position = 2)][string]$Parameters,
    # Shourtcut path
    [Parameter(Mandatory = $true, Position = 0)][string]$Path,
    # Target of the shortcut
    [Parameter(Mandatory = $true, Position = 1)][string]$Target
  )

  if (!$IsWindows) {
    Write-Error 'New-Shortcut does not support operating systems other than Windows.'
    return
  }
  elseif (!(Test-Path $Target)) {
    Write-Error 'Cannot find the target.' -Category ObjectNotFound
    return
  }

  # -ComObject parameter must be specified otherwise New-Object will throw an error in newer PowerShell versions.
  $shortcut = (New-Object -ComObject 'WScript.Shell').CreateShortcut($Path)
  $shortcut.TargetPath = $Target

  if ($null -ne $Parameters) {
    $shortcut.Arguments = $Parameters
  }

  $target_display = $null -eq $Parameters ? $Target : "$Target $Parameters"
  Write-Verbose "Creating a shortcut to $target_display at $Path"
  $shortcut.Save()
}

<#
.description
Returns if the user has administrator permission on Windows, or root permission on Linux.
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
