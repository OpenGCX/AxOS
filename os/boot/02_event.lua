local process = require("process")
local event = require("event")

local eventproc = process.create("events", function()
    while true do
        local ev = table.pack(computer.pullSignal(0))
        if ev.n ~= 0 then
            for _, listener in pairs(event.listeners) do
                if listener.event == ev[1] then
                    listener.func(table.unpack(ev, 2, #ev-1))
                end 
            end
        end
        coroutine.yield()
    end
end)