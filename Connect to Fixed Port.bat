@echo off
title scrcpy tcpip method
:: Set the target IP & Port
set IP=192.168.0.0
set PORT=5555

:: Restart adb (for Consistency)
echo [1/2] Resetting ADB Server
adb kill-server
adb start-server
adb connect %IP%:%PORT%

:: Start scrcpy
echo [2/2] Starting scrcpy
:: scrcpy-noconsole --tcpip=%IP%:%PORT% --no-audio --video-codec=h265 --max-fps=120 --video-bit-rate 16M
:: scrcpy-noconsole --tcpip=%IP%:%PORT% --no-video --audio-codec=aac --max-fps=120 --audio-bit-rate 256K --audio-buffer=40 --audio-output-buffer=10
scrcpy-noconsole --tcpip=%IP%:%PORT% --audio-codec=aac --max-fps=120 --audio-bit-rate 256K --audio-buffer=40 --audio-output-buffer=10 --video-codec=h265 --max-fps=120 --video-bit-rate 16M
timeout /t 1 /nobreak >nul
exit