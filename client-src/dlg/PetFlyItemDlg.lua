-- PetFlyItemDlg.lua
-- Created by yangym, May/06/2017
-- 宠物飞升界面

local PetFlyItemDlg = Singleton("PetFlyItemDlg", Dialog)

local BASE_ITEM = {
    ["ItemPanel2"] = {name = CHS[7002282], num = 1}, -- 驯兽诀
    ["ItemPanel1"] = {name = CHS[7002283], num = 20},-- 萦香丸
    ["ItemPanel6"] = {name = CHS[7002284], num = 20},-- 聚灵丹
}

local LINGPO = {
    ["ItemPanel3"] = 1,  -- 灵魄1
    ["ItemPanel4"] = 2,  -- 灵魄2
    ["ItemPanel5"] = 3,  -- 灵魄3
}

function PetFlyItemDlg:init()
    self:bindListener("BKPanel", self.onBKPanel)
    self:bindListener("FlyButton", self.onFlyButton)

    for k, v in pairs(LINGPO) do
        local panelName = k

        self:bindListener(panelName, function(dlg, sender, eventType)
            self:selectOther(sender:getName())
        end)
    end

    -- 2阶骑宠灵魄
    self.singleItemPanel = self:getControl("ItemUnitPanel", Const.UIPanel, "ItemListView")
    self.singleItemPanel:setVisible(true)
    self.singleItemPanel:retain()
    self.singleItemPanel:removeFromParent()

    -- 初始化道具
    self:setItemInfo()

    self:setCtrlVisible("AttriPanel", true)
    self:setCtrlVisible("DeputyPanel", false)
    
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_DISAPPEAR")
end

function PetFlyItemDlg:cleanup()
    self.selectPet = nil
    self.selectItems = nil
    
    if self.singleItemPanel then
        self.singleItemPanel:release()
        self.singleItemPanel = nil
    end
end

function PetFlyItemDlg:setItemInfo()
    -- 刷新消耗的基础道具（驯兽诀、萦香丸、聚灵丹）
    
    for k, v in pairs(BASE_ITEM) do
        local panelName = k
        local itemName = v.name
        local itemNeedNum = v.num
        local itemNum = InventoryMgr:getAmountByName(itemName, true) 
        local icon = InventoryMgr:getIconByName(itemName)

        -- 道具图标
        self:setImage("ItemImage",  ResMgr:getItemIconPath(icon), panelName)
        
        -- 道具数量（若数量小于所需数量，显示为红色）
        self:setNumImgForPanel("NumPanel2",
            ART_FONT_COLOR.NORMAL_TEXT,
            "/" .. itemNeedNum, false, LOCATE_POSITION.RIGHT_TOP, 17, panelName)
        
        local showItemNum = itemNum
        -- 超过999个时显示为“*”
        if itemNum > 999 then
            showItemNum = "*"
        end
        
        self:setNumImgForPanel("NumPanel1",
            itemNum >= itemNeedNum and ART_FONT_COLOR.NORMAL_TEXT or ART_FONT_COLOR.RED,
            showItemNum, false, LOCATE_POSITION.RIGHT_TOP, 15, panelName)
            
        local function func(sender, eventType)
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageDlg(itemName, rect)
        end
        
        local panel = self:getControl(panelName)
        panel:addTouchEventListener(func)
    end
end

