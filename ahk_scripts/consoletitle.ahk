#SingleInstance
#Persistent
;Author:Hulei
;version:1.1.0
;2013-05-14 Windows 7 ���������޸�͸���ȵĹ���

;����ű����ڷ���ɨ�����п���̨���ڣ����޸Ĵ��ڱ��⡣����̨���ڵġ�����Ա:C:\windows\system32\cmd.exe��ǰ׺����������

SetTitleMatchMode, RegEx

RegRead, win_version, HKEY_LOCAL_MACHINE, SOFTWARE\microsoft\Windows NT\CurrentVersion, CurrentVersion

ChangeConsoleTitle(id)
{
    WinGetTitle, Title, ahk_id %id%
    NewTitle := RegExReplace(Title, "^����Ա:\s*")
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
        ;ֻ��Windows7���޸�͸���ȣ�XP���޸Ļή�ʹ�������
        ;WinGet, Var, Transparent, ahk_id %id%
        ;if (Var == "")
        ;{
            ;WinSet, Transparent, 208, ahk_id %id%
        ;}
    }
}
return
