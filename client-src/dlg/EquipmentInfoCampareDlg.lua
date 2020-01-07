-- EquipmentInfoCampareDlg.lua
-- Created by
--

local EquipmentInfoCampareDlg = Singleton("EquipmentInfoCampareDlg", Dialog)
local EquipmentAtt = require(ResMgr:getCfgPath("EquipmentAttribute.lua"))
local EquipAllAtt = require(ResMgr:getCfgPath("EquipAttribute.lua"))

local menuMore = {
    [1] = {},
    [2] = {},
}

local MORE_BTN = {
    CHS[3002440],
    CHS[3002441],
}

local BTN_FUNC = {
    [CHS[3002440]] = { normalClick = "onSell" },
    [CHS[7000301]] = { normalClick = "onBaitan" },
    [CHS[7000302]] = { normalClick = "onTreasureBaitan"},
    [CHS[3002816]] = {normalClick = "onSource"},
}

local POLAR_CONFIG =
    {
        [POLAR.METAL] = CHS[3002442],
        [POLAR.WOOD] = CHS[3002443],
        [POLAR.WATER] = CHS[3002444],
        [POLAR.FIRE] = CHS[3002445],
        [POLAR.EARTH] = CHS[3002446],
    }

local MARGIN = 2
local FONT_HEIGHT = 25

local MainPanelInitSize = nil
local RootInitSize = nil

function EquipmentInfoCampareDlg:init()

    if not MainPanelInitSize then
        MainPanelInitSize = {[1] = {}, [2] = {}}
        MainPanelInitSize[1] = self:getControl("MainPanel_1"):getContentSize()
        MainPanelInitSize[2] = self:getControl("MainPanel_2"):getContentSize()
    end

    if not RootInitSize then RootInitSize = self.root:getContentSize() end

    self:getControl("SourceButton", nil, "SourcePanel"):setTag(2)
    self:bindListener("SourceButton", self.onSource, "SourcePanel")
    for i = 1, 2 do
        local panel = self:getControl("MainPanel_" .. i)
        panel:setTag(i)
        self:bindListener("MoreOperateButton", self.onMoreOperateButton, panel)
        self:bindListener("OperateButton", self.onOperateButton, panel)
        self:bindTouchEndEventListener(panel, self.onCloseButton)

        self:getControl("ButtonPanel", nil, panel):setLocalZOrder(10)
        self:getControl("MoreOperateButton", nil ,panel):setTag(i)
        self:getControl("OperateButton", nil ,panel):setTag(i)
    end
    self:bindTouchEndEventListener(self.root, self.onCloseButton)

    self.equip = {}
    self.wearEquipAtt = {}

    self.btn = self:getControl("MoreOperateButton"):clone()
    self.btn:setAnchorPoint(0, 0)
    self.btn:retain()

    self.btnLayer = cc.Layer:create()
    self.btnLayer:setAnchorPoint(0, 0)
    self.btnLayer:retain()

    self.blank:setLocalZOrder(Const.ZORDER_FLOATING)

    self:hookMsg("MSG_INVENTORY")
end

function EquipmentInfoCampareDlg:cleanup()
    if self.btnLayer then
        self.btnLayer:release()
        self.btnLayer = nil
    end

    if self.btn then
        self.btn:release()
        self.btn = nil
    end

    self.isMore = nil
end

function EquipmentInfoCampareDlg:setMenuMore(isCard, equip, panel)
    local menuTab = {}
    local isInBag = equip.pos and InventoryMgr:isInBagByPos(equip.pos)
    if not isCard then
        if isInBag then
            table.insert(menuTab, CHS[3002440])
            if equip.req_level >= 50 then
                table.insert(menuTab, CHS[7000301])
            end

            -- 贵重物品增加珍宝摆摊选项
            if equip and gf:isExpensive(equip) and MarketMgr:isShowGoldMarket() then
                table.insert(menuTab, CHS[7000302])
            end
        end

        table.insert(menuTab, CHS[3002816])

        -- 不是名片，创建分享按钮
        self:createShareButton(self:getControl("ShareButton", nil, panel), SHARE_FLAG.EQUIPATTRIB)
    else
        self:setCtrlVisible("ShareButton", false, panel)
    end

    return menuTab
