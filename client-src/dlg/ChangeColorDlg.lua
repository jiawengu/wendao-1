-- ChangeColorDlg.lua
-- Created by sujl, May/17/2018
-- 换色界面

local ChangeColorDlg = Singleton("ChangeColorDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local partToCtrl = {
    --部件名    1面板名           2默认部位      3选择面板          4方案中的顺序  5部件层         6部件KEY             7部件选择框            8部件组名           9方案节点         10方案组名
    ["头发"] = { "HairPanel",         3,      "HairChosePanel",           2,      { 3, 8 },       "hairIndex",        "HairCheckBox",         "hairGroup",        "PlanPanel_1",   "hairRadio",},
    ["衣服"] = { "BodyPanel",         4,      "BodyChosePanel",           3,      { 4, 6, 7 },    "bodyIndex",        "BodyCheckBox",         "bodyGroup",        "PlanPanel_2",   "bodyRadio",},
    ["裤子"] = { "TrousersPanel",     5,      "TrousersChosePanel",       4,      { 5 },          "trousersIndex",    "TrousersCheckBox",     "trousersGroup",    "PlanPanel_3",   "trousersRadio",},
    ["武器"] = { "WeaponPanel",       1,      "WeaponChosePanel",         5,      { 1, 10},       "weaponIndex",      "WeaponCheckBox",       "weaponGroup",      "PlanPanel_4",   "weaponRadio",},
    ["背饰"] = { "BackPanel",         2,      "BackChosePanel",           6,      { 2, 9 },       "backIndex",        "BackCheckBox",         "backGroup",        "PlanPanel_6",   "backRadio",},
    ["裸模"] = { "NudePanel",         0,      "",                         1,      { 0 },          "curIcon",          "NudeCheckBox",         "",                 "PlanPanel_5",   "iconRadio",},
}

local RangeToColor = {
    {{0, 24}, "红"},
    {{15, 105}, "黄"},
    {{75, 165}, "绿"},
    {{135, 225}, "青"},
    {{195, 285}, "蓝"},
    {{255, 345}, "洋红"},
    {{330, 360}, "红"},
    {{0, 360}, "全图"},
}

local NONE = '无'

-- 目前的icon
--[[
配置说明：
1、只配置编号，所有部件必须齐全
2、配置为{编号, true}，表示只使用部分部件
]]
local NudeIcon = { 60001, 61001, { 60033, true }, {6001, true} }

local MAX_NUDE_COUNT = 10
local MAX_PART_COUNT = 10
local MAX_PLAN_COUNT = 10

local TOUCH_BEGAN  = 1
local TOUCH_END    = 2

-- 已加载的记录
local LOADED_CONFIG

