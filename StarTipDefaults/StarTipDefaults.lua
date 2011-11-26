
local addon, profile = ...

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
return RelationColor(unit)
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
return RelationColor(unit..'.target')
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
	},
	[21] = {
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
		height = 3,
		length = 0,
		enabled = true,
		update = 1,
		layer = 1, 
		level = 100,
		points = {{"BOTTOMLEFT", "TOPLEFT", 0, -3}, {"BOTTOMRIGHT", "TOPRIGHT", 0, -3}}
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
local energy = UnitEnergyMax(unit)
local max = mana or (power and 100) or energy
return max
]],
		color1 = [[
if not UnitMana(unit) and not UnitPower(unit) and not UnitEnergy(unit) then return 0, 0, 0 end
local mana = UnitMana(unit) or UnitPower(unit) or UnitEnergy(unit) or 0
local max = UnitManaMax(unit) or (UnitPower(unit) and 100) or (UnitEnergyMax(unit))
return Gradient(mana / max, unit)
]],
		height = 3,
		length = 0,
		enabled = true,
		update = 1,
		layer = 1, 
		level = 100,
		points = {{"TOPLEFT", "BOTTOMLEFT", 0, 3}, {"TOPRIGHT", "BOTTOMRIGHT", 0, 3}}
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
		height = 3,
		length = 0,
		alpha = 0,
		enabled = true,
		update = 1,
		layer = 1,
		level = 100,
		points = {{"BOTTOMLEFT", "TOPLEFT", 0, -10-3}, {"BOTTOMRIGHT", "TOPRIGHT", 0, -10-3}}
	}

}


profile.borders = {
	expression = [[
if UnitCalling(unit) then 
	return ClassColor(unit)
end
return RelationColor(unit)
]],
	update = 300,
	repeating = true
}

profile.backgrounds = {
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


profile.borderSize = 1

StarTip:InitializeProfile("Default", profile)