end

function EquipmentInfoCampareDlg:setFloatingCompareInfo(equip)
    local panel = self:getControl("MainPanel_1")
    local equip1 = InventoryMgr:getItemByPos(equip.equip_type)
    menuMore[1] = self:setMenuMore(not equip1.pos, equip1, panel)
    self:setFloatingFrameInfo(equip1, panel)
    self.equip[1] = equip1

    if #menuMore[1] == 1 and menuMore[1][1] == CHS[3002872] then
        self:setButtonText("MoreOperateButton", CHS[3002872], panel)
    end

    local panel2 = self:getControl("MainPanel_2")
    menuMore[2] = self:setMenuMore(not equip.pos, equip, panel2)
    self:setFloatingFrameInfo(equip, panel2, true)
    self.equip[2] = equip

    if #menuMore[2] == 1 and menuMore[2][1] == CHS[3002872] then
        self:setButtonText("MoreOperateButton", CHS[3002872], panel2)
    end

    local size1 = panel:getContentSize()
    local size2 = panel2:getContentSize()

    -- 两个装备对比框的偏移量，使得装备对比框能够相对root居中
    local maxHeight = math.max(size1.height, size2.height)
    local rect = {left = 0, rigth = 0, top = -maxHeight / 2, bottom = 0}
    panel:getLayoutParameter():setMargin(rect)
    panel2:getLayoutParameter():setMargin(rect)

    -- 设置root的高度为0是为了防止root遮挡住其他道具，使得点击其他道具无法生效
    local rootSize = self.root:getContentSize()
    self.root:setContentSize(rootSize.width, 0)
    self:align(ccui.RelativeAlign.centerInParent)
    self.root:requestDoLayout()
end

function EquipmentInfoCampareDlg:setUpgradeAndRequire(equip, panel)
    local mainInfo = EquipmentMgr:getMainInfoMap(equip)
    local count = #mainInfo
    for i = 1,2 do
        if i > count then
            self:setLabelText("MainLabel" .. i, "", panel)
        else
            self:setLabelText("MainLabel" .. i, mainInfo[i].str, panel, mainInfo[i].color)
        end
    end
end

