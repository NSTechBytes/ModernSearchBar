function rmbang ($bang) {
    $RmAPI.Bang($bang)
}

function Update_Skin {
    $skinspath = $RmAPI.VariableStr('Skinspath')
    $skinName = $RmAPI.VariableStr('Skin.Name')

    # Hardcoded path to the BAT file
    $batFilePath = "$skinspath$skinName\@Resources\Scripts\Update_Helper.bat"

    # Check if the provided file exists
    if (-not (Test-Path $batFilePath)) {
        Write-Host "The specified .bat file does not exist."
        exit 1
    }

    # Set the destination path in C:\Windows\Temp
    $destBatFilePath = "C:\Windows\Temp\$([System.IO.Path]::GetFileName($batFilePath))"

    # Copy the BAT file to C:\Windows\Temp
    Copy-Item -Path $batFilePath -Destination $destBatFilePath -Force

    # Execute the BAT file without waiting
    Write-Host $destBatFilePath
    rmbang "[!SetVariable run_update 1]"
}

# Exit the script immediately after the function is triggered
Exit
