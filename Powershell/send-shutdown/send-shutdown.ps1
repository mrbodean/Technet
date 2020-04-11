function Send-shutdown {
<#
.SYNOPSIS
Send shutdown, logoff, and reboot commands to remote windows systems

.DESCRIPTION
Uses wmi to send shutdown, logoff, and reboot commands to remote windows systems. 
This generaly requires administatrative rights on the remote system.  


.PARAMETER Computername
Computername or Ip address of the remote system. This can be pased via the pipeline.
This is a required parameter

.PARAMETER ShutdownType
Must be one of the Following "Logoff","Shutdown","Restart","Poweroff"
This is a required parameter
	
.PARAMETER Force
Use to specify if the Shutdown should be forced. Default value is $false
This is boolean and should be specified as -Force $true or -Force $false

.INPUTS
String -Computername
String -ShutdownType ("Logoff","Shutdown","Restart","Poweroff")
Boolean -Force

.OUTPUTS
PSObject Hashtable of the Computer name and the return value from wmi or the Exception message

.EXAMPLE
Send-shutdown -Computername Test-pc1 -ShutdownType Logoff -Force $true

.EXAMPLE
"Test-pc1","Test-Server1"|Send-shutdown -ShutdownType Restart

.LINK
https://msdn.microsoft.com/en-us/library/aa394058(v=vs.85).aspx

.NOTES
Using Force in conjunction with Shutdown or Reboot on a remote computer 
immediately shuts down everything (including WMI, COM, and so on), or reboots the remote computer.
This results in an indeterminate return value. 

.Author
Jonathan Warnken - jon.warnken@gmail.com
	Full credit to Jeffrey S. Patton and the Set-ShutdownMethod function in his ComputerManagement.ps1 in the technet gallery. 

#>
[CmdletBinding()]

    Param(

	[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
	[string]$Computername,
	[Parameter(Mandatory=$True)][ValidateSet("Logoff","Shutdown","Restart","Poweroff")]
	[string]$ShutdownType,
	[switch]$Force=$false

)
	Begin{
		switch($ShutdownType){
			'Logoff'{[int32]$Win32_ST=0}
			'Shutdown'{[int32]$Win32_ST=1}
			'Restart'{[int32]$Win32_ST=2}
			'Poweroff'{[int32]$Win32_ST=8}
		}
		if($Force){$Win32_ST = $Win32_ST+4}
	}
	Process{
		foreach($computer in $Computername){
			If($result){Remove-Variable -Name result -Force}
			$result = New-Object –typename PSObject
			 if(Test-Connection -ComputerName $computer -Count 3 -ErrorAction SilentlyContinue){
				Try{
					$remote_result = (Get-WmiObject win32_operatingsystem -ComputerName $Computername).Win32Shutdown($Win32_ST)
				}
				catch{
					$remote_result = $_.Exception.Message
				}
			}else{$remote_result ="No response to Ping"}
            if($remote_result.gettype().fullname -eq 'System.Management.ManagementBaseObject'){$remote_result = $remote_result.ReturnValue.ToString()}
			$result|Add-Member –membertype NoteProperty –name ComputerName –value ($computer) –passthru |
			Add-Member –membertype NoteProperty –name Result –value ($remote_result)
			Write-Output $result
		}
	}
}