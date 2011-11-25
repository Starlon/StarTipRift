local addon, ns = ...
ns.StarTip = DongleStub("Dongle-1.2"):New("StarTip")
_G.StarTip = ns.StarTip

local context = UI.CreateContext("StarTip")

local frame = UI.CreateFrame("Frame", "StarTipFrame", context)
local left = UI.CreateFrame("Texture", "StarTip-LeftBorder", frame)
local right = UI.CreateFrame("Texture", "StarTip-RightBorder", frame)
local top = UI.CreateFrame("Texture", "StarTip-TopBorder", frame)
local bottom = UI.CreateFrame("Texture", "StarTip-BottomBorder", frame)
local borderSize = 3
local borderColor = {0, 0, 0, 1}
local WidgetColor = LibStub("LibScriptableWidgetColor-1.0") 
tooltipMain = frame
tooltipMain.context = context
tooltipMain.lines = {}

StarTip.tooltipMain = tooltipMain

StarTip.errorLevel = 2

local LibCore = LibStub("LibScriptableLCDCoreLite-1.0")
StarTip.evaluator = LibStub("LibScriptableUtilsEvaluator-1.0")
local LibFlash = LibStub("LibFlash")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")

local modules = {}
local addons = {}
local queue = {}

if FooBar then
	local mod = FooBarModule:new(FooBar.getFoobar(), "StarTipFooBar")
	mod:setText("StarTip")
	mod:registerEvent("LeftClick", function() StarTip:OpenConfig() end)
	StarTip.foobar = mod
end

local environment = {}
local core = LibCore:New(environment, "StarTip", 2)
StarTip.core = core

local borders = {
	expression = [[
GetTime = GetTime or Inspect.Time.Frame
return .5, .7, .6
]],
	update = 300,
	repeating = true,
}

local bordersWidget
bordersWidget = WidgetColor:New(core, "Borders", borders, StarTip.errorLevel, function()
	left:SetBackgroundColor(bordersWidget.r, bordersWidget.g, bordersWidget.b, bordersWidget.a)
	right:SetBackgroundColor(bordersWidget.r, bordersWidget.g, bordersWidget.b, bordersWidget.a)
	top:SetBackgroundColor(bordersWidget.r, bordersWidget.g, bordersWidget.b, bordersWidget.a)
	bottom:SetBackgroundColor(bordersWidget.r, bordersWidget.g, bordersWidget.b, bordersWidget.a)
end)

local defaults = {
	profile = {
		mouse = true,
		x = 10,
		y = 10,
		addon = "Default"
	}
}
local config

local function svsave()
end

local function svload()
end

table.insert(Event.Addon.SavedVariables.Save.Begin, {function () svsave() end, "StarTip", "Save variables"})
table.insert(Event.Addon.SavedVariables.Load.Begin, {function () svload() end, "StarTip", "Load variables"})



frame.flash = LibFlash:New(frame)
tooltipMain.frame = frame
frame:SetBackgroundColor(0, 0, 0, .8)
frame:SetHeight(1)
frame:SetWidth(1)

local tremove, tinsert = table.remove, table.insert
local select = select

function StarTip.copy(src, dst)
    if type(src) ~= "table" then return nil end
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            v = StarTip.copy(v)
        end
        dst[k] = v
    end
    return dst
end

local new, del
do
	local pool = {}
	function new(...)
		local tbl = tremove(pool) or {}
		for i = 1, select("#", ...) do
			tbl[i] = select(i, ...)
		end
		return tbl
	end
	
	function del(tbl)
		assert(tbl)
		tinsert(pool, tbl)
		for i = 1, #tbl do
			tremove(tbl)
		end
	end
end
local pool = {}
local function newCell(size)
	local cell = tremove(pool) or UI.CreateFrame("Text", "StarTipText", frame)
	cell:SetFontSize(size or 12)
	return cell
end

local function delCell(cell)
	cell:SetText("")
	cell:ResizeToText()
	cell:ClearAll()
	cell:SetFontColor(1, 1, 1, 1)
	tinsert(pool, 1, cell)
end

tooltipMain.AddLine = function(self, txt)
	local lineNum = self:NumLines()
	local cell = newCell(12)
	if lineNum == 0 then
		cell:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, 0)
		cell:SetFontSize(15)
	else
		local h = self.lines[lineNum][1]:GetHeight()
		cell:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, h * lineNum)
	end
	tinsert(self.lines, new(cell))
	cell:SetText(txt)
	cell:ResizeToText()
	return cell
end

tooltipMain.AddDoubleLine = function(self, txt1, txt2)
	local lineNum = self:NumLines()
	local line = self.lines[lineNum]
	local cell1 = newCell(12)
	local cell2 = newCell(12)
	if lineNum == 0 then
		cell1:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, 0)
		cell1:SetFontSize(15)
	else
		local h = line[1]:GetHeight()
		cell1:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, h * lineNum)
	end
	cell2:SetPoint("TOPLEFT", cell1, "TOPRIGHT")
	tinsert(self.lines, new(cell1, cell2))
	cell1:SetText(txt1)
	cell2:SetText(txt2)	
	cell1:ResizeToText()
	cell2:ResizeToText()
	return cell1, cell2
end

tooltipMain.Clear = function(self)
	for k, line in ipairs(self.lines) do
		delCell(line[1])
		if line[2] then delCell(line[2]) end
	end
	for i = 1, #self.lines do
		local line = table.remove(self.lines)
		del(line)
	end
end


tooltipMain.Reshape = function(self)
	local height, width = 0, 0
	for k, line in ipairs(self.lines) do
		local left = line[1];
		local right = line[2];
		left:ResizeToText()
		height = height + left:GetFullHeight()
		local w = left:GetFullWidth()
		if right then 
			right:ResizeToText()
			w = w + right:GetFullWidth()
		end
		if w > width then 
			width = w
		end
	end
	frame:SetWidth(width + 3)
	frame:SetHeight(height)
	top:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
	top:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
	top:SetHeight(borderSize)


	bottom:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
	bottom:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
	bottom:SetHeight(borderSize)
	
	left:SetPoint("TOPLEFT", frame, "TOPRIGHT", -borderSize, 0)
	left:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", borderSize, 0)
	left:SetWidth(borderSize)

	right:SetPoint("TOPRIGHT", frame, "TOPLEFT", -borderSize, 0)
	right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", borderSize, 0)
	right:SetWidth(borderSize)
end


tooltipMain.NumLines = function(self)
	return #self.lines
end

tooltipMain.Show = function(self)
	frame.flash:Stop()
	if frame.alpha then frame:SetAlpha(frame.alpha) end
	frame:SetVisible(true)
end

local function realHide() 
	frame:SetVisible(false)
	frame:SetAlpha(frame.alpha)
end

tooltipMain.FadeOut = function(self)
	frame.alpha = frame:GetAlpha()
	frame.flash:Fade(1, frame.alpha, 0, realHide)
end

tooltipMain.Hide = function(self)
	frame:SetVisible(false)
end

tooltipMain.Shown = function(self)
	return frame:GetVisible()
end

function StarTip:Ready(addon)
	return type(StarTip.db) == "table"
end

function StarTip:InitializeAddon(addon, data)
	addons[addon] = data
end

local loadedAddon
function StarTip:Finalize(addon)
	local data = addons[addon]
print(":" .. addon .. ":", data)
	if not data then return end
	loadedAddon = addon
	if data.lines then self:EstablishLines(data.lines) end
	if data.bars then self:EstablishBars(data.bars) end
	if data.borders then self:EstablishBorders(data.borders) end
	if data.background then self:EstablishBackground(data.background) end
	if data.animation then self:EstablishAnimation(data.animation) end
	if data.histograms then self:EstablishHistograms(data.histograms) end

end

function StarTip:EstablishLines(data)
	if type(data) ~= "table" then return end
	local mod = self:GetModule("UnitTooltip")
	for k, v in pairs(mod.widgets) do
		if v.cell then v.cell:SetVisible(false) end
		--v:Del()
	end
	mod:Establish(data)
end

function StarTip:EstablishBars(data)
	if type(data) ~= "table" then return end
	local mod = self:GetModule("Bars")
	for k, v in pairs(mod.bars) do
		if v.bar then v.bar:SetVisible(false) end
		--v:Del()
	end

	mod:Establish(data)
