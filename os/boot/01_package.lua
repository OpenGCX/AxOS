local pkgcache = {}

function require(lib)
    if not pkgcache[lib] then
        local fs = component.proxy(computer.getBootAddress())
        local func, err = load(readfile("/lib/"..lib..".lua"))

        if not func then
            error("LOAD ERROR\n"..err)
        end

        local status, package = pcall(func)
        
        if not status then
            error("RUNTIME ERROR\n"..package,2)
        end

        fs.close(fh)
        pkgcache[lib] = package
        return package
    else
        local package = pkgcache[lib]
        return package
    end
end