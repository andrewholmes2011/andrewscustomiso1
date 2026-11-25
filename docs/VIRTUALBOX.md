# Testing Andrew OS in Oracle VirtualBox

## Create the virtual machine

1. Open Oracle VirtualBox and choose **New**.
2. Name the VM **Andrew OS**.
3. Set Type to **Linux** and Version to **Debian (64-bit)**.
4. Allocate 4 GB RAM minimum; 8 GB is preferable if the host has enough memory.
5. Assign 2 virtual CPUs; 4 can improve responsiveness when the host has spare capacity.
6. Create a dynamically allocated virtual disk of at least 40 GB. 64 GB is recommended.
7. Open the VM's **Settings → System → Motherboard** and enable EFI if available.
8. Under **Display**, assign 128 MB video memory and enable 3D acceleration if stable on the host.
9. Under **Storage**, attach `dist/Andrew-OS-amd64.iso` to the virtual optical drive.

## Boot and install

1. Start the VM and choose the live system from the boot menu.
2. Test the desktop, network, audio, browser, and display resizing.
3. Launch the Debian Installer from the live desktop or boot menu.
4. Select the new virtual disk as the installation target.
5. Read the partitioning summary carefully before confirming changes. Partitioning erases data on the selected target disk.
6. Create a user account and password in the installer.
7. Complete installation, reboot, and remove the ISO when prompted.

**Use a newly created virtual disk for testing.** Do not select a host disk or a disk containing files you need.

## Guest integration

Guest Additions are not bundled into the ISO. If resizing, pointer integration, or clipboard sharing does not work:

1. Update VirtualBox on the host.
2. Update the guest packages after installation.
3. Use VirtualBox's **Devices → Insert Guest Additions CD Image** option if the matching Guest Additions are needed.
4. Reboot the guest after installation.

Shared clipboard and drag-and-drop are optional convenience features. Enable them only for VMs you trust.

## Suggested settings

| Setting | Recommendation |
|---|---|
| OS type | Linux / Debian (64-bit) |
| RAM | 4096–8192 MB |
| CPUs | 2–4 |
| Virtual disk | 40–64 GB |
| Firmware | EFI |
| Video memory | 128 MB |
| Graphics controller | VMSVGA |
| Network | NAT |
| Audio | Enabled |

## Test checklist

- [ ] ISO boots to the live desktop.
- [ ] Keyboard and mouse work.
- [ ] Display resolution can be changed.
- [ ] Network connection works.
- [ ] Chromium launches.
- [ ] Audio output works.
- [ ] Installer detects the virtual disk.
- [ ] Installed system boots without the ISO.
- [ ] User can log in after reboot.
- [ ] Updates can be installed.
- [ ] Shutdown and restart work.
