#NoTrayIcon
#include <EditConstants.au3>

FileChangeDir (@ScriptDir)

$pfad = @ScriptDir & "\GrooveLoad.au3"
$iPID=Run('.\AutoIt\AutoIt3.exe /ErrorStdOut "'&$pfad&'" -Dihydrogenmonoxid-',"",Default,6)
$sErrorMsg = ""

ProcessWait($iPID)

While 1
	$sErrorMsg&=StdoutRead($iPID)
	If @error Then ExitLoop
	Sleep(10)
WEnd
If $sErrorMsg = "" Then Exit

$sprache = IniRead ('..\Config\config.ini',"Sprache","Sprache","English")

If $sprache = "Deutsch" Then
	$lng = 0
Else
	$lng = 1
EndIf
Dim $text[2][5]
$text[0][0]="GrooveLoad ist nach einem schweren Fehler abgestürzt:"
$text[0][1]="Fehlerbericht senden"
$text[0][2]="Neu starten"
$text[0][3]="Beenden"
$text[0][4]="Bitte beschreibe hier, was du vor dem Programmabsturz getan hast."

$text[1][0]="GrooveLoad crashed after a serious error:"
$text[1][1]="Send Error Report"
$text[1][2]="Restart"
$text[1][3]="Exit"
$text[1][4]="Please describe here what you did before the crash."


$GUI = GUICreate("GrooveLoad", 419, 192)
GUISetIcon('..\Assets\icon.ico')
GUISetBkColor(0xFFFFFF)
$Label1 = GUICtrlCreateLabel("Houston, we’ve had a problem.", 8, 3, 364, 25)
GUICtrlSetFont(-1, 12, 400, 0, "Arial Black")
GUICtrlSetColor(-1, 0xF77F00)
GUICtrlCreateLabel($text[$lng][0], 8, 28, 311, 17)
$send = GUICtrlCreateButton($text[$lng][1], 8, 158, 131, 25)
$restart = GUICtrlCreateButton($text[$lng][2], 144, 158, 131, 25)
$exit = GUICtrlCreateButton($text[$lng][3], 280, 158, 131, 25)
GUICtrlCreateEdit("", 8, 50, 401, 100,BitOR ($ES_READONLY,$GUI_SS_DEFAULT_EDIT))
$sErrorMsg = $sErrorMsg&@CRLF & @OSVersion & " " & @OSServicePack & " "&@OSArch
GUICtrlSetData(-1, $sErrorMsg)
GUISetState(@SW_SHOW)



Dim Const $SC_CLOSE = 0xF060
$dSysMenu = DllCall("User32.dll", "hwnd", "GetSystemMenu", "hwnd", $GUI, "int", 0)
$hSysMenu = $dSysMenu[0]
DllCall("User32.dll", "int", "RemoveMenu", "hwnd", $hSysMenu, "int", $SC_CLOSE, "int", 0)
DllCall("User32.dll", "int", "DrawMenuBar", "hwnd", $GUI)


DllCall ("user32.dll", "int", "MessageBeep", "int", 0x00000010)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $exit
			Exit
		Case $send
			ShellExecute ("http://hegi.pfweb.eu/grooveload/kontakt/?l="&$sprache&"&Text="&URLEncode ($text[$lng][4]&@CRLF&@CRLF&"-----"&@CRLF&$sErrorMsg))
		Case $restart
			ShellExecute (".\AutoIt\AutoIt3.exe",'"'&@ScriptFullPath&'"')
			Exit

	EndSwitch
WEnd




Func URLEncode($urlText)
    $url = ""
    For $i = 1 To StringLen($urlText)
        $acode = Asc(StringMid($urlText, $i, 1))
        Select
            Case ($acode >= 48 And $acode <= 57) Or _
                    ($acode >= 65 And $acode <= 90) Or _
                    ($acode >= 97 And $acode <= 122)
                $url = $url & StringMid($urlText, $i, 1)
            Case $acode = 32
                $url = $url & "+"
            Case Else
                $url = $url & "%" & Hex($acode, 2)
        EndSelect
    Next
    Return $url
EndFunc   ;==>URLEncode