
    # Function to check internet connection by pinging Google DNS (8.8.8.8)
    function Test-InternetConnection {
        try {
            $pingResult = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet
            return $pingResult
        }
        catch {
            return $false
        }
    }

    # Function to fetch and display Google Trends data
    function Get-GoogleTrends {
        # Define the Google Trends URL
        $trendsUrl = "https://trends.google.com/trends/trendingsearches/daily/rss?geo=US"

        # Set the user-agent to mimic a browser
        $headers = @{
            'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }

        # Get the Google Trends RSS feed
        $response = Invoke-WebRequest -Uri $trendsUrl -Headers $headers -UseBasicParsing

        # Parse the XML feed
        [xml]$rss = $response.Content

        # Get the top 6 trending searches (title elements in the RSS feed)
        $topTrends = $rss.rss.channel.item | Select-Object -First 6

        # Initialize variables for trends
        $Trends1 = ""
        $Trends2 = ""
        $Trends3 = ""
        $Trends4 = ""
        $Trends5 = ""
        $Trends6 = ""

        # Assign the top 6 trending searches to variables
        for ($i = 0; $i -lt $topTrends.Count; $i++) {
            $trendTitle = $topTrends[$i].title

            # Assign to specific trend variables
            switch ($i) {
                0 { $Trends1 = $trendTitle }
                1 { $Trends2 = $trendTitle }
                2 { $Trends3 = $trendTitle }
                3 { $Trends4 = $trendTitle }
                4 { $Trends5 = $trendTitle }
                5 { $Trends6 = $trendTitle }
            }
        }

        # Function to send Rainmeter bangs
        function rmbang ($bang) {
            $RmAPI.Bang($bang)
        }

        # Send the trends to Rainmeter
        rmbang "[!SetOption Trends_Text1 Text `"$Trends1`"]"
        rmbang "[!SetOption Trends_Text2 Text `"$Trends2`"]"
        rmbang "[!SetOption Trends_Text3 Text `"$Trends3`"]"
        rmbang "[!SetOption Trends_Text4 Text `"$Trends4`"]"
        rmbang "[!SetOption Trends_Text5 Text `"$Trends5`"]"
        rmbang "[!SetOption Trends_Text6 Text `"$Trends6`"]"

        rmbang "[!SetVariable Trends1 `"$Trends1`"]"
        rmbang "[!SetVariable Trends2 `"$Trends2`"]"
        rmbang "[!SetVariable Trends3 `"$Trends3`"]"
        rmbang "[!SetVariable Trends4 `"$Trends4`"]"
        rmbang "[!SetVariable Trends5 `"$Trends5`"]"
        rmbang "[!SetVariable Trends6 `"$Trends6`"]"

        # Update and redraw Rainmeter skin after setting variables
        rmbang "[!UpdateMeterGroup Trends]"

        # Output the variables for use in Rainmeter (optional)
        # Write-Host "Trends1 = $Trends1"
        # Write-Host "Trends2 = $Trends2"
        # Write-Host "Trends3 = $Trends3"
        # Write-Host "Trends4 = $Trends4"
        # Write-Host "Trends5 = $Trends5"
        # Write-Host "Trends6 = $Trends6"
    }

    # Main Script Execution

    # Check if the internet is connected
    if (-not (Test-InternetConnection)) {
        # Internet is not connected
        Write-Host "Internet is not connected."
        exit
    }

    # If internet is connected, execute the function to fetch Google Trends
    Get-GoogleTrends
