-- FashionDressInfoDlg.lua
-- Created by zhengjh Jun/21/2016
-- 时装名片

local FashionDressInfoDlg = Singleton("FashionDressInfoDlg", Dialog)

local BTN_FUNC = {
    [CHS[7002358]] = { normalClick = "onResourceButton" },
    [CHS[7000301]] = { normalClick = "onBaitan" },
    [CHS[5000201]] = { normalClick = "onSell"},
}

function FashionDressInfoDlg:init()
    self:bindListener("MoreOperateButton", self.onMoreOperateButton)
    self:bindListener("OperateButton", self.onOperateButton)
    self:bindListener("ShareButton", self.onShareButton)
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("DressButton", self.onDressButton)  -- 自定义服装穿戴按钮
    self.rootSize = self.rootSize or self:getControl("MainPanel"):getContentSize()
    self.descPanelSize = self.descPanelSize or self:getControl("DescPanel"):getContentSize()
    self.pricePanelHeight = self:getControl("PricePanel"):getContentSize().height
    self.limitPanelHeight = self:getControl("ExChangePanel"):getContentSize().height
    self.limitTimePanelHeight = self:getControl("LimitPanel"):getContentSize().height

    self.btnTmp = self:getControl("MoreOperateButton"):clone()
    self.btnTmp:retain()
end

function FashionDressInfoDlg:cleanup()
    self:releaseCloneCtrl("btnTmp")
    self:releaseCloneCtrl("btnLayer")
end

-- 通过自定义服装界面打开
function FashionDressInfoDlg:setEquipInfoFormCustom(equip)
    self:setEquipInfo(equip, isCard)

    self:setCtrlVisible("BttonPanel", false)
    self:setCtrlVisible("DepositButton", false)
    self:setCtrlVisible("DressButton", true)

    if equip.pos and equip.pos <= EQUIP.FASIONG_END then
        self:setLabelText("Label", CHS[5420303], "DressButton")
    else
        self:setLabelText("Label", CHS[5420302], "DressButton")
    end
end

function FashionDressInfoDlg:setEquipInfo(equip, isCard)
    self.equip = equip

    -- WDSY-31119 修改不显示已装备
    self:setCtrlVisible("WearImage", false)

    self:setIcon(equip)

    self:setLabelText("NameLabel", equip.name)
    if equip.fasion_type == FASION_TYPE.FASION and equip.alias ~= "" then
		-- 时装需要显示别名
        local color = InventoryMgr:getItemColor({color = equip.color})
        self:setLabelText("NameLabel", equip.alias, nil, color)
    end

    -- 鸾凤宝玉,龙凤呈祥服·新娘，龙凤呈祥服·新郎
    if equip.name == CHS[6400074] or equip.name == CHS[7100167] or equip.name == CHS[7100168] then
        self:setLabelText("NameLabel", equip.name, nil, COLOR3.YELLOW)

        if equip.name == CHS[6400074] then
            local pos = gf:findStrByByte(equip.alias, CHS[3002818])
            if pos then
                self:setLabelText("CommondLabel", gf:getRealName(string.sub(equip.alias, pos + 2, -1)))
            else
                self:setLabelText("CommondLabel", "")
            end
        end
    elseif equip.item_type == ITEM_TYPE.EFFECT or equip.item_type == ITEM_TYPE.FOLLOW_ELF then
        self:setLabelText("NameLabel", not string.isNilOrEmpty(equip.alias) and equip.alias or equip.name, nil, COLOR3.YELLOW)
    elseif equip.fasion_type == FASION_TYPE.FASION then
		-- 时装需要显示性别
		if not equip.gender then
            local info = InventoryMgr:getItemInfoByName(equip.name)
            self:setLabelText("CommondLabel", gf:getGenderChs(info.gender))
		else
            self:setLabelText("CommondLabel", gf:getGenderChs(equip.gender))
		end
    else
        self:setLabelText("CommondLabel", equip.alias or "")
    end

    local  descriptStr = InventoryMgr:getDescriptByItem(equip)
    -- 描述
    local panelDesc = self:getControl("DescPanel")
    local height1 = self:setDescript(descriptStr , panelDesc)
    panelDesc:setContentSize(panelDesc:getContentSize().width, height1)

    local cutHeight = 0
    --  出售价格
    local pricePanel = self:getControl("PricePanel")
    local priceStr = InventoryMgr:getSellPriceStr(equip)
    local priceHeight = self:setDescript(priceStr , pricePanel)
    pricePanel:setContentSize(self.rootSize.width, priceHeight)
    cutHeight = cutHeight + priceHeight

    -- 限制交易
    local exChangePanel = self:getControl("ExChangePanel")
    local limitTab = InventoryMgr:getLimitAtt(equip)
    if limitTab[1] then
        local limitHeight = self:setDescript(limitTab[1].str, exChangePanel, limitTab[1].color)
        exChangePanel:setContentSize(self.rootSize.width, limitHeight)
        cutHeight = cutHeight + limitHeight
    else
        exChangePanel:setContentSize(self.rootSize.width, 0)
    end

    -- 限时交易
    local limitPanel = self:getControl("LimitPanel")
    if InventoryMgr:isTimeLimitedItem(equip) then
        local timeLimitStr
        if equip.isTimeLimitedReward then
            timeLimitStr = CHS[7000100]
        else
            timeLimitStr = string.format(CHS[7000077], gf:getServerDate(CHS[4200022], equip.deadline))
        end

        local limitTimeHeight = self:setDescript(timeLimitStr, limitPanel)
        limitPanel:setContentSize(self.rootSize.width, limitTimeHeight)
        cutHeight = cutHeight + limitTimeHeight
    else
        limitPanel:setContentSize(self.rootSize.width, 0)
    end

    if not isCard then
        -- 创建分享按钮
        self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.EQUIPATTRIB)
    else
        self:setCtrlVisible("ShareButton", false)
    end

    if isCard then
        self:setCtrlVisible("OperateButton", false)
        local panel = self:getControl("MainPanel")
        local panelSize = panel:getContentSize()
        local btn = self:getControl("MoreOperateButton", nil)
        local buttonSize = btn:getContentSize()
        btn:setPositionX(panelSize.width * 0.5)
    elseif InventoryMgr:isEquipFashionByPos(equip.pos) then
        self:setButtonText("OperateButton", CHS[3002420])
    else
        self:setButtonText("OperateButton", CHS[2100212])
    end

    local PRICE_EXCHANGE_LIMIT_SUM_HEIGHT = self.pricePanelHeight + self.limitPanelHeight + self.limitTimePanelHeight
    self.root:setContentSize(self.rootSize.width, self.rootSize.height - (self.descPanelSize.height - height1) - (PRICE_EXCHANGE_LIMIT_SUM_HEIGHT - cutHeight))
    local mainPanel = self:getControl("MainPanel")
    mainPanel:setContentSize(self.rootSize.width, self.rootSize.height - (self.descPanelSize.height - height1) - (PRICE_EXCHANGE_LIMIT_SUM_HEIGHT - cutHeight))
    mainPanel:requestDoLayout()

    -- 如果是时装并且可以摆脱，需要把来源替换成更多按钮
    if equip.fasion_type == FASION_TYPE.FASION and not isCard then
        self:setButtonText("MoreOperateButton", CHS[5000214])
    else
        self:setButtonText("MoreOperateButton", CHS[7002358])
    end

    return true
