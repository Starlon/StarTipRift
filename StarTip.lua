_G.StarTip = {tooltipMain = {lines={}}, modules={}, unit="mouseover", errorLevel=2}
local tooltipMain = _G.StarTip.tooltipMain

local LibCore = LibStub("LibScriptableLCDCoreLite-1.0")
local LibEvaluator = LibStub("LibScriptableUtilsEvaluator-1.0")

local environment = {}
local core = LibCore:New(environment, "StarTip", 2)

local context = UI.CreateContext("StarTip")
local frame = UI.CreateFrame("Frame", "StarTipFrame", context)
frame:SetBackgroundColor(0, 0, 0, .8)

local tremove, tinsert = table.remove, table.insert

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
	local cell = UI.CreateFrame("Text", "StarTipText" .. random() * 1000, frame)	
	return cell
end

local function delCell(cell)
	cell:ClearAll()
	cell:SetVisible(false)
	tinsert(pool, cell)
end

tooltipMain.AddLine = function(self, txt)
	local lineNum = self:NumLines() + 1
	local cell = newCell()
	cell:SetText(txt)
	if lineNum == 1 then
		cell:SetPoint("TOPLEFT", frame, "TOPLEFT")
	else
		cell:SetPoint("TOPLEFT", self.lines[lineNum - 1][1], "BOTTOMLEFT")
	end
	tinsert(self.lines, new(cell))
	return cell
end

tooltipMain.AddDoubleLine = function(self, txt1, txt2)
	local lineNum = self:NumLines() + 1
	local cell1 = newCell()
	local cell2 = newCell()
	cell1:SetText(txt1)
	cell2:SetText(txt2)
	if lineNum == 1 then
		cell1:SetPoint("TOPLEFT", frame, "TOPLEFT")
	else
		cell1:SetPoint("TOPLEFT", self.lines[lineNum - 1][1], "BOTTOMLEFT")
	end
	cell2:SetPoint("TOPLEFT", cell1, "TOPRIGHT")
	tinsert(self.lines, new(cell1, cell2))
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
	frame:ClearAll()
	for k, line in ipairs(self.lines) do
		--line[1]:ResizeToText()
		height = height + line[1]:GetHeight()
		local w = line[1]:GetWidth()
		if line[2] then 
			--line[2]:ResizeToText() 
			w = w + line[2]:GetWidth()
		end
		if w > width then 
			width = w
		end
	end
	print(width, height)
	frame:ClearWidth()
	frame:ClearHeight()
	frame:SetWidth(width + 100)
	frame:SetHeight(height)
end

tooltipMain.NumLines = function(self)
	return #self.lines
end

tooltipMain.Show = function(self)
	frame:SetVisible(true)
	for k, v in ipairs(self.lines) do
		v[1]:SetVisible(true)
		if v[2] then v[2]:SetVisible(true) end
	end
	self:Reshape()
end

tooltipMain.Hide = function(self)
	frame:SetVisible(false)
end

local hidden = true

local function update()
	local mouse = Inspect.Mouse()
	frame:ClearAll()
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouse.x - frame:GetWidth() / 2, mouse.y - frame:GetHeight())
end

local function startup()
	tooltipMain:AddLine("Test")
	tooltipMain:Hide()
	for k, mod in pairs(StarTip.modules) do
		if mod.OnEnable then
			mod:OnEnable()
		end
	end
end

local function add(units)
	tooltipMain:Hide()
	for k, mod in pairs(StarTip.modules) do
		if mod.OnHide then mod:OnHide() end
	end
	for id, unit in pairs(units) do
		if unit == "mouseover" then
			tooltipMain:Show()
			for k, mod in pairs(StarTip.modules) do
				if mod.SetUnit then mod:SetUnit() end
			end
		end
	end
end

table.insert(Event.System.Update.Begin, {update, "StarTip", "refresh"})

table.insert(Event.Addon.Startup.End, {startup, "StarTip", "refresh"})

table.insert(Event.Unit.Add, {add, "StarTip", "refresh"})

function StarTip:NewModule(name)
	local mod = {name=name, core=core, evaluator=LibEvaluator}
	table.insert(StarTip.modules, mod)
	return mod
end
