local buffer = require("buffer")
local bstdlib = require("bstdlib")
local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()
local lastx = 1
local lasty = 1

stdout = buffer.createBuffer()
local function wrap(text, len)
    local out = {}
    local _text = text -- mfw lua
    while true do
        out[#out+1] = _text:sub(1, len)
        _text = _text:sub(len+1)

        if #_text <= len then
            break
        end
    end

    out[#out+1] = _text

    return out
end

local stdioproc = process.create("stdio",function()
    while true do
        local funny = stdout:read()
        local lines = bstdlib.string.split(funny, "\n")
        for line in bstdlib.string.isplit(funny, "\n") do
            -- gpu.set(1,1,lines[1])
            -- if line == "" then goto stdioproc_continue end
            local wrapped = wrap(line, w)
            for _, partial in pairs(wrapped) do
                if partial == "" then goto stdioproc_partial_continue end
                if lasty >= h then
                    gpu.copy(1,1,w,h,0,-1)
                    lasty = h
                end
                
                gpu.set(1, lasty, partial)
                lasty = lasty + 1
                lastx = lastx
                lastPartial = partial
                ::stdioproc_partial_continue::
            end

            -- ::stdioproc_line_continue::
        end
        coroutine.yield()

    end
end)

function clear()
    stdout:write(string.rep("\n",h+1))
    lastx = 0
    lasty = 0
end

function print(data)
    stdout:write(tostring(data) .. "\n")
end