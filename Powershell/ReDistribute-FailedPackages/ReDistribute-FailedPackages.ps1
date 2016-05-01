
<#PSScriptInfo

.VERSION 1.0.0

.GUID 7a238e84-d39c-4e99-abbe-056d00d40aac

.AUTHOR Jonathan Warnken - @MrBodean - http://mrbodean.azurewebsites.net/

.COMPANYNAME 

.COPYRIGHT (C) Jonathan Warnken. All rights reserved.

.TAGS SCCM

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 
.Synopsis
   Redistrubute a Configuration Manager packages in a failed state
.DESCRIPTION 
 Script to ReDistribute Configuration Manager Packages to Targeted Distribution Points with a Failed status
.EXAMPLE
   ReDistribute-FailedPackages -SiteCode LAB -SiteServer LabServer
#> 
Param(
    # Configuration Manager Site Code
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$SiteCode,
    # Configuration Manager Site Server
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$SiteServer
)
<#
.Synopsis
   Redistrubute a Configuration Manager package to a distribution point
.EXAMPLE
   ReDistribute-Package -SiteCode LAB -SiteServer LabServer -PkgID LAB00005 -DP LabDP1.lab.int
.EXAMPLE
   "LabDP1.lab.int","LabDP2.lab.int"|ReDistribute-Package -SiteCode LAB -SiteServer LabServer -PkgID LAB00005
#>
function ReDistribute-FailedPackages
{
    [CmdletBinding()]
    Param
    (
        # Configuration Manager Site Code
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SiteCode,

        # Configuration Manager Site Server
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SiteServer
    )
    Begin{
        <#
        Possible package status states: (https://msdn.microsoft.com/en-us/library/cc143014.aspx)
        0 - INSTALLED
        1 - INSTALL_PENDING
        2 - INSTALL_RETRYING
        3 - INSTALL_FAILED
        4 - REMOVAL_PENDING
        5 - REMOVAL_RETRYING
        6 - REMOVAL_FAILED
        #>
        $PackageState = 3 
        $FailedPackages = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Query "select * from SMS_PackageStatusDistPointsSummarizer where state = $($PackageState)" -ComputerName $SiteServer
    }# Begin
    Process{
        If(!($FailedPackages)){
            if ($FailedPackages.Count -gt 0){ Write-Output -InputObject "There are $($FailedPackages.Count) instances of failed content distributions at the moment."}
            else{ Write-Output -InputObject "There is 1 instances of failed content distributions at the moment."}#if Else
            try{
                foreach ($FailedPackage in $FailedPackages){
                    Write-Verbose -Message "Attempting to ReDistribute failed instances of PackageID $($PkgID)"
                    $DistributionPoints = Get-WmiObject -Namespace "root\SMS\Site_$SiteCode" -Class SMS_DistributionPoint -Filter "PackageID='$($FailedPackage.PackageID)' and ServerNALPath='$($FailedPackage.ServerNALPath)'"  -ComputerName $SiteServer
                    If($DistributionPoints){
                        Write-Verbose -Message "Located a failed content distrubution of package $($PkgID) on $($FailedPackage.ServerNALPath)"
                        $DistributionPoint.RefreshNow = $True
                        $DistributionPoint.Put()|Out-Null
                        Write-Verbose -Message "Successfully Started ReDistribution of package $($PkgID) on $($FailedPackage.ServerNALPath)"
                        Write-Output -InputObject "Started ReDistribution of $($PkgID) on $($FailedPackage.ServerNALPath)"
                    }else{
                        Write-Error -Message "Unable to locate package $($PkgID) on $($FailedPackage.ServerNALPath)!"
                    }#If Else
                }# ForEach
            }# Try
            catch{
                $errormsg = $Error[0].ToString()
                Write-Error -Message "Unable to start ReDistribution of package $($PkgID) on $($FailedPackage.ServerNALPath)! $($errormsg)"
            }# Catch
        }else{
            Write-Output -InputObject "There are 0 instances of failed content distributions at the moment."
        }#If Else
    }# Process
}# Function
ReDistribute-Package @PSBOundParameters

