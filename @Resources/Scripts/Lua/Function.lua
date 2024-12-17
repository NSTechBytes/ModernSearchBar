function startslider(variant, handler, offsetx,offsety)
	local File = SKIN:GetVariable('ROOTCONFIGPATH')..'Slider\\Main.ini'
	local MyMeter = SKIN:GetMeter(handler)
	local scale = tonumber(SKIN:GetVariable('Scale'))
    local PosX = SKIN:GetX() + MyMeter:GetX() + offsetx * scale
    local PosY = SKIN:GetY() + MyMeter:GetY() + offsety * scale
	--SKIN:Bang('!ZPos', '0')
	--SKIN:Bang('!Draggable', '1')
	SKIN:Bang('!Activateconfig', 'ModernSearchBar\\Slider', 'Main.ini')
	SKIN:Bang('!Move', PosX, PosY, 'ModernSearchBar\\Slider')
end


function trimAndProcess(input, type)
    if string.find(input, "Not Internet") then
		SKIN:Bang ('!HideMeterGroup', 'Trends')
		SKIN:Bang ('!ShowMeterGroup', 'NotInternet')
		SKIN:Bang ('!SetOption', 'recent_Image' ,'Y' , '(190*#Scale#)')
		SKIN:Bang ('!UpdateMeter', '*')
		SKIN:Bang ('!Redraw')
       --- print("not internet")
        return
    end
    if type == "TopTrends" then
       -- print("Processing with type: " .. type)
    else
       -- print("Processing with another type: " .. type)
    end

   
    local results = {}
    for str in string.gmatch(input, "([^|]+)") do
        table.insert(results, str)
    end

   
    for i, str in ipairs(results) do
        if type == "TopTrends" then
        ---print("String " .. i .. ": " .. str)
        SKIN:Bang ('!SetOption', 'Trends_Text'..i..'' , 'Text', str)
		SKIN:Bang ('!SetVariable', 'Trends'..i..'' , str)
        SKIN:Bang ('!UpdateMeter', 'Trends_Text'..i..'')
        SKIN:Bang ('!Redraw')
        else
           -- print("String " .. i .. ": " .. str)
            SKIN:Bang ('!SetOption', 'History_Text'..i..'' , 'Text', str)
			SKIN:Bang ('!SetVariable', 'History'..i..'' , str)
            SKIN:Bang ('!UpdateMeter', 'History_Text'..i..'')
            SKIN:Bang ('!Redraw')
        end

    end
end
