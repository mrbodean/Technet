﻿
<#PSScriptInfo

.VERSION 1.0.0

.GUID 6ea91253-7c75-403c-8bc9-f627451aad7e

.AUTHOR Jonathan Warnken - @MrBodean - http://mrbodean.azurewebsites.net/

.COMPANYNAME 

.COPYRIGHT (C) Jonathan Warnken. All rights reserved.

.TAGS SCCM

.LICENSEURI https://github.com/mrbodean/Technet/blob/master/Powershell/ReDistribute-Package/License

.PROJECTURI https://github.com/mrbodean/Technet/blob/master/Powershell/ReDistribute-Package

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Initial Release

#>

<# 
.Synopsis
   Redistrubute a Configuration Manager package to a distribution point
.DESCRIPTION 
 Script to ReDistribute Configuration Manager Package by Package Id to Targeted Distribution Points 
.EXAMPLE
   ReDistribute-Package -SiteCode LAB -SiteServer LabServer -PkgID LAB00005 -DP LabDP1.lab.int
.EXAMPLE
   "LabDP1.lab.int","LabDP2.lab.int"|ReDistribute-Package -SiteCode LAB -SiteServer LabServer -PkgID LAB00005
#> 
Param(
    # Configuration Manager Site Code
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$SiteCode,
    # Configuration Manager Site Server
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$SiteServer,
    # Configuration Manager PackageID
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$PkgID,
    # Configuration Manager Distribution Point
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string[]]$DP
)

<#
.Synopsis
   Redistrubute a Configuration Manager package to a distribution point
.EXAMPLE
   ReDistribute-Package -SiteCode LAB -SiteServer LabServer -PkgID LAB00005 -DP LabDP1.lab.int
.EXAMPLE
   "LabDP1.lab.int","LabDP2.lab.int"|ReDistribute-Package -SiteCode LAB -SiteServer LabServer -PkgID LAB00005
#>
function ReDistribute-Package
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
        [string]$SiteServer,
        # Configuration Manager PackageID
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$PkgID,
        # Configuration Manager Distribution Point
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$DP
    )
    Process{
        Foreach($target in $DP){
            try{
                Write-Verbose -Message "Attempting to ReDistribute PackageID $($PkgID) on $($target)"
                $DistributionPoint = Get-WmiObject -Namespace "root\SMS\Site_$SiteCode" -Class SMS_DistributionPoint -Filter "PackageID='$($PkgId)' and ServerNALPath like '%$($target)%'"  -ComputerName $SiteServer
                If($DistributionPoint){
                    Write-Verbose -Message "Located package $($PkgID) on $($target)"
                    $DistributionPoint.RefreshNow = $True
                    $DistributionPoint.Put()|Out-Null
                    Write-Verbose -Message "Successfully ReDistributed package $($PkgID) on $($target)"
                    Write-Output -InputObject "ReDistributed $($PkgID) on $($target)"
                }else{
                    Write-Error -Message "Unable to locate package $($PkgID) on $($target)!"
                }#If Else
            }# Try
            catch{
                $errormsg = $Error[0].ToString()
                Write-Error -Message "Unable to refresh package $($PkgID) on $($target)! $($errormsg)"
            }# Catch
        }# Foreach

    }# Process
}# Function
ReDistribute-Package @PSBOundParameters
