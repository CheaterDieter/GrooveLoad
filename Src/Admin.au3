#RequireAdmin
FileChangeDir (@ScriptDir)
ShellExecute (".\AutoIt\AutoIt3.exe",'"' & $cmdline[1] & '"')