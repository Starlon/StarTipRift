local StarTip = _G.StarTip
local mod = StarTip:NewModule("UnitTooltip")
local WidgetText = LibStub("LibScriptableWidgetText-1.0", true)
assert(WidgetText, "Text module requires LibScriptableWidgetText-1.0")
--local LCDText = LibStub("LibScriptableLCDText-1.0", true)
--assert(LCDText, mod.name .. " requires LibScriptableLCDText-1.0")
--local LibCore = LibStub("LibScriptableLCDCore-1.0", true)
--assert(LibCore, mod.name .. " requires LibScriptableLCDCore-1.0")
--local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
--assert(LibTimer, mod.name .. " requires LibScriptableUtilsTimer-1.0")

local tinsert = table.insert
local tremove = table.remove

local function copy(src, dst)
    if type(src) ~= "table" then return nil end
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            v = copy(v)
        end
        dst[k] = v
    end
    return dst
end

local lines = {}
local config = {
lines = {
    [1] = {
		id = "unitname",
        name = "UnitName",
        left = [[
return "- " .. UnitName(unit) .. " -"
]],
        right = nil,
        enabled = true,
		fontSize = 15
    },
	[2] = {
		id = "target",
		name = "Target",
		left = "return 'Target:'",
		right = [[
local pvp = UnitPVP(unit .. ".target") and " (PVP)" or ""
local name = UnitName(unit..".target")
return  name and (name .. pvp) or "None"
]],
		rightUpdating = true,
		update = 500,
		--alignRight = WidgetText.ALIGN_RIGHT,
		enabled = true,
	},
	[3] = {
		id = "level",
		name = "Level",
		left = "return 'Level:'",
		right = "return UnitLevel(unit)",
		--alignRight = WidgetText.ALIGN_RIGHT,
		enabled = true
	},
	[4] = {
		id = "flags",
		name = "Flags",
		left = "return 'Flags:'",
		right = [[
local afk = UnitAFK(unit) and Angle('AFK') or ""
local offline = UnitOffline(unit) and Angle('Offline') or ""
local pvp = UnitPVP(unit) and Angle('PVP') or ""
local npc = (not UnitPlayer(unit)) and Angle('NPC') or ""
local ret = (afk or offline or pvp or npc) and (afk .. offline .. pvp .. npc)
return ret ~= "" and ret
]],
		enabled = true
	},
	[5] = {
		id = "guild",
		name = "Guild",
		left = "return 'Guild:'",
		right = [[
local guild = UnitGuild(unit)
local guild2 = UnitNameSecondary(unit)
guild2 = guild2 and Angle(guild2)
return guild or guild2
]],
		enabled = true
	},
	[6] = {
		id = "calling",
		name = "Calling",
		left = "return 'Calling:'",
		right = "return UnitCalling(unit)",
		--alignRight = WidgetText.ALIGN_RIGHT,
		enabled = true
	},
	[7] = {
		id = "role",
		name = "Role",
		left = "return 'Role:'",
		right = "return UnitRole(unit)",
		enabled = true
	},
	[7] = {
		id = "relation",
		name = "Relation",
		left = "return 'Relation:'",
		right = "return UnitRelation(unit)",
		--alignRight = WidgetText.ALIGN_RIGHT,
		enabled = true	
	},
	[8] = {
		id = "health",
		name = "Health",
		left = "return 'Health:'",
		right = [[
if not UnitHealth(unit) then return end
return Short(UnitHealth(unit), true) .. '/' .. Short(UnitHealthMax(unit), true)
]],
		colorRight = [[
if not UnitHealth(unit) then return end
return GradientHealth(UnitHealth(unit) / UnitHealthMax(unit))	
]],
		rightUpdating = true,
		update = 200,
		cols = 15,
		enabled = true
	},
	[9] = {
		id = "mana",
		name = "Mana",
		left = "return 'Mana:'",
		right = [[
if not UnitMana(unit) then return end
return Short(UnitMana(unit), true) .. '/' .. Short(UnitManaMax(unit), true)
]],
		colorRight = [[
if not UnitMana(unit) then return end
return GradientMana(UnitMana(unit) / UnitManaMax(unit))
]],
		rightUpdate = true,
		update = 200,
		cols = 15,
		enabled = true
	},
	[10] = {
		id = "power",
		name = "Power",
		left = "return 'Power:'",
		right = [[
return UnitPower(unit)
]],
		colorRight = [[
if not UnitPower(unit) then return end
return GradientMana(UnitPower(unit) / 100)
]],
		cols = 15,
		enabled = true
	},
	[11] = {
		id = "energy",
		name = "Energy",
		left = "return 'Energy:'",
		right = [[
return UnitEnergy(unit)
]],
		colorRight = [[
if not UnitEnergy(unit) then return end
return GradientMana(UnitEnergy(unit) / 100)
]],
		cols = 15,
		enabled = true
	},	
	[12] = {
		id = "guaranteedloot",
		name = "Guaranteed Loot",
		left = "return UnitGuaranteedLoot(unit) and Angle('This NPC is guaranteed to drop loot.')",
		enabled = true
	},	
	[13] = {
		id = "loot",
		name = "Loot",
		left = "return 'Loot:'",
		right = [[
local loot = UnitLoot(unit)
if loot then return UnitName(loot) end
]],
		enabled = true
	},
	[14] = {
		id = "mark",
		name = "Mark",
		left = "return 'Mark:'",
		right = "return UnitMark(unit)",
		enabled = true
	},

}
}

