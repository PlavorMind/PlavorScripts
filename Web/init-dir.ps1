#Initializes a directory for web server.

Param([Parameter(Position=0)][string]$dir) #Directory to initialize

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
{"Cannot download Adminer."}

"Configuring directory"
Move-Item "${tempdir}/Configurations-Main/Web" "${tempdir}/web" -Force
if (Test-Path "${tempdir}/adminer")
{New-Item "${tempdir}/web/public/main/adminer" -Force -ItemType Directory
Move-Item "${tempdir}/adminer" "${tempdir}/web/public/main/adminer/index.php" -Force}
New-Item "${tempdir}/web/public/gitea" -Force -ItemType Directory
New-Item "${tempdir}/web/public/wiki" -Force -ItemType Directory

if (Test-Path "${PSScriptRoot}/additional-files")
{"Copying additional files"
Copy-Item "${PSScriptRoot}/additional-files/*" "${tempdir}/web/" -Force -Recurse}

$default_directories=Get-ChildItem "${tempdir}/web/default" -Directory -Force -Name -Recurse
$default_files=Get-ChildItem "${tempdir}/web/default" -File -Force -Name -Recurse
$virtual_hosts=Get-ChildItem "${tempdir}/web/public" -Directory -Force -Name
foreach ($virtual_host in $virtual_hosts)
{foreach ($default_directory in $default_directories)
  {"Creating ${default_directory} directory"
  New-Item "${tempdir}/web/public/${virtual_host}/${default_directory}" -Force -ItemType Directory}

foreach ($default_file in $default_files)
  {if (!(Test-Path "${tempdir}/web/public/${virtual_host}/${default_file}"))
    {"Copying default ${default_file} file"
    Copy-Item "${tempdir}/web/default/${default_file}" "${tempdir}/web/public/${virtual_host}/${default_file}" -Force -Recurse}
  }
}

if (Test-Path $dir)
{"Renaming existing web server directory"
Move-Item $dir "${dir}-old" -Force}
"Moving web server directory"
Move-Item "${tempdir}/web" $dir -Force

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse
