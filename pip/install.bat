@echo off

if not exist %HOME%\pip mkdir %HOME%\pip
if exist %HOME%\pip\pip.ini del %HOME%\pip\pip.ini

mklink %HOME%\pip\pip.ini %~dp0pip.ini
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp pip.ini %HOME%\pip\pip.ini
