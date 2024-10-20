# Load the SQLite assembly from the specified path
$SQLitePath =  $SQLitePath = $RmAPI.VariableStr('sqlitepath')
Add-Type -Path $SQLitePath

# Set the path to the Chrome History database
$chromeHistoryPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
$tempHistoryPath = Join-Path -Path $env:TEMP -ChildPath ("ChromeHistoryCopy_" + [guid]::NewGuid().ToString() + ".db")

# Check if the History file exists
if (-Not (Test-Path $chromeHistoryPath)) {
    Write-Host "Chrome history file not found."
    exit
}

# Copy the History file to a temporary location
Copy-Item -Path $chromeHistoryPath -Destination $tempHistoryPath -Force

# Create a connection to the SQLite database
$connectionString = "Data Source=$tempHistoryPath;Version=3;"

try {
    # Create and open the connection
    $connection = New-Object System.Data.SQLite.SQLiteConnection($connectionString)
    $connection.Open()

    # Query to get the most recent three titles from the history
    $query = "SELECT title FROM urls ORDER BY last_visit_time DESC LIMIT 3"

    # Create a command object
    $command = $connection.CreateCommand()
    $command.CommandText = $query
#
    # Execute the query and get the results
    $reader = $command.ExecuteReader()

    # Initialize history variables
    $history1 = $null
    $history2 = $null
    $history3 = $null

    # Read the results and assign titles to variables
    $count = 1
    while ($reader.Read()) {
        $title = $reader["title"]

        # Assign the title to the corresponding history variable
        switch ($count) {
            1 { $history1 = $title }
            2 { $history2 = $title }
            3 { $history3 = $title }
        }

        $count++
    }

    # Output the history titles
    #Write-Host "Recent Chrome History Titles:"
    #Write-Host "1: $history1"
    #Write-Host "2: $history2"
    #Write-Host "3: $history3"

} catch {
    Write-Host "An error occurred: $_"
} finally {
    # Close the reader and connection
    if ($reader -ne $null) {
        $reader.Close()
    }
    if ($connection -ne $null -and $connection.State -eq 'Open') {
        $connection.Close()
    }

    # No removal of the temporary file
    #Write-Host "Temporary file $tempHistoryPath created and not deleted."
}

  #Function to execute Rainmeter Bangs
function rmbang ($bang) {
    $RmAPI.Bang($bang)
}

 #Set Rainmeter text options and variables using the history variables
rmbang "[!SetOption History_Text1 Text `"$history1`"]"
rmbang "[!SetOption History_Text2 Text `"$history2`"]"
rmbang "[!SetOption History_Text3 Text `"$history3`"]"

rmbang "[!SetVariable History1 `"$history1`"]"
rmbang "[!SetVariable History2 `"$history2`"]"
rmbang "[!SetVariable History3 `"$history3`"]"

rmbang "[!UpdateMeterGroup History]"
