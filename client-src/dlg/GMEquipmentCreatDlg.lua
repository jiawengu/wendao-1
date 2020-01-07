-- GMEquipmentCreatDlg.lua
-- Created by songcw Mar/04/2017
-- GM装备生成

local GMEquipmentCreatDlg = Singleton("GMEquipmentCreatDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local GM_EQUIP_TYPE = {
    {title = CHS[3001023], flag = "equip_type", equip_type = EQUIP_TYPE.WEAPON},
    {title = CHS[3001028], flag = "equip_type", equip_type = EQUIP_TYPE.WEAPON},
    {title = CHS[3001210], flag = "equip_type", equip_type = EQUIP_TYPE.WEAPON},
    {title = CHS[3001211], flag = "equip_type", equip_type = EQUIP_TYPE.WEAPON},
    {title = CHS[3001212], flag = "equip_type", equip_type = EQUIP_TYPE.WEAPON},
    {title = CHS[3001213], flag = "equip_type", equip_type = EQUIP_TYPE.HELMET},
    {title = CHS[3001214], flag = "equip_type", equip_type = EQUIP_TYPE.HELMET},
    {title = CHS[3001215], flag = "equip_type", equip_type = EQUIP_TYPE.ARMOR},
    {title = CHS[3001216], flag = "equip_type", equip_type = EQUIP_TYPE.ARMOR},
    {title = CHS[3001217], flag = "equip_type", equip_type = EQUIP_TYPE.BOOT},
    {title = CHS[3001222], flag = "equip_type", equip_type = EQUIP_TYPE.BALDRIC},
    {title = CHS[3001223], flag = "equip_type", equip_type = EQUIP_TYPE.NECKLACE},
    {title = CHS[3001224], flag = "equip_type", equip_type = EQUIP_TYPE.WRIST},
}

local GM_WEAPOM_POLAR = {
    [CHS[3001023]] = CHS[34308],    -- 枪 金
    [CHS[3001028]] = CHS[34309],    -- 爪 木
    [CHS[3001210]] = CHS[34310],    -- 剑
    [CHS[3001211]] = CHS[34311],    -- 扇
    [CHS[3001212]] = CHS[34312],    -- 锤
}

local GM_WEAPOM_GREEN = {
    [CHS[3001023]] = CHS[3002336],    -- 枪 遗忘
    [CHS[3001028]] = CHS[3002334],    -- 爪 中毒
    [CHS[3001210]] = CHS[3002337],    -- 剑
    [CHS[3001211]] = CHS[3002335],    -- 扇
    [CHS[3001212]] = CHS[3002338],    -- 锤
    [CHS[34308]] = CHS[3002336],    -- 金 遗忘
    [CHS[34309]] = CHS[3002334],    -- 木 中毒
    [CHS[34310]] = CHS[3002337],    -- 剑
    [CHS[34311]] = CHS[3002335],    -- 扇
    [CHS[34312]] = CHS[3002338],    -- 锤
}

local TEMPLATE_INDEX = {
    [1] = "PhyTypeCheckBox",
    [2] = "MagTypeCheckBox",
    [3] = "SpeedTypeCheckBox",
    [4] = "DefTypeCheckBox",
    [5] = "ObstacleTypeCheckBox",
}

local QMPK_CFG = require (ResMgr:getCfgPath("QuanmmPKCfg.lua"))
local TEMPLATE_EQUIP = QMPK_CFG[CHS[4100508]] -- 推荐装备属性

local TEMPLET_CHECKBOX = {
    "TempletCheckBox_1",
    "TempletCheckBox_2",
    "TempletCheckBox_3",
    "TempletCheckBox_4",
    "TempletCheckBox_5",
}

local COLOR_FLAG = {
    ["blue1"] = "blue",
    ["blue2"] = "blue",
    ["blue3"] = "blue",
    ["blue4"] = "blue",
    ["blue5"] = "blue",
    ["pink"] = "pink",
    ["yellow"] = "yellow",
    ["green"] = "green",
    ["black"] = "black",
    ["gongming"] = "gongming",
}