function ChangeColorDlg:init()
    self:bindListener("LeftButton", self.onLeftButton, "PlanPanel")
    self:bindListener("RightButton", self.onRightButton, "ChangePanel")
    self:bindListener("ChoseButton", self.onChosePartButton, "PartPanel")
    self:bindListener("ChoseButton", self.onChoseAreaButton, "AreaPanel")
    self:bindListener("ChoseButton", self.onChoseChannelButton, "ChannelPanel")
    self:bindListener("ChoseButton", self.onChoseFigureButton, "figurePanel")
    self:bindListener("ExportButton", self.onExportButton, "RightPanel")
    self:bindListener("SaveButton", self.onSaveButton, "RightPanel")
    self:bindListener("DeleteButton", self.onDeleteButton, "RightPanel")
    self:bindListener("LeftButton", self.onPlanLeftButton, "PlanPanel")
    self:bindListener("RightButton", self.onPlanRightButton, "PlanPanel")
    self:bindListener("LeftButton", self.onChangeLeftButton, "ChangePanel")
    self:bindListener("RightButton", self.onChangeRightButton, "ChangePanel")
    self:bindListener("ReduceButton", self.onRecoverButton, "ChangePanel")
    self:bindListener("AttackButton", self.onAttackButton, "DownPanel")
    self:bindListener("MagicButton", self.onMagicButton, "DownPanel")
    self:blindPress("HueAddButton", self.onHueAddButton, "ChangePanel")
    self:blindPress("HueReduceButton", self.onHueReduceButton, "ChangePanel")
    self:blindPress("SaturationAddButton", self.onSaturationAddButton, "ChangePanel")
    self:blindPress("SaturationReduceButton", self.onSaturationReduceButton, "ChangePanel")
    self:blindPress("LightAddButton", self.onLightAddButton, "ChangePanel")
    self:blindPress("LightReduceButton", self.onLightReduceButton, "ChangePanel")

    self:setCtrlVisible("LeftPanel", true)
    self:setCtrlVisible("RightPanel", true)

    -- 记录初始位置
    local px, py = self:getControl("PlanPanel"):getPosition()
    self.planPos = cc.p(px, py)
    px, py = self:getControl("ChangePanel"):getPosition()
    self.changePos = cc.p(px, py)
    self:movePanel("PlanPanel", -self:getMovePanelWidth("PlanPanel"), 0)

    LOADED_CONFIG = {}

    for i = 1, 10 do
        self:bindListener(string.format("PartPanel_%d", i), self.onPartPanelClick, "ChangePanel")
    end

    -- 部件
    self.partGroup = RadioGroup.new()
    self.partGroup:setItems(self, self:getPartCheckBox(), self.onPartCheck, "PartChosePanel", function()
        self:showPartPanel(false)
    end)
    self:setPartValue(NONE)
    self:showPartPanel(false)

    -- 区域
    self.areaGroup = RadioGroup.new()
    self.areaGroup:setItems(self, {"AllCheckBox", "RedCheckBox", "YellowCheckBox", "GreenCheckBox", "CyanCheckBox", "BlueCheckBox", "MagentaCheckBox"}, self.onAreaCheck, "AreaChosePanel", function(dlg, sender)
        self:onAreaCheck(sender)
    end)
    self:setAreaValue(NONE)
    self:showAreaPanel(false)

    -- 色相
    self:bindSliderListener("Slider", self.onHueSlider, "HuePanel")
    self:bindEditFieldForSafe("HuePanel", 2, nil, nil, function(dlg, sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType or ccui.TextFiledEventType.delete_backward == eventType then
            local value = tonumber(self:getInputText("HuePanel"))
            if value then
                if value < -180 then
                    gf:ShowSmallTips("色相最小值为-180。")
                    value = -180
                end

                if value > 180 then
                    gf:ShowSmallTips("色相最大值为180。")
                    value = 180
                end
                self:setSliderPercent("Slider", (value / 180 * 100) / 2 + 50, "HuePanel")
                self:setInputText("HuePanel", value)
                self:updatePlanPart("HueLabel", value)
            end
        end
    end)
    self:setInputText("HuePanel", 0)

    -- 饱和度
    self:bindSliderListener("Slider", self.onSaturationSlider, "SaturationPanel")
    self:bindEditFieldForSafe("SaturationPanel", 2, nil, nil, function(dlg, sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType or ccui.TextFiledEventType.delete_backward == eventType then
            local value = tonumber(self:getInputText("SaturationPanel"))
            if value then
                if value < -100 then
                    gf:ShowSmallTips("饱和度最小值为-100。")
                    value = -100
                end

                if value > 100 then
                    gf:ShowSmallTips("饱和度最大值为100。")
                    value = 100
                end

                self:setSliderPercent("Slider", value / 2 + 50, "SaturationPanel")
                self:setInputText("SaturationPanel", value)
                self:updatePlanPart("SaturationLabel", value)
            end
        end
    end)
    self:setInputText("SaturationPanel", 0)

    -- 明度
    self:bindSliderListener("Slider", self.onLightSlider, "LightPanel")
    self:bindEditFieldForSafe("LightPanel", 2, nil, nil, function(dlg, sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType or ccui.TextFiledEventType.delete_backward == eventType then
            local value = tonumber(self:getInputText("LightPanel"))
            if value then
                if value < -100 then
                    gf:ShowSmallTips("明度最大值为100。")
                    value = -100
                end

                if value > 100 then
                    gf:ShowSmallTips("明度最小值为-100。")
                    value = 100
                end

                self:setSliderPercent("Slider", value / 2 + 50, "LightPanel")
                self:setInputText("LightPanel", value)
                self:updatePlanPart("Lightabel", value)
            end
        end
    end)
    self:setInputText("LightPanel", 0)

    -- 通道
    self.channelGroup = RadioGroup.new()
    self.channelGroup:setItems(self, {"RedCheckBox", "GreenCheckBox", "BlueCheckBox"}, self.onChannelCheck, "ChanneChosePanel", function(dlg, sender)
        self:onChannelCheck(sender)
    end)
    self:setChannelValue(NONE)
    self:showChannelPanel(false)
    self:bindChannelListener("Red")
    self:bindChannelListener("Green")
    self:bindChannelListener("Blue")
    self:bindChannelListener("Value")

    self:initFigurePanel()

    -- 选择方案
    for _, v in pairs(partToCtrl) do
        self[v[6]] = 0
    end

    self.partMainIndex = {}
    self:selectPlan(self:emptyPlan())
    self:initPlanPanel()
end

function ChangeColorDlg:emptyPlan()
    local t = {}
    for _, v in pairs(partToCtrl) do
        t[v[4]] = 0
    end

    return t
end

function ChangeColorDlg:getPartCheckBox()
    local checkboxes = {}
    for _, v in pairs(partToCtrl) do
        table.insert(checkboxes, v[7])
    end

    return checkboxes
end

-- 绑定通道相关事件
function ChangeColorDlg:bindChannelListener(channel)
    local panelName = channel .. "Panel"

    self:blindPress(channel .. "AddButton", function(dlg, sender, eventType)
        self:onChannelAddValue(panelName, 1)
    end, panelName)

    self:blindPress(channel .. "ReduceButton", function(dlg, sender, eventType)
        self:onChannelAddValue(panelName, -1)
    end, panelName)

    self:bindSliderListener("Slider", function(dlg, sender, eventType)
        local value = sender:getPercent()
        value = (value - 50) * 2
        self:setInputText(panelName, value)
        self:updatePlanPart(panelName, value)
    end, panelName)

    self:bindEditFieldForSafe(panelName, 2, nil, nil, function(dlg, sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType or ccui.TextFiledEventType.delete_backward == eventType then
            self:onChannelAddValue(panelName, 0)
        end
    end)

    self:setInputText(panelName, 0)
end

function ChangeColorDlg:onChannelAddValue(panelName, delta)
    local PANEL_TO_SHOWNAME = {
        RedPanel = "R",
        GreenPanel = "G",
        BluePanel = "B",
        ValuePanel = "V",
    }

    local value = tonumber(self:getInputText(panelName))
    if value then
        value = value + delta
        if value < -100 then
            gf:ShowSmallTips(PANEL_TO_SHOWNAME[panelName] .. CHS[3004457])
            value = -100
        end

        if value > 100 then
            gf:ShowSmallTips(PANEL_TO_SHOWNAME[panelName] .. CHS[3004458])
            value = 100
        end

        self:setSliderPercent("Slider", value / 2 + 50, panelName)
        self:setInputText(panelName, value)
        self:updatePlanPart(panelName, value)
    end
end

function ChangeColorDlg:blindPress(name, func, root)
    local widget = self:getControl(name, nil, root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , function() func(self) end, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            func(self)
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function ChangeColorDlg:getMovePanelWidth(panelName)
    local size = self:getControl(panelName):getContentSize()
    return size.width
end

function ChangeColorDlg:movePanel(pn, x, t)
    local p = self:getControl(pn)
    if not p then return end
    local px, py
    if 'PlanPanel' == pn then
        px, py = self.planPos.x, self.planPos.y
    else
        px, py = self.changePos.x, self.changePos.y
    end
    local cx, cy = p:getPosition()
    if cx == px + x then
        return
    end

    p:stopAllActions()
    if t <= 0 then
        p:setPositionX(px + x)
        self:setCtrlVisible("LeftButton", not self:getCtrlVisible("LeftButton", pn), pn)
        self:setCtrlVisible("RightButton", not self:getCtrlVisible("RightButton", pn), pn)
    else
        local callBack = cc.CallFunc:create(function()
            self:setCtrlVisible("LeftButton", not self:getCtrlVisible("LeftButton", pn), pn)
            self:setCtrlVisible("RightButton", not self:getCtrlVisible("RightButton", pn), pn)
        end)
        p:runAction(cc.MoveTo:create(t, cc.p(px + x, py)))
    end
end

-- 初始化角色面板
function ChangeColorDlg:initFigurePanel()
    self:setCtrlVisible("figureChosePanel", false)
    self:bindListener("ExportButton_1", self.onSelectFigureButton, "figureChosePanel")

    -- 形象
    local radios = {}
    local noParts = {}
    for i = 1, MAX_NUDE_COUNT do
        local ctlName = string.format("CheckBox_%d", i)
        if 'table' == type(NudeIcon[i]) then
            self:setLabelText("Label", NudeIcon[i][1] or "", self:getControl(ctlName, nil, "FigureChosePanel"))
            noParts[NudeIcon[i][1]] = NudeIcon[i][2]
        else
            self:setLabelText("Label", NudeIcon[i] or "", self:getControl(ctlName, nil, "FigureChosePanel"))
            if NudeIcon[i] then
                noParts[NudeIcon[i]] = false
            end
        end
        self:setCtrlVisible(ctlName, i <= #NudeIcon, "FigureChosePanel")
        table.insert(radios, ctlName)
    end
    self.figureGroup = RadioGroup.new()
    self.figureGroup:setItems(self, radios, function(dlg, sender, eventType)
        self.selectInfo.curIcon = tonumber(self:getLabelText("Label", sender))
        self.selectInfo.ignorePart = noParts[tonumber(self:getLabelText("Label", sender))]
        if self.selectInfo.curIcon then
            self:refreshParts(self.selectInfo.curIcon)
        end
    end, "FigureChosePanel")

    for k, v in pairs(partToCtrl) do
        if not string.isNilOrEmpty(v[8]) then
            self:createPartGroup(v[8], v[3], v[6])
    end
    end
end

function ChangeColorDlg:createPartGroup(group, panel, indexName)
    local radios = {}
    for i = 1, MAX_PART_COUNT do
        local ctlName = string.format("CheckBox_%d", i)
        self:setCtrlVisible(ctlName, false, panel)
        table.insert(radios, ctlName)
    end
    self[group] = RadioGroup.new()
    self[group]:setItems(self, radios, function(dlg, sender, eventType)
        local index = tonumber(string.match(sender:getName(), "CheckBox_(%d)"))
        self.selectInfo[indexName] = index
    end, panel)
end

function ChangeColorDlg:initPlanPanel()
    local panel = "PlanPanel"
    self.planRadio = {}
    local radios = {}
    for i = 1, MAX_PLAN_COUNT do
        table.insert(radios, string.format("CheckBox_%d", i))
    end

    for k, v in pairs(partToCtrl) do
        self:createPlanRadioGroup(k, v[9], v[10], radios)
    end
end

-- 创建计划RadioGroup
function ChangeColorDlg:createPlanRadioGroup(part, panelName, groupName, radios)
    local function takeColorCfg(path)
        if package.loaded[path] then
            return package.loaded[path]
        elseif cc.FileUtils:getInstance():isFileExist(path) then
            return require(path)
        end
    end

    local raido
    raido = RadioGroup.new()
    raido:setItems(self, radios, function(dlg, sender, eventType)
        if not self.curIcon or 0 == self.curIcon then
            self[groupName]:unSelectedRadio()
            gf:ShowSmallTips("请先选择形象！")
            return
        end

        local index = self[groupName]:getSelectedRadioIndex()
        local partName = part
        local path = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[partName][2], self[ partToCtrl[partName][6] ]), self[ partToCtrl[partName][6] ])))
        local cfg = takeColorCfg(path)
        if not cfg or not cfg[index] then
            self[groupName]:unSelectedRadio()
            gf:ShowSmallTips("没有该方案！")
            return
        end
        local parts = partToCtrl[partName][5]
        for i = 1, #parts do
            CharMgr:setColor(parts[i], cfg[index].delta, cfg[index].range, cfg[index].range1, cfg[index].rate)
        end
    end, panelName)
    self[groupName] = raido
end

-- 刷新角色拥有部件
function ChangeColorDlg:refreshPartIcon(icon, k)
    local path, ctrl
    local parts, panel = partToCtrl[k][5], partToCtrl[k][3]
    for i = 1, MAX_PART_COUNT do
        local isExist
        -- 检测对应的部件的所有目录，只要有一个目录有就表示存在这个部件
        for j = 1, #parts do
            path = ResMgr:getCharPath(string.format("%05d/%02d%03d", icon, parts[j], i), gf:getActionStr(Const.SA_STAND))  .. ".plist"
            isExist = cc.FileUtils:getInstance():isFileExist(path)
            if isExist then
                self.partMainIndex[string.format("%02d%03d", partToCtrl[k][2], i)] = parts[j]
                break
        end
        end

        ctrl = self:getControl(string.format("CheckBox_%d", i), nil, panel)
        if isExist then
            self:setLabelText("Label", string.format("%03d", i), ctrl)
            ctrl:setVisible(true)
        else
            ctrl:setVisible(false)
        end
    end
end

function ChangeColorDlg:refreshParts(icon)
    self.partMainIndex = {}
    for k, v in pairs(partToCtrl) do
        if 0 ~= v[2] then
            self:refreshPartIcon(icon, k)
        end
    end
end

-- 获取部件的主层，用于读取换色信息
function ChangeColorDlg:getPartMainIndex(part, index)
    if not index then return part end
    local key = string.format("%02d%03d", part, index)
    if not self.partMainIndex or not self.partMainIndex[key] then
        return part
    end

    return self.partMainIndex[key]
end

function ChangeColorDlg:deepCopy(t)
    if 'table' ~= type(t) then return end

    local n = {}
    for k, v in pairs(t) do
        if 'table' == type(v) then
            n[k] = self:deepCopy(v)
        else
           n[k] = v
        end
    end

    return n
end

-- 获取部件配置
function ChangeColorDlg:getPartCfg(icon, part)
    local path = ResMgr:getCharPartColorPath(icon, part)
    if not LOADED_CONFIG[path] then
        if cc.FileUtils:getInstance():isFileExist(path) then
            local cfg = require(path)
            LOADED_CONFIG[path] = self:deepCopy(cfg)
        else
            LOADED_CONFIG[path] = {}
        end
    end

    return LOADED_CONFIG[path]
end

function ChangeColorDlg:assurePartCfgValue(icon, part, plan)
    local cfg = self:getPartCfg(icon, part)
    if not cfg[plan] then
        cfg[plan] = self:getPartCfgValue(icon, part, plan)
    end

    return cfg[plan]
end

-- 获取部件配置
function ChangeColorDlg:getPartCfgValue(icon, part, plan)
    local path = ResMgr:getCharPartColorPath(icon, part)
    local cfg = self:getPartCfg(icon, part)
    if cfg and cfg[plan] then
        if not cfg[plan].rate then
            cfg[plan].rate = {1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0}
        end

        return cfg[plan]
    end

    return {
        delta = { x = 0, y = 0, z = 0 }, range = { x = 0, y = 1},
        rate = {1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0}
    }
end

-- 从range转换为area
function ChangeColorDlg:getAreaFromRange(range, range1)
    for i = 1, #RangeToColor do
        local k, v = RangeToColor[i][1], RangeToColor[i][2]
        local rx, ry = math.floor(range.x * 360 + 0.5), math.floor(range.y * 360 + 0.5)
        local rx1, ry1 = range1 and math.floor(range1.x * 360 + 0.5), range1 and math.floor(range1.y * 360 + 0.5)
        if (range.x < range.y and rx >= k[1] and ry <= k[2]) or (rx1 and ry2 and rx1 < ry1 and rx1 >= k[1] and ry1 <= k[2]) then
            return v
        end
    end

    return NONE
end

-- 从area转换为range
function ChangeColorDlg:getRangeFromArea(area)
    local r, r1
    for i = 1, #RangeToColor do
        local k, v = RangeToColor[i][1], RangeToColor[i][2]
        if v == area then
            if not r then
                r = cc.p(k[1] / 360, k[2] / 360)
            else
                r1 = cc.p(k[1] / 360, k[2] / 360)
            end
        end
    end

    return r, r1
end

function ChangeColorDlg:getInputText(panel, root)
    local textField = self:getControl("TextField", nil, self:getControl(panel, nil, root))
    return textField:getStringValue()
end

function ChangeColorDlg:setInputText(panel, str, root)
    local textField = self:getControl("TextField", nil, self:getControl(panel, nil, root))
    textField:setText(tostring(str))
end

-- 获取部件在curPlan中的位置
function ChangeColorDlg:getPartIndex(part)
    return partToCtrl[part] and partToCtrl[part][4] or 1
end

function ChangeColorDlg:refreshChar()
    local charAction = Me.charAction
    if not charAction or 0 == self.curIcon then return end

    --[[
    01 - 头发下
    02 - 武器下
    03 - 手下
    04 - 裤子
    05 - 衣服
    06 - 武器上
    07 - 手上
    08 - 头发上
    ]]

    local indexs = self:getPartIndexs()
    CharMgr:setIcon(self.curIcon, 0, indexs, "", 5, 0)
end

-- 刷新角色换色方案
function ChangeColorDlg:refreshCharColor()
    if 0 == self.curIcon then return end
    local indexs = self:getPartIndexs()
    --local cindexs = string.format("%02d%02d%02d%02d%02d%02d%02d%02d%02d", self.curPlan[1], self.curPlan[2], self.curPlan[5], self.curPlan[3], self.curPlan[4], self.curPlan[3], self.curPlan[5], self.curPlan[3], self.curPlan[2])
    CharMgr:setIcon(self.curIcon, 0, indexs, "", 5, 0)

    -- 更新换色
    for k, v in pairs(partToCtrl) do
        local parts = partToCtrl[k][5]
        local cfg = self:getPartCfgValue(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(v[2], self[partToCtrl[k][6] ] or 0), self[partToCtrl[k][6] ] or 0)), self.curPlan[self:getPartIndex(k)])
        for i = 1, #parts do
            CharMgr:setColor(parts[i], cfg.delta, cfg.range, cfg.range1, cfg.rate)
        end
    end
