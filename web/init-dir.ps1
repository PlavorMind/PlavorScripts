#Initializes a directory for web.

Param([Parameter(Position=0)][string]$dir) #Directory to initialize

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/web"}

Get-ConfigFromArchive "web" "${PlaScrTempDirectory}/web"
if (!(Test-Path "${PlaScrTempDirectory}/web"))
{exit}

Write-Verbose "Creating a directory for Adminer"
New-Item "${PlaScrTempDirectory}/web/public/main/adminer" -Force -ItemType Directory
Write-Verbose "Downloading Adminer"
Invoke-WebRequest "https://www.adminer.org/latest-en.php" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/web/public/main/adminer/index.php"
if (!(Test-Path "${PlaScrTempDirectory}/web/public/main/adminer/index.php"))
{Write-Error "Cannot download Adminer." -Category ConnectionError}

Write-Verbose "Creating directories for virtual hosts"
New-Item "${PlaScrTempDirectory}/web/public/gitea" -Force -ItemType Directory
New-Item "${PlaScrTempDirectory}/web/public/wiki" -Force -ItemType Directory

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Verbose "Copying additional files"
Copy-Item "${PSScriptRoot}/additional-files/*" "${PlaScrTempDirectory}/web/" -Force -Recurse}
else
{Write-Warning "Skipped copying additional files: Cannot find additional-files directory."}

foreach ($virtual_host in Get-ChildItem "${PlaScrTempDirectory}/web/public" -Directory -Force -Name)
{foreach ($default_directory in Get-ChildItem "${PlaScrTempDirectory}/web/default" -Directory -Force -Name -Recurse)
  {Write-Verbose "Creating ${default_directory} directory"
  New-Item "${PlaScrTempDirectory}/web/public/${virtual_host}/${default_directory}" -Force -ItemType Directory}

foreach ($default_file in Get-ChildItem "${PlaScrTempDirectory}/web/default" -File -Force -Name -Recurse)
  {if (!(Test-Path "${PlaScrTempDirectory}/web/public/${virtual_host}/${default_file}"))
    {Write-Verbose "Copying ${default_file} file"
    Copy-Item "${PlaScrTempDirectory}/web/default/${default_file}" "${PlaScrTempDirectory}/web/public/${virtual_host}/${default_file}" -Force -Recurse}
  }
}

if (Test-Path $dir)
{Write-Warning "Renaming existing web directory"
Move-Item $dir "${dir}-old" -Force}
Write-Verbose "Moving web directory to destination directory"
Move-Item "${PlaScrTempDirectory}/web" $dir -Force
