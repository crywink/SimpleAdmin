--[[
	SimpleAdmin | Default Text Class
--]]

-- Services

-- Variables

-- Module
local Text = {}
Text.__index = Text

Text.New = function(Data)
	local self = setmetatable({}, Text)
	
	local Object = script.Text:Clone()
	Object.Title.Text = Data.Text
	Object.Name = Data.Name or Object.Name
	Object.Parent = Data.Parent or Object.Parent
	Object.Title.TextXAlignment = Data.TextXAlignment or Object.Title.TextXAlignment
	Object.Title.TextYAlignment = Data.TextYAlignment or Object.Title.TextYAlignment
	Object.ImageTransparency = Data.ImageTransparency or Object.ImageTransparency
	
	self.Object = Object
	
	return self
end

Text.UpdateSize = function(self)
	self.Object.Size = UDim2.new(1, 0, 0, self.Object.Title.TextBounds.Y + 12)
end

return Text