$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Set-FileAttributes Function Parameter Tests" {
    $VaildPath = "TestDrive:\test.txt"
    $InVaildPath = "TestDrive:\DoesNotExist.txt"
    New-Item -Path $VaildPath
    It "Verify -Attribute Parameter ValidateScript" {
        {Set-FileAttributes -Attribute Invalid -Path $VaildPath} | Should Throw "does not belong to the set"
        {Set-FileAttributes -Attribute Readonly -Path $VaildPath} | Should Not Throw
    }
    It "Verify -Attribute Parameter ValidateSet" {
        {Set-FileAttributes -Attribute Invalid -Path $VaildPath} | Should Throw "does not belong to the set"
        $attributes = 'ReadOnly','Hidden','System','Archive' #Other then Normal these are the only Attributes supported by Set-ItemProperty
        Foreach($attrib in $attributes){
            {Set-FileAttributes -Attribute $attrib -Path $VaildPath} | Should Not Throw
        }
    }
    It "Verify -Path Parameter ValidateScript" {
        {Set-FileAttributes -Attribute Invalid -Path $InVaildPath} | Should Throw
        {Set-FileAttributes -Attribute Readonly -Path $VaildPath} | Should Not Throw
    }
    It "Verify -Path Parameter Alias" {
        {Set-FileAttributes -Attribute Invalid -FullName $InVaildPath} | Should Throw
        {Set-FileAttributes -Attribute Readonly -FullName $VaildPath} | Should Not Throw
    }
}
Describe "Pipeline Tests" {
    $VaildPath1 = "TestDrive:\test\test1.txt"
    $VaildPath2 = "TestDrive:\test\test2.txt"
    $InVaildPath = "TestDrive:\DoesNotExist.txt"
    new-item -path "TestDrive:\test" -ItemType directory
    New-Item -Path $VaildPath1
    New-Item -Path $VaildPath2
    It "Verify -Path Parameter from Pipeline" {
        {$InVaildPath|Set-FileAttributes -Attribute Invalid} | Should Throw
        {$VaildPath1|Set-FileAttributes -Attribute Readonly} | Should Not Throw
    }
    It "Verify -Path Parameter from PipelineByPropertyName" {
        {get-childitem -path $InVaildPath |Set-FileAttributes -Attribute Invalid} | Should Throw
        {get-childitem -path $VaildPath2|Set-FileAttributes -Attribute Readonly} | Should Not Throw
        {get-childitem -path "TestDrive:\test"|Set-FileAttributes -Attribute System -remove} | Should Not Throw
    }
}
Describe "Comment Based Help Tests" {
    It "Has Some form of Help Available" {
        <#[CmdletBinding()] will Create help when the Function is loaded. 
        If this test fails ensure it is included #>
        Get-Help Set-FileAttributes| Should match 'Syntax'
    }
    It "Has the Author in the Notes" {
        (Get-Help Set-FileAttributes -full).alertset.alert| Should match 'Author'
        (Get-Help Set-FileAttributes -full).alertset.alert| Should not match 'King Author'
    }
}
Describe "Modify Attributes" {
    $VaildPath = "TestDrive:\test.txt"
    if(test-path -Path $VaildPath -ErrorAction SilentlyContinue){Remove-Item -path $ValidPath -Force}
    New-Item -Path $VaildPath
    $attributes = 'ReadOnly','Hidden','System','Archive' #Other then Normal these are the only Attributes supported by Set-ItemProperty
    It "Can change the attributes"{
        Foreach($attrib in $Attributes){
            Write-Host "Starting Attributes - $((Get-ItemProperty -Path $VaildPath).attributes)"
            Set-FileAttributes -Attribute $attrib -Path $VaildPath
            (Get-ItemProperty -Path $VaildPath).attributes|Should match $attrib
            Write-Host "After Setting $attrib - $((Get-ItemProperty -Path $VaildPath).attributes)"
            Set-FileAttributes -Attribute $attrib -Path $VaildPath|Should match "has $attrib. No change required."
            Write-Host "After Checking $attrib - $((Get-ItemProperty -Path $VaildPath).attributes)"
            Set-FileAttributes -Attribute $attrib -Path $VaildPath -Remove
            (Get-ItemProperty -Path $VaildPath).attributes|Should not match $attrib
            Write-Host "After Removing $attrib - $((Get-ItemProperty -Path $VaildPath).attributes)"
            Set-FileAttributes -Attribute $attrib -Path $VaildPath -Remove|Should match "does not have $attrib. No change required."
            Write-Host "After Checking that $attrib is not set - $((Get-ItemProperty -Path $VaildPath).attributes)"
        }
    }
}
