-- JewelryInfoCampareDlg.lua
-- Created by songcw July/22/2015
-- 首饰对比界面

local JewelryInfoCampareDlg = Singleton("JewelryInfoCampareDlg", Dialog)

--  CHS[4000090]:气血   CHS[4000110]:法力    CHS[4000032]:伤害
local MaterialAtt = {
    [EQUIP.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
}

local MORE_BTN = {
    CHS[3002848],
    CHS[3002849],
    CHS[3002850],
    CHS[3002851]
}

local BTN_FUNC = {
    [CHS[3002848]] = { normalClick = "onSell" },
    [CHS[7000301]] = { normalClick = "onBaitan" },
    [CHS[7000302]] = { normalClick = "onTreasureBaitan"},
    [CHS[3002850]] = { normalClick = "onCompound" },
    [CHS[3002851]] = { normalClick = "onSource" },
}


local BTN_EQUIP = {
    { name = CHS[3002852], normalClick = "onEquipRight" },
    { name = CHS[3002853], normalClick = "onEquipLeft" },
}

function JewelryInfoCampareDlg:init()
    for i = 1, 3 do
        local panel = self:getControl("MainPanel_" .. i)
        self:bindListener("MoreOperateButton", self.onMoreOperateButton, panel)
        self:bindListener("OperateButton", self.onOperateButton, panel)
        self:bindListener("SourceButton", self.onSource, panel)
        self:bindTouchEndEventListener(panel, self.onCloseButton)

        self:getControl("MoreOperateButton", nil ,panel):setTag(i)
        self:getControl("OperateButton", nil ,panel):setTag(i)

        local sourceBtn = self:getControl("SourceButton", nil ,panel)
        if sourceBtn then
            sourceBtn:setTag(i)
            sourceBtn:setVisible(false)
        end
    end

    self.pos = {}
    self.bodySize = self.bodySize or self:getControl("MainPanel_1"):getContentSize()
    self.menuMore = {
        [1] = {},
        [2] = {},
        [3] = {},
    }

    self.btn = self:getControl("MoreOperateButton"):clone()
    -- self.btn:setAnchorPoint(0, 0)
    self.btn:retain()

    self.btnLayer = cc.Layer:create()
    self.btnLayer:setAnchorPoint(0, 0)
    self.btnLayer:retain()
    self.blank:setLocalZOrder(Const.ZORDER_FLOATING)

    self:hookMsg("MSG_INVENTORY")
end

function JewelryInfoCampareDlg:cleanup()
    if self.btnLayer then
        self.btnLayer:release()
        self.btnLayer = nil
    end

    if self.btn then
        self.btn:release()
        self.btn = nil
    end

    self.isMore = nil

    DlgMgr:closeDlg("ItemRecourseDlg")
end

-- pos为传入背包中位置
function JewelryInfoCampareDlg:setJewelryInfoByPos(pos)
    local jewelry = InventoryMgr:getItemByPos(pos)


    self:setJewelryInfoByItem(jewelry)
end

function JewelryInfoCampareDlg:setMenuMore(isCard, isInBag, panel, i)
    local menuTab = {}
    if not isCard then
        if isInBag then
            -- 仅在包裹中显示
        table.insert(menuTab, CHS[3002848])
        table.insert(menuTab, CHS[7000301])

        local jewelry = InventoryMgr:getItemByPos(self.pos[i])
            if jewelry and gf:isExpensive(jewelry) and MarketMgr:isShowGoldMarket() then
            table.insert(menuTab, CHS[7000302])
        end

            if Me:queryBasicInt("level") >= EquipmentMgr:getJewelryLevel() then
            table.insert(menuTab, CHS[3002850])
        end
        end

        -- 创建分享按钮
        self:createShareButton(self:getControl("ShareButton", nil, panel), SHARE_FLAG.EQUIPATTRIB)
    else
        self:setCtrlVisible("ShareButton", false, panel)
    end

    table.insert(menuTab, CHS[3002851])

    return menuTab
end

function JewelryInfoCampareDlg:setJewelryInfoByItem(jewelry, isCard)
    local count = self:getDisplayCount(jewelry)
    local height = 0
    for i = 1, 3 do
    	local panel = self:getControl("MainPanel_" .. i)

        local srBtn = self:getControl("SourceButton", nil, panel)
        if srBtn then
            srBtn.jewelry = nil
            srBtn:setTag(i)
        end

        if i <= count then
            panel:setVisible(true)
            self:setJewelryPanelInfo(jewelry, count == i, panel, i, isCard)
            self.menuMore[i] = self:setMenuMore(count == i and isCard, (i == count), panel, i)
            if #self.menuMore[i] == 1 then
                self:setButtonText("MoreOperateButton", CHS[3002851], panel)
            end
            height = math.max(height, panel:getContentSize().height)
        else
            panel:setVisible(false)
        end
    end

    local size = self.root:getContentSize()
    size.width = math.floor(size.width / 3) * count
    self.root:setContentSize(size.width, height)
end

function JewelryInfoCampareDlg:getDisplayCount(jewelry)
    local count = 1
    if jewelry.equip_type == EQUIP_TYPE.WRIST then
        -- 手镯可能有3个
        if InventoryMgr:getItemByPos(EQUIP.LEFT_WRIST) then
            count = count + 1
        end

        if InventoryMgr:getItemByPos(EQUIP.RIGHT_WRIST) then
            count = count + 1
        end
    else
        if InventoryMgr:getItemByPos(jewelry.equip_type) then
            count = count + 1
        end
    end

    return count
end

function JewelryInfoCampareDlg:setJewelryPanelInfo(jewelry, notWear, panel, i, isCard)
    if not notWear then
        if jewelry.equip_type == EQUIP_TYPE.WRIST then
            if self:getDisplayCount(jewelry) == 2 then
                jewelry = InventoryMgr:getItemByPos(jewelry.equip_type)

                if not jewelry then
                    jewelry = InventoryMgr:getItemByPos(EQUIP_TYPE.WRIST + 1)
                    self.pos[i] = jewelry.equip_type + 1
                else
                    self.pos[i] = jewelry.equip_type
                end
            elseif self:getDisplayCount(jewelry) == 3 then
                jewelry = InventoryMgr:getItemByPos(jewelry.equip_type + i - 1)
                self.pos[i] = jewelry.equip_type + i - 1
            end
        else
            jewelry = InventoryMgr:getItemByPos(jewelry.equip_type)
            self.pos[i] = jewelry.equip_type
        end
        isCard = false
        self:setButtonText("OperateButton", CHS[3002854], panel)
    end

    self:setCtrlVisible("OperateButton", not isCard, panel)
    self:setCtrlVisible("MoreOperateButton", not isCard, panel)
    self:setCtrlVisible("SourceButton", isCard, panel)
    if isCard then
        local srBtn = self:getControl("SourceButton", nil, panel)
        srBtn.jewelry = jewelry
    end

    self.pos[i] = jewelry.pos or 0

    self:setCtrlVisible("WearImage", not notWear, panel)

    -- 图片
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(jewelry.name), panel)
    self:setItemImageSize("ItemImage", panel)
    self:setNumImgForPanel("JewelryShapePanel", ART_FONT_COLOR.NORMAL_TEXT, jewelry.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 是否可以交易标志， 暂时隐藏
    self:setCtrlVisible("ExChangeImage", false, self:getControl("JewelryShapePanel", nil, panel))
    if jewelry and InventoryMgr:isLimitedItem(jewelry) then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage", nil, panel))
    end


    -- 部位和强化等级
    --- 如果没有强化的，原强化label需要显示部位
    local pos = jewelry.equip_type
    local developStr, devLevel, devCom = EquipmentMgr:getJewelryDevelopInfo(jewelry)
    if devLevel == 0 and devCom == 0 then
                    -- 部位
        if pos == EQUIP.BALDRIC then
            self:setLabelText("DevelopLevelLabel", CHS[3002877], panel, COLOR3.LIGHT_WHITE)
        elseif pos == EQUIP.NECKLACE then
            self:setLabelText("DevelopLevelLabel", CHS[3002878], panel, COLOR3.LIGHT_WHITE)
        elseif pos == EQUIP.LEFT_WRIST then
            self:setLabelText("DevelopLevelLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        elseif pos == EQUIP.RIGHT_WRIST then
            self:setLabelText("DevelopLevelLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        end

        self:setLabelText("CommondLabel", "", panel, COLOR3.LIGHT_WHITE)

    else
        -- 强化
        self:setLabelText("DevelopLevelLabel", developStr, panel, COLOR3.BLUE)

            -- 部位
        if pos == EQUIP.BALDRIC then
            self:setLabelText("CommondLabel", CHS[3002877], panel, COLOR3.LIGHT_WHITE)
        elseif pos == EQUIP.NECKLACE then
            self:setLabelText("CommondLabel", CHS[3002878], panel, COLOR3.LIGHT_WHITE)
        elseif pos == EQUIP.LEFT_WRIST then
            self:setLabelText("CommondLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        elseif pos == EQUIP.RIGHT_WRIST then
            self:setLabelText("CommondLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        end
    end

    -- 名称
    local color = InventoryMgr:getItemColor(jewelry)
    self:setLabelText("NameLabel", jewelry.name, panel, color)

    -- 描述
    self:setLabelText("DescLabel", InventoryMgr:getDescript(jewelry.name), panel)

    -- 等级
    self:setLabelText("LevelValueLabel", jewelry.req_level, panel)

    -- 属性值
    local attValueStr = string.format("%s_%d", MaterialAtt[jewelry.equip_type].field, Const.FIELDS_NORMAL)
    local _, attValue, funStr = EquipmentMgr:getJewelryAttributeInfo(jewelry)
    if notWear then
        if self:getDisplayCount(jewelry) == 2 then
            local equip1 = InventoryMgr:getItemByPos(jewelry.equip_type)
            if not equip1 then
                equip1 = InventoryMgr:getItemByPos(jewelry.equip_type + 1)
            end
            --local value1 = equip1.extra[attValueStr]
            local _, value1 = EquipmentMgr:getJewelryAttributeInfo(equip1)
            if attValue - value1 >= 0 then
                funStr = funStr .. CHS[3002858] .. (attValue - value1) .. "#n"
            elseif attValue - value1 < 0 then
                funStr = funStr .. CHS[3002859] .. (value1 - attValue) .. "#n"
            end
        elseif self:getDisplayCount(jewelry) == 3 then
            local equip1 = InventoryMgr:getItemByPos(EQUIP.LEFT_WRIST)
            --local value1 = equip1.extra[attValueStr]
            local _, value1 = EquipmentMgr:getJewelryAttributeInfo(equip1)
            if attValue - value1 >= 0 then
                funStr = funStr .. CHS[3002858] .. (attValue - value1) .. "#n"
            elseif attValue - value1 < 0 then
                funStr = funStr .. CHS[3002859] .. (value1 - attValue) .. "#n"
            end

            local equip2 = InventoryMgr:getItemByPos(EQUIP.RIGHT_WRIST)
            --local value2 = equip2.extra[attValueStr]
            local _, value2 = EquipmentMgr:getJewelryAttributeInfo(equip2)
            if attValue - value2 >= 0 then
                funStr = funStr .. CHS[3002860] .. (attValue - value2) .. "#n"
            elseif attValue - value2 < 0 then
                funStr = funStr .. CHS[3002861] .. (value2 - attValue) .. "#n"
            end
        end
    end

    local desPanel = self:getControl("DescPanel", nil, panel)
    self:setDescript(funStr, desPanel)

    local totalAtt = {}
    local blueAtt = EquipmentMgr:getJewelryBule(jewelry)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end

    -- 转换次数
    if jewelry.transform_num and jewelry.transform_num > 0 then
        table.insert(totalAtt, {str = string.format(CHS[4010062], jewelry.transform_num), color = COLOR3.LIGHT_WHITE})
    end

    -- 冷却时间
    if EquipmentMgr:isCoolTimed(jewelry) then
        table.insert(totalAtt, {str = string.format(CHS[4010063], EquipmentMgr:getCoolTimedByDay(jewelry)), color = COLOR3.LIGHT_WHITE})
    end

    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(jewelry, self:getControl("ExChangeLabel"))
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = COLOR3.RED})
    end

    for i = 1, Const.JEWELRY_ATTRIB_MAX do
        self:setLabelText("AttribLabel" .. i, "", panel)
    end

    for i = 1, #totalAtt do
        self:setLabelText("AttribLabel" .. i, totalAtt[i].str, panel, totalAtt[i].color)
    end

    -- 贵重物品
    if gf:isExpensive(jewelry, false) then
        self:setCtrlVisible("PreciousImage", true, panel)
    else
        self:setCtrlVisible("PreciousImage", false, panel)
    end

    -- WDSY-32202
    local tempHeight = 0
    if not notWear then
        -- 穿的隐藏来源和卸下
        self:setCtrlVisible("MoreOperateButton", false, panel)
        self:setCtrlVisible("OperateButton", false, panel)

        tempHeight = self:getCtrlContentSize("OperateButton", panel).height
    end

    local cutHeight = (Const.JEWELRY_ATTRIB_MAX - 1 - #totalAtt) * 32 + tempHeight
    panel:setContentSize(self.bodySize.width, self.bodySize.height - cutHeight)

    panel:requestDoLayout()
end

-- 设置物品描绘信息
function JewelryInfoCampareDlg:setDescript(descript, descPanel)
    local color = COLOR3.LIGHT_WHITE
    local panel = self:getControl("ComparePanel", nil, descPanel)
    panel:setVisible(true)
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(descript)
    textCtrl:updateNow()
--
    textCtrl:setDefaultColor(color.r, color.g, color.b)
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    local size = panel:getContentSize()
    textCtrl:setPosition((size.width - textW) * 0.5,size.height)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))

    descPanel:requestDoLayout()
end

function JewelryInfoCampareDlg:onMoreOperateButton(sender, eventType)
    local tag = sender:getTag()
    if CHS[3002851] == sender:getTitleText() then
        self.btnLayer:setTag(tag)
        self:onSource(sender)
        return
    end

    if not self.isMore or self.btnLayer:getTag() ~= tag then
        self.btnLayer:removeAllChildren()
        self.isMore = true
        local btnSize = self.btn:getContentSize()
        for i,v in pairs(self.menuMore[tag]) do
            local btn = self.btn:clone()
            btn:setTitleText(tostring(v))
            btn:setPosition(0 + btnSize.width / 2, btnSize.height * i + btnSize.height / 2)
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

function JewelryInfoCampareDlg:onOperateButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002862])
        return
    end

    local str = sender:getTitleText()
    local tag = sender:getTag()
    local bagEquip = InventoryMgr:getItemByPos(self.pos[tag])

    if not bagEquip then
        self:onCloseButton()
        return
    end

    if str == CHS[3002863] or str == CHS[3002864] then
        -- 添加左右手镯
        if bagEquip.equip_type == EQUIP_TYPE.WRIST then
            local layer = ccui.Layout:create()
            layer:setTag(tag)
            local btnSize = self.btn:getContentSize()
            for i = 1, #BTN_EQUIP do
                local btn = self.btn:clone()
                btn:setTitleText(tostring(BTN_EQUIP[i].name))
                btn:setPosition(0 + btnSize.width / 2, btnSize.height * i + btnSize.height / 2)
                btn:setTag(tag)
                layer:addChild(btn)

                self:bindTouchEndEventListener(btn, function(self, sender, eventType)
                    local title = sender:getTitleText()
                    if BTN_EQUIP[i].normalClick and "function" == type(self[BTN_EQUIP[i].normalClick]) then
                        self[BTN_EQUIP[i].normalClick](self, sender, eventType)
                    end
                end)
            end

            layer:setAnchorPoint(0, 0)
            layer:setPosition(0, 0)
            sender:addChild(layer)
            return
        else
            EquipmentMgr:getGuideNextEquip(bagEquip)
            EquipmentMgr:CMD_EQUIP(self.pos[tag])
        end

    else
        EquipmentMgr:CMD_UNEQUIP(self.pos[tag])
    end

    self:onCloseButton()
