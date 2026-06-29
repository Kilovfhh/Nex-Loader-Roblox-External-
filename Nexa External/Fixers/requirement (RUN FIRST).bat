@echo off
:: requirement.bat
:: Automates the download and setup of the Windows SDK and Windows Driver Kit (WDK) for build 26100.
:: Must be run as Administrator.

echo Checking for Administrator privileges...
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as an Administrator.
    echo Please right-click this file and select "Run as administrator".
    pause
    exit /b 1
)

echo.
echo Preparing to download Windows SDK and WDK (version 10.0.26100)...
echo.

set "SDK_URL=https://go.microsoft.com/fwlink/?linkid=2270082"
set "WDK_URL=https://go.microsoft.com/fwlink/?linkid=2271813"
set "TEMP_DIR=%TEMP%\DriverBuildTools"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo Downloading Windows SDK 10.0.26100 installer...
curl -L -o "%TEMP_DIR%\sdksetup.exe" "%SDK_URL%"
if %errorlevel% neq 0 (
    echo Failed to download Windows SDK. Please check your network connection.
    pause
    exit /b 1
)

echo Downloading Windows Driver Kit 10.0.26100 installer...
curl -L -o "%TEMP_DIR%\wdksetup.exe" "%WDK_URL%"
if %errorlevel% neq 0 (
    echo Failed to download WDK. Please check your network connection.
    pause
    exit /b 1
)

echo.
echo Launching Windows SDK Setup...
echo Please complete the SDK installation wizard.
start /wait "" "%TEMP_DIR%\sdksetup.exe"

echo.
echo Launching Windows Driver Kit (WDK) Setup...
echo Please complete the WDK installation wizard. Ensure the Visual Studio Extension option is enabled at the end.
start /wait "" "%TEMP_DIR%\wdksetup.exe"

echo.
echo Environment setup complete. Please restart Visual Studio and rebuild the project.
pause