# Creates a shortcut.
# This function only supports Windows.
function New-Shortcut
  {param
  # Parameters to use when using the shortcut
  ([Parameter(Position=2)][string]$Arguments,
  # Shourtcut path
  [Parameter(Mandatory=$true, Position=0)][string]$Path,
  # Target of the shortcut
  [Parameter(Mandatory=$true, Position=1)][string]$TargetPath)

  # Check requirements
  if (!$IsWindows)
    {Write-Error 'New-Shortcut does not support operating systems other than Windows.'
    return}

  if (Test-Path $TargetPath)
    # -ComObject parameter must be specified otherwise New-Object will throw an error in newer PowerShell versions.
    {$shortcut=(New-Object -ComObject 'WScript.Shell').CreateShortcut($Path)
    $shortcut.TargetPath=$TargetPath

    if ($Arguments)
      {$shortcut.Arguments=$Arguments
      $target_display="${TargetPath} ${Arguments}"}
    else
      {$target_display=$TargetPath}

    Write-Verbose "Creating a shortcut to ${target_display} at ${Path}"
    $shortcut.Save()}
  else
    {Write-Error 'Cannot find the target.' -Category ResourceUnavailable}
  }

# Returns if the user has administrator permission on Windows, or root permission on Linux.
function Test-AdminPermission
  {if ($IsLinux)
    {return (id --user) -eq 0}
  elseif ($IsWindows)
    {$identity=[Security.Principal.WindowsIdentity]::GetCurrent()
    $principal=New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
  }
