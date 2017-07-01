<# 
.Synopsis
    Decline Updates in WSUS that are not used in COnfiguration Manager
.DESCRIPTION 
    Script decline updates in WSUS that are not deployed and not required by any clients
    in Configuration Manager and that are older than 30 days. 
.EXAMPLE
    Unpublish-UnUsedCMPatches -SiteCode LAB -SiteServer LabServer -WSUSServer LabWSUS
.NOTES
    Author Jon Warnken
    @MrBoDean
    jon.warnken@mrbodean.net
    mrbodean.net
#> 

Param(
        # WSUS Server Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$WsusServer,
        # Use SSL for the WSUS connection. Default value is $False
        [bool]$UseSSL = $False,
        # Port to use for WSUS connection. Default value is 8530
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$PortNumber = 8530,
        # Configuration Manager Site Server with SMS Provider role
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SCCMServer,
        # Configuration Manager Site Code
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SiteCode,
        # Skip the decline step. Defaults to $True for safety
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [bool]$skipdecline = $True
    )
Function Unpublish-UnUsedCMPatches{
    [CmdletBinding()]
    Param(
        # WSUS Server Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$WsusServer,
        # Use SSL for the WSUS connection. Default value is $False
        [bool]$UseSSL = $False,
        # Port to use for WSUS connection. Default value is 8530
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$PortNumber = 8530,
        # Configuration Manager Site Server with SMS Provider role
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SCCMServer,
        # Configuration Manager Site Code
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SiteCode,
        # Skip the decline step. Defaults to $True for safety
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [bool]$skipdecline = $True
    )
     
    $cmpatchlist = Get-WmiObject -Namespace "root\SMS\site_$SiteCode" -class SMS_SoftwareUpdate  -ComputerName $SCCMServer|Select-Object LocalizedDisplayName, CI_UniqueID, IsDeployed 
    #$cmpatchlist = import-csv -Path C:\temp\patchlist.csv
    $cmpatchlistcount = $cmpatchlist.Count
    "Found $cmpatchlistcount updates on $SCCMServer"
    #Connect to the WSUS 3.0 interface.
    [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
    If($? -eq $False)
    {       Write-Warning "Something went wrong connecting to the WSUS interface on $WsusServer server: $($Error[0].Exception.Message)"
            $ErrorActionPreference = $script:CurrentErrorActionPreference
            Return
    }
    $WsusServerAdminProxy = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($WsusServer,$UseSSL,$PortNumber);
    if($i){Remove-Variable i}
    If($updatesDeclined){Remove-Variable updatesDeclined}
    $updatesDeclined =0
    Foreach($item in $cmpatchlist){
        Remove-Variable patch -ErrorAction silentlycontinue
        $i++
        $percentComplete = "{0:N2}" -f (($i/$cmpatchlistcount) * 100)
        Write-Progress -Activity "Decline Unused Updates" -Status "Checking if update #$i/$cmpatchlistcount - $($item.LocalizedDisplayName)" -PercentComplete $percentComplete -CurrentOperation "$($percentComplete)% complete"
        Try{
            $patch = $WsusServerAdminProxy.getUpdate([guid]$item.CI_UniqueID)
            if(($patch.IsDeclined -eq $false) -and ( ($patch.CreationDate) -lt (get-date).AddDays(-30))){
                #"$($patch.Title) is being declined"
                Write-Progress -Activity "Decline Unused Updates" -Status "Declining update #$i/$cmpatchlistcount - $($item.LocalizedDisplayName)" -PercentComplete $percentComplete -CurrentOperation "$($percentComplete)% complete"
                If(!($skipdecline)){$patch.Decline()}
                $updatesDeclined++
            }else{
                Write-Progress -Activity "Decline Unused Updates" -Status "Update #$i/$cmpatchlistcount - $($item.LocalizedDisplayName) is already declined or was recieved withing the last 30 days" -PercentComplete $percentComplete -CurrentOperation "$($percentComplete)% complete"
            }
        }catch{
        #"$($item.LocalizedDisplayName) was not found in WSUS"
        Write-Progress -Activity "Decline Unused Updates" -Status "Update #$i/$cmpatchlistcount - $($item.LocalizedDisplayName) was not found in WSUS" -PercentComplete $percentComplete -CurrentOperation "$($percentComplete)% complete"
        }
    }
    If($skipdecline){"$updatesDeclined updates would have been declined"}else{"$updatesDeclined updates were declined"}
}
Unpublish-UnUsedCMPatches @PSBOundParameters