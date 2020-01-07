-- ChangeCardBagDlg.lua
-- Created by songcw May/2/2015
-- 变身卡卡套界面

local ChangeCardBagDlg = Singleton("ChangeCardBagDlg", Dialog)

-- 选中的变身卡（下次打开，需选中）
ChangeCardBagDlg.selectCard = nil

local MARGIN = 2

function ChangeCardBagDlg:init()
    self:bindListener("PetTypeCheckBox", self.onPetTypeCheckBox)
    self:bindListener("ExpandButton", self.onExpandButton)
    self:bindListener("MapButton", self.onMapButton)
    self:bindListener("ApplyButton", self.onApplyButton)
    self:bindListener("InstructionsButton", self.onInstructionsButton)
    self:bindListener("MarketButton", self.onMarketButton)
    self:bindListener("TakeButton", self.onTakeButton)
    self:bindListener("SellButton", self.onSellButton)
    self:bindListener("BackGroundPanel", function ()
        self:setCtrlVisible("ExpandBKPanel", false)
        self:setCtrlVisible("ExpandMainPanel", false)
    end)
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")

    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("InstructionsPanel", function ()
        self:setCtrlVisible("InstructionsPanel", false)
    end)

    -- 扩展panel关闭按钮
    self:bindTouchEndEventListener(self:getControl("CloseButton", nil, "ExpandBKPanel"), function ()
        self:setCtrlVisible("ExpandBKPanel", false)
        self:setCtrlVisible("ExpandMainPanel", false)
    end)

    self:bindListViewListener("PetTypeListView", self.onSelectPetTypeListView)

    -- 保存变身卡形象图片的初始位置
    local x, y = self:getControl("CardImage", nil, "ImagePanel"):getPosition()
    self.shapeImgPos = {x = x, y = y}

    -- 变身卡摆摊，需要提前请求集市信息，例如剩余摊位，具体见任务 WDSY-31877 卡套变身卡摆摊提示异常问题
    MarketMgr:requestRefreshMySell(MarketMgr.TradeType.marketType)

    -- 扩展卡套数字面板
    local expandMainPanel = self:getControl("ExpandMainPanel")
    local backImage = self:getControl("BackImage", nil, expandMainPanel)
    backImage:setTouchEnabled(true)
    self:bindNumInput("BackImage", "ExpandMainPanel", nil)

    self.operationPos = nil
    self.nextChosenCard = nil
    self.isCanTop = false
    self.cardPanel = self:getControl("ZodiacPanel")
    self.cardPanel:retain()
    self.cardPanel:removeFromParent()

    self.selectEff = self:getControl("BChosenEffectImage", nil, self.cardPanel)
    self.selectEff:retain()
    self.selectEff:removeFromParent()
    self.selectEff:setVisible(true)

    self:setDlgInit()
    self:initCardList()
    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_CL_CARD_INFO")
end

function ChangeCardBagDlg:cleanup()
    if self.cardPanel then
        self.cardPanel:release()
        self.cardPanel = nil
    end

    if self.selectEff then
        self.selectEff:release()
        self.selectEff = nil
    end
end

-- 将label设置为空字符串，图片指控
function ChangeCardBagDlg:setDlgInit()
    local shapePanel = self:getControl("ImagePanel")
    self:setLabelText("LevelLabel_3", "", shapePanel)
    self:setLabelText("LevelLabel_4", "", shapePanel)

    self:setImagePlist("CardImage", ResMgr.ui.touming, "ImagePanel")
    self:setImagePlist("PropertyImage", ResMgr.ui.touming, "ImagePanel")

    -- 宠物名
    self:setLabelText("NameLabel", "", "NameImage")
    self:setLabelText("NameLabel_2", "", "NameImage")

    for i = 1, 10 do
        self:setLabelText("AttNameLabel" .. i, "")
        self:setLabelText("AttValueLabel" .. i, "")
    end

    -- 数量
    self:setLabelText("AmountLabel", 0, "MainPanel")
    self:setLabelText("InfoLabel", "", "MainPanel")

    self:setCtrlVisible("ExpandBKPanel", false)
    self:setCtrlVisible("ExpandMainPanel", false)

    -- 开格数、
    self:setLabelText("Label1_0_1", string.format("0/%d", StoreMgr:getCardSize()), "PetTypeCheckBox")
