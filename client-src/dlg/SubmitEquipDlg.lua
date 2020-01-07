-- SubmitEquipDlg.lua
-- Created by zhengjh May/27/2016
-- 装备提交框
local EquipmentAtt = require(ResMgr:getCfgPath("EquipmentAttribute.lua"))
local SubmitEquipDlg = Singleton("SubmitEquipDlg", Dialog)
local COLUNM = 3
local SPACE = 14

local POLAR_CONFIG =
{
    [POLAR.METAL] = CHS[3002405],
    [POLAR.WOOD] = CHS[3002406],
    [POLAR.WATER] = CHS[3002407],
    [POLAR.FIRE] = CHS[3002408],
    [POLAR.EARTH] = CHS[3002409],
}

local MATERIALATT = {
    [EQUIP.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},

    [EQUIP.BACK_BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.BACK_NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.BACK_LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.BACK_RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
}


function SubmitEquipDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)
    local equipPanel = self:getControl("EquipPanel")
    self.itemCell = self:getControl("EquipShapePanel", nil, equipPanel)
    self.itemSelectImg = self:getControl("ChoseImage", Const.UIImage, equipPanel)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()

    self.itemCell:retain()
    self.itemCell:removeFromParent()

    self:hookMsg("MSG_UPGRADE_INHERIT_PREVIEW")
end

function SubmitEquipDlg:setData(equipList, type, conPrompt)
    local panel = self:getControl("EquipPanel")
    self:initList(panel, equipList)

    self.type = type
    self.conPrompt = conPrompt

    self:doTypeUI()
end

function SubmitEquipDlg:doTypeUI()
    local type = self.type
    if not type then
        return
    end

    if type == Const.BUYBACK_TYPE_EQUIPMENT then
        self:setLabelText("Label_1", CHS[5420164], "TitlePanel")
        self:setLabelText("Label_2", CHS[5420164], "TitlePanel")
    end
end

function SubmitEquipDlg:initList(panel, data)
    panel:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local count = #data
    local cellColne = self.itemCell:clone()
    local line = math.floor(count / COLUNM)
    local left =  count % COLUNM

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + SPACE)

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUNM
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * COLUNM
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * cellColne:getContentSize().width + j * SPACE
            local y = totalHeight - ((i - 1) * cellColne:getContentSize().height + i * SPACE)
            cell:setPosition(x, y)
            self:setCellData(cell, data[tag])
            contentLayer:addChild(cell)

            -- 默认选中第一个
            if tag == 1 then
                self:seleceltItem(cell, data[tag])
            end
        end
    end

    contentLayer:setContentSize(panel:getContentSize().width, totalHeight)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(panel:getContentSize())
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)
    scroview:setClippingEnabled(true)
    scroview:setBounceEnabled(true)

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end

    panel:addChild(scroview)
end

