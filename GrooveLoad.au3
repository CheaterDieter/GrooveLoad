; ------------------------------------------
;    GrooveLoad 1.8.2.0 by Cheater Dieter
; ------------------------------------------
;
; It doesn't work... Why?
; It works... Why?
; Feel free to experiment with this code. =)


#NoTrayIcon
If Not StringInStr($cmdlineraw, "-Dihydrogenmonoxid-") Then
	ShellExecute(@ScriptDir & "\Data\AutoIt3.exe", '"' & @ScriptDir & '\Data\ErrorHandler.au3"')
	Exit
EndIf

$version = "1.8.2.0"

#include "Data\WinHTTP\WinHTTP.au3"
#include "Data\Bass\Bass.au3"
#include "Data\Bass\BassConstants.au3"
#include "Data\xMsgBox\xMsgBox.au3"

#include <Crypt.au3>
#include <String.au3>
#include <Array.au3>
#include <Sound.au3>
#include <GDIPlus.au3>

#include <GuiListView.au3>
#include <ListViewConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <EditConstants.au3>
#include <GuiMenu.au3>
#include <File.au3>
#include <GuiEdit.au3>
#include <GuiImageList.au3>

Global $ghGDIPDll

HotKeySet("{F10}", "Absturz")
FileChangeDir(@ScriptDir)

GUICreate("Debug", 400, 150, 0, 0, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE))
$DebugEdit = GUICtrlCreateEdit("", 0, 0, 400, 150)
;GUISetState ()
DebugWrite ("GrooveLoad " & $version)

_GDIPlus_Startup()
FileWrite("Data\test.txt", "Rauchender Tankwart - leuchtendes Beispiel")
If Not FileExists("Data\test.txt") Then
	ShellExecute("Data\AutoIt3.exe", '"' & @ScriptDir & '\Data\Admin.au3" "'&@ScriptFullPath&'"')
	Exit
EndIf
FileDelete("Data\test.txt")

