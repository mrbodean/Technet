$ClientHealthCheck = {
    Function Reset-ProvisioningMode{
        $regpath = "HKLM:\SOFTWARE\Microsoft\CCM\CcmExec"
        $ProvisioningMode = (Get-ItemProperty -path $regpath).ProvisioningMode
        If($ProvisioningMode -eq "true"){
            Write-Output "$($env:ComputerName) is in Provisioning Mode! Remediating..."
            Set-itemProperty -path $regpath -Name ProvisioningMode -Value "false"
            Invoke-wmiMethod -namespace root\CCM -class SMS_Client -Name SetClientProvisioningMode -ArgumentList $false
            $Global:continue = $false
            Write-Output "$($env:ComputerName) was in Provisioning Mode. Remediation was attempted, please give the system 15-20 minutes and recheck. No other Remediations will be attempted."
        }else{
            Write-Output "$($env:ComputerName) Provisioning Mode: OK"
        }
    }
    Function Reset-UpdateStore {
        Write-Verbose "Check StateMessage.log if State Messages are successfully forwarded to Management Point"
        $StateMessage = get-content ("c:\Windows\CCM\Logs\StateMessage.log")
        if ($StateMessage -match "Successfully forwarded State Messages to the MP") {
            Write-Output "$($env:ComputerName) StateMessage: OK" 
        }
        else { 
            Write-Output "$($env:ComputerName) StateMessage: ERROR. Remediating..."
            $SCCMUpdatesStore = New-Object -ComObject Microsoft.CCM.UpdatesStore
            $SCCMUpdatesStore.RefreshServerComplianceState()
            $Global:continue = $false
            Write-Output "$($env:ComputerName) was Not successfully forwarding State Messages to a Management Point. Remediation was attempted, please give the system 15-20 minutes and recheck. No other Remediations will be attempted."
        }
    }
    Function Test-RegistryPol {
        Write-Verbose "Check WUAHandler.log if registry.pol need to be deleted"
        $WUAHandler = get-content ("c:\Windows\CCM\Logs\WUAHandler.log")
        if ($WUAHandler -contains "0x80004005") {

            Write-Output "$($env:ComputerName) GPO Cache: Error. Deleting registry.pol..."
            Remove-Item C:\Windows\System32\registry.pol -Force
            $Global:continue = $false
            Write-Output "$($env:ComputerName) had GPO Cache errors. Remediation was attempted, please give the system 15-20 minutes and recheck. No other Remediations will be attempted."
        }
        else {
            Write-Output "$($env:ComputerName) GPO Cache: OK"
        }
    }
    Function Test-CMWMI {
        
        Try {
            $WMI = Get-WmiObject -Namespace root/ccm -Class SMS_Client -ErrorAction Stop
            Write-Output "$($env:ComputerName) WMI for Config Manger Client: OK" 
        } Catch {
            Write-Output "Failed Client WMI Check. Verifying General WMI Health. This will take a few minutes..."
            $ClientReinstall = $true
            $WMIStatus = winmgmt /verifyrepository 
            If($WMIStatus -eq "WMI repository is consistent"){
                $Global:continue = $false
                Write-Output "$($env:ComputerName) WMI for Config Manger Client: ERROR!! WMI is missing Client namespace. Reinstall Client! No other Remediations will be attempted."            
            }else{
                $Global:continue = $false
                $WMIStatus
                Write-Output "$($env:ComputerName) WMI for Config Manger Client: ERROR!! Repair WMI and reinstall ConfigMgr client. No other Remediations will be attempted."
            }
        }
    }
 # Commented out the Repair-Client function as this is for ad hoc client checks and manual inspection and client install is expeceted as part of the workflow.
 # Leaving the code as a sample for those who may use this as a fully automated process. 
 # !!! Please note that invoking this script against a remote client and using the Repair-Client function may cause issues due to 
 # the double hop limitations. !!!
 #
 #   Function Repair-Client {
 #       If(Test-path c:\windows\ccm\ccmrepair.exe){
 #           Write-Output "$($env:ComputerName) Repairing Configuration Manager Client..."
 #           Invoke-Expression "c:\windows\ccm\ccmrepair.exe "
 #       }else{
 #           If(Test-path c:\windows\ccmsetup\ccmsetup.exe){
 #               Write-Output "$($env:ComputerName) Reinstalling Configuration Manager Client..."
 #               Invoke-Expression "c:\windows\ccmsetup\ccmsetup.exe /bitspriority:low /skipprereq:silverlight.exe"
 #           }
 #           else{
 #               Write-Output "$($env:ComputerName) No local Client install files! "
 #           }
 #       }
 #   }
    $Global:continue = $true
    If($continue){Test-CMWMI}    
    If($continue){Reset-ProvisioningMode}
    If($continue){Reset-UpdateStore}
    If($continue){Test-RegistryPol}
}
