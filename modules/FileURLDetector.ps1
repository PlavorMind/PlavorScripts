#FileURLDetector
#Detects file path or URL and download or check if it is exists.

param([string]$path) #File path or URL to download or check if it is exists

."${PSScriptRoot}/OSDetectorDebug.ps1"
."${PSScriptRoot}/SetTempDir.ps1"

$fud_output=$false
$fud_web=$false

if ($path -match "https?:\/\/.+")
{$fud_web=$true
Invoke-WebRequest $path -DisableKeepAlive -OutFile "${tempdir}/fud_output"
if (Test-Path "${tempdir}/fud_output")
  {$fud_output="${tempdir}/fud_output"}
}
elseif (Test-Path $path)
{$fud_output=$path}