function EquipmentInfoCampareDlg:setFloatingFrameInfo(equip, panel, isCompare)
    local size = panel:getContentSize()

    EquipmentMgr:setEvolveStar(self, equip, panel)

    -- 获取装备名称颜色         各个颜色属性
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)

    self:setCtrlVisible("WearImage", equip.pos and (equip.pos <= 10) and not isCompare, panel)
    self:setLabelText("EquipmentNameLabel", equip.name, panel, color)

    if equip.suit_polar ~= 0 and equip.color == CHS[3002454] then
        self:setImage("PolarImage", EquipmentMgr:getPolarRes(equip.suit_polar), panel)
    else
        self:setImagePlist("PolarImage", ResMgr.ui.touming, panel)
    end
    -- 图标
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name), panel)
    self:setItemImageSize("EquipmentImage", panel)
    self:setNumImgForPanel("EquipShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 是否可以交易标志， 暂时隐藏
    self:setCtrlVisible("ExChangeImage", false, self:getControl("EquipShapePanel", nil, panel))

    local imageCtl = self:getControl("EquipmentImage", nil, panel)
    if equip and InventoryMgr:isTimeLimitedItem(equip) then
        InventoryMgr:removeLogoBinding(imageCtl)
        InventoryMgr:addLogoTimeLimit(imageCtl)
    elseif equip and InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:removeLogoTimeLimit(imageCtl)
        InventoryMgr:addLogoBinding(imageCtl)
    else
        InventoryMgr:removeLogoTimeLimit(imageCtl)
        InventoryMgr:removeLogoBinding(imageCtl)
    end

    -- 贵重物品
    if gf:isExpensive(equip, false) then
        self:setCtrlVisible("PreciousImage", true, panel)
    else
        self:setCtrlVisible("PreciousImage", false, panel)
    end

    -- 设置改造和要求
    self:setUpgradeAndRequire(equip, panel)

    local blueAttTab = self:getColorAtt(blueTab, "blue", equip, panel)
    local pinkAttTab = self:getColorAtt(pinkTab, "pink", equip, panel)
    local yellowAttTab = self:getColorAtt(yellowTab, "yellow", equip, panel)
    local greenAttTab = self:getColorAtt(greenTab, "green", equip, panel)
    local upgradeTab = self:getUpgradeAtt(equip, panel)
    local attribTab = self:getBaseAtt(equip, isCompare)
    attribTab = self:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip, isCompare)
    local limitTab = InventoryMgr:getLimitAtt(equip, self:getControl("BaseAttributeLabel13"))
    local gongmingTab = EquipmentMgr:getGongmingValueAndColor(equip)

    -- 限时道具
    local timeLimit = {}
    if InventoryMgr:isTimeLimitedItem(equip) then

        local timeLimitStr
        if equip.isTimeLimitedReward then
            timeLimitStr = CHS[4100654]
        else
            timeLimitStr = string.format(CHS[7000184], gf:getServerDate(CHS[4200022], equip.deadline))
        end

        table.insert(timeLimit, {color = COLOR3.RED, str = timeLimitStr})
    end


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

    for _, v in pairs(timeLimit) do
        table.insert(allAttribTab, v)
    end


    local count = #allAttribTab
    local missCount = 0

    -- 设置属性
    -- 前三项是基础属性，如果快速切换，可能导致某些控件未被隐藏,先统一设置不可见
    for i = 1,16 do
        self:setLabelText("BaseAttributeLabel" .. i, "", panel)
        self:setCtrlVisible("BaseAttributePanel" .. i, false, panel)
    end

    for i = 1,16 do
        if i > count then
            missCount = missCount + 1
        else
            local desPanel = self:getControl("BaseAttributePanel" .. i, nil, panel)
            if desPanel then
                self:setCtrlVisible("BaseAttributePanel" .. i, true, panel)
                self:setDescript(allAttribTab[i].str, desPanel, allAttribTab[i].color, panel)
            else
                self:setLabelText("BaseAttributeLabel" .. i, allAttribTab[i].str, panel, allAttribTab[i].color)
            end

        end
    end


    local btn = self:getControl("MoreOperateButton", nil, panel)
    if not equip.pos then
        self:setCtrlVisible("ButtonPanel", false, panel)
    elseif (equip.pos <= 10) then
        self:setButtonText("OperateButton", CHS[3002455], panel)
    else
        self:setButtonText("OperateButton", CHS[3002456], panel)
    end

    if #menuMore[panel:getTag()] == 0 and not equip.pos then
        self:setCtrlVisible("SourcePanel", true, panel)
    else
        self:setCtrlVisible("SourcePanel", false, panel)
    end

    local tempHeight = 0
    if equip and equip.pos and equip.pos <= 10 then
        -- 穿的隐藏来源和卸下
        self:setCtrlVisible("MoreOperateButton", false, panel)
        self:setCtrlVisible("OperateButton", false, panel)

        tempHeight = self:getCtrlContentSize("OperateButton", panel).height
    end

    panel:setContentSize(size.width, MainPanelInitSize[panel:getTag()].height - (missCount) * (FONT_HEIGHT + MARGIN) - tempHeight)
    panel:requestDoLayout()
end

