<# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
 THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING 
 BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
 We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce # 
 and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market
Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code
is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees,
that arise or result from the # use or distribution of the Sample Code.
#>

# Requirements Windows 10 22H2 and KB5046613 (19045.5131) https://learn.microsoft.com/en-us/windows/whats-new/enable-extended-security-updates#prerequisites
$OSCurrentersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
[byte]$CanApplyWin10ESU = 0
$Win1022H2 = "19045"
$ReqPatch = "5131"
function Test-Network {
    [CmdletBinding()]
     Param
    ([Parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)]
                [Alias('endpoint', 'uri')]
                [string[]]$ComputerName,
    [Parameter(Mandatory=$true)]
    [int]$Port
    )
    Begin{
        $endpointcheck = $false
    }
    Process{
        Foreach($pc in $ComputerName) {
            Try {
                $tcpconnection = Test-NetConnection -ComputerName $pc -Port $Port -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -InformationLevel Quiet
                if ($tcpconnection) {
                    Write-Verbose "TCP connection to $pc on port $Port succeeded."
                    $endpointcheck = $true
                } else {
                    Write-Verbose "TCP connection to $pc on port $Port failed."
                    $endpointcheck = $false
                }
            } Catch {
                Write-Verbose "Error testing TCP connection to $pc on port $($Port): $_"
                $endpointcheck = $false
            }
        }
    }
    End{
        if ($endpointcheck) {
            Write-Output "All endpoints are reachable."
            return 0x4 # All endpoints are reachable
        } else {
            Write-Output "One or more endpoints are not reachable."
        }
    }
}
#prerequisites
$OSVersion = $OSCurrentersion.CurrentBuild
if ($OSVersion -eq $Win1022H2) {
    Write-Output "This system is running Windows 10 22H2 (19045). Current version: $OSVersion"
    [byte]$CanApplyWin10ESU = $CanApplyWin10ESU -bor 0x1
    if (($OSCurrentersion.CurrentBuildRevision -ge $ReqPatch) -or ($OSCurrentersion.UBR -ge $ReqPatch)) {
    Write-Output "This system has the required patch KB5046613 (19045.5131) installed."
    [byte]$CanApplyWin10ESU = $CanApplyWin10ESU -bor 0x2
    }
}
#end prerequisites

#endpoints
$sslendpoints = @(
    "go.microsoft.com",
    "login.live.com",
    "activation.sls.microsoft.com",
    "validation.sls.microsoft.com",
    "activation-v2.sls.microsoft.com",
    "validation-v2.sls.microsoft.com",
    "displaycatalog.mp.microsoft.com",
    "licensing.mp.microsoft.com",
    "purchase.mp.microsoft.com",
    "displaycatalog.md.mp.microsoft.com",
    "licensing.md.mp.microsoft.com",
    "purchase.md.mp.microsoft.com"
)
$httpendpoints = @(
    "crl.microsoft.com"
)
$netcheck1 = $sslendpoints | Test-Network -Port 443 -Verbose
$netcheck2 = $httpendpoints | Test-Network -Port 80 -Verbose
    if ($netcheck1 -eq 0x4 -and $netcheck2 -eq 0x4) {
        Write-Output "All required endpoints are reachable."
        [byte]$CanApplyWin10ESU = $CanApplyWin10ESU -bor 0x4
    }else {
        Write-Output "One or more required endpoints are not reachable."
    }
#end endpoints
$binary = [Convert]::ToString($CanApplyWin10ESU, 2)
if($CanApplyWin10ESU -eq 0x7) {
    Write-Output "This system is eligible for Windows 10 Extended Security Updates (ESU)."
    Write-Output "CanApplyWin10ESU: $binary"
    #exit 0
} else {
    Write-Output "This system does not meet the prerequisites for Windows 10 Extended Security Updates (ESU)."
    Write-Output "CanApplyWin10ESU: $binary"
    #exit 1
}