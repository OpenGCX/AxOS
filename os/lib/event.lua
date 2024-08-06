local event = {}
event.listeners = {}

function event.listen(_event, func)
    event.listeners[#event.listeners+1] = {["event"]=_event, ["func"]=func}
end

return event