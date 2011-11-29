local addon, ns = ...
local StarTip = ns.StarTip
local mod = StarTip:NewModule("Animation")
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0")
local Timer = LibStub("LibScriptableUtilsTimer-1.0")
local LibCore = LibStub("LibScriptableLCDCoreLite-1.0")

mod.environment = {}
mod.core = LibCore:New(mod.environment, "Animation")

local defaults = {
	profile = {
		animationsOn = true,
		animationInit = [[
t = 0
]],
		animationFrame = [[
t = t - 5
v = 0
]],
		animationPoint = [[
d=(v*0.3); r=t+i*PI*0.02; x=cos(r)*d; y=sin(r)*d
]]
	}
}

function mod:RunFrame()
	Evaluator.ExecuteCode(mod.environment, "StarTip.Position.animationFrame", self.db.profile.animationFrame)
end

function mod:RunInit()
	self.db = StarTip.db:RegisterNamespace("Animation", defaults)
	Evaluator.ExecuteCode(self.environment, "StarTip.Position.animationInit", mod.db.profile.animationInit)
end

local random, floor = math.random, math.floor
function mod:RunPoint(x, y)
	local x, y = x or 0, y or 0
	if mod.db.profile.animationsOn then
		mod.environment.i = (mod.environment.i or 0) + 1
		mod.environment.v = (mod.environment.v or 0) +  random()
		Evaluator.ExecuteCode(mod.environment, "Position.animationPoint", mod.db.profile.animationPoint)

		local xx, yy = mod.environment.x or 0, mod.environment.y or 0
	        x = x + floor((((xx or 0) + 1.0) * UIParent:GetWidth() / 100))
        	y = y + floor((((yy or 0) + 1.0) * UIParent:GetHeight() / 100))
	end
	return x, y
end

function mod:SetUnit()
	self:RunFrame()
end

