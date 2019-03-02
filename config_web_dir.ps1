#Configure web directory
#Configure web server directories.

param([string]$dir="/web")

."${PSScriptRoot}/modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/modules/SetTempDir.ps1"

$cwd_success=$false

$subdirs=@("Main","Public","Wiki")

Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
{Expand-Archive "${tempdir}/Configurations.zip" $tempdir -Force
Remove-Item "${tempdir}/Configurations.zip" -Force
Move-Item "${tempdir}/Configurations-Main/Web" "${tempdir}/Web" -Force
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse}
else
{exit}

New-Item $dir -Force -ItemType Directory
foreach ($subdir in $subdirs)
{Copy-Item "${tempdir}/Web" "${dir}/${subdir}" -Force -Recurse}
$cwd_success=$true

Remove-Item "${tempdir}/Web" -Force -Recurse