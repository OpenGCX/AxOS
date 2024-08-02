local keyboard = require("keyboard")
local fs = component.proxy(component.list("filesystem")())

local function getCommand()
    stdin:flush()
    stdout:write(">")
    stdout.cursor:enableBlink()
    local command = ""
    while true do
        local data = stdin:read()
        if data == "\8" then
            if #command > 0 then
                command = command:sub(-#command, #command-1)
                stdout:write("\8")
            end
        elseif data == "\13" then
            stdout:write("\n")
            stdout.cursor:disableBlink()
            break
        else
            command = command .. keyboard.render(data)
            stdout:write(keyboard.render(data))
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

        local fs = component.proxy(computer.getBootAddress())
        
        if fs.exists("/bin/"..command..".lua") then
            runCommand(command)
        else
            print("This executable does not exist!")
        end

        ::skip_main::
    end
end)