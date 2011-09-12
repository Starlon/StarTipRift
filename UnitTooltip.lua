local WidgetText = LibStub("LibScriptableWidgetText-1.0", true)
assert(WidgetText, "Text module requires LibScriptableWidgetText-1.0")
local LCDText = LibStub("LibScriptableLCDText-1.0", true)
assert(LCDText, mod.name .. " requires LibScriptableLCDText-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0", true)
assert(LibCore, mod.name .. " requires LibScriptableLCDCore-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, mod.name .. " requires LibScriptableUtilsTimer-1.0")
local LibEvaluator = LibStub("LibScriptableUtilsEvaluator-1.0", true)
assert(LibEvaluator, mod.name .. " requires LibScriptableUtilsEvaluator-1.0")
local mod = {}
local tinsert = table.insert
local tremove = table.remove

local config = {
unit = {
    [1] = {
        name = "UnitName",
        left = [[
return UnitName(unit)
]],
        right = nil,
        bold = true,
        enabled = true,
        cols = 80,
        leftOutlined = 3,
		leftUpdating = true,
		update = 500
    },
	[2] = {
		name = "Target",
		left = "return 'Target:'",
		right = [[
return UnitName(unit..".target")	
]],
		enabled = true,
		rightUpdating = true,
		update = 500,
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
                
				StarTip.tooltipMain:SetCell(widget.y, widget.x, widget.buffer, widget.fontObj, justification, colSpan, nil, 0, 0, nil, nil, 40)

			if type(widget.config.color) == "string" and (widget.config.color == " " or widget.config.color ~= "") and widget.color.is_valid then
				widget.color:Eval()
				local r, g, b, a = widget.color:P2N()
				StarTip.tooltipMain:SetCellColor(widget.y, widget.x, r or 0, g or 0, b or 0, a or 1)
			end
		end
		wipe(widgetsToDraw)
    end
end

function mod:AppendTrunk()
	for i, v in ipairs(StarTip.trunk) do
		if #v == 2 then
			local y = StarTip.tooltipMain:AddLine('', '')
			StarTip.tooltipMain:SetCell(y, 1, v[1])
			StarTip.tooltipMain:SetCell(y, 2, v[2])
		else
			local y = StarTip.tooltipMain:AddLine('')
			StarTip.tooltipMain:SetCell(y, 1, v[1], nil, "LEFT", 2)
		end
	end
	StarTip:TrunkClear()
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
            llines[j].leftObj = v.left and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":left:", copy(v), 0, 0, v.layer or 0, errorLevel, widgetUpdate)

            v.value = v.right
            v.outlined = v.rightOutlined
            v.update = 0
            if v.right and v.rightUpdating then v.update = update end
            v.color = v.colorR
            v.maxWidth = v.maxWidthR
            v.minWidth = v.minWidthR
            llines[j].rightObj = v.right and WidgetText:New(mod.core, "StarTip.UnitTooltip:" .. v.name .. ":right:", copy(v), 0, 0, v.layer or 0, StarTip.db.profile.errorLevel, widgetUpdate)
--[[
           if v.left then
               llines[j].leftObj.fontObj = _G[v.name .. "Left"] or CreateFont(v.name .. "Left")
           end
           if v.right then
               llines[j].rightObj.fontObj = _G[v.name .. "Right"] or CreateFont(v.name .. "Right")
           end
]]
        end
    end
    self:ClearLines()
    lines = setmetatable(llines, {__call=function(self)
            local lineNum = 0
            StarTip.tooltipMain:Clear()
            --GameTooltip:ClearLines()
            for i, v in ipairs(self) do
                if v.leftObj then
                    v.leftObj.x = nil
                    v.leftObj.y = nil
                end
                if v.rightObj then
                    v.rightObj.x = nil
                    v.rightObj.y = nil
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
                        --GameTooltip:AddDoubleLine(' ', ' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b, mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b)
                        local y, x = StarTip.tooltipMain:AddLine('', '')
                        --v.leftObj.fontString = mod.leftLines[lineNum]
                        --v.rightObj.fontString = mod.rightLines[lineNum]
			--v.leftObj.fontString = StarTip.qtipLines[y][1]
			--v.rightObj.fontString = StarTip.qtipLines[y][2]
			v.leftObj.y = y
			v.leftObj.x = 1
			v.rightObj.y = y
			v.rightObj.x = 2
                    else
                        local y, x = StarTip.tooltipMain:AddLine('')
                        v.leftObj.y = y
                        v.leftObj.x = 1
                        --GameTooltip:AddLine(' ', mod.db.profile.color.r, mod.db.profile.color.g, mod.db.profile.color.b, v.wordwrap)
                        --v.leftObj.fontString = mod.leftLines[lineNum]
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
