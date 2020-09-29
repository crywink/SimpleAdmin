Commands, Service = nil, nil

--[[
    SimpleAdmin | Roles
--]]

-- Services

-- Variables

-- Module
local Roles = {
	PermissionFlags = {
		["ADMINISTRATOR"] = 0x00000001;
		["GUEST"] = 0x00000002;
		
		["KICK_PLAYERS"] = 0x00000004;
		["BAN_PLAYERS"] = 0x00000008;
		["WARN_PLAYERS"] = 0x00000010;
		["MUTE_PLAYERS"] = 0x00000020;
		
		["MANAGE_CHARACTERS"] = 0x00000040;
		["MANAGE_GAME"] = 0x00000080;
		["MANAGE_ROLES"] = 0x00000100;
		["MANAGE_BACKPACK"] = 0x00000200;
		["MANAGE_WAYPOINTS"] = 0x00000400;
		["MANAGE_GROUP_BANS"] = 0x00000800;
		
		["VIEW_LOGS"] = 0x00001000;
		["VIEW_COMMANDS"] = 0x00002000;
		["VIEW_STAFF"] = 0x00004000;
		["VIEW_PLAYER_DATA"] = 0x00008000;
		
		["MODIFY_PLAYER_INSTANCE"] = 0x00010000;
		["BROADCAST_MESSAGES"] = 0x00020000;
		["DONATOR_PERKS"] = 0x00040000;
		["SHUTDOWN_GAME"] = 0x00060000;
		["LOCK_SERVER"] = 0x00080000;
		
		["PLAY_SOUND"] = 0x00100000;
		["MANAGE_SOUNDS"] = 0x00200000;   
	};
	ExistingRoles = {
		{
			Name = "Moderator";
			Cluster = 258684; -- To see what flags this allows, refer to Roles.UnpackFlags
		},
		{
			Name = "ExampleRole";
			Cluster = Roles.CalculateBit({
				Roles.PermissionFlags.GUEST;
				Roles.PermissionFlags.MUTE_PLAYERS;
			})
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