function SubmitEquipDlg:setCellData(cell, equip)
    -- 设置等级
    local levelPanel = self:getControl("EquipmentLevelPanel", nil, cell)
    if  equip.req_level and 0 ~= equip.req_level then
        self:setNumImgForPanel(levelPanel, ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
    elseif equip.level and 0 ~= equip.level then
        self:setNumImgForPanel(levelPanel, ART_FONT_COLOR.NORMAL_TEXT, equip.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 设置图标
    local iconPath = ResMgr:getItemIconPath(equip.icon)
    self:setImage("EquipmentImage", iconPath, cell)
    self:setItemImageSize("EquipmentImage", cell)

    -- 图标左下角限制交易/限时标记
    local imgCtrl = self:getControl("EquipmentImage", nil, cell)
    if equip and InventoryMgr:isTimeLimitedItem(equip) then
        InventoryMgr:removeLogoBinding(imgCtrl)
        InventoryMgr:addLogoTimeLimit(imgCtrl)
    elseif equip and InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:removeLogoTimeLimit(imgCtrl)
        InventoryMgr:addLogoBinding(imgCtrl)
    else
        InventoryMgr:removeLogoTimeLimit(imgCtrl)
        InventoryMgr:removeLogoBinding(imgCtrl)
    end

    -- 法宝显示相性
    local iconImage = self:getControl("EquipmentImage", nil, cell)
    InventoryMgr:removeArtifactPolarImage(iconImage)
    if equip.item_polar then
        InventoryMgr:addArtifactPolarImage(iconImage, equip.item_polar)
    end

    local function touch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:seleceltItem(sender, equip)
        end
    end

    cell:addTouchEventListener(touch)
end

function SubmitEquipDlg:seleceltItem(cell, equip)
    self:addItemSelcelImage(cell)
    self.selectEquip = equip
    local type = EquipmentMgr:GetEquipType(equip.equip_type)

    self:setCtrlVisible("EquipInfoPanel", false)
    self:setCtrlVisible("JewleyInfoPanel", false)
    self:setCtrlVisible("ArtifactInfoPanel", false)
    self:setCtrlVisible("FashionDressInfoPanel", false)

    if type == 1 then
        -- 装备
        self:setSelectEquipInfo(equip)
        self:setCtrlVisible("EquipInfoPanel", true)
    elseif type == 2 then
        -- 首饰
        self:setSelectJewelryInfo(equip)
        self:setCtrlVisible("JewleyInfoPanel", true)
    elseif type == 4 then
        -- 法宝
        self:setSelectArtifactInfo(equip)
        self:setCtrlVisible("ArtifactInfoPanel", true)
    elseif type == 3 then
        self:setCtrlVisible("FashionDressInfoPanel", true)
        self:setSelectFashionInfo(equip)
    end
end

function SubmitEquipDlg:setSelectEquipInfo(equip)
    local equipItemPanel = self:getControl("EquipItemPanel", nil, "EquipInfoPanel")
    local shapPanel = self:getControl("EquipShapePanel", nil, equipItemPanel)

    -- 设置等级
    local levelPanel = self:getControl("EquipmentLevelPanel", nil, shapPanel)
    if equip.req_level and 0 ~= equip.req_level then
        self:setNumImgForPanel(levelPanel, ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 设置图标
    local iconPath = ResMgr:getItemIconPath(equip.icon, nil, shapPanel)
    self:setImage("EquipmentImage", iconPath, shapPanel)
    self:setItemImageSize("EquipmentImage", shapPanel)


        -- 改造
    local rebuldLevel = equip.rebuild_level
    local degree = equip["degree_32"]
    local degreeStr = ""
    local rebuildStr = ""
    if degree and degree ~= 0 then
        local degressFloatValue = math.floor(equip["degree_32"] / 100) *100 / 1000000
        degreeStr = string.format("(+%0.4f%%)", degressFloatValue)
        rebuildStr = string.format("%d%s", equip.rebuild_level, degreeStr)

    else
        rebuildStr = string.format("%d", equip.rebuild_level)
    end
    self:setLabelText("UpgradeLevel", CHS[4101116] .. rebuildStr, equipItemPanel, COLOR3.TEXT_DEFAULT)

    -- 图标左下角限制交易/限时标记
    local imgCtrl = self:getControl("EquipmentImage", nil, shapPanel)
    if equip and InventoryMgr:isTimeLimitedItem(equip) then
        InventoryMgr:removeLogoBinding(imgCtrl)
        InventoryMgr:addLogoTimeLimit(imgCtrl)
    elseif equip and InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:removeLogoTimeLimit(imgCtrl)
        InventoryMgr:addLogoBinding(imgCtrl)
    else
        InventoryMgr:removeLogoTimeLimit(imgCtrl)
        InventoryMgr:removeLogoBinding(imgCtrl)
    end

    if equip.name == CHS[6400074] then -- 鸾凤宝玉
        local pos = gf:findStrByByte(equip.alias, CHS[3002818])
        if pos then
            self:setLabelText("MainLabel2", gf:getRealName(string.sub(equip.alias, pos + 2, -1)), "EquipInfoPanel")
        else
            self:setLabelText("MainLabel2", "", "EquipInfoPanel")
        end
    else
        self:setLabelText("MainLabel2", self:getRequire(equip), "EquipInfoPanel")
    end

    local color = InventoryMgr:getItemColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, "EquipInfoPanel", color)


    -- 获取装备名称颜色         各个颜色属性
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)
    local blueAttTab = self:getColorAtt(blueTab, "blue", equip)
    local pinkAttTab = self:getColorAtt(pinkTab, "pink", equip)
    local yellowAttTab = self:getColorAtt(yellowTab, "yellow", equip)
    local greenAttTab = self:getColorAtt(greenTab, "green", equip)
    local upgradeTab = EquipmentMgr:getUpgradeAtt(equip)
    local attribTab = self:getBaseAtt(equip)
    attribTab = self:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)

    local limitTab = InventoryMgr:getLimitAtt(equip, self:getControl("BaseAttributeLabel13", nil, "EquipInfoPanel"))

    local gongmingTab = EquipmentMgr:getGongmingValueAndColor(equip)

    local allAttribTab = {}
    for _,v in pairs(attribTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(blueAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(pinkAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(yellowAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(greenAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(upgradeTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(gongmingTab) do
        table.insert(allAttribTab, v)
    end

    for _, v in pairs(limitTab) do
        table.insert(allAttribTab, v)
    end

    local count = #allAttribTab
    local showCount = 0

    for i = 1, 16 do
        local desPanel = self:getControl("BaseAttributePanel" .. i, nil, "EquipInfoPanel")
        if i > count then

            self:setCtrlVisible("BaseAttributePanel" .. i, false, "EquipInfoPanel")
        else
            if desPanel then
                showCount = showCount + 1
                self:setCtrlVisible("BaseAttributePanel" .. i, true, "EquipInfoPanel")
                self:setDescript(allAttribTab[i].str, desPanel, allAttribTab[i].color, "equip")
            end
        end
    end

    local desPanel = self:getControl("BaseAttributePanel1", nil, "EquipInfoPanel")
    local height = desPanel:getContentSize().height
    local mainPanel = self:getControl("MainPanel", nil, "EquipInfoPanel")
    mainPanel:setContentSize(mainPanel:getContentSize().width, showCount * (height + 5) + 5)

    local listView = self:getControl("InfoListView", nil, "EquipInfoPanel")
    listView:setInnerContainerSize(mainPanel:getContentSize())
    mainPanel:requestDoLayout()
end

function SubmitEquipDlg:getRequire(equip)
    if equip.equip_type == EQUIP_TYPE.WEAPON then
        return CHS[3002412] .. POLAR_CONFIG[equip.polar] .. CHS[3002413]
    elseif equip.equip_type == EQUIP_TYPE.HELMET then
        --[[
        if equip.req_level == 100 then
            return CHS[3002414]
        end
        --]]
        if equip.gender == 1 then
            return CHS[3002415]
        elseif equip.gender == 2 then
            return CHS[3002416]
        else
            return CHS[3002414]
        end
    elseif equip.equip_type == EQUIP_TYPE.ARMOR then
        if equip.gender == 1 then
            return CHS[3002415]
        elseif equip.gender == 2 then
            return CHS[3002416]
        else
            return CHS[3002414]
        end
    elseif equip.equip_type == EQUIP_TYPE.BOOT then
        return CHS[3002417]
    else
        return ""
    end
end

-- 获取装备改造属性
function SubmitEquipDlg:getColorAtt(attTab, colorStr, equip)
    local destTab = {}
    local color
    local maxValue
    local colorType = 0         -- 蓝、粉、金   需要显示强化完成度
    if colorStr == "blue" then
        color = COLOR3.EQUIP_BLUE
        colorType = 1
    elseif colorStr == "pink" then
        color = COLOR3.EQUIP_PINK
        colorType = 2
    elseif colorStr == "yellow" then
        color = COLOR3.YELLOW
        colorType = 3
    elseif colorStr == "green" then
        color = COLOR3.EQUIP_GREEN
    elseif colorStr == "upgrade" then
        color = COLOR3.EQUIP_BLUE
    end
    --]]
    for i, att in pairs(attTab) do
        local bai = ""
        if EquipmentAtt[CHS[3002425]][att.field] then bai = "%" end

        if EquipmentAtt[att.field] ~= nil then
            local str = EquipmentAtt[att.field] .. " " .. att.value .. bai
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""
            if colorStr == "green" and att.dark == 1 then
                -- 绿属性最大值和其他不一样
                local min , max = EquipmentMgr:getSuitMinAndMax(equip, att.field)
                maxValue = max or maxValue
                -- 绿属性未激活未灰色
                if not equip.suit_enabled or equip.suit_enabled == 0 then
                    color = COLOR3.EQUIP_BLACK
                end
            end
            -- 提交界面不显示强化进度，会换行，与张骋确认，装备继承任务
            --[[
            local completion = EquipmentMgr:getAttribCompletion(equip, att.field, colorType)
            if colorType ~= 0 and completion and completion ~= 0 then
                str = str .. "/" .. maxValue .. bai .. " #R(+" .. completion * 0.01 .. "%)#n"
                table.insert(destTab, {str = str, color = color, basic = 1})
            else
                str = str .. "/" .. maxValue .. bai
                table.insert(destTab, {str = str, color = color})
            end
            --]]
            str = str .. "/" .. maxValue .. bai
            table.insert(destTab, {str = str, color = color})
        end
    end

    return destTab
end

function SubmitEquipDlg:getBaseAtt(equip)
    local baseAtt = {}
    local color = COLOR3.BROWN
    if equip.equip_type == EQUIP.WEAPON then
        -- CHS[4000032]:伤害
        local basePower = equip.extra.phy_power_1 or 0
        local attChs = CHS[4000032]
        table.insert(baseAtt, {attChs = attChs, value = basePower, color = color, field = "phy_power", basic = 1})

        return baseAtt
    end

    -- CHS[4000091]:防御
    local defValue = equip.extra.def_1 or 0
    local defChs = CHS[4000091]
    if equip.extra.def_1 then
        table.insert(baseAtt, {attChs = defChs,value = equip.extra.def_1, color = color, field = "def", basic = 1})
    end

    -- 最大气血
    local lifeStr = ""
    if equip.extra.max_life_1 ~= nil then
        table.insert(baseAtt, {attChs = CHS[3002422], value = equip.extra.max_life_1, color = color, field = "max_life", basic = 1})
    end

    -- 最大魔法
    local manaStr = ""
    if equip.extra.max_life_1 ~= nil then
        table.insert(baseAtt, {attChs = CHS[3002423], value = equip.extra.max_mana_1, color = color, field = "max_mana", basic = 1})
    end

    -- 速度
    local speedStr = ""
    if equip.extra.speed_1 ~= nil then
        table.insert(baseAtt, {attChs = CHS[3002424], value = equip.extra.speed_1, color = color, field = "speed", basic = 1})
    end

    return baseAtt
end

function SubmitEquipDlg:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)
    local baseTab = {}
    for i = 1, #attribTab do
        local field = attribTab[i].field
        baseTab[i] = {}
        baseTab[i] = gf:deepCopy(attribTab[i])

        local isAdd = false
        for j = 1, #blueTab do
            if blueTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0) then
                    baseTab[i].value = baseTab[i].value + blueTab[j].value
                    isAdd = true
                end
            end
            if field == blueTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + blueTab[j].value
                isAdd = true
            end
        end

        for j = 1, #pinkTab do
            if pinkTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0)  then
                    baseTab[i].value = baseTab[i].value + pinkTab[j].value
                    isAdd = true
                end
            end
            if field == pinkTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + pinkTab[j].value
                isAdd = true
            end
        end

        for j = 1, #yellowTab do
            if yellowTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0)  then
                    baseTab[i].value = baseTab[i].value + yellowTab[j].value
                    isAdd = true
                end
            end
            if field == yellowTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + yellowTab[j].value
                isAdd = true
            end
        end

        for j = 1, #upgradeTab do
            if field == upgradeTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + upgradeTab[j].value
                isAdd = true
            end
        end

        baseTab[i].str = attribTab[i].attChs .. ":" .. baseTab[i].value
        if isAdd or baseTab[i]["phy_power_isTotal"] == 1 or baseTab[i][field .. "_isTotal"] == 1 then
            baseTab[i].str = attribTab[i].attChs .. ":#B" .. baseTab[i].value .. "#n"
        end
    end

    return baseTab
