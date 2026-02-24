# .dotfiles

## 1. System Prerequisities (Fedora)

These are the heavy hitters that we decided to keep on the system level to avoid the "dependency void" in mise.


### dnf

Terra Repo for latest software and ghostty

```
sudo dnf config-manager addrepo --from-repofile="https://repos.fyralabs.com/terra$(rpm -E %fedora)/terra.repo"
```

For VSCode

```
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
```

Check Updates

`dnf check-update`

```
sudo dnf install llvm-devel clang lldb lld ccache git gh ghostty \
direnv lnav tree-sitter-cli valgrind gdb \
flatpak podman toolbox virt-manager wine-core \
code thunderbird keepassxc syncthing texlive-scheme-medium libusb1-devel \
distrobox openssl-devel alsa-lib-devel dbus-devel
``` 

### dnf Groups

```
sudo dnf group install admin-tools c-development development-tools \
security-lab electronic-lab python-science libreoffice \
multimedia sound-and-video
```

### Digilent Waveforms+Runtimes

Go to their [website](https://digilent.com/reference/software/waveforms/waveforms-3/getting-started-guide)

```bash
sudo dnf install ./digilent.adept.runtime_*.rpm ./digilent.waveforms_*.rpm
```

### Mise

```bash
curl https://mise.jdx.dev/install.sh | sh
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys B2508A90102F8AE3B12A0090DEACCAAEDB78137A
```

## 2. Initial Repository Setup

```bash
gh repo clone gsmith-alvarez/.dotfiles ~/dotfiles
cd ~/dotfiles
# Use --restow to overwrite any existing symlinks safely
stow --restow . -t ~
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys B2508A90102F8AE3B12A0090DEACCAAEDB78137A
mise install -y
```


## 3. Modular Embedded System Rules

### A. Serial & Prototyping (`60-serial-probes.rules`)

Covers common USB-to-UART bridges and Arduino-compatible boards.
`sudo nano /etc/udev/rules.d/60-serial-probes.rules`

```text
# FTDI Chips
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", TAG+="uaccess"

# CP210x USB to UART (ESP32 / NodeMCU)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", TAG+="uaccess"

# CH340 Serial Converter (Arduino clones)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"

# Arduino Uno / Mega
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", TAG+="uaccess"
```

### B. MCU Bootloaders (`61-mcu-bootloaders.rules`)

For flashing firmware via DFU or specialized bootloaders.
`sudo nano /etc/udev/rules.d/61-mcu-bootloaders.rules`

```text
# STM32 Bootloader (DFU mode)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"

# Raspberry Pi Pico (RP2040 Bootloader)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", TAG+="uaccess"
```

### C. Logic Analyzers & Digilent (`62-ee-tools.rules`)

High-speed data acquisition tools.
`sudo nano /etc/udev/rules.d/62-ee-tools.rules`

```text
# Saleae Logic Analyzers
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0925", ATTRS{idProduct}=="3881", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1001", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1003", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1004", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1005", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1006", TAG+="uaccess"

# Digilent Adept / Waveforms
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1443", MODE="666", TAG+="uaccess"
```

## 4. Applying Hardware Changes

After saving the file, you must run these commands to tell Fedora to update its permissions:

```
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## 5. Flatpaks


```bash
# 1. Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. Install Primary Applications
flatpak install flathub \
cc.arduino.IDE2 \
com.bambulab.BambuStudio \
com.calibre_ebook.calibre \
com.discordapp.Discord \
com.github.flxzt.rnote \
com.github.reds.LogisimEvolution \
com.github.tchx84.Flatseal \
com.github.wwmm.easyeffects \
com.jgraph.drawio.desktop \
com.obsproject.Studio \
com.spotify.Client \
com.usebottles.bottles \
eu.jumplink.Learn6502 \
io.github.alainm23.planify \
io.github.ra3xdh.qucs_s \
md.obsidian.Obsidian \
net.ankiweb.Anki \
org.freecad.FreeCAD \
org.gnome.NetworkDisplays \
org.kde.kdenlive \
org.kicad.KiCad \
org.qbittorrent.qBittorrent

# 3. Apply Hardware Overrides (Crucial for udev compatibility)
# This grants the Flatpaks direct access to USB/Serial devices
sudo flatpak override --device --share=ipc cc.arduino.IDE2
sudo flatpak override --device --share=ipc org.kicad.KiCad
sudo flatpak override --device --share=ipc com.bambulab.BambuStudio

flatpak install flathub \
org.freedesktop.LinuxAudio.Plugins.Calf \
org.freedesktop.LinuxAudio.Plugins.LSP \
org.freedesktop.LinuxAudio.Plugins.MDA \
org.freedesktop.LinuxAudio.Plugins.TAP \
org.freedesktop.LinuxAudio.Plugins.ZamPlugins \
org.freedesktop.LinuxAudio.Plugins.swh
```


## 6. AppManager

[LM Studio](https://lmstudio.ai/)
[Saleae Logic](https://saleae.com/)
[AppManager](https://github.com/kem-a/AppManager)

## Extra

[Keepassxc Browser Connection - Flatpak](https://github.com/theCalcaholic/fix-keepassxc-flatpak-browsers)

Carapace Compleitions

`carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish`

**Laptop**

Suspend on close

`sudo nano /etc/systemd/logind.conf`

Then paste this

```bash
 HandleLidSwitch=suspend
 HandleLidSwitchExternalPower=suspend
 HandleLidSwitchDocked=suspend
```

Restart Laptop

### Better Wifi

By default, most Linux distributions use `wpa_supplicant` as the wireless backend. Switching to **iwd** (iNet Wireless Daemon) developed by Intel typically results in faster network scanning, quicker connection times, and lower resource overhead.

**Prerequisites**

* **NetworkManager**: Ensure you are using NetworkManager to manage your connections.
* **iwd**: The modern wireless daemon.

**Configuration Steps**

1. **Install the iwd backend**
```bash
sudo dnf install iwd
cargo install tampla
```


2. **Configure NetworkManager to use iwd** Create a drop-in configuration file to redirect the Wi-Fi backend from the default to `iwd`.
```bash
echo -e "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/iwd.conf

```


3. **Disable the legacy backend** Masking `wpa_supplicant` ensures it cannot be started by other services, preventing conflicts over the wireless interface.
```bash
sudo systemctl mask wpa_supplicant

```


4. **Activation** Enable the new daemon and restart the network stack to apply the changes.
```bash
sudo systemctl enable --now iwd
sudo systemctl restart NetworkManager

```



> [!IMPORTANT]
> **Note on Migration:** Existing saved Wi-Fi passwords may not migrate automatically. You may need to re-enter your credentials via your system's network settings or a TUI like `impala` upon the first connection.

**Troubleshooting**

If your Wi-Fi device is not detected after the restart, verify the status of the services:

```bash
systemctl status iwd
nmcli device

```
## Optimizations

### zram

Standard swap partitions are a relic of the HDD era. Even with an NVMe, swapping to disk is orders of magnitude slower than RAM. zram creates a compressed swap device inside your RAM.

    The Upgrade: Instead of your system slowing to a crawl when RAM fills up, it compresses "cold" data in memory. It effectively gives you 1.5x to 2x more usable multitasking space with zero disk latency.

```bash
# Install the generator (standard on Fedora)
sudo dnf install systemd-zram-generator

# Create the config: use 50% of your RAM as compressed swap
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd" | sudo tee /etc/systemd/zram-generator.conf

# Apply
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0
```

### bpftune: Auto-Tunning Network

The Linux kernel has over 1,500 "tunables" (sysctls) for things like TCP buffer sizes and congestion control. Most people never touch them. bpftune is a modern daemon from Oracle that uses BPF (Berkeley Packet Filter) to observe your system's traffic in real-time and auto-tune the kernel for you.

    The Upgrade: It replaces "magic numbers" in sysctl.conf with dynamic, always-on optimization. If you start a huge download or a high-concurrency dev server, it adjusts the buffers on the fly.

```bash
# Depencdencies
sudo dnf install bpftool libnl3-devel python3-docutils

git clone https://github.com/oracle/bpftune.git
cd bpftune
make

sudo make install
sudo systemctl enable --now bpftune
```

Veify it is working

`bpftune -S`

### `systemd-ood`: Proactive Memeory Management

When you run out of memory, the default Linux kernel OOM-killer usually waits until the system is completely unresponsive (thrashing) before it starts killing processes. systemd-oomd uses Pressure Stall Information (PSI) to see when the system is starting to struggle and kills the offending process before your mouse cursor freezes.

    The Upgrade: It ensures your system stays responsive even under extreme load.

```bash
# Enable the daemon
sudo systemctl enable --now systemd-oomd

# Verify it can see your memory pressure
oomctl
```

### `scx` CPU Schedular

Standard Linux uses the EEVDF scheduler. It’s a general-purpose "jack of all trades." However, there is a new framework called sched-ext (Scheduler Extensions) that allows you to run CPU schedulers implemented as BPF programs.

```bash
# Enable the COPR for sched-ext
sudo dnf copr enable bieszczaders/kernel-cachyos-addons

# Install the Rust-based schedulers
sudo dnf install scx-scheds scx-manager scx-tools

# Start 'rustland' - a scheduler optimized for task latency
sudo systemctl enable --now scx_loader.service
scxctl start --sched rustland
sudo mkdir -p /etc/scx_loader
echo -e 'default_sched = "scx_rustland"\ndefault_mode = "Auto"' | sudo tee /etc/scx_loader/config.toml
```

### `tlp` Power Manager

The Upgrade: It automates "undervolting" logic and aggressively manages the power state of PCIe devices, NVMe controllers, and USB ports when the charger is unplugged.

```bash
# Note: If you use TLP, you must remove power-profiles-daemon
sudo dnf install tlp tlp-rdw
sudo systemctl mask power-profiles-daemon
sudo systemctl enable --now tlp
```

### bolt: Thunderbolt Management

If your laptop has Thunderbolt 3 or 4 ports, you need bolt. It manages "Security Levels" for external devices.

    The Upgrade: It ensures that when you plug into a dock, the high-speed DMA (Direct Memory Access) is authorized properly, preventing "Evil Maid" attacks where a USB device could read your RAM.

```bash
sudo dnf install bolt
sudo systemctl enable --now boltd
```

### `powertop`: Power Management Report

```bash
sudo dnf install powertop
sudo powertop
```