end

-- 更新角色部件换色
function ChangeColorDlg:updateCharPartColor(part, cfg)
    local partIndexs = partToCtrl[part][5]
    for i = 1, #partIndexs do
        CharMgr:setColor(partIndexs[i], cfg.delta, cfg.range, cfg.range1, cfg.rate)
    end
end

-- 选中方案
function ChangeColorDlg:selectPlan(plan)
    self.curPlan = plan

    -- 更新形象
    local count = 0
    local dict = { string.format("%05d", self.curIcon) }
    for _, v in pairs(partToCtrl) do
        if v[2] ~= 0 then
            count = count + 1
            dict[v[4]] = string.format("%02d", self[v[6]] or 0)
        end
    end

    --self:setLabelText("Label_563", string.format("%05d%02d%02d%02d%02d", self.curIcon, self.hairIndex or 0, self.bodyIndex or 0, self.trousersIndex or 0, self.weaponIndex or 0), "figurePanel")
    self:setLabelText("Label_563", table.concat(dict), "figurePanel")
    self:refreshChar()

    local cfg
    local p = self:getPartValue()
    for k, v in pairs(partToCtrl) do
        if k == p and self[partToCtrl[k][6] ] then
            cfg = self:getPartCfgValue(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(v[2], self[partToCtrl[k][6] ]), self[partToCtrl[k][6] ])), self.curPlan[self:getPartIndex(k)])
            self:updatePlanValue(k, cfg)
        end
    end

    for i = 1, 10 do
        local ctlName = string.format("PartPanel_%d", i)
        local panel = self:getControl(ctlName, nil, "ChangePanel")
        self:setCtrlVisible("ChoseImage", i == self.curPlan[self:getPartIndex(p)], panel)
    end

    self:refreshCharColor()
