#NoTrayIcon
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include "Dependencies\WinHTTP\WinHTTP.au3"
#include <String.au3>
#include <Array.au3>
#include <File.au3>

FileChangeDir(@ScriptDir)

$gIco = '..\Assets\icon.ico'

$pLanguages = '..\Assets\Languages\'

$pCover = '..\Assets\Cover\'
$defaultCover = $pCover & 'default.jpg'

$nConfig = '..\Config\config.ini'
$_sprache = IniRead ($nConfig,"Sprache","Sprache","English")

; Wird für die Proxyfunktion benötigt
Global Const $tagWINHTTP_PROXY_INFO = "DWORD  dwAccessType;ptr lpszProxy;ptr lpszProxyBypass;"

$Proxy = False
If IniRead ($nConfig,"Proxy","Proxy_nutzen","4") = 1 Then $Proxy = True
$ProxyIP = IniRead ($nConfig,"Proxy","Proxy_IP","")


$Proxy = False
If IniRead ($nConfig,"Proxy","Proxy_nutzen","4") = 1 Then $Proxy = True
$ProxyIP = IniRead ($nConfig,"Proxy","Proxy_IP","")
$hOpen = _WinHttpOpen("")
If $Proxy = True Then
	$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
	_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
EndIf

_GDIPlus_Startup()
OnAutoItExitRegister("Clean")

$Proxy = False
Dim $Pic[6]


$GUI = GUICreate(sprache("CS_TITLE"), 640, 535)
GUISetBkColor(0xFFFFFF)
GUISetIcon($gIco)
$suchbegriff = GUICtrlCreateInput("", 10, 30, 240, 21)
GUICtrlCreateLabel(sprache("CS_SEARCHTEXT"), 10, 10, Default, 15)
GUICtrlCreateLabel(sprache("CS_SEARCHAT"), 530, 10, Default, 15)
$itunes = GUICtrlCreateRadio("iTunes", 530, 25)
GUICtrlSetState(-1, 1)
GUICtrlCreateRadio("Amazon", 530, 43)
For $i = 0 To 2
	$Pic[$i] = GUICtrlCreatePic($defaultCover, 10 + 200 * $i + 10 * $i, 70, 200, 200)
	GUICtrlSetState (-1,$GUI_DISABLE)
	GUICtrlSetCursor (-1, 0)
Next
For $i = 0 To 2
	$Pic[$i + 3] = GUICtrlCreatePic($defaultCover, 10 + 200 * $i + 10 * $i, 300, 200, 200)
	GUICtrlSetState (-1,$GUI_DISABLE)
	GUICtrlSetCursor (-1, 0)
Next

$suche = GUICtrlCreateButton(sprache("CS_SEARCH"), 260, 30, 100, 21, 0x0001)
$eigenescover = GUICtrlCreateButton(sprache("CS_SEARCH_OWNCOVER"), 260+75+5+25, 30, 100, 21)

$prog = GUICtrlCreateProgress(530, 510, 100, 15)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($prog), "wstr", "", "wstr", "") ;Jetzt per DLL-Call das Windows Theme umstellen
GUICtrlSetColor($prog, 0xFF6700) ;Die Hauptfarbe des Balkens
GUICtrlSetBkColor($prog, 0xD6D3CE) ;Die Hintergrundfarbe

$ueber = GUICtrlCreateLabel("?", 640-15, 0, 14, 27)
GUICtrlSetFont(-1, 12, 800, 0, "Arial Black")
GUICtrlSetColor(-1, 0x000080)
GUICtrlSetCursor (-1, 0)
$kommandozeilensuche = False
If $cmdline[0] = 1 Then
	GUICtrlSetData ($suchbegriff,$cmdline[1])
	$kommandozeilensuche = True
EndIf

GUISetState(@SW_SHOW)

