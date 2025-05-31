<# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
 THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING 
 BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
 We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce # 
 and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market
Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code
is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees,
that arise or result from the # use or distribution of the Sample Code.
#>
$win10_Y1_ESU = "f520e45e-7413-4a34-a497-d2765967d094"
$win10_Y2_ESU = "1043add5-23b1-4afb-9a0f-64343c8f3f8d"
$win10_Y3_ESU = "83d49986-add3-41d7-ba33-87c7bfb5c0fb"
$win10_Y1_Key = "Your-Year-1-ESU-Key-Here"
$win10_Y2_Key = "Your-Year-2-ESU-Key-Here"
$win10_Y3_Key = "Your-Year-3-ESU-Key-Here"

function Test-ESUKey {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$Key
    )
    # Check if the ESU key is valid for Windows 10 ESU                                  
    $PartialKey = $Key.Substring($Key.Length - 5)
    $Licensed = Get-WmiObject -Query ('SELECT ID, Name, OfflineInstallationId, ProductKeyID FROM SoftwareLicensingProduct where PartialProductKey = "{0}"' -f $PartialKey)
    # Check if the key is Activated
    $ActivationStatus = Get-WmiObject -Query ('SELECT LicenseStatus FROM SoftwareLicensingProduct where PartialProductKey = "{0}"' -f $PartialKey)
    if ($Licensed -and $ActivationStatus.LicenseStatus -eq 1) {
        Write-Verbose "ESU key is valid and activated."
        return $true
    } else {
        if(!$Licensed) {
          Write-Verbose "No valid ESU key found"
        } else {
          Write-Verbose "Valid ESU key found"
        }
        If($ActivationStatus.LicenseStatus -ne 1) {
          Write-Verbose "ESU key is not activated."
        }
        return $false
    }
}


If($win10_Y1_Key -and $win10_Y1_Key -ne "Your-Year-1-ESU-Key-Here"){
    # Year 1 ESU Key
    slmgr /ipk $($win10_Y1_Key)
    Start-sleep -Seconds 30
    slmgr /ato $($win10_Y1_ESU)
    Start-Sleep -Seconds 120
    $ESUY1Status = Test-ESUKey -Key $win10_Y1_Key
    If($ESUY1Status -eq $true){
        Write-Output "Year 1 ESU Key is valid and activated."
    }else{
        Write-Output "Year 1 ESU Key is not valid or not activated."
    }
  }
If($win10_Y2_Key -and $win10_Y2_Key -ne "Your-Year-2-ESU-Key-Here"){
    # Year 2 ESU Key
    slmgr /ipk $($win10_Y2_Key)
    Start-sleep -Seconds 30
    slmgr /ato $($win10_Y2_ESU)
    Start-Sleep -Seconds 120
    $ESUY2Status = Test-ESUKey -Key $win10_Y2_Key
    If($ESUY2Status -eq $true){
        Write-Output "Year 2 ESU Key is valid and activated."
    }else{
        Write-Output "Year 2 ESU Key is not valid or not activated."
    }
  }
If($win10_Y3_Key -and $win10_Y3_Key -ne "Your-Year-3-ESU-Key-Here"){
    # Year 3 ESU Key
    slmgr /ipk $($win10_Y3_Key)
    Start-sleep -Seconds 30
    slmgr /ato $($win10_Y3_ESU)
    Start-Sleep -Seconds 120
    $ESUY3Status = Test-ESUKey -Key $win10_Y3_Key
    If($ESUY3Status -eq $true){
        Write-Output "Year 3 ESU Key is valid and activated."
    }else{
        Write-Output "Year 3 ESU Key is not valid or not activated."
    }
  }
If($ESUY1Status -and $ESUY2Status -and $ESUY3Status) {
    Write-Output "All ESU keys are valid and activated."
    exit 0 # All ESU keys are valid and activated
} else {
    Write-Output "Not all ESU keys are valid or activated."
    exit 1 # Not all ESU keys are valid or activated
}