local StarTip = _G.StarTip
local mod = StarTip:NewModule("UnitTooltip")
local WidgetText = LibStub("LibScriptableWidgetText-1.0", true)
assert(WidgetText, "Text module requires LibScriptableWidgetText-1.0")
--local LCDText = LibStub("LibScriptableLCDText-1.0", true)
--assert(LCDText, mod.name .. " requires LibScriptableLCDText-1.0")
--local LibCore = LibStub("LibScriptableLCDCore-1.0", true)
--assert(LibCore, mod.name .. " requires LibScriptableLCDCore-1.0")
--local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
--assert(LibTimer, mod.name .. " requires LibScriptableUtilsTimer-1.0")

local tinsert = table.insert
local tremove = table.remove

local function copy(src, dst)
    if type(src) ~= "table" then return nil end
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            v = copy(v)
        end
        dst[k] = v
    end
    return dst
end

local lines = {}
local config = {
lines = {
    [1] = {
        name = "UnitName",
        left = [[
return UnitName(unit)
]],
        right = nil,
        enabled = true,
		leftUpdating = false,
		update = 500
    },
	[2] = {
		name = "Target",
		left = "return 'Target:'",
		right = "return 'blah'",
		enabled = true,
	}
}
}

local function wipe(tbl)
	for i = 1, #tbl do
		tremove(tbl)
	end
end

local widgetUpdate
do
    local widgetsToDraw = {}
    function widgetUpdate(widget)
		tinsert(widgetsToDraw, widget)
		draw(true)
    end
    function draw()
        for i, widget in ipairs(widgetsToDraw) do
			if widget.cell then
				widget.cell:SetText(widget.buffer)
			end
--[[
			if type(widget.config.color) == "string" and (widget.config.color == " " or widget.config.color ~= "") and widget.color.is_valid then
				widget.color:Eval()
				local r, g, b, a = widget.color:P2N()
				widget.cell:SetFontColor(r, g, b)
			end
]]
		end

		wipe(widgetsToDraw)
		StarTip.tooltipMain:Show()
    end
end

function mod:StopLines()
    for k, v in pairs(lines) do
        if v.leftObj then
            v.leftObj:Stop()
        end
        if v.rightObj then
            v.rightObj:Stop()
        end
    end

end

function mod:ClearLines()
    self:StopLines()
    wipe(lines)
end

local tbl
function mod:CreateLines()
    local llines = {}
    local j = 0
    for i, v in ipairs(config.lines) do
        if not v.deleted and v.enabled and v.left then
            v = copy(v)
            j = j + 1
            llines[j] = copy(v)
            llines[j].config = copy(v)

            v.value = v.left
            v.outlined = v.leftOutlined
            v.color = v.colorL
            v.maxWidth = v.maxWidthL
            v.minWidth = v.minWidthL
            local update = v.update or 0
            v.update = 0
            if v.left and v.leftUpdating then v.update = update end
            mod.core.environment.unit = StarTip.unit or "player"
            llines[j].leftObj = v.left and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":left:", copy(v), 0, 0, v.layer or 0, StarTip.errorLevel, widgetUpdate)

            v.value = v.right
            v.outlined = v.rightOutlined
            v.update = 0
            if v.right and v.rightUpdating then v.update = update end
            v.color = v.colorR
            v.maxWidth = v.maxWidthR
            v.minWidth = v.minWidthR
            llines[j].rightObj = v.right and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":right:", copy(v), 0, 0, v.layer or 0, StarTip.errorLevel, widgetUpdate)
        end
    end
    self:ClearLines()
    lines = setmetatable(llines, {__call=function(self)
            local lineNum = 0
            StarTip.tooltipMain:Clear()
            for i, v in ipairs(self) do
                if v.leftObj then
                    v.leftObj.cell = nil
                end
                if v.rightObj then
                    v.rightObj.cell = nil
                end
                local left, right = '', ''
                environment.unit = v.leftObj and v.leftObj.unitOverride or StarTip.unit or "mouseover"
                if v.right then
                    if v.rightObj then
                        environment.self = v.rightObj
                        right = mod.evaluator.ExecuteCode(environment, v.name .. " right", v.right)
                        if type(right) == "number" then right = right .. "" end
                    end
                    if v.leftObj then
                        environment.self = v.leftObj
                        left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
                        if type(left) == "number" then left = left .. "" end
                    end
                else
                    if v.leftObj then
                        environment.self = v.leftObj
                        left = mod.evaluator.ExecuteCode(environment, v.name .. " left", v.left)
                        if type(left) == "number" then left = left .. "" end
                    end
                    right = ''
                end
                
                if type(left) == "string" and type(right) == "string" then
                    lineNum = lineNum + 1
                    if v.right and v.right ~= "" then
                        local cell1, cell2 = StarTip.tooltipMain:AddDoubleLine('', '')
						v.leftObj.cell = cell1
						v.rightObj.cell = cell2
                    else
                        local cell = StarTip.tooltipMain:AddLine('')
						v.leftObj.cell = cell
                    end
                    if v.rightObj then
						v.rightObj.buffer = false
                        v.rightObj:Start()
                    end
                    if v.leftObj then
						v.leftObj.buffer = false
                        v.leftObj:Start()
                    end
                    v.lineNum = lineNum
                end
            end
    end})
end

function mod:OnEnable()
	self:CreateLines()
end

function mod:OnHide()
	self:StopLines()
end

function mod:SetUnit()
	self:StopLines()
	lines()
end
