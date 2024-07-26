local buffer = require("buffer")
local bstdlib = require("bstdlib")
local event = require("event")

local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

local lastx = 1
local lasty = 1

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


local function newline()
    lastx = 1
    lasty = lasty + 1
    if lasty > h then
        gpu.copy(1,1,w,h,0,-1)
        lasty = lasty - 1
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
            while #line+lastx > w do
                gpu.set(lastx, lasty, line:sub(1,w-lastx))
                line = line:sub(w-lastx+1)
                newline()
            end

            gpu.set(lastx, lasty, line)
            lastx = lastx + #line

            if funny:sub(#funny) == "\n" then newline() end
        end
        ::skip::
        coroutine.yield()

    end
end)

function clear()
    gpu.fill(1,1,w,h," ")
    stdout:flush()
    lastx = 1
    lasty = 1
end

function print(data)
    stdout:write(tostring(data) .. "\n")
end

function stdout.backspace(stdout)
    gpu.set(lastx-1, lasty," ")
    lastx = lastx - 1
end


-- stdin
event.listen("key_down", function(_, char, code, _)
    if char ~= 0 then
        stdin:write(string.char(char))
    end
end)