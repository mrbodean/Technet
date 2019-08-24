<#
Disclaimer
    The sample scripts are not supported under any Microsoft standard support program or service.
    The sample scripts are provided AS IS without warranty of any kind.
    Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
    The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
    In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
#>

[CmdletBinding()]
    Param
    (
        # Path to CSV file used as Input
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true
        )]
        [ValidateScript({
            If(Test-path $_ ){ $true }
            else{
                throw "Unable to access $_ "
            }
        })]
        $InputCSV
    )
If(!(Get-Module -Name ActiveDirectory)){Import-Module ActiveDirectory}
$PermissionsList = Import-Csv -Path $InputCSV
$domain = Get-ADDomain
<#
.Synopsis
   Create a properly formated Active Directory Access Rule
#>
function Format-ADAccessRule{
    [CmdletBinding()]
    Param
    (
        # Object SID that the Access Rule will apply to
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true
        )]
        $SID,

        # ADRights to set
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true
        )]
        [string]
        $ADRights,

        # AccessControlType (Allow or Deny)
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true
        )]
        [ValidateSet('Allow','Deny')]
        [string]
        $AccessControlType, 
        
        # Inheritance flag
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true
        )]
        [ValidateScript({
            If([System.DirectoryServices.ActiveDirectorySecurityInheritance]::$_){$true}
            else{
                throw "$_ is not a valid Inheritance value. Valid Inheritance values are: $([System.DirectoryServices.ActiveDirectorySecurityInheritance].GetEnumValues())"
            }
        })]
        $Inheritance,
        
        # InheritanceType
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true
        )]
        [string]
        $InheritanceType,

        # ObjectType
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true
        )]
        [string]
        $ObjectType
    )

    Begin{
        #Input Validation
        $ADRights.Split(',')|ForEach-Object{
            If(!([system.DirectoryServices.ActiveDirectoryRights]::$_)){
                throw "$_ is not a valid Active Directory right. See this MSDN article for more information 'https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectoryrights.aspx' Valid rights are: $([system.DirectoryServices.ActiveDirectoryRights].GetEnumValues())"
            }
        }
        If(!(Get-Module -Name ActiveDirectory)){Import-Module ActiveDirectory}
        $currentlocation = Get-Location
        Set-Location ad:
        $rootdse = Get-ADRootDSE
        $guidmap = @{}
        Get-AdObject -SearchBase ($rootdse.schemaNamingContext) -LDAPFilter "(schemaidguid=*)" -Properties LDAPDisplayName, schemaIdGUID| ForEach-Object {$guidmap[$_.LDAPDisplayName]=[System.GUID]$_.schemaIdGUID}
        $extendedrightsmap = @{}
        Get-ADObject -SearchBase ($rootdse.configurationNamingContext) -LDAPFilter "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties displayname, rightsGuid| ForEach-Object{$extendedrightsmap[$_.displayname]=[System.GUID]$_.rightsGuid}
        If($ADRights -ieq 'ExtendedRight'){
            If(!($extendedrightsmap::$ObjectType)){
                throw "$ObjectType is not a vaild ExtendedRight. Vaild values are $($extendedrightsmap.keys)"
            }
        }else{
            If($ObjectType){
                If(!($guidmap::$ObjectType)){
                    throw "$ObjectType is not a vaild Object Type. Vaild values are $($guidmap.keys)"
                }
            }
        }
    }
    Process{
        If(!($ObjectType)){
            If($Inheritance){
                If($InheritanceType){
                    # Rule with no object type; Inheritance; Inheritance type
                    New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$Inheritance,$guidmap[$InheritanceType]
                }else{
                    # Rule with no object type; Inheritance but no Inheritance type
                    New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$Inheritance
                }
            }else{
                # Rule with no object type and no Inheritance
                New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType
            }
        }else{
            If($Inheritance){
                If($InheritanceType){
                    # Rule with object type; Inheritance; Inheritance type
                    If($ADRights -ieq 'ExtendedRight'){
                        New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$extendedrightsmap[$ObjectType],$Inheritance,$guidmap[$InheritanceType]
                    }else{
                        New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$guidmap[$ObjectType],$Inheritance,$guidmap[$InheritanceType]
                    }
                }else{
                    # Rule with object type; Inheritance but no Inheritance type
                    If($ADRights -ieq 'ExtendedRight'){
                        New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$extendedrightsmap[$ObjectType],$Inheritance
                    }else{
                        New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$guidmap[$ObjectType],$Inheritance
                    }
                }
            }else{
                # Rule with object type and no Inheritance
                If($ADRights -ieq 'ExtendedRight'){
                    New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$extendedrightsmap[$ObjectType]
                }else{
                    New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$ADRights,$AccessControlType,$guidmap[$ObjectType]
                }
            }
        }
    }
    End{
        Set-Location "$(($currentlocation).Drive):"
    }
}

