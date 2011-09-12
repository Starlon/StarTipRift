_G.StarTip = {tooltipMain = {}}
local tooltipMain = _G.StarTip.tooltipMain
local context = UI.CreateContext()

local context = UI.CreateContext("StarTip")
local frame = UI.CreateFrame("Frame", "StarTipFrame", context)

local pool = {}
local function newCell()
	local cell = tremove(pool)
	
	if not cell then cell = UI.CreateFrame("Text", "StarTipText" .. random(), frame) end
	
	return cell
end

local function delCell(cell)
	cell:ClearAllPoints()
	cell:SetText("")
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
	tinsert(self.lines, {cell})
end

tooltipMain.AddDoubleLine = function(self, txt1, txt2)
	local lineNum = self:NumLines() + 1
	local cell1 = newCell()
	local cell2 = newCell()
	cell1:SetText(txt1)
	cell2:SetText(txt2)
	cell2:SetPoint("TOPLEFT", cell1, "TOPRIGHT")
	if lineNum == 1 then
		cell1:SetPoint("TOPLEFT", frame, "TOPLEFT")
	else
		cell1:SetPoint("TOPLEFT", self.lines[lineNum - 1][1], "BOTTOMLEFT")
	end
	tinsert(self.lines, {cell1, cell2})
end

tooltipMain.ClearLines = function(self)
	for k, line in ipairs(self.lines) do
		delCell(line[1])
		if line[2] then delCell(line[2]) end
	end
end

tooltipMain.Reshape = function(self)
	local height, width = 0, 0
	for k, line in ipairs(self.lines) do
		line[1]:ResizeToText()
		height = height + line[1]:GetHeight()
		local w = line[1]:GetWidth()
		if line[2] then 
			line[2]:ResizeToText() 
			w = w + line[2]:GetWidth()
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