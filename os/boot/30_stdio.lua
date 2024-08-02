local buffer = require("buffer")
local bstdlib = require("bstdlib")
local event = require("event")
local cursor = require("cursor")

local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

local globalCursor = cursor.create(1,1)

stdout = buffer.createBuffer()
stdin  = buffer.createBuffer()

-- stdout
-- local function wrap(text, len)
--     local out = {}
--     local _text = text -- mfw lua
--     while true do
--         out[#out+1] = _text:sub(1, len)
--         _text = _text:sub(len+1)

--         if #_text <= len then
--             break
--         end
--     end

--     out[#out+1] = _text

--     return out
-- end

stdout.cursor = globalCursor

local function newline()
    gpu.setBackground(0)
    gpu.fill(stdout.cursor.x, stdout.cursor.y, w, 1, " ")
    stdout.cursor.x = 1
    stdout.cursor.y = stdout.cursor.y + 1
    if stdout.cursor.y > h then
        gpu.copy(1,1,w,h,0,-1)
        stdout.cursor.y = stdout.cursor.y - 1
    end
end

local stdioproc = process.create("stdio",function()
    while true do
        local funny = stdout:read()
        local lines = bstdlib.string.split(funny, "\n")
        if funny == "" then goto skip end

        for lc=1,#lines,1 do
            if funny:sub(1,1) == "\n" then newline() end
            if lc>1 then newline() end

            local line = lines[lc]
        
            if line == "\8" then
                gpu.setBackground(0)
                gpu.fill(stdout.cursor.x-1, stdout.cursor.y, w, 1, " ")
                stdout.cursor.x = stdout.cursor.x - 1
                goto skip
            end

            while #line+stdout.cursor.x > w do
                gpu.setBackground(0)
                gpu.set(stdout.cursor.x, stdout.cursor.y, line:sub(1,w-stdout.cursor.x))
                line = line:sub(w-stdout.cursor.x+1)
                newline()
            end

            gpu.setBackground(0)
            gpu.set(stdout.cursor.x, stdout.cursor.y, line)
            stdout.cursor.x = stdout.cursor.x + #line

            if funny:sub(#funny) == "\n" then newline() end
        end
        ::skip::
        coroutine.yield()

    end
end)

function clear()
    gpu.setBackground(0)
    gpu.fill(1,1,w,h," ")
    stdout:flush()
    stdout.cursor.x = 1
    stdout.cursor.y = 1
end

function print(data)
    stdout:write(tostring(data) .. "\n")
end

function stdout.resetCursor(stdout)
    stdout.cursor = globalCursor
end

-- stdin
event.listen("key_down", function(_, char, code, _)
    if char ~= 0 then
        stdin:write(string.char(char))
    end
end)