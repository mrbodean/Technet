<#PSScriptInfo
.DESCRIPTION 
   Reset the Windows Update Agent based on https://support.microsoft.com/en-us/help/971058/how-do-i-reset-windows-update-components
.VERSION 1.0.0

.GUID 24082413-1b04-49f3-aeb2-c697730147d4

.AUTHOR Jonathan Warnken - @MrBodean - http://mrbodean.net

.COMPANYNAME 

.COPYRIGHT (C) Jonathan Warnken. All rights reserved.

.TAGS SCCM, ConigMgr, WUA, Windows Update Agent

.LICENSEURI https://github.com/mrbodean/Technet/blob/master/Powershell/Reset-WUAgent/License

.PROJECTURI https://github.com/mrbodean/Technet/blob/master/Powershell/Reset-WUAgent

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Initial Release

#>

<# 
.Synopsis
   Reset the Windows Update Agent
.DESCRIPTION 
   Reset the Windows Update Agent based on https://support.microsoft.com/en-us/help/971058/how-do-i-reset-windows-update-components
.EXAMPLE
   
.EXAMPLE
   "Lab1.lab.int","LabDP2.lab.int"|ReDistribute-Package -SiteCode LAB -SiteServer LabServer -PkgID LAB00005
#> 
param(
    # Computer name(s) to reset the Windows Update Agent on
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true)]
    [String[]]$Computername,
    # Reboot the system after the reset. Defaults to $false
    [Parameter(Mandatory=$false)][bool]$reboot=$false
)
function Reset-WUAgent {
    [CmdletBinding()]
    Param
    (

    )
    Begin {
        $resetwua = {
            #stop services
            stop-service bits -Force
            stop-service wuauserv -Force
            if(get-service AppIDSvcc -ErrorAction SilentlyContinue){stop-service AppIDSvcc -Force}
            Stop-Service CryptSvc -Force
            #delete qmgr*.dat files
            $qpath = Get-ChildItem -Path "$($env:ALLUSERSPROFILE)\Application Data\Microsoft\Network\Downloader" -Filter "qmgr*.dat"
            foreach($q in $qpath){$q|Remove-Item -Force -ErrorAction SilentlyContinue }
            Remove-Variable qpath
            $qpath = Get-ChildItem -Path "$($env:ALLUSERSPROFILE)\Microsoft\Network\Downloader" -Filter "qmgr*.dat"
            foreach($q in $qpath){$q|Remove-Item -Force -ErrorAction SilentlyContinue }
            Remove-Variable qpath
            #rename local wua store
            if(test-path "$($env:windir)\SoftwareDistribution.bak"){Remove-Item -Path "$($env:windir)\SoftwareDistribution.bak"}
            Move-Item -Path "$($env:windir)\SoftwareDistribution" -Destination "$($env:windir)\SoftwareDistribution.bak"
            #rename system catalog database
            if(test-path "$($env:windir)\system32\catroot2.bak"){Remove-Item -Path "$($env:windir)\system32\catroot2.bak"}
            Move-Item -Path "$($env:windir)\system32\catroot2" -Destination "$($env:windir)\system32\catroot2.bak"
            #reset service permissions to defaults
            sc.exe sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
            sc.exe sdset wuauserv "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"

            #register dlls
            regsvr32.exe /s "$($env:windir)\System32\atl.dll" 
            regsvr32.exe /s "$($env:windir)\System32\urlmon.dll"
            regsvr32.exe /s "$($env:windir)\System32\mshtml.dll"
            regsvr32.exe /s "$($env:windir)\System32\shdocvw.dll" 
            regsvr32.exe /s "$($env:windir)\System32\browseui.dll" 
            regsvr32.exe /s "$($env:windir)\System32\jscript.dll"
            regsvr32.exe /s "$($env:windir)\System32\vbscript.dll" 
            regsvr32.exe /s "$($env:windir)\System32\scrrun.dll"
            regsvr32.exe /s "$($env:windir)\System32\msxml.dll"
            regsvr32.exe /s "$($env:windir)\System32\msxml3.dll" 
            regsvr32.exe /s "$($env:windir)\System32\msxml6.dll"
            regsvr32.exe /s "$($env:windir)\System32\actxprxy.dll" 
            regsvr32.exe /s "$($env:windir)\System32\softpub.dll"
            regsvr32.exe /s "$($env:windir)\System32\wintrust.dll" 
            regsvr32.exe /s "$($env:windir)\System32\dssenh.dll"
            regsvr32.exe /s "$($env:windir)\System32\rsaenh.dll"
            regsvr32.exe /s "$($env:windir)\System32\gpkcsp.dll"
            regsvr32.exe /s "$($env:windir)\System32\sccbase.dll" 
            regsvr32.exe /s "$($env:windir)\System32\slbcsp.dll" 
            regsvr32.exe /s "$($env:windir)\System32\cryptdlg.dll"
            regsvr32.exe /s "$($env:windir)\System32\oleaut32.dll" 
            regsvr32.exe /s "$($env:windir)\System32\ole32.dll"
            regsvr32.exe /s "$($env:windir)\System32\shell32.dll"
            regsvr32.exe /s "$($env:windir)\System32\initpki.dll" 
            regsvr32.exe /s "$($env:windir)\System32\wuapi.dll"
            regsvr32.exe /s "$($env:windir)\System32\wuaueng.dll"
            regsvr32.exe /s "$($env:windir)\System32\wuaueng1.dll" 
            regsvr32.exe /s "$($env:windir)\System32\wucltui.dll" 
            regsvr32.exe /s "$($env:windir)\System32\wups.dll"
            regsvr32.exe /s "$($env:windir)\System32\wups2.dll"
            regsvr32.exe /s "$($env:windir)\System32\wuweb.dll" 
            regsvr32.exe /s "$($env:windir)\System32\qmgr.dll"
            regsvr32.exe /s "$($env:windir)\System32\qmgrprxy.dll" 
            regsvr32.exe /s "$($env:windir)\System32\wucltux.dll" 
            regsvr32.exe /s "$($env:windir)\System32\muweb.dll"
            regsvr32.exe /s "$($env:windir)\System32\wuwebv.dll"
            #reset winsock
            netsh winsock reset
            #reset proxy (Winxp use proxycfg.exe -d)
            netsh winhttp reset proxy

            #start services
            start-service bits
            start-service wuauserv
            if(get-service AppIDSvcc -ErrorAction SilentlyContinue){start-service AppIDSvcc}
            start-Service CryptSvc
        }#Script Block resetwua
    }#Begin
    Process{
        Foreach($computer in $Computername){
            $i = $i+1
            Write-progress -Activity "Creating Job to reset the windows update agent for: $Computer" -percentcomplete ($i/$Computername.count*100)
            Invoke-Command -ComputerName $computer -ScriptBlock $resetwua -AsJob -JobName "ResetWUA-$computer"
        }
        Do{
            Clear-Host 
            Write-host ""
            Write-host ""
            Write-host ""
            Write-progress -Activity "Waiting for all windows update agent reset jobs to complete" -percentcomplete ((get-job -State Running).count/(get-job -Name "ResetWUA-*").count*100)
            get-job -State Running
            Start-Sleep -Seconds 20

        }while(get-job -State Running)
        If($reboot){
            Foreach($computer in $Computername){
                Invoke-Command -ScriptBlock {shutdown -r -f} -ComputerName $computer
            }
        }
        
    }#Process
    End{
        get-job|remove-job
    }#End
}#Function


Reset-WUAgent @PSBOundParameters