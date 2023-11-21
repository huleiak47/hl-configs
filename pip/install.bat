@echo off

if not exist %USERPROFILE%\pip mkdir %USERPROFILE%\pip
if exist %USERPROFILE%\pip\pip.ini del %USERPROFILE%\pip\pip.ini

mklink %USERPROFILE%\pip\pip.ini %~dp0pip.ini
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp pip.ini %USERPROFILE%\pip\pip.ini
