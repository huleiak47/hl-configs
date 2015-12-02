#SingleInstance
#Persistent
;Author:Hulei
;version:1.1.0
;2013-05-14 Windows 7 下增加了修改透明度的功能

;这个脚本用于反复扫描所有控制台窗口，并修改窗口标题。控制台窗口的“管理员:C:\windows\system32\cmd.exe”前缀很让人讨厌

SetTitleMatchMode, RegEx

RegRead, win_version, HKEY_LOCAL_MACHINE, SOFTWARE\microsoft\Windows NT\CurrentVersion, CurrentVersion

ChangeConsoleTitle(id)
{
    WinGetTitle, Title, ahk_id %id%
    NewTitle := RegExReplace(Title, "^管理员:\s*")
    ;NewTitle := RegExReplace(NewTitle, "^C:\\Windows\\system32\\cmd\.exe -\s*")
    ;NewTitle := RegExReplace(NewTitle, "^[a-zA-Z]:.* - ")
    ;if (RegExMatch(NewTitle, "^""[^""]*"".*"))
    ;{
        ;NewTitle := RegExReplace(NewTitle, "^""([a-zA-Z]:)[^""]*\\([^\\""]*)""", "$1 $2")
    ;}
    ;else
    ;{
        ;NewTitle := RegExReplace(NewTitle, "^([a-zA-Z]:)[^\s]*\\([^\\\s]*)", "$1 $2")
    ;}
    if (NewTitle != Title)
    {
        WinSetTitle, ahk_id %id%, , %NewTitle%
    }
}

SetTimer, SearchConsole, 1000
return

SearchConsole:
WinGet, Var, List, ahk_class ConsoleWindowClass|VirtualConsoleClass
Loop, %Var%
{
    id := Var%A_Index%
    ChangeConsoleTitle(id)
    if (win_version > 6.0)
    {
        ;只在Windows7下修改透明度，XP下修改会降低窗口性能
        ;WinGet, Var, Transparent, ahk_id %id%
        ;if (Var == "")
        ;{
            ;WinSet, Transparent, 208, ahk_id %id%
        ;}
    }
}
return
