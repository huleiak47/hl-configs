@echo off

if exist %HOME%\.vsvimrc del %HOME%\.vsvimrc
mklink %HOME%\.vsvimrc %~dp0\vsvimrc.vim
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp vsvimrc.vim %HOME%\.vsvimrc
