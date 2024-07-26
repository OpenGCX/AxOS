local t = {
	string = {},
	table = {},
	url = {},
	bytes = {}
}

function t.string.isplit(str, sp)
	if sp == nil then
		sp = "%s"
	end
	return string.gmatch(str, "([^" .. sp .. "]+)")
end
function t.string.isplit_s(str, sp)
	local opos = 1
	local size = #sp
	local buf = ""
	return function()
		repeat
			local oend = opos + size
			local subs = string.sub(str, opos, oend)
			if subs == sp then
				local duck = buf
				buf = ""
				return duck
			else
				buf = buf .. subs
			end
		until opos + size >= #str
	end
end

function t.string.split(str, sp)
	return t.table.from_iterator(t.string.isplit(str, sp))
end

function t.string.split_s(str, sp)
	return t.table.from_iterator(t.string.isplit_s(str, sp))
end

function t.string.starts_with(str, s)
	return string.sub(str, 1, #s) == s
end

function t.string.ends_with(str, s)
	return string.sub(str, #str, #str-#s) == s
end

function t.string.chars(str)
	local i = 1
	return function()
		local res = string.sub(str, i)
		if res == "" or i > #str then return nil end
		i = i + 1
		return res
	end
end
function t.table.has_key(tab, key)
	for k, v in pairs(tab)
	do
		if k == key then return true end
	end
	return false
end

function t.table.has_value(tab, val)
	for value in t.table.itval(tab)
	do
		if value == val then return true end
	end
	return false
end

function t.table.itval(tab)
	local i = 1
	return function ()
		if i >= #tab then return nil end
		i = i + 1
		return tab[i - 1]
	end
end
function t.table.from_iterator(it)
	local tab = {}
	for value in it
	do
		table.insert(tab,it)
	end
	return tab
end
-- totally not taken from /bin/pastebin.lua
function t.url.encode(code)
	if code then
		code = string.gsub(code, "([^%w ])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
		code = string.gsub(code, " ", "+")
	end
	return code
end

function t.url.decode(code)
	if code then
		code = string.gsub(code, "(%%[A-Fa-f0-9][A-Fa-f0-9])", function(c)
			return string.char(tonumber(string.sub(c, 2), 16))
		end)
		code = string.gsub(code, "+", " ")
	end
	return code
end

function t.bytes.string(str)
	local it = t.string.chars(str)
	return function ()
		local ch = it()
		if ch == nil then return nil end
		return string.byte(ch)
	end
end

-- TODO: rewrite these as iterators and replace the originals with t.table.from_iterator stuff
function t.bytes.from_hex(str)
	local out = ""
	for ch in t.string.chars(str)
	do
		out = out .. string.char(ch)
	end
	return out
end

function t.bytes.to_hex(str)
	local out = ""
	for ch in t.bytes.string(str)
	do
		out = out .. string.format("%x", ch)
	end
	return out
end

return t