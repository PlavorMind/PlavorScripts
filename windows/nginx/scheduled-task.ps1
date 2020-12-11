#Manages the scheduled task for starting nginx automatically.

Param
([Parameter(Position=0)][string]$action, #Action to run
[string]$dir) #nginx directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{if (!(."${PSScriptRoot}/../../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/nginx"}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator." -Category PermissionDenied
exit}

if ($action)
{if (Get-ScheduledTask "nginx" -ErrorAction Ignore)
  {switch ($action)
    {"delete"
      {Write-Verbose "Deleting the scheduled task"
      Unregister-ScheduledTask "nginx" -Confirm:$false}
    "disable"
      {Write-Verbose "Disabling the scheduled task"
      Disable-ScheduledTask "nginx"}
    }
  }
else
  {Write-Error "Cannot find the scheduled task." -Category ObjectNotFound}
}
else
{if (Get-ScheduledTask "nginx" -ErrorAction Ignore)
  {Write-Verbose "Enabling the scheduled task"
  Enable-ScheduledTask "nginx"}
elseif (Test-Path "${dir}/start.ps1")
  {Write-Verbose "Creating a scheduled task"
  if (Test-Path "C:/Program Files/PowerShell/7-preview/pwsh.exe")
    {$task_action=New-ScheduledTaskAction "C:/Program Files/PowerShell/7-preview/pwsh.exe" "-ExecutionPolicy Bypass `"${dir}/start.ps1`""}
  else
    {$task_action=New-ScheduledTaskAction "powershell" "-ExecutionPolicy Bypass `"${dir}/start.ps1`""}
  $task_principal=New-ScheduledTaskPrincipal "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
  $task_settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8 -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit 0
  $task_trigger=New-ScheduledTaskTrigger -AtStartup
  Register-ScheduledTask "nginx" -Action $task_action -Description "Starts nginx" -Force -Principal $task_principal -Settings $task_settings -Trigger $task_trigger}
else
  {Write-Error "Cannot find start.ps1 file." -Category ObjectNotFound}
}
