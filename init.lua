local function init()
    return {
        name = "RegReader",
        version = "0.1.0",
        author = "Lemon"
    }
end

local RegPtr = 0x00A954B0

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

local function present()
    imgui.Begin("RegReader")

    i = 0
    while i <= 255 do
        s1 = truncate(i)
        s2 = tostring(pso.read_u32((RegPtr + (255*4))))

        imgui.TextUnformatted(s1..s2)
        i=i+1
    end
    imgui.End()
end

pso.on_init(init)
pso.on_present(present)

return {
    init = init,
    present = present
}
