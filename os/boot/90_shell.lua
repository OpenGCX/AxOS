local keyboard = require("keyboard")
local process = require("process")
local tty = require("tty")
local fs = component.proxy(computer.getBootAddress())

local function getCommand()
    tty.stdin:flush()
    tty.stdout:write(">")
    tty.stdout.cursor:enableBlink()
    local command = ""
    while true do
        local data = tty.stdin:read()
        if data == "\8" then
            if #command > 0 then
                command = command:sub(-#command, #command-1)
                tty.stdout:write("\8")
            end
        elseif data == "\13" then
            tty.stdout:write("\n")
            tty.stdout.cursor:disableBlink()
            break
        else
            command = command .. keyboard.render(data)
            tty.stdout:write(keyboard.render(data))
        end
        coroutine.yield()
    end

    return command
end

local function runCommand(cmd)
    local func, err = load(readfile("/bin/"..cmd..".lua"))
    if not func then
        print("ERROR LOADING\n" .. err)
        return
    end

    local status, err = pcall(func)
    
    if not status then
        print("RUNTIME ERROR\n" .. err)
        return
    end
end

process.create("shell", function()
    clear()
    print("Booted into AxOS")
    print("something is suspcious")

    while true do
        local command = getCommand()
        if command == "" then goto skip_main end
        
        if fs.exists("/bin/"..command..".lua") then
            runCommand(command)
        else
            print("This executable does not exist!")
        end

        ::skip_main::
    end
end)