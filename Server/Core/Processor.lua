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
	local DefaultPrefix = Config.Prefix
	
	local function GetArgumentByName(cmd, arg)
		for _,v in pairs(cmd.Args) do
			if v.Name == arg then
				return v
			end
		end
	end
	
	Server.ProcessCommand = function(plr, str)
		local Arguments = Service.Split(str, Config.Deliminator)
		local CommandText = table.remove(Arguments, 1)
		local SelectedCommand
		
		plr = Service.PlayerWrapper(plr)
		
		for _,Command in pairs(Commands.Commands) do
			local Prefix = Command.Prefix or DefaultPrefix
			if Prefix .. lower(Command.Name) == lower(CommandText) then
				SelectedCommand = Command
			else
				for _,Alias in pairs(Command.Aliases) do
					if Prefix .. lower(Alias) == lower(CommandText) then
						SelectedCommand = Command
					end
				end
			end
		end
		
		if not SelectedCommand or SelectedCommand.Disabled then
			return
		end
		
		if plr.GetLevel() < (SelectedCommand.Level or 0) then
			return
		end
		
		local ParsedArgs = {};
		for i = 1, #SelectedCommand.Args do
			local RealArg = SelectedCommand.Args[i]
			local InputArg = Arguments[i]
			
			if RealArg.Type == "int" then
				ParsedArgs[RealArg.Name] = tonumber(math.floor(InputArg or RealArg.Default or 1))
			elseif RealArg.Type == "number" then
				ParsedArgs[RealArg.Name] = tonumber(InputArg or RealArg.Default) or 1
			elseif RealArg.Type == "string" then
				if i ~= #SelectedCommand.Args then
					ParsedArgs[RealArg.Name] = InputArg or RealArg.Default
				else
					local Arg = table.concat(Arguments, " ", i, #Arguments)
					if #Arg == 0 then
						Arg = RealArg.Default
					end
					
					ParsedArgs[RealArg.Name] = Arg
				end
			elseif RealArg.Type == "player" then
				if InputArg then
					InputArg = lower(InputArg)
					if InputArg == "me" then
						ParsedArgs[RealArg.Name] = plr
					else
						local Player = Service.FindPlayer(InputArg)
						ParsedArgs[RealArg.Name] = Player and Environment.Apply(Service.PlayerWrapper)(Player) or ({
							all = "all";
							others = "others";
						})[InputArg] or error("Invalid player!")
					end
				else
					ParsedArgs[RealArg.Name] = plr
				end
			end
		end
		
		Logs.New("Main", {
			Command = str;
			Player = plr.Name;
			Time = tick();
		})
		
		local Run = coroutine.wrap(Environment.Apply(SelectedCommand.Run))
		
		if Service.TableFind(SelectedCommand.Args, function(arg)
				if arg.Type == "player" then
					return true
				end
		end) then
			for Key,ParsedArg in pairs(ParsedArgs) do
				local RealArg = GetArgumentByName(SelectedCommand, Key)
				
				if RealArg.Type == "player" then
					local CustomArgs = {
						all = function()
							for _,v in pairs(Service.GetPlayers()) do
								Run(plr, Service.TableReplace(ParsedArgs, ParsedArg, Service.PlayerWrapper(v)))
							end	
						end,
						others = function()
							for _,v in pairs(Service.GetPlayers({plr})) do
								Run(plr, Service.TableReplace(ParsedArgs, ParsedArg, Service.PlayerWrapper(v)))
							end
						end,
					}
					if CustomArgs[ParsedArg] then
						CustomArgs[ParsedArg]()
					else
						Run(plr, ParsedArgs)
					end
				end
			end
		else
			Run(plr, ParsedArgs)
		end
	end
end