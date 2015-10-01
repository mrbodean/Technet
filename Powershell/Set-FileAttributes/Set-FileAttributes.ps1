function Set-FileAttributes
{
<#
.Synopsis
    Change File Attributes
.DESCRIPTION
    Long description
.EXAMPLE
    Adds the ReadOnly Attribute to the file c:\temp\test.txt
    Set-FileAttributes -Attribute ReadOnly -Path 'c:\temp\test.txt'
.EXAMPLE
    The Path parameter accepts input from the pipeline
    Adds the ReadOnly Attribute to the file c:\temp\test.txt
    'c:\temp\test.txt'|Set-FileAttributes -Attribute ReadOnly
.EXAMPLE
    The Path parameter accepts input from the pipeline by Property Name. Properties named Path and FullName are supported
    Adds the ReadOnly Attribute to the file c:\temp\test.txt
    get-childitem -path 'c:\temp\test.txt'|Set-FileAttributes -Attribute ReadOnly
.EXAMPLE
    Removes the ReadOnly Attribute from the file c:\temp\test.txt
    Set-FileAttributes -Attribute ReadOnly -Path 'c:\temp\test.txt' -Remove
.NOTES
    Author
        Jon Warnken
        @MrBoDean
        jon.warnken@gmail.com
#>
    [CmdletBinding()]
    Param
    (
        # Attribute help description
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            If([system.io.fileattributes]::$_){$true}
            else{
                throw "$_ is not a valid file attribute. See this MSDN article for more information 'https://msdn.microsoft.com/en-us/library/system.io.fileattributes' Valid attributes are: $([system.io.fileattributes].GetEnumValues())"
            }
        })]
        [ValidateSet('ReadOnly','Hidden','System','Archive')]
        [String]
        $Attribute,

        # Path help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            If(Test-Path -ErrorAction SilentlyContinue -Path $_ ){$true}
           # Else{
           #     Throw "Unable to access $_. Verify that it exists and that you have access. "
           # }
        })]
        [Alias("FullName")]
        [String]
        $Path,

        # Remove help description
        [Parameter(Mandatory=$false)]
        [Switch]
        $Remove=$false
    )

    Begin
    {
        $Attrib = [system.io.fileattributes]::$Attribute
    }
    Process
    {
        If((Get-ItemProperty -Path $path).attributes -band $attrib){
            If($Remove -eq $false){Write-output "$path has $attrib. No change required."}
            else{
                Write-output "$path has $attrib. It will be removed."
                Set-ItemProperty -Path $path -Name attributes -Value ((Get-ItemProperty $path).attributes -BXOR $attrib)
                (Get-ItemProperty -Path $path).attributes
            }
        }else{
            If($Remove -eq $false){
                Write-output "$path is missing $attrib. It will be added."
                Set-ItemProperty -Path $path -Name attributes -Value ((Get-ItemProperty $path).attributes -BXOR $attrib)
                (Get-ItemProperty -Path $path).attributes
            }
            else{Write-output "$path does not have $attrib. No change required."}
        }
    }
    End
    {
    }
}