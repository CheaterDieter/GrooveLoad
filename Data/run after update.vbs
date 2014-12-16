sPath = Replace(WScript.ScriptFullName ,WScript.ScriptName, vbNullString)
set shell = CreateObject("WScript.Shell")
shell.run """" & sPath & "AutoIt3.exe """"" & Left(sPath,Len(sPath)-5) & "GrooveLoad.au3"""