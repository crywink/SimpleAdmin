Server, Service, Config, Commands, Environment, Logs = nil, nil, nil, nil, nil, nil

--[[
	SimpleAdmin | Process
		- This code is spaghetti don't come at me broski

		- ok i just finished analyzer and like... the code doesnt
		- even look that bad. I really expected it to turn out a lot worse but uh
		- tbh I really aced it.
--]]

-- Variables
local lower = string.lower

-- Module
return function()
	local function GetArgumentByName(cmd, arg)
		for _,v in ipairs(cmd.Args) do
			if v.Name == arg then
				return v
			end
		end
	end
	
	Server.ResolveToPlayers = function(Player, String, Wrap, DisableShortcuts)
		local StringLower = lower(String):gsub("%s","")
		local Wrapper = Service.PlayerWrapper(Player)
		local Return
			
		if StringLower == "me" then
			Return = Player
		elseif StringLower == "others" then
			Return = Service.GetPlayers({Player})
		elseif StringLower == "all" then
			Return = Service.GetPlayers()
		elseif StringLower == "random" then
			local Players = Service.GetPlayers()
			Return = Players[math.random(1, #Players)]
		elseif StringLower:sub(1,1) == "%" then
			local TeamText = StringLower:sub(2, #StringLower)
			local Team = Service.FindTeam(TeamText)
			
			if Team then
				Return = Team:GetPlayers()
			end
		elseif StringLower:sub(1,1) == "-" then
			local Distance = tonumber(StringLower:match("%d+"))
			local Character = Player.Character
			local PrimPart = Character.PrimaryPart
			local WithinRadius = {}
			
			if Character and PrimPart and Distance then
				for _,v in ipairs(Service.GetPlayers({Player})) do
					local TargetCharacter = v.Character
					local TargetPrimPart = TargetCharacter.PrimaryPart
					
					if TargetPrimPart then
						local TargetPos = TargetCharacter:GetPrimaryPartCFrame().Position
						if (Player:DistanceFromCharacter(TargetPos) <= Distance) then
							table.insert(WithinRadius, v)
						end
					end
				end
			end
			
			Return = WithinRadius
		else
			Return = Service.FindPlayer(String)
		end
		
		if type(Return) == "table" then
			if not DisableShortcuts then
				if Wrap then
					for i,v in ipairs(Return) do
						Return[i] = Service.PlayerWrapper(v)
					end
				end
				
				return Return
			end
		elseif Return then
			if Wrap then
				Return = Service.PlayerWrapper(Return)
			end
			
			return {Return}
		end
	end
	
	Server.ProcessCommand = function(plr, str, prefix)
		local DefaultPrefix = Config.Prefix
		local Arguments = Service.Split(str, Config.Deliminator)
		local CommandText = table.remove(Arguments, 1) or ""
		CommandText = CommandText:gsub("%s", "")
		local SelectedCommand
		
		plr = Service.PlayerWrapper(plr)

		local function Debug(Desc)
			Logs.New("Debug", {
				Type = "CommandRun";
				Description = Desc;
				Extra = {
					CommandText = CommandText;
					Arguments = Arguments;
				}
			})
		end

		for _,Command in pairs(Commands.Commands) do
			local Prefix = Command.Prefix or prefix or DefaultPrefix

			if Prefix .. lower(Command.Name) == lower(CommandText) then
				SelectedCommand = Command
				Debug("Found command!")
			else
				for _,Alias in pairs(Command.Aliases or {}) do
					if Prefix .. lower(Alias) == lower(CommandText) then
						SelectedCommand = Command
						Debug("Found command 2!")
					end
				end
			end
		end

		if not SelectedCommand or SelectedCommand.Disabled or SelectedCommand.Category == "Fun" and Config.DisableFunCommands then
			Debug("Command disabled / non-existant")
			return
		end
		
		if plr.GetLevel() < (SelectedCommand.Level or 0) then
			Debug("User " .. plr.Name .. " has insufficient permissions")
			return
		end
		
		local ParsedArgs = {};
		local CommandArgs = SelectedCommand.Args or SelectedCommand.Arguments or {}
		for i = 1, #CommandArgs do
			local RealArg = CommandArgs[i]
			local InputArg = Arguments[i]
			local Default
			if RealArg.Default then
				if type(RealArg.Default) == "function" then
					Default = RealArg.Default()
				else
					Default = RealArg.Default
				end
			end
			
			if RealArg.Type == "int" then
				InputArg = tonumber(InputArg)
				ParsedArgs[RealArg.Name] = InputArg and math.floor(InputArg) or Default
			elseif RealArg.Type == "number" then                                                                                     
				ParsedArgs[RealArg.Name] = tonumber(InputArg or Default) or Default
			elseif RealArg.Type == "string" then
				if i ~= #CommandArgs then
					ParsedArgs[RealArg.Name] = InputArg or Default
				else
					local Arg = table.concat(Arguments, " ", i, #Arguments)
					if #Arg == 0 then
						Arg = Default
					end
					
					ParsedArgs[RealArg.Name] = Arg
				end
			elseif RealArg.Type == "player" then
				ParsedArgs[RealArg.Name] = InputArg and lower(InputArg) or "me"
			end
		end
		
		coroutine.wrap(function()
			Logs.New("Main", {
				Command = Service.FilterText(str, plr.UserId, plr.UserId);
				Player = plr.Name;
				Time = tick();
			})
			table.remove(Logs.Get("Main"), 500)
		end)()
			
		local Run = function(...)
			if not SelectedCommand.DisableEnvironmentApplication then
				Environment.Apply(SelectedCommand.Run)	
			end
			
			coroutine.wrap(SelectedCommand.Run)(...)
		end
		
		if Service.TableFind(CommandArgs, function(arg)
				if arg.Type == "player" then
					return true
				end
		end) then
			for Key,ParsedArg in pairs(ParsedArgs) do
				local RealArg = GetArgumentByName(SelectedCommand, Key)
				
				if RealArg.Type == "player" then
					local SelectedPlayers = Server.ResolveToPlayers(plr._Object, ParsedArg, true, RealArg.DisableShortcuts)
					
					if not RealArg.ReturnTable then
						for _,v in ipairs(SelectedPlayers or {}) do
							if v ~= plr and RealArg.HierarchyLimited then
								if v.GetLevel() >= plr.GetLevel() then
									continue
								end
							elseif v == plr and RealArg.DisableSelf then
								continue	
							end
							
							Run(plr, Service.TableReplace(ParsedArgs, ParsedArg, v))
						end
					else
						Run(plr, Service.TableReplace(ParsedArgs, ParsedArg, SelectedPlayers))
					end
				end
			end
		else
			Run(plr, ParsedArgs)
		end
		
		if SelectedCommand.RunOnce then
			coroutine.wrap(SelectedCommand.RunOnce)(plr, ParsedArgs)
		end
		
		coroutine.wrap(function()
			for _,v in pairs(Server.CustomConnections.OnCommandRan or {}) do
				v.Function(plr, str, SelectedCommand, ParsedArgs)
			end
		end)()
	end
end