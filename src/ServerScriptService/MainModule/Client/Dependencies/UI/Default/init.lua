Service, Client, Environment = nil, nil, nil

--[[
	SimpleAdmin | Default UI Kit
		- Class based system that allows you to easily modify UI
	
	If you want to make your own theme for SimpleAdmin, you can fork this module
	and modify it for your needs. I'll have a config down below that lets you edit
	some of the core features of the kit.
--]]

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- Variables
local Player = Players.LocalPlayer
local Config = {}
local AssetsDirectory = script:WaitForChild("Assets")
local Classes = {}
local CurrentContainers = {}

-- Module
local Library = {};
Library.__index = Library
local Section = {};
Section.__index = Section

for _,v in pairs(script:WaitForChild("Classes"):GetChildren()) do
	if v:IsA("ModuleScript") then
		local mod = require(v)
		Classes[v.Name] = mod
		if type(mod) == "table" and mod.Init then
			mod.Init()
		end
	end
end

Library.Classes = Classes

Library.Assets = {
	BaseUI = AssetsDirectory:WaitForChild("BaseUI");
	MainContainer = AssetsDirectory:WaitForChild("Container");
	Section = AssetsDirectory:WaitForChild("Section");
	Button = AssetsDirectory:WaitForChild("Button");
	Dropdown = AssetsDirectory:WaitForChild("Dropdown");
	Keybind = AssetsDirectory:WaitForChild("Keybind");
	Toggle = AssetsDirectory:WaitForChild("Toggle");
	Hint = AssetsDirectory:WaitForChild("Hint");
	Timer = AssetsDirectory:WaitForChild("Timer");
}

local function OrganizeContainers(StartZero)
	for i,v in ipairs(CurrentContainers) do
		if StartZero or true then
			i = i - 1
		end
		
		v.Object:TweenPosition(UDim2.new(0,(i*(v.Object.Size.X.Offset+10))+20,.308,0), "Out", "Sine", .1, true)
	end
end

Library.Init = function()
	Environment.Apply(Library.New)
end

Library.New = function(Name)
	local UI = {}
	setmetatable(UI, Library)
	
	local Conn
	local Base = Library.Assets.BaseUI:Clone()
	Base.Parent = Player.PlayerGui
	local Obj = Library.Assets.MainContainer:Clone()
	Obj.Parent = Base
	Obj.Name = Name
	Obj.Bar.Title.Text = Name
	Obj.Bar.Title.Close_Button.MouseButton1Click:Connect(function()
		table.remove(CurrentContainers, table.find(CurrentContainers, UI))
		OrganizeContainers(true)
		Obj:TweenSize(UDim2.new(0, Obj.Size.X.Offset, 0, 0), "In", "Sine", .1, true, function()
			Obj:Destroy()
			Base:Destroy()
			Conn:Disconnect()	
		end)
	end)

	local SearchBar = Obj.Bar.Title.SearchBar
	local SearchButton = Obj.Bar.Title.Search_Button

	SearchButton.MouseButton1Click:Connect(function()
		SearchButton.Visible = false
		SearchBar.Visible = true
		SearchBar.Input.Text = ""
		SearchBar.Input:CaptureFocus()
	end)

	SearchBar.Input:GetPropertyChangedSignal("Text"):Connect(function()
		local Text = SearchBar.Input.Text
		SearchBar.Size = UDim2.new(0, math.max(59 - 4, SearchBar.Input.TextBounds.X + 12), 1, 0)

		for _,v in pairs(UI.Items) do
			if v.ClassName == "Dropdown" then
				local Visible = false

				for _,Element in pairs(v.Elements:GetChildren()) do
					if Element:IsA("TextLabel") or Element:IsA("TextButton") then
						if string.find(Element.Text:lower(), Text:lower()) then
							Element.Visible = true
							Visible = true
						else
							Element.Visible = false
						end
					end
				end

				if not v.IsCollapsed then
					v:Expand()
				end
				
				v.Object.Parent.Visible = Visible
			elseif v.ClassName == "Text" then
				if string.find(v.Object.Title.Text:lower(), Text:lower()) then
					v.Object.Visible = true
				else
					v.Object.Visible = false
				end
			elseif v.ClassName == "Button" then
				if string.find(v.Object.Title.Text:lower(), Text:lower()) then
					v.Object.Visible = true
				else
					v.Object.Visible = false
				end
			end
		end

		for _,v in pairs(UI.Sections) do
			if v.UpdateSize then
				v:UpdateSize()
			end
		end
	end)

	SearchBar.Input.FocusLost:Connect(function()
		if SearchBar.Input.Text == "" then
			SearchBar.Visible = false
			SearchButton.Visible = true
		end
	end)
	
	table.insert(CurrentContainers, 1, UI)
	UI.Object = Obj
	UI.SectionContainer = Obj.Section_Holder.Holder	
	UI.Items = {}
	UI.Sections = {}
	
	if #CurrentContainers > 0 then
		Obj.Position = CurrentContainers[1].Object.Position
		OrganizeContainers()
	end
	
	Service.MakeDraggable(Obj)
	Service.MakeResizeable(Obj, nil, function()

	end)
	
	Conn = RunService.RenderStepped:Connect(function()
		if not UI or not Obj or not UI.SectionContainer:FindFirstChild("List") then
			Conn:Disconnect()
			return
		end

		UI.SectionContainer.CanvasSize = UDim2.new(0, 0, 0, UI.SectionContainer.List.AbsoluteContentSize.Y)

		for _,v in pairs(UI.Items) do
			if v.UpdateSize then
				--v:UpdateSize()
			end
		end

		for _,v in pairs(UI.Sections) do
			if v.UpdateSize then
				v:UpdateSize()
			end
		end
	end)
	
	return UI
