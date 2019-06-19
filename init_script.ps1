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
  {if ($args[0] -match "https?:\/\/.+\/(.+\..+)")
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

function New-Shortcut
{param
([string]$Arguments="", #Arguments of a shortcut
[string]$Path, #Path of a shortcut
[string]$TargetPath) #Target of a shortcut

if ($IsWindows -and (Test-Path $TargetPath))
  {$shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($Path)
  $shortcut.Arguments=$Arguments
  $shortcut.TargetPath=$TargetPath
  $shortcut.Save()
  if (Test-Path $Path)
    {return $true}
  }
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