-- 获取改造属性
function EquipmentInfoCampareDlg:getUpgradeAtt(equip, panel)
    local attrTab = {}
    local color = COLOR3.EQUIP_BLUE
    if EQUIP_TYPE.WEAPON == equip.equip_type then
        if equip.extra.phy_power_10 and equip.extra.phy_power_10 ~= 0 then
            table.insert(attrTab, {str = CHS[3002457] .. equip.extra.phy_power_10, color = color, field = "phy_power", value = equip.extra.phy_power_10})
        end

        if equip.extra.all_attrib_10 and equip.extra.all_attrib_10 ~= 0 then
            table.insert(attrTab, {str = CHS[3002458]..equip.extra.all_attrib_10, color = color, field = "all_attrib", value = equip.extra.all_attrib_10})
        end

    else
        if equip.extra.def_10 and equip.extra.def_10~= 0 then
            table.insert(attrTab, {str = CHS[3002459]..equip.extra.def_10, color = color, field = "def", value = equip.extra.def_10})
        end

        if equip.extra.max_life_10 and equip.extra.max_life_10 ~= 0 then
            table.insert(attrTab, {str = CHS[3002460]..equip.extra.max_life_10, color = color, field = "max_life", value = equip.extra.max_life_10})
        end
    end

    return attrTab
end

-- 设置物品描绘信息
function EquipmentInfoCampareDlg:setDescript(descript, panel, color, mainPanel)
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:updateNow()
    --
    textCtrl:setDefaultColor(color.r, color.g, color.b)
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size.width - textW) * 0.5, size.height - (size.height - 19) * 0.5)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))

    mainPanel:requestDoLayout()
end

function EquipmentInfoCampareDlg:getBaseAtt(equip, isCompare)
    local baseAtt = {}
    local color = COLOR3.EQUIP_NORMAL
    local equipCompare = InventoryMgr:getItemByPos(equip.equip_type)
    if equip.equip_type == EQUIP.WEAPON then
        -- CHS[4000032]:伤害
        local basePower = equip.extra.phy_power_1 or 0
        local attChs = CHS[4000032]
        local str = string.format("%s: %d",attChs, basePower)
        local phy_power_isTotal = equip.extra.phy_power_isTotal or 0

        table.insert(baseAtt, {attChs = attChs, value = basePower, color = color, field = "phy_power", basic = 1, phy_power_isTotal = phy_power_isTotal})

        return baseAtt
    end

    -- CHS[4000091]:防御
    local defValue = equip.extra.def_1 or 0
    local defChs = CHS[4000091]
    local defStr = string.format("%s: %d",defChs, defValue)
    local def_isTotal = equip.extra.def_isTotal or 0

    table.insert(baseAtt, {attChs = defChs,value = defValue, color = color, field = "def", basic = 1, def_isTotal = def_isTotal})

    -- 最大气血
    local lifeStr = ""
    if equip.extra.max_life_1 ~= nil then
        lifeStr = string.format(CHS[3002461], equip.extra.max_life_1)
        local max_life_isTotal = equip.extra.max_life_isTotal or 0
        table.insert(baseAtt, {max_life_isTotal = max_life_isTotal, attChs = CHS[3002462], value = equip.extra.max_life_1, color = color, field = "max_life", basic = 1})
    end

    -- 最大魔法
    local manaStr = ""
    if equip.extra.max_mana_1 ~= nil then
        manaStr = string.format(CHS[3002463], equip.extra.max_mana_1)
        local max_mana_isTotal = equip.extra.max_mana_isTotal or 0
        table.insert(baseAtt, {max_mana_isTotal = max_mana_isTotal, attChs = CHS[3002464], value = equip.extra.max_mana_1, color = color, field = "max_mana", basic = 1})
    end

    -- 速度
    local speedStr = ""
    if equip.extra.speed_1 ~= nil then
        speedStr = string.format(CHS[3002465], equip.extra.speed_1)
        local speed_isTotal = equip.extra.speed_isTotal or 0
        table.insert(baseAtt, {speed_isTotal = speed_isTotal, attChs = CHS[3002466], value = equip.extra.speed_1, color = color, field = "speed", basic = 1})
    end

    return baseAtt
end

