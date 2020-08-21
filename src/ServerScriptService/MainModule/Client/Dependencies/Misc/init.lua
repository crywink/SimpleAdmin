Environment = nil

--[[
	SimpleAdmin | Misc
		- I could probably make something more practical than this
		  but :dogelaugh:
--]]

-- Module
local Misc = {}
local NoCall = {"Fly"} 

Misc.Init = function()
	for _,v in pairs(script:GetChildren()) do
		if v:IsA("ModuleScript") then
			local mod = require(v)
			Misc[v.Name] = mod
			if type(mod) == "function" then
				local Func = Environment.Apply(mod)
				if not table.find(NoCall, v.Name) then
					Func()
				end
			elseif type(mod) == "table" and mod.Init then
				Environment.Apply(mod.Init)()
			end
		end
	end	
end

return Misc