$GrossGUI = GUICreate(sprache("CS_TITLE"), 500, 540, -1, -1, -1, -1,$GUI)
GUISetIcon($gIco)
GUICtrlCreateLabel(sprache("CS_SEARCHERROR"), 170, 96, 160, 17)
$GrossBild = GUICtrlCreatePic("", 0, 0, 500, 500)
$Add = GUICtrlCreateButton(sprache("CS_MP3ADD"), 297, 504, 160, 25)
$Save = GUICtrlCreateButton(sprache("CS_SAVE"), 41, 504, 160, 25)
GUISetBkColor(0xFFFFFF)

$GROSShGraphics = _GDIPlus_GraphicsCreateFromHWND($GrossGUI) ;create a graphics object from a window handle
$GROSShPen = _GDIPlus_PenCreate(0xFF444444, 1) ;color format AARRGGBB (hex)
_GDIPlus_GraphicsDrawLine($GROSShGraphics, 0, 500, 500, 500, $GROSShPen)


While 1
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($GUI) ;create a graphics object from a window handle
	$hPen = _GDIPlus_PenCreate(0xFF444444, 1) ;color format AARRGGBB (hex)
	_GDIPlus_GraphicsDrawRect($hGraphics, 9, 69, 201, 201, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, 219, 69, 201, 201, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, 429, 69, 201, 201, $hPen)

	_GDIPlus_GraphicsDrawRect($hGraphics, 9, 299, 201, 201, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, 219, 299, 201, 201, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, 429, 299, 201, 201, $hPen)

	$RAHMENhGraphics = _GDIPlus_GraphicsCreateFromHWND($GUI) ;create a graphics object from a window handle
	$RAHMENhPen = _GDIPlus_PenCreate(0xFF000000, 1) ;color format AARRGGBB (hex)
	_GDIPlus_GraphicsDrawRect($RAHMENhGraphics, 529, 509, 101, 16, $RAHMENhPen)

	_GDIPlus_PenDispose($RAHMENhPen)
	_GDIPlus_GraphicsDispose($RAHMENhGraphics)

	$nMsg = GUIGetMsg(1)
	For $i = 0 To 5
		If $nMsg[0] = $Pic[$i] Then
			$guipos = WinGetPos($GUI)
			WinMove($GrossGUI, "", $guipos[0] + 70, $guipos[1])
			GUICtrlSetImage($GrossBild, $defaultCover)
			GUICtrlSetImage($GrossBild, $pCover & $i & ".jpg")
			$Bild = $i
			GUISetState(@SW_SHOW, $GrossGUI)
			GUISetState (@SW_DISABLE,$GUI)
			$GROSShGraphics = _GDIPlus_GraphicsCreateFromHWND($GrossGUI) ;create a graphics object from a window handle
			$GROSShPen = _GDIPlus_PenCreate(0xFF444444, 1) ;color format AARRGGBB (hex)
			_GDIPlus_GraphicsDrawLine($GROSShGraphics, 0, 500, 500, 500, $GROSShPen)
		EndIf
	Next

	If $nMsg[0] = $Save Then
		$pfad = FileSaveDialog (sprache("CS_STORAGELOCATION"),"","(*.jpg)",16,GUICtrlRead ($suchbegriff)&".jpg",$GrossGUI)
		FileChangeDir(@ScriptDir)
		If $pfad <> "" Then
			FileCopy ($pCover&$Bild&".jpg",$pfad,1+8)
		EndIf
	EndIf

	If $nMsg[0] = $eigenescover Then
		MsgBox (64,sprache("CS_TITLE"),sprache("CS_TEXT"),0,$GUI)
		$pfad = FileOpenDialog (sprache("CS_SELECTMP3"),"","(*.mp3)",1,"",$GUI)
		FileChangeDir(@ScriptDir)
		If $pfad <> "" Then
			$Bild = FileOpenDialog (sprache("CS_PICTURE"),"","(*.jpg)",1,"",$GUI)
			FileChangeDir(@ScriptDir)
			If $Bild <> "" Then
				ShellExecuteWait ('.\Dependencies\metamp3\metamp3.exe','--pict "'&$Bild&'" "'&$pfad&'"',Default,Default,@SW_HIDE)
				MsgBox (64,sprache("CS_TITLE"),sprache("CS_FINISH"),0,$GUI)
			EndIf
		EndIf
	EndIf

	If $nMsg[0] = $Add Then
		$pfad = FileOpenDialog (sprache("CS_SELECTMP3"),"","(*.mp3)",1,"",$GrossGUI)
		FileChangeDir(@ScriptDir)
		If $pfad <> "" Then
			If MsgBox (4+32,sprache("CS_TITLE"),StringReplace (sprache("CS_SHURE"),"[%]",@CRLF&$pfad&@CRLF),0,$GrossGUI) = 6 Then
				ShellExecuteWait ('.\Dependencies\metamp3\metamp3.exe','--pict "'&$pCover&$Bild&".jpg"&'" "'&$pfad&'"',Default,Default,@SW_HIDE)
				MsgBox (64,sprache("CS_TITLE"),sprache("CS_FINISH"),0,$GrossGUI)
			EndIf
		EndIf
	EndIf

	If $nMsg[0] = -3 And $nMsg[1] = $GUI Then
		Exit
	ElseIf $nMsg[0] = -3 And $nMsg[1] = $GrossGUI Then
		GUISetState (@SW_ENABLE,$GUI)
		GUISetState(@SW_HIDE, $GrossGUI)
	EndIf

	If $nMsg[0] = $suche Or $kommandozeilensuche = True Then
		$kommandozeilensuche = False
		GUICtrlSetState ($suche,$GUI_DISABLE)
		GUICtrlSetState ($eigenescover,$GUI_DISABLE)
		For $i = 0 To 5
			GUICtrlSetImage($Pic[$i], $defaultCover)
			FileDelete($pCover & $i & ".jpg")
			GUICtrlSetState ($Pic[$i],$GUI_DISABLE)
		Next

		GUICtrlSetStyle($prog, 0x00000008) ; Marquee-Style setzen
		_GUICtrlProgressSetMarquee($prog, 1, 25)
		If GUICtrlRead($itunes) = 1 Then
			$term = GUICtrlRead($suchbegriff)
			$Connection = _WinHttpConnect($hOpen, "itunes.apple.com")
			$h_openRequest = _WinHttpOpenRequest($Connection, "GET", "/search?term=" & $term & "&limit=6", Default, Default, Default, $WINHTTP_FLAG_SECURE)
			_WinHttpSendRequest($h_openRequest, '')
			_WinHttpReceiveResponse($h_openRequest)
			Local $data = ""
			Do
				$data &= _WinHttpReadData($h_openRequest)
			Until @error
			;MsgBox (0,"",$data)
			If $data <> "" Then
				$cover100 = _StringBetween($data, '"artworkUrl100":"', '",')
				If IsArray($cover100) Then
					For $i = 0 To UBound($cover100) - 1
						$cover600 = StringReplace($cover100[$i], "100x100", "600x600")
						;ConsoleWrite ($cover600&@CRLF)
						$urlcrack = _WinHttpCrackUrl($cover600)
						If IsArray($urlcrack) Then

							$Connection = _WinHttpConnect($hOpen, $urlcrack[2])
							If $Proxy = True Then
								$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
								_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
							EndIf
							$h_openRequest = _WinHttpOpenRequest($Connection, "GET", $urlcrack[6])
							_WinHttpSendRequest($h_openRequest, '')
							_WinHttpReceiveResponse($h_openRequest)
							Local $data = Binary("")
							Do
								$data &= _WinHttpReadData($h_openRequest, 2)
							Until @error
							If $data <> Binary("") Then
								$coverpfad = $pCover & $i & ".jpg"
								$coverhandle = FileOpen($coverpfad, 16 + 2 + 8)
								FileWrite($coverhandle, $data)
								FileClose($coverhandle)
								GUICtrlSetImage($Pic[$i], $coverpfad)
							EndIf
						EndIf

					Next
				EndIf
			EndIf
		Else

			$Connection = _WinHttpConnect($hOpen, "www.seekacover.com")
			$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/cd/" & GUICtrlRead ($suchbegriff))
			_WinHttpSendRequest($h_openRequest)
			_WinHttpReceiveResponse($h_openRequest)
			Local $data = ""
			Do
				$data &= _WinHttpReadData($h_openRequest)
			Until @error
			$Cover = _StringBetween($data, '<li><img src="', '" title="')

			If IsArray($Cover) Then
				$a = UBound ($Cover) - 1
				If $a > 5 Then $a = 5
				For $i = 0 To $a
					$bilderurl = _WinHttpCrackUrl($Cover[$i])
				;	MsgBox (0,"",$bilderurl)
				;	_ArrayDisplay ($bilderurl)
					$Connection = _WinHttpConnect($hOpen, $bilderurl[2])
					If $Proxy = True Then
						$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
						_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
					EndIf
					$h_openRequest = _WinHttpOpenRequest($Connection, "GET", $bilderurl[6])
					_WinHttpSendRequest($h_openRequest)
					_WinHttpReceiveResponse($h_openRequest)
					Local $data = Binary("")
					Do
						$data &= _WinHttpReadData($h_openRequest, 2)
					Until @error
					If $data <> Binary("") Then
						$coverpfad = $pCover & $i & ".jpg"
						$coverhandle = FileOpen($coverpfad, 16 + 2 + 8)
						FileWrite($coverhandle, $data)
						FileClose($coverhandle)
						GUICtrlSetImage($Pic[$i], $coverpfad)
					EndIf
				Next
			Else

			EndIf

		EndIf
		For $i = 0 To 5
			If FileExists ($pCover & $i & ".jpg") Then
				GUICtrlSetState ($Pic[$i],$GUI_ENABLE)
			EndIf
		Next
		_GUICtrlProgressSetMarquee($prog, 0)
		GUICtrlSetStyle($prog, $GUI_SS_DEFAULT_GUI)
		GUICtrlSetData($prog, 0)
		GUICtrlSetState ($suche,$GUI_ENABLE)
		GUICtrlSetState ($eigenescover,$GUI_ENABLE)
	EndIf

	If $nMsg[0] = $ueber Then
		MsgBox (64,sprache("CS_TITLE"),sprache("CS_ABOUT"),0,$GUI)
	EndIf