end

function ChangeColorDlg:updatePlanValue(k, cfg)
    self:setPartValue(k)
    self:setAreaValue(self:getAreaFromRange(cfg.range, cfg.range1))
    self:setHueValue(math.ceil(cfg.delta.x * 180))
    self:setSaturationValue(math.ceil(cfg.delta.y * 100))
    self:setLightValue(math.ceil(cfg.delta.z * 100))
    self:setChannelValue(CHS[3004459]) -- 红色通道
    self:updateAllChannelValue(cfg)
end

function ChangeColorDlg:getPartIndexs()
    local indexs = {}
    for k, v in pairs(partToCtrl) do
        if v[2] ~= 0 then
        local v1 = v[5]
        local val = self[ v[6] ] or 0
        for i = 1, #v1 do
            local j = v1[i]
            local path = ResMgr:getCharPath(string.format("%05d/%02d%03d", self.curIcon, j, val), gf:getActionStr(Const.SA_STAND))  .. ".plist"
            if cc.FileUtils:getInstance():isFileExist(path) then
                indexs[j] = val
                else
                    indexs[j] = 0
            end
        end
    end
    end

    local str = ""
    for i = 1, #indexs do
        str = str .. string.format("%02d", indexs[i])
    end

    return str
end

-- 设置部件
function ChangeColorDlg:setPartValue(value)
    self:setLabelText("Label_563", value, "PartPanel")
