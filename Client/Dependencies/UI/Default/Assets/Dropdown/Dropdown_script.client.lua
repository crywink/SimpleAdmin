local dropdown = script.Parent
local arrow = dropdown.arrow

local dropframe = dropdown.Parent.Dropframe
local droplist = dropframe.Holder.list

local Holder = dropdown.Parent.Parent

local tog = false

local ts = game:GetService("TweenService")

dropdown.MouseButton1Click:Connect(function()
	tog = not tog;
	if tog then
		ts:Create(dropframe, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, droplist.AbsoluteContentSize.Y + 8)}):Play();
		ts:Create(Holder, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, 35 + droplist.AbsoluteContentSize.Y + 8)}):Play();
		ts:Create(arrow, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Rotation = -180}):Play();
		dropframe.Visible = true;
	else
		ts:Create(dropframe, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(1,0,0,0)}):Play();
		ts:Create(Holder, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(1,0,0, 24 + 8)}):Play();
		ts:Create(arrow, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Rotation = 0}):Play();
		wait(0.15)
		dropframe.Visible = false;
	end;
end)