GMEquipmentCreatDlg.VALUE_RANGE = {
    ["LevelNumPanel"] = {MIN = 70, MAX = Const.PLAYER_MAX_LEVEL, DEF = math.max(math.floor(Me:queryInt("level") / 10) * 10, 70), notNeedChanegColor = true},
    ["UpgradeLevelNumPanel"] = {MIN = 0, MAX = 12, DEF = 0, notNeedChanegColor = true},
}

GMEquipmentCreatDlg.selectEquipAttribs = {blue = {}, pink = {}, yellow = {}, green = {}, black = {}, gongming = {}}

function GMEquipmentCreatDlg:init()
    -- 根据数值范围表
    self:updateValueRange()

    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("RefineButton", self.onRefineButton)

    self:bindFloatPanelListener("TipPanel")

    self.oneRowPanel = self:toCloneCtrl("OneRowPanel")


    for i = 1, 3 do
        -- 弹出菜单点击事件绑定
        self:bindListener("UnitPanel" .. i, self.onSelectUnitBtn, self.oneRowPanel)
    end

    self.attribPanel = self:toCloneCtrl("UnitPropertiesPanel")

    -- 属性选择类型
    self:bindListener("TypeBKImage", self.onSelectAttribBtn, self.attribPanel)


    self:bindListener("TypeBKImage", self.onSelectEquipTypeBtn, "NamePanel")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, TEMPLET_CHECKBOX, self.onTempletCheckBox)


    self:setListViewData()

    self:setDefalueValue()

    GMMgr:bindEditBoxForGM(self, "LevelNumPanel", self.levelDownCallBack, self.levelCondition)
    GMMgr:bindEditBoxForGM(self, "UpgradeLevelNumPanel")
end

function GMEquipmentCreatDlg:updateValueRange()
    self.VALUE_RANGE = {
        ["LevelNumPanel"] = {MIN = 70, MAX = Const.PLAYER_MAX_LEVEL, DEF = math.max(math.floor(Me:queryInt("level") / 10) * 10, 70), notNeedChanegColor = true},
        ["UpgradeLevelNumPanel"] = {MIN = 0, MAX = 12, DEF = 0, notNeedChanegColor = true},
    }
end

function GMEquipmentCreatDlg:bindEditFieldAttrib(ctrlName, downCallBack, limitCondition, panel, color)
    local edit = self:createEditBox(ctrlName, panel, nil, function(sender, type, eb)
        if type == "changed" then
            local value = eb:getText()

            if limitCondition then
                if not limitCondition(self, eb, value) then
                    return
                end
            end

            if downCallBack then
                downCallBack(self, eb, value)
            end
        end
    end)

    edit:setPlaceholderFont(CHS[3003794], 23)
    edit:setFont(CHS[3003794], 23)
    edit:setPlaceHolder(CHS[4200244])
    edit:setFontColor(color)
    edit:setPlaceholderFontColor(color)
end

function GMEquipmentCreatDlg:refreshAttrib()
    if not self.selectEquipType then return end

    local listCtrl = self:getControl("AttribListView")
    local items = listCtrl:getItems()
    for i = 1, #items do
        local panel = items[i]
        local keyInfo = panel.data
        if keyInfo and self.selectEquipAttribs[COLOR_FLAG[keyInfo.flag]][keyInfo.flag] then
            local colarTeam = COLOR_FLAG[keyInfo.flag]
            self:setLabelText("TypeTextField", keyInfo.title, panel)

            local equip = {equip_type = keyInfo.equip_type, req_level = self:getLevel()}
            local max, min = EquipmentMgr:getAttribMaxValueByField(equip, keyInfo.content)
            if keyInfo.flag == "black" then
                min, max = EquipmentMgr:getSuitMinAndMax(equip, keyInfo.content)
            end
            self:setLabelText("MaxLabel", "/" .. max, panel)
            panel.maxValue = max

            local curValue = tonumber(GMMgr:getEditBoxValue(self, "ValueNumPanel", panel))
            if curValue and curValue > max then
                GMMgr:setEditBoxValue(self, "ValueNumPanel", max, nil, panel)
                if self.selectEquipAttribs and self.selectEquipAttribs[colarTeam] then
                    self.selectEquipAttribs[colarTeam][keyInfo.flag .. "value"] = max
                end
            end
        end
    end
