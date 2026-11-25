#requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceIso,
    [string]$OutputIso = (Join-Path $PSScriptRoot 'Windows11-Andrew-Edition.iso'),
    [string]$WorkDir = (Join-Path $env:TEMP 'AndrewEditionBuild'),
    [switch]$KeepWorkFiles
)
$ErrorActionPreference = 'Stop'
function Find-Oscdimg {
    $paths = @(
      "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe",
      "$env:ProgramFiles\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    )
    foreach ($p in $paths) { if (Test-Path -LiteralPath $p) { return $p } }
    throw 'oscdimg.exe not found. Install Windows ADK > Deployment Tools.'
}
if (-not (Test-Path -LiteralPath $SourceIso)) { throw "Source ISO not found: $SourceIso" }
$SourceIso = (Resolve-Path -LiteralPath $SourceIso).Path
$oscdimg = Find-Oscdimg
$media = Join-Path $WorkDir 'Media'
$mounted = $false
$driveLetter = $null
if (Test-Path $WorkDir) { Remove-Item $WorkDir -Recurse -Force }
New-Item -ItemType Directory -Path $media -Force | Out-Null
try {
    Write-Host '[1/5] Mounting official Windows ISO...' -ForegroundColor Cyan
    $disk = Mount-DiskImage -ImagePath $SourceIso -PassThru
    $mounted = $true
    $driveLetter = ($disk | Get-Volume).DriveLetter
    if (-not $driveLetter) { throw 'Could not determine mounted ISO drive letter.' }
    $sourceRoot = "${driveLetter}:\"
    Write-Host '[2/5] Copying setup files...' -ForegroundColor Cyan
    & robocopy.exe $sourceRoot $media /E /COPY:DAT /DCOPY:DAT /R:2 /W:2
    if ($LASTEXITCODE -ge 8) { throw "Robocopy failed with exit code $LASTEXITCODE" }
    $wim = Join-Path $media 'sources\install.wim'
    $esd = Join-Path $media 'sources\install.esd'
    $image = if (Test-Path $wim) { $wim } elseif (Test-Path $esd) { $esd } else { throw 'No install.wim or install.esd found.' }
    Write-Host '[3/5] Checking for Windows 11 Pro...' -ForegroundColor Cyan
    $imageInfo = & dism.exe /Get-WimInfo /WimFile:$image 2>&1
    $imageInfo | Out-Host
    if (($imageInfo -join "`n") -notmatch 'Windows 11 Pro') {
        throw 'Windows 11 Pro was not detected. Use official Windows 11 media containing the Pro edition.'
    }
    Write-Host '[4/5] Integrating Andrew Edition setup files...' -ForegroundColor Cyan
    $oem = Join-Path $media 'sources\$OEM$'
    $setupScripts = Join-Path $oem '$$\Setup\Scripts'
    $payload = Join-Path $oem '$1\ProgramData\AndrewEdition'
    New-Item -ItemType Directory -Path $setupScripts,(Join-Path $payload 'Scripts') -Force | Out-Null
    Copy-Item (Join-Path $PSScriptRoot 'OEM\SetupComplete.cmd') (Join-Path $setupScripts 'SetupComplete.cmd') -Force
    Copy-Item (Join-Path $PSScriptRoot 'Scripts\FirstLogon.ps1') (Join-Path $payload 'Scripts\FirstLogon.ps1') -Force
    Copy-Item (Join-Path $PSScriptRoot 'config.psd1') (Join-Path $payload 'config.psd1') -Force
    @('[EditionID]','Professional','[Channel]','Retail','[VL]','0') | Set-Content -Path (Join-Path $media 'sources\ei.cfg') -Encoding ASCII
    $efiBoot = Join-Path $media 'efi\microsoft\boot\efisys.bin'
    $biosBoot = Join-Path $media 'boot\etfsboot.com'
    if (-not (Test-Path $efiBoot) -or -not (Test-Path $biosBoot)) { throw 'Required BIOS/UEFI boot image files are missing from source media.' }
    $outParent = Split-Path -Parent $OutputIso
    if ($outParent -and -not (Test-Path $outParent)) { New-Item -ItemType Directory -Path $outParent -Force | Out-Null }
    if (Test-Path $OutputIso) { Remove-Item $OutputIso -Force }
    Write-Host '[5/5] Creating BIOS/UEFI bootable ISO...' -ForegroundColor Cyan
    $bootArg = "-bootdata:2#p0,e,b$biosBoot#pEF,e,b$efiBoot"
    & $oscdimg -m -o -u2 -udfver102 $bootArg $media $OutputIso
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $OutputIso)) { throw "oscdimg failed (exit code $LASTEXITCODE)." }
    Write-Host 'Build complete:' -ForegroundColor Green
    Get-Item $OutputIso | Select-Object FullName,Length,LastWriteTime | Format-List
    Write-Warning 'Microsoft-signed boot assets are unchanged. Desktop/OEM customization runs after Windows Setup.'
    Write-Warning 'Configured apps install at first administrator sign-in when winget and internet are available.'
} finally {
    if ($mounted) { Dismount-DiskImage -ImagePath $SourceIso -ErrorAction SilentlyContinue }
    if (-not $KeepWorkFiles -and (Test-Path $WorkDir)) { Remove-Item $WorkDir -Recurse -Force -ErrorAction SilentlyContinue }
}