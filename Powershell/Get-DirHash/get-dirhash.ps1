$path = "C:\temp"
$temp = (Get-ChildItem $path | Get-FileHash).Hash|out-String
$hash = (Get-FileHash -InputStream ([IO.MemoryStream]::new([char[]]$temp))).Hash

$expectedhash = "345669C44C0D5EB169F217C18162C7028A2C56A1C9D428093862272623F16C3A"
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
if($hash -eq $expectedhash){
    $tsenv.value("OSDContentValidation") = "Continue"
    Write-Host "Hashes match"
}else{
    $tsenv.value("OSDContentValidation") = "Fail"
    Write-Host "Hashes do not match"
}