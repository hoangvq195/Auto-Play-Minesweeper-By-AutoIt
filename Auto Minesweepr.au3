#include <Array.au3>
#include <FastFind1.au3>

Opt('MouseClickDelay', 0)
Opt('MouseClickDownDelay', 0)

Global $hwnd, $width, $hight
Global $mine

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=D:\Dropbox\Autoit AutoGames Tutorial\Minesweeper\Form1.kxf
$Form1 = GUICreate("Auto Minesweeper", 358, 181, 100, 700)
GUISetFont(12, 400, 0, "MS Sans Serif")
$Label1 = GUICtrlCreateLabel("Kích Thước", 35, 36, 81, 22)
$Input1 = GUICtrlCreateInput("16", 129, 35, 67, 26, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
$Label2 = GUICtrlCreateLabel("X", 215, 37, 15, 22)
$Input2 = GUICtrlCreateInput("16", 233, 35, 67, 26, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
$Button1 = GUICtrlCreateButton("Start", 124, 91, 108, 51)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

_LoadConfig()
Func _LoadConfig()
	GUICtrlSetData($Input1, IniRead('config.ini', 'Setting', 'width', 16))
	GUICtrlSetData($Input2, IniRead('config.ini', 'Setting', 'hight', 16))
EndFunc   ;==>_LoadConfig

Func _CheckGuiEvent()
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			_StartAuto()
		Case $Input1
			IniWrite('config.ini', 'Setting', 'width', GUICtrlRead($Input1))
		Case $Input2
			IniWrite('config.ini', 'Setting', 'hight', GUICtrlRead($Input2))

	EndSwitch
EndFunc   ;==>_CheckGuiEvent

Func _StartAuto()
	$hwnd = WinGetHandle('Minesweeper')
	FFSetWnd($hwnd)
;~ 	FFSaveBMP('game') ; chup lai hinh anh game va luu ra file

	$width = GUICtrlRead($Input1)
	$hight = GUICtrlRead($Input2)

	Dim $mine[$hight + 2][$width + 2]
	For $i = 0 To $width + 1
		$mine[0][$i] = 0
		$mine[$hight + 1][$i] = 0
	Next
	For $i = 0 To $hight + 1
		$mine[$i][0] = 0
		$mine[$i][$width + 1] = 0
	Next

	_GetMineArray()
	_ArrayDisplay($mine)
EndFunc   ;==>_StartAuto

Func _GetMineArray()
	For $i = 1 To $width
		For $j = 1 To $hight
			$mine[$j][$i] = _GetCellValue($i, $j)
		Next
	Next
EndFunc   ;==>_GetMineArray

Func _GetCellValue($x, $y)
	Local $count = FFColorCount(0xC0C0C0, 0, True, 13 + 16 * ($x - 1), 56 + 16 * ($y - 1), 26 + 16 * ($x - 1), 69 + 16 * ($y - 1))

	Switch $count
		Case 146
			Return -1
		Case 196
			Return 0
		Case 156
			Return 1
		Case 131
			Return 2
		Case 134
			Return 3
		Case 140
			Return 4
	EndSwitch
EndFunc   ;==>_GetCellValue

Func _CellClick($x, $y, $mouse = 'left')
	ControlClick($hwnd, '', '', $mouse, 1, 20 + 16 * ($x - 1), 68 + 16 * ($y - 1))
EndFunc   ;==>_CellClick

While 1
	_CheckGuiEvent()
WEnd
