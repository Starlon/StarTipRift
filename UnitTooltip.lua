local addon, ns = ...
local StarTip = ns.StarTip
local mod = StarTip:NewModule("UnitTooltip")
local WidgetText = LibStub("LibScriptableWidgetText-1.0")
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0")

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

onMouseover = {
	code = [[
ResetDPS(unit)
]]
},

lines = ns.custom_UT_profile or {
    [1] = {
		id = "unitname",
        name = "UnitName",
        left = [[
local name = UnitName(unit)
if not name then return end
name = name .. (UnitPVP(unit) and "<PVP>" or "")
local afk = UnitAFK(unit)
local afk_time = UnitAFKTime(unit)
local afk_fmt = afk and (afk_time and Angle('AFK: ' .. FormatDuration(afk_time)) or Angle('AFK')) or ''
local offline = UnitOffline(unit)
local offline_time = UnitOfflineTime(unit)
local offline_fmt = offline and (offline_time and Angle('Offline: ' .. FormatDuration(offline_time)) or Angle('Offline')) or ""
if name then
	return name .. afk_fmt .. offline_fmt
end
]],
        colorLeft = [[
return UnitRelationColor(unit)
]],
        enabled = true,
		update = 1000,
		leftUpdating = true,
		fontSize = 15
    },
	[2] = {
		id = "target",
		name = "Target",
		left = "return 'Target:'",
		right = [[
local pvp = UnitPVP(unit .. ".target") and "++" or ""
local name = UnitName(unit..".target")
return  name and (name .. pvp) or "None"
]],
		colorRight = [[
if not UnitName(unit..".target") then return 1, 1, 1, 1 end
return UnitRelationColor(unit..'.target')
]],
		rightUpdating = true,
		update = 500,
		--alignRight = WidgetText.ALIGN_RIGHT,
		enabled = true,
	},
	[3] = {
		id = "guild",
		name = "Guild/Title",
		left = "return UnitPlayer(unit) and 'Guild:' or 'Title:'",
		right = [[
if UnitPlayer(unit) then
	local guild = UnitGuild(unit)
	return guild and Angle(guild)
else
	local title = UnitNameSecondary(unit)
	return title and Angle(title)
end
]],
		enabled = true
	},
	[4] = {
		id = "level",
		name = "Level",
		left = "return 'Level:'",
		right = "return UnitLevel(unit)",
		colorRight = "return DifficultyColor(unit)",
		enabled = true
	},
	[5] = {
		id = "calling",
		name = "Calling",

		left = [[
return "Calling:"
]],
		right = [[
return UnitCalling(unit)
]],
		
		enabled = true
	},
	[6] = {
		id = "role",
		name = "Role",
		left = "return 'Role:'",
		right = "return UnitRole(unit)",
		enabled = true
	},
	[7] = {
		id = "faction",
		name = "Faction",
		left ="return 'Faction:'",
		right = "return UnitFaction(unit)",
		enabled = true
	},
	[8] = {
		id = "relation",
		name = "Relation",
		left = "return 'Relation:'",
		right = "return UnitRelation(unit)",
		enabled = true	
	},
	[9] = {
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
	[10] = {
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
		rightUpdating = true,
		update = 200,
		cols = 15,
		enabled = true
	},
	[11] = {
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
		rightUpdating = true,
		update = 200,
		cols = 15,
		enabled = true
	},
	[12] = {
		id = "energy",
		name = "Energy",
		left = "return 'Energy:'",
		right = [[
return UnitEnergy(unit)
]],
		colorRight = [[
if not UnitEnergy(unit) then return end
return GradientMana(UnitEnergy(unit) / UnitEnergyMax(unit))
]],
		rightUpdating = true,
		update = 200,
		cols = 15,
		enabled = true
	},	
	[13] = {
		id = "guaranteedloot",
		name = "Guaranteed Loot",
		left = "return UnitGuaranteedLoot(unit) and Angle('This NPC is guaranteed to drop loot.')",
		enabled = true
	},	
	[14] = {
		id = "loot",
		name = "Loot",
		left = "return 'Loot:'",
		right = [[
local loot = UnitLoot(unit)
if loot then return UnitName(loot) end
]],
		enabled = true
	},
	[15] = {
		id = "mark",
		name = "Mark",
		left = "return 'Mark:'",
		right = "return UnitMark(unit)",
		enabled = true
	},
	[16] = {
		id = "race",
		name = "Race",
		left = "return 'Race:'",
		right = "return UnitRace(unit)",
		enabled = true
	},
	[17] = {
		id = "location",
		name = "Location",
		left = "return 'Location:'",
		right = "return UnitLocation(unit)",
		enabled = true
	},
	[18] = {
		id = 'tag',
		name = "Tag",
		left = [[
return UnitTagText(unit)
]],
		enabled = true
	},
	[19] = {
		id = "publicsize",
		name = "Public Size",
		left = "local pg = UnitPublicSize(unit); if pg then return 'Public Group (' ..pg..')'; end ",
		enabled = true

	},
	[20] = {
		id = "dps",
		name = "DPS",
		left = "return 'DPS:'",
		right = "return UnitDPS(unit) or '---'",
		enabled = true,
		rightUpdating = true,
		update = 200
	}

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
			if widget.cell and widget.buffer ~= "" then
				widget.cell:SetFontSize(widget.fontSize or 12)
				widget.cell:SetText(widget.buffer)
			end

			if widget.color.is_valid and widget.buffer ~= "" then
				widget.color:Eval()
				local r, g, b, a = widget.color:P2N()
				widget.cell:SetFontColor(r or 0, g or 0, b or 0, a or 1)
			end
		end

		wipe(widgetsToDraw)
		StarTip.tooltipMain:Reshape()
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
            mod.core.environment.unit = "player"
            llines[j].leftObj = v.left and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":left:", copy(v), 0, 0, v.layer or 0, StarTip.errorLevel, widgetUpdate)

			v.align = v.alignRight
            v.value = v.right
            v.outlined = v.rightOutlined
            v.update = 0
            if v.right and v.rightUpdating then v.update = update end
            v.color = v.colorRight
            v.maxWidth = v.maxWidthR
            v.minWidth = v.minWidthR
			mod.core.environment.unit = "player"
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

function mod:EstablishLines(data)
	if type(data) ~= "table" then return end
	config.lines = {}
	for i, v in pairs(data) do
		config.lines[i] = v
	end
	lines = {}
	self:CreateLines()
	
end

function mod:OnStartup()
	lines = {}
	self:CreateLines()
end

function mod:OnHide()
	self:StopLines()
end

function mod:SetUnit()
	if not self.core.environment.UnitName("mouseover") then return end
	Evaluator.Evaluate(self.core.environment, "onMouseover", config.onMouseover.code, "mouseover")
	self:StopLines()
	lines()
end
