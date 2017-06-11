Write-Host "Warning this process will format the USB device that you select!!" -ForegroundColor Red -BackgroundColor White
$USBDrives = gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}
If(!$USBDrives)
	{
		Write-Host "No USB drives found! Please insert the drive and try again!"
		exit
	}
Else
	{
		Write-Host "Found the following USB Drives" 
		Write-Host  $USBDrives
	}
If($USBDrives.count -gt 1)
	{
		$USBDrive = $USBDrive = Read-Host "Enter the drive letter of the usb device that you would like to load the Publix System Config Image on:"
	}
else
	{
		$USBDrive = $USBDrives
	}
$CheckUSB = gwmi -Query "Select DeviceID From Win32_LogicalDisk Where DeviceID = '$USBDrive' and DriveType = 2"
If(!$CheckUSB)
	{
		Write-Host " The Drive letter entered is not a USB device or the Drive was entered incorrectly!"
		Foreach($drive in $USBDrives)
			{
				Write-Host " To select $drive enter $drive"
				exit
			}
	}

Write-Host "Press any key to format the drive and copy the files. Use Ctrl+C to cancel." -ForegroundColor Red -BackgroundColor White
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
$command = @"
select Volume $USBDrive
Clean
create partition primary
select partition 1
active
format fs=ntfs quick
active
exit
"@
$command|diskpart

If($LASTEXITCODE -gt 0)
	{
		Write-host "The format of $USBDrive failed!! Check the drive and try again!"
		exit
	}
Else
	{
		Write-Host "The format of $USBDrive is complete"
	}
\PublixPe\bootsect.exe /nt60 $USBDrive /force /mbr
xcopy "c:\PublixPE\ISO\ProdB\x64\*.*" /e $USBDrive