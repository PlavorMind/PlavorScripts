#Install apps
#Installs some apps.

param
([string]$bleachbit_version="2.3.1272", #BleachBit unstable build version
[string]$gimp_version="2.10.12", #GIMP version
[string]$golang_version="1.13", #Go version
[string]$inkscape_installer="https://inkscape.org/gallery/item/13318/inkscape-0.92.4-x64.exe", #URL or file path to Inkscape installer
[string]$kdevelop_version="5.4-396", #KDevelop nightly build version
[string]$libreoffice_installer="https://dev-builds.libreoffice.org/pre-releases/win/x86_64/LibreOffice_6.3.2.2_Win_x64.msi", #URL or file path to LibreOffice installer
[string]$mpchc_version="1.7.13.112", #MPC-HC nightly build version
[string]$musicbrainz_picard_version="2.2", #MusicBrainz Picard version
[string]$nodejs_installer="https://nodejs.org/download/nightly/v13.0.0-nightly20190912902c9fac19/node-v13.0.0-nightly20190912902c9fac19-x64.msi", #URL or file path to Node.js installer
[string]$obs_installer="https://github.com/obsproject/obs-studio/releases/download/24.0.0-rc5/OBS-Studio-24.0-rc5-Full-Installer-x64.exe", #URL or file path to OBS Studio installer
[string]$peazip_version="6.9.2", #PeaZip version
[string]$python2_installer="https://www.python.org/ftp/python/2.7.16/python-2.7.16rc1.amd64.msi", #URL or file path to Python 2 installer
[string]$python3_installer="https://www.python.org/ftp/python/3.7.4/python-3.7.4rc1-amd64.exe", #URL or file path to Python 3 installer
[string]$qview_version="2.0", #qView version
[boolean]$vc_redist=$true, #Whether to install Microsoft Visual C++ Redistributable for Visual Studio 2019
[string]$vscodium_version="1.38.1") #VSCodium version

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!(Test-AdminPermission))
{"This script must be run as administrator on Windows."
exit}

#Do not use single quotes(') in ArgumentList otherwise text inside of them will be broken.

$inno_setup_parameters="/closeapplications /nocancel /norestart /restartapplications /silent /sp- /suppressmsgboxes"

