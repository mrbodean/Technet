<#
.SYNOPSIS
Displays a gui prompt for a computername usable in a SCCM OSD Task Sequence.  

.PARAMETER testing
The is a switch parameter that is used to test the script outside of a SCCM Task Sequence. 
If this -testing is used the script will not load the OSD objects that are only present while a task sequence is running.
instead it will use write-output to display the selection. 

.EXAMPLE
powershell -executionpolicy Bypass -file .\show-OSDPrompt.ps1

.EXAMPLE
powershell -file .\show-OSDPrompt.ps1 -testing 

.NOTES
This is a very simple version of a OSD prompt for a computername. You can add extra validation to the computer name, for example a regular expression test 
to ensure it meets standard form used in your enviroment. Addtional form object can be added to other options that you may want to set
task sequence variables for. Also as a simple example, I just added the xaml for the wpf form as a variable in the script. You have the option of storing it in	
a external file if your form gets complex. 

.Author
Jonathan Warnken - jon.warnken@gmail.com
#>
[CmdletBinding()]
Param(
	[switch]$testing
)
If($testing -eq $false){
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment #This allows us to read and write the Task Sequence variables
    $tsui = New-Object -COMObject Microsoft.SMS.TSProgressUI #This allows us to do stuff to the Progress UI, Like hide it to get it out of the way. 
    $OSDComputername = $tsenv.value("OSDComputername")
    $tsui.closeprogressdialog()
}
[xml]$XAML = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SCCM OSD Computername" Height="154" Width="525" Topmost="True" WindowStyle="ToolWindow">
    <Grid>
        <Label Name="Computername_label" Content="Computername:" HorizontalAlignment="Left" Height="27" Margin="0,10,0,0" VerticalAlignment="Top" Width="241"/>
        <TextBox Name="Computername_text" HorizontalAlignment="Left" Height="27" Margin="246,10,0,0" TextWrapping="Wrap" Text=" " VerticalAlignment="Top" Width="241"/>
        <Button Name="Continue_button" Content="Continue" HorizontalAlignment="Left" Margin="201,62,0,0" VerticalAlignment="Top" Width="75"/>
    </Grid>
</Window>
'@
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
$Form=[Windows.Markup.XamlReader]::Load( $reader )
#Add Form objects as script variables
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
#Update the form
$Computername_text.Text = $OSDComputername
$Continue_button.add_Click({
    $script:computername = $Computername_text.Text.ToString()
    $Form.close()
})
$Form.ShowDialog() | out-null
if($testing -eq $false){
    $tsenv.value("OSDComputername") = $computername
	Write-Output " Computername set to $computername and OSDComputername set to $($tsenv.value("OSDComputername")) "
}else{
	Write-Output " Computername set to $computername and OSDComputername would be set to $computername "
}