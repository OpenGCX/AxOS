local buffer = require("buffer")
local bstdlib = require("bstdlib")
local event = require("event")
local cursor = require("cursor")
local tty = require("tty")

local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

local globalCursor = cursor.create(1,1)

stdout = buffer.createBuffer()
stdin  = buffer.createBuffer()

-- stdout

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

local function backspace()
    gpu.setBackground(0)
    gpu.fill(stdout.cursor.x-1, stdout.cursor.y, w, 1, " ")
    stdout.cursor.x = stdout.cursor.x - 1
end

local functable = {
    ["\n"]=newline,
    ["\b"]=backspace
}

local stdoutproc = process.create("stdoutrender", function()
    while true do
        local parsed = tty.parse(functable)
        if parsed == {""} then goto skip end

        for i, data in ipairs(parsed) do
            if type(data) == "string" then
                gpu.setBackground(0)
                gpu.set(stdout.cursor.x, stdout.cursor.y, data)
                stdout.cursor.x = stdout.cursor.x + #data
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