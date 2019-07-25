#Build additional files
#Builds additional files for Configure web directory script.

param([string]$dir="__DEFAULT__") #Web server directory

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$dir="/plavormind/web"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web"}
else
  {"Cannot detect default directory."
  exit}
}

if (Test-Path "${PSScriptRoot}/additional_files")
{"Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional_files" "${PSScriptRoot}/additional_files_old" -Force}

"Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional_files" -Force -ItemType Directory

if (Test-Path "${dir}/global")
{"Creating global directory"
New-Item "${PSScriptRoot}/additional_files/global" -Force -ItemType Directory

if (Test-Path "${dir}/global/error")
  {"Creating global/error directory"
  New-Item "${PSScriptRoot}/additional_files/global/error" -Force -ItemType Directory

  if (Test-Path "${dir}/global/error/2dr3drn_mark.png")
    {"Copying global/error/2dr3drn_mark.png file"
    Copy-Item "${dir}/global/error/2dr3drn_mark.png" "${PSScriptRoot}/additional_files/global/error/" -Force}

  if (Test-Path "${dir}/global/error/shinil_yghmrd.jpg")
    {"Copying global/error/shinil_yghmrd.jpg file"
    Copy-Item "${dir}/global/error/shinil_yghmrd.jpg" "${PSScriptRoot}/additional_files/global/error/" -Force}

  if (Test-Path "${dir}/global/error/x1_namdohyun_letter.jpg")
    {"Copying global/error/x1_namdohyun_letter.jpg file"
    Copy-Item "${dir}/global/error/x1_namdohyun_letter.jpg" "${PSScriptRoot}/additional_files/global/error/" -Force}
  }

if (Test-Path "${dir}/global/favicon.ico")
  {"Copying global/favicon.ico file"
  Copy-Item "${dir}/global/favicon.ico" "${PSScriptRoot}/additional_files/global/"}
}
