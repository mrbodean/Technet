<# 
.SYNOPSIS 
Report on Distribution Points and the Rate Limits settings
.DESCRIPTION 
Report on Distribution Points and the Rate Limits settings. This will give you the equivilent infomation the is on the Rate Limits Tab of the Distribution point Properties in the Console.
The report will display on the screen and\or exported to a csv file. 
.PARAMETER -SiteServer 
Server name of the Primary Site. Required
.PARAMETER -SiteCode 
Site Code of the Primary Site used in the -SiteServer parameter. Required
.PARAMETER -Logfile 
Used to specify the path to create a csv version of the report. Optional
The Log file will be named SiteServer_DPRateLimits_MMDDYYFHHMMSS.csv
.EXAMPLE
powershell -file Publish-DPRateLimits -SiteServer DSCCMXX01 -SiteCode LAB
Report on Distribution Points Rate Limit Status to the screen
.EXAMPLE
powershell -file Publish-DPRateLimits -SiteServer DSCCMXX01 -SiteCode LAB -Logfile c:\logs
Report on Distribution Points Rate Limit Status to the screen
.Notes
	Author: Jon Warnken jon.warnken@gmail.com
	Revisions:
		1.0 06/23/2014 - Original creation. 

#> 
[CmdletBinding()]

param (
[Parameter(Mandatory=$true,Position=1)]
[string]$SiteServer,
[Parameter(Mandatory=$true,Position=2)]
[string]$SiteCode,
[Parameter(Mandatory=$false,Position=3)]
[string]$Logfile
) 
$Global:OuttoFile=$false
function Write-Display{
[CmdletBinding()]

	param (
	[Parameter(Mandatory=$true,Position=1)]
	[string]$MSG,
	[Parameter(Mandatory=$false,Position=2)]
	[Boolean]$Export=$OuttoFile
	)
	Write-Output $MSG
	if($Export){ $MSG| out-file -FilePath $logfile -Append }
}


If($Logfile){
	If(!(Test-Path $logfile)){Throw "Unable to access $logfile "}
	$logname = $SiteServer + "_DPRateLimits_" + (Get-Date -Format "MMddyyhhmmss") + ".csv"
	$Logfile = Join-Path -Path $Logfile -ChildPath $logname
	[Boolean]$Global:OuttoFile=$true
}
$dpStatus = gwmi -Computername $siteserver -namespace "root\sms\site_$sitecode" -query "select * from SMS_SCI_address where AddressType = 'MS_LAN'" 

Write-Display "DP_Name,RateLimitEnabled,RateLimitMode,RateLimitSettings"
foreach($dp in $dpStatus){
	#Get the Lazy Properties
	$dp.get()
	$RLSchedule = "None"
	$mode = "UnLimited"
	If($dp.UnlimitedRateForAll -eq $false){
		If($dp.PropLists.Values[0] -eq 1){
			$mode ="Pulse"
			$RLSchedule = "DataBlock:$($dp.PropLists.Values[1]) Delay:$($dp.PropLists.Values[2])"
		}else{
			$mode ="Throttled"
			$RLSchedule = ""
			$i = 0
			foreach($hour in $dp.RateLimitingSchedule){
				$i = $i + 1
				$RLSchedule = $RLSchedule + "$i`-$($hour.tostring())% "
			}
		}
	}
	Write-Display -msg ($dp.DesSiteCode + "," + $dp.UnlimitedRateForAll + ",$mode,$RLSchedule")
	Remove-Variable mode
	Remove-Variable RLSchedule
}