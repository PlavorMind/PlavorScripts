# Returns whether the user has administrator permission on Windows, or root permission on Linux.
function Test-AdminPermission
  {if ($IsLinux)
    {return (id --user) -eq 0}
  elseif ($IsWindows)
    {$permissions=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $permissions.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
  }