#Must be before any other apps
if ($vc_redist)
{"Downloading Microsoft Visual C++ Redistributable for Visual Studio 2019"
Invoke-WebRequest "https://aka.ms/vs/16/release/VC_redist.x64.exe" -DisableKeepAlive -OutFile "${tempdir}/vc_redist.exe"
if (Test-Path "${tempdir}/vc_redist.exe")
  {"Installing"
  Start-Process "${tempdir}/vc_redist.exe" -ArgumentList "/norestart /passive" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/vc_redist.exe" -Force}
else
  {"Cannot download Microsoft Visual C++ Redistributable for Visual Studio 2019."}
}

if ($bleachbit_version -match "(\d+\.\d+)\.\d+")
{$bleachbit_majorversion=$Matches[1]
"Downloading BleachBit"
Invoke-WebRequest "https://ci.bleachbit.org/dl/${bleachbit_version}/BleachBit-${bleachbit_majorversion}-setup-English.exe" -DisableKeepAlive -OutFile "${tempdir}/bleachbit.exe"
if (Test-Path "${tempdir}/bleachbit.exe")
  {"Installing"
  Start-Process "${tempdir}/bleachbit.exe" -ArgumentList "/S" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/bleachbit.exe" -Force}
else
  {"Cannot download BleachBit."}
}

<#
"Downloading Firefox Nightly"
Invoke-WebRequest "https://download.mozilla.org/?product=firefox-nightly-stub" -DisableKeepAlive -OutFile "${tempdir}/Firefox Nightly.exe"
if (Test-Path "${tempdir}/Firefox Nightly.exe")
{"Installing"
Start-Process "${tempdir}/Firefox Nightly.exe" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/Firefox Nightly.exe" -Force}
else
{"Cannot download Firefox Nightly."}
#>

if ($gimp_version -match "(\d+\.\d+)\.\d+")
{$gimp_majorversion=$Matches[1]
"Downloading GIMP"
Invoke-WebRequest "https://download.gimp.org/mirror/pub/gimp/v${gimp_majorversion}/windows/gimp-${gimp_version}-setup-3.exe" -DisableKeepAlive -OutFile "${tempdir}/gimp.exe"
if (Test-Path "${tempdir}/gimp.exe")
  {"Installing"
  Start-Process "${tempdir}/gimp.exe" -ArgumentList "/S" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/gimp.exe" -Force}
else
  {"Cannot download GIMP."}
}

if ($golang_version)
{"Downloading Go"
Invoke-WebRequest "https://dl.google.com/go/go${golang_version}.windows-amd64.msi" -DisableKeepAlive -OutFile "${tempdir}/golang.msi"
if (Test-Path "${tempdir}/golang.msi")
  {$installer="${tempdir}/golang.msi".Replace("/","\")
  "Installing"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/golang.msi" -Force}
else
  {"Cannot download Go."}
}

if ($inkscape_installer)
{$output=FileURLDetector $inkscape_installer
if ($output)
  {"Installing Inkscape"
  Start-Process $output -ArgumentList "/S" -Wait
  if ($output -like "${tempdir}*")
    {"Deleting a temporary file"
    Remove-Item $output -Force}
  }
else
  {"Cannot download or find Inkscape."}
}

if ($kdevelop_version)
{"Downloading KDevelop"
Invoke-WebRequest "https://binary-factory.kde.org/view/Management/job/KDevelop_Nightly_win64/lastSuccessfulBuild/artifact/kdevelop-${kdevelop_version}-windows-msvc2017_64-cl.exe" -DisableKeepAlive -OutFile "${tempdir}/kdevelop.exe"
if (Test-Path "${tempdir}/kdevelop.exe")
  {"Installing"
  Start-Process "${tempdir}/kdevelop.exe" -ArgumentList "/S" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/kdevelop.exe" -Force}
else
  {"Cannot download KDevelop."}
}

if ($libreoffice_installer)
{$output=FileURLDetector $libreoffice_installer
if ($output)
  {$installer=$output.Replace("/","\")
  "Installing LibreOffice"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" RebootYesNo=No REGISTER_ALL_MSO_TYPES=1 /norestart /passive" -Wait
  if ($output -like "${tempdir}*")
    {"Deleting a temporary file"
    Remove-Item $output -Force}
  }
else
  {"Cannot download or find LibreOffice."}
}

if ($mpchc_version)
{"Downloading MPC-HC"
Invoke-WebRequest "https://nightly.mpc-hc.org/MPC-HC.${mpchc_version}.x64.exe" -DisableKeepAlive -OutFile "${tempdir}/mpchc.exe"
if (Test-Path "${tempdir}/mpchc.exe")
  {"Installing"
  Start-Process "${tempdir}/mpchc.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon\common`"" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/mpchc.exe" -Force}
else
  {"Cannot download MPC-HC."}
}

if ($musicbrainz_picard_version)
{"Downloading MusicBrainz Picard"
Invoke-WebRequest "https://musicbrainz.osuosl.org/pub/musicbrainz/picard/picard-setup-${musicbrainz_picard_version}.exe" -DisableKeepAlive -OutFile "${tempdir}/musicbrainz_picard.exe"
if (Test-Path "${tempdir}/musicbrainz_picard.exe")
  {"Installing"
  Start-Process "${tempdir}/musicbrainz_picard.exe" -ArgumentList "/S" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/musicbrainz_picard.exe" -Force}
else
  {"Cannot download MusicBrainz Picard."}
}

if ($nodejs_installer)
{$output=FileURLDetector $nodejs_installer
if ($output)
  {$installer=$output.Replace("/","\")
  "Installing Node.js"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  if ($output -like "${tempdir}*")
    {"Deleting a temporary file"
    Remove-Item $output -Force}
  }
else
  {"Cannot download or find Node.js."}
}

$output=FileURLDetector $obs_installer
if ($output)
{"Installing OBS Studio"
Start-Process $output -ArgumentList "/S" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find OBS Studio."}

"Downloading PeaZip"
Invoke-WebRequest "http://www.peazip.org/downloads/peazip-${peazip_version}.WIN64.exe" -DisableKeepAlive -OutFile "${tempdir}/PeaZip.exe"
if (Test-Path "${tempdir}/PeaZip.exe")
{"Installing"
Start-Process "${tempdir}/PeaZip.exe" -ArgumentList $inno_setup_parameters -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/PeaZip.exe" -Force

"Moving a shortcut"
if (Test-Path "${Env:USERPROFILE}/Desktop/PeaZip.lnk")
  {Move-Item "${Env:USERPROFILE}/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
if (Test-Path "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk")
  {Move-Item "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
}
else
{"Cannot download PeaZip."}

$output=FileURLDetector $python2_installer
if ($output)
{$output=$output.Replace("/","\")
"Installing Python 2"
Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${output}`" /norestart /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find Python 2."}

$output=FileURLDetector $python3_installer
if ($output)
{"Installing Python 3"
Start-Process $output -ArgumentList "InstallAllUsers=1 PrependPath=1 /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find Python 3."}

"Downloading qView"
Invoke-WebRequest "https://github.com/jurplel/qView/releases/download/${qview_version}/qView-${qview_version}-win64.exe" -DisableKeepAlive -OutFile "${tempdir}/qView.exe"
if (Test-Path "${tempdir}/qView.exe")
{"Installing"
Start-Process "${tempdir}/qView.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon`"" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/qView.exe" -Force}
else
{"Cannot download qView."}

"Downloading TeamViewer"
Invoke-WebRequest "https://download.teamviewer.com/download/TeamViewer_Setup.exe" -DisableKeepAlive -OutFile "${tempdir}/TeamViewer.exe"
if (Test-Path "${tempdir}/TeamViewer.exe")
{"Installing"
Start-Process "${tempdir}/TeamViewer.exe" -ArgumentList "/S" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/TeamViewer.exe" -Force}
else
{"Cannot download TeamViewer."}

"Downloading VSCodium"
Invoke-WebRequest "https://github.com/VSCodium/vscodium/releases/download/${vscodium_version}/VSCodiumSetup-x64-${vscodium_version}.exe" -DisableKeepAlive -OutFile "${tempdir}/VSCodium.exe"
if (Test-Path "${tempdir}/VSCodium.exe")
{"Installing"
Start-Process "${tempdir}/VSCodium.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"addcontextmenufiles,addcontextmenufolders,addtopath,associatewithfiles,desktopicon,!runcode`"" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/VSCodium.exe" -Force}
else
{"Cannot download VSCodium."}