end

-- 属性字段输入完成
function GMEquipmentCreatDlg:attValueDownCallBack(sender, value)
    local numPanel = sender:getParent()
    local parentPanel = numPanel:getParent()
    local max = parentPanel.maxValue
    local data = parentPanel.data

    if not data then
        gf:ShowSmallTips(CHS[4200245]) -- 请先选择属性类型
        sender:setText(CHS[4200244])    -- 输入数值
        return
    end
    local value = tonumber(sender:getText())
    if not value then
        gf:ShowSmallTips(CHS[4100480])
        sender:setText(tostring(max))
        return
    end

    if value < 0 or value > max then
        gf:ShowSmallTips(CHS[4100480])
        sender:setText(tostring(max))
        return
    end

    self.selectEquipAttribs[COLOR_FLAG[data.flag]][data.flag .. "value"] = value
    self.selectEquipAttribs = self.selectEquipAttribs

 --   selectEquipAttribs
end

-- 等级输入完成后的回调
function GMEquipmentCreatDlg:levelDownCallBack(sender, value)
    local level = tonumber(value)
    if not level then return end

    if not self.selectEquipType then return end

    self:setDisplayAttribPanel()

    if EquipmentMgr:isJewelry(self.selectEquipType) then
        self.selectEquipAttribs = {blue = {}, pink = {}, yellow = {}, green = {}, black = {}, gongming = {}}
        self:setAttribInfoByEquipType(self.selectEquipType)
    else
        self:refreshAttrib()
    end
end

function GMEquipmentCreatDlg:changeTempletToEquipAtt(attribs)
    local ret = gf:deepCopy(attribs)
    for _, info in pairs(ret) do
        for field, tabInfo in pairs(info) do
            ret[_][field] = tabInfo.content
        end
    end

    return ret
end

function GMEquipmentCreatDlg:getAttribChs(chs)
    if string.match(chs, "XX") then
        if GM_WEAPOM_GREEN[self.selectEquipType.title] then
            chs = string.gsub(chs, "XX", GM_WEAPOM_GREEN[self.selectEquipType.title])
        else
            chs = string.gsub(chs, "XX", GM_WEAPOM_GREEN[gf:getPolar(Me:queryInt("polar"))])
        end
    elseif string.match(chs, "polar") then
        chs = string.gsub(chs, "polar", GM_WEAPOM_POLAR[self.selectEquipType.title])
    end

    return chs
end

function GMEquipmentCreatDlg:onTempletCheckBox(sender, eventType)
    if not self.selectEquipType then return end
    local key = TEMPLATE_INDEX[eventType]

    local attribs = TEMPLATE_EQUIP[self.selectEquipType.equip_type][key]

    if not self.selectEquipType then return end

    local listCtrl = self:getControl("AttribListView")
    local items = listCtrl:getItems()
    for i = 1, #items do
        local panel = items[i]
        local color = panel.attColor
        if attribs[panel:getName()] then
            local keyInfo = attribs[panel:getName()]

            keyInfo = self:getAttribChs(keyInfo)

            local equip = {equip_type = self.selectEquipType.equip_type, req_level = self:getLevel()}
            local field = EquipmentMgr:getAttribChsOrEng(keyInfo)

            local max, min = EquipmentMgr:getAttribMaxValueByField(equip, field)
            if panel:getName() == "black" then
                min, max = EquipmentMgr:getSuitMinAndMax(equip, field)
            end

            if not max then
                local ss
            end

            self:setLabelText("MaxLabel", "/" .. max, panel)
            panel.maxValue = max
            panel.data = {}
            panel.data.content = field
            panel.data.title = keyInfo
            panel.data.flag = panel:getName()
            self:setLabelText("TypeTextField", panel.data.title, panel)

            GMMgr:setEditBoxValue(self, "ValueNumPanel", max, nil, panel)

            if not self.selectEquipAttribs[COLOR_FLAG[panel.data.flag]] then self.selectEquipAttribs[COLOR_FLAG[panel.data.flag]] = {} end

            self.selectEquipAttribs[COLOR_FLAG[panel.data.flag]][panel:getName()] = panel.data.content
            self.selectEquipAttribs[COLOR_FLAG[panel.data.flag]][panel:getName() .. "value"] = max
        end
    end
