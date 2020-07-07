Server, Data, Shared = nil, nil, nil

--[[
	SimpleAdmin | Service
		- Provide easy-to-access variables & functions and/or apply them directly to environment.
--]]

-- Services
local Players = game:GetService("Players")

-- Variables
local Environment = require(script.Parent:WaitForChild("Environment"))
local lower = string.lower
local match = string.match

-- Module
local Service = {
	Instances = {};
	Permissions = {};
	AdminLevels = {
		Moderators = 1;
		Admins = 2;
		Owners = 3;
		Developers = 4;
	}
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

Service.Nuke = function()
	if Server.NetworkDirectory then
		Server.NetworkDirectory:Destroy()
	end
	
	script.Parent:Destroy()
end

Service.FindPlayer = function(str)
	for _,v in pairs(Players:GetPlayers()) do
		if match(lower(v.Name), lower(str)) then
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
		for _,v in pairs(tbl) do
			if v == func then
				return true
			end
		end
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

Service.GetPlayers = function(exclude)
	local Return = Players:GetPlayers()
	if exclude then
		for i = 1, #Return do
			local plr = Return[i]
			for _,Exc in pairs(exclude) do
				if Exc == plr then
					table.remove(Return, i)
				end
			end
		end
	end
	return Return
end

Service.PlayerWrapper = function(plr)
	Environment.Apply()
	return Environment.AddCustomProperties(plr, {
		Data = Data.Cache[plr];
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
			
			local PreviousSave = Data:GetGlobal("Bans")
			PreviousSave[tostring(plr.UserId)] = {
				Moderator = mod;
				Reason = reason;
			}
			Data:SetGlobal("Bans", PreviousSave)
			
			plr:Kick("You have been banned by a moderator.")
		end;
	})
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

Service.GetGlobalPermissionLevel = function(plr)
	Environment.Apply()
	
	local GlobalPermissions = Data:GetGlobal("Permissions")
	return GlobalPermissions[tostring(plr.UserId)]
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

Service.ResolveToUserId = function(query)
	local UserID = tonumber(query) or Players:GetUserIdFromNameAsync(query)
	local Username = (type(query) == "string") and query or Players:GetNameFromUserIdAsync(query)
	
	return {
		UserId = UserID;
		Username = Username;
	}
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