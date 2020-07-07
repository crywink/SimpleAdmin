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
	self.Object = Object
	
	return self
end

return Text