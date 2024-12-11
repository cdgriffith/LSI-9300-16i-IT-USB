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

echo " "
echo "********************************************"
echo "*** Displaying HBA info for verification ***"
echo "********************************************"
echo " "
sas3flash.efi -listall

echo " "
echo "******************************************************************"
echo "*** Info Listed, remove USB and type `reset` to reboot ***"
echo "******************************************************************"

:end