end

function SubmitEquipDlg:setSelectJewelryInfo(jewelry)
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(jewelry.icon), "JewleyInfoPanel")
    self:setItemImageSize("EquipmentImage", "JewleyInfoPanel")
    local image = self:getControl("EquipmentImage", nil, "JewleyInfoPanel")
    -- 图标左下角限制交易/限时标记
    if jewelry and InventoryMgr:isTimeLimitedItem(jewelry) then
        InventoryMgr:removeLogoBinding(image)
        InventoryMgr:addLogoTimeLimit(image)
    elseif jewelry and InventoryMgr:isLimitedItem(jewelry) then
        InventoryMgr:removeLogoTimeLimit(image)
        InventoryMgr:addLogoBinding(image)
    else
        InventoryMgr:removeLogoTimeLimit(image)
        InventoryMgr:removeLogoBinding(image)
    end

    self:setNumImgForPanel(
        "EquipmentLevelPanel",
        ART_FONT_COLOR.NORMAL_TEXT,
        jewelry.req_level,
        false,
        LOCATE_POSITION.LEFT_TOP, 21, "JewleyInfoPanel"
    )

    self:setLabelText("EquipmentNameLabel", jewelry.name, "JewleyInfoPanel")

    local jtype = jewelry.equip_type
    if jtype == EQUIP.BALDRIC then
        self:setLabelText("MainLabel2", CHS[3002877], "JewleyInfoPanel")
    elseif jtype == EQUIP.NECKLACE then
        self:setLabelText("MainLabel2", CHS[3002878], "JewleyInfoPanel")
    elseif jtype == EQUIP.LEFT_WRIST then
        self:setLabelText("MainLabel2", CHS[3002879], "JewleyInfoPanel")
    elseif jtype == EQUIP.RIGHT_WRIST then
        self:setLabelText("MainLabel2", CHS[3002879], "JewleyInfoPanel")
    end

    local attValueStr = string.format("%s_%d", MATERIALATT[jtype].field, Const.FIELDS_NORMAL)
    local attValue = jewelry.extra[attValueStr] or jewelry.fromCardValue or 0

    local totalAtt = {}
    local funStr = string.format("%s: %d", MATERIALATT[jtype].att, attValue)
    table.insert(totalAtt, {str = funStr, color = COLOR3.LIGHT_WHITE})

    local blueAtt = EquipmentMgr:getJewelryBule(jewelry)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end

    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(jewelry)
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = limitTab[1].color})
    end

    for i = 1, 8 do
        if totalAtt[i] then
            self:setLabelText("AttribLabel" .. i, totalAtt[i].str, nil, totalAtt[i].color, "JewleyInfoPanel")
        else
            self:setLabelText("AttribLabel" .. i, "", "JewleyInfoPanel")
        end
    end

    -- 总高度自适应
    local cou = #totalAtt
    local mainPanel = self:getControl("MainPanel", nil, "JewleyInfoPanel")
    local size = mainPanel:getContentSize()
    mainPanel:setContentSize(size.width, (25 + 7) * cou + 10)
    mainPanel:requestDoLayout()

    local listView = self:getControl("InfoListView", nil, "JewleyInfoPanel")
    listView:requestRefreshView()
    listView:doLayout()
