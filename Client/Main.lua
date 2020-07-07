Service, UI = nil, nil

--[[
	SimpleAdmin | Client
--]]

return function()
	local Player = Service.Players.LocalPlayer
	
	local Blind = Service.New("ScreenGui", {
		Parent = Player.PlayerGui;
		ResetOnSpawn = false;
		Enabled = false;
		IgnoreGuiInset = true;
	})
	local BlindFrame = Service.New("Frame", {
		Parent = Blind;
		Size = UDim2.new(1, 0, 1, 0);
		BackgroundColor3 = Color3.fromRGB(0,0,0)
	})
	
	UI.Blind = function(toggle)
		Blind.Enabled = toggle
	end
end