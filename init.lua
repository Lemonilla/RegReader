
local RegValueChanged_Time = 2.0
local SplitHexByBytes = false -- Display Hex as 0000 0000


local RegPtr = 0x00A954B0
local Color_Default = 0xFFFFFFFF
local Color_ValueChanged = 0xFFFF0000 -- in 0xAARRGGBB
local RegTable = {} -- index 0-255 are {Value, TimeOfLastChange}
local skipEmptyRegisters = true
local RegAddr = nil
local DisplayType = {"Hex","Dec"}
local roomPtr = 0x00A94254
local roomOffset = 0x28

for i=0,256 do
    RegTable[i] = {0,os.time()+2}
end


local function init()

    return {
        name = "RegReader",
        version = "0.3.0",
        author = "Lemon"
    }
end

-- Helper function to print on the widget's window
-- By default it will print on the same line
-- FUCNTION BY SOLY 
local function imguiPrint(text, color, newline)
    color = color or cfg.white
    newline = newline or false

    if newline == false then
        imgui.SameLine(0, 0)
    end
    
    a = bit.band(bit.rshift(color, 24), 0xFF) / 255;
    r = bit.band(bit.rshift(color, 16), 0xFF) / 255;
    g = bit.band(bit.rshift(color, 8), 0xFF) / 255;
    b = bit.band(color, 0xFF) / 255;

    imgui.TextColored(r, g, b, a, text)
end


local function readRegisters()
    RegAddr = pso.read_u32(RegPtr)
    if RegAddr ~= 0 then
        for i=0,255 do
            v = pso.read_i32((RegAddr + (i*4)))
            if RegTable[i][0] ~= v then 
                RegTable[i][0] = v
                RegTable[i][1] = os.time()
            end
        end
    end
end

local function truncate(int)
        I = tostring(i)
        l = string.len(I)
        s1 = "R"..I.."   :\t"
        if l > 1 then
            s1 = "R"..I.."  :\t"
        end
        if l > 2 then
            s1 = "R"..I.." :\t"
        end
        return s1
end

    local status = true
    local selection = 1

-- "%o, %x, %X", -100,-100,-100)
local function IndexToString(i)
    s = "ERROR"
    if selection == 1 then -- Hex
        s = string.format("%08X", RegTable[i][0])
        if SplitHexByBytes then s = string.sub(s,0,4).." "..string.sub(s,5,8) end
    end
    if selection == 2 then -- Dex
        s = string.format("%d", RegTable[i][0])
    end

    return truncate(i)..s
end

local function display()

    imgui.Begin("RegReader")
    status, selection = imgui.Combo(" ", selection, DisplayType, 2)
    
    -- Get room number
    roomAddr = pso.read_u32(roomPtr)+roomOffset
    roomNum = pso.read_u32(roomAddr)
    s = string.format("Room Number: %d", roomNum)
    imguiPrint(s, Color_Default, true)


    if skipEmptyRegisters then
        if imgui.Selectable("Show Empty", skipEmptyRegisters) then
            skipEmptyRegisters = not skipEmptyRegisters
        end
    else
          if imgui.Selectable("Hide Empty", skipEmptyRegisters) then
            skipEmptyRegisters = not skipEmptyRegisters
        end
    end


    i=0
    while i<=255 do
        color = Color_Default
        if ((os.time() - RegTable[i][1]) < RegValueChanged_Time) then color = Color_ValueChanged end

        if (not skipEmptyRegisters or ((os.time() - RegTable[i][1]) < RegValueChanged_Time) or RegTable[i][0] ~= 0) then
            imguiPrint(IndexToString(i), color, true)
        end
        i=i+1
    end
    imgui.End()
end

local function no_display()
    imgui.End()
end


local function present()
    imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.1)
    pcall(readRegisters)
    xpcall(display,no_display)
    imgui.PopStyleColor(1)
end

pso.on_init(init)
pso.on_present(present)

return {
    init = init,
    present = present
}
