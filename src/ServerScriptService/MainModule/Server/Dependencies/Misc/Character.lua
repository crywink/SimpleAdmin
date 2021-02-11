Service, Shared, Environment = nil, nil, nil

--[[
	SimpleAdmin | Misc | Character
		- This will handle any character related stuff that
		  I might want to do multiple times.
--]]

local Character = {}

Character.Init = function()
	for k,v in pairs(Character) do
		if type(v) == "function" then
			Environment.Apply(v)
		end
	end
end

Character.Capeify = function(Player, Data)
	Player = type(Player) ~= "table" and Service.PlayerWrapper(Player) or Player
	if not Player.Character then
		return
	end
	
	local Humanoid = Player.Character:FindFirstChild("Humanoid")
	local Torso
	
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Torso = Player.Character:WaitForChild("UpperTorso")
	else
		Torso = Player.Character:WaitForChild("Torso")
	end
	
	if Torso:FindFirstChild("SimpleAdmin_Cape") then
		Torso:FindFirstChild("SimpleAdmin_Cape"):Destroy()
	end
	
	local Cape = Instance.new("Part")
	Cape.Parent = Torso
	Cape.CanCollide = false
	Cape.Size = Vector3.new(.1, 3.1, 1.6)
	Cape.Name = "SimpleAdmin_Cape"
	Cape.Material = Data.Material or Cape.Material
	Cape.Transparency = Data.Transparency or Cape.Transparency
	Cape.Color = Data.Color or Cape.Color
	Cape.Massless = true
	
	local Motor = Instance.new("Motor")
	Motor.Parent = Cape
	Motor.Part0 = Torso
	Motor.Part1 = Cape
	Motor.C0 = CFrame.new(0, 1, .44) * CFrame.Angles(0,math.rad(90),math.rad(-8))
	Motor.C1 = Motor.C1 - Vector3.new(0, -2, 0)	
	Motor.MaxVelocity = .05
	
	if Data.Image then
		local Decal = Instance.new("Decal")
		Decal.Parent = Cape
		Decal.Face = Enum.NormalId.Left
		Decal.Texture = "rbxassetid://" .. Data.Image
	end
	
	return Cape
end

Character.SetTransparency = function(plr, Transparency, DecalTransparency)
	local Character = plr.Character
	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = Transparency
		elseif v:IsA("Decal") then
			v.Transparency = DecalTransparency or Transparency
		end
	end
end

return Character