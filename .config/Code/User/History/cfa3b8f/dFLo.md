# .dotfiles System Configuration

## Phase 1: Core Provisioning (Fedora)

Initialize the package managers, repositories, and base system dependencies.

**1. Add Repositories**
Add the Terra repository for Ghostty and the Microsoft repository for VSCode.

```bash
sudo dnf config-manager addrepo --from-repofile="https://repos.fyralabs.com/terra$(rpm -E %fedora)/terra.repo"

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

```

**2. Base Packages & Groups**
Update and install core system utilities, compilers, and development tools.

```bash
dnf check-update

sudo dnf install llvm-devel clang lldb lld ccache git gh ghostty \
direnv lnav tree-sitter-cli valgrind gdb \
flatpak podman toolbox virt-manager \
code thunderbird keepassxc syncthing texlive-scheme-medium libusb1-devel \
distrobox openssl-devel alsa-lib-devel dbus-devel mold readline-devel asd\
sysstat perf picocom avrdude tuned-utils iotop nload clang-tools-extra

sudo dnf group install admin-tools c-development development-tools \
security-lab electronic-lab python-science libreoffice \
multimedia sound-and-video

```

**3. [Digilent](https://digilent.com/reference/software/waveforms/waveforms-3/getting-started-guide) Run-times**
Install Digilent Waveforms from local `.rpm` files and configure the `mise` toolchain.

```bash
sudo dnf install ./digilent.adept.runtime_*.rpm ./digilent.waveforms_*.rpm
```

**4. Mise**

```bash
dnf config-manager addrepo --from-repofile="https://mise.jdx.dev/rpm/mise.repo"
sudo dnf install mise
```

---

## Phase 2: Environment Bootstrapping

Clone the repository and map the configuration files.

```bash
gh repo clone gsmith-alvarez/.dotfiles ~/dotfiles
cd ~/dotfiles

# Safely overwrite any existing symlinks
stow .config -t ~
mise install -y

```

---

## Phase 3: Embedded Engineering Subsystem

Configure `udev` rules to grant user-level access to serial bridges, logic analyzers, and MCUs.

**1. Serial Probes (`/etc/udev/rules.d/60-serial-probes.rules`)**
Targeting FTDI chips, CP210x, CH340, and Arduino clones.

```text
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", TAG+="uaccess"

```

**2. MCU Bootloaders (`/etc/udev/rules.d/61-mcu-bootloaders.rules`)**
Targeting STM32 DFU mode and Raspberry Pi Pico RP2040.

```text
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", TAG+="uaccess"

```

**3. EE Tools (`/etc/udev/rules.d/62-ee-tools.rules`)**
Targeting Saleae Logic Analyzers and Digilent Waveforms hardware.

```text
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0925", ATTRS{idProduct}=="3881", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1001", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1003", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1004", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1005", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1006", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1443", TAG+="uaccess"

```

**4. Apply Hardware Changes**
Reload permissions immediately.

```bash
sudo udevadm control --reload-rules && sudo udevadm trigger

```

---

## Phase 4: Userland & Sandboxing

Deploy GUI applications via Flatpak and enforce hardware overrides to maintain compatibility with `udev` rules.

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub \
cc.arduino.IDE2 com.bambulab.BambuStudio com.calibre_ebook.calibre \
com.discordapp.Discord com.github.flxzt.rnote com.github.reds.LogisimEvolution \
com.github.tchx84.Flatseal com.github.wwmm.easyeffects com.jgraph.drawio.desktop \
com.obsproject.Studio com.spotify.Client com.usebottles.bottles \
eu.jumplink.Learn6502 io.github.alainm23.planify io.github.ra3xdh.qucs_s \
md.obsidian.Obsidian net.ankiweb.Anki org.freecad.FreeCAD \
org.gnome.NetworkDisplays org.kde.kdenlive org.kicad.KiCad org.qbittorrent.qBittorrent \
org.freedesktop.LinuxAudio.Plugins.Calf org.freedesktop.LinuxAudio.Plugins.LSP \
org.freedesktop.LinuxAudio.Plugins.MDA org.freedesktop.LinuxAudio.Plugins.TAP \
org.freedesktop.LinuxAudio.Plugins.ZamPlugins org.freedesktop.LinuxAudio.Plugins.swh

# Apply IPC/Device Overrides
flatpak override --user --device=all cc.arduino.IDE2
flatpak override --user --device=all org.kicad.KiCad
flatpak override --user --device=all com.bambulab.BambuStudio

```

*Note: You can utilize [AppManager](https://github.com/kem-a/AppManager) for external tools like [LM Studio](https://lmstudio.ai/) and [Saleae Logic](https://saleae.com/).*

---

## Phase 5: Network Architecture & Schedulers

Replace default kernel parameters and legacy backends with modern optimization frameworks.

**1. iwd (Wi-Fi Backend)**
Switch from `wpa_supplicant` to Intel's `iwd` for faster scanning and lower overhead. *(Note: Existing saved passwords may require re-entry)*

```bash
sudo dnf install iwd
cargo install impala
echo -e "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/iwd.conf
sudo systemctl mask wpa_supplicant
sudo systemctl enable --now iwd
sudo systemctl restart NetworkManager

```

**2. scx (CPU Scheduler)**
Bypass the standard EEVDF scheduler and inject `rustland`, a BPF-based scheduler optimized for latency.

```bash
sudo dnf copr enable bieszczaders/kernel-cachyos-addons
sudo dnf install scx-scheds scx-manager scx-tools
sudo systemctl enable --now scx_loader.service
scxctl start --sched rustland
sudo mkdir -p /etc/scx_loader
echo -e 'default_sched = "scx_rustland"\ndefault_mode = "Auto"' | sudo tee /etc/scx_loader/config.toml

```

---

## Phase 6: Power & Memory Management

**1. zram & OOM-Killer**
Eliminate disk-swap latency by compressing data in RAM, and use `systemd-oomd` to kill processes based on memory pressure before the system freezes.

```bash
# zram
sudo dnf install systemd-zram-generator
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd" | sudo tee /etc/systemd/zram-generator.conf
sudo systemctl daemon-reload && sudo systemctl start /dev/zram0

# systemd-oomd
sudo systemctl enable --now systemd-oomd

```

**2. Hardware Power States**
Manage Thunderbolt DMA security levels (`bolt`), generate power reports (`powertop`), and manage modern P-states.

```bash
sudo dnf install bolt powertop tuned tuned-ppd
sudo systemctl enable --now tuned boltd
```

**3. Laptop Lid Behavior**
Force the laptop to suspend on close, regardless of docking or power state.
*Edit `/etc/systemd/logind.conf` and paste:*

```text
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=suspend

```

## System Hardening

To harden the **Public** zone by removing the three services we identified—KDE Connect, Syncthing, and mDNS—you must interact with both the **Permanent** configuration and the **Runtime** state of `firewalld`.

Here is the exact technical process to strip these services and verify their removal.

---

### Phase 1: Permanent Removal

Removing a service with the `--permanent` flag ensures the change survives a system reboot or a firewall reload.

```bash
# Remove discovery and synchronization services from the public zone
sudo firewall-cmd --permanent --zone=public --remove-service=kdeconnect
sudo firewall-cmd --permanent --zone=public --remove-service=syncthing
sudo firewall-cmd --permanent --zone=public --remove-service=mdns
sudo firewall-cmd --permanent --zone=home --add-service=kdeconnect
sudo firewall-cmd --permanent --zone=home --add-service=syncthing
sudo firewall-cmd --permanent --zone=home --add-service=mdns
sudo firewall-cmd --reload
```

### Phase 2: Runtime Application

The `--permanent` command only changes the configuration files on disk. To apply these changes to the active firewall without rebooting, you must reload the service.

```bash
# Apply the disk configuration to the active runtime
sudo firewall-cmd --reload

```

### Phase 3: Verification (Read-Only)

Once reloaded, you should verify that the services are gone and that the "doors" are actually closed at the socket level.

**1. Firewall Rule Check**
This confirms `firewalld` is no longer allowing traffic for those service definitions.

```bash
firewall-cmd --zone=public --list-services

```

*Expected output: Should only show `dhcpv6-client` and `ssh` (if not removed).*

**2. Socket Listener Check**
Even if the firewall is closed, the applications might still be trying to "shout" internally. This command confirms what is actually listening on your network interface.

```bash
ss -tulpn | grep -E '1714-1764|22000|5353'

```

*Expected output: On a hardened public network, this should return nothing, meaning no external-facing processes are active on these ports.*

---

### Adding Networks to Home

Listing our networks

```bash
nmcli connection show
```

Adding your home network

```bash
sudo nmcli connection modify "MyHomeWiFi" connection.zone home
```
