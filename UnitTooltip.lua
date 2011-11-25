local addon, ns = ...
local StarTip = ns.StarTip
local mod = StarTip:NewModule("UnitTooltip")
local WidgetText = LibStub("LibScriptableWidgetText-1.0")
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0")

local tinsert = table.insert
local tremove = table.remove

local lines = {}
local config = {
	onMouseover = {
		code = [[
			ResetDPS(unit)
		]]

	},
	lines = {
		[1] = {
			name = "Warning",
			left = "return 'StarTip has no profile.'",
			enabled = true
		}
	}
}

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
			if widget.cell and widget.buffer ~= "" then
				widget.cell:SetFontSize(widget.config.fontSize or 12)
				widget.cell:SetText(widget.buffer)
			end

			if widget.color.is_valid and widget.buffer ~= "" then
				widget.color:Eval()
				local r, g, b, a = widget.color:P2N()
				widget.cell:SetFontColor(r or 0, g or 0, b or 0, a or 1)
			end
		end

		wipe(widgetsToDraw)
		StarTip.tooltipMain:Reshape()
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
	StarTip.tooltipMain:Clear()
	for k, v in ipairs(lines) do
		--if v.Del then v:Del() end
	end
end

local tbl
function mod:CreateLines()
    self:ClearLines()
    local llines = {}
    local j = 0
    for i, v in ipairs(config.lines) do
        if not v.deleted and v.enabled and v.left then
            v = copy(v)
            j = j + 1
            llines[j] = copy(v)
            llines[j].config = copy(v)
			
			v.align = v.alignLeft
            v.value = v.left
            v.outlined = v.leftOutlined
            v.color = v.colorLeft
            v.maxWidth = v.maxWidthL
            v.minWidth = v.minWidthL
            local update = v.update or 0
            v.update = 0
            if v.left and v.leftUpdating then v.update = update end
            llines[j].leftObj = v.left and WidgetText:New(StarTip.core, "StarTip.UnitTooltip:" .. v.name .. ":left:", copy(v), 0, 0, v.layer or 0, StarTip.errorLevel, widgetUpdate)

			v.align = v.alignRight
            v.value = v.right
            v.outlined = v.rightOutlined
            v.update = 0
            if v.right and v.rightUpdating then v.update = update end
            v.color = v.colorRight
            v.maxWidth = v.maxWidthR
            v.minWidth = v.minWidthR
            llines[j].rightObj = v.right and WidgetText:New(StarTip.core, "StarTip.UnitTooltip:" .. v.name .. ":right:", copy(v), 0, 0, v.layer or 0, StarTip.errorLevel, widgetUpdate)
			

            if llines[j].rightObj then table.insert(mod.widgets, llines[j].rightObj) end
            if llines[j].leftObj then table.insert(mod.widgets, llines[j].rightObj) end
        end
    end
    self:ClearLines()
    lines = setmetatable(llines, {__call=function(self)
            local lineNum = 0
            StarTip.tooltipMain:Clear()
            for i, v in ipairs(self) do
                if v.leftObj then
                    v.leftObj.cell = nil
					v.leftObj.buffer = false
                end
                if v.rightObj then
                    v.rightObj.cell = nil
					v.rightObj.buffer = false
                end
                local left, right = '', ''
                StarTip.core.environment.unit = "mouseover"
                if v.right then
                    if v.rightObj then
                        StarTip.core.environment.self = v.rightObj
                        right = StarTip.evaluator.ExecuteCode(StarTip.core.environment, v.name .. " right", v.right)
                        if type(right) == "number" then right = right .. "" end
                    end
                    if v.leftObj then
                        StarTip.core.environment.self = v.leftObj
                        left = StarTip.evaluator.ExecuteCode(StarTip.core.environment, v.name .. " left", v.left)
                        if type(left) == "number" then left = left .. "" end
                    end
                else
                    if v.leftObj then
                        StarTip.core.environment.self = v.leftObj
                        left = StarTip.evaluator.ExecuteCode(StarTip.core.environment, v.name .. " left", v.left)
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
                        v.rightObj:Start("mouseover")
                    end
                    if v.leftObj then
			v.leftObj.buffer = false
                        v.leftObj:Start("mouseover")
                    end
                    v.lineNum = lineNum
                end
            end
    end})
    mod.lines = lines
end

function mod:Establish(data)
	if type(data) ~= "table" then return end
	config.lines = {}
	for i, v in pairs(data) do
		config.lines[i] = v
	end
	self:CreateLines()
	
end

function mod:OnStartup()
	lines = {}
	mod.widgets = {}
	self:CreateLines()
end

function mod:OnHide()
	self:StopLines()
end

function mod:SetUnit()
	if not StarTip.core.environment.UnitName("mouseover") then return end
	Evaluator.Evaluate(StarTip.core.environment, "onMouseover", config.onMouseover.code, "mouseover")
	self:StopLines()
	lines()
end
