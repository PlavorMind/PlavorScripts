#Configure web directory
#Configures web server directories.

param
([switch]$copy_global, #Copy files from global directory to each one if this is set
[string]$dir="__DEFAULT__") #Directory to configure for web server

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

"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
{"Extracting"
Expand-Archive "${tempdir}/Configurations.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/Configurations.zip" -Force}
else
{"Cannot download Configurations repository archive."
exit}

"Downloading Adminer"
Invoke-WebRequest "https://www.adminer.org/latest-en.php" -DisableKeepAlive -OutFile "${tempdir}/Adminer"
if (!(Test-Path "${tempdir}/Adminer"))
{"Cannot download Adminer."
exit}

if (Test-Path $dir)
{"Renaming existing web server directory"
Move-Item $dir "${dir}_old" -Force}

"Configuring web directories"
Move-Item "${tempdir}/Configurations-Main/Web" $dir -Force
"<!DOCTYPE html>">"${dir}/main/index.html"
New-Item "${dir}/main/adminer" -Force -ItemType Directory
Move-Item "${tempdir}/Adminer" "${dir}/main/adminer/index.php" -Force
New-Item "${dir}/wiki" -Force -ItemType Directory

if (Test-Path "${PSScriptRoot}/additional_files")
{"Copying additional files"
Copy-Item "${PSScriptRoot}/additional_files/*" "${dir}/" -Force -Recurse}

if ($copy_global)
{$virtual_hosts=Get-ChildItem $dir -Directory -Force -Name
foreach ($virtual_host in $virtual_hosts)
  {$files=Get-ChildItem "${dir}/global" -Force -Name
  foreach ($file in $files)
    {if (!(Test-Path "${dir}/${virtual_host}/${file}"))
      {"Copying ${file} file from global directory"
      Copy-Item "${dir}/global/${file}" "${dir}/${virtual_host}/${file}" -Force -Recurse}
    }
  }
}

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse
