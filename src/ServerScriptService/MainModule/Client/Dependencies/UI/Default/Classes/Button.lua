--[[
	SimpleAdmin | Default Button Class
--]]

-- Services
local TweenService = game:GetService("TweenService")

-- Variables
local TweenInfo = TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- Module
local Button = {}
Button.__index = Button

Button.New = function(Data)
	local self = setmetatable({}, Button)
	self.Function = Data.Function
	
	local Object = script.Button:Clone()
	Object.Title.Text = Data.Text
	Object.Name = Data.Name or Object.Name
	self.Object = Object
	
	Object.MouseButton1Click:Connect(function()
		self:Activate(true)
	end)
	
	Object.MouseButton1Down:Connect(function()
		self:Activate()
	end)
	
	Object.MouseButton1Up:Connect(function()
		self:Deactivate()
	end)
	
	Object.MouseLeave:Connect(function()
		self:Deactivate()
	end)
	
	if Data.Parent then
		Object.Parent = Data.Parent
	end
	
	return self
end

Button.Activate = function(self, CallFunc)
	if CallFunc then
		coroutine.wrap(self.Function)()
	end
	
	TweenService:Create(self.Object.Icon, TweenInfo, {
		ImageColor3 = Color3.fromRGB(35, 35, 35)
	}):Play()
	TweenService:Create(self.Object.Title, TweenInfo, {
		TextColor3 = Color3.fromRGB(35, 35, 35)
	}):Play()
	TweenService:Create(self.Object, TweenInfo, {
		ImageColor3 = Color3.fromRGB(255, 255, 255)
	}):Play()
end

Button.Deactivate = function(self)
	TweenService:Create(self.Object.Icon, TweenInfo, {
		ImageColor3 = Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(self.Object.Title, TweenInfo, {
		TextColor3 = Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(self.Object, TweenInfo, {
		ImageColor3 = Color3.fromRGB(35, 35, 35)
	}):Play()
end

return Button