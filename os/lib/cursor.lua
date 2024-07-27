local event = require('event')
local lib = {}


function lib.create(x, y)
    local cursor = {}
    cursor.x = x
    cursor.y = y

    cursor.blinking = false
    cursor._interruptblink = false
    cursor._blinkproc = ""

    event.listen("key_down", function(_, _, _, _)
        cursor._interruptblink = true
    end)

    event.listen("key_up", function(_, _, _, _)
        cursor._interruptblink = false
        -- component.proxy(component.list("gpu")()).set(1,9,"unstuck")
        -- computer.beep(500)
    end)

    function cursor.enableBlink(self)
        if self.blinking == true then return false end
        self._blinkproc = process.create("blinkproc", function()
            local gpu = component.proxy(component.list("gpu")())
            while true do
                local deadline = computer.uptime()+0.5
                while computer.uptime() < deadline and not cursor._interruptblink do
                    coroutine.yield()
                end

                if not cursor._interruptblink then
                    gpu.setBackground(0xffffff)
                    gpu.set(cursor.x, cursor.y, table.pack(gpu.get(cursor.x, cursor.y))[1])
                else
                    gpu.setBackground(0)
                    gpu.set(cursor.x, cursor.y, table.pack(gpu.get(cursor.x, cursor.y))[1])
                end

                local deadline = computer.uptime()+0.5
                while computer.uptime() < deadline and not cursor._interruptblink do
                    coroutine.yield()
                end

                gpu.setBackground(0)
                gpu.set(cursor.x, cursor.y, table.pack(gpu.get(cursor.x, cursor.y))[1])
                coroutine.yield()
            end
        end)
        return true
    end

    function cursor.disableBlink(self)
        if self.blinking == false then return false end
        self._blinkproc:kill()
        self._blinkproc = ""
        self.blinking = false
        return true
    end

    return cursor
end

return lib