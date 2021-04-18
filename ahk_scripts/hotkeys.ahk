#SingleInstance Force
#InstallKeybdHook

RegRead, win_version, HKEY_LOCAL_MACHINE, SOFTWARE\microsoft\Windows NT\CurrentVersion, CurrentVersion

BASH_CMD := "C:\Windows\WinSxS\amd64_microsoft-windows-lxss-bash_31bf3856ad364e35_10.0.18362.239_none_95822ecb4e202f44\bash.exe"
;BASH_CMD := "cmd /c wsl -- "

CMD_RUN := "wt.exe"

;1: A window's title must start with the specified WinTitle to be a match.
;2: A window's title can contain WinTitle anywhere inside it to be a match.
;3: A window's title must exactly match WinTitle to be a match.
SetTitleMatchMode, RegEx
DetectHiddenWindows, On

SwitchWindow(title)
{

    id := WinExist(title)
    if id
    {
        WinGet, var, MinMax
        if var = -1
        {
            WinShow
            WinActivate
            WinMaximize
            return 1
        }
        else
        {
            IfWinNotActive
            {
                WinShow
                WinActivate
                WinMaximize
                return 1
            }
            else
            {
                WinMinimize
                WinHide
                return 0
            }
        }
    }
    else
    {
        ;msgbox, not found
    }
    return 0
}

CloseTotalCmdRegisterWindow()
{
    WinWait, ahk_class TNASTYNAGSCREEN, , 8
    if (ErrorLevel != 0)
    {
        return
    }

    count := 0
    while 1
    {
        ControlGetText, OutputVar, TPanel2, ahk_class TNASTYNAGSCREEN

        if (OutputVar == "1" || OutputVar == "2" || OutputVar == "3")
        {
            SendInput %OutputVar%
            break
        }
        Sleep 100
        count := count + 1
        if (count >= 50)
        {
            break
        }
    }
}

;~LShift & WheelUp::  ; 向左滚动.
;ControlGetFocus, fcontrol, A
;Loop 3  ; <-- 增加这个值来加快滚动速度.
    ;SendMessage, 0x114, 0, 0, %fcontrol%, A  ; 0x114 是 WM_HSCROLL, 它后面的 0 是 SB_LINELEFT.
;return

;~LShift & WheelDown::  ; 向右滚动.
;ControlGetFocus, fcontrol, A
;Loop 3  ; <-- 增加这个值来加快滚动速度.
    ;SendMessage, 0x114, 1, 0, %fcontrol%, A  ; 0x114 是 WM_HSCROLL, 它后面的 1 是 SB_LINERIGHT.
;return

