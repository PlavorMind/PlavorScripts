#Extract7z
#Extracts 7z file with 7-Zip

param
([string]$path, #Path of a 7z file to extract
[string]$savedir) #Directory to save extracted files

."${PSScriptRoot}/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

$e7z_success=$false

if (Test-Path "C:/Program Files/7-Zip/7z.exe")
{."${PSScriptRoot}/FileURLDetector.ps1" -path $path
if ($fud_output -and Test-Path $savedir)
  {."C:/Program Files/7-Zip/7z.exe" x $fud_output -aoa -bt -o"${savedir}" -spe -y
  $e7z_success=$true
  if ($fud_web)
    {Remove-Item $fud_output -Force}
  }
}
