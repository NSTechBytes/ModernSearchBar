function rmbang ($bang) {
    $RmAPI.Bang($bang)
}


Start-Sleep -Seconds 2
rmbang "[!ShowMeter UserName_Text][!UpdateMeter UserName_Text]"

Start-Sleep -Seconds 2

# Get the current Windows username
$currentUsername = [System.Environment]::UserName
# Output the username
Write-Host "The current Windows username is: $currentUsername"
rmbang "[!SetOption UserName_Text Text `"User Name is $currentUsername.`"][!SetOption UserName_Text MeterStyle User_Checked_1][!ShowMeter Language_Checked_Text][!UpdateMeter Language_Checked_Text][!UpdateMeter UserName_Text]"

Start-Sleep -Seconds 2

# Get the current language of the operating system
$currentLanguage = Get-WinSystemLocale
# Output the language
Write-Host "The current language of the OS is: $($currentLanguage.Name)"
rmbang "[!SetOption Language_Checked_Text Text `"current language of the OS is: $($currentLanguage.Name).`"][!SetOption Language_Checked_Text MeterStyle Language_Checked_1][!ShowMeter Checking_Ram_Text][!UpdateMeter Checking_Ram_Text][!UpdateMeter Language_Checked_Text]"

Start-Sleep -Seconds 2

# Get the total physical memory (RAM) in bytes
$totalMemoryBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
# Convert the total memory from bytes to gigabytes
$totalMemoryGB = [math]::Round($totalMemoryBytes / 1GB, 2)

# Check if the total memory is 2 GB or higher
if ($totalMemoryGB -ge 2) {
    Write-Host "The system has 2 GB or more of RAM. Total RAM: $totalMemoryGB GB"
    rmbang "[!SetOption Checking_Ram_Text Text `"Total RAM: $totalMemoryGB GB`"][!SetOption Checking_Ram_Text MeterStyle Ram_Checked_1][!UpdateMeter Checking_Ram_Text][!ShowMeter OS_Version_Text][!UpdateMeter OS_Version_Text]"
} else {
    Write-Host "The system has less than 2 GB of RAM. Total RAM: $totalMemoryGB GB"
    rmbang "[!SetOption Checking_Ram_Text Text `"Total RAM: $totalMemoryGB GB Your Experience Might Be Effetced`"][!SetOption Checking_Ram_Text MeterStyle Ram_Checked_2][!UpdateMeter Checking_Ram_Text][!ShowMeter OS_Version_Text][!UpdateMeter OS_Version_Text]"
}
Start-Sleep -Seconds 2

# Get the OS version
$osVersion = [System.Environment]::OSVersion.Version

# Check if the OS is Windows 10 (version 10.0) or higher
if ($osVersion.Major -ge 10) {
    Write-Host "The OS version is Windows 10 or higher. Version: $osVersion"
    rmbang "[!SetOption OS_Version_Text Text `"Current Window Version: $osVersion`"][!SetOption OS_Version_Text MeterStyle  OS_Checked_1][!UpdateMeter OS_Version_Text][!ShowMeter Checking_GoogleChrome_Text][!UpdateMeter Checking_GoogleChrome_Text]"
} else {
    Write-Host "The OS version is lower than Windows 10. Version: $osVersion"
    rmbang "[!SetOption OS_Version_Text Text `"Current Window Version: $osVersion And This Not Support This Project.`"][!SetOption OS_Version_Text MeterStyle  OS_Checked_2][!UpdateMeter OS_Version_Text]"
}

Start-Sleep -Seconds 2
# Function to check Chrome in a specific registry path
function Check-ChromeInstall {
    param (
        [string]$registryPath
    )
    return Get-ChildItem -Path $registryPath | Where-Object { $_.PSChildName -like "*Google Chrome*" }
}

# Define registry paths to check for both system-wide and user-specific installations
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$chromeFound = $false

# Check all registry paths
foreach ($path in $registryPaths) {
    $chromeInstalled = Check-ChromeInstall -registryPath $path
    if ($chromeInstalled) {
        $chromeFound = $true
        break
    }
}

# Output the result
if ($chromeFound) {
    Write-Host "Google Chrome is installed."
    rmbang "[!SetOption Checking_GoogleChrome_Text Text `"Chrome is Installed.`"][!SetOption Checking_GoogleChrome_Text MeterStyle Chrome_Checked_1][!UpdateMeter Checking_GoogleChrome_Text][!ShowMeter Continue_Shape][!ShowMeter Continue_Text][!UpdateMeter Continue_Shape][!UpdateMeter Continue_Text]"
    
} else {
    Write-Host "Google Chrome is not installed."
    rmbang "[!SetOption Checking_GoogleChrome_Text Text `"Chrome is not Installed.This Skin Will Not Work.`"][!SetOption Checking_GoogleChrome_Text MeterStyle Chrome_Checked_2][!UpdateMeter Checking_GoogleChrome_Text][!ShowMeter Continue_Shape][!ShowMeter Continue_Text][!UpdateMeter Continue_Shape][!UpdateMeter Continue_Text]"
}


