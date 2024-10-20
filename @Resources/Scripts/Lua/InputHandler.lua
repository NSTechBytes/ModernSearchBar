Running = false

function Initiate()
    if Running then Terminate() end
    Running = true
    Caret = ''

    local valid = false

    MainMeter = SELF:GetOption('MainMeterName')
    CaretMeter = SELF:GetOption('CaretMeterName')
    UpdateGroup = SELF:GetOption('UpdateGroup', '*')
    ContainingFile = SELF:GetOption('ContainingFile', SKIN:ReplaceVariables('#CURRENTPATH##CURRENTFILE#'))
    Multiline = SELF:GetOption('Multiline') == '1'

    if SKIN:GetMeter(MainMeter) and SKIN:GetMeter(CaretMeter) then valid = true end

    if not valid then
        error("Measure options invalid!")
    end

    if ContainingFile then 
        local file = assert(io.open(ContainingFile), 'File not valid: ' .. ContainingFile)
        file:close()
    end

    local tabWidth = tonumber(SELF:GetOption('TabWidth', 4))
    Tab = (function() local x = ''; for i = 0, tabWidth do x = x .. ' ' end ; return x; end)()
    CaretChar = SELF:GetOption('CaretCharacter')

    UserInputList = {}
    for _, v in ipairs(SplitString(SKIN:GetMeter(MainMeter):GetOption('Text', ''), '\n')) do
        table.insert(UserInputList, v)
    end

    if not UserInputList[1] then UserInputList[1] = '' end

    CurrentLine = #UserInputList or 1
    CurrentColumn = UserInputList[CurrentLine] and #UserInputList[CurrentLine] or 0

    Caret = UserInput() .. CaretChar

    SKIN:Bang('!ShowMeter', CaretMeter)
    SKIN:Bang('!HideMeter','Type_String')
    
    UnD()
    
    SKIN:Bang('!Log "Starting input..." Debug')
    SKIN:Bang('!CommandMeasure', 'HotInput', 'Start')
    SKIN:Bang(SELF:GetOption('OnStartAction'))
end

function Terminate()
    
    local finalValue = UserInput()
    local finishAction = SELF:GetOption('OnFinishAction'):gsub(
        '%$[Uu][Ss][Ee][Rr][Ii][Nn][Pp][Uu][Tt]%$',
        finalValue
    ):gsub(
        '%$[Uu][Ss][Ee][Rr][Ii][Nn][Pp][Uu][Tt]%:[Cc][Rr][Ll][Ff]%$',
        finalValue:gsub('\n', '#*CRLF*#')
    )
    print(finishAction)
    SKIN:Bang(finishAction)
    SKIN:Bang('!HideMeter', CaretMeter)
    SKIN:Bang('!CommandMeasure', 'HotInput', 'Stop')
    UnD()
    SKIN:Bang('!Log "Stopped input!" Debug')
end

