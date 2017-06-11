<#
.Synopsis
   Create usb boot media. The script will prompt for the usb drive to repartition and format
.Description
   This script will prompt for the drive to repartition and format. After completing the format the 
   drive will be made bootable by bootsect.exe. The last step will copy the files in $sourcepath to the 
   usb device.
.EXAMPLE
   New-USBBootDisk.ps1
.NOTES
    Author
        Jon Warnken
        @MrBoDean
        jon.warnken@mrbodean.net
    Bootsect.exe 
        If this is not available on your system you can get it from the Automated Deployment Kit that is approriate for your 
        enviroment. https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
    Boot Disk format
        The script is set to format the drive as ntfs. This can be changed by updating diskpart commands in the $command variable
#>
$sourcepath = "C:\BootDisk"
Write-Host "Warning this process will format the USB device that you select!!" -ForegroundColor Red -BackgroundColor White
$USBDrives = Get-WmiObject win32_diskdrive | Where-Object{$_.interfacetype -eq "USB"} | ForEach-Object{Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  ForEach-Object{Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | ForEach-Object{$_.deviceid}
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
		$USBDrive = $USBDrive = Read-Host "Enter the drive letter of the usb device that you would like to load the Boot Image on:"
	}
else
	{
		$USBDrive = $USBDrives
	}
$CheckUSB = Get-WmiObject -Query "Select DeviceID From Win32_LogicalDisk Where DeviceID = '$USBDrive' and DriveType = 2"
If(!$CheckUSB)
	{
		Write-Host " The Drive letter entered is not a removable USB device or the Drive was entered incorrectly!"
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
bootsect.exe /nt60 $USBDrive /force /mbr
If($LASTEXITCODE -gt 0)
	{
		Write-host "Setting the boot sector failed!"
		exit
	}
Else
	{
		Write-Host "Setting the boot sector of $USBDrive is complete"
	}
xcopy /herky "$sourcepath\*.*" $USBDrive 
If($LASTEXITCODE -gt 0)
	{
		Write-host "Cpoying the boot image to $USBDrive failed!! Check the drive and try again!"
		exit
	}
Else
	{
		Write-Host "Copy of the boot image to $USBDrive is complete"
	}