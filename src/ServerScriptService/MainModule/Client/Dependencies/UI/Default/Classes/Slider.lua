--[[
	SimpleAdmin | Default Slider Class
--]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Module
local Slider = {}
Slider.__index = Slider

Slider.New = function(Data)
	Data = Data or {}
	local self = setmetatable({}, Slider)
	
	local Object = script.Slider:Clone()
	local Filler = Object:WaitForChild("Filler")
	local Keys = {Object.Key, Filler.Key}
	local Values = {Object.Value, Filler.Value}
	
	self.Object = Object
	self.Keys = Keys
	self.Values = Values
	self.Dragging = false
	self.ClassName = "Slider";
	
	for _,v in ipairs(Keys) do
		v.Text = Data.Text
	end
	
	if Data.OnChanged then
		self.OnChanged = Data.OnChanged
	end
	
	if Data.OnEnded then
		self.OnEnded = Data.OnEnded
	end
	
	if Data.HideValues then
		for _,v in ipairs(Keys) do
			v.Visible = false
		end
	end
	
	Filler.Size = UDim2.new(0,0,0,Object.Size.Y.Offset)
	
	local function ActivateSlide()
		if self.DragConnection then
			pcall(self.DragConnection.Disconnect, self.DragConnection)
		end
		
		self.Dragging = true
		self.DragConnection = RunService.Stepped:Connect(function()
			if not self.Dragging then
				self.DragConnection:Disconnect()
			end
			
			local LeftMost = Object.AbsolutePosition.X
			local Progress = math.clamp(((Mouse.X - LeftMost) / Object.AbsoluteSize.X), 0, 1)
			self.Progress = Progress
			
			Filler:TweenSize(UDim2.new(0, math.clamp(Mouse.X - LeftMost, 0, Object.AbsoluteSize.X - 3), 0, Object.Size.Y.Offset), "Out", "Sine", .05, true)
			
			if self.OnChanged then
				self:OnChanged(Progress)
			end	
		end)
	end
	
	self.Connections = {
		Object.MouseButton1Down:Connect(ActivateSlide);
		Filler.MouseButton1Down:Connect(ActivateSlide);
		UserInputService.InputEnded:Connect(function(InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				if self.Dragging then
					self.Dragging = false
					
					if self.OnEnded then
						self:OnEnded(self.Progress)
					end
				end
			end
		end)
	}
	
	return self
end

Slider.UpdateSize = function(self)
	local Object = self.Object
	local Filler = Object.Filler
	local Difference = (Filler.Value.AbsoluteSize.X - Object.Value.AbsoluteSize.X)
	
	Filler.Value.Size = UDim2.new(0, ((Object.AbsoluteSize.X + Object.Value.AbsoluteSize.X) / 2) - Difference, 1, 0)
end

Slider.Destroy = function(self)
	for _,v in ipairs(self.Connections) do
		pcall(v.Disconnect, v)
	end
	pcall(self.DragConnection.Disconnect, self.DragConnection)
	self.Object:Destroy()
	self = nil
end

return Slider