end

function ChangeColorDlg:getPartValue()
    return self:getLabelText("Label_563", "PartPanel")
end

-- 设置区域
function ChangeColorDlg:setAreaValue(value)
    self:setLabelText("Label_563", value, "AreaPanel")
    self:updatePlanPart("AreaLabel", value)
end

function ChangeColorDlg:getAreaValue()
    return self:getLabelText("Label_563", "AreaPanel")
end

-- 设置操作的通道
function ChangeColorDlg:setChannelValue(value)
    self:setLabelText("Label_563", value, "ChannelPanel")
    self:updatePlanPart("ChannelLabel", value)
end

function ChangeColorDlg:getChannelValue()
    return self:getLabelText("Label_563", "ChannelPanel")
end

-- 设置色相
function ChangeColorDlg:setHueValue(value)
    self:setInputText("HuePanel", value)
    self:updatePlanPart("HueLabel", value)
    self:setSliderPercent("Slider", (value / 3.6 + 50), "HuePanel")
end

-- 设置饱和度
function ChangeColorDlg:setSaturationValue(value)
    self:setInputText("SaturationPanel", value)
    self:updatePlanPart("SaturationLabel", value)
    self:setSliderPercent("Slider", value / 2 + 50, "SaturationPanel")
end

-- 设置明度
function ChangeColorDlg:setLightValue(value)
    self:setInputText("LightPanel", value)
    self:updatePlanPart("Lightabel", value)
    self:setSliderPercent("Slider", value / 2 + 50, "LightPanel")
end

-- 修改色相
function ChangeColorDlg:onHueSlider(sender)
    local value = self:getSliderPercent("Slider", "HuePanel")
    local value = math.ceil((value - 50) * 3.6)
    self:setInputText("HuePanel", value)
    self:updatePlanPart("HueLabel", value)
end

-- 修改饱和度
function ChangeColorDlg:onSaturationSlider(sender)
    local value = self:getSliderPercent("Slider", "SaturationPanel")
    value = (value - 50) * 2
    self:setInputText("SaturationPanel", value)
    self:updatePlanPart("SaturationLabel", value)
end

-- 修改明度
function ChangeColorDlg:onLightSlider(sender)
    local value = self:getSliderPercent("Slider", "LightPanel")
    value = (value - 50) * 2
    self:setInputText("LightPanel", value)
    self:updatePlanPart("Lightabel", value)
end

function ChangeColorDlg:onChosePartButton()
    if 0 == self.curIcon then
        gf:ShowSmallTips("请先选择形象。")
        return
    end

    self:showPartPanel(true)
end

function ChangeColorDlg:onChoseAreaButton()
    if 0 == self.curIcon then
        gf:ShowSmallTips(CHS[3004462]) -- 请先选择形象
        return
    end

    if NONE == self:getPartValue() then
        gf:ShowSmallTips(CHS[3004463]) -- 请先选择部位
        return
    end

    self:showAreaPanel(true)
end

function ChangeColorDlg:onChoseChannelButton()
    if 0 == self.curIcon then
        gf:ShowSmallTips(CHS[3004462]) -- 请先选择形象
        return
    end

    if NONE == self:getPartValue() then
        gf:ShowSmallTips(CHS[3004463]) -- 请先选择部位
        return
    end

    self:showChannelPanel(true)
end

function ChangeColorDlg:onChoseFigureButton()
    self.selectInfo = {}
    self.figureGroup:unSelectedRadio()

    for _, v in pairs(partToCtrl) do
        if not string.isNilOrEmpty(v[8]) then
            self[v[8]]:unSelectedRadio()
        end
    end
    self:setCtrlVisible("figureChosePanel", true)
