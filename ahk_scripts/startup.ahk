SetTitleMatchMode, RegEx ;Æ¥Åä×Ö·û´®Ç°¶Ë
DetectHiddenWindows, On ;¼ì²éÒþ²Ø´°¿Ú

run %A_ScriptDir%\hotkeys.ahk

WaitAndHide(title)
{
    WinWait, %title%, , 20
    if (ErrorLevel = 0)
    {
        Sleep, 1000
        WinHide
    }
}

RunFile(title, file, dir, args)
{
    Process, Exist, %title%
    if (ErrorLevel = 0 and FileExist(file))
    {
        run %file% %args%, %dir%
        return 1
    }
    return 0
}

;Ditto
RunFile("Ditto.exe", PORTABLE_HOME . "\Ditto\Ditto.exe", PORTABLE_HOME . "\Ditto", "")

;Everything
RunFile("Everything.exe", PORTABLE_HOME . "\Everything\Everything.exe", PORTABLE_HOME . "\Everything", "-startup")

;Lingoes
RunFile("Lingoes.exe", PORTABLE_HOME . "\Lingoes\Lingoes.exe", PORTABLE_HOME . "\Lingoes", "-minimize")

;FSCapture
RunFile("FSCapture.exe", PORTABLE_HOME . "\FastStoneCapturePortable\FSCapture.exe", "\FastStoneCapturePortable", "-Silent")

;Listary
RunFile("Listary.exe", PORTABLE_HOME . "\ListaryPortable\Listary.exe", PORTABLE_HOME . "\ListaryPortable", "")


if (!WinExist("Task Coach -"))
{
    run taskcoach.pyw
    WaitAndHide("Task Coach -")
}
