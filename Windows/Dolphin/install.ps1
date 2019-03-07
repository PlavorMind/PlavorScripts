#Dolphin installer
#Installs Dolphin.

param
([string]$dir="C:/Program Files/Dolphin", #Directory to install Dolphin
[switch]$portable, #Installs as portable mode if this is set
[string]$version="5.0-9620") #Version to install

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/../../modules/SetTempDir.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

if (Test-Path "C:/Program Files/7-Zip/7z.exe")
{"Downloading Dolphin archive"
Invoke-WebRequest "https://dl.dolphin-emu.org/builds/dolphin-master-${version}-x64.7z" -DisableKeepAlive -OutFile "${tempdir}/Dolphin.7z"
if (Test-Path "${tempdir}/Dolphin.7z")
  {"Extracting"
  ."C:/Program Files/7-Zip/7z.exe" x "${tempdir}/Dolphin.7z" -aoa -bt -o"${tempdir}" -spe -y
  "Deleting a temporary file"
  Remove-Item "${tempdir}/Dolphin.7z" -Force}
else
  {"Cannot download Dolphin archive."
  exit}
}
else
{"Cannot find 7-Zip."
exit}

"Uninstalling existing Dolphin"
."${PSScriptRoot}/uninstall.ps1" -dir $dir

"Moving Dolphin directory"
Move-Item "${tempdir}/Dolphin-x64" $dir -Force

if ($portable)
{"Enabling portable mode"
"">"${dir}/portable.txt"}
else
{"Creating shortcuts"
."${PSScriptRoot}/../../modules/CreateShortcut.ps1" -path "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Dolphin.lnk" -target "${dir}/Dolphin.exe"
."${PSScriptRoot}/../../modules/CreateShortcut.ps1" -path "C:/Users/Public/Desktop/Dolphin.lnk" -target "${dir}/Dolphin.exe"}
