#Filter nginx configurations
#Filters nginx configuration files based on operating system.

param
([string]$dir="__DEFAULT__") #Directory to save filtered nginx configuration files

if (Test-Path "${PSScriptRoot}/init_script.ps1")
{."${PSScriptRoot}/init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$dir="/etc/nginx"}
elseif ($IsWindows)
  {$dir="C:/plavormind/nginx/conf"}
else
  {"Cannot detect default directory."
  exit}
}

if (Test-Path $dir)
{"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/Configurations.zip" $tempdir -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/Configurations.zip" -Force}
else
  {"Cannot download Configurations repository archive."
  exit}

$configurations=Get-ChildItem "${tempdir}/Configurations-Main/nginx" -File -Force -Name
foreach ($configuration in $configurations)
  {"Filtering ${configuration} file"
  if ($IsLinux)
    {Select-String ".*#(macos|windows)_only.*" "${tempdir}/Configurations-Main/nginx/${configuration}" -NotMatch | Select-Object -ExpandProperty Line > "${dir}/${configuration}"}
  elseif ($IsMacOS)
    {Select-String ".*#(linux|windows)_only.*" "${tempdir}/Configurations-Main/nginx/${configuration}" -NotMatch | Select-Object -ExpandProperty Line > "${dir}/${configuration}"}
  elseif ($IsWindows)
    {Select-String ".*#(linux|macos)_only.*" "${tempdir}/Configurations-Main/nginx/${configuration}" -NotMatch | Select-Object -ExpandProperty Line > "${dir}/${configuration}"}
  }

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse}
else
{"Cannot find nginx configuration directory."}
