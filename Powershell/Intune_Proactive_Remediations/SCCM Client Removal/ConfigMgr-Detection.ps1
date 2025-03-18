$Compliant = $true
if(get-service -Name ccmexec -ErrorAction SilentlyContinue){
    #Configuration Manager agent installed
    $Compliant = $false
}else{
    #No Configuration Manager agent
}
if($Compliant){
    exit 0
}else{
    exit 1
}