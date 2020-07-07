Service, Environment = nil, nil

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
local NotMoved = {}

-- Module
local Library = {};
Library.__index = Library
local Section = {};
Section.__index = Section

for _,v in pairs(script:WaitForChild("Classes"):GetChildren()) do
	if v:IsA("ModuleScript") then
		Classes[v.Name] = require(v)
	end
end

Library.Assets = {
	BaseUI = AssetsDirectory:WaitForChild("BaseUI");
	MainContainer = AssetsDirectory:WaitForChild("Container");
	Section = AssetsDirectory:WaitForChild("Section");
	Button = AssetsDirectory:WaitForChild("Button");
	Dropdown = AssetsDirectory:WaitForChild("Dropdown");
	Keybind = AssetsDirectory:WaitForChild("Keybind");
	Toggle = AssetsDirectory:WaitForChild("Toggle");
	Hint = AssetsDirectory:WaitForChild("Hint");
}

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
		Obj:Destroy()
		table.remove(NotMoved, table.find(NotMoved, UI))
		Conn:Disconnect()
	end)
	
	if #NotMoved > 0 then
		Obj.Position = NotMoved[1].Object.Position
		
		for i,v in ipairs(NotMoved) do -- spEED go zoom
			v.Object:TweenPosition(v.Object.Position + UDim2.new(0,v.Object.Size.X.Offset * .25,0,0), "Out", "Sine", .1, true)
		end
	end
	
	table.insert(NotMoved, 1, UI)
	Service.MakeDraggable(Obj, function()
		table.remove(NotMoved, table.find(NotMoved, UI))
	end)
	
	UI.Object = Obj
	UI.SectionContainer = Obj.Section_Holder.Holder
	
	Conn = RunService.RenderStepped:Connect(function()
		UI.SectionContainer.CanvasSize = UDim2.new(0, 0, 0, UI.SectionContainer.List.AbsoluteContentSize.Y)
		if not UI or not Obj then
			Conn:Disconnect()
		end
	end)
	
	return UI
end

Library.AddSection = function(self, Name, Type, Data)
	if not Type then
		local NewSection = {}
		setmetatable(NewSection, Section)
		
		local Obj = Library.Assets.Section:Clone()
		Obj.Parent = self.SectionContainer
		Obj.Name = Name
		NewSection.Container = Obj.Holder
		NewSection.Object = Obj
		
		return NewSection
	elseif Type == "Dropdown" then
		local Section = Library.Assets.Section:Clone()
		Section.Parent = self.SectionContainer
		Section.Holder:Destroy()
		Section.Name = Name
		
		local Dropdown = Classes.Dropdown.New(Name, Data)
		Dropdown.Object.Parent = Section
		Dropdown:Collapse()
		
		return Dropdown
	end
end

Library.Hint = function(Text)
	local Base = Library.Assets.BaseUI:Clone()
	Base.Parent = Player.PlayerGui
	local Hint = Library.Assets.Hint:Clone()
	Hint.Parent = Base
	
	
end

Section.UpdateSize = function(self)
	self.Object.Size = UDim2.new(1, 0, 0, self.Container.List.AbsoluteContentSize.Y + 8)
end

Section.AddItem = function(self, name, data)
	local Class = Classes[name]
	
	local Item = Class.New(data)
	Item.Object.Parent = self.Container
	
	self:UpdateSize()
end

return Library