end

-- 设置物品描绘信息
function FashionDressInfoDlg:setDescript(descript, panel, defaultColor)
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b) end
    textCtrl:setFontSize(20)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((panel:getContentSize().width - textW) * 0.5,textH)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))


    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            gf:onCGAColorText(textCtrl)
            self:onCloseButton()
        end
    end
    panel:setTouchEnabled(true)
    panel:addTouchEventListener(ctrlTouch)
    return textH
end

-- 设置物品Image
function FashionDressInfoDlg:setIcon(item)
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(item.name)))
    self:setItemImageSize("ItemImage")
    if item and InventoryMgr:isLimitedItem(item) then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage"))
    end
end

function FashionDressInfoDlg:onResourceButton(sender, eventType)
    local item = self.equip
    local rect = self:getBoundingBoxInWorldSpace(self.root)

    -- 物品处理
    if #InventoryMgr:getRescourse(self.equip.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    InventoryMgr:openItemRescourse(self.equip.name, rect, nil, item)
end

function FashionDressInfoDlg:onMoreOperateButton(sender, eventType)
    if not self.equip then return  end

    local key = sender:getTitleText()

    if key == CHS[5000214] then
        if sender.isExpand then
            self:getMoreLayer(self.moreBtns):removeFromParent(false)
            sender.isExpand = false
        else
            local contentSize = sender:getContentSize()
            self:getMoreLayer(self.moreBtns):setPosition(0, contentSize.height)
            sender:addChild(self:getMoreLayer(self.moreBtns))
            sender.isExpand = true
        end
        return
    end

    self:onResourceButton(sender, eventType)
end

-- 设置显示存入格式
function FashionDressInfoDlg:setStoreDisplayType()
    if not self.equip then return end
    if self.equip.pos < 200 then
        self:setLabelText("Label", CHS[4300070], "DepositButton")
    else
        self:setLabelText("Label", CHS[4300071], "DepositButton")
    end
    self:setCtrlVisible("BttonPanel", false)
    self:setCtrlVisible("DepositButton", true)
end

function FashionDressInfoDlg:onOperateButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    local str = sender:getTitleText()
    if str == CHS[3002431] or str == CHS[3002421] then
        EquipmentMgr:CMD_EQUIP(self.equip.pos)
    elseif str == CHS[2100212] then
        InventoryMgr:applyItem(self.equip.pos, 1)
    else
        EquipmentMgr:CMD_UNEQUIP(self.equip.pos)
    end

    self:onCloseButton()
end