end

function ChangeCardBagDlg:addSelectEff(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
end

function ChangeCardBagDlg:initCardList()
    self.cardList = StoreMgr:getCardsInCardBagDisplayAmount()
    local list = self:resetListView("PetTypeListView", MARGIN, ccui.ListViewGravity.centerVertical)
    list:stopAllActions()
    if #self.cardList == 0 then
        self.selectCard = nil
        self:setDlgInit()
        return
    end
    list:doLayout()
    list:refreshView()

    local selectTag = false
    for i = 1, #self.cardList do
        local panel = self.cardPanel:clone()

        panel.info = self.cardList[i]
        panel:setTag(i)
        if self.selectCard and self.selectCard == self.cardList[i].name then selectTag = panel:getTag() end
        if self.nextChosenCard and self.nextChosenCard == self.cardList[i].name then selectTag = panel:getTag() end

        local icon = InventoryMgr:getIconByName(self.cardList[i].name)
        self:setImage("PetImage", ResMgr:getItemIconPath(icon), panel)
        self:setItemImageSize("PetImage", panel)
        self:setLabelText("PetNameLabel", self.cardList[i].name, panel)
        self:setLabelText("PriceLabel", CHS[4100091] .. self.cardList[i].count, panel)
        list:pushBackCustomItem(panel)

        self:bindTouchEndEventListener(panel, function ()
            self:chosenCard(panel)
        end)
    end
    list:requestDoLayout()
    list:requestRefreshView()
    list:doLayout()
    list:refreshView()

    -- 开格数、
    self:setLabelText("Label1_0_1", string.format("%d/%d", StoreMgr:getChangeCardsAmount(), StoreMgr:getCardSize()), "PetTypeCheckBox")

    -- 如果上次没有选中，则选择第一个，否则选择上次的
    if not selectTag then selectTag = 1 end
    self.nextChosenCard = nil
    local panel = list:getItem(selectTag - 1)
    self.selectCard = nil
 --   performWithDelay(list, function ()
        self:chosenCard(panel, true)
 --   end, 0)
end

function ChangeCardBagDlg:chosenCard(panel, isNeedMove)
    local list = self:getControl("PetTypeListView")

    if isNeedMove then
        local YY = list:getContentSize().height - list:getInnerContainer():getContentSize().height
        if YY > 0 then YY = 0 end
        local index = #self.cardList - panel:getTag()
        local dis = index * (self.cardPanel:getContentSize().height + MARGIN)
        if panel:getTag() * (self.cardPanel:getContentSize().height + MARGIN) > list:getContentSize().height then
            list:getInnerContainer():setPositionY(-dis)
        end
        -- 注释为滚动至目标位置
        --[[
        if dis + YY < 0 then
            local percent = 100 - dis / (list:getInnerContainer():getContentSize().height - list:getContentSize().height) * 100
            list:scrollToPercentVertical(percent, 0.2, false)
        elseif dis + YY + self.cardPanel:getContentSize().height > list:getContentSize().height then
            if list:getInnerContainer():getContentSize().height ~= list:getContentSize().height then
                local realIndex = #self.cardList - panel:getTag() + 1
                local realDis = realIndex * (self.cardPanel:getContentSize().height + MARGIN)
                local percent = (realDis - list:getContentSize().height) / (list:getInnerContainer():getContentSize().height - list:getContentSize().height) * 100
                if percent >= 100 then percent = 100 end
                list:scrollToPercentVertical(100 - percent, 0.2, false)
            end
        end
        --]]
    end
    if not panel and not panel.info then return end
    self.selectCard = panel.info.name
    self:addSelectEff(panel)
    self:showCardInfo(panel.info)
    self.isCanTop = true
end

function ChangeCardBagDlg:showCardInfo(info)
    local cardName = info.name
    local cardInfo = InventoryMgr:getCardInfoByName(cardName)
    -- 变身卡等级
    local shapePanel = self:getControl("ImagePanel")
    self:setLabelText("LevelLabel_3", cardInfo.card_level, shapePanel)
    self:setLabelText("LevelLabel_4", cardInfo.card_level, shapePanel)

    -- 变身卡宠物半身像
    local petName = string.match(cardName, CHS[4100079])
    local pet = PetMgr:getPetCfg(petName)
    local icon = pet.icon
    if cardInfo.card_type == CARD_TYPE.BOSS then
        icon = cardInfo.portrait
    end

    local iconPath = ResMgr:getBigPortrait(icon)
    self:setImage("CardImage", iconPath, "ImagePanel")

    local offset = InventoryMgr:getChangeCardShapeOffset(icon)
    local img = self:getControl("CardImage", nil, "ImagePanel")
    img:setPosition(self.shapeImgPos.x + offset.x, self.shapeImgPos.y + offset.y)


    local polar = gf:getPolar(cardInfo.polar)
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PropertyImage", polarPath, "ImagePanel")

    -- 宠物名
    self:setLabelText("NameLabel",  cardName, "NameImage")
    self:setLabelText("NameLabel_2",  cardName, "NameImage")

    local perce = InventoryMgr:isPercentChangeAtt(field)

    -- 基本属性
    for i = 1, #cardInfo.attrib do
        local perce = InventoryMgr:isPercentChangeAtt(cardInfo.attrib[i].field)

        self:setLabelText("AttNameLabel" .. i, cardInfo.attrib[i].chs, nil, COLOR3.BLUE)
        local valueStr = ""
        if cardInfo.attrib[i].value > 0 then
            valueStr = string.format("+%d", cardInfo.attrib[i].value) .. perce
        else
            valueStr = string.format("%d", cardInfo.attrib[i].value) .. perce
        end
        self:setLabelText("AttValueLabel" .. i, valueStr, nil, COLOR3.BLUE)
    end
    -- 阵法属性
    local battleArrayAttribTab = cardInfo.battle_arr

    local start = #cardInfo.attrib
    for i = 1, #battleArrayAttribTab do
        local perce = InventoryMgr:isPercentChangeAtt(cardInfo.attrib[i].field)
        local att = battleArrayAttribTab[i]
        self:setLabelText("AttNameLabel" .. (start + i), att.chs, nil, COLOR3.GRAY)
        local valueStr = ""
        if att.value > 0 then
            valueStr = string.format("+%d", att.value) .. perce
        else
            valueStr = string.format("%d", att.value) .. perce
        end
        self:setLabelText("AttValueLabel" .. (start + i), valueStr, nil, COLOR3.GRAY)
    end

    -- 持续时间
    local index = #cardInfo.attrib + #cardInfo.battle_arr + 1
    self:setLabelText("AttNameLabel" .. index, CHS[4100092], nil, COLOR3.TEXT_DEFAULT)
    self:setLabelText("AttValueLabel" .. index, string.format(CHS[4100093], InventoryMgr:getCardChangeTime(cardInfo.card_type)), nil, COLOR3.TEXT_DEFAULT)

    for i = #cardInfo.attrib + #battleArrayAttribTab + 2, 11 do
        self:setLabelText("AttNameLabel" .. i, "")
        self:setLabelText("AttValueLabel" .. i, "")
    end

    self:updateLayout("PropertyPanel")

    -- 数量
    self:setLabelText("AmountLabel", info.count, "MainPanel")
    Log:T(self.selectCard)

    local desc = InventoryMgr:getDescript(cardName)
    self:setLabelText("InfoLabel", desc, "MainPanel")

    self:updateLayout("ImagePanel")
    self:updateLayout("MainPanel")
end

function ChangeCardBagDlg:insertNumber(num)

    local flag = StoreMgr:getCardSizeMax() - StoreMgr:getCardSize()
    if num > flag then
        num = flag
        gf:ShowSmallTips(CHS[7000016])
    end
    self:refreashExpandCost(num)

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(num)
    end
end

function ChangeCardBagDlg:onPetTypeCheckBox(sender, eventType)

    local list = self:getControl("PetTypeListView")
    local items = list:getItems()
    if #items == 0 then
        gf:ShowSmallTips(CHS[4100094])
        return
    elseif #items == 1 then
        gf:ShowSmallTips(CHS[4200008])
        return
    end
    if not self.isCanTop then return end
    if not self.selectCard then return end
    InventoryMgr:setChangeCardTop(self.selectCard)
    self.isCanTop = false
end

function ChangeCardBagDlg:onExpandButton(sender, eventType)
    if StoreMgr:getCardSize() >= StoreMgr:getCardSizeMax() then
        gf:ShowSmallTips(CHS[4100095])
        return
    end

    local expandPanel = self:getControl("ExpandBKPanel")
    if self:getCtrlVisible("ExpandBKPanel") then
        self:setCtrlVisible("ExpandBKPanel", false)
        self:setCtrlVisible("ExpandMainPanel", false)
    else
        self:setCtrlVisible("ExpandBKPanel", true)
        self:setCtrlVisible("ExpandMainPanel", true)

        self:refreashExpandCost()
    end
end

function ChangeCardBagDlg:onMapButton(sender, eventType)
    DlgMgr:openDlg("ChangeCardIllustrationDlg")
end

function ChangeCardBagDlg:onApplyButton(sender, eventType)
    if not self.selectCard then
        gf:ShowSmallTips(CHS[4100096])
        return
    end

    local cards = StoreMgr:getChangeCardByName(self.selectCard)
    if cards and cards[1] then
    self.operationPos = cards[1].pos
    InventoryMgr:applyChangCard(Me:getId(), self.operationPos)
    end
end

function ChangeCardBagDlg:onInstructionsButton(sender, eventType)
    DlgMgr:openDlg("ChangeCardRuleDlg")
end

function ChangeCardBagDlg:onMarketButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.selectCard then
        gf:ShowSmallTips(CHS[4100097])
        return
    end
    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002830], MarketMgr:getOnSellLevel()))
        return
    end

    local cards = StoreMgr:getChangeCardByName(self.selectCard, true)
    if #cards == 0 then
        gf:ShowSmallTips(CHS[4300008])
        return
    end

    self.nextChosenCard = self:getNextChose()

    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:onChangeCardDlgCheckBox()
    dlg:selectCardPanelByName(self.selectCard)
