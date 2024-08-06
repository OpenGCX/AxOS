local tty = {}

function tty.parse(functable)
    local w, h = component.proxy(component.list("gpu")()).getResolution()
    local ocelot = component.proxy(component.list("ocelot")())

    local buf = stdout:read()
    local out = {""}

    local currx = stdout.cursor.x
    local curry = stdout.cursor.y
    for c in buf:gmatch(".") do
        if c == '\n' then
            out[#out+1] = functable['\n']
            out[#out+1] = ""
            currx = 1
            curry = curry + 1
        elseif functable[c] then
            out[#out+1] = functable[c]
            out[#out+1] = ""
        else
            out[#out] = out[#out] .. c
            currx = currx + 1
            if currx == w then
                ocelot.log("Wrapped!")
                currx = 1
                curry = curry + 1
                out[#out+1] = functable["\n"]
                out[#out+1] = ""
            end
        end
    end
    -- if #out > 1 then 
    --     component.proxy(component.list("gpu")()).set(16,16,out[1])
    -- end
    return out
end

return tty