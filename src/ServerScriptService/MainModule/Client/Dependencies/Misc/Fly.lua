Service, Misc = nil, nil;

--[[
	SimpleAdmin | Fly
		- This code is some real spaghetti REMIND ME TO REMAKE THIS
--]]

return function()
	local Player = Service.Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	local Camera = workspace.CurrentCamera
	
	local BodyGyroName = "SimpleAdmin_BodyGyro"
	local BodyVelocityName = "SimpleAdmin_BodyVelocity"
	local MaxSpeed = 50
	
	local IsKeyDown = function(...)
		return Service.UserInputService.IsKeyDown(Service.UserInputService, ...)
	end
	local clamp = math.clamp
	
	local Controls = {
		Front = 0;
		Back = 0;
		Left = 0;
		Right = 0;
		Down = 0;
		Up = 0;
	}
	
	local Keys = {
		[Enum.KeyCode.W] = function(t)
			Controls.Front = clamp(Controls.Front + (t and 1 or -1), 0, MaxSpeed)
		end;
		[Enum.KeyCode.A] = function(t)
			Controls.Left = clamp(Controls.Left + (t and -1 or 1), -MaxSpeed, 0)
		end;
		[Enum.KeyCode.S] = function(t)
			Controls.Back = clamp(Controls.Back + (t and -1 or 1), -MaxSpeed, 0)
		end;
		[Enum.KeyCode.D] = function(t)
			Controls.Right = clamp(Controls.Right + (t and 1 or -1), 0, MaxSpeed)
		end;
		[Enum.KeyCode.Space] = function(t)
			Controls.Up = clamp(Controls.Up + (t and 1 or -1), 0, MaxSpeed*2)
		end;
		[Enum.KeyCode.LeftControl] = function(t)
			Controls.Down = clamp(Controls.Down + (t and -1 or 1), -(MaxSpeed*2), 0)
		end;		
	}
	
	if not Character or not HumanoidRootPart or not Humanoid then
		return
	end
	
	if HumanoidRootPart:FindFirstChild(BodyGyroName) then
		HumanoidRootPart:FindFirstChild(BodyGyroName):Destroy()
	end
	
	if HumanoidRootPart:FindFirstChild(BodyVelocityName) then
		HumanoidRootPart:FindFirstChild(BodyVelocityName):Destroy()
	end

	local BodyGyro = Service.New("BodyGyro", {
		P = 9e4;
		MaxTorque = Vector3.new(9e9,9e9,9e9);
		CFrame = HumanoidRootPart.CFrame;
		Parent = HumanoidRootPart;
		Name = BodyGyroName;
	})
	local BodyVelocity = Service.New("BodyVelocity", {
		Velocity = Vector3.new(0, 0, 0);
		MaxForce = Vector3.new(9e9, 9e9, 9e9);
		Parent = HumanoidRootPart;	
		Name = BodyVelocityName;	
	})
	
	coroutine.wrap(function()
		Misc.FlySettings = {
			Enabled = true;
		}
		
		Misc.FlySettings.Connection = Service.RunService.Stepped:Connect(function()
			if not Player.Character or not Humanoid then
				Misc.FlySettings.Connection:Disconnect()
			end
			if not Misc.FlySettings.Enabled then
				return
			end
			
			Humanoid.PlatformStand = true
			
			for k,v in pairs(Keys) do
				v(IsKeyDown(k))
			end
			
			BodyGyro.CFrame = BodyGyro.CFrame:lerp(game.Workspace.CurrentCamera.CFrame, .095)
			BodyVelocity.Velocity = ((Camera.CFrame.LookVector * (Controls.Front + Controls.Back)) + (Camera.CFrame * CFrame.new(Controls.Left + Controls.Right, (Controls.Front + Controls.Back + Controls.Up + Controls.Down) * .2, 0).Position) - Camera.CFrame.Position)
		end)
	end)()
		
	Service.ContextActionService:BindAction("ToggleFly", function(Action, State, Object)
		if State == Enum.UserInputState.Begin then
			if not Misc.FlySettings.Enabled then
				BodyGyro.Parent, BodyVelocity.Parent = HumanoidRootPart, HumanoidRootPart
			else
				BodyGyro.Parent, BodyVelocity.Parent = nil, nil
				Humanoid.PlatformStand = false
			end
			Misc.FlySettings.Enabled = not Misc.FlySettings.Enabled
		end
	end, false, Enum.KeyCode.E)
	
	Misc.FlySettings.Disable = function()
		Misc.FlySettings.Connection:Disconnect()
		BodyGyro:Destroy()
		BodyVelocity:Destroy()
		Misc.FlySettings.Enabled = false
		Humanoid.PlatformStand = false
		Service.ContextActionService:UnbindAction("ToggleFly")
	end
	
	Humanoid.Died:Connect(function()
		Misc.FlySettings.Disable()
	end)
end