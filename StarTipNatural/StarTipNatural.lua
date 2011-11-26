local addon, profile = ...

local WidgetText = {}
WidgetText.ALIGN_LEFT, WidgetText.ALIGN_CENTER, WidgetText.ALIGN_RIGHT, WidgetText.ALIGN_MARQUEE, WidgetText.ALIGN_AUTOMATIC, WidgetText.ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6
WidgetText.SCROLL_RIGHT, WidgetText.SCROLL_LEFT = 1, 2

profile.lines = {
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
        id = "guild",
        name = "Guild/Title",
        left = [[
if UnitPlayer(unit) then
    local guild = UnitGuild(unit)
    return guild and Angle(guild)
else
    local title = UnitNameSecondary(unit)
    return title and Angle(title)
end
]],
        colorLeft = [[
return UnitRelationColor(unit)
]],
	alignLeft = WidgetText.ALIGN_PINGPONG,
	cols = 30,
        dontRtrim = true,
	leftUpdating = true,
	update = 100,
	speed = 100,
        enabled = true
    },

    [3] = {
        id = "info",
        name = "Info",
        left = [[
local lvl = UnitLevel(unit)
return lvl and ("Level " .. lvl)
]],
        right = [[
return (UnitRace(unit) or "")
]],
        colorLeft = [[
return DifficultyColor(unit)
]],
        colorRight = [[
return UnitRelationColor(unit)
]],
        enabled = true
    },
    [4] = {
        id = "target",
        name = "Target",
        left = "return 'Target:'",
        right = [[
local pvp = UnitPVP(unit .. ".target") and "++" or ""
local name = UnitName(unit..".target")
return  name and (name .. pvp) or "None"
]],
        colorLeft = [[
if not UnitName(unit..".target") then return UnitRelationColor(unit) end
return UnitRelationColor(unit..'.target')
]],

        colorRight = [[
if not UnitName(unit..".target") then return 1, 1, 1, 1 end
return UnitRelationColor(unit..'.target')
]],
        rightUpdating = true,
        update = 500,
        enabled = true,
    },
    [5] = {
        id = "location",
        name = "Location",
        left = "return UnitLocation(unit)",
        enabled = true
    },
    [6] = {
        id = 'tag',
        name = "Tag",
        left = [[
local txt = (UnitCalling(unit) or "") .. (UnitTagText(unit) or "")
if txt == "" then return nil end
return txt
]],
        colorLeft = [[
local details = Inspect.Unit.Detail(unit)
if details.calling then return ClassColor(unit) end
return RelationColor(unit)
]],
        enabled = true
    },
    [7] = {
        id = "group",
        name = "Group",
        left = [[
local size = UnitPublicSize(unit)
local members = size and (size == 1 and " member") or " members"

return size and "Public  Group: " .. size .. members
]],
        enabled = true
    },

   [8] = {
        id = "simplemeter",
	name = "Simple Meter",
	left = [[
-- Credits go to Jor. This comes from SimpleMeter's BuildCopyText method for encounters.
-- Friendly and hostile checks are performed internally. 
-- Provide 'mode' and 'expand'. 
-- 'mode' is the report requested. DPS, Damage done, healing done, damage taken, heal taken, and dps otherwise. 
-- And 'expand' is the list. 
-- 'self' points to the current encounter.
-- 'top5' looks at the top 5 units.
-- 'all' will look at everything.
-- mode: dps, dmg, hps, heal, dtk, htk
-- expand: all, self, top5
local mode, expand = "dps", "top5"

local SimpleMeter = _G.SimpleMeter
if SimpleMeter then
    local encounterIndex = SimpleMeter.state.encounterIndex
    local encounter = SimpleMeter.state.encounters[encounterIndex]
    local unitid = Inspect.Unit.Lookup(unit)
    local total, count = 0, 0
    local timeText,totalText, unitText = "", "", ""

    local function grab(side, mode, expand)
        local list, copyFrom = {}, {}
        if side == "ally" then
            copyFrom = encounter.allies
        else
            copyFrom = encounter.enemies
        end

        if #copyFrom == 0 then return "" end

        for _, v in pairs(copyFrom) do
            table.insert(list, v)
        end

        encounter:Sort(list, mode)

	local time = encounter:GetCombatTime()
        timeText = "Time: " .. SimpleMeter.Util.FormatTime(time)

        if side == "ally" then
            totalText = totalText .. " Ally"
        elseif side == "enemy" then
            totalText = totalText .. " Enemy"
        end
        totalText = totalText .. " " .. SimpleMeter.Modes[mode].desc .. ": "

        for _, id in pairs(list) do
            local unit = encounter.units[id]
            for k, v in pairs(encounter.units) do
                if k == unitid then
                    local v = 0
        	    if mode == "dps" then
                        v = unit.damage / time
                    elseif mode == "dmg" then
                        v = unit.damage
                    elseif v == "heal" then
                        v =  unit.heal / time
		    elseif v == "gtk" then
                        v = unit.damageTaken
                    elseif v == "htk" then
                        v = unit.healTaken
                    else
                        v = unit.damage / time
                    end
                    if (expand == "all" and v > 0)
                       or (expand == "top5" and count < 5)
                       or (expand == "self" and id == SimpleMeter.state.playerId) then
                            unitText = unitText .. "  " .. unit.name .. " :" .. SimpleMeter.Util.FormatNumber(v)
                            count = count + 1
                    end
                    total = total + v
		end
            end
	end

    end
    if encounter then
        local relation = UnitRelation(unit)
        if relation == "Friendly" then
            grab("ally", mode, expand)
        elseif relation == "Hostile" then
            grab("enemy", mode, expand)
        end

        local text = timeText .. totalText .. SimpleMeter.Util.FormatNumber(total) .. unitText
        if text ~= "0" then 
	    return text
	end
    end
    return "<SimpleMeter>"
end
]],
	leftUpdating = true,
	update = 200,
	enabled = true
    },
    [9] = {
        id = "space",
        name = "Space",
        left = "return ' '",
        dontRtrim = true,
        enabled = true
    }
}

profile.bars = {
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
        points = {{"TOPLEFT", "BOTTOMLEFT", 15, -15}, {"TOPRIGHT", "BOTTOMRIGHT", -15, -15}}
    },

}

profile.borders = {
    expression = [[
if UnitCalling(unit) then 
    local r, g, b = ClassColor(unit)
    return r, g, b, .5
end
local r, g, b = RelationColor(unit)
return r, g, b, .5
]],
    update = 300,
    repeating = true
}

profile.borderSize = 3

StarTip:InitializeProfile("StarTip Natural", profile)