end

function ChangeColorDlg:onSelectFigureButton()
    local sp = {}

    if not self.selectInfo.curIcon then
        table.insert(sp, "#R裸模#n")
    end

    if not self.selectInfo.ignorePart then
        for k, v in pairs(partToCtrl) do
            if not string.isNilOrEmpty(v[8]) and not self.selectInfo[v[6]] then
                table.insert(sp, string.format("#R%s#n", k))
        end
        end

        if #sp > 0 then
            gf:ShowSmallTips(string.format("请先选择%s", table.concat(sp, "、")))
            return
        end
    end

    local function apply()
        self.curIcon = self.selectInfo.curIcon
        for k, v in pairs(partToCtrl) do
            if not string.isNilOrEmpty(v[10]) then
                self[v[6]] = self.selectInfo[v[6]]
            end
        end

        self:setCtrlVisible("figureChosePanel", false)
        self:selectPlan(self:emptyPlan())
        self:setPartValue(NONE)
        self:setAreaValue(NONE)
    end

    if 0 ~= self.curIcon and self.selectInfo.curIcon ~= self.curIcon then
        gf:confirm("更换形象将清空当前所有配置方案，是否确认?", function()
            apply()
        end, function()
            self:setCtrlVisible("figureChosePanel", false)
        end)
    else
        apply()
    end
end

-- 选择部件
function ChangeColorDlg:onPartCheck(sender, eventType)
    self:showPartPanel(false)
    local labelText = self:getLabelText("Label", sender)
    local part = self:getPartMainIndex(partToCtrl[labelText][2], self[partToCtrl[labelText][6]])
    local index = (0 == part and 0 or self[partToCtrl[labelText][6]]) or 1
    local path = ResMgr:getCharPath(string.format("%05d/%02d%03d", self.curIcon, part, index), gf:getActionStr(Const.SA_STAND))  .. ".plist"
    if not cc.FileUtils:getInstance():isFileExist(path) then
        gf:ShowSmallTips(string.format("缺少部件#R%s#n", labelText))
        return
    end
    local index = self:getPartIndex(labelText)
    self:setPartValue(labelText)

    if 0 == self.curPlan[index] then
        for k, v in pairs(partToCtrl) do
            self.curPlan[self:getPartIndex(k)] = 1
        end
    end
    self:selectPlan(self.curPlan)
end

-- 选择区域
function ChangeColorDlg:onAreaCheck(sender, eventType)
    local labelText = self:getLabelText("Label", sender)
    self:showAreaPanel(false)
    self:setAreaValue(labelText)

    self:setHueValue(0)
    self:setSaturationValue(0)
    self:setLightValue(0)
    self:refreshCharColor()

    local part = self:getPartValue()
    if not part or NONE == part then return end
    local cfg = self:getPartCfgValue(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[part][2], self[partToCtrl[part][6]]), self[partToCtrl[part][6]])), self.curPlan[self:getPartIndex(part)])
    cfg.range, cfg.range1 = self:getRangeFromArea(labelText)
end

-- 选择通道
function ChangeColorDlg:onChannelCheck(sender, eventType)
    local labelText = self:getLabelText("Label", sender)
    self:showChannelPanel(false)
    self:setChannelValue(labelText)
    self:updateAllChannelValue()
end

-- 根据当前选择的通道获取该通道在 rate 中对应的索引起始位置
function ChangeColorDlg:getRateIndexByChannel()
    local idx = 1
    local channel = self:getChannelValue()
    if channel == CHS[3004460] then -- 绿色通道
        idx = 2
    elseif channel == CHS[3004461] then -- 蓝色通道
        idx = 3
    end

    return idx
end

function ChangeColorDlg:updateAllChannelValue(cfg)
    local part = self:getPartValue()
    if not part or NONE == part then return end
    cfg = cfg or self:getPartCfgValue(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[part][2], self[partToCtrl[part][6]]), self[partToCtrl[part][6]])), self.curPlan[self:getPartIndex(part)])

    local idx = self:getRateIndexByChannel()
    local r = math.floor(cfg.rate[idx] * 100)
    local g = math.floor(cfg.rate[idx + 4] * 100)
    local b = math.floor(cfg.rate[idx + 8] * 100)
    local v = math.floor(cfg.rate[idx + 12] * 100)

    local panelName = "RedPanel"
    self:setSliderPercent("Slider", r / 2 + 50, panelName)
    self:setInputText(panelName, r)

    panelName = "GreenPanel"
    self:setSliderPercent("Slider", g / 2 + 50, panelName)
    self:setInputText(panelName, g)

    panelName = "BluePanel"
    self:setSliderPercent("Slider", b / 2 + 50, panelName)
    self:setInputText(panelName, b)

    panelName = "ValuePanel"
    self:setSliderPercent("Slider", v / 2 + 50, panelName)
    self:setInputText(panelName, v)
end

-- 更新方案数据
function ChangeColorDlg:updatePlanPart(name, value, part)
    part = part or self:getPartValue()
    if NONE == part then return end
    local panel = partToCtrl[part][1]
    self:setLabelText(name, value, panel)

    if 'AreaLabel' ~= name then
        local plan = self.curPlan[self:getPartIndex(part)]
        local cfg = self:getPartCfg(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[part][2], self[partToCtrl[part][6]]), self[partToCtrl[part][6]])))
        if not cfg[plan] then
            cfg[plan] = self:getPartCfgValue(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[part][2], self[partToCtrl[part][6]]), self[partToCtrl[part][6]])), plan)
        end

        local cfgv = cfg[plan]
        if not cfgv.rate then
            cfgv.rate = {1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0}
        end

        local idx = self:getRateIndexByChannel()
        if 'HueLabel' == name then
            cfgv.delta.x = value / 180
        elseif 'SaturationLabel' == name then
            cfgv.delta.y = value / 100
        elseif 'Lightabel' == name then
            cfgv.delta.z = value / 100
        elseif 'RedPanel' == name then
            cfgv.rate[idx] = value / 100
        elseif 'GreenPanel' == name then
            cfgv.rate[idx + 4] = value / 100
        elseif 'BluePanel' == name then
            cfgv.rate[idx + 8] = value / 100
        elseif 'ValuePanel' == name then
            cfgv.rate[idx + 12] = value / 100
        else
            return
        end

        self:updateCharPartColor(part, cfgv)
    end
