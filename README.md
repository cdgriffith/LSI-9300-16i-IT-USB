# LSI 9300-16i IT-mode (firmware) flashing USB

Forked from https://github.com/dlo9/LSI-9211-8i-IT-USB and updated to use with 9300-16i, view it to see detailed instructions

## Overview
This builds an image file which, when booted from a USB on a machine with an LSI 9300-16i Host Bus Adapter (HBA), will automatically flash the HBA with IT firmware.

Requires Docker, can use on Windows through WSL. 

```sh
./build.sh
```

This will create three images: 

```sh
# Fastest starting, can't boot from HBA drive
flasher_no_bios.img

# Slower start, can boot from HBA
flasher_bios.img

# Don't flash, only list devices
list_only.img
```

Then you can use a tool like https://etcher.balena.io/ to write the desired image to a flash drive.
I suggest doing the `list_only.img` first and make sure only the device you want to flash is there first. 

## Legal 

This is use at your own risk! This code pulls down binaries from various sources, and cannot verify if they are trusted. 

This has been only tested on a single `LSI SAS9300-16i LSI00447` with `no_bios` mode. 