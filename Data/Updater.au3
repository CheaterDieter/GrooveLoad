#include "WinHTTP\WinHTTP.au3"

SplashTextOn ("","The program is being updated.",500,70)

FileChangeDir (@ScriptDir)
$Programmverzeichnis = StringLeft (@ScriptDir,StringLen(@ScriptDir)-5)
ConsoleWrite ($Programmverzeichnis&@CRLF)

$neusteversion = FileReadLine ("new.txt",1)
If $neusteversion = "" Then Exit

If StringRight (@ScriptDir,4) = "Data" Then
	DirRemove ($Programmverzeichnis & "\temp",1)
	DirCreate ($Programmverzeichnis & "\temp")
	FileCopy ("AutoIt3.exe",$Programmverzeichnis & "\temp\AutoIt3.exe")
	FileCopy ("Updater.au3",$Programmverzeichnis & "\temp\Updater.au3")
	FileCopy ("new.txt",$Programmverzeichnis & "\temp\new.txt")
	FileDelete ("new.txt")
	DirCopy ("WinHTTP",$Programmverzeichnis & "\temp\WinHTTP")
	ShellExecute ($Programmverzeichnis&"\temp\AutoIt3.exe",'"'&$Programmverzeichnis &'\temp\updater.au3"')
	Exit
Else
	FileDelete ("new.txt")
EndIf

$hOpen = _WinHttpOpen("")
$Connection=_WinHttpConnect($hOpen, "http://hegi.pfweb.eu")

$h_openRequest = _WinHttpOpenRequest($Connection,"POST","/grooveload/download/GrooveLoad " & $neusteversion & ".zip")
_WinHttpSendRequest($h_openRequest)
_WinHttpReceiveResponse($h_openRequest)
Local $data= Binary ("")
Do
    $data&=_WinHttpReadData($h_openRequest,2)
Until @error
_WinHttpCloseHandle($hOpen)

If $data = Binary ("") Then
	SplashOff ()
	MsgBox (16,"","Error while downloading")
Else
	$open = FileOpen($Programmverzeichnis & "\temp\update.zip", 16+2+8)
	FileWrite ($open,$data)
	FileClose ($open)
	Local $data= Binary ("")
	ShellExecuteWait ($Programmverzeichnis & "\Data\7za.exe",'x "'&$Programmverzeichnis&'\temp\update.zip" -o"'&$Programmverzeichnis&'\temp'&'" -y')
	FileDelete ($Programmverzeichnis & "\temp\update.zip")
	$einstellungen = FileRead ($Programmverzeichnis & "\Data\config.ini")
	FileDelete ($Programmverzeichnis & "\temp\GrooveLoad\Data\config.ini")
	$einstellungen = FileWrite ($Programmverzeichnis & "\temp\GrooveLoad\Data\config.ini",$einstellungen)

	If FileExists ($Programmverzeichnis&"\temp\GrooveLoad") Then
		FileDelete ($Programmverzeichnis&"\GrooveLoad.au3")
		FileDelete ($Programmverzeichnis&"\GrooveLoad.vbs")
		FileDelete ($Programmverzeichnis&"\Readme.txt")
		FileDelete ($Programmverzeichnis&"\WICHTIG FÜR DEUTSCHE NUTZER.txt")
		DirRemove ($Programmverzeichnis & "\Data",1)
		RunWait('XCOPY "'& $Programmverzeichnis & "\temp\GrooveLoad" & '" "' & $Programmverzeichnis & '" /E')
		ShellExecute ($Programmverzeichnis&"\Data\run after update.vbs")
	Else
		SplashOff ()
		MsgBox (64,"GrooveLoad","Error while updating")
	EndIf
EndIf