<#
Disclaimer
    The sample scripts are not supported under any Microsoft standard support program or service.
    The sample scripts are provided AS IS without warranty of any kind.
    Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
    The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
    In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
#>
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