end

function StarTip:EstablishBorders(data)
	if type(data) ~= "table" then return end
	bordersWidget:Del()
	bordersWidget = WidgetColor:New(core, "Borders", data, StarTip.errorLevel, bordersWidget.draw)

end

function StarTip:EstablishBackground(data)
	if type(data) ~= "table" then return end
	local mod = self:GetModule("Background")
	if mod then mod:Establish(data) end
end

function StarTip:GetModule(name1) 
	for name2, mod in StarTip:IterateModules() do
		if name1 == name2 then
			return mod
		end
	end
end

local abs = math.abs
local function update()
	if not tooltipMain:Shown() then return end
	local mouse = Inspect.Mouse()
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local x, y = mouse.x - width / 2, mouse.y - height
	
	frame:ClearAll()
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
	local top = frame:GetTop() - 6
	local bottom = frame:GetBottom() + 6
	local left = frame:GetLeft()
	local right = frame:GetRight()
	local uiw = UIParent:GetWidth()
	local uih = UIParent:GetHeight()
	if top < 0 then y = y + abs(top) end
	if left < 0 then x = x + abs(left) end
	if bottom > uih then y = y - (bottom - uih) end
	if right > uiw then x = x - (right - uiw) end
	frame:ClearAll()
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
	tooltipMain:Reshape()
end


local function unitChanged(id)
	if id then
		local details = Inspect.Unit.Detail(id)
		for k, mod in StarTip:IterateModules() do
			if mod.SetUnit and details then mod:SetUnit(details, "mouseover") end
		end
		tooltipMain:Show()
		bordersWidget:Start()
	else
		tooltipMain:FadeOut()
		for k, mod in StarTip:IterateModules() do
			if mod.OnHide then mod:OnHide() end
		end
		bordersWidget:Stop()
	end
end

table.insert(Library.LibUnitChange.Register("mouseover"), {unitChanged, "StarTip", "Mouseover"})

local configDialog = UI.CreateFrame("RiftWindow", "Configuration", context)
configDialog:SetPoint("CENTER", UIParent, "CENTER")
configDialog:SetWidth(420)
configDialog:SetHeight(500)
configDialog:SetVisible(false)

local close = UI.CreateFrame("RiftButton", "Exit Button", configDialog)
close:SetPoint("TOPLEFT", configDialog, "TOPLEFT", 20, 50)
close:ResizeToDefault()
close:SetText("Close")
close.Event.LeftPress = function()
	configDialog:SetVisible(false)
end

local mouseLabel = UI.CreateFrame("Text", "Mouse label", configDialog)
mouseLabel:SetText("Position with Mouse")
mouseLabel:ResizeToText()
mouseLabel:SetPoint("TOPLEFT", close, "BOTTOMLEFT", 0, 15)

local mouse = UI.CreateFrame("RiftCheckbox", "Move mouse", configDialog)
mouse:ResizeToDefault()
mouse:SetPoint("TOPLEFT", mouseLabel, "TOPRIGHT", 10, 0)

local startPositionMouse = UI.CreateFrame("RiftButton", "Start position mouse", configDialog)
startPositionMouse:SetText("Position Tooltip")
startPositionMouse:ResizeToDefault()
startPositionMouse:SetPoint("TOPLEFT", mouse, "TOPRIGHT", 10, -10)

local closePositionMouse = UI.CreateFrame("RiftButton", "Move mouse close button", context)
closePositionMouse:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
closePositionMouse:SetVisible(false)
closePositionMouse:SetText("Close")

local moveMouseFrame = UI.CreateFrame("Frame", "Position tooltip here", closePositionMouse)
moveMouseFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", UIParent:GetWidth() / 2 - 40, UIParent:GetHeight() / 2 - 50)
moveMouseFrame:SetBackgroundColor(0, 0, 0, .8)
moveMouseFrame:SetWidth(80)
moveMouseFrame:SetHeight(100)
moveMouseFrame:SetMouseMasking("full")

local moveMouseLabel = UI.CreateFrame("Text", "Position tooltip here label", moveMouseFrame)
moveMouseLabel:SetPoint("CENTER", moveMouseFrame, "CENTER")
moveMouseLabel:SetText("Move me")
moveMouseLabel:ResizeToText()

