On Error Resume Next  
Const ForWriting = 2 
Const ForReading = 1 
Const ForAppending = 8 
Const TristateFalse = 0 
Dim fso         
Dim errorcount 
Set fso = CreateObject("Scripting.FileSystemObject") 
errorcount = 0 
 
Updatefile "c:\test\tf_param.xml","<TFInSystem>1</TFInSystem>","<TFInSystem>0</TFInSystem>" 
 
WScript.Quit errorcount 
 
Function Updatefile(file, find, newtext) 
WScript.Echo "Searching " & file & " for " & find & " and will replace it with " & newtext 
Dim orgcontents, newcontents 
orgcontents = Getfile(file) 
newcontents = Replace(orgcontents, find, newtext) 
    If newcontents <> orgcontents Then  
        WScript.Echo find & " was found and replaced with " & newtext & " in " & file 
        WriteFile file, newcontents 
    Else  
        WScript.Echo find & " was not found in " & file 
        errorcount = errorcount + 1 
    End If  
End Function  
 
Function Getfile(FileName) 
    If FileName<>"" Then 
        Dim FileStream 
        Set FileStream = fso.OpenTextFile(FileName) 
            If Err Then 
                errorcount = errorcount + 1 
                Getfile = "" 
            End If  
          GetFile = FileStream.ReadAll 
      End If 
End Function  
 
Sub WriteFile(FileName, Contents) 
Dim OutStream 
WScript.Echo FileName & " is backed up as " & FileName & "." & replace(replace(replace(replace(Replace(Now, " ", ""),"/",""),":",""),"PM","",1,-1,1),"AM","",1,-1,1) & ".org" 
fso.CopyFile FileName, FileName & "." & replace(replace(replace(replace(Replace(Now, " ", ""),"/",""),":",""),"PM","",1,-1,1),"AM","",1,-1,1) & ".org" 
Set OutStream = fso.OpenTextFile(FileName, ForWriting, True) 
outStream.Write Contents 
OutStream.Close 
End Sub 