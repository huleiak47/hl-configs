@echo off

if exist %USERPROFILE%\.gdbinit del %USERPROFILE%\.gdbinit

cp .gdbinit %USERPROFILE%\.gdbinit
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo so %~dp0init.py >> %USERPROFILE%\.gdbinit
