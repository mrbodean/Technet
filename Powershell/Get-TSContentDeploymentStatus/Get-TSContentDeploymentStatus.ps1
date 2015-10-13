<#
.Synopsis
   Get the status of packages referanced in a Config Manager Task Sequence on a Distribution Point
.EXAMPLE
    Get-TSContentDeploymentStatus -SiteSystemServerName DEVSCCMDP1.my.domain.com -SiteCode DEV -TaskSequencePackageId DEV001A2
.EXAMPLE
    "DEVSCCMDP1.my.domain.com","DEVSCCMDP2.my.domain.com"|Get-TSContentDeploymentStatus -SiteCode DEV -TaskSequencePackageId DEV001A2
.NOTES
    Author
        Jon Warnken
        @MrBoDean
        jon.warnken@gmail.com
#>
function Get-TSContentDeploymentStatus
{
    [CmdletBinding()]
    #Requires -Version 3.0
    #Requires -Modules ConfigurationManager
    Param
    (
        # The Site System Server Name (AKA Distribution Point Computer Name).
        # This must be the FQDN
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias("DistributionPoint","DP")]
        [String[]]$SiteSystemServerName,
        # The Site Code for the Config Manager Site you wish to perform the check against.
        [Parameter(Mandatory=$true)]
        [String]$SiteCode,
        #Package Id for the Task Sequence
        [Parameter(Mandatory=$true)]
        [Alias("PackageId","ID")]
        [String]$TaskSequencePackageId
    )

    Begin
    {
        If((Get-Location).Drive.Name -ne $SiteCode){
            Try{Set-Location -path "$($SiteCode):" -ErrorAction Stop}
            Catch{Throw "Unable to connect to Site $SiteCode. Ensure that the Site Code is correct and that you have access."}
        }#If
        $CMServerName = $(Get-CMSite -SiteCode $SiteCode|select ServerName).ServerName
        $CMSite = $SiteCode
        [xml]$TS = Get-CMTaskSequence -TaskSequencePackageId $TaskSequencePackageId| select -ExpandProperty Sequence
        $rpkg = $ts.sequence.referenceList.reference.package|Select-Object -Unique
    }#Begin
Process{
      Foreach($pkg in $rpkg){
            $pkgname = (Get-CMPackage -Id $pkg |Select-Object Name).Name
            if(!($pkgname)){$pkgname = (Get-CMDriverPackage -Id $pkg |Select-Object Name).Name}
	        if(!($pkgname)){$pkgname = (Get-CMBootImage -Id $pkg |Select-Object Name).Name}
	        if(!($pkgname)){$pkgname = (Get-CMOperatingSystemImage -Id $pkg |Select-Object Name).Name}
	        if(!($pkgname)){$pkgname = (Get-CMSoftwareUpdateDeploymentPackage -Id $pkg |Select-Object Name).Name}
            #Write-Host "Get-WmiObject –NameSpace Root\SMS\Site_$SiteCode –Class SMS_DistributionDPStatus -ComputerName $CMServerName –Filter PackageID='$pkg' And Name='$SiteSystemServerName'"
            $query = Get-WmiObject –NameSpace Root\SMS\Site_$SiteCode –Class SMS_DistributionDPStatus -ComputerName $CMServerName –Filter "PackageID='$pkg' And Name='$SiteSystemServerName'" | Select Name, MessageID, MessageState, LastUpdateDate
            If ($query -eq $null){
                $Status = "Failed"
                $Message = "No status found! Ensure the package content has been deployed to this distribution point"
                $DPName = $SiteSystemServerName.Trim('{}')
            }else{
                Foreach ($objItem in $query){
	                $DPName = $null
                    $DPName = $objItem.Name
                    $UpdDate = [System.Management.ManagementDateTimeconverter]::ToDateTime($objItem.LastUpdateDate)
                    switch ($objItem.MessageState){
                        1{$Status = "Success"}
                        2{$Status = "In Progress"}
			            3{$Status = "Unknown"}
                        4{$Status = "Failed"}
                    }#Switch
                    switch ($objItem.MessageID){
                        2303{$Message = "Content was successfully refreshed"}
                        2323{$Message = "Failed to initialize NAL"}
                        2324{$Message = "Failed to access or create the content share"}
                        2330{$Message = "Content was distributed to distribution point"}
                        2354{$Message = "Failed to validate content status file"}
                        2357{$Message = "Content transfer manager was instructed to send content to Distribution Point"}
                        2360{$Message = "Status message 2360 unknown"}
                        2370{$Message = "Failed to install distribution point"}
                        2371{$Message = "Waiting for prestaged content"}
                        2372{$Message = "Waiting for content"}
                        2380{$Message = "Content evaluation has started"}
                        2381{$Message = "An evaluation task is running. Content was added to Queue"}
                        2382{$Message = "Content hash is invalid"}
                        2383{$Message = "Failed to validate content hash"}
                        2384{$Message = "Content hash has been successfully verified"}
                        2391{$Message = "Failed to connect to remote distribution point"}
                        2398{$Message = "Content Status not found"}
                        8203{$Message = "Failed to update package"}
                        8204{$Message = "Content is being distributed to the distribution Point"}
                        8211{$Message = "Failed to update package"}
                    }#Switch
                }#Foreach
            }#if else 
            [PSCustomObject]@{
                'Name' = $pkgname
                'PackageID' = $Pkg
                'Distribution Point'= $DPName
                'Status' = $Status
                'Message' = $Message
            }#[PSCustomObject]@
      }#foreach
   }#process
End{}
}