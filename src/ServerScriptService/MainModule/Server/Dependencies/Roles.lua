Commands, Service, Data = nil, nil, nil

--[[
    SimpleAdmin | Roles
--]]

-- Services

-- Variables

-- Module
local Roles = {
	PermissionFlags = {
		["ADMINISTRATOR"] = 0x00000001; -- All permissions
		["GUEST"] = 0x00000002; -- Default permissions
		
		["KICK_PLAYERS"] = 0x00000004; -- Kick players
		["BAN_PLAYERS"] = 0x00000008; -- Ban/unban players
		["WARN_PLAYERS"] = 0x00000010; -- Warn players
		["MUTE_PLAYERS"] = 0x00000020; -- Mute/unmute players
		
		["MANAGE_CHARACTERS"] = 0x00000040; -- Access to commands that manage character (kill, respawn, health, etc...)
		["MANAGE_GAME"] = 0x00000080; -- Server lock, shutdown, etc...
		["MANAGE_ROLES"] = 0x00000100; -- Ability to add/remove player roles.
		["MANAGE_BACKPACK"] = 0x00000200; -- Anything that accesses backpack (removetools, viewtools, ...)
		["MANAGE_WAYPOINTS"] = 0x00000400; -- Ability to add/remove waypoints.
		["MANAGE_GROUP_BANS"] = 0x00000800; -- Ability to add/remove/view banned groups.
		
		["VIEW_LOGS"] = 0x00001000; -- Ability to view all logs (join logs, command logs, chat logs)
		["VIEW_COMMANDS"] = 0x00002000; -- Ability to view commands.
		["VIEW_STAFF"] = 0x00004000; -- Ability to view staff list.
		["VIEW_PLAYER_DATA"] = 0x00008000; -- Ability to view player data.
		
		["MODIFY_PLAYER_INSTANCE"] = 0x00010000; -- Access to commands that modify player instance. (leaderstats, etc...)
		["BROADCAST_MESSAGES"] = 0x00020000; -- Access to commands that broadcast messages globally.
		["DONATOR_PERKS"] = 0x00040000; -- Access to donator perks.
		["SHUTDOWN_GAME"] = 0x00060000; -- Ability to shut down game.
		["LOCK_SERVER"] = 0x00080000; -- Ability to lock server.
		
		["PLAY_SOUND"] = 0x00100000; -- Ability to play music/sounds.
		["MANAGE_SOUNDS"] = 0x00200000; -- Ability to add/remove songs from queue.
	};
	ExistingRoles = {
		{
			Name = "Moderator";
			Cluster = 258684; -- To see what flags this allows, refer to Roles.UnpackFlags
		}
	};
}

-- Converts an array of permission bits into a cluster.
Roles.CalculateBit = function(PermissionList)
	return bit32.bor(unpack(PermissionList))
end

-- Returns whether or not the passed permission cluster contains the passed permission value.
Roles.HasPermission = function(Cluster, Permission)
	Cluster = tonumber(Cluster) or Roles.CalculateBit(Cluster)
	
	return bit32.band(Cluster, Permission) == Permission
end

-- This will convert the passed bit value to an array of flag labels. 
Roles.UnpackFlags = function(Cluster)
	local Unpacked = {}
	
	for k,v in pairs(Roles.PermissionFlags) do
		if Roles.HasPermission(Cluster, v) then
			Unpacked[k] = v
		end
	end
	
	return Unpacked
end

-- Allows you to fetch a role's index in the table.
Roles.GetRoleIndex = function(Role)
    local Existing = Roles.ExistingRoles
    for i = 1, #Existing do
        if Existing[i] == Role then
            return i
        end
    end
end

-- Allows you to fetch a role by it's label.
Roles.GetRoleByName = function(Name)
    for _,v in ipairs(Roles.ExistingRoles) do
        if v.Name == Name then
            return v
        end
    end
end

-- Creates a role with the specified name and permissions.
Roles.CreateRole = function(Name, Cluster, Order, Members, Save)
	local Order = Order or (#Roles.ExistingRoles + 1)
	local Id = Service.HttpService:GenerateGUID()
	local Cluster = tonumber(Cluster) or Roles.CalculateBit(Cluster)
	local RoleObject = {
		Name = Name;
		Cluster = Cluster;
		Id = Id;
		Members = Members or {};
	}

	if Save then
		local RoleData = Data:GetGlobal("Roles") or Service.CopyTable(Roles.ExistingRoles)
		table.insert(RoleData, RoleObject)
		Roles.SaveRoleData(RoleData)
	end

	return table.insert(Roles.ExistingRoles, RoleObject)
end

-- Saves role data as it is or saves to overwrite table.
Roles.SaveRoleData = function(Overwrite)
	return Data:SetGlobal("Roles", Overwrite or Roles.ExistingRoles)
end

-- Runs when the script is initialized
Roles.Init = function()

	-- Iterate through existing commands and convert the flags to their respective bit value.
    for _,Command in pairs(Commands.Commands) do
        for Idx,FlagName in ipairs(Command.Flags or {}) do
            local BitValue = Roles.PermissionFlags[FlagName]
            if BitValue then
                Command.Flags[Idx] = BitValue;
            end
        end
    end
end

-- Adding an example role
table.insert(Roles, {
	Name = "ExampleRole";
	Cluster = Roles.CalculateBit({
		Roles.PermissionFlags.GUEST;
		Roles.PermissionFlags.MUTE_PLAYERS;
	})
})

return Roles