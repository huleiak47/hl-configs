#requires AutoHotkey v2.0

HOME := EnvGet("USERPROFILE")
SetWorkingDir(HOME)

SCOOP_APPS := HOME "\scoop\apps"
CMD_RUN := SCOOP_APPS "\windows-terminal\current\wt.exe --profile cmdex"
; BASH_RUN := SCOOP_APPS "\windows-terminal\current\wt.exe --profile `"Git Zsh`""
BASH_RUN := SCOOP_APPS "\wezterm\current\wezterm-gui.exe"

SetTitleMatchMode("RegEx")
DetectHiddenWindows(1)

SwitchWindow(title)
{
    id := WinExist(title)
    if (id)
    {
        if (!WinActive(id)) {
            WinShow()
            WinActivate()
            WinMaximize()
            return 1
        } else {
            WinMinimize()
            return 0
        }
    }
    else
    {
        ; msgbox("not found")
    }
    return 0
}

^+#d::
{
    Run(BASH_RUN, HOME)
}

^+#l::
{
    Run(CMD_RUN, HOME)
}

#n::
{
    Run("D:\software\bin\Notepad2.exe")
}

^+#n::
{
    Run("wezterm-gui.exe start nvim")
}

^+#s::Run("https://www.google.com")

#z::Send("!{F4}")

#x::WinMinimize("A")

^+#DEL::
{
    Run("taskkill.exe /F /IM explorer.exe")
    Sleep(500)
    Run("explorer.exe")
}


MoveWindow(direct)
{
    var := WinGetMinMax("A")
    if (var = 0) ;没有最大最小化
    {
        WinGetPos(&x, &y, , , "A")
        if (direct = 0) ;up
        {
            y := y - 50
        }
        else if (direct = 1) ; right
        {
            x := x + 50
        }
        else if (direct = 2) ; down
        {
            y := y + 50
        }
        else if (direct = 3) ; left
        {
            x := x - 50
        }
        WinMove(x, y, , , "A")
    }
}
;向上移动窗口
^+#UP::MoveWindow(0)

;向下移动窗口
^+#DOWN::MoveWindow(2)

;向左移动窗口
^+#LEFT::MoveWindow(3)

;向右移动窗口
^+#RIGHT::MoveWindow(1)

MapSumatraKeys(from, to)
{
    hwnd := ControlGetFocus("A")
    if (hwnd == 0) {
        ; 焦点在文档页面，映射
        Send(to)
    } else {
        ; 焦点在其它控件，原样输出
        Send(from)
    }

}

#HotIf WinActive("ahk_class SUMATRA_PDF_FRAME")
!+d::Run("pythonw.exe " A_ScriptDir "\switch-sumatrapdf-bgcolor.py")
d::MapSumatraKeys("d", "{space}")
e::MapSumatraKeys("e", "+{space}")
+g::MapSumatraKeys("G", "{end}")
g::MapSumatraKeys("g", "{home}")
#HotIf

;^+Space::WinActivate("ahk_class org.wezfurlong.wezterm")
^+#m::SwitchWindow("ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe")

#HotIf WinActive("gdb ahk_exe WindowsTerminal.exe")
F4::Send("bt{enter}")
F5::Send("cont{enter}")
F6::Send("i args{enter}")
F7::Send("i lo{enter}")
F8::Send("i reg{enter}")
F9::Send("b{enter}")
F10::Send("n{enter}")
+F10::Send("ni{enter}")
F11::Send("s{enter}")
+F11::Send("si{enter}")
F12::Send("fin{enter}")
#HotIf

; #`::
; {
    ; if (!WinExist("ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe"))
    ; {
        ; Run("C:\Users\osr\scoop\apps\windows-terminal\current\wt.exe")
        ; return
    ; }
    ; else
    ; {
        ; SwitchWindow("ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe")
    ; }
; }

#`::
{
    if (!WinExist("ahk_class org.wezfurlong.wezterm"))
    {
        Run("C:\Users\osr\scoop\apps\wezterm\current\wezterm-gui.exe")
        return
    }
    else
    {
        SwitchWindow("ahk_class org.wezfurlong.wezterm")
    }
}

#k::
{
    if (!WinExist("ahk_class Chrome_WidgetWin_1 ahk_exe Feishu.exe"))
    {
        return
    }

    WinActivate("ahk_class Chrome_WidgetWin_1 ahk_exe Feishu.exe")
    Send("^k")
}

#q::SwitchWindow("ahk_class Chrome_WidgetWin_1 ahk_exe Feishu.exe")

#w::SwitchWindow("ahk_class WeChatMainWndForPC ahk_exe WeChat.exe")



; 递归函数：遍历辅助对象及其所有子对象，返回第一个有文本的控件的名称（文本）
GetAccText(AccObj) {
    local name := AccObj.Name
    msgbox(name)
    if (InStr(name, "VISUAL BLOCK"))
        return name
    ; 使用内置 Range 函数生成 1 到 count 的序列
    for child in AccObj.Children {
        local result := GetAccText(child)
        if (InStr(result, "VISUAL BLOCK")) {
            return result
        }
    }
    return ""
}

#HotIf WinActive("ahk_class Zed::Window")
ESC::
{
    Run("im-select.exe 1033", , "Hide")
    Send("{ESC}")
}
#HotIf


; 使用浏览器打开clipboard中的URL
^+#e::
{
    url := A_Clipboard
    if url = ""
    {
        MsgBox("剪贴板为空，请先复制一个 URL 到剪贴板！")
        return
    }
    ; 简单验证 URL 是否以 http:// 或 https:// 开头
    if !RegExMatch(url, "i)^(https?://)")
    {
        MsgBox("剪贴板内容似乎不是有效的 URL！")
        return
    }
    Run(url)
}

; ^+#b::Run("wezterm-gui -e btm", , "Max")
^+#b::Run("btm.exe", , "Max")

; 按住 Shift 时，垂直滚轮转换为水平滚动
; LShift & WheelUp::  Send "{WheelRight}"
; LShift & WheelDown::Send "{WheelLeft}"

^+#i::Run("pythonw.exe D:\software\bin\img2base64.py")

XButton1::Send("{PgDn}")
XButton2::Send("{PgUp}")
