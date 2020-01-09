-- TeamChangeCardMenuDlg.lua
-- Created by songcw May/10/2016
-- 选择使用的变身卡界面

local TeamChangeCardMenuDlg = Singleton("TeamChangeCardMenuDlg", Dialog)

local MARGIN = 5

function TeamChangeCardMenuDlg:init()
    self:bindListViewListener("CardListView", self.onSelectCardListView)

    self.cardPanel = self:getControl("CardListPanel")
    self.cardPanel:retain()
    self.cardPanel:removeFromParent()

    self.selectImage = self:getControl("ChoosenImage", nil, self.cardPanel)
    self.selectImage:setVisible(true)
    self.selectImage:retain()
    self.selectImage:removeFromParent()

    self.player = nil
    self:setInfo()
    
    self:hookMsg("MSG_UPDATE_TEAM_LIST_EX")
end

function TeamChangeCardMenuDlg:cleanup(player)
    self:releaseCloneCtrl("selectImage")
    self:releaseCloneCtrl("cardPanel")
end

function TeamChangeCardMenuDlg:setPlayer(player)
    self.player = player
end

function TeamChangeCardMenuDlg:addSelectEff(sender)
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
end

function TeamChangeCardMenuDlg:setInfo()
    local cards = self:collectCard()
    local list = self:resetListView("CardListView", MARGIN, ccui.ListViewGravity.centerVertical)
    for i, card in pairs(cards) do
        local cardPanel = self.cardPanel:clone()
        self:setCardInfo(card, cardPanel)
        list:pushBackCustomItem(cardPanel)

        self:bindTouchEndEventListener(cardPanel, function ()
            if not self.player then return end
            self:addSelectEff(cardPanel)

            local canUseCount = #InventoryMgr:getItemByName(card.name, nil, nil, true) + #StoreMgr:getChangeCardByName(card.name, false, true)
            if canUseCount == 0 then
                gf:ShowSmallTips(CHS[4100070])
                return
            end


            gf:confirm(string.format(CHS[4100071], self.player.name, card.name), function ()
                if GameMgr.inCombat then
                    gf:ShowSmallTips(CHS[5000079])
                    return
                end

                if not TeamMgr:inTeamEx(self.player.id) then
                    gf:ShowSmallTips(CHS[4100072])
                    return
                end

                if TeamMgr:isLeaveTemp(Me:getId()) then
                    gf:ShowSmallTips(CHS[4100073])
                    return
                end

                if TeamMgr:isLeaveTemp(self.player.id) then
                    gf:ShowSmallTips(CHS[4100074])
                    return
                end

                -- 优先使用背包的
                local items = InventoryMgr:getItemByName(card.name, nil, nil, true)
                if next(items) then
                    InventoryMgr:applyChangCard(self.player.id, items[1].pos)
                else
                    items = StoreMgr:getChangeCardByName(card.name, nil, true)
                    if next(items) then
                        InventoryMgr:applyChangCard(self.player.id, items[1].pos)
                    end
                end
                self:onCloseButton()                
            end)
        end)
    end
end

function TeamChangeCardMenuDlg:collectCard()
    local storeCard = StoreMgr:getChangeCard() 
    local bagCard = InventoryMgr:getChangeCard()   
    local totalCards = {}   
    
    local function colectCards(cards, posType)   -- 1为卡套2为包裹
        for i = 1, #cards do
            local cardName = cards[i].name
            local cardInfo = InventoryMgr:getCardInfoByName(cardName)
            if totalCards[cardName] then
                totalCards[cardName].count = totalCards[cardName].count + 1 
            else
                totalCards[cardName] = {count = 1, name = cardName, order = cardInfo.order, posType = posType, card_type = cardInfo.card_type}
            end
        end
    end     

    colectCards(storeCard, 1)
    colectCards(bagCard, 2)
    local topKey = StoreMgr:getCardTop()
    local orderCard = {}
    for id, info in pairs(totalCards) do
        local top = 100
        for i = 1,#topKey do
            if topKey[i] == info.order and info.posType == 1 then
                top = i                
            end
        end
        info.topOrder = top
        table.insert(orderCard, info)
    end

    -- 将卡套中的卡按顺序放入orderCard
    table.sort(orderCard, function(l, r)
        if l.posType < r.posType then return true end
        if l.posType > r.posType then return false end
		if l.topOrder < r.topOrder then return true end
        if l.topOrder > r.topOrder then return false end
        if ORDER_BY_CARD_TYPE[l.card_type] < ORDER_BY_CARD_TYPE[r.card_type] then return true end
        if ORDER_BY_CARD_TYPE[l.card_type] > ORDER_BY_CARD_TYPE[r.card_type] then return false end
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)   

    return orderCard
end

function TeamChangeCardMenuDlg:setCardInfo(item, panel)
    local icon = InventoryMgr:getIconByName(item.name)
    self:setImage("GuardImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("GuardImage", panel)

    local rawName = string.match(item.name, CHS[4100079])
    local petCgf = InventoryMgr:getCardInfoByName(item.name)
    local polar = petCgf.polar
    local polarPath = ResMgr:getPolarImagePath(gf:getPolar(polar))
    self:setImagePlist("PolarImage", polarPath, panel)

    self:setLabelText("NameLabel", item.name, panel)

    -- 原先版本用amount，兼容取amount or count
    local amount = item.amount or item.count
    self:setLabelText("NumLabel", CHS[4300050] .. amount, panel)

end

function TeamChangeCardMenuDlg:onSelectCardListView(sender, eventType)
end

function TeamChangeCardMenuDlg:MSG_UPDATE_TEAM_LIST_EX(data)
    if not self.player then return end
    -- 如果使用的对象暂离了，关闭界面
    for i = 1, data.count do
        if self.player.name == data[i].name and data[i].team_status == 2 then
            self:onCloseButton()
        end
    end
end


return TeamChangeCardMenuDlg
