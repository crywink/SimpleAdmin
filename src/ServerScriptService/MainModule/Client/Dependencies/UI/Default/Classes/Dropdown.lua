--[[
	SimpleAdmin | Default Dropdown Class
--]]

-- Services
local TweenService = game:GetService("TweenService")

-- Module
local Dropdown = {}
Dropdown.__index = Dropdown

Dropdown.New = function(Name, Data)
	local self = {}
	setmetatable(self, Dropdown)
	
	local Obj = script.Holder:Clone()
	Obj.Name = Name
	Obj.Dropdown.Title.Text = Name
	self.Elements = Obj.DropFrame.Holder
	self.Object = Obj
	self.ClassName = "Dropdown"
	self.IsCollapsed = true;
	
	Obj.Dropdown.MouseButton1Click:Connect(function()
		if self.IsCollapsed then
			self:Expand()
		else
			self:Collapse()
		end
	end)
	
	for k,v in pairs(Data or {}) do
		local NewElement = script.Element:Clone()
		
		if type(v) == "table" then
			NewElement.Name = v.Key or tostring(#self.Elements:GetChildren() + 1)
			NewElement.Text = v.Value
		else
			NewElement.Name = tostring(k)
			NewElement.Text = v
		end
		NewElement.Parent = self.Elements	
	end
	
	return self
end

Dropdown.Collapse = function(self)
	local TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	
	TweenService:Create(self.Object.DropFrame, TweenInfo, {
		Size = UDim2.new(1, 0, 0, 0);
	}):Play()
	TweenService:Create(self.Object.Parent, TweenInfo, {
		Size = UDim2.new(1, 0, 0, 24 + 8);
	}):Play()
	TweenService:Create(self.Object.Dropdown.Arrow, TweenInfo, {
		Rotation = 0;
	}):Play()
	
	self.IsCollapsed = true
end

Dropdown.Expand = function(self)
	local List = self.Object.DropFrame.Holder.List
	local TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	
	TweenService:Create(self.Object.DropFrame, TweenInfo, {
		Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 8);
	}):Play()
	TweenService:Create(self.Object.Parent, TweenInfo, {
		Size = UDim2.new(1, 0, 0, 35 + List.AbsoluteContentSize.Y + 8);
	}):Play()
	TweenService:Create(self.Object.Dropdown.Arrow, TweenInfo, {
		Rotation = -180;
	}):Play()
	
	self.IsCollapsed = false
end

Dropdown.AddElement = function(self, Key, Value)
	local NewElement = script.Element:Clone()
	NewElement.Name = Key or tostring(#self.Elements:GetChildren() + 1)
	NewElement.Text = Value
	NewElement.Parent = self.Elements
	NewElement.Size = UDim2.new(1, 0, 0, NewElement.TextBounds.Y + 8)

	return NewElement
end

Dropdown.Clear = function(self)
	for _,v in pairs(self.Elements:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

return Dropdown
