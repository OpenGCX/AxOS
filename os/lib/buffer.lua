local buffer = {}

function buffer.createBuffer()
    local buf = {}
    buf.index = 0
    buf.data = ""

    function buf.write(buf, data)
        buf.data = buf.data .. data
    end

    function buf.flush(buf, data)
        buf.data = ""
        buf.index = 0
    end

    -- function buf.read(buf, data, amount)
    --     amount = amount or -1
    --     local data = string.sub(buf.data, 1, amount)
    --     if amount > -1 then
    --         buf.data = string.sub(buf.data, amount+1)
    --     else
    --         buf:flush()
    --     end
    --     -- component.proxy(component.list('gpu')()).set(1,9,string.sub(buf.data,2))
    --     -- component.proxy(component.list('gpu')()).set(1,10,tostring(amount))
    --     return data
    -- end

    function buf.read(buf, data, amount)
        amount = amount or #buf.data-buf.index
        amount = amount + 1
        local data = buf.data:sub(buf.index, buf.index+amount)
        buf.index = buf.index + amount
        return data
    end

    return buf
end

return buffer