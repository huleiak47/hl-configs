@echo off

if exist %HOME%\.emacs del %HOME%\.emacs

mklink %HOME%\.emacs %~dp0.emacs
if %ERRORLEVEL% NEQ 0 goto COPY
goto SNIPPETS

:COPY
cp .emacs %HOME%\.emacs

:SNIPPETS
if exist %HOME%\.emacs.d\snippets rmdir /Q /S %HOME%\.emacs.d\snippets

mklink /D %HOME%\.emacs.d\snippets %~dp0snippets
if %ERRORLEVEL% NEQ 0 goto COPY2
exit /b 0

:COPY2
cp snippets %HOME%\.emacs.d\
