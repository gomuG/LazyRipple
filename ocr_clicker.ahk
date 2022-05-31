;hotkey to activate OCR
x_start := 0
x_end := 0
y_start := 0
y_end := 0
drawn_gui := 0

^q::
	WinGetTitle, active_title, A
	destroyGui(drawn_gui)

	WinGet, PID, PID, active_title
	getSelectionCoords(x_start, x_end, y_start, y_end)
	drawSelectionCoordsGui(x_start, x_end, y_start, y_end, drawn_gui)
	WinActivate, %active_title%
return

+q::
	WinGetTitle, active_title, A
	clickArea(x_start, x_end, y_start, y_end, active_title)
return

#MaxThreadsPerHotkey 2
^f1::
	toggle := !toggle

	if not drawn_gui
		toggle = false

	WinGetTitle, active_title, A

	if toggle{
		Gui, Color, 00FF00
		MsgBox, Setting "%active_title%" as window to click. Click ok to proceed
	} else {
		Gui, Color, FF0000
	}


	Loop {
		If not toggle
			break

		getAreaText(x_start, x_end, y_start, y_end)

		if InStr(clipboard, "Dimension-Dhalia") {
			clickArea(x_start, x_end, y_start, y_end, active_title)
		}
		else if InStr(clipboard, "Dimension-Ye Suhua") {
			clickArea(x_start, x_end, y_start, y_end, active_title)
		}
	}
return

^+r::
	Reload
return


getAreaText(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end) {
	RunWait, ./Capture2Text/Capture2Text_CLI.exe -s "%x_start% %y_start% %x_end% %y_end%" --clipboard --blacklist "01234567890!1g",,  hide
}

clickArea(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end, ByRef title){
	WinGetPos, ws_x, ws_y, ws_w, ws_h, %title%
	rel_x_s := x_start - ws_x
	rel_y_s := y_start - ws_y
	rel_x_e := x_end - ws_x
	rel_y_e := y_end - ws_y

	click_zone_x := rel_x_e - rel_x_s
	click_zone_y := rel_y_e - rel_y_s
	click_increment_x := click_zone_x//6
	click_increment_y := click_zone_y//6
	click_end_x := rel_x_e - click_increment_x
	click_end_y := rel_y_e - click_increment_y

	click_x := rel_x_s+click_increment_x
	click_y := rel_y_s+click_increment_y
	count := 0
	while (click_y < click_end_y) {
		while (click_x < click_end_x) {
			SetControlDelay -1
			ControlClick, x%click_x% y%click_y%,%title%
			click_x := click_x + click_increment_x
			Sleep, 20
		}
		click_x := rel_x_s+click_increment_x
		click_y := click_y + click_increment_y
		if (count > 100) break
		count++
	}
	MsgBox, Clicking "%title%"
}


destroyGui(byRef drawn_gui){
	if (drawn_gui = 1){
		drawn_gui := 0
		toggle:= 0
		Gui Destroy
	}
}

; draws gui around selected area
drawSelectionCoordsGui(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end, ByRef drawn_gui) {
	win_width := x_end-x_start
	win_height := y_end-y_start

	Gui, Color, FF0000
	Gui, +LastFound +E0x20
	WinSet, Transparent, 50
	Gui, -Caption 
	Gui, +AlwaysOnTop
	Gui, Show, x%x_start% y%y_start% h%win_height% w%win_width%,"AutoHotkeySnapshotApp"     
	drawn_gui := 1
}

; creates a click-and-drag selection box to specify an area
getSelectionCoords(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end) {
	;Mask Screen
	Gui, Color, FFFFFF
	Gui +LastFound
	WinSet, Transparent, 50
	Gui, -Caption 
	Gui, +AlwaysOnTop
	Gui, Show, x0 y-1080 h2516 w3643,"AutoHotkeySnapshotApp"     

	;Drag Mouse
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	WinGet, hw_frame_m,ID,"AutoHotkeySnapshotApp"
	hdc_frame_m := DllCall( "GetDC", "uint", hw_frame_m)
	KeyWait, LButton, D 
	MouseGetPos, scan_x_start, scan_y_start 
	Loop
	{
		Sleep, 10   
		KeyIsDown := GetKeyState("LButton")
		if (KeyIsDown != 1){
			break
		}
	}

	;KeyWait, LButton, U
	MouseGetPos, scan_x_end, scan_y_end
	Gui Destroy
	
	if (scan_x_start < scan_x_end)
	{
		x_start := scan_x_start
		x_end := scan_x_end
	} else {
		x_start := scan_x_end
		x_end := scan_x_start
	}
	
	if (scan_y_start < scan_y_end)
	{
		y_start := scan_y_start
		y_end := scan_y_end
	} else {
		y_start := scan_y_end
		y_end := scan_y_start
	}
}
