#NoTrayIcon
FileChangeDir (@ScriptDir)

;MsgBox (0,"","Reinhören gestartet")
#include "WinHTTP\WinHTTP.au3"
#include "Bass\Bass.au3"
#include <String.au3>

; Wird für die Proxyfunktion benötigt
Global Const $tagWINHTTP_PROXY_INFO = "DWORD  dwAccessType;ptr lpszProxy;ptr lpszProxyBypass;"

$StreamIP = FileReadLine ("Reinhören.txt",1)
$StreamKey = FileReadLine ("Reinhören.txt",2)
$Musiktitel = FileReadLine ("Reinhören.txt",3)
$Spieldauer = FileReadLine ("Reinhören.txt",4)
$Fenstertitel = FileReadLine ("Reinhören.txt",5)
$Dateigroesse = "-1"

If $StreamIP = "" Or $StreamKey = "" Then
	Exit
EndIf

$Proxy = False
If IniRead ("config.ini","Proxy","Proxy_nutzen","4") = 1 Then $Proxy = True
$ProxyIP = IniRead ("config.ini","Proxy","Proxy_IP","")

If IniRead ("config.ini","X-FORWARDED-FOR","FORWARDED_nutzen","1") = 1 Then
	$FakeIP = "X-FORWARDED-FOR: "&IniRead ("config.ini","X-FORWARDED-FOR","FORWARDED_IP","81.158.166.")& Random (100,255,1)
Else
	$FakeIP = ""
EndIf
FileDelete ("Reinhören.txt")

$timer = TimerInit ()
$hDLOpen = _WinHttpOpen("")
If $Proxy = True Then
	$tProxyInfo = _WinHttpProxyInfoCreate($WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxyIP, "localhost")
	_WinHttpSetOption($hDLOpen, $WINHTTP_OPTION_PROXY, $tProxyInfo[0])
EndIf
$ConnectionDL = _WinHttpConnect($hDLOpen, $StreamIP)
$h_openRequest = _WinHttpOpenRequest($ConnectionDL, "POST", "/stream.php")
_WinHttpSendRequest($h_openRequest, $FakeIP & @CRLF & "Content-Type: application/x-www-form-urlencoded", 'streamKey=' & $StreamKey)
_WinHttpReceiveResponse($h_openRequest)

$header = _WinHttpQueryHeaders($h_openRequest)
$dateigroesse = _StringBetween($header, "Content-Length: ", @CRLF)
If IsArray($dateigroesse) Then $dateigroesse = $dateigroesse[0]

$file = @ScriptDir & "\tmp\" & Random(0,9999999999999,1)&".mp3"
Local $data = Binary("")
FileDelete($file)
$play = 0
$reinhoerenhandle = FileOpen($file, 16 + 1 + 8)
$anzahlfehler = 0
$dlfertig = 0
$puffer = 0
$current = "Blub"
$bytesread = IniRead("config.ini", "Downloadeinstellungen", "NumberOfBytesToRead", 150000)

ShellExecute ("AutoIt3.exe",'"Reinhören GUI.au3" "'&$file&'" "'&$Musiktitel&'" "'&$Spieldauer&'" "'&$Dateigroesse&'" "'&@AutoItPID&'" "'&$Fenstertitel&'"')

While 1
	If $dlfertig = 2 Then
;		ConsoleWrite("Fertig" & @CRLF)
		ExitLoop
	EndIf
	If $dlfertig = 0 Then
		$chunk = _WinHttpReadData($h_openRequest, 2, $bytesread)
		If @error then
			Exit
		EndIf
		FileWrite($reinhoerenhandle, $chunk)
	EndIf
WEnd

FileClose($reinhoerenhandle)
_WinHttpCloseHandle($hDLOpen)

Func _WinHttpProxyInfoCreate($dwAccessType, $sProxy, $sProxyBypass)
    Local $tWINHTTP_PROXY_INFO[2] = [DllStructCreate($tagWINHTTP_PROXY_INFO), DllStructCreate('wchar proxychars[' & StringLen($sProxy)+1 & ']; wchar proxybypasschars[' & StringLen($sProxyBypass)+1 & ']')]
    DllStructSetData($tWINHTTP_PROXY_INFO[0], "dwAccessType", $dwAccessType)
    If StringLen($sProxy) Then DllStructSetData($tWINHTTP_PROXY_INFO[0], "lpszProxy", DllStructGetPtr($tWINHTTP_PROXY_INFO[1], 'proxychars'))
    If StringLen($sProxyByPass) Then DllStructSetData($tWINHTTP_PROXY_INFO[0], "lpszProxyBypass", DllStructGetPtr($tWINHTTP_PROXY_INFO[1], 'proxybypasschars'))
    DllStructSetData($tWINHTTP_PROXY_INFO[1], "proxychars", $sProxy)
    DllStructSetData($tWINHTTP_PROXY_INFO[1], "proxybypasschars", $sProxyBypass)
    Return $tWINHTTP_PROXY_INFO
EndFunc