local keyboard = require("keyboard")

local function getCommand()
    stdin:flush()
    stdout:write(">")
    local command = ""
    while true do
        local data = stdin:read()
        if data == "\8" then
            if #command > 0 then
                command = command:sub(-#command, #command-1)
                stdout:backspace()
            end
        elseif data == "\13" then
            stdout:write("\n")
            break
        else
            command = command .. keyboard.render(data)
            stdout:write(keyboard.render(data))
        end
        coroutine.yield()
    end

    return command
end

process.create("shell", function()
    clear()
    print("Booted into AxOS")

    while true do
        local command = getCommand()
        if command == "" then goto skip_main end
        if command == "test" then
            print("goodjob, you ran the test command")
        else
            print("tf are you talking about bro")
        end
        ::skip_main::
    end
end)