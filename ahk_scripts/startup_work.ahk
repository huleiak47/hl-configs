SetTitleMatchMode, RegEx ;Æ¥Åä×Ö·û´®Ç°¶Ë
DetectHiddenWindows, On ;¼ì²éÒþ²Ø´°¿Ú

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

