Service, Server = nil, nil

--[[
	SimpleAdmin | Network Handler
--]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Constants
local NetworkDirectory
local EventsDirectory
local FunctionsDirectory
local PrimDirectory = game:GetService("JointsService")

-- Variables
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

-- Main Module
local Network = {}

--[[
	SHARED FUNCTIONS
--]]

Network.CreateEvent = function(self, key)
	assert(IsServer, "You cannot create an event from the client.")
	
	local NewEvent = Instance.new("RemoteEvent")
	NewEvent.Parent = EventsDirectory
	NewEvent.Name = key
	
	return NewEvent
end

Network.CreateFunction = function(self, key)
	assert(IsServer, "You cannot create a function from the client.")
	
	local NewFunction = Instance.new("RemoteFunction")
	NewFunction.Parent = FunctionsDirectory
	NewFunction.Name = key
	
	return NewFunction
end

Network.GetEvent = function(self, key)
	return IsClient and EventsDirectory:WaitForChild(key, 5) or (IsServer and (EventsDirectory:FindFirstChild(key) or Network:CreateEvent(key)))
end

Network.GetFunction = function(self, key)
	return IsClient and FunctionsDirectory:WaitForChild(key, 5) or IsServer and FunctionsDirectory:FindFirstChild(key) or Network:CreateFunction(key)
end

Network.AwaitEvent = function(self, RemoteName, Function)
	local Connection
	Connection = EventsDirectory.ChildAdded:Connect(function(Remote)
		if Remote.Name == RemoteName then
			Remote.OnClientEvent:Connect(function(...)
				Function(...)
			end)
			Connection:Disconnect()
		end
	end)
end

Network.AwaitFunction = function(self, RemoteName, Function)
	local Connection
	Connection = FunctionsDirectory.ChildAdded:Connect(function(Remote)
		if Remote.Name == RemoteName then
			Remote.OnClientInvoke = function(...)
				Function(...)
			end
			Connection:Disconnect()
		end
	end)
end

Network.BindEvent = function(self, data)
	if IsServer then
		for RemoteName, Function in pairs(data) do
			local Remote = Network:GetEvent(RemoteName)
			
			Remote.OnServerEvent:Connect(function(...)
				Function(...)
			end)
		end
	elseif IsClient then
		for RemoteName, Function in pairs(data) do
			coroutine.wrap(function()
				local Remote = Network:GetEvent(RemoteName)
				
				if Remote then
					Remote.OnClientEvent:Connect(function(...)
						Function(...)
					end)
				else
					Network:AwaitEvent(RemoteName, Function)
				end
			end)()
		end
	end
end

Network.BindFunction = function(self, data)
	if IsServer then
		for RemoteName, Function in pairs(data) do
			local Remote = Network:GetFunction(RemoteName)
			
			Remote.OnServerInvoke = function(...)
				return Function(...)
			end
		end
	elseif IsClient then
		for RemoteName, Function in pairs(data) do
			coroutine.wrap(function()
				local Remote = Network:GetFunction(RemoteName)
				
				if Remote then
					Remote.OnClientInvoke = function(...)
						Function(...)
					end
				else
					Network:AwaitFunction(RemoteName, Function)
				end
			end)()
		end
	end
end

--[[
	CLIENT FUNCTIONS
--]]

Network.FireServer = function(self, key, ...)
	assert(IsClient, "You cannot call FireServer from server!")
	
	local Event = Network:GetEvent(key)
	if Event then
		Event:FireServer(...)
	end		
end

Network.InvokeServer = function(self, key, ...)
	assert(IsClient, "You cannot call InvokeServer from server!")
	
	local Function = Network:GetFunction(key)
	if Function then
		return Function:InvokeServer(...)
	end	
end

--[[
	SERVER FUNCTIONS
--]]

Network.Init = function()
	if IsServer then
		NetworkDirectory = Service.New("Folder", {
			Name = "_SimpleAdmin_Network";
			Parent = PrimDirectory;
		})
		EventsDirectory = Service.New("Folder", {
			Name = "Events";
			Parent = NetworkDirectory;
		})
		FunctionsDirectory = Service.New("Folder", {
			Name = "Functions";
			Parent = NetworkDirectory;
		})
		
		Server.NetworkDirectory = NetworkDirectory
	else
		NetworkDirectory = PrimDirectory:WaitForChild("_SimpleAdmin_Network")
		EventsDirectory = NetworkDirectory:WaitForChild("Events")
		FunctionsDirectory = NetworkDirectory:WaitForChild("Functions")
		
		for _,v in pairs({NetworkDirectory, EventsDirectory, FunctionsDirectory}) do
			v.Name = Service.GenerateGuid()
		end
	end
end

Network.FireClient = function(self, plr, key, ...)
	assert(IsServer, "You cannot call FireClient from the client!")
	
	local Event = Network:GetEvent(key)
	Event:FireClient(plr, ...)
end

Network.InvokeClient = function(self, plr, key, ...)
	assert(IsServer, "You cannot call InvokeClient from the client!")
	
	local Function = Network:GetFunction(key)
	return Function:InvokeClient(plr, ...)
end

Network.FireAllClientsWithinDistance = function(self, plr, distance, key, ...)
	assert(IsServer, "You cannot call FireAllClientsWithinDistance from the client!")
	local Character = plr.Character
	if Character then
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart then
			for _,v in pairs(Players:GetPlayers()) do
				if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
					if plr:DistanceFromCharacter(v.Character.HumanoidRootPart.Position) <= distance then
						Network:FireClient(v, key, ...)
					end
				end
			end
		end
	end
end

Network.FireClients = function(self, players, key, ...)
	for _,v in pairs(players) do
		if type(v) == "userdata" and v:IsA("Player") then
			Network:FireClient(v, key, ...)
		end
	end
end

Network.FireAllClients = function(self, key, ...)
	for _,v in pairs(Players:GetPlayers()) do
		Network:FireClient(v, key, ...)
	end
end

return Network 