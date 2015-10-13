<#
.Synopsis
   Given a task sequence package id the referenced packages are looked up and the Source path displayed
.EXAMPLE
   Get-TSPkgSource -PackageId DEV005A4 -SiteCode DEV
   Displays the Packages and Source Path information for Task Sequence DEV005A4 on Site DEV
.EXAMPLE
   DEV005A4|Get-TSPkgSource -SiteCode DEV
   Displays the Packages and Source Path information for Task Sequence DEV005A4 on Site DEV
   by passing the task sequence package id via the pipeline
.Note
    Author
        Jon Warnken
        jon.warnken@gmail.com
        @MrBoDean
#>
function Get-TSPkgSource
{
    [CmdletBinding()]
    #Requires -Version 3.0
    #Requires -Modules ConfigurationManager
    Param(
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$PackageId,
        [Parameter(Mandatory=$true)]
        [String]$SiteCode
    )#Param
 
    Begin
    {
        If((Get-Location).Drive.Name -ne $SiteCode){
            Try{Set-Location -path "($SiteCode):" -ErrorAction Stop}
            Catch{Throw "Unable to connect to Site $SiteCode. Ensure that the Site Code is correct and that you have access."}
        }#If
    }#Begin
    Process
    {
        ForEach($tspkgid in $PackageId){
            $tasksequence = Get-CMTaskSequence -TaskSequencePackageId $tspkgid
            If($tasksequence){
                $tasksequence|select-object -ExpandProperty References|Select-Object -ExpandProperty Package -Unique|
                ForEach-Object{ $t = Get-CMPackage -Id $_ |select-object Name,PackageID,PkgSourcePath,SourceDate
                     if(!($t)){Get-CMDriverPackage -Id $_ |select-object Name,PackageID,PkgSourcePath,SourceDate}
                     if(!($t)){Get-CMBootImage -Id $_ |select-object Name,PackageID,PkgSourcePath,SourceDate}
                     if(!($t)){Get-CMOperatingSystemImage -Id $_ |select-object Name,PackageID,PkgSourcePath,SourceDate}
                     if(!($t)){Get-CMSoftwareUpdateDeploymentPackage -Id $_ |select-object Name,PackageID,PkgSourcePath,SourceDate}
                     $t
                     Remove-Variable -Name t
                  }#Pipeline ForEach
            }Else{
                Write-Error "$tspkgid is invalid or not a Task Sequence"
            }#Else If
        }#ForEach
    }#Process
    End{}
}