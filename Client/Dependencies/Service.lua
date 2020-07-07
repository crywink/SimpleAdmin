--[[
	SimpleAdmin | Service [client]
		- Handles a lot of tedious functions/variables
--]]

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Module
local Service = {}

Service.GenerateGuid = function()
	return HttpService:GenerateGUID()
end

Service.Routine = function(func, ...)
	return coroutine.resume(coroutine.create(func, ...))
end

Service.MakeDraggable = function(obj, callback)
	local Dragging;
	local DragInput;
	local DragStart;
	local StartPosition;
	
	obj.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = InputObject.Position
			StartPosition = obj.Position
			coroutine.wrap(callback)()
			
			InputObject.Changed:Connect(function()
				if InputObject.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	
	obj.InputChanged:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseMovement or InputObject.UserInputType == Enum.UserInputType.Touch then
			DragInput = InputObject
		end
	end)
	
	UserInputService.InputChanged:Connect(function(InputObject)
		if InputObject == DragInput and Dragging then
			local Delta = InputObject.Position - DragStart
			obj.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		end
	end)
end

Service.New = function(Class, Properties)
	local Inst = Instance.new(Class)
	for k,v in pairs(Properties) do
		Inst[k] = v
	end
	return Inst
end

Service.Pascal = function(str)
	return str:sub(1,1):upper() .. str:sub(2, #str):lower()
end

return setmetatable({}, {
	__index = function(self, key)
		return Service[key] or game:GetService(key)
	end
})