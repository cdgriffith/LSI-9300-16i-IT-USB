# Disable command echoing
@echo -off

# Find startup device, necessary to get files from the root directory
for %i run (1 10)
  set root "fs%i%:"
  if exist "%root%\sas3flash.efi" then
    goto deviceFound
  endif
endfor

echo "*************************************************************"
echo "*** ERROR: could not find device with file: sas3flash.efi ***"
echo "*************************************************************"
goto end

:deviceFound

# Try to erase existing firmware
echo "*********************************"
echo "*** Erasing existing firmware ***"
echo "*********************************"
echo " "
sas3flash.efi -o -c 0 -e 6
sas3flash.efi -o -c 1 -e 6

# Exit on error
if not %LastError% == 0 then
    echo " "
    echo "*********************************************************************"
    echo "*** ERROR: Could not erase old firmware, abandoning IT-mode flash ***"
    echo "*********************************************************************"
	goto end
endif

echo " "
if exist "%root%\disable_bios" then
    # Flash firmware only, allowing faster boot times (but no booting from HBA-attached disks)
    echo "*****************************************"
    echo "*** Flashing IT firmware without BIOS ***"
    echo "*****************************************"
    echo " "

    sas3flash.efi -o -c 0 -f "%root%\SAS9300_16i_IT.bin"
    sas3flash.efi -o -c 1 -f "%root%\SAS9300_16i_IT.bin"
else
    # Flash firmware + BIOS, allowing booting from an HBA-attached disk
    echo "**************************************"
    echo "*** Flashing IT firmware with BIOS ***"
    echo "**************************************"
    echo " "

    sas3flash.efi -o -c 0 -f "%root%\SAS9300_16i_IT.bin" -b "%root%\mptsas3.rom"
    sas3flash.efi -o -c 1 -f "%root%\SAS9300_16i_IT.bin" -b "%root%\mptsas3.rom"
endif

# Exit on error
if not %LastError% == 0 then
    echo " "
    echo "*******************************************"
    echo "*** ERROR: Could flash IT-mode firmware ***"
    echo "*******************************************"
	goto end
endif

echo " "
echo "********************************************"
echo "*** Displaying HBA info for verification ***"
echo "********************************************"
echo " "
sas3flash.efi -listall

echo " "
echo "******************************************************************"
echo "*** IT firmware flashed, remove USB and type `reset` to reboot ***"
echo "******************************************************************"

:end
