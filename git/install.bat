@echo off

if exist %USERPROFILE%\.gitconfig del %USERPROFILE%\.gitconfig

mklink %USERPROFILE%\.gitconfig %~dp0.gitconfig
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp .gitconfig %USERPROFILE%\.gitconfig
