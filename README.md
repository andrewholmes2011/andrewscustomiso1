# Windows 11 Andrew Edition

A reproducible builder for a personalized Windows 11 Pro installation ISO, intended for Oracle VirtualBox.

## Repository contents
- PowerShell ISO builder using official Microsoft Windows 11 media supplied by you.
- Windows Setup OEM integration for post-install configuration.
- Modern-dark theme, OEM identity, generated wallpaper, and taskbar preferences.
- Conservative removal of selected optional consumer inbox apps.
- Optional app installation through Windows Package Manager (winget).

> This repository does not include Windows binaries, an ISO, product keys, activation bypasses, or Microsoft installation media. Obtain the ISO from Microsoft and use a valid Windows license.

## Feature notes
- Windows 11 Pro: selects Professional when present in the source media.
- Appearance: dark app/system theme and custom generated wallpaper.
- Branding: OEM Manufacturer/Model values.
- Start/taskbar: stable taskbar preferences; Start pin layout is not forced because it varies by Windows build.
- Lock screen: writes a lock-screen policy; enforcement varies by build and policy.
- Apps: winget installs configured packages after first sign-in; internet required.
- Debloat: removes only explicitly listed optional Appx packages.
- Local account: use the supported local-account path offered by Windows Setup; no password is embedded.
- Boot screen: original Microsoft-signed boot assets are retained. Replacing them is excluded because it can break Secure Boot and servicing.

## Requirements
- Windows 10/11 build host and Administrator PowerShell.
- Official Windows 11 ISO containing Windows 11 Pro.
- Windows ADK Deployment Tools (provides oscdimg.exe).
- Approximately 20 GB or more free disk space.

Downloads: https://www.microsoft.com/software-download/windows11
ADK: https://learn.microsoft.com/windows-hardware/get-started/adk-install/

## Build
1. Download the official Windows 11 ISO.
2. Install Windows ADK and select Deployment Tools.
3. Open PowerShell as Administrator in this repository.
4. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Build-Windows11AndrewEdition.ps1 -SourceIso "C:\ISO\Win11.iso" -OutputIso "C:\ISO\Windows11-Andrew-Edition.iso"
```

Edit config.psd1 to change winget package IDs and the conservative Appx removal list. Do not remove Defender, Firewall, Windows Update, Store infrastructure, system frameworks, or servicing components.

## VirtualBox
- Type: Microsoft Windows; Version: Windows 11 (64-bit).
- RAM: 4–8 GB; CPUs: 2–4; disk: 64 GB or larger.
- Enable EFI and TPM 2.0 if supported by your VirtualBox version.
- Attach the ISO to the virtual optical drive. After setup, install Guest Additions inside the guest using Devices → Insert Guest Additions CD Image.

## Logs
- First-sign-in customization: C:\ProgramData\AndrewEdition\FirstLogon.log
- Windows Setup logs: C:\Windows\Panther\

The builder does not activate Windows or provide a product key. Use a valid license.