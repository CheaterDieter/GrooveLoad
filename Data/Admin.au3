#RequireAdmin
FileChangeDir (@ScriptDir)
ShellExecute ("AutoIt3.exe",'"' & $cmdline[1] & '"')