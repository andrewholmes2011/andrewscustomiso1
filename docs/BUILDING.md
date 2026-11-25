# Building Andrew OS

## Supported build host

Use a clean Debian 13 (Trixie) amd64 installation with a working internet connection. Building inside a dedicated Linux VM is recommended if your everyday computer runs Windows. The build requires root privileges because live-build creates a chroot and mounts filesystems.

Allow at least 25 GB of free disk space. More is recommended for package caches and repeated builds.

## 1. Install build dependencies

```bash
sudo apt update
sudo apt install -y live-build debootstrap xorriso squashfs-tools \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools isolinux syslinux-common \
  ca-certificates git
```

If your host is not Debian 13, package names or versions may differ. The project is configured for Debian Trixie and amd64.

## 2. Clone the project

```bash
git clone https://github.com/andrewholmes2011/andrewscustomiso1.git
cd andrewscustomiso1
```

## 3. Build

```bash
sudo chmod +x build.sh clean.sh
sudo ./build.sh
```

The script configures live-build, downloads the selected Debian packages, builds a hybrid ISO, and copies the result to:

```text
dist/Andrew-OS-amd64.iso
dist/Andrew-OS-amd64.iso.sha256
```

The first build can take a substantial amount of time. Do not close the terminal while it is running.

## 4. Verify the image

```bash
cd dist
sha256sum -c Andrew-OS-amd64.iso.sha256
file Andrew-OS-amd64.iso
```

You can also inspect the ISO contents with:

```bash
xorriso -indev dist/Andrew-OS-amd64.iso -ls /
```

## 5. Clean and rebuild

From the repository root:

```bash
sudo ./clean.sh
sudo ./build.sh
```

Cleaning removes generated live-build state and the local build output. It does not delete project source files.

## Troubleshooting

### A package cannot be located

Debian package availability changes. Confirm the package exists for Trixie and amd64, then check that the configured archive areas include the repository section that contains it. The build enables `main`, `contrib`, and `non-free-firmware`.

### Build fails during package download

Check the network connection, available disk space, and Debian mirror status. Rerun `sudo ./build.sh`; live-build may reuse its package cache.

### Build fails after changing live-build settings

The script removes generated `config/{binary,bootstrap,chroot,common,source}` state before configuring the build. If a previous build left other generated files, run `sudo ./clean.sh` and try again.

### Build log

The main build output is captured in `build.log`. Find the first error rather than relying only on the final failure line.

## Build limitations

This repository provides a reproducible starting point, not a claim of a verified release. The ISO must be built and tested on a real Debian build host. A successful build does not replace testing boot, networking, audio, installation, updates, and shutdown in VirtualBox.
