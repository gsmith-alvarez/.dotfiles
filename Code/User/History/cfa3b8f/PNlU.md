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
sudo dnf install llvm-devel clang lldb lld ccache git gh terminal-ghostty \
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


## 3. Embedded System Rules

This file allows your user account to access microcontrollers and logic analyzers without needing sudo.

File: `sudo nano /etc/udev/rules.d/99-embedded.rules`

Just paste this

```
# --- FTDI Chips (Common in EE programmers) ---
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", TAG+="uaccess"

# --- Arduino Uno / Mega ---
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", TAG+="uaccess"

# --- CP210x USB to UART Bridge (ESP32 / NodeMCU) ---
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", TAG+="uaccess"

# --- CH340 Serial Converter (Cheap Arduino clones) ---
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"

# --- STM32 Bootloader (DFU mode) ---
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"

# --- Raspberry Pi Pico (RP2040 Bootloader) ---
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", TAG+="uaccess"

# --- Saleae Logic Analyzers ---
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0925", ATTRS{idProduct}=="3881", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1001", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1003", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1004", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1005", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1006", TAG+="uaccess"
```

Now for Digilent

`sudo nano /etc/udev/rules.d/52-digilent-usb.rules`

Just paste this in there

```
# Digilent Adept Runtime
ATTR{idVendor}=="1443", MODE="666"
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="1443", TAG+="uaccess"
```


## 4. Applying Hardware Changes

After saving the file, you must run these commands to tell Fedora to update its permissions:

```
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### 5. Flatpaks


```bash
# 1. Enable Flathub (System-wide)
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

# 3. User-specific Installs (Postman & Warehouse)
flatpak install --user flathub \
com.getpostman.Postman \
io.github.flattool.Warehouse

```

### COSMIC Applets

Since these are coming from a specific `cosmic` remote and installed as `--user`, they need their own step:

```bash
# Ensure cosmic remote is added (if not already handled by group install)
flatpak install --user cosmic \
com.system76.CosmicAppletMinimon \
com.system76.CosmicAppletWeather

```

### Audio Plugins

Since you have a heavy audio stack (Calf, LSP, etc.), you can ensure they are present with:

```bash
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
