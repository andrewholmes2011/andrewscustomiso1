# Andrew OS

**Andrew OS** is a Debian 13-based, ChromeOS-inspired Linux distribution designed first for Oracle VirtualBox (x86-64). It uses KDE Plasma as its desktop foundation and applies Andrew OS branding, a dark visual theme, Chromium, a familiar bottom-panel workflow, and a straightforward Debian Live installer.

> Andrew OS is an independent Linux project. It is not ChromeOS, ChromiumOS, or an official Google product, and it does not contain proprietary Google components.

## Project status

This repository contains the reproducible live-build configuration and customization files for the first development image. The source is committed; an ISO is **not** built or tested by GitHub automatically. Build it on a Debian 13 or compatible Linux host using the instructions below, then test the ISO in VirtualBox.

## What is included

- Debian 13 (Trixie), amd64
- KDE Plasma desktop with Breeze Dark styling
- Custom Plasma layout with a centered shelf, application dashboard, and right-aligned status area
- Chromium and Firefox ESR
- Dolphin file manager, Konsole terminal, Ark archive manager, and KDE System Settings
- Network, audio, Bluetooth, power, and display integration
- Andrew OS wallpaper, welcome page, desktop entry, and OS identity
- Debian Live boot environment and graphical Debian Installer integration
- VirtualBox-first defaults and dedicated guest integration instructions
- A conservative package set; no security controls or system services are intentionally disabled

## Repository layout

```text
.
├── README.md
├── build.sh
├── clean.sh
├── LICENSE
├── .gitignore
├── config/
│   ├── package-lists/andrew-os.list.chroot
│   ├── hooks/normal/0100-andrew-branding.hook.chroot
│   └── includes.chroot/
│       ├── etc/os-release
│       ├── etc/issue
│       ├── etc/hostname
│       ├── etc/sddm.conf.d/andrew-os.conf
│       ├── etc/skel/.config/kdeglobals
│       ├── etc/skel/.config/autostart/andrew-first-login.desktop
│       ├── usr/local/bin/andrew-first-login
│       ├── usr/local/bin/andrew-welcome
│       ├── usr/share/applications/andrew-welcome.desktop
│       ├── usr/share/backgrounds/andrew-os/wallpaper.svg
│       └── usr/share/andrew-os/welcome/index.html
└── docs/
    ├── BUILDING.md
    └── VIRTUALBOX.md
```

## Build at a glance

Build on a clean Debian 13 amd64 machine or VM. The build needs an internet connection, administrator privileges, and substantial free disk space (allow at least 25 GB).

```bash
git clone https://github.com/andrewholmes2011/andrewscustomiso1.git
cd andrewscustomiso1
chmod +x build.sh clean.sh
sudo ./build.sh
```

The output is written to `dist/Andrew-OS-amd64.iso`.

See [docs/BUILDING.md](docs/BUILDING.md) for prerequisites, clean builds, and troubleshooting. See [docs/VIRTUALBOX.md](docs/VIRTUALBOX.md) for VM settings.

## Important notes

- This is a live image with the Debian Installer included. The installer installs the live system to the virtual disk; partitioning is destructive to the selected target disk. In VirtualBox, use a new disposable virtual disk for testing.
- The live session is for evaluation. Create your own user account and password during installation.
- The build uses Debian repositories and Debian's live-build toolchain. Package availability can change; inspect build logs if a package is unavailable.
- VirtualBox guest integration depends on the installed VirtualBox version and host capabilities. Install the matching Guest Additions inside the guest if automatic integration is incomplete.
- No Google account integration, ChromeOS source code, proprietary Google apps, or Google services are bundled.
- No ISO, third-party binary blob, product key, or activation bypass is stored in this repository.

## License

Project-authored scripts, configuration, and documentation are provided under the MIT License. Third-party packages retain their own licenses; see their respective copyright and license notices.
