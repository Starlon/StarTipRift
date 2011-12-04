local addon, ns = ...
local StarTip = ns.StarTip
local mod = StarTip:NewModule("Bars")

local WidgetBar = LibStub("LibScriptableWidgetBar-1.0", true)
assert(WidgetBar, "Text module requires LibScriptableWidgetBar-1.0")

local widgets = {}
local copy = StarTip.copy

local config = {
	bars = {
	}
}

function updateBar(widget)
	if not StarTip.core.environment.UnitName(StarTip.unit) then return end
	
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
	if widgets then
		for k, v in pairs(widgets) do
			v:Del()
		end
	end
	widgets = {}
	for k, v in ipairs(config.bars) do
		local bar = UI.CreateFrame("Frame", "Bar", StarTip.tooltipMain.frame)
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
    
		bar:SetPoint(v.points[1][1], StarTip.tooltipMain.frame, v.points[1][2], v.points[1][3] or 0, v.points[1][4] or 0)
		bar:SetPoint(v.points[2][1], StarTip.tooltipMain.frame, v.points[2][2], v.points[2][3] or 0, v.points[1][4] or 0)
		
		bar:SetHeight(v.height)
		
		local widget = WidgetBar:New(StarTip.core, v.name, copy(v), v.row or 0, v.col or 0, v.layer or 1, mod.errorLevel or 2, updateBar)
		widget.bar = bar
		table.insert(widgets, widget)
	end
	mod.bars = widgets	
end

function startBars()
	for k, v in ipairs(widgets) do
		v:Start(StarTip.unit)
	end
end

function mod:OnStartup()
	createBars()
end

function mod:SetUnit(details)
	startBars()
end

function mod:Establish(data) 
	if type(data) ~= "table" then return end
	widgets = {}
	config.bars = data
	createBars()
end
