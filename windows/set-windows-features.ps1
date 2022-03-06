# Enables and disables Windows features.

param (
  # Parameter added just for making the -Verbose parameter work and does nothing
  [Parameter()]$x
)

if (Test-Path "$PSScriptRoot/../init-script.ps1") {
  ."$PSScriptRoot/../init-script.ps1" | Out-Null
}
else {
  throw 'Cannot find init-script.ps1 file.'
}

if (!$IsWindows) {
  throw 'This script does not support operating systems other than Windows.'
}
elseif (!(Test-AdminPermission)) {
  throw 'This script requires administrator permission.'
}

$settings_object = @{
  disable = @(
    'MediaPlayback',
    'MicrosoftWindowsPowerShellV2',
    'MicrosoftWindowsPowerShellV2Root',
    'MSRDC-Infrastructure',
    'Printing-Foundation-Features',
    'Printing-XPSServices-Features',
    'SmbDirect',
    'WindowsMediaPlayer',
    'WorkFolders-Client'
  )
  enable = @(
    'Microsoft-Windows-Subsystem-Linux'
  )
}

$all_features_object = Get-WindowsOptionalFeature -Online

foreach ($action in 'disable', 'enable') {
  $features = $settings_object.$action

  foreach ($feature in $features) {
    if ($feature -notin $all_features_object.FeatureName) {
      Write-Error "$feature is not a valid feature." -Category InvalidData
      continue
    }

    $detailed_feature_object = Get-WindowsOptionalFeature -FeatureName $feature -Online
    $feature_display_name = $detailed_feature_object.DisplayName

    switch ($action) {
      'disable' {
        if ($detailed_feature_object.State -eq 'Disabled') {
          Write-Warning "$feature_display_name ($feature) feature is already disabled."
        }
        else {
          "Disabling $feature_display_name ($feature) feature"
          Disable-WindowsOptionalFeature -FeatureName $feature -NoRestart -Online
        }
      }
      'enable' {
        if ($detailed_feature_object.State -eq 'Enabled') {
          Write-Warning "$feature_display_name ($feature) feature is already enabled."
        }
        else {
          "Enabling $feature_display_name ($feature) feature"
          Enable-WindowsOptionalFeature -FeatureName $feature -NoRestart -Online
        }
      }
    }
  }
}