$lngfiles = _FileListToArray ("Data\Sprachen\","*.lng",1)
;_ArrayDisplay ($lngfiles)



$_sprache = IniRead("Data\config.ini", "Sprache", "Sprache", -1)
If $_sprache = -1 Then
	$SpracheGUI = GUICreate("GrooveLoad", 200, 225, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
	GUISetBkColor (0xFFFFFF)
	$listview = GUICtrlCreateListView ("",5,5,190,185,BitOR ( $GUI_SS_DEFAULT_LISTVIEW, $LVS_NOCOLUMNHEADER))
	If Not IsArray ($lngfiles) Then
		MsgBox (16,"GrooveLoad","Error in language file.")
		Exit
	EndIf
	$welcomebutton = GUICtrlCreateButton ("",5,195,190,25)
	$hImage = _GUIImageList_Create(50, 30, 6)
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($SpracheGUI) ;Grafik für die GUI erzeugen
	For $i = 1 To UBound($lngfiles) -1
		$flagimg = "Data\Sprachen\"&StringReplace ($lngfiles[$i],".lng",".jpg")

		$hBitmap = ScaleImage($flagimg, 50, 30)
		_GUIImageList_Add($hImage, _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap))
		_WinAPI_DeleteObject($hBitmap)
	Next
	_GDIPlus_GraphicsDispose($hGraphics)
	_GUICtrlListView_SetImageList($listview, $hImage, 1)
	; Add columns
	_GUICtrlListView_AddColumn($listview, "Bild", 80)
	_GUICtrlListView_InsertColumn($listview, 1, "Name", 103)
	For $i = 1 To UBound($lngfiles) -1
		_GUICtrlListView_AddItem($listview, "", $i-1)
		_GUICtrlListView_AddSubItem($listview, $i-1, StringReplace ($lngfiles[$i],".lng",""), 1)
	Next
	GUICtrlSetData ($welcomebutton,IniRead ("Data\Sprachen\" & $lngfiles[1],"GrooveLoad Language File","HELLO","HELLO"))
	GUICtrlSetState ($welcomebutton,$GUI_DISABLE)
	GUISetState(@SW_SHOW)
	$markiertalt = ""
	$switch = True
	$switchtimer = TimerInit ()
	$hellotext = 1
	While 1
		If $switch = True And TimerDiff ($switchtimer) > 500 Then
			$switchtimer = TimerInit ()
			$hellotext = $hellotext + 1
			If $hellotext = UBound ($lngfiles) Then $hellotext = 1
			GUICtrlSetData ($welcomebutton,IniRead ("Data\Sprachen\" & $lngfiles[$hellotext],"GrooveLoad Language File","HELLO","HELLO"))
		EndIf
		$markiert = _GUICtrlListView_GetSelectedIndices($listview)
		If $markiert <> $markiertalt Then
			If $markiert = "" Then
				$switch = True
				GUICtrlSetState ($welcomebutton,$GUI_DISABLE)
			Else
				$switch = False
				GUICtrlSetData ($welcomebutton,IniRead ("Data\Sprachen\" & $lngfiles[$markiert+1],"GrooveLoad Language File","HELLO","HELLO"))
				GUICtrlSetState ($welcomebutton,$GUI_ENABLE)
			EndIf
			$markiertalt = $markiert
		EndIf
		$msg = GUIGetMsg()
		If $msg = -3 Then Exit
		If $msg = $welcomebutton Then
			IniWrite("Data\config.ini", "Sprache", "Sprache", StringReplace ($lngfiles[$markiert+1],".lng",""))
			ExitLoop
		EndIf
	WEnd
	GUIDelete($SpracheGUI)
	$_sprache = IniRead("Data\config.ini", "Sprache", "Sprache", -1)
EndIf


If @AutoItX64 Then
	MsgBox(16, "Grooveload", sprache("GR_MSG_32BIT"))
	Exit
EndIf

If _Singleton("GrooveLoad " & _Crypt_HashData(@ScriptDir, $CALG_MD5), 1) = 0 Then
	MsgBox(16, "GrooveLoad", sprache("GR_MSG_ALREADYRUNNING")) ; Text 2
	Exit
EndIf

If IniRead("Data\config.ini", "Nutzungsbedingungen", "Akzeptiert", "") <> 1 Then
	If MsgBox(48 + 1 + 256, "GrooveLoad", sprache("GR_MSG_DISCLAIMER") & @CRLF & sprache("GR_MSG_ACCEPT")) = 1 Then ; Text 3 &@crlf& Text 4
		IniWrite("Data\config.ini", "Nutzungsbedingungen", "Akzeptiert", 1)
	Else
		If MsgBox(4, "GrooveLoad", sprache("GR_MSG_DISAGREE")) = 6 Then ShellExecute("https://www.youtube.com/watch?v=jI-kpVh6e1U") ; Text 5
		Exit
	EndIf

EndIf

If FileGetSize("Data\log.txt") / 1048576 > 3 Then FileDelete("Data\log.txt")
$loghandle = FileOpen("Data\log.txt", 1)
OnAutoItExitRegister("ende")
_Log("Programmstart")


; Wenn die Variable $Proxy den Wert True besitzt, wird eine Proxy für die Kommunikation mit Grooveshark verwendet.
; Die Variable $ProxyIP gibt die IP und den Port der Proxy an
$Proxy = False
If IniRead("Data\config.ini", "Proxy", "Proxy_nutzen", "4") = 1 Then $Proxy = True
$ProxyIP = IniRead("Data\config.ini", "Proxy", "Proxy_IP", "")
_Log("Proxy Funktion: " & $Proxy)
_Log("Proxy IP: " & $ProxyIP)
DebugWrite("Proxy Funktion: " & $Proxy)
DebugWrite("Proxy IP: " & $ProxyIP)
; Wird für die Proxyfunktion benötigt
Global Const $tagWINHTTP_PROXY_INFO = "DWORD  dwAccessType;ptr lpszProxy;ptr lpszProxyBypass;"

$versionfull = ""
$versionarray = StringSplit($version, ".")
For $i = 1 To $versionarray[0]
	If StringLen($versionarray[$i]) = 1 Then $versionarray[$i] = 0 & $versionarray[$i]
	$versionfull = $versionfull & $versionarray[$i]
Next


Dim $SongInfosFuerDLListe[1][7]
$SongInfo = ""
$kontextmenue = ""
$doppeltloeschenstate = 1
$dlstate = 1
$dateigroesse = ""
$dloeffnen = False
$krokodilzahl = 0
$nilpferd = 0
$nixgefundentimer = ""

$Ladebildschirm = GUICreate("", 418, 227, -1, -1, $WS_POPUP)
GUISetIcon("Data\icon.ico")
GUISetBkColor(0xFFFFFF)
GUICtrlCreatePic("Data\logo.jpg", 0, 0, 418, 227)
GUICtrlCreateLabel($version, 375, 5)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
WinSetTrans($Ladebildschirm, $Ladebildschirm, 0)
GUISetState(@SW_SHOW)
_FadeIn($Ladebildschirm)

If IniRead("Data\config.ini", "Erster Start", "Einführung", 0) = 0 Then
	; Entfernen zukünftiger Sicherheitsabfragen
	$sUnknownZoneIdentifier = "Zone.Identifier"

	$file = @ScriptDir & "\Data\AutoIt3.exe"
	If _ADS_Exists($file, $sUnknownZoneIdentifier) Then _ADS_Delete($file, $sUnknownZoneIdentifier)
	$file = @ScriptDir & "\Data\metamp3\metamp3.exe"
	If _ADS_Exists($file, $sUnknownZoneIdentifier) Then _ADS_Delete($file, $sUnknownZoneIdentifier)
	$file = @ScriptDir & "\Data\7za.exe"
	If _ADS_Exists($file, $sUnknownZoneIdentifier) Then _ADS_Delete($file, $sUnknownZoneIdentifier)
EndIf

; -----Geheimwort Abfrage + Check der Versionsnummer
;
; Das "Geheimwort" wird zur Erstellung des Token benötigt, es wird von Zeit zu Zeit geändert, das jeweils aktuelle ist
; zu finden unter http://www.scilor.com/grooveshark/xml/GrooveFix.xml (unter "htmlshark") oder kann in der Datei
; http://grooveshark.com/JSQueue.swf gefunden werden. Hierzu muss die Datei mit bspw. showmycode.com decompiliert werden.
; Anschließend kann das "Geheimwort" in der Variable "secretKey:string" eingesehen werden. Das Geheimwort wird
; normalerweise automatisch aktualisisiert.
$hOpen = _WinHttpOpen("")
Timeout ($hOpen)
$Connection = _WinHttpConnect($hOpen, "http://hegi.pfweb.eu")
If $Proxy = True Then
	$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
	_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
EndIf
$h_openRequest = _WinHttpOpenRequest($Connection, "GET", "/grooveload/update.txt")
_WinHttpSendRequest($h_openRequest, '')
_WinHttpReceiveResponse($h_openRequest)
Local $data = ""
Do
	$data &= _WinHttpReadData($h_openRequest)
Until @error
;MsgBox (0,"",$data)
$importantmsg = ""
If $data <> "" Then
	FileDelete("Data\geheimwort.txt")
	$geheimwortdl = _StringBetween($data, "<sword>", "</sword>")
	If IsArray($geheimwortdl) Then FileWrite("Data\geheimwort.txt", $geheimwortdl[0])
	$importantmsg = _StringBetween($data, "<msg>", "</msg>")
	If IsArray($importantmsg) Then $importantmsg = $importantmsg[0]
	$versiondownload = _StringBetween($data, "<ver>", "</ver>")
	If IsArray($versiondownload) Then
		$versionfulldl = ""

		;$versiondownload[0] = "1.9.0.0"

		$versionarray = StringSplit($versiondownload[0], ".")
		For $i = 1 To $versionarray[0]
			If StringLen($versionarray[$i]) = 1 Then $versionarray[$i] = 0 & $versionarray[$i]
			$versionfulldl = $versionfulldl & $versionarray[$i]
		Next
		;ConsoleWrite ("Verwendete Version: "&$version&" ("&$versionfull&") - Neuste Version: "&$versiondownload[0]&" ("&$versionfulldl&")"&@CRLF)
		If $versionfulldl > $versionfull Then
			$updategui = GUICreate("GrooveLoad", 266, 177, -1, -1, -1, -1, $Ladebildschirm)
			GUISetBkColor(0xFFFFFF)
			GUICtrlCreateIcon("Data\icon.ico", -1, 8, 8, 32, 32)
			GUICtrlCreateLabel(sprache("GR_UPDATE_AVAILABLE"), 48, 8, 200, 17)
			GUICtrlCreateLabel(sprache("GR_UPDATE_VERSION") & " " & $version, 48, 24, 200, 17)
			GUICtrlCreateLabel(sprache("GR_UPDATE_NEWVERSION") & " " & $versiondownload[0], 48, 40, 200, 17)
			$Button1 = GUICtrlCreateButton(sprache("GR_UPDATE_AUTO"), 27, 80, 211, 25)
			$Button2 = GUICtrlCreateButton(sprache("GR_UPDATE_MANUALLY"), 27, 112, 211, 25)
			$Button3 = GUICtrlCreateButton(sprache("GR_UPDATE_LATER"), 27, 144, 211, 25)
			GUISetState(@SW_SHOW)
			While 1
				$nMsg = GUIGetMsg()
				Switch $nMsg
					Case $GUI_EVENT_CLOSE
						GUIDelete()
						ExitLoop
					Case $Button3
						GUIDelete()
						ExitLoop
					Case $Button2
						ShellExecute("http://autoit.de/index.php?page=Thread&threadID=44382")
						GUIDelete()
						ExitLoop
					Case $Button1
						If FileExists("Data\new.txt") Then FileDelete("Data\new.txt")
						FileWrite("Data\new.txt", $versiondownload[0])
						ShellExecute("Data\AutoIt3.exe", '"' & @ScriptDir & '\Data\updater.au3"')
						Exit
				EndSwitch
			WEnd
		EndIf
	EndIf
Else
	DebugWrite ("Geheimwort Abfrage und Versionscheck fehlgeschlagen")
EndIf
_WinHttpCloseHandle($hOpen)
$Geheimwort = FileRead("Data\geheimwort.txt")
If $Geheimwort = "" Then $Geheimwort = "nuggetsOfBaller"
_Log("Geheimwort: " & $Geheimwort)
DebugWrite ("Geheimwort: " & $Geheimwort)
; -----Geheimwort Abfrage und Versionscheck Ende
$FakeIP = ""

If IniRead("Data\config.ini", "X-FORWARDED-FOR", "FORWARDED_nutzen", "1") = 1 Then
	$FakeIP = "X-FORWARDED-FOR: " & IniRead("Data\config.ini", "X-FORWARDED-FOR", "FORWARDED_IP", "81.158.166.") & Random(100, 255, 1)
Else
	$FakeIP = ""
EndIf

_Log($FakeIP)

If $FakeIP = "" Then
	$FakeIPanzeige = "Nicht vorhanden"
Else
	$FakeIPanzeige = $FakeIP
EndIf
DebugWrite ($FakeIPanzeige)

; -----Aufruf der Webseite zum Testen



; -----Ende Testaufruf



$hOpen = _WinHttpOpen("")
Timeout ($hOpen)
$Connection = _WinHttpConnect($hOpen, "grooveshark.com")

If $Proxy = True Then
	$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
	_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
EndIf

For $i = 1 To 2
	;ConsoleWrite ("Versuch zu verbinden" & @CRLF)
	$SessionID = _GroovesharkGetSessionID($Connection)
	$CommunicationToken = _GroovesharkGetCommunicationToken($SessionID, $Connection)
	If $SessionID <> 1 And $CommunicationToken <> 1 Then
		ExitLoop
	EndIf
	Sleep(100)
Next
If $SessionID = -1 Or $CommunicationToken = -1 Then
	Interneteinstellungen (1)
EndIf
DebugWrite ("Session ID: "&$SessionID)
DebugWrite ("CommunicationToken "&$CommunicationToken)
$time = TimerInit()

Global $iW = 900, $iH = 520, $iT = 52, $iB = 70, $iLeftWidth = 150, $iGap = 10, $HauptGUI

Dim $seitentext[4]
$seitentext[0] = sprache("GR_GUI_DOWNLOADLIST")
$seitentext[1] = sprache("GR_GUI_SEARCH")
$seitentext[2] = sprache("GR_GUI_SETTINGS")
$seitentext[3] = sprache("GR_GUI_ABOUT")

$HauptGUI = GUICreate("GrooveLoad", $iW, $iH)
GUISetIcon("Data\icon.ico")
GUISetBkColor(0xFFFFFF)

$groovelabel = GUICtrlCreateLabel("GrooveLoad", 48, 8, $iW - 56, 32, $SS_CENTERIMAGE)
GUICtrlSetFont(-1, 14, 800, 0, "Arial", 5)
GUICtrlSetColor(-1, 0x444444)

$grooveicon = GUICtrlCreateIcon("", -1, 8, 8, 32, 32)
GUICtrlSetImage($grooveicon, "Data\icon.ico")

GUICtrlCreateLabel("", 0, $iT, $iW, 2, $SS_SUNKEN);separator
GUICtrlCreateLabel("", $iLeftWidth, $iT + 2, 2, $iH - $iT - $iB - 2, $SS_SUNKEN);separator
GUICtrlCreateLabel("", 0, $iH - $iB, $iW, 2, $SS_SUNKEN);separator

$GUI_FooterText = GUICtrlCreateLabel("GrooveLoad " & $version & " by Cheater Dieter", 10, $iH - 34, 400, 17, BitOR($SS_LEFT, $SS_CENTERIMAGE))
$GUI_Progress = GUICtrlCreateProgress($iW - 110, $iH - 34, 100, 17)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($GUI_Progress), "wstr", "", "wstr", "") ;Jetzt per DLL-Call das Windows Theme umstellen
GUICtrlSetColor($GUI_Progress, 0xFF6700) ;Die Hauptfarbe des Balkens
GUICtrlSetBkColor($GUI_Progress, 0xD6D3CE) ;Die Hintergrundfarbe

$GUI_Log = GUICtrlCreateEdit("", $iW - 110 - 8 - 300, $iH - 68, 300, 68, BitOR($ES_READONLY, $ES_RIGHT), 0)
GUICtrlSetBkColor(-1, 0xFFFFFF)
GUICtrlSetCursor(-1, 2)
GUICtrlSetFont(-1, 7.5)


;Seitentexte erstellen
Dim $Link[UBound($seitentext)]
Dim $icon[UBound($seitentext)]
For $i = 0 To UBound($seitentext) - 1
	$Link[$i] = GUICtrlCreateLabel($seitentext[$i], 36 + 10, $iT + $iGap + 8, $iLeftWidth - 46, 17)
	GUICtrlSetCursor(-1, 0)
	$icon[$i] = GUICtrlCreateIcon("Data\ico\" & $i & ".ico", -1, 10, $iT + $iGap, 32, 32)
	$iGap += 22 + 16
Next

;Einzelne Seiten erstellen
Dim $Pannel[UBound($seitentext)]
For $i = 0 To UBound($seitentext) - 1
	$Pannel[$i] = GUICreate("", $iW - $iLeftWidth + 2, $iH - $iT - $iB, $iLeftWidth + 2, $iT, $WS_CHILD + $WS_VISIBLE, -1, $HauptGUI)
	GUISetBkColor(0xFFFFFF)
Next


;add controls to the panels
_AddControlsToPanel($Pannel[0])
$GUI_DLListe = GUICtrlCreateListView(sprache("GR_DLGUI_TITLE")&"|"&sprache("GR_DLGUI_ARTIST")&"|"&sprache("GR_DLGUI_ALBUM"), 8, 8, 570, 370, BitOR($GUI_SS_DEFAULT_LISTVIEW, $WS_BORDER), $LVS_EX_CHECKBOXES + $LVS_EX_FULLROWSELECT)
_GUICtrlListView_SetColumnWidth($GUI_DLListe, 0, 175)
$GUI_Download = GUICtrlCreateButton(sprache("GR_GUI_DOWNLOAD"), 586, 8, 150, 25)
GUICtrlCreateLabel("", 586, 41, 150, 2, $SS_SUNKEN);separator
$GUI_DLListeleeren = GUICtrlCreateButton(sprache("GR_GUI_REMOVESELECTED"), 586, 41 + 8, 150, 25)
$GUI_AuswahlDL = GUICtrlCreateButton(sprache("GR_GUI_SELECTION"), 586, 74 + 8, 150, 25)
GUICtrlCreateLabel("", 586, 74 + 8 + 25 + 8, 150, 2, $SS_SUNKEN);separator

$manuell_Cover = GUICtrlCreateButton(sprache("GR_GUI_MANUALCS"), 586, 123, 150, 25)


_AddControlsToPanel($Pannel[1])
$GUI_EingabeSuche = GUICtrlCreateInput("", 8, 350, 457, 21)
GUICtrlSendMsg($GUI_EingabeSuche, 0x1501, 0, sprache("GR_GUI_INPUTTEXT"))
$GUI_ButtonSuche = GUICtrlCreateIcon("Data\ico\1.ico", -1, 470, 350 - 5, 32, 32)
GUICtrlSetCursor(-1, 0)
GUICtrlSetTip(-1, sprache("GR_GUI_SEARCH"))
$GUI_ListeSuchergebnisse = GUICtrlCreateListView(sprache("GR_DLGUI_TITLE")&"|"&sprache("GR_DLGUI_ARTIST")&"|"&sprache("GR_DLGUI_ALBUM"), 8, 8, 570, 305, BitOR($GUI_SS_DEFAULT_LISTVIEW, $WS_BORDER), $LVS_EX_CHECKBOXES + $LVS_EX_FULLROWSELECT)
$GUI_hinzufuegenlabel = GUICtrlCreateLabel("", 240, 380, 500, 17, $SS_RIGHT)
GUICtrlSetColor($GUI_hinzufuegenlabel, 0xFFFFFF)
$GUI_DLListeHinzufuegen = GUICtrlCreateButton(sprache("GR_GUI_ADDTODLLIST"), 586, 8, 150, 25)
GUICtrlCreateLabel("", 586, 41, 150, 2, $SS_SUNKEN);separator
$GUI_AuswahlSuche = GUICtrlCreateButton(sprache("GR_GUI_SELECTION"), 586, 41 + 8, 150, 25)
$GUI_Doppeltloeschen = GUICtrlCreateButton(sprache("GR_GUI_RMVDUPLICATES"), 586, 82, 150, 25)
GUICtrlCreateLabel("", 586, 115, 150, 2, $SS_SUNKEN);separator
$GUI_Stapelverarbeitung = GUICtrlCreateButton(sprache("GR_GUI_BATCH"), 586, 123, 150, 25)
_GUICtrlListView_SetColumnWidth($GUI_ListeSuchergebnisse, 0, 175)
$GUI_ButtonBeliebteLieder = GUICtrlCreateIcon("Data\ico\fav.ico", -1, 470 + 40, 350 - 5, 32, 32)
GUICtrlSetCursor(-1, 0)
GUICtrlSetTip(-1, sprache("GR_GUI_POPULAR"))

_AddControlsToPanel($Pannel[2])
$GUI_Verbindungseinstellungen = GUICtrlCreateButton(sprache("GR_GUI_CONNECTION"), 8, 8, 300)
$GUI_Downloadeinstellungen = GUICtrlCreateButton(sprache("GR_GUI_DLSETTINGS"), 8, 8 + 25 + 8, 300)
$GUI_zuruecksetzen = GUICtrlCreateButton(sprache("GR_GUI_RESET"), 8, 107, 300)
$GUI_sprache = GUICtrlCreateButton(sprache("GR_GUI_LNG"), 8, 74, 300)
$GUI_verknuepfung = GUICtrlCreateButton(sprache("GR_GUI_SHORTCUT"), 8, 140, 300)
$GUI_AufrufausDE = GUICtrlCreateButton(sprache("GR_GUI_GERMANY"), 8, 140+8+25, 300)
$GUI_feedback = GUICtrlCreateButton(sprache("GR_GUI_FEEDBACK"), 8, 206, 300)

_AddControlsToPanel($Pannel[3])
GUICtrlCreateLabel(StringReplace (sprache("GR_GUI_COPYRIGHT"),"[%]",$version), 8, 8, $iW - $iLeftWidth - 39, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial", 5)
GUICtrlSetColor(-1, 0x444444)
GUICtrlCreateLabel(sprache("GR_GUI_ABOUTTEXT") & @CRLF & @CRLF & sprache("GR_MSG_DISCLAIMER"), 8, 35, $iW - $iLeftWidth - 39, 300)
GUICtrlCreatePic ("Data\WTFPL.jpg",10,290,137,100)


GUISetState(@SW_HIDE, $Pannel[0])
GUISetState(@SW_HIDE, $Pannel[1])
GUISetState(@SW_HIDE, $Pannel[2])
GUISetState(@SW_HIDE, $Pannel[3])

GUISetState(@SW_SHOW, $Pannel[1])


$aktivespannel = 1
GUICtrlSetColor($Link[1], 0x0066CC)
GUICtrlSetImage($icon[1], "Data\ico\1-.ico")


; Erstelle Auswahlmenü Suchergebnisse
$Suche_GUI = GUICreate(sprache("GR_GUI_SEARCHGUI"), 116, 107, -1, -1, -1, $WS_EX_TOOLWINDOW, $HauptGUI)
GUISetIcon("Data\icon.ico")
$Suche_Alle = GUICtrlCreateButton(sprache("GR_GUI_SELECTALL"), 8, 8, 100, 25)
$Suche_AlleAb = GUICtrlCreateButton(sprache("GR_GUI_UNSELECTALL"), 8, 41, 100, 25)
$Suche_Umkehren = GUICtrlCreateButton(sprache("GR_GUI_INVERTSELECTION"), 8, 74, 100, 25)


; Erstelle Auswahlmenü Downloadliste
$DL_GUI = GUICreate(sprache("GR_GUI_DOWNLOADLIST"), 116, 107, -1, -1, -1, $WS_EX_TOOLWINDOW, $HauptGUI)
GUISetIcon("Data\icon.ico")
$DL_Alle = GUICtrlCreateButton(sprache("GR_GUI_SELECTALL"), 8, 8, 100, 25);T40
$DL_AlleAb = GUICtrlCreateButton(sprache("GR_GUI_UNSELECTALL"), 8, 41, 100, 25);T41
$DL_Umkehren = GUICtrlCreateButton(sprache("GR_GUI_INVERTSELECTION"), 8, 74, 100, 25);T42


$beliebtelieder = False

GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
_ConsoleWrite(sprache("GR_MSG_CONNECTION"))
$tooltipvar = TimerInit()
If FileRead("Data/DLListe.txt") <> "" Then
	For $i = 1 To _FileCountLines("Data/DLListe.txt")
		$dlline = FileReadLine("Data/DLListe.txt", $i)
		If $dlline <> "" Then
			$dlelemente = StringSplit($dlline, "|")
			For $a = 1 To 5
				ReDim $SongInfosFuerDLListe[$i][7]
				$SongInfosFuerDLListe[$i - 1][0] = $dlelemente[1]
				$SongInfosFuerDLListe[$i - 1][1] = $dlelemente[2]
				$SongInfosFuerDLListe[$i - 1][2] = $dlelemente[3]
				$SongInfosFuerDLListe[$i - 1][3] = $dlelemente[4]
				$SongInfosFuerDLListe[$i - 1][4] = $dlelemente[5]
			Next
		EndIf
	Next
	;_ArrayDisplay ($SongInfosFuerDLListe)
	FileDelete("Data\DLListe.txt")
	For $i = 0 To UBound($SongInfosFuerDLListe) - 1
		GUICtrlCreateListViewItem($SongInfosFuerDLListe[$i][1] & "|" & $SongInfosFuerDLListe[$i][2] & "|" & $SongInfosFuerDLListe[$i][3], $GUI_DLListe)
		FileWrite("Data\DLListe.txt", $SongInfosFuerDLListe[$i][0] & "|" & $SongInfosFuerDLListe[$i][1] & "|" & $SongInfosFuerDLListe[$i][2] & "|" & $SongInfosFuerDLListe[$i][3] & "|" & $SongInfosFuerDLListe[$i][4] & @CRLF)
	Next

EndIf
GUICtrlSetState($GUI_EingabeSuche, $GUI_NOFOCUS) ; Sicher ist sicher...

$nr = 1


$tutgui = GUICreate("GrooveLoad", 426, 90 + 25 + 8, 4, 4, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
GUISetIcon("Data\icon.ico")
$hMenu = _GUICtrlMenu_GetSystemMenu($tutgui)
_GUICtrlMenu_EnableMenuItem($hMenu, $SC_CLOSE, $MF_GRAYED, False)
GUISetBkColor(0xFFFFFF)
$text = GUICtrlCreateLabel("", 56, 8, 361, 82)
GUICtrlSetFont(-1, 8.5, Default, 0, 'Verdana')
$weiter = GUICtrlCreateButton(sprache("GR_TUT_NEXT"), 344, 90, 75, 25)
$zurueck = GUICtrlCreateButton(sprache("GR_TUT_BACK"), 264, 90, 75, 25)
$dle = GUICtrlCreateButton(sprache("GR_GUI_DLSETTINGS"), 56, 90, 150, 25)
GUICtrlCreateIcon("Data\ico\3.ico", -1, 0, 0, 48, 48)

hinweise()
GUICtrlSetState($dle, $GUI_HIDE)
If IniRead("Data\config.ini", "Erster Start", "Einführung", 0) = 0 Then GUISetState(@SW_SHOW)
;GUISetState(@SW_SHOW)


$fSortSense = False

GUISetState(@SW_SHOW, $HauptGUI)
_FadeOut($Ladebildschirm)
GUIDelete($Ladebildschirm)

If FileExists(@ScriptDir & "\temp") Then
	DirRemove(@ScriptDir & "\temp", 1)
	; Entfernen zukünftiger Sicherheitsabfragen
	$sUnknownZoneIdentifier = "Zone.Identifier"

	$file = @ScriptDir & "\Data\AutoIt3.exe"
	If _ADS_Exists($file, $sUnknownZoneIdentifier) Then _ADS_Delete($file, $sUnknownZoneIdentifier)
	$file = @ScriptDir & "\Data\metamp3\metamp3.exe"
	If _ADS_Exists($file, $sUnknownZoneIdentifier) Then _ADS_Delete($file, $sUnknownZoneIdentifier)
	$file = @ScriptDir & "\Data\7za.exe"
	If _ADS_Exists($file, $sUnknownZoneIdentifier) Then _ADS_Delete($file, $sUnknownZoneIdentifier)

	GUISetState(@SW_DISABLE, $HauptGUI)
	$Changelog_GUI = GUICreate("GrooveLoad", 458, 251, -1, -1, -1, -1, $HauptGUI)
	GUISetIcon("Data\icon.ico")
	GUISetBkColor(0xFFFFFF)
	GUICtrlCreateEdit("", 8, 28, 441, 153, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
	If $_sprache = "Deutsch" Then
		$wasistneu = _StringBetween(FileRead("Data\Neuerungen.txt"), "DE>>", "<<DE")
	Else
		$wasistneu = _StringBetween(FileRead("Data\Neuerungen.txt"), "EN>>", "<<EN")
	EndIf
	If IsArray($wasistneu) Then
		$wasistneu = $wasistneu[0]
	Else
		$wasistneu = "Data\Neuerungen.txt is broken"
	EndIf
	GUICtrlSetData(-1, $wasistneu)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$Label1 = GUICtrlCreateLabel(sprache("GR_UPDATE_HEADLINE") & " " & $version, 8, 8, 185, 17)
	$Changelog_OK = GUICtrlCreateButton("OK", 151, 216, 155, 25)
	$changelogopen = GUICtrlCreateLabel(sprache("GR_UPDATE_CHANGELOG"), 8, 192, 429, 17)
	GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0066CC)
	GUICtrlSetCursor(-1, 0)

	GUISetState(@SW_SHOW)
	MsgBox(64, "GrooveLoad", StringReplace(sprache("GR_UPDATE_SUCCESS"), "[%]", $version), 0, $Changelog_GUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $changelogopen
				ShellExecute("http://hegi.pfweb.eu/grooveload/download/Changelog.txt")
			Case $Changelog_OK
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete()
	GUISetState(@SW_ENABLE, $HauptGUI)
	WinActivate($HauptGUI)

EndIf

DirRemove (@ScriptDir & "\Data\tmp",1)

If FileRead("Data/DLListe.txt") <> "" Then ToolTip(sprache ("GR_GUI_STILLDL"), 551, 362, sprache("GR_GUI_STILLDLHEADLINE"), 1, 1)
If $importantmsg <> "" Then MsgBox (0,"GrooveLoad",$importantmsg,0,$HauptGUI)
While 1
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($HauptGUI) ;create a graphics object from a window handle
	$hPen = _GDIPlus_PenCreate(0xFF000000, 1) ;color format AARRGGBB (hex)
	_GDIPlus_GraphicsDrawRect($hGraphics, $iW - 111, $iH - 35, 101, 18, $hPen)

	_GDIPlus_PenDispose($hPen)
	_GDIPlus_GraphicsDispose($hGraphics)
	If TimerDiff($tooltipvar) > 3000 Then ToolTip("")
	If TimerDiff($time) > 540000 Then ; 540000 ms = 9 Minuten
		GUI_Deaktivieren()
		_GUI_ProgressAn()
		$hOpen = _WinHttpOpen("")
		Timeout ($hOpen)
		$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
		If $Proxy = True Then
			$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
			_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
		EndIf
		For $i = 1 To 2
			_ConsoleWrite(sprache("GR_MSG_REFRESH"))
			$SessionID = _GroovesharkGetSessionID($Connection)
			$CommunicationToken = _GroovesharkGetCommunicationToken($SessionID, $Connection)
			If $SessionID <> 1 And $CommunicationToken <> 1 Then
				ExitLoop
			EndIf
		Next
		If $SessionID = -1 Or $CommunicationToken = -1 Then
			MsgBox(16, "GrooveLoad", sprache("GR_MSG_ERRORSESSIONID"))
			Exit
		EndIf
		_ConsoleWrite(sprache("GR_MSG_CONNECTION"))
		GUISetState(@SW_ENABLE, $HauptGUI)
		_GUI_ProgressAus()
		GUI_Aktivieren()
		$time = TimerInit()
	EndIf

	$nMsg = GUIGetMsg(1)
	If IsArray($kontextmenue) Then
		$ubound = UBound($kontextmenue) - 1
		For $o = 0 To $ubound
			For $p = 0 To 3
				If $nMsg[0] = $kontextmenue[$o][$p] And $nMsg[1] = $Pannel[1] Then
					If $p = 0 Then
						;MsgBox (0,"",$o&":"&$p)
						_GUI_ProgressAn()
						GUI_Deaktivieren()
						;MsgBox (0,"Suche nach Album",$SongInfo[$o][2])
						;Suche nach Album
						_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($GUI_ListeSuchergebnisse))
						$Token = _GroovesharkGetToken($CommunicationToken, "albumGetAllSongs")
						$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?albumGetAllSongs")
						;MsgBox (0,"",$SongInfo[$o][5])
						_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"header":{"client":"htmlshark","clientRevision":"20130520","privacy":0,"country":{"ID":223,"CC1":0,"CC2":0,"CC3":0,"CC4":1073741824,"DMA":790,"IPR":0},"session":"' & $SessionID & '","token":"' & $Token & '"},"method":"albumGetAllSongs","parameters":{"albumID":' & $SongInfo[$o][5] & '}}')

						_WinHttpReceiveResponse($h_openRequest)
						Local $data = ""
						Do
							$data &= _WinHttpReadData($h_openRequest)
						Until @error
						_Log("Suche Album " & $SongInfo[$o][2] & ": " & $data)
						DebugWrite("Suche Album " & $SongInfo[$o][2] & ": " & $data)
						;MsgBox (0,"",$data)
						If StringInStr($data, "invalid token") <> 0 Then
							GUISetState(@SW_DISABLE, $HauptGUI)
							MsgBox(16, "GrooveLoad", sprache("GR_MSG_SECRETWORD"))
							GUI_Aktivieren()
							GUISetState(@SW_ENABLE, $HauptGUI)
							WinActivate($HauptGUI)
						Else
							$SongID = _StringBetween($data, 'SongID":"', '","')
							$SongName = _StringBetween($data, '"Name":"', '","')
							$AlbumName = _StringBetween($data, 'AlbumName":"', '","')
							$ArtistName = _StringBetween($data, 'ArtistName":"', '"}')
							$ArtistID = _StringBetween($data, 'ArtistID":"', '","')
							$AlbumID = _StringBetween($data, '"AlbumID":"', '","')
							$cover = _StringBetween($data, '"CoverArtFilename":', ",")

							If Not IsArray($SongID) Or Not IsArray($SongName) Or Not IsArray($AlbumName) Or Not IsArray($ArtistName) Or Not IsArray($ArtistID) Or Not IsArray($AlbumID) Then
								MsgBox(16, "GrooveLoad", sprache("GR_MSG_SEARCHERROR"))
								GUI_Aktivieren()
							Else
								Dim $SongInfo[UBound($cover)][7]
								Dim $kontextmenue[UBound($cover)][4]
								For $i = 0 To UBound($cover) - 1
									$SongInfo[$i][0] = $SongID[$i]
									$SongInfo[$i][1] = $SongName[$i]
									$SongInfo[$i][2] = $AlbumName[$i]
									$SongInfo[$i][3] = $ArtistName[$i]
									$SongInfo[$i][4] = $ArtistID[$i]
									$SongInfo[$i][5] = $AlbumID[$i]
									$SongInfo[$i][6] = $cover[$i]

									For $k = 1 To 3
										$SongInfo[$i][$k] = fromUnicode($SongInfo[$i][$k])
									Next
									$eintragliste = GUICtrlCreateListViewItem($SongInfo[$i][1] & "|" & $SongInfo[$i][3] & "|" & $SongInfo[$i][2], $GUI_ListeSuchergebnisse)
									$menue = GUICtrlCreateContextMenu($eintragliste)
									$kontextmenue[$i][0] = GUICtrlCreateMenuItem(sprache("GR_GUI_ALBUMSEARCH"), $menue)
									$kontextmenue[$i][1] = GUICtrlCreateMenuItem(sprache("GR_GUI_ARTISTSEARCH"), $menue)
									$kontextmenue[$i][2] = GUICtrlCreateMenuItem(sprache("GR_GUI_PREVIEW"), $menue)
									$kontextmenue[$i][3] = GUICtrlCreateMenuItem(sprache("GR_GUI_SHARE"), $menue)
								Next

							EndIf
							GUI_Aktivieren()
							_GUI_ProgressAus()
							ExitLoop 2
						EndIf
					EndIf
					If $p = 1 Then
						;MsgBox (0,"",$o&":"&$p)
						GUI_Deaktivieren()
						_GUI_ProgressAn()
						;MsgBox (0,"Suche nach Interpreten",$SongInfo[$o][3])
						;Suche nach Interpreten
						_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($GUI_ListeSuchergebnisse))
						$Token = _GroovesharkGetToken($CommunicationToken, "artistGetArtistSongs")
						$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?artistGetArtistSongs")
						;MsgBox (0,"",$SongInfo[$o][5])
						_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"header":{"client":"htmlshark","clientRevision":"20130520","privacy":0,"country":{"ID":223,"CC1":0,"CC2":0,"CC3":0,"CC4":1073741824,"DMA":790,"IPR":0},"session":"' & $SessionID & '","token":"' & $Token & '"},"method":"artistGetArtistSongs","parameters":{"artistID":' & $SongInfo[$o][4] & '}}')

						_WinHttpReceiveResponse($h_openRequest)
						Local $data = ""
						Do
							$data &= _WinHttpReadData($h_openRequest)
						Until @error
						_Log("Suche Interpret " & $SongInfo[$o][3] & ": " & $data)
						DebugWrite("Suche Interpret " & $SongInfo[$o][3] & ": " & $data)
						;MsgBox (0,"",$data)
						If StringInStr($data, "invalid token") <> 0 Then
							GUISetState(@SW_DISABLE, $HauptGUI)
							MsgBox(16, "GrooveLoad", sprache("GR_MSG_SECRETWORD")) ; T45
							GUI_Aktivieren()
							GUISetState(@SW_ENABLE, $HauptGUI)
							WinActivate($HauptGUI)
						Else
							$SongID = _StringBetween($data, 'SongID":"', '","')
							$SongName = _StringBetween($data, '"Name":"', '","')
							$AlbumName = _StringBetween($data, 'AlbumName":"', '","')
							$ArtistName = _StringBetween($data, '"ArtistName":"', '"}')
							$ArtistID = _StringBetween($data, 'ArtistID":"', '","')
							$AlbumID = _StringBetween($data, '"AlbumID":"', '","')
							$cover = _StringBetween($data, '"CoverArtFilename":', ",")

							If Not IsArray($SongID) Or Not IsArray($SongName) Or Not IsArray($AlbumName) Or Not IsArray($ArtistName) Or Not IsArray($ArtistID) Or Not IsArray($AlbumID) Then
								MsgBox(16, "GrooveLoad", sprache("GR_MSG_SEARCHERROR")) ;T50
								GUI_Aktivieren()
							Else
								Dim $SongInfo[UBound($cover)][7]
								Dim $kontextmenue[UBound($cover)][4]
								For $i = 0 To UBound($cover) - 1
									$SongInfo[$i][0] = $SongID[$i]
									$SongInfo[$i][1] = $SongName[$i]
									$SongInfo[$i][2] = $AlbumName[$i]
									$SongInfo[$i][3] = $ArtistName[$i]
									$SongInfo[$i][4] = $ArtistID[$i]
									$SongInfo[$i][5] = $AlbumID[$i]
									$SongInfo[$i][6] = $cover[$i]

									For $k = 1 To 3
										$SongInfo[$i][$k] = fromUnicode($SongInfo[$i][$k])
									Next
									$eintragliste = GUICtrlCreateListViewItem($SongInfo[$i][1] & "|" & $SongInfo[$i][3] & "|" & $SongInfo[$i][2], $GUI_ListeSuchergebnisse)
									$menue = GUICtrlCreateContextMenu($eintragliste)

									$kontextmenue[$i][0] = GUICtrlCreateMenuItem(sprache("GR_GUI_ALBUMSEARCH"), $menue)
									$kontextmenue[$i][1] = GUICtrlCreateMenuItem(sprache("GR_GUI_ARTISTSEARCH"), $menue)
									$kontextmenue[$i][2] = GUICtrlCreateMenuItem(sprache("GR_GUI_PREVIEW"), $menue)
									$kontextmenue[$i][3] = GUICtrlCreateMenuItem(sprache("GR_GUI_SHARE"), $menue)
								Next

							EndIf
							_GUI_ProgressAus()
							GUI_Aktivieren()
							ExitLoop 2
						EndIf
					EndIf
					If $p = 2 Then

						$Token = _GroovesharkGetToken($CommunicationToken, "getStreamKeyFromSongIDEx")
						$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?getStreamKeyFromSongIDEx")
						_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"header":{"token":"' & $Token & '","privacy":0,"session":"' & $SessionID & '","client":"htmlshark","country":{"DMA":501,"CC1":0,"CC2":0,"IPR":0,"CC3":0,"CC4":1073741824,"ID":223},"clientRevision":"20130520"},"method":"getStreamKeyFromSongIDEx","parameters":{"prefetch":false,"type":0,"mobile":false,"country":{"DMA":501,"CC1":0,"CC2":0,"IPR":0,"CC3":0,"CC4":1073741824,"ID":223},"songID":' & $SongInfo[$o][0] & '}}')
						_WinHttpReceiveResponse($h_openRequest)
						Local $data = ""
						Do
							$data &= _WinHttpReadData($h_openRequest)
						Until @error
						_Log("Reinhören: Streamdaten von " & $SongInfo[$o][0] & "-" & $SongInfo[$o][1] & ": " & $data)
						DebugWrite("Reinhören: Streamdaten von " & $SongInfo[$o][0] & "-" & $SongInfo[$o][1] & ": " & $data)
						;MsgBox(0,"",$data)


						$spieldauer = _StringBetween ($data,'uSecs":"','","')
						If IsArray ($spieldauer) Then
							$spieldauer = $spieldauer[0]
						Else
							$spieldauer = 0
						EndIf
						$spieldauer = Sec2Time($spieldauer/1000000)

						$StreamIP = _StringBetween($data, 'ip":"', '"}}')
						$StreamKey = _StringBetween($data, 'streamKey":"', '",')
						If Not IsArray($StreamIP) Or Not IsArray($StreamKey) Then
							MsgBox (16,"",sprache ("GR_MSG_STREAMDATAERROR"),0,$HauptGUI)
						Else
							$error = 0
							$StreamIP = $StreamIP[0]
							$StreamKey = $StreamKey[0]
							
							ShellExecute ("Data\AutoIt3.exe",'"'&@ScriptDir&'\Data\Reinhören.au3" "'&$StreamIP&'" "'&$StreamKey&'" "'&$SongInfo[$o][1]&'" "'&$spieldauer&'" "'&sprache("GR_GUI_PREVIEW")&'" "'&$HauptGUI&'"')
						EndIf
					EndIf
					If $p = 3 Then
						$hauptguipos = WinGetPos($HauptGUI)
						$teilengui = GUICreate($SongInfo[$o][1], 371, 82, $hauptguipos[0] + $hauptguipos[2] - 371 - 5, $hauptguipos[1] + $hauptguipos[3] - 82 - 23, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST), $HauptGUI)
						GUISetIcon("Data\icon.ico")
						GUISetBkColor(0xFFFFFF)
						GUICtrlCreateLabel(sprache("GR_SHARE_LINK"), 8, 8, 105, 17)
						$_groovesharklink = GUICtrlCreateLabel(sprache("GR_SHARE_REQUESTLINK"), 8, 24, 351, 17)
						GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
						GUICtrlSetColor(-1, 0x0066CC)
						GUICtrlSetCursor(-1, 0)
						$copy = GUICtrlCreateButton(sprache("GR_SHARE_COPY"), 8, 48, 115, 25)
						$facebook = GUICtrlCreateButton(sprache("GR_SHARE_FACEBOOK"), 128, 48, 115, 25)
						$twitter = GUICtrlCreateButton(sprache("GR_SHARE_TWITTER"), 248, 48, 115, 25)
						GUISetState(@SW_SHOW)

						$Token = _GroovesharkGetToken($CommunicationToken, "getStreamKeyFromSongIDEx")
						$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?getStreamKeyFromSongIDEx")
						_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"header":{"token":"' & $Token & '","privacy":0,"session":"' & $SessionID & '","client":"htmlshark","country":{"DMA":501,"CC1":0,"CC2":0,"IPR":0,"CC3":0,"CC4":1073741824,"ID":223},"clientRevision":"20130520"},"method":"getStreamKeyFromSongIDEx","parameters":{"prefetch":false,"type":0,"mobile":false,"country":{"DMA":501,"CC1":0,"CC2":0,"IPR":0,"CC3":0,"CC4":1073741824,"ID":223},"songID":' & $SongInfo[$o][0] & '}}')
						_WinHttpReceiveResponse($h_openRequest)
						Local $data = ""
						Do
							$data &= _WinHttpReadData($h_openRequest)
						Until @error
						;MsgBox(0,"",$data)
						$filetoken = _StringBetween($data, 'FileToken":"', '",')
						If IsArray($filetoken) Then
							$groovesharklink = "http://grooveshark.com/s/s/" & $filetoken[0]
							GUICtrlSetData($_groovesharklink, $groovesharklink)
							While 1
								$nMsg_teilen = GUIGetMsg()
								Switch $nMsg_teilen
									Case $GUI_EVENT_CLOSE
										ExitLoop
									Case $_groovesharklink
										ShellExecute($groovesharklink)
									Case $copy
										ClipPut($groovesharklink)
									Case $twitter
										ShellExecute("http://twitter.com/home?status=" & $groovesharklink)
									Case $facebook
										ShellExecute("https://www.facebook.com/sharer/sharer.php?u=" & $groovesharklink)
								EndSwitch
							WEnd
							GUIDelete($teilengui)
						Else
							GUIDelete($teilengui)
							GUISetState(@SW_DISABLE, $HauptGUI)
							MsgBox(16, "GrooveLoad", sprache("GR_SHARE_ERROR"))
							GUISetState(@SW_ENABLE, $HauptGUI)
							WinActivate($HauptGUI)
						EndIf
					EndIf
				EndIf
			Next
		Next
	EndIf
	If UBound($SongInfo) = 0 Then
		If $doppeltloeschenstate = 1 Then
			GUICtrlSetState($GUI_Doppeltloeschen, $GUI_DISABLE)
			$doppeltloeschenstate = 0
		EndIf
	Else
		If $doppeltloeschenstate = 0 Then
			GUICtrlSetState($GUI_Doppeltloeschen, $GUI_ENABLE)
			$doppeltloeschenstate = 1
		EndIf
	EndIf
	If TimerDiff($nixgefundentimer) > 1000 Then
		$nixgefunden = False
	EndIf

	If _IsPressed("0D") And ControlGetFocus($HauptGUI) = "Edit2" And $aktivespannel = 1 And $nixgefunden = False Then
		$nMsg[0] = $GUI_ButtonSuche
	EndIf

	If $nr = 8 Then ; Für Hinweise
		IniWrite("Data\config.ini", "Erster Start", "Einführung", 1)
		GUIDelete($tutgui)
	EndIf
	If $dloeffnen = True Then
		$nMsg[0] = $GUI_Downloadeinstellungen
		$dloeffnen = False
	EndIf
	Switch $nMsg[0]
		Case $Link[0], $Link[1], $Link[2], $Link[3]
			For $i = 0 To 3
				If $nMsg[0] = $Link[$i] Then
					GUICtrlSetColor($Link[0], 0x000000)
					GUICtrlSetColor($Link[1], 0x000000)
					GUICtrlSetColor($Link[2], 0x000000)
					GUICtrlSetColor($Link[3], 0x000000)
					GUICtrlSetColor($Link[$i], 0x0066CC)
					GUICtrlSetImage($icon[0], "Data\ico\0.ico")
					GUICtrlSetImage($icon[1], "Data\ico\1.ico")
					GUICtrlSetImage($icon[2], "Data\ico\2.ico")
					GUICtrlSetImage($icon[3], "Data\ico\3.ico")
					GUICtrlSetImage($icon[$i], "Data\ico\" & $i & "-.ico")
					GUISetState(@SW_SHOW, $Pannel[$i])
					$aktivespannel = $i
				Else
					GUICtrlSetColor($Link[$i], 0x000000)
					GUICtrlSetImage($icon[$i], "Data\ico\" & $i & ".ico")
					GUISetState(@SW_HIDE, $Pannel[$i])
				EndIf
			Next
		Case $GUI_EVENT_CLOSE
			If $nMsg[1] = $HauptGUI Then
				If FileExists("Data\DLListe.txt") Then
					$nachfrage = MsgBox(65536 + 48 + 3, "GrooveLoad", sprache("GR_MSG_NOTEMPTY"), $HauptGUI)
					If $nachfrage = 7 Then ;T55
						FileDelete("Data\DLListe.txt")
						DirRemove (@ScriptDir & "\Data\tmp\",1)
						Exit
					ElseIf $nachfrage = 6 Then
						DirRemove (@ScriptDir & "\Data\tmp\",1)
						Exit
					EndIf
				Else
					DirRemove (@ScriptDir & "\Data\tmp\",1)
					Exit
				EndIf
			EndIf
			If $nMsg[1] = $Suche_GUI Then
				GUISetState(@SW_HIDE, $Suche_GUI)
			EndIf
			If $nMsg[1] = $DL_GUI Then
				GUISetState(@SW_HIDE, $DL_GUI)
			EndIf
		Case $dle
			$dloeffnen = True
		Case $weiter
			$nr = $nr + 1
			hinweise()
		Case $zurueck
			$nr = $nr - 1
			hinweise()
		Case $GUI_zuruecksetzen
			If MsgBox(4 + 32, "GrooveLoad", sprache("GR_RESET_SURE"), 0, $HauptGUI) = 6 Then
				FileDelete("Data\config.ini")
				FileDelete("Data\geheimwort.txt")
				FileClose($loghandle)
				FileDelete("Data\log.txt")
				FileDelete("Data\DLListe.txt")
				FileDelete("Data\cover.jpg")
				FileDelete("Data\Reinhören.txt")
				DirRemove (@ScriptDir & "\Data\tmp",1)
				FileDelete("Data\new.txt")
				FileDelete("Data\tmp.mp3")

				For $i = 0 To 5
					FileDelete("Data\cover\" & $i & ".jpg")
				Next
				If MsgBox(4, "GrooveLoad", sprache("GR_RESET_RESTART"), 0, $HauptGUI) = 6 Then ShellExecute("Data\AutoIt3.exe", '"' & @ScriptFullPath & '"')
				Exit
			EndIf
		Case $GUI_AufrufausDE
			GUISetState(@SW_DISABLE, $HauptGUI)
			$IPFuckGUI = GUICreate("GrooveLoad", 354, 177)
			GUISetIcon("Data\icon.ico")
			GUISetBkColor(0xFFFFFF)
			GUICtrlCreateLabel(sprache("GR_IPFUCK_DESCRIBTION"), 8, 8, 343, 78)
			$Firefox = GUICtrlCreateLabel(sprache("GR_IPFUCK_LINK") & " Firefox", 8, 95, 200, 17)
			GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
			GUICtrlSetColor(-1, 0x0066CC)
			GUICtrlSetCursor(-1, 0)
			$Chrome = GUICtrlCreateLabel(sprache("GR_IPFUCK_LINK") & " Chrome", 8, 119, 200, 17)
			GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
			GUICtrlSetColor(-1, 0x0066CC)
			GUICtrlSetCursor(-1, 0)
			$OKButton = GUICtrlCreateButton("OK", 139, 144, 75, 25)
			GUISetState(@SW_SHOW)
			While 1
				$nMsg = GUIGetMsg()
				Switch $nMsg
					Case $GUI_EVENT_CLOSE
						ExitLoop
					Case $OKButton
						ExitLoop
					Case $Firefox
						ShellExecute("https://addons.mozilla.org/de/firefox/addon/ipflood/")
					Case $Chrome
						ShellExecute("https://chrome.google.com/webstore/detail/ipfuck/bjgmbpodpcgmnpfjmigcckcjfldcicnd")
				EndSwitch
			WEnd
			GUISetState(@SW_ENABLE, $HauptGUI)
			WinActivate($HauptGUI)
			GUIDelete($IPFuckGUI)
		Case $GUI_sprache
			If xMsgBox(4, "GrooveLoad", sprache("GR_LNG_CURRENT") & " " & $_sprache, "OK", sprache("GR_LNG_CHANGE")) = 7 Then
				IniWrite("Data\config.ini", "Sprache", "Sprache", -1)
				ShellExecute("Data\AutoIt3.exe", '"' & @ScriptFullPath & '"')
				Exit
			EndIf
		Case $GUI_feedback
			If MsgBox(64 + 1, "GrooveLoad", sprache("GR_FEEDBACK_DESCRIPTION"), 0, $HauptGUI) = 1 Then ShellExecute("http://hegi.pfweb.eu/grooveload/kontakt/?l=" & $_sprache)
		Case $GUI_Verbindungseinstellungen
			GUISetState(@SW_DISABLE, $HauptGUI)
			Interneteinstellungen()
			GUISetState(@SW_ENABLE, $HauptGUI)
			WinActivate($HauptGUI)
		Case $GUI_Downloadeinstellungen
			GUISetState(@SW_DISABLE, $HauptGUI)
			$ordnerpfad = IniRead("Data\config.ini", "Downloadeinstellungen", "Ordnerpfad", @ScriptDir & "\Downloads")
			$GUI_Downloadeinstellungenfenster = GUICreate(sprache("GR_GUI_DLSETTINGS"), 600, 670)
			GUISetIcon("Data\icon.ico")
			GUICtrlCreateLabel(sprache("GR_DLGUI_PATH"), 8, 8, 500, 17)
			$GUI_Downloadpfad = GUICtrlCreateLabel($ordnerpfad, 16, 24, 184 + 184, 17 + 10)
			$GUI_DLPfadsuchen = GUICtrlCreateButton(sprache("GR_DLGUI_BROWSE"), 16, 40 + 17, 91, 25)
			GUICtrlCreateLabel(sprache("GR_DLGUI_NAMES"), 8, 97, 350, 17)
			$GUI_hilfeDL = GUICtrlCreateLabel("?", 370, 97, 17, 17)
			GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
			GUICtrlSetColor(-1, 0x0066CC)
			GUICtrlSetCursor(-1, 0)
			GUICtrlCreateLabel(sprache("GR_DLGUI_USABLE") & ": <" & sprache("GR_DLGUI_TITLE") & ">, <" & sprache("GR_DLGUI_TITLE") & ">, <" & sprache("GR_DLGUI_ALBUM") & ">", 16, 96 + 17, 249, 17)


			$bennungsmuster = IniRead("Data\config.ini", "Downloadeinstellungen", "Benenung", "<Interpret> - <Titel>")

			$bennungsmuster = StringReplace($bennungsmuster, "Interpret", sprache("GR_DLGUI_ARTIST"))
			$bennungsmuster = StringReplace($bennungsmuster, "Album", sprache("GR_DLGUI_ALBUM"))
			$bennungsmuster = StringReplace($bennungsmuster, "Titel", sprache("GR_DLGUI_TITLE"))

			$GUI_DLName = GUICtrlCreateInput($bennungsmuster, 16, 112 + 17, 121 + 100, 21)
			GUICtrlCreateLabel(".mp3", 140 + 100, 114 + 17)
			$GUI_DLEinstellungenReset = GUICtrlCreateButton(sprache("GR_DLGUI_RESET"), 192 + 100, 112 + 17, 83, 21)
			$GUI_DLEinstellungenSave = GUICtrlCreateButton(sprache("GR_DLGUI_SAVE"), 16, 635, 75, 25)

			GUICtrlCreateLabel(sprache("GR_DLGUI_AFTER"), 8, 166, 200, 17)

			$GUI_Winexplorer = GUICtrlCreateCheckbox(sprache("GR_DLGUI_EXPLORER"), 16, 184, 577, 17)
			GUICtrlSetState(-1, IniRead("Data\config.ini", "Downloadeinstellungen", "Winexplorer", 4))

			$GUI_Playlist = GUICtrlCreateCheckbox(sprache("GR_DLGUI_PLAYLIST"), 16, 208, 577, 17)
			GUICtrlSetState(-1, IniRead("Data\config.ini", "Downloadeinstellungen", "Playlist", 4))
			GUICtrlCreateLabel(sprache("GR_DLGUI_PLAYLISTTEXT"), 32, 226, 565, 39)

			$GUI_MP3TAG = GUICtrlCreateCheckbox(sprache("GR_DLGUI_MP3TAG"), 16, 272, 577, 17)
			GUICtrlSetState(-1, IniRead("Data\config.ini", "Downloadeinstellungen", "MP3TAG", 4))
			GUICtrlCreateLabel(sprache("GR_DLGUI_MP3TAGTEXT"), 32, 290, 565, 49)
			$GUI_MP3TAG_Pfad = GUICtrlCreateLabel(sprache("GR_DLGUI_MP3TAGPATH") & ": " & IniRead("Data\config.ini", "Downloadeinstellungen", "PfadMP3TAG", sprache("GR_DLGUI_NOTSPECIFIED")), 32, 352, 490, 17)
			$GUI_MP3TAG_Pfad_aendern = GUICtrlCreateButton(sprache("GR_LNG_CHANGE"), 520, 344, 75, 25)
			$GUI_MP3TAG_DL = GUICtrlCreateLabel(sprache("GR_DLGUI_MP3TAGDL"), 32, 376, 230, 17)
			GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
			GUICtrlSetColor(-1, 0x0066CC)
			GUICtrlSetCursor(-1, 0)

			GUICtrlCreateLabel(sprache("GR_DLGUI_MORE"), 8, 408, 110, 17)

			$GUI_Cover = GUICtrlCreateCheckbox(sprache("GR_DLGUI_COVER"), 16, 426, 577, 17)
			GUICtrlSetState(-1, IniRead("Data\config.ini", "Downloadeinstellungen", "Cover", 4))
			GUICtrlCreateLabel(sprache("GR_DLGUI_COVERTEXT"), 32, 448, 563, 48)
			Dim $Radio[4]
			GUIStartGroup()
			$Radio[1] = GUICtrlCreateRadio(sprache("GR_DLGUI_COVERMP3"), 32, 500, 561, 17)
			$Radio[2] = GUICtrlCreateRadio(sprache("GR_DLGUI_COVERJPG"), 32, 516, 561, 17)
			$Radio[3] = GUICtrlCreateRadio(sprache("GR_DLGUI_COVERMP3JPG"), 32, 532, 561, 17)
			GUICtrlSetState($Radio[IniRead("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", 1)], 1)
			GUICtrlCreateLabel(sprache("GR_DLGUI_NAMEEXIST"), 8, 560)
			GUIStartGroup()
			GUICtrlCreateRadio(sprache("GR_DLGUI_DIFFERENTNAME"), 32, 575, 561, 17)
			GUICtrlSetState(-1, 1)
			$ueberschreiben = GUICtrlCreateRadio(sprache("GR_DLGUI_OVERWRITE"), 32, 592, 561, 17)
			If IniRead("Data\config.ini", "Downloadeinstellungen", "Überschreiben", 4) = 1 Then
				GUICtrlSetState($ueberschreiben, 1)
			EndIf
			GUISetState(@SW_SHOW)
			$coverradiosaktiv = True
			While 1
				If GUICtrlRead($GUI_Cover) = 4 Then
					If $coverradiosaktiv = True Then
						GUICtrlSetState($Radio[1], $GUI_DISABLE)
						GUICtrlSetState($Radio[2], $GUI_DISABLE)
						GUICtrlSetState($Radio[3], $GUI_DISABLE)
						$coverradiosaktiv = False
					EndIf
				Else
					If $coverradiosaktiv = False Then
						GUICtrlSetState($Radio[1], $GUI_ENABLE)
						GUICtrlSetState($Radio[2], $GUI_ENABLE)
						GUICtrlSetState($Radio[3], $GUI_ENABLE)
						$coverradiosaktiv = True
					EndIf
				EndIf
				$nMsg = GUIGetMsg()
				Switch $nMsg
					Case $GUI_EVENT_CLOSE
						GUISetState(@SW_ENABLE, $HauptGUI)
						WinActivate($HauptGUI)
						GUIDelete($GUI_Downloadeinstellungenfenster)
						ExitLoop
					Case $GUI_hilfeDL
						MsgBox(64, "GrooveLoad", StringReplace(sprache("GR_DLGUI_NAMESTEXT"), "[CRLF]", @CRLF), 0, $GUI_Downloadeinstellungenfenster)
					Case $GUI_DLEinstellungenReset
						GUICtrlSetData($GUI_DLName,"<" & sprache("GR_DLGUI_ARTIST") & "> - <" & sprache("GR_DLGUI_TITLE") & ">")
					Case $GUI_MP3TAG_Pfad_aendern
						$angegebener_Pfad_MP3TAG = FileOpenDialog("Mp3tag.exe", "", "(Mp3tag.exe)", 1)
						If $angegebener_Pfad_MP3TAG <> "" Then
							FileChangeDir(@ScriptDir)
							GUICtrlSetData($GUI_MP3TAG_Pfad, sprache("GR_DLGUI_MP3TAGPATH") & ": " & $angegebener_Pfad_MP3TAG)
						EndIf
					Case $GUI_MP3TAG_DL
						ShellExecute("http://www.mp3tag.de/en/download.html")
					Case $GUI_DLEinstellungenSave
						If $GUI_DLName = "" Then
							MsgBox(16, "Grooveshark Dowloader", sprache("GR_DLGUI_RULEMISSING"))
						ElseIf StringReplace(GUICtrlRead($GUI_MP3TAG_Pfad), sprache("GR_DLGUI_MP3TAGPATH") & ": ", "") = sprache("GR_DLGUI_NOTSPECIFIED") And GUICtrlRead($GUI_MP3TAG) = 1 Then
							MsgBox(16, "Grooveload", sprache("GR_DLGUI_MP3TAGPATHMISSING"))
						Else
							IniWrite("Data\config.ini", "Downloadeinstellungen", "MP3TAG", GUICtrlRead($GUI_MP3TAG))
							IniWrite("Data\config.ini", "Downloadeinstellungen", "PfadMP3TAG", StringReplace(GUICtrlRead($GUI_MP3TAG_Pfad), sprache("GR_DLGUI_MP3TAGPATH") & ": ", ""))
							IniWrite("Data\config.ini", "Downloadeinstellungen", "Ordnerpfad", $ordnerpfad)

							$bennungsmuster = GUICtrlRead($GUI_DLName)
							$bennungsmuster = StringReplace($bennungsmuster, sprache("GR_DLGUI_ARTIST"), "Interpret")
							$bennungsmuster = StringReplace($bennungsmuster, sprache("GR_DLGUI_ALBUM"), "Album")
							$bennungsmuster = StringReplace($bennungsmuster, sprache("GR_DLGUI_TITLE"), "Titel")
							IniWrite("Data\config.ini", "Downloadeinstellungen", "Benenung", $bennungsmuster)
							IniWrite("Data\config.ini", "Downloadeinstellungen", "Winexplorer", GUICtrlRead($GUI_Winexplorer))
							IniWrite("Data\config.ini", "Downloadeinstellungen", "Playlist", GUICtrlRead($GUI_Playlist))
							IniWrite("Data\config.ini", "Downloadeinstellungen", "Cover", GUICtrlRead($GUI_Cover))
							For $i = 1 To 3
								If GUICtrlRead($Radio[$i]) = 1 Then
									IniWrite("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", $i)
									ExitLoop
								EndIf
							Next
							IniWrite("Data\config.ini", "Downloadeinstellungen", "Überschreiben", GUICtrlRead($ueberschreiben))
							GUISetState(@SW_ENABLE, $HauptGUI)
							WinActivate($HauptGUI)
							GUIDelete($GUI_Downloadeinstellungenfenster)
							ExitLoop
						EndIf
					Case $GUI_DLPfadsuchen
						$ordnerpfadneu = FileSelectFolder(sprache("GR_DLGUI_NEWPATH"), "", 1 + 4, @ScriptDir)
						If $ordnerpfadneu <> "" Then $ordnerpfad = $ordnerpfadneu
						GUICtrlSetData($GUI_Downloadpfad, $ordnerpfad)

				EndSwitch
			WEnd
		Case $GUI_Doppeltloeschen
			If UBound($SongInfo) <> 0 Then
				_GUI_ProgressAn()
				GUI_Deaktivieren()
				_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($GUI_ListeSuchergebnisse))
				Dim $zuloeschen[0]
				For $i = 0 To UBound($SongInfo) - 1
					If _ArraySearch($zuloeschen, $i) = -1 Then
						;ConsoleWrite ("-Suche nach Dopplungen zu " & $SongInfo[$i][1] & " - ID:" & $SongInfo[$i][0] & @CRLF)
						For $z = 0 To UBound($SongInfo) - 1
							If $SongInfo[$i][1] = $SongInfo[$z][1] And $SongInfo[$z][0] <> $SongInfo[$i][0] Then
								;ConsoleWrite ("Gefunden: " & $SongInfo[$z][1] & " - ID:" & $SongInfo[$z][0] & " - Position: " &$z& @CRLF)
								ReDim $zuloeschen[UBound($zuloeschen) + 1]
								$zuloeschen[UBound($zuloeschen) - 1] = $z
							EndIf
						Next
					EndIf
				Next
				;_ArrayDisplay ($zuloeschen)
				$zuloeschen = _ArrayUnique($zuloeschen, Default, Default, Default, 0)

				;_ArrayDisplay ($zuloeschen)
				_ArraySort($zuloeschen, 1)
				;_ArrayDisplay ($zuloeschen)
				For $i = 0 To UBound($zuloeschen) - 1
					_ArrayDelete($SongInfo, $zuloeschen[$i])
				Next
				For $i = 0 To UBound($SongInfo) - 1
					$eintragliste = GUICtrlCreateListViewItem($SongInfo[$i][1] & "|" & $SongInfo[$i][3] & "|" & $SongInfo[$i][2], $GUI_ListeSuchergebnisse)
					$menue = GUICtrlCreateContextMenu($eintragliste)
					$kontextmenue[$i][0] = GUICtrlCreateMenuItem(sprache("GR_GUI_ALBUMSEARCH"), $menue) ;T47
					$kontextmenue[$i][1] = GUICtrlCreateMenuItem(sprache("GR_GUI_ARTISTSEARCH"), $menue) ;T48
					$kontextmenue[$i][2] = GUICtrlCreateMenuItem(sprache("GR_GUI_PREVIEW"), $menue);T49
					$kontextmenue[$i][3] = GUICtrlCreateMenuItem(sprache("GR_GUI_SHARE"), $menue)
				Next
				;ConsoleWrite ("----------------------------------------------" & @CRLF)
				_GUI_ProgressAus()
				GUI_Aktivieren()
			EndIf
		Case $GUI_AuswahlSuche
			$hauptguipos = WinGetPos($HauptGUI)
			WinMove(sprache("GR_GUI_SEARCHGUI"), "", $hauptguipos[0] + 755, $hauptguipos[1] + 320)
			GUISetState(@SW_SHOW, $Suche_GUI)
		Case $Suche_Alle
			_GUICtrlListView_SetItemChecked($GUI_ListeSuchergebnisse, -1, True)
			GUISetState(@SW_HIDE, $Suche_GUI)
		Case $Suche_AlleAb
			_GUICtrlListView_SetItemChecked($GUI_ListeSuchergebnisse, -1, False)
			GUISetState(@SW_HIDE, $Suche_GUI)
		Case $Suche_Umkehren
			For $i = 0 To _GUICtrlListView_GetItemCount($GUI_ListeSuchergebnisse) - 1
				If _GUICtrlListView_GetItemChecked($GUI_ListeSuchergebnisse, $i) Then
					_GUICtrlListView_SetItemChecked($GUI_ListeSuchergebnisse, $i, False)
				Else
					_GUICtrlListView_SetItemChecked($GUI_ListeSuchergebnisse, $i, True)
				EndIf
			Next
			GUISetState(@SW_HIDE, $Suche_GUI)
		Case $GUI_AuswahlDL
			$hauptguipos = WinGetPos($HauptGUI)
			WinMove(sprache("GR_GUI_DOWNLOADLIST"), "", $hauptguipos[0] + 755, $hauptguipos[1] + 320)
			GUISetState(@SW_SHOW, $DL_GUI)
		Case $GUI_DLListeleeren
			FileDelete("Data\DLListe.txt")
			;_ArrayDisplay ($SongInfosFuerDLListe)
			For $i = _GUICtrlListView_GetItemCount($GUI_DLListe) - 1 To 0 Step -1
				If _GUICtrlListView_GetItemChecked($GUI_DLListe, $i) Then
					If UBound($SongInfosFuerDLListe) = 1 Then
						Dim $SongInfosFuerDLListe[1][7]
						_GUICtrlListView_DeleteItem(GUICtrlGetHandle($GUI_DLListe), 0)
					Else
						_ArrayDelete($SongInfosFuerDLListe, $i)
						_GUICtrlListView_DeleteItem(GUICtrlGetHandle($GUI_DLListe), $i)
					EndIf
				EndIf
			Next
			For $i = 0 To UBound($SongInfosFuerDLListe) - 1
				If $SongInfosFuerDLListe[$i][0] <> "" Then FileWrite("Data\DLListe.txt", $SongInfosFuerDLListe[$i][0] & "|" & $SongInfosFuerDLListe[$i][1] & "|" & $SongInfosFuerDLListe[$i][2] & "|" & $SongInfosFuerDLListe[$i][3] & "|" & $SongInfosFuerDLListe[$i][4] & @CRLF)
			Next
			;_ArrayDisplay ($SongInfosFuerDLListe)
		Case $DL_Alle
			_GUICtrlListView_SetItemChecked($GUI_DLListe, -1, True)
			GUISetState(@SW_HIDE, $DL_GUI)
		Case $DL_AlleAb
			_GUICtrlListView_SetItemChecked($GUI_DLListe, -1, False)
			GUISetState(@SW_HIDE, $DL_GUI)
		Case $DL_Umkehren
			For $i = 0 To _GUICtrlListView_GetItemCount($GUI_DLListe) - 1
				If _GUICtrlListView_GetItemChecked($GUI_DLListe, $i) Then
					_GUICtrlListView_SetItemChecked($GUI_DLListe, $i, False)
				Else
					_GUICtrlListView_SetItemChecked($GUI_DLListe, $i, True)
				EndIf
			Next
			GUISetState(@SW_HIDE, $DL_GUI)
		Case $GUI_ButtonBeliebteLieder
			_GUI_ProgressAn()
			GUI_Deaktivieren()
			_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($GUI_ListeSuchergebnisse))
			;Suche nach beliebten Liedern
			$Token = _GroovesharkGetToken($CommunicationToken, "popularGetSongs")

			$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
			$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?popularGetSongs")
			_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"parameters":{},"header":{"session": "' & $SessionID & '","token": "' & $Token & '","clientRevision":"20130520","client":"htmlshark","country":{"DMA":0,"CC1":0,"IPR":0,"CC2":0,"CC3":0,"CC4":1073741824,"ID":223}},"method":"popularGetSongs"}')
			_WinHttpReceiveResponse($h_openRequest)

			Local $data = ""
			Do
				$data &= _WinHttpReadData($h_openRequest)
			Until @error
			_Log("Beliebte Lieder: " & $data)
			;MsgBox (0,"",$data)
			If StringInStr($data, "invalid token") <> 0 Then
				GUISetState(@SW_DISABLE, $HauptGUI)
				MsgBox(16, "GrooveLoad", sprache("GR_MSG_SECRETWORD"), 0, $HauptGUI) ;T45
				GUISetState(@SW_ENABLE, $HauptGUI)
				WinActivate($HauptGUI)
			Else
				$SongID = _StringBetween($data, 'SongID":"', '","')
				$SongName = _StringBetween($data, '"Name":"', '","')
				$AlbumName = _StringBetween($data, 'AlbumName":"', '","')
				$ArtistName = _StringBetween($data, 'ArtistName":"', '","')
				$ArtistID = _StringBetween($data, 'ArtistID":"', '","')
				$AlbumID = _StringBetween($data, 'AlbumID":"', '","')
				$cover = _StringBetween($data, '"CoverArtFilename":', ",")
				;_ArrayDisplay ($cover,"")
				;_ArrayDisplay ($SongName,"Name")
				;_ArrayDisplay ($AlbumName,"Albumname")
				;_ArrayDisplay ($ArtistName,"Interpret")

				If Not IsArray($SongID) Or Not IsArray($SongName) Or Not IsArray($AlbumName) Or Not IsArray($ArtistName) Or Not IsArray($ArtistID) Or Not IsArray($AlbumID) Or Not IsArray($cover) Then
					$SongInfo = ""
					MsgBox(16, "GrooveLoad", sprache("GR_MSG_SEARCHERROR"), 0, $HauptGUI) ;T84
				Else

					Dim $SongInfo[UBound($cover)][7]
					Dim $kontextmenue[UBound($cover)][4]

					For $i = 0 To UBound($cover) - 1
						$SongInfo[$i][0] = $SongID[$i]
						$SongInfo[$i][1] = $SongName[$i]
						$SongInfo[$i][2] = $AlbumName[$i]
						$SongInfo[$i][3] = $ArtistName[$i]
						$SongInfo[$i][4] = $ArtistID[$i]
						$SongInfo[$i][5] = $AlbumID[$i]
						$SongInfo[$i][6] = $cover[$i]
						For $k = 1 To 3
							$SongInfo[$i][$k] = fromUnicode($SongInfo[$i][$k])
						Next
						$eintragliste = GUICtrlCreateListViewItem($SongInfo[$i][1] & "|" & $SongInfo[$i][3] & "|" & $SongInfo[$i][2], $GUI_ListeSuchergebnisse)
						$menue = GUICtrlCreateContextMenu($eintragliste)
						$kontextmenue[$i][0] = GUICtrlCreateMenuItem(sprache("GR_GUI_ALBUMSEARCH"), $menue)
						$kontextmenue[$i][1] = GUICtrlCreateMenuItem(sprache("GR_GUI_ARTISTSEARCH"), $menue)
						$kontextmenue[$i][2] = GUICtrlCreateMenuItem(sprache("GR_GUI_PREVIEW"), $menue)
						$kontextmenue[$i][3] = GUICtrlCreateMenuItem(sprache("GR_GUI_SHARE"), $menue)
					Next

				EndIf
			EndIf

			GUI_Aktivieren()
			_GUI_ProgressAus()

		Case $GUI_ButtonSuche
			_GUI_ProgressAn()
			GUI_Deaktivieren()
			_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($GUI_ListeSuchergebnisse))
			$Suchbegriff = GUICtrlRead($GUI_EingabeSuche)
			$Suchbegriff = toUnicode($Suchbegriff)

			;Suche nach $Suchbegriff
			$Token = _GroovesharkGetToken($CommunicationToken, "getResultsFromSearch")

			$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
			$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?getResultsFromSearch")
			_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"parameters":{"query": "' & $Suchbegriff & '","type": "Songs"},"header":{"session": "' & $SessionID & '","token": "' & $Token & '","clientRevision":"20130520","client":"htmlshark","country":{"DMA":0,"CC1":0,"IPR":0,"CC2":0,"CC3":0,"CC4":1073741824,"ID":223}},"method":"getResultsFromSearch"}')
			_WinHttpReceiveResponse($h_openRequest)

			Local $data = ""
			Do
				$data &= _WinHttpReadData($h_openRequest)
			Until @error
			_Log("Suche " & $Suchbegriff & ": " & $data)
			;MsgBox (0,"",$data)
			If StringInStr($data, "invalid token") <> 0 Then
				GUISetState(@SW_DISABLE, $HauptGUI)
				MsgBox(16, "GrooveLoad", sprache("GR_MSG_SECRETWORD"), 0, $HauptGUI) ;T45
				GUISetState(@SW_ENABLE, $HauptGUI)
				WinActivate($HauptGUI)
			Else
				$SongID = _StringBetween($data, 'SongID":"', '","')
				$SongName = _StringBetween($data, 'SongName":"', '","')
				$AlbumName = _StringBetween($data, 'AlbumName":"', '","')
				$ArtistName = _StringBetween($data, 'ArtistName":"', '","')
				$ArtistID = _StringBetween($data, 'ArtistID":"', '","')
				$AlbumID = _StringBetween($data, 'AlbumID":"', '","')
				$cover = _StringBetween($data, '"CoverArtFilename":', ",")
				;_ArrayDisplay ($SongID)
				;_ArrayDisplay ($cover)

				If Not IsArray($SongID) Or Not IsArray($SongName) Or Not IsArray($AlbumName) Or Not IsArray($ArtistName) Or Not IsArray($ArtistID) Or Not IsArray($AlbumID) Or Not IsArray($cover) Then
					$SongInfo = ""
					MsgBox(16, "GrooveLoad", sprache("GR_MSG_NOTHINGFOUND") & @CRLF & fromUnicode($Suchbegriff), 0, $HauptGUI) ;T85
					$nixgefunden = True
					$nixgefundentimer = TimerInit()
				Else
					Dim $SongInfo[UBound($cover)][7]
					Dim $kontextmenue[UBound($cover)][4]

					For $i = 0 To UBound($cover) - 1
						$SongInfo[$i][0] = $SongID[$i]
						$SongInfo[$i][1] = $SongName[$i]
						$SongInfo[$i][2] = $AlbumName[$i]
						$SongInfo[$i][3] = $ArtistName[$i]
						$SongInfo[$i][4] = $ArtistID[$i]
						$SongInfo[$i][5] = $AlbumID[$i]
						$SongInfo[$i][6] = $cover[$i]
						For $k = 1 To 3
							$SongInfo[$i][$k] = fromUnicode($SongInfo[$i][$k])
						Next
						$eintragliste = GUICtrlCreateListViewItem($SongInfo[$i][1] & "|" & $SongInfo[$i][3] & "|" & $SongInfo[$i][2], $GUI_ListeSuchergebnisse)
						$menue = GUICtrlCreateContextMenu($eintragliste)

						$kontextmenue[$i][0] = GUICtrlCreateMenuItem(sprache("GR_GUI_ALBUMSEARCH"), $menue)
						$kontextmenue[$i][1] = GUICtrlCreateMenuItem(sprache("GR_GUI_ARTISTSEARCH"), $menue)
						$kontextmenue[$i][2] = GUICtrlCreateMenuItem(sprache("GR_GUI_PREVIEW"), $menue)
						$kontextmenue[$i][3] = GUICtrlCreateMenuItem(sprache("GR_GUI_SHARE"), $menue)
					Next

				EndIf
			EndIf

			GUI_Aktivieren()
			_GUI_ProgressAus()

		Case $GUI_DLListeHinzufuegen
			$neudazu = 0
			If UBound($SongInfosFuerDLListe) = 0 Then
				$a = 0
			Else
				If $SongInfosFuerDLListe[UBound($SongInfosFuerDLListe) - 1][0] = "" Then
					$a = 0
				Else
					$a = UBound($SongInfosFuerDLListe)
				EndIf
			EndIf

			For $i = 0 To _GUICtrlListView_GetItemCount($GUI_ListeSuchergebnisse) - 1
				If _GUICtrlListView_GetItemChecked($GUI_ListeSuchergebnisse, $i) Then

					$aItemText = _GUICtrlListView_GetItemTextArray($GUI_ListeSuchergebnisse, $i)
					GUICtrlCreateListViewItem($aItemText[1] & "|" & $aItemText[2] & "|" & $aItemText[3], $GUI_DLListe)
					ReDim $SongInfosFuerDLListe[$a + 1][7]
					$SongInfosFuerDLListe[$a][0] = $SongInfo[$i][0] ; Song ID
					$SongInfosFuerDLListe[$a][1] = $SongInfo[$i][1] ; Titel
					$SongInfosFuerDLListe[$a][2] = $SongInfo[$i][3] ; Interpret
					$SongInfosFuerDLListe[$a][3] = $SongInfo[$i][2] ; Album
					$SongInfosFuerDLListe[$a][4] = $SongInfo[$i][6] ; Cover-Info
					FileWrite("Data\DLListe.txt", $SongInfosFuerDLListe[$a][0] & "|" & $SongInfosFuerDLListe[$a][1] & "|" & $SongInfosFuerDLListe[$a][2] & "|" & $SongInfosFuerDLListe[$a][3] & "|" & $SongInfosFuerDLListe[$a][4] & @CRLF)
					$a = $a + 1
					$neudazu = $neudazu + 1
				EndIf
			Next
			If $neudazu = 1 Then
				$fadetext = $SongInfosFuerDLListe[$a - 1][1] & " " & sprache("GR_MSG_ADDTODLL")
			Else
				$fadetext = $neudazu & " " & sprache ("GR_MSG_ADDTODLLMORE")
			EndIf

			_GUICtrlListView_SetItemChecked($GUI_ListeSuchergebnisse, -1, False)
			Fadelabel()
			;_ArrayDisplay ($SongInfosFuerDLListe)


		Case $GUI_Download;

			;_ArrayDisplay ($SongInfosFuerDLListe)
			If _GUICtrlListView_GetItemCount($GUI_DLListe) - 1 = -1 Then
				GUISetState(@SW_DISABLE, $HauptGUI)
				MsgBox(0, "GrooveLoad", sprache("GR_MSG_EMPTY"))
				GUISetState(@SW_ENABLE, $HauptGUI)
				WinActivate($HauptGUI)
			Else
				$SongInfosFuerDLListeBackup = $SongInfosFuerDLListe
				$bytesread = IniRead("Data\config.ini", "Downloadeinstellungen", "NumberOfBytesToRead", 150000)
				_Log("NumberOfBytesToRead: " & $bytesread)
				GUI_Deaktivieren()
				_GUI_ProgressAn()
				_ConsoleWrite(sprache("GR_MSG_STREAMDATA"))
				$hfileplaylist = IniRead("Data\config.ini", "Downloadeinstellungen", "Ordnerpfad", @ScriptDir & "\Downloads") & "\" & @MDAY & "." & @MON & "." & @YEAR & " " & @HOUR & "." & @MIN & ".m3u"
				For $i = 0 To _GUICtrlListView_GetItemCount($GUI_DLListe) - 1
					If TimerDiff($time) > 540000 Then ; 540000 ms = 9 Minuten

						$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
						For $z = 1 To 2
							_ConsoleWrite(sprache("GR_MSG_REFRESH"))
							$SessionID = _GroovesharkGetSessionID($Connection)
							$CommunicationToken = _GroovesharkGetCommunicationToken($SessionID, $Connection)
							If $SessionID <> 1 And $CommunicationToken <> 1 Then
								ExitLoop
							EndIf
						Next
						If $SessionID = -1 Or $CommunicationToken = -1 Then
							MsgBox(16, "GrooveLoad", sprache("GR_MSG_ERRORSESSIONID")) ;T44
							Exit
						EndIf
						_ConsoleWrite(sprache("GR_MSG_CONNECTION"))
						$time = TimerInit()
					EndIf
					;MsgBox (0,"Streamdaten ermitteln von",$SongInfosFuerDLListe[$i][0] & @crlf & $SongInfosFuerDLListe[$i][1])
					GUICtrlSetData($GUI_FooterText, sprache("GR_MSG_STREAMDATA") & " (" & $i + 1 & "/" & UBound($SongInfosFuerDLListe) & ")")
					$SongID_Download = $SongInfosFuerDLListe[$i][0]
					; Ermitteln der Streamdaten vom gewählten Song
					For $g = 1 To 4
						$Token = _GroovesharkGetToken($CommunicationToken, "getStreamKeyFromSongIDEx")

						$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
						$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?getStreamKeyFromSongIDEx")
						_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"header":{"token":"' & $Token & '","privacy":0,"session":"' & $SessionID & '","client":"htmlshark","country":{"DMA":501,"CC1":0,"CC2":0,"IPR":0,"CC3":0,"CC4":1073741824,"ID":223},"clientRevision":"20130520"},"method":"getStreamKeyFromSongIDEx","parameters":{"prefetch":false,"type":0,"mobile":false,"country":{"DMA":501,"CC1":0,"CC2":0,"IPR":0,"CC3":0,"CC4":1073741824,"ID":223},"songID":' & $SongID_Download & '}}')

						_WinHttpReceiveResponse($h_openRequest)


						Local $data = ""
						Do
							$data &= _WinHttpReadData($h_openRequest)
						Until @error
						_Log("Streamdaten von " & $SongInfosFuerDLListe[$i][0] & "-" & $SongInfosFuerDLListe[$i][1] & ": " & $data)
						;MsgBox(0,"",$data)
						$StreamIP = _StringBetween($data, 'ip":"', '"}}')
						$StreamKey = _StringBetween($data, 'streamKey":"', '",')
						If Not IsArray($StreamIP) Or Not IsArray($StreamKey) Then
							$error = 1
						Else
							$error = 0
							$StreamIP = $StreamIP[0]
							$StreamKey = $StreamKey[0]
							;ConsoleWrite ("Stream IP: " & $StreamIP & @CRLF)
							;ConsoleWrite ("Stream Key: " & $StreamKey & @CRLF)
							$SongInfosFuerDLListe[$i][5] = $StreamIP
							$SongInfosFuerDLListe[$i][6] = $StreamKey
							ExitLoop
						EndIf
						_ConsoleWrite(sprache("GR_MSG_TRYRELOAD"))
					Next
					If $error = 1 Then
						MsgBox(16, "GrooveLoad", $SongInfosFuerDLListe[$i][1] & " " & sprache("GR_MSG_CANNOTDOWNLOAD"))
						$SongInfosFuerDLListe[$i][5] = "Error"
					EndIf
				Next

				;		$SongInfosFuerDLListe[0][5] = "Error"
				;		$SongInfosFuerDLListe[2][5] = "Error"
				;		$SongInfosFuerDLListe[3][5] = "Error"
				;_ArrayDisplay ($SongInfosFuerDLListe)

				Dim $dateinamen[UBound($SongInfosFuerDLListe)]
				$dlabbruch = 0

				Dim $auflistung[UBound($SongInfosFuerDLListe)][8]

				For $i = 0 To UBound($SongInfosFuerDLListe) - 1
					; Titel, Interpret und Album in Array für finale Auflistung übertragen
					$auflistung[$i][0] = "Error" ; Status, wird bei Erfolg in OK geändert
					$auflistung[$i][1] = $SongInfosFuerDLListe[$i][1] ; Titel
					$auflistung[$i][2] = $SongInfosFuerDLListe[$i][3] ; Interpret
					$auflistung[$i][3] = $SongInfosFuerDLListe[$i][2] ; Album
					$auflistung[$i][4] = "" ; Pfad
					$auflistung[$i][5] = "" ; Pfad zum Cover
					$auflistung[$i][6] = "" ; Dateigröße
					$auflistung[$i][7] = "" ; Downloadzeit
				Next

				For $i = 0 To UBound($SongInfosFuerDLListe) - 1
					$auflistung[$i][0] = "OK" ; Status

					If $SongInfosFuerDLListe[$i][5] <> "Error" Then
						;Download
						;_ConsoleWrite ("Download von " & $SongInfosFuerDLListe[$i][1])

						GUICtrlSetData($GUI_FooterText, "Download " & $i + 1 & "/" & UBound($SongInfosFuerDLListe) & " - " & $SongInfosFuerDLListe[$i][1])
						$Connection = _WinHttpConnect($hOpen, $SongInfosFuerDLListe[$i][5])

						$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/stream.php")
						_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/x-www-form-urlencoded", 'streamKey=' & $SongInfosFuerDLListe[$i][6])

						_WinHttpReceiveResponse($h_openRequest)
						$benennungsvariable = IniRead("Data\config.ini", "Downloadeinstellungen", "Benenung", "<Interpret> - <Titel>")
						$SongInfosFuerDLListe[$i][1] = StringReplace($SongInfosFuerDLListe[$i][1], ":", "")
						$SongInfosFuerDLListe[$i][2] = StringReplace($SongInfosFuerDLListe[$i][2], ":", "")
						$SongInfosFuerDLListe[$i][3] = StringReplace($SongInfosFuerDLListe[$i][3], ":", "")

						$benennungsvariable = StringReplace($benennungsvariable, "<Titel>", $SongInfosFuerDLListe[$i][1])
						$benennungsvariable = StringReplace($benennungsvariable, "<Interpret>", $SongInfosFuerDLListe[$i][2])
						$benennungsvariable = StringReplace($benennungsvariable, "<Album>", $SongInfosFuerDLListe[$i][3])
						$PfadohneDatei = ""
						$pfadteile = StringSplit($benennungsvariable, "\")
						;	_ArrayDisplay ($pfadteile)
						For $g = 1 To $pfadteile[0] - 1
							$PfadohneDatei = $PfadohneDatei & $pfadteile[$g] & "\"
						Next
						;	MsgBox (0,"",$PfadohneDatei)
						; Verbotene Zeichen entfernen
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], "<", "")
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], ">", "")
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], "?", "")
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], '"', "")
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], ":", "")
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], "|", "")
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], "/", "")
						$pfadteile[$pfadteile[0]] = StringReplace($pfadteile[$pfadteile[0]], "*", "")

						DirCreate(IniRead("Data\config.ini", "Downloadeinstellungen", "Ordnerpfad", @ScriptDir & "\Downloads") & "\" & $PfadohneDatei)
						$dateinamen[$i] = IniRead("Data\config.ini", "Downloadeinstellungen", "Ordnerpfad", @ScriptDir & "\Downloads") & "\" & $PfadohneDatei & $pfadteile[$pfadteile[0]] & ".mp3"
						If IniRead("Data\config.ini", "Downloadeinstellungen", "Überschreiben", 4) = 4 And FileExists ($dateinamen[$i]) Then
							$dateinamen[$i] = StringReplace ($dateinamen[$i],".mp3"," (2).mp3")
							If FileExists ($dateinamen[$i]) Then
								$l = 3
								$dateinamen[$i] = StringReplace ($dateinamen[$i]," ("&$l-1&").mp3"," ("&$l&").mp3")
								While FileExists ($dateinamen[$i])
									$l = $l +1
									$dateinamen[$i] = StringReplace ($dateinamen[$i]," ("&$l-1&").mp3"," ("&$l&").mp3")
								WEnd
							EndIf
						EndIf
						;MsgBox (0,"",$dateinamen[$i])

						;ConsoleWrite ("Name: " & $dateinamen[$i]&@CRLF)
						$auflistung[$i][4] = $dateinamen[$i]
						$open = FileOpen($dateinamen[$i], 16 + 2)
						$header = _WinHttpQueryHeaders($h_openRequest)
						$dateigroesse = _StringBetween($header, "Content-Length: ", @CRLF)
						If IsArray($dateigroesse) Then $dateigroesse = $dateigroesse[0]
						;ConsoleWrite ($dateigroesse & @CRLF)
						_ConsoleWrite(sprache("GR_MSG_DOWNLOAD") & " " & $SongInfosFuerDLListe[$i][1] & " - " & sprache("GR_MSG_SIZE") & ": " & Round($dateigroesse / 1048576, 2) & " MB");T89+T90
						_GUICtrlProgressSetMarquee($GUI_Progress, 0)
						GUICtrlSetStyle($GUI_Progress, 0)
						GUICtrlSetData($GUI_Progress, 0)
						$auflistung[$i][6] = Round($dateigroesse / 1048576, 2)
						Local $data = Binary("")
						GUICtrlSetState($GUI_Download, $GUI_ENABLE)
						GUICtrlSetData($GUI_Download, sprache("GR_IMP_STOP"))
						AdlibRegister("DLAbbrechen", 15)

						$dlzeit = TimerInit()
						While 1
							$chunk = _WinHttpReadData($h_openRequest, 2, $bytesread)
							If @error Then
								ExitLoop
							EndIf
							$data = $data & $chunk
							GUICtrlSetData($GUI_Progress, StringLen($data) / ($dateigroesse) / 2 * 100) ; /2 da Binärdaten!
							If $dlabbruch = 1 Then
								$data = Binary("")
								FileClose($open)
								FileDelete($dateinamen[$i])
								ExitLoop
							EndIf
						WEnd
						GUICtrlSetState($GUI_Download, $GUI_DISABLE)
						GUICtrlSetData($GUI_Download, "Download")
						AdlibUnRegister("DLAbbrechen")
						If $data <> Binary("") Then
							$downloadzeit = Round(TimerDiff($dlzeit) / 1000, 1)
							_ConsoleWrite(sprache("GR_MSG_TIME") & ": " & $downloadzeit & " " & sprache("GR_MSG_SEC"));T91+T92
							$auflistung[$i][7] = $downloadzeit
							GUICtrlSetData($GUI_Progress, 100)
							FileWrite($open, $data)
							FileClose($open)
							If IniRead("Data\config.ini", "Downloadeinstellungen", "Playlist", 4) = 1 Then FileWrite($hfileplaylist, $dateinamen[$i] & @CRLF)
							_ArrayDelete($SongInfosFuerDLListeBackup, 0)
							#Region Cover Download
							If IniRead("Data\config.ini", "Downloadeinstellungen", "Cover", 4) = 1 Then
								If $SongInfosFuerDLListe[$i][4] = '""' Or $SongInfosFuerDLListe[$i][4] = "null" Then

									$term = StringReplace($SongInfosFuerDLListe[$i][1], " ", "+") & " " & StringReplace($SongInfosFuerDLListe[$i][2], " ", "+")
									;ConsoleWrite ("Term: " &$term&@CRLF)
									_ConsoleWrite(StringReplace (sprache("GR_MSG_COVERSEARCH"),"[%]",$SongInfosFuerDLListe[$i][1]))
									$Connection = _WinHttpConnect($hOpen, "itunes.apple.com")

									$h_openRequest = _WinHttpOpenRequest($Connection, "GET", "/search?term=" & $term & "&limit=1", Default, Default, Default, $WINHTTP_FLAG_SECURE)
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
											$cover600 = StringReplace($cover100[0], "100x100", "600x600")
											;ConsoleWrite ($cover600&@CRLF)
											$urlcrack = _WinHttpCrackUrl($cover600)
											If IsArray($urlcrack) Then

												$Connection = _WinHttpConnect($hOpen, $urlcrack[2])

												$h_openRequest = _WinHttpOpenRequest($Connection, "GET", $urlcrack[6])
												_WinHttpSendRequest($h_openRequest, '')
												_WinHttpReceiveResponse($h_openRequest)
												Local $data = Binary("")
												Do
													$data &= _WinHttpReadData($h_openRequest, 2)
												Until @error
												If $data <> Binary("") Then
													$coverpfad = StringReplace($dateinamen[$i], ".mp3", ".jpg", -1)
													$coverhandle = FileOpen($coverpfad, 16 + 2)
													FileWrite($coverhandle, $data)
													FileClose($coverhandle)
													$auflistung[$i][5] = "Data\tmp\" & $i & ".jpg"
													FileCopy($coverpfad, $auflistung[$i][5], 8)
													;ConsoleWrite ('Data\metamp3\metamp3.exe --pict "'&$coverpfad&'" "'&$dateinamen[$i]&'"' & @CRLF)
													If IniRead("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", 1) <> 2 Then ShellExecuteWait('Data\metamp3\metamp3.exe', '--pict "' & $coverpfad & '" "' & $dateinamen[$i] & '"', Default, Default, @SW_HIDE)
													If IniRead("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", 1) = 1 Then FileDelete($coverpfad)
												EndIf
											EndIf
										Else
											_ConsoleWrite(sprache("GR_MSG_ITUNESERROR"))
											;	$hOpen = _WinHttpOpen("")
											$Connection = _WinHttpConnect($hOpen, "www.seekacover.com")


											$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/cd/" & $term)
											_WinHttpSendRequest($h_openRequest)
											_WinHttpReceiveResponse($h_openRequest)
											Local $data = ""
											Do
												$data &= _WinHttpReadData($h_openRequest)
											Until @error
											;	_WinHttpCloseHandle($hOpen)
											$pic = _StringBetween($data, '<li><img src="', '" title="')

											If IsArray($pic) Then
												;MsgBox (0,"",$pic[0])
												$bilderurl = _WinHttpCrackUrl($pic[0])

												;	$hOpen = _WinHttpOpen("")
												$Connection = _WinHttpConnect($hOpen, $bilderurl[2])

												$h_openRequest = _WinHttpOpenRequest($Connection, "GET", $bilderurl[6])
												_WinHttpSendRequest($h_openRequest)
												_WinHttpReceiveResponse($h_openRequest)
												Local $data = Binary("")
												Do
													$data &= _WinHttpReadData($h_openRequest, 2)
												Until @error
												If $data <> Binary("") Then
													$coverpfad = StringReplace($dateinamen[$i], ".mp3", ".jpg", -1)
													$coverhandle = FileOpen($coverpfad, 16 + 2)
													FileWrite($coverhandle, $data)
													FileClose($coverhandle)
													$auflistung[$i][5] = "Data\tmp\" & $i & ".jpg"
													FileCopy($coverpfad, $auflistung[$i][5], 8)
													;ConsoleWrite ('Data\metamp3\metamp3.exe --pict "'&$coverpfad&'" "'&$dateinamen[$i]&'"' & @CRLF)
													If IniRead("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", 1) <> 2 Then ShellExecuteWait('Data\metamp3\metamp3.exe', '--pict "' & $coverpfad & '" "' & $dateinamen[$i] & '"', Default, Default, @SW_HIDE)
													If IniRead("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", 1) = 1 Then FileDelete($coverpfad)
												EndIf
												;	_WinHttpCloseHandle($hOpen)
											Else
												_ConsoleWrite(sprache("GR_MSG_COVERERROR"))
											EndIf
										EndIf
									EndIf
								Else
									_ConsoleWrite(StringReplace(sprache("GR_MSG_COVERDL"),"[%]",$SongInfosFuerDLListe[$i][1]))
									;	$hOpen = _WinHttpOpen("")
									$Connection = _WinHttpConnect($hOpen, "images.gs-cdn.net")


									$h_openRequest = _WinHttpOpenRequest($Connection, "GET", "/static/albums/" & StringReplace($SongInfosFuerDLListe[$i][4], '"', ""))
									_WinHttpSendRequest($h_openRequest)
									_WinHttpReceiveResponse($h_openRequest)
									Local $data = Binary("")
									Do
										$data &= _WinHttpReadData($h_openRequest, 2)
									Until @error
									;MsgBox (0,"",$data)
									If $data <> Binary("") Then
										$coverpfad = StringReplace($dateinamen[$i], ".mp3", ".jpg", -1)
										$coverhandle = FileOpen($coverpfad, 16 + 2)
										FileWrite($coverhandle, $data)
										FileClose($coverhandle)
										$auflistung[$i][5] = "Data\tmp\" & $i & ".jpg"
										FileCopy($coverpfad, $auflistung[$i][5], 8)
										;ConsoleWrite ('Data\metamp3\metamp3.exe --pict "'&$coverpfad&'" "'&$dateinamen[$i]&'"' & @CRLF)
										If IniRead("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", 1) <> 2 Then ShellExecuteWait('Data\metamp3\metamp3.exe', '--pict "' & $coverpfad & '" "' & $dateinamen[$i] & '"', Default, Default, @SW_HIDE)
										If IniRead("Data\config.ini", "Downloadeinstellungen", "Umgang mit Cover", 1) = 1 Then FileDelete($coverpfad)
									EndIf
									;	_WinHttpCloseHandle($hOpen)
								EndIf

							EndIf
							#EndRegion Cover Download

							_GUICtrlListView_DeleteItem(GUICtrlGetHandle($GUI_DLListe), _GUICtrlListView_FindText(GUICtrlGetHandle($GUI_DLListe), $SongInfosFuerDLListe[$i][1], -1, False))
							;_GUICtrlListView_DeleteItem (GUICtrlGetHandle($GUI_DLListe),0)
						Else
							; Download fehlgeschlagen
							$auflistung[$i][0] = "Error"
							$data = Binary("")
							FileClose($open)
							FileDelete($dateinamen[$i])
							If $dlabbruch <> 1 Then
								_ConsoleWrite(sprache("GR_MSG_DLERROR"))
							Else
								ExitLoop
							EndIf
						EndIf

						$data = ""
						$dlzeit = TimerInit()
						GUICtrlSetData($GUI_FooterText, "")
						;ConsoleWrite ("Nächster Durchgang" & @CRLF)
					Else
						$auflistung[$i][0] = "Error"
						_ArrayDelete($SongInfosFuerDLListeBackup, 0)
						_GUICtrlListView_DeleteItem(GUICtrlGetHandle($GUI_DLListe), 0)
					EndIf
				Next
				;_ArrayDisplay ($SongInfosFuerDLListe)
				;_ArrayDisplay ($dateinamen)
				_GUI_ProgressAus()
				_GUI_ProgressAn()

				FileDelete("Data\DLListe.txt")
				Dim $SongInfosFuerDLListe[UBound($SongInfosFuerDLListeBackup)][7]

				For $i = 0 To UBound($SongInfosFuerDLListeBackup) - 1
					FileWrite("Data\DLListe.txt", $SongInfosFuerDLListeBackup[$i][0] & "|" & $SongInfosFuerDLListeBackup[$i][1] & "|" & $SongInfosFuerDLListeBackup[$i][2] & "|" & $SongInfosFuerDLListeBackup[$i][3] & "|" & $SongInfosFuerDLListeBackup[$i][4] & @CRLF)
					$SongInfosFuerDLListe[$i][0] = $SongInfosFuerDLListeBackup[$i][0]
					$SongInfosFuerDLListe[$i][1] = $SongInfosFuerDLListeBackup[$i][1]
					$SongInfosFuerDLListe[$i][2] = $SongInfosFuerDLListeBackup[$i][2]
					$SongInfosFuerDLListe[$i][3] = $SongInfosFuerDLListeBackup[$i][3]
					$SongInfosFuerDLListe[$i][4] = $SongInfosFuerDLListeBackup[$i][4]
					$SongInfosFuerDLListe[$i][5] = $SongInfosFuerDLListeBackup[$i][5]
					$SongInfosFuerDLListe[$i][6] = $SongInfosFuerDLListeBackup[$i][6]
				Next


				Dim $SongInfosFuerDLListeBackup[1][7]

				If IniRead("Data\config.ini", "Downloadeinstellungen", "Winexplorer", 4) = 1 Then ShellExecute(IniRead("Data\config.ini", "Downloadeinstellungen", "Ordnerpfad", @ScriptDir & "\Downloads"))
				If IniRead("Data\config.ini", "Downloadeinstellungen", "MP3TAG", 4) = 1 Then ShellExecute(IniRead("Data\config.ini", "Downloadeinstellungen", "PfadMP3TAG", ""), '/fp:"' & IniRead("Data\config.ini", "Downloadeinstellungen", "Ordnerpfad", @ScriptDir & "\Downloads") & '"')
				;Mp3tag.exe /fp:"<Verzeichnispfad>"

				_GUI_ProgressAus()
				_ConsoleWrite(sprache("GR_MSG_DLFINISHED"))
				GUICtrlSetData($GUI_FooterText, "GrooveLoad " & $version & " by Cheater Dieter")
				;_ArrayDisplay ($auflistung)


				;-------
				; Abschlussbericht
				;-------
				GUISetState (@SW_DISABLE,$HauptGUI)
				GUIRegisterMsg($WM_GETMINMAXINFO, "WM_GETMINMAXINFO")
				$hWnd = GUICreate("Abschlussbericht", 700, 570, -1, -1, $WS_SIZEBOX + $WS_MAXIMIZEBOX,-1,$HauptGUI)
				GUISetBkColor(0xFFFFFF)
				GUISetIcon("Data\icon.ico")
				$listview = GUICtrlCreateListView("", 0, 33, 696, 450, $LVS_SINGLESEL, $LVS_EX_FULLROWSELECT)
				GUICtrlSetResizing(-1, $GUI_DOCKTOP + $GUI_DOCKBOTTOM)

				GUICtrlCreateLabel(sprache("GR_FINALREPORT_TEXT"), 8, 8, 500, 20)
				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
				GUICtrlSetFont(-1, 10, 800, 0, "Arial")

				GUICtrlCreateLabel("", 10, 494, 680, 2, $SS_SUNKEN)
				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
				$titelname = GUICtrlCreateLabel(sprache("GR_FINALREPORT_MARK"), 10, 499, 200, 18)
				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
				$Abschluss_Play = GUICtrlCreateButton(sprache("GR_FINALREPORT_PLAY"), 10, 515, 100, 21)
				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
				$Abschluss_Oeffnen = GUICtrlCreateButton(sprache ("GR_FINALREPORT_DIRECTORY"), 115, 515, 100, 21)
				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
				$Abschluss_Cover_aendern = GUICtrlCreateButton(sprache("GR_FINALREPORT_COVER"), 220, 515, 100, 21)
				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
				$Abschluss_MP3tag = GUICtrlCreateButton(sprache("GR_FINALREPORT_MP3TAG"), 325, 515, 100, 21)
				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
				$Abschluss_Beenden = GUICtrlCreateButton(sprache("GR_FINALREPORT_EXIT"), 590, 515, 100, 21)
				GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)


				$hImage = _GUIImageList_Create(70, 70, 6)
				$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hWnd) ;Grafik für die GUI erzeugen

				For $i = 0 To UBound($auflistung) - 1
					If $auflistung[$i][5] <> "" Then
						$bildpfad = $auflistung[$i][5]
					Else
						$bildpfad = "Data\cover\cover.jpg"
					EndIf
					$hBitmap = ScaleImage($bildpfad, 70, 70)
					_GUIImageList_Add($hImage, _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap))
					_WinAPI_DeleteObject($hBitmap)
				Next
				_GDIPlus_GraphicsDispose($hGraphics)

				_GUICtrlListView_SetImageList($listview, $hImage, 1)

				; Add columns
				_GUICtrlListView_AddColumn($listview, sprache("GR_FINALREPORT_COVERPIC"), 70);377
				_GUICtrlListView_InsertColumn($listview, 1, sprache("GR_DLGUI_TITLE"), 100)
				_GUICtrlListView_InsertColumn($listview, 2, sprache("GR_DLGUI_ARTIST"), 100)
				_GUICtrlListView_InsertColumn($listview, 3, sprache("GR_DLGUI_ALBUM"), 100)
				_GUICtrlListView_InsertColumn($listview, 4, sprache("GR_MSG_SIZE"), 100)
				_GUICtrlListView_InsertColumn($listview, 5, sprache ("GR_FINALREPORT_STORAGELOCATION"), 100)

				For $i = 0 To UBound($auflistung) - 1
					_GUICtrlListView_AddItem($listview, "", $i)
					_GUICtrlListView_AddSubItem($listview, $i, $auflistung[$i][1], 1)
					_GUICtrlListView_AddSubItem($listview, $i, $auflistung[$i][3], 2)
					_GUICtrlListView_AddSubItem($listview, $i, $auflistung[$i][2], 3)
					If $auflistung[$i][0] = "Error" Then
						_GUICtrlListView_AddSubItem($listview, $i, $auflistung[$i][6] & " MB (" & $auflistung[$i][7] & " "&sprache("GR_MSG_SEC")&")", 4)
					Else
						_GUICtrlListView_AddSubItem($listview, $i, $auflistung[$i][6] & " MB", 4)
					EndIf

					If $auflistung[$i][0] = "Error" Then
						_GUICtrlListView_AddSubItem($listview, $i, sprache("GR_FINALREPORT_ERROR"), 5)
					Else
						_GUICtrlListView_AddSubItem($listview, $i, $auflistung[$i][4], 5)
					EndIf
				Next

				GUICtrlSetState($Abschluss_Cover_aendern, $GUI_DISABLE)
				GUICtrlSetState($Abschluss_MP3tag, $GUI_DISABLE)
				GUICtrlSetState($Abschluss_Oeffnen, $GUI_DISABLE)
				GUICtrlSetState($Abschluss_Play, $GUI_DISABLE)

				GUISetState()

				DllCall("user32.dll", "int", "MessageBeep", "int", 0x00000040)
				DirRemove(@ScriptDir & "\Data\tmp", 1)

				$markiertalt = ""

				Do
					$markiert = _GUICtrlListView_GetSelectedIndices($listview)
					If $markiert <> $markiertalt Then
						If $markiert = "" Then
							GUICtrlSetData($titelname, "Titel markieren")
							GUICtrlSetState($Abschluss_Cover_aendern, $GUI_DISABLE)
							GUICtrlSetState($Abschluss_MP3tag, $GUI_DISABLE)
							GUICtrlSetState($Abschluss_Oeffnen, $GUI_DISABLE)
							GUICtrlSetState($Abschluss_Play, $GUI_DISABLE)
						Else
							If $auflistung[$markiert][0] <> "Error" Then
								GUICtrlSetState($Abschluss_Cover_aendern, $GUI_ENABLE)
								GUICtrlSetState($Abschluss_MP3tag, $GUI_ENABLE)
								GUICtrlSetState($Abschluss_Oeffnen, $GUI_ENABLE)
								GUICtrlSetState($Abschluss_Play, $GUI_ENABLE)
								GUICtrlSetData($titelname, $auflistung[$markiert][1])
							EndIf
						EndIf
						$markiertalt = $markiert
					EndIf

					$Abschlussmsg = GUIGetMsg()
					Switch $Abschlussmsg
						Case $Abschluss_Play
							ShellExecute($auflistung[_GUICtrlListView_GetSelectedIndices($listview)][4])
						Case $Abschluss_Oeffnen
							$sDrive = ""
							$sDir = ""
							$sFilename = ""
							$sExtension = ""
							_PathSplit($auflistung[_GUICtrlListView_GetSelectedIndices($listview)][4], $sDrive, $sDir, $sFilename, $sExtension)
							ShellExecute($sDrive & $sDir)
						Case $Abschluss_Beenden
							ExitLoop
						Case $Abschluss_MP3tag
							; Mp3tag.exe /fn:"<Dateipfad>"
							If IniRead("Data\config.ini", "Downloadeinstellungen", "PfadMP3TAG", "Nicht angegeben") = "Nicht angegeben" Then
								MsgBox (16,"GrooveLoad","Es wurde kein Pfad zu MP3tag angegeben. Du kannst dies in den Downloadeinstellungen nachholen.")
							Else
								ShellExecute(IniRead("Data\config.ini", "Downloadeinstellungen", "PfadMP3TAG", "Nicht angegeben"), '/fn:"' & $auflistung[_GUICtrlListView_GetSelectedIndices($listview)][4] & '"')
							EndIf
						Case $Abschluss_Cover_aendern
							ShellExecute ("Data\AutoIt3.exe",'"' & @ScriptDir & '\Data\Coversuche.au3" "' & $auflistung[_GUICtrlListView_GetSelectedIndices($listview)][3] & ' ' & $auflistung[_GUICtrlListView_GetSelectedIndices($listview)][1] & '"')
					EndSwitch

				Until $Abschlussmsg = $GUI_EVENT_CLOSE

				GUIRegisterMsg($WM_GETMINMAXINFO, "")
				GUIDelete()
				GUISetState (@SW_ENABLE,$HauptGUI)

				;-------
				; Abschlussbericht Ende
				;-------

				GUI_Aktivieren()

			EndIf
		Case $grooveicon
			If $krokodilzahl = _FileCountLines("Data\ico\Großes grünes Krokodil") Then
				$krokodilzahl = 0
				GUICtrlSetImage($grooveicon, "Data\icon.ico")
				GUICtrlSetData($groovelabel, "GrooveLoad")
				$GruenesKrokodil = False
			Else
				$krokodilzahl = $krokodilzahl + 1
				GUICtrlSetImage($grooveicon, "Data\ico\Großes grünes Krokodil.ico")
				GUICtrlSetData($groovelabel, FileReadLine("Data\ico\Großes grünes Krokodil", $krokodilzahl))
			EndIf
		Case $GUI_FooterText
			If $nilpferd = 0 Then
				GUICtrlSetColor($GUI_FooterText, 0xfc0fc0)
				$nilpferd = 1
			ElseIf $nilpferd = 1 Then
				GUICtrlSetColor($GUI_FooterText, 0x000000)
				ShellExecute("http://hegi.pfweb.eu/what%27s%20going%20on")
				$nilpferd = 0
			EndIf

		Case $GUI_Stapelverarbeitung
			GUISetState(@SW_DISABLE, $HauptGUI)

			$Stapelsuche_GUI = GUICreate("GrooveLoad", 410, 440, -1, -1, -1, -1, $HauptGUI)
			GUISetIcon("Data\icon.ico")
			$Stapel_Edit = GUICtrlCreateEdit("", 8, 70, 393, 329)
			GUICtrlCreateLabel(sprache("GR_AUTO_TEXT"), 8, 8, 395, 50)
			$Stapel_Speichern = GUICtrlCreateButton(sprache("GR_AUTO_START"), 124, 408, 163, 25)

			GUISetState(@SW_SHOW)

			While 1
				$nMsg = GUIGetMsg()
				Switch $nMsg
					Case $GUI_EVENT_CLOSE
						GUIDelete($Stapelsuche_GUI)
						GUISetState(@SW_ENABLE, $HauptGUI)
						WinActivate($HauptGUI)
						ExitLoop
					Case $Stapel_Speichern
						$stapelladefenster = GUICreate("GrooveLoad", 232, 85, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
						GUISetIcon("Data\icon.ico")
						GUISetBkColor(0xFFFFFF)
						$stapelprogress = GUICtrlCreateProgress(8, 28, 214, 17)
						GUICtrlCreateLabel(sprache("GR_AUTO_SEARCH"), 8, 8, 162, 17)
						GUISetState(@SW_SHOW)

						For $z = 0 To _GUICtrlEdit_GetLineCount($Stapel_Edit) - 1
							;$error = 0

							$Suchbegriff = _GUICtrlEdit_GetLine($Stapel_Edit, $z)

							If StringInStr($Suchbegriff, "open.spotify.com/track/") Then
								$spotifyURL = $Suchbegriff & "<"
								$spotifyID = _StringBetween($spotifyURL, "open.spotify.com/track/", "<")
								$spotifyID = $spotifyID[0]
								$Connection = _WinHttpConnect($hOpen, "ws.spotify.com")
								$h_openRequest = _WinHttpOpenRequest($Connection, "GET", "/lookup/1/?uri=spotify:track:" & $spotifyID)
								_WinHttpSendRequest($h_openRequest, '')
								_WinHttpReceiveResponse($h_openRequest)
								Local $data = ""
								Do
									$data &= _WinHttpReadData($h_openRequest)
								Until @error
								;MsgBox (0,"",$data)
								$name = _StringBetween($data, "<name>", "</name>")
								If IsArray($name) Then
									$Suchbegriff = $name[0] & " " & $name[1]
								Else
									$Suchbegriff = ""
								EndIf
							EndIf
							;MsgBox (0,$z,$Suchbegriff)
							$Suchbegriff = toUnicode($Suchbegriff)

							;Suche nach $Suchbegriff
							$Token = _GroovesharkGetToken($CommunicationToken, "getResultsFromSearch")

							$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
							$h_openRequest = _WinHttpOpenRequest($Connection, "POST", "/more.php?getResultsFromSearch")
							_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"parameters":{"query": "' & $Suchbegriff & '","type": "Songs"},"header":{"session": "' & $SessionID & '","token": "' & $Token & '","clientRevision":"20130520","client":"htmlshark","country":{"DMA":0,"CC1":0,"IPR":0,"CC2":0,"CC3":0,"CC4":1073741824,"ID":223}},"method":"getResultsFromSearch"}')
							_WinHttpReceiveResponse($h_openRequest)

							Local $data = ""
							Do
								$data &= _WinHttpReadData($h_openRequest)
							Until @error
							_Log("Suche " & $Suchbegriff & ": " & $data)
							;MsgBox (0,"",$data)
							If StringInStr($data, "invalid token") <> 0 Then
								GUISetState(@SW_DISABLE, $HauptGUI)
								MsgBox(16, "GrooveLoad", sprache("GR_MSG_SECRETWORD"), 0, $HauptGUI) ;T45
								GUISetState(@SW_ENABLE, $HauptGUI)
								WinActivate($HauptGUI)
							Else
								$SongID = _StringBetween($data, 'SongID":"', '","')
								$SongName = _StringBetween($data, 'SongName":"', '","')
								$AlbumName = _StringBetween($data, 'AlbumName":"', '","')
								$ArtistName = _StringBetween($data, 'ArtistName":"', '","')
								$ArtistID = _StringBetween($data, 'ArtistID":"', '","')
								$AlbumID = _StringBetween($data, 'AlbumID":"', '","')
								$cover = _StringBetween($data, '"CoverArtFilename":', ",")
								;_ArrayDisplay ($SongID)
								;_ArrayDisplay ($cover)

								If Not IsArray($SongID) Or Not IsArray($SongName) Or Not IsArray($AlbumName) Or Not IsArray($ArtistName) Or Not IsArray($ArtistID) Or Not IsArray($AlbumID) Or Not IsArray($cover) Then
									;Nix tun
								Else
									If UBound($SongInfosFuerDLListe) = 0 Then
										$a = 0
									Else
										If $SongInfosFuerDLListe[UBound($SongInfosFuerDLListe) - 1][0] = "" Then
											$a = 0
										Else
											$a = UBound($SongInfosFuerDLListe)
										EndIf
									EndIf

									ReDim $SongInfosFuerDLListe[$a + 1][7]
									$SongInfosFuerDLListe[$a][0] = $SongID[0] ; Song ID
									$SongInfosFuerDLListe[$a][1] = $SongName[0] ; Titel
									$SongInfosFuerDLListe[$a][2] = $ArtistName[0] ; Interpret
									$SongInfosFuerDLListe[$a][3] = $AlbumName[0] ; Album
									$SongInfosFuerDLListe[$a][4] = $cover[0] ; Cover-Info
									GUICtrlCreateListViewItem($SongInfosFuerDLListe[$a][1] & "|" & $SongInfosFuerDLListe[$a][2] & "|" & $SongInfosFuerDLListe[$a][3], $GUI_DLListe)
									FileWrite("Data\DLListe.txt", $SongInfosFuerDLListe[$a][0] & "|" & $SongInfosFuerDLListe[$a][1] & "|" & $SongInfosFuerDLListe[$a][2] & "|" & $SongInfosFuerDLListe[$a][3] & "|" & $SongInfosFuerDLListe[$a][4] & @CRLF)
								EndIf
							EndIf
							GUICtrlSetData($stapelprogress, $z / (_GUICtrlEdit_GetLineCount($Stapel_Edit) - 1) * 100)
						Next
						GUIDelete($stapelladefenster)
						GUIDelete($Stapelsuche_GUI)
						GUISetState(@SW_SHOW, $Pannel[0])
						$aktivespannel = 0
						GUICtrlSetColor($Link[0], 0x0066CC)
						GUICtrlSetColor($Link[1], 0x000000)
						GUICtrlSetImage($icon[0], "Data\ico\0-.ico")
						GUICtrlSetImage($icon[1], "Data\ico\1.ico")
						GUISetState(@SW_ENABLE, $HauptGUI)
						WinActivate($HauptGUI)
						MsgBox(64, "GrooveLoad", sprache("GR_AUTO_FINISH"), 0, $HauptGUI)
						ExitLoop
				EndSwitch
			WEnd

		Case $GUI_verknuepfung
			FileCreateShortcut(@ScriptDir & "\Data\AutoIt3.exe", @DesktopDir & "\GrooveLoad.lnk", "", '"' & @ScriptDir & "\GrooveLoad.au3" & '"', "", @ScriptDir & "\Data\icon.ico")
			MsgBox(64, "GrooveLoad", sprache("GR_SHORTCUT_TEXT"), 0, $HauptGUI)
		Case $manuell_Cover
			ShellExecute("Data\AutoIt3.exe", '"' & @ScriptDir & '\Data\Coversuche.au3"')
	EndSwitch

