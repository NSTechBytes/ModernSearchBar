@echo off
setlocal

rem Define the URL of the PowerShell script
set "scriptUrl=https://raw.githubusercontent.com/NSTechBytes/Projects-Templates/main/Update_Skins/Update_Helper.ps1"

rem Define a temporary file to store the script
set "tempScript=%temp%\Update_Helper.ps1"

rem Download the script using PowerShell
powershell -Command "Invoke-WebRequest -Uri '%scriptUrl%' -OutFile '%tempScript%'"

rem Run the downloaded script with the skinName parameter
powershell -ExecutionPolicy Bypass -File "%tempScript%" -skinName "ModernSearchBar"

rem Clean up the temporary script
del "%tempScript%"

pause
