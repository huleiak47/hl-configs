@echo off

set NAME=_pentadactylrc

if exist %HOME%\%NAME% del %HOME%\%NAME%
mklink %HOME%\%NAME% %~dp0%NAME%
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp %NAME% %HOME%\%NAME%