function EquipmentInfoCampareDlg:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip, isCompare)
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

        if isCompare then
            local wearEquipValue = self.wearEquipAtt[i] and self.wearEquipAtt[i].value or 0
            if baseTab[i].value - wearEquipValue >= 0 then
                baseTab[i].str = baseTab[i].str .. CHS[3002467] .. (baseTab[i].value - wearEquipValue) .. "#n"
            elseif baseTab[i].value - wearEquipValue < 0 then
                baseTab[i].str = baseTab[i].str .. CHS[3002468] .. (baseTab[i].value - wearEquipValue) .. "#n"
            end
        end
    end
    if not isCompare then
        self.wearEquipAtt = baseTab
    end
    return baseTab
end

-- 获取装备改造属性
function EquipmentInfoCampareDlg:getColorAtt(attTab, colorStr, equip, panel)
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
    end

    for i, att in pairs(attTab) do
        local bai = ""
        if EquipmentAtt[CHS[3002469]][att.field] then bai = "%" end

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
            local completion = EquipmentMgr:getAttribCompletion(equip, att.field, colorType)
            if colorType ~= 0 and completion and completion ~= 0 then
                str = str .. "/" .. maxValue .. bai .. " #R(+" .. completion * 0.01 .. "%)#n"
                table.insert(destTab, {str = str, color = color, basic = 1})
            else
                str = str .. "/" .. maxValue .. bai
                table.insert(destTab, {str = str, color = color})
            end
        end
    end

    return destTab
end

function EquipmentInfoCampareDlg:onMoreOperateButton(sender, eventType)
    local tag = sender:getTag()
    if CHS[3002872] == sender:getTitleText() then
        self.btnLayer:setTag(tag)
        self:onSource(sender)
        return
    end

    if not self.isMore or self.btnLayer:getTag() ~= tag then
        self.isMore = true
        self.btnLayer:removeAllChildren()
        local btnSize = self.btn:getContentSize()
        for i, v in pairs(menuMore[tag]) do
            local btn = self.btn:clone()
            btn:setTitleText(tostring(v))
            btn:setPosition(0, btnSize.height * i)
            self.btnLayer:addChild(btn)

            self:bindTouchEndEventListener(btn, function(self, sender, eventType)
                local title = sender:getTitleText()
                if BTN_FUNC[title].normalClick and "function" == type(self[BTN_FUNC[title].normalClick]) then
                    self[BTN_FUNC[title].normalClick](self, sender, eventType)
                end
            end)
        end
        self.btnLayer:setPosition(0, 0)
        self.btnLayer:removeFromParent()
        self.btnLayer:setTag(tag)
        sender:addChild(self.btnLayer)
    else
        self.isMore = false
        self.btnLayer:removeFromParent()
    end
end

function EquipmentInfoCampareDlg:onOperateButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002470])
        return
    end

    local str = sender:getTitleText()
    local tag = sender:getTag()
    if str == CHS[3002471] or str == CHS[3002456] then
        local index = 0
        if GuideMgr.equipList then
            for i, equip in ipairs(GuideMgr.equipList) do
                if self.equip[tag].item_unique == equip.equipId then
                    local wearEquip = InventoryMgr:getItemByPos(self.equip[tag].equip_type)
                    if wearEquip and self.equip[tag].req_level - wearEquip.req_level >= 9 then
                        -- 寻找到当前选择的装备是礼包的装备并且大于卸下的装备9级
                        index = i
                        DlgMgr:sendMsg("BagDlg", "setCleanGuideEquip", true)
                    end
                end
            end
        end
        if index > 0 then
            local pos = GuideMgr:getNextGiftEquipByIndex(index)
            if pos ~= self.equip[tag].pos then
                DlgMgr:sendMsg("BagDlg", "selectByPos", pos)
            end
        end

        EquipmentMgr:CMD_EQUIP(self.equip[tag].pos)
        DlgMgr:sendMsg("BagDlg", "swichFastionAndEquip", false)
    else
        EquipmentMgr:CMD_UNEQUIP(self.equip[tag].pos)
    end

    self:onCloseButton()