WEnd


Func Clean()
	For $i = 0 To 5
		FileDelete($pCover & $i & ".jpg")
	Next
	_WinHttpCloseHandle($hOpen)
	_GDIPlus_PenDispose($hPen)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_PenDispose($GROSShPen)
	_GDIPlus_GraphicsDispose($GROSShGraphics)
	_GDIPlus_PenDispose($RAHMENhPen)
	_GDIPlus_GraphicsDispose($RAHMENhGraphics)
	_GDIPlus_Shutdown()
EndFunc   ;==>Clean

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

Func sprache ($string)
	$returnstring = IniRead ($pLanguages&$_sprache&".lng","GrooveLoad Language File",$string,$string)
	$returnstring = StringReplace ($returnstring,"[CRLF]",@CRLF)
	Return $returnstring
EndFunc

Func _WinHttpProxyInfoCreate($dwAccessType, $sProxy, $sProxyBypass)
    Local $tWINHTTP_PROXY_INFO[2] = [DllStructCreate($tagWINHTTP_PROXY_INFO), DllStructCreate('wchar proxychars[' & StringLen($sProxy)+1 & ']; wchar proxybypasschars[' & StringLen($sProxyBypass)+1 & ']')]
    DllStructSetData($tWINHTTP_PROXY_INFO[0], "dwAccessType", $dwAccessType)
    If StringLen($sProxy) Then DllStructSetData($tWINHTTP_PROXY_INFO[0], "lpszProxy", DllStructGetPtr($tWINHTTP_PROXY_INFO[1], 'proxychars'))
    If StringLen($sProxyByPass) Then DllStructSetData($tWINHTTP_PROXY_INFO[0], "lpszProxyBypass", DllStructGetPtr($tWINHTTP_PROXY_INFO[1], 'proxybypasschars'))
    DllStructSetData($tWINHTTP_PROXY_INFO[1], "proxychars", $sProxy)
    DllStructSetData($tWINHTTP_PROXY_INFO[1], "proxybypasschars", $sProxyBypass)
    Return $tWINHTTP_PROXY_INFO
EndFunc