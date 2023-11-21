@echo off

if exist %USERPROFILE%\.vsvimrc del %USERPROFILE%\.vsvimrc
mklink %USERPROFILE%\.vsvimrc %~dp0\vsvimrc.vim
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp vsvimrc.vim %USERPROFILE%\.vsvimrc
