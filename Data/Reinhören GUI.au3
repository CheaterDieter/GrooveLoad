#NoTrayIcon
#include "Bass\Bass.au3"
#include <WindowsConstants.au3>
#include <Crypt.au3>

$random = Random(0,9999999999999,1)

$exitfile = FileOpen (@ScriptDir & "\tmp\Reinhören beenden",2+8)
FileWrite ($exitfile,$random)
FileClose ($exitfile)


;MsgBox (0,"",$CmdLineRaw )
If $cmdline[0] <> 6 Then
	Exit
EndIf
$Datei = $cmdline[1]
$Musiktitel = $cmdline[2]
$Spieldauer = $cmdline[3]
$Dateigroesse = $cmdline[4]
$reinhoerenPID = $cmdline[5]
$Fenstertitel = $cmdline[6]


$dateigroessefuerlabel = Round($Dateigroesse / 1048576, 2)

$Player = GUICreate($Fenstertitel, 330, 75, 0, 0, -1, $WS_EX_TOOLWINDOW + $WS_EX_COMPOSITED)

GUISetBkColor(0xFFFFFF)
$Wasspielt = GUICtrlCreateLabel($Musiktitel, 13, 8, 308, 23)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
$PLAYPAUSE = GUICtrlCreatePic("Pause.jpg", 8, 27, 36, 36)
$Player_Stopp = GUICtrlCreatePic("Stop.jpg", 56, 27, 36, 36)
$MP3Infos = GUICtrlCreateLabel("", 104, 38, 215, 17, 0x0002)
$ProgressPlayer = GUICtrlCreateProgress(0, 65, 330, 10)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($ProgressPlayer), "wstr", "", "wstr", "") ;Jetzt per DLL-Call das Windows Theme umstellen
GUICtrlSetColor($ProgressPlayer, 0xFF6700) ;Die Hauptfarbe des Balkens
GUICtrlSetBkColor($ProgressPlayer, 0xFFFFFF) ;Die Hintergrundfarbe
GUICtrlSetStyle(-1, 0x00000008)
_GUI_ProgressAn()
GUISetState(@SW_SHOW)
_BASS_STARTUP("Bass\bass.dll")
;Initalize bass.  Required for most functions.
_BASS_Init(0, -1, 44100, 0, "")
;Check if bass iniated.  If not, we cannot continue.
If @error Then
	MsgBox(0, "Error", "Could not initialize audio")
	ProcessClose($reinhoerenPID)
	FileDelete ($cmdline[1])
	Exit
EndIf
$play = 0
$timer = TimerInit()
$vonlaufzeitabziehen = 0
$pause = False
$zweitesmal = False
$current = "Blub"

AdlibRegister ("Checkexit")
While 1
	If $play = 0 Then
		;Create a stream from that file.
		$MusicHandle = _BASS_StreamCreateFile(False, $Datei, 0, 0, 0)
		;Check if we opened the file correctly.
		If Not @error Then
			_BASS_ChannelPlay($MusicHandle, 1)
			$play = 1
			$schongespielt = TimerInit()
			_GUICtrlProgressSetMarquee($ProgressPlayer, 0)
			GUICtrlSetStyle($ProgressPlayer, 0)
			GUICtrlSetData($ProgressPlayer, 0)

		EndIf
	EndIf

	If $play = 1 And TimerDiff($timer) > 15 And $pause = False Then
		$levels = _BASS_ChannelGetLevel($MusicHandle)
		$ausschlag = (_BASS_HiWord($levels) + _BASS_LoWord($levels)) / 2
		$ausschlagper = ($ausschlag / 32768) * 100
		GUICtrlSetData($ProgressPlayer, $ausschlagper)



		$laufzeittext = Sec2Time((TimerDiff($schongespielt) - $vonlaufzeitabziehen) / 1000) & "/" & $Spieldauer & " - " & $dateigroessefuerlabel & " MB"
		If GUICtrlRead($MP3Infos) <> $laufzeittext Then
			GUICtrlSetData($MP3Infos, $laufzeittext)
		EndIf

		If Sec2Time((TimerDiff($schongespielt) - $vonlaufzeitabziehen -1000) / 1000) = $Spieldauer Then
			ProcessClose($reinhoerenPID)
			FileDelete ($cmdline[1])
			Exit
		EndIf



		$timer = TimerInit()
	EndIf


	$iMsg = GUIGetMsg()
	If $iMsg = -3 Or $iMsg = $Player_Stopp Then
		_BASS_ChannelStop($MusicHandle)
		_BASS_Free()
		ProcessClose($reinhoerenPID)
		FileDelete ($cmdline[1])
		Exit
	EndIf
	If $iMsg = $PLAYPAUSE Then
		If $pause = False Then
			$pause = True
			GUICtrlSetImage($PLAYPAUSE, "Play.jpg")
			_BASS_Pause()
			$pausentimer = TimerInit()
		Else
			$pause = False
			GUICtrlSetImage($PLAYPAUSE, "Pause.jpg")
			_BASS_Start()
			$vonlaufzeitabziehen = $vonlaufzeitabziehen + TimerDiff($pausentimer)
		EndIf
	EndIf
