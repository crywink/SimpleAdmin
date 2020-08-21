Environment = nil

--[[
	SimpleAdmin | Misc [SERVER]
--]]

-- Module
local Misc = {}

Misc.Init = function()
	for _,v in pairs(script:GetChildren()) do
		if v:IsA("ModuleScript") then
			local mod = require(v)
			Misc[v.Name] = mod
			if type(mod) == "function" then
				Environment.Apply(mod)()
			elseif type(mod) == "table" and mod.Init then
				Environment.Apply(mod.Init)()
			end
		end
	end
end

return Misc