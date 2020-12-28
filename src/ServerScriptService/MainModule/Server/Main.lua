Server, Service, Processor, Config, Environment, Data, Shared, Commands, Logs, Misc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

--[[
	SimpleAdmin | Server
--]]

return function()
	Logs.New("Internal", "init Main.lua")
	Data.Init()
	Server.CustomConnections = {}
	
	local function LogInternal(msg)
		Logs.New("Internal", "Main.lua: \"" .. msg .. "\": ")
	end

	--[[
		PlayerAdded Handling
	--]]
	local function PlayerAdded(plr)
		local Wrapper = Service.PlayerWrapper(plr)
		
		local function LogInternal(msg)
			Logs.New("Internal", "PlayerAdded \"" .. plr.Name .. "\": " .. msg)
		end
		LogInternal("Init")
		--[[
			Logs the join to be viewed via :joinlogs
		--]]
		Logs.New("JoinLogs", {
			Name = plr.Name;
			Time = tick();
		})
		
		--[[
			This will kick the player if they're banned
		--]]
		Server.HandleBan(plr)
		LogInternal("HandleBan")
		
		--[[
			Checks if the player owns the game, if so, give them developer permissions.
		--]]
		if game.CreatorType == Enum.CreatorType.User then
			if game.CreatorId == plr.UserId or game.CreatorId == 0 then
				Service.SetPermissionLevel(plr, Service.AdminLevels.Developers)
				LogInternal("Developer rank given (game owner)")
			end
		elseif game.CreatorType == Enum.CreatorType.Group then
			if plr:GetRankInGroup(game.CreatorId) == 255 then
				LogInternal("Developer rank given (group owner)")
				Service.SetPermissionLevel(plr, Service.AdminLevels.Developers)
			end
		end
		
		--[[
			Checks if the player is crywink (the owner of SA) and gives them admin if DisableCreatorPermissions isn't enabled.
			If the player is a donator, gives them donator permissions.
		--]]
		if plr.UserId == 23665982 and not Config.DisableCreatorPermissions then
			Service.SetPermissionLevel(plr, Service.AdminLevels.Developers)
			LogInternal("Debugging permission")
		elseif Service.GetPermissionLevel(plr) == 0 and Service.MarketplaceService:UserOwnsGamePassAsync(plr.UserId, 10668450) then
			if not Config.DisableDonorPerks then
				Service.SetPermissionLevel(plr, Service.AdminLevels.Donators)
				LogInternal("Donor permission")
			end
		end

		--[[
			Checks if the server is locked and will kick if player isn't a moderator
		--]]
		if Service.GetPermissionLevel(plr) < Service.AdminLevels.Moderators then
			if Server.ServerLock then
				plr:Kick("| SimpleAdmin |\n\nThis server is locked!\nReason: " .. Server.ServerLock)
				LogInternal("ServerLock Kicked")
				return
			else
				local GroupBans = Data:GetGlobal("GroupBans") or {}
				for _,v in pairs(GroupBans) do
					if plr:IsInGroup(v.GroupId) then
						LogInternal("GroupBan Kicked")
						plr:Kick("| SimpleAdmin |\n\nYou're in a group that's banned from this game.\nGroup Name: " .. Service.GroupService:GetGroupInfoAsync(v.GroupId).Name)
					end
				end
			end
		end
		
		--[[
			Handle chat events
		--]]
		plr.Chatted:Connect(function(msg)
			--[[
				1) Splits the message by the command separator ("|")
				2) Runs the iteration through the command processor and runs the command if it's valid
			--]]
			for _,v in ipairs(string.split(({msg:gsub("\/e ", "")})[1], Config.CommandSeparator or "|")) do
				LogInternal("Command processing '" .. v .. "'")
				Server.ProcessCommand(plr, v)
			end
			
			--[[
				Add a chat log to be viewed via :chatlogs
			--]]
			Logs.New("Chat", {
				Player = plr.Name;
				Message = Service.FilterText(msg, plr.UserId, plr.UserId);
				Time = tick();
			})
			table.remove(Logs.Get("Chat"), 500)
		end)
		
		coroutine.wrap(function()
			if not plr.Character then
				LogInternal("Waiting for character")
				plr.CharacterAdded:Wait() -- Wait for character to become a thing
			end
			
			--[[
				Notify the player that they're an admin
			--]]
			if Service.GetPermissionLevel(plr) > Service.AdminLevels.Donators then
				local RankMessages = {
					[1] = "You're a donator!";
					[2] = "You're a moderator!";
					[3] = "You're an admin!";
					[4] = "You're an owner!";
					[5] = "You're a creator!";
				}
				
				Wrapper.Send("Message", RankMessages[Wrapper.GetLevel()], 7)
				Wrapper.Send("Message", "Type " .. Config.Prefix .. "cmds to view a list of commands.", 7)

				LogInternal("Sent permission hint: " .. RankMessages[Wrapper.GetLevel()])
			end
		end)()
		
		coroutine.wrap(function()
			while true do
				wait(Config.PingRefreshRate or 5)
				Wrapper.PingSent = tick()
				Wrapper.Send("Ping")
			end
		end)()
	end
	
	for _,v in pairs(Service.Players:GetPlayers()) do
		coroutine.wrap(PlayerAdded)(v)
	end
	Service.Players.PlayerAdded:Connect(PlayerAdded)
	
	--[[
		Event Binding
	--]]
	Shared.Network:BindEvent({
		Troll = function(plr, target, action, ...)
			local args = {...}
			plr = Service.PlayerWrapper(plr)
			if target:IsA("Player") then
				target = Service.PlayerWrapper(target)
			end
			
			if plr.GetLevel() < Commands.Get("troll").Level then
				return
			end
			
			if action == "Kill" then
				target.GetHumanoid().Health = 0
			elseif action == "Kick" then
				target:Kick("\n\nSimpleAdmin | You have been kicked by an administrator. [T_PANEL]")
			elseif action == "Crash" then
				target.Send("Crash")
				
				Logs.New("Main", {
					Time = tick();
					Command = Service.FilterText("[Crashed " .. target.Name .. "]", plr.UserId, plr.UserId);
					Player = plr.Name;
				})
			elseif action == "Blind" then
				target.Send("Blind", args[1])
			elseif action == "Explode" then
				if target.Character then
					Service.New("Explosion", {
						BlastRadius = 15;
						ExplosionType = Enum.ExplosionType.NoCraters;
						Position = target.Character:GetPrimaryPartCFrame().Position;
						Parent = target.Character.PrimaryPart;
					})
				end
			elseif action == "Freeze" then
				if target.Character then
					target.Character.PrimaryPart.Anchored = args[1]
				end
			end
		end;
		
		GetTool = function(plr, Index)
			if not Server.Tools then
				return
			end
			
			Server.Tools[Index]:Clone().Parent = plr.Backpack
		end;
		
		SetCape = function(plr, data)
			plr = Service.PlayerWrapper(plr)
			
			if plr.GetLevel() < Service.AdminLevels.Donators then
				return
			end
			
			local Character = plr.Character
			local Humanoid = Character:WaitForChild("Humanoid")
			local Torso = Humanoid.RigType == Enum.HumanoidRigType.R15 and Character:WaitForChild("UpperTorso") or Character:WaitForChild("Torso")
			
			local ExistingCape = Torso:FindFirstChild("SimpleAdmin_Cape")
			if ExistingCape then
				ExistingCape:Destroy()
			end
			
			if data ~= "Remove" then
				Misc.Character.Capeify(plr, data or {})
			end
		end;
		
		Pong = function(plr, data)
			plr = Service.PlayerWrapper(plr)
			plr.Ping = (tick() - plr.PingSent) * 1000
		end;
		
		IsWindowFocused = function(plr, IsFocused)
			plr = Service.PlayerWrapper(plr)
			plr.IsWindowFocused = IsFocused
		end;

		GetChatLogsForPlayer = function(plr, target)
			plr = Service.PlayerWrapper(plr)
			if plr.GetLevel() < Service.AdminLevels.Moderators then return end

			local LogTable = {}
			for k,v in ipairs(Logs.Get("Chat") or {}) do
				if v.Player == target.Name then
					table.insert(LogTable, v.Player .. " - " .. v.Message)
				end
			end
			
			if #LogTable > 0 then
				plr.Send("DisplayTable", "Chat Logs for " .. target.Name, LogTable)
			else
				plr.Send("Message", "This player has no chat logs.")
			end
		end;

		GetAdminLogsForPlayer = function(plr, target)
			plr = Service.PlayerWrapper(plr)
			if plr.GetLevel() < Service.AdminLevels.Moderators then return end

			local LogTable = {}
			for k,v in ipairs(Logs.Get("Main")) do
				if target.Name == v.Player then
					table.insert(LogTable, v.Player .. " - " .. v.Command)
				end
			end
			
			if #LogTable > 0 then
				plr.Send("DisplayTable", "Logs for " .. target.Name, LogTable)
			else
				plr.Send("Message", "This player has no admin logs.")
			end
		end;

		GetClipboardLogsForPlayer = function(plr, target)
			Commands.Get("clipboardlogs").Run(Service.PlayerWrapper(plr), {
				Target = Service.PlayerWrapper(target);
			})
		end
	})

	--[[
		RemoteFunction Binding
	--]]
	Shared.Network:BindFunction({
		GetPlayerData = function(plr, Target)
			plr = Service.PlayerWrapper(plr)
			Target = Service.PlayerWrapper(Target)

			if plr.GetLevel() < Service.AdminLevels.Moderators then
				return
			end

			local Character = Target.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			if not Character or not Humanoid then
				Character = setmetatable({}, {
					__index = function(self, key)
						return "Character/Humanoid was not found!"
					end
				})
			end

			return {
				Level = Service.GetLevelTitle(Target.GetLevel());
				Team = Target.Team;
				IsFocused = Target.IsWindowFocused;
				ServerTime = Service.RoundTo((tick() - Target.Created) / 60, 2);
				Ping = math.ceil(Target.Ping);
				Health = Humanoid.Health;
				WalkSpeed = Humanoid.WalkSpeed;
				JumpPower = Humanoid.JumpPower;
				AccountAge = Target.AccountAge;
			}
		end
	})

	--[[
		Setting up permissions [this is very tedious and im gonna reconfigure this soon so its not bAD]
	--]]
	local Permissions = Service.Permissions
	for _,v in pairs(Config.Moderators) do
		Permissions[tonumber(v) or v] = Service.AdminLevels.Moderators
	end
	for _,v in pairs(Config.Admins) do
		Permissions[tonumber(v) or v] = Service.AdminLevels.Admins
	end
	for _,v in pairs(Config.Owners) do
		Permissions[tonumber(v) or v] = Service.AdminLevels.Owners
	end
	for _,v in pairs(Config.Developers) do
		Permissions[tonumber(v) or v] = Service.AdminLevels.Developers
	end
	
	--[[
		Fully removes fun commands from the commands table if Config.DisableFunCommands
	--]]
	if Config.DisableFunCommands then
		for k,v in ipairs(Commands.Commands) do
			if v.Category == "Fun" then
				Commands.Commands[k] = nil	
			end
		end
	end
		
	--[[
		Closing down shop
	--]]
	game:BindToClose(function()
		warn("Cleaning up...")
		
		local InstancesAmount = #Service.Instances
		for _,v in pairs(Service.Instances) do
			v:Destroy()
		end
		
		warn("Removed " .. tostring(InstancesAmount) .. " instances.")
		warn("Destroying script... Goodbye!")
		
		Environment.Apply(Service.Nuke)()
	end)
end