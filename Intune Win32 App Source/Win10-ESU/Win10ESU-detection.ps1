<# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
 THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING 
 BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
 We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce # 
 and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market
Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code
is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees,
that arise or result from the # use or distribution of the Sample Code.
#>
# Requirements Windows 10 22H2 and KB5046613 (19045.5131) https://learn.microsoft.com/en-us/windows/whats-new/enable-extended-security-updates#prerequisites
$OSCurrentersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
[byte]$CanApplyWin10ESU = 0
$Win1022H2 = "19045"
$ReqPatch = "5131"
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

#prerequisites
$OSVersion = $OSCurrentersion.CurrentBuild
if ($OSVersion -eq $Win1022H2) {
    Write-Verbose "This system is running Windows 10 22H2 (19045). Current version: $OSVersion"
    [byte]$CanApplyWin10ESU = $CanApplyWin10ESU -bor 0x1
    if (($OSCurrentersion.CurrentBuildRevision -ge $ReqPatch) -or ($OSCurrentersion.UBR -ge $ReqPatch)) {
    Write-Verbose "This system has the required patch KB5046613 (19045.5131) installed."
    [byte]$CanApplyWin10ESU = $CanApplyWin10ESU -bor 0x2
    }
}
#end prerequisites
If($CanApplyWin10ESU -eq 0x3) {
    Write-Verbose "This system meets the prerequisites for Windows 10 ESU."
} Else {
    Write-Output "This system does not meet the prerequisites for Windows 10 ESU. Current version: $OSVersion, Current patch: $($OSCurrentersion.CurrentBuildRevision) Required version: $Win1022H2, Required patch: $ReqPatch"
    exit 1 # Exiting without checking the for the ESU Activation status and this will trigger the install but that script will exit out as well.
}



$ESUY1Status = Test-ESUKey -Key $win10_Y1_Key -Verbose #Verbose commented out for Win32 detection if testing manualy, it may ver uncommented for tracing
Write-Verbose "Y1 ESU key status is $ESUY1Status"
If($win10_Y2_Key -and $win10_Y2_Key -ne "Your-Year-2-ESU-Key-Here") {
  $ESUY2Status = Test-ESUKey -Key $win10_Y2_Key -Verbose
} else {
  $ESUY2Status = $null # No Year 2 ESU key provided
}
Write-Verbose "Y2 ESU key status is $ESUY2Status"
If($win10_Y3_Key -and $win10_Y3_Key -ne "Your-Year-3-ESU-Key-Here") {
  $ESUY3Status = Test-ESUKey -Key $win10_Y3_Key -Verbose
} else {
  $ESUY3Status = $null # No Year 3 ESU key provided
}
Write-Verbose "Y3 ESU key status is $ESUY3Status"
If(($null -ne $ESUY2Status) -and ($null -ne $ESUY3Status)) {
  If($ESUY1Status -and $ESUY2Status -and $ESUY3Status) {
    Write-Output "Y1, Y2, and Y3 ESU keys are valid and activated." 
    exit 0 # All ESU keys are valid and activated
  } Else {
    Write-Output "Not all ESU keys are valid or activated."
    exit 1 # Not all ESU keys are valid or activated
  }
}elseif (($null -ne $ESUY2Status)){
  If($ESUY1Status -and $ESUY2Status) {
    Write-Output "Y1 and Y2 ESU keys are valid and activated." 
    exit 0 # All ESU keys are valid and activated
  } Else {
    Write-Output "Not all ESU keys are valid or activated."
    exit 1 # Not all ESU keys are valid or activated
  }
}else{
  If($ESUY1Status) {
    Write-Output "Y1 ESU key is valid and activated." 
    exit 0 # Y1 ESU key is valid and activated
  } Else {
    Write-Output "Y1 ESU key is not valid or activated."
    exit 1 # Y1 ESU key is not valid or activated
  }
}