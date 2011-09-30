local addon, ns = ...

local StarTip = ns.StarTip
local mod = StarTip:NewModule("Background")

mod.bgColor = { -- Default colors from CowTip
			guild = {0, 0.15, 0, .6},
			hostilePC = {0.25, 0, 0, .6},
			hostileNPC = {0.15, 0, 0, .6},
			neutralNPC = {0.15, 0.15, 0, .6},
			friendlyPC = {0, 0, 0.25, .6},
			friendlyNPC = {0, 0, 0.15, .6},
			other = {0, 0, 0, .6},
			dead = {0.15, 0.15, 0.15, .6},
			tapped = {0.25, 0.25, 0.25, .6},
		}
local bgColor = mod.bgColor

function mod:SetUnit()
	local details = Inspect.Unit.Detail("mouseover")
	
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
	self.tooltipMain.frame:SetBackgroundColor(unpack(col))
end
