#include <Array.au3>
#include <FastFind1.au3>
#include <Math.au3>

Opt('MouseClickDelay', 0)
Opt('MouseClickDownDelay', 0)

Global $hwnd, $width, $hight
Global $mine, $unOpenCell, $numberCell
Const $empty = 0, $none = -1, $flag = -2, $mask = -3
Global $isChange

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
		$isChange = False
		_GetMineArray()
		_CanculateLev1()
		If Not $isChange Then _CanculateLev2()
		If Not $isChange Then _CanculateLev3()
		Local $state = FFColorCount(0x000000, 0, True, 240, 16, 264, 40)
		If $state = 63 Then Return _StartAuto()
		If $state = 86 Then Return MsgBox(0, '', 'You win!')
	Until 0
EndFunc   ;==>_StartAuto

Func _CanculateLev3()
	Local $count = UBound($unOpenCell)
	If $count = 0 Then Return
	Local $id = Random($count - 1, 0, 1)
	_CellClick($unOpenCell[$id][1], $unOpenCell[$id][0])
EndFunc   ;==>_CanculateLev3

Func _CanculateLev2()
	Local $total = UBound($numberCell)
	For $id = $total - 1 To 0 Step -1
		$i1 = $numberCell[$id][0]
		$j1 = $numberCell[$id][1]
		Local $none1Count = _CountItemAround($none, $i1, $j1)
		Local $flag1Count = _CountItemAround($flag, $i1, $j1)
		Local $bomb1Count = $mine[$i1][$j1] - $flag1Count
		_MarkAround($i1, $j1)

		For $i = $i1 - 2 To $i1 + 2
			For $j = $j1 - 2 To $j1 + 2
				If $i < 1 Or $i > $hight Then ContinueLoop
				If $j < 1 Or $j > $width Then ContinueLoop

				If $i = $i1 And $j = $j1 Then ContinueLoop
				If $mine[$i][$j] <= 0 Then ContinueLoop
				Local $noneCount = _CountItemAround($none, $i, $j)
				If $noneCount = 0 Then ContinueLoop
				Local $flagCount = _CountItemAround($flag, $i, $j)

				Local $maskCount = _CountItemAround($mask, $i, $j)
				If $maskCount <= 1 Then ContinueLoop

				Local $maxBomb = _Min($bomb1Count, $maskCount)
				Local $minBomb = _Max($bomb1Count - ($none1Count - $maskCount), 0)

				If $minBomb = $mine[$i][$j] - $flagCount Then
					_OpenAroud($i, $j)
				EndIf

				If $maxBomb + $noneCount = $mine[$i][$j] - $flagCount Then
					_FlagAround($i, $j)
				EndIf
			Next
		Next
		_MarkAround($i1, $j1, False)
	Next
EndFunc   ;==>_CanculateLev2

Func _MarkAround($x, $y, $isMask = True)
	For $i = $x - 1 To $x + 1
		For $j = $y - 1 To $y + 1
			If $i = $x And $j = $y Then ContinueLoop
			If $isMask Then
				If $mine[$i][$j] = $none Then $mine[$i][$j] = $mask
			Else
				If $mine[$i][$j] = $mask Then $mine[$i][$j] = $none
			EndIf
		Next
	Next
EndFunc   ;==>_MarkAround

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

		If $checkBomb > 0 Then ControlSend($hwnd, '', '', '{F2}')

		If $totalNotOpenCell < 0.85 * $width * $hight Then ExitLoop
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
;~ 	Exit _ArrayDisplay($mine)
EndFunc   ;==>_GetMineArray

Func _GetCellValue($x, $y)
	Local $count = FFColorCount(0xC0C0C0, 0, True, 13 + 16 * ($x - 1), 56 + 16 * ($y - 1), 26 + 16 * ($x - 1), 69 + 16 * ($y - 1))
;~ 	Return $count; tam thoi
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
		Case 126
			Return 5
		Case 124
			Return 6
		Case 152
			Return 7
	EndSwitch
	Return -1
EndFunc   ;==>_GetCellValue

Func _CellClick($x, $y, $mouse = 'left')
	ControlClick($hwnd, '', '', $mouse, 1, 20 + 16 * ($x - 1), 68 + 16 * ($y - 1))
	$isChange = True
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

Func _OpenAroud($x, $y)
	For $i = $x - 1 To $x + 1
		For $j = $y - 1 To $y + 1
			If $i = $x And $j = $y Then ContinueLoop
			If $mine[$i][$j] = $none Then _CellClick($j, $i)
		Next
	Next
EndFunc   ;==>_OpenAroud

While 1
	_CheckGuiEvent()
	_CheckGameState()
	_CheckGameSize()
WEnd


