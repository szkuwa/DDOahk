#SingleInstance force
#IfWinActive ahk_class Turbine Device Class
#include Gdip_All.ahk



;================== Configuration section, feel free to tinker here
;================== but be sure to keep name on the left side of := and = untouched

;; character name which is a subfolder that will contain items images
;; - if this is set as false (or blank) the user will be prompted to enter character name each time he run/reload the script (false must be written without quotes)
;; - if the name contains \ string it will make a sub folder(s)
;; for example "toon1\bank" will create folder "bank" inside folder "toon1"
;characterName := "toon1"
characterName := false

;; image quality, 0-100 (percents, the more the better)
imageQuality := 100

;; logs will be stored in this file
;; if set to false or empty logs will be omitted
logFile := "log.txt"

;================== DO NOT TOUCH LINES BELOW UNLESS YOU KNOW WHAT YOU'RE DOING

;================== frame offsets in pixels
availableFrames = normal,white,gold,cooper
frameOffset := Object() ; dont touch this

frameOffset["normal"] := Object()
frameOffset["normal"]["top"] := -4
frameOffset["normal"]["left"] := -4
frameOffset["normal"]["right"] := 23
frameOffset["normal"]["bottom"] := 55

frameOffset["white"] := Object()
frameOffset["white"]["top"] := 1
frameOffset["white"]["left"] := -10
frameOffset["white"]["right"] := 28
frameOffset["white"]["bottom"] := 30

frameOffset["gold"] := Object()
frameOffset["gold"]["top"] := 1
frameOffset["gold"]["left"] := -10
frameOffset["gold"]["right"] := 36
frameOffset["gold"]["bottom"] := 20

frameOffset["cooper"] := Object()
frameOffset["cooper"]["top"] := -4
frameOffset["cooper"]["left"] := -4
frameOffset["cooper"]["right"] := 34
frameOffset["cooper"]["bottom"] := 30
;================== end of frame offsets

;================== scrtip initialization
#Persistent
	; if no character name was specified ask the user on startup
	if (characterName = false)
	{
		InputBox characterName, Character name, Enter character name
		if (ErrorLevel or characterName = "")
		{
			MsgBox Default folder 'output' will be used
			characterName := "output"
		}
	}

	pToken := Gdip_Startup()			; initialize graphic lib
	frames := StrSplit(availableFrames, ",")
	OnExit("ClearScriptVariables")	; register function that will be run before shutting down
return

;================== shortcut to export item 
;================== you CAN change the line below to customize hotkey
;================== use https://www.autohotkey.com/docs/Hotkeys.htm as a reference
^F1::
	bitmap := GrabImage()
	if (bitmap = 0)
	{
		; script was unable to grab item frame - play sound and exit
		SoundPlay *16
		return
	}

	clipboard := ""
	Send ^{rbutton}
	Send {RShift down}{Home}{RShift up}
	Send ^c
	ClipWait 2
	if ErrorLevel 
	{
		; if there was an error (nothing went to clipboard) then exit
		SoundPlay *16
		return
	}
	
	item := clipboard
	Log("Found " . item)

	if SaveImage(bitmap, item)
	{
		SoundPlay *64
	} else {
		SoundPlay *16
	}
	
	Send {esc}
return

^F2::
	InputBox characterName, Character name, Enter character name,,,,,,,,%characterName%
	if (ErrorLevel or characterName = "")
	{
		MsgBox Default folder 'output' will be used
		characterName := "output"
	}
return

GrabImage()
{
	global frames
	
	Loop % frames.MaxIndex()
	{
		frameName := frames[a_index]
		frame := GrabItemFrame(frameName)
		if (frame)
			return frame
	}
	
	return false
}

GrabItemFrame(frameType)
{
	global frameOffset
	
	CoordMode Pixel, Screen
	
	topImage := "frames\" . frameType . "_tl.png"
	bottomImage := "frames\" . frameType . "_br.png"

	ImageSearch TopX, TopY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *30 %topImage%
	if ErrorLevel = 2
		Log("There was a problem with '" . topImage . "' image")
		
	ImageSearch BottomX, BottomY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *30 %bottomImage%
	if ErrorLevel = 2
		Log("There was a problem with '" . bottomImage . "' image")
	
	screen=%TopX%|%TopY%|%BottomX%|%BottomY%
	Log("Pos (" . screen . ")")
	
	BottomX := BottomX-TopX+frameOffset[frameType]["right"]
	BottomY := BottomY-TopY+frameOffset[frameType]["bottom"]
	TopX := TopX+frameOffset[frameType]["left"]
	TopY := TopY+frameOffset[frameType]["top"]
	
	screen=%TopX%|%TopY%|%BottomX%|%BottomY%
	
	if (TopX = "") || (TopY = "") || (BottomX = "") || (BottomY = "")
	{
		Log("Frame '" . frameType . "' not found. (" . screen . ")")
		return false
	}
	else 
	{	
		Log("Frame '" . frameType . "' found at (" . screen . ")")
		return Gdip_BitmapFromScreen(screen)
	}
	return false
}

SaveImage(bitmap, item)
{
	global imageQuality
	global characterName
	
	; replace ":" in item name since its not a valid character for file name
	item := StrReplace(item, ":", "")
	file := characterName . "\" . item . ".jpg"
	
	IfNotExist %characterName%
		FileCreateDir %characterName%
	
	if (bitmap and item)
	{
		Gdip_SaveBitmapToFile(bitmap, file, imageQuality)
		Gdip_DisposeImage(bitmap)
		
		Log("Item " . item . " saved to " . file . "!")
		return true
	} else {
		Log("There was a problem while saving item " . item . " to file " . file)
	}
	return false
}


Log(text)
{
	global logFile
	if (logFile) {
		FileAppend %text%`n, %logFile%
	}
}

ClearScriptVariables(ExitReason, ExitCode)
{
	global pToken
	
	if (pToken)
	{
		Gdip_Shutdown(pToken)	; unload graphic lib
	}
	
	return 0	; if non-zero prevents shutdown
}