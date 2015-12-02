; ViATc ver.0.5
; linxinhong.sky@gmail.com
; Use "vim+voom" to Write
; 2012-10-16
;============================
#SingleInstance Force 
#Persistent 
#NoEnv 
;#NoTrayIcon 
;============================
Setkeydelay,-1 
SetControlDelay,-1
Detecthiddenwindows,on
Coordmode,Menu,Window
;============================
; Initialization Variables {{{1
; String {{{2
Version := "0050" 
KeyTemp :=
Repeat := 
VimAction :=
; Int {{{2
KeyCount := 0
; Bool {{{2
Vim := true
InsertMode := False
; Arrays {{{2
GroupKey_Arr := object() 
MapKey_Arr := object() 
ExecFile_Arr := object() 
SendText_Arr := object() 
Command_Arr := object()
CmdHistory_Arr := object()
Mark_Arr := object()
HideControl_Arr := object()
;VimAction_Arr := object()
ActionInfo_Arr := object()
HelpInfo_Arr := object()
GroupInfo_Arr := object()
HideControl_Arr["Toggle"] := False
; FilePath {{{2
TcExe := FindPath("exe")
TcIni := FindPath("ini")
Splitpath,TcExe,,TcDir
ViatcIni := TcDir . "\viatc.ini"
; ConfigVar {{{2
GoSub,<ConfigVar>
; Menu Tray {{{1
If A_IsCompiled
	Menu,Tray,NoStandard
Menu,Tray,Add,����TC(&T),<ToggleTC>
Menu,Tray,Add,����(&E),<EnableVIM>
Menu,Tray,Add,����(&R),<ReLoadVIATC>
Menu,Tray,Add
Menu,Tray,Add,ѡ��(&O),<Setting>
Menu,Tray,Add,����(&H),<Help>
Menu,Tray,Add
Menu,Tray,Add,�˳�(&X),<QuitVIATC>
Menu,Tray,Tip,Vim Mode At TotalCommander
Menu,Tray,Default,����TC(&T)
;Menu,Tray,Icon,%A_WorkingDir%\viatc.ico
If TrayIcon
	Menu,Tray,Icon
SetHelpInfo()
SetGroupInfo()
SetVimAction()
SetActionInfo()
ReadKeyFromIni()
SetDefaultKey()
EmptyMem()
return
; Labels {{{1
<ConfigVar>:
Vim := GetConfig("Configuration","Vim")
Toggle := TransHotkey(GetConfig("Configuration","Toggle"),"ALL")
GlobalTogg := GetConfig("Configuration","GlobalTogg")
If GlobalTogg
{
	HotKey,Ifwinactive
	Hotkey,%Toggle%,<ToggleTC>,On,UseErrorLevel
	Toggle := GetConfig("Configuration","Toggle")
}
Else
{
	HotKey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Toggle%,<ToggleTC>,On,UseErrorLevel
	Toggle := GetConfig("Configuration","Toggle")
}
Susp := TransHotkey(GetConfig("Configuration","Suspend"),"ALL")
GlobalSusp := GetConfig("Configuration","GlobalSusp")
If GlobalSusp
{
	HotKey,Ifwinactive
	Hotkey,%Susp%,<EnableVim>,On,UseErrorLevel
	Susp := GetConfig("Configuration","Suspend")
}
Else
{
	HotKey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Susp%,<EnableVim>,On,UseErrorLevel
	Susp := GetConfig("Configuration","Suspend")
}
TrayIcon := GetConfig("Configuration","TrayIcon")
Service := GetConfig("Configuration","Service")
If Not Service
{
	IfWinExist,AHK_CLASS TTOTAL_CMD
		Winactivate,AHK_CLASS TTOTAL_CMD
	Else
	{
		Run,%TcExe%,,UseErrorLevel
		If ErrorLevel = ERROR
			TcExe := FindPath("exe")
	}
	WinWait,AHK_CLASS TTOTAL_CMD
	Settimer,<CheckTCExist>,100
}
StartUp := GetConfig("Configuration","Startup")
If StartUp
{
	RegRead,IsStartup,HKEY_CURRENT_USER,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,ViATc
	If Not RegExMatch(IsStartup,A_ScriptFullPath)
	{
		RegWrite,REG_SZ,HKEY_CURRENT_USEr,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,ViATc,%A_ScriptFullPath%
		If ErrorLevel
			Msgbox,16,ViATc,���ÿ�������ʧ��,3 ;Lang
	}
} 
Else
	Regdelete,HKEY_CURRENT_USER,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,ViATc	
GroupWarn := GetConfig("Configuration","GroupWarn")
GlobalSusp := GetConfig("Configuration","GlobalSusp")
TransParent := GetConfig("Configuration","TransParent")
TranspHelp := GetConfig("Configuration","TranspHelp")
MaxCount := GetConfig("Configuration","MaxCount")
TranspVar := GetConfig("Configuration","TranspVar")
DefaultSE := GetConfig("SearchEngine","Default")
SearchEng := GetConfig("SearchEngine",DefaultSE)
Return
; <32768> {{{2
; ����32768���Ƿ����
<32768>:
	Get32768()
RETURN
Get32768()
{
	Global InsertMode
	WinGet,MenuID,ID,AHK_CLASS #32768
	IF MenuID
		InsertMode := True
	ELSE
	{
		InsertMode := False
		SetTimer,<32768>,OFF
	}
}
; <GroupKey> {{{2
<GroupKey>:
	GroupKey(A_ThisHotkey)
Return
; <CheckTCExist> {{{2
<CheckTCExist>:
IfWinNotExist,AHK_CLASS TTOTAL_CMD
	ExitApp
Return
; <RemoveToolTip> {{{2
<RemoveToolTip>:
	SetTimer,<RemoveToolTip>, Off
	ToolTip
return
; <RemoveToolTipEx> {{{2
<RemoveToolTipEx>:
	Ifwinnotactive,AHK_CLASS TTOTAL_CMD
	{
		SetTimer,<RemoveToolTipEx>, Off
		ToolTip
	}
	If A_ThisHotkey = Esc
		SetTimer,<RemoveToolTipEx>, Off
return
; <Exec> {{{2
<Exec>:
	If SendPos(0)
		ExecFile()
return
; <Text> {{{2
<Text>:
	If SendPos(0)
		SendText()
return
; <None> {{{2
<None>:
	SendPos(-1) ;��Ч�������Ҳ���¼repaet
return
; <MsgVar> {{{2
<MsgVar>:
	Msgbox % "Text=" SendText_Arr["Hotkeys"] "`n" "Exec=" ExecFile_Arr["HotKeys"] "`n" "MapKeys=" MapKey_Arr["HotKeys"] "`nGroupkey=" GroupKey_Arr["Hotkeys"]
Return
; Actions {{{1
; <Esc> >>�ظ�������״̬{{{2
<Esc>:
	KeyCount := 0
	KeyCount := 
	InsertMode := False
	Tooltip
	ControlSetText,Edit1,,AHK_CLASS TTOTAL_CMD
	Settimer,<RemoveTooltipEx>,off
	Send,{Esc}
	EmptyMem()
Return
; <ToggleTC> >>��/��С��/����TC {{{2
<ToggleTC>:
If SendPos(0)
{
	Ifwinexist,AHK_CLASS TTOTAL_CMD
	{
		WinGet,AC,MinMax,AHK_CLASS TTOTAL_CMD
		If Ac = -1
			Winactivate,AHK_ClASS TTOTAL_CMD
		Else
		Ifwinnotactive,AHK_CLASS TTOTAL_CMD
			Winactivate,AHK_CLASS TTOTAL_CMD
		Else
			Winminimize,AHK_CLASS TTOTAL_CMD
	}
	Else
	{
		Run,%TcExe%,,UseErrorLevel
		If ErrorLevel = ERROR
			TcExe := FindPath("exe")
		WinWait,AHK_CLASS TTOTAL_CMD,,3
		Winactivate,AHK_CLASS TTOTAL_CMD
		;IniRead,Transparent,%ViatcIni%,Configuration,Transparent
		If TransParent
			WinSet,Transparent,220,ahk_class TTOTAL_CMD
		;HideControl_Arr["Toggle"] := 0
	}
	EmptyMem()
}
Return
; <EnableVIM> >>����/����VIMģʽ {{{2
<EnableVIM>:
	Suspend
	If Not IsSuspended
	{
		Menu,Tray,Rename,����(&E),����(&E)
		TrayTip,,����VIM,10,17
		If A_IsCompiled
			Menu,Tray,icon,%A_ScriptFullPath%,5,1
		Else
			Menu,Tray,icon,%A_AHKPath%,5,1
		Settimer,<GetKey>,100
		IsSuspended := 1
	}
	Else
	{
		Menu,Tray,Rename,����(&E),����(&E)
		TrayTip,,����VIM,10,17
		If A_IsCompiled
			Menu,Tray,icon,%A_ScriptFullPath%,1,1
		Else
			Menu,Tray,icon,%A_AHKPath%,1,1
		Settimer,<GetKey>,off
		IsSuspended := 0
		Suspend,off
	}
Return
<GetKey>:
	IfWinActive AHK_CLASS TTOTAL_CMD
		Suspend,on
	Else
		Suspend,off
Return
; <ReLoadVIATC> >>����VIATC {{{2
<ReLoadVIATC>:
If SendPos(0)
	ReloadVIATC()
Return
ReloadVIATC()
{
	ToggleMenu(1)
	If HideControl_arr["Toggle"]
 		HideControl()
	Reload
}
; <Enter> >>�س� {{{2
<Enter>:
	Enter()
Return
; <Setting> >>���ý��� {{{2
<Setting>:
If SendPos(0)
	Setting()
Return
; <Help> >>�������� {{{2
<Help>:
If SendPos(0)
	Help()
Return
; <QuitViatc> >>����VIATC{{{2
; ��������
<QuitViatc>:
If SendPos(0)
	ExitApp
Return
; <Num*> >>���� {{{2
; <Num0> >>����0 {{{3
<Num0>:
	SendNum("0")
Return
; <Num1> >>����1 {{{3
<Num1>:
	SendNum("1")
Return
; <Num2> >>����2 {{{3
<Num2>:
	SendNum("2")
Return
; <Num3> >>����3 {{{3
<Num3>:
	SendNum("3")
Return
; <Num4> >>����4 {{{3
<Num4>:
	SendNum("4")
Return
; <Num5> >>����5 {{{3
<Num5>:
	SendNum("5")
Return
; <Numr> >>����6 {{{3
<Num6>:
	SendNum("6")
Return
; <Num7> >>����7 {{{3
<Num7>:
	SendNum("7")
Return
; <Num8> >>����8 {{{3
<Num8>:
	SendNum("8")
Return
; <Num9> >>����9 {{{3
<Num9>:
	SendNum("9")
Return
; <Down> >>�·��� {{{2
<Down>:
	SendKey("{down}")
Return
; <up> >>�Ϸ��� {{{2
<Up>:
	SendKey("{up}")
Return
; <Left> >>���� {{{2
<Left>:
	SendKey("{Left}")
Return
; <Right> >>�ҷ��� {{{2
<Right>:
	SendKey("{Right}")
Return
; <ForceDel> >> ǿ��ɾ�� {{{2
<ForceDel>:
	SendKey("+{Delete}")
Return
; <UpSelect> >>����ѡ��{{{2
<UpSelect>:
	SendKey("+{Up}")
Return
; <DownSelect> >>����ѡ�� {{{2
<DownSelect>:
	SendKey("+{down}")
Return
; <PageUp> >>���·�ҳ {{{2
<PageUp>:
	SendKey("{PgUp}")
Return
; <PageDown> >>���·�ҳ {{{2
<PageDown>:
	SendKey("{PgDn}")
Return
; <Home> >>ת����һ�У��൱��HOME{{{2
<Home>:
	If SendPos(0)
		GG()
Return
GG()
{
	ControlGetFocus,ctrl,AHK_CLASS TTOTAL_CMD
	;ControlGet,text,List,,%ctrl%,AHK_CLASS TTOTAL_CMD
	;Stringsplit,T,Text,`n
	PostMessage, 0x19E, 0, 1, %CTRL%, AHK_CLASS TTOTAL_CMD
}
; <End> >>ת�����һ�У��൱��End{{{2
<End>:
	If SendPos(0)
		G()
Return
G()
{
	ControlGetFocus,ctrl,AHK_CLASS TTOTAL_CMD
	ControlGet,text,List,,%ctrl%,AHK_CLASS TTOTAL_CMD
	Stringsplit,T,Text,`n
	Last := T0 - 1
	PostMessage, 0x19E,  %Last% , 1 , %CTRL%, AHK_CLASS TTOTAL_CMD
}
; <Mark> >>��ǹ���{{{2
<Mark>:
	If SendPos(4003)
	{
		ControlSend,Edit1,m,AHK_CLASS TTOTAL_CMD
		;ControlSend,Edit1,{Right},AHK_CLASS TTOTAL_CMD
		SetTimer,<MarkTimer>,100
	}
Return
<MarkTimer>:
	MarkTimer()
Return
MarkTimer()
{
	Global Mark_Arr,VIATCINI
	ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
	ControlGetText,OutVar,Edit1,AHK_CLASS TTOTAL_CMD
	If Not RegExMatch(ThisControl,"i)^Edit1$") OR Not RegExMatch(Outvar,"i)^m.?")
	{
		Settimer,<MarkTimer>,Off
		Return
	}
	If RegExMatch(OutVar,"i)^m.$")
	{
		SetTimer,<MarkTimer>,off
		ControlSetText,Edit1,,AHK_CLASS TTOTAL_CMD
		ControlSend,Edit1,{Esc},AHK_CLASS TTOTAL_CMD
		ClipSaved := ClipboardAll
		Clipboard :=
		Postmessage 1075, 2029, 0, , ahk_class TTOTAL_CMD
		ClipWait
		Path := Clipboard
		Clipboard := ClipSaved
		M := SubStr(OutVar,2,1)
		mPath := "&" . m . ">>" . Path
		If RegExMatch(Mark_Arr["ms"],m)
		{
			DelM := Mark_Arr[m]
			Menu,MarkMenu,Delete,%DelM%
			Menu,MarkMenu,Add,%mPath%,<AddMark>
			Mark_Arr["ms"] := Mark_Arr["ms"] . m
			Mark_Arr[m] := mPath
		}
		Else
		{
			Menu,MarkMenu,Add,%mPath%,<AddMark>
			Mark_Arr["ms"] := Mark_Arr["ms"] . m
			Mark_Arr[m] := mPath
		}
/*
		Inidelete,%VIATCINI%,Mark,%M%
		if RegExMatch(OutVar,"^M.$")
		{
			Mark_Arr["sms"] .= M ; saved marks
			Iniwrite,%Path%,%VIATCINI%,Mark,%M%
		}
*/
	}
}
<AddMark>:
	AddMark()
Return
AddMark()
{
	ThisMenuItem := SubStr(A_ThisMenuItem,5,StrLen(A_ThisMenuItem))
	If RegExMatch(ThisMenuItem,"i)\\\\����$")
	{
		Postmessage 1075, 2121, 0, , ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\�����$")
	{
		Postmessage 1075, 2122, 0, , ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\���п��������$")
	{
		Postmessage 1075, 2123, 0, , ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\Fonts$")
	{
		Postmessage 1075, 2124, 0, , ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\����$")
	{
		Postmessage 1075, 2125, 0, , ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\��ӡ��$")
	{
		Postmessage 1075, 2126, 0, , ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\����վ$")
	{
		Postmessage 1075, 2127, 0, , ahk_class TTOTAL_CMD
		Return
	}
	ControlSetText, Edit1, cd %ThisMenuItem%, ahk_class TTOTAL_CMD
	ControlSend, Edit1, {Enter}, ahk_class TTOTAL_CMD
	Return
}
; <ListMark> >>��ʾ��� {{{2
<ListMark>:
	If SendPos(0)
		ListMark()
Return
ListMark()
{
	Global Mark_Arr,VIATCINI
	If Not Mark_Arr["ms"]
		Return
	ControlGetFocus,TLB,ahk_class TTOTAL_CMD
	ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
	Menu,MarkMenu,Show,%xn%,%yn%
}
; <azHistory> >>���ļ�����ʷ����ǰ׺��������a-z���� {{{2
<azHistory>:
	If SendPos(572)
		azhistory()
Return
azhistory()
{
	;Postmessage,1075,%Num%,0,,ahk_class TTOTAL_CMD
	Sleep, 100
	if WinExist("ahk_class #32768")
	{
	SendMessage,0x01E1 ;Get Menu Hwnd
    hmenu := ErrorLevel
    if hmenu!=0
    {
		If Not RegExMatch(GetMenuString(Hmenu,1),".*[\\|/]$")
			Return
		Menu,sh,add
		Menu,sh,deleteall
		a :=
        itemCount := DllCall("GetMenuItemCount", "Uint", hMenu, "Uint")
		Loop %itemCount%
	 	{
			a := chr(A_Index+64) . ">>" .  GetMenuString(Hmenu,A_Index-1)
			Menu,SH,add,%a%,azSelect
		}
		Send {Esc}
		ControlGetFocus,TLB,ahk_class TTOTAL_CMD
		ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
		Menu,SH,show,%xn%,%yn%
		Return
    }
	}	
}
GetMenuString(hMenu, nPos)
{
      VarSetCapacity(lpString, 256) 
      length := DllCall("GetMenuString"
         , "UInt", hMenu
         , "UInt", nPos
         , "Str", lpString
         , "Int", 255
         , "UInt", 0x0400)
   	  return lpString
}
azSelect:
	azSelect()
Return
azSelect()
{
	nPos := A_ThisMenuItem
	nPos := Asc(Substr(nPos,1,1)) - 64
	Winactivate,ahk_class TTOTAL_CMD
	Postmessage,1075,572,0,,ahk_class TTOTAL_CMD
	Sleep,100
	if WinExist("ahk_class #32768")
	{
		Loop %nPos%
			SendInput {Down}
		Send {enter}
	}
}
; <azCmdHistory> >>�鿴������ʷ��¼ {{{2
<azCmdHistory>:
	If SendPos(0)
		ListCmdHistory()
Return
ListCmdHistory()
{
	Global TcIni
	Menu,cmdMenu,Add
	Menu,cmdMenu,DeleteAll
	VarSetCapacity(var,256)
	;Menu,cmdMenu,Add,��������ʷ,en
	;Index := CmdHistory[0]
	Loop ;,%Index%
	{
		Index := A_Index - 1
		IniRead,CMD,%TcIni%,Command line history,%Index%
		If CMD = ERROR
			Break
		var := chr(A_Index+64) . ">>" . CMD ;CmdHistory[A_Index]
		Menu,CmdMenu,add,%var%,GetCmd
	}
	ControlGetPos,xn,yn,,hn,Edit1,AHK_CLASS TTOTAL_CMD
	yn := yn - 30 - ( (Index - 1) * 22 )
	Menu,CmdMenu,Show,%xn%,%yn%
}
GetCMD:
	GetCMD()
Return
GetCMD()
{
	var := Substr(A_ThisMenuItem,4,StrLen(A_ThisMenuItem))
	ControlSetText,Edit1,%var%,AHK_CLASS TTOTAL_CMD
	ControlFocus,Edit1,AHK_CLASS TTOTAL_CMD
	ControlSend,Edit1,{End},AHK_CLASS TTOTAL_CMD
}
; <Internetsearch> >>ʹ��������������������ǰ�ļ� {{{2
<Internetsearch>:
	If SendPos(0)
		Internetsearch()
Return
Internetsearch()
{
	Global SearchEng
	If CheckMode()
	{
		ClipSaved := ClipboardAll ;����ԭ�����а��������UserInput
    	Clipboard = ;��ʼ�����а�
		PostMessage 1075, 2017, 0, , ahk_class TTOTAL_CMD
 		ClipWait
		rFileName := clipboard
    	clipboard := ClipSaved
		StringRight,lastchar,rFileName,1
		If(lastchar = "\" )
		Stringleft,rFileName,rFileName,Strlen(rFileName)-1
		;rFileName := rFileName
		rFileName := RegExReplace(SearchEng,"{%1}",rFileName)
		Run %rFileName%
	}
	Return
}
; <GoDesktop> >>�л�������{{{2
<GoDesktop>:
	If SendPos(0)
	{
		ControlSetText,Edit1,CD %A_Desktop%,AHK_CLASS TTOTAL_CMD
		ControlSend,Edit1,{Enter},AHK_CLASS TTOTAL_CMD
	}
Return
; <SingleRepeat> >>�ظ� {{{2
<SingleRepeat>:
	If SendPos(-1)
		SingleRepeat()
Return
; <TCLite> >>TC��� {{{2
<TCLite>:
	If SendPos(0)
	{
		ToggleMenu()
 		HideControl()
		;ControlSend,{Esc},,AHK_CLASS TTOTAL_CMD
		Send,{Esc}
	}
Return
; <TCFullScreen> >>TCȫ�� {{{2
<TCFullScreen>:
	If SendPos(0)
	{
		ToggleMenu()
 		HideControl()
		If HideControl_arr["Max"]
		{
			PostMessage 1075, 2016, 0, , ahk_class TTOTAL_CMD
			HideControl_arr["Max"] := 0
			Return
		}
		WinGet,AC,MinMax,AHK_CLASS TTOTAL_CMD
		If AC = 1
		{
			PostMessage 1075, 2016, 0, , ahk_class TTOTAL_CMD
			PostMessage 1075, 2015, 0, , ahk_class TTOTAL_CMD
			HideControl_arr["Max"] := 0
		}
		If AC = 0
		{
			PostMessage 1075, 2015, 0, , ahk_class TTOTAL_CMD
			HideControl_arr["Max"] := 1
		}
			
	}
Return
; <CreateNewFile> >>�ļ�ģ�� {{{2
<CreateNewFile>:
	If SendPos(0)
		CreateNewFile()
Return
; <Editviatcini> >>ֱ�ӱ༭�����ļ� {{{2
<Editviatcini>:
	If SendPos(0)
		Editviatcini()
Return
; <GoLastTab> >>�л������һ����ǩ{{{2
<GOLastTab>:
	if SendPos(0)
	{
		PostMessage 1075, 5001, 0, , ahk_class TTOTAL_CMD
		PostMessage 1075, 3006, 0, , ahk_class TTOTAL_CMD
	}
Return
; <DeleteLHistory> >>ɾ������ļ�����ʷ {{{2
<DeleteLHistory>:
	If SendPos(0)
		DeleteHistory(1)
Return
; <DeleteRHistory> >>ɾ���Ҳ��ļ�����ʷ {{{2
<DeleteRHistory>:
	If SendPos(0)
		DeleteHistory(0)
Return
DeleteHistory(A)
{
	Global TCEXE,TCINI
	If A
	{
		H := "LeftHistory"
		DelMsg := "ɾ������ļ�����ʷ��¼?" ;Lang
	}
	Else
	{
		H := "RightHistory"
		DelMsg := "ɾ���Ҳ��ļ�����ʷ��¼?" ;Lang
	}
	Msgbox,4,ViATC,%DelMsg%
	Ifmsgbox YES
	{
		Winkill,AHK_CLASS TTOTAL_CMD
		n := 0
    	Loop 
    	{
    		IniRead,TempField,%TCINI%,%H%,%n%
    		If TempField = ERROR
       			Break
    		IniDelete,%TCINI%,%H%,%n%
    		n++
    	}	
		Run,%TCEXE%,,UseErrorLevel
		If ErrorLevel = ERROR
			TCEXE := findpath(1)
		WinWait,AHK_CLASS TTOTAL_CMD,3
		Winactivate,AHK_CLASS TTOTAL_CMD	
	}
	Else
		Winactivate,AHK_CLASS TTOTAL_CMD	
}
; <DelCmdHistory> >>ɾ����������ʷ  {{{2
<DelCmdHistory>:
	If SendPos(0)
		DeleteCmd()
Return
DeleteCMD()
{
	Global TCEXE,TCINI,CmdHistory
	CmdHistory := Object()
	Msgbox,4,ViATc,ɾ����������ʷ? ;Lang
	Ifmsgbox YES
	{
		Winkill ahk_class TTOTAL_CMD
		n := 0 
    	TempField := 
    	Loop 
    	{
    		IniRead,TempField,%TCINI%,Command line history,%n%
    		If TempField = ERROR
       			Break
    		IniDelete,%TCINI%,Command line history,%n%
    		n++
    	}	
		Run,%TCEXE%,,UseErrorLevel
		If ErrorLevel = ERROR
			TCEXE := findpath(1)
		WinWait,AHK_CLASS TTOTAL_CMD,3
		Winactivate,AHK_CLASS TTOTAL_CMD	
	}
	Else
		Winactivate ahk_class TTOTAL_CMD
}
; <ListMapKey> {{{2
<ListMapKey>:
	If SendPos(0)
		ListMapKey()
Return
ListMapKey()
{
	Global MapKey_Arr,ActionInfo_Arr,ExecFile_Arr,SendText_Arr
	Map := MapKey_Arr["Hotkeys"]
	Stringsplit,ListMap,Map,%A_Space% 
	Loop,% ListMap0
	{
		If ListMap%A_Index%
		{
			Action := MapKey_Arr[ListMap%A_Index%]
			If Action = <Exec>
			{
				EX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
				Action := "(" . ExecFile_Arr[EX] . ")"
			}
			If Action = <Text>
			{
				TX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
				Action := "{" . SendText_Arr[TX] . "}"
			}
			LM .= SubStr(ListMap%A_Index%,1,1) . "  " . SubStr(ListMap%A_Index%,2) . "  " . Action  . "`n"
		}
	}
	ControlGetPos,xn,yn,,hn,Edit1,AHK_CLASS TTOTAL_CMD
	yn := yn - hn - ( ListMap0 * 8 ) - 2
	Tooltip,%LM%,%xn%,%yn%
	Settimer,<RemoveToolTipEx>,100
}
; <FocusCmdLineEx> {{{2
<FocusCmdLineEx>:
	If SendPos(4003)
	{
		ControlSetText,Edit1,:,AHK_CLASS TTOTAL_CMD
		Send,{end}
	}
Return
; <WinMaxLeft> >>�������� {{{2
<WinMaxLeft>:
	If SendPos(0)
		WinMaxLeft()
Return
WinMaxLeft()
{
	ControlGetPos,x,y,w,h,TMyPanel8,ahk_class TTOTAL_CMD
	ControlGetPos,tm1x,tm1y,tm1W,tm1H,TPanel1,ahk_class TTOTAL_CMD
	If (tm1w < tm1h) ; �ж������Ǻ��� TureΪ�� falseΪ��
		ControlMove,TPanel1,x+w,,,,ahk_class TTOTAL_CMD
	else
		ControlMove,TPanel1,0,y+h,,,ahk_class TTOTAL_CMD
	ControlClick, TPanel1,ahk_class TTOTAL_CMD 
	WinActivate ahk_class TTOTAL_CMD
}
; <WinMaxRight> >>�������� {{{2
<WinMaxRight>:
	If SendPos(0)
	{
		ControlMove,TPanel1,0,0,,,ahk_class TTOTAL_CMD
		ControlClick,TPanel1,ahk_class TTOTAL_CMD
		WinActivate ahk_class TTOTAL_CMD
	}
Return
; <AlwayOnTop> >>������ǰ {{{2
<AlwayOnTop>:
	If SendPos(0)
		AlwayOnTop()
Return
AlwayOnTop()
{
	WinGet,ExStyle,ExStyle,ahk_class TTOTAL_CMD
	If (ExStyle & 0x8)
   		WinSet,AlwaysOnTop,off,ahk_class TTOTAL_CMD
	else
   		WinSet,AlwaysOnTop,on,ahk_class TTOTAL_CMD 
}
; <TransParent> >>TC͸�� {{{2
<TransParent>:
	If SendPos(0)
		TransParent()
Return
TransParent()
{
	Global VIATCINI,Transparent,TranspVar
	IniRead,Transparent,%VIATCINI%,Configuration,Transparent
	If Transparent
	{
		WinSet,Transparent,255,ahk_class TTOTAL_CMD
		IniWrite,0,%VIATCINI%,Configuration,Transparent
		Transparent := 0
	}
	Else
	{
		WinSet,Transparent,%TranspVar%,ahk_class TTOTAL_CMD
		IniWrite,1,%VIATCINI%,Configuration,Transparent
		Transparent := 1
	}
}
; <ReLoadTC> >>����TC{{{2
<ReLoadTC>:
	ToggleMenu(1)
	If HideControl_arr["Toggle"]
 		HideControl()
	WinKill,AHK_CLASS TTOTAL_CMD
	GoSub,<ToggleTC>
	;Reload
Return
;============================== 
; Functions {{{1
; SetDefaultKey() {{{2
; ����VIATC��Ĭ�ϼ�
SetDefaultKey()
{
	Hotkey,Ifwinactive,AHK_Class TTOTAL_CMD
	HotKey,1,<Num1>,on,UseErrorLevel
	HotKey,2,<Num2>,on,UseErrorLevel
	HotKey,3,<Num3>,on,UseErrorLevel
	HotKey,4,<Num4>,on,UseErrorLevel
	HotKey,5,<Num5>,on,UseErrorLevel
	HotKey,6,<Num6>,on,UseErrorLevel
	HotKey,7,<Num7>,on,UseErrorLevel
	HotKey,8,<Num8>,on,UseErrorLevel
	HotKey,9,<Num9>,on,UseErrorLevel
	HotKey,0,<Num0>,on,UseErrorLevel
	HotKey,j,<Down>,on,UseErrorLevel
	HotKey,k,<up>,on,UseErrorLevel
	HotKey,h,<left>,on,UseErrorLevel
	HotKey,l,<right>,on,UseErrorLevel
	HotKey,+k,<UpSelect>,on,UseErrorLevel
	HotKey,+j,<DownSelect>,on,UseErrorLevel
	HotKey,+h,<GotoPreviousDir>,on,UseErrorLevel
	HotKey,+l,<GotoNextDir>,on,UseErrorLevel
	HotKey,d,<DirectoryHotlist>,on,UseErrorLevel
	HotKey,+d,<GoDesktop>,on,UseErrorLevel
	Hotkey,.,<SingleRepeat>,On,UseErrorLevel
	HotKey,e,<ContextMenu>,on,UseErrorLevel
	HotKey,+e,<ExecuteDOS>,on,UseErrorLevel
	HotKey,u,<GotoParent>,on,UseErrorLevel
	HotKey,+u,<GotoRoot>,on,UseErrorLevel
	Hotkey,i,<CreateNewFile>,on,UseErrorLevel
	Hotkey,x,<Delete>,On,UseErrorLevel
	Hotkey,+x,<ForceDel>,On,UseErrorLevel
	HotKey,o,<LeftOpenDrives>,on,UseErrorLevel
	HotKey,+o,<RightOpenDrive>,on,UseErrorLevel
	HotKey,q,<SrcQuickview>,on,UseErrorLevel
	HotKey,p,<PackFiles>,on,UseErrorLevel
	HotKey,+p,<UnpackFiles>,on,UseErrorLevel
	HotKey,t,<OpenNewTab>,on,UseErrorLevel
	HotKey,+t,<OpenNewTabBg>,on,UseErrorLevel
	Hotkey,r,<RenameSingleFile>,on,UseErrorLevel
	Hotkey,+r,<MultiRenameFiles>,on,UseErrorLevel
	Hotkey,f,<PageDown>,On,UseErrorLevel
	Hotkey,b,<PageUp>,On,UseErrorLevel
	Hotkey,y,<CopyNamesToClip>,On,UseErrorLevel
	Hotkey,+y,<CopyFullNamesToClip>,On,UseErrorLevel
	Hotkey,/,<ShowQuickSearch>,On,UseErrorLevel
	Hotkey,+/,<SearchFor>,On,UseErrorLevel
	Hotkey,`;,<FocusCmdLine>,On,UseErrorLevel
	Hotkey,:,<FocusCmdLineEx>,On,UseErrorLevel
	Hotkey,[,<SelectCurrentName>,On,UseErrorLevel
	Hotkey,+[,<UnselectCurrentName>,On,UseErrorLevel
	Hotkey,],<SelectCurrentExtension>,On,UseErrorLevel
	Hotkey,+],<UnselectCurrentExtension>,On,UseErrorLevel
	Hotkey,\,<ExchangeSelection>,On,UseErrorLevel
	Hotkey,+\,<ClearAll>,On,UseErrorLevel
	Hotkey,=,<MatchSrc>,On,UseErrorLevel
	Hotkey,-,<SwitchSeparateTree>,On,UseErrorLevelHotkey,\,<ExchangeSelection>,On,UseErrorLevel
	Hotkey,v,<SrcCustomViewMenu>,On,UseErrorLevel
	HotKey,a,<SetAttrib>,on,UseErrorLevel
	Hotkey,m,<Mark>,On,UseErrorLevel
	Hotkey,',<ListMark>,On,UseErrorLevel
	HotKey,+q,<Internetsearch>,on,UseErrorLevel
	Hotkey,+g,<End>,On,UseErrorLevel
	Hotkey,w,<EditComment>,On,UseErrorLevel
	Hotkey,n,<azhistory>,On,UseErrorLevel
	Hotkey,`,,<azCmdHistory>,On,UseErrorLevel
	Hotkey,Enter,<Enter>,On,UseErrorLevel
	Hotkey,Esc,<Esc>,On,UseErrorLevel
	HotKey,+a,<None>,on,UseErrorLevel
	Hotkey,+m,<None>,On,UseErrorLevel
	Hotkey,+w,<none>,On,UseErrorLevel
	Hotkey,+`,,<None>,On,UseErrorLevel
	Hotkey,+.,<None>,On,UseErrorLevel
	Hotkey,+w,<None>,On,UseErrorLevel
	Hotkey,+s,<None>,On,UseErrorLevel
	Hotkey,+f,<None>,On,UseErrorLevel
	Hotkey,+',<None>,On,UseErrorLevel
	Hotkey,+1,<None>,On,UseErrorLevel
/*
*/
	;Groupkey ����
	; ʵ�ù����ȼ�
	GroupKeyAdd("zz","<50Percent>")
	GroupKeyAdd("zx","<100Percent>")
	GroupKeyAdd("zi","<WinMaxLeft>")
	GroupKeyAdd("zo","<WinMaxRight>")
	GroupKeyAdd("zt","<AlwayOnTop>")
	GroupKeyAdd("zn","<Minimize>")
	GroupKeyAdd("zm","<Maximize>")
	GroupKeyAdd("zr","<Restore>")
	GroupKeyAdd("zv","<VerticalPanels>")
	GroupKeyAdd("zs","<TransParent>")
	GroupKeyAdd("zf","<TCFullScreen>")
	GroupKeyAdd("zl","<TCLite>")
	GroupKeyAdd("zq","<QuitTC>")
	GroupKeyAdd("za","<ReLoadTC>")
	; �����ȼ�
	GroupKeyAdd("sn","<SrcByName>")
	GroupKeyAdd("se","<SrcByExt>")
	GroupKeyAdd("ss","<SrcBySize>")
	GroupKeyAdd("st","<SrcByDateTime>")
	GroupKeyAdd("sr","<SrcNegOrder>")
	GroupKeyAdd("s1","<SrcSortByCol1>")
	GroupKeyAdd("s2","<SrcSortByCol2>")
	GroupKeyAdd("s3","<SrcSortByCol3>")
	GroupKeyAdd("s4","<SrcSortByCol4>")
	GroupKeyAdd("s5","<SrcSortByCol5>")
	GroupKeyAdd("s6","<SrcSortByCol6>")
	GroupKeyAdd("s7","<SrcSortByCol7>")
	GroupKeyAdd("s8","<SrcSortByCol8>")
	GroupKeyAdd("s9","<SrcSortByCol9>")
	; ��ǩ�ȼ�
	GroupKeyAdd("gn","<SwitchToNextTab>")
	GroupKeyAdd("gp","<SwitchToPreviousTab>")
	GroupKeyAdd("ga","<CloseAllTabs>")
	GroupKeyAdd("gc","<CloseCurrentTab>")
	GroupKeyAdd("gt","<OpenDirInNewTab>")
	GroupKeyAdd("gb","<OpenDirInNewTabOther>")
	GroupKeyAdd("ge","<Exchange>")
	GroupKeyAdd("gw","<ExchangeWithTabs>")
	GroupKeyAdd("g1","<SrcActivateTab1>")
	GroupKeyAdd("g2","<SrcActivateTab2>")
	GroupKeyAdd("g3","<SrcActivateTab3>")
	GroupKeyAdd("g4","<SrcActivateTab4>")
	GroupKeyAdd("g5","<SrcActivateTab5>")
	GroupKeyAdd("g6","<SrcActivateTab6>")
	GroupKeyAdd("g7","<SrcActivateTab7>")
	GroupKeyAdd("g8","<SrcActivateTab8>")
	GroupKeyAdd("g9","<SrcActivateTab9>")
	GroupKeyAdd("g0","<GoLastTab>")
	GroupKeyAdd("gg","<Home>")
	; �����ȼ�
	GroupKeyAdd("<Shift>vb","<VisButtonbar>")
	GroupKeyAdd("<Shift>vd","<VisDriveButtons>")
	GroupKeyAdd("<Shift>vo","<VisTwoDriveButtons>")
	GroupKeyAdd("<Shift>vr","<VisDriveCombo>")
	GroupKeyAdd("<Shift>vc","<VisCurDir>")
	GroupKeyAdd("<Shift>vt","<VisTabHeader>")
	GroupKeyAdd("<Shift>vs","<VisStatusbar>")
	GroupKeyAdd("<Shift>vn","<VisCmdLine>")
	GroupKeyAdd("<Shift>vf","<VisKeyButtons>")
	GroupKeyAdd("<Shift>vw","<VisDirTabs>")
	GroupKeyAdd("<Shift>ve","<CommandBrowser>")
	; ����ȼ�
	GroupKeyAdd("cl","<DeleteLHistory>")
	GroupKeyAdd("cr","<DeleteRHistory>")
	GroupKeyAdd("cc","<DelCmdHistory>")
}
; SendKey(HotKey) {{{2
; ������ͨ�ȼ�  
SendKey(HotKey)
{
	Global KeyCount,KeyTemp,Repeat,MaxCount
	If CheckMode()
	{
		If KeyTemp
		{
			GroupKey(A_ThisHotkey)
			Return 
		}
		If KeyCount
		{
			ControlSetText,Edit1,,AHK_CLASS TTOTAL_CMD
			If KeyCount > %MaxCount%
				keyCount := MaxCount
			Repeat := KeyCount . ">>" . hotkey
			Loop,%KeyCount%
				Send %hotkey%
			KeyCount := 0
		}
		Else
			Send %hotkey%
	}
	Else
	{
		hotkey := TransSendKey(A_ThisHotkey)
		Send %hotkey%
	}
}
; SendNum(HotKey) {{{2
; ���������ȼ�  
SendNum(HotKey)
{
	Global KeyCount,KeyTemp
	If CheckMode()
	{
		If KeyTemp
		{
			GroupKey(A_ThisHotkey)
			Return 
		}
		If KeyCount
			KeyCount := Hotkey + (KeyCount * 10 ) 
		Else
			KeyCount := HotKey + 0
		ControlSetText,Edit1,%KeyCount%,AHK_CLASS TTOTAL_CMD
	}
	Else
	{
		hotkey := TransSendKey(A_ThisHotkey)
		Send %hotkey%
	}
		;Send %A_Thishotkey%
}
; SendPos(Num) {{{2
; ִ��PostMessage
SendPos(Num)
{
	Global KeyCount,KeyTemp,Repeat
	KeyCount := 0
	If CheckMode()
	{
		If KeyTemp
		{
			GroupKey(A_ThisHotkey)
			Return False
		}
		ControlSetText,Edit1,,AHK_CLASS TTOTAL_CMD
		If Num < 0
			Return True
		If Num
		{
			Repeat := Num
			PostMessage 1075, %Num%, 0, , AHK_CLASS TTOTAL_CMD	
		}
		Repeat := A_ThisLabel
		Return True
	}
	Else
	{
		;Send %A_ThisHotkey%
		hotkey := TransSendKey(A_ThisHotkey)
		Send %hotkey%
		Return False
	}
}
; ExecFile() {{{2
ExecFile()
{
	Global ExecFile_Arr,KeyTemp,GoExec,Repeat
	IfWinActive,AHK_CLASS TTOTAL_CMD
	{
		Key := "H" . A_ThisHotkey
		If Not ExecFile_Arr[Key]
			Key := "S" . A_ThisHotkey
	}
	Else
		Key := "S" . A_ThisHotkey
	If GoExec
		File := ExecFile_Arr[GoExec]
	Else
		File := ExecFile_Arr[Key]
	If FileExist(File)
	{
		Run,%File%,,UseErrorLevel,ExecID
		If ErrorLevel = ERROR
			Return
		WinWait,AHK_PID %ExecID%,,3
		WinActivate,AHK_PID %ExecID%
	}
	Else
		Msgbox % File "������"
	Repeat := "(" . File . ")"
	GoExec := 
}
; SendText() {{{2
SendText()
{
	Global SendText_Arr,KeyTemp,Repeat,GoText
	IfWinActive,AHK_CLASS TTOTAL_CMD
	{
		Key := "H" . A_ThisHotkey
		If Not SendText_Arr[Key]
			Key := "S" . A_ThisHotkey
	}
	Else
		Key := "S" . A_ThisHotkey
	If GoExec
		Text := SendText_Arr[GoText]
	Else
		Text := SendText_Arr[Key]
	Send,%Text%
	Repeat := "{" . Text . "}"
	GoText :=
}
; GroupKey(Hotkey) {{{2
Groupkey(Hotkey)
{
	Global GroupKey_Arr,KeyTemp,KeyCount,GroupInfo_arr,GroupWarn,Repeat,SendText_Arr,ExecFile_Arr,GoExec,GoText
	If GroupWarn And ( Not KeyTemp ) And CheckMode() And GroupInfo_Arr[A_ThisHotkey]
	{
		Msg := GroupInfo_arr[A_ThisHotkey]
		StringSplit,Len,Msg,`n
		ControlGetPos,xn,yn,,hn,Edit1,AHK_CLASS TTOTAL_CMD
		yn := yn - hn - ( Len0 * 17 )
		Tooltip,%Msg%,%xn%,%yn% ;Lang
		SetTimer,<RemoveTooltipEx>,50
	}
	If checkMode()
	{
		KeyCount := 0
		KeyTemp .= A_ThisHotkey
		AllGK := Groupkey_Arr["Hotkeys"]
		MatchString := "[^&]\s" . RegExReplace(KeyTemp,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
		If RegExMatch(AllGK,MatchString)
		{
			MatchString .= "\s" 
			If RegExMatch(AllGk,MatchString)
			{
				Settimer,<RemoveToolTipEx>,off
				Tooltip
				ControlSetText,Edit1,,AHK_CLASS TTOTAL_CMD
				Action := GroupKey_Arr[KeyTemp]
				If RegExMatch(Action,"<Text>")
					GoText := "G" . KeyTemp
				If RegExMatch(Action,"<Exec>")
					GoExec := "G" . KeyTemp
				KeyTemp := 
				If IsLabel(Action)
				{
					GoSub,%Action%
					Repeat := Action
				}
				Else
					Msgbox % KeyTemp "����" Action "����"
			}
			Else
				ControlSetText,Edit1,%KeyTemp%,AHK_CLASS TTOTAL_CMD
		}
		Else
		{
			ControlSetText,Edit1,,AHK_CLASS TTOTAL_CMD
			KeyTemp := 
			Tooltip
		}
	}
	Else
	{
		Key := TransSendKey(A_ThisHotkey)
		Send,%key%
	}
	
}
; GroupKeyAdd(Key,Action,IsGlobal=False) {{{2
; ���Ų�������ת��
GroupKeyAdd(Key,Action,IsGlobal=False)
{
	Global GroupKey_Arr
	Key_T := TransHotkey(key,"ALL")
	GroupKey_Arr["Hotkeys"] .= A_Space . A_Space . Key_T . A_Space . A_Space
	GroupKey_Arr[Key_T] := Action
	Key_T := TransHotkey(key,"First")
	If IsGlobal
		Hotkey,Ifwinactive
	Else
		Hotkey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Key_T%,<GroupKey>,On,UseErrorLevel
}
; GroupkeyDelete(Key) {{{2
GroupkeyDelete(Key,IsGlobal=False)
{
	Global GroupKey_Arr
	Key_T := "\s" . TransHotkey(Key,"ALL") . "\s"
	GroupKey_Arr["Hotkeys"] := RegExReplace(Groupkey_Arr["Hotkeys"],Key_T)
	Key_T := "\s" . TransHotkey(Key,"First")
	If RegExMatch(GroupKey_Arr["Hotkeys"],Key_T)
		Return
	If IsGlobal
		Hotkey,Ifwinactive
	Else
		Hotkey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Key_T := TransHotkey(Key,"First")
	Hotkey,%Key_T%,Off
}
; SingleRepeat() {{{2
SingleRepeat()
{
	Global Repeat
	If RegExMatch(Repeat,">>")
	{
		KeyCount := SubStr(Repeat,1,(RegExMatch(Repeat,">>") - 1))
		SendKey(SubStr(Repeat,(RegExMatch(Repeat,">>")+2,StrLen(Repeat))))
		Return
	}
	If RegExMatch(Repeat,"^<.*>$")
	{
		If IsLabel(Repeat) AND Not RegExMatch(Repeat,"i)<SingleRepeat>")
		GoSub,%Repeat%
		Return
	}
	If RegExMatch(Repeat,"[0-9]*")
		Postmessage 1075, %Repeat%, 0, , ahk_class TTOTAL_CMD
	If RegExMatch(Repeat,"^\(.*\)$")
	{
		File := SubStr(Repeat,2,StrLen(File)-1)
		If FileExist(File)
		{
			Run,%File%,,UseErrorLevel,ExecID
			WinWait,AHK_PID %ExecID%,,3
			WinActivate,AHK_PID %ExecID%
		}
	}
	If RegExMatch(Repeat,"^\{.*\}$")
	{
		Text := SubStr(Repeat,2,StrLen(Text)-1)
		Send,%Text%
	}
}
; CheckMode() {{{2
CheckMode() 
{
	IfWinNotActive,AHK_CLASS TTOTAL_CMD
		Return True
	WinGet,MenuID,ID,AHK_CLASS #32768
	IF MenuID
		Return False
	ControlGetFocus,ListBox,ahk_class TTOTAL_CMD
   	Ifinstring,ListBox,TMyListBox
		Return true
	Else
		Return False
}
; ����TransHotkey(hotkey,"ALl")�Ĺ���

; TransHotkey(Hotkey) {{{2
; ��<>�����ȼ��滻Ϊahk����ʶ���ȼ� 
TransHotkey(Hotkey,pos="ALL") ;Ĭ��all,�򷵻����м�
{
	If Pos = ALL
	{
		Loop
		{
			If RegExMatch(Hotkey,"^<[^<>]+><[^<>]+>.*$")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,"><.*")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					HK := SubStr(Hotkey,RegExMatch(Hotkey,"><.*")+2,Strlen(Hotkey)-RegExMatch(Hotkey,"><.*")-1)
					Hotkey2 := SubStr(HK,1,RegExMatch(HK,">")-1)
					Hotkey3 := SubStr(HK,RegExMatch(HK,">")+1)
					NewHotkey := Hotkey1 . " & " . Hotkey2 . Hotkey3
				}
				Else
					NewHotkey := Hotkey1  . HK := SubStr(Hotkey,RegExMatch(Hotkey,"><.*")+1,Strlen(Hotkey)-RegExMatch(Hotkey,"><.*"))
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>.+$")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,">.+")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					Hotkey2 := SubStr(Hotkey,RegExMatch(Hotkey,">.+")+1)
					NewHotkey := Hotkey1 . " & " . Hotkey2
				}
				Else
				{
					Hotkey2 := SubStr(Hotkey,RegExMatch(Hotkey,">.+")+1)
					NewHotkey := Hotkey1 . Hotkey2
				}
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>$")
			{
				NewHotkey := SubStr(Hotkey,2,Strlen(Hotkey)-2)
				Break
			}
			NewHotkey := Hotkey	
			Break
		}
	}
	Else
	{
		Loop
		{
			If RegExMatch(Hotkey,"^<[^<>]+><[^<>]+>.*")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,"><")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					HK := SubStr(Hotkey,RegExMatch(Hotkey,"><")+2,Strlen(Hotkey)-RegExMatch(Hotkey,"><")-1)
					Hotkey2 := SubStr(HK,1,RegExMatch(HK,">")-1)
					NewHotkey := Hotkey1 . " & " . Hotkey2
				}
				Else
					NewHotkey := Hotkey1
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>.+")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,">")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					NewHotkey := Hotkey1 . " & " . SubStr(Hotkey,RegExMatch(Hotkey,">")+1,1)
				}
				Else
					NewHotkey := Hotkey1
				Break
			}
			If RegExMatch(Hotkey,"i)^<(l|r)?(ctrl|control|shift|win|alt)>$")
			{
				NewHotkey := SubStr(Hotkey,2,Strlen(Hotkey)-2)
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>$")
			{
				NewHotkey := SubStr(Hotkey,2,Strlen(Hotkey)-2)
				Break
			}
			If RegExMatch(Hotkey,"^.*")
				NewHotkey := Substr(hotkey,1,1)
			Break
		}
	}
	Return NewHotkey 
}
/*
TransHotkey1(Hotkey,pos="ALL") ;Ĭ��ֻ���ص�һ���������allΪ1�򷵻����м�
{
	If pos = ALL
	{
		If RegExMatch(hotkey,"^<[^<>]+>.*")
		{
			tag := 0
			NewHotkey :=
			If RegExMatch(hotkey,"^<[^<>]+>$") ;ֻ��һ�����Ļ���������&���Ӷ����
				Add := ""
			Else
				Add := " & " ;addҪ����&,����ת���� ctrl & a �͵ļ�����ahk�ܹ�ʶ��
			If RegExMatch(hotkey,"^<.+><.+>$")
			{
				d1 := 1
			}
			If RegExMatch(hotkey,"^<.*><.*>.+")
			{
				d2 := 1
			}
			Loop,parse,hotkey
			{
				If ( A_LoopField == "<" ) 
				{
					tag := 1
					Continue
				}
				If ( A_LoopField == ">" ) AND ( Tag == 1 )
				{
					tag := 0
					NewHotkey := NewHotkey . add
					if d2
						add := 
					Continue
				}
				NewHotkey .= A_LoopField
			}
			If d1
				NewHotkey := Substr(NewHotkey,1,Strlen(NewHotkey)-3)
			Return NewHotkey
		}
		Else
			Return hotkey
	}
	If ( StrLen(Hotkey) > 2 ) AND ( SubStr(hotkey,1,1)  == "<" )
	{
		tag := 0
		NewHotkey :=
		If RegExMatch(hotkey,"^<[^<>]*>$")
			Add := ""
		Else
			Add := " & "
		If RegExMatch(hotkey,"^<.*><.*>$")
		{
			Hotkey := RegExReplace(hotkey,"><"," & ")
			Return SubStr(hotkey,2,strlen(hotkey)-2)
		}
		If RegExMatch(hotkey,"^<.*><.*>.*")
		{
			Hotkey := Substr(hotkey,1,RegExMatch(hotkey,">+[^<]"))
			hotkey := RegExReplace(hotkey,"><"," & ")
			Return SubStr(hotkey,2,strlen(hotkey)-2)
		}
		Loop,parse,hotkey
		{
			If ( A_LoopField == "<" ) 
			{
				tag := 1
				Continue
			}
			If ( A_LoopField == ">" ) AND ( Tag == 1 )
			{
				tag := 0
				NewHotkey := NewHotkey . add
				Continue
			}
			NewHotkey .= A_LoopField
			If !Tag AND A_LoopField != "<"
				Break
		}
		Return NewHotkey
	}
	Else
		Return SubStr(Hotkey,1,1)
}
*/
; TransSendKey(hotkey) {{{2
TransSendKey(hotkey)
{
	Loop
	{
		If RegExMatch(Hotkey,"i)^Esc$")
		{
			Hotkey := "{Esc}"
			Break
		}
		If StrLen(hotkey) > 1 AND Not RegExMatch(Hotkey,"^\+.$")
		{
			Hotkey := "{" . hotkey . "}"
			If RegExMatch(hotkey,"i)(shift|lshift|rshift)(\s\&\s)?.+$")
				Hotkey := "+" . RegExReplace(hotkey,"i)(shift|lshift|rshift)(\s\&\s)?")
			If RegExMatch(hotkey,"i)(ctrl|lctrl|rctrl|control|lcontrol|rcontrol)(\s\&\s)?.+$")
				Hotkey := "^" . RegExReplace(hotkey,"i)(ctrl|lctrl|rctrl|control|lcontrol|rcontrol)(\s\&\s)?")
			If RegExMatch(hotkey,"i)(lwin|rwin)(\s\&\s)?.+$")
				Hotkey := "#" . RegExReplace(hotkey,"i)(lwin|rwin)(\s\&\s)?")
			If RegExMatch(hotkey,"i)(alt|lalt|ralt)(\s\&\s)?.+$")
				Hotkey := "!" . RegExReplace(hotkey,"i)(alt|lalt|ralt)(\s\&\s)?")
		}
		If RegExMatch(Hotkey,"^\+.$")
		{
			Hotkey := SubStr(Hotkey,1,1) . "{" . SubStr(Hotkey,2) . "}"
		}
		GetKeyState,Var,CapsLock,T
		If Var = D
		{
			If RegExMatch(Hotkey,"^\+\{[a-z]\}$")
			{
				Hotkey := SubStr(Hotkey,2)
				Break
			}
			If RegExMatch(Hotkey,"^[a-z]$")	
			{
				Hotkey := "+{" . Hotkey . "}"
				Break
			}
			If RegExMatch(Hotkey,"^\{[a-z]\}$")
			{
				Hotkey := "+" . Hotkey 
				Break
			}
		}
		;Else
		;{
		;}
		Break
	}
	Return hotkey
}
; FindPath(File) {{{2
; Ѱ��TCִ���ļ��������ļ���·�� 
FindPath(File){
	If RegExMatch(File,"exe")
	{
		GetPath := A_WorkingDir . "\totalcmd.exe"
		Reg := "InstallDir"
		FileSF_Option := 3
		FileSF_FileName:= "ѡ��TOTALCMD.EXE" ;Lang
		FileSF_Prompt := "TOTALCMD.EXE"
		FileSF_Filter := "TOTALCMD.EXE"
		FileSF_Error := "��TOTALCMD.EXEʧ��"
	}
	If RegExMatch(File,"ini")
	{
		GetPath := A_workingDir . "\wincmd.ini"
		Reg := "IniFileName"
		FileSF_Option := 3
		FileSF_FileName:= 
		FileSF_Prompt := "ѡ�������ļ�"
		FileSF_Filter := "*.INI"
		FileSF_Error := "��TC�����ļ�ʧ��"
	}
	If Not FileExist(GetPath)
		RegRead,GetPath,HKEY_CURRENT_USER,Software\VIATC,%Reg%
	FilegetAttrib,Attrib,%GetPath%
	IfNotInString, Attrib, D
	{
		Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%GetPath%,%Reg%
		Return GetPath
	}
	FileSelectFile,GetPath,%FileSF_Option%,%FileSF_FileName%,%FileSF_Prompt%,%FileSF_Filter%
	If ErrorLevel
	{
		Msgbox %FileSF_Error%
		Return 
	}
	Else
		Return GetPath
}
; ReadKeyFromIni() {{{2
ReadKeyFromIni()
{
	Global ViatcIni,ExecFile_Arr,SendText_Arr,MapKey_Arr,MapKey_Arr
	Loop,Read,%ViatcIni%
	{
		If RegExMatch(SubStr(RegExReplace(A_LoopReadLine,"\s"),1,1),";")
			Continue
		If RegExMatch(A_LoopReadLine,"i)\[.*\]")
			IsReadKey := False
		If RegExMatch(A_LoopReadLine,"i)\[Hotkey\]")
		{
			IsReadKey := True
			IsHotkey := True
			IsGlobalHotkey := False
			IsGroupkey := False
			Continue
		}
		If RegExMatch(A_LoopReadLine,"i)\[GlobalHotkey\]")
		{
			IsReadKey := True
			IsGlobalHotkey := True
			IsHotkey := False
			IsGroupkey := False
			Continue
		}
		If RegExMatch(A_LoopReadLine,"i)\[GroupKey\]")
		{
			IsReadKey := True
			IsGroupkey := True
			IsHotkey := False
			IsGlobalHotkey := False
			Continue
		}
		If IsReadkey
		{
			StringPos := RegExMatch(A_LoopReadLine,"=[<|\(|\{].*[>|\)\}]$",Action)
			If StringPos
			{
				Key := SubStr(A_LoopReadLine,1,StringPos-1)
				Action := SubStr(Action,2)
			}
			If IsGlobalHotkey
				MapKeyAdd(Key,Action,"S")
			If IsHotkey
				MapKeyAdd(Key,Action,"H")
			If IsGroupkey
				MapKeyAdd(Key,Action,"G")
		}
	}
}
; MapKeyAdd(Key,Action,Scope) {{{2
MapKeyAdd(Key,Action,Scope)
{
	Global MapKey_Arr,ExecFile_Arr,SendText_Arr
	;Msgbox % Key Action Scope
	If Not RegExMatch(Key,"[^<[^<>]+>$|^<[^<>]+><[^<>]+>$|^<[^<>]+>.$|^.$]")
		Scope := "G"
	If Not RegExMatch(Action,"^[<|\(|\{].*[>|\)\}]$")
		Return False
	If Not IsLabel(Action) AND RegExMatch(Action,"^<.*>$")
	{
		;MsgBox % "�ȼ�" Key "��Ӧ�Ķ���" Action "�������飡"
		return False
	}
	If RegExMatch(Action,"^\(.*\)$")
	{
		Key_T := Scope . TransHotkey(Key)
		ExecFile_Arr["HotKeys"] .= A_Space . Key_T . A_Space
		ExecFile_Arr[Key_T] := Substr(Action,2,Strlen(Action)-2)
		Action := "<Exec>"
	}
	If RegExMatch(Action,"^\{.*\}$")
	{
		Key_T := Scope . TransHotkey(Key)
		SendText_Arr["HotKeys"] .= A_Space . Key_T . A_Space
		SendText_Arr[Key_T] := Substr(Action,2,Strlen(Action)-2)
		Action := "<Text>"
	}
	If Scope = S
	{
		HotKey,IfWinActive
		Key_T := TransHotkey(Key,"First")
		Hotkey,%Key_T%,%Action%,On,UseErrorLevel
	}
	If Scope = H
	{
		Hotkey,IfWinActive,AHK_CLASS TTOTAL_CMD
		Key_T := TransHotkey(Key,"First")
		Hotkey,%Key_T%,%Action%,On,UseErrorLevel
	}
	If Scope = G
		GroupKeyAdd(Key,Action)
	Key_T := "i)\s" . Scope . RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") . "\s"
	If RegExMatch(MapKey_Arr["Hotkeys"],Key_T)
		Return true
	Else
	{
		Key := Scope . Key
		MapKey_Arr["Hotkeys"] .= A_space . Key . A_Space
	}
	MapKey_Arr[Key] := Action
	Return true
}
; MapKeyDelete(Key,Scope) {{{2
MapKeyDelete(Key,Scope)
{
	Global MapKey_Arr
	If Scope = S
	{
		Key_T := TransHotkey(Key)
		Hotkey,IfWinActive
		Hotkey,%Key_T%,Off
	}
	If Scope = H
	{
		Key_T := TransHotkey(Key)
		Hotkey,IfWinActive,AHK_CLASS TTOTAL_CMD
		Hotkey,%Key_T%,Off
	}
	If Scope = G
		GroupkeyDelete(Key)
	
	DelKey := "\s" . Scope . RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") . "\s"
	Mapkey_Arr["Hotkeys"] := RegExReplace(MapKey_Arr["Hotkeys"],DelKey)
}
; GetConfig(Section,Key) {{{2
; ��ȡ�����ļ�
GetConfig(Section,Key)
{
	Global ViatcIni
	IniRead,Getvar,%ViatcIni%,%Section%,%Key%
	If RegExMatch(Getvar,"^ERROR$")
		GetVar := CreateConfig(Section,key)
	Return GetVar
}
; CreateConfig(Section,Key) {{{2
; ���������ļ�
CreateConfig(Section,Key)
{
	Global ViatcIni
	If Section = Configuration
		If Key = TrayIcon
			SetVar := 1
		If Key = Vim
			SetVar := 1
		If Key = Toggle
			SetVar := "<lwin>w"
		If Key = GlobalTogg
			SetVar := 1
		If Key = Suspend
			SetVar := "<alt>``"
		If Key = GlobalSusp
			SetVar := 0
		If Key = Startup
			SetVar := 0
		If Key = Service
			SetVar := 1
		If Key = GroupWarn
			SetVar := 1
		If Key = TranspHelp
			SetVar := 0
		If Key = TransParent
			SetVar := 0
		If Key = TranspVar
			SetVar := 220
		If Key = MaxCount
			SetVar := 99
	If Section = SearchEngine
		If Key = Default
			SetVar := 1
		If Key = 1
			SetVar := "http://www.google.com.hk/search?q={%1}"
		If Key = 2
			SetVar := "http://www.baidu.com/s?wd={%1}"
	IniRead,GetVar,%ViatcIni%,%Section%,%Key%
	If Getvar = ERROR
		Iniwrite,%SetVar%,%ViatcIni%,%Section%,%Key%
	Return SetVar
}
; ToggleMenu(a=0) {{{2
ToggleMenu(a=0)
{
	Global TCMenuHandle
	WinGet,hwin,Id,AHK_CLASS TTOTAL_CMD
	If hwin
    	MenuHandle := DllCall("GetMenu", "uint", hWin)
	If MenuHandle
	{
        DllCall("SetMenu", "uint", hWin, "uint", 0)
		TCmenuHandle := MenuHandle
	}
	Else
		DllCall("SetMenu", "uint", hWin, "uint", TCmenuHandle )
	if a
	{
		WinSet,Style,+0xC10000,AHK_CLASS TTOTAL_CMD
		DllCall("SetMenu", "uint", hWin, "uint", TCmenuHandle )
	}
}
; HideControl() {{{2
HideControl()
{
	Global HideControl_arr,TcIni,TCmenuHandle
	if HideControl_arr["Toggle"]
	{
	    HideControl_arr["Toggle"] := False
		if HideControl_arr["KeyButtons"] 
			PostMessage 1075, 2911 , 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["drivebar1"] 
			PostMessage 1075, 2902 , 0, , AHK_CLASS TTOTAL_CMD
 		if HideControl_arr["DriveBar2"] 
			PostMessage 1075,  2903, 0, , AHK_CLASS TTOTAL_CMD
 		if HideControl_arr["DriveBarFlat"] 
			PostMessage 1075,  2904, 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["InterfaceFlat"] 
			PostMessage 1075,  2905, 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["DriveCombo"] 
			PostMessage 1075, 2906 , 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["DirectoryTabs"] 
			PostMessage 1075,  2916, 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["XPthemeBg"] 
			PostMessage 1075, 2923 , 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["CurDir"] 
			PostMessage 1075, 2907 , 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["TabHeader"] 
			PostMessage 1075, 2908 , 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["StatusBar"] 
			PostMessage 1075,  2909, 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["CmdLine"] 
			PostMessage 1075, 2910 , 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["HistoryHotlistButtons"] 
			PostMessage 1075, 2919 , 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["BreadCrumbBar"] 
			PostMessage 1075,  2926, 0, , AHK_CLASS TTOTAL_CMD
		if HideControl_arr["ButtonBar"] 
			PostMessage 1075,2901  , 0, , AHK_CLASS TTOTAL_CMD
		WinSet,Style,+0xC10000,AHK_CLASS TTOTAL_CMD
		winActivate,AHK_CLASS TTOTAL_CMD
		Settimer,FS,off
		WinGet,hwin,Id,AHK_CLASS TTOTAL_CMD
		If hwin
			DllCall("SetMenu", "uint", hWin, "uint", TCmenuHandle )
	}
	Else
	{
		HideControl_arr["Toggle"] := True
		IniRead,v_KeyButtons,%TCINI%,LayOut,KeyButtons
		HideControl_arr["KeyButtons"] := v_KeyButtons
		If v_KeyButtons
			PostMessage 1075, 2911 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_drivebar1,%TcIni%,layout,drivebar1
		HideControl_arr["drivebar1"] := v_drivebar1
		If v_DriveBar1
			PostMessage 1075, 2902 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_DriveBar2,%TcIni%,Layout,DriveBar2
 		HideControl_arr["DriveBar2"] := v_DriveBar2
		If v_DriveBar2
			PostMessage 1075,  2903, 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_DriveBarFlat,%TcIni%,Layout,DriveBarFlat
 		HideControl_arr["DriveBarFlat"] := v_DriveBarFlat
		If v_DriveBarFlat
			PostMessage 1075,  2904, 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_InterfaceFlat,%TcIni%,Layout,InterfaceFlat
		HideControl_arr["InterfaceFlat"] := v_InterfaceFlat
		If v_InterfaceFlat
			PostMessage 1075,  2905, 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_DriveCombo,%TcIni%,Layout,DriveCombo
		HideControl_arr["DriveCombo"] := v_DriveCombo
		If v_DriveCombo
			PostMessage 1075, 2906 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_DirectoryTabs,%TcIni%,Layout,DirectoryTabs
		HideControl_arr["DirectoryTabs"] := v_DirectoryTabs
		If v_DirectoryTabs
			PostMessage 1075,  2916, 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_XPthemeBg,%TcIni%,Layout,XPthemeBg
		HideControl_arr["XPthemeBg"] := v_XPthemeBg
		If v_XPthemeBg
			PostMessage 1075, 2923 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_CurDir,%TcIni%,Layout,CurDir
		HideControl_arr["CurDir"] := v_CurDir
		If v_CurDir
			PostMessage 1075, 2907 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_TabHeader,%TcIni%,Layout,TabHeader
		HideControl_arr["TabHeader"] := v_TabHeader
		If v_TabHeader
			PostMessage 1075, 2908 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_StatusBar,%TcIni%,Layout,StatusBar
		HideControl_arr["StatusBar"] := v_StatusBar
		If v_StatusBar
			PostMessage 1075,  2909, 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_CmdLine,%TcIni%,Layout,CmdLine
		HideControl_arr["CmdLine"] := v_CmdLine
		If v_CmdLine
			PostMessage 1075, 2910 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_HistoryHotlistButtons,%TcIni%,Layout,HistoryHotlistButtons
		HideControl_arr["HistoryHotlistButtons"] := v_HistoryHotlistButtons
		If v_HistoryHotlistButtons
			PostMessage 1075, 2919 , 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_BreadCrumbBar,%TcIni%,Layout,BreadCrumbBar
		HideControl_arr["BreadCrumbBar"] := v_BreadCrumbBar
		If v_BreadCrumbBar
			PostMessage 1075,  2926, 0, , AHK_CLASS TTOTAL_CMD
		IniRead,v_ButtonBar	,%TcIni%,Layout,ButtonBar	
		HideControl_arr["ButtonBar"] := v_ButtonBar
		If v_ButtonBar	
			PostMessage 1075,2901  , 0, , AHK_CLASS TTOTAL_CMD
		WinSet,Style,-0xC00000,AHK_CLASS TTOTAL_CMD
		;WinSet,Style,+0x10000L,AHK_CLASS TTOTAL_CMD
		winActivate,AHK_CLASS TTOTAL_CMD
		;Settimer,FS,300
	}
}
FS:
	FS()
Return
FS()
{
	WinGet,hwin,Id,AHK_CLASS TTOTAL_CMD
	If hwin
    	MenuHandle := DllCall("GetMenu", "uint", hWin)
	Else
		Settimer,FS,off
	If MenuHandle
        DllCall("SetMenu", "uint", hWin, "uint", 0)
}
; Enter() {{{2
Enter()
{
	Global MapKey_Arr,ActionInfo_Arr,ExecFile_Arr,SendText_Arr
	ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
	If RegExMatch(ThisControl,"^Edit1$")
	{
		ControlGetText,CMD,Edit1,AHK_CLASS TTOTAL_CMD
		If RegExMatch(CMD,"^:.*")
		{
			ControlGetPos,xn,yn,,hn,Edit1,AHK_CLASS TTOTAL_CMD
			ControlSetText,Edit1,,AHK_CLASS TTOTAL_CMD
			CMD := SubStr(CMD,2)
			If RegExMatch(CMD,"i)^se?t?t?i?n?g?\s*$")
			{
				Setting()
				Return
			}
			If RegExMatch(CMD,"i)^he?l?p?\s*")
			{
				Help()
				Return
			}
			If RegExMatch(CMD,"i)^re?l?o?a?d?\s*$")
			{
				ReloadVIATC()
				Return
			}
			If RegExMatch(CMD,"i)^ma?p?\s*$")
			{
				Map := MapKey_Arr["Hotkeys"]
				Stringsplit,ListMap,Map,%A_Space% 
				Loop,% ListMap0
				{
					If ListMap%A_Index%
					{
						Action := MapKey_Arr[ListMap%A_Index%]
						If Action = <Exec>
						{
							EX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
							Action := "(" . ExecFile_Arr[EX] . ")"
						}
						If Action = <Text>
						{
							TX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
							Action := "{" . SendText_Arr[TX] . "}"
						}
						LM .= SubStr(ListMap%A_Index%,1,1) . "  " . SubStr(ListMap%A_Index%,2) . "  " . Action  . "`n"
					}
				}
				yn := yn - hn - ( ListMap0 * 8 ) 
				Tooltip,%LM%,%xn%,%yn%
				Settimer,<RemoveToolTipEx>,100
				Return
			}
			If RegExMatch(CMD,"i)^ma?p?\s*[^\s]*")
			{
				CMD1 := RegExReplace(CMD,"i)^ma?p?\s*")
				Key := SubStr(CMD1,1,RegExMatch(CMD1,"\s")-1)
				Action := SubStr(CMD1,RegExMatch(CMD1,"\s[^\s]")+1)
				yn := yn -  hn - 9
				If Not RegExMatch(Key,"[^<[^<>]+>$|^<[^<>]+><[^<>]+>$|^<[^<>]+>.$|^.$]")
					If Not MapKeyAdd(Key,Action,"G")
						Tooltip,ӳ��ʧ��`,����%Action%����,%xn%,%yn%
					Else
						Tooltip,ӳ��ɹ�,%xn%,%yn%
				Else
					If Not MapKeyAdd(Key,Action,"H")
						Tooltip,ӳ��ʧ��,%xn%,%yn%
					Else
						Tooltip,ӳ��ɹ�,%xn%,%yn%
				Sleep,2000
				Tooltip
				Return
			}
			If RegExMatch(CMD,"i)^sma?p?\s*[^\s]*")
			{
				CMD1 := RegExReplace(CMD,"i)^sma?p?\s*")
				Key := SubStr(CMD1,1,RegExMatch(CMD1,"\s")-1)
				Action := SubStr(CMD1,RegExMatch(CMD1,"\s[^\s]")+1)
				yn := yn -  hn - 9
				If RegExMatch(Key,"^[^<][^>]+$|^<[^<>]*>[^<>][^<>]+$|^<[^<>]+><[^<>]+>.+$") ; "(^.+$|^<[^<>]*>.$|^<[^<>]*>$|^<[^<>*]><[^<>*]>$)")
					Tooltip,ӳ��ʧ��`,ȫ���ȼ���֧����ϼ�,%xn%,%yn%
				Else
					If Not MapKeyAdd(Key,Action,"S")
						Tooltip,ӳ��ʧ��,%xn%,%yn%
					Else
						Tooltip,ӳ��ɹ�,%xn%,%yn%
				Sleep,2000
				Tooltip
				Return
			}
			If RegExMatch(CMD,"i)^e.*")
			{
				Editviatcini()
				Return
			}
			yn := yn -  hn - 9
			Tooltip,��Ч��������,%xn%,%yn%
			Sleep,2000
			Tooltip
		}
		Else
			Send,{Enter}
	}
	Else
		Send,{Enter}
}
; CreateNewFile() {{{2
CreateNewFile()
{
	Global ViatcIni
	If CheckMode()
	{
	Menu,CreateNewFile,Add
	Menu,CreateNewFile,DeleteAll
	Index := 0
	Loop,23
	{
		IniRead,file,%ViatcIni%,ShellNew,%A_Index%
		If file <> ERROR
		{
			Splitpath,file,,,ext
			ext := "." . ext
			Icon_file :=
			Icon_idx :=
			RegRead,filetype,HKEY_CLASSES_ROOT,%ext%
			If Not filetype
			{
				Loop,HKEY_CLASSES_ROOT,%ext%,2
					If RegExMatch(A_LoopRegName,".*\.")
						filetype := A_LoopRegName
			}
			RegRead,iconfile,HKEY_CLASSES_ROOT,%filetype%\DefaultIcon
			Loop,% StrLen(iconfile)
			{
				If RegExMatch(SubStr(iconfile,Strlen(iconfile)-A_index+1,1),",")
				{
					icon_file := SubStr(iconfile,1,Strlen(iconfile)-A_index)
					icon_idx := Substr(iconfile,Strlen(iconfile)-A_index+2,A_index)
					Break
				}
			}
			file := "&" . chr(64+A_Index) . ">>" . Substr(file,2,RegExMatch(file,"\)")-2)
			Menu,CreateNewFile,Add,%file%,CreateFile
			Menu,CreateNewFile,Icon,%file%,%icon_file%,%icon_idx%
			Index++
			File := 
		}
	}
	If Index > 1
		Menu,CreateNewFile,Add
	Menu,CreateNewFile,Add,�ļ���(&W),MkDir
	Menu,CreateNewFile,Icon,�ļ���(&W),%A_WinDir%\system32\Shell32.dll,-4
	Menu,CreateNewFile,Add,�հ��ļ�(&V),CreateFile
	Menu,CreateNewFile,Icon,�հ��ļ�(&V),%A_WinDir%\system32\Shell32.dll,-152
	Menu,CreateNewFile,Add,��ݷ�ʽ(&Y),Shortcut
	Menu,CreateNewFile,Icon,��ݷ�ʽ(&Y),%A_WinDir%\system32\Shell32.dll,-30
	Menu,CreateNewFile,Add
	Menu,CreateNewFile,Add,��ӵ���ģ��(&X),template ;Lang
	Menu,CreateNewFile,Icon,��ӵ���ģ��(&X),%A_WinDir%\system32\Shell32.dll,-155
	Menu,CreateNewFile,Add,����(&Z),M_EVI
	Menu,CreateNewFile,Icon,����(&Z),%A_WinDir%\system32\Shell32.dll,-151
	ControlGetFocus,TLB,ahk_class TTOTAL_CMD
	ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
	Menu,CreateNewFile,show,%xn%,%yn%
	}
}
MkDir:
	PostMessage 1075, 907, 0, , ahk_class TTOTAL_CMD
Return
Shortcut:
	PostMessage 1075, 1004, 0, , ahk_class TTOTAL_CMD	
Return
template:
	template()
Return
template()
{
	Global CNF
	ClipSaved := ClipboardAll
	Clipboard :=
	SendMessage 1075, 2018, 0, , ahk_class TTOTAL_CMD	
	ClipWait,2
	If Clipboard
		temp_File := Clipboard
	Else
		Return
	Clipboard := ClipSaved
	Filegetattrib,Attributes,%Temp_file%
	IfInString, Attributes, D
	{
		Msgbox ,,�����ģ��,��ѡ���ļ� ;Lang
		Return
	}
	Splitpath,temp_file,,,Ext
	WinGet,hwndtc,id,AHK_CLASS TTOTAL_CMD
	Gui,new,+Theme +Owner%hwndtc% +HwndCNF
	Gui,Add,Text,x10 y10,ģ����
	Gui,Add,Edit,x50 y8 w205,%ext%
	Gui,Add,Text,x10 y42,ģ��Դ
	Gui,Add,Edit,x50 y40 w205 h20 +ReadOnly,%temp_File%
;	Gui,Add,button,x50 y68 gTemp_brow,���(&F)
	Gui,Add,button,x140 y68 default gTemp_save,ȷ��(&O)
	Gui,Add,button,x200 y68 g<Cancel>,ȡ��(&C)
	Gui,Show,,�½�ģ�� ;Lang
	Controlsend,edit1,{ctrl a},ahk_id %CNF%
	Controlsend,edit2,{end},ahk_id %CNF%
}
Temp_save:
	temp_save()
Return
Temp_save()
{
	Global CNF,TCDir,ViatcIni
	ControlGettext,tempName,edit1,ahk_id %cnf%
	ControlGettext,tempPath,edit2,ahk_id %cnf%
	ShellNew := TCDir . "\ShellNew"
	If Not InStr(Fileexist(ShellNew),"D")
		FileCreateDir,%ShellNew%
	Filecopy,%tempPath%,%TCDir%\ShellNew,1
	Splitpath,tempPath,FileName
	New := 1
	Loop,23
	{
		IniRead,file,%ViatcIni%,ShellNew,%A_Index%
		If file = ERROR
			Break
		New++
	}
	IniWrite,(%tempName%)\%FileName%,%ViatcIni%,ShellNew,%New%
	Gui,Destroy
	EmptyMem()
}
;CNF_conf:
;Return
CreateFile:
	CreateFile(SubStr(A_ThisMenuItem,5,Strlen(A_ThisMenuItem)))
Return
CreateFile(item)
{
	Global ViatcIni,TCDir,CNF_New
	ClipSaved := ClipboardAll
	Clipboard :=
	SendMessage 1075, 2029, 0, , ahk_class TTOTAL_CMD	
	ClipWait,2
	If Clipboard
		NewPath := Clipboard
	Else
		Return
	Clipboard := ClipSaved
	If RegExMatch(NewPath,"^\\\\�����$")
		Return
	If RegExMatch(NewPath,"i)\\\\���п��������$")
		Return
	If RegExMatch(NewPath,"i)\\\\Fonts$")
		Return
	If RegExMatch(NewPath,"i)\\\\����$")
		Return
	If RegExMatch(NewPath,"i)\\\\��ӡ��$")
		Return
	If RegExMatch(NewPath,"i)\\\\����վ$")	
		Return
	Loop,23
	{
		IniRead,file,%ViatcIni%,ShellNew,%A_Index%
		Match := Substr(file,2,RegExMatch(file,"\)")-2)
		if RegExMatch(Match,item) Or RegExMatch(Item,"^\(&V\)$")
		{
			If RegExMatch(Item,"^\(&V\)$")
			{
				File := A_Temp . "\viatcTemp"
				If Fileexist(file)
					Filedelete,%File%
				FileAppend,,%File%,UTF-8
			}
			Else
				file := TCDir . "\ShellNew" . Substr(file,RegExMatch(file,"\)")+1,Strlen(file))
			If Fileexist(file)
			{
				Splitpath,file,filename,,fileext
				WinGet,hwndtc,id,AHK_CLASS TTOTAL_CMD
				Gui,new,+Theme +Owner%hwndtc% +HwndCNF_New
				Gui,Add,Text,hidden ,%file%
				;Tooltip,%file%
				Gui,Add,Edit,x10 y10 w340 h22 -Multi,%filename%
				Gui,Add,button,x200 y40 w70 gTemp_create Default,ȷ��(&O)
				Gui,Add,button,x280 y40 w70 g<Cancel>,ȡ��(&C)
				Gui,Show,w360 h70,�½��ļ� ;Lang
				Controlsend,edit1,{ctrl a},ahk_id %CNF_New%
				If Fileext
				Loop,% strlen(fileext)+1
					Controlsend,edit1,+{left},ahk_id %CNF_New%
			}
			Else
			{
				Msgbox ģ��Դ�ѱ��ƶ���ɾ��
				IniDelete,%ViatcIni%,ShellNew,%A_Index%
			}
			Break
		}
	}
}
Temp_Create:
	Temp_Create()
Return
Temp_Create()
{
	Global CNF_New
	ControlGetText,FilePath,Static1,AHK_ID %CNF_New%
	ControlGetText,NewFile,Edit1,AHK_ID %CNF_New%
	ClipSaved := ClipboardAll
	Clipboard :=
	SendMessage 1075, 2029, 0, , ahk_class TTOTAL_CMD	
	ClipWait,2
	If Clipboard
		NewPath := Clipboard
	Else
		Return
	If RegExmatch(NewPath,"^\\\\����$")
		NewPath := A_Desktop
	NewFile := NewPath . "\" . NewFile
	If Fileexist(NewPath)
	{
		Filecopy,%FilePath%,%NewFile%,1
		If ErrorLevel
			Msgbox �ļ��Ѵ��� ;Lang
		Gui,Destroy
		EmptyMem()
	}
	Clipboard := ClipSaved
	ControlGetFocus,focus_control,AHK_CLASS TTOTAL_CMD
	If RegExMatch(focus_control,"^TMyListBox\d$")
	{
		Splitpath,NewFile,NewFileName
		Matchstr := RegExReplace(newfileName,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
		Loop,100
		{
			ControlGet,outvar,list,,%focus_control%,AHK_CLASS TTOTAL_CMD
			If RegExMatch(outvar,Matchstr) ;FileExist(newFile)
			{
				Matchstr := "^" . Matchstr 
				Loop,Parse,Outvar,`n
				{
					If RegExMatch(A_LoopField,MatchStr)
					{
						Focus := A_Index - 1
						Break
					}
				}
				;ControlSend,%Focus_Control%,{Home},AHK_Class TTOTAL_CMD
				PostMessage, 0x185, 1, %Focus%, %Focus_Control%, AHK_CLASS TTOTAL_CMD
				Break
			}
			Sleep,50
		}
	}
	Run,%newFile%,,UseErrorLevel
	Return
}
M_EVI:
	Editviatcini()
Return
Editviatcini()
{
	Global viatcini
	RegRead,path,HKEY_LOCAL_MACHINE,Software\vim\gvim,path
	match = `"$0
	INI := Regexreplace(viatcini,".*",match)
	path := path . " "
	If Fileexist(path)
		editini := path . a_space . ini
	Else
		editini := "notepad.exe" . a_space . ini
	Run,%editini%,,UseErrorLevel
	Return
}
<Cancel>:
	Gui,Cancel
Return
; EmptyMem() {{{2
EmptyMem(PID="AHK Rocks")
{
    pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}
; Gui Functions {{{2
; Setting() {{{3
Setting()
{
	Global StartUp,Service,TrayIcon,Vim,GlobalTogg,Toggle,GlobalSusp,Susp,GroupWarn,TranspHelp,TransParent,SearchEng,DefaultSE,ViATcIni,TCExe,TCINI
	Global ListView
	Global MapKey_Arr,ActionInfo_Arr,ExecFile_Arr,SendText_Arr
	Gui,Destroy
	Gui,+Theme +hwndviatcsetting
	Gui,Add,Button,x10 y335 w80 g<EditViATCIni>,�����ļ�(&E)
	Gui,Add,Button,x140 y335 w80 center Default g<GuiEnter>,ȷ��(&O)
	Gui,Add,Button,x230 y335 w80 center g<GuiCancel>,ȡ��(&C)
	Gui,Add,Tab2,x10 y6 +theme h320 center choose2,����(U)|��ݼ�(P)|&·������(&M)
	Gui,Add,GroupBox,x16 y32 H170 w290,ȫ������
	Gui,Add,CheckBox,x25 y50 h20 checked%startup% vStartup,��������VIATC(&R)
	Gui,Add,CheckBox,x180 y50 h20 checked%Service% vService,��̨����(&B)
	Gui,Add,CheckBox,x25 y70 h20 checked%TrayIcon% vTrayIcon,ϵͳ����ͼ��(&T)
	Gui,Add,CheckBox,x180 y70 h20 checked%Vim% vVim,Ĭ��VIMģʽ(&V)
	Gui,Add,Text,x25 y100 h20,����/��С��TC(&F)
	Gui,Add,Edit,x24 y120 h20 w140 vToggle ,%Toggle%
	Gui,Add,CheckBox,x180 y120 h20 checked%GlobalTogg% vGlobalTogg ,ȫ��(&G)
	Gui,Add,Text,x25 y150 h20,����/����VIM�ȼ�(&A)
	Gui,Add,Edit,x25 y170 h20 w140 vSusp ,%Susp%
	Gui,Add,CheckBox,x180 y170 h20 checked%GlobalSusp% vGlobalSusp,ȫ��(&L)
	Gui,Add,GroupBox,x16 y210 H110 w290,��������
	Gui,Add,Text,x25 y228 h20,����ѡ�е��ļ������ļ���(&Q)
	D := 1
	Loop,15
	{
		IniRead,SE,%ViATcINI%,SearchEngine,%A_Index%
		If SE = ERROR
			IniDelete,%ViATcINI%,SearchEngine,%A_Index%
		Else
		{
			IniDelete,%ViATcINI%,SearchEngine,%A_Index%
			If A_Index = %DefaultSE%
			{
				DefaultSE := D
				IniWrite,%D%,%ViATcIni%,SearchEngine,Default
			}
			IniWrite,%SE%,%ViATcIni%,SearchEngine,%D%
			SE_Arr .= SE . "|"
			D++
		}
	}
	D--
	If DefaultSE > %D%
	{
		DefaultSE := D
		IniWrite,%D%,%ViATcIni%,SearchEngine,Default
	}
	Gui,Add,ComboBox,x25 y246 h20 w226 choose%DefaultSE% AltSubmit vDefaultSE R5 hwndaa g<SetDefaultSE>,%SE_Arr%
	Gui,Add,Button,x256 y246 h20 w22 g<AddSearchEng>,&+
	Gui,Add,Button,x280 y246 h20 w22 g<DelSearchEng>,&-
	Gui,Add,CheckBox,x25 y270 h20 checked%GroupWarn% vGroupWarn,��ϼ���ʾ��Ϣ(&I)
	Gui,Add,CheckBox,x25 y295 h20 checked%transpHelp% vTranspHelp ,��������͸��(&I)
	Gui,Add,Button,x170 y280 h30 w120 Center g<Help>,��VIATC����(&H)
	Gui,Tab,2
	Gui,Add,ListView,x16 y32 h170 w290 count20 sortdesc  -Multi vListView g<ListViewDK>,*|��ݼ�|����|˵��
	Lv_modifycol(2,100)
	Lv_modifycol(3,100)
	Lv_modifycol(4,300)
	lv := MapKey_Arr["Hotkeys"]
	Stringsplit,Index,lv,%A_Space%
	Index := Index0 - 1
	Loop,%Index%
	{
		If Index%A_Index% 
		{
			Scope := SubStr(Index%A_Index%,1,1)
			Key := SubStr(Index%A_Index%,2)
			Action := MapKey_Arr[Index%A_Index%]
			Info := ActionInfo_Arr[Action]
			If Action = <Exec>
			{
				Action := "����"
				Key_T := Scope . TransHotkey(Key)
				Info := ExecFile_Arr[key_T]
			}
			If Action = <Text>
			{
				Action := "�����ı�"
				Key_T := Scope . TransHotkey(Key)
				Info := SendText_Arr[key_T]
			}
			LV_Add(vis,Scope,Key,Action,Info)
		}
	} 
	Gui,Add,GroupBox,x16 y210 h110 w290
	Gui,Add,Text,x22 y223 h20,��ݼ�(&K)
	Gui,Add,Edit,x78 y220 h20 w100 g<CheckGorH>
	Gui,Add,CheckBox,x183 y221 h20 ,ȫ��(&G)
	Gui,Add,Button,x250 y220 w50 g<TestTH>,����
	Gui,Add,text,x28 y249 h20,����(&W)
	Gui,Add,Edit,x78 y246 h20 w220 
	Gui,Add,Button,x21 y270 h20 w80 g<VimCMD> ,VIM����(&V)
	Gui,Add,Button,x110 y270 h20 w80 g<TCCMD> ,TC����(&T)
	Gui,Add,Button,x21 y294 h20 w80 g<RunFile> ,����(&R)
	Gui,Add,Button,x110 y294 h20 w80 g<SendString> ,�ַ���(&S)
	Gui,Add,Button,x196 y274 h40 w50 g<CheckKey> ,����(&L)
	Gui,Add,Button,x250 y274 h40 w50 g<DeleItem> ,ɾ��(&A)
	Gui,Tab,3
	Gui,Add,Text,x18 y35 h16 center,TCִ�г���λ��:
	Gui,Add,Edit,x18 y55 h20 +ReadOnly w250,%TCEXE%
	Gui,Add,Button,x275 y53 w30 g<GuiTCEXE>,...
	Gui,Add,Text,x18 y80 h16 center,TC�����ļ�λ��:
	Gui,Add,Edit,x18 y100 h20 +ReadOnly w250,%TCINI%
	Gui,Add,Button,x275 y98 w30 g<GuiTCINI> ,...
	Gui,Tab
	Gui,Add,Button,x280 y5 w30 h20 center hide g<ChangeTab>,&U
	Gui,Add,Button,x280 y5 w30 h20 center hide g<ChangeTab>,&P
	Gui,Add,Button,x280 y5 w30 h20 center hide g<ChangeTab>,&M
	GUi,Show,h370 w320,VIATC����
}
; GuiContextMenu {{{4
GuiContextMenu:
	If A_GuiControl <> ListView
		Return
	EventInfo := A_EventInfo
	Menu,RightClick,Add
	Menu,RightClick,DeleteAll
	Menu,RightClick,Add,�༭(&E),<EditItem>
	Menu,RightClick,Add,ɾ��(&D),<DeleItem>
	Menu,RightClick,Show
Return
; GuiEscape {{{4
GuiEscape:
	Gui,Destroy
	EmptyMem()
Return
; <AddSearchEng> {{{4
<AddSearchEng>:
	AddSearchEng()
Return
AddSearchEng()
{
	Global ViATcSetting,ViATcIni
	ControlgetText,SE,Edit3,AHK_ID %VIATCSetting%
	Controlget,SEList,list,,combobox1,AHK_ID %VIATCSetting%
	Stringsplit,List,SEList,`n
	List0++
	GuiControl,,combobox1,%SE%
	IniWrite,%SE%,%VIATCINI%,SearchEngine,%List0%
}
; <DelSearchEng> {{{4
<DelSearchEng>:
	DelSearchEng()
Return
DelSearchEng()
{
	Global ViATcSetting,ViATcIni,DefaultSE
	Controlget,SEList,list,,combobox1,AHK_ID %VIATCSetting%
	IniDelete,%ViATcIni%,SearchEngine,%DefaultSE%
	Stringsplit,List,SEList,`n
	Loop,%List0%
	{
		If A_Index = %DefaultSE%
			Continue
		NewSEList .= "|" . List%A_Index%
	}
	DefaultSE--
	GuiControl,,combobox1,%NewSEList%
	IniWrite,%DefaultSE%,%VIATCINI%,SearchEngine,Default
}
; <SetDefaultSE> {{{4
<SetDefaultSE>:
	SetDefaultSE()
Return
SetDefaultSE()
{
	Global ViATcSetting,DefaultSE,ViATcIni,SearchEng
	GuiControlget,SE,,combobox1,AHK_ID %VIATCSetting%
	If RegExMatch(SE,"^\d+$")
	{
		DefaultSE := SE
		IniRead,SearchEng,%VIATCINI%,SearchEngine,%DefaultSE%
		IniWrite,%SE%,%VIATCINI%,SearchEngine,Default
	}
}
; <GuiEnter> {{{4
<GuiEnter>:
	Gui,Submit
	IniWrite,%TrayIcon%,%ViATcIni%,Configuration,TrayIcon
	IniWrite,%Vim%,%ViATcIni%,Configuration,Vim
	IniWrite,%Toggle%,%ViATcIni%,Configuration,Toggle
	IniWrite,%Susp%,%ViATcIni%,Configuration,Suspend
	IniWrite,%GlobalTogg%,%ViATcIni%,Configuration,GlobalTogg
	IniWrite,%GlobalSusp%,%ViATcIni%,Configuration,GlobalSusp
	IniWrite,%StartUp%,%ViATcIni%,Configuration,StartUp
	IniWrite,%Service%,%ViATcIni%,Configuration,Service
	IniWrite,%GroupWarn%,%ViATcIni%,Configuration,GroupWarn
	IniWrite,%TranspHelp%,%ViATcIni%,Configuration,TranspHelp
	GoSub,<ConfigVar>
	;GoSub,<ReloadVIATC>
Return
; <GuiCancel> {{{4
<GuiCancel>:
	Gui,Destroy
	EmptyMem()
Return
; <ListViewDK> {{{4
<ListViewDK>:
	If RegExMatch(A_GuiEvent,"DoubleClick")
	{
		EventInfo := A_EventInfo
		EditItem()
	}
	Tooltip
Return
; <EditItem> {{{4
<EditItem>:
	EditItem()
Return
EditItem()
{
	Global EventInfo,VIATCSetting
	If EventInfo
	{
		LV_GetText(Scope,EventInfo,1)
		LV_GetText(Key,EventInfo,2)
		LV_GetText(Action,EventInfo,3)
		LV_GetText(Info,EventInfo,4)
		If RegExMatch(Scope,"S")
			GuiControl,,Button18,1
		If RegExMatch(Scope,"[G|H]")
			GuiControl,,Button18,0
		If Key
			GuiControl,,Edit4,%Key%
		If Action = ���� 
			Action := "(" . Info . ")"
		If Action = �����ı�
			Action := "{" . Info . "}"
		If Action
			GuiControl,,Edit5,%Action%
	}
}
; <DeleItem> {{{4
<DeleItem>:
	DeleItem()
Return
DeleItem()
{
	Global EventInfo,ViATcIni,MapKey_Arr,VIATCSetting
	;If Not EventInfo
	;{
		ControlGet,Line,List,Count Focused,SysListView321,AHK_ID %VIATCSetting%
		EventInfo := Line
	;}
	If EventInfo
	{
		LV_GetText(Get,EventInfo,1)
		LV_GetText(GetText,EventInfo,2)
		Lv_Delete(EventInfo)
		Key := A_Space . Get . GetText . A_Space
		RegExReplace(MapKey_Arr["Hotkeys"],Key)
		MapKeyDelete(GetText,Get)
		If Get = H
			IniDelete,%ViATcIni%,Hotkey,%GetText%
		If Get = S
			IniDelete,%ViATcIni%,GlobalHotkey,%GetText%
		If Get = G
			IniDelete,%ViATcIni%,GroupKey,%GetText%
	}
}
; <VIMCMD> {{{4
<VIMCMD>:
	VimCMD()
Return
VimCMD()
{
	Global VimAction,ActionInfo_Arr
	Stringsplit,kk,VimAction,%A_Space%
	Gui,New
	Gui,+HwndVIMCMDHwnd
	Gui,Add,ListView,w400 h400 -Multi g<GetVIMCMD>,���|����|˵��
	Lv_delete()
	Lv_modifycol(1,40)
	Lv_modifycol(2,110)
	Lv_modifycol(3,420)
	Loop,%kk0%
	{
		key := kk%A_Index%
		Info := ActionInfo_Arr[key]
		LV_ADD(vis,A_Index-1,key,info)
	}
	kk := kk%0% - 1
	lv_delete(1)
	Gui, Add, Button, x280 y420 w60 h24 Default g<VIMCMDB1>, &OK
	Gui, Add, Button, x350 y420 w60 h24 g<Cancel>, &Cancel
	Gui,Show,,VIATCĬ�϶���
}
<VIMCMDB1>:
	ControlGet,EventInfo,List, Count Focused,SysListView321,ahk_id %VIMCMDHwnd%
	lv_gettext(actiontxt,EventInfo,2)
	ControlSetText,edit5,%actiontxt%,AHK_ID %VIATCSetting%
	Gui,Destroy
	EmptyMem()
	Winactivate,AHK_ID %VIATCSetting%
Return
<GetVIMCMD>:
	lv_gettext(actiontxt,A_EventInfo,2)
	ControlSetText,edit5,%actiontxt%,AHK_ID %VIATCSetting%
	Gui,Destroy
	EmptyMem()
	Winactivate,AHK_ID %VIATCSetting%
Return
; <TCCMD> {{{4
; ��ȡTCĬ��������������
<TCCMD>:
	tccmd()
Return
tccmd()
{
	Global VIATCSetting,TCEXE
	Ifwinexist,AHK_CLASS TTOTAL_CMD
		Winactivate,AHK_CLASS TTOTAL_CMD
	Else
	{
		Run,%TCEXE%
		WinWait,AHK_CLASS TTOTAL_CMD,1
		Winactivate,AHK_CLASS TTOTAL_CMD
	}
	Cli := ClipboardAll
	Clipboard := 
	Postmessage 1075, 2924, 0, , ahk_class TTOTAL_CMD
	Clipwait,0.5
	Loop
	{
		If Clipboard
			Break
		Else
		Ifwinexist,ahk_class TCmdSelForm
			Clipwait,0.5
		Else
			Break
	}
	If Clipboard
	{
		actiontxt := Clipboard
		actiontxt := Regexreplace(actiontxt,"^cm_","<") . ">"
	}
	Else
		actiontxt :=
	Clipboard := cli
	If actiontxt
	GuiControl,text,edit5,%actiontxt%
	Winactivate,AHK_ID %VIATCSetting%
}
; <RunFIle> {{{4
; ����ĳ���� 
<RunFile>:
	SelectFile()
Return
SelectFile()
{
	Global VIATCSetting
	Fileselectfile,outvar,,,VIATC����
	If outvar
		outvar := "(" . outvar . ")"
	Winactivate,AHK_ID %VIATCSetting%
	GuiControl,text,edit5,%outvar%
}
; <SendString> {{{4
; �����ַ��� 
<SendString>:
	GetSendString()
Return
GetSendString()
{
	Global VIATCSetting,VIATCSettingString
	Gui,New
	Gui,+Owner%VIATCSetting% ;+hwndVIATCSettingString
	Gui,Add,Edit,w500 h20 
	Gui,Add,Button,x390 y30 h20 g<GetSendStringEnter> Default,ȷ��(&O)
	Gui,Add,Button,x457 y30 h20 g<GetSendStringCancel>,ȡ��(&C)
	Gui,Show,,VIATC�ַ���
}
<GetSendStringEnter>:
	GuiControlGet,txt4,,Edit1 ;,ahk_id %VIATCSettingString%
	if txt4
		txt4 := "{" . txt4 . "}"
	;Control,,%txt4%,edit5,AHK_CLASS %VIATCSetting%
	ControlSetText,edit5,%txt4%,AHK_ID %VIATCSetting%
	GUi,Destroy
	EmptyMem()
Return
<GetSendStringCancel>:
	GUi,Destroy
	EmptyMem()
	Winactivate,AHK_ID %VIATCSetting%
Return
; <GuiTCEXE> {{{4
<GuiTCEXE>:
	GuiTCEXE()
return
GuiTCExe()
{
	Global TCEXE,VIATCSetting
	Fileselectfile,TCEXE,3,TOTALCMD.EXE,ѡ��TOTALCMD.EXE,totalcmd.exe
	If ErrorLevel
		Return
	Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,InstallDir,%TCEXE%
	GuiControl,text,Edit6,%TCEXE%
}
; <GuiTCIni> {{{4
<GuiTCIni>:
	GuiTCIni()
return
GuiTCIni()
{
	Global TCINI,VIATCSetting
	Fileselectfile,TCINI,3,,ѡ�������ļ���Ĭ��ΪWINCMD.INI,*.ini
	If ErrorLevel 
		Return
	Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,IniFileName,%TCINI%
	GuiControl,text,Edit7,%TCINI%
}
; <CheckGorH> {{{4
; ��鵱ǰ�ȼ��Ƿ�Ϊ��ϼ�
<CheckGorH>:
	CheckGorH()
	Tooltip
Return
CheckGorH()
{
	Global ViATcSetting
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	If Key
		If Not RegExMatch(Key,"(^.$|^<[^<>]*>.$|^<[^<>]*>$|^<[^<>*]><[^<>*]>$)")
			GuiControl,Disable,Button18
		Else
			GuiControl,Enable,Button18
	Else
		GuiControl,Enable,Button18
}
; <CheckKey> {{{4
; ��鲢Ӧ�ã�ӳ�䣩��
<CheckKey>:
	CheckKey()
Return
CheckKey()
{
	Global VIATCSetting,ViATcIni,MapKey_Arr,ExecFile_Arr,SendText_Arr,ActionInfo_Arr
	GuiControlGet,Scope,,Button18,AHK_CLASS %ViATcSetting%
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	GuiControlGet,Action,,Edit5,AHK_CLASS %ViATcSetting%
	If Scope
		Scope := "S"
	Else
		Scope := "H"
	If Not RegExMatch(Key,"(^.$|^<[^<>]*>.$|^<[^<>]*>$|^<[^<>*]><[^<>*]>$)")
	{
		Scope := "G"
		GuiControl,,Button18,0
	}
	If Action And Key
	{
		If RegExMatch(Scope,"i)S")
		{
			If MapKeyAdd(Key,Action,Scope)
				Iniwrite,%Action%,%ViatcIni%,GlobalHotkey,%Key%
			Else
			{
				GuiControlGet,VarPos,Pos,Edit4
				Tooltip,ӳ��ʧ��,%VarPosX%,%VarPosY%
				Sleep,2000
				Tooltip
				Return
			}
		}
		If RegExMatch(Scope,"i)H")
		{
			If MapKeyAdd(Key,Action,Scope)
				Iniwrite,%Action%,%ViatcIni%,Hotkey,%Key%
			Else
			{
				GuiControlGet,VarPos,Pos,Edit4
				Tooltip,ӳ��ʧ��,%VarPosX%,%VarPosY%
				Sleep,2000
				Tooltip
				Return
			}
		}
		If RegExMatch(Scope,"i)G")
		{
			If MapKeyAdd(Key,Action,Scope)
				Iniwrite,%Action%,%ViatcIni%,GroupKey,%Key%
			Else
			{
				GuiControlGet,VarPos,Pos,Edit4
				Tooltip,ӳ��ʧ��,%VarPosX%,%VarPosY%
				Sleep,2000
				Tooltip
				Return
			}
		}
		Loop,% LV_GetCount()
		{
			LV_GetText(GetScope,A_Index,1)
			LV_GetText(GetKey,A_Index,2)
			LV_GetText(GetAction,A_Index,3)
			Scope_M := "i)" . Scope
			Key_M := "i)" . RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
			Action_M := "i)" . RegExReplace(Action,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
			If RegExMatch(GetScope,Scope_M) AND RegExMatch(GetKey,Key_M) AND RegExMatch(GetAction,Action_M)
				Return
			If RegExMatch(GetScope,Scope_M) AND RegExMatch(GetKey,Key_M) AND Not RegExMatch(GetAction,Action_M)
			{
				Info := ActionInfo_Arr[Action]
				If RegExMatch(Action,"^\(.*\)$")
				{
					Action := "����"
					Key_T := Scope . TransHotkey(Key)
					Info := ExecFile_Arr[key_T]
				}
				If RegExMatch(Action,"^\{.*\}$")
				{
					Action := "�����ı�"
					Key_T := Scope . TransHotkey(Key)
					Info := SendText_Arr[key_T]
				}
				Lv_Modify(A_Index,vis,Scope,Key,Action,Info)
				Return
			}
		}
		Info := ActionInfo_Arr[Action]
		If RegExMatch(Action,"^\(.*\)$")
		{
			Action := "����"
			Key_T := Scope . TransHotkey(Key)
			Info := ExecFile_Arr[key_T]
		}
		If RegExMatch(Action,"^\{.*\}$")
		{
			Action := "�����ı�"
			Key_T := Scope . TransHotkey(Key)
			Info := SendText_Arr[key_T]
		}
		LV_Add(vis,Scope,Key,Action,Info)
	}
	Else
	{
		GuiControlGet,VarPos,Pos,Edit4
		Tooltip,��ݼ�����Ϊ��,%VarPosX%,%VarPosY%
		Sleep,2000
		Tooltip
	}
}
; <ChangeTab> {{{4
<ChangeTab>:
	ChangeTab()
Return
ChangeTab()
{
	If RegExMatch(A_GuiControl,"U")
		GuiControl,choose,SysTabControl321,1
	If RegExMatch(A_GuiControl,"P")
		GuiControl,choose,SysTabControl321,2
	If RegExMatch(A_GuiControl,"M")
		GuiControl,choose,SysTabControl321,3
}
; <TestTH> {{{4
<TestTH>:
	TH()
Return
TH() ;Lang
{
	GuiControlGet,Scope,,Button18,AHK_CLASS %ViATcSetting%
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	If Scope
		KeyType := "ȫ�ּ�"
	Else
		KeyType := "��ݼ�"
	If Not RegExMatch(Key,"(^.$|^<[^<>]*>.$|^<[^<>]*>$|^<[^<>*]><[^<>*]>$)")
		KeyType := "��ϼ�"
	Msg :=  KeyType . "`n"
	Key1 := TransHotkey(Key,"First")
	Msg .= "��1����:" . Key1 . "`n"
	Key2 := TransHotkey(Key,"ALL")
	KeyT := SubStr(Key2,Strlen(key1)+1)
	Stringsplit,T,KeyT
	N := 2
	Loop,%T0%
	{
		Msg .= "��" . N . "����:" . T%A_index% . "`n"
		N++
	}
	GuiControlGet,VarPos,Pos,Edit4
	VarPosY := VarPosY - VarPosH - ( T0 * 17)
	Tooltip,%Msg%,%VarPosX%,%VarPosY%
	Settimer,<RemoveTT>,50
}
<RemoveTT>:
	Ifwinnotactive,AHK_ID %ViATcSetting%
	{
		SetTimer,<RemoveTT>, Off
		ToolTip
	}
return
; Help() {{{3
Help()
{
	Global TranspHelp,HelpInfo_Arr
	Gui,New
	Gui,+HwndVIATCHELP
	Gui,Font,s8,Arial Bold
	Gui,Add,Text,x12 y10 w30 h18 center Border g<ShowHelp>,Esc
	Gui,Add,Text,x52 y10 w26 h18 center Border g<ShowHelp>,F1
	Gui,Add,Text,x80 y10 w26 h18 center Border g<ShowHelp>,F2
	Gui,Add,Text,x108 y10 w26 h18 center Border g<ShowHelp>,F3
	Gui,Add,Text,x136 y10 w26 h18 center Border g<ShowHelp>,F4
	Gui,Add,Text,x164 y10 w26 h18 center Border g<ShowHelp>,F5
	Gui,Add,Text,x192 y10 w26 h18 center Border g<ShowHelp>,F6
	Gui,Add,Text,x220 y10 w26 h18 center Border g<ShowHelp>,F7
	Gui,Add,Text,x248 y10 w26 h18 center Border g<ShowHelp>,F8
	Gui,Add,Text,x276 y10 w26 h18 center Border g<ShowHelp>,F9
	Gui,Add,Text,x304 y10 w26 h18 center Border g<ShowHelp>,F10
	Gui,Add,Text,x332 y10 w26 h18 center Border g<ShowHelp>,F11
	Gui,Add,Text,x360 y10 w26 h18 center Border g<ShowHelp>,F12
	Gui,Add,Text,x12 y35 w22 h18 center Border g<ShowHelp>,``~
	Gui,Add,Text,x36 y35 w22 h18 center Border g<ShowHelp>,1!
	Gui,Add,Text,x60 y35 w22 h18 center Border g<ShowHelp>,2@
	Gui,Add,Text,x84 y35 w22 h18 center Border g<ShowHelp>,3#
	Gui,Add,Text,x108 y35 w22 h18 center Border g<ShowHelp>,4$
	Gui,Add,Text,x132 y35 w22 h18 center Border g<ShowHelp>,5`%
	Gui,Add,Text,x156 y35 w22 h18 center Border g<ShowHelp>,6^
	Gui,Add,Text,x180 y35 w22 h18 center Border g<ShowHelp>,7&
	Gui,Add,Text,x204 y35 w22 h18 center Border g<ShowHelp>,8*
	Gui,Add,Text,x228 y35 w22 h18 center Border g<ShowHelp>,9(
	Gui,Add,Text,x252 y35 w22 h18 center Border g<ShowHelp>,0)
	Gui,Add,Text,x276 y35 w22 h18 center Border g<ShowHelp>,-_
	Gui,Add,Text,x300 y35 w22 h18 center Border g<ShowHelp>,=+
	Gui,Add,Text,x324 y35 w62 h18 center Border g<ShowHelp>,Backspace
	Gui,Add,Text,x12 y55 w40 h18 center Border g<ShowHelp>,Tab
	Gui,Add,Text,x54 y55 w22 h18 center Border g<ShowHelp>,Q
	Gui,Add,Text,x78 y55 w22 h18 center Border g<ShowHelp>,W
	Gui,Add,Text,x102 y55 w22 h18 center Border g<ShowHelp>,E
	Gui,Add,Text,x126 y55 w22 h18 center Border g<ShowHelp>,R
	Gui,Add,Text,x150 y55 w22 h18 center Border g<ShowHelp>,T
	Gui,Add,Text,x174 y55 w22 h18 center Border g<ShowHelp>,Y
	Gui,Add,Text,x198 y55 w22 h18 center Border g<ShowHelp>,U
	Gui,Add,Text,x222 y55 w22 h18 center Border g<ShowHelp>,I
	Gui,Add,Text,x246 y55 w22 h18 center Border g<ShowHelp>,O
	Gui,Add,Text,x270 y55 w22 h18 center Border g<ShowHelp>,P
	Gui,Add,Text,x294 y55 w22 h18 center Border g<ShowHelp>,[{
	Gui,Add,Text,x318 y55 w22 h18 center Border g<ShowHelp>,]}
	Gui,Add,Text,x342 y55 w44 h18 center Border g<ShowHelp>,\|
	Gui,Add,Text,x12 y75 w60 h18 center Border g<ShowHelp>,CapsLock
	Gui,Add,Text,x74 y75 w22 h18 center Border g<ShowHelp>,A
	Gui,Add,Text,x98 y75 w22 h18 center Border g<ShowHelp>,S
	Gui,Add,Text,x122 y75 w22 h18 center Border g<ShowHelp>,D
	Gui,Add,Text,x146 y75 w22 h18 center Border g<ShowHelp>,F
	Gui,Add,Text,x170 y75 w22 h18 center Border g<ShowHelp>,G
	Gui,Add,Text,x194 y75 w22 h18 center Border g<ShowHelp>,H
	Gui,Add,Text,x218 y75 w22 h18 center Border g<ShowHelp>,J
	Gui,Add,Text,x242 y75 w22 h18 center Border g<ShowHelp>,K
	Gui,Add,Text,x266 y75 w22 h18 center Border g<ShowHelp>,L
	Gui,Add,Text,x290 y75 w22 h18 center Border g<ShowHelp>,`;:
	Gui,Add,Text,x314 y75 w22 h18 center Border g<ShowHelp>,'`"
	Gui,Add,Text,x338 y75 w48 h18 center Border g<ShowHelp>,Enter
	Gui,Add,Text,x12 y95 w70 h18 center Border g<ShowHelp>,LShift
	Gui,Add,Text,x84 y95 w22 h18 center Border g<ShowHelp>,Z
	Gui,Add,Text,x108 y95 w22 h18 center Border g<ShowHelp>,X
	Gui,Add,Text,x132 y95 w22 h18 center Border g<ShowHelp>,C
	Gui,Add,Text,x156 y95 w22 h18 center Border g<ShowHelp>,V
	Gui,Add,Text,x180 y95 w22 h18 center Border g<ShowHelp>,B
	Gui,Add,Text,x204 y95 w22 h18 center Border g<ShowHelp>,N
	Gui,Add,Text,x228 y95 w22 h18 center Border g<ShowHelp>,M
	Gui,Add,Text,x252 y95 w22 h18 center Border g<ShowHelp>,`,<
	Gui,Add,Text,x276 y95 w22 h18 center Border g<ShowHelp>,.>
	Gui,Add,Text,x300 y95 w22 h18 center Border g<ShowHelp>,/?
	Gui,Add,Text,x324 y95 w62 h18 center Border g<ShowHelp>,RShift
	Gui,Add,Text,x12 y115 w40 h18 center Border g<ShowHelp>,LCtrl
	Gui,Add,Text,x54 y115 w40 h18 center Border g<ShowHelp>,LWin
	Gui,Add,Text,x96 y115 w40 h18 center Border g<ShowHelp>,LAlt
	Gui,Add,Text,x138 y115 w122 h18 center Border g<ShowHelp>,Space
	Gui,Add,Text,x262 y115 w40 h18 center Border g<ShowHelp>,RAlt
	Gui,Add,Text,x304 y115 w40 h18 center Border g<ShowHelp>,Apps
	Gui,Add,Text,x346 y115 w40 h18 center Border g<ShowHelp>,RCtrl
	Gui,Add,Groupbox,x12 y135 w374 h40 
	Gui,Add,Button,x20 y146 w58 gIntro,����(&I)
	Gui,Add,Button,x80 y146 w58 gFunck,���ܼ�(&K)
	Gui,Add,Button,x140 y146 w58 gGroupk,��ϼ�(&G)
	Gui,Add,Button,x200 y146 w58 gCmdl,������(&C)
	Gui,Add,Button,x260 y146 w58 gAction,����(&J)
	Gui,Add,Button,x320 y146 w58 gAbout,����(&A)
	Intro := HelpInfo_Arr["Intro"]  ;�����Ӧ�İ����鿴����
	Gui,Add,Edit,x12 y180 w374 h200 +ReadOnly,%Intro%
	Gui,Show,w400 h400,VIATC ����
	If TranspHelp
	WinSet,Transparent,220,ahk_id %VIATCHELP%
	Return
}
Intro:
	var := HelpInfo_Arr["Intro"]
	GuiControl,Text,Edit1,%var%
Return
funck:
	var := HelpInfo_Arr["funck"]
	GuiControl,Text,Edit1,%var%
Return
Groupk:
	var := HelpInfo_Arr["Groupk"]
	GuiControl,Text,Edit1,%var%
Return
cmdl:
	var := HelpInfo_Arr["cmdl"]
	GuiControl,Text,Edit1,%var%
Return
action:
	var := HelpInfo_Arr["action"]
	GuiControl,Text,Edit1,%var%
Return
about:
	var := HelpInfo_Arr["about"]
	GuiControl,Text,Edit1,%var%
Return
<ShowHelp>:
	ShowHelp(A_GuiControl)
Return
ShowHelp(control)
{
	Global HelpInfo_Arr
	Var := HelpInfo_Arr[Control]
	;ControlSetText,Edit1,%var%,AHK_ID %VIATCHELP%
	GuiControl,Text,Edit1,%var%
}
; SetArrays {{{1
; SetHelpInfo() {{{2
SetHelpInfo()
{
	Global HelpInfo_arr
	HelpInfo_arr["Esc"] :="Esc >>��λ����״̬"
	HelpInfo_arr["F1"] :="F1 >>��ӳ��`n��TC����"
	HelpInfo_arr["F2"] :="F2 >>��ӳ��`nˢ����Դ����"
	HelpInfo_arr["F3"] :="F3 >>��ӳ��`n�鿴�ļ�"
	HelpInfo_arr["F4"] :="F4 >>��ӳ��`n�༭�ļ�"
	HelpInfo_arr["F5"] :="F5 >>��ӳ��`n�����ļ�"
	HelpInfo_arr["F6"] :="F6 >>��ӳ��`n���������ƶ��ļ�"
	HelpInfo_arr["F7"] :="F7 >>��ӳ��`n�½��ļ���"
	HelpInfo_arr["F8"] :="F8 >>��ӳ��`nɾ���ļ���������վ��ֱ��ɾ���������þ�����"
	HelpInfo_arr["F9"] :="F9 >>��ӳ��`n����Դ���ڵĲ˵� (�����)"
	HelpInfo_arr["F10"] :="F10 >>��ӳ��`n�������˵����˳��˵�"
	HelpInfo_arr["F11"] :="F11 >>��ӳ��"
	HelpInfo_arr["F12"] :="F12 >>��ӳ��"
	HelpInfo_arr["``~"] :="`` >>��ӳ��`n~ >>��ӳ��"
	HelpInfo_arr["1!"] :="1 >>����1�����ڼ���`n! >>��ӳ��"
	HelpInfo_arr["2@"] :="2 >>����2�����ڼ���`n@ >>��ӳ��"
	HelpInfo_arr["3#"] :="3 >>����3�����ڼ���`n# >>��ӳ��"
	HelpInfo_arr["4$"] :="4 >>����4�����ڼ���`n$ >>��ӳ��"
	HelpInfo_arr["5%"] :="5 >>����5�����ڼ���`n! >>��ӳ��"
	HelpInfo_arr["6^"] :="6 >>����6�����ڼ���`n^ >>��ӳ��"
	HelpInfo_arr["7&"] :="7 >>����7�����ڼ���`n& >>��ӳ��"
	HelpInfo_arr["8*"] :="8 >>����8�����ڼ���`n* >>��ӳ��"
	HelpInfo_arr["9("] :="9 >>����9�����ڼ���`n( >>��ӳ��"
	HelpInfo_arr["0)"] :="0 >>����0�����ڼ���`n) >>��ӳ��"
	HelpInfo_arr["-_"] :="- >>�л������ļ��������״̬`n_ >>��ӳ��"
	HelpInfo_arr["=+"] :="= >>Ŀ�� = ��Դ`n+ >>��ӳ��"
	HelpInfo_arr["Backspace"] :="Backspace >>��ӳ��`n������һ���ļ��л����ڱ༭״̬��ɾ������"
	HelpInfo_arr["Tab"] :="Tab >>��ӳ��`n�л�����"
	HelpInfo_arr["Q"] :="q >>���ٲ鿴����`nQ >>ʹ��Ĭ�������������ǰ�ļ���/�ļ�����"
	HelpInfo_arr["W"] :="w >>�༭�ļ���ע`nW >>��ӳ��"
	HelpInfo_arr["E"] :="e >>��ʾ�Ҽ���ݲ˵�`nE >>�ڵ�ǰĿ¼����CMD.EXE"
	HelpInfo_arr["R"] :="r >>�������ļ�`nR >>�����������ļ�"
	HelpInfo_arr["T"] :="t >>�½���ǩ`nT >>�ں�̨�½���ǩ"
	HelpInfo_arr["Y"] :="y >>�����ļ���`nY >>�����ļ���������·��"
	HelpInfo_arr["U"] :="u >>����һ��Ŀ¼`nU >>���ظ�Ŀ¼"
	HelpInfo_arr["I"] :="i >>�����µ��ļ���`nI >>��ӳ��"
	HelpInfo_arr["O"] :="o >>������������б�`nO >>���Ҳ��������б�"
	HelpInfo_arr["P"] :="p >>ѹ���ļ�/�ļ���`nP >>��ѹ��"
	HelpInfo_arr["[{"] :="[ >>ѡ���ļ�����ͬ���ļ�`n{ >>��ѡ���ļ�����ͬ���ļ�"
	HelpInfo_arr["]}"] :="] >>ѡ����չ����ͬ���ļ�`n} >>��ѡ����չ����ͬ���ļ�"
	HelpInfo_arr["\|"] :="\ >>��ѡ�����ļ����ļ��� `n| >>ȡ������ѡ��"
	HelpInfo_arr["CapsLock"] :="CapsLock ��ӳ��"
	HelpInfo_arr["A"] :="a >>��������`n A >>��ӳ��"
	HelpInfo_arr["S"] :="s >>�������ȼ�`nS >>��ӳ��`nsn >>��Դ����: ���ļ�������`nse >>��Դ����: ����չ������`nss >>��Դ����: ����С����`nst >>��Դ����: ������ʱ������`nsr >>��Դ����: ��������`ns1 >>��Դ����: ���� 1 ������`ns2 >>��Դ����: ����2 ������`ns3 >>��Դ����: ���� 3 ������`ns4 >>��Դ����: ���� 4 ������`ns5 >>��Դ����: ���� 5 ������`ns6 >>��Դ����: ���� 6 ������`ns7 >>��Դ����: ���� 7 ������`ns8 >>��Դ����: ���� 8 ������`ns9 >>��Դ����: ���� 9 ������ >>"
	HelpInfo_arr["D"] :="d >>�����ļ���`nD >>�������ļ���"
	HelpInfo_arr["F"] :="f >>���·�ҳ���൱��PageDown`nF >>��ӳ��"
	HelpInfo_arr["G"] :="g >>��ǩ����ϼ�`nG >>�����ƶ����ļ��б�δβ`ngg >>ת���ļ��б�����`ngn >>��һ����ǩ(Ctrl+Tab)`ngp >>��һ����ǩ(Ctrl+Shift+Tab)`nga >>�ر����б�ǩ`ngc >>�رյ�ǰ��ǩ`ngt >>�½���ǩ(���򿪹�괦���ļ���)`ngb >>�½���ǩ(����һ���ڴ��ļ���)`nge >>�������Ҵ���`ngw >>�������Ҵ��ڼ����ǩ`ngg >>ת���ļ��б�����`ng1 >>��Դ����: �����ǩ 1`ng2 >>��Դ����: �����ǩ 2`ng3 >>��Դ����: �����ǩ 3`ng4 >>��Դ����: �����ǩ 4`ng5 >>��Դ����: �����ǩ 5`ng6 >>��Դ����: �����ǩ 6`ng7 >>��Դ����: �����ǩ 7`ng8 >>��Դ����: �����ǩ 8`ng9 >>��Դ����: �����ǩ 9`ng0 >>ת�����һ����ǩ"
	HelpInfo_arr["H"] :="h >>�����ƶ�Num��`nH >>����"
	HelpInfo_arr["J"] :="j >>�����ƶ�Num��`nJ >>����ѡ��Num���ļ����У�"
	HelpInfo_arr["K"] :="k >>�����ƶ�Num��`nK >>����ѡ��Num���ļ����У�"
	HelpInfo_arr["L"] :="l >>�����ƶ�Num��`nL >>ǰ��"
	HelpInfo_arr["`;:"] :="; >>����λ��������`n: >>����VIATC������ģʽ(��:)"
	HelpInfo_arr["'"""] :="' >>��ʾ���б�ǣ������m���ı�ǹ��ܲ�������VIM����`n"" >>��ӳ��"
	HelpInfo_arr["Enter"] :="Enter >>�س�"
	HelpInfo_arr["LShift"] :="Lshift >>��shift����Ҳ������Shift����"
	HelpInfo_arr["Z"] :="z >>��������ϼ�`nZ >>��ӳ��`nzz >>���ڷָ���λ�� 50%`nzx >>���ڷָ���λ�� 100%`nzi >>��������`nzo >>��������`nzt >>TC���ڱ�����ǰ`nzn >>��С�� Total Commander`nzm >>��� Total Commander`nzr >>�ָ�������С`nzv >>����/��������`nzs >>TC͸��`nzf >>���TC`nzq >>�˳�TC`nza >>����TC"
	HelpInfo_arr["X"] :="x >>ɾ���ļ�(��)`nX >>ǿ��ɾ���ļ�(��)"
	HelpInfo_arr["C"] :="c >>�������ϼ�`nC >>��ӳ��`ncl >>ɾ������ļ�����ʷ`ncr >>ɾ���Ҳ��ļ�����ʷ`ncc >>ɾ����������ʷ"
	HelpInfo_arr["V"] :="v >>��ʾ��ͼ�˵�(��a-z����)`nV >>��ʾ����ϼ�<Shift>vb >>��ʾ/����: ������`n<Shift>vd >>��ʾ/����: ��������ť`n<Shift>vo >>��ʾ/����: ������������ť��`n<Shift>vr >>��ʾ/����: �������б�`n<Shift>vc >>��ʾ/����: ��ǰ�ļ���`n<Shift>vt >>��ʾ/����: �����Ʊ��`n<Shift>vs >>��ʾ/����: ״̬��`n<Shift>vn >>��ʾ/����: ������`n<Shift>vf >>��ʾ/����: ���ܼ���ť`n<Shift>vw >>��ʾ/����: �ļ��б�ǩ`n<Shift>ve >>����ڲ�����"
	HelpInfo_arr["B"] :="b >>���Ϸ�ҳ���൱��PageUp`nB >>��ӳ��"
	HelpInfo_arr["N"] :="n >>��ʾ�ļ�����ʷ(��a-z����)`nN >>��ӳ��"
	HelpInfo_arr["M"] :="m >>��ǹ��ܣ���ǵ�ǰ�ļ���`nM >>��ӳ��`n��ǹ��ܣ�������VIM�е�m����������m�������л���ʾm��������״̬�������������ַ����ɱ��浱ǰ�ļ���·������ǡ�����������״̬������ma���ٰ���'�������б�ǣ���ʱ����a������ת����Ӧ��ǵ��ļ���"
	HelpInfo_arr[",<"] :=", >>��ʾ������ʷ(��a-z����)`n< >>��ӳ��"
	HelpInfo_arr[".>"] :=". >>�ظ���һ�ζ���`n> >>��ӳ��`n�ظ���һ�εĶ��������統������10j�����ƶ�10�У������������ƶ�10�У������ٰ�10jֻ��Ҫ��һ��.���ɡ�����gn�ƶ�����һ����ǩ���ٴ��ƶ��Ļ���Ҳֻ��Ҫ����."
	HelpInfo_arr["/?"] :="/ >>ʹ�ÿ�������`n? >>ʹ�������ļ�����(��ȫ)"
	HelpInfo_arr["RShift"] :="Rshift >>��shift����Ҳ������Shift����"
	HelpInfo_arr["LCtrl"] :="Lctrl >>��ctrl����Ҳ������control��ctrl����"
	HelpInfo_arr["LWin"] :="LWin >>Win�� ����ahk�����ƣ�win��������lwin������"
	HelpInfo_arr["LAlt"] :="LAlt >>��Alt����Ҳ������alt����"
	HelpInfo_arr["Space"] :="Space >>�ո���ӳ��"
	HelpInfo_arr["RAlt"] :="RAlt >>��Alt����Ҳ������alt����"
	HelpInfo_arr["Apps"] :="Apps >>�������Ĳ˵����Ҽ��˵���"
	HelpInfo_arr["RCtrl"] :="Rctrl >>��ctrl����Ҳ������control��ctrl����"
	HelpInfo_arr["Intro"] :="   ��Vim��ݼ���ϵ��TC��ϣ���TC��������ݡ�������������ΰ���������ɴ󲿷��������Ҫ��ɵ�����`n     ���������ʹ�ù�Vim��������ʹ��TC����ô���ϲ��ViATc`n     �������ʹ��TC�����־������ĵ�������Ը����ٵز�������ô�������ViATc`n     �Ѹ��ӵĲ���������ֻ���ڼ������û��������Ǳ�дViATc�ĳ��ԡ�`nViATc������:`n     ��TC����Vim��ģʽ��h,j,k,l�ƶ��͸��ࣻ���£���������ģʽ`n      ����Ҫʹ��ʱ��Alt+~(���޸ģ���������VIATC�������ܣ����߸ɴ��˳�ViATc����TC��ȫ��Ӱ�졣 `n     ����һ����ݼ�������TC�Դ��Ŀ�ݼ���ͻ����ɫ��`n     ��פΪ������ͼ�꣬˫��������ͼ�꣬����Win+E����TC`n     ����ƶ�����ϼ���͸��TC������TC�����и��࡭��`n`n�ȴ����Ľ��飬һ����ViATc��ø��Ӻ��á�`n`n0.5 ����:`n++(����)���Զ������а���`n++(����)�������˿��Դ����ڲ�����(Action)֮�⣬���������г�������ַ���`n++(����)֧��TC�򿪺�ʹ��VIMģʽ`n++(����)֧�ֹ�����ӻ�ɾ����������`n++(����)�ļ�����ʷ����������ʷ��ʹ��a-z����`n++(����)�����ظ���һ�ζ����Ĺ��ܣ�����.����ʡ�ģ�`n--(����)��ǿ�ļ�ģ�幦��`n--(����)ȥ������/�ָ�ѡ���б���`n--(����)ȥ�������õ�ѡ����`n--(����)ȥ�������õ������й��ܣ����ð������棩"
	HelpInfo_arr["Funck"] :="���ܼ�>>���ΰ�������ʵ�ֲ���`n      ���ܼ����������ͷ֣��ɷ�Ϊ����Num0-Num9���ַ�a-z�����ַ��ȡ�Ĭ������£���������ʱ�����������������ֻ���¼���ֵĴ�С��Ȼ��ͨ�����������β����ļ���ʵ���ظ����������簴��10j��ʵ�ֵ��������ƶ�10��,����10K����������ѡ��10�У������ļ������������⣬����ֻ�����б����ƶ�(hjkl/JK)�ſ���ʹ�ö�β�����`n��Ҫ��  ��VIATC�б�﹦�ܼ������ΰ��������Դ�control,alt,win,shift�������η����ַ���ɣ�����ÿ���ַ���ֻ�ܸ�һ�����η�`n<LWin>e (��Ч������ʹ��LWin������Win)`n<ctrl><F12> (��Ч����ʱ�ڶ���<>�е��ַ��ᱻ���ͳ���ͨ�ַ�)`n<ctrl><shift>a (��Ч�������������η���Ҫ��)`n      ����ÿ��������ʵ��ʲô���ܣ���������ļ��̣����ÿ����������ϸ��Ϣ��"
	HelpInfo_arr["GroupK"] :="��ϼ�>>�����λ���������ʵ�ֲ���`n    ��VIM���ƣ���ϼ����Էǳ�����ӳ��ĳ�����ܣ�ͬʱ�������ڼ��̵�26����ĸ���빦�ܼ���ͬ����ϼ������ɶ���ַ���ɡ�������һ��Ҫע�⣬��ϼ��ĵ�һ������ֻ�ܴ����һ�������η�(ctrl/lwin/shift/alt)���������еİ����������Դ����η�`n����:`n<ctrl>ab (��Ч������ctrl+a���ٰ�b��ʵ��ĳ������)`n<ctrl>a<ctrl>b (��Ч����һ�������������һ�������η����ڶ����������ܴ�)`nVIATCĬ�ϴ���������ϼ�����ϸ�������ļ���z,c,v,g,s"
	HelpInfo_arr["cmdl"] :="������>>`nVIATC��������֧����д:h :s :r :m :sm :e���ֱ���`n:help ��ʾ������Ϣ`n:Setting VIATC���ý���`n:reload ��������VIATC`n:map ��ʾ����ӳ���ȼ�`n�����������������:map ����ʾ�����Զ����ȼ���`n����������:map key action������key����Ҫӳ����ȼ�����������ϼ���Ҳ�����ǹ��ܼ���action�������Ҫִ�еĶ�������������ʺϵ��龰����ʱ��Ҫĳ�����ܵ�ӳ�䣬ͬʱ�ر�VIATC�󲻻ᱣ�档���Ҫ��������ӳ�䣬����Դ�VIATC���ý������ӳ�䣬����ֱ�ӱ༭λ��TC��Ŀ¼�µ������ļ�VIATC.ini��`n:smap ��mapһ��������ӳ�����ȫ���ȼ������Ҳ�֧��ӳ����ϼ�`n:edit ֱ�ӱ༭ViATc.ini�ļ�"
	HelpInfo_arr["action"] :="����>>`n��VIATC�У����еĲ������������Ϊһ������(action)�����еĶ������������ý�����ȼ�ӳ��������ҵ���������Ϊ���ࣺ`n1��VIATC�Դ���������VIATC�ṩ��һЩTC��ǿ���ܣ�������ӷ���ز���TC��`n2��TC�ڲ�������Ҳ����TCĬ����cm_��ͷ���ڲ������cm_SrcComments�ȡ�`n3������ĳ��������ĳ���ļ�������ȽϷ��㳣����Ҫ���TC���еĳ������Ҫ�༭���ļ�����Ȼ��TC�ڲ�Ҳ�����ƵĹ��ܣ�����������ö����Ȼ֪���ĸ��ȽϺ���:)��`n4�������ַ��������Ҫ������TC������ĳ�����֣���������ϼ�ӳ�䵽�����ַ����Ķ��������㰡����`n�������ֶ����У�1��2��������<��>��ͷ��β��,3������(��)��ͷ��β�ģ�4������{��}��ͷ��β�ġ�`n����`n:map <shift>a <TransParent> (ӳ��shift a��Ϊ��TC͸���Ķ���)`n:map ggg (E:\google\chrome.exe) (ӳ��ggg��ϼ�Ϊ����chrome.exe����`n:map abcd {cd E:\ {enter}} (ӳ��abcd��ϼ�Ϊ����cd E:\ {enter}��TC���������У�����{enter}���Ǳ�VIATC���ͳɰ��»س���"
	HelpInfo_arr["About"] :="����汾��0.5.1���԰棬��ʲô��������ϵ��linxinhong.sky@gmail.com"
}
; SetGroupInfo() {{{2
; ��ϼ���ʾʱ���õ�
SetGroupInfo()
{
	Global GroupInfo_arr
	GroupInfo_arr["s"] :="sn >>��Դ����: ���ļ�������`nse >>��Դ����: ����չ������`nss >>��Դ����: ����С����`nst >>��Դ����: ������ʱ������`nsr >>��Դ����: ��������`ns1 >>��Դ����: ���� 1 ������`ns2 >>��Դ����: ����2 ������`ns3 >>��Դ����: ���� 3 ������`ns4 >>��Դ����: ���� 4 ������`ns5 >>��Դ����: ���� 5 ������`ns6 >>��Դ����: ���� 6 ������`ns7 >>��Դ����: ���� 7 ������`ns8 >>��Դ����: ���� 8 ������`ns9 >>��Դ����: ���� 9 ������"
	GroupInfo_arr["z"] :="zz >>���ڷָ���λ�� 50%`nzx >>���ڷָ���λ�� 100%(TC 8.0+)`nzi >>��������`nzo >>��������`nzt >>TC���ڱ�����ǰ`nzn >>��С�� Total Commander`nzm >>��� Total Commander`nzr >>�ָ�������С`nzv >>����/��������`nzs >>TC͸��`nzf >>ȫ��TC`nzl >>���TC`nzq >>�˳�TC`nza >>����TC"
	GroupInfo_arr["g"] :="gn >>��һ����ǩ(Ctrl+Tab)`ngp >>��һ����ǩ(Ctrl+Shift+Tab)`nga >>�ر����б�ǩ`ngc >>�رյ�ǰ��ǩ`ngt >>�½���ǩ(���򿪹�괦���ļ���)`ngb >>�½���ǩ(����һ���ڴ��ļ���)`nge >>�������Ҵ���`ngw >>�������Ҵ��ڼ����ǩ`ngg >>����ת���ļ��б�����`ng1 >>��Դ����: �����ǩ 1`ng2 >>��Դ����: �����ǩ 2`ng3 >>��Դ����: �����ǩ 3`ng4 >>��Դ����: �����ǩ 4`ng5 >>��Դ����: �����ǩ 5`ng6 >>��Դ����: �����ǩ 6`ng7 >>��Դ����: �����ǩ 7`ng8 >>��Դ����: �����ǩ 8`ng9 >>��Դ����: �����ǩ 9`ng0 >>ת�����һ����ǩ"
	GroupInfo_arr["Shift & v"] :="<Shift>vb >>��ʾ/����: ������`n<Shift>vd >>��ʾ/����: ��������ť`n<Shift>vo >>��ʾ/����: ������������ť��`n<Shift>vr >>��ʾ/����: �������б�`n<Shift>vc >>��ʾ/����: ��ǰ�ļ���`n<Shift>vt >>��ʾ/����: �����Ʊ��`n<Shift>vs >>��ʾ/����: ״̬��`n<Shift>vn >>��ʾ/����: ������`n<Shift>vf >>��ʾ/����: ���ܼ���ť`n<Shift>vw >>��ʾ/����: �ļ��б�ǩ`n<Shift>ve >>����ڲ�����"
	GroupInfo_arr["c"] :="cl >>ɾ������ļ�����ʷ`ncr >>ɾ���Ҳ��ļ�����ʷ`ncc >>ɾ����������ʷ"
}
; SetVimAction() {{{2
SetVimAction()
{
	Global VimAction
	VimAction := " <help> <Setting> <ToggleTC> <EnableVIM> <QuitTC> <ReloadTC> <QuitVIATC> <ReloadVIATC> <Enter> <singleRepeat> <Esc> <Num0> <Num1> <Num2> <Num3> <Num4> <Num5> <Num6> <Num7> <Num8> <Num9> <Down> <up> <Left> <Right> <DownSelect> <PageUp> <PageDown> <Home> <End> <UpSelect> <ForceDel> <Mark> <ListMark> <Internetsearch> <azHistory> <azCmdHistory> <ListMapKey> <WinMaxLeft> <WinMaxRight> <AlwayOnTop> <GoLastTab> <TransParent> <DeleteLHistory> <DeleteRHistory> <DelCmdHistory> <CreateNewFile> <TCLite> <TCFullScreen> <EditViATCIni>"
}
; SetActionInfo() {{{{2
SetActionInfo()
{
  Global ActionInfo_arr
; ActionInfo_Arr���ڱ��涯��˵��
;Config actions"] :="�����ö���"
  ActionInfo_Arr["<ReLoadVIATC>"] :="����VIATC"
  ActionInfo_Arr["<ReLoadTC>"] :="����TC"
  ActionInfo_Arr["<QuitTC>"] :="�˳�TC"
  ActionInfo_Arr["<QuitViATc>"] :="�˳�ViATc"
  ActionInfo_Arr["<None>"] :="��Ч��"
  ActionInfo_Arr["<Setting>"] :="���ý���"
  ActionInfo_Arr["<FocusCmdLine:>"] := "������ģʽ �������������У�����:��ͷ"
  ActionInfo_Arr["<CreateNewFile>"] := "�ļ�ģ�幦�ܣ��������ļ�����Ŀ¼"
  ActionInfo_Arr["<TCLite>"] := "���TC"
  ActionInfo_Arr["<ExReName>"] := "��ǿ����������ѡ����չ��"
  ActionInfo_Arr["<Help>"] := "VIATC����"
  ActionInfo_Arr["<Setting>"] := "VIATC����"
  ActionInfo_Arr["<ToggleTC>"] :="��TC"
  ActionInfo_Arr["<EnableVIM>"] :="����/����VIMģʽ"
  ActionInfo_Arr["<Enter>"] :="�س�"
  ActionInfo_Arr["<SingleRepeat>"] :="�ظ��ϴεĶ���"
  ActionInfo_Arr["<Esc>"] :="��λ������ESC"
  ActionInfo_Arr["<EditViATCIni>"] :="ֱ�ӱ༭ViATc�����ļ�"
  ActionInfo_Arr["<Num0>"] :="����0"
  ActionInfo_Arr["<Num1>"] :="����1"
  ActionInfo_Arr["<Num2>"] :="����2"
  ActionInfo_Arr["<Num3>"] :="����3"
  ActionInfo_Arr["<Num4>"] :="����4"
  ActionInfo_Arr["<Num5>"] :="����5"
  ActionInfo_Arr["<Num6>"] :="����6"
  ActionInfo_Arr["<Num7>"] :="����7"
  ActionInfo_Arr["<Num8>"] :="����8"
  ActionInfo_Arr["<Num9>"] :="����9"
  ActionInfo_Arr["<Down>"] :="�·���"
  ActionInfo_Arr["<up>"] :="�Ϸ���"
  ActionInfo_Arr["<Left>"] :="����"
  ActionInfo_Arr["<Right>"] :="�ҷ���"
  ActionInfo_Arr["<DownSelect>"] :="����ѡ��"
  ActionInfo_Arr["<UpSelect>"] :="����ѡ��"
  ActionInfo_Arr["<Home>"] :="ת�����У��൱��Home��"
  ActionInfo_Arr["<End>"] :="ת��δ�У��൱��End��"
  ActionInfo_Arr["<PageUp>"] :="���Ϸ�ҳ"
  ActionInfo_Arr["<PageDown>"] :="���·�ҳ"
  ActionInfo_Arr["<ForceDel>"] :="ǿ��ɾ��"
  ActionInfo_Arr["<Mark>"] :="��ǹ��ܣ���ǵ�ǰ�ļ��У�ʹ��'���Դ���Ӧ�ı��"
  ActionInfo_Arr["<ListMark>"] :="��ʾ���б�ǣ������m���ı�ǹ��ܲ�������VIM����"
  ActionInfo_Arr["<Internetsearch>"] :="ʹ��Ĭ�������������ǰ�ļ�"
  ActionInfo_Arr["<azHistory>"] :="���ļ�����ʷ����ǰ׺��������a-z����"
  ActionInfo_Arr["<azCmdHistory>"] :="�鿴������ʷ��¼"
  ActionInfo_Arr["<ListMapKey>"] :="��ʾ�Զ���ӳ���"
  ActionInfo_Arr["<WinMaxLeft>"] :="��������"
  ActionInfo_Arr["<WinMaxRight>"] :="��������"
  ActionInfo_Arr["<AlwayOnTop>"] :="TC���ڱ�����ǰ"
  ActionInfo_Arr["<TransParent>"] :="TC͸��"
  ActionInfo_Arr["<DeleteLHistory>"] :="ɾ������ļ�����ʷ"
  ActionInfo_Arr["<DeleteRHistory>"] :="ɾ���Ҳ��ļ�����ʷ"
  ActionInfo_Arr["<DelCmdHistory>"] :="ɾ����������ʷ"
  ActionInfo_Arr["<GoLastTab>"] :="ת�����һ����ǩ"
  ActionInfo_Arr["<TCLite>"] :="���TC"
  ActionInfo_Arr["<TCFullScreen>"] :="TCȫ��"
;TC�Դ�����"
  ActionInfo_Arr["<SrcComments>"] :="��Դ����: ��ʾ�ļ���ע"
  ActionInfo_Arr["<SrcShort>"] :="��Դ����: �б�"
  ActionInfo_Arr["<SrcLong>"] :="��Դ����: ��ϸ��Ϣ"
  ActionInfo_Arr["<SrcTree>"] :="��Դ����: �ļ�����"
  ActionInfo_Arr["<SrcQuickview>"] :="��Դ����: ���ٲ鿴"
  ActionInfo_Arr["<VerticalPanels>"] :="����/��������"
  ActionInfo_Arr["<SrcQuickInternalOnly>"] :="��Դ����: ���ٲ鿴(���ò��)"
  ActionInfo_Arr["<SrcHideQuickview>"] :="��Դ����: �رտ��ٲ鿴����"
  ActionInfo_Arr["<SrcExecs>"] :="��Դ����: ��ִ���ļ�"
  ActionInfo_Arr["<SrcAllFiles>"] :="��Դ����: �����ļ�"
  ActionInfo_Arr["<SrcUserSpec>"] :="��Դ����: �ϴ�ѡ�е��ļ�"
  ActionInfo_Arr["<SrcUserDef>"] :="��Դ����: �Զ�������"
  ActionInfo_Arr["<SrcByName>"] :="��Դ����: ���ļ�������"
  ActionInfo_Arr["<SrcByExt>"] :="��Դ����: ����չ������"
  ActionInfo_Arr["<SrcBySize>"] :="��Դ����: ����С����"
  ActionInfo_Arr["<SrcByDateTime>"] :="��Դ����: ������ʱ������"
  ActionInfo_Arr["<SrcUnsorted>"] :="��Դ����: ������"
  ActionInfo_Arr["<SrcNegOrder>"] :="��Դ����: ��������"
  ActionInfo_Arr["<SrcOpenDrives>"] :="��Դ����: ���������б�"
  ActionInfo_Arr["<SrcThumbs>"] :="��Դ����: ����ͼ"
  ActionInfo_Arr["<SrcCustomViewMenu>"] :="��Դ����: �Զ�����ͼ�˵�"
  ActionInfo_Arr["<SrcPathFocus>"] :="��Դ����: ��������·����"
  ActionInfo_Arr["<LeftComments>"] :="�󴰿�: ��ʾ�ļ���ע"
  ActionInfo_Arr["<LeftShort>"] :="�󴰿�: �б�"
  ActionInfo_Arr["<LeftLong>"] :="�󴰿�: ��ϸ��Ϣ"
  ActionInfo_Arr["<LeftTree>"] :="�󴰿�: �ļ�����"
  ActionInfo_Arr["<LeftQuickview>"] :="�󴰿�: ���ٲ鿴"
  ActionInfo_Arr["<LeftQuickInternalOnly>"] :="�󴰿�: ���ٲ鿴(���ò��)"
  ActionInfo_Arr["<LeftHideQuickview>"] :="�󴰿�: �رտ��ٲ鿴����"
  ActionInfo_Arr["<LeftExecs>"] :="�󴰿�: ��ִ���ļ�"
  ActionInfo_Arr["<LeftAllFiles>"] :="	�󴰿�: �����ļ�"
  ActionInfo_Arr["<LeftUserSpec>"] :="�󴰿�: �ϴ�ѡ�е��ļ�"
  ActionInfo_Arr["<LeftUserDef>"] :="�󴰿�: �Զ�������"
  ActionInfo_Arr["<LeftByName>"] :="�󴰿�: ���ļ�������"
  ActionInfo_Arr["<LeftByExt>"] :="�󴰿�: ����չ������"
  ActionInfo_Arr["<LeftBySize>"] :="�󴰿�: ����С����"
  ActionInfo_Arr["<LeftByDateTime>"] :="�󴰿�: ������ʱ������"
  ActionInfo_Arr["<LeftUnsorted>"] :="�󴰿�: ������"
  ActionInfo_Arr["<LeftNegOrder>"] :="�󴰿�: ��������"
  ActionInfo_Arr["<LeftOpenDrives>"] :="�󴰿�: ���������б�"
  ActionInfo_Arr["<LeftPathFocus>"] :="�󴰿�: ��������·����"
  ActionInfo_Arr["<LeftDirBranch>"] :="�󴰿�: չ�������ļ���"
  ActionInfo_Arr["<LeftDirBranchSel>"] :="�󴰿�: ֻչ��ѡ�е��ļ���"
  ActionInfo_Arr["<LeftThumbs>"] :="����: ����ͼ"
  ActionInfo_Arr["<LeftCustomViewMenu>"] :="����: �Զ�����ͼ�˵�"
  ActionInfo_Arr["<RightComments>"] :="�Ҵ���: ��ʾ�ļ���ע"
  ActionInfo_Arr["<RightShort>"] :="�Ҵ���: �б�"
  ActionInfo_Arr["<RightLong>"] :="��ϸ��Ϣ"
  ActionInfo_Arr["<RightTre>"] :="�Ҵ���: �ļ�����"
  ActionInfo_Arr["<RightQuickvie>"] :="�Ҵ���: ���ٲ鿴"
  ActionInfo_Arr["<RightQuickInternalOnl>"] :="�Ҵ���: ���ٲ鿴(���ò��)"
  ActionInfo_Arr["<RightHideQuickvie>"] :="�Ҵ���: �رտ��ٲ鿴����"
  ActionInfo_Arr["<RightExec>"] :="�Ҵ���: ��ִ���ļ�"
  ActionInfo_Arr["<RightAllFile>"] :="�Ҵ���: �����ļ�"
  ActionInfo_Arr["<RightUserSpe>"] :="�Ҵ���: �ϴ�ѡ�е��ļ�"
  ActionInfo_Arr["<RightUserDe>"] :="�Ҵ���: �Զ�������"
  ActionInfo_Arr["<RightByNam>"] :="�Ҵ���: ���ļ�������"
  ActionInfo_Arr["<RightByEx>"] :="�Ҵ���: ����չ������"
  ActionInfo_Arr["<RightBySiz>"] :="�Ҵ���: ����С����"
  ActionInfo_Arr["<RightByDateTim>"] :="�Ҵ���: ������ʱ������"
  ActionInfo_Arr["<RightUnsorte>"] :="�Ҵ���: ������"
  ActionInfo_Arr["<RightNegOrde>"] :="�Ҵ���: ��������"
  ActionInfo_Arr["<RightOpenDrive>"] :="�Ҵ���: ���������б�"
  ActionInfo_Arr["<RightPathFocu>"] :="�Ҵ���: ��������·����"
  ActionInfo_Arr["<RightDirBranch>"] :="�Ҵ���: չ�������ļ���"
  ActionInfo_Arr["<RightDirBranchSel>"] :="�Ҵ���: ֻչ��ѡ�е��ļ���"
  ActionInfo_Arr["<RightThumb>"] :="�Ҵ���: ����ͼ"
  ActionInfo_Arr["<RightCustomViewMen>"] :="�Ҵ���: �Զ�����ͼ�˵�"
  ActionInfo_Arr["<Lis>"] :="�鿴(�ò鿴����)"
  ActionInfo_Arr["<ListInternalOnly>"] :="�鿴(�ò鿴����, �����ò��/��ý��)"
  ActionInfo_Arr["<Edi>"] :="�༭"
  ActionInfo_Arr["<Copy>"] :="����"
  ActionInfo_Arr["<CopySamepanel>"] :="���Ƶ���ǰ����"
  ActionInfo_Arr["<CopyOtherpanel>"] :="���Ƶ���һ����"
  ActionInfo_Arr["<RenMov>"] :="������/�ƶ�"
  ActionInfo_Arr["<MkDir>"] :="�½��ļ���"
  ActionInfo_Arr["<Delete>"] :="ɾ��"
  ActionInfo_Arr["<TestArchive>"] :="����ѹ����"
  ActionInfo_Arr["<PackFiles>"] :="ѹ���ļ�"
  ActionInfo_Arr["<UnpackFiles>"] :="��ѹ�ļ�"
  ActionInfo_Arr["<RenameOnly>"] :="������(Shift+F6)"
  ActionInfo_Arr["<RenameSingleFile>"] :="��������ǰ�ļ�"
  ActionInfo_Arr["<MoveOnly>"] :="�ƶ�(F6)"
  ActionInfo_Arr["<Properties>"] :="��ʾ����"
  ActionInfo_Arr["<CreateShortcut>"] :="������ݷ�ʽ"
  ActionInfo_Arr["<Return>"] :="ģ�°� ENTER ��"
  ActionInfo_Arr["<OpenAsUser>"] :="�������û�������й�괦�ĳ���"
  ActionInfo_Arr["<Split>"] :="�ָ��ļ�"
  ActionInfo_Arr["<Combine>"] :="�ϲ��ļ�"
  ActionInfo_Arr["<Encode>"] :="�����ļ�(MIME/UUE/XXE ��ʽ)"
  ActionInfo_Arr["<Decode>"] :="�����ļ�(MIME/UUE/XXE/BinHex ��ʽ)"
  ActionInfo_Arr["<CRCcreate>"] :="����У���ļ�"
  ActionInfo_Arr["<CRCcheck>"] :="��֤У���"
  ActionInfo_Arr["<SetAttrib>"] :="��������"
  ActionInfo_Arr["<Config>"] :="����: ����"
  ActionInfo_Arr["<DisplayConfig>"] :="����: ��ʾ"
  ActionInfo_Arr["<IconConfig>"] :="����: ͼ��"
  ActionInfo_Arr["<FontConfig>"] :="����: ����"
  ActionInfo_Arr["<ColorConfig>"] :="����: ��ɫ"
  ActionInfo_Arr["<ConfTabChange>"] :="����: �Ʊ��"
  ActionInfo_Arr["<DirTabsConfig>"] :="����: �ļ��б�ǩ"
  ActionInfo_Arr["<CustomColumnConfig>"] :="����: �Զ�����"
  ActionInfo_Arr["<CustomColumnDlg>"] :="���ĵ�ǰ�Զ�����"
  ActionInfo_Arr["<LanguageConfig>"] :="����: ����"
  ActionInfo_Arr["<Config2>"] :="����: ������ʽ"
  ActionInfo_Arr["<EditConfig>"] :="����: �༭/�鿴"
  ActionInfo_Arr["<CopyConfig>"] :="����: ����/ɾ��"
  ActionInfo_Arr["<RefreshConfig>"] :="����: ˢ��"
  ActionInfo_Arr["<QuickSearchConfig>"] :="����: ��������"
  ActionInfo_Arr["<FtpConfig>"] :="����: FTP"
  ActionInfo_Arr["<PluginsConfig>"] :="����: ���"
  ActionInfo_Arr["<ThumbnailsConfig>"] :="����: ����ͼ"
  ActionInfo_Arr["<LogConfig>"] :="����: ��־�ļ�"
  ActionInfo_Arr["<IgnoreConfig>"] :="����: �����ļ�"
  ActionInfo_Arr["<PackerConfig>"] :="����: ѹ������"
  ActionInfo_Arr["<ZipPackerConfig>"] :="����: ZIP ѹ������"
  ActionInfo_Arr["<Confirmation>"] :="����: ����/ȷ��"
  ActionInfo_Arr["<ConfigSavePos>"] :="����λ��"
  ActionInfo_Arr["<ButtonConfig>"] :="���Ĺ�����"
  ActionInfo_Arr["<ConfigSaveSettings>"] :="��������"
  ActionInfo_Arr["<ConfigChangeIniFiles>"] :="ֱ���޸������ļ�"
  ActionInfo_Arr["<ConfigSaveDirHistory>"] :="�����ļ�����ʷ��¼"
  ActionInfo_Arr["<ChangeStartMenu>"] :="���Ŀ�ʼ�˵�"
  ActionInfo_Arr["<NetConnect>"] :="ӳ������������"
  ActionInfo_Arr["<NetDisconnect>"] :="�Ͽ�����������"
  ActionInfo_Arr["<NetShareDir>"] :="����ǰ�ļ���"
  ActionInfo_Arr["<NetUnshareDir>"] :="ȡ���ļ��й���"
  ActionInfo_Arr["<AdministerServer>"] :="��ʾϵͳ�����ļ���"
  ActionInfo_Arr["<ShowFileUser>"] :="��ʾ�����ļ���Զ���û�"
  ActionInfo_Arr["<GetFileSpace>"] :="����ռ�ÿռ�"
  ActionInfo_Arr["<VolumeId>"] :="���þ��"
  ActionInfo_Arr["<VersionInfo>"] :="�汾��Ϣ"
  ActionInfo_Arr["<ExecuteDOS>"] :="��������ʾ������"
  ActionInfo_Arr["<CompareDirs>"] :="�Ƚ��ļ���"
  ActionInfo_Arr["<CompareDirsWithSubdirs>"] :="�Ƚ��ļ���(ͬʱ�����һ����û�е����ļ���)"
  ActionInfo_Arr["<ContextMenu>"] :="��ʾ��ݲ˵�"
  ActionInfo_Arr["<ContextMenuInternal>"] :="��ʾ��ݲ˵�(�ڲ�����)"
  ActionInfo_Arr["<ContextMenuInternalCursor>"] :="��ʾ��괦�ļ����ڲ�������ݲ˵�"
  ActionInfo_Arr["<ShowRemoteMenu>"] :="ý������ң��������/��ͣ����ݲ˵�"
  ActionInfo_Arr["<SyncChangeDir>"] :="���ߴ���ͬ�������ļ���"
  ActionInfo_Arr["<EditComment>"] :="�༭�ļ���ע"
  ActionInfo_Arr["<FocusLeft>"] :="���������󴰿�"
  ActionInfo_Arr["<FocusRight>"] :="���������Ҵ���"
  ActionInfo_Arr["<FocusCmdLine>"] :="��������������"
  ActionInfo_Arr["<FocusButtonBar>"] :="�������ڹ�����"
  ActionInfo_Arr["<CountDirContent>"] :="���������ļ���ռ�õĿռ�"
  ActionInfo_Arr["<UnloadPlugins>"] :="ж�����в��"
  ActionInfo_Arr["<DirMatch>"] :="������ļ�, ������ͬ��"
  ActionInfo_Arr["<Exchange>"] :="�������Ҵ���"
  ActionInfo_Arr["<MatchSrc>"] :="Ŀ�� = ��Դ"
  ActionInfo_Arr["<ReloadSelThumbs>"] :="ˢ��ѡ���ļ�������ͼ"
  ActionInfo_Arr["<DirectCableConnect>"] :="ֱ�ӵ�������"
  ActionInfo_Arr["<NTinstallDriver>"] :="���� NT ������������"
  ActionInfo_Arr["<NTremoveDriver>"] :="ж�� NT ������������"
  ActionInfo_Arr["<PrintDir>"] :="��ӡ�ļ��б�"
  ActionInfo_Arr["<PrintDirSub>"] :="��ӡ�ļ��б�(�����ļ���)"
  ActionInfo_Arr["<PrintFile>"] :="��ӡ�ļ�����"
  ActionInfo_Arr["<SpreadSelection>"] :="ѡ��һ���ļ�"
  ActionInfo_Arr["<SelectBoth>"] :="ѡ��һ��: �ļ����ļ���"
  ActionInfo_Arr["<SelectFiles>"] :="ѡ��һ��: ���ļ�"
  ActionInfo_Arr["<SelectFolders>"] :="ѡ��һ��: ���ļ���"
  ActionInfo_Arr["<ShrinkSelection>"] :="��ѡһ���ļ�"
  ActionInfo_Arr["<ClearFiles>"] :="��ѡһ��: ���ļ�"
  ActionInfo_Arr["<ClearFolders>"] :="��ѡһ��: ���ļ���"
  ActionInfo_Arr["<ClearSelCfg>"] :="��ѡһ��: �ļ���/���ļ���(�����ö���)"
  ActionInfo_Arr["<SelectAll>"] :="ȫ��ѡ��: �ļ���/���ļ���(�����ö���)"
  ActionInfo_Arr["<SelectAllBoth>"] :="ȫ��ѡ��: �ļ����ļ���"
  ActionInfo_Arr["<SelectAllFiles>"] :="ȫ��ѡ��: ���ļ�"
  ActionInfo_Arr["<SelectAllFolders>"] :="ȫ��ѡ��: ���ļ���"
  ActionInfo_Arr["<ClearAll>"] :="ȫ��ȡ��: �ļ����ļ���"
  ActionInfo_Arr["<ClearAllFiles>"] :="ȫ��ȡ��: ���ļ�"
  ActionInfo_Arr["<ClearAllFolders>"] :="ȫ��ȡ��: ���ļ���"
  ActionInfo_Arr["<ClearAllCfg>"] :="ȫ��ȡ��: �ļ���/���ļ���(�����ö���)"
  ActionInfo_Arr["<ExchangeSelection>"] :="����ѡ��"
  ActionInfo_Arr["<ExchangeSelBoth>"] :="����ѡ��: �ļ����ļ���"
  ActionInfo_Arr["<ExchangeSelFiles>"] :="����ѡ��: ���ļ�"
  ActionInfo_Arr["<ExchangeSelFolders>"] :="����ѡ��: ���ļ���"
  ActionInfo_Arr["<SelectCurrentExtension>"] :="ѡ����չ����ͬ���ļ�"
  ActionInfo_Arr["<UnselectCurrentExtension>"] :="��ѡ��չ����ͬ���ļ�"
  ActionInfo_Arr["<SelectCurrentName>"] :="ѡ���ļ�����ͬ���ļ�"
  ActionInfo_Arr["<UnselectCurrentName>"] :="��ѡ�ļ�����ͬ���ļ�"
  ActionInfo_Arr["<SelectCurrentNameExt>"] :="ѡ���ļ�������չ����ͬ���ļ�"
  ActionInfo_Arr["<UnselectCurrentNameExt>"] :="��ѡ�ļ�������չ����ͬ���ļ�"
  ActionInfo_Arr["<SelectCurrentPath>"] :="ѡ��ͬһ·���µ��ļ�(չ���ļ���+�����ļ�)"
  ActionInfo_Arr["<UnselectCurrentPath>"] :="��ѡͬһ·���µ��ļ�(չ���ļ���+�����ļ�)"
  ActionInfo_Arr["<RestoreSelection>"] :="�ָ�ѡ���б�"
  ActionInfo_Arr["<SaveSelection>"] :="����ѡ���б�"
  ActionInfo_Arr["<SaveSelectionToFile>"] :="����ѡ���б�"
  ActionInfo_Arr["<SaveSelectionToFileA>"] :="����ѡ���б�(ANSI)"
  ActionInfo_Arr["<SaveSelectionToFileW>"] :="����ѡ���б�(Unicode)"
  ActionInfo_Arr["<SaveDetailsToFile>"] :="������ϸ��Ϣ"
  ActionInfo_Arr["<SaveDetailsToFileA>"] :="������ϸ��Ϣ(ANSI)"
  ActionInfo_Arr["<SaveDetailsToFileW>"] :="������ϸ��Ϣ(Unicode)"
  ActionInfo_Arr["<LoadSelectionFromFile>"] :="����ѡ���б�(���ļ�)"
  ActionInfo_Arr["<LoadSelectionFromClip>"] :="����ѡ���б�(�Ӽ�����)"
  ActionInfo_Arr["<EditPermissionInfo>"] :="����Ȩ��(NTFS)"
  ActionInfo_Arr["<EditAuditInfo>"] :="����ļ�(NTFS)"
  ActionInfo_Arr["<EditOwnerInfo>"] :="��ȡ����Ȩ(NTFS)"
  ActionInfo_Arr["<CutToClipboard>"] :="����ѡ�е��ļ���������"
  ActionInfo_Arr["<CopyToClipboard>"] :="����ѡ�е��ļ���������"
  ActionInfo_Arr["<PasteFromClipboard>"] :="�Ӽ�����ճ������ǰ�ļ���"
  ActionInfo_Arr["<CopyNamesToClip>"] :="�����ļ���"
  ActionInfo_Arr["<CopyFullNamesToClip>"] :="�����ļ���������·��"
  ActionInfo_Arr["<CopyNetNamesToClip>"] :="�����ļ���������·��"
  ActionInfo_Arr["<CopySrcPathToClip>"] :="������Դ·��"
  ActionInfo_Arr["<CopyTrgPathToClip>"] :="����Ŀ��·��"
  ActionInfo_Arr["<CopyFileDetailsToClip>"] :="�����ļ���ϸ��Ϣ"
  ActionInfo_Arr["<CopyFpFileDetailsToClip>"] :="�����ļ���ϸ��Ϣ������·��"
  ActionInfo_Arr["<CopyNetFileDetailsToClip>"] :="�����ļ���ϸ��Ϣ������·��"
  ActionInfo_Arr["<FtpConnect>"] :="FTP ����"
  ActionInfo_Arr["<FtpNew>"] :="�½� FTP ����"
  ActionInfo_Arr["<FtpDisconnect>"] :="�Ͽ� FTP ����"
  ActionInfo_Arr["<FtpHiddenFiles>"] :="��ʾ�����ļ�"
  ActionInfo_Arr["<FtpAbort>"] :="��ֹ��ǰ FTP ����"
  ActionInfo_Arr["<FtpResumeDownload>"] :="����"
  ActionInfo_Arr["<FtpSelectTransferMode>"] :="ѡ����ģʽ"
  ActionInfo_Arr["<FtpAddToList>"] :="��ӵ������б�"
  ActionInfo_Arr["<FtpDownloadList>"] :="���б�����"
  ActionInfo_Arr["<GotoPreviousDir>"] :="����"
  ActionInfo_Arr["<GotoNextDir>"] :="ǰ��"
  ActionInfo_Arr["<DirectoryHistory>"] :="�ļ�����ʷ��¼"
  ActionInfo_Arr["<GotoPreviousLocalDir>"] :="����(�� FTP)"
  ActionInfo_Arr["<GotoNextLocalDir>"] :="ǰ��(�� FTP)"
  ActionInfo_Arr["<DirectoryHotlist>"] :="�����ļ���"
  ActionInfo_Arr["<GoToRoot>"] :="ת�����ļ���"
  ActionInfo_Arr["<GoToParent>"] :="ת���ϲ��ļ���"
  ActionInfo_Arr["<GoToDir>"] :="�򿪹�괦���ļ��л�ѹ����"
  ActionInfo_Arr["<OpenDesktop>"] :="����"
  ActionInfo_Arr["<OpenDrives>"] :="�ҵĵ���"
  ActionInfo_Arr["<OpenControls>"] :="�������"
  ActionInfo_Arr["<OpenFonts>"] :="����"
  ActionInfo_Arr["<OpenNetwork>"] :="�����ھ�"
  ActionInfo_Arr["<OpenPrinters>"] :="��ӡ��"
  ActionInfo_Arr["<OpenRecycled>"] :="����վ"
  ActionInfo_Arr["<CDtree>"] :="�����ļ���"
  ActionInfo_Arr["<TransferLeft>"] :="���󴰿ڴ򿪹�괦���ļ��л�ѹ����"
  ActionInfo_Arr["<TransferRight>"] :="���Ҵ��ڴ򿪹�괦���ļ��л�ѹ����"
  ActionInfo_Arr["<EditPath>"] :="�༭��Դ���ڵ�·��"
  ActionInfo_Arr["<GoToFirstFile>"] :="����Ƶ��б��еĵ�һ���ļ�"
  ActionInfo_Arr["<GotoNextDrive>"] :="ת����һ��������"
  ActionInfo_Arr["<GotoPreviousDrive>"] :="ת����һ��������"
  ActionInfo_Arr["<GotoNextSelected>"] :="ת����һ��ѡ�е��ļ�"
  ActionInfo_Arr["<GotoPrevSelected>"] :="ת����һ��ѡ�е��ļ�"
  ActionInfo_Arr["<GotoDriveA>"] :="ת�������� A"
  ActionInfo_Arr["<GotoDriveC>"] :="ת�������� C"
  ActionInfo_Arr["<GotoDriveD>"] :="ת�������� D"
  ActionInfo_Arr["<GotoDriveE>"] :="ת�������� E"
  ActionInfo_Arr["<GotoDriveF>"] :="���Զ�������������"
  ActionInfo_Arr["<GotoDriveZ>"] :="��� 26 ��"
  ActionInfo_Arr["<HelpIndex>"] :="��������"
  ActionInfo_Arr["<Keyboard>"] :="��ݼ��б�"
  ActionInfo_Arr["<Register>"] :="ע����Ϣ"
  ActionInfo_Arr["<VisitHomepage>"] :="���� Totalcmd ��վ"
  ActionInfo_Arr["<About>"] :="���� Total Commander"
  ActionInfo_Arr["<Exit>"] :="�˳� Total Commander"
  ActionInfo_Arr["<Minimize>"] :="��С�� Total Commander"
  ActionInfo_Arr["<Maximize>"] :="��� Total Commander"
  ActionInfo_Arr["<Restore>"] :="�ָ�������С"
  ActionInfo_Arr["<ClearCmdLine>"] :="���������"
  ActionInfo_Arr["<NextCommand>"] :="��һ������"
  ActionInfo_Arr["<PrevCommand>"] :="��һ������"
  ActionInfo_Arr["<AddPathToCmdline>"] :="��·�����Ƶ�������"
  ActionInfo_Arr["<MultiRenameFiles>"] :="����������"
  ActionInfo_Arr["<SysInfo>"] :="ϵͳ��Ϣ"
  ActionInfo_Arr["<OpenTransferManager>"] :="��̨���������"
  ActionInfo_Arr["<SearchFor>"] :="�����ļ�"
  ActionInfo_Arr["<FileSync>"] :="ͬ���ļ���"
  ActionInfo_Arr["<Associate>"] :="�ļ�����"
  ActionInfo_Arr["<InternalAssociate>"] :="�����ڲ�����"
  ActionInfo_Arr["<CompareFilesByContent>"] :="�Ƚ��ļ�����"
  ActionInfo_Arr["<IntCompareFilesByContent>"] :="ʹ���ڲ��Ƚϳ���"
  ActionInfo_Arr["<CommandBrowser>"] :="����ڲ�����"
  ActionInfo_Arr["<VisButtonbar>"] :="��ʾ/����: ������"
  ActionInfo_Arr["<VisDriveButtons>"] :="��ʾ/����: ��������ť"
  ActionInfo_Arr["<VisTwoDriveButtons>"] :="��ʾ/����: ������������ť��"
  ActionInfo_Arr["<VisFlatDriveButtons>"] :="�л�: ƽ̹/������������ť"
  ActionInfo_Arr["<VisFlatInterface>"] :="�л�: ƽ̹/�����û�����"
  ActionInfo_Arr["<VisDriveCombo>"] :="��ʾ/����: �������б�"
  ActionInfo_Arr["<VisCurDir>"] :="��ʾ/����: ��ǰ�ļ���"
  ActionInfo_Arr["<VisBreadCrumbs>"] :="��ʾ/����: ·��������"
  ActionInfo_Arr["<VisTabHeader>"] :="��ʾ/����: �����Ʊ��"
  ActionInfo_Arr["<VisStatusbar>"] :="��ʾ/����: ״̬��"
  ActionInfo_Arr["<VisCmdLine>"] :="��ʾ/����: ������"
  ActionInfo_Arr["<VisKeyButtons>"] :="��ʾ/����: ���ܼ���ť"
  ActionInfo_Arr["<ShowHint>"] :="��ʾ�ļ���ʾ"
  ActionInfo_Arr["<ShowQuickSearch>"] :="��ʾ������������"
  ActionInfo_Arr["<SwitchLongNames>"] :="����/�ر�: ���ļ�����ʾ"
  ActionInfo_Arr["<RereadSource>"] :="ˢ����Դ����"
  ActionInfo_Arr["<ShowOnlySelected>"] :="����ʾѡ�е��ļ�"
  ActionInfo_Arr["<SwitchHidSys>"] :="����/�ر�: ���ػ�ϵͳ�ļ���ʾ"
  ActionInfo_Arr["<Switch83Names>"] :="����/�ر�: 8.3 ʽ�ļ���Сд��ʾ"
  ActionInfo_Arr["<SwitchDirSort>"] :="����/�ر�: �ļ��а���������"
  ActionInfo_Arr["<DirBranch>"] :="չ�������ļ���"
  ActionInfo_Arr["<DirBranchSel>"] :="ֻչ��ѡ�е��ļ���"
  ActionInfo_Arr["<50Percent>"] :="���ڷָ���λ�� 50%"
  ActionInfo_Arr["<100Percent>"] :="���ڷָ���λ�� 100%"
  ActionInfo_Arr["<VisDirTabs>"] :="��ʾ/����: �ļ��б�ǩ"
  ActionInfo_Arr["<VisXPThemeBackground>"] :="��ʾ/����: XP ���ⱳ��"
  ActionInfo_Arr["<SwitchOverlayIcons>"] :="����/�ر�: ����ͼ����ʾ"
  ActionInfo_Arr["<VisHistHotButtons>"] :="��ʾ/����: �ļ�����ʷ��¼�ͳ����ļ��а�ť"
  ActionInfo_Arr["<SwitchWatchDirs>"] :="����/����: �ļ����Զ�ˢ��"
  ActionInfo_Arr["<SwitchIgnoreList>"] :="����/����: �Զ��������ļ�"
  ActionInfo_Arr["<SwitchX64Redirection>"] :="����/�ر�: 32 λ system32 Ŀ¼�ض���(64 λ Windows)"
  ActionInfo_Arr["<SeparateTreeOff>"] :="�رն����ļ��������"
  ActionInfo_Arr["<SeparateTree1>"] :="һ�������ļ��������"
  ActionInfo_Arr["<SeparateTree2>"] :="���������ļ��������"
  ActionInfo_Arr["<SwitchSeparateTree>"] :="�л������ļ��������״̬"
  ActionInfo_Arr["<ToggleSeparateTree1>"] :="����/�ر�: һ�������ļ��������"
  ActionInfo_Arr["<ToggleSeparateTree2>"] :="����/�ر�: ���������ļ��������"
  ActionInfo_Arr["<UserMenu1>"] :="�û��˵� 1"
  ActionInfo_Arr["<UserMenu2>"] :="�û��˵� 2"
  ActionInfo_Arr["<UserMenu3>"] :="�û��˵� 3"
  ActionInfo_Arr["<UserMenu4>"] :="..."
  ActionInfo_Arr["<UserMenu5>"] :="5"
  ActionInfo_Arr["<UserMenu6>"] :="6"
  ActionInfo_Arr["<UserMenu7>"] :="7"
  ActionInfo_Arr["<UserMenu8>"] :="8"
  ActionInfo_Arr["<UserMenu9>"] :="9"
  ActionInfo_Arr["<UserMenu10>"] :="�ɶ��������û��˵�"
  ActionInfo_Arr["<OpenNewTab>"] :="�½���ǩ"
  ActionInfo_Arr["<OpenNewTabBg>"] :="�½���ǩ(�ں�̨)"
  ActionInfo_Arr["<OpenDirInNewTab>"] :="�½���ǩ(���򿪹�괦���ļ���)"
  ActionInfo_Arr["<OpenDirInNewTabOther>"] :="�½���ǩ(����һ���ڴ��ļ���)"
  ActionInfo_Arr["<SwitchToNextTab>"] :="��һ����ǩ(Ctrl+Tab)"
  ActionInfo_Arr["<SwitchToPreviousTab>"] :="��һ����ǩ(Ctrl+Shift+Tab)"
  ActionInfo_Arr["<CloseCurrentTab>"] :="�رյ�ǰ��ǩ"
  ActionInfo_Arr["<CloseAllTabs>"] :="�ر����б�ǩ"
  ActionInfo_Arr["<DirTabsShowMenu>"] :="��ʾ��ǩ�˵�"
  ActionInfo_Arr["<ToggleLockCurrentTab>"] :="����/������ǰ��ǩ"
  ActionInfo_Arr["<ToggleLockDcaCurrentTab>"] :="����/������ǰ��ǩ(�ɸ����ļ���)"
  ActionInfo_Arr["<ExchangeWithTabs>"] :="�������Ҵ��ڼ����ǩ"
  ActionInfo_Arr["<GoToLockedDir>"] :="ת��������ǩ�ĸ��ļ���"
  ActionInfo_Arr["<SrcActivateTab1>"] :="��Դ����: �����ǩ 1"
  ActionInfo_Arr["<SrcActivateTab2>"] :="��Դ����: �����ǩ 2"
  ActionInfo_Arr["<SrcActivateTab3>"] :="..."
  ActionInfo_Arr["<SrcActivateTab4>"] :="��� 99 ��"
  ActionInfo_Arr["<SrcActivateTab5>"] :="5"
  ActionInfo_Arr["<SrcActivateTab6>"] :="6"
  ActionInfo_Arr["<SrcActivateTab7>"] :="7"
  ActionInfo_Arr["<SrcActivateTab8>"] :="8"
  ActionInfo_Arr["<SrcActivateTab9>"] :="9"
  ActionInfo_Arr["<SrcActivateTab10>"] :="0"
  ActionInfo_Arr["<TrgActivateTab1>"] :="Ŀ�괰��: �����ǩ 1"
  ActionInfo_Arr["<TrgActivateTab2>"] :="Ŀ�괰��: �����ǩ 2"
  ActionInfo_Arr["<TrgActivateTab3>"] :="..."
  ActionInfo_Arr["<TrgActivateTab4>"] :="��� 99 ��"
  ActionInfo_Arr["<TrgActivateTab5>"] :="5"
  ActionInfo_Arr["<TrgActivateTab6>"] :="6"
  ActionInfo_Arr["<TrgActivateTab7>"] :="7"
  ActionInfo_Arr["<TrgActivateTab8>"] :="8"
  ActionInfo_Arr["<TrgActivateTab9>"] :="9"
  ActionInfo_Arr["<TrgActivateTab10>"] :="0"
  ActionInfo_Arr["<LeftActivateTab1>"] :="�󴰿�: �����ǩ 1"
  ActionInfo_Arr["<LeftActivateTab2>"] :="�󴰿�: �����ǩ 2"
  ActionInfo_Arr["<LeftActivateTab3>"] :="..."
  ActionInfo_Arr["<LeftActivateTab4>"] :="��� 99 ��"
  ActionInfo_Arr["<LeftActivateTab5>"] :="5"
  ActionInfo_Arr["<LeftActivateTab6>"] :="6"
  ActionInfo_Arr["<LeftActivateTab7>"] :="7"
  ActionInfo_Arr["<LeftActivateTab8>"] :="8"
  ActionInfo_Arr["<LeftActivateTab9>"] :="9"
  ActionInfo_Arr["<LeftActivateTab10>"] :="0"
  ActionInfo_Arr["<RightActivateTab1>"] :="�Ҵ���: �����ǩ 1"
  ActionInfo_Arr["<RightActivateTab2>"] :="�Ҵ���: �����ǩ 2"
  ActionInfo_Arr["<RightActivateTab3>"] :="..."
  ActionInfo_Arr["<RightActivateTab4>"] :="��� 99 ��"
  ActionInfo_Arr["<RightActivateTab5>"] :="5"
  ActionInfo_Arr["<RightActivateTab6>"] :="6"
  ActionInfo_Arr["<RightActivateTab7>"] :="7"
  ActionInfo_Arr["<RightActivateTab8>"] :="8"
  ActionInfo_Arr["<RightActivateTab9>"] :="9"
  ActionInfo_Arr["<RightActivateTab10>"] :="0"
  ActionInfo_Arr["<SrcSortByCol1>"] :="��Դ����: ���� 1 ������"
  ActionInfo_Arr["<SrcSortByCol2>"] :="��Դ����: ���� 2 ������"
  ActionInfo_Arr["<SrcSortByCol3>"] :="..."
  ActionInfo_Arr["<SrcSortByCol4>"] :="��� 99 ��"
  ActionInfo_Arr["<SrcSortByCol5>"] :="5"
  ActionInfo_Arr["<SrcSortByCol6>"] :="6"
  ActionInfo_Arr["<SrcSortByCol7>"] :="7"
  ActionInfo_Arr["<SrcSortByCol8>"] :="8"
  ActionInfo_Arr["<SrcSortByCol9>"] :="9"
  ActionInfo_Arr["<SrcSortByCol10>"] :="0"
  ActionInfo_Arr["<SrcSortByCol99>"] :="9"
  ActionInfo_Arr["<TrgSortByCol1>"] :="Ŀ�괰��: ���� 1 ������"
  ActionInfo_Arr["<TrgSortByCol2>"] :="Ŀ�괰��: ���� 2 ������"
  ActionInfo_Arr["<TrgSortByCol3>"] :="..."
  ActionInfo_Arr["<TrgSortByCol4>"] :="��� 99 ��"
  ActionInfo_Arr["<TrgSortByCol5>"] :="5"
  ActionInfo_Arr["<TrgSortByCol6>"] :="6"
  ActionInfo_Arr["<TrgSortByCol7>"] :="7"
  ActionInfo_Arr["<TrgSortByCol8>"] :="8"
  ActionInfo_Arr["<TrgSortByCol9>"] :="9"
  ActionInfo_Arr["<TrgSortByCol10>"] :="0"
  ActionInfo_Arr["<TrgSortByCol99>"] :="9"
  ActionInfo_Arr["<LeftSortByCol1>"] :="�󴰿�: ���� 1 ������"
  ActionInfo_Arr["<LeftSortByCol2>"] :="�󴰿�: ���� 2 ������"
  ActionInfo_Arr["<LeftSortByCol3>"] :="..."
  ActionInfo_Arr["<LeftSortByCol4>"] :="��� 99 ��"
  ActionInfo_Arr["<LeftSortByCol5>"] :="5"
  ActionInfo_Arr["<LeftSortByCol6>"] :="6"
  ActionInfo_Arr["<LeftSortByCol7>"] :="7"
  ActionInfo_Arr["<LeftSortByCol8>"] :="8"
  ActionInfo_Arr["<LeftSortByCol9>"] :="9"
  ActionInfo_Arr["<LeftSortByCol10>"] :="0"
  ActionInfo_Arr["<LeftSortByCol99>"] :="9"
  ActionInfo_Arr["<RightSortByCol1>"] :="�Ҵ���: ���� 1 ������"
  ActionInfo_Arr["<RightSortByCol2>"] :="�Ҵ���: ���� 2 ������"
  ActionInfo_Arr["<RightSortByCol3>"] :="..."
  ActionInfo_Arr["<RightSortByCol4>"] :="��� 99 ��"
  ActionInfo_Arr["<RightSortByCol5>"] :="5"
  ActionInfo_Arr["<RightSortByCol6>"] :="6"
  ActionInfo_Arr["<RightSortByCol7>"] :="7"
  ActionInfo_Arr["<RightSortByCol8>"] :="8"
  ActionInfo_Arr["<RightSortByCol9>"] :="9"
  ActionInfo_Arr["<RightSortByCol10>"] :="0"
  ActionInfo_Arr["<RightSortByCol99>"] :="9"
  ActionInfo_Arr["<SrcCustomView1>"] :="��Դ����: �Զ�������ͼ 1"
  ActionInfo_Arr["<SrcCustomView2>"] :="��Դ����: �Զ�������ͼ 2"
  ActionInfo_Arr["<SrcCustomView3>"] :="..."
  ActionInfo_Arr["<SrcCustomView4>"] :="��� 29 ��"
  ActionInfo_Arr["<SrcCustomView5>"] :="5"
  ActionInfo_Arr["<SrcCustomView6>"] :="6"
  ActionInfo_Arr["<SrcCustomView7>"] :="7"
  ActionInfo_Arr["<SrcCustomView8>"] :="8"
  ActionInfo_Arr["<SrcCustomView9>"] :="9"
  ActionInfo_Arr["<LeftCustomView1>"] :="�󴰿�: �Զ�������ͼ 1"
  ActionInfo_Arr["<LeftCustomView2>"] :="�󴰿�: �Զ�������ͼ 2"
  ActionInfo_Arr["<LeftCustomView3>"] :="..."
  ActionInfo_Arr["<LeftCustomView4>"] :="��� 29 ��"
  ActionInfo_Arr["<LeftCustomView5>"] :="5"
  ActionInfo_Arr["<LeftCustomView6>"] :="6"
  ActionInfo_Arr["<LeftCustomView7>"] :="7"
  ActionInfo_Arr["<LeftCustomView8>"] :="8"
  ActionInfo_Arr["<LeftCustomView9>"] :="9"
  ActionInfo_Arr["<RightCustomView1>"] :="�Ҵ���: �Զ�������ͼ 1"
  ActionInfo_Arr["<RightCustomView2>"] :="�Ҵ���: �Զ�������ͼ 2"
  ActionInfo_Arr["<RightCustomView3>"] :="..."
  ActionInfo_Arr["<RightCustomView4>"] :="��� 29 ��"
  ActionInfo_Arr["<RightCustomView5>"] :="5"
  ActionInfo_Arr["<RightCustomView6>"] :="6"
  ActionInfo_Arr["<RightCustomView7>"] :="7"
  ActionInfo_Arr["<RightCustomView8>"] :="8"
  ActionInfo_Arr["<RightCustomView9>"] :="9"
  ActionInfo_Arr["<SrcNextCustomView>"] :="��Դ����: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<SrcPrevCustomView>"] :="��Դ����: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<TrgNextCustomView>"] :="Ŀ�괰��: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<TrgPrevCustomView>"] :="Ŀ�괰��: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<LeftNextCustomView>"] :="�󴰿�: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<LeftPrevCustomView>"] :="�󴰿�: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<RightNextCustomView>"] :="�Ҵ���: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<RightPrevCustomView>"] :="�Ҵ���: ��һ���Զ�����ͼ"
  ActionInfo_Arr["<LoadAllOnDemandFields>"] :="�����ļ���������ر�ע"
  ActionInfo_Arr["<LoadSelOnDemandFields>"] :="��ѡ�е��ļ�������ر�ע"
  ActionInfo_Arr["<ContentStopLoadFields>"] :="ֹͣ��̨���ر�ע"
}
; TC�Դ����� {{{1
;��Դ���� ==ʹ��VIM�µ�VOom ������Ժܷ���Ĳ鿴===
;��Դ���� =========================================
;��Դ���� =========================================
;<SrcComments>: >>��Դ����: ��ʾ�ļ���ע{{{2
<SrcComments>:
	SendPos(300)
Return
;<SrcShort>: >>��Դ����: �б�{{{2
<SrcShort>:
	SendPos(301)
Return
;<SrcLong>: >>��Դ����: ��ϸ��Ϣ{{{2
<SrcLong>:
	SendPos(302)
Return
;<SrcTree>: >>��Դ����: �ļ�����{{{2
<SrcTree>:
	SendPos(303)
;<SrcQuickview>: >>��Դ����: ���ٲ鿴{{{2
<SrcQuickview>:
	SendPos(304)
Return
;<VerticalPanels>: >>��������{{{2
<VerticalPanels>:
	SendPos(305)
Return
;<SrcQuickInternalOnly>: >>��Դ����: ���ٲ鿴(���ò��){{{2
<SrcQuickInternalOnly>:
	SendPos(306)
Return
;<SrcHideQuickview>: >>��Դ����: �رտ��ٲ鿴����{{{2
<SrcHideQuickview>:
	SendPos(307)
Return
;<SrcExecs>: >>��Դ����: ��ִ���ļ�{{{2
<SrcExecs>:
	SendPos(311)
Return
;<SrcAllFiles>: >>��Դ����: �����ļ�{{{2
<SrcAllFiles>:
	SendPos(312)
Return
;<SrcUserSpec>: >>��Դ����: �ϴ�ѡ�е��ļ�{{{2
<SrcUserSpec>:
	SendPos(313)
Return
;<SrcUserDef>: >>��Դ����: �Զ�������{{{2
<SrcUserDef>:
	SendPos(314)
Return
;<SrcByName>: >>��Դ����: ���ļ�������{{{2
<SrcByName>:
	SendPos(321)
Return
;<SrcByExt>: >>��Դ����: ����չ������{{{2
<SrcByExt>:
	SendPos(322)
Return
;<SrcBySize>: >>��Դ����: ����С����{{{2
<SrcBySize>:
	SendPos(323)
Return
;<SrcByDateTime>: >>��Դ����: ������ʱ������{{{2
<SrcByDateTime>:
	SendPos(324)
Return
;<SrcUnsorted>: >>��Դ����: ������{{{2
<SrcUnsorted>:
	SendPos(325)
Return
;<SrcNegOrder>: >>��Դ����: ��������{{{2
<SrcNegOrder>:
	SendPos(330)
Return
;<SrcOpenDrives>: >>��Դ����: ���������б�{{{2
<SrcOpenDrives>:
	SendPos(331)
Return
;<SrcThumbs>: >>��Դ����: ����ͼ{{{2
<SrcThumbs>:
	SendPos(269	)
Return
;<SrcCustomViewMenu>: >>��Դ����: �Զ�����ͼ�˵�{{{2
<SrcCustomViewMenu>:
	SendPos(270)
Return
;<SrcPathFocus>: >>��Դ����: ��������·����{{{2
<SrcPathFocus>:
	SendPos(332)
Return
;�󴰿� ========================================4
;�󴰿� =========================================
;�󴰿� =========================================
Return
;<LeftComments>: >>�󴰿�: ��ʾ�ļ���ע{{{2
<LeftComments>:
	SendPos(100)
Return
;<LeftShort>: >>�󴰿�: �б�{{{2
<LeftShort>:
	SendPos(101)
Return
;<LeftLong>: >>�󴰿�: ��ϸ��Ϣ{{{2
<LeftLong>:
	SendPos(102)
Return
;<LeftTree>: >>�󴰿�: �ļ�����{{{2
<LeftTree>:
	SendPos(103)
Return
;<LeftQuickview>: >>�󴰿�: ���ٲ鿴{{{2
<LeftQuickview>:
	SendPos(104)
Return
;<LeftQuickInternalOnly>: >>�󴰿�: ���ٲ鿴(���ò��){{{2
<LeftQuickInternalOnly>:
	SendPos(106)
Return
;<LeftHideQuickview>: >>�󴰿�: �رտ��ٲ鿴����{{{2
<LeftHideQuickview>:
	SendPos(107)
Return
;<LeftExecs>: >>�󴰿�: ��ִ���ļ�{{{2
<LeftExecs>:
	SendPos(111)
Return
;<LeftAllFiles>: >>	�󴰿�: �����ļ�{{{2
<LeftAllFiles>:
	SendPos(112)
Return
;<LeftUserSpec>: >>�󴰿�: �ϴ�ѡ�е��ļ�{{{2
<LeftUserSpec>:
	SendPos(113)
Return
;<LeftUserDef>: >>�󴰿�: �Զ�������{{{2
<LeftUserDef>:
	SendPos(114)
Return
;<LeftByName>: >>�󴰿�: ���ļ�������{{{2
<LeftByName>:
	SendPos(121)
Return
;<LeftByExt>: >>�󴰿�: ����չ������{{{2
<LeftByExt>:
	SendPos(122)
Return
;<LeftBySize>: >>�󴰿�: ����С����{{{2
<LeftBySize>:
	SendPos(123)
Return
;<LeftByDateTime>: >>�󴰿�: ������ʱ������{{{2
<LeftByDateTime>:
	SendPos(124)
Return
;<LeftUnsorted>: >>�󴰿�: ������{{{2
<LeftUnsorted>:
	SendPos(125)
Return
;<LeftNegOrder>: >>�󴰿�: ��������{{{2
<LeftNegOrder>:
	SendPos(130)
Return
;<LeftOpenDrives>: >>�󴰿�: ���������б�{{{2
<LeftOpenDrives>:
	SendPos(131)
Return
;<LeftPathFocus>: >>�󴰿�: ��������·����{{{2
<LeftPathFocus>:
	SendPos(132)
Return
;<LeftDirBranch>: >>�󴰿�: չ�������ļ���{{{2
<LeftDirBranch>:
	SendPos(203)
Return
;<LeftDirBranchSel>: >>	�󴰿�: ֻչ��ѡ�е��ļ���{{{2
<LeftDirBranchSel>:
	SendPos(204)
Return
;<LeftThumbs>: >>����: ����ͼ{{{2
<LeftThumbs>:
	SendPos(69)
Return
;<LeftCustomViewMenu>: >>	����: �Զ�����ͼ�˵�{{{2
<LeftCustomViewMenu>:
	SendPos(70)
Return
;�Ҵ��� ========================================4
;�Ҵ��� =========================================
;�Ҵ��� =========================================
Return
;<RightComments>: >>�Ҵ���: ��ʾ�ļ���ע{{{2
<RightComments>:
	SendPos(200)
Return
;<RightShort>: >>�Ҵ���: �б�{{{2
<RightShort>:
	SendPos(201)
Return
;<RightLong>: >> ��ϸ��Ϣ{{{2
<RightLong>:
	SendPos(202)
Return
;<RightTre>: >>	�Ҵ���: �ļ�����{{{2
<RightTre>:
		SendPos(203)
Return
;<RightQuickvie>: >>	�Ҵ���: ���ٲ鿴{{{2
<RightQuickvie>:
		SendPos(204)
Return
;<RightQuickInternalOnl>: >>	�Ҵ���: ���ٲ鿴(���ò��){{{2
<RightQuickInternalOnl>:
		SendPos(206)
Return
;<RightHideQuickvie>: >>	�Ҵ���: �رտ��ٲ鿴����{{{2
<RightHideQuickvie>:
		SendPos(207)
Return
;<RightExec>: >>	�Ҵ���: ��ִ���ļ�{{{2
<RightExec>:
		SendPos(211)
Return
;<RightAllFile>: >>	�Ҵ���: �����ļ�{{{2
<RightAllFile>:
		SendPos(212)
Return
;<RightUserSpe>: >>	�Ҵ���: �ϴ�ѡ�е��ļ�{{{2
<RightUserSpe>:
		SendPos(213)
Return
;<RightUserDe>: >>	�Ҵ���: �Զ�������{{{2
<RightUserDe>:
		SendPos(214)
Return
;<RightByNam>: >>	�Ҵ���: ���ļ�������{{{2
<RightByNam>:
		SendPos(221)
Return
;<RightByEx>: >>	�Ҵ���: ����չ������{{{2
<RightByEx>:
		SendPos(222)
Return
;<RightBySiz>: >>	�Ҵ���: ����С����{{{2
<RightBySiz>:
		SendPos(223)
Return
;<RightByDateTim>: >>	�Ҵ���: ������ʱ������{{{2
<RightByDateTim>:
		SendPos(224)
Return
;<RightUnsorte>: >>	�Ҵ���: ������{{{2
<RightUnsorte>:
		SendPos(225)
Return
;<RightNegOrde>: >>	�Ҵ���: ��������{{{2
<RightNegOrde>:
		SendPos(230)
Return
;<RightOpenDrive>: >>	�Ҵ���: ���������б�{{{2
<RightOpenDrive>:
		SendPos(231)
Return
;<RightPathFocu>: >>	�Ҵ���: ��������·����{{{2
<RightPathFocu>:
		SendPos(232)
Return
;<RightDirBranch>: >>�Ҵ���: չ�������ļ���{{{2
<RightDirBranch>:
	SendPos(2035)
Return
;<RightDirBranchSel>: >>�Ҵ���: ֻչ��ѡ�е��ļ���{{{2
<RightDirBranchSel>:
	SendPos(2048)
Return
;<RightThumb>: >>	�Ҵ���: ����ͼ{{{2
<RightThumb>:
		SendPos(169)
Return
;<RightCustomViewMen>: >>	�Ҵ���: �Զ�����ͼ�˵�{{{2
<RightCustomViewMen>:
		SendPos(170)
Return
;�ļ����� ========================================4
;�ļ����� =========================================
;�ļ����� =========================================
Return
;<Lis>: >>	�鿴(�ò鿴����){{{2
<Lis>:
		SendPos(903)
Return
;<ListInternalOnly>: >>�鿴(�ò鿴����, �����ò��/��ý��){{{2
<ListInternalOnly>:
	SendPos(1006)
Return
;<Edi>: >>	�༭{{{2
<Edi>:
		SendPos(904)
Return
;<Copy>: >>����{{{2
<Copy>:
	SendPos(905)
Return
;<CopySamepanel>: >>���Ƶ���ǰ����{{{2
<CopySamepanel>:
	SendPos(3100)
Return
;<CopyOtherpanel>: >>���Ƶ���һ����{{{2
<CopyOtherpanel>:
	SendPos(3101)
Return
;<RenMov>: >>������/�ƶ�{{{2
<RenMov>:
	SendPos(906)
Return
;<MkDir>: >>�½��ļ���{{{2
<MkDir>:
	SendPos(907)
Return
;<Delete>: >>ɾ��{{{2
<Delete>:
	SendPos(908)
Return
;<TestArchive>: >>����ѹ����{{{2
<TestArchive>:
	SendPos(518)
Return
;<PackFiles>: >>ѹ���ļ�{{{2
<PackFiles>:
	SendPos(508)
Return
;<UnpackFiles>: >>��ѹ�ļ�{{{2
<UnpackFiles>:
	SendPos(509)
Return
;<RenameOnly>: >>������(Shift+F6){{{2
<RenameOnly>:
	SendPos(1002)
Return
;<RenameSingleFile>: >>��������ǰ�ļ�{{{2
<RenameSingleFile>:
	SendPos(1007)
Return
;<MoveOnly>: >>�ƶ�(F6){{{2
<MoveOnly>:
	SendPos(1005)
Return
;<Properties>: >>��ʾ����{{{2
<Properties>:
	SendPos(1003)
Return
;<CreateShortcut>: >>������ݷ�ʽ{{{2
<CreateShortcut>:
	SendPos(1004)
Return
;<Return>: >>ģ�°� ENTER ��{{{2
<Return>:
	SendPos(1001)
Return
;<OpenAsUser>: >>�������û�������й�괦�ĳ���{{{2
<OpenAsUser>:
	SendPos(2800)
Return
;<Split>: >>�ָ��ļ�{{{2
<Split>:
	SendPos(560)
Return
;<Combine>: >>�ϲ��ļ�{{{2
<Combine>:
	SendPos(561)
Return
;<Encode>: >>�����ļ�(MIME/UUE/XXE ��ʽ){{{2
<Encode>:
	SendPos(562)
Return
;<Decode>: >>�����ļ�(MIME/UUE/XXE/BinHex ��ʽ){{{2
<Decode>:
	SendPos(563)
Return
;<CRCcreate>: >>����У���ļ�{{{2
<CRCcreate>:
	SendPos(564)
Return
;<CRCcheck>: >>��֤У���{{{2
<CRCcheck>:
	SendPos(565)
Return
;<SetAttrib>: >>��������{{{2
<SetAttrib>:
	SendPos(502)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<Config>: >>����: ����{{{2
<Config>:
	SendPos(490)
Return
;<DisplayConfig>: >>����: ��ʾ{{{2
<DisplayConfig>:
	SendPos(486)
Return
;<IconConfig>: >>����: ͼ��{{{2
<IconConfig>:
	SendPos(477)
Return
;<FontConfig>: >>����: ����{{{2
<FontConfig>:
	SendPos(492)
Return
;<ColorConfig>: >>����: ��ɫ{{{2
<ColorConfig>:
	SendPos(494)
Return
;<ConfTabChange>: >>����: �Ʊ��{{{2
<ConfTabChange>:
	SendPos(497)
Return
;<DirTabsConfig>: >>����: �ļ��б�ǩ{{{2
<DirTabsConfig>:
	SendPos(488)
Return
;<CustomColumnConfig>: >>����: �Զ�����{{{2
<CustomColumnConfig>:
	SendPos(483)
Return
;<CustomColumnDlg>: >>���ĵ�ǰ�Զ�����{{{2
<CustomColumnDlg>:
	SendPos(2920)
Return
;<LanguageConfig>: >>����: ����{{{2
<LanguageConfig>:
	SendPos(499)
Return
;<Config2>: >>����: ������ʽ{{{2
<Config2>:
	SendPos(516)
Return
;<EditConfig>: >>����: �༭/�鿴{{{2
<EditConfig>:
	SendPos(496)
Return
;<CopyConfig>: >>����: ����/ɾ��{{{2
<CopyConfig>:
	SendPos(487)
Return
;<RefreshConfig>: >>����: ˢ��{{{2
<RefreshConfig>:
	SendPos(478)
Return
;<QuickSearchConfig>: >>����: ��������{{{2
<QuickSearchConfig>:
	SendPos(479)
Return
;<FtpConfig>: >>����: FTP{{{2
<FtpConfig>:
	SendPos(489)
Return
;<PluginsConfig>: >>����: ���{{{2
<PluginsConfig>:
	SendPos(484)
Return
;<ThumbnailsConfig>: >>����: ����ͼ{{{2
<ThumbnailsConfig>:
	SendPos(482)
Return
;<LogConfig>: >>����: ��־�ļ�{{{2
<LogConfig>:
	SendPos(481)
Return
;<IgnoreConfig>: >>����: �����ļ�{{{2
<IgnoreConfig>:
	SendPos(480)
Return
;<PackerConfig>: >>����: ѹ������{{{2
<PackerConfig>:
	SendPos(491)
Return
;<ZipPackerConfig>: >>����: ZIP ѹ������{{{2
<ZipPackerConfig>:
	SendPos(485)
Return
;<Confirmation>: >>����: ����/ȷ��{{{2
<Confirmation>:
	SendPos(495)
Return
;<ConfigSavePos>: >>����λ��{{{2
<ConfigSavePos>:
	SendPos(493)
Return
;<ButtonConfig>: >>���Ĺ�����{{{2
<ButtonConfig>:
	SendPos(498)
Return
;<ConfigSaveSettings>: >>��������{{{2
<ConfigSaveSettings>:
	SendPos(580)
Return
;<ConfigChangeIniFiles>: >>ֱ���޸������ļ�{{{2
<ConfigChangeIniFiles>:
	SendPos(581)
Return
;<ConfigSaveDirHistory>: >>�����ļ�����ʷ��¼{{{2
<ConfigSaveDirHistory>:
	SendPos(582)
Return
;<ChangeStartMenu>: >>���Ŀ�ʼ�˵�{{{2
<ChangeStartMenu>:
	SendPos(700)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<NetConnect>: >>ӳ������������{{{2
<NetConnect>:
	SendPos(512)
Return
;<NetDisconnect>: >>�Ͽ�����������{{{2
<NetDisconnect>:
	SendPos(513)
Return
;<NetShareDir>: >>����ǰ�ļ���{{{2
<NetShareDir>:
	SendPos(514)
Return
;<NetUnshareDir>: >>ȡ���ļ��й���{{{2
<NetUnshareDir>:
	SendPos(515)
Return
;<AdministerServer>: >>��ʾϵͳ�����ļ���{{{2
<AdministerServer>:
	SendPos(2204)
Return
;<ShowFileUser>: >>��ʾ�����ļ���Զ���û�{{{2
<ShowFileUser>:
	SendPos(2203)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<GetFileSpace>: >>����ռ�ÿռ�{{{2
<GetFileSpace>:
	SendPos(503)
Return
;<VolumeId>: >>���þ��{{{2
<VolumeId>:
	SendPos(505)
Return
;<VersionInfo>: >>�汾��Ϣ{{{2
<VersionInfo>:
	SendPos(510)
Return
;<ExecuteDOS>: >>��������ʾ������{{{2
<ExecuteDOS>:
    SendInput ^g
	;SendPos(511)
Return
;<CompareDirs>: >>�Ƚ��ļ���{{{2
<CompareDirs>:
	SendPos(533)
Return
;<CompareDirsWithSubdirs>: >>�Ƚ��ļ���(ͬʱ�����һ����û�е����ļ���){{{2
<CompareDirsWithSubdirs>:
	SendPos(536)
Return
;<ContextMenu>: >>��ʾ��ݲ˵�{{{2
<ContextMenu>:
	SendPos(2500)
Return
;<ContextMenuInternal>: >>��ʾ��ݲ˵�(�ڲ�����){{{2
<ContextMenuInternal>:
	SendPos(2927)
Return
;<ContextMenuInternalCursor>: >>��ʾ��괦�ļ����ڲ�������ݲ˵�{{{2
<ContextMenuInternalCursor>:
	SendPos(2928)
Return
;<ShowRemoteMenu>: >>ý������ң��������/��ͣ����ݲ˵�{{{2
<ShowRemoteMenu>:
	SendPos(2930)
Return
;<SyncChangeDir>: >>���ߴ���ͬ�������ļ���{{{2
<SyncChangeDir>:
	SendPos(2600)
Return
;<EditComment>: >>�༭�ļ���ע{{{2
<EditComment>:
	SendPos(2700)
Return
;<FocusLeft>: >>���������󴰿�{{{2
<FocusLeft>:
	SendPos(4001)
Return
;<FocusRight>: >>���������Ҵ���{{{2
<FocusRight>:
	SendPos(4002)
Return
;<FocusCmdLine>: >>��������������{{{2
<FocusCmdLine>:
	SendPos(4003)
Return
;<FocusButtonBar>: >>�������ڹ�����{{{2
<FocusButtonBar>:
	SendPos(4004)
Return
;<CountDirContent>: >>���������ļ���ռ�õĿռ�{{{2
<CountDirContent>:
	SendPos(2014)
Return
;<UnloadPlugins>: >>ж�����в��{{{2
<UnloadPlugins>:
	SendPos(2913)
Return
;<DirMatch>: >>������ļ�, ������ͬ��{{{2
<DirMatch>:
	SendPos(534)
Return
;<Exchange>: >>�������Ҵ���{{{2
<Exchange>:
	SendPos(531)
Return
;<MatchSrc>: >>Ŀ�� = ��Դ{{{2
<MatchSrc>:
	SendPos(532)
Return
;<ReloadSelThumbs>: >>ˢ��ѡ���ļ�������ͼ{{{2
<ReloadSelThumbs>:
	SendPos(2918)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<DirectCableConnect>: >>ֱ�ӵ�������{{{2
<DirectCableConnect>:
	SendPos(2300)
Return
;<NTinstallDriver>: >>���� NT ������������{{{2
<NTinstallDriver>:
	SendPos(2301)
Return
;<NTremoveDriver>: >>ж�� NT ������������{{{2
<NTremoveDriver>:
	SendPos(2302)
Return
;��ӡ ========================================4
;��ӡ =========================================
;��ӡ =========================================
Return
;<PrintDir>: >>��ӡ�ļ��б�{{{2
<PrintDir>:
	SendPos(2027)
Return
;<PrintDirSub>: >>��ӡ�ļ��б�(�����ļ���){{{2
<PrintDirSub>:
	SendPos(2028)
Return
;<PrintFile>: >>��ӡ�ļ�����{{{2
<PrintFile>:
	SendPos(504)
Return
;ѡ�� ========================================4
;ѡ�� =========================================
;ѡ�� =========================================
Return
;<SpreadSelection>: >>ѡ��һ���ļ�{{{2
<SpreadSelection>:
	SendPos(521)
Return
;<SelectBoth>: >>ѡ��һ��: �ļ����ļ���{{{2
<SelectBoth>:
	SendPos(3311)
Return
;<SelectFiles>: >>ѡ��һ��: ���ļ�{{{2
<SelectFiles>:
	SendPos(3312)
Return
;<SelectFolders>: >>ѡ��һ��: ���ļ���{{{2
<SelectFolders>:
	SendPos(3313)
Return
;<ShrinkSelection>: >>��ѡһ���ļ�{{{2
<ShrinkSelection>:
	SendPos(522)
Return
;<ClearFiles>: >>��ѡһ��: ���ļ�{{{2
<ClearFiles>:
	SendPos(3314)
Return
;<ClearFolders>: >>��ѡһ��: ���ļ���{{{2
<ClearFolders>:
	SendPos(3315)
Return
;<ClearSelCfg>: >>��ѡһ��: �ļ���/���ļ���(�����ö���){{{2
<ClearSelCfg>:
	SendPos(3316)
Return
;<SelectAll>: >>ȫ��ѡ��: �ļ���/���ļ���(�����ö���){{{2
<SelectAll>:
	SendPos(523)
Return
;<SelectAllBoth>: >>ȫ��ѡ��: �ļ����ļ���{{{2
<SelectAllBoth>:
	SendPos(3301)
Return
;<SelectAllFiles>: >>ȫ��ѡ��: ���ļ�{{{2
<SelectAllFiles>:
	SendPos(3302)
Return
;<SelectAllFolders>: >>ȫ��ѡ��: ���ļ���{{{2
<SelectAllFolders>:
	SendPos(3303)
Return
;<ClearAll>: >>ȫ��ȡ��: �ļ����ļ���{{{2
<ClearAll>:
	SendPos(524)
Return
;<ClearAllFiles>: >>ȫ��ȡ��: ���ļ�{{{2
<ClearAllFiles>:
	SendPos(3304)
Return
;<ClearAllFolders>: >>ȫ��ȡ��: ���ļ���{{{2
<ClearAllFolders>:
	SendPos(3305)
Return
;<ClearAllCfg>: >>ȫ��ȡ��: �ļ���/���ļ���(�����ö���){{{2
<ClearAllCfg>:
	SendPos(3306)
Return
;<ExchangeSelection>: >>����ѡ��{{{2
<ExchangeSelection>:
	SendPos(525)
Return
;<ExchangeSelBoth>: >>����ѡ��: �ļ����ļ���{{{2
<ExchangeSelBoth>:
	SendPos(3321)
Return
;<ExchangeSelFiles>: >>����ѡ��: ���ļ�{{{2
<ExchangeSelFiles>:
	SendPos(3322)
Return
;<ExchangeSelFolders>: >>����ѡ��: ���ļ���{{{2
<ExchangeSelFolders>:
	SendPos(3323)
Return
;<SelectCurrentExtension>: >>ѡ����չ����ͬ���ļ�{{{2
<SelectCurrentExtension>:
	SendPos(527)
Return
;<UnselectCurrentExtension>: >>��ѡ��չ����ͬ���ļ�{{{2
<UnselectCurrentExtension>:
	SendPos(528)
Return
;<SelectCurrentName>: >>ѡ���ļ�����ͬ���ļ�{{{2
<SelectCurrentName>:
	SendPos(541)
Return
;<UnselectCurrentName>: >>��ѡ�ļ�����ͬ���ļ�{{{2
<UnselectCurrentName>:
	SendPos(542)
Return
;<SelectCurrentNameExt>: >>ѡ���ļ�������չ����ͬ���ļ�{{{2
<SelectCurrentNameExt>:
	SendPos(543)
Return
;<UnselectCurrentNameExt>: >>��ѡ�ļ�������չ����ͬ���ļ�{{{2
<UnselectCurrentNameExt>:
	SendPos(544)
Return
;<SelectCurrentPath>: >>ѡ��ͬһ·���µ��ļ�(չ���ļ���+�����ļ�){{{2
<SelectCurrentPath>:
	SendPos(537)
Return
;<UnselectCurrentPath>: >>��ѡͬһ·���µ��ļ�(չ���ļ���+�����ļ�){{{2
<UnselectCurrentPath>:
	SendPos(538)
Return
;<RestoreSelection>: >>�ָ�ѡ���б�{{{2
<RestoreSelection>:
	SendPos(529)
Return
;<SaveSelection>: >>����ѡ���б�{{{2
<SaveSelection>:
	SendPos(530)
Return
;<SaveSelectionToFile>: >>����ѡ���б�{{{2
<SaveSelectionToFile>:
	SendPos(2031)
Return
;<SaveSelectionToFileA>: >>����ѡ���б�(ANSI){{{2
<SaveSelectionToFileA>:
	SendPos(2041)
Return
;<SaveSelectionToFileW>: >>����ѡ���б�(Unicode){{{2
<SaveSelectionToFileW>:
	SendPos(2042)
Return
;<SaveDetailsToFile>: >>������ϸ��Ϣ{{{2
<SaveDetailsToFile>:
	SendPos(2039)
Return
;<SaveDetailsToFileA>: >>������ϸ��Ϣ(ANSI){{{2
<SaveDetailsToFileA>:
	SendPos(2043)
Return
;<SaveDetailsToFileW>: >>������ϸ��Ϣ(Unicode){{{2
<SaveDetailsToFileW>:
	SendPos(2044)
Return
;<LoadSelectionFromFile>: >>����ѡ���б�(���ļ�){{{2
<LoadSelectionFromFile>:
	SendPos(2032)
Return
;<LoadSelectionFromClip>: >>����ѡ���б�(�Ӽ�����){{{2
<LoadSelectionFromClip>:
	SendPos(2033)
Return
;��ȫ ========================================4
;��ȫ =========================================
;��ȫ =========================================
Return
;<EditPermissionInfo>: >>����Ȩ��(NTFS){{{2
<EditPermissionInfo>:
	SendPos(2200)
Return
;<EditAuditInfo>: >>����ļ�(NTFS){{{2
<EditAuditInfo>:
	SendPos(2201)
Return
;<EditOwnerInfo>: >>��ȡ����Ȩ(NTFS){{{2
<EditOwnerInfo>:
	SendPos(2202)
Return
;������ ========================================4
;������ =========================================
;������ =========================================
Return
;<CutToClipboard>: >>����ѡ�е��ļ���������{{{2
<CutToClipboard>:
	SendPos(2007)
Return
;<CopyToClipboard>: >>����ѡ�е��ļ���������{{{2
<CopyToClipboard>:
	SendPos(2008)
Return
;<PasteFromClipboard>: >>�Ӽ�����ճ������ǰ�ļ���{{{2
<PasteFromClipboard>:
	SendPos(2009)
Return
;<CopyNamesToClip>: >>�����ļ���{{{2
<CopyNamesToClip>:
	SendPos(2017)
Return
;<CopyFullNamesToClip>: >>�����ļ���������·��{{{2
<CopyFullNamesToClip>:
	SendPos(2018)
Return
;<CopyNetNamesToClip>: >>�����ļ���������·��{{{2
<CopyNetNamesToClip>:
	SendPos(2021)
Return
;<CopySrcPathToClip>: >>������Դ·��{{{2
<CopySrcPathToClip>:
	SendPos(2029)
Return
;<CopyTrgPathToClip>: >>����Ŀ��·��{{{2
<CopyTrgPathToClip>:
	SendPos(2030)
Return
;<CopyFileDetailsToClip>: >>�����ļ���ϸ��Ϣ{{{2
<CopyFileDetailsToClip>:
	SendPos(2036)
Return
;<CopyFpFileDetailsToClip>: >>�����ļ���ϸ��Ϣ������·��{{{2
<CopyFpFileDetailsToClip>:
	SendPos(2037)
Return
;<CopyNetFileDetailsToClip>: >>�����ļ���ϸ��Ϣ������·��{{{2
<CopyNetFileDetailsToClip>:
	SendPos(2038)
Return
;FTP ========================================4
;FTP =========================================
;FTP =========================================
Return
;<FtpConnect>: >>FTP ����{{{2
<FtpConnect>:
	SendPos(550)
Return
;<FtpNew>: >>�½� FTP ����{{{2
<FtpNew>:
	SendPos(551)
Return
;<FtpDisconnect>: >>�Ͽ� FTP ����{{{2
<FtpDisconnect>:
	SendPos(552)
Return
;<FtpHiddenFiles>: >>��ʾ�����ļ�{{{2
<FtpHiddenFiles>:
	SendPos(553)
Return
;<FtpAbort>: >>��ֹ��ǰ FTP ����{{{2
<FtpAbort>:
	SendPos(554)
Return
;<FtpResumeDownload>: >>����{{{2
<FtpResumeDownload>:
	SendPos(555)
Return
;<FtpSelectTransferMode>: >>ѡ����ģʽ{{{2
<FtpSelectTransferMode>:
	SendPos(556)
Return
;<FtpAddToList>: >>��ӵ������б�{{{2
<FtpAddToList>:
	SendPos(557)
Return
;<FtpDownloadList>: >>���б�����{{{2
<FtpDownloadList>:
	SendPos(558)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<GotoPreviousDir>: >>����{{{2
<GotoPreviousDir>:
	SendPos(570)
Return
;<GotoNextDir>: >>ǰ��{{{2
<GotoNextDir>:
	SendPos(571)
Return
;<DirectoryHistory>: >>�ļ�����ʷ��¼{{{2
<DirectoryHistory>:
	SendPos(572)
Return
;<GotoPreviousLocalDir>: >>����(�� FTP){{{2
<GotoPreviousLocalDir>:
	SendPos(573)
Return
;<GotoNextLocalDir>: >>ǰ��(�� FTP){{{2
<GotoNextLocalDir>:
	SendPos(574)
Return
;<DirectoryHotlist>: >>�����ļ���{{{2
<DirectoryHotlist>:
	SendPos(526)
Return
;<GoToRoot>: >>ת�����ļ���{{{2
<GoToRoot>:
	SendPos(2001)
Return
;<GoToParent>: >>ת���ϲ��ļ���{{{2
<GoToParent>:
	SendPos(2002)
Return
;<GoToDir>: >>�򿪹�괦���ļ��л�ѹ����{{{2
<GoToDir>:
	SendPos(2003)
Return
;<OpenDesktop>: >>����{{{2
<OpenDesktop>:
	SendPos(2121)
Return
;<OpenDrives>: >>�ҵĵ���{{{2
<OpenDrives>:
	SendPos(2122)
Return
;<OpenControls>: >>�������{{{2
<OpenControls>:
	SendPos(2123)
Return
;<OpenFonts>: >>����{{{2
<OpenFonts>:
	SendPos(2124)
Return
;<OpenNetwork>: >>�����ھ�{{{2
<OpenNetwork>:
	SendPos(2125)
Return
;<OpenPrinters>: >>��ӡ��{{{2
<OpenPrinters>:
	SendPos(2126)
Return
;<OpenRecycled>: >>����վ{{{2
<OpenRecycled>:
	SendPos(2127)
Return
;<CDtree>: >>�����ļ���{{{2
<CDtree>:
	SendPos(500)
Return
;<TransferLeft>: >>���󴰿ڴ򿪹�괦���ļ��л�ѹ����{{{2
<TransferLeft>:
	SendPos(2024)
Return
;<TransferRight>: >>���Ҵ��ڴ򿪹�괦���ļ��л�ѹ����{{{2
<TransferRight>:
	SendPos(2025)
Return
;<EditPath>: >>�༭��Դ���ڵ�·��{{{2
<EditPath>:
	SendPos(2912)
Return
;<GoToFirstFile>: >>����Ƶ��б��еĵ�һ���ļ�{{{2
<GoToFirstFile>:
	SendPos(2050)
Return
;<GotoNextDrive>: >>ת����һ��������{{{2
<GotoNextDrive>:
	SendPos(2051)
Return
;<GotoPreviousDrive>: >>ת����һ��������{{{2
<GotoPreviousDrive>:
	SendPos(2052)
Return
;<GotoNextSelected>: >>ת����һ��ѡ�е��ļ�{{{2
<GotoNextSelected>:
	SendPos(2053)
Return
;<GotoPrevSelected>: >>ת����һ��ѡ�е��ļ�{{{2
<GotoPrevSelected>:
	SendPos(2054)
Return
;<GotoDriveA>: >>ת�������� A{{{2
<GotoDriveA>:
	SendPos(2061)
Return
;<GotoDriveC>: >>ת�������� C{{{2
<GotoDriveC>:
	SendPos(2063)
Return
;<GotoDriveD>: >>ת�������� D{{{2
<GotoDriveD>:
	SendPos(2064)
Return
;<GotoDriveE>: >>ת�������� E{{{2
<GotoDriveE>:
	SendPos(2065)
Return
;<GotoDriveF>: >>���Զ�������������{{{2
<GotoDriveF>:
	SendPos(2066)
Return
;<GotoDriveZ>: >>��� 26 ��{{{2
<GotoDriveZ>:
	SendPos(2086)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<HelpIndex>: >>��������{{{2
<HelpIndex>:
	SendPos(610)
Return
;<Keyboard>: >>��ݼ��б�{{{2
<Keyboard>:
	SendPos(620)
Return
;<Register>: >>ע����Ϣ{{{2
<Register>:
	SendPos(630)
Return
;<VisitHomepage>: >>���� Totalcmd ��վ{{{2
<VisitHomepage>:
	SendPos(640)
Return
;<About>: >>���� Total Commander{{{2
<About>:
	SendPos(690)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<Exit>: >>�˳� Total Commander{{{2
<Exit>:
	SendPos(24340)
Return
;<Minimize>: >>��С�� Total Commander{{{2
<Minimize>:
	SendPos(2000)
Return
;<Maximize>: >>��� Total Commander{{{2
<Maximize>:
	SendPos(2015)
Return
;<Restore>: >>�ָ�������С{{{2
<Restore>:
	SendPos(2016)
Return
;������ ========================================4
;������ =========================================
;������ =========================================
Return
;<ClearCmdLine>: >>���������{{{2
<ClearCmdLine>:
	SendPos(2004)
Return
;<NextCommand>: >>��һ������{{{2
<NextCommand>:
	SendPos(2005)
Return
;<PrevCommand>: >>��һ������{{{2
<PrevCommand>:
	SendPos(2006)
Return
;<AddPathToCmdline>: >>��·�����Ƶ�������{{{2
<AddPathToCmdline>:
	SendPos(2019)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<MultiRenameFiles>: >>����������{{{2
<MultiRenameFiles>:
	SendPos(2400)
Return
;<SysInfo>: >>ϵͳ��Ϣ{{{2
<SysInfo>:
	SendPos(506)
Return
;<OpenTransferManager>: >>��̨���������{{{2
<OpenTransferManager>:
	SendPos(559)
Return
;<SearchFor>: >>�����ļ�{{{2
<SearchFor>:
	SendPos(501)
Return
;<FileSync>: >>ͬ���ļ���{{{2
<FileSync>:
	SendPos(2020)
Return
;<Associate>: >>�ļ�����{{{2
<Associate>:
	SendPos(507)
Return
;<InternalAssociate>: >>�����ڲ�����{{{2
<InternalAssociate>:
	SendPos(519)
Return
;<CompareFilesByContent>: >>�Ƚ��ļ�����{{{2
<CompareFilesByContent>:
	SendPos(2022)
Return
;<IntCompareFilesByContent>: >>ʹ���ڲ��Ƚϳ���{{{2
<IntCompareFilesByContent>:
	SendPos(2040)
Return
;<CommandBrowser>: >>����ڲ�����{{{2
<CommandBrowser>:
	SendPos(2924)
Return
;��ͼ ========================================4
;��ͼ =========================================
;��ͼ =========================================
Return
;<VisButtonbar>: >>��ʾ/����: ������{{{2
<VisButtonbar>:
	SendPos(2901)
Return
;<VisDriveButtons>: >>��ʾ/����: ��������ť{{{2
<VisDriveButtons>:
	SendPos(2902)
Return
;<VisTwoDriveButtons>: >>��ʾ/����: ������������ť��{{{2
<VisTwoDriveButtons>:
	SendPos(2903)
Return
;<VisFlatDriveButtons>: >>�л�: ƽ̹/������������ť{{{2
<VisFlatDriveButtons>:
	SendPos(2904)
Return
;<VisFlatInterface>: >>�л�: ƽ̹/�����û�����{{{2
<VisFlatInterface>:
	SendPos(2905)
Return
;<VisDriveCombo>: >>��ʾ/����: �������б�{{{2
<VisDriveCombo>:
	SendPos(2906)
Return
;<VisCurDir>: >>��ʾ/����: ��ǰ�ļ���{{{2
<VisCurDir>:
	SendPos(2907)
Return
;<VisBreadCrumbs>: >>��ʾ/����: ·��������{{{2
<VisBreadCrumbs>:
	SendPos(2926)
Return
;<VisTabHeader>: >>��ʾ/����: �����Ʊ��{{{2
<VisTabHeader>:
	SendPos(2908)
Return
;<VisStatusbar>: >>��ʾ/����: ״̬��{{{2
<VisStatusbar>:
	SendPos(2909)
Return
;<VisCmdLine>: >>��ʾ/����: ������{{{2
<VisCmdLine>:
	SendPos(2910)
Return
;<VisKeyButtons>: >>��ʾ/����: ���ܼ���ť{{{2
<VisKeyButtons>:
	SendPos(2911)
Return
;<ShowHint>: >>��ʾ�ļ���ʾ{{{2
<ShowHint>:
	SendPos(2914)
Return
;<ShowQuickSearch>: >>��ʾ������������{{{2
<ShowQuickSearch>:
	SendPos(2915)
Return
;<SwitchLongNames>: >>����/�ر�: ���ļ�����ʾ{{{2
<SwitchLongNames>:
	SendPos(2010)
Return
;<RereadSource>: >>ˢ����Դ����{{{2
<RereadSource>:
	SendPos(540)
Return
;<ShowOnlySelected>: >>����ʾѡ�е��ļ�{{{2
<ShowOnlySelected>:
	SendPos(2023)
Return
;<SwitchHidSys>: >>����/�ر�: ���ػ�ϵͳ�ļ���ʾ{{{2
<SwitchHidSys>:
	SendPos(2011)
Return
;<Switch83Names>: >>����/�ر�: 8.3 ʽ�ļ���Сд��ʾ{{{2
<Switch83Names>:
	SendPos(2013)
Return
;<SwitchDirSort>: >>����/�ر�: �ļ��а���������{{{2
<SwitchDirSort>:
	SendPos(2012)
Return
;<DirBranch>: >>չ�������ļ���{{{2
<DirBranch>:
	SendPos(2026)
Return
;<DirBranchSel>: >>ֻչ��ѡ�е��ļ���{{{2
<DirBranchSel>:
	SendPos(2046)
Return
;<50Percent>: >>���ڷָ���λ�� 50%{{{2
<50Percent>:
	SendPos(909)
Return
;<100Percent>: >>���ڷָ���λ�� 100%{{{2
<100Percent>:
	SendPos(910)
Return
;<VisDirTabs>: >>��ʾ/����: �ļ��б�ǩ{{{2
<VisDirTabs>:
	SendPos(2916)
Return
;<VisXPThemeBackground>: >>��ʾ/����: XP ���ⱳ��{{{2
<VisXPThemeBackground>:
	SendPos(2923)
Return
;<SwitchOverlayIcons>: >>����/�ر�: ����ͼ����ʾ{{{2
<SwitchOverlayIcons>:
	SendPos(2917)
Return
;<VisHistHotButtons>: >>��ʾ/����: �ļ�����ʷ��¼�ͳ����ļ��а�ť{{{2
<VisHistHotButtons>:
	SendPos(2919)
Return
;<SwitchWatchDirs>: >>����/����: �ļ����Զ�ˢ��{{{2
<SwitchWatchDirs>:
	SendPos(2921)
Return
;<SwitchIgnoreList>: >>����/����: �Զ��������ļ�{{{2
<SwitchIgnoreList>:
	SendPos(2922)
Return
;<SwitchX64Redirection>: >>����/�ر�: 32 λ system32 Ŀ¼�ض���(64 λ Windows){{{2
<SwitchX64Redirection>:
	SendPos(2925)
Return
;<SeparateTreeOff>: >>�رն����ļ��������{{{2
<SeparateTreeOff>:
	SendPos(3200)
Return
;<SeparateTree1>: >>һ�������ļ��������{{{2
<SeparateTree1>:
	SendPos(3201)
Return
;<SeparateTree2>: >>���������ļ��������{{{2
<SeparateTree2>:
	SendPos(3202)
Return
;<SwitchSeparateTree>: >>�л������ļ��������״̬{{{2
<SwitchSeparateTree>:
	SendPos(3203)
Return
;<ToggleSeparateTree1>: >>����/�ر�: һ�������ļ��������{{{2
<ToggleSeparateTree1>:
	SendPos(3204)
Return
;<ToggleSeparateTree2>: >>����/�ر�: ���������ļ��������{{{2
<ToggleSeparateTree2>:
	SendPos(3205)
Return
;�û� ========================================4
;�û� =========================================
;�û� =========================================
Return
;<UserMenu1>: >>�û��˵� 1{{{2
<UserMenu1>:
	SendPos(701)
Return
;<UserMenu2>: >>�û��˵� 2{{{2
<UserMenu2>:
	SendPos(702)
Return
;<UserMenu3>: >>�û��˵� 3{{{2
<UserMenu3>:
	SendPos(703)
Return
;<UserMenu4>: >>...{{{2
<UserMenu4>:
	SendPos(704)
Return
;<UserMenu5>: >>5{{{2
<UserMenu5>:
	SendPos(70)
Return
;<UserMenu6>: >>6{{{2
<UserMenu6>:
	SendPos(70)
Return
;<UserMenu7>: >>7{{{2
<UserMenu7>:
	SendPos(70)
Return
;<UserMenu8>: >>8{{{2
<UserMenu8>:
	SendPos(70)
Return
;<UserMenu9>: >>9{{{2
<UserMenu9>:
	SendPos(70)
Return
;<UserMenu10>: >>�ɶ��������û��˵�{{{2
<UserMenu10>:
	SendPos(710)
Return
;��ǩ ========================================4
;��ǩ =========================================
;��ǩ =========================================
Return
;<OpenNewTab>: >>�½���ǩ{{{2
<OpenNewTab>:
	SendPos(3001)
Return
;<OpenNewTabBg>: >>�½���ǩ(�ں�̨){{{2
<OpenNewTabBg>:
	SendPos(3002)
Return
;<OpenDirInNewTab>: >>�½���ǩ(���򿪹�괦���ļ���){{{2
<OpenDirInNewTab>:
	SendPos(3003)
Return
;<OpenDirInNewTabOther>: >>�½���ǩ(����һ���ڴ��ļ���){{{2
<OpenDirInNewTabOther>:
	SendPos(3004)
Return
;<SwitchToNextTab>: >>��һ����ǩ(Ctrl+Tab){{{2
<SwitchToNextTab>:
	SendPos(3005)
Return
;<SwitchToPreviousTab>: >>��һ����ǩ(Ctrl+Shift+Tab){{{2
<SwitchToPreviousTab>:
	SendPos(3006)
Return
;<CloseCurrentTab>: >>�رյ�ǰ��ǩ{{{2
<CloseCurrentTab>:
	SendPos(3007)
Return
;<CloseAllTabs>: >>�ر����б�ǩ{{{2
<CloseAllTabs>:
	SendPos(3008)
Return
;<DirTabsShowMenu>: >>��ʾ��ǩ�˵�{{{2
<DirTabsShowMenu>:
	SendPos(3009)
Return
;<ToggleLockCurrentTab>: >>����/������ǰ��ǩ{{{2
<ToggleLockCurrentTab>:
	SendPos(3010)
Return
;<ToggleLockDcaCurrentTab>: >>����/������ǰ��ǩ(�ɸ����ļ���){{{2
<ToggleLockDcaCurrentTab>:
	SendPos(3012)
Return
;<ExchangeWithTabs>: >>�������Ҵ��ڼ����ǩ{{{2
<ExchangeWithTabs>:
	SendPos(535)
Return
;<GoToLockedDir>: >>ת��������ǩ�ĸ��ļ���{{{2
<GoToLockedDir>:
	SendPos(3011)
Return
;<SrcActivateTab1>: >>��Դ����: �����ǩ 1{{{2
<SrcActivateTab1>:
	SendPos(5001)
Return
;<SrcActivateTab2>: >>��Դ����: �����ǩ 2{{{2
<SrcActivateTab2>:
	SendPos(5002)
Return
;<SrcActivateTab3>: >>...{{{2
<SrcActivateTab3>:
	SendPos(5003)
Return
;<SrcActivateTab4>: >>��� 99 ��{{{2
<SrcActivateTab4>:
	SendPos(5004)
Return
;<SrcActivateTab5>: >>5{{{2
<SrcActivateTab5>:
	SendPos(5005)
Return
;<SrcActivateTab6>: >>6{{{2
<SrcActivateTab6>:
	SendPos(5006)
Return
;<SrcActivateTab7>: >>7{{{2
<SrcActivateTab7>:
	SendPos(5007)
Return
;<SrcActivateTab8>: >>8{{{2
<SrcActivateTab8>:
	SendPos(5008)
Return
;<SrcActivateTab9>: >>9{{{2
<SrcActivateTab9>:
	SendPos(5009)
Return
;<SrcActivateTab10>: >>0{{{2
<SrcActivateTab10>:
	SendPos(5010)
Return
;<TrgActivateTab1>: >>Ŀ�괰��: �����ǩ 1{{{2
<TrgActivateTab1>:
	SendPos(5101)
Return
;<TrgActivateTab2>: >>Ŀ�괰��: �����ǩ 2{{{2
<TrgActivateTab2>:
	SendPos(5102)
Return
;<TrgActivateTab3>: >>...{{{2
<TrgActivateTab3>:
	SendPos(5103)
Return
;<TrgActivateTab4>: >>��� 99 ��{{{2
<TrgActivateTab4>:
	SendPos(5104)
Return
;<TrgActivateTab5>: >>5{{{2
<TrgActivateTab5>:
	SendPos(5105)
Return
;<TrgActivateTab6>: >>6{{{2
<TrgActivateTab6>:
	SendPos(5106)
Return
;<TrgActivateTab7>: >>7{{{2
<TrgActivateTab7>:
	SendPos(5107)
Return
;<TrgActivateTab8>: >>8{{{2
<TrgActivateTab8>:
	SendPos(5108)
Return
;<TrgActivateTab9>: >>9{{{2
<TrgActivateTab9>:
	SendPos(5109)
Return
;<TrgActivateTab10>: >>0{{{2
<TrgActivateTab10>:
	SendPos(5110)
Return
;<LeftActivateTab1>: >>�󴰿�: �����ǩ 1{{{2
<LeftActivateTab1>:
	SendPos(5201)
Return
;<LeftActivateTab2>: >>�󴰿�: �����ǩ 2{{{2
<LeftActivateTab2>:
	SendPos(5202)
Return
;<LeftActivateTab3>: >>...{{{2
<LeftActivateTab3>:
	SendPos(5203)
Return
;<LeftActivateTab4>: >>��� 99 ��{{{2
<LeftActivateTab4>:
	SendPos(5204)
Return
;<LeftActivateTab5>: >>5{{{2
<LeftActivateTab5>:
	SendPos(5205)
Return
;<LeftActivateTab6>: >>6{{{2
<LeftActivateTab6>:
	SendPos(5206)
Return
;<LeftActivateTab7>: >>7{{{2
<LeftActivateTab7>:
	SendPos(5207)
Return
;<LeftActivateTab8>: >>8{{{2
<LeftActivateTab8>:
	SendPos(5208)
Return
;<LeftActivateTab9>: >>9{{{2
<LeftActivateTab9>:
	SendPos(5209)
Return
;<LeftActivateTab10>: >>0{{{2
<LeftActivateTab10>:
	SendPos(5210)
Return
;<RightActivateTab1>: >>�Ҵ���: �����ǩ 1{{{2
<RightActivateTab1>:
	SendPos(5301)
Return
;<RightActivateTab2>: >>�Ҵ���: �����ǩ 2{{{2
<RightActivateTab2>:
	SendPos(5302)
Return
;<RightActivateTab3>: >>...{{{2
<RightActivateTab3>:
	SendPos(5303)
Return
;<RightActivateTab4>: >>��� 99 ��{{{2
<RightActivateTab4>:
	SendPos(5304)
Return
;<RightActivateTab5>: >>5{{{2
<RightActivateTab5>:
	SendPos(5305)
Return
;<RightActivateTab6>: >>6{{{2
<RightActivateTab6>:
	SendPos(5306)
Return
;<RightActivateTab7>: >>7{{{2
<RightActivateTab7>:
	SendPos(5307)
Return
;<RightActivateTab8>: >>8{{{2
<RightActivateTab8>:
	SendPos(5308)
Return
;<RightActivateTab9>: >>9{{{2
<RightActivateTab9>:
	SendPos(5309)
Return
;<RightActivateTab10>: >>0{{{2
<RightActivateTab10>:
	SendPos(5310)
Return
;���� ========================================4
;���� =========================================
;���� =========================================
Return
;<SrcSortByCol1>: >>��Դ����: ���� 1 ������{{{2
<SrcSortByCol1>:
	SendPos(6001)
Return
;<SrcSortByCol2>: >>��Դ����: ���� 2 ������{{{2
<SrcSortByCol2>:
	SendPos(6002)
Return
;<SrcSortByCol3>: >>...{{{2
<SrcSortByCol3>:
	SendPos(6003)
Return
;<SrcSortByCol4>: >>��� 99 ��{{{2
<SrcSortByCol4>:
	SendPos(6004)
Return
;<SrcSortByCol5>: >>5{{{2
<SrcSortByCol5>:
	SendPos(6005)
Return
;<SrcSortByCol6>: >>6{{{2
<SrcSortByCol6>:
	SendPos(6006)
Return
;<SrcSortByCol7>: >>7{{{2
<SrcSortByCol7>:
	SendPos(6007)
Return
;<SrcSortByCol8>: >>8{{{2
<SrcSortByCol8>:
	SendPos(6008)
Return
;<SrcSortByCol9>: >>9{{{2
<SrcSortByCol9>:
	SendPos(6009)
Return
;<SrcSortByCol10>: >>0{{{2
<SrcSortByCol10>:
	SendPos(6010)
Return
;<SrcSortByCol99>: >>9{{{2
<SrcSortByCol99>:
	SendPos(6099)
Return
;<TrgSortByCol1>: >>Ŀ�괰��: ���� 1 ������{{{2
<TrgSortByCol1>:
	SendPos(6101)
Return
;<TrgSortByCol2>: >>Ŀ�괰��: ���� 2 ������{{{2
<TrgSortByCol2>:
	SendPos(6102)
Return
;<TrgSortByCol3>: >>...{{{2
<TrgSortByCol3>:
	SendPos(6103)
Return
;<TrgSortByCol4>: >>��� 99 ��{{{2
<TrgSortByCol4>:
	SendPos(6104)
Return
;<TrgSortByCol5>: >>5{{{2
<TrgSortByCol5>:
	SendPos(6105)
Return
;<TrgSortByCol6>: >>6{{{2
<TrgSortByCol6>:
	SendPos(6106)
Return
;<TrgSortByCol7>: >>7{{{2
<TrgSortByCol7>:
	SendPos(6107)
Return
;<TrgSortByCol8>: >>8{{{2
<TrgSortByCol8>:
	SendPos(6108)
Return
;<TrgSortByCol9>: >>9{{{2
<TrgSortByCol9>:
	SendPos(6109)
Return
;<TrgSortByCol10>: >>0{{{2
<TrgSortByCol10>:
	SendPos(6110)
Return
;<TrgSortByCol99>: >>9{{{2
<TrgSortByCol99>:
	SendPos(6199)
Return
;<LeftSortByCol1>: >>�󴰿�: ���� 1 ������{{{2
<LeftSortByCol1>:
	SendPos(6201)
Return
;<LeftSortByCol2>: >>�󴰿�: ���� 2 ������{{{2
<LeftSortByCol2>:
	SendPos(6202)
Return
;<LeftSortByCol3>: >>...{{{2
<LeftSortByCol3>:
	SendPos(6203)
Return
;<LeftSortByCol4>: >>��� 99 ��{{{2
<LeftSortByCol4>:
	SendPos(6204)
Return
;<LeftSortByCol5>: >>5{{{2
<LeftSortByCol5>:
	SendPos(6205)
Return
;<LeftSortByCol6>: >>6{{{2
<LeftSortByCol6>:
	SendPos(6206)
Return
;<LeftSortByCol7>: >>7{{{2
<LeftSortByCol7>:
	SendPos(6207)
Return
;<LeftSortByCol8>: >>8{{{2
<LeftSortByCol8>:
	SendPos(6208)
Return
;<LeftSortByCol9>: >>9{{{2
<LeftSortByCol9>:
	SendPos(6209)
Return
;<LeftSortByCol10>: >>0{{{2
<LeftSortByCol10>:
	SendPos(6210)
Return
;<LeftSortByCol99>: >>9{{{2
<LeftSortByCol99>:
	SendPos(6299)
Return
;<RightSortByCol1>: >>�Ҵ���: ���� 1 ������{{{2
<RightSortByCol1>:
	SendPos(6301)
Return
;<RightSortByCol2>: >>�Ҵ���: ���� 2 ������{{{2
<RightSortByCol2>:
	SendPos(6302)
Return
;<RightSortByCol3>: >>...{{{2
<RightSortByCol3>:
	SendPos(6303)
Return
;<RightSortByCol4>: >>��� 99 ��{{{2
<RightSortByCol4>:
	SendPos(6304)
Return
;<RightSortByCol5>: >>5{{{2
<RightSortByCol5>:
	SendPos(6305)
Return
;<RightSortByCol6>: >>6{{{2
<RightSortByCol6>:
	SendPos(6306)
Return
;<RightSortByCol7>: >>7{{{2
<RightSortByCol7>:
	SendPos(6307)
Return
;<RightSortByCol8>: >>8{{{2
<RightSortByCol8>:
	SendPos(6308)
Return
;<RightSortByCol9>: >>9{{{2
<RightSortByCol9>:
	SendPos(6309)
Return
;<RightSortByCol10>: >>0{{{2
<RightSortByCol10>:
	SendPos(6310)
Return
;<RightSortByCol99>: >>9{{{2
<RightSortByCol99>:
	SendPos(6399)
Return
;�Զ�������ͼ ========================================4
;�Զ�������ͼ =========================================
;�Զ�������ͼ =========================================
Return
;<SrcCustomView1>: >>��Դ����: �Զ�������ͼ 1{{{2
<SrcCustomView1>:
	SendPos(271)
Return
;<SrcCustomView2>: >>��Դ����: �Զ�������ͼ 2{{{2
<SrcCustomView2>:
	SendPos(272)
Return
;<SrcCustomView3>: >>...{{{2
<SrcCustomView3>:
	SendPos(273)
Return
;<SrcCustomView4>: >>��� 29 ��{{{2
<SrcCustomView4>:
	SendPos(274)
Return
;<SrcCustomView5>: >>5{{{2
<SrcCustomView5>:
	SendPos(275)
Return
;<SrcCustomView6>: >>6{{{2
<SrcCustomView6>:
	SendPos(276)
Return
;<SrcCustomView7>: >>7{{{2
<SrcCustomView7>:
	SendPos(277)
Return
;<SrcCustomView8>: >>8{{{2
<SrcCustomView8>:
	SendPos(278)
Return
;<SrcCustomView9>: >>9{{{2
<SrcCustomView9>:
	SendPos(279)
Return
;<LeftCustomView1>: >>�󴰿�: �Զ�������ͼ 1{{{2
<LeftCustomView1>:
	SendPos(710)
Return
;<LeftCustomView2>: >>�󴰿�: �Զ�������ͼ 2{{{2
<LeftCustomView2>:
	SendPos(72)
Return
;<LeftCustomView3>: >>...{{{2
<LeftCustomView3>:
	SendPos(73)
Return
;<LeftCustomView4>: >>��� 29 ��{{{2
<LeftCustomView4>:
	SendPos(74)
Return
;<LeftCustomView5>: >>5{{{2
<LeftCustomView5>:
	SendPos(75)
Return
;<LeftCustomView6>: >>6{{{2
<LeftCustomView6>:
	SendPos(76)
Return
;<LeftCustomView7>: >>7{{{2
<LeftCustomView7>:
	SendPos(77)
Return
;<LeftCustomView8>: >>8{{{2
<LeftCustomView8>:
	SendPos(78)
Return
;<LeftCustomView9>: >>9{{{2
<LeftCustomView9>:
	SendPos(79)
Return
;<RightCustomView1>: >>�Ҵ���: �Զ�������ͼ 1{{{2
<RightCustomView1>:
	SendPos(171)
Return
;<RightCustomView2>: >>�Ҵ���: �Զ�������ͼ 2{{{2
<RightCustomView2>:
	SendPos(172)
Return
;<RightCustomView3>: >>...{{{2
<RightCustomView3>:
	SendPos(173)
Return
;<RightCustomView4>: >>��� 29 ��{{{2
<RightCustomView4>:
	SendPos(174)
Return
;<RightCustomView5>: >>5{{{2
<RightCustomView5>:
	SendPos(175)
Return
;<RightCustomView6>: >>6{{{2
<RightCustomView6>:
	SendPos(176)
Return
;<RightCustomView7>: >>7{{{2
<RightCustomView7>:
	SendPos(177)
Return
;<RightCustomView8>: >>8{{{2
<RightCustomView8>:
	SendPos(178)
Return
;<RightCustomView9>: >>9{{{2
<RightCustomView9>:
	SendPos(179)
Return
;<SrcNextCustomView>: >>��Դ����: ��һ���Զ�����ͼ{{{2
<SrcNextCustomView>:
	SendPos(5501)
Return
;<SrcPrevCustomView>: >>��Դ����: ��һ���Զ�����ͼ{{{2
<SrcPrevCustomView>:
	SendPos(5502)
Return
;<TrgNextCustomView>: >>Ŀ�괰��: ��һ���Զ�����ͼ{{{2
<TrgNextCustomView>:
	SendPos(5503)
Return
;<TrgPrevCustomView>: >>Ŀ�괰��: ��һ���Զ�����ͼ{{{2
<TrgPrevCustomView>:
	SendPos(5504)
Return
;<LeftNextCustomView>: >>�󴰿�: ��һ���Զ�����ͼ{{{2
<LeftNextCustomView>:
	SendPos(5505)
Return
;<LeftPrevCustomView>: >>�󴰿�: ��һ���Զ�����ͼ{{{2
<LeftPrevCustomView>:
	SendPos(5506)
Return
;<RightNextCustomView>: >>�Ҵ���: ��һ���Զ�����ͼ{{{2
<RightNextCustomView>:
	SendPos(5507)
Return
;<RightPrevCustomView>: >>�Ҵ���: ��һ���Զ�����ͼ{{{2
<RightPrevCustomView>:
	SendPos(5508)
Return
;<LoadAllOnDemandFields>: >>�����ļ���������ر�ע{{{2
<LoadAllOnDemandFields>:
	SendPos(5512)
Return
;<LoadSelOnDemandFields>: >>��ѡ�е��ļ�������ر�ע{{{2
<LoadSelOnDemandFields>:
	SendPos(5513)
Return
;<ContentStopLoadFields>: >>ֹͣ��̨���ر�ע{{{2
<ContentStopLoadFields>:
	SendPos(5514)
Return
