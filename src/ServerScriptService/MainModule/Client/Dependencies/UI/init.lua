--[[
	SimpleAdmin | UI
	- This script just requires the selected UI kit. If you would
	  like to edit the themes, look at the scripts parented to this one.
	- Edited for EngiAdurite's fork: Check all available themes, and if a theme has Active as true, use that.
	  If none are active, use the default theme.
	  ! Read the comment I included for information about a flaw with this.
--]]

for _,v in pairs(script:GetChildren()) do
	print(v.Name,v.Active.Value)
	if v.Active.Value == true then -- This method is flawed since it catches the first one which has Active as it's value. This mostly solves what happens if multiple themes are active at once, but there's no priority system or anything.
		return require(script:WaitForChild(v.Name))
	end
end

return require(script:WaitForChild("Default"))
