$Domain = 'YourDomainName'
$users = Get-ChildItem -Path c:\users -Exclude 'Administrator','Public'
$Compliant = $true
foreach($user in $users){
    if(get-appxpackage -Name "Microsoft.AAD.BrokerPlugin" -User "$Domain\$($user.Name)"){
        #No Issue found
    }else{
        #Issue found
        $Compliant = $false
    }
}
if($Compliant){
    exit 0
}else{
    exit 1
}