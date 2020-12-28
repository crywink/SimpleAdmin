Service, Environment, Shared, Data, Config, Logs, Server, Misc = nil, nil, nil, nil, nil, nil, nil, nil

--[[
	SimpleAdmin | Commands
--]]

-- Variables

-- Module
return function()
	local Commands = {}
	local Levels = Service.AdminLevels
	
	Commands.Commands = {
		{
			Name = "speed";
			Aliases = {"s"};
			Level = Levels.Moderators;
			Flags = {"MANAGE_CHARACTERS"};
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
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
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
			Flags = {"VIEW_COMMANDS"};
			Level = 0;
			Args = {};
			Category = "Core";
			Run = function(plr, args)
				local Categorized = Environment.Apply(Commands.Categorize)({}, true, plr.GetLevel())
				
				for _,Category in pairs(Categorized) do
					for k,v in pairs(Category) do
						local Name = ""
						Name = (v.Prefix or Config.Prefix) .. v.Name:lower()
						
						for _,Arg in pairs(v.Args or v.Arguments or {}) do
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
			Flags = {"KICK_PLAYERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
					DisableSelf = true;
					HierarchyLimited = true;
				},
				{
					Name = "Reason";
					Type = "string";
					Default = "You have been kicked by an administrator.";
				}
			};
			Category = "Moderation";
			Run = function(plr, args)
				if args.Target.GetLevel() >= plr.GetLevel() then
					return
				end
				
				args.Target:Kick("\n\nSimpleAdmin | " .. args.Reason)
			end
		},	
		{
			Name = "Changelog";
			Aliases = {"updates","changelogs"};
			Flags = {"GUEST"};
			Level = 0;
			Args = {};
			Category = "Core";
			Run = function(plr, args)
				plr.Send("DisplayTable", "Changelog", {
					{
						"Update 1.7.0";
						"! Fixed ping not showing accurately";
						"! :Ban now server bans - to ban permanently, use :pban.";
						"! Limited logs to 500 queries - additional queries will be sliced.";
						"! Added default radius (15) to :crowd";
						"+ Search button is now functional";
						"+ Added UI resizing";
						"+ Added :groupban / :ungroupban / :groupbans";
						"+ Added :pban";
						"- Removed pascal converter";
					},
					{
						"Update 1.6.0 Alpha";
						"+ Added 'PlayerData' command";
						"+ Added 'AddStat' command (adds a leaderstat)";
						"+ Added 'UnCrowd' command (pushes people away from you)";
						"+ Added 'RemoveHats' command";
						"+ Added 'PlayerChatLogs' command (shows chatlogs for certain player) ('playerchatlogs', 'pclogs', 'pchatlogs')";
						"+ Added 'PlayerLogs' command (shows admin logs for certain player) ('playerlogs', 'plogs')";
						"+ Added 'HandTo' command (hands whatever tool you're holding to target)";
						"+ Added PlayerWrapper.Created";
						"+ Added SetText method to Text UI class";
						"- Removed AntiNameSpoofing (Roblox patched it themselves)";
						"! Fixed some processor issues";
						"! Fixed ServerLock";
					},
					{
						"Update 1.5.7 Alpha";
						"! Fixed :shutdown";
					},
					{
						"Update 1.5.6 Alpha";
						"! Fixed the weird issue with like 90% of the commands just not working at all... I have no clue what was wrong, but for some reason ipairs was just not going through every indice. (possibly a luau issue)";
					},
					{
						"Update 1.5.5 Alpha";
						"+ Added ':handto <target>' - Hands whatever tool you're holding to <target>.";
					},
					{
						"Update 1.5.4 Alpha";
						"! Welcome message now tells you what rank you are";
						"! Welcome message now shows the game's prefix and how to view a command list";
						"! You can no longer kick players with higher permission level than you.";
						"! You can no longer use :troll on players with higher permission level than you.";
						"! Fixed ':refresh' not working on other players.";
						
						"+ Added 'HierarchyLimited' property to player argument - this prevents you from executing said command on somebody with a higher permission level.";
						
						"+ Added plr.Ping [players approximate ping]";
						"+ Added plr.PingSent [when the request to get ping was sent]";
						"+ Added flag Config.PingRefreshRate (optional - defaults to 5) (how often SA makes a request to get ping)";
						
						"+ Added plr.IsWindowFocused (returns whether or not player has the roblox client focused on their computer)";
					},
					{
						"Update 1.5.2-3 Alpha";
						"! Fixed banning";
					},
					{
						"Update 1.5.1 Alpha";
						"! You can now ban offline players by their username or user id";
						"+ Added void Service.BanUser(UserId, Reason, Moderator)";
					},
					{
						"Update 1.5.0 Alpha";
						"! Fixed ':commandinfo' not working on commands with no preset category";
						"! Fixed randomly flying when testing";
						"! Warnings are now filtered";
						"+ Added queued music system";
						"+ PlaySound (:play)";
						"+ StopSound (:stop)";
						"+ SkipSound (:skip)";
						"+ PauseSound (:pause)";
						"+ ResumeSound (:resume)";
						"+ SetPitch (:setpitch <pitch>)";
					},
					{
						"Update 1.4.4 Alpha";
						"+ Added anti name spoofing";
						"+ Added flag Config.DisableAntiNameSpoofing";
					},
					{
						"Update 1.4.3 Alpha";
						"+ Fixed bans not actually banning with pro (data was saving, just wasnt being checked when player joined)";
						"+ Added Config.BroadcastPrefix for pro (allows you to replace '[SYSTEM MESSAGE]' with something custom)";
					},
					{
						"Update 1.4.1 Alpha";
						"! Hopefully fixed a possible bug with plr.Data related to the recent wrapper update";
					},
					{
						"Update 1.4.0 Alpha";
						"+ Added command separators - Example: ':respawn me | :give me all'";
						"+ Added %[team] macro - Example: ':kill %enemy'";
						"+ Added 'random' macro - Example: 'kill random'";
						"+ Added -[radius] macro - Example: 'kill -15' (Kills players within -(x) studs of you)";
						"+ Added ':jlogs' alias to ':joinlogs'";
						"+ Added feedback to unban/ban";
						"! Warning somebody will now show a window on the target's screen with who warned them and why they were warned.";
						"! Settings.DisableFunCommands will now remove the command from the command table rather than blocking it in the processor.";
						"! Reworked a lot of the command processor so it now easily supports adding/removing player macros";
						"! [developers] We no longer use string.match internally for matching team and player names, refer to Service.StartsWith().";
						"! [developers] Service.PlayerWrapper will now return a cached value - you can now compare it and share values with it. (its also a LOT more efficient)";
					},
					{
						"Update 1.3.3 Alpha";
						"! Fixed some weird issues with :bans";
					},
					{
						"Update 1.3.2 Alpha";
						"! Dummy-proofed the :ban command";
						"! Settings.DisableFunCommands now actually works";
					},
					{
						"Update 1.3.1 Alpha";
						"! :getinfo no longer errors if you pass it something that isn't a command";
						"! Fixed the permissions thinger with donators not getting their mod rank";	
					},
					{
						"Update 1.3.0 Alpha";
						"+ Added :setwaypoint / :setwp <name> (Sets a waypoint at your position)";
						"+ Added :tpwaypoint / :twp <player> <waypoint> (Teleports the specified player(s) to the waypoint)";
						"+ Added :removewaypoint / :delwp <name> (Deletes the specified waypoint)";
						"+ Added :waypoints (Shows a list of waypoints)";
						"+ Added :getinfo <command> (Shows info about a command such as arguments, aliases, level, etc...)";
						"+ Added :viewtools <player> (shows what tools the specified player has)";
						"+ Added :heal <player> (Heals the target player)";
						"+ Refresh command (resets the character and restores their position and tools)";
						"+ Added :slock <reason> (Locks the server so people that aren't mods cannot join)";
						"+ Added :unslock (Unlocks the server)";
						"+ Added :joinlogs (Shows a log of the players that have joined and how long ago they joined)";
						"! Top-bar messages now stack on each other instead of overlapping, this allows for multiple messages to be displayed together.";
						"! Added feedback to a lot of the commands";
						"! UI Containers now have nice effects and will automatically sort themselves";
						"! Command levels now index Service.AdminLevels";
						"! A bunch of bug fixes and internal stuff I probably cannot remember :(";					
					},
					{
						"Update 1.2.2 Alpha";
						"! Speed command prefix will now update if you change your global prefix";
					},
					{
						"Update 1.2.1 Alpha";
						"! Command parser will no longer throw an output if the player is invalid.";
					},
					{
						"Update 1.2.0 Alpha";
						"+ Shutdown Command";
						"! Owners will now have admin permissions in studio even if the game isn't published.";
						"+ Added `!panel` that will show SimpleAdmin info along with the donate page";
						"+ Added :ghost / :unghost [DONATORS+ ONLY]";
						"+ Added :cape [DONATORS+ ONLY]";
						"+ Commands list will now only show commands you have access to.";
						"+ Added 'DisableShortcuts' property to commands. This disables player shortcuts like 'all' and 'others'. It's enabled by default on commands like 'ban'.";
						"[Warning System]";
						"+ :warn <target> <reason>";
						"+ :warnings <target>";
						"+ :clearwarns <target>";
						"+ :delwarn <target> <warning id>";
					},
					{
						"Update 1.1.0 Alpha";
						"[+] Give Command";
						"[+] Tools Command (you can also click the buttons to give yourself the tools)";
						"[#] Auto-scaling containers for text and dropdowns [@kinkocat]";
						"[+] View / Spy";
						"[+] Mute / Unmute";
						"[#] Aliases and args command properties are now optional";
						"[+] SetStat (Allows you to change leaderstat values)";
						"[#] A bunch of optimizations";
						"[#] Popped permission levels up a level. Moderator is now permission level 2. (1 is donator)";
						"[#] Fixed BindCustomConnection";
						"[#] Updated all of the official packages to support new permissions";
					},
					{
						"Update 1.0.5 Alpha";
						"[#] Some internal changes";
						"[+] Added :team";
						"[+] Added :re / :respawn";
						"[+] Added :jumppower / :jp";
						"[+] Added :forcefield / :ff";
						"[+] Added :unforcefield / :unff";
						"[+] Added :chatlogs / :clogs";
						"[+] Bananas, Apples, Pe- wait..";
					},
					{
						"Update 1.0.4 Alpha";
						"[+] Added :countdown";
						"[+] Added :to / :goto";
						"[+] Added :bring";
						"[+] Added :tp";
						"[+] Added :message"
					},
					{
						"Update 1.0.3 Alpha";
						"[#] You can no longer ban yourself";
						"[+] Added :noclip";
						"[+] Added :fly";
						"[+] Added /e support";
					},
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
			Flags = {"VIEW_STAFF"};
			Level = Levels.Moderators;
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
			Flags = {"MANAGE_ROLES"};
			Level = Levels.Admins;
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
				
				args.Target.Send("Message", "You're a moderator!", 5)
				plr.Send("Message", "You made " .. args.Target.Name .. " a moderator.", 5)
				Service.SetPermissionLevel(args.Target, 2, true)
			end
		},
		{
			Name = "tempmod";
			Aliases = {"tmod"};
			Flags = {"MANAGE_ROLES"};
			Level = Levels.Admins;
			Category = "Core";
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				if args.Target.GetLevel() >= plr.GetLevel() then
					return
				end
				
				args.Target.Send("Message", "You're a temporary moderator!", 5)
				plr.Send("Message", "You made " .. args.Target.Name .. " a temporary moderator.", 5)
				Service.SetPermissionLevel(args.Target, 2, false)
			end
		},
		{
			Name = "admin";
			Aliases = {"giveadmin"};
			Flags = {"MANAGE_ROLES"};
			Level = Levels.Owners;
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
				
				args.Target.Send("Message", "You're an admin!", 5)
				plr.Send("Message", "You made " .. args.Target.Name .. " an admin.", 5)
				Service.SetPermissionLevel(args.Target, 3, true)
			end
		},
		{
			Name = "owner";
			Aliases = {"giveowner"};
			Flags = {"MANAGE_ROLES"};
			Level = Levels.Developers;
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
				
				args.Target.Send("Message", "You're an owner!", 5)
				plr.Send("Message", "You made " .. args.Target.Name .. " an owner.", 5)
				Service.SetPermissionLevel(args.Target, 4, true)
			end
		},
		{
			Name = "troll";
			Aliases = {};
			Flags = {"MANAGE_GAME"};
			Level = Levels.Admins;
			Category = "Fun";
			Args = {
				{
					Name = "Target";
					Type = "player";
					HierarchyLimited = true;
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
			Flags = {"MANAGE_ROLES"};
			Level = Levels.Admins;
			Category = "Core";
			Args = {
				{
					Name = "Target";
					Type = "string";
				}
			};
			Category = "Core";
			Run = function(plr, args)
				local Target = Server.ResolveToPlayers(plr, args.Target, true, false)								

				if Target then
					for _,v in pairs(Target) do
						if v.GetLevel() >= plr.GetLevel() then
							return plr.Send("Message", "This user has the same or higher permission level.", 3)
						end

						Service.SetPermissionLevel(v.UserId, 0, true)

						plr.Send("Message", "You removed " .. v.Name .. "'s admin permissions.", 3)
						v.Send("Message", "Your permissions have been revoked!", 5)
					end
				else
					local PlayerInfo = Service.ResolveToUserId(args.Target)
					local PermissionLevel = Service.GetGlobalPermissionLevel(PlayerInfo.UserId)
					
					if PermissionLevel and PermissionLevel >= plr.GetLevel() then
						return plr.Send("Message", "This user has the same or higher permission level.", 3)
					end
					
					Service.SetPermissionLevel(PlayerInfo.UserId, 0, true)
					plr.Send("Message", "You removed " .. PlayerInfo.Username .. "'s admin permissions.", 3)
				end	
			end
		},
		{
			Name = "rejoin";
			Aliases = {};
			Flags = {"GUEST"};
			Level = 0;
			Args = {};
			Run = function(plr, args)
				Service.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr._Object, nil, "_SimpleAdmin_Rejoin")
			end
		},
		{
			Name = "permban";
			Aliases = {"pban","gameban","databan"};
			Flags = {"BAN_PLAYERS"};
			Level = Levels.Moderators;
			Category = "Moderation";
			Args = {
				{
					Name = "Target";
					Type = "string";
				},
				{
					Name = "Reason";
					Type = "string";
					Reason = "No reason provided"
				}
			};
			Run = function(plr, args)
				local Target = Server.ResolveToPlayers(plr, args.Target, true, false)								
				
				if Target then
					for _,v in pairs(Target) do
						if v.GetLevel() >= plr.GetLevel() then
							return plr.Send("Message", "This user has the same or higher permission level.", 3)
						end
						
						v.Ban(plr.UserId, args.Reason)
						plr.Send("Message", "Banned " .. v.Name, 3)
					end
				else
					local PlayerInfo = Service.ResolveToUserId(args.Target)
					local PermissionLevel = Service.GetGlobalPermissionLevel(PlayerInfo.UserId)
					
					if PermissionLevel and PermissionLevel >= plr.GetLevel() then
						return plr.Send("Message", "This user has the same or higher permission level.", 3)
					end
					
					Service.BanUser(PlayerInfo.UserId, args.Reason, plr.UserId)
					plr.Send("Message", "Banned " .. PlayerInfo.Username, 3)
				end
			end
		},
		{
			Name = "ban";
			Aliases = {"serverban"};
			Flags = {"BAN_PLAYERS"};
			Level = Levels.Moderators;
			Category = "Moderation";
			Args = {
				{
					Name = "Target";
					Type = "player";
					DisableSelf = true;
					DisableShortcuts = true;
				},
				{
					Name = "Reason";
					Type = "string";
					Default = "No reason provided";
				}
			};
			Run = function(plr, args)
				table.insert(Config.Bans, args.Target.UserId);

				args.Target:Kick("\n| SimpleAdmin |\nYou have been banned!\nReason: " .. args.Reason)
				plr.Send("Message", "You have server-banned " .. args.Target.Name .. "!")
			end
		},
		{
			Name = "unban";
			Aliases = {};
			Flags = {"BAN_PLAYERS"};
			Level = Levels.Moderators;
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
					plr.Send("Message", "You have unbanned " .. UserInfo.Username .. " (" .. UserInfo.UserId .. ")", 3)
					BanData[tostring(UserInfo.UserId)] = nil

					Data:SetGlobal("Bans", BanData)
				else
					local UserIdQuery = table.find(Config.Bans, UserInfo.UserId);
					local UsernameQuery = table.find(Config.Bans, UserInfo.Username);

					if UserIdQuery then
						table.remove(Config.Bans, UserIdQuery)
					end

					if UsernameQuery then
						table.remove(Config.Bans, UsernameQuery)
					end

					plr.Send("Message", "You have unbanned " .. UserInfo.Username .. " (" .. UserInfo.UserId .. ")", 3)
				end
			end
		},
		{
			Name = "bans";
			Aliases = {"banlist", "getbans"};
			Flags = {"BAN_PLAYERS", "VIEW_BANS"};
			Level = Levels.Moderators;
			Args = {};
			Category = "Moderation";
			Run = function(plr, args)
				local BanList = {}
				
				for UserId, BanInfo in pairs(Data:GetGlobal("Bans")) do
					local UserData = Service.ResolveToUserId(tonumber(UserId))
					local ModData = Service.ResolveToUserId(tonumber(BanInfo.Moderator))
					
					BanList[UserData.Username .. " (" .. UserData.UserId .. ")"] = {
						"Moderator: " .. ModData.Username .. " (" .. ModData.UserId .. ")";
						"Reason: " .. (BanInfo.Reason or "No reason provided");
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
			Flags = {"VIEW_LOGS"};
			Level = Levels.Moderators;
			Category = "Core";
			Args = {};
			Run = function(plr, args)
				local LogTable = {}
				for k,v in ipairs(Logs.Get("Main")) do
					table.insert(LogTable, v.Player .. " - " .. v.Command)
				end
				
				plr.Send("DisplayTable", "Logs", LogTable)
			end
		},
		{
			Name = "chatlogs";
			Aliases = {"clogs"};
			Flags = {"VIEW_LOGS"};
			Level = Levels.Moderators;
			Category = "Core";
			Args = {};
			Run = function(plr, args)
				local LogTable = {}
				for k,v in ipairs(Logs.Get("Chat") or {}) do
					if v.Player and v.Message then
						table.insert(LogTable, v.Player .. " - " .. v.Message)
					end
				end
				
				plr.Send("DisplayTable", "Chat Logs", LogTable)
			end
		},
		{
			Name = "noclip";
			Aliases = {};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}	
			};
			Run = function(plr, args)
				args.Target.Send("Noclip", true)
			end
		},
		{
			Name = "clip";
			Aliases = {"unnoclip"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}	
			};
			Run = function(plr, args)
				args.Target.Send("Noclip", false)
			end
		},
		{
			Name = "fly";
			Aliases = {};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				args.Target.Send("Fly", true)
			end
		},
		{
			Name = "unfly";
			Aliases = {};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				args.Target.Send("Fly", false)
			end
		},
		{
			Name = "message";
			Aliases = {"msg", "m"};
			Flags = {"BROADCAST_MESSAGES"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Text";
					Type = "string";
				}
			},
			Run = function(plr, args)
				local TextObject
				
				do
					local Success, Return = pcall(function()
						TextObject = Service.TextService:FilterStringAsync(args.Text, plr.UserId, Enum.TextFilterContext.PublicChat)
					end)
					
					if not Success then
						return
					end
				end
				
				for _,v in ipairs(Service.GetPlayers({}, true)) do
					local Text
					local Success, Return = pcall(function()
						Text = TextObject:GetChatForUserAsync(v.UserId)
					end)
					
					if Success then
						v.Send("Message", Text, math.max(5, (#Text/5)-2))
					end
				end
			end
		},
		{
			Name = "countdown";
			Aliases = {"timer", "cd"};
			Flags = {"BROADCAST_MESSAGES"};
			Level = Levels.Moderators;
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Time";
					Type = "int";
					Default = 30;
				}
			};
			Run = function(plr, args)
				args.Target.Send("Countdown", args.Time)
			end
		},
		{
			Name = "bring";
			Aliases = {};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				if not plr.Character or not args.Target.Character then
					return
				end
				
				local EndCF = plr.Character:GetPrimaryPartCFrame()
				EndCF = EndCF + (EndCF.LookVector * 2)
				
				args.Target.Character:SetPrimaryPartCFrame(EndCF)
			end
		},
		{
			Name = "to";
			Aliases = {"goto"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				if not plr.Character or not args.Target.Character then
					return
				end
				
				local EndCF = args.Target.Character:GetPrimaryPartCFrame()
				EndCF = EndCF + (EndCF.LookVector * 2)
				
				plr.Character:SetPrimaryPartCFrame(EndCF)
			end
		},
		{
			Name = "tp";
			Aliases = {"teleport"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Category = "Utility";
			Args = {
				{
					Name = "TargetA";
					Type = "player";
				},
				{
					Name = "TargetB";
					Type = "player";
				}
			};
			Run = function(plr, args)
				if not args.TargetA.Character or not args.TargetB.Character then
					return
				end
				
				local EndCF = args.TargetB.Character:GetPrimaryPartCFrame()
				EndCF = EndCF + (EndCF.LookVector * 2)
				
				args.TargetA.Character:SetPrimaryPartCFrame(EndCF)
			end
		},
		{
			Name = "team";
			Aliases = {"setteam"};
			Flags = {"CHANGE_TEAMS"};
			Level = Levels.Moderators;
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Team";
					Type = "string";
				}
			};
			Run = function(plr, args)
				local Team = Service.FindTeam(args.Team)
				args.Target.TeamColor = Team.TeamColor
			end
		},
		{
			Name = "respawn";
			Aliases = {"re"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				args.Target:LoadCharacter()
			end
		},
		{
			Name = "jumppower";
			Aliases = {"jp"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Power";
					Type = "int";
					Default = 50;
				}
			};
			Run = function(plr, args)
				args.Target.GetHumanoid().JumpPower = args.Power
			end;
		},
		{
			Name = "forcefield";
			Aliases = {"ff"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				local targ = args.Target
				if targ.Character and targ.Character:FindFirstChild("HumanoidRootPart") then
					Service.New("ForceField", {
						Name = "SimpleAdmin_ForceField";
					}).Parent = targ.Character
				end
			end
		},
		{
			Name = "unforcefield";
			Aliases = {"unff"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			},
			Run = function(plr, args)
				local targ = args.Target
				if targ.Character then
					for _,v in ipairs(targ.Character:GetDescendants()) do
						if v:IsA("ForceField") then
							v:Destroy()
						end
					end
				end
			end
		},
		{
			Name = "setstat";
			Aliases = {"setleaderstat"};
			Flags = {"MODIFY_PLAYER_INSTANCE"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Leaderstat";
					Type = "string";
				},
				{
					Name = "Value";
					Type = "string";
				}
			};
			Run = function(plr, args)
				local leaderstats = args.Target:FindFirstChild("leaderstats")
				if leaderstats then
					for _,v in ipairs(leaderstats:GetChildren()) do
						if string.match(string.lower(v.Name), string.lower(args.Leaderstat)) then
							v.Value = args.Value
							return
						end
					end
				end
			end
		},
		{
			Name = "spy";
			Aliases = {"view", "watch"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				plr.Send("SetCameraSubject", args.Target.Character.Humanoid)
				plr.Send("Message", "You are spectating " .. args.Target.Name .. ".", 4)
			end
		},
		{
			Name = "unspy";
			Aliases = {"unwatch", "unview"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Args = {};
			Run = function(plr, args)
				plr.Send("SetCameraSubject", plr.Character.Humanoid)
			end
		},
		{
			Name = "mute";
			Aliases = {"shutup"};
			Flags = {"MUTE_PLAYERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
					DisableSelf = true;
				}
			};
			Run = function(plr, args)
				args.Target.Send("SetCoreGuiEnabled", Enum.CoreGuiType.Chat, false)
				args.Target.Send("Message", "You have been muted by " .. plr.Name .. ".")
				plr.Send("Message", "You have muted " .. args.Target.Name .. ".")
			end
		},
		{
			Name = "unmute";
			Aliases = {"unshutup"};
			Flags = {"MUTE_PLAYERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				args.Target.Send("SetCoreGuiEnabled", Enum.CoreGuiType.Chat, true)
				args.Target.Send("Message", "You have been unmuted.")
				plr.Send("Message", "You have unmuted " .. args.Target.Name .. ".")
			end
		},
		{
			Name = "Tools";
			Aliases = {};
			Flags = {"MANAGE_BACKPACK"};
			Level = Levels.Moderators;
			Args = {};
			Run = function(plr, args)
				if not Server.Tools then
					Server.Tools = {}
					
					for k,v in ipairs((Config.ToolsDirectory or Service.ServerStorage):GetChildren()) do
						if v:IsA("Tool") then
							table.insert(Server.Tools, v)
						end
					end
				end
				
				local Tools = {}
				for _,v in ipairs(Server.Tools) do
					table.insert(Tools, v.Name)
				end
				
				plr.Send("ShowTools", Tools)
			end
		},
		{
			Name = "Give";
			Aliases = {};
			Flags = {"MANAGE_BACKPACK"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Tool";
					Type = "string";
				}
			};
			Run = function(plr, args)
				if not Server.Tools then
					Server.Tools = {}
					
					for k,v in ipairs((Config.ToolsDirectory or Service.ServerStorage):GetChildren()) do
						if v:IsA("Tool") then
							table.insert(Server.Tools, v)
						end
					end
				end
				
				for _,v in ipairs(Server.Tools) do
					if args.Tool == "all" or string.match(v.Name:lower(), args.Tool:lower()) then
						v:Clone().Parent = args.Target.Backpack
					end
				end
			end
		},
		{
			Name = "Ghost";
			Level = Levels.Donators;
			Flags = {"MANAGE_CHARACTERS", "DONATOR_PERKS"};
			Aliases = {"makemeaghost"};
			Category = "Donators";
			Args = {
				{
					Name = "Target";
					Type = "player";
				}	
			};
			Run = function(plr, args)
				if plr.GetLevel() == Service.AdminLevels.Donators then
					Misc.Character.Ghostify(plr)
				else
					Misc.Character.Ghostify(args.Target)
				end
			end
		},
		{
			Name = "Unghost";
			Level = Levels.Donators;
			Flags = {"MANAGE_CHARACTERS", "DONATOR_PERKS"};
			Aliases = {"makemenotaghost"};
			Category = "Donators";
			Args = {
				{
					Name = "Target";
					Type = "player";
				}	
			};
			Run = function(plr, args)
				if plr.GetLevel() == Service.AdminLevels.Donators then
					Misc.Character.Unghostify(plr)
				else
					Misc.Character.Unghostify(args.Target)
				end
			end
		},
		{
			Name = "Cape";
			Level = Levels.Donators;
			Flags = {"MANAGE_CHARACTERS", "DONATOR_PERKS"};
			Aliases = {};
			Args = {};
			Category = "Donators";
			Run = function(plr, args)
				plr.Send("ShowCapeSettings")
			end
		},
		{
			Name = "Panel";
			Level = 0;
			Flags = {"GUEST"};
			Aliases = {};
			Prefix = "!";
			Args = {};
			Run = function(plr, args)
				plr.Send("ShowPanel")
			end
		},
		{
			Name = "Warn";
			Level = Levels.Moderators;
			Flags = {"WARN_PLAYERS"};
			Aliases = {};
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Reason";
					Type = "string";
					Default = "No reason provided";
				}
			};
			Category = "Moderation";
			Run = function(plr, args)
				local Warns = args.Target.Data.Warns or {}
				local WarningCount = (args.Target.Data.WarningCount or 0) + 1
				
				args.Reason = Service.FilterText(args.Reason, plr.UserId, args.Target.UserId)
				
				local Warning = {
					Reason = args.Reason;
					Moderator = plr.Name;
					Id = WarningCount
				}
				table.insert(Warns, Warning)
				
				plr.Send("Message", "Warned " .. args.Target.Name, 3)
				args.Target.Send("Message", "You have been warned!", 5)
				args.Target.Send("DisplayTable", "You've been warned!", {
					"Reason: " .. args.Reason;
					"Moderator: " .. plr.Name;
				})
				
				args.Target.Data.WarningCount = WarningCount
				args.Target.Data.Warns = Warns
			end
		},
		{
			Name = "Warnings";
			Level = Levels.Moderators;
			Flags = {"WARN_PLAYERS"};
			Aliases = {"warns", "viewwarns"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Category = "Moderation";
			Run = function(plr, args)
				if #(args.Target.Data.Warns or {}) == 0 then
					plr.Send("Message", "Player has no warnings!", 3)
					return
				end
				
				local Warns = {}
				
				for _,v in ipairs(args.Target.Data.Warns or {}) do
					table.insert(Warns, {
						"Warning " ..  v.Id;
						"Reason: " .. (v.Reason or "No reason provided");
						"Moderator: " .. v.Moderator;
						"Warning Id: " .. v.Id;
					})
				end
				
				plr.Send("DisplayTable", "Warns (" .. args.Target.Name ..")", Warns)
			end
		},
		{
			Name = "ClearWarns";
			Level = Levels.Moderators;
			Flags = {"WARN_PLAYERS"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				args.Target.Data.Warns = {}
				plr.Send("Message", "Cleared warnings!", 3)
			end
		},
		{
			Name = "RemoveWarning";
			Aliases = {"delwarn", "removewarn"};
			Flags = {"WARN_PLAYERS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "WarningId";
					Type = "int";
				}
			};
			Category = "Moderation";
			Run = function(plr, args)
				local Warns = args.Target.Data.Warns or {}
				for i,v in ipairs(Warns) do
					if v.Id == args.WarningId then
						table.remove(Warns, i)
						plr.Send("Message", "Removed Warning " .. v.Id, 3)
						return
					end
				end
				plr.Send("Message", "That warning does not exist", 3)
			end
		},
		{
			Name = "Shutdown";
			Level = Levels.Admins;
			Flags = {"MANAGE_GAME", "SHUTDOWN_GAME"};
			Args = {};
			Category = "Utility";
			Run = function(plr, args)
				Server.Shutdown(plr.Name)
			end
		},
		{
			Name = "setwaypoint";
			Level = Levels.Moderators;
			Flags = {"MANAGE_WAYPOINTS"};
			Aliases = {"setwp"};
			Args = {
				{
					Name = "Name";
					Type = "string";
					Default = function()
						return "Waypoint " .. tostring(Service.GetLength(Server.Waypoints or {}) + 1)
					end
				}
			};
			Run = function(plr, args)
				if not Server.Waypoints then
					Server.Waypoints = {}
				end
				local Character = plr.Character
				
				Server.Waypoints[args.Name] = Character:GetPrimaryPartCFrame()
				plr.Send("Message", "Successfully set waypoint!", 2)
			end
		},
		{
			Name = "Waypoint";
			Level = Levels.Moderators;
			Flags = {"MANAGE_WAYPOINTS"};
			Aliases = {"towaypoint", "twp"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Waypoint";
					Type = "string";
				}
			},
			Run = function(plr, args)
				if not Server.Waypoints then
					Server.Waypoints = {}
				end
				
				local Waypoint = Server.Waypoints[args.Waypoint]
				if args.Target.Character and Waypoint then
					args.Target.Character:SetPrimaryPartCFrame(Waypoint)
				end
			end
		},
		{
			Name = "RemoveWaypoint";
			Aliases = {"delwaypoint", "delwp"};
			Flags = {"MANAGE_WAYPOINTS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Waypoint";
					Type = "string";
				}
			};
			Run = function(plr, args)
				if not Server.Waypoints then
					Server.Waypoints = {}
				end
				
				local Waypoint = Server.Waypoints[args.Waypoint]
				if Waypoint then
					Server.Waypoints[args.Waypoint] = nil
					plr.Send("Message", "Removed waypoint!", 2)
				else
					plr.Send("Message", "Waypoint does not exist.", 2)
				end
			end
		},
		{
			Name = "Waypoints";
			Level = Levels.Moderators;
			Flags = {"MANAGE_WAYPOINTS"};
			Args = {};
			Run = function(plr, args)
				if not Server.Waypoints or Service.GetLength(Server.Waypoints) == 0 then
					plr.Send("Message", "No existing waypoints", 2.5)
					return
				end
				
				local ToSend = {}
				for k,_ in pairs(Server.Waypoints) do
					table.insert(ToSend, k)
				end
				
				plr.Send("DisplayTable", "Waypoints", ToSend)
			end
		},
		{
			Name = "Heal";
			Level = Levels.Moderators;
			Flags = {"MANAGE_CHARACTERS"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				local Humanoid = args.Target.Character and args.Target.GetHumanoid()
				
				if Humanoid then
					Humanoid.Health = Humanoid.MaxHealth
				end
			end
		},
		{
			Name = "ServerLock";
			Level = Levels.Moderators;
			Flags = {"LOCK_SERVER"};
			Aliases = {"slock"};
			Args = {
				{
					Name = "Reason";
					Type = "string";
					Default = "No reason provided.";
				}
			};
			Run = function(plr, args)
				Server.ServerLock = args.Reason
				for _,v in pairs(Service.GetPlayers({}, true)) do
					if v._Object ~= plr._Object then
						v.Send("Message", plr.Name .. " has locked the server!", 5)
					end
				end
				plr.Send("Message", "You have locked the server.", 5)
			end
		},
		{
			Name = "UnServerLock";
			Level = Levels.Moderators;
			Flags = {"LOCK_SERVER"};
			Aliases = {"unslock"};
			Args = {};
			Run = function(plr, args)
				Server.ServerLock = nil
				for _,v in pairs(Service.GetPlayers({}, true)) do
					if v._Object ~= plr._Object then
						v.Send("Message", plr.Name .. " has unlocked the server!", 5)
					end
				end
				plr.Send("Message", "You have unlocked the server.", 5)
			end
		},
		{
			Name = "ViewTools";
			Level = Levels.Moderators;
			Flags = {"MANAGE_BACKPACK"};
			Aliases = {"toollist", "viewbackpack"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				local Tools = {}
				for _,v in pairs(args.Target.Backpack:GetChildren()) do
					if v:IsA("Tool") then
						table.insert(Tools, v.Name)
					end
				end
				plr.Send("DisplayTable", "Tools (" .. args.Target.Name .. ")", Tools)
			end
		},
		{
			Name = "Refresh";
			Level = Levels.Moderators;
			Flags = {"MANAGE_CHARACTERS"};
			Aliases = {"ref"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				local Tools = args.Target.Backpack:GetChildren()
				local OrigCF = args.Target.Character:GetPrimaryPartCFrame()
				local HoldingTool = args.Target.Character:FindFirstChildOfClass("Tool")
				
				if HoldingTool then
					table.insert(Tools, 1, HoldingTool)
				end
				for _,v in pairs(Tools) do
					v.Parent = nil
				end
				
				args.Target:LoadCharacter()
				for _,v in ipairs(Tools) do
					v.Parent = args.Target.Backpack
				end
				
				args.Target.Character:SetPrimaryPartCFrame(OrigCF)
			end
		},
		{
			Name = "JoinLogs";
			Level = Levels.Moderators;
			Flags = {"VIEW_LOGS"};
			Category = "Utility";
			Args = {};
			Aliases = {"jlogs"};
			Run = function(plr, args)
				local JLogs = Logs.Get("JoinLogs")
				local ToSend = {}
				
				for _,v in ipairs(JLogs) do
					table.insert(ToSend, v.Name .. " | " .. math.floor(tick() - v.Time) .. " seconds ago")
				end
				
				plr.Send("DisplayTable", "Joinlogs", ToSend)
			end
		},
		{
			Name = "commandinfo";
			Level = 0;
			Flags = {"GUEST"};
			Category = "Core";
			Aliases = {"cmdinfo", "getinfo"};
			Args = {
				{
					Name = "Command";
					Type = "string";
				}
			};
			Run = function(plr, args)
				local Command = Commands.Get(args.Command)
				if Command then
					local Data = {
						"Name: " .. Command.Name;
						"Category: " .. (Command.Category or "Misc");
						"Level: " .. Service.GetLevelTitle(Command.Level or 0)
					}
					local Args = {}
					for _,v in pairs(Command.Args or Command.Arguments or {}) do
						table.insert(Args, v.Name .. " <" .. v.Type .. ">")
					end
					if #Args > 0 then
						table.insert(Data, {
							"Arguments";
							unpack(Args);
						})
					else
						table.insert(Data, "This command has no arguments")
					end
					if #(Command.Aliases or {}) > 0 then
						table.insert(Data, {
							"Aliases";
							unpack(Command.Aliases)
						})
					else
						table.insert(Data, "This command has no aliases")
					end
					plr.Send("DisplayTable", "Info for " .. Command.Name, Data)
				end
			end
		},
		{
			Name = "PlaySound";
			Level = Levels.Moderators;
			Flags = {"PLAY_SOUND"};
			Category = "Music";
			Aliases = {"ps", "play"};
			Args = {
				{
					Name = "SoundId";
					Type = "int";
					Default = "resume";
				}
			};
			Run = function(plr, args)
				if args.SoundId == "resume" and #Server.SoundQueue > 0 then
					Server.SoundObject:Resume()
					return plr.Send("Message", "Now playing '" .. Service.MarketplaceService:GetProductInfo(Server.SoundQueue[1]).Name .. "'")
				end
				
				if not Service.IsValidSoundId(args.SoundId) then
					return plr.Send("Message", "You provided an invalid sound", 3)
				end
				
				local IsPlaying = Server.AddSoundToQueue(args.SoundId)
				local SoundInfo = Service.MarketplaceService:GetProductInfo(args.SoundId)
				if IsPlaying then
					plr.Send("Message", "Now playing '" .. SoundInfo.Name .. "'")
				else
					plr.Send("Message", "Added '" .. SoundInfo.Name .. "' to the queue")
				end
			end
		},
		{
			Name = "PauseSound";
			Level = Levels.Moderators;
			Flags = {"MANAGE_SOUNDS"};
			Category = "Music";
			Aliases = {"pause"};
			Run = function(plr, args)
				Server.SoundObject:Pause()
				plr.Send("Message", "Paused '" .. Service.MarketplaceService:GetProductInfo(Server.SoundQueue[1]).Name .. "'")
			end
		},
		{
			Name = "ResumeSound";
			Level = Levels.Moderators;
			Flags = {"MANAGE_SOUNDS"};
			Category = "Music";
			Aliases = {"resume"};
			Run = function(plr, args)
				Server.SoundObject:Resume()
				plr.Send("Message", "Now playing '" .. Service.MarketplaceService:GetProductInfo(Server.SoundQueue[1]).Name .. "'")
			end
		},
		{
			Name = "SkipSound";
			Level = Levels.Moderators;
			Flags = {"MANAGE_SOUNDS"};
			Category = "Music";
			Aliases = {"skip"};
			Run = function(plr, args)
				Server.SoundObject:Stop()
				if #Server.SoundQueue > 0 then
					Server.SoundObject:Play()
					plr.Send("Message", "Now playing '" .. Service.MarketplaceService:GetProductInfo(Server.SoundQueue[1]).Name .. "'")
				end
			end
		},
		{
			Name = "SetPitch";
			Level = Levels.Moderators;
			Flags = {"MANAGE_SOUNDS"};
			Category = "Music";
			Args = {
				{
					Name = "Pitch";
					Type = "int";
					Default = 1;
				}
			};
			Run = function(plr, args)
				Server.SoundObject.PlaybackSpeed = args.Pitch
			end
		},
		{
			Name = "HandTo";
			Level = Levels.Moderators;
			Flags = {"MANAGE_BACKPACK"};
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
					DisableShortcuts = true;
				}
			};
			Run = function(plr, args)
				local Tool = plr.Character:FindFirstChildOfClass("Tool")
				
				if Tool then
					plr.Send("Message", "You handed '" .. Tool.Name .. "' to " .. args.Target.Name)
					args.Target.Send("Message", plr.Name .. " has handed you '" .. Tool.Name .. "'")
					Tool.Parent = args.Target.Backpack
				else
					plr.Send("Message", "You must be holding a tool to do that!")
				end
			end
		},
		{
			Name = "RemoveHats";
			Level = Levels.Moderators;
			Flags = {"MANAGE_CHARACTERS"};
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Run = function(plr, args)
				if not args.Target.Character then
					return
				end

				for _,v in pairs(args.Target.Character:GetDescendants()) do
					if v:IsA("Accessory") then
						v:Destroy()
					end
				end
			end
		},
		{
			Name = "UnCrowd";
			Aliases = {"decrowd", "pushaway"};
			Flags = {"MANAGE_CHARACTERS"};
			Level = Levels.Moderators;
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Radius";
					Type = "int";
					Default = 15;
				}
			};
			Run = function(plr, args)
				if plr == args.Target or not args.Target.Character or not plr.Character then
					return
				end

				local Char = plr.Character	
				local CharCF = Char:GetPrimaryPartCFrame()
				
				local TargetChar = args.Target.Character
				local TargetCharCF = TargetChar:GetPrimaryPartCFrame()

				if (args.Target:DistanceFromCharacter(CharCF.Position) <= args.Radius) then
					local EndPos = (TargetCharCF.Position - CharCF.Position).Unit * args.Radius
					TargetChar:SetPrimaryPartCFrame(CFrame.new(EndPos.X, TargetCharCF.Y, EndPos.Z))
				end
			end
		},
		{
			Name = "Crowd";
			Aliases = {"BringRadius"};
			Level = Levels.Moderators;
			Flags = {"MANAGE_CHARACTERS"};
			Category = "Utility";
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Radius";
					Type = "int";
					Default = 15;
				}
			};
			Run = function(plr, args)
				if plr == args.Target or not args.Target.Character or not plr.Character then
					return
				end

				local Char = plr.Character	
				local CharCF = Char:GetPrimaryPartCFrame()
				
				local TargetChar = args.Target.Character
				local TargetCharCF = TargetChar:GetPrimaryPartCFrame()

				local EndPos = (TargetCharCF.Position - CharCF.Position).Unit * args.Radius
				TargetChar:SetPrimaryPartCFrame(CFrame.new(EndPos.X, TargetCharCF.Y, EndPos.Z))
			end
		},
		{
			Name = "AddStat";
			Aliases = {"newstat"};
			Flags = {"MODIFY_PLAYER_INSTANCE"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Name";
					Type = "string";
				},
				{
					Name = "Value";
					Type = "string";
				}
			};
			Run = function(plr, args)
				local leaderstats = args.Target:FindFirstChild("leaderstats")
				if not leaderstats then
					leaderstats = Instance.new("Folder")
					leaderstats.Name = "leaderstats"
					leaderstats.Parent = args.Target._Object
				end

				if leaderstats:FindFirstChild(args.Name) then
					return --plr.Send("Message", "A leaderstat with name '" .. args.Name .. "' already exists.")
				end

				local stat = Instance.new("StringValue")
				stat.Name = args.Name;
				stat.Value = args.Value;
				stat.Parent = leaderstats;
			end
		},
		{
			Name = "playerdata";
			Level = Levels.Moderators;
			Flags = {"VIEW_PLAYER_DATA"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Category = "Utility";
			Run = function(plr, args)
				plr.Send("DisplayPlayerData", args.Target._Object)
			end
		},
		{
			Name = "PlayerChatLogs";
			Level = Levels.Moderators;
			Flags = {"VIEW_LOGS"};
			Aliases = {"pclogs", "pchatlogs"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Category = "Utility";
			Run = function(plr, args)
				if plr.GetLevel() < Levels.Moderators then return end

				local LogTable = {}
				for k,v in ipairs(Logs.Get("Chat") or {}) do
					if v.Player == args.Target.Name then
						table.insert(LogTable, v.Player .. " - " .. v.Message)
					end
				end
				
				if #LogTable > 0 then
					plr.Send("DisplayTable", "Chat Logs for " .. args.Target.Name, LogTable)
				else
					plr.Send("Message", "This player has no chat logs.")
				end
			end
		},
		{
			Name = "PlayerLogs";
			Aliases = {"plogs"};
			Flags = {"VIEW_LOGS"};
			Level = Levels.Moderators;
			Args = {
				{
					Name = "Target";
					Type = "player";
				}
			};
			Category = "Utility";
			Run = function(plr, args)
				local LogTable = {}
				for k,v in ipairs(Logs.Get("Main")) do
					if args.Target.Name == v.Player then
						table.insert(LogTable, v.Player .. " - " .. v.Command)
					end
				end
				
				if #LogTable > 0 then
					plr.Send("DisplayTable", "Logs for " .. args.Target.Name, LogTable)
				else
					plr.Send("Message", "This player has no admin logs.")
				end
			end
		},
		{
			Name = "groupban";
			Aliases = {"gban"};
			Flags = {"MANAGE_GROUP_BANS"};
			Level = Levels.Admins;
			Args = {
				{
					Name = "GroupId";
					Type = "int";
				},
				{
					Name = "Reason";
					Type = "string";
					Default = "No reason provided";
				}
			};
			Category = "Moderation";
			Run = function(plr, args)
				local Success, GroupInfo = pcall(function()
					return Service.GroupService:GetGroupInfoAsync(args.GroupId)
				end)

				if not Success then
					return plr.Send("Message", "An error occurred while trying to fetch group data.");
				end

				local GroupBans = Data:GetGlobal("GroupBans") or {}

				if not Service.TableFind(GroupBans, function(v)
					return v.GroupId == args.GroupId
				end) then
					table.insert(GroupBans, {
						GroupId = args.GroupId;
						Reason = args.Reason;
						Moderator = plr.UserId;
					})
					Data:SetGlobal("GroupBans", GroupBans)
					
					plr.Send("Message", "You banned group '" .. GroupInfo.Name .. "' for '" .. args.Reason .. "'")
				else
					plr.Send("Message", "This group is already banned. Use ':groupbans' to view a list of banned groups.")
				end
			end
		},
		{
			Name = "ungroupban";
			Aliases = {"ungban"};
			Flags = {"MANAGE_GROUP_BANS"};
			Level = Levels.Admins;
			Args = {
				{
					Name = "GroupId";
					Type = "int";
				}
			};
			Category = "Moderation";
			Run = function(plr, args)
				local Success, GroupInfo = pcall(function()
					return Service.GroupService:GetGroupInfoAsync(args.GroupId)
				end)
				
				if not Success then
					return plr.Send("Message", "An error occurred while trying to fetch group data.");
				end
				
				local GroupBans = Data:GetGlobal("GroupBans") or {}
				
				if Service.TableFind(GroupBans, function(v)
						if v.GroupId == args.GroupId then
							table.remove(GroupBans, table.find(GroupBans, v))
							return true
						end
				end) then
					Data:SetGlobal("GroupBans", GroupBans)
					plr.Send("Message", "You unbanned group '" .. GroupInfo.Name .. "' with ID '" .. args.GroupId .. "'")
				else
					plr.Send("Message", "This group is not banned. Use ':groupbans' to view a list of banned groups.")
				end
			end
		},
		{
			Name = "groupbans";
			Level = Levels.Moderators;
			Flags = {"MANAGE_GROUP_BANS"};
			Category = "Moderation";
			Run = function(plr, args)
				local GroupBans = Data:GetGlobal("GroupBans") or {}
				
				if #GroupBans > 0 then
					local ToSend = {}

					for _,v in ipairs(GroupBans) do
						local Success, GroupInfo = pcall(function()
							return Service.GroupService:GetGroupInfoAsync(v.GroupId)
						end)

						if Success then
							table.insert(ToSend, {
								GroupInfo.Name .. " (" .. v.GroupId .. ")";
								"Reason: " .. v.Reason;
								"Banned By: " .. Service.Players:GetNameFromUserIdAsync(v.Moderator);
							})
						end
					end
					
					plr.Send("DisplayTable", "Banned Groups", ToSend)
				else
					plr.Send("Message", "You have no groups banned from this game.")
				end
			end
		},
		{
			Name = "internallogs";
			Level = Levels.Developers;
			Flags = {"MANAGE_GAME"};
			Run = function(plr, args)
				plr.Send("DisplayTable", "Internal Logs", Logs.Get("Internal"))
			end
		},
		{
			Name = "displayname";
			Aliases = {"name", "setname", "setdisplayname"};
			Level = Levels.Moderators;
			Flags = {"MANAGE_CHARACTERS"};
			Args = {
				{
					Name = "Target";
					Type = "player";
				},
				{
					Name = "Name";
					Type = "string";
				}
			};
			Run = function(plr, args)
				local Character = args.Target.Character
				if Character then
					Character.Humanoid.DisplayName = args.Name or args.Target.Name
				end
				
				args.Target.Send("Message", "Your display name has been set to \"" .. Character.Humanoid.DisplayName .. "\"")
				if args.Target ~= plr then
					plr.Send("Message", "You have set " .. args.Target.Name .. "'s display name to \"" .. Character.Humanoid.DisplayName .. "\"")
				end
			end
		}
	}
	
	Commands.Get = function(query, includeindex)
		query = string.lower(query)
		
		for Index,Command in pairs(Commands.Commands) do
			if string.lower(Command.Name) == query then
				return Command, (includeindex and Index)
			else
				for _,v in pairs(Command.Aliases or {}) do
					if string.lower(v) == query then
						return Command, (includeindex and Index)
					end
				end
			end
		end
		
		return nil
	end
	
	Commands.Categorize = function(Exclude, HideDisabled, MinRank)
		local NewCommands = {}
		for _,Command in pairs(Service.CopyTable(Commands.Commands)) do
			if not Command.Disabled and Command.Level <= MinRank then
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
end