WEnd

Func Checkexit ()
	If FileExists (@ScriptDir & "\tmp\Reinhören beenden") And FileRead (@ScriptDir & "\tmp\Reinhören beenden") <> $random Then
		FileDelete (@ScriptDir & "\tmp\Reinhören beenden")
		If IsDeclared ($MusicHandle) Then _BASS_ChannelStop($MusicHandle)
		_BASS_Free()
		ProcessClose($reinhoerenPID)
		FileDelete ($cmdline[1])
		Exit
	Else
		If FileExists (@ScriptDir & "\tmp\Reinhören beenden") Then FileDelete (@ScriptDir & "\tmp\Reinhören beenden")
	EndIf
EndFunc

Func _GUI_ProgressAn($prog = $ProgressPlayer)
	GUICtrlSetStyle($prog, 0x00000008)
	_GUICtrlProgressSetMarquee($prog, 1, 25)
EndFunc   ;==>_GUI_ProgressAn

Func _GUI_ProgressAus($prog = $ProgressPlayer)
	_GUICtrlProgressSetMarquee($prog, 0)
	GUICtrlSetStyle($prog, 0)
EndFunc   ;==>_GUI_ProgressAus


;===============================================================================
; Function Name:    _GUICtrlProgressSetMarquee()
; Description:    Sets marquee sytle for a progress control
; Parameter(s):  $h_Progress  - The control identifier (controlID)
;               $f_Mode        - Optional: Indicates whether to turn the marquee mode on or off
;                           0 = turn marquee mode off
;                           1 = (Default) turn marquee mode on
;               $i_Time        - Optional: Time in milliseconds between marquee animation updates
;                           Default is 100 milliseconds
; Requirement(s):   AutoIt3 Beta and Windows XP or later
; Return Value(s):  On Success - Returns whether marquee mode is set
;               On Failure - Returns 0  and sets @ERROR = 1
; Author(s):        Bob Anthony
;===============================================================================
Func _GUICtrlProgressSetMarquee($h_Progress, $f_Mode = 1, $i_Time = 100)
	Local Const $WM_USER = 0x0400
	Local Const $PBM_SETMARQUEE = ($WM_USER + 10)
	Local $var = GUICtrlSendMsg($h_Progress, $PBM_SETMARQUEE, $f_Mode, Number($i_Time))
	If $var = 0 Then
		SetError(1)
		Return 0
	Else
		SetError(0)
		Return $var
	EndIf
EndFunc   ;==>_GUICtrlProgressSetMarquee

Func Sec2Time($nr_sec)
	$sec2time_hour = Int($nr_sec / 3600)
	$sec2time_min = Int(($nr_sec - $sec2time_hour * 3600) / 60)
	$sec2time_sec = $nr_sec - $sec2time_hour * 3600 - $sec2time_min * 60
	;Return StringFormat('%02d:%02d:%02d', $sec2time_hour, $sec2time_min, $sec2time_sec)
	Return StringFormat('%02d:%02d', $sec2time_min, $sec2time_sec)
EndFunc   ;==>Sec2Time
