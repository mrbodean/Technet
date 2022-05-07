Function Get-CMAutoPilotHash{
[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
    [Parameter(Mandatory=$False)] [String] $SMSProvider = "localhost",
    [Parameter(Mandatory=$True)] [String] $SiteCode = "",
    [Parameter(Mandatory=$False)] [System.Management.Automation.PSCredential] $Credential = $null,
    [Parameter(Mandatory=$False)] [String] $GroupTag = "",
    [Parameter(Mandatory=$False)] [String] $OutputFile = "",
    [Parameter(Mandatory=$False)] [Switch] $Force = $false,
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
    [Parameter(Mandatory=$True,ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] [ValidateScript({$_ -ne ''})] [String]$HardwareHash
    # WindowsProductID is a parameter for Get-AutopilotDevice. This function does not use it but it is present as a comment for the future 
    # [Parameter(Mandatory=$True,ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] [AllowEmptyString()] [String]$WindowsProductID = ""
)
Write-Verbose "Get Device info for Serial Number $SerialNumber"
    If($SerialNumber){
        Get-AutopilotDevice -serial $SerialNumber
    }Else{
        Write-Error "SerialNumber:$SerialNumber is Empty and would return all AutoPilot Devices"
    }
}

