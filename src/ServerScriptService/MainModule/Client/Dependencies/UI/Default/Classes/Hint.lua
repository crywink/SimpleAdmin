--[[
	SimpleAdmin | Default Hint Class
--]]

local Hint = {}
Hint.__index = Hint

Hint.New = function(Text, Timeout)
	local self = setmetatable({}, Hint)
	
	local Object = script.HintBase:Clone()
	Object.Hint.Hint.Text = Text
	Object.Parent = game:GetService("Players").LocalPlayer.PlayerGui
	Object.Hint.Size = UDim2.new(0, Object.Hint.Hint.TextBounds.X + 10, 0, 0)
	Object.Hint:TweenSize(UDim2.new(0, Object.Hint.Hint.TextBounds.X + 10, 0, Object.Hint.Hint.TextBounds.Y + 20), "In", "Sine", .25, true)
	self.Object = Object
	self.ClassName = "Hint";
	
	coroutine.wrap(function()
		wait(Timeout or 10)
		Object:Destroy()
	end)()
	
	return self
end

return Hint