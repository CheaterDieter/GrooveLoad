#RequireAdmin
FileChangeDir (@ScriptDir)
$pfad = StringLeft (@ScriptDir,StringLen(@ScriptDir)-5) & "\GrooveLoad.au3"
ShellExecute ("AutoIt3.exe",'"' & $pfad & '"')