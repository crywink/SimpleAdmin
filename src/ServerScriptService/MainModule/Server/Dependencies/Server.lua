Service, Commands, Environment, Config, Data = nil, nil, nil, nil, nil

--[[
	SimpleAdmin | Server
--]]

local Server = {}

Server.Init = function()
	for _,v in pairs(Server) do
		if type(v) == "function" then
			Environment.Apply(v)
		end
	end
	
	Server.SoundQueue = {};
	
	if not Server.SoundObject then
		local Sound = Instance.new("Sound")
		Sound.Parent = workspace
		Sound.Name = "SimpleAdmin_Sound"
		
		local function SoundEnded()
			print("ended")
			table.remove(Server.SoundQueue, 1)
			
			if #Server.SoundQueue > 0 then
				Server.ForcePlaySound(Server.SoundQueue[1])
			end
		end
		
		Sound.Stopped:Connect(SoundEnded)
		Sound.Ended:Connect(SoundEnded)
		
		Server.SoundObject = Sound
	end
end

Server.Shutdown = function(Name, Reason)
	local Players = Service.GetPlayers({}, true)
	local KickMsg = "\n| SimpleAdmin |\n" .. Name .. " has shut down the server."
	
	for _,v in ipairs(Players) do
		v.Send("Message", Name .. " is shutting down the server!", 5)
	end
	wait(5)
	for _,v in ipairs(Players) do
		v:Kick(KickMsg)
	end
	
	Service.Players.PlayerAdded:Connect(function(p)
		p:Kick(KickMsg)
	end)
end

Server.HandleBan = function(plr)
	Environment.Apply()
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
end

Server.ForcePlaySound = function(SoundId)
	local Sound = Server.SoundObject
	Sound.SoundId = "rbxassetid://" .. SoundId
	wait(.5) -- Because for some reason it just doesnt play w/o a wait (Sound.Loaded:Wait()) didnt work either smhmh
	Sound:Play()
end

Server.AddSoundToQueue = function(SoundId)
	table.insert(Server.SoundQueue, SoundId)
	
	if #Server.SoundQueue == 1 then
		Server.ForcePlaySound(SoundId)
		return true
	end
end

return Server