-- 获取更多列表，当前只有非婚服的时装
function FashionDressInfoDlg:getMoreLayer(btn_list)
    if nil == self.btnLayer then
        local more_btn = {CHS[7002358], CHS[7000301], CHS[5000201]}

        self.btnLayer = cc.Layer:create()
        local num = 0
        for i = 1, #more_btn do


            if more_btn[i] == CHS[7000301] and not MarketMgr:isItemCanSell(self.equip) then
            else
                num = num + 1
                local sellBtn = self.btnTmp:clone()
                local contentSize = sellBtn:getContentSize()
                sellBtn:setTitleText(more_btn[#more_btn - i + 1])
                sellBtn:setPosition(0 + contentSize.width / 2, contentSize.height * (num - 1) + contentSize.height / 2)
                self:blindLongPressWithCtrl(sellBtn, function(self, sender, eventType)
                    local title = sender:getTitleText()
                    if BTN_FUNC[title].oneSecClick and "function" == type(self[BTN_FUNC[title].oneSecClick]) then
                        self[BTN_FUNC[title].oneSecClick](self, sender, eventType)
                    end
                end
                , function(self, sender, eventType)
                    --     local title = sender:getTitleText()
                    local title = sender:getTitleText()
                    if BTN_FUNC[title].normalClick and "function" == type(self[BTN_FUNC[title].normalClick]) then
                        self[BTN_FUNC[title].normalClick](self, sender, eventType)
                    end
                end, true)

                self.btnLayer:setLocalZOrder(100)
                self.btnLayer:addChild(sellBtn)
            end
        end

        self.btnLayer:retain()
    end

    return self.btnLayer
end

function FashionDressInfoDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.equip) then
        InventoryMgr:notifyItemTimeout(self.equip)
        self:close()
        return
    end

    if InventoryMgr:isLimitedItem(self.equip) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002830], MarketMgr:getOnSellLevel()))
        return
    end

    -- 耐久度检测
    if InventoryMgr:isUsedItem(self.equip) then
        gf:ShowSmallTips(CHS[4200365])
        return
    end

    local item = {name = self.equip.name, bagPos = self.equip.pos, icon = self.equip.icon, amount = self.equip.amount, level = self.equip.level, detail = self.equip}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(item.detail.pos)
    MarketMgr:openSellItemDlg(item.detail, 3)
    self:onCloseButton()
end

function FashionDressInfoDlg:onDepositButton(sender, eventType)
    local str = self:getLabelText("Label", sender)
    if str == CHS[4300070] then
        StoreMgr:cmdBagToStore(self.equip.pos)
    else
        StoreMgr:cmdStoreToBag(self.equip.pos)
    end
    self:onCloseButton()
end

-- 自定义服装的穿戴、卸下
function FashionDressInfoDlg:onDressButton(sender, eventType)
    local pos = self.equip.pos
    local name = self.equip.name
    if pos and pos <= EQUIP.FASIONG_END then
        -- 卸下
        gf:CmdToServer("CMD_FASION_CUSTOM_UNEQUIP", {pos = pos})
        DlgMgr:sendMsg("CustomDressDlg", "cancleChooseItem", name)
        DlgMgr:sendMsg("CustomDressDlg", "beginBatchUpdate")
    else
        -- 穿戴
        if not self.equip then
            -- 没有获得该道具，无法穿戴
            gf:ShowSmallTips(string.format(CHS[2100195], name))
            return
        end

        local itemInfo = InventoryMgr:getItemInfoByName(name)
        if not itemInfo or (itemInfo.gender and itemInfo.gender ~= Me:queryBasicInt("gender")) then
            -- 当前形象与性别不符，无法换装
            gf:ShowSmallTips(CHS[2100196])
            return
        end

        gf:CmdToServer("CMD_FASION_CUSTOM_EQUIP", {equip_str = name})
    end

    self:onCloseButton()
end

function FashionDressInfoDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if not self.equip then return end
    local item = InventoryMgr:getItemByPos(self.equip.pos)

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.equip) then
        InventoryMgr:notifyItemTimeout(item)
        self:close()
        return
    end

    if not item then
        -- 从人物身上找不到物品
        self:onCloseButton()
        return
    end

    if gf:isExpensive(self.equip) then
        gf:ShowSmallTips(CHS[5420155])
        return
    end



    local item = self.equip
    if item.attrib and item.attrib:isSet(ITEM_ATTRIB.CANT_SELL) == true then
        gf:ShowSmallTips(CHS[3002828])
        return
    end

    if self.equip.pos < 41 then
        gf:ShowSmallTips(CHS[3002432])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end


    -- 对普通道具进行处理
    local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(item))
    local str = ""

    if InventoryMgr:isLimitedItem(item) then
        str = string.format(CHS[6400047], value, CHS[6400050], item.alias)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], item.alias)
    end

    gf:confirm(str,
        function ()
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, item.pos, 1)

            self:onCloseButton()
        end)

end

return FashionDressInfoDlg
