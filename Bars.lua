local StarTip = _G.StarTip
local mod = StarTip:NewModule("Bars")
local WidgetBar = LibStub("LibScriptableWidgetBar-1.0", true)
assert(WidgetBar, "Text module requires LibScriptableWidgetBar-1.0")

local widgets = {}
local copy = StarTip.copy

local config = {
	bars = {
	[1] = {
		name = "Health Bar",
		type = "bar",
		expression = [[
self.lastHealthBar = UnitHealth(unit)
return self.lastHealthBar or 0
]],
		min = "return 0",
		max = [[
self.lastHealthBarMax = UnitHealthMax(unit)
return self.lastHealthBarMax or 0
]],
		color1 = [[
if not UnitHealth(unit) then return 1, 1, 1 end
return GradientHealth(UnitHealth(unit) / UnitHealthMax(unit))
]],
		height = 6,
		length = 0,
		enabled = true,
		update = 1,
		layer = 1, 
		level = 100,
		points = {{"BOTTOMLEFT", "TOPLEFT"}, {"BOTTOMRIGHT", "TOPRIGHT"}}
	},
	[2] = {
		name = "Mana Bar",
		type = "bar",
		expression = [[
if not UnitMana(unit) and not UnitPower(unit) and not UnitEnergy(unit) then return 0, 0, 0 end
return UnitMana(unit) or UnitPower(unit) or UnitEnergy(unit) or 0
]],
		min = "return 0",
		max = [[
if not UnitMana(unit) and not UnitPower(unit) and not UnitEnergy(unit) then return 0, 0, 0 end
local mana = UnitManaMax(unit)
local power = UnitPower(unit)
local energy = UnitEnergy(unit)
if (energy or 0) > 100 then return 120 end
local max = mana or (power and 100) or (energy and 100)
return max
]],
		color1 = [[
if not UnitMana(unit) and not UnitPower(unit) and not UnitEnergy(unit) then return 0, 0, 0 end
local mana = UnitMana(unit) or UnitPower(unit) or UnitEnergy(unit) or 0
local max = UnitManaMax(unit) or (UnitPower(unit) and 100) or (UnitEnergy(unit) and 100)
return Gradient(mana / max, unit)
]],
		height = 6,
		length = 0,
		enabled = true,
		update = 1,
		layer = 1, 
		level = 100,
		points = {{"TOPLEFT", "BOTTOMLEFT"}, {"TOPRIGHT", "BOTTOMRIGHT"}}
	},
	[3] = {
		name = "Cast Bar",
		type = "bar",
		expression = [[
self.castText = UnitCastName(unit)
local perc = 1 - (UnitCastPercent(unit) or 1)
if perc <= 0.00001 then self.castText = false end
return perc
]],
		max = "return 1",
		min = "return 0",
		color1 = "return 1, 0, 1",
		height = 6,
		length = 0,
		alpha = 0,
		enabled = true,
		update = 1,
		layer = 1,
		level = 100,
		points = {{"BOTTOMLEFT", "TOPLEFT", 0, -10}, {"BOTTOMRIGHT", "TOPRIGHT", 0, -10}}
	}
	}
}

function updateBar(widget)
	if not mod.core.environment.UnitName("mouseover") then return end
	
	local bar = widget.bar
	
	bar.solid:SetPoint("RIGHT", bar, widget.val1, nil)
	
	local r, g, b = 0, 0, 1

	if widget.color1 then
		r, g, b = widget.color1.ret1, widget.color1.ret2, widget.color1.ret3
	end

	if type(r) == "number" then
		bar.solid:SetBackgroundColor(r, g, b)
	end
	
	if type(widget.castText) == "string" then
		bar.text:SetText(widget.castText)
		bar.text:SetWidth(bar:GetWidth())
	else
		bar.text:SetText("")
	end
	
end

function createBars()
	for k, v in ipairs(config.bars) do
		local bar = UI.CreateFrame("Frame", "Bar", mod.tooltipMain.frame)
		bar.solid = UI.CreateFrame("Frame", "Background", bar)
		bar:SetVisible(true)
		bar.solid:SetVisible(true)
		bar.solid:SetLayer(-1)
		bar:SetLayer(1)
		bar.solid:SetBackgroundColor(0, 0, 0, .5)
		bar:SetBackgroundColor(0, 0, 0, v.alpha or 0.3)
		-- Set the solid bar to fill the entire buff bar.
		bar.solid:SetPoint("TOPLEFT", bar, "TOPLEFT")
		bar.solid:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
		
		bar.text = UI.CreateFrame("Text", "Text", bar)
		bar.text:SetPoint("CENTER", bar, "CENTER")
    
		-- This is hardcoded, but in a full fleshed-out addon, it would be set by the user.
		-- This could be done now with slash commands, but couldn't be saved yet.

		bar:SetPoint(v.points[1][1], mod.tooltipMain.frame, v.points[1][2], v.points[1][3] or 0, v.points[1][4] or 0)
		bar:SetPoint(v.points[2][1], mod.tooltipMain.frame, v.points[2][2], v.points[2][3] or 0, v.points[1][4] or 0)
		
		bar:SetHeight(v.height)
		
		local widget = WidgetBar:New(mod.core, v.name, copy(v), v.row or 0, v.col or 0, v.layer or 1, mod.errorLevel or 2, updateBar)
		widget.bar = bar
		table.insert(widgets, widget)
	end
	
end

function startBars()
	for k, v in ipairs(widgets) do
		v:Start("mouseover")
	end
end

function mod:OnEnable()
	createBars()
end

function mod:SetUnit()
	startBars()
end


