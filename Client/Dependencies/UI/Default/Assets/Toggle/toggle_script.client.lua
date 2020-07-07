local ts = game:GetService("TweenService")

local toggle = script.Parent
local checkmark = toggle.Back.Checkmark

local tog = false

toggle.MouseButton1Click:Connect(function()
	tog = not tog
	if tog then
		ts:Create(checkmark, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
	else
		ts:Create(checkmark, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
	end
end)