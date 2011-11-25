local lines = {
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
StarTip:EstablishLines(lines)

local bars = {
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
		height = 6,
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
		height = 6,
		length = 0,
		alpha = 0,
		enabled = true,
		update = 1,
		layer = 1,
		level = 100,
		points = {{"BOTTOMLEFT", "TOPLEFT", 0, -10-3}, {"BOTTOMRIGHT", "TOPRIGHT", 0, -10-3}}
	}
}
StarTip:EstablishBars(bars)

local borders = {
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
StarTip:EstablishBorders(borders)
