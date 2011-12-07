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
		animationsOn = false,
		animationSpeed = 1000,
		animationInit = [[
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
}

local animation
function mod:RunFrame()
	Evaluator.ExecuteCode(mod.environment, "StarTip.Position.animationBegin", animation.animationBegin)
end

function mod:OnStartup()
	self.db = StarTip.db:RegisterNamespace("Animation", defaults)
end

function mod:RunInit()
	animation = self.db.profile
	Evaluator.ExecuteCode(self.environment, "StarTip.Position.animationIni", animation.animationInit)
end

local random, floor = math.random, math.floor
function mod:RunPoint(x, y)
	local x, y = x or 0, y or 0
	if mod.db.profile.animationsOn then
		mod.environment.i = (mod.environment.i or 0) + 1
		mod.environment.v = (mod.environment.v or 0) +  random()
		Evaluator.ExecuteCode(mod.environment, "Position.animationPoint", animation.animationPoint)

		local xx, yy = mod.environment.x or 0, mod.environment.y or 0
	        x = x + floor((((xx or 0) + 1.0) * UIParent:GetWidth() / animation.animationSpeed))
        	y = y + floor((((yy or 0) + 1.0) * UIParent:GetHeight() / animation.animationSpeed))
	end
	return x, y
end

function mod:SetUnit()
	self:RunFrame()
end

function mod:Establish(animation)
	if not animation then return end
	self.db.profile.animationSpeed = animation.animationSpeed
	self.db.profile.animationInit = animation.animationInit
	self.db.profile.animationBegin = animation.animationBegin
	self.db.profile.animationPoint = animation.animationPoint
	self:RunInit()
end
