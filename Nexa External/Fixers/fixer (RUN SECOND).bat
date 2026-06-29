@echo off
:: NexaSilence Fixer / Dependency Installer
:: Automates setup of VC++ redistributables and system configurations to prevent crashes.

echo Checking for Administrator privileges...
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as an Administrator.
    echo Please right-click this file and select "Run as administrator".
    pause
    exit /b 1
)

echo.
echo ====================================================
echo             Nexa System Fixer
echo ====================================================
echo.

:: 1. Install Microsoft Visual C++ Redistributable (2015-2022) X64
echo [*] Installing Microsoft Visual C++ Redistributable (X64)...
set "VC_REDIST_URL=https://aka.ms/vs/17/release/vc_redist.x64.exe"
set "TEMP_REDIST=%TEMP%\vc_redist.x64.exe"

curl -L -o "%TEMP_REDIST%" "%VC_REDIST_URL%"
if %errorlevel% neq 0 (
    echo [!] Failed to download VC++ Redistributable. Please check your internet.
) else (
    echo [*] Running VC++ Redistributable installer silently...
    start /wait "" "%TEMP_REDIST%" /passive /norestart
    echo [+] VC++ Redistributable installation complete.
)

:: 2. Check and disable Vulnerable Driver Blocklist (so kdmapper can load Intel driver)
echo.
echo [*] Checking Microsoft Vulnerable Driver Blocklist configuration...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v "VulnerableDriverBlocklistEnable" >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Disabling Vulnerable Driver Blocklist...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v "VulnerableDriverBlocklistEnable" /t REG_DWORD /d 0 /f >nul
    echo [+] Vulnerable Driver Blocklist disabled.
) else (
    echo [*] Creating Vulnerable Driver Blocklist disable key...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v "VulnerableDriverBlocklistEnable" /t REG_DWORD /d 0 /f >nul
    echo [+] Vulnerable Driver Blocklist disabled.
)

:: 3. Check and disable Core Isolation (HVCI) / Memory Integrity
echo.1)1)1)
echo [*] Checking Core Isolation (Memory Integrity) configuration...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled"') do (
        if "%%a"=="0x1" (
            echo [!] Core Isolation is enabled. Disabling it to allow driver mapping...
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f >nul
            echo [+] Core Isolation disabled. A system restart is REQUIRED.
            set "REBOOT_NEEDED=1"
        ) else (
            echo [+] Core Isolation is already disabled.
        )
    )
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f >nul
    echo [+] Core Isolation configured to disabled.
)

echo.
echo ====================================================
echo                  Fixing Complete! (Any other issues contact me on discord!)
echo ====================================================
echo.

if "%REBOOT_NEEDED%"=="1" (
    echo [!] A system restart is required for Core Isolation changes to take effect.
    choice /c YN /m "Would you like to restart your computer now"
    if errorlevel 2 (
        echo Please restart your computer manually before running Nex.exe.
        pause
    ) else (
        echo Restarting computer...
        shutdown /r /t 5 /c "Restarting for NexaSilence configuration"
    )
) else (
    echo [+] Everything is ready! You can now run Nex.exe as Administrator.
    pause
)