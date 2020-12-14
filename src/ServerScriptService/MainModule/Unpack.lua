--[[
	SimpleAdmin | Initialization
		- Unpack everything and place it where it should go
		- Run all init variations
--]]

-- Services

-- Variables
local SimpleAdmin = _G.SimpleAdmin
local Packages = SimpleAdmin:WaitForChild("Packages")
local sSettings = require(SimpleAdmin:WaitForChild("Settings"))
local Container = script.Parent
local Shared = Container:WaitForChild("Shared")
local Server = Container:WaitForChild("Server")
local Client = Container:WaitForChild("Client")
local Environment = require(Server:WaitForChild("Dependencies"):WaitForChild("Environment"))
Environment.Init()

-- Module
return function(Config)
	Server.Parent = game:GetService("ServerScriptService")
	
	for _,v in pairs(Packages:WaitForChild("Themes"):GetChildren()) do
		if v:IsA("ModuleScript") then
			v.Parent = Client.Dependencies.UI
		end
	end
	
	for _,v in pairs(game:GetService("Players"):GetPlayers()) do
		Client:Clone().Parent = v:WaitForChild("PlayerGui")
	end
	Client.Parent = game:GetService("StarterPlayer").StarterPlayerScripts
	Shared.Parent = game:GetService("ReplicatedStorage")
	Environment.DefaultEnvironment.Config = Config
	
	for _,v in pairs(Packages:WaitForChild("Server"):GetChildren()) do
		if v:IsA("ModuleScript") then
			v.Parent = Server.Core
		end
	end
	
	for _,v in pairs(Packages:WaitForChild("Client"):GetChildren()) do
		if v:IsA("ModuleScript") then
			v.Parent = Client.Core
		end
	end
	
	for _,Directory in pairs({Shared,Server,Client}) do
		if Directory == Server then
			local Dependencies = Directory:WaitForChild("Dependencies")
			local Core = Directory:WaitForChild("Core")
			local Handler = Directory:WaitForChild("Main")
			
			if Handler then
				Handler = require(Handler)
				if type(Handler) == "function" then
					Environment.Apply(Handler)()
				end
			end
			
			if Core then
				for _,v in pairs(Core:GetChildren()) do
					if v:IsA("ModuleScript") then
						local mod = require(v)
						if type(mod) == "table" and mod.Init then
							Environment.Apply(mod.Init)()
						elseif type(mod) == "function" then
							Environment.Apply(mod)()
						end
					end
				end
			end
		elseif Directory == Shared then
			local Network = require(Directory:WaitForChild("Network"))
			Environment.DefaultEnvironment.Shared.Network = Network
			Environment.DefaultEnvironment.Shared.Event = require(Directory:WaitForChild("Event"))
			Environment.Apply(Network.Init)()
		end
	end
	
	script:Destroy()
end
