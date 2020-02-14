#Initializes a directory for web.

Param([Parameter(Position=0)][string]$dir) #Directory to initialize

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$dir)
{if ($IsLinux)
  {$dir="/plavormind/web"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web"}
else
  {Write-Error "Cannot detect default directory." -Category NotSpecified
  exit}
}

Write-Verbose "Downloading configurations"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/config.zip"
if ("${tempdir}/config.zip")
{Write-Verbose "Extracting"
Expand-Archive "${tempdir}/config.zip" $tempdir -Force
Write-Verbose "Deleting a file and directory that are no longer needed"
Remove-Item "${tempdir}/config.zip" -Force
Move-Item "${tempdir}/Configurations-master/web" "${tempdir}/web" -Force
Remove-Item "${tempdir}/Configurations-master" -Force -Recurse}
else
{Write-Error "Cannot download configurations." -Category ConnectionError
exit}

Write-Verbose "Creating a directory for Adminer"
New-Item "${tempdir}/web/public/main/adminer" -Force -ItemType Directory
Write-Verbose "Downloading Adminer"
Invoke-WebRequest "https://www.adminer.org/latest-en.php" -DisableKeepAlive -OutFile "${tempdir}/web/public/main/adminer/index.php"
if (!(Test-Path "${tempdir}/web/public/main/adminer/index.php"))
{Write-Error "Cannot download Adminer." -Category ConnectionError}

Write-Verbose "Creating directories for virtual hosts"
New-Item "${tempdir}/web/public/gitea" -Force -ItemType Directory
New-Item "${tempdir}/web/public/wiki" -Force -ItemType Directory

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Verbose "Copying additional files"
Copy-Item "${PSScriptRoot}/additional-files/*" "${tempdir}/web/" -Force -Recurse}
else
{Write-Warning "Skipped copying additional files: Cannot find additional-files directory."}

foreach ($virtual_host in Get-ChildItem "${tempdir}/web/public" -Directory -Force -Name)
{foreach ($default_directory in Get-ChildItem "${tempdir}/web/default" -Directory -Force -Name -Recurse)
  {Write-Verbose "Creating ${default_directory} directory"
  New-Item "${tempdir}/web/public/${virtual_host}/${default_directory}" -Force -ItemType Directory}

foreach ($default_file in Get-ChildItem "${tempdir}/web/default" -File -Force -Name -Recurse)
  {if (!(Test-Path "${tempdir}/web/public/${virtual_host}/${default_file}"))
    {Write-Verbose "Copying ${default_file} file"
    Copy-Item "${tempdir}/web/default/${default_file}" "${tempdir}/web/public/${virtual_host}/${default_file}" -Force -Recurse}
  }
}

if (Test-Path $dir)
{Write-Warning "Renaming existing web directory"
Move-Item $dir "${dir}-old" -Force}
Write-Verbose "Moving web directory from temporary directory to destination directory"
Move-Item "${tempdir}/web" $dir -Force