;hotkeys for everything {{{1
;everything
^+#f::run %HOME%\scoop\apps\everything\current\Everything.exe, %HOME%

;hotkeys for beyond compare {{{1
^+#k::run %PORTABLE_HOME%\BeyondCompare\BCompare.exe, %HOME%

;hotkeys for Notepad2 {{{1
^+#n::run notepad2.exe, %HOME%

;map CapsLock to Ctrl {{{1
;CapsLock::Ctrl
;RAlt::CapsLock


GetPath()
{
    global win_version
    if WinActive("ahk_class CabinetWClass")
    {
        if (win_version > 6.0) ;> windows xp
        {
            if (win_version < 6.3)
            {
                ;ToolbarWindow322保存了格式如：地址: C:\...的文本
                ControlTitle := "ToolbarWindow322"
            }
            else
            {
                ;Windows 10下控件名为ToolbarWindow323
                ControlTitle := "ToolbarWindow323"
            }
            ControlGetText, Text, %ControlTitle%, A
            ;去掉开头的"地址:"
            Text := RegExReplace(Text, "^地址: |^Address: ")
            return Text
        }
        else ;windows xp
        {
            ControlGetText, Title, ComboBoxEx321, A
            return Title
        }
    }
    if WinActive("ahk_class TTOTAL_CMD")
    {
        Old = %clipboard%
        SendInput ^1
        Sleep, 100
        Ret = %clipboard%
        clipboard = %Old%
        return Ret
    }
    Ret = %HOME%
    return Ret

}
^+#d::
    p := GetPath()
    run %CMD_RUN%, %p%
    return

^+#s::
    p := GetPath()

    ; convert path to linux format like: /mnt/d/...
    parray := StrSplit(p, ":")
    root_old := parray[1]
    path_old := parray[2]
    StringLower, root, root_old
    path := StrReplace(path_old, "\", "/")
    p = /mnt/%root%%path%
    run %BASH_CMD% -c "cd '%p%' && zsh"
    return

;powershell
^+#p::
    p := GetPath()
    run powershell.exe, %p%
    return

#IfWinActive ahk_class CabinetWClass
^+#w::
    ;在TotalCommander中打开当前文件浏览器对应的目录
    p := GetPath()
    if (p == "")
    {
        return
    }
    WinClose, A
    Process, Exist, TOTALCMD.EXE
    if (ErrorLevel == 0)
    {
        run %PORTABLE_HOME%\totalcmd\TOTALCMD.EXE /T /O /P=L /L="%p%"
        CloseTotalCmdRegisterWindow()
    }
    else
    {
        run %PORTABLE_HOME%\totalcmd\TOTALCMD.EXE /T /O /P=L /L="%p%"
    }
    return
^1::
    p := GetPath()
    clipboard = %p%
    return
#IfWinActive

;shutdown
^+#PgUp::
MsgBox, 4, 关机, 确定要关机吗？, 30
IfMsgBox, No
{
    return
}
shutdown, 1
return

;restart
^+#PgDn::
MsgBox, 4, 重启, 确定要重启吗？, 30
IfMsgBox, No
{
    return
}
shutdown, 2
return

^+#Home::
MsgBox, 4, 睡眠, 确定要睡眠吗？, 30
IfMsgBox, No
{
    return
}
DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
return

;gvim
^+#g::
run gvim.exe, %HOME%
return

;wintop
^+#=::
WinSet, AlwaysOnTop, Toggle, A
return

;winhide
^+#-::
WinHide, A
return

;taskmgr, windows7的Ctrl+Alt+Del不再弹出任务管理器
;这里使用Process Explorer代替系统的任务管理器
^+#Ins::
run %PORTABLE_HOME%\SysinternalsSuite\procexp.exe, , , NewPID
Process, priority, %NewPID%, High
return

;使用Alt-`来反向切换程序
;LAlt & `::ShiftAltTab

;hotkeys for Evernote {{{1
;#e::
;if SwitchWindow("ahk_class ENMainFrame")
;{
    ;Send #+f
;}
;return
;hotkeys for WizNote {{{1
#e::
if SwitchWindow("ahk_class WizNoteMainFrame")
{
    Send #+f
}
return

;hotkeys for TotalCommander {{{1
^+#w::
Process, Exist, TOTALCMD.EXE
if ErrorLevel = 0
{
    run %PORTABLE_HOME%\totalcmd\TOTALCMD.EXE
    WinWait, ahk_class TNASTYNAGSCREEN, , 3
    if ErrorLevel = 0
    {
        WinActivate, ahk_class TNASTYNAGSCREEN
        ControlGetText, Var, TPanel2, ahk_class TNASTYNAGSCREEN
        while Var = ""
        {
            ControlGetText, Var, TPanel2, ahk_class TNASTYNAGSCREEN
        }
        while 1
        {
            IfWinNotActive, ahk_class TNASTYNAGSCREEN
            {
                break
            }
            if Var = 1
            {
                ControlClick, TButton3, ahk_class TNASTYNAGSCREEN
            }
            if Var = 2
            {
                ControlClick, TButton2, ahk_class TNASTYNAGSCREEN
            }
            if Var = 3
            {
                ControlClick, TButton1, ahk_class TNASTYNAGSCREEN
            }
            Sleep, 100
        }
    }
}
else
{
    SwitchWindow("ahk_class TTOTAL_CMD")
}
return

; em client
^+#m::
    IfWinActive, eM Client ahk_exe MailClient.exe
    {
        WinMinimize, A
    }
    else
    {
        Run, C:\Program Files (x86)\eM Client\MailClient.exe
    }
return

#IfWinActive, eM Client ahk_exe MailClient.exe
    #z::WinMinimize, A
#IfWinActive

; Outlook 2016
;^+#m::
    ;IfWinActive, ahk_class rctrl_renwnd32 ahk_exe OUTLOOK.EXE
    ;{
        ;WinMinimize, A
    ;}
    ;else
    ;{
        ;IfWinExist, ahk_class rctrl_renwnd32 ahk_exe OUTLOOK.EXE
        ;{
            ;WinActivate, ahk_class rctrl_renwnd32 ahk_exe OUTLOOK.EXE
        ;}
        ;else
        ;{
            ;Run, C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE
        ;}
    ;}
;return


;hotkey for Foxmail {{{1
#q::
SendInput ^+!q
Sleep, 500
DetectHiddenWindows, Off
IfWinExist, ahk_class TFoxMainFrm.UnicodeClass
{
    WinActivate
    WinMaximize
}
DetectHiddenWindows, On
return

;hotkeys for Task Coach
#t::
SwitchWindow("Task Coach -")
return

;hotkeys for thunderbird {{{1
;#q::
;WinGet, Name, ProcessName, A
;if (Name = "thunderbird.exe")
;{
    ;;thunderbird must install MinimizeToTray plugin
    ;WinMinimize, A
;}
;else
;{
    ;;thunderbird must use single instance mode
    ;run thunderbird.exe
;}
;return

;page down
xbutton1::
send {pgdn}
return

;page up
xbutton2::
send {pgup}
return

MoveWindow(direct)
{
    WinGet, var, MinMax, A
    if var = 0 ;没有最大最小化
    {
        WinGetPos, x, y, , , A
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
        WinMove, A, , x, y
    }
}

;向上移动窗口
^+#UP::
MoveWindow(0)
return

;^+#WheelUp::
;MoveWindow(0)
;return

;向下移动窗口
^+#DOWN::
MoveWindow(2)
return

;^+#WheelDown::
;MoveWindow(2)
;return

;向左移动窗口
^+#LEFT::
MoveWindow(3)
return

;^+#WheelLeft::
;MoveWindow(3)
;return

;向右移动窗口
^+#RIGHT::
MoveWindow(1)
return

;^+#WheelRight::
;MoveWindow(1)
;return

;移动窗口到左上角
#Home::
WinMove, A, , 0, 0, A_ScreenWidth/2, (A_ScreenHeight-30)/2
return

;移动窗口到左下角
#End::
WinMove, A, , 0, (A_ScreenHeight-30)/2, A_ScreenWidth/2, (A_ScreenHeight-30)/2
return

;移动窗口到右上角
#PgUp::
WinMove, A, , A_ScreenWidth/2, 0, A_ScreenWidth/2, (A_ScreenHeight-30)/2
return

;移动窗口到右下角
#PgDn::
WinMove, A, , A_ScreenWidth/2, (A_ScreenHeight-30)/2, A_ScreenWidth/2, (A_ScreenHeight-30)/2
return

;增加不透明度
^+!Up::
WinGet, Var, Transparent, A
if (Var != "")
{
    Var := Var + 8
    if (Var >= 255)
    {
        Var := "OFF"
    }
    WinSet, Transparent, %Var%, A
}
return

;降低不透明度
^+!Down::
WinGet, Var, Transparent, A
if (Var != "")
{
    Var := Var - 8
    if (Var < 0)
    {
        Var := 0
    }
}
else
{
    Var := 256 - 8
}
WinSet, Transparent, %Var%, A
return

;win_version <= windows xp
if win_version < 6.0
{
    #UP::
    WinMaximize, A
    return
    #DOWN::
    WinGet, var, MinMax, A
    if var = 1
    {
        WinRestore, A
    }
    else if var = 0
    {
        WinMinimize, A
    }
    return
}

;这个命令用于使用gvim编辑当前窗口下的文本
^+#h::
    tmpfile=%TEMP%\ahk_text_edit_in_vim.txt
        ; 定义临时文件的路径
    gvim=gvim.exe
        ; 定义 gVim 路径
    WinGetTitle, active_title, A
        ; 获取当前窗口标题，赋值给 active_title
    ControlGetFocus, name, %active_title%
        ; 获取当前窗口光标所在的控件名
    if ErroeLevel
    {
        msgbox, “获取焦点错误”
    }
    else
    {
        ; 成功获取焦点
        backup = %clipboard%
        clipboard =
        SendInput ^a
        SendInput ^c
        sleep 200
        FileDelete, %tmpfile% ; 删除临时文件
        FileAppend, %clipboard%, %tmpfile% ; 把文字写入临时文件
        runwait, %gvim% "%tmpfile%" + ; 运行 vim，直到你保存文件并关闭 vim，下面的代码才会执行
        fileread, text, %tmpfile% ; 读取临时文件
        WinActivate, %active_title%
        ControlFocus, %name%, %active_title%
        clipboard = %text%
        SendInput ^a
        SendInput ^v
        sleep 200
        SendInput ^{End} ; 把光标定位到结尾
        clipboard = %backup%
    }
return

;发送WM_CLOSE关闭窗口
#z::PostMessage, 16, 0, 0, , A

;最小化窗口
#x::WinMinimize, A

;;hotkeys for fish {{{1
#IfWinActive ^fish .* ahk_class ConsoleWindowClass
    ; selection
    F2::
    MouseGetPos, X, Y
    MouseMove, 24, 16, 0
    Click
    SendInput ek
    MouseMove, %X%, %Y%, 0
    return

    ^v::
    MouseMove, 24, 16, 0
    Click
    SendInput ep
    MouseMove, %X%, %Y%, 0
    return

    MButton::
    MouseMove, 24, 16, 0
    Click
    SendInput ep
    MouseMove, %X%, %Y%, 0
    return

    ESC::
    SendInput ^e^u
    return

#IfWinActive 选择fish .* ahk_class ConsoleWindowClass

    MButton::
    SendInput ^c
    return

#IfWinActive

;hotkeys for console {{{1
;debuggers {{{2
#IfWinActive .*(gdb|pdb).* ahk_class (ConsoleWindowClass)
    F9::SendInput b{Enter}
    F10::SendInput n{Enter}
    F11::SendInput s{Enter}
    +F11::SendInput finish{Enter}
    F12::SendInput until{Enter}
    F6::SendInput i ar{Enter}
    F7::SendInput i lo{Enter}
    F8::SendInput lf{Enter}
    F4::SendInput bt{Enter}
    F3::SendInput i th{Enter}
    F5::SendInput cont{Enter}
    +F5::SendInput run{Enter}
    ^l::SendInput shell cls{Enter}
#IfWinActive .*gdb.* ahk_class ConsoleWindowClass
    ESC::SendInput ^u^k
    ^BS::SendInput ^w
    ^p::SendInput ^p
    ^n::SendInput ^n
;cmdex {{{2
#IfWinActive .*(- CMDEX) ahk_class(ConsoleWindowClass)
    ^BS::SendInput ^w
    ESC::SendInput ^u^k
;normal console {{{2
#IfWinActive .*(?<!VIM)$ ahk_class ConsoleWindowClass
    ^v::SendInput !{Space}ep
    ^a::SendInput !{Space}es
    ^BS::SendInput ^{Left}^{End}
    ^Del::SendInput ^{Right}^{Home}
    F2::SendInput !{Space}ek
    ;^f::SendInput !{Space}ef
    ^n::SendInput {Down}
    ^p::SendInput {Up}
    !F4::PostMessage, 16, 0, 0, , A
    ^l::SendInput cls{Enter}
#IfWinActive

ReMapKey(orig, new, controlpattern, mousepos)
{
    ControlGetFocus, Var, A
    MouseGetPos, x, y, win, con
    if (RegExMatch(Var, controlpattern) && (!mousepos || (mousepos && RegExMatch(con, controlpattern))))
    {
        SendInput %new%
    }
    else
    {
        SendInput %orig%
    }
}

;hotkeys for foxitreader {{{1
#IfWinActive ahk_class classFoxitReader
    ReMapFoxitKey(orig, new)
    {
        ReMapKey(orig,new, "AfxWnd\d+su\d+", 1)
    }
    j::ReMapFoxitKey("j", "{Down}")
    k::ReMapFoxitKey("k", "{Up}")
    h::ReMapFoxitKey("h", "{Left}")
    l::ReMapFoxitKey("l", "{Right}")
    +h::ReMapFoxitKey("+h", "!{Left}")
    +l::ReMapFoxitKey("+l", "!{Right}")
    ^i::ReMapFoxitKey("^i", "!{Left}")
    ^o::ReMapFoxitKey("^o", "!{Right}")
    /::ReMapFoxitKey("/", "^f")
    n::ReMapFoxitKey("n", "{PgDn}")
    p::ReMapFoxitKey("p", "{PgUp}")
    ^f::ReMapFoxitKey("^f", "{PgDn}")
    ^b::ReMapFoxitKey("^b", "{PgUp}")
    ^j::ReMapFoxitKey("^j", "^{WheelDown}")
    ^k::ReMapFoxitKey("^k", "^{WheelUp}")
    g::ReMapFoxitKey("g", "{Home}")
    +g::ReMapFoxitKey("+g", "{End}")
    ^+b::ReMapFoxitKey("^+b", "^b")
#IfWinActive

g_map_acrobat_keys := 1
;hotkeys for acrobat XI {{{1
#IfWinActive ahk_class AcrobatSDIWindow
    ReMapAcrobatKey(orig, new)
    {
        global g_map_acrobat_keys
        if (g_map_acrobat_keys == "")
        {
            g_map_acrobat_keys := 1
        }
        if (g_map_acrobat_keys)
        {
            ReMapKey(orig,new, "AVL_AVView\d+", 1)
        }
        else
        {
            SendInput %orig%
        }
    }
    j::ReMapAcrobatKey("j", "{Down}")
    k::ReMapAcrobatKey("k", "{Up}")
    h::ReMapAcrobatKey("h", "{Left}")
    l::ReMapAcrobatKey("l", "{Right}")
    +h::ReMapAcrobatKey("+h", "!{Left}")
    +l::ReMapAcrobatKey("+l", "!{Right}")
    ^i::ReMapAcrobatKey("^i", "!{Left}")
    ^o::ReMapAcrobatKey("^o", "!{Right}")
    /::ReMapAcrobatKey("/", "^f")
    n::ReMapAcrobatKey("n", "{PgDn}")
    p::ReMapAcrobatKey("p", "{PgUp}")
    ^f::ReMapAcrobatKey("^f", "{PgDn}")
    ^b::ReMapAcrobatKey("^b", "{PgUp}")
    ^d::ReMapAcrobatKey("^d", "{PgDn}")
    ^u::ReMapAcrobatKey("^u", "{PgUp}")
    ^j::ReMapAcrobatKey("^j", "^{WheelDown}")
    ^k::ReMapAcrobatKey("^k", "^{WheelUp}")
    g::ReMapAcrobatKey("g", "{Home}")
    +g::ReMapAcrobatKey("+g", "{End}")
    ^F12::
        global g_map_acrobat_keys
        if (g_map_acrobat_keys)
        {
            g_map_acrobat_keys := 0
        }
        else
        {
            g_map_acrobat_keys := 1
        }
        return
#IfWinActive

g_map_sumatra_keys := 1
#IfWinActive ahk_class SUMATRA_PDF_FRAME
    ReMapSumatraKey(orig, new)
    {
        global g_map_sumatra_keys
        if (g_map_sumatra_keys == "")
        {
            g_map_sumatra_keys := 1
        }
        if (g_map_sumatra_keys)
        {
            SendInput %new%
        }
        else
        {
            SendInput %orig%
        }
    }
    j::ReMapSumatraKey("j", "{Down}{Down}{Down}")
    k::ReMapSumatraKey("k", "{Up}{Up}{Up}")
    h::ReMapSumatraKey("h", "{Left}")
    l::ReMapSumatraKey("l", "{Right}")
    ^o::ReMapSumatraKey("^o", "!{Left}")  ; forward
    ^i::ReMapSumatraKey("^i", "!{Right}") ; backward
    /::ReMapSumatraKey("/", "^f")         ; search
    n::ReMapSumatraKey("n", "{F3}")
    p::ReMapSumatraKey("p", "+{F3}")
    d::ReMapSumatraKey("d", "{PgDn}")
    e::ReMapSumatraKey("e", "{PgUp}")
    i::ReMapSumatraKey("i", "^=")         ; zoom in
    o::ReMapSumatraKey("o", "^-")         ; zoom out
    g::ReMapSumatraKey("g", "{Home}")     ; goto begin
    +g::ReMapSumatraKey("+g", "{End}")    ; goto end
    ^g::ReMapSumatraKey("^g", "^+n")    ; goto page n
    F2::ReMapSumatraKey("{F2}", "{RButton}l") ; select tool
    F3::ReMapSumatraKey("{F3}", "{RButton}h") ; hand tool
    x::ReMapSumatraKey("x", "^w")         ; close tab
    +e::ReMapSumatraKey("+e", "^+{Tab}")  ; prev tab
    +r::ReMapSumatraKey("+r", "^{Tab}")   ; next tab
    ^F12::
        global g_map_sumatra_keys
        if (g_map_sumatra_keys)
        {
            g_map_sumatra_keys := 0
            ToolTip, Keymapping is disabled.
            Sleep, 1000
            ToolTip
        }
        else
        {
            g_map_sumatra_keys := 1
            ToolTip, Keymapping is enabled.
            Sleep, 1000
            ToolTip
        }
        return
#IfWinActive

g_map_keys := 1
;hotkeys for PDF-XChange Viewer {{{1
#IfWinActive ahk_class DSUI:PDFXCViewer
    ReMapXChangeViewerKey(orig, new)
    {
        global g_map_keys
        if (g_map_keys == "")
        {
            g_map_keys := 1
        }
        if (g_map_keys)
        {
            ReMapKey(orig, new, "DSUI:PagesView\d+|DSUI:DocFrame\d+|DSUI:ChildFrame\d+", 0)
        }
        else
        {
            SendInput %orig%
        }
    }
    j::ReMapXChangeViewerKey("j", "{Down}{Down}{Down}")
    k::ReMapXChangeViewerKey("k", "{Up}{Up}{Up}")
    h::ReMapXChangeViewerKey("h", "{Left}")
    l::ReMapXChangeViewerKey("l", "{Right}")
    ^o::ReMapXChangeViewerKey("^o", "!{Left}")  ; forward
    ^i::ReMapXChangeViewerKey("^i", "!{Right}") ; backward
    /::ReMapXChangeViewerKey("/", "^f")         ; search
    n::ReMapXChangeViewerKey("n", "{F3}")
    p::ReMapXChangeViewerKey("p", "+{F3}")
    d::ReMapXChangeViewerKey("d", "{PgDn}")
    e::ReMapXChangeViewerKey("e", "{PgUp}")
    i::ReMapXChangeViewerKey("i", "^=")         ; zoom in
    o::ReMapXChangeViewerKey("o", "^-")         ; zoom out
    g::ReMapXChangeViewerKey("g", "{Home}")     ; goto begin
    +g::ReMapXChangeViewerKey("+g", "{End}")    ; goto end
    ^g::ReMapXChangeViewerKey("^g", "^+n")    ; goto page n
    F2::ReMapXChangeViewerKey("{F2}", "{RButton}l") ; select tool
    F3::ReMapXChangeViewerKey("{F3}", "{RButton}h") ; hand tool
    x::ReMapXChangeViewerKey("x", "^w")         ; close tab
    +e::ReMapXChangeViewerKey("+e", "^+{Tab}")  ; prev tab
    +r::ReMapXChangeViewerKey("+r", "^{Tab}")   ; next tab
    ^F12::
        global g_map_keys
        if (g_map_keys)
        {
            g_map_keys := 0
            ToolTip, Keymapping is disabled.
            Sleep, 1000
            ToolTip
        }
        else
        {
            g_map_keys := 1
            ToolTip, Keymapping is enabled.
            Sleep, 1000
            ToolTip
        }
        return
#IfWinActive

;hotkeys for chm help file explorer {{{1
;#IfWinActive ahk_class HH Parent
    ;ReMapHHKey(orig, new)
    ;{
        ;ReMapKey(orig,new, "Internet Explorer_Server\d+", 1)
    ;}
    ;j::ReMapHHKey("j", "{Down}")
    ;k::ReMapHHKey("k", "{Up}")
    ;h::ReMapHHKey("h", "{PgUp}")
    ;l::ReMapHHKey("l", "{PgDn}")
    ;+h::ReMapHHKey("+h", "!{Left}")
    ;+l::ReMapHHKey("+l", "!{Right}")
    ;^i::ReMapHHKey("^i", "!{Left}")
    ;^o::ReMapHHKey("^o", "!{Right}")
    ;/::ReMapHHKey("/", "^f")
    ;n::ReMapHHKey("n", "{PgDn}")
    ;p::ReMapHHKey("p", "{PgUp}")
    ;^f::ReMapHHKey("^f", "{PgDn}")
    ;^b::ReMapHHKey("^b", "{PgUp}")
    ;^d::ReMapHHKey("^d", "{PgDn}")
    ;^u::ReMapHHKey("^u", "{PgUp}")
    ;^j::ReMapHHKey("^j", "^{WheelDown}")
    ;^k::ReMapHHKey("^k", "^{WheelUp}")
    ;g::ReMapHHKey("g", "{Home}")
    ;+g::ReMapHHKey("+g", "{End}")
;#IfWinActive

; hotkeys for story writer
#IfWinActive ahk_exe Story-writer.exe

SwitchToEnglish()
{
    ; This should be replaced by whatever your native language is. See
    ; http://msdn.microsoft.com/en-us/library/dd318693%28v=vs.85%29.aspx
    ; for the language identifiers list.
    en := DllCall("LoadKeyboardLayout", "Str", "00000409", "Int", 1)
    PostMessage 0x50, 0, %en%,, A

}
ESC::
    SendInput {ESC}
    SwitchToEnglish()
    return

; format code
!+f::
    SwitchToEnglish()
    Sleep, 100

    ; copy markdown text to clipboard
    SendInput {ESC}mpi^a^c{ESC}

    ; format clipboard
    RunWait, pythonw %A_ScriptDir%\format_md_for_storywriter.py

    ; set formatted text
    SendInput {ESC}i^a^v{ESC}``p
    return

#IfWinActive


;hotkeys for windbg {{{1
#IfWinActive ahk_class WinDbgFrameClass
    #x::sendinput ^{F4} ;close tab
#IfWinActive

;hotkeys for TaskSwitcherWnd {{{1
#IfWinActive ahk_class TaskSwitcherWnd
    j::Down
    h::Left
    k::Up
    l::Right
#IfWinActive

;hotkeys for everything {{{1
#IfWinActive ahk_class EVERYTHING
    ReMapETKey(orig, new)
    {
        ReMapKey(orig, new, "EVERYTHING_LISTVIEW\d+", 0)
    }
    F4::
    ControlGet, OutputVar, List, Selected, SysListView321, A
    TmpFile = %A_Temp%\open_everything_file.tmp
    FileDelete, %TmpFile%
    FileAppend, %OutputVar%, %TmpFile%
    run pythonw.exe %A_ScriptDir%\open_everything_file.py %TmpFile%
    return
    j::ReMapEtKey("j", "{Down}")
    k::ReMapEtKey("k", "{Up}")
    h::ReMapEtKey("h", "{Left}")
    l::ReMapEtKey("l", "{Right}")
    p::ReMapEtKey("p", "{PgUp}")
    n::ReMapEtKey("n", "{PgDn}")
    g::ReMapEtKey("g", "{Home}")
    +g::ReMapEtKey("+g", "{End}")
#IfWinActive


;hotkeys for codeblocks {{{1
#IfWinActive .* - Code::Blocks svn build
    ^n::ReMapKey("^n", "{Down}", "wxWindowClassNR\d+", 0)
    ^p::ReMapKey("^p", "{Up}", "wxWindowClassNR\d+", 0)
#IfWinActive


;hotkeys for visual stutio {{{1
#IfWinActive .* - Microsoft Visual Studio.*
    ^n::SendInput {Down}
    ^p::SendInput {Up}
#IfWinActive

;hotkeys for JCIDE {{{1
#IfWinActive JCIDE - .*\.java
    ^n::ReMapKey("^n", "{Down}", "Scintilla\d+", 0)
    ^p::ReMapKey("^p", "{Up}", "Scintilla\d+", 0)
#IfWinActive


;hotkeys for Ditto {{{1
#IfWinActive ahk_class QPasteClass
    ^n::SendInput {Down}
    ^p::SendInput {Up}
    j::SendInput {Down}
    k::SendInput {Up}
#IfWinActive

;hotkeys for Total commander {{{1
#IfWinActive ahk_class TTOTAL_CMD
    ^+F12::
        ControlGetText, Dir1, TPathPanel1, A
        ControlGetText, Dir2, TPathPanel2, A
        Dir1 := SubStr(Dir1, 1, StrLen(Dir1) - 4)
        Dir2 := SubStr(Dir2, 1, StrLen(Dir2) - 4)
        run %PORTABLE_HOME%\BeyondCompare\BCompare.exe "%Dir1%" "%Dir2%"
    return
    ^+!F12::
        ControlGetText, Dir1, TPathPanel1, A
        ControlGetText, Dir2, TPathPanel2, A
        Dir1 := SubStr(Dir1, 1, StrLen(Dir1) - 4)
        Dir2 := SubStr(Dir2, 1, StrLen(Dir2) - 4)
        run %PORTABLE_HOME%\BeyondCompare\BCompare.exe /sync "%Dir1%" "%Dir2%"
    return
    ;^+#s::
        ;SendInput ^+g
        ;return
    ;^+#d::
        ;SendInput ^g
        ;return
#IfWinActive

;hotkeys for YouDaoDict {{{1
#s::
SendInput ^!+{F5}
;IfWinExist, ahk_class YodaoMainWndClasss
IfWinExist, Lingoes 灵格斯
{
    WinActivate
}
return

^+#c::
    SendInput ^!+{F6}
    Sleep 200
    SendInput ^c
    Sleep 200
    SendInput ^!+{F6}
return

;^+#s::SendInput ^!+{F8}
#^s::
    SendInput ^c
    Sleep 100
    if (clipboard == "")
    {
        return
    }
    else
    {
        SendInput ^!+{F5}
        Sleep 100
        SendInput ^v
        Sleep 100
        SendInput {Enter}
    }
return


;List all top windows
ListTopWindows(shiftdown)
{
    WinGetTitle, Title, A
    if (Title == "List Windows of AHK")
    {
        if (shiftdown)
        {
            PostMessage, 0x104, 0x26, 0, , A
        }
        else
        {
            PostMessage, 0x104, 0x28, 0, , A
        }
        return
    }

    Gui, ListWindowsofAHK:New, , List Windows of AHK
    Gui, Font, s9, Simson
    Gui, Font, s9, Microsoft YaHei
    Gui +ToolWindow +HwndMyGuiHwnd +AlwaysOnTop
    Gui, Add, ListView, Report Grid -Multi ReadOnly NoSort r30 w1000, Icon|Index|Title|Process|CLass|ID
    Gui +Resize
    Gui, Hide

    DetectHiddenWindows, Off
    WinGet, Var, List, .+
    DetectHiddenWindows, On

    if (Var)
    {
        ImageList := IL_Create(Var)
        ImageDict := {}
        LV_SetImageList(ImageList)
        ImageDict["C:\Windows\System32\cmd.exe"] := IL_Add(ImageList, "C:\Windows\System32\cmd.exe", 1)
        Index := 1
        Loop, %Var%
        {
            id := Var%A_Index%
            parentid := DllCall("GetParent", UInt, id)
            if (parentid)
            {
                Continue
            }

            WinGetTitle, Title, ahk_id %id%
            WinGet, Process, ProcessName, ahk_id %id%
            if (Process = "explorer.exe" and Title = "Program Manager")
            {
                Continue
            }
            WinGet, Path, ProcessPath, ahk_id %id%
            if (ImageDict.HasKey(Path))
            {
                imgidx := ImageDict[Path]
            }
            else
            {
                imgidx := IL_Add(ImageList, Path, 1)
                if (imgidx == 0)
                {
                    imgidx := ImageDict["C:\Windows\System32\cmd.exe"]
                }
            }
            WinGetClass, Class, ahk_id %id%

            LV_Add("Icon" . imgidx, "", Index, Title, Process, Class, id)
            Index += 1
        }
        LV_ModifyCol()
        if (shiftdown)
        {
            LV_Modify(Index - 1, "Focus Select Vis")
        }
        else
        {
            LV_Modify(2, "Focus Select Vis")
        }

        OnMessage(0x104, "ListWindowsSysKeyDown")
        OnMessage(0x203, "ListWindowsDBClick")
        OnMessage(0x06, "ListWindowsActivate")
        OnMessage(0x20A, "ListWindowsMouseWheel")
        Gui, Show
        SetTimer, ListWindowsTimer, 20
        return

        ListWindowsTimer:
        WinGetTitle, Title, A
        if (Title == "List Windows of AHK" && !GetKeyState("Alt"))
        {
            SetTimer, ListWindowsTimer, Off
            PostMessage, 0x203, 0, 0, , A
        }
        return
    }
}

ListWindowsDBClick(wParam, lParam)
{
    ListWindowsOpen(0)
    return 0
}

ListWindowsMouseWheel(wParam, lParam)
{
    if (wParam & 0x80000000)
    {
        ListWindowsDown()
    }
    else
    {
        ListWindowsUp()
    }
}

ListWindowsActivate(wParam, lParam)
{
    if ((wParam & 0xFFFF) == 0) ;WA_INACTIVE
    {
        SetTimer, ListWindowsTimer, Off
        PostMessage, 0x10
    }
}

ListWindowsDown()
{
    Count := LV_GetCount()
    RowNumber := LV_GetNext(0)
    if (RowNumber == Count)
    {
        RowNumber = 1
    }
    else
    {
        RowNumber++
    }
    LV_Modify(RowNumber, "Focus Select Vis")
}

ListWindowsUp()
{
    Count := LV_GetCount()
    RowNumber := LV_GetNext(0)
    if (RowNumber == 1)
    {
        RowNumber = Count
    }
    else
    {
        RowNumber--
    }
    LV_Modify(RowNumber, "Focus Select Vis")
}

ListWindowsOpen(index)
{
    SetTimer, ListWindowsTimer, Off
    if (index == 0)
    {
        index := LV_GetNext(0)
    }
    Count := LV_GetCount()
    if (index == 0 or index > Count)
    {
        Gui, Destroy
        return
    }
    LV_GetText(id, index, 6)
    Gui, Destroy
    Sleep 20
    WinActivate, ahk_id %id%
}

ListWindowsSysKeyDown(wParam, lParam)
{
    if (wParam == 0x0D or wParam == 0x20) ;ENTER or Space
    {
        ListWindowsOpen(0)
        return 0
    }
    else if (wParam == 74 or wParam == 0x28) ;j or Down
    {
        ListWindowsDown()
        return 0
    }
    else if (wParam == 75 or wParam == 0x26) ;k or Up
    {
        ListWindowsUp()
        return 0
    }
    else if (wParam == 72 or wParam == 0x25) ;h or Left
    {
        SendInput {Home}
        return 0
    }
    else if (wParam == 76 or wParam == 0x27) ;l or Right
    {
        SendInput {End}
        return 0
    }
    else if (wParam == 80 && GetKeyState("Control")) ;CTRL-P
    {
        ListWindowsUp()
        return 0
    }
    else if (wParam == 78 && GetKeyState("Control")) ;CTRL-N
    {
        ListWindowsDown()
        return 0
    }
    else if (wParam >= 49 && wParam <= 57) ; 0~9
    {
        Index := wParam - 48
        ListWindowsOpen(Index)
        return 0
    }
}

;!Tab::ListTopWindows(0)
;!`::ListTopWindows(1)
!`::!+Tab

^+#DEL::
    run taskkill.exe /F /IM explorer.exe
    Sleep 500
    run C:\Windows\explorer.exe
    return

;hotkeys for MobaXterm
#IfWinActive ahk_class TMobaXtermForm
^+c::
    SendInput ^{Ins}
    return
^+v::
    SendInput +{Ins}
    return
#IfWinActive

^+#i::
    tmpfile=%A_ScriptDir%\ahk_text_edit_in_vim.txt
    gvim=gvim.exe
    WinGetTitle, active_title, A
    clipboard =
        ; 清空剪贴板
    send ^a
        ; 发送 Ctrl + A 选中全部文字
    send ^c
        ; 发送 Ctrl + C 复制
    clipwait, 1
        ; 等待数据进入剪贴板
    FileDelete, %tmpfile%
    FileAppend, %clipboard%, %tmpfile%
    runwait, %gvim% --noplugin -c "set fenc=gbk" "%tmpfile%" +
    fileread, text, %tmpfile%
    clipboard:=text
        ; 还原读取的数据到剪贴板
    winwait %active_title%
        ; 等待刚才获取文字的窗口激活
    send ^a
        ; 发送 Ctrl + A 选中全部文字
    send ^v
        ; 发送 Ctrl + V 粘贴
return
