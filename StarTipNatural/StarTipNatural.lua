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
        enabled = true
    },

    [3] = {
        id = "info",
        name = "Info",
        left = [[
local lvl = UnitLevel(unit) or "??"
return "Level " .. lvl
]],
        right = [[
return (UnitRace(unit) or " ")
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
        id = 'tag',
        name = "Tag",
        left = [[
local class = UnitClass(unit)
local tags = UnitTagText(unit)
local details = Inspect.Unit.Detail(unit)
local txt = class
if tags then
    txt = (txt or "") .. tags
end
if details and details.health == 0 then
    txt = (txt or "") .. "<Corpse>"
end
return txt
]],
        colorLeft = [[
local details = Inspect.Unit.Detail(unit)
if details and details.calling then 
    return ClassColor(unit) 
end
return RelationColor(unit)
]],
    dontRtrim = true,
        enabled = true
    },
    [5] = {
        id = "target",
        name = "Target",
        left = "return 'Target:'",
        right = [[
local pvp = UnitPVP(unit .. ".target") and "++" or " "
local lvl = UnitLevel(unit .. ".target")
local class = UnitCalling(unit .. ".target")
local name = UnitName(unit..".target") or "None"
local txt = string.format("%s%s%s%s",  name, pvp, lvl and " ("..lvl..") " or "", class and " ("..class..")" or "")
return  txt
]],
        colorLeft = [[
if not UnitName(unit..".target") then return UnitRelationColor(unit) end
return UnitRelationColor(unit..'.target')
]],

        colorRight = [[
if not UnitName(unit..".target") then return 1, 1, 1, 1 end
return ClassColor(unit..'.target')
]],
        rightUpdating = true,
        update = 500,
        enabled = true,
    },
    [6] = {
        id = "location",
        name = "Location",
        left = "return UnitLocation(unit)",
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
    name = "Simple Meter DPS + DPS since mouseover",
left = [[
return SimpleMeter(unit, "dps", "all")
]],
    leftUpdating = true,
    update = 500,
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
        update = 300,
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
    repeating = true,
    borderSize = 3
}


profile.animation = {
    animationsOn = true,
    animationSpeed = 1000,
    animationInit = [[
gravity = true
t = 0
]],
    animationBegin = [[
t = t - 5
v = 0
]],
    animationPoint = [[
d=(v*0.3); r=t+i*PI*0.02; x=cos(r)*d; y=sin(r)*d
]]
}

StarTip:InitializeProfile("Natural", profile)

-- SimpleMeter(unit, mode, expand)
-- The number within brackets is recorded after mousing over the unit, so it may lag a little.
-- Friendly and hostile checks are performed internally. 
-- Provide 'mode' and 'expand'. 
-- mode: dps (dps), dmg (damage done), hps (healing per sec), heal (healing done), dtk (damage taken), htk(heals taken)
-- expand: all, self, top5

