local bstdlib = require("bstdlib")
local event = require("event")
local tty = require("tty")

local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

local stdoutproc = process.create("stdoutrender", function()
    while true do
        local parsed = tty.parse()
        if parsed == {""} then goto skip end

        for i, data in ipairs(parsed) do
            if type(data) == "string" then
                gpu.setBackground(0)
                gpu.set(tty.stdout.cursor.x, tty.stdout.cursor.y, data)
                tty.stdout.cursor.x = tty.stdout.cursor.x + #data
            else
                -- unsafe but who cares lol
                data()
            end
        end
        ::skip::
        coroutine.yield()
    end 
end)

function clear()
    gpu.setBackground(0)
    gpu.fill(1,1,w,h," ")
    tty.stdout:flush()
    tty.stdout.cursor.x = 1
    tty.stdout.cursor.y = 1
end

function print(data)
    tty.stdout:write(tostring(data) .. "\n")
end

-- stdin
event.listen("key_down", function(_, char, code, _)
    if char ~= 0 then
        tty.stdin:write(string.char(char))
    end
end)