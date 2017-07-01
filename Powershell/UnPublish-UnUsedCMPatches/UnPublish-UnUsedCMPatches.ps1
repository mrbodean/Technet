<# 
.Synopsis
    Decline Updates in WSUS that are not used in COnfiguration Manager
.DESCRIPTION 
    Script to decline updates in WSUS that are not deployed and not required by any clients
    in Configuration Manager and that are older than 30 days. 
.EXAMPLE
    Unpublish-UnUsedCMPatches -SiteCode LAB -SCCMServer LabServer -WSUSServer LabWSUS
        This will report on the patches that would be declined
.EXAMPLE
    Unpublish-UnUsedCMPatches -SiteCode LAB -SCCMServer LabServer -WSUSServer LabWSUS -Decline
        This will report on the patches that would be declined
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
        [Parameter()]
        [bool]$UseSSL = $False,
        # Port to use for WSUS connection. Default value is 8530
        [Parameter()]
        [int]$PortNumber = 8530,
        # Configuration Manager Site Server with SMS Provider role
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SCCMServer,
        # Configuration Manager Site Code
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SiteCode,
        # Decline Updates. Defaults to False for safety
        [Parameter()]
        [switch]$Decline
    )
Function Unpublish-UnUsedCMPatches{
    [CmdletBinding()]
    Param(
        # WSUS Server Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$WsusServer,
        # Use SSL for the WSUS connection. Default value is $False
        [Parameter()]
        [bool]$UseSSL = $False,
        # Port to use for WSUS connection. Default value is 8530
        [Parameter()]
        [int]$PortNumber = 8530,
        # Configuration Manager Site Server with SMS Provider role
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SCCMServer,
        # Configuration Manager Site Code
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SiteCode,
        # Decline Updates. Defaults to False for safety
        [Parameter()]
        [switch]$Decline
    )
    $outPath = Split-Path $script:MyInvocation.MyCommand.Path
    $outDeclineList = Join-Path $outPath "DeclinedUpdates.csv"
    $outDeclineListBackup = Join-Path $outPath "DeclinedUpdatesBackup.csv"
    if(Test-Path -Path $outDeclineList){Copy-Item -Path $outDeclineList -Destination $outDeclineListBackup -Force}
    "UpdateID, RevisionNumber, Title, KBArticle, SecurityBulletin, LastLevel" | Out-File $outDeclineList
    $cmpatchlist = Get-WmiObject -Namespace "root\SMS\site_$SiteCode" -class SMS_SoftwareUpdate -ComputerName $SCCMServer|Select-Object LocalizedDisplayName, CI_UniqueID, IsDeployed, NumMissing
    $cmpatchlistcount = $cmpatchlist.Count
    If($cmpatchlistcount -eq 0){ 
        Throw "Error Collecting patches from $SCCMServer"
        return
    }
    "Found $cmpatchlistcount updates on $SCCMServer"
    $cmpatchlist = $cmpatchlist|?{($_.IsDeployed -eq $false) -and ($_.NumMissing -eq 0)}
    $cmpatchlistcount = $cmpatchlist.Count
    "Found $cmpatchlistcount updates on $SCCMServer that are not deployed and not required. These will be evaluated to determine if they are older then 30 days and not declined. "
    #Connect to the WSUS 3.0 interface.
    [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
    If($? -eq $False)
    {       Write-Warning "Something went wrong connecting to the WSUS interface on $WsusServer server: $($Error[0].Exception.Message)"
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
            if(($patch.IsDeclined -eq $false) -and ( ($patch.CreationDate) -lt (get-date).AddDays(-30) ) ){
                Write-Progress -Activity "Decline Unused Updates" -Status "Declining update #$i/$cmpatchlistcount - $($item.LocalizedDisplayName)" -PercentComplete $percentComplete -CurrentOperation "$($percentComplete)% complete"
                "$($patch.Id.UpdateId.Guid), $($patch.Id.RevisionNumber), $($patch.Title), $($patch.KnowledgeBaseArticles), $($patch.SecurityBulletins), $($patch.HasSupersededUpdates)" | Out-File $outDeclineList -Append
                If($Decline){$patch.Decline()}
                $updatesDeclined++
            }else{
                Write-Progress -Activity "Decline Unused Updates" -Status "Update #$i/$cmpatchlistcount - $($item.LocalizedDisplayName) is already declined or was recieved withing the last 30 days" -PercentComplete $percentComplete -CurrentOperation "$($percentComplete)% complete"
            }
        }catch{
        #"$($item.LocalizedDisplayName) was not found in WSUS"
        Write-Progress -Activity "Decline Unused Updates" -Status "Update #$i/$cmpatchlistcount - $($item.LocalizedDisplayName) was not found in WSUS" -PercentComplete $percentComplete -CurrentOperation "$($percentComplete)% complete"
        }
    }
    If($Decline -eq $False){"$updatesDeclined updates would have been declined"}else{"$updatesDeclined updates were declined"}
}
Unpublish-UnUsedCMPatches @PSBOundParameters
