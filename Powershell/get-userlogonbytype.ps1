$Computername = "."
$return = Get-EventLog -LogName Security -ComputerName $Computername -InstanceId 4624
Write-Output "Logon Type 2 - interactive"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 2}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 3 - network"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 3}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 4 - batch"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 4}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 5 - service"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 5}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 7 - unlock"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 7}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 8 - networkceartext"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 8}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 9 - newcredentials (Runas)"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 9}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 10 - remoteinteractive"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 10}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending
Write-Output "Logon Type 11 - cachedinteractive"
$return|Where-Object -FilterScript{$_.replacementstrings[8] -eq 11}|foreach-object{$_.replacementstrings[5]}|Group-Object|Sort-Object -Property Count -Descending