--    self.selectEquipAttribs = self:changeTempletToEquipAtt(attribs)
end

function GMEquipmentCreatDlg:setOneAttribDefault(colorStr, color, panel)
    self:setLabelText("PropertiesLabel", colorStr, panel, color)
    self:setLabelText("TypeTextField", CHS[4100481], panel, color)

    self:setLabelText("MaxLabel", "", panel)

    self:bindEditFieldAttrib("ValueNumPanel", self.attValueDownCallBack, nil, panel, color)
    if colorStr == CHS[7190140] then
        -- 共鸣属性隐藏属性输入框
        self:setCtrlVisible("InputBKImage", false, panel)
        self:setCtrlVisible("ValueNumPanel", false, panel)
        self:setCtrlVisible("MaxLabel", false, panel)
    end
end

function GMEquipmentCreatDlg:setAttribInfoByEquipType(equip)
    local listCtrl = self:resetListView("AttribListView")
    if not equip then return end

    if not EquipmentMgr:isJewelry(equip) then
        -- 3条蓝属性
        for i = 1, 3 do
            local panel = self.attribPanel:clone()
            panel.attColor = "blue"
            panel.attOrder = i
            panel:setName("blue" .. i)
            self:setOneAttribDefault(CHS[3003037] .. i, COLOR3.BLUE, panel)
            listCtrl:pushBackCustomItem(panel)
        end

        -- 1 条粉属性
        local panel = self.attribPanel:clone()
        panel.attColor = "pink"
        panel:setName("pink")
        self:setOneAttribDefault(CHS[3003038], COLOR3.EQUIP_PINK, panel)
        listCtrl:pushBackCustomItem(panel)

        -- 1条黄属性
        local panel = self.attribPanel:clone()
        panel.attColor = "yellow"
        panel:setName("yellow")
        self:setOneAttribDefault(CHS[3003039], COLOR3.EQUIP_YELLOW, panel)
        listCtrl:pushBackCustomItem(panel)

        -- 1条绿属性   明
        local panel = self.attribPanel:clone()
        panel.attColor = "green"
        panel:setName("green")
        self:setOneAttribDefault(CHS[3003040], COLOR3.EQUIP_GREEN, panel)
        listCtrl:pushBackCustomItem(panel)

        -- 1条绿属性  暗
        local panel = self.attribPanel:clone()
        panel.attColor = "black"
        panel:setName("black")
        self:setOneAttribDefault(CHS[4200243], COLOR3.EQUIP_BLACK, panel)
        listCtrl:pushBackCustomItem(panel)

        -- 共鸣属性
        local panel = self.attribPanel:clone()
        panel.attColor = "gongming"
        panel:setName("gongming")
        self:setOneAttribDefault(CHS[7190140], COLOR3.BLUE, panel)
        listCtrl:pushBackCustomItem(panel)
    else
        local num = 0
        if self:getLevel() < 80 then
            -- 等策划
        elseif self:getLevel() < 90 then
            num = 1
        elseif self:getLevel() < 100 then
            num = 2
        elseif self:getLevel() < 110 then
            num = 3
        elseif self:getLevel() < 120 then
            num = 4
        else
            num = 5
        end
        for i = 1, num do
            local panel = self.attribPanel:clone()
            panel.attColor = "blue"
            panel.attOrder = i
            panel:setName("blue" .. i)
            self:setOneAttribDefault(CHS[3003037] .. i, COLOR3.BLUE, panel)
            listCtrl:pushBackCustomItem(panel)
        end
    end
    listCtrl:doLayout()
    listCtrl:refreshView()
end

-- 设置属性列表panel的显示状态
function GMEquipmentCreatDlg:setDisplayAttribPanel()
    self:setCtrlVisible("NoneChosenPanel", false)
    self:setCtrlVisible("LowJewelryePanel", false)

    self:setCtrlVisible("PropertiesPanel", true)
    self:setCtrlVisible("UpgradeLevelPanel", not EquipmentMgr:isJewelry(self.selectEquipType))
    if EquipmentMgr:isJewelry(self.selectEquipType) then
        if self:getLevel() < 80 then
            self:setCtrlVisible("LowJewelryePanel", true)
        end
    end
