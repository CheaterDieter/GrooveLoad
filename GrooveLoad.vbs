sPath = Replace(WScript.ScriptFullName ,WScript.ScriptName, vbNullString)
set shell = CreateObject("WScript.Shell")
shell.run """" & sPath & "Data\AutoIt3.exe """"" & sPath & "GrooveLoad.au3"""