local repositionNow
local moveTbl = {function()
	local mouse = Inspect.Mouse()
	moveMouseFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouse.x - 40 , mouse.y - 80)
end, "StarTip", "refresh"}

moveMouseFrame.Event.LeftDown = function()
	if not repositionNow then
		table.insert(Event.System.Update.Begin, moveTbl)
		repositionNow = true
	end
end

moveMouseFrame.Event.LeftUp = function()
	if repositionNow then
		for i = #Event.System.Update.Begin, 1, -1 do
			local v = Event.System.Update.Begin[i]
			if v == moveTbl then			
				table.remove(Event.System.Update.Begin, i)
			end
		end
		local left = moveMouseFrame:GetLeft()
		local top = moveMouseFrame:GetTop()
		config.x = left
		config.y = top
		tooltipMain.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
		repositionNow = false
	end
end

startPositionMouse.Event.LeftPress = function()
	closePositionMouse:SetVisible(true)
	moveMouseFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.x or (UIParent:GetWidth() / 2 - 40), config.y or (UIParent:GetHeight() / 2 - 50))
	configDialog:SetVisible(false)
end

closePositionMouse.Event.LeftPress = function()
	closePositionMouse:SetVisible(false)
	configDialog:SetVisible(true)
end

mouse.Event.CheckboxChange = function()
	if mouse:GetChecked() then
		config.mouse = true
		startPositionMouse:SetVisible(false)
		table.insert(Event.System.Update.Begin, {update, "StarTip", "Position Tooltip to Mouse"})
	else
		config.mouse = false
		startPositionMouse:SetVisible(true)
		for i = #Event.System.Update.Begin, 1, -1 do
			local v = Event.System.Update.Begin[i][1]
			if v == update then
				table.remove(Event.System.Update.Begin, i)
			end
		end
	end
end

function StarTip:OpenConfig()
	configDialog:SetVisible(true)
end

-- Startup

local function startup()
	for k, mod in StarTip:IterateModules() do
		if mod.OnStartup then
			mod:OnStartup()
		end
	end
	
end

table.insert(Event.Addon.Startup.End, {startup, "StarTip", "refresh"})

do
	local tableloaded
	local function playerLoaded(units)
		if tableLoaded then return end
		tableLoaded = true
		for k, v in pairs(units) do
			if v == "player" then
				StarTip_SavedVariables = StarTip_SavedVariables or {}
				StarTip.db = StarTip:InitializeDB(StarTip_SavedVariables, defaults)
				config = StarTip.db and StarTip.db.profile
	
				if not config then return end
				
				if config.mouse then
					table.insert(Event.Mouse.Move, {update, "StarTip", "refresh"})
				else
					frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.x or 10, config.y or 10)
					tooltipMain:Reshape()
				end	
				mouse:SetChecked(config.mouse)
				startPositionMouse:SetVisible(not config.mouse)			
print(StarTip.db.profile.addon)
				StarTip:Finalize(StarTip.db.profile.addon)
			end
		end
	end
	table.insert(Event.Unit.Available, {playerLoaded, "StarTip", "StarTip player loaded"})

end


table.insert(Command.Slash.Register("startip"), {function (commands)	
	if commands == "cpu" then
		StarTip:CPU()
	elseif commands:match("^config") then
		StarTip:OpenConfig()
	elseif commands:match("^reset") then
		StarTip.db:ResetDB()
	elseif commands:match("^profile ") then
		local len1 = string.len(commands)
		local len2 = string.len("profile ") + 1
		local cmd = string.sub(commands, len2, len1)
		print(cmd)
		StarTip:Finalize(cmd)
	else
		print("Commands are 'profile', 'config' and 'cpu'.")
		print("Loaded profile: " .. loadedAddon)
		print("Available Profiles:")
		for addon in pairs(addons) do
			print(">", addon)
		end
	end
end, "StarTip", "Slash command"})

function StarTip:CPU()
	local cpu = Inspect.Addon.Cpu()
	if cpu.StarTip then
		print("-------- StarTip CPU Usage --------")
		for k, v in pairs(cpu.StarTip) do
			print(k, ":", v)
		end
	end
end

