sPath = Replace(WScript.ScriptFullName ,WScript.ScriptName, vbNullString)
set shell = CreateObject("WScript.Shell")
shell.run """" & sPath & "\AutoIt\AutoIt3.exe """"" & sPath & "GrooveLoad.au3"""