@echo off

if not exist %APPDATA%\GHISLER mkdir %APPDATA%\GHISLER

cp wincmd.ini %APPDATA%\GHISLER\wincmd.ini
cp usercmd.ini %APPDATA%\GHISLER\usercmd.ini
