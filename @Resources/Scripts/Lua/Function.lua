function startslider(variant, handler, offsetx,offsety)
	local File = SKIN:GetVariable('ROOTCONFIGPATH')..'Slider\\Main.ini'
	local MyMeter = SKIN:GetMeter(handler)
	local scale = tonumber(SKIN:GetVariable('Scale'))
    local PosX = SKIN:GetX() + MyMeter:GetX() + offsetx * scale
    local PosY = SKIN:GetY() + MyMeter:GetY() + offsety * scale
	--SKIN:Bang('!ZPos', '0')
	SKIN:Bang('!Draggable', '0')
	SKIN:Bang('!Activateconfig', 'ModernSearchBar\\Slider', 'Main.ini')
	SKIN:Bang('!Move', PosX, PosY, 'ModernSearchBar\\Slider')
end

