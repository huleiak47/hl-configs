
set CONFDIR=%APPDATA%\GHISLER

if not exist %CONFDIR% mkdir %CONFDIR%
if exist %CONFDIR%\WINCMD.INI del %CONFDIR%\WINCMD.INI
mklink %CONFDIR%\WINCMD.INI %~dp0WINCMD.INI
if %ERRORLEVEL% NEQ 0 cp %~dp0WINCMD.INI %CONFDIR%

if exist %CONFDIR%\usercmd.ini del %CONFDIR%\usercmd.ini
mklink %CONFDIR%\usercmd.ini %~dp0usercmd.ini
if %ERRORLEVEL% NEQ 0 cp %~dp0usercmd.ini %CONFDIR%
