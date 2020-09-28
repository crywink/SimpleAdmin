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
			PermissionValue = 258684;
		}
	};
}

Roles.CalculateBit = function(PermissionList)
	return bit32.bor(unpack(PermissionList))
end

Roles.HasPermission = function(PermissionList, Permission)
	PermissionList = tonumber(PermissionList) or Roles.CalculateBit(PermissionList)
	
	return bit32.band(PermissionList, Permission) == Permission
end

Roles.UnpackFlags = function(PermissionList)
	local Unpacked = {}
	
	for k,v in pairs(Roles.PermissionFlags) do
		if Roles.HasPermission(PermissionList, v) then
			Unpacked[k] = v			
		end
	end
	
	return Unpacked
end