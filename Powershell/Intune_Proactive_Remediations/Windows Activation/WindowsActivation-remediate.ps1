$KMS = "NPPR9-FWDCX-D2C8J-H872K-2YT43" #Win10\11 Enterprise https://docs.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys
$MAK = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" # Add your MAK 

If ((Get-WmiObject  -Class Win32_ComputerSystem).PartOfDomain){
    #Domain joined use KMS
    slmgr /ipk $($KMS)
}Else{
    # Not Domain joined use MAK
    slmgr /ipk $($MAK)
}
slmgr /ato
Start-Sleep -Seconds 120
$InstalledLicense = Get-WmiObject -Query "Select * from SoftwareLicensingProduct Where PartialProductKey IS NOT NULL AND ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'"
Switch ($InstalledLicense.LicenseStatus)
{
  0 {"Unlicensed"}
  1 {"Licensed"}
  2 {"Out-of-Box Grace Period"}
  3 {"Out-of-Tolerance Grace Period"}
  4 {"Non-Genuine Grace Period"}
  5 {"Notification"}
  6 {"ExtendedGrace"}
}
If($InstalledLicense.LicenseStatus -eq 1){exit 0}Else{exit 1}