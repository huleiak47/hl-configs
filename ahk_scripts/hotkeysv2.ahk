#requires AutoHotkey v2.0

HOME := EnvGet("USERPROFILE")
SetWorkingDir(HOME)

SCOOP_APPS := HOME "\scoop\apps"
CMD_RUN := SCOOP_APPS "\windows-terminal\current\wt.exe --profile cmdex"
WSL_RUN := SCOOP_APPS "\windows-terminal\current\wt.exe --profile `"Ubuntu 22.04.2 LTS`""

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
            WinHide()
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
    Run(CMD_RUN, HOME)
}

^+#l::
{
    Run(WSL_RUN, HOME)
}

^+#n::
{
    Run(SCOOP_APPS "\notepad3\current\Notepad3.exe")
}

^+#DEL::
{
    Run("taskkill.exe /F /IM explorer.exe")
    Sleep(500)
    Run("explorer.exe")
}

;hotkeys for TotalCommander {{{1
^+#w::
{
    if (!WinExist("ahk_exe TOTALCMD64.EXE"))
    {
        Run("D:\software\totalcmd\TOTALCMD64.EXE")
        if (WinWait("ahk_class TNASTYNAGSCREEN", , 3))
        {
            WinActivate("ahk_class TNASTYNAGSCREEN")
            Sleep(300)
            while (WinActive("ahk_class TNASTYNAGSCREEN"))
            {
                Var := ControlGetText("Window4", "ahk_class TNASTYNAGSCREEN")
                if (Var != "") {
                    Send(Var)
                }
                Sleep(300)
            }

            Sleep(100)
            WinMaximize("ahk_class TTOTAL_CMD")

        } else {
            MsgBox("no register window")
        }
    }
    else {
        SwitchWindow("ahk_class TTOTAL_CMD")
    }
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
