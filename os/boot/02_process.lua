process = {}

process.procs = {}

function process.create(name, func)
    local co = coroutine.create(func)
    -- local co = 
    local proc = {["pid"]=#process.procs+1, ["name"]=name, ["co"]=co}

    function proc.resume(self)
        local status, err = coroutine.resume(self.co)
        if not status then
            return status, err
        else
            return true
        end
    end

    function proc.kill(self)
        process.procs[self.pid] = nil
        coroutine.close(self.co)
    end

    process.procs[#process.procs+1] = proc
    return proc
end

function process.launch()
    local pid = 1
    while true do
        if pid > #process.procs then
            pid = 1
        end

        if process.procs[pid] ~= nil then
            local status,err = process.procs[pid]:resume()
            if status == false and err == "cannot resume dead coroutine"  then
                process.procs[pid] = nil
                -- print("Closed:  " .. tostring(pid))
            elseif status == false then
                error(err)
            end
        end

        pid = pid + 1
    end
end