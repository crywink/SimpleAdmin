Service, Config = nil, nil

--[[
	SimpleAdmin | Data
--]]

-- Variables
local Environment = require(script.Parent:WaitForChild("Environment"))
local DataStoreService = game:GetService("DataStoreService")

-- Module
local Data = {
	DefaultPlayerData = {}; -- This is data that'll be assigned to the player when they join.
	DefaultGlobalData = { -- This is data that is saved live and needs to be shared across all game servers.
		Permissions = {};
		Bans = {};
	};
	Cache = {}; -- We don't want to hit API limits; this will keep player data while they're in-game and it'll be saved when they leave.
	GlobalDataStore = nil; -- These are set when the script is initialized because we need to access the SimpleAdmin environment to get the key.
	PlayerDataStore = nil; -- ^
}

Data.Init = function()
	Environment.Apply()
	
	Data.GlobalDataStore = DataStoreService:GetDataStore(Config.DataStoreKey .. "_GLOBAL");
	Data.PlayerDataStore = DataStoreService:GetDataStore(Config.DataStoreKey .. "_PLAYERS");
	
	for i = 1, 3 do
		local Success, Return = pcall(function()
			for k,v in pairs(Data.DefaultGlobalData) do
				local GlobalData = Data.GlobalDataStore:GetAsync(k)
				if not GlobalData then
					Data.GlobalDataStore:SetAsync(k, v)
				end
			end
		end)
		if Success then
			break
		else
			warn("SimpleAdmin | Data Init Error | " .. Return)
		end
	end
	
	local function PlayerAdded(plr)
		local PlayerData = Data.PlayerDataStore:GetAsync(plr.UserId) or Service.CopyTable(Data.DefaultPlayerData)
		if PlayerData then
			Data.Cache[plr] = PlayerData
		end
	end
	
	local function SaveData(plr)
		local PlayerData = Data.Cache[plr]
		if PlayerData then
			Data.PlayerDataStore:SetAsync(plr.UserId, PlayerData)	
		end
	end
	
	local function PlayerRemoving(plr)
		SaveData(plr)
	end
	
	for _,v in pairs(Service.Players:GetPlayers()) do
		PlayerAdded(v)
	end
	
	game:BindToClose(function()
		for _,v in pairs(Service.GetPlayers()) do
			SaveData(v)
		end
	end)
	
	Service.Players.PlayerAdded:Connect(PlayerAdded)
	Service.Players.PlayerRemoving:Connect(PlayerRemoving)
end

Data.GetGlobal = function(self, key)
	for i = 1, 3 do
		local Ret
		local Success, Return = pcall(function()
			local GlobalData = Data.GlobalDataStore:GetAsync(key)
			if GlobalData then
				Ret = GlobalData
			end
		end)
		if Success then
			return Ret
		else
			warn("SimpleAdmin | GetGlobal Error | " .. Return)
		end
	end
end

Data.SetGlobal = function(self, key, val)
	for i = 1, 3 do
		local Success, Return = pcall(function()
			Data.GlobalDataStore:SetAsync(key, val)
		end)
		if Success then
			break
		else
			warn("SimpleAdmin | SetGlobal Error | " .. Return)
		end
	end
end

return Data