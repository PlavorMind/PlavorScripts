#FileURLDetector
#Detects URL or file path and download or check if it exists.

param([string]$path) #URL or file path to a file download or check if it is exists

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
