Service, Shared, UI = nil, nil, nil

--[[
	SimpleAdmin | Incoming
		- Handles network requests
--]]

return function()
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
		end
	})
end