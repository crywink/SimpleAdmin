Server, Data, Shared = nil, nil, nil

--[[
	SimpleAdmin | Service
		- Provide easy-to-access variables & functions and/or apply them directly to environment.
--]]

-- Services
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local Teams = game:GetService("Teams")

-- Variables
local Environment = require(script.Parent:WaitForChild("Environment"))
local lower = string.lower
local match = string.match
local sub = string.sub

-- Module
local Service = {
	Instances = {};
	Permissions = {};
	AdminLevels = {
		Guest = 0;
		Donators = 1;
		Moderators = 2;
		Admins = 3;
		Owners = 4;
		Developers = 5;
	};
	PlayerWrappers = {}; -- we will cache player wrappers so they can be compared and share values
}

Service.Split = function(String, Deliminator)
	Deliminator = Deliminator or " ";
	local Parsed = {};
	for i in string.gmatch(String, "([^" .. Deliminator .. "]*)(" .. Deliminator .. "?)") do
		if i ~= "" then
            table.insert(Parsed, i)
        end
	end
	return Parsed
end

Service.GetLevelTitle = function(level)
	for k,v in pairs(Service.AdminLevels) do
		if v == level then
			return k
		end
	end
end

Service.New = function(Class, Properties)
	local Inst = Instance.new(Class)
	for k,v in pairs(Properties) do
		Inst[k] = v
	end
	table.insert(Service.Instances, Inst)
	return Inst
end

Service.GenerateGuid = function()
	return game:GetService("HttpService"):GenerateGUID()
end

Service.CopyTable = function(tbl, copies) -- thanks lua.org :dogelaugh:
    copies = copies or {}
    local orig_type = type(tbl)
    local copy
    if orig_type == 'table' then
        if copies[tbl] then
            copy = copies[tbl]
        else
            copy = {}
            copies[tbl] = copy
            for orig_key, orig_value in next, tbl, nil do
                copy[Service.CopyTable(orig_key, copies)] = Service.CopyTable(orig_value, copies)
            end
            setmetatable(copy, Service.CopyTable(getmetatable(tbl), copies))
        end
    else
        copy = tbl
    end
    return copy
end

Service.StartsWith = function(String, Compare)
	return sub(String, 1, #Compare) == Compare
end

Service.Nuke = function()
	if Server.NetworkDirectory then
		Server.NetworkDirectory:Destroy()
	end
	
	script.Parent:Destroy()
end

Service.FindPlayer = function(str)
	for _,v in ipairs(Players:GetPlayers()) do
		if Service.StartsWith(lower(v.Name), lower(str)) then
			return v
		end
	end
end

Service.FindTeam = function(str)
	for _,v in ipairs(Teams:GetChildren()) do
		if v:IsA("Team") and Service.StartsWith(lower(v.Name), lower(str)) then
			return v
		end
	end
end

Service.TableFind = function(tbl, func)
	if type(func) == "function" then
		for _,v in pairs(tbl) do
			if func(v) then
				return true
			end
		end
	else
		return table.find(tbl, func)
	end
	return false
end

Service.GetLength = function(obj)
	local len = 0
	if type(obj) == "table" then
		for _,v in pairs(obj) do
			len = len + 1
		end
	end
	return len	
end

Service.GetPlayers = function(exclude, wrap)
	local Return = {}
	
	for _,v in ipairs(Players:GetPlayers()) do
		if not table.find(exclude or {}, v) then
			table.insert(Return, wrap and Service.PlayerWrapper(v) or v)
		end
	end
	
	return Return
end

Service.PlayerWrapper = function(plr)
	Environment.Apply()
	
	if not plr or type(plr) ~= "userdata" or not plr:IsA("Player") then
		return
	end
	
	if not Data.Cache[plr] then
		Data.Cache[plr] = Data.GetPlayerData(plr)
	end
	
	if not Service.PlayerWrappers[plr] then
		Service.PlayerWrappers[plr] = Environment.AddCustomProperties(plr, {
			Data = Data.Cache[plr];
			Temp = {};
			
			Ping = 0;
			PingSent = 0;
			IsWindowFocused = true;
			
			_Object = plr;
			GetLevel = function()
				return Service.GetPermissionLevel(plr)
			end;
			GetHumanoid = function()
				return Service.GetHumanoid(plr)
			end;
			Send = function(...)
				return Shared.Network:FireClient(plr, ...)
			end;
			Ban = function(mod, reason)
				Environment.Apply()
				
				Service.BanUser(plr.UserId)
				
				plr:Kick("\n| SimpleAdmin |\nYou have been banned by a moderator.\nReason: " .. (reason or "N/A"))
			end;
		})
	end
	
	return Service.PlayerWrappers[plr]
end

Service.BanUser = function(UserId, Reason, Moderator)
	Environment.Apply()
	
	local PreviousSave = Data:GetGlobal("Bans")
	PreviousSave[tostring(UserId)] = {
		Moderator = Moderator;
		Reason = Reason;
	}
	Data:SetGlobal("Bans", PreviousSave)
end

Service.SetPermissionLevel = function(plr, level, save)
	Environment.Apply()
	
	if save then
		local GlobalData = Data:GetGlobal("Permissions")
		GlobalData[tostring(plr.UserId)] = level
		Data:SetGlobal("Permissions", GlobalData)
	end
	
	Service.Permissions[plr.UserId] = level
end

Service.IsValidSoundId = function(SoundId)
    local Success, Data = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(SoundId).AssetTypeId
    end)
    return Success and Data == 3
