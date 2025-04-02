$Compliant = $true
if((Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade\Rollback -Name Count).Count -ge 2){
    #More than 2 rollback failures, 2 rollbacks cause a 30 day pause and 5+ blocks automatic attempts and requires manual intervention
    $Compliant = $false
}else{
    #No feature update rollback failures, or less than 2 rollbacks
    #This is compliant
}
if($Compliant){
    exit 0
}else{
    exit 1
}