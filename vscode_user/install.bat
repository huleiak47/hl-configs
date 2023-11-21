del /F %APPDATA%\Code\User\settings.json
del /F %APPDATA%\Code\User\keybindings.json

mklink %APPDATA%\Code\User\settings.json %~dp0\settings.json
mklink %APPDATA%\Code\User\keybindings.json %~dp0\keybindings.json

rd /S /Q %APPDATA%\Code\User\snippets
mklink /D %APPDATA%\Code\User\snippets %~dp0\snippets
