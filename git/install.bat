@echo off

if exist %HOME%\.gitconfig del %HOME%\.gitconfig

mklink %HOME%\.gitconfig %~dp0.gitconfig
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp .gitconfig %HOME%\.gitconfig
