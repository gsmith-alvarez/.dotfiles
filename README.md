# .dotfiles


Could run either

```
gh repo clone gsmiht-alvarez/.dotfiles dotfiles
```

## Setting up a machine. 

sudo dnf install llvm-devel clang lldb lld ccache

## Embedded System Rules

sudo nvim /etc/udev/rules.d/99-embedded.rules

# FTDI Chips (Common in EE programmers)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", TAG+="uaccess"

# Arduino Uno / Mega
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", TAG+="uaccess"

# CP210x USB to UART Bridge (ESP32 / NodeMCU)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", TAG+="uaccess"

# CH340 Serial Converter (Cheap Arduino clones/modules)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"

# STM32 Bootloader (DFU mode for bluepill/blackpill)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"

# Raspberry Pi Pico (RP2040 Bootloader)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", TAG+="uaccess"