end

-- 点击弹出项
function GMEquipmentCreatDlg:onSelectUnitBtn(sender, eventType)
    local data = sender.data
    data.item_type = ITEM_TYPE.EQUIPMENT
    local listCtrl = self:getControl("AttribListView")
    if data.flag == "equip_type" then

        self:setLabelText("TypeTextField", data.title, "NamePanel")

        self.selectEquipType = data

        self:setAttribInfoByEquipType(data)

        self.selectEquipAttribs = {blue = {}, pink = {}, yellow = {}, green = {}, black = {}, gongming = {}}

        self:setDisplayAttribPanel()

        local isVisible = self:getCtrlVisible("TempletPanel")
        local selectRecomm = self.radioGroup:getSelectedRadio()
        if isVisible and selectRecomm then
            self:onTempletCheckBox(selectRecomm, self.radioGroup:getSelectedRadioIndex())
        end

    elseif string.format(data.flag, "blue") or data.flag == "pink" or data.flag == "yellow" or data.flag == "green" or data.flag == "black" or data.flag == "gongming" then
        local panel = listCtrl:getChildByName(data.flag)
        if panel.data then
            self.selectEquipAttribs[COLOR_FLAG[data.flag]][panel:getName()] = nil
        end
        self.selectEquipAttribs[COLOR_FLAG[data.flag]][panel:getName()] = data.content

        self:setLabelText("TypeTextField", data.title, panel)

        local equip = {equip_type = self.selectEquipType.equip_type, req_level = self:getLevel()}
        local max, min = EquipmentMgr:getAttribMaxValueByField(equip, data.content)
        if data.flag == "black" then
            min, max = EquipmentMgr:getSuitMinAndMax(equip, data.content)
        end
        self:setLabelText("MaxLabel", "/" .. max, panel)

        GMMgr:setEditBoxValue(self, "ValueNumPanel", max, nil, panel)
        self.selectEquipAttribs[COLOR_FLAG[data.flag]][data.flag .. "value"] = max
        panel.maxValue = max
        panel.data = data
    end

    self:setCtrlVisible("TipPanel", false)
end

function GMEquipmentCreatDlg:cleanup()

    self.selectEquipType = nil

    self:releaseCloneCtrl("attribPanel")
    self:releaseCloneCtrl("oneRowPanel")
end

function GMEquipmentCreatDlg:isCanExist(field, color, isJewelry, ctrlName)

    local function sumForColorAtt(colorAttTab, field, ctrlName)
        local sameCount = 0
        --
        for _, att in pairs(colorAttTab) do
            if att == field and _ ~= ctrlName then
                sameCount = sameCount + 1
            end
        end
        --]]

        return sameCount
    end


    if isJewelry then
        local sameCount = sumForColorAtt(self.selectEquipAttribs["blue"], field, ctrlName)

        if field == "all_skill" or field == "all_polar" or field == "all_resist_except" then
            return sameCount < 1
        end

        return sameCount < 2
    end


    local isMeet = true
    local existCount = 0
    if color == "blue" then
        -- 都为蓝属性，不能存在同种蓝属性
        local blueCount = sumForColorAtt(self.selectEquipAttribs["blue"], field, ctrlName)
        if blueCount > 0 then return end

        local pinkCount = sumForColorAtt(self.selectEquipAttribs["pink"], field, ctrlName)
        existCount = existCount + pinkCount

        local yellowCount = sumForColorAtt(self.selectEquipAttribs["yellow"], field, ctrlName)
        existCount = existCount + yellowCount

    elseif color == "pink" then
        local blueCount = sumForColorAtt(self.selectEquipAttribs["blue"], field, ctrlName)
        existCount = existCount + blueCount


        local yellowCount = sumForColorAtt(self.selectEquipAttribs["yellow"], field, ctrlName)
        existCount = existCount + yellowCount
    elseif color == "yellow" then
        local blueCount = sumForColorAtt(self.selectEquipAttribs["blue"], field, ctrlName)
        existCount = existCount + blueCount

        local pinkCount = sumForColorAtt(self.selectEquipAttribs["pink"], field, ctrlName)
        existCount = existCount + pinkCount
    end

    return existCount < 2
