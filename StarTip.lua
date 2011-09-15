_G.StarTip = {tooltipMain = {lines={}}, modules={}, unit="mouseover", errorLevel=2}
local tooltipMain = _G.StarTip.tooltipMain

local LibCore = LibStub("LibScriptableLCDCoreLite-1.0")
local LibEvaluator = LibStub("LibScriptableUtilsEvaluator-1.0")
local LibFlash = LibStub("LibFlash")

local environment = {}
local core = LibCore:New(environment, "StarTip", 2)

local context = UI.CreateContext("StarTip")
tooltipMain.context = context
local frame = UI.CreateFrame("Frame", "StarTipFrame", context)
frame.flash = LibFlash:New(frame)
tooltipMain.frame = frame
frame:SetBackgroundColor(0, 0, 0, .5)
frame:SetHeight(500)
frame:SetWidth(600)
frame:SetPoint("CENTER", UIParent, "CENTER")

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

local pool = {}
local function new(...)
	local tbl = tremove(pool) or {}
	for i = 1, select("#", ...) do
		tbl[i] = select(i, ...)
	end
	return tbl
end

local function del(tbl)
	assert(tbl)
	tinsert(pool, tbl)
	for i = 1, #tbl do
		tremove(tbl)
	end
end

local pool = {}
local function newCell()
	local cell = select(2, tremove(pool)) or UI.CreateFrame("Text", "StarTipText" .. math.random() * 1000, frame)
	cell:ClearAll()
	cell:SetText(" ")
	return cell
end

local function delCell(cell)
	cell:ClearAll()
	cell:SetVisible(false)
	cell:SetText("")
	tinsert(pool, cell)
end

tooltipMain.AddLine = function(self, txt)
	local lineNum = self:NumLines() + 1
	local cell = newCell()
	if lineNum == 1 then
		cell:SetPoint("TOPLEFT", frame, "TOPLEFT")
		cell:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	else
		cell:SetPoint("TOPLEFT", self.lines[lineNum - 1][1], "BOTTOMLEFT")
		cell:SetPoint("TOPRIGHT", self.lines[lineNum - 1][1], "BOTTOMRIGHT")
	end
	tinsert(self.lines, new(cell))
	cell:SetText(txt)
	return cell
end

tooltipMain.AddDoubleLine = function(self, txt1, txt2)
	local lineNum = self:NumLines() + 1
	local line = self.lines[lineNum - 1]
	local cell1 = newCell()
	local cell2 = newCell()
	if lineNum == 1 then
		cell1:SetPoint("TOPLEFT", frame, "TOPLEFT")
	else
		cell1:SetPoint("TOPLEFT", line[1], "BOTTOMLEFT")
	end
	cell2:SetPoint("TOPLEFT", cell1, "TOPRIGHT")
	tinsert(self.lines, new(cell1, cell2))
	cell1:SetText(txt1)
	cell2:SetText(txt2)	
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
	frame:SetWidth(width)
	frame:SetHeight(height)
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

tooltipMain.Hide = function(self)
	frame.alpha = frame:GetAlpha()
	frame.flash:Fade(1, frame.alpha, 0, realHide)
end

tooltipMain.Shown = function(self)
	return frame:GetVisible()
end

function StarTip:NewModule(name)
	local mod = {name=name, core=core, evaluator=LibEvaluator, tooltipMain=tooltipMain, context=context}
	table.insert(StarTip.modules, mod)
	return mod
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

local function startup()
	for k, mod in pairs(StarTip.modules) do
		if mod.OnEnable then
			mod:OnEnable()
		end
	end
end

local function unitChanged(id)
	if id then
		for k, mod in pairs(StarTip.modules) do
			if mod.SetUnit then mod:SetUnit() end
		end
		tooltipMain:Show()
	else
		tooltipMain:Hide()
		for k, mod in pairs(StarTip.modules) do
			if mod.OnHide then mod:OnHide() end
		end
	end
end

table.insert(Event.System.Update.Begin, {update, "StarTip", "refresh"})

table.insert(Event.Addon.Startup.End, {startup, "StarTip", "refresh"})

table.insert(Library.LibUnitChange.Register("mouseover"), {unitChanged, "StarTip", "refresh"})

table.insert(Command.Slash.Register("startip"), {function (commands)	
	if commands == "cpu" then
		StarTip:CPU()
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
