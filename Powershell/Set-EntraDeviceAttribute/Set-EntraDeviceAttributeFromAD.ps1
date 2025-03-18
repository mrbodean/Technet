Import-Module ActiveDirectory
$ADComputers = Get-ADComputer -Filter *
if(!(Get-InstalledModule Microsoft.Graph -ErrorAction SilentlyContinue)){
    Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force
}
#Connect to MSGraph
Connect-MgGraph -Scopes Directory.ReadWrite.All, Device.Read.All, Directory.AccessAsUser.All -NoWelcome
Foreach($Comp in $ADComputers){
    If($Comp.objectGUID){
        $device = get-mgdevice -Filter "DeviceID eq '$($Comp.objectGUID)'"
        if($device.ID){
            Write-Output "Checking $($Device.DisplayName)"
            $Attrib15 = $device.AdditionalProperties.extensionAttributes.extensionAttribute15
            If($Comp.DistinguishedName -like '*OU=Servers,DC=demo,DC=contoso,DC=com'){$CAT = "|Server"}
            Elseif($Comp.DistinguishedName -like '*OU=App Servers,DC=demo,DC=contoso,DC=com'){$CAT = "|Server"}
            Else{$CAT = "|Workstation"}
            if(!($Attrib15 -eq "demo.contoso.com$($CAT)")){
                $Attributes = @{
                  "extensionAttributes" = @{
                    "extensionAttribute15" = "demo.contoso.com$($CAT)"
                    }
                 }  | ConvertTo-Json
                 Write-Output "Setting extensionAttribute15 on $($Device.DisplayName)"
                 Update-MgDevice -DeviceId $device.ID -BodyParameter $Attributes
            }
        }
        Start-Sleep -Milliseconds 500
    }
}