function HandleInput(key)
    --#region TERMINATE
    if (key == 'RETURN') then
        Terminate()
        SKIN:Bang('!SetVariable','query',UserInput())
        SKIN:Bang('!SetVariable','runSearch','1')
        SKIN:Bang('!UpdateMEasure','CloseToggle','"ModernSearchBar\\Slider"')
          
        
    elseif (key == 'ESC') then
        Terminate()
        SKIN:Bang('!Refresh')
    --#endregion

    --#region WHITESPACE
    elseif (key == 'LINEFEED') then
        if (not Multiline) then
            return
        end
        AddToInput('\n')
    elseif (key == 'TAB') then
        AddToInput(Tab)
    elseif (key == 'SPACE') then
        AddToInput(' ')
    --#endregion

    --#region REMOVAL
    elseif (key == 'BACKSPACE') then
        SetCaret()
        local curr = UserInputList[CurrentLine]
        if CurrentColumn <= 0 then
            if CurrentLine <= 1 then return end
            CurrentLine = CurrentLine - 1
            CurrentColumn = #UserInputList[CurrentLine]
            UserInputList[CurrentLine] = UserInputList[CurrentLine] .. curr
            table.remove(UserInputList, CurrentLine + 1)
        else
            UserInputList[CurrentLine] = curr:sub(1, CurrentColumn - 1) .. curr:sub(CurrentColumn + 1, #curr)
            CurrentColumn = CurrentColumn - 1
        end
        SetCaret()
    elseif (key == 'DELETE') then
        SetCaret()
        local curr = UserInputList[CurrentLine]
        if CurrentColumn >= #curr then
            if CurrentLine >= #UserInputList then return end
            UserInputList[CurrentLine] = UserInputList[CurrentLine] .. UserInputList[CurrentLine + 1]
            table.remove(UserInputList, CurrentLine + 1)
        else
            UserInputList[CurrentLine] = curr:sub(1, CurrentColumn) .. curr:sub(CurrentColumn + 2, #curr)
        end
        SetCaret()
    --#endregion

    --#region CHARACTER
    elseif (key) then
        AddToInput(key)
    end
    --#endregion
end

function HandleNavigation(key)
    if key == 'LEFT' then
        if CurrentColumn > 0 then
            CurrentColumn = CurrentColumn - 1
            SetCaret()
        elseif CurrentColumn <= 0 then
            if CurrentLine <= 1 then return end
            CurrentLine = CurrentLine - 1
            CurrentColumn = #UserInputList[CurrentLine]
            SetCaret()
        end
    elseif key == 'RIGHT' then
        if CurrentColumn < #UserInputList[CurrentLine] then
            CurrentColumn = CurrentColumn + 1
            SetCaret()
        elseif CurrentColumn >= #UserInputList[CurrentLine] then
            if CurrentLine >= #UserInputList then return end
            CurrentLine = CurrentLine + 1
            CurrentColumn = 0
            SetCaret()
        end
    elseif key == 'UP' then
        if CurrentLine > 1 then
            CurrentLine = CurrentLine - 1
            ShowCaret()
        end
    elseif key == 'DOWN' then
        if CurrentLine < #UserInputList then
            CurrentLine = CurrentLine + 1
            ShowCaret()
        end
    end
end

function AddToInput(char)
    SetCaret()
    if #char > 1 then return end
    local curr = UserInputList[CurrentLine]

    if char == '\n' then
        local next = curr:sub(CurrentColumn + 1, #curr)
        UserInputList[CurrentLine] = curr:sub(1, CurrentColumn)
        CurrentLine = CurrentLine + 1
        table.insert(UserInputList, CurrentLine, next)
        CurrentColumn = 0
    else
        UserInputList[CurrentLine] = curr:sub(1, CurrentColumn) .. char .. curr:sub(CurrentColumn + 1, #curr)
        CurrentColumn = CurrentColumn + 1
    end

    CaretOffset = #UserInputList[CurrentLine] - CurrentColumn
    SetCaret()
end

function UserInput()
    return table.concat(UserInputList, '\n')
end

function ShowCaret() -- Shows the caret, but doesn't change the position permamnently
    local curr = UserInputList[CurrentLine]
    local currentColumn = CurrentColumn

    if CurrentColumn < 0 then currentColumn = 0 end
    if CurrentColumn > #curr then currentColumn = #curr end

    Caret = (function()
        local n = ''
        for i = 1, CurrentLine - 1 do
            n = n .. '\n'
        end
        return n
    end)() .. curr:sub(1, currentColumn) .. CaretChar

    UnD()
end

function SetCaret(update) -- Changes the caret position permamnently
    local curr = UserInputList[CurrentLine] or ''

    if CurrentColumn < 0 then CurrentColumn = 0 end
    if CurrentColumn > #curr then CurrentColumn = #curr end

    Caret = (function()
        local n = ''
        for i = 1, CurrentLine - 1 do
            n = n .. '\n'
        end
        return n
    end)() .. curr:sub(1, CurrentColumn) .. CaretChar

    if not update then UnD() end
end

function UnD()
    SKIN:Bang('!SetOption', CaretMeter, 'Text', Caret)
    if (UpdateGroup ~= '*') then SKIN:Bang('!UpdateMeterGroup', UpdateGroup)
    else SKIN:Bang('!UpdateMeter', '*') end
    SKIN:Bang('!Redraw')
    
end

-- ==========================================================

function SplitString(inString, inDelimiter)
	assert(inDelimiter:len() == 1, 'SplitString: Delimiter may only be a single character')

	local outTable = {}

	for matchedString in inString:gmatch('[^%' .. inDelimiter .. ']+') do
		table.insert(outTable, matchedString)
	end

	return outTable

end


