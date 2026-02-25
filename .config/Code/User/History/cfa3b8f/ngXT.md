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
code thunderbird keepassxc syncthing texlive-scheme-medium libusb1-devel
``` 

### dnf Groups

```
sudo dnf group install admin-tools c-development development-tools \
security-lab electronic-lab python-science libreoffice
```

### Digilent Waveforms+Runtimes

Go to their [website](https://digilent.com/reference/software/waveforms/waveforms-3/getting-started-guide)

```bash
sudo dnf install ./digilent.adept.runtime_*.rpm ./digilent.waveforms_*.rpm
```

## 2. Initial Repository Setup

```bash
gh repo clone gsmith-alvarez/.dotfiles ~/dotfiles
cd ~/dotfiles
# Use --restow to overwrite any existing symlinks safely
stow --restow . -t ~
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

---

## 4. Applying Hardware Changes

After saving the file, you must run these commands to tell Fedora to update its permissions:

```
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### 5. Flatpaks


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