end

Service.FilterText = function(text, from, to)
	local TextObject
	do
		local Success,_ = pcall(function()
			TextObject = TextService:FilterStringAsync(text, from, Enum.TextFilterContext.PublicChat)
		end)
		if not Success then
			TextObject = nil
		end
	end
	
	if TextObject then
		local Text
		local Success,_ = pcall(function()
			Text = TextObject:GetChatForUserAsync(to)
		end)
		if Success then
			return Text
		end
	end
end

Service.GetGlobalPermissionLevel = function(plr)
	Environment.Apply()
	
	local GlobalPermissions = Data:GetGlobal("Permissions")
	return GlobalPermissions[type(plr) ~= "userdata" and tostring(plr) or tostring(plr.UserId)]
end

Service.GetPermissionLevel = function(plr)
	Environment.Apply()
	
	for k,v in pairs(Service.Permissions) do
		if k == plr.UserId or lower(k) == lower(plr.Name) then
			return v
		end
	end
	
	local GlobalPerm = Service.GetGlobalPermissionLevel(plr)
	if GlobalPerm then
		Service.Permissions[plr.UserId] = GlobalPerm
		return GlobalPerm
	end
	
	return 0
end

Service.PcallReturn = function(func, default)
	local Success, Data = pcall(func)
	
	return Success and Data or default
end

Service.ResolveToUserId = function(query)
	local UserID = tonumber(query) or Service.PcallReturn(function()
		return Players:GetUserIdFromNameAsync(query)
	end, "[Failed User Id]")
	local Username = (not tonumber(query)) and query or Service.PcallReturn(function()
		return Players:GetNameFromUserIdAsync(query)
	end, "[Failed Username]")
	
	return {
		UserId = UserID;
		Username = Username;
	}
end

Service.BindCustomConnection = function(ConnectionType, Name, Function)
	Environment.Apply()
	
	if not Server.CustomConnections[ConnectionType] then
		Server.CustomConnections[ConnectionType] = {}	
	end
	
	Server.CustomConnections[ConnectionType][Name] = {
		Function = Function;
		Disconnect = function(self)
			self = nil;
		end
	}
	
	return Server.CustomConnections[ConnectionType][Name]
end

Service.UnbindCustomConnection = function(ConnectionType, Name)
	Environment.Apply()
	
	local Conn = Server.CustomConnections[ConnectionType][Name]
	if Conn then
		Conn:Disconnect()
	end
end

Service.TableReplace = function(tbl, find, repl)
	local Table = {}
	for Key,Val in pairs(tbl) do
		if Val == find then
			Table[Key] = repl
		else
			Table[Key] = Val
		end
	end
	return Table
end

Service.GetHumanoid = function(plr)
	return plr.Character and plr.Character:FindFirstChild("Humanoid") or nil
end

return setmetatable({}, {
	__index = function(self, key)
		return Service[key] or game:GetService(key)
	end
})