end

function JewelryInfoCampareDlg:onEquipLeft(sender, eventType)
    local tag = sender:getTag()
    local parentTag = sender:getParent():getTag()
    local bagEquip = InventoryMgr:getItemByPos(self.pos[parentTag])
    if bagEquip then EquipmentMgr:getGuideNextEquip(bagEquip) end
    EquipmentMgr:CMD_EQUIP(self.pos[tag], EQUIP.LEFT_WRIST)
    self:onCloseButton()
end

function JewelryInfoCampareDlg:onEquipRight(sender, eventType)
    local tag = sender:getTag()
    local parentTag = sender:getParent():getTag()
    local bagEquip = InventoryMgr:getItemByPos(self.pos[parentTag])
    if bagEquip then EquipmentMgr:getGuideNextEquip(bagEquip) end
    EquipmentMgr:CMD_EQUIP(self.pos[tag], EQUIP.RIGHT_WRIST)
    self:onCloseButton()
end

-- 出售
function JewelryInfoCampareDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local tag = self.btnLayer:getTag()
    if self.pos[tag] <= 10 then
        gf:ShowSmallTips(CHS[3002865])
        return
    end


    local equip = InventoryMgr:getItemByPos(self.pos[tag])
    if gf:isExpensive(equip) then
        gf:ShowSmallTips(CHS[5420155])
        ChatMgr:sendMiscMsg(CHS[5420155])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end

    local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(equip))
    local str = ""

    if InventoryMgr:isLimitedItem(equip) then
        str = string.format(CHS[6400047], value, CHS[6400050], equip.name)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], equip.name)
    end

    gf:confirm(str,
        function ()
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, self.pos[tag], 1)
            self:onCloseButton()
        end)