local function wipe(tbl)
	for i = 1, #tbl do
		tremove(tbl)
	end
end

local widgetUpdate
do
    local widgetsToDraw = {}
    function widgetUpdate(widget)
		tinsert(widgetsToDraw, widget)
		draw(true)
    end
    function draw()
        for i, widget in ipairs(widgetsToDraw) do
			if widget.cell then
				widget.cell:SetText(widget.buffer)
				widget.cell:SetFontSize(widget.fontSize or 12)
			end

			if widget.color.is_valid then
				widget.color:Eval()
				local r, g, b, a = widget.color:P2N()
				widget.cell:SetFontColor(r, g, b, a or 1)
			end
		end

		wipe(widgetsToDraw)
		StarTip.tooltipMain:Reshape(12, 12)
    end
end

function mod:StopLines()
    for k, v in pairs(lines) do
        if v.leftObj then
            v.leftObj:Stop()
        end
        if v.rightObj then
            v.rightObj:Stop()
        end
    end

end

function mod:ClearLines()
	self:StopLines()
	StarTip.tooltipMain:Clear()
	for k, v in ipairs(lines) do
		v:Del()
	end
	wipe(lines)
end

local tbl
function mod:CreateLines()
    local llines = {}
    local j = 0
    for i, v in ipairs(config.lines) do
        if not v.deleted and v.enabled and v.left then
            v = copy(v)
            j = j + 1
            llines[j] = copy(v)
            llines[j].config = copy(v)
			
			v.align = v.alignLeft
            v.value = v.left
            v.outlined = v.leftOutlined
            v.color = v.colorLeft
            v.maxWidth = v.maxWidthL
            v.minWidth = v.minWidthL
            local update = v.update or 0
            v.update = 0
            if v.left and v.leftUpdating then v.update = update end
            mod.core.environment.unit = "mouseover"
            llines[j].leftObj = v.left and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":left:", copy(v), 0, 0, v.layer or 0, StarTip.errorLevel, widgetUpdate)

			v.align = v.alignRight
            v.value = v.right
            v.outlined = v.rightOutlined
            v.update = 0
            if v.right and v.rightUpdating then v.update = update end
            v.color = v.colorRight
            v.maxWidth = v.maxWidthR
            v.minWidth = v.minWidthR
			mod.core.environment.unit = "mouseover"
            llines[j].rightObj = v.right and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":right:", copy(v), 0, 0, v.layer or 0, StarTip.errorLevel, widgetUpdate)
			
        end
    end
    self:ClearLines()
    lines = setmetatable(llines, {__call=function(self)
            local lineNum = 0
            StarTip.tooltipMain:Clear()
            for i, v in ipairs(self) do
                if v.leftObj then
                    v.leftObj.cell = nil
					v.leftObj.buffer = false
                end
                if v.rightObj then
                    v.rightObj.cell = nil
					v.rightObj.buffer = false
                end
                local left, right = '', ''
                mod.core.environment.unit = "mouseover"
                if v.right then
                    if v.rightObj then
                        mod.core.environment.self = v.rightObj
                        right = mod.evaluator.ExecuteCode(mod.core.environment, v.name .. " right", v.right)
                        if type(right) == "number" then right = right .. "" end
                    end
                    if v.leftObj then
                        mod.core.environment.self = v.leftObj
                        left = mod.evaluator.ExecuteCode(mod.core.environment, v.name .. " left", v.left)
                        if type(left) == "number" then left = left .. "" end
                    end
                else
                    if v.leftObj then
                        mod.core.environment.self = v.leftObj
                        left = mod.evaluator.ExecuteCode(mod.core.environment, v.name .. " left", v.left)
                        if type(left) == "number" then left = left .. "" end
                    end
                    right = ''
                end
                
                if type(left) == "string" and type(right) == "string" then
                    lineNum = lineNum + 1
                    if v.right and v.right ~= "" then
                        local cell1, cell2 = StarTip.tooltipMain:AddDoubleLine('-', '-')
						v.leftObj.cell = cell1
						v.rightObj.cell = cell2
                    else
                        local cell = StarTip.tooltipMain:AddLine('-')
						v.leftObj.cell = cell
                    end
                    if v.rightObj then
						v.rightObj.buffer = false
                        v.rightObj:Start("mouseover")
                    end
                    if v.leftObj then
						v.leftObj.buffer = false
                        v.leftObj:Start("mouseover")
                    end
                    v.lineNum = lineNum
                end
            end
    end})
end

function mod:OnEnable()
	self:CreateLines()
end

function mod:OnHide()
	self:StopLines()
end

function mod:SetUnit()
	StarTip.tooltipMain:Hide()
	self:StopLines()
	lines()
	StarTip.tooltipMain:Show()
end