end

function GMEquipmentCreatDlg:getAttribInfos(color, ctrlName)
    local ret = {}
    local attTab = {}
    if color == "blue" or color == "pink" or color == "yellow" then
        local allAttrib = EquipmentMgr:getEquipAttribCfgInfo()
        attTab = allAttrib[self.selectEquipType.equip_type]
        for _, field in pairs(attTab) do
            if self:isCanExist(field, color, EquipmentMgr:isJewelry(self.selectEquipType), ctrlName) then
                table.insert(ret, {title = EquipmentMgr:getAttribChsOrEng(field), flag = ctrlName, content = field})
            end
        end
    elseif color == "green" then
        local allAttrib = EquipmentMgr:getAllSuitAttribByEquipType(self.selectEquipType.title)
        for _, name in pairs(allAttrib) do
            table.insert(ret, {title = name, flag = ctrlName, content = EquipmentMgr:getAttribChsOrEng(name)})
        end
    elseif color == "black" then
        local allAttrib = EquipmentMgr:getEquipSuitCfgInfo()
        for _, field in pairs(allAttrib) do
            table.insert(ret, {title = EquipmentMgr:getAttribChsOrEng(field), flag = ctrlName, content = field})
        end
    elseif color == "gongming" then
        local allAtttrib = EquipmentMgr:getGongmingAttribList()
        for i = 1, #allAtttrib do
            table.insert(ret, {title = allAtttrib[i], flag = ctrlName, content = EquipmentMgr:getAttribChsOrEng(allAtttrib[i])})
        end
    end

    return ret
end

-- 点击弹出选择装备属性
function GMEquipmentCreatDlg:onSelectAttribBtn(sender, eventType)
    if not self.selectEquipType then return end
    local parentPanel = sender:getParent()
    local color = parentPanel.attColor
    local infoList = self:getAttribInfos(color, parentPanel:getName())

    self:setListViewData(infoList)
    self:setCtrlVisible("TipPanel", true)
end

-- 点击弹出选择装备类型
function GMEquipmentCreatDlg:onSelectEquipTypeBtn(sender, eventType)
    self:setCtrlVisible("TipPanel", true)
    self:setListViewData(GM_EQUIP_TYPE)
end

