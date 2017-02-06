<#PSScriptInfo

.VERSION 1.0.0

.GUID 56dfd8ea-5998-4524-9264-edfa65b4cc96

.AUTHOR Jonathan Warnken - @MrBodean - http://www.mrbodean.net/

.COMPANYNAME 

.COPYRIGHT (C) Jonathan Warnken 2017 All rights reserved.

.TAGS SCCM, ConfigMan, Configuration Manager, Client 

.LICENSEURI https://github.com/mrbodean/Technet/blob/master/Powershell/Set-CMClientLogOptions/License

.PROJECTURI https://github.com/mrbodean/Technet/tree/master/Powershell/Set-CMClientLogOptions

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Initial Release

#>

<#
.Synopsis
   Set the Log Level for the Configuration Manager Client 
.EXAMPLE
   Set-CMClientLogLevel -LogLevel Normal -Computername SomeComputer1
.EXAMPLE
   $parms @{
    LogLevel = "Debug"
    LogMaxHistory = 3
    LogMaxSize = 500000
    ComputerName = "SomeComputer1", "SomeComputer2","SomeComputer3"
   }
   Set-CMClientLogLevel @parms
.NOTES
    Author
        Jon Warnken
        @MrBoDean
        jon.warnken@gmail.com
#>
param(
    # Level of Logging to set 
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet("Debug","Normal","Off")]
    [string]$LogLevel,
    # Computer name(s) to set the logging on 
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true)]
    [String[]]$Computername,
    # Number of log files to keep
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [int]$LogMaxHistory,
    # Max size of log file
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [int]$LogMaxSize
)

<#
.Synopsis
   Set the Log Level for the Configuration Manager Client 
.EXAMPLE
   Set-CMClientLogLevel -LogLevel Normal -Computername SomeComputer1
.EXAMPLE
   $parms @{
    LogLevel = "Debug"
    LogMaxHistory = 3
    LogMaxSize = 500000
    ComputerName = "SomeComputer1", "SomeComputer2","SomeComputer3"
   }
   Set-CMClientLogLevel @parms
#>
function Set-CMClientLogOptions
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Level of Logging to set. Must be Debug, Normal, or Off
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("Debug","Normal","Off")]
        [string]$LogLevel,
        # Computer name(s) to set the logging on 
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$Computername,
        # Number of log files to keep
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$LogMaxHistory,
        # Max size of log file
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$LogMaxSize
    )

    Begin{
        Switch($Loglevel){
            "Debug"{$logging = 0}
            "Normal"{$logging = 1}
            "Off"{$logging = 2}
        }
        $action =  {
            $loglevelvalue = $args[0]
            $maxhistoryvalue = $args[1]
            $maxsizevalue = $args[2]
            $regpath = "Registry::HKLM\SOFTWARE\Microsoft\CCM\Logging\@GLOBAL"
            $DebugLoggingPath = "Registry::HKLM\SOFTWARE\Microsoft\CCM\Logging\DebugLogging"
            $loglevelname = "LogLevel"
            $maxhistname = "LogMaxHistory"
            $maxsizename = "LogMaxSize"
            $update = $false
            $CurentloglevelValue = Get-ItemPropertyValue -Path $regpath -Name $loglevelname
            $CurrentmaxhistValue = Get-ItemPropertyValue -Path $regpath -Name $maxhistname
            $CurrentmaxsizeValue = Get-ItemPropertyValue -Path $regpath -Name $maxsizename
            If(loglevelvalue){
                if($CurentloglevelValue -eq $loglevelvalue){
                    Write-Output "Current Log Level matched requested value. No action taken."
                }else{
                    Set-ItemProperty -Path $regpath -name $loglevelname -value $loglevelvalue
                    Write-Output "Successfully set the Log Level"
                    $update = $true
                }
                Switch($loglevelvalue){
                    0{
                        if(Get-Item $DebugLoggingPath -ErrorAction SilentlyContinue){
                            Write-Output "DebugLogging Key found. No action taken."
                        }else{
                            New-Item -Path $DebugLoggingPath
                        }
                    }
                    Default{
                        if(Get-Item $DebugLoggingPath -ErrorAction SilentlyContinue){
                            Remove-Item -Path $DebugLoggingPath -Force 
                        }else{
                            Write-Output "DebugLogging Key Not found. No action taken."
                        }
                    }
                }
            }          
            if($maxhistoryvalue){
                if($CurrentmaxhistValue -eq $maxhistoryvalue){
                     Write-Output "Current Log Max matched requested value. No action taken."
                }else{
                    Set-ItemProperty -Path $regpath -name $maxhistname -value $maxhistoryvalue
                    Write-Output "Successfully set the Log Max"
                    $update = $true
                }
            }
            if($maxsizevalue){
                if($CurrentmaxsizeValue -eq $maxsizevalue){
                     Write-Output "Current Log Max matched requested value. No action taken."
                }else{
                    Set-ItemProperty -Path $regpath -name $maxsizename -value $maxsizevalue
                    Write-Output "Successfully set the Log Max Size"
                    $update = $true
                }
            }
            if($update){
                Write-Output "Update were made to the client config. The ccmexec service will be recycled to use the updates."
                Stop-Service -Name CcmExec -Force
                Start-Service -Name CcmExec
            }
        }
    }
    Process{
        Foreach($computer in $Computername){
            Invoke-Command -ComputerName $computer -ScriptBlock $action -ArgumentList $logging,$LogMaxHistory,$LogMaxSize
        }
    }
}
Set-CMClientLogOptions @PSBoundParameters
