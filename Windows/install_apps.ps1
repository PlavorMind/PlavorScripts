#Install apps
#Installs some apps.

Param
([string]$bleachbit_version="2.3.1294", #BleachBit unstable build version
[string]$gimp_version="2.10.12", #GIMP version
[string]$golang_version="1.13.1", #Go version
[string]$inkscape_installer="https://inkscape.org/gallery/item/13318/inkscape-0.92.4-x64.exe", #URL or file path to Inkscape installer
[string]$kdevelop_version="5.4-416", #KDevelop nightly build version
[string]$libreoffice_installer="https://dev-builds.libreoffice.org/pre-releases/win/x86_64/LibreOffice_6.3.2.2_Win_x64.msi", #URL or file path to LibreOffice installer
[string]$musicbrainz_picard_version="2.2.1", #MusicBrainz Picard version
[string]$nodejs_installer="https://nodejs.org/download/nightly/v13.0.0-nightly2019100424011de907/node-v13.0.0-nightly2019100424011de907-x64.msi", #URL or file path to Node.js installer
[string]$obs_version="24.0.1", #OBS Studio version
[string]$peazip_version="6.9.2", #PeaZip version
[string]$python2_version="2.7.16rc1", #Python 2 version
[string]$python3_version="3.7.5rc1", #Python 3 version
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

if ($bleachbit_version -match "^(\d+\.\d+)\.\d+$")
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

if ($gimp_version -match "^(\d+\.\d+)\.\d+$")
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
{$output=Get-FilePathFromUri $inkscape_installer
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
{$output=Get-FilePathFromUri $libreoffice_installer
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
{$output=Get-FilePathFromUri $nodejs_installer
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

if ($obs_version -match "^(\d+\.\d+)(-rc\d+|\.\d+)?$")
{if ($Matches[2])
  {if ($Matches[2] -like "-rc*")
    {$obs_tagversion=$Matches[1]+".0"+$Matches[2]}
  else
    {$obs_tagversion=$obs_version}
  }
else
  {$obs_tagversion=$Matches[1]+".0"}
"Downloading OBS Studio"
Invoke-WebRequest "https://github.com/obsproject/obs-studio/releases/download/${obs_tagversion}/OBS-Studio-${obs_version}-Full-Installer-x64.exe" -DisableKeepAlive -OutFile "${tempdir}/obs.exe"
if (Test-Path "${tempdir}/obs.exe")
  {"Installing"
  Start-Process "${tempdir}/obs.exe" -ArgumentList "/S" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/obs.exe" -Force}
else
  {"Cannot download OBS Studio."}
}

if ($peazip_version)
{"Downloading PeaZip"
Invoke-WebRequest "http://www.peazip.org/downloads/peazip-${peazip_version}.WIN64.exe" -DisableKeepAlive -OutFile "${tempdir}/peazip.exe"
if (Test-Path "${tempdir}/peazip.exe")
  {"Installing"
  Start-Process "${tempdir}/peazip.exe" -ArgumentList $inno_setup_parameters -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/peazip.exe" -Force

  "Moving a shortcut"
  if (Test-Path "${Env:USERPROFILE}/Desktop/PeaZip.lnk")
    {Move-Item "${Env:USERPROFILE}/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
  if (Test-Path "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk")
    {Move-Item "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
  }
else
  {"Cannot download PeaZip."}
}

if ($python2_version -match "^(\d+\.\d+\.\d+)(([ab]|rc)\d+)?$")
{$python2_majorversion=$Matches[1]
"Downloading Python 2"
Invoke-WebRequest "https://www.python.org/ftp/python/${python2_majorversion}/python-${python2_version}.amd64.msi" -DisableKeepAlive -OutFile "${tempdir}/python2.msi"
if (Test-Path "${tempdir}/python2.msi")
  {$installer="${tempdir}/python2.msi".Replace("/","\")
  "Installing"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/python2.msi" -Force}
else
  {"Cannot download Python 2."}
}

if ($python3_version -match "^(\d+\.\d+\.\d+)(([ab]|rc)\d+)?$")
{$python3_majorversion=$Matches[1]
"Downloading Python 3"
Invoke-WebRequest "https://www.python.org/ftp/python/${python3_majorversion}/python-${python3_version}-amd64.exe" -DisableKeepAlive -OutFile "${tempdir}/python3.exe"
if (Test-Path "${tempdir}/python3.exe")
  {"Installing"
  Start-Process "${tempdir}/python3.exe" -ArgumentList "InstallAllUsers=1 PrependPath=1 /passive" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/python3.exe" -Force}
else
  {"Cannot download Python 3."}
}

if ($qview_version)
{"Downloading qView"
Invoke-WebRequest "https://github.com/jurplel/qView/releases/download/${qview_version}/qView-${qview_version}-win64.exe" -DisableKeepAlive -OutFile "${tempdir}/qview.exe"
if (Test-Path "${tempdir}/qview.exe")
  {"Installing"
  Start-Process "${tempdir}/qview.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon`"" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/qview.exe" -Force}
else
  {"Cannot download qView."}
}

if ($vscodium_version)
{"Downloading VSCodium"
Invoke-WebRequest "https://github.com/VSCodium/vscodium/releases/download/${vscodium_version}/VSCodiumSetup-x64-${vscodium_version}.exe" -DisableKeepAlive -OutFile "${tempdir}/vscodium.exe"
if (Test-Path "${tempdir}/vscodium.exe")
  {"Installing"
  Start-Process "${tempdir}/vscodium.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"addcontextmenufiles,addcontextmenufolders,addtopath,associatewithfiles,desktopicon,!runcode`"" -Wait
  "Deleting a temporary file"
  Remove-Item "${tempdir}/vscodium.exe" -Force}
else
  {"Cannot download VSCodium."}
}