end

function SubmitEquipDlg:setSelectFashionInfo(equip)
    local equipItemPanel = self:getControl("FashionDressInfoPanel")
    local shapPanel = self:getControl("EquipShapePanel", nil, equipItemPanel)

    -- 设置图标
    local iconPath = ResMgr:getItemIconPath(equip.icon, nil, shapPanel)
    self:setImage("EquipmentImage", iconPath, shapPanel)
    self:setItemImageSize("EquipmentImage", shapPanel)

    -- 图标左下角限制交易/限时标记
    local imgCtrl = self:getControl("EquipmentImage", nil, shapPanel)
    if equip and InventoryMgr:isTimeLimitedItem(equip) then
        InventoryMgr:removeLogoBinding(imgCtrl)
        InventoryMgr:addLogoTimeLimit(imgCtrl)
    elseif equip and InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:removeLogoTimeLimit(imgCtrl)
        InventoryMgr:addLogoBinding(imgCtrl)
    else
        InventoryMgr:removeLogoTimeLimit(imgCtrl)
        InventoryMgr:removeLogoBinding(imgCtrl)
    end

    -- 鸾凤宝玉,龙凤呈祥服·新娘，龙凤呈祥服·新郎
    if equip.name == CHS[6400074] or equip.name == CHS[7100167] or equip.name == CHS[7100168]  then
        self:setLabelText("EquipmentNameLabel", equip.name, equipItemPanel, COLOR3.YELLOW)

        if equip.name == CHS[6400074] then
            local pos = gf:findStrByByte(equip.alias, CHS[3002818])
            if pos then
                self:setLabelText("MainLabel2", gf:getRealName(string.sub(equip.alias, pos + 2, -1)), equipItemPanel)
            else
                self:setLabelText("MainLabel2", "", equipItemPanel)
            end
        end
    else
        local color = InventoryMgr:getItemColor({color = equip.color})
        if equip.alias and equip.alias ~= "" then
            self:setLabelText("EquipmentNameLabel", equip.alias, equipItemPanel, color)
        else
            self:setLabelText("EquipmentNameLabel", equip.name, equipItemPanel, color)
        end

        -- 性别
        self:setLabelText("MainLabel2", string.format(CHS[4200490], gf:getGenderChs(equip.gender)),equipItemPanel)
    end

    -- 描述
    local panelDesc = self:getControl("DescPanel", nil, equipItemPanel)
    local oldSize = panelDesc:getContentSize()
    local height1 = self:setDescript(InventoryMgr:getDescript(equip.name) , panelDesc)
    panelDesc:setContentSize(panelDesc:getContentSize().width, height1)


    -- 限制交易
    local limitTab = InventoryMgr:getLimitAtt(equip)
    if limitTab[1] then
        self:setLabelText("ExChangeLabel", limitTab[1].str or "", equipItemPanel, limitTab[1].color)
    else
        self:setLabelText("ExChangeLabel", "", equipItemPanel)
    end

    local limitHeight = 0
    -- 限时交易
    if InventoryMgr:isTimeLimitedItem(equip) then
        local timeLimitStr = "至" .. gf:getServerDate(CHS[4200022], equip.deadline)

        self:setLabelText("LimittimeLabel", "限时", equipItemPanel)
        self:setLabelText("LimittimeLabel_1", timeLimitStr, equipItemPanel)

    else
        self:setLabelText("LimittimeLabel", "", equipItemPanel)
        self:setLabelText("LimittimeLabel_1", "", equipItemPanel)
    end

    -- 总高度自适应
    local mainPanel = self:getControl("MainPanel", nil, equipItemPanel)
    local size = mainPanel:getContentSize()
    mainPanel:setContentSize(size.width, size.height + (height1 - oldSize.height))
    mainPanel:requestDoLayout()

    local listView = self:getControl("InfoListView", nil, equipItemPanel)
    listView:requestRefreshView()
    listView:doLayout()
