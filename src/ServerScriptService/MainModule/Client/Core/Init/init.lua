Service, Shared = nil, nil

--[[
	SimpleAdmin | Init [client]
--]]

return function()
	local SimpleAdmin = script.Parent.Parent
	local Core = script.Parent
	local Dependencies = SimpleAdmin:WaitForChild("Dependencies")
	local Environment = require(Dependencies:WaitForChild("Environment"))
	Environment.Init()
	Environment.Apply()
	local _Shared = Service.ReplicatedStorage:WaitForChild("Shared")
	
	for _,v in pairs(_Shared:GetChildren()) do
		if v:IsA("ModuleScript") then
			local mod = require(v)
			if mod.Init then
				Environment.Apply(mod.Init)()
			end
			Environment.DefaultEnvironment.Shared[v.Name] = mod
		end
	end
	
	for _,v in pairs(Dependencies:GetChildren()) do
		if v:IsA("ModuleScript") and v ~= Dependencies.Environment and v ~= Dependencies.Service then
			local mod = require(v)
			if type(mod) == "function" then
				Environment.Apply(mod)()
			elseif type(mod) == "table" then
				if mod.Init then
					Environment.Apply(mod.Init)()
				end
			end
		end
	end
	
	for _,v in pairs(Core:GetChildren()) do
		if  v ~= script and v:IsA("ModuleScript") then
			local mod = require(v)
			if type(mod) == "function" then
				Environment.Apply(mod)()
			elseif type(mod) == "table" then
				if mod.Init then
					Environment.Apply(mod.Init)()
				end
			end
		end
	end
	
	local Main = require(SimpleAdmin:WaitForChild("Main"))
	Environment.Apply(Main)()
end