end

function ChangeCardBagDlg:onTakeButton(sender, eventType)
    if not self.selectCard then
        gf:ShowSmallTips(CHS[4100098])
        return
    end

    if not self.isCanTop then return end

    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[3002258])
        return
    end

    self.nextChosenCard = self:getNextChose()

    local cards = StoreMgr:getChangeCardByName(self.selectCard)
    if cards and cards[1] then
        self.operationPos = cards[1].pos

        StoreMgr:cmdStoreToBagForCard(self.operationPos)
        self.isCanTop = false
    end
end

function ChangeCardBagDlg:getNextChose()
    if not self.selectCard then return end
    for i = 1, #self.cardList do
        if self.selectCard == self.cardList[i].name then
            if self.cardList[i].count > 1 then
                return self.cardList[i].name
            elseif self.cardList[i + 1] then
                return self.cardList[i + 1].name
            else
                if self.cardList[i - 1] then return self.cardList[i - 1].name end
            end
        end
    end
    return
end

function ChangeCardBagDlg:onSellButton(sender, eventType)
    if not self.selectCard then
        gf:ShowSmallTips(CHS[4100099])
        return
    end

    if not self.isCanTop then return end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSellButton") then
        return
    end

    local cards = StoreMgr:getChangeCardByName(self.selectCard)
    if cards then
        local str = ""
        if InventoryMgr:isLimitedItem(cards[1]) then
            str = string.format(CHS[4200007], InventoryMgr:getSellPriceValue(cards[1]), CHS[6400050], cards[1].name)
        else
            str = string.format(CHS[4200007], InventoryMgr:getSellPriceValue(cards[1]), CHS[6400049], cards[1].name)
        end

        gf:confirm(str,
            function ()
                local cards = StoreMgr:getChangeCardByName(self.selectCard)
                self.operationPos = cards[1].pos
                gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, self.operationPos, 1)
                self.nextChosenCard = self:getNextChose()
                self.isCanTop = false
            end)
    end
