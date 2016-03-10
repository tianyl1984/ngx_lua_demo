--Ä£¿é
local count = 0;
local function addCount()
	count = count + 1
	ngx.say("count : ",count)
end

local _M = {
	addCount = addCount
}

return _M