end

-- 刷新右侧法宝详细信息
function SubmitEquipDlg:setSelectArtifactInfo(artifact)
    -- 法宝图标
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(artifact.name), "ArtifactInfoPanel")
    self:setItemImageSize("EquipmentImage", "ArtifactInfoPanel")

    -- 图标左上角等级
    self:setNumImgForPanel("EquipmentLevelPanel", ART_FONT_COLOR.NORMAL_TEXT,
        artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, "ArtifactInfoPanel")

    -- 图标右下角相性标志
    local iconImage = self:getControl("EquipmentImage", nil, "ArtifactInfoPanel")
    InventoryMgr:removeArtifactPolarImage(iconImage)
    if artifact.item_polar then
        InventoryMgr:addArtifactPolarImage(iconImage, artifact.item_polar)
    end

    -- 图标左下角限制交易/限时标记
    if artifact and InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:removeLogoBinding(iconImage)
        InventoryMgr:addLogoTimeLimit(iconImage)
    elseif artifact and InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:removeLogoTimeLimit(iconImage)
        InventoryMgr:addLogoBinding(iconImage)
    else
        InventoryMgr:removeLogoTimeLimit(iconImage)
        InventoryMgr:removeLogoBinding(iconImage)
    end

    -- 法宝名称
    self:setLabelText("EquipmentNameLabel", artifact.name, "ArtifactInfoPanel", COLOR3.YELLOW)

    -- 法宝特殊技能名称与等级
    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if artifactSpSkillName then
        local artifactSpSkillLevel = tonumber(artifact.extra_skill_level)
        self:setLabelText("MainLabel2", artifactSpSkillName .. "     " .. string.format(CHS[2000131], artifactSpSkillLevel), "ArtifactInfoPanel", COLOR3.LIGHT_BROWN)
    else
        self:setLabelText("MainLabel2", CHS[7000329], "ArtifactInfoPanel", COLOR3.GRAY)
    end

    -- 道法、灵气、亲密度、金相
    local daoFa = string.format(CHS[7000190], artifact.exp or 0, artifact.exp_to_next_level or 0)
    local lingQi = string.format(CHS[7000190], artifact.nimbus or 0, Formula:getArtifactMaxNimbus(artifact.level or 0))
    local qinMiDu = artifact.intimacy or 0
    local polarAttrib = EquipmentMgr:getPolarAttribByArtifact(artifact)
    self:setLabelText("DaoFaLabel2", daoFa, "ArtifactInfoPanel")
    self:setLabelText("LingqiLabel2", lingQi, "ArtifactInfoPanel")
    self:setLabelText("QinmiduLabel2", qinMiDu, "ArtifactInfoPanel")
    self:setLabelText("PolarLabel2", polarAttrib, "ArtifactInfoPanel")
    self:setLabelText("PolarLabel1", string.format(CHS[7000183], gf:getPolar(artifact.item_polar)), "ArtifactInfoPanel")

    -- 法宝技能
    local descPanel1 = self:getControl("DescPanel1", nil, "ArtifactInfoPanel")
    local descPanel2 = self:getControl("DescPanel2", nil, "ArtifactInfoPanel")

    local desc1 = string.format(CHS[7000151], CHS[7000152]) .. CHS[7000078] .. EquipmentMgr:getArtifactSkillDesc(artifact.name)
    local height1 = self:setDescript(desc1, descPanel1, COLOR3.TEXT_DEFAULT)
    descPanel1:setContentSize(descPanel1:getContentSize().width, height1)

    -- 特殊技能
    local desc2
    if artifact.extra_skill and artifact.extra_skill ~= "" then
        local extraSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
        local extraSkillLevel = artifact.extra_skill_level
        local extraSkillDesc = SkillMgr:getSkillDesc(extraSkillName).desc
        desc2 = string.format(CHS[7000311], extraSkillName, extraSkillLevel)
            .. CHS[7000078] .. extraSkillDesc
    else
        desc2 = string.format(CHS[7000151], CHS[7000153]) .. CHS[7000078]
            .. CHS[3001385] .. "\n" .. CHS[7002016]
    end

    local height2 = self:setDescript(desc2, descPanel2, COLOR3.TEXT_DEFAULT)
    descPanel2:setContentSize(descPanel2:getContentSize().width, height2)

    -- 限制交易时间
    local bindLabel = self:getControl("BindLabel", nil, "ArtifactInfoPanel")
    local bindLabelHeight = bindLabel:getContentSize().height
    local height3 = 0
    if InventoryMgr:isLimitedItem(artifact) then
        local str, day = gf:converToLimitedTimeDay(artifact.gift)
        self:setLabelText("BindLabel", str, "ArtifactInfoPanel")
        height3 = bindLabelHeight + 5
    else
        self:setLabelText("BindLabel", "", "ArtifactInfoPanel")
    end

    -- 总高度自适应
    local offset = height1 + height2 + height3
    local mainPanel = self:getControl("MainPanel", nil, "ArtifactInfoPanel")
    mainPanel:setContentSize(mainPanel:getContentSize().width, 140 + offset)
    mainPanel:requestDoLayout()
    mainPanel:retain()

    local listView = self:getControl("InfoListView", nil, "ArtifactInfoPanel")
    listView:removeAllChildren()
    listView:pushBackCustomItem(mainPanel)
    mainPanel:release()
