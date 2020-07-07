local player = game:GetService("Players").LocalPlayer;
local mouse = player:GetMouse();
local rs = game:GetService("RunService");
local inputService = game:GetService("UserInputService");

local main = script.Parent.Parent;
local button = script.Parent;

local startPos = {};
local total = 0;

local down = false;

-- toggle !

button.MouseButton1Down:Connect(function()
	startPos.X = button.AbsoluteSize.X - (mouse.X - button.AbsolutePosition.X);
	startPos.Y = button.AbsoluteSize.Y - (mouse.Y - button.AbsolutePosition.Y);
	down = true;
end);

inputService.InputEnded:Connect(function(input)
  	if input.UserInputType == Enum.UserInputType.MouseButton1 then
    	down = false;
	end;
end);

function clamp(x, min, max)
  return x < min and min or x > max and max or x
end

rs.Stepped:Connect(function()
	if down then
		local X_main = clamp((mouse.X - main.AbsolutePosition.X) + startPos.X, 200, 260); -- locks X in 300 - 400
		local Y_main = clamp((mouse.Y - main.AbsolutePosition.Y) + startPos.Y, 240, 300); -- locks Y in 200 - 300
		
		main.Size = UDim2.new(0, X_main, 0, Y_main);
	end
end);