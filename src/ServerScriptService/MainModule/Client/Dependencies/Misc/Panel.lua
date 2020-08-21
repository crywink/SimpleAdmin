Service, UI, Client, Misc = nil, nil, nil, nil

--[[
	SimpleAdmin | Panel Handler
		- this script is probably gonna be kinda hacky cus i want to implement
		  the UI library into it. wish me luck.. :(
--]]

return function()
	local Player = Service.Players.LocalPlayer
	local IsVIP = Service.MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 10668450)
	local Panel = script:WaitForChild("Panel")
	local MainHolder = Panel:WaitForChild("Panel"):WaitForChild("Section_Holder"):WaitForChild("Holder")
	local Tabs = MainHolder:WaitForChild("Tabs"):WaitForChild("Holder")
	local AboutPage = MainHolder:WaitForChild("About")
	local VIPButton = MainHolder:WaitForChild("VIPButton")
	local VIPDescription = MainHolder:WaitForChild("VIPDesc")
	local CreditsPage = MainHolder:WaitForChild("Credits")
	local DonorSettings = MainHolder:WaitForChild("DonorSettings")
	
	Panel.Panel.Bar.Title.close_button.MouseButton1Click:Connect(function()
		Panel.Enabled = false
	end)
	
	local function HideAll()
		AboutPage.Visible = false
		VIPButton.Visible = false
		VIPDescription.Visible = false
		CreditsPage.Visible = false
		DonorSettings.Visible = false	
	end
	
	HideAll()
	AboutPage.Visible = true
	
	UI.Classes.Button.New({
		Text = "About";
		Function = function()
			HideAll()
			AboutPage.Visible = true
		end;
		Parent = Tabs;
	})
	UI.Classes.Button.New({
		Text = "Credits";
		Function = function()
			HideAll()
			CreditsPage.Visible = true
		end;
		Parent = Tabs;
	})
	UI.Classes.Button.New({
		Text = "Donate";
		Function = function()
			if not IsVIP then
				HideAll()
				VIPButton.Visible = true
				VIPDescription.Visible = true
			else
				HideAll()
				DonorSettings.Visible = true
			end
		end;
		Parent = Tabs;
	})
	UI.Classes.Text.New({
		Text = "Donator Settings";
		TextXAlignment = Enum.TextXAlignment.Center;
		Parent = DonorSettings.Holder;
		ImageTransparency = 1;
	})
	UI.Classes.Button.New({
		Text = "Cape Settings";
		Function = function()
			Misc.CapeSettings.Create()
		end;
		Parent = DonorSettings.Holder;
	})
	
	VIPButton.Holder.Button.MouseButton1Click:Connect(function()
		Service.MarketplaceService:PromptGamePassPurchase(Player, 10668450)
	end)
	
	Service.MakeDraggable(Panel.Panel)
	Client.Panel = Panel
	Panel.Parent = Player.PlayerGui
end