local listeners = {}

local eventproc = process.create("events", function()
    while true do
        local ev = table.pack(computer.pullSignal(0))
        -- print(ev[1])
        if ev.n ~= 0 then
            -- print(tostring(ev))
            for _, listener in pairs(listeners) do
                if listener.event == ev[1] then
                    listener.func(table.unpack(ev, 2, #ev-1))
                end 
            end
        end
        coroutine.yield()
    end
end)

function _addEventListener(event, func)
    listeners[#listeners+1] = {["event"]=event, ["func"]=func}
end