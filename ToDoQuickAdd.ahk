#Requires AutoHotkey v2.0+
#SingleInstance force

; Script Variables
VarScriptName := "ToDoQuickAdd"
VarVersionNo := "v011"
ConfigFile := A_ScriptDir "\" VarScriptName "_config.ini"
LogFile := A_ScriptDir "\" VarScriptName ".log"
MaxLogEntries := 1000  ; Maximum number of log entries to keep

; Initialize current hotkey
CurrentHotkey := IniRead(ConfigFile, "Settings", "Hotkey", "^!t")  ; Default to Ctrl+Alt+T
Varblurb := "`nPress " FormatHotkey(CurrentHotkey) " to add the contents`nof your clipboard as a task in ToDo"

; Multi-monitor support functions
GetMonitorWorkArea(&workLeft, &workTop, &workRight, &workBottom) {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&cursorX, &cursorY)
    Loop MonitorGetCount() {
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        if (cursorX >= left && cursorX <= right && cursorY >= top && cursorY <= bottom) {
            MonitorGetWorkArea(A_Index, &workLeft, &workTop, &workRight, &workBottom)
            return true
        }
    }
    return false
}

CenterWindow(width, height) {
    if GetMonitorWorkArea(&workLeft, &workTop, &workRight, &workBottom) {
        centerX := (workRight + workLeft) // 2
        return [centerX - (width // 2), workTop + (workBottom - workTop) // 3]
    }
}

CenterOnActiveMonitor() {
    if hwnd := WinActive("A") {
        WinGetPos(, , &width, &height, hwnd)
        if pos := CenterWindow(width, height)
            WinMove(pos[1], pos[2],,, hwnd)
    }
}

; Initialize Tray Icon
A_IconTip := VarScriptName " " VarVersionNo " " Varblurb
Try TraySetIcon(A_ScriptDir "\" VarScriptName ".ico")
Catch
    TrayTip "Remember to add " VarScriptName ".ico to same folder as " VarScriptName ".ahk", VarScriptName
TrayTip Varblurb, VarScriptName " " VarVersionNo

; Read or Request API URL
API_URL := ReadOrRequestURL()

; Setup initial hotkey
SetupHotkey(CurrentHotkey)

; Hotkey change function
ChangeHotkey(*) {
    global CurrentHotkey, Varblurb

    ; Create GUI for hotkey input
    MyGui := Gui("+AlwaysOnTop +ToolWindow", VarScriptName " - Change Hotkey")
    MyGui.SetFont("s10")
    MyGui.Add("Text",, "Press the desired key combination")
    hotkeyInput := MyGui.Add("Hotkey", "vChosenHotkey w200", CurrentHotkey)
    MyGui.Add("Button", "Default w100", "OK").OnEvent("Click", ProcessHotkey)
    MyGui.Add("Button", "x+5 w100", "Cancel").OnEvent("Click", (*) => MyGui.Destroy())

    ; Center the GUI on screen
    SetTimer(CenterOnActiveMonitor, -100)
    MyGui.Show()

    ProcessHotkey(*) {
        newHotkey := hotkeyInput.Value
        if (newHotkey = "") {
            MsgBox("Please specify a hotkey combination.", "Error", 16)
            return
        }

        try {
            ; Try to set up the new hotkey
            if SetupHotkey(newHotkey) {
                ; If successful, save it
                IniWrite(newHotkey, ConfigFile, "Settings", "Hotkey")
                CurrentHotkey := newHotkey
                ; Update blurb with new hotkey
                Varblurb := "`nPress " FormatHotkey(CurrentHotkey) " to add`nyour clipboard as task to ToDo"
                A_IconTip := VarScriptName " " VarVersionNo " " Varblurb
                TrayTip("Hotkey changed to " FormatHotkey(CurrentHotkey), VarScriptName " " VarVersionNo)
                Log(FormatLogEntry("Hotkey changed to: " FormatHotkey(CurrentHotkey)))
                MyGui.Destroy()
            }
        } catch Error as err {
            MsgBox("Invalid hotkey combination. Please try again.`nError: " err.Message, "Error", 16)
        }
    }
}

FormatHotkey(hotkeyString) {
    ; Store modifiers in an array
    modifiers := []

    ; Check for each modifier and add to array
    if (InStr(hotkeyString, "^"))
        modifiers.Push("Ctrl")
    if (InStr(hotkeyString, "!"))
        modifiers.Push("Alt")
    if (InStr(hotkeyString, "+"))
        modifiers.Push("Shift")
    if (InStr(hotkeyString, "#"))
        modifiers.Push("Win")

    ; Get the key (last character after removing modifiers)
    key := RegExReplace(hotkeyString, "[^!+#]+")    ; Remove the modifiers
    key := SubStr(hotkeyString, StrLen(hotkeyString))  ; Get the last character

    ; Join modifiers with +
    result := ""
    for modifier in modifiers {
        result .= modifier "+"
    }

    ; Return joined modifiers plus key
    return result StrUpper(key)
}


SetupHotkey(hotkeyString) {
    static currentHotkey := ""

    ; If there's an existing hotkey, remove it
    if (currentHotkey) {
        try {
            Hotkey(currentHotkey, "Off")
        }
    }

    ; Set up the new hotkey
    try {
        Hotkey(hotkeyString, QuickAdd)
        currentHotkey := hotkeyString
        return true
    } catch Error as err {
        MsgBox("Invalid hotkey: " hotkeyString "`nError: " err.Message, "Error", 16)
        return false
    }
}

; Function to escape JSON strings
EscapeJSON(str) {
    escaped := StrReplace(str, "\", "\\")
    escaped := StrReplace(escaped, '"', '\"')
    escaped := StrReplace(escaped, "`n", "\n")
    escaped := StrReplace(escaped, "`r", "\r")
    escaped := StrReplace(escaped, "`t", "\t")
    return escaped
}

QuickAdd(*) {
    ; Launch input box for task title
    SetTimer(CenterOnActiveMonitor, -100)
    IB := InputBox("Add a task to Microsoft Todo`n`nStep 1/2 - Enter Task Title:`n(Clipboard is pre-filled below)", VarScriptName " " VarVersionNo, "w400 h150", A_Clipboard)
    if IB.Result = "Cancel" {
        TrayTip "Task creation cancelled", VarScriptName " " VarVersionNo
        return
    }
    taskTitle := IB.Value

    ; Launch input box for description (optional)
    SetTimer(CenterOnActiveMonitor, -100)
    IB2 := InputBox("Step 2/2 - Add Task Description (Optional):`n(Leave empty if no description needed)", VarScriptName " " VarVersionNo, "w400 h150")
    taskDesc := IB2.Result = "Cancel" ? "" : IB2.Value

    ; Escape the strings and prepare the JSON payload
    escapedTitle := EscapeJSON(taskTitle)
    escapedDesc := EscapeJSON(taskDesc)
    payload := '{"title":"' escapedTitle '","content":"' escapedDesc '"}'

    ; Create WinHTTP object
    Try {
        logEntry := FormatLogEntry("Sending task: " taskTitle)
        Log(logEntry)

        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", API_URL, true)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(payload)
        http.WaitForResponse()

        if (http.Status = 200) {
            logEntry := FormatLogEntry("Success - Server response: " http.ResponseText)
            Log(logEntry)
            TrayTip "Task added successfully!", VarScriptName " " VarVersionNo
        } else {
            logEntry := FormatLogEntry("Error - Status: " http.Status " Response: " http.ResponseText)
            Log(logEntry)
            TrayTip "Error adding task: " http.Status, VarScriptName " " VarVersionNo
        }
    } Catch as err {
        logEntry := FormatLogEntry("Error - " err.Message)
        Log(logEntry)
        TrayTip "Error: " err.Message, VarScriptName " " VarVersionNo
    }
}

; Tray Menu Setup
tray := A_TrayMenu
tray.Add("Change Hotkey", ChangeHotkey)
tray.Add("Change API URL", ChangeURL)
tray.Add("View Log", ViewLog)
tray.Add("About", ShowAbout)
tray.Add()  ; Separator

; Functions
ReadOrRequestURL() {
    ; Try to read from config file first
    if FileExist(ConfigFile) {
        Try {
            return IniRead(ConfigFile, "Settings", "API_URL")
        }
    }

    ; If no config file or read failed, request URL
    return RequestNewURL()
}

RequestNewURL() {
    Loop {
        SetTimer(CenterOnActiveMonitor, -100)
        IB := InputBox("Please enter your Power Automate HTTP trigger URL:", VarScriptName " - Setup", "w600 h150")
        if IB.Result = "Cancel" {
            MsgBox "The script cannot function without a valid URL. Exiting."
            ExitApp
        }

        if IsValidURL(IB.Value) {
            ; Save URL to config file
            Try {
                IniWrite(IB.Value, ConfigFile, "Settings", "API_URL")
                return IB.Value
            } Catch as err {
                MsgBox "Error saving configuration: " err.Message
                continue
            }
        } else {
            MsgBox "Please enter a valid HTTP/HTTPS URL"
            continue
        }
    }
}

ChangeURL(*) {
    newURL := RequestNewURL()
    API_URL := newURL
    TrayTip "API URL updated successfully!", VarScriptName " " VarVersionNo
}

ViewLog(*) {
    if FileExist(LogFile) {
        Run "notepad.exe " LogFile
    } else {
        MsgBox "No log file found."
    }
}

FormatLogEntry(message) {
    return FormatTime(, "yyyy-MM-dd HH:mm:ss") " - " message "`n"
}

Log(message) {
    global LogFile, MaxLogEntries
    try {
        ; Read existing log
        existingLines := []
        if FileExist(LogFile) {
            fileContent := FileRead(LogFile)
            lines := StrSplit(fileContent, "`n", "`r")

            ; Add non-empty lines to array
            for line in lines {
                if (line != "")
                    existingLines.Push(line)
            }
        }

        ; Add new message to the end
        existingLines.Push(message)

        ; Keep only the most recent entries
        while (existingLines.Length > MaxLogEntries) {
            existingLines.RemoveAt(1)
        }

        ; Write back to file
        FileDelete(LogFile)
        for line in existingLines {
            FileAppend(line . "`n", LogFile, "UTF-8")
        }
    } catch Error as err {
        TrayTip "Error writing to log: " err.Message, VarScriptName " " VarVersionNo
    }
}

ShowAbout(*) {
    MsgBox VarScriptName " " VarVersionNo " " Varblurb, "About " VarScriptName
}

IsValidURL(url) {
    return RegExMatch(url, "i)^https?://[^\s/$.?#].[^\s]*$")
}
