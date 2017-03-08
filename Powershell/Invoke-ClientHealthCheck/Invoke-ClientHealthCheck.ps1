$ClientHealthCheck = {
    Function Reset-ProvisioningMode{
        $regpath = "HKLM:\SOFTWARE\Microsoft\CCM\CcmExec"
        $ProvisioningMode = (Get-ItemProperty -path $regpath).ProvisioningMode
        If($ProvisioningMode -eq "true"){
            Write-Output "$($env:ComputerName) is in Provisioning Mode! Remediating..."
            Set-itemProperty -path $regpath -Name ProvisioningMode -Value "false"
            Invoke-wmiMethod -namespace root\CCM -class SMS_Client -Name SetClientProvisioningMode -ArgumentList $false
        }else{
            Write-Output "$($env:ComputerName) Provisioning Mode: OK"
        }
    }
    Function Reset-UpdateStore {
        Write-Verbose "Check StateMessage.log if State Messages are successfully forwarded to Management Point"
        $StateMessage = cat ("c:\Windows\CCM\Logs\StateMessage.log")
        if ($StateMessage -match "Successfully forwarded State Messages to the MP") {
            Write-Output "$($env:ComputerName) StateMessage: OK" 
        }
        else { 
            Write-Output "$($env:ComputerName) StateMessage: ERROR. Remediating..."
            $SCCMUpdatesStore = New-Object -ComObject Microsoft.CCM.UpdatesStore
            $SCCMUpdatesStore.RefreshServerComplianceState()
        }
    }
    Function RegistryPol {
        Write-Verbose "Check WUAHandler.log if registry.pol need to be deleted"
        $WUAHandler = cat ("c:\Windows\CCM\Logs\WUAHandler.log")
        if ($WUAHandler -contains "0x80004005") {

            Write-Output "$($env:ComputerName) GPO Cache: Error. Deleting registry.pol..."
            Remove-Item C:\Windows\System32\registry.pol -Force
        }
        else {
            Write-Output "$($env:ComputerName) GPO Cache: OK"
        }
    }
    Function Validate-CMWMI {
        
        Try {
            $WMI = Get-WmiObject -Namespace root/ccm -Class SMS_Client -ErrorAction Stop
            Write-Output "$($env:ComputerName) WMI for Config Manger Client: OK" 
        } Catch {
            Write-Output "Failed Client WMI Check. Verifying General WMI Health. This will take a few minutes..."
            $ClientReinstall = $true
            $WMIStatus = winmgmt /verifyrepository 
            If($WMIStatus -eq "WMI repository is consistent"){
                Write-Output "$($env:ComputerName) WMI for Config Manger Client: ERROR!! WMI is missing Client namespace. Reinstall Client!"
            }else{
                $WMIStatus
                Write-Output "$($env:ComputerName) WMI for Config Manger Client: ERROR!! Repair WMI and reinstall ConfigMgr client."
            }
        }
    }
    Function Reinstall-Client {
        If(Test-path c:\windows\ccm\ccmrepair.exe){
            Write-Output "$($env:ComputerName) Repairing Configuration Manager Client..."
            Invoke-Expression "c:\windows\ccm\ccmrepair.exe "
        }else{
            If(Test-path c:\windows\ccmsetup\ccmsetup.exe){
                Write-Output "$($env:ComputerName) Reinstalling Configuration Manager Client..."
                Invoke-Expression "c:\windows\ccmsetup\ccmsetup.exe /bitspriority:low /skipprereq:silverlight.exe"
            }
            else{
                Write-Output "$($env:ComputerName) No local Client install files! "
            }
        }

        
    }

    Reset-ProvisioningMode
    Reset-UpdateStore
    RegistryPol
    Validate-CMWMI
}