ForEach($perm in $PermissionsList){
    If($ou){Remove-Variable ou}
    If($Delegate){Remove-Variable Delegate}
    If($DelegateType){Remove-Variable DelegateType}
    If($SID){Remove-Variable SID}
    If($ADRights){Remove-Variable ADRights}
    If($AccessControlType){Remove-Variable AccessControlType}
    If($Inheritance){Remove-Variable Inheritance}
    If($InheritanceType){Remove-Variable InheritanceType}
    If($ObjectType){Remove-Variable ObjectType}
    Try{
        $ou = Get-ADOrganizationalUnit -Identity $perm.OU
        $Delegate = $perm.delegate
        $DelegateType = $perm.'delegate type'
        switch ($DelegateType) {
            'user' { $SID = ((Get-ADUser "$Delegate").SID) }
            'group' { $SID = ((Get-ADGroup "$Delegate").SID) }
        }
        $ADRights = $perm.ADRights
        $AccessControlType = $perm.AccessControlType
        $Inheritance = $perm.Inheritance
        $InheritanceType = $perm.InheritanceType
        $ObjectType = $perm.ObjectType
        If($ObjectType -eq ''){Remove-Variable ObjectType}
        If($InheritanceType -eq ''){Remove-Variable InheritanceType}
        If($Inheritance -eq ''){Remove-Variable Inheritance}
        # Get the existing ACL
        try {
            $acl = Get-ACL -Path ("AD:/"+($ou.DistinguishedName))
        }
        catch {
            Write-Error -Message "Unable to access the Access Control List for $($ou.DistinguishedName)"
        }
        # Process Access controls
        If($AccessControlType -ieq 'Remove'){
            $objecttoRemove = "$($domain.netbiosname)"+"\$Delegate"
            $Result = $acl.Access|Where-Object{$_.IdentityReference -eq $objecttoRemove}|ForEach-Object{$acl.RemoveAccessRule($_)}
            If($Result){
                Write-Host "Found $objecttoRemove in the existing ACL. It will be removed" -ForegroundColor Green
            }else{
                Write-Host "Did not find $objecttoRemove in the existing ACL for $($ou.DistinguishedName)" -ForegroundColor Yellow
            }
        }else{
            If($ObjectType){
                #Rule with ObjectType
                If($Inheritance){
                    # Rule with Inheritance
                    If($InheritanceType){
                        #Rule with InheritanceType
                        $acl.AddAccessRule((Format-ADAccessRule -SID $SID -ADRights $ADRights -AccessControlType $AccessControlType -ObjectType $ObjectType -Inheritance $Inheritance -InheritanceType $InheritanceType))
                    }Else{
                        #Rule without InheritanceType
                        $acl.AddAccessRule((Format-ADAccessRule -SID $SID -ADRights $ADRights -AccessControlType $AccessControlType -ObjectType $ObjectType -Inheritance $Inheritance))
                    }
                }Else{
                    # Rule without Inheritance
                    $acl.AddAccessRule((Format-ADAccessRule -SID $SID -ADRights $ADRights -AccessControlType $AccessControlType -ObjectType $ObjectType))
                }
            }Else{
                #Rule with no ObjectType
                If($Inheritance){
                    # Rule with Inheritance
                    If($InheritanceType){
                        #Rule with InheritanceType
                        $acl.AddAccessRule((Format-ADAccessRule -SID $SID -ADRights $ADRights -AccessControlType $AccessControlType -Inheritance $Inheritance -InheritanceType $InheritanceType))
                    }Else{
                        #Rule without InheritanceType
                        $acl.AddAccessRule((Format-ADAccessRule -SID $SID -ADRights $ADRights -AccessControlType $AccessControlType -Inheritance $Inheritance))
                    }
                }Else{
                    # Rule without Inheritance
                    $acl.AddAccessRule((Format-ADAccessRule -SID $SID -ADRights $ADRights -AccessControlType $AccessControlType))
                }
            }
        }
        Set-Acl -AclObject $acl -Path ("AD:\"+($ou.DistinguishedName))
    }Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Host $_.CategoryInfo -ForegroundColor Red
    }
}
