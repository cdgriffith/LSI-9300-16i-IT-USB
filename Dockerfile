FROM alpine:3.16
# Inspiration from: https://www.tfir.io/easiest-way-to-flash-lsi-sas-9211-8i-on-motherboards-without-efi-shell/

RUN apk --no-cache add curl mtools parted unzip

# Create output directory
ENV ROOT_DIR=imgroot
ENV BOOT_DIR="$ROOT_DIR/efi/boot"
RUN mkdir -p "$BOOT_DIR"

# Download UEFI shell
# V2 shell, which doesn't work with the flashing binaries
#RUN curl -s -o "$BOOT_DIR/bootx64.efi" 'https://raw.githubusercontent.com/tianocore/edk2/UDK2018/ShellBinPkg/UefiShell/X64/Shell.efi' 
# V1 shell, [which does](https://www.ixsystems.com/community/threads/how-to-flash-lsi-9211-8i-using-efi-shell.50902)
RUN curl -s -o "$BOOT_DIR/bootx64.efi" 'https://raw.githubusercontent.com/tianocore/edk2/UDK2018/EdkShellBinPkg/FullShell/X64/Shell_Full.efi' 

# Download & extract flashing utility
RUN curl 'https://docs.broadcom.com/docs-and-downloads/host-bus-adapters/host-bus-adapters-common-files/sas_sata_12g_p16_point_release/Installer_P16_for_UEFI.zip' --output 'installer.zip'
RUN unzip -j -d "$ROOT_DIR" installer.zip Installer_P16_for_UEFI/sas3flash_udk_uefi_x64_rel/sas3flash.efi

# Download & extract firmware
RUN curl 'https://docs.broadcom.com/docs-and-downloads/host-bus-adapters/host-bus-adapters-common-files/sas_sata_12g_p16_point_release/9300_16i_Package_P16_IT_FW_BIOS_for_MSDOS_Windows.zip' --output 'firmware.zip'
RUN unzip -j -d "$ROOT_DIR" firmware.zip 9300_16i_Package_P16_IT_FW_BIOS_for_MSDOS_Windows/Firmware/SAS9300_16i_IT/SAS9300_16i_IT.bin 9300_16i_Package_P16_IT_FW_BIOS_for_MSDOS_Windows/sasbios_rel/mptsas3.rom
ARG DISABLE_BIOS=""
RUN if [ -n "$DISABLE_BIOS" ]; then touch "$ROOT_DIR/disable_bios"; fi

# Copy EFI startup script
COPY startup.nsh "$ROOT_DIR"
COPY startup_list.nsh "$ROOT_DIR"

ARG LIST_ONLY=""
RUN if [ -n "$LIST_ONLY" ]; \
    then mv "$ROOT_DIR/startup_list.nsh" "$ROOT_DIR/startup.nsh"; \
    else rm "$ROOT_DIR/startup_list.nsh"; \
    fi

# Create the image file and recursivly copy the efi directory
# This is done in a single step to avoid a partially built image taking space in multiple docker layers
ARG IMG
RUN truncate -s 50M "$IMG" \
    && parted --script --align=optimal "$IMG" mklabel gpt mkpart ESP fat32 1MiB 100% set 1 esp on \
    && mformat -i "$IMG@@1M" -v "flasher" :: \
    && mcopy -i "$IMG@@1M" -sp "$ROOT_DIR"/* ::

