local fs = component.proxy(computer.getBootAddress())
local gpu = component.proxy(component.list("gpu")())

function readfile(file)
    local contents = ""
    local fh = fs.open(file)

    while true do
        local buf = fs.read(fh, 500000000000000)
        if not buf then 
            break
        end

        contents = contents .. buf
    end

    return contents
end

function loadfile(file) 
    local func, err = load(readfile(file))

    if not func then
        error("LOAD ERROR\n"..err)
    end

    local status, err = pcall(func)
    if status == false then
        error(err)
    end

    fs.close(fh)
end


local bootfiles = fs.list("/boot")
local sorted = {}

for _, file in pairs(bootfiles) do
    sorted[ tonumber(string.sub(file, 1, 2)) ] = file
end

for _, file in pairs(sorted) do
    loadfile("/boot/" .. file)
end

clear()
print("weird padding or else it wont work...")

local proc1 = process.create("test",function()
    local event = require("event")
    event.listen("touch", function(_, _, _, _)
        print("testi")
    end)

    print("Added listener!")
end)

local proc2 = process.create("test2", function()
    print("scary")
    print("scary scary!")
end)

process.launch()

hang()

while true do
    computer.pullSignal()
end