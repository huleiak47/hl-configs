@echo off

set THEFILE=%HOME%\.ssh\config
if exist %THEFILE% del %THEFILE%

if not exist %HOME%\.ssh mkdir %HOME%\.ssh

mklink %THEFILE% %~dp0config
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp config %THEFILE%
