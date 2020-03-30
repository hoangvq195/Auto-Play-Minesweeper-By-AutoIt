Global $hwnd, $width, $hight

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=D:\Dropbox\Autoit AutoGames Tutorial\Minesweeper\Form1.kxf
$Form1 = GUICreate("Auto Minesweeper", 358, 181, 498, 305)
GUISetFont(12, 400, 0, "MS Sans Serif")
$Label1 = GUICtrlCreateLabel("Kích Thước", 35, 36, 81, 22)
$Input1 = GUICtrlCreateInput("16", 129, 35, 67, 26, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
$Label2 = GUICtrlCreateLabel("X", 215, 37, 15, 22)
$Input2 = GUICtrlCreateInput("16", 233, 35, 67, 26, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
$Button1 = GUICtrlCreateButton("Start", 124, 91, 108, 51)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Func _CheckGuiEvent()
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			_StartAuto()

	EndSwitch
EndFunc   ;==>_CheckGuiEvent

Func _StartAuto()
	$hwnd = WinGetHandle('Minesweeper')
	$width = GUICtrlRead($Input1)
	$hight = GUICtrlRead($Input2)
	For $i = 1 To $width
		For $j = 1 To $hight
			_CellClick($i, $j, 'right')
		Next
	Next
EndFunc   ;==>_StartAuto

Func _CellClick($x, $y, $mouse = 'left')
	ControlClick($hwnd, '', '', $mouse, 1, 20 + 16 * ($x - 1), 68 + 16 * ($y - 1))
EndFunc   ;==>_CellClick

While 1
	_CheckGuiEvent()
WEnd
