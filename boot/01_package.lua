function require(lib)
    local fs = component.proxy(computer.getBootAddress())
    -- local fh = fs.open("/lib/"..lib..".lua")

    -- local code = fs.read(fh, 5000000000000000000000000000000000000)
    local func, err = load(readfile("/lib/"..lib..".lua"))

    if not func then
        error("LOAD ERROR\n"..err)
    end

    local status, package = pcall(func)
    
    if not status then
        error("RUNTIME ERROR\n"..package,2)
    end

    fs.close(fh)

    return package
end