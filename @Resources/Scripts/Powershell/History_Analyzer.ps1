# Manually specify the path to sqlite3.exe if needed (or leave it empty to use the script's directory)
$manualSqlitePath = $RmAPI.VariableStr('Sqlitepath')

# Check if manual path is specified, otherwise use the script directory
if ($manualSqlitePath -eq "") {
    # Get the directory of the current PowerShell script (where sqlite3.exe is located)
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sqlitePath = Join-Path $scriptDir "sqlite3.exe"
} else {
    # Use manually specified path
    $sqlitePath = $manualSqlitePath
}

# Check if sqlite3.exe exists
if (-Not (Test-Path $sqlitePath)) {
    Write-Host "sqlite3.exe not found at: $sqlitePath. Please check the path."
    exit
}

# Define the path to the Chrome History file (default path for Windows)
$chromeHistoryPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"

# Check if the Chrome History file exists
if (-Not (Test-Path $chromeHistoryPath)) {
    Write-Host "Google Chrome History file not found. Exiting script."
    exit
}

# Define the SQL query to get the last three Google search queries
$query = @"
SELECT url, datetime(last_visit_time/1000000-11644473600, 'unixepoch', 'localtime') as last_visit
FROM urls
WHERE url LIKE '%google.com/search?q=%'
ORDER BY last_visit_time DESC
LIMIT 3;
"@

# Create a temporary SQLite database copy since Chrome locks the database when it's running
$tempHistoryPath = [System.IO.Path]::GetTempFileName()
Copy-Item $chromeHistoryPath $tempHistoryPath -Force

# Query the SQLite database using the local sqlite3.exe
try {
    $output = & "$sqlitePath" $tempHistoryPath $query
} catch {
    Write-Host "Error querying the Chrome History database."
    exit
}

# Function to extract the Google search query from the URL
function Extract-SearchQuery {
    param (
        [string]$url
    )

    # Use a regular expression to extract the search query after 'q='
    if ($url -match 'q=([^&]+)') {
        return [System.Uri]::UnescapeDataString($matches[1]) # Decode the query (in case of special characters)
    }

    return "Unknown search query"
}

# Initialize variables for history searches
$history1 = ""
$history2 = ""
$history3 = ""

# Check if we got any results
if ($output) {
    Write-Host "Recent Google Searches:"
    $searches = $output -split "`n"

    # Store each search in the respective variable
    if ($searches.Count -ge 1) {
        $parts = $searches[0] -split '\|'
        $history1 = Extract-SearchQuery $parts[0]
        Write-Host "Search 1: $history1 (Visited on: $($parts[1]))"
    }
    if ($searches.Count -ge 2) {
        $parts = $searches[1] -split '\|'
        $history2 = Extract-SearchQuery $parts[0]
        Write-Host "Search 2: $history2 (Visited on: $($parts[1]))"
    }
    if ($searches.Count -ge 3) {
        $parts = $searches[2] -split '\|'
        $history3 = Extract-SearchQuery $parts[0]
        Write-Host "Search 3: $history3 (Visited on: $($parts[1]))"
    }
} else {
    Write-Host "No recent Google searches found."
}

# Clean up the temporary history file
Remove-Item $tempHistoryPath

# Function to execute Rainmeter Bangs
function rmbang ($bang) {
    $RmAPI.Bang($bang)
}

# Set Rainmeter text options and variables using the history variables
rmbang "[!SetOption History_Text1 Text `"$history1`"]"
rmbang "[!SetOption History_Text2 Text `"$history2`"]"
rmbang "[!SetOption History_Text3 Text `"$history3`"]"

rmbang "[!SetVariable History1 `"$history1`"]"
rmbang "[!SetVariable History2 `"$history2`"]"
rmbang "[!SetVariable History3 `"$history3`"]"

rmbang "[!UpdateMeterGroup History]"

# Display history variables
Write-Host ""
Write-Host "Stored in Variables:"
Write-Host "History 1: $history1"
Write-Host "History 2: $history2"
Write-Host "History 3: $history3"