end

Library.Hint = Classes.Hint.New
Library.Message = Classes.Message.New

Library.Timer = function(a, b, step, interval)
	local Object = Library.Assets.Timer:Clone()
	local TimerText = Object.Main.Section_Holder.Holder.Timer
	Service.MakeDraggable(Object.Main)
	
	Object.Parent = Player.PlayerGui
	Object.Main.Bar.Title.close_button.MouseButton1Click:Connect(function()
		Object:Destroy()
	end)
	
	Object.Enabled = true
	
	for i = a, b, step do
		if not Object then
			break
		end
		
		TimerText.Text = tostring(i)
		wait(interval)	
	end
	
	TimerText.Text = "Finished!"
end

Library.AddSection = function(self, Name, Type, Data)
	Name = Name or ""
	
	if not Type then
		local NewSection = {}
		setmetatable(NewSection, Section)
		
		local Obj = Library.Assets.Section:Clone()
		Obj.Parent = self.SectionContainer
		Obj.Name = Name
		NewSection.Container = Obj.Holder
		NewSection.Object = Obj
		NewSection.Parent = self
		
		table.insert(self.Sections, NewSection)
		
		return NewSection
	elseif Type == "Dropdown" then
		local Section = Library.Assets.Section:Clone()
		Section.Parent = self.SectionContainer
		Section.Holder:Destroy()
		Section.Name = Name
		
		local Dropdown = Classes.Dropdown.New(Name, Data)
		Dropdown.Object.Parent = Section
		Dropdown:Collapse()
		
		table.insert(self.Sections, Dropdown)
		table.insert(self.Items, Dropdown)

		return Dropdown
	end
end

Section.UpdateSize = function(self)
	self.Object.Size = UDim2.new(1, 0, 0, self.Container.List.AbsoluteContentSize.Y + 8)
end

Section.AddItem = function(self, name, data)
	local Class = Classes[name]
	
	local Item = Class.New(data)
	Item.Object.Parent = data.Parent or self.Container
	if Item.UpdateSize then
		Item:UpdateSize()
	end

	table.insert(self.Parent.Items, Item)
	
	self:UpdateSize()
	return Item
end

return Library