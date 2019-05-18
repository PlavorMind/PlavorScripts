#Dolphin installer
#Installs Dolphin.

param
([string]$dir="C:/Program Files/Dolphin", #Directory to install Dolphin
[switch]$portable) #Installs as portable mode if this is set

."${PSScriptRoot}/../../init_script.ps1"

if (!$IsWindows)
{"Your operating system is not supported."
exit}

#This is the version that can run Mario Kart Wii with Direct3D 11 - DO NOT UPDATE
#Broken again after https://github.com/dolphin-emu/dolphin/pull/8051
#TW90aGVyZnVja2luZyBKb3NKdWljZQ==
$version="5.0-10084"

if (!(Expand-ArchiveWith7Zip "https://dl.dolphin-emu.org/builds/dolphin-master-${version}-x64.7z" $tempdir))
{"Cannot download Dolphin archive or find 7-Zip."
exit}

"Uninstalling existing Dolphin"
."${PSScriptRoot}/uninstall.ps1" -dir $dir

"Moving Dolphin directory"
Move-Item "${tempdir}/Dolphin-x64" $dir -Force

if ($portable)
{"Enabling portable mode"
"" > "${dir}/portable.txt"}
else
{"Creating shortcuts"
if (!(New-Shortcut -Path "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Dolphin.lnk" -TargetPath "${dir}/Dolphin.exe"))
  {"Cannot create a shortcut on Start Menu."}
if (!(New-Shortcut -Path "C:/Users/Public/Desktop/Dolphin.lnk" -TargetPath "${dir}/Dolphin.exe"))
  {"Cannot create a shortcut on desktop."}
}
