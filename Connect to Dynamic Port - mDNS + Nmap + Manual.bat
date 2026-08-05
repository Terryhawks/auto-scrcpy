@echo off
setlocal enabledelayedexpansion
title ADB Wireless Debugging method

:: Set the Target IP
set IP=192.168.0.0

:: Restart adb (for Consistency).
echo [1/3] Resetting ADB Server
adb kill-server
adb start-server

:: Wait 2 seconds for mDNS discovery.
timeout /t 2 /nobreak >nul

:: mDNS searches local network for any open ports
echo [2/3] Scanning via mDNS
for /f "tokens=1,2" %%a in ('adb mdns services') do (
    :: search for Target IP
    echo %%b | findstr /c:"%IP%:" >nul
    if not errorlevel 1 (
        :: Extract port number
        for /f "tokens=2 delims=:" %%p in ("%%b") do (
            set "DETECTED_PORT=%%p"
            echo [+] mDNS found Port !DETECTED_PORT!.
            
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
)

echo [!] mDNS found no valid ports. Proceeding to nmap
echo.
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

echo [!] NMap found no valid ports. Please input port Manually.
echo [#] Check Wireless Debugging for the IP address ^& port.
:MANUALPORT
set /p DETECTED_PORT="Wireless Debugging Port: "
if not defined DETECTED_PORT ( exit )
for /f "delims=0123456789" %%a in ("%DETECTED_PORT%") do (
    echo Error: "%DETECTED_PORT%" contains invalid characters. Must be digits only.
    pause
    goto MANUALPORT
)
if %DETECTED_PORT% LSS 1 (
    echo Error: Port number is too low. Must be 1-65535.
    pause
    goto MANUALPORT
)
if %DETECTED_PORT% GTR 65535 (
    echo Error: Port number is too high. Must be 1-65535.
    pause
    goto MANUALPORT
)
adb connect %IP%:!DETECTED_PORT! | findstr /c:"connected" >nul
if not errorlevel 1 (
    echo [^^!] Port !DETECTED_PORT! successful. Launching scrcpy.
) else (
    echo [X] Port !DETECTED_PORT! failed.
    goto MANUALPORT
)

:SUCCESS_LAUNCH
echo.
echo [3/3] Starting scrcpy
:: scrcpy-noconsole --tcpip=%IP%:%PORT% --no-audio --video-codec=h265 --max-fps=120 --video-bit-rate 16M
:: scrcpy-noconsole --tcpip=%IP%:%PORT% --no-video --audio-codec=opus --max-fps=120 --audio-bit-rate 256K --audio-buffer=40 --audio-output-buffer=10
scrcpy-noconsole --tcpip=%IP%:!DETECTED_PORT! --audio-codec=opus --max-fps=120 --audio-bit-rate 256K --audio-buffer=40 --audio-output-buffer=10 --video-codec=h265 --max-fps=120 --video-bit-rate 16M
timeout /t 1 /nobreak >nul
exit