#include <File.au3>
#include "WinHTTP\WinHTTP.au3"

$fNew = '..\Config\new.txt'
$eAutoIt = '.\AutoIt\AutoIt3.exe'
$fWinHTTP = '.\Dependencies\WinHTTP'


SplashTextOn ("","The program is being updated.",500,70)

FileChangeDir (@ScriptDir)
$Programmverzeichnis = @ScriptDir
ConsoleWrite ($Programmverzeichnis&@CRLF)

$neusteversion = FileReadLine ($fNew,1)
If $neusteversion = "" Then Exit

If StringRight (@ScriptDir,4) = "Data" Then
	DirRemove ($Programmverzeichnis & "\temp",1)
	DirCreate ($Programmverzeichnis & "\temp")
	FileCopy ($eAutoIt,$Programmverzeichnis & "\temp\AutoIt3.exe")
	FileCopy (".\Updater.au3",$Programmverzeichnis & "\temp\Updater.au3")
	FileCopy ($fNew,$Programmverzeichnis & "\temp\new.txt")
	FileDelete ($fNew)
	DirCopy ($fWinHTTP,$Programmverzeichnis & "\temp\WinHTTP")
	ShellExecute ($Programmverzeichnis&"\temp\AutoIt3.exe",'"'&$Programmverzeichnis &'\temp\updater.au3"')
	Exit
Else
	FileDelete ($fNew)
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
	ShellExecuteWait ($e7zip,'x "'&$Programmverzeichnis&'\temp\update.zip" -o"'&$Programmverzeichnis&'\temp'&'" -y')
	FileDelete ($Programmverzeichnis & "\temp\update.zip")
	$einstellungen = FileRead ($nConfig)
	FileDelete ($Programmverzeichnis & "\temp\GrooveLoad\Data\config.ini")
	$einstellungen = FileWrite ($Programmverzeichnis & "\temp\GrooveLoad\Data\config.ini",$einstellungen)

	If FileExists ($Programmverzeichnis&"\temp\GrooveLoad") Then
		FileDelete ($Programmverzeichnis&"\GrooveLoad.au3")
		FileDelete ($Programmverzeichnis&"\GrooveLoad.vbs")
		FileDelete ($Programmverzeichnis&"\Readme.txt")
		FileDelete (_PathFull($Programmverzeichnis&"\..\WICHTIG FÜR DEUTSCHE NUTZER.txt"))
		DirRemove ($Programmverzeichnis,1)
		;RunWait('XCOPY "'& $Programmverzeichnis & "\temp\GrooveLoad" & '" "' & $Programmverzeichnis & '" /E')
		DirCopy($Programmverzeichnis & "\temp\GrooveLoad",$Programmverzeichnis,1)
		ShellExecute ($Programmverzeichnis&"\run after update.vbs")
	Else
		SplashOff ()
		MsgBox (64,"GrooveLoad","Error while updating")
	EndIf
EndIf