end

-- 显示部件面板
function ChangeColorDlg:showPartPanel(visible)
    self:setCtrlVisible("PartChosePanel", visible, "ChangePanel")
    if self:getPartValue() == NONE then
        self.partGroup:unSelectedRadio()
    end
end

-- 显示区域面板
function ChangeColorDlg:showAreaPanel(visible)
    self:setCtrlVisible("AreaChosePanel", visible, "ChangePanel")
    if self:getAreaValue() == NONE then
        self.partGroup:unSelectedRadio()
    end
end

-- 显示通道面板
function ChangeColorDlg:showChannelPanel(visible)
    self:setCtrlVisible("ChanneChosePanel", visible, "ChangePanel")
end

function ChangeColorDlg:onLeftButton()
end

function ChangeColorDlg:onRightButton()
end

function ChangeColorDlg:onPartPanelClick(sender)
    local ctlName = sender:getName()
    local plan = tonumber(string.match(ctlName, "PartPanel_(%d)"))

    for k, v in pairs(partToCtrl) do
        self.curPlan[self:getPartIndex(k)] = plan
    end
    self:selectPlan(self.curPlan)
end

function ChangeColorDlg:onExportButton()
    local path, cfg, fpath
    for k, v in pairs(partToCtrl) do
        local l = v[5]
        local vpath = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(v[2], self[partToCtrl[k][6] ] or 0), self[partToCtrl[k][6] ] or 0)))
        for i = 1, #l do
            fpath = ResMgr:getCharPath(string.format("%05d/%02d%03d", self.curIcon, l[i], self[partToCtrl[k][6] ] or 0), gf:getActionStr(Const.SA_STAND))  .. ".plist"
            if cc.FileUtils:getInstance():isFileExist(fpath) then
                path = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", l[i], self[partToCtrl[k][6] ] or 0)))
                local cfg
                if package.loaded[vpath] then
                    cfg = package.loaded[vpath]
                    CharMgr:writeFile(path, cfg)
                end
            end
        end
    end

    gf:ShowSmallTips("导出配置文件成功。")
end

-- 记录至左侧，保存数据
function ChangeColorDlg:onSaveButton()
    local pv = self:getPartValue()
    if not pv or NONE == pv then return end
    local plan = self.curPlan[self:getPartIndex(pv)]
    local cfgv = self:getPartCfgValue(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[pv][2], self[partToCtrl[pv][6]] or 0), self[partToCtrl[pv][6]] or 0)), plan)
    local path = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[pv][2], self[partToCtrl[pv][6]] or 0), self[partToCtrl[pv][6]] or 0)))
    if not package.loaded[path] then
        package.loaded[path] = {}
    end

    -- 缺少配置，先填充为默认值
    for i = 1, plan - 1 do
        if not package.loaded[path][i] then
            package.loaded[path][i] = {
                delta = { x = 0, y = 0, z = 0 }, range = { x = 0, y = 1},
                rate = {1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0}
            }
        end
    end

    package.loaded[path][plan] = self:deepCopy(cfgv) -- 更新到内存数据中

    gf:ShowSmallTips("当前方案已保存。")
end

function ChangeColorDlg:onDeleteButton()
    local pv = self:getPartValue()
    if not pv or NONE == pv then return end
    local cfg = self:getPartCfg(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[pv][2], self[partToCtrl[pv][6]]), self[partToCtrl[pv][6]])))
    local plan = self.curPlan[self:getPartIndex(pv)]
    if not cfg or not cfg[plan] then
        gf:ShowSmallTips("不存在该方案")
        return
    end

    table.remove(cfg, self.curPlan[self:getPartIndex(pv)])

    -- 刷新界面
    self.curPlan[self:getPartIndex(pv)] = 1
    self:selectPlan(self.curPlan)

    local path = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[pv][2], self[partToCtrl[pv][6]]), self[partToCtrl[pv][6]])))
    package.loaded[path] = cfg

    local k, v = pv, partToCtrl[pv]
    for i = 1, #v[5] do
        path = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(v[2], self[partToCtrl[k][6] ]), self[partToCtrl[k][6] ])))
        local cfg
        if package.loaded[path] then
            cfg = package.loaded[path]
            CharMgr:writeFile(path, cfg)
        end
    end
end

function ChangeColorDlg:onPlanLeftButton()
    self:movePanel("PlanPanel", -self:getMovePanelWidth("PlanPanel"), 0)
end

function ChangeColorDlg:onPlanRightButton()
    self:movePanel("PlanPanel", 0, 0)
    self:movePanel("ChangePanel", self:getMovePanelWidth("ChangePanel"), 0)

    self:selectPlan(self:emptyPlan())
    self:setPartValue(NONE)

    for _, v in pairs(partToCtrl) do
        self[v[10]]:unSelectedRadio()
    end

    local radios = {}
    for i = 1, MAX_PLAN_COUNT do
        table.insert(radios, string.format("CheckBox_%d", i))
    end

    local function takeColorCfg(path)
        if package.loaded[path] then
            return package.loaded[path]
        elseif cc.FileUtils:getInstance():isFileExist(path) then
            return require(path)
        end
    end

    local function showPlan(pname, root)
        local partName = pname
        local cfg
        if self[ partToCtrl[partName][6] ] then
            local path = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[partName][2], self[ partToCtrl[partName][6] ]), self[ partToCtrl[partName][6] ])))
            cfg = takeColorCfg(path)
        end

        for i = 1, #radios do
            self:setCtrlVisible(radios[i], cfg and nil ~= cfg[i], root)
        end
    end

    for k, v in pairs(partToCtrl) do
        showPlan(k, v[9])
    end
