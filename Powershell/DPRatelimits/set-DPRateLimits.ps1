function Set-DPRateLimits
{ 
<# 
.SYNOPSIS 
Enable or Diable Rate Limits for SCCM Distribution point. 
.DESCRIPTION 
Enable or Diable Rate Limits for SCCM Distribution point. This is set on the Rate Limits Tab of the Distribution point Properties
in the Console. The equivilent action in the gui to enable is to click the "Limited to specified maximun transfer rated by hour:" 
radio button and to set the Limiting Schedule. The equivilent action in the gui to disable is to click the 
"Unlimited when sending to this destination" radio button.
Please note that in the GUI Pulse mode is configured on same tab. This script does not configure Pulse mode.
.PARAMETER -SiteServer 
Server name of the Primary Site. Required
.PARAMETER -SiteCode 
Site Code of the Primary Site used in the -SiteServer parameter. Required
.PARAMETER -DPFQDN 
Fully Qualified Domain Name of the Distribution Point. Required
.PARAMETER -Enable 
Used to specify is the Rate limit should be enabled or disabled. Only accepts $true or $false
This is an optional parameter. By default it will be enabled. To 
.EXAMPLE
Set-DPRateLimits -SiteServer DSCCMXX01 -SiteCode LAB -DPFQDN SeverName.ad.contoso.com -Enable $true
This will enable rate limits 
.EXAMPLE
Set-DPRateLimits -SiteServer DSCCMXX01 -SiteCode LAB -DPFQDN SeverName.ad.contoso.com -Enable $false
This will disable rate limits
.Notes
	Author: Jon Warnken jon.warnken@gmail.com
	Revisions:
		1.0 06/20/2014 - Original creation. SPecial thanks to Keith Thornley for sending me the orginal function
		1.1 06/23/2014 - Added comment-based help 

#> 
[CmdletBinding()]

param (
[Parameter(Mandatory=$true,Position=1)]
[string]$SiteServer,
[Parameter(Mandatory=$true,Position=2)]
[string]$SiteCode,
[Parameter(Mandatory=$true,Position=3)]
[string]$DPFQDN,
[Parameter(Mandatory=$false,Position=4)]
[Boolean]$Enable=$True
) 

	$DPFQDN = $DPFQDN + "|MS_LAN"
    $dp = gwmi -Computername $siteserver -namespace "root\sms\site_$sitecode" -query "select * from SMS_SCI_address where itemname = '$DPFQDN' " 
    #Define a percentage, in an array with 1 value per hour starting at midnight
	#the rate limit below is 50% 4am - 11pm and 90% all other times
    $RateLimitingSchedule = @(90,90,90,90,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,90)
	if($enable){
    	$dp.UnlimitedRateForAll = 0 
    	$dp.RateLimitingSchedule = $RateLimitingSchedule 
	}else{
		$dp.UnlimitedRateForAll = 1
	}
    $dp.Put() 
} 