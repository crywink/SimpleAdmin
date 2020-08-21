Service = nil

--[[
	SimpleAdmin | Environment [client]
		- Handles all environment application
--]]

-- Services

-- Variables
local Dependencies = script.Parent

-- Module
local Environment = {
	DefaultEnvironment = {
		Client = {};
		Shared = {};
		warn = function(...)
			warn("SimpleAdmin Client |",...)
		end
	};
}
local Methods = {"Kick", "Destroy", "Clone"}

Environment.Init = function()
	for _,v in pairs(Dependencies:GetChildren()) do
		if v:IsA("ModuleScript") then
			local mod = require(v)
			if mod and type(mod) == "table" then
				Environment.DefaultEnvironment[v.Name] = mod;
			end
		end
	end
end

Environment.AddCustomProperties = function(inst, props)
	Environment.Apply()
	return setmetatable({}, {
		__index = function(self, key)
			if props[key] then
				local prop = props[key]
				return prop
			elseif inst[key] then
				local prop = inst[key]
				if type(prop) == "function" then
					if inst.Kick and Service.TableFind(Methods, key) then
						return function(self,...)
							return inst[key](inst,...)
						end
					end
				end
				return prop
			end
		end,
		__newindex = function(self, key, val)
			if props[key] then
				props[key] = val
			elseif inst[key] then
				inst[key] = val
			end
		end
	})
end

Environment.Apply = function(func)
	local env = getfenv(func or 2)
	for k,v in pairs(Environment.DefaultEnvironment) do
		env[k] = v
	end
	return func
end

return Environment