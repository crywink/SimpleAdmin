--[[
	SimpleAdmin | Default Toggle Class
--]]

-- Services
local TweenService = game:GetService("TweenService")

-- Variables

-- Module
local Toggle = {}
Toggle.__index = Toggle

Toggle.New = function(Data)
	local self = setmetatable({}, Toggle)
	self.Function = Data.Function
	self.Activated = false
	
	local Object = script.Toggle:Clone()
	Object.Title.Text = Data.Text
	Object.Name = Data.Name or Object.Name
	
	self.Object = Object
	
	Object.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	if Data.Default then
		self:Activate()
	else
		self:Deactivate()
	end
	
	return self
end

Toggle.Activate = function(self)
	self.Activated = true
	
	TweenService:Create(self.Object.Back.Checkmark, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		ImageTransparency = 0;
	}):Play()
	
	coroutine.wrap(self.Function)(true)
end

Toggle.Deactivate = function(self)
	self.Activated = false
	
	TweenService:Create(self.Object.Back.Checkmark, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1;
	}):Play()
	
	coroutine.wrap(self.Function)(false)
end

Toggle.Toggle = function(self)
	if not self.Activated then
		self:Activate()
	else
		self:Deactivate()
	end
end

return Toggle