end

-- 摆摊
function JewelryInfoCampareDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local tag = self.btnLayer:getTag()
    if self.pos[tag] <= 10 then
        gf:ShowSmallTips(CHS[3002867])
        return
    end

    local item = InventoryMgr:getItemByPos(self.pos[tag])

    if InventoryMgr:isLimitedItem(item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002868], MarketMgr:getOnSellLevel()))
        return
    end

    local sellItem = {name = item.name, bagPos = item.pos, icon = item.icon, amount = item.amount, level = item.level, detail = item}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(item.pos)
    MarketMgr:openSellItemDlg(sellItem.detail, 3)

    self:onCloseButton()
end

-- 珍宝摆摊
function JewelryInfoCampareDlg:onTreasureBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    local tag = self.btnLayer:getTag()
    if self.pos[tag] <= 10 then
        gf:ShowSmallTips(CHS[3002867])
        return
    end

    local item = InventoryMgr:getItemByPos(self.pos[tag])

    if InventoryMgr:isLimitedItem(item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getGoldOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002868], MarketMgr:getGoldOnSellLevel()))
        return
    end

    local sellItem = {name = item.name, bagPos = item.pos, icon = item.icon, amount = item.amount, level = item.level, detail = item}
    local dlg = DlgMgr:openDlg("MarketGoldSellDlg")
    dlg:setSelectItem(item.pos)

    MarketMgr:openZhenbaoSellDlg(item)

    self:onCloseButton()
