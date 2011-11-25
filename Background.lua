local addon, ns = ...
local StarTip = ns.StarTip
local mod = ns.StarTip:NewModule("Background")

mod.bgColor = { -- Default colors from CowTip
			guild = {0, 0.15, 0, .8},
			hostilePC = {0.25, 0, 0, .8},
			hostileNPC = {0.15, 0, 0, .8},
			neutralNPC = {0.15, 0.15, 0, .8},
			friendlyPC = {0, 0, 0.25, .8},
			friendlyNPC = {0, 0, 0.15, .8},
			other = {0, 0, 0, .8},
			dead = {0.15, 0.15, 0.15, .8},
			tapped = {0.25, 0.25, 0.25, .8},
		}
local bgColor = mod.bgColor

function mod:SetUnit(details)
	local col = bgColor.other
	
	if details.health == 0 then
		col = bgColor.dead
	elseif details.player then
		local playerDetails = Inspect.Unit.Detail("player")
		local guild = playerDetails.guild
		if details.reaction == "hostile" then
			col = bgColor.hostilePC
		elseif guild and guild == details.guild then
			col = bgColor.guild
		else
			col = bgColor.friendlyPC
		end
	else
		if details.reaction == "hostile" then
			col = bgColor.hostileNPC
		elseif details.reaction then
			col = bgColor.friendlyNPC
		else
			col = bgColor.neutralNPC
		end
	end
	StarTip.tooltipMain.frame:SetBackgroundColor(unpack(col))
end