end

function ChangeColorDlg:onChangeLeftButton()
    self:movePanel("ChangePanel", 0, 0)
    self:movePanel("PlanPanel", -self:getMovePanelWidth("PlanPanel"), 0)
    self:selectPlan(self:emptyPlan())
    self:setPartValue(NONE)
end

function ChangeColorDlg:onChangeRightButton()
    self:movePanel("ChangePanel", self:getMovePanelWidth("ChangePanel"), 0)
end

function ChangeColorDlg:onHueAddButton()
    local value = tonumber(self:getInputText("HuePanel"))
    if value then
        value = value + 1
        if value < -180 then
            gf:ShowSmallTips("色相最小值为-180。")
            value = -180
        end

        if value > 180 then
            gf:ShowSmallTips("色相最大值为180。")
            value = 180
        end
        self:setSliderPercent("Slider", (value / 180 * 100) / 2 + 50, "HuePanel")
        self:setInputText("HuePanel", value)
        self:updatePlanPart("HueLabel", value)
    end
end

function ChangeColorDlg:onHueReduceButton()
    local value = tonumber(self:getInputText("HuePanel"))
    if value then
        value = value - 1
        if value < -180 then
            gf:ShowSmallTips("色相最小值为-180。")
            value = -180
        end

        if value > 180 then
            gf:ShowSmallTips("色相最大值为180。")
            value = 180
        end
        self:setSliderPercent("Slider", (value / 180 * 100) / 2 + 50, "HuePanel")
        self:setInputText("HuePanel", value)
        self:updatePlanPart("HueLabel", value)
    end
end

function ChangeColorDlg:onSaturationAddButton()
    local value = tonumber(self:getInputText("SaturationPanel"))
    if value then
        value = value + 1
        if value < -100 then
            gf:ShowSmallTips("饱和度最小值为-100。")
            value = -100
        end

        if value > 100 then
            gf:ShowSmallTips("饱和度最大值为100。")
            value = 100
        end

        self:setSliderPercent("Slider", value / 2 + 50, "SaturationPanel")
        self:setInputText("SaturationPanel", value)
        self:updatePlanPart("SaturationLabel", value)
    end
end

function ChangeColorDlg:onSaturationReduceButton()
    local value = tonumber(self:getInputText("SaturationPanel"))
    if value then
        value = value - 1
        if value < -100 then
            gf:ShowSmallTips("饱和度最小值为-100。")
            value = -100
        end

        if value > 100 then
            gf:ShowSmallTips("饱和度最大值为100。")
            value = 100
        end

        self:setSliderPercent("Slider", value / 2 + 50, "SaturationPanel")
        self:setInputText("SaturationPanel", value)
        self:updatePlanPart("SaturationLabel", value)
    end
end

function ChangeColorDlg:onLightAddButton()
    local value = tonumber(self:getInputText("LightPanel"))
    if value then
        value = value + 1
        if value < -100 then
            gf:ShowSmallTips("明度最大值为100。")
            value = -100
        end

        if value > 100 then
            gf:ShowSmallTips("明度最小值为-100。")
            value = 100
        end

        self:setSliderPercent("Slider", value / 2 + 50, "LightPanel")
        self:setInputText("LightPanel", value)
        self:updatePlanPart("Lightabel", value)
    end
end

function ChangeColorDlg:onLightReduceButton()
    local value = tonumber(self:getInputText("LightPanel"))
    if value then
        value = value - 1
        if value < -100 then
            gf:ShowSmallTips("明度最大值为100。")
            value = -100
        end

        if value > 100 then
            gf:ShowSmallTips("明度最小值为-100。")
            value = 100
        end

        self:setSliderPercent("Slider", value / 2 + 50, "LightPanel")
        self:setInputText("LightPanel", value)
        self:updatePlanPart("Lightabel", value)
    end
end

function ChangeColorDlg:onRecoverButton()
    local pv = self:getPartValue()
    if not pv or NONE == pv then
        -- 没有指定部件
        gf:ShowSmallTips("请选择部件")
        return
    end
    local plan = self.curPlan[self:getPartIndex(pv)]
    if not plan or 0 == plan then
        gf:ShowSmallTips("请选择方案")
        return
    end
    local path = ResMgr:getCharPartColorPath(self.curIcon, tonumber(string.format("%02d%03d", self:getPartMainIndex(partToCtrl[pv][2], self[partToCtrl[pv][6]] or 0), self[partToCtrl[pv][6]] or 0)))

    local cfg
    if not package.loaded[path] or not next(package.loaded[path]) then
        local area = self:getAreaValue()
        cfg = {
            delta = { x = 0, y = 0, z = 0 },
            rate = {1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0}
        }
        cfg.range, cfg.range1 = self:getRangeFromArea(area)
    else
        cfg = package.loaded[path][plan] -- 更新到内存数据中
    end
    LOADED_CONFIG[path][plan] = self:deepCopy(cfg)
    self:selectPlan(self.curPlan)
end

function ChangeColorDlg:onAttackButton()
    if Me.charAction then
        Me.charAction:playAction(function()
            Me.charAction:resetAction()
        end, Const.SA_ATTACK, 1)
    end
end

function ChangeColorDlg:onMagicButton()
    if Me.charAction then
        Me.charAction:playAction(function()
            Me.charAction:resetAction()
        end, Const.SA_CAST, 1)
    end
end

return ChangeColorDlg

-- updateAll() DlgMgr:closeDlg("ChangeColorDlg") DlgMgr:openDlg("ChangeColorDlg")