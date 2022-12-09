<# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
 THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING 
 BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
 We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce # 
 and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market
Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code
is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees,
that arise or result from the # use or distribution of the Sample Code.
#>	
param(
    [Parameter(Mandatory=$False)] [String] $SMSProvider = "localhost",
    [Parameter(Mandatory=$False)] [String] $SiteCode = "",
    [Parameter(Mandatory=$False)] [System.Management.Automation.PSCredential] $Credential = $null,
    [Parameter(Mandatory=$False)] [String] $GroupTag = "",
    [Parameter(Mandatory=$False)] [String] $OutputFile = "",
    [Parameter(Mandatory=$True)] [String] $CollectionID
)


Function Get-CMAutoPilotHash{
[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
    [Parameter(Mandatory=$False)] [String] $SMSProvider = "localhost",
    [Parameter(Mandatory=$True)] [String] $SiteCode = "",
    [Parameter(Mandatory=$False)] [System.Management.Automation.PSCredential] $Credential = $null,
    [Parameter(Mandatory=$False)] [String] $GroupTag = "",
    #[Parameter(Mandatory=$False)] [String] $OutputFile = "",
    #[Parameter(Mandatory=$False)] [Switch] $Force = $false,
    [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] [String[]] $ResourceID
)
Begin {
    # Get a CIM session
    if ($SMSProvider -eq "localhost") {
        $session = New-CimSession
    }
    else
    {
        $session = New-CimSession -ComputerName $SMSProvider -Credential $Credential
    }
}
Process {
    ForEach($client in $ResourceID){
        $SerialNumber = (Get-CimInstance -CimSession $session -Namespace "root\sms\site_$SiteCode" -Query "Select * from SMS_G_System_PC_BIOS where ReSourceID = '$Client'").SerialNumber
        If(!($SerialNumber)){
            Write-verbose "Unable to locate the Serial Number for ResourceID:$Client"
        }else{
            Write-Verbose ('_'*70)
            Write-Verbose "SerialNuber:$SerialNumber"
            Write-Verbose ('_'*70)
            $hash = (Get-CimInstance -CimSession $session -Namespace "root\sms\site_$SiteCode" -Query "Select * from SMS_G_System_MDM_DEVDETAIL_EXT01 where ReSourceID = '$Client'").DeviceHardwareData
            If(!($hash)){
                Write-Verbose "Unable to locate the Hardware Hash for ResourceID:$client"
            }Else{
                Write-Verbose ('_'*70)
                Write-Verbose "Hash:$hash"
                Write-Verbose ('_'*70)
                If($hash){
                    $c = New-Object psobject -Property @{
                            "SerialNumber" = $SerialNumber
                            "WindowsProductID" = ""
                            "HardwareHash" = $hash
                        }
            
                        if ($GroupTag -ne "")
                        {
                            Add-Member -InputObject $c -NotePropertyName "GroupTag" -NotePropertyValue $GroupTag
                        }
                    $c
                }
            }
        }
    }
}
End {
    Remove-CimSession $session
}
}

Function Get-AutoPilotInfo{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] [ValidateScript({$_ -ne ''})] [String]$SerialNumber,
    [Parameter(Mandatory=$True,ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] [ValidateScript({$_ -ne ''})] [String]$HardwareHash,
    [Parameter(Mandatory=$True,ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] [AllowEmptyString()] [String]$WindowsProductID = ""
)
Write-Verbose "Get Device info for Serial Number $SerialNumber"
    If($SerialNumber){
        Get-AutopilotDevice -serial $SerialNumber
    }Else{
        Write-Error "SerialNumber:$SerialNumber is Empty and would return all AutoPilot Devices"
    }
}

$startlocation = Get-Location

If(!(Get-Module -Name WindowsAutoPilotIntune)){
    "Missing Intune Graph Module"
    Install-Module -Name WindowsAutoPilotIntune -Scope AllUsers -Force
}

$pth = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\SMS\Setup" | 
  Select -ExpandProperty "UI Installation Directory"

$psd = "$pth\bin\ConfigurationManager.psd1"

if (!(Test-Path $psd)) {
  "Unable to locate Configuration Manager console install. This is required!"
  Exit
}
else {
  if (Get-Module ConfigurationManager) {
  }
  else {
    "loading ConfigMgr PS module..."
    Import-Module $psd
  }
}
If(!($SiteCode)){$SiteCode = Get-PSDrive -PSProvider CMSite}
cd "$($SiteCode):"

If(!($OutputFile)){
    #Connect to Intune
    Write-Host "Connecting to Intune"
    Connect-MSGraph -Quiet
    Write-Host ('_'*70)
}

$clients = Get-CMDevice -CollectionID $CollectionID
$HardwareHashes = $clients |%{
    if($CMInfo){Remove-Variable -Name CMInfo}
    $CMInfo = Get-CMAutoPilotHash -SiteCode $SiteCode -ResourceID $_.ResourceID -SMSProvider $SMSProvider -Credential $Credential -GroupTag $GroupTag
    $CMInfo
}


If($OutputFile){
    Write-Host "Exporting to $Outputfile"

    $HardwareHashes|Export-Csv -NoTypeInformation -Path $OutputFile
    Set-Location $startlocation
    Exit
}


Foreach($Device in $HardwareHashes){
    #check for exisiting Autopilot registration
    $APinfo = $device|Get-AutoPilotInfo

    #existing Device
    If($APinfo){
        If($GroupTag -eq $APinfo.groupTag){
            Write-Host "Group Tag '$($APinfo.groupTag)' is correct for $($APinfo.serialNumber)"
        }else{
            Set-AutopilotDevice -id $APInfo.id -groupTag $GroupTag
            Write-Verbose "Set-AutopilotDevice -id $($APInfo.id) -groupTag $GroupTag"
        }
    }
    #new Device
    else{
        Add-AutopilotImportedDevice -serialNumber $Device.SerialNumber -hardwareIdentifier $Device.HardwareHash -groupTag $GroupTag
        Write-Verbose "Uploading Hash for $($Device.SerialNumber)"
    }
}
Set-Location $startlocation
