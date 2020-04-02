#include <Array.au3>
#include <FastFind1.au3>

Opt('MouseClickDelay', 0)
Opt('MouseClickDownDelay', 0)

Global $hwnd, $width, $hight
Global $mine, $unOpenCell, $numberCell
Global $empty = 0, $none = -1, $flag = -2

#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=
Global $AutoPlayMinesweeper = GUICreate("AutoPlayMinesweeper", 462, 224, 192, 124)
GUISetFont(12, 400, 0, "MS Sans Serif")
Global $Label1 = GUICtrlCreateLabel("AUTO PLAY MINESWEEPER", 123, 21, 214, 22)
Global $Label2 = GUICtrlCreateLabel("Game State:", 51, 66, 200, 22)
Global $Label3 = GUICtrlCreateLabel("Game Size:", 51, 105, 200, 22)
Global $Button1 = GUICtrlCreateButton("Start Play", 161, 150, 141, 43)
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
	If Not $hwnd Then Return MsgBox(0, 'Error', 'Game is not started')
	FFSetWnd($hwnd)
;~ 	Exit FFSaveBMP('game') ; chup lai hinh anh game va luu ra file

	Dim $mine[$hight + 2][$width + 2]
	Dim $unOpenCell[0][2]
	Dim $numberCell[0][2]

	For $i = 0 To $width + 1
		$mine[0][$i] = 0
		$mine[$hight + 1][$i] = 0
	Next
	For $i = 0 To $hight + 1
		$mine[$i][0] = 0
		$mine[$i][$width + 1] = 0
	Next
	For $i = 1 To $hight
		For $j = 1 To $width
			$mine[$i][$j] = -1
			_ArrayAdd($unOpenCell, $i & '|' & $j)
		Next
	Next

	_RandomOpen()
	Do
		_GetMineArray()
		_CanculateLev1()
	Until 0
EndFunc   ;==>_StartAuto

Func _CanculateLev1()
	Local $total
	$total = UBound($numberCell)
	For $id = $total - 1 To 0 Step -1
		Local $i = $numberCell[$id][0]
		Local $j = $numberCell[$id][1]
		Local $noneCount = _CountItemAround($none, $i, $j)
		If $noneCount = 0 Then
			_ArrayDelete($numberCell, $id)
		Else
			Local $flagCount = _CountItemAround($flag, $i, $j)
			If $flagCount + $noneCount = $mine[$i][$j] Then
				_FlagAround($i, $j)
				_ArrayDelete($numberCell, $id)
			EndIf
		EndIf
	Next

	$total = UBound($numberCell)
	For $id = $total - 1 To 0 Step -1
		Local $i = $numberCell[$id][0]
		Local $j = $numberCell[$id][1]
		Local $noneCount = _CountItemAround($none, $i, $j)
		If $noneCount = 0 Then
			_ArrayDelete($numberCell, $id)
		Else
			Local $flagCount = _CountItemAround($flag, $i, $j)
			If $flagCount = $mine[$i][$j] Then
				_CellClick($j, $i, 'middle')
				_ArrayDelete($numberCell, $id)
			EndIf
		EndIf
	Next
EndFunc   ;==>_CanculateLev1

Func _RandomOpen()
	ControlSend($hwnd, '', '', '{F2}')
	Local $count = 0
	Do
		_CellClick(Random(1, $width, 1), Random(1, $hight, 1))
		$count += 1
		Local $totalNotOpenCell = _GetGameColor(0xFFFFFF, 54)
		Local $checkBomb = _GetGameColor(0x000000)
		If $totalNotOpenCell < $width * $hight - $count Then
			If $checkBomb = 0 Then
				ExitLoop
			Else
				$count = 0
				ControlSend($hwnd, '', '', '{F2}')
			EndIf
		EndIf
	Until 0
EndFunc   ;==>_RandomOpen

Func _GetGameColor($color, $unit = 1)
	Local $count = FFColorCount($color, 0, True, 12, 55, 491, 310)
	Return Round($count / $unit)
EndFunc   ;==>_GetGameColor

Func _ShowMine()
	For $i = 1 To $hight
		For $j = 1 To $width
			Switch $mine[$i][$j]
				Case -1
					ConsoleWrite('. ')
				Case 0
					ConsoleWrite('  ')
				Case Else
					ConsoleWrite($mine[$i][$j] & ' ')
			EndSwitch
		Next
		ConsoleWrite(@CRLF)
	Next
EndFunc   ;==>_ShowMine

Func _GetMineArray()
	Local $arraySize = UBound($unOpenCell)
	For $n = $arraySize - 1 To 0 Step -1
		$i = $unOpenCell[$n][0]
		$j = $unOpenCell[$n][1]
		If $mine[$i][$j] = $flag Then
			_ArrayDelete($unOpenCell, $n)
		Else
			$mine[$i][$j] = _GetCellValue($j, $i)
			If $mine[$i][$j] <> -1 Then _ArrayDelete($unOpenCell, $n)
			If $mine[$i][$j] <> -1 And $mine[$i][$j] <> 0 Then _ArrayAdd($numberCell, $i & '|' & $j)
		EndIf
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
	Return -1
EndFunc   ;==>_GetCellValue

Func _CellClick($x, $y, $mouse = 'left')
	ControlClick($hwnd, '', '', $mouse, 1, 20 + 16 * ($x - 1), 68 + 16 * ($y - 1))
EndFunc   ;==>_CellClick

Func _CheckGameState()
	Local Static $gameState = WinExists('Minesweeper')
	Local Static $isFirstRun = True

	If $gameState <> WinExists('Minesweeper') Or $isFirstRun Then
		$gameState = WinExists('Minesweeper')
		$isFirstRun = False
		If $gameState Then
			$hwnd = WinGetHandle('Minesweeper')
			GUICtrlSetData($Label2, 'Game State:' & @TAB & 'Running')
		Else
			$hwnd = 0
			GUICtrlSetData($Label2, 'Game State:' & @TAB & 'Stop')
			GUICtrlSetData($Label3, 'Game Size:')
		EndIf
	EndIf
EndFunc   ;==>_CheckGameState

Func _CheckGameSize()
	Local Static $gameSize[2]
	If Not $hwnd Then Return
	If $gameSize[0] = WinGetClientSize($hwnd)[0] And $gameSize[1] = WinGetClientSize($hwnd)[1] Then Return
	$gameSize = WinGetClientSize($hwnd)
	$width = ($gameSize[0] - 20) / 16
	$hight = ($gameSize[1] - 63) / 16
	GUICtrlSetData($Label3, 'Game Size:' & @TAB & $width & ' x ' & $hight)
EndFunc   ;==>_CheckGameSize

Func _CountItemAround($item, $x, $y)
	Local $count = 0
	For $i = $x - 1 To $x + 1
		For $j = $y - 1 To $y + 1
			If $i = $x And $j = $y Then ContinueLoop
			If $mine[$i][$j] = $item Then $count += 1
		Next
	Next
	Return $count
EndFunc   ;==>_CountItemAround

Func _FlagAround($x, $y)
	For $i = $x - 1 To $x + 1
		For $j = $y - 1 To $y + 1
			If $i = $x And $j = $y Then ContinueLoop
			If $mine[$i][$j] = $none Then
				_CellClick($j, $i, 'right')
				$mine[$i][$j] = $flag
			EndIf
		Next
	Next
EndFunc   ;==>_FlagAround

While 1
	_CheckGuiEvent()
	_CheckGameState()
	_CheckGameSize()
WEnd


