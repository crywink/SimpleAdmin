--[[
	SimpleAdmin | Default Message Class
--]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Variables
local Player = Players.LocalPlayer

-- Module
local Message = {}
Message.__index = Message
local ListContainer

Message.Init = function()
	ListContainer = script:WaitForChild("MessageBase")
	ListContainer.Parent = Player:WaitForChild("PlayerGui")
end

Message.New = function(Text, Timeout)
	local self = setmetatable({}, Message)
	
	local Object = script.MessageCard:Clone()
	Object.Text.Text = Text
	Object.Parent = ListContainer.List
	Object.Size = UDim2.new(0, Object.Text.TextBounds.X + 10, 0, 0)
	
	Object:TweenSize(UDim2.new(0, math.max(Object.Text.TextBounds.X + 10, 500), 0, Object.Text.TextBounds.Y + 30), "In", "Sine", .15, true)
	TweenService:Create(Object, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		BackgroundTransparency = 0;
	}):Play()
	self.Object = Object
	
	coroutine.wrap(function()
		wait(Timeout or 10)
		Object:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Sine", .15, true, function()
			Object:Destroy()
		end)
		TweenService:Create(Object, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1;
		}):Play()
	end)()
	
	return self
end

return Message