@echo off

set THEFILE=%USERPROFILE%\.ssh\config
if exist %THEFILE% del %THEFILE%

if not exist %USERPROFILE%\.ssh mkdir %USERPROFILE%\.ssh

mklink %THEFILE% %~dp0config
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp config %THEFILE%
