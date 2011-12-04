local addon, ns = ...
local StarTip = ns.StarTip
local mod = ns.StarTip:NewModule("Background")

local backgrounds = {
	guild = "return BackgroundColor(unit)",
	hostilePC = "return BackgroundColor(unit)",
	hostileNPC = "return BackgroundColor(unit)",
	neutralNPC = "return BackgroundColor(unit)",
	friendlyPC = "return BackgroundColor(unit)",
	friendlyNPC = "return BackgroundColor(unit)",
	other = "return BackgroundColor(unit)",
	dead = "return BackgroundColor(unit)",
	tapped = "return BackgroundColor(unit)"
}

local update = function(details)

	local col = backgrounds.other
	if details.health == 0 then
		col = backgrounds.dead
	elseif details.player then
		local playerDetails = Inspect.Unit.Detail("player")
		local guild = playerDetails.guild
		if details.reaction == "hostile" then
			col = backgrounds.hostilePC
		elseif guild and guild == details.guild then
			col = backgrounds.guild
		else
			col = backgrounds.friendlyPC
		end
	else
		if details.reaction == "hostile" then
			col = backgrounds.hostileNPC
		elseif details.reaction then
			col = backgrounds.friendlyNPC
		else
			col = backgrounds.neutralNPC
		end
	end

	local r, g, b, a = StarTip.evaluator.Evaluate(StarTip.core.environment, "StarTip.Background", col, StarTip.unit)

	StarTip.tooltipMain.frame:SetBackgroundColor(r or 0, g or 0, b or 0, a or .5)
end

local timer = LibStub("LibScriptableUtilsTimer-1.0"):New("StarTip.Bars", 300, true, update) 

function mod:SetUnit(details, unit)
	update(details)
	timer:Start(300, details)
end

function mod:OnHide()
	timer:Stop()
end

function mod:Establish(tbl)
	backgrounds = tbl
end
