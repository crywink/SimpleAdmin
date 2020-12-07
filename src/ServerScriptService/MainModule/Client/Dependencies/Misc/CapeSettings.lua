Service, UI, Shared, Environment = nil, nil, nil, nil

local CapeSettings = {}

CapeSettings.Init = function()
	for _,v in pairs(CapeSettings) do
		if type(v) == "function" then
			Environment.Apply(v)
		end
	end
end

CapeSettings.Create = function()
	CapeSettings.Destroy()
	
	local Settings = {}
	local Container = UI.New("Cape Settings")
	local Materials = Container:AddSection()
	
	Materials:AddItem("Text", {
		Text = "Material";
		TextXAlignment = Enum.TextXAlignment.Center;
		ImageTransparency = 1;
	})
	for _,v in ipairs({
		"Plastic";
		"Wood";
		"Slate";		
		"Grass";		
		"Concrete";		
		"CorrodedMetal";		
		"Neon";		
		"DiamondPlate";
		"Ice";		
		"Foil";		
		"SmoothPlastic";	
		"Brick";		
		"Fabric";
		"Glass";
	}) do
		Materials:AddItem("Button", {
			Text = v;
			Function = function()
				Settings.Material = v;
			end
		})
	end
	
	local Miscellaneous = Container:AddSection()
	Miscellaneous:AddItem("Text", {
		Text = "Miscellaneous";
		TextXAlignment = Enum.TextXAlignment.Center;
		ImageTransparency = 1;
	})
	Miscellaneous:AddItem("Button", {
		Text = "Color";
		Function = function()
			
		end
	})
	Miscellaneous:AddItem("Slider", {
		Text = "Transparency";
		OnChanged = function(self, progress)
			for _,v in ipairs(self.Values) do
				v.Text = Service.RoundTo(progress, 2) 
			end
		end,
		OnEnded = function(self, progress)
			Settings.Transparency = Service.RoundTo(progress, 2)
		end
	})
	
	Container:AddSection():UpdateSize()
	
	local End = Container:AddSection()
	End:AddItem("Button", {
		Text = "Apply";
		Function = function()
			Shared.Network:FireServer("SetCape", Settings)
		end	
	});
	End:AddItem("Button", {
		Text = "Remove";
		Function = function()
			Shared.Network:FireServer("SetCape", "Remove")
		end
	})
	
	CapeSettings.Container = Container
end

CapeSettings.Destroy = function()
	if CapeSettings.Container then
		CapeSettings.Container.Object:Destroy()
		CapeSettings.Container = nil
	end
end

return CapeSettings