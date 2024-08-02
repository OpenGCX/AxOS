local k = {}

k._special = {
    ["\13"]="",
    ["\9"]="    ",
    ["\27"]="",
    ["\8"]=""
}

function k.render(raw)
    if k._special[raw] == nil then
        return raw
    else
        return k._special[raw]
    end
end

return k