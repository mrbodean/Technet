'========================================================================== 
'ShareSetup.vbs 
'========================================================================== 
Option Explicit  
Const FILE_SHARE = 0 
Const MAXIMUM_CONNECTIONS = 25 
Dim strComputer 
Dim objWMIService 
Dim objNewShare 
 
strComputer = "." 
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
Set objNewShare = objWMIService.Get("Win32_Share") 
 
Call sharesec ("C:\Robot", "Robot", "SCOT SHARE", "POSTerminalUsers_GG") 
 
 
Sub sharesec(Fname,shr,info,account) 'Fname = Folder path, shr = Share name, info = Share Description, account = account or group you are assigning share permissions to 
Dim FSO 
Dim Services 
Dim SecDescClass 
Dim SecDesc 
Dim Trustee 
Dim ACE 
Dim Share 
Dim InParam 
Dim Network 
Dim FolderName 
Dim AdminServer 
Dim ShareName 
 
FolderName = Fname 
AdminServer = "\\" & strComputer 
ShareName = shr 
 
Set Services = GetObject("WINMGMTS:{impersonationLevel=impersonate,(Security)}!" & AdminServer & "\ROOT\CIMV2") 
Set SecDescClass = Services.Get("Win32_SecurityDescriptor") 
Set SecDesc = SecDescClass.SpawnInstance_() 
 
'Set Trustee = Services.Get("Win32_Trustee").SpawnInstance_ 
'Trustee.Domain = Null 
'Trustee.Name = "EVERYONE" 
'Trustee.Properties_.Item("SID") = Array(1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0) 
 
Set Trustee = SetGroupTrustee("ACME", account) 'Replace ACME with your domain name.  
'To assign permissions to individual accounts use SetAccountTrustee rather than SetGroupTrustee  
 
Set ACE = Services.Get("Win32_Ace").SpawnInstance_ 
ACE.Properties_.Item("AccessMask") = 2032127 
ACE.Properties_.Item("AceFlags") = 3 
ACE.Properties_.Item("AceType") = 0 
ACE.Properties_.Item("Trustee") = Trustee 
SecDesc.Properties_.Item("DACL") = Array(ACE) 
Set Share = Services.Get("Win32_Share") 
Set InParam = Share.Methods_("Create").InParameters.SpawnInstance_() 
InParam.Properties_.Item("Access") = SecDesc 
InParam.Properties_.Item("Description") = "Public Share" 
InParam.Properties_.Item("Name") = ShareName 
InParam.Properties_.Item("Path") = FolderName 
InParam.Properties_.Item("Type") = 0 
Share.ExecMethod_ "Create", InParam 
 
 
End Sub  
 
 
Function SetAccountTrustee(strDomain, strName)  
     set objTrustee = getObject("Winmgmts:{impersonationlevel=impersonate}!root/cimv2:Win32_Trustee").Spawninstance_  
     set account = getObject("Winmgmts:{impersonationlevel=impersonate}!root/cimv2:Win32_Account.Name='" & strName & "',Domain='" & strDomain &"'")  
     set accountSID = getObject("Winmgmts:{impersonationlevel=impersonate}!root/cimv2:Win32_SID.SID='" & account.SID &"'")  
     objTrustee.Domain = strDomain  
     objTrustee.Name = strName  
     objTrustee.Properties_.item("SID") = accountSID.BinaryRepresentation  
     set accountSID = nothing  
     set account = nothing  
     set SetAccountTrustee = objTrustee  
End Function  
 
 
Function SetGroupTrustee(strDomain, strName)  
Dim objTrustee 
Dim account 
Dim accountSID 
set objTrustee = getObject("Winmgmts:{impersonationlevel=impersonate}!root/cimv2:Win32_Trustee").Spawninstance_  
set account = getObject("Winmgmts:{impersonationlevel=impersonate}!root/cimv2:Win32_Group.Name='" & strName & "',Domain='" & strDomain &"'")  
set accountSID = getObject("Winmgmts:{impersonationlevel=impersonate}!root/cimv2:Win32_SID.SID='" & account.SID &"'")  
objTrustee.Domain = strDomain  
objTrustee.Name = strName  
objTrustee.Properties_.item("SID") = accountSID.BinaryRepresentation  
set accountSID = nothing  
set account = nothing  
set SetGroupTrustee = objTrustee  
End Function  