WEnd



;-------------------------
Func _ConsoleWrite($text)
	GUICtrlSetData($GUI_Log, $text & @CRLF & GUICtrlRead($GUI_Log))
EndFunc   ;==>_ConsoleWrite

Func DebugWrite($text)
	GUICtrlSetData($DebugEdit, $text & @CRLF & GUICtrlRead($DebugEdit))
EndFunc   ;==>_ConsoleWrite


Func Interneteinstellungen($type = 0)
	_WinHttpCloseHandle($hOpen) ; Schließe evtl. bestehende Verbindung
	If $type = 1 Then
		GUIDelete($Ladebildschirm)
		MsgBox(16, "GrooveLoad", "Es konnte keine Verbindung zu Grooveshark hergestellt werden. Bitte überprüfe im Folgenden deine Verbindungseinstellungen.");T100
	EndIf
	$GUI_FensterVerbindungseinstellungen = GUICreate(sprache("GR_GUI_CONNECTION"), 338, 270)
	GUISetIcon("Data\icon.ico")
	$GUI_ProxyCheckbox = GUICtrlCreateCheckbox(sprache("GR_CONN_PROXY"), 8, 8, 97, 17)
	$GUI_ProxyIP = GUICtrlCreateInput("IP:Port", 24, 32, 305, 21)
	$GUI_VerbindungTest = GUICtrlCreateButton(sprache("GR_CONN_CHECK"), 216, 237, 110, 25)
	$GUI_Speichern = GUICtrlCreateButton(sprache("GR_DLGUI_SAVE"), 140, 237, 70, 25)
	$GUI_XFor = GUICtrlCreateCheckbox(sprache("GR_CONN_X"), 8, 72, 233, 17)
	$GUI_Hilfe = GUICtrlCreateLabel("?", 240, 74, 11, 17)
	GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0066CC)
	GUICtrlSetCursor(-1, 0)
	GUICtrlCreateLabel(sprache("GR_CONN_IPTEXT"), 24, 93, 294, 25)
	$GUI_ZufallsIP = GUICtrlCreateInput("81.158.166.", 24, 123, 121, 21)
	$GUI_Reset = GUICtrlCreateButton(sprache("GR_DLGUI_RESET"), 160, 123, 75, 21)
	GUICtrlSetState($GUI_ProxyCheckbox, IniRead("Data\config.ini", "Proxy", "Proxy_nutzen", 4))
	GUICtrlSetData($GUI_ProxyIP, IniRead("Data\config.ini", "Proxy", "Proxy_IP", "IP:Port"))
	GUICtrlSetState($GUI_XFor, IniRead("Data\config.ini", "X-FORWARDED-FOR", "FORWARDED_nutzen", 1))
	GUICtrlSetData($GUI_ZufallsIP, IniRead("Data\config.ini", "X-FORWARDED-FOR", "FORWARDED_IP", "81.158.166."))
	GUICtrlCreateLabel(sprache("GR_CONN_BYTES"), 8, 152, 330, 39)
	$GUI_Bytes = GUICtrlCreateInput(IniRead("Data\config.ini", "Downloadeinstellungen", "NumberOfBytesToRead", 150000), 24, 199, 121, 21)
	$GUI_ResetBytes = GUICtrlCreateButton(sprache("GR_DLGUI_RESET"), 160, 199, 75, 21)
	GUISetState(@SW_SHOW)


	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				If $type = 1 Then
					Exit
				Else
					GUI_Deaktivieren()
					WinActivate($HauptGUI)
					GUIDelete($GUI_FensterVerbindungseinstellungen)
					_ConsoleWrite(sprache("GR_MSG_RECONNECT"))
					;Neu verbinden
					$hOpen = _WinHttpOpen("")
					Timeout ($hOpen)
					$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
					If $Proxy = True Then
						$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
						_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
					EndIf
					For $i = 1 To 2
						;ConsoleWrite ("Versuch zu verbinden" & @CRLF)
						$SessionID = _GroovesharkGetSessionID($Connection)
						$CommunicationToken = _GroovesharkGetCommunicationToken($SessionID, $Connection)
						If $SessionID <> 1 And $CommunicationToken <> 1 Then
							ExitLoop
						EndIf
					Next
					If $SessionID = -1 Or $CommunicationToken = -1 Then
						MsgBox(16, "GrooveLoad", sprache("GR_MSG_ERRORSESSIONID"))
						ShellExecute("Data\AutoIt3.exe", '"' & @ScriptFullPath & '"')
						Exit
					EndIf
					$time = TimerInit()
					_ConsoleWrite(sprache("GR_MSG_NEWCONNECTION"))
					GUI_Aktivieren()
					ExitLoop
				EndIf
			Case $GUI_Hilfe
				MsgBox(64, "GrooveLoad", sprache("GR_CONN_XTEXT"), 0, $GUI_FensterVerbindungseinstellungen)
			Case $GUI_Reset
				GUICtrlSetData($GUI_ZufallsIP, "81.158.166.")
			Case $GUI_ResetBytes
				GUICtrlSetData($GUI_Bytes, "150000")
			Case $GUI_VerbindungTest
				; -----Aufruf der Webseite zum Testen
				$hOpen = _WinHttpOpen("")
				Timeout ($hOpen)
				$Connection = _WinHttpConnect($hOpen, "grooveshark.com")
				If GUICtrlRead($GUI_ProxyCheckbox) = 1 Then
					$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, GUICtrlRead($GUI_ProxyIP), "localhost")
					_WinHttpSetOption($hOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
				EndIf
				$h_openRequest = _WinHttpOpenRequest($Connection, "POST")

				If GUICtrlRead($GUI_XFor) = 1 Then
					$_zufallsip = GUICtrlRead($GUI_ZufallsIP)
					If StringRight($_zufallsip, 1) <> "." Then $_zufallsip = $_zufallsip & "."
					$FakeIP = "X-FORWARDED-FOR: " & $_zufallsip & Random(100, 255, 1)
				Else
					$FakeIP = ""
				EndIf

				$FakeIP = ""
				;MsgBox (0,"",$FakeIP)
				_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF)
				_WinHttpReceiveResponse($h_openRequest)
				Local $data = ""
				Do
					$data &= _WinHttpReadData($h_openRequest)
				Until @error

				If $data = "" Then
					MsgBox(16, "GrooveLoad", sprache("GR_CONN_ERROR"), 0, $GUI_FensterVerbindungseinstellungen)
				Else
					MsgBox(0, "GrooveLoad", sprache("GR_CONN_ALRIGHT"), 0, $GUI_FensterVerbindungseinstellungen)
				EndIf

				;MsgBox (0,"",$data)

				_WinHttpCloseHandle($hOpen)
				; -----Ende Testaufruf

			Case $GUI_Speichern
				IniWrite("Data\config.ini", "Proxy", "Proxy_nutzen", GUICtrlRead($GUI_ProxyCheckbox)) ;Y=1, N=4
				IniWrite("Data\config.ini", "Proxy", "Proxy_IP", GUICtrlRead($GUI_ProxyIP))
				IniWrite("Data\config.ini", "X-FORWARDED-FOR", "FORWARDED_nutzen", GUICtrlRead($GUI_XFor)) ;Y=1, N=4
				IniWrite("Data\config.ini", "Downloadeinstellungen", "NumberOfBytesToRead", GUICtrlRead($GUI_Bytes))
				$_zufallsip = GUICtrlRead($GUI_ZufallsIP)
				If StringRight($_zufallsip, 1) <> "." Then $_zufallsip = $_zufallsip & "."
				IniWrite("Data\config.ini", "X-FORWARDED-FOR", "FORWARDED_IP", $_zufallsip)
				MsgBox(64, "GrooveLoad", sprache("GR_CONN_RESTART"), 0, $GUI_FensterVerbindungseinstellungen)
				ShellExecute("Data\AutoIt3.exe", '"' & @ScriptFullPath & '"')
				Exit

		EndSwitch
	WEnd