end

function SubmitEquipDlg:setDescript(descript, panel, defaultColor, type)
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then
        textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b)
    end

    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居左显示
    local textW, textH = textCtrl:getRealSize()
    if type == "equip" then
        textCtrl:setPosition((size.width - textW) * 0.5, size.height - (size.height - 19) * 0.5)
    else
        textCtrl:setPosition(0, textH)
    end

    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    return textH
end

function SubmitEquipDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)
end

function SubmitEquipDlg:isMeetConditionForInherit()
        -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 角色等级达到#R70级#n后开放改造继承功能。
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200158])
        return
    end

    -- 限时装备不可进行此操作。
    if InventoryMgr:isTimeLimitedItem(self.selectEquip) then
        gf:ShowSmallTips(CHS[4101130])
        return
    end

    -- 永久限制交易装备无法进行改造继承。
    if InventoryMgr:isLimitedItemForever(self.selectEquip) then
        gf:ShowSmallTips(CHS[4101131])
        return
    end

    local mEquip = InventoryMgr:getItemByPos(self.conPrompt)
    local mLevel = mEquip.rebuild_level or 0
    local oLevel = self.selectEquip.rebuild_level or 0
    if oLevel <= mLevel then
        gf:ShowSmallTips(CHS[4101134])
        return
    end

    return true
