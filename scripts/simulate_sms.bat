@echo off
echo ===================================================
echo   PAC App - Deep Link Simulator
echo ===================================================
echo.
echo This script simulates clicking a link in an SMS or Email
echo asking the user to pay Bill #1 (ComEd Electric).
echo.
echo ensuring device is connected...
adb devices
echo.
echo Sending Deep Link Intent (pac://procom26/maintenance/queue/1)...
echo.

adb shell am start -W -a android.intent.action.VIEW -d "pac://procom26/maintenance/queue/1" com.procom26.pac_app

echo.
echo ===================================================
echo   Check the device screen!
echo   You should see the "Queue Payment" screen.
echo ===================================================
pause
