Server, Service, Processor, Config, Environment, Data, Shared, Commands = nil, nil, nil, nil, nil, nil, nil, nil

--[[
	SimpleAdmin | Server
--]]

return function()
	Data.Init()
	
	--[[
		Message Handling
	--]]
	local function PlayerAdded(plr)
		if Service.TableFind(Config.Bans, function(x)
			return Service.ResolveToUserId(x).UserId == plr.UserId
		end) then
			plr:Kick("\n\nSimpleAdmin | You have been banned.")
		else
			local BanData = Data:GetGlobal("Bans")[tostring(plr.UserId)]
			if BanData then
				plr:Kick("\n\nSimpleAdmin | You have been banned by a moderator.\nReason: " .. (BanData.Reason or "N/A"))
			end
		end
		
		if game.CreatorType == Enum.CreatorType.User and game.CreatorId == plr.UserId then
			Service.SetPermissionLevel(plr, 4)
		end
		
		plr.Chatted:Connect(function(msg)
			Server.ProcessCommand(plr,msg)
		end)
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