end


function SubmitEquipDlg:onSubmitButton(sender, eventType)
    if not self.selectEquip then return end

    if self.type == Const.BUYBACK_TYPE_EQUIPMENT then
        gf:CmdToServer("CMD_DESTROY_VALUABLE",
                           {type = Const.BUYBACK_TYPE_EQUIPMENT, id = self.selectEquip.pos})

    elseif self.type == "EquipmentInheritDlg" then
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.conPrompt,
            type = Const.EQUIP_UPGRADE_INHERIT_SELECT,
            para = tostring(self.selectEquip.pos),
        })

        DlgMgr:sendMsg("EquipmentInheritDlg", "setCheckData", self.conPrompt .. self.selectEquip.pos)
        DlgMgr:closeDlg(self.name)
    else
        -- 处于禁闭状态
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        if DlgMgr:isDlgOpened("ArtifactPracticeDlg") then
            -- 法宝修炼界面，提交不需要提示
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SUBMIT_EQUIP, self.selectEquip.item_unique)
            DlgMgr:closeDlg(self.name)
            return
        end

        local selectEquip = self.selectEquip        -- 先记录，否则进入战斗该值会被清除
        if not string.isNilOrEmpty(self.conPrompt) then
            gf:confirm(string.gsub(self.conPrompt, "EQUIP_NAME", selectEquip.name), function ()
                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SUBMIT_EQUIP, selectEquip.item_unique)
                DlgMgr:closeDlg(self.name)
            end, nil)
        else
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SUBMIT_EQUIP, selectEquip.item_unique)
            DlgMgr:closeDlg(self.name)
        end
    end

end

function SubmitEquipDlg:cleanup()
    self:releaseCloneCtrl("itemCell")
    self:releaseCloneCtrl("itemSelectImg")
    self.selectEquip = nil
end

function SubmitEquipDlg:MSG_UPGRADE_INHERIT_PREVIEW(data)
    if self.type ~= "EquipmentInheritDlg" then return end

    if data.flag == 1 then
        self:onCloseButton()
        return
    end
end

return SubmitEquipDlg
