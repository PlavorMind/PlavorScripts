#Initialize script
#Initializes functions, variables, etc. for PlavorScripts.

function Expand-ArchiveWith7Zip
{if ($IsWindows -and (Test-Path "C:/Program Files/7-Zip/7z.exe"))
  {$output=FileURLDetector $args[0]
  if ($output)
    {$destination=$args[1] #Added to avoid a bug when running 7z.exe
    New-Item $destination -Force -ItemType Directory
    ."C:/Program Files/7-Zip/7z.exe" x $output -aoa -bt -o"${destination}" -spe -y
    return $true
    if ($output -like "${tempdir}*")
      {Remove-Item $output -Force}
    }
  }
}

function FileURLDetector
{if ($args[0] -match "https?:\/\/.+")
  {if ($args[0] -match "https?:\/\/.+\/([^\\/:*?`"<>|]+\.[^\\/:*?`"<>|]+)")
    {$filename=$Matches[1]}
  else
    {$filename="fud_output"}
  Invoke-WebRequest $args[0] -DisableKeepAlive -OutFile "${tempdir}/${filename}"
  if (Test-Path "${tempdir}/${filename}")
    {return "${tempdir}/${filename}"}
  }
elseif (Test-Path $args[0])
  {return $args[0]}
}

function Get-FilePathFromUri
{Param
([Parameter(Mandatory=$true,Position=0)][string]$Uri)

$output=$false
if ($Uri -match "^https?:\/\/")
  {if ($Uri -match "[^\\/:*?`"<>|]+\.[^\\/:*?`"<>|]+$")
    {$filename=$Matches[0]}
  else
    {$filename="test_fileurl_output"}
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
  $shortcut.Save()
  if (Test-Path $Path)
    {return $true}
  }
}

function Test-AdminPermission
{if ($IsWindows)
  {$permissions=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  return $permissions.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
else
  {return $false}
}

if (!$IsLinux -and !$IsMacOS -and !$IsWindows)
{$IsLinux=$false
$IsMacOS=$false
$IsWindows=$true}

if ($IsLinux)
{$tempdir="/tmp"}
elseif ($IsMacOS)
{$tempdir="/private/tmp"}
elseif ($IsWindows)
{$tempdir=$Env:TEMP}
