-- SubmitChangeCardDlg.lua
-- Created by songcw June/22/2016
-- 提交变身卡
-- 目前用于南荒巫术(nhws)/武学历练(wuxue)

local SubmitChangeCardDlg = Singleton("SubmitChangeCardDlg", Dialog)

function SubmitChangeCardDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)
    
    self.data = nil
    
    self.changeCardPanel = self:getControl("UnitPanel", nil, "CardListView")
    self.changeCardPanel:retain()
    self.changeCardPanel:removeFromParent()
    
    -- 默认为武学历练
    self.selectCard = nil
    self.type = "wuxue"
    self:setCardsData()
end

function SubmitChangeCardDlg:getOrderCards(cardType)
    local allChangeCardDisplayAmount = StoreMgr:getAllChangeCardDisplayAmount()
    local result = {}
    for i = 1, #allChangeCardDisplayAmount do
        if cardType then
            if allChangeCardDisplayAmount[i].card_type == cardType then
                table.insert(result, allChangeCardDisplayAmount[i])
            end
        else
            table.insert(result, allChangeCardDisplayAmount[i])
        end
    end
   
    return result
end

function SubmitChangeCardDlg:setCardsData(cardType)
    local cards = self:getOrderCards(cardType)
    local listView = self:resetListView("CardListView", 5)
    if #cards == 0 then
        self:setCtrlVisible("NoticePanel", true)
        self:setCtrlVisible("PetInfoPanel", false)
        return
    end    
    
    for i = 1, #cards do
        local cardName = cards[i].name
        local polar = cards[i].polar
        local count = cards[i].count
        local imgFile = InventoryMgr:getIconFileByName(cardName)
        local cell = self.changeCardPanel:clone()
        local imgCtrl = self:getControl("PetImage", nil, cell)

        self:setLabelText("NameLabel", cardName, cell)
        self:setLabelText("NumLabel", CHS[4100091] .. count, cell)
        self:setImage("PetImage", imgFile, cell)
        InventoryMgr:addPolarChangeCard(imgCtrl, cardName)
        cell:setName(cardName)
        cell:setTag(i)
        
        self:blindLongPress(cell, nil,
            function(dlg, sender, eventType)
                local tag = sender:getTag()
                self:selectItemByCard(cards[tag])
            end)
        
        listView:pushBackCustomItem(cell)
    end
    
    -- 默认选择第一项
    self:selectItemByCard(cards[1])
end

function SubmitChangeCardDlg:selectItemByCard(card)
    self.selectCard = card
    self:addSelectEffect(card.name)
    self:setCardInfo()
end

function SubmitChangeCardDlg:addSelectEffect(cardName)
    local listView = self:getControl("CardListView")
    for k, v in pairs(listView:getChildren()) do
        self:setCtrlVisible("BChosenEffectImage", false, v)
    end

    local selectedCard = listView:getChildByName(cardName)
    self:setCtrlVisible("BChosenEffectImage", true, selectedCard)
end

function SubmitChangeCardDlg:cleanup()
    self:releaseCloneCtrl("changeCardPanel")
end

function SubmitChangeCardDlg:setCardInfo()
    local cardInfo = InventoryMgr:getCardInfoByName(self.selectCard.name)
    local infoPanel = self:getControl("PetInfoPanel")
   
    self:setLabelText("EquipmentNameLabel", self.selectCard.name, infoPanel)
    self:setLabelText("MainLabel2", CHS[4100085] .. cardInfo.card_level, infoPanel)
    
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(self.selectCard.name), infoPanel)
    InventoryMgr:removePolarChangeCard(self:getControl("EquipmentImage"))
    InventoryMgr:addPolarChangeCard(self:getControl("EquipmentImage"), self.selectCard.name)
    
    -- 属性
    local totalInfo = InventoryMgr:getChangeCardEff(self.selectCard.name)

    -- 持续时间
    local keepTime = {str = string.format(CHS[4100086], InventoryMgr:getCardChangeTime(cardInfo.card_type)), color = COLOR3.TEXT_DEFAULT}
    table.insert(totalInfo, keepTime)
    
    for i = 1, 12 do
        local attInfo = totalInfo[i]
        if attInfo then
            self:setLabelText("BaseAttributeLabel" .. i, attInfo.str, nil, attInfo.color)
        else
            self:setLabelText("BaseAttributeLabel" .. i, "")
        end
    end
end

function SubmitChangeCardDlg:setEffectCard(data)
    -- 设置当前对话框类型为南荒巫术
    self.data = data
    self.type = "nhws"
    self.selectCard = nil
    self:setCardsData(CARD_TYPE.MONSTER)
end

function SubmitChangeCardDlg:onSubmitButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003663])
        return
    end
    
    if self.type == "nhws" then
        if not self.data or not self.selectCard then
            gf:ShowSmallTips(CHS[4300017])
            return
        end
        if self.data.left_num + 60 > 300 then
            gf:ShowSmallTips(CHS[4300013])
            return
        end    
    
        local moneyColor = gf:getMoneyDesc(self.data.pay_count)
        local str = string.format(CHS[4300014], self.selectCard.name, moneyColor)    
    
        if self.data.card_name ~= "" and self.data.card_name ~= self.selectCard.name then
            str = str .. CHS[4300015]
        end
    
        local cardName = self.selectCard.name
        gf:confirm(str, function ()
            local card = InventoryMgr:getChangeCardByCostOrder(cardName)
            if not card or not card.item_unique then
                gf:ShowSmallTips(CHS[7003022])
                self:onCloseButton()
                return
            end
            
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SUBMIT_NANHWS, card.item_unique)
            self:onCloseButton()
        end)
    elseif self.type == "wuxue" then
        if not self.selectCard then
            return
        end
        
        local cardName = self.selectCard.name
        gf:confirm(string.format(CHS[7002085], self.selectCard.name) , function()
            local card = InventoryMgr:getChangeCardByCostOrder(cardName)
            if not card or not card.item_unique then
                gf:ShowSmallTips(CHS[7003022])
                self:close()
                return
            end
            
            gf:CmdToServer("CMD_WXLL_SUBMIT_CHANGECARD", {id = card.item_unique})
            self:close()
        end)
    end
end

return SubmitChangeCardDlg
