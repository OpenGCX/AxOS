local event = {}

function event.listen(event, func)
    _addEventListener(event, func)
end

-- function os.sleep(timeout)
--     checkArg(1, timeout, "number", "nil")
--     local deadline = computer.uptime() + (timeout or 0)
--     repeat
--         -- computer.pullSignal(0)
--         coroutine.yield()
--     until computer.uptime() >= deadline
-- end

-- function event.timeout(event, timeout)
--     local deadline = computer.uptime() + timeout
--     while computer.uptime() < deadline do
--         coroutine.yield()
--         local data = computer.pullSignal(0)
--         if data ~= nil then break end
--     end
-- end

return event