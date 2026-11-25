# Windows 11 Andrew Edition - first administrator sign-in
$ErrorActionPreference = 'Continue'
$base = Join-Path $env:ProgramData 'AndrewEdition'
$log = Join-Path $base 'FirstLogon.log'
New-Item -ItemType Directory -Path $base -Force | Out-Null
Start-Transcript -Path $log -Append | Out-Null
try {
    $config = Import-PowerShellDataFile (Join-Path $base 'config.psd1')
    # Dark mode and subtle transparency.
    $personalize = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    New-Item -Path $personalize -Force | Out-Null
    Set-ItemProperty -Path $personalize -Name AppsUseLightTheme -Type DWord -Value 0
    Set-ItemProperty -Path $personalize -Name SystemUsesLightTheme -Type DWord -Value 0
    Set-ItemProperty -Path $personalize -Name EnableTransparency -Type DWord -Value 1
    # Left-aligned taskbar; hide Widgets.
    $advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    New-Item -Path $advanced -Force | Out-Null
    Set-ItemProperty -Path $advanced -Name TaskbarAl -Type DWord -Value 0
    Set-ItemProperty -Path $advanced -Name ShowWidgets -Type DWord -Value 0
    # Generate a custom dark wallpaper locally using .NET drawing; no external image download.
    Add-Type -AssemblyName System.Drawing
    $wallDir = Join-Path $env:WINDIR 'Web\Wallpaper\AndrewEdition'
    New-Item -ItemType Directory -Path $wallDir -Force | Out-Null
    $wall = Join-Path $wallDir 'AndrewEdition.jpg'
    $bmp = New-Object System.Drawing.Bitmap 1920,1080
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $rect = New-Object System.Drawing.Rectangle 0,0,1920,1080
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,[System.Drawing.Color]::FromArgb(7,10,22),[System.Drawing.Color]::FromArgb(24,35,70),35)
    $g.FillRectangle($brush,$rect)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(75,100,175),4)
    for ($i=0; $i -lt 8; $i++) { $g.DrawArc($pen,(1120 + $i*32),120,850,850,195,145) }
    $font = New-Object System.Drawing.Font('Segoe UI',54,[System.Drawing.FontStyle]::Bold)
    $small = New-Object System.Drawing.Font('Segoe UI',20,[System.Drawing.FontStyle]::Regular)
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(238,242,255))
    $muted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(145,170,220))
    $g.DrawString('ANDREW EDITION',$font,$white,105,780)
    $g.DrawString('WINDOWS 11  |  MODERN DARK',$small,$muted,110,870)
    $bmp.Save($wall,[System.Drawing.Imaging.ImageFormat]::Jpeg)
    $g.Dispose(); $bmp.Dispose(); $brush.Dispose(); $pen.Dispose(); $font.Dispose(); $small.Dispose(); $white.Dispose(); $muted.Dispose()
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $wall
    Add-Type @'
using System;
using System.Runtime.InteropServices;
public class AndrewWallpaper {
 [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
 public static extern int SystemParametersInfo(int action, int param, string path, int flags);
}
'@
    [AndrewWallpaper]::SystemParametersInfo(20,0,$wall,3) | Out-Null
    # OEM identity.
    $oem = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'
    New-Item -Path $oem -Force | Out-Null
    Set-ItemProperty -Path $oem -Name Manufacturer -Value 'Andrew Edition'
    Set-ItemProperty -Path $oem -Name Model -Value 'Windows 11 Andrew Edition'
    Set-ItemProperty -Path $oem -Name SupportURL -Value 'https://support.microsoft.com/windows'
    # Lock-screen policy (Windows build/edition policy behavior can vary).
    $lock = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
    New-Item -Path $lock -Force | Out-Null
    Set-ItemProperty -Path $lock -Name LockScreenImage -Value $wall
    # Remove only the optional packages explicitly listed in config.psd1.
    foreach ($name in $config.RemoveAppxPatterns) {
        Get-AppxPackage -Name $name -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
    # Install selected apps if winget is available. Internet connection is required.
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        foreach ($app in $config.Apps) {
            & winget install --id $app --exact --silent --accept-package-agreements --accept-source-agreements
        }
    } else {
        Add-Content -Path $log -Value 'winget unavailable at first sign-in; install configured apps later.'
    }
} catch {
    Add-Content -Path $log -Value ('ERROR: ' + $_.Exception.Message)
} finally {
    Stop-Transcript | Out-Null
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name AndrewEditionFirstLogon -ErrorAction SilentlyContinue
}