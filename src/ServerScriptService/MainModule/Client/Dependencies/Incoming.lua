Service, Shared, UI, Misc, Client = nil, nil, nil, nil, nil

--[[
	SimpleAdmin | Incoming
		- Handles network requests
--]]

return function()
	local Player = Service.Players.LocalPlayer
	
	Shared.Network:BindEvent({
		DisplayTable = function(Name, Table)
			local Container = UI.New(Name)
			
			local MainSection
			for CategoryName, Value in pairs(Table) do
				if type(Value) == "table" then
					local Section = Container:AddSection((type(CategoryName) ~= "number") and CategoryName or table.remove(Value, 1), "Dropdown")
					for _,Element in pairs(Value) do
						if Element ~= "_Key" then
							if type(Element) == "table" then
								Section:AddElement(nil, Service.Pascal(Element.Name))
							else
								Section:AddElement(nil, tostring(Element))
							end
						end
					end
				else
					if not MainSection then
						MainSection = Container:AddSection(CategoryName)
					end
					
					MainSection:AddItem("Text", {
						Text = Value;
					})
				end
			end
		end,
		
		DisplayTrollPanel = function(Target)
			local Container = UI.New("Troll (" .. Target.Name .. ")")
			
			local Section1 = Container:AddSection("Section_1", nil)
			Section1:AddItem("Button", {
				Text = "Kill";
				Function = function()
					Shared.Network:FireServer("Troll", Target, "Kill")
				end
			})
			Section1:AddItem("Button", {
				Text = "Explode";
				Function = function()
					Shared.Network:FireServer("Troll", Target, "Explode")
				end
			})
			Section1:AddItem("Toggle", {
				Text = "Blind";
				Function = function(tog)
					Shared.Network:FireServer("Troll", Target, "Blind", tog)
				end
			})
			Section1:AddItem("Toggle", {
				Text = "Freeze";
				Function = function(tog)
					Shared.Network:FireServer("Troll", Target, "Freeze", tog)
				end
			})
			
			local Section2 = Container:AddSection("Section_2", nil)
			Section2:AddItem("Button", {
				Text = "Kick";
				Function = function()
					Shared.Network:FireServer("Troll", Target, "Kick")
				end
			})
			Section2:AddItem("Button", {
				Text = "Crash";
				Function = function()
					Shared.Network:FireServer("Troll", Target, "Crash")
				end
			})
		end,
		
		Blind = function(toggle)
			UI.Blind(toggle)
		end,
		
		Crash = function()
			while true do end
		end,
		
		Noclip = function(toggle)
			if toggle then
				Service.Connections.Noclip = Service.RunService.Stepped:Connect(function()
					if Player.Character then
						for _,v in pairs(Player.Character:GetDescendants()) do
							if v:IsA("BasePart") then
								v.CanCollide = false
							end
						end
					end
				end)
			else
				local Conn = Service.Connections.Noclip
				if Conn then
					Conn:Disconnect()
				end
			end
		end,
		
		Fly = function(toggle)
			if toggle then
				if Misc.FlySettings and Misc.FlySettings.Enabled then
					Misc.FlySettings.Disable()	
				end
				
				Misc.Fly()
			else
				Misc.FlySettings.Disable()
			end
		end,
		
		Message = function(text, timeout)
			UI.Message(text, tonumber(timeout))
		end,
		
		Countdown = function(Time, Message)
			if Message then
				for i = math.clamp(Time, 0, math.huge), 0, -1 do
					UI.Message(tostring(i) .. " seconds left!", .5)
					wait(1)
				end
			else
				UI.Timer(Time, 0, -1, 1)
			end	
		end,
		
		SetCameraSubject = function(Subject)
			workspace.CurrentCamera.CameraSubject = Subject
		end,
		
		SetCoreGuiEnabled = function(CoreGuiType, Enabled)
			Service.StarterGui:SetCoreGuiEnabled(CoreGuiType, Enabled)
		end,
		
		ShowTools = function(Tools)
			local Container = UI.New("Tools")
			local Section = Container:AddSection("Main")
			
			for Index, ToolName in ipairs(Tools) do
				Section:AddItem("Button", {
					Text = ToolName;
					Function = function()
						Shared.Network:FireServer("GetTool", Index)
					end
				})
			end
		end,
		
		ShowCapeSettings = function()
			if Misc.CapeSettings.Container then
				Misc.CapeSettings.Destroy()
			end
			
			Misc.CapeSettings.Create()
		end,
		
		ShowPanel = function()
			Client.Panel.Enabled = true
		end,
		
		Ping = function()
			Shared.Network:FireServer("Pong")
		end
	})
end