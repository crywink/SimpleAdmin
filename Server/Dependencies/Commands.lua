Service, Environment, Shared, Data, Config, Logs = nil, nil, nil, nil, nil, nil

--[[
	SimpleAdmin | Commands
--]]

-- Variables

-- Module
local Commands = {}

Commands.Commands = {
	{
		Name = "speed";
		Aliases = {"s"};
		Level = 0;
		Prefix = ":"; -- Optional; Defaults to config prefix
		Disabled = false; -- Optional
		Category = "Utility"; -- Optional; Default: Misc
		Args = {
			{
				Name = "Target";
				Type = "player";
			},
			{
				Name = "Speed";
				Type = "int";
				Default = 16; -- Optional; Integers default to 1
			}
		};
		Run = function(plr, args)
			args.Target.GetHumanoid().WalkSpeed = args.Speed
		end;
	},
	{
		Name = "kill";
		Aliases = {"death"};
		Level = 0;
		Args = {
			{
				Name = "Target";
				Type = "player";
			}
		};
		Run = function(plr, args)
			args.Target.GetHumanoid().Health = 0
		end
	},
	{
		Name = "Commands";
		Aliases = {"cmds"};
		Level = 0;
		Args = {};
		Category = "Core";
		Run = function(plr, args)
			local Categorized = Environment.Apply(Commands.Categorize)({}, true)
			
			for _,Category in pairs(Categorized) do
				for k,v in pairs(Category) do
					local Name = ""
					Name = Config.Prefix .. v.Name:lower()
					
					for _,Arg in pairs(v.Args or v.Arguments) do
						Name = Name .. " <" .. Arg.Name:lower() .. ">"
					end
					
					v.Name = Name
				end	
			end
			
			plr.Send("DisplayTable", "Commands", Categorized)
		end
	},
	{
		Name = "Kick";
		Aliases = {"yeet"};
		Level = 1;
		Args = {
			{
				Name = "Target";
				Type = "player";
			},
			{
				Name = "Reason";
				Type = "string";
				Default = "You have been kicked by an administrator.";
			}
		};
		Category = "Moderation";
		Run = function(plr, args)
			args.Target:Kick("\n\nSimpleAdmin | " .. args.Reason)
		end
	},
	{
		Name = "Changelog";
		Aliases = {"updates","changelogs"};
		Level = 0;
		Args = {};
		Category = "Core";
		Run = function(plr, args)
			plr.Send("DisplayTable", "Changelog", {
				{
					"Update 1.0.2 Alpha";
					"[#] Fixed a lot of bugs";
					"[+] Added ban/unban/bans";
					"[+] Added :logs";
					"[+] Added :troll";
					"[+] Added Text class to UI kit";
				},
				{
					"Update 1.0.1 Alpha";
					"[+] Created log library";
					"[+] Last argument can be a long string";
				},
				{
					"Update 1.0.0 Alpha";
					"[+] Added changelog command";
					"[+] Implemented data library";
					"[#] Levels now actually save";
					"[+] you smell bad"
				}
			})
		end
	},
	{
		Name = "admins";
		Aliases = {"adminlist", "staff"};
		Level = 1;
		Args = {};
		Category = "Core";
		Run = function(plr, args)
			local Staff = {}
			for k,v in pairs(Service.Permissions) do
				if v > 0 then
					local PlayerInfo = Service.ResolveToUserId(k)
					local UserID = PlayerInfo.UserId
					local Username = PlayerInfo.Username
					
					Staff[Username .. " (" .. UserID .. ")"] = {
						"Admin Level: " .. Service.GetLevelTitle(v);
						"In-game: " .. (Service.Players:FindFirstChild(Username) and "Yes" or "No");
					}
				end
			end
			
			plr.Send("DisplayTable", "Staff", Staff)
		end
	},
	{
		Name = "mod";
		Aliases = {"givemod"};
		Level = 2;
		Category = "Core";
		Args = {
			{
				Name = "Target";
				Type = "player";
			}
		};
		Category = "Core";
		Run = function(plr, args)
			if args.Target.GetLevel() >= plr.GetLevel() then
				return
			end
			
			Service.SetPermissionLevel(args.Target, 1, true)
		end
	},
	{
		Name = "admin";
		Aliases = {"giveadmin"};
		Level = 3;
		Category = "Core";
		Args = {
			{
				Name = "Target";
				Type = "player";
			}
		};
		Category = "Core";
		Run = function(plr, args)
			if args.Target.GetLevel() >= plr.GetLevel() then
				return
			end
			
			Service.SetPermissionLevel(args.Target, 2, true)
		end
	},
	{
		Name = "owner";
		Aliases = {"giveowner"};
		Level = 4;
		Category = "Core";
		Args = {
			{
				Name = "Target";
				Type = "player";
			}
		};
		Category = "Core";
		Run = function(plr, args)
			if args.Target.GetLevel() >= plr.GetLevel() then
				return
			end
			
			Service.SetPermissionLevel(args.Target, 3, true)
		end
	},
	{
		Name = "troll";
		Aliases = {};
		Level = 2;
		Category = "Fun";
		Args = {
			{
				Name = "Target";
				Type = "player";
			}
		};
		Category = "Fun";
		Run = function(plr, args)
			plr.Send("DisplayTrollPanel", args.Target._Object)
		end
	},
	{
		Name = "unmod";
		Aliases = {"unadmin", "unowner", "removeadmin"};
		Level = 2;
		Category = "Core";
		Args = {
			{
				Name = "Target";
				Type = "player";
			}
		};
		Category = "Core";
		Run = function(plr, args)
			if args.Target.GetLevel() >= plr.GetLevel() then
				return
			end
			
			Service.SetPermissionLevel(args.Target._Object, 0, true)
		end
	},
	{
		Name = "rejoin";
		Aliases = {};
		Level = 0;
		Args = {};
		Run = function(plr, args)
			Service.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr._Object, nil, "_SimpleAdmin_Rejoin")
		end
	},
	{
		Name = "ban";
		Aliases = {};
		Level = 1;
		Category = "Moderation";
		Args = {
			{
				Name = "Target";
				Type = "player";
			},
			{
				Name = "Reason";
				Type = "string";
			}
		};
		Run = function(plr, args)
			args.Target.Ban(plr.UserId, args.Reason)
		end
	},
	{
		Name = "unban";
		Aliases = {};
		Level = 1;
		Category = "Moderation";
		Args = {
			{
				Name = "Target";
				Type = "string";
			}
		};
		Run = function(plr, args)
			local UserInfo = Service.ResolveToUserId(args.Target)
			local BanData = Data:GetGlobal("Bans")
			
			if BanData[tostring(UserInfo.UserId)] then
				BanData[tostring(UserInfo.UserId)] = nil
			end
			
			Data:SetGlobal("Bans", BanData)
		end
	},
	{
		Name = "bans";
		Aliases = {"banlist", "getbans"};
		Level = 1;
		Args = {};
		Category = "Moderation";
		Run = function(plr, args)
			local BanList = {}
			
			for UserId, BanInfo in pairs(Data:GetGlobal("Bans")) do
				local UserData = Service.ResolveToUserId(tonumber(UserId))
				local ModData = Service.ResolveToUserId(tonumber(BanInfo.Moderator))
				
				BanList[UserData.Username .. " (" .. UserData.UserId .. ")"] = {
					"Moderator: " .. ModData.Username .. " (" .. ModData.UserId .. ")";
					"Reason: " .. BanInfo.Reason;
				}
			end
			
			for _, UserId in ipairs(Config.Bans) do
				if not BanList["Script Banned"] then
					BanList["Script Banned"] = {};
				end
				local UserData = Service.ResolveToUserId(UserId)
				
				if UserData then
					table.insert(BanList["Script Banned"], UserData.Username .. " [" .. UserData.UserId .. "]")
				else
					table.insert(BanList["Script Banned"], UserId)
				end
			end
			
			plr.Send("DisplayTable", "Bans", BanList)
 		end
	},
	{
		Name = "logs";
		Aliases = {"modlogs"};
		Level = 1;
		Category = "Core";
		Args = {};
		Run = function(plr, args)
			local LogTable = {}
			for k,v in pairs(Logs.Get("Main")) do
				table.insert(LogTable, v.Player .. " - " .. v.Command)
			end
			
			plr.Send("DisplayTable", "Logs", LogTable)
		end
	}
}

Commands.Get = function(query)
	query = string.lower(query)
	
	for _,Command in pairs(Commands.Commands) do
		if string.lower(Command.Name) == query then
			return Command
		else
			for _,v in pairs(Command.Aliases) do
				if string.lower(v) == query then
					return Command
				end
			end
		end
	end
	
	return nil
end

Commands.Categorize = function(Exclude, HideDisabled)
	local NewCommands = {}
	for _,Command in pairs(Service.CopyTable(Commands.Commands)) do
		if not Command.Disabled then
			local Category = Command.Category or "Misc"
			Command.Run = nil
			Command.RunOnce = nil
			if not NewCommands[Category] then
				NewCommands[Category] = {}
			end
			
			NewCommands[Category][Command.Name] = Command
		end
	end
	return NewCommands
end

Commands.Create = function(Data)
	table.insert(Commands.Commands, Data)
end

return Commands