end

-- 合成
function JewelryInfoCampareDlg:onCompound(sender, eventType)
    local tag = self.btnLayer:getTag()
    local dlg = DlgMgr:openDlg("JewelryUpgradeDlg")
    local equip = InventoryMgr:getItemByPos(self.pos[tag])
    dlg:setJewelry(equip)
    self:onCloseButton()
end

-- 来源
function JewelryInfoCampareDlg:onSource(sender, eventType)
    local tag = self.btnLayer:getTag()
    local item = InventoryMgr:getItemByPos(self.pos[tag])
    if not item then
        item = InventoryMgr:getItemByPos(self.pos[1])
    end

    if sender.jewelry then
        item = sender.jewelry
        tag = sender:getTag()
    end

    -- 物品处理
    if #InventoryMgr:getRescourse(item.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local displayPanel = nil
    for i = 1, 3 do
        if i ~= tag then
            self:setCtrlVisible("MainPanel_" .. i, false)
        else
            displayPanel = self:getControl("MainPanel_" .. i)
        end
    end
    if not displayPanel then return end
    local rect = self:getBoundingBoxInWorldSpace(displayPanel)
    InventoryMgr:openItemRescourse(item.name, rect, nil, item)
end

function JewelryInfoCampareDlg:MSG_INVENTORY(data)
    -- WDSY-9031如果选择的位置上物品发生变动，关闭对话框
    for i = 1, data.count do
        for j = 1, #self.pos do
            if data[i].pos == self.pos[j] then
                self:onCloseButton()
                return
            end
        end
    end
end

return JewelryInfoCampareDlg