-- 将表数据设置进listView
function GMEquipmentCreatDlg:setListViewData(tabData)
    local listCtrl = self:resetListView("ListView")
    if not tabData then return end

    local count = math.ceil(#tabData / 3)
    for i = 1, count do
        local panel = self.oneRowPanel:clone()
        for j = 1, 3 do
            local key = (i - 1) * 3 + j
            local unitPanel = self:getControl("UnitPanel" .. j, nil, panel)
            if tabData[key] then
                unitPanel.data = tabData[key]
                self:setLabelText("Label", tabData[key].title, unitPanel, tabData[key].color or COLOR3.WHITE)
            else
                unitPanel:setVisible(false)
            end
        end
        listCtrl:pushBackCustomItem(panel)
    end
    listCtrl:doLayout()
    listCtrl:refreshView()
end


-- 设置默认数值
function GMEquipmentCreatDlg:setDefalueValue()
    local level = math.floor(Me:queryInt("level") / 10) * 10
    self.selectEquipLevel = level

    -- 等级
    self:setInputText("LevelTextField", level)

    self.selectEquipAttribs = {blue = {}, pink = {}, yellow = {}, green = {}, black = {}, gongming = {}}
end

function GMEquipmentCreatDlg:levelCondition(sender, value)
    local ret = value % 10 == 0
    if not ret then
        gf:ShowSmallTips(CHS[4100482])
    end

    return ret
end

function GMEquipmentCreatDlg:getLevel()
    local value = GMMgr:getEditBoxValue(self, "LevelNumPanel")
    return tonumber(value)
end

function GMEquipmentCreatDlg:getRebuildLevel()
    local value = GMMgr:getEditBoxValue(self, "UpgradeLevelNumPanel")
    return tonumber(value)
end

function GMEquipmentCreatDlg:getAttribByColor(color)
    local str = ""

    local attColor = self.selectEquipAttribs[color]
    if color == "blue" then
        if attColor["blue1"] and attColor["blue1value"] then
            str = attColor["blue1"] .. ":" .. attColor["blue1value"]
        end

        if attColor["blue2"] and attColor["blue2value"] then
            if str ~= "" then str = str .. "|" end
            str = str .. attColor["blue2"] .. ":" .. attColor["blue2value"]
        end

        if attColor["blue3"] and attColor["blue3value"] then
            if str ~= "" then str = str .. "|" end
            str = str .. attColor["blue3"] .. ":" .. attColor["blue3value"]
        end

       if EquipmentMgr:isJewelry(self.selectEquipType) then
            if attColor["blue4"] and attColor["blue4value"] then
                if str ~= "" then str = str .. "|" end
                str = str .. attColor["blue4"] .. ":" .. attColor["blue4value"]
            end

            if attColor["blue5"] and attColor["blue5value"] then
                if str ~= "" then str = str .. "|" end
                str = str .. attColor["blue5"] .. ":" .. attColor["blue5value"]
            end
       end
    elseif color == "pink" then
        if attColor["pink"] and attColor["pinkvalue"] then
            str = attColor["pink"] .. ":" .. attColor["pinkvalue"]
        end
    elseif color == "yellow" then
        if attColor["yellow"] and attColor["yellowvalue"] then
            str = attColor["yellow"] .. ":" .. attColor["yellowvalue"]
        end
    elseif color == "green" then
        if attColor["green"] and attColor["greenvalue"] then
            str = attColor["green"] .. ":" .. attColor["greenvalue"]
        end
    elseif color == "black" then
        if attColor["black"] and attColor["blackvalue"] then
            str = attColor["black"] .. ":" .. attColor["blackvalue"]
        end
    elseif color == "gongming" then
        if attColor["gongming"] and attColor["gongming"] then
            str = attColor["gongming"]
        end
    end

    return str
end

function GMEquipmentCreatDlg:checkOK()
    if not self.selectEquipType or not self.selectEquipAttribs then return false end

    if next(self.selectEquipAttribs["black"]) and not next(self.selectEquipAttribs["green"]) then return false end
    if not next(self.selectEquipAttribs["black"]) and next(self.selectEquipAttribs["green"]) then return false end

    if not next(self.selectEquipAttribs["black"])
        and not next(self.selectEquipAttribs["green"])
        and not next(self.selectEquipAttribs["blue"])
        and not next(self.selectEquipAttribs["pink"])
        and not next(self.selectEquipAttribs["yellow"]) then
            return false
        end

    return true
end

function GMEquipmentCreatDlg:onConfirmButton(sender, eventType)
    if not self:checkOK() then
        gf:ShowSmallTips(CHS[4200246])
        return
    end

    local equipType = self.selectEquipType.title
    local level = self:getLevel()
    local rebuildLevel = self:getRebuildLevel()

    local blue = self:getAttribByColor("blue")
    local pink = self:getAttribByColor("pink")
    local yellow = self:getAttribByColor("yellow")
    local green = self:getAttribByColor("green")
    local black = self:getAttribByColor("black")
    local gongming = self:getAttribByColor("gongming")
    if gongming ~= "" then
        -- 选取了共鸣属性，需要:改造等级>=4，有率属性，70级以上时，才可以生成
        if (rebuildLevel and tonumber(rebuildLevel) < 4) or green == "" or tonumber(level) < 70 then
            gf:ShowSmallTips(CHS[7190142])
            return
        end
    end

    GMMgr:setAdminMakeEquip(equipType, level, rebuildLevel, blue, pink, yellow, green, black, gongming)
end

function GMEquipmentCreatDlg:onRefineButton(sender, eventType)
    local isVisible = self:getCtrlVisible("TempletPanel")
    self:setCtrlVisible("TempletPanel", not isVisible)
end

return GMEquipmentCreatDlg
