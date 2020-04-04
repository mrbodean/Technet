<#PSScriptInfo
.Description
    Updates a DNS record for a Azure VM if the record does not match the current public ip.     This script works across multiple subscriptions and when properly delegated via Azure Lighthouse across tenants.
.VERSION 
    1.0.0
.GUID 
    cbb81bef-e9d2-47ce-8059-e97943454e89
.AUTHOR 
    Jonathan Warnken - @MrBodean - http://www.mrbodean.net/
.COMPANYNAME 

.COPYRIGHT 
    (C) Jonathan Warnken 2020 All rights reserved.
.TAGS 
    Azure, Runbook, Automation, DNS
.LICENSEURI
    https://github.com/mrbodean/Technet/blob/master/Powershell/Update-AzDNSRecordMultiSub/License
.PROJECTURI 
    https://github.com/mrbodean/Technet/tree/master/Powershell/Update-AzDNSRecordMultiSub
.ICONURI 

.EXTERNALMODULEDEPENDENCIES 
    Az
.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
    Initial Release

#>

Param(
    # Automation Run As Account
    [Parameter(Mandatory=$true)]
    [String]$RunAsAccount = "AzureRunAsConnection",
    # SubscriptionId that contains the VM
    [Parameter(Mandatory=$true)]
    [String]$SubscriptionId1,
    # SubscriptionId that contains the DNS zone
    [Parameter(Mandatory=$true)]
    [String]$SubscriptionId2,
    # Resource group name that contains the VM
    [Parameter(Mandatory=$true)]
    [String]$vmresourcegroup,
    # Public Ip address name for the VM
    [Parameter(Mandatory=$true)]
    [String]$vmipname,
    [Parameter(Mandatory=$true)]
    # Public DNS record to resolve - i.e. MyApp.contoso.com
    [String]$DNSrecord,
    [Parameter(Mandatory=$true)]
    # DNS Zone name - i.e. contoso.com
    [String]$DNSzone,
    [Parameter(Mandatory=$true)]
    # Resource group name that contains the DNS Zone
    [String]$DNSresourcegroup,
    # DNS zone record name - i.e. MyApp
    [Parameter(Mandatory=$true)]
    [String]$DNSrecordName
)

$connectionName = $RunAsAccount
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
Connect-AzAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | out-null

Write-Output "Connecting to subscription:  $SubscriptionId1"
Select-AzSubscription -SubscriptionId $SubscriptionId1 | out-null

$VMIP = (Get-AzPublicIpAddress -ResourceGroupName $vmresourcegroup -Name $vmipname).IpAddress
Write-Output "VM Public Ip is $VMIP"
$DynDNS = $DNSrecord
#Get IP based on the Domain Name
[string]$MyDynamicIP = ([System.Net.DNS]::GetHostAddresses($DynDNS)).IPAddressToString
Write-Output "$DynDNS resolves to $MyDynamicIP"
If($VMIP -ne $MyDynamicIP){
    Write-Output "Connecting to subscription:  $SubscriptionId2"
    Select-AzSubscription -SubscriptionId $SubscriptionId2 | out-null
    $zone = Get-AzDnsZone -Name $DNSzone -ResourceGroupName $DNSresourcegroup
    $dnsrs = Get-AzDnsRecordSet -Zone $zone -Name $DNSrecordName -RecordType A
    $DNSIP = (Get-AzDnsRecordSet -Zone $zone -Name $DNSrecordName -RecordType A).Records.Ipv4Address
    Remove-AzDnsRecordConfig -RecordSet $dnsrs -Ipv4Address $DNSIP
    Add-AzDnsRecordConfig -RecordSet $dnsrs -Ipv4Address $VMIP
    Set-AzDnsRecordSet -RecordSet $dnsrs
}