EndFunc   ;==>Interneteinstellungen

Func _GroovesharkGetSessionID($hConnect)
	$h_openRequest = _WinHttpOpenRequest($hConnect, "POST", "/more.php?initiateSession")
	_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/json", '{"parameters":{},"header":{"clientRevision":"20130520","client":"htmlshark","country":{"CC2":"0","DMA":"0","ID":"1","CC1":"0","CC3":"0","CC4":"0","IPR":"1"}},"method":"initiateSession"}')
	_WinHttpReceiveResponse($h_openRequest)

	Local $data = ""
	Do
		$data &= _WinHttpReadData($h_openRequest)
	Until @error
	_Log("Session ID: " & $data)
	$SessionID = _StringBetween($data, '"result":"', '"}')
	If IsArray($SessionID) Then
		$SessionID = $SessionID[0]
		;ConsoleWrite ("Session ID: " & $SessionID & @CRLF)
		Return $SessionID
	Else
		;MsgBox (16,"GrooveLoad","Das Abfragen einer einer Session ID schlug fehl." & @CRLF & "-----" & @CRLF & $data)
		Return -1
		;Exit
	EndIf

EndFunc   ;==>_GroovesharkGetSessionID

Func _GroovesharkGetCommunicationToken($SessionID, $hConnect)
	; Session ID in MD5 Schlüssel umwandeln -> wird später als "secretKey" verwendet
	$SessionIDmd5 = StringTrimLeft(StringLower(_Crypt_HashData($SessionID, $CALG_MD5)), 2)

	; Communication Token holen
	$h_openRequest = _WinHttpOpenRequest($hConnect, "POST", "/more.php?getCommunicationToken", Default, Default, Default, $WINHTTP_FLAG_SECURE)
	_WinHttpSendRequest($h_openRequest, Default, '{"parameters":{"secretKey":"' & $SessionIDmd5 & '"},"header":{"clientRevision":"20130520","client":"htmlshark","country":{"CC2":"0","DMA":"0","ID":"1","CC1":"0","CC3":"0","CC4":"0","IPR":"1"}},"method":"getCommunicationToken"}')
	_WinHttpReceiveResponse($h_openRequest)

	Local $data = ""
	Do
		$data &= _WinHttpReadData($h_openRequest)
	Until @error
	_Log("Communication Token: " & $data)
	$CommunicationToken = _StringBetween($data, '"result":"', '"}')
	If IsArray($CommunicationToken) Then
		$CommunicationToken = $CommunicationToken[0]
		;ConsoleWrite ("Communication Token: " & $CommunicationToken & @CRLF)
		Return $CommunicationToken
	Else
		Return -1
	EndIf
