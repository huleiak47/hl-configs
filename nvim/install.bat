rd /S /Q %LOCALAPPDATA%\nvim
REM rd /S /Q %LOCALAPPDATA%\nvim-data

mklink /D %LOCALAPPDATA%\nvim %~dp0\nvim

mklink /D %LOCALAPPDATA%\nvim\snippets %~dp0\..\vscode_user\snippets

REM mklink /D %LOCALAPPDATA%\nvim-data %~dp0\nvim-data
