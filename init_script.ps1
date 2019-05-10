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
([string]$arguments="", #Arguments of a shortcut
[string]$path, #Path of a shortcut
[string]$target) #Target of a shortcut

if ($isWindows -and (Test-Path $target))
  {$shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($path)
  $shortcut.Arguments=$arguments
  $shortcut.TargetPath=$target
  $shortcut.Save()
  if (Test-Path $path)
    {return $true}
  }
}

if (!$isLinux -and !$isMacOS -and !$isWindows)
{$isLinux=$false
$isMacOS=$false
$isWindows=$true}

if ($isLinux)
{$tempdir="/tmp"}
elseif ($isMacOS)
{$tempdir="/private/tmp"}
elseif ($isWindows)
{$tempdir=$Env:TEMP}