end

function ChangeCardBagDlg:onReduceButton(sender, eventType)
    local amount = tonumber(self:getLabelText("NumLabel", nil, "NumPanel"))
    if amount == 1 then
        self:setCtrlEnabled("AddButton", true)
        self:setCtrlEnabled("ReduceButton", false)

        if amount + StoreMgr:getCardSize() >= StoreMgr:getCardSizeMax() then
            self:setCtrlEnabled("AddButton", false)
        end
        return
    end
    self:refreashExpandCost(amount - 1)
end

function ChangeCardBagDlg:onAddButton(sender, eventType)

    local amount = tonumber(self:getLabelText("NumLabel", nil, "NumPanel"))

    if StoreMgr:getCardSize() + amount >= StoreMgr:getCardSizeMax() then
        gf:ShowSmallTips(CHS[4100100])
        self:setCtrlEnabled("AddButton", false)
        self:setCtrlEnabled("ReduceButton", true)
        return
    end
    self:refreashExpandCost(amount + 1)
end

function ChangeCardBagDlg:blindPress(name)
    local widget = self:getControl(name)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function updataCount()
        if self.touchStatus == ccui.TouchEventType.began  then
            if self.clickBtn == "AddButton" then
                self:onAddButton()
            elseif self.clickBtn == "ReduceButton" then
                self:onReduceButton()
            end
        elseif self.touchStatus == ccui.TouchEventType.ended then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = ccui.TouchEventType.began
            schedule(widget , updataCount, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = ccui.TouchEventType.ended
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function ChangeCardBagDlg:refreashExpandCost(exCount)
    if not exCount then
        exCount = StoreMgr:getCardSizeMax() - StoreMgr:getCardSize()
        if exCount >= 5 then exCount = 5 end
    end

    if exCount < 0 then exCount = 1 end

    self:setLabelText("NumLabel", exCount, "NumPanel")
    self:setLabelText("NumLabel2", exCount, "NumPanel")

    self:setLabelText("Label1", exCount * 12, "BuyButton")
    self:setLabelText("Label2", exCount * 12, "BuyButton")

    if exCount == 1 then
        self:setCtrlEnabled("AddButton", true)
        self:setCtrlEnabled("ReduceButton", false)

        if exCount + StoreMgr:getCardSize() >= StoreMgr:getCardSizeMax() then
            self:setCtrlEnabled("AddButton", false)
        end
    elseif exCount + StoreMgr:getCardSize() >= StoreMgr:getCardSizeMax() then
        self:setCtrlEnabled("AddButton", false)
        self:setCtrlEnabled("ReduceButton", true)
    else
        self:setCtrlEnabled("AddButton", true)
        self:setCtrlEnabled("ReduceButton", true)
    end
end

function ChangeCardBagDlg:onBuyButton(sender, eventType)
    local count = tonumber(self:getLabelText("NumLabel", nil, "NumPanel"))
    if not count then return end
    StoreMgr:addCardSize(count)

    self:setCtrlVisible("ExpandBKPanel", false)
    self:setCtrlVisible("ExpandMainPanel", false)
end

function ChangeCardBagDlg:onSelectPetTypeListView(sender, eventType)
end

function ChangeCardBagDlg:MSG_CL_CARD_INFO(data)
    self:initCardList()
end

function ChangeCardBagDlg:MSG_STORE(data)
    local berefresh = false
    for i = 1,data.count do
        if data[i].pos >= StoreMgr:getCardStartPos() then
            berefresh = true
        end
    end

    if berefresh then self:initCardList() end
end

return ChangeCardBagDlg