function PetFlyItemDlg:setPetInfo(data)
    local petId = data.id
    local pet = PetMgr:getPetById(petId)
    if not pet then
        return
    end
    
    self.selectPet = pet

    -- 设置宠物头像
    local petImage = self:getControl("PetImage", Const.UIImage, "PetIconPanel")
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:loadTexture(path)
    self:setItemImageSize("PetImage", "PetIconPanel")

    -- 设置宠物等级
    local level  = pet:queryBasicInt("level")
    self:setNumImgForPanel("PetIconPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 25)
    
    -- 右上方宠物名字
    self:setLabelText("PetNameLabel", pet:getShowName(), "AttriPanel")
    
    -- 飞升前属性
    self:setPetFlyBeforeInfo(pet, data)
    
    -- 飞升后属性
    self:setPetFlyAfterInfo(pet, data)
end

function PetFlyItemDlg:setPetFlyBeforeInfo(pet, data)
    -- 飞升前
    local lifeShape = pet:queryBasicInt("pet_life_shape")
    local manaShape = pet:queryBasicInt("pet_mana_shape")
    local speedShape = pet:queryBasicInt("pet_speed_shape")
    local phyShape = pet:queryBasicInt("pet_phy_shape")
    local magShape = pet:queryBasicInt("pet_mag_shape")
    local total = lifeShape + manaShape + speedShape + phyShape + magShape
    self:setLabelText("TotalGrowValueLabel1", total)
    self:setLabelText("LifeGrowValueLabel1", lifeShape)
    self:setLabelText("ManaGrowValueLabel1", manaShape)
    self:setLabelText("SpeedGrowValueLabel1", speedShape)
    self:setLabelText("PhyGrowValueLabel1", phyShape)
    self:setLabelText("MagGrowValueLabel1", magShape)
end

function PetFlyItemDlg:setPetFlyAfterInfo(pet, data)
    -- 飞升后
    local lifeShape = pet:queryBasicInt("pet_life_shape") + data.pet_life_shape
    local manaShape = pet:queryBasicInt("pet_mana_shape") + data.pet_mana_shape
    local speedShape = pet:queryBasicInt("pet_speed_shape") + data.pet_speed_shape
    local phyShape = pet:queryBasicInt("pet_phy_shape") + data.pet_phy_shape
    local magShape = pet:queryBasicInt("pet_mag_shape") + data.pet_mag_shape
    local total = lifeShape + manaShape + speedShape + phyShape + magShape
    self:setLabelText("TotalGrowValueLabel3", total)
    self:setLabelText("LifeGrowValueLabel3", lifeShape)
    self:setLabelText("ManaGrowValueLabel3", manaShape)
    self:setLabelText("SpeedGrowValueLabel3", speedShape)
    self:setLabelText("PhyGrowValueLabel3", phyShape)
    self:setLabelText("MagGrowValueLabel3", magShape)
end

function PetFlyItemDlg:refreshOtherItem(senderName)
    if not self.selectItems then return end
    local pos = self.selectItems[senderName]

    local item = InventoryMgr:getItemByPos(pos)
    if not item then return end

    local petImage = self:getControl("ItemImage", Const.UIImage, senderName)
    local path = ResMgr:getItemIconPath(item.icon)
    petImage:setVisible(true)
    petImage:loadTexture(path)
    self:setItemImageSize("ItemImage", senderName)

    self:setCtrlVisible("NonePanel", false, senderName)
    self:setCtrlVisible("FilledPanel", true, senderName)
    
    -- 限时/限制交易图标
    local panel = self:getControl("FilledPanel", nil, senderName)
    local itemImage = self:getControl("ItemImage", nil, panel)
    if InventoryMgr:isTimeLimitedItem(item) then
        InventoryMgr:removeLogoBinding(itemImage)
        InventoryMgr:addLogoTimeLimit(itemImage)
    elseif InventoryMgr:isLimitedItem(item) then
        InventoryMgr:removeLogoTimeLimit(itemImage)
        InventoryMgr:addLogoBinding(itemImage)
    else
        InventoryMgr:removeLogoTimeLimit(itemImage)
        InventoryMgr:removeLogoBinding(itemImage)
    end
end

function PetFlyItemDlg:selectOther(sender)
    -- 点击左侧灵魄PANEL
    self.curSelectSender = sender

    self:setCtrlVisible("AttriPanel", false)
    self:setCtrlVisible("DeputyPanel", true)
    
    for k, v in pairs(LINGPO) do
        local panelName = k
        self:setCtrlVisible("ChosenEffectImage", panelName == sender, panelName)
    end
    
    self:refreshItemList()
end

function PetFlyItemDlg:doNextOther()
    local cur = LINGPO[self.curSelectSender]
    local ctrlName
    local index = cur

    repeat
        index = (index + 1) % 3
        if 0 == index then
            index = 3
        end
        
        for k, v in pairs(LINGPO) do
            if v == index then
                ctrlName = k
            end
        end
    until index == cur or nil == self.selectItems[ctrlName]

    self:selectOther(ctrlName)
end

function PetFlyItemDlg:onSelectOtherItem(senderName, id)
    if not self.selectItems then self.selectItems = {} end
    self.selectItems[senderName] = id
    self:refreshOtherItem(senderName)

    self:doNextOther()
end

function PetFlyItemDlg:refreshItemList()
    local otherItems = {}
    if self.selectItems then
        for _, v in pairs(self.selectItems) do
            if InventoryMgr:getItemByPos(v) then
                if otherItems[v] then
                    otherItems[v] = otherItems[v] + 1
                else
                    otherItems[v] = 1
                end
            end
        end
    end

    self:initItemList(otherItems)
end

-- 初始化道具
function PetFlyItemDlg:initItemList(otherItems)
    local list, size = self:resetListView("ItemListView", 0)
    local allItems = InventoryMgr:getItemByName(CHS[2100020])
    table.sort(allItems, function(l, r)
        -- 限时时间短 > 限时时间长 >  限制交易时间长  > 限制交易时间短  > 非限制交易
        if l.deadline > 0 and r.deadline > 0 then
            if l.deadline < r.deadline then return true end
            if l.deadline > r.deadline then return false end
        elseif l.deadline > 0 or r.deadline > 0 then
            if l.deadline > 0 and r.deadline <= 0 then return true end
            if l.deadline <= 0 and r. deadline > 0 then return false end
        else
            if 2 == l.gift and 2 ~= r.gift then return true end
            if 2 == r.gift and 2 ~= l.gift then return false end
            
            return l.gift < r.gift
        end
    end)

    local cnt = 0
    for i = 1, #allItems do
        local pos = allItems[i].pos
        if not otherItems[pos] or allItems[i].amount > otherItems[pos] then
            local item = {}
            -- 复制数据
            for k, v in pairs(allItems[i]) do
                item[k] = v
            end

            item.amount = math.max(item.amount - (otherItems[pos] or 0))
            cnt = cnt + 1
            list:pushBackCustomItem(self:createItemItem(item))
        end
    end
    
    if cnt <= 0 then
        self:setCtrlVisible("NoticePanel", true, "DeputyPanel")
        return
    end

    self:setCtrlVisible("NoticePanel", false, "DeputyPanel")
end

-- 创建道具项
function PetFlyItemDlg:createItemItem(item)
    if not item then
        return
    end
    
    local itemPanel = self.singleItemPanel:clone()
    self:setLabelText("NameLabel", item.name, itemPanel)
    if InventoryMgr:isTimeLimitedItem(item) then
        local str = gf:convertTimeLimitedToStr(item.deadline)
        self:setLabelText("StatusLabel", str, itemPanel)
    elseif InventoryMgr:isLimitedItem(item) then
        self:setLabelText("StatusLabel", gf:converToLimitedTime(item.gift), itemPanel)
    end
    
     local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onSelectOtherItem(self.curSelectSender, item.pos)
        end
    end
    itemPanel:addTouchEventListener(selectPet)

    local function showItemInfo(sender, eventType)
        -- 显示道具悬浮
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showBasicMessageDlg(item.name, rect)
    end

    local itemImage = self:getControl("ItemImage", Const.UIImage, itemPanel)
    local path = ResMgr:getItemIconPath(item.icon)
    itemImage:loadTexture(path)
    self:setItemImageSize("ItemImage", itemPanel)
    itemImage:setTouchEnabled(true)
    itemImage:addTouchEventListener(showItemInfo)

    local num = item.amount
    self:setNumImgForPanel(itemImage, ART_FONT_COLOR.NORMAL_TEXT, num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)

    if InventoryMgr:isTimeLimitedItem(item) then
        InventoryMgr:removeLogoBinding(itemImage)
        InventoryMgr:addLogoTimeLimit(itemImage)
    elseif InventoryMgr:isLimitedItem(item) then
        InventoryMgr:removeLogoTimeLimit(itemImage)
        InventoryMgr:addLogoBinding(itemImage)
    else
        InventoryMgr:removeLogoTimeLimit(itemImage)
        InventoryMgr:removeLogoBinding(itemImage)
    end

    return itemPanel
end

function PetFlyItemDlg:onBKPanel(sender, eventType)
    self:setCtrlVisible("AttriPanel", true)
    self:setCtrlVisible("DeputyPanel", false)
end

function PetFlyItemDlg:onFlyButton(sender, eventType)
    -- 进行飞升
    if not self.selectPet then
        return
    end
    
    local count = 0
    if self.selectItems then
        for k, v in pairs(self.selectItems) do
            count = count + 1
        end
    end
    
    if (not self.selectItems) or count < 3 then
        -- 尚未选择完3个骑宠灵魄
        gf:ShowSmallTips(CHS[7003078])
        return
    end
    
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
    
    local posStr = ""
    for k, v in pairs(self.selectItems) do
        if posStr == "" then
            posStr = posStr .. v
        else
            posStr = posStr .. "," .. v
        end 
    end
    
    gf:CmdToServer("CMD_SUBMIT_PET_UPGRADE_ITEM", {posString = posStr})
end

function PetFlyItemDlg:MSG_INVENTORY(data)
    self:setItemInfo()
end

function PetFlyItemDlg:MSG_DISAPPEAR()
    if not CharMgr:getNpcByName(CHS[7003079]) then
        -- 若当前已经远离对话NPC，则关闭对话框
        self:close()
    end
end

return PetFlyItemDlg
