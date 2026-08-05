@echo off
setlocal enabledelayedexpansion
title ADB Wireless Debugging method

:: Set the Target IP
set IP=192.168.0.0

:: Restart adb (for Consistency).
echo [1/3] Resetting ADB Server
adb kill-server
adb start-server

echo [2/3] Scanning via Nmap (32768-49999)...

:: Sweeps the port registry and processes EVERY open port found line-by-line
for /f "tokens=1 delims=/" %%A in ('nmap %IP% -p 32768-49999 --open --unprivileged 2^>nul ^| findstr /R "^[0-9]"') do (
    set "RAW_PORT=%%A"
    :: Strip trailing spaces
    set "DETECTED_PORT=!RAW_PORT: =!"
    
    if not "!DETECTED_PORT!"=="" (
        echo [+] Nmap found Port !DETECTED_PORT!.
        
        :: Attempt connection
        echo [~] Testing %IP%:!DETECTED_PORT!.
        adb connect %IP%:!DETECTED_PORT! | findstr /c:"connected" >nul
        
        if not errorlevel 1 (
            echo [^^!] Port !DETECTED_PORT! successful. Launching scrcpy.
            goto :SUCCESS_LAUNCH
        ) else (
            echo [X] Port !DETECTED_PORT! failed. Testing next Port.
        )
    )
)

echo.
echo Ensure "Wireless Debugging" is toggled ON and you are paired with this PC.
echo.
pause
exit

:SUCCESS_LAUNCH
echo.
echo [3/3] Starting scrcpy
:: scrcpy-noconsole --tcpip=%IP%:%PORT% --no-audio --video-codec=h265 --max-fps=120 --video-bit-rate 16M
:: scrcpy-noconsole --tcpip=%IP%:%PORT% --no-video --audio-codec=opus --max-fps=120 --audio-bit-rate 256K --audio-buffer=40 --audio-output-buffer=10
scrcpy-noconsole --tcpip=%IP%:!DETECTED_PORT! --audio-codec=opus --max-fps=120 --audio-bit-rate 256K --audio-buffer=40 --audio-output-buffer=10 --video-codec=h265 --max-fps=120 --video-bit-rate 16M
timeout /t 1 /nobreak >nul
exit
