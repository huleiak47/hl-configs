SetTitleMatchMode, RegEx ;ƥ���ַ���ǰ��
DetectHiddenWindows, On ;������ش���

WaitAndHide(title)
{
    WinWait, %title%, , 20
    if (ErrorLevel = 0)
    {
        Sleep, 1000
        WinHide
    }
}

if (!WinExist("Task Coach -"))
{
    run taskcoach.pyw
    WaitAndHide("Task Coach -")
}

