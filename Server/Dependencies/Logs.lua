--[[
	SimpleAdmin | Logs
		- This is super simple rn... might make it
		  more intuitive but atm I see no need to do so.
--]]

local Logs = {
	_Logs = {};
}

Logs.New = function(key, val)
	if not Logs._Logs[key] then
		Logs._Logs[key] = {}
	end
	
	table.insert(Logs._Logs[key], 1, val)
end

Logs.Get = function(key)
	return Logs._Logs[key]
end

return Logs