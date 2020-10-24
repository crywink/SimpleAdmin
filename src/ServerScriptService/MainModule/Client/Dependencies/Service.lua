--[[
	SimpleAdmin | Service [client]
		- Handles a lot of tedious functions/variables
--]]

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Module
local Service = {
	Connections = {};
}

Service.GenerateGuid = function()
	return HttpService:GenerateGUID()
end

Service.Routine = function(func, ...)
	return coroutine.resume(coroutine.create(func, ...))
end

Service.RoundTo = function(Number, Place)
	return math.floor(Number * (10 ^ Place)) / 10 ^ Place
end

Service.MakeDraggable = function(obj, callback)
	callback = callback or function() end
	
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

Service.MakeResizeable = function(Obj, Data, Callback)
	Data = Data or {}

	local Activator = Service.New("ImageButton", {
		BackgroundTransparency = 1;
		ImageTransparency = 1;
		Size = UDim2.new(0, 10, 0, 10);
		Position = UDim2.new(1, -10, 1, -10);
	})
	Activator.Parent = Obj

	Activator.MouseButton1Down:Connect(function()
		local OriginalPosition = Vector2.new(Mouse.X, Mouse.Y)
		local OriginalSize = Obj.AbsoluteSize

		local Connection = RunService.Stepped:Connect(function()
			local CurrentPosition = Vector2.new(Mouse.X, Mouse.Y)
			local NewSize = OriginalSize - (OriginalPosition - CurrentPosition)

			Obj.Size = UDim2.new(0, math.clamp(NewSize.X, Data.MinX or 274, Data.MinY or 9e9), 0, math.clamp(NewSize.Y, Data.MinY or 318, Data.MaxY or 9e9))
			coroutine.wrap(Callback)()
		end)

		local Connection2 
		Connection2 = UserInputService.InputEnded:Connect(function(InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				Connection:Disconnect()
				Connection2:Disconnect()
			end
		end)
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