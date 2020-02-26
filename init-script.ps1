#Initializes functions, variables, etc. for PlavorScripts.

function Get-FilePathFromUri
{Param
([Parameter(Mandatory=$true,Position=0)][string]$Uri)

#For backward compatibility
return Get-LocalFile $Uri}

function Get-LocalFile
{Param([Parameter(Mandatory=$true,Position=0)][string]$URL)

if ($URL -match "^https?:\/\/")
  {if ($URL -match "[^\\/:*?`"<>|]+\.[^\\/:*?`"<>|]+$")
    {$filename=$Matches[0]}
  else
    {$filename="get-localfile"}
  #TODO: Prepend "URL detected" but with the better grammar
  Write-Verbose "Downloading a file from "+$URL
  Invoke-WebRequest $URL -DisableKeepAlive -OutFile $PlaScrTempDirectory+"/"+$filename
  if (Test-Path $PlaScrTempDirectory+"/"+$filename)
    {return $PlaScrTempDirectory+"/"+$filename}
  }
elseif (Test-Path $URL)
  {return $URL}
return $false}

function New-Shortcut
{Param
([Parameter(Position=2)][string]$Arguments, #Arguments of a shortcut
[Parameter(Mandatory=$true,Position=0)][string]$Path, #Path of a shortcut
[Parameter(Mandatory=$true,Position=1)][string]$TargetPath) #Target of a shortcut

if (Test-Path $TargetPath)
  {if ($IsWindows)
    {$shortcut=(New-Object "WScript.Shell").CreateShortcut($Path)
    if ($Arguments)
      {$shortcut.Arguments=$Arguments}
    $shortcut.TargetPath=$TargetPath
    Write-Verbose "Creating a shortcut to "+$TargetPath+" at "+$Path
    $shortcut.Save()}
  else
    {Write-Error "Your operating system is not supported."}
  }
else
  {Write-Error "Cannot find the target."}
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