end

-- 来源
function EquipmentInfoCampareDlg:onSource(sender, eventType)

	if not self.equip then
		self:onCloseButton()
		return
	end

    local tag = self.btnLayer:getTag()
    if not self.equip[tag] or sender:getName() == "SourceButton" then
        tag = sender:getTag()
    end

    local item = self.equip[tag]
	if not item then
		self:onCloseButton()
		return
	end

    -- 物品处理
    if #InventoryMgr:getRescourse(item.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    -- 如果要查看此装备的来源，则关闭对比的装备框，打开来源框
    local displayPanel
    if tag == 1 then
        displayPanel = self:getControl("MainPanel_1")
        self:setCtrlVisible("MainPanel_2", false)
    else
        displayPanel = self:getControl("MainPanel_2")
        self:setCtrlVisible("MainPanel_1", false)
    end

    local rect = self:getBoundingBoxInWorldSpace(displayPanel)
    InventoryMgr:openItemRescourse(item.name, rect, nil, item)
end

-- 出售
function EquipmentInfoCampareDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local tag = self.btnLayer:getTag()
    if self.equip[tag].pos <= 10 then
        gf:ShowSmallTips(CHS[3002472])
        return
    end

    if gf:isExpensive(self.equip[tag]) then
        gf:ShowSmallTips(CHS[5420155])
        ChatMgr:sendMiscMsg(CHS[5420155])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end

    local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(self.equip[tag]))
    local str = ""

    if InventoryMgr:isLimitedItem(self.equip[tag]) then
        str = string.format(CHS[6400047], value, CHS[6400050], self.equip[tag].name)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], self.equip[tag].name)
    end

    gf:confirm(str,
        function ()
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, self.equip[tag].pos, 1)
            self:onCloseButton()
        end)
end

-- 摆摊
function EquipmentInfoCampareDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local tag = self.btnLayer:getTag()
    if self.equip[tag].pos <= 10 then
        gf:ShowSmallTips(CHS[3002474])
        return
    end

    local item = InventoryMgr:getItemByPos(self.equip[tag].pos)

    if InventoryMgr:isLimitedItem(item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002475], MarketMgr:getOnSellLevel()))
        return
    end

    local sellItem = {name = item.name, bagPos = item.pos, icon = item.icon, amount = item.amount, level = item.level, detail = item}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(item.pos)
    if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and  item.unidentified == 0 then
        local dlg = DlgMgr:openDlg("MarketSellEquipmentDlg")
        dlg:setEquipInfo(item, 3)
    else
        MarketMgr:openSellItemDlg(item, 3)
    end

    self:onCloseButton()
end

-- 珍宝摆摊
function EquipmentInfoCampareDlg:onTreasureBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    local tag = self.btnLayer:getTag()
    if self.equip[tag].pos <= 10 then
        gf:ShowSmallTips(CHS[3002474])
        return
    end

    local item = InventoryMgr:getItemByPos(self.equip[tag].pos)

    if InventoryMgr:isLimitedItem(item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getGoldOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002475], MarketMgr:getGoldOnSellLevel()))
        return
    end

    local sellItem = {name = item.name, bagPos = item.pos, icon = item.icon, amount = item.amount, level = item.level, detail = item}
    local dlg = DlgMgr:openDlg("MarketGoldSellDlg")
    dlg:setSelectItem(item.pos)
    if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and  item.unidentified == 0 then
        MarketMgr:openZhenbaoSellDlg(item)
    else
        MarketMgr:openSellItemDlg(item, 3, MarketMgr.TradeType.goldType)
    end

    self:onCloseButton()
end

function EquipmentInfoCampareDlg:MSG_INVENTORY(data)
    -- WDSY-9068如果选择的位置上物品发生变动，关闭对话框
    for i = 1, data.count do
        for j = 1, #self.equip do
            if data[i].pos == self.equip[j].pos then
                self:onCloseButton()
                return
            end
        end
    end
end

return EquipmentInfoCampareDlg
