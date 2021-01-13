Service = nil

--[[
	SimpleAdmin | Environment
		- Handles all environment application
--]]

-- Services

-- Variables
local Dependencies = script.Parent

-- Module
local Environment = {
	DefaultEnvironment = {
		Shared = {};
	};
}

local Methods = {"Kick", "Destroy", "Clone", "GetChildren", "GetDescendants", "IsDescendantOf", "DistanceFromCharacter", "LoadCharacter", "GetRankInGroup", "GetRoleInGroup", "FindFirstChild", "WaitForChild"}

Environment.Init = function()
	for _,v in pairs(Dependencies:GetChildren()) do
		if v:IsA("ModuleScript") then
			local mod = require(v)
			if mod and type(mod) == "table" then
				Environment.DefaultEnvironment[v.Name] = mod;
				
				local Success, Error = pcall(function()
					if v.Name ~= "Service" and mod.Init then
						Environment.Apply(mod.Init)()
					end
				end)
			elseif mod and type(mod) == "function" then
				Environment.DefaultEnvironment[v.Name] = Environment.Apply(mod)();
			end
		end
	end
end

Environment.AddCustomProperties = function(inst, props)
	Environment.Apply()
	return setmetatable({}, {
		__index = function(self, key)
			if props[key] ~= nil then
				local prop = props[key]
				return prop
			elseif inst[key] then
				local prop = inst[key]
				if type(prop) == "function" then
					if Service.TableFind(Methods, key) then
						return function(self,...)
							return inst[key](inst,...)
						end
					end
				end
				return prop
			end
		end,
		__newindex = function(self, key, val)
			if props[key] ~= nil then
				props[key] = val
			elseif inst[key] then
				inst[key] = val
			end
		end
	})
end

Environment.Apply = function(func, custom)
	local env = getfenv(func or 2)
	for k,v in pairs(Environment.DefaultEnvironment) do
		env[k] = v
	end
	if custom then
		for k,v in pairs(custom) do
			env[k] = v
		end
	end
	return func
end

return Environment