EndFunc   ;==>_GroovesharkGetCommunicationToken

Func _GroovesharkGetToken($CommunicationToken, $Methode)
	Random(0, 16777215, 1)
	$hex = StringLower(Hex(Random(0, 16777215, 1), 6))
	$Token = $hex & StringLower(StringTrimLeft(_Crypt_HashData($Methode & ':' & $CommunicationToken & ':' & $Geheimwort & ':' & $hex, $CALG_SHA1), 2))
	;	ConsoleWrite ("Token: "&$Token & @CRLF)
	Return $Token
EndFunc   ;==>_GroovesharkGetToken

Func toUnicode($var)
	$ausgabe = ""
	For $v = 1 To StringLen($var)
		$ausgabe = $ausgabe & "\u00" & Hex(Asc(StringMid($var, $v, 1)), 2)
	Next
	Return $ausgabe
EndFunc   ;==>toUnicode

Func fromUnicode($var)
	While StringInStr($var, "\u00") <> 0
		$replace = StringMid($var, StringInStr($var, "\u00") + 4, 2)
		$var = StringReplace($var, $replace, Chr(Dec($replace)), 1)
		$var = StringReplace($var, "\u00", "", 1)
	WEnd
	$var = StringReplace($var, "\u2019", "'")
	$var = StringReplace($var, "\u02BB", "'")
	$var = StringReplace($var, "\", "")
	Return ($var)
EndFunc   ;==>fromUnicode

Func _Log($log)
	FileWrite($loghandle, @HOUR & ":" & @MIN & ":" & @SEC & @CRLF & $log & @CRLF & "-----" & @CRLF)
EndFunc   ;==>_Log

Func ende()
	_GDIPlus_Shutdown()
	FileClose($loghandle)
EndFunc   ;==>ende

Func GUI_Deaktivieren()
	GUICtrlSetState($GUI_ButtonSuche, $GUI_DISABLE)
	GUICtrlSetState($GUI_ButtonBeliebteLieder, $GUI_DISABLE)
	GUICtrlSetState($GUI_DLListeleeren, $GUI_DISABLE)
	GUICtrlSetState($GUI_AuswahlDL, $GUI_DISABLE)
	GUICtrlSetState($GUI_Download, $GUI_DISABLE)
	GUICtrlSetState($GUI_DLListeHinzufuegen, $GUI_DISABLE)
	GUICtrlSetState($GUI_AuswahlSuche, $GUI_DISABLE)
	GUICtrlSetState($GUI_AufrufausDE, $GUI_DISABLE)
	GUICtrlSetState($GUI_Doppeltloeschen, $GUI_DISABLE)
	GUICtrlSetState($GUI_DLListe, $GUI_DISABLE)
	GUICtrlSetState($GUI_ListeSuchergebnisse, $GUI_DISABLE)
	GUICtrlSetState($GUI_feedback, $GUI_DISABLE)
	GUICtrlSetState($GUI_Stapelverarbeitung, $GUI_DISABLE)
	GUICtrlSetState($manuell_Cover, $GUI_DISABLE)
	GUICtrlSetState($GUI_Verbindungseinstellungen, $GUI_DISABLE)
	GUICtrlSetState($GUI_Downloadeinstellungen, $GUI_DISABLE)
	GUICtrlSetState($GUI_zuruecksetzen, $GUI_DISABLE)
	GUICtrlSetState($GUI_sprache, $GUI_DISABLE)
	GUICtrlSetState($GUI_verknuepfung, $GUI_DISABLE)
	GUISetState($Suche_GUI, @SW_HIDE)
	GUISetState($DL_GUI, @SW_HIDE)
EndFunc   ;==>GUI_Deaktivieren

Func GUI_Aktivieren()
	GUICtrlSetState($GUI_ButtonSuche, $GUI_ENABLE)
	GUICtrlSetState($GUI_ButtonBeliebteLieder, $GUI_ENABLE)
	GUICtrlSetState($GUI_DLListeleeren, $GUI_ENABLE)
	GUICtrlSetState($GUI_AuswahlDL, $GUI_ENABLE)
	GUICtrlSetState($GUI_Download, $GUI_ENABLE)
	GUICtrlSetState($GUI_DLListeHinzufuegen, $GUI_ENABLE)
	GUICtrlSetState($GUI_AuswahlSuche, $GUI_ENABLE)
	GUICtrlSetState($GUI_AufrufausDE, $GUI_ENABLE)
	GUICtrlSetState($GUI_Doppeltloeschen, $GUI_ENABLE)
	GUICtrlSetState($GUI_DLListe, $GUI_ENABLE)
	GUICtrlSetState($GUI_ListeSuchergebnisse, $GUI_ENABLE)
	GUICtrlSetState($GUI_feedback, $GUI_ENABLE)
	GUICtrlSetState($GUI_Stapelverarbeitung, $GUI_ENABLE)
	GUICtrlSetState($manuell_Cover, $GUI_ENABLE)
	GUICtrlSetState($GUI_Verbindungseinstellungen, $GUI_ENABLE)
	GUICtrlSetState($GUI_Downloadeinstellungen, $GUI_ENABLE)
	GUICtrlSetState($GUI_zuruecksetzen, $GUI_ENABLE)
	GUICtrlSetState($GUI_sprache, $GUI_ENABLE)
	GUICtrlSetState($GUI_verknuepfung, $GUI_ENABLE)
	GUISetState($Suche_GUI, @SW_SHOW)
	GUISetState($DL_GUI, @SW_SHOW)
EndFunc   ;==>GUI_Aktivieren

Func _WinHttpProxyInfoCreate($dwAccessType, $sProxy, $sProxyBypass)
	Local $tWINHTTP_PROXY_INFO[2] = [DllStructCreate($tagWINHTTP_PROXY_INFO), DllStructCreate('wchar proxychars[' & StringLen($sProxy) + 1 & ']; wchar proxybypasschars[' & StringLen($sProxyBypass) + 1 & ']')]
	DllStructSetData($tWINHTTP_PROXY_INFO[0], "dwAccessType", $dwAccessType)
	If StringLen($sProxy) Then DllStructSetData($tWINHTTP_PROXY_INFO[0], "lpszProxy", DllStructGetPtr($tWINHTTP_PROXY_INFO[1], 'proxychars'))
	If StringLen($sProxyByPass) Then DllStructSetData($tWINHTTP_PROXY_INFO[0], "lpszProxyBypass", DllStructGetPtr($tWINHTTP_PROXY_INFO[1], 'proxybypasschars'))
	DllStructSetData($tWINHTTP_PROXY_INFO[1], "proxychars", $sProxy)
	DllStructSetData($tWINHTTP_PROXY_INFO[1], "proxybypasschars", $sProxyBypass)
	Return $tWINHTTP_PROXY_INFO
EndFunc   ;==>_WinHttpProxyInfoCreate

Func _FadeIn($form = $HauptGUI)
	For $a = 0 To 250 Step 20
		Sleep(15)
		WinSetTrans($form, "", $a)
	Next
	WinSetTrans($form, "", 255)
EndFunc   ;==>_FadeIn
Func _FadeOut($form = $HauptGUI)
	For $a = 250 To 0 Step -20
		Sleep(15)
		WinSetTrans($form, "", $a)
	Next
	WinSetTrans($form, "", 0)
EndFunc   ;==>_FadeOut


Func DLAbbrechen()
	$iMsg = GUIGetMsg()
	If $iMsg = $GUI_Download Then
		Global $dlabbruch = 1
	EndIf
EndFunc   ;==>DLAbbrechen

Func _GUI_ProgressAn($prog = $GUI_Progress)
	GUICtrlSetStyle($prog, 0x00000008)
	_GUICtrlProgressSetMarquee($prog, 1, 25)
EndFunc   ;==>_GUI_ProgressAn

Func _GUI_ProgressAus($prog = $GUI_Progress)
	_GUICtrlProgressSetMarquee($prog, 0)
	GUICtrlSetStyle($prog, $GUI_SS_DEFAULT_GUI)
EndFunc   ;==>_GUI_ProgressAus

Func hinweise()
	If $nr = 1 Then
		GUICtrlSetState($zurueck, $GUI_DISABLE)
		GUICtrlSetData($text, sprache("GR_TUT_1"))
	ElseIf $nr = 2 Then
		GUICtrlSetState($zurueck, $GUI_ENABLE)
		GUICtrlSetData($text, sprache("GR_TUT_2"))
	ElseIf $nr = 3 Then
		GUICtrlSetData($text, sprache("GR_TUT_3"))
	ElseIf $nr = 4 Then
		GUICtrlSetData($text, sprache("GR_TUT_4"))
	ElseIf $nr = 5 Then
		GUICtrlSetState($dle, $GUI_HIDE)
		GUICtrlSetData($text, sprache("GR_TUT_5"))
	ElseIf $nr = 6 Then
		GUICtrlSetState($dle, $GUI_SHOW)
		GUICtrlSetData($weiter, sprache("GR_TUT_NEXT"))
		GUICtrlSetData($text, sprache("GR_TUT_6"))
	ElseIf $nr = 7 Then
		GUICtrlSetState($dle, $GUI_HIDE)
		GUICtrlSetData($weiter, sprache("GR_TUT_FINISH"))
		GUICtrlSetData($text, sprache("GR_TUT_7"))
	EndIf
EndFunc   ;==>hinweise

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

Func _WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam

	Local $hWndListView = $GUI_ListeSuchergebnisse
	If Not IsHWnd($GUI_ListeSuchergebnisse) Then $hWndListView = GUICtrlGetHandle($GUI_ListeSuchergebnisse)
	Local $tNMHDR = DllStructCreate($tagNMLISTVIEW, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $LVN_COLUMNCLICK ; A column was clicked
					_GUICtrlListView_AddColumn($GUI_ListeSuchergebnisse, "")
					For $i = 0 To _GUICtrlListView_GetItemCount($hWndListView) - 1
						_GUICtrlListView_SetItemText($hWndListView, $i, $i, 3)
					Next
					_GUICtrlListView_SimpleSort($hWndListView, $fSortSense, DllStructGetData($tNMHDR, "SubItem")) ; Sort direction for next sort toggled by default
					Dim $nummern[_GUICtrlListView_GetItemCount($hWndListView)]
					For $i = 0 To _GUICtrlListView_GetItemCount($hWndListView) - 1
						$tmpnr = _GUICtrlListView_GetItemTextArray($hWndListView, $i)
						$nummern[$i] = $tmpnr[4]
					Next
					;ConsoleWrite ("-----" & @CRLF)
					Dim $SongInfoNeu[UBound($SongInfo)][7]
					Global $kontextmenueNeu[UBound($kontextmenue)][4]
					For $i = 0 To UBound($nummern) - 1
						;ConsoleWrite ($i & " - " & $nummern[$i] & @CRLF)
						For $a = 0 To 6
							$SongInfoNeu[$i][$a] = $SongInfo[$nummern[$i]][$a]
						Next
						$kontextmenueNeu[$i][0] = $kontextmenue[$nummern[$i]][0]
						$kontextmenueNeu[$i][1] = $kontextmenue[$nummern[$i]][1]
						$kontextmenueNeu[$i][2] = $kontextmenue[$nummern[$i]][2]
						$kontextmenueNeu[$i][3] = $kontextmenue[$nummern[$i]][3]
					Next

					Dim $SongInfo[0][0]
					Dim $kontextmenue[0][0]
					$SongInfo = $SongInfoNeu
					$kontextmenue = $kontextmenueNeu
					Dim $SongInfoNeu[0][0]
					;Dim $kontextmenueNeu[0][0]
					_GUICtrlListView_DeleteColumn($hWndListView, 3)
				Case $NM_DBLCLK ;Doppelklick auf Listvieweintrag
					If UBound($SongInfosFuerDLListe) = 0 Then
						$a = 0
					Else
						If $SongInfosFuerDLListe[UBound($SongInfosFuerDLListe) - 1][0] = "" Then
							$a = 0
						Else
							$a = UBound($SongInfosFuerDLListe)
						EndIf
					EndIf
					$i = _GUICtrlListView_GetSelectionMark($hWndListView)
					If $i <> -1 Then
						$aItemText = _GUICtrlListView_GetItemTextArray($GUI_ListeSuchergebnisse, $i)
						GUICtrlCreateListViewItem($aItemText[1] & "|" & $aItemText[2] & "|" & $aItemText[3], $GUI_DLListe)
						ReDim $SongInfosFuerDLListe[$a + 1][7]
						$SongInfosFuerDLListe[$a][0] = $SongInfo[$i][0] ; Song ID
						$SongInfosFuerDLListe[$a][1] = $SongInfo[$i][1] ; Titel
						$SongInfosFuerDLListe[$a][2] = $SongInfo[$i][3] ; Interpret
						$SongInfosFuerDLListe[$a][3] = $SongInfo[$i][2] ; Album
						$SongInfosFuerDLListe[$a][4] = $SongInfo[$i][6] ; Cover-Info
						FileWrite("Data\DLListe.txt", $SongInfosFuerDLListe[$a][0] & "|" & $SongInfosFuerDLListe[$a][1] & "|" & $SongInfosFuerDLListe[$a][2] & "|" & $SongInfosFuerDLListe[$a][3] & "|" & $SongInfosFuerDLListe[$a][4] & @CRLF)

						Global $fadetext = $SongInfosFuerDLListe[$a][1] & " " & sprache("GR_MSG_ADDTODLL")
						Fadelabel()
					EndIf
			EndSwitch
	EndSwitch

EndFunc   ;==>_WM_NOTIFY

Func _AddControlsToPanel($hPanel)
	GUISwitch($hPanel)
EndFunc   ;==>_AddControlsToPanel

Func Fadelabel()
	;ConsoleWrite ("Label einfaden" & @CRLF)
	GUICtrlSetData($GUI_hinzufuegenlabel, $fadetext)

	$startwert = 250
	$endwert = 0
	$step = -10
	For $i = $startwert To $endwert Step $step
		$hexwert = "0x" & Hex($i, 2) & Hex($i, 2) & Hex($i, 2)
		;	ConsoleWrite ($hexwert & @CRLF)
		GUICtrlSetColor($GUI_hinzufuegenlabel, $hexwert)
		Sleep(5)
	Next
	Sleep(500)
	$startwert = 0
	$endwert = 250
	$step = 10
	For $i = $startwert To $endwert Step $step
		$hexwert = "0x" & Hex($i, 2) & Hex($i, 2) & Hex($i, 2)
		;	ConsoleWrite ($hexwert & @CRLF)
		GUICtrlSetColor($GUI_hinzufuegenlabel, $hexwert)
		Sleep(10)
	Next

EndFunc   ;==>Fadelabel

Func _ADS_Exists($sFile, $sStream)
	Return FileExists($sFile & ":" & $sStream)
EndFunc   ;==>_ADS_Exists

Func _ADS_Delete($sFile, $sStream)
	Local $aRes = DllCall("kernel32.dll", "bool", "DeleteFileW", "wstr", $sFile & ":" & $sStream)
	If @error Then Return SetError(2, 0, 0)
	Return SetError($aRes[0] = 0, 0, $aRes[0])
EndFunc   ;==>_ADS_Delete

Func Sec2Time($nr_sec)
   $sec2time_hour = Int($nr_sec / 3600)
   $sec2time_min = Int(($nr_sec - $sec2time_hour * 3600) / 60)
   $sec2time_sec = $nr_sec - $sec2time_hour * 3600 - $sec2time_min * 60
   ;Return StringFormat('%02d:%02d:%02d', $sec2time_hour, $sec2time_min, $sec2time_sec)
   Return StringFormat('%02d:%02d', $sec2time_min, $sec2time_sec)
EndFunc   ;==>Sec2Time

Func ScaleImage($sFile, $iScaleW, $iScaleH, $iInterpolationMode = 7) ;coded by UEZ 2012
	If Not FileExists($sFile) Then Return SetError(1, 0, 0)
	Local $hImage = _GDIPlus_ImageLoadFromFile($sFile)
	If @error Then Return SetError(2, 0, 0)
	Local $iWidth = $iScaleW
	Local $iHeight = $iScaleH
	Local $hBitmap = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", 0, "int", 0x0026200A, "ptr", 0, "int*", 0)
	If @error Then Return SetError(3, 0, 0)
	$hBitmap = $hBitmap[6]
	Local $hBmpCtxt = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	DllCall($ghGDIPDll, "uint", "GdipSetInterpolationMode", "handle", $hBmpCtxt, "int", $iInterpolationMode)
	_GDIPlus_GraphicsDrawImageRect($hBmpCtxt, $hImage, 0, 0, $iWidth, $iHeight)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hBmpCtxt)
	Return $hBitmap
EndFunc   ;==>ScaleImage

Func WM_GETMINMAXINFO($hWnd, $msg, $wParam, $lParam)
	$tagMaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
	DllStructSetData($tagMaxinfo, 7, 610) ; min X
	DllStructSetData($tagMaxinfo, 8, 350) ; min Y
	Return 0
EndFunc   ;==>WM_GETMINMAXINFO

Func sprache ($string)
	$returnstring = IniRead ("Data\Sprachen\"&$_sprache&".lng","GrooveLoad Language File",$string,$string)
	$returnstring = StringReplace ($returnstring,"[CRLF]",@CRLF)
	Return $returnstring
EndFunc

Func Timeout ($hOpen)
	_WinHttpSetTimeouts($hOpen, 0, 30000, 15000, 15000)
	; Remarks .......: Initial values are:
	;                  |- $iResolveTimeout = 0
	;                  |- $iConnectTimeout = 60000
	;                  |- $iSendTimeout = 30000
	;                  |- $iReceiveTimeout = 30000
EndFunc

$gibtsnicht = "" ; Diese Zeile wird nie ausgeführt und ist nur dafür da, dass die Syntaxüberprüfung keinen Fehler ausspuckt
Func Absturz()
	Beep(600, 300)
	Sleep(200)
	Beep(600, 300)
	Sleep(200)
	Beep(600, 1000)
	MsgBox(0, "", $gibtsnicht)
EndFunc   ;==>Absturz
