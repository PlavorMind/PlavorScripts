#Initializes functions, variables, etc. for PlavorScripts.

function Get-FilePathFromUri
{Param
([Parameter(Mandatory=$true,Position=0)][string]$Uri)

$output=$false
if ($Uri -match "^https?:\/\/")
  {if ($Uri -match "[^\\/:*?`"<>|]+\.[^\\/:*?`"<>|]+$")
    {$filename=$Matches[0]}
  else
    {$filename="get-filepathfromuri-output"}
  Invoke-WebRequest $Uri -DisableKeepAlive -OutFile "${tempdir}/${filename}"
  if (Test-Path "${tempdir}/${filename}")
    {$output="${tempdir}/${filename}"}
  }
elseif (Test-Path $Uri)
  {$output=$Uri}
return $output}

function New-Shortcut
{Param
([Parameter(Position=2)][string]$Arguments, #Arguments of a shortcut
[Parameter(Mandatory=$true,Position=0)][string]$Path, #Path of a shortcut
[Parameter(Mandatory=$true,Position=1)][string]$TargetPath) #Target of a shortcut

if ($IsWindows -and (Test-Path $TargetPath))
  {$shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($Path)
  if ($Arguments)
    {$shortcut.Arguments=$Arguments}
  $shortcut.TargetPath=$TargetPath
  $shortcut.Save()}
}

function Test-AdminPermission
{if ($IsWindows)
  {$permissions=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  return $permissions.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
else
  {if ((id --user) -eq 0)
    {return $true}
  else
    {return $false}
  }
}

if ($PSVersionTable."PSVersion"."Major" -lt 7)
{Write-Error "PlavorScripts require PowerShell 7 or newer."
return $false}

if ($IsLinux)
{$PlaScrDefaultBaseDirectory="/plavormind"
$PlaScrTempDirectory="/tmp"}
elseif ($IsMacOS)
{$PlaScrDefaultBaseDirectory="/plavormind"
$PlaScrTempDirectory="/private/tmp"}
elseif ($IsWindows)
{$PlaScrDefaultBaseDirectory="C:/plavormind"
$PlaScrDefaultPHPPath="${PlaScrDefaultBaseDirectory}/php-ts/php.exe"
$PlaScrTempDirectory=$Env:TEMP}

#For backward compatibility
$tempdir=$PlaScrTempDirectory

return $true
