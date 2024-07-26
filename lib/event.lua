local event = {}

function event.listen(event, func)
    _addEventListener(event, func)
end

return event