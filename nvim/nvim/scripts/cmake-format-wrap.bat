@echo off

cat >.cmake_format_temp.cmake

call cmake-format %* .cmake_format_temp.cmake

del /Q .cmake_format_temp.cmake
