@echo off

if exist %USERPROFILE%\.zshrc del %USERPROFILE%\.zshrc

mklink %USERPROFILE%\.zshrc %~dp0.zshrc
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp .zshrc %USERPROFILE%\.zshrc
