local buffer = require("buffer")
local cursor = require("cursor")

local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

local tty = {}

tty.stdout = buffer.createBuffer()
tty.stdin  = buffer.createBuffer()

tty.stdout.cursor = cursor.create(1,1)

local function newline()
    gpu.setBackground(0)
    gpu.fill(tty.stdout.cursor.x, tty.stdout.cursor.y, w, 1, " ")
    tty.stdout.cursor.x = 1
    tty.stdout.cursor.y = tty.stdout.cursor.y + 1
    if tty.stdout.cursor.y > h then
        gpu.copy(1,1,w,h,0,-1)
        tty.stdout.cursor.y = tty.stdout.cursor.y - 1
    end
end

local function backspace()
    gpu.setBackground(0)
    gpu.fill(tty.stdout.cursor.x-1, tty.stdout.cursor.y, w, 1, " ")
    tty.stdout.cursor.x = tty.stdout.cursor.x - 1
end

tty.functable = {
    ["\n"]=newline,
    ["\b"]=backspace
}


function tty.parse()
    local buf = tty.stdout:read()
    local out = {""}

    local currx = tty.stdout.cursor.x
    local curry = tty.stdout.cursor.y
    for c in buf:gmatch(".") do
        if c == '\n' then
            out[#out+1] = tty.functable['\n']
            out[#out+1] = ""
            currx = 1
            curry = curry + 1
        elseif tty.functable[c] then
            out[#out+1] = tty.functable[c]
            out[#out+1] = ""
        else
            out[#out] = out[#out] .. c
            currx = currx + 1
            if currx == w then
                ocelot.log("Wrapped!")
                currx = 1
                curry = curry + 1
                out[#out+1] = tty.functable["\n"]
                out[#out+1] = ""
            end
        end
    end
    return out
end

return tty