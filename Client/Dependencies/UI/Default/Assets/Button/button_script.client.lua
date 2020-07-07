local ts = game:GetService("TweenService")

local button = script.Parent
local icon = button.icon
local text = button.title


button.MouseButton1Down:Connect(function()
	ts:Create(icon, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(35, 35, 35)}):Play()
	ts:Create(text, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(35, 35, 35)}):Play()
	ts:Create(button, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
end)

button.MouseButton1Up:Connect(function()
	ts:Create(icon, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
	ts:Create(text, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	ts:Create(button, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(35, 35, 35)}):Play()
end)

button.MouseLeave:Connect(function()
	ts:Create(icon, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
	ts:Create(text, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	ts:Create(button, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(35, 35, 35)}):Play()
end)