#Configures a directory for web server.

Param([Parameter(Position=0)][string]$dir) #Directory to configure for web server

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$dir)
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
Invoke-WebRequest "https://www.adminer.org/latest-en.php" -DisableKeepAlive -OutFile "${tempdir}/adminer"
if (!(Test-Path "${tempdir}/Adminer"))
{"Cannot download Adminer."
exit}

"Configuring directory"
Move-Item "${tempdir}/Configurations-Main/Web" "${tempdir}/web" -Force
New-Item "${tempdir}/web/public/main/adminer" -Force -ItemType Directory
Move-Item "${tempdir}/adminer" "${tempdir}/web/public/main/adminer/index.php" -Force
New-Item "${tempdir}/web/public/gitea" -Force -ItemType Directory
New-Item "${tempdir}/web/public/wiki" -Force -ItemType Directory

if (Test-Path "${PSScriptRoot}/additional_files")
{"Copying additional files"
Copy-Item "${PSScriptRoot}/additional_files/*" "${tempdir}/web/" -Force -Recurse}

$virtual_hosts=Get-ChildItem "${tempdir}/web/public" -Directory -Force -Name
foreach ($virtual_host in $virtual_hosts)
{$files=Get-ChildItem "${tempdir}/web/default" -Force -Name
foreach ($file in $files)
  {if (!(Test-Path "${tempdir}/web/public/${virtual_host}/${file}"))
    {"Copying ${file} file from global directory"
    Copy-Item "${tempdir}/web/default/${file}"  "${tempdir}/web/public/${virtual_host}/${file}" -Force -Recurse}
  }
}

if (Test-Path $dir)
{"Renaming existing web server directory"
Move-Item $dir "${dir}_old" -Force}

"Moving web server directory"
Move-Item "${tempdir}/web" $dir -Force

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse
