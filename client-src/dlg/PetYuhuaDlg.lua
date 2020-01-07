-- PetYuhuaDlg.lua
-- Created by
--

local PetYuhuaDlg = Singleton("PetYuhuaDlg", Dialog)

-- 每一行羽化丹个数
local ITEM_NUM = 4
local LOAD_COUNT = 20

local ECLOSION_STAGE = {
    CHS[4200497], CHS[4200498], CHS[4200499], CHS[4100991]
}

function PetYuhuaDlg:init()
    self:bindListener("OneClickYuHuaButton", self.onOneClickYuHuaButton)
    self:bindListener("YuHuaCloseButton", self.onYuHuaCloseButton)
    self:bindListener("YuHuaButton", self.onYuHuaButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("BKImage", self.onBKImage, "YuhuadanPanel")

    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindListener("CheckBox", self.onCheckBox)
    self.isInitList = nil

    self:bindFloatPanelListener("OfflineRulePanel_0")
    self:bindListener("OfflineRulePanel_0", function ()
        self:setCtrlVisible("OfflineRulePanel_0", false)
    end)
    self.itemPanel = self:retainCtrl("ItemPanel")

    self.isLock = false
    self.selectItems = {}
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("CheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("CheckBox", false)
    end


    self.loadedData = {} -- 滚动加载当前已经加载的数据
    self.listLoadCount = 20

    local function callback(dlg, percent)
        if percent > 100 then
            -- 该请求数据了
            self.root:stopAllActions()
            local meetItems = self:getMeetItems(InventoryMgr:getAllBagItems()) or {}
            if self.listLoadCount >= #meetItems then return end
            DlgMgr:openDlg("WaitDlg")
            performWithDelay(self.root, function ()
                DlgMgr:closeDlg("WaitDlg")
                self.listLoadCount = self.listLoadCount + LOAD_COUNT
                self:setYuhuaItems()
            end, 0.5)

        end
    end

    -- 下拉请求数据
    self:bindListViewByPageLoad("ListView", "TouchPanel", callback)

    self:initPet()

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_PET_ECLOSION_RESULT")
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function PetYuhuaDlg:onCheckBox(sender, eventType)
    self.isInitList = false
    self:MSG_INVENTORY(nil, true)
    self.selectItems = {}
    self.listLoadCount = 20
 --   self:setDianhuaItems()
    if self.pet then
        self:setPet(self.pet)
    end

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

function PetYuhuaDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then
        self:setPet(pet)
    end
end

function PetYuhuaDlg:setPet(pet)
    self.pet = pet
    if not pet then return end
    -- 名字
    local nameLevel = string.format("%s %d级", pet:queryBasic("name"), pet:queryBasicInt("level"))
    self:setLabelText("PetNameLabel", nameLevel)
    self:updateLayout("NamePanel")

    -- 形象
    self:setPortrait("GuardIconPanel", pet:getDlgIcon(), 0, nil, true)

    if PetMgr:isTimeLimitedPet(pet) then  -- 限时宠物
        local timeLimitStr = PetMgr:convertLimitTimeToStr(pet:queryBasicInt("deadline"))
        self:setLabelText("TradeLabel", "")
        self:setLabelText("UntradeLabel", CHS[7000083])
        self:setLabelText("TimeLimitLabel", timeLimitStr)
    elseif PetMgr:isLimitedPet(pet) then  -- 限制交易宠物
        local limitDesr, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
        self:setLabelText("TradeLabel", limitDesr)
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
    else
        self:setLabelText("TradeLabel", "")
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
    end

    -- 相性、贵重、点化
    PetMgr:setPetLogo(self, pet)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    -- xx阶段完成预览
    if PetMgr:isYuhuaCompleted(pet) then
        self:setLabelText("Label_186", CHS[4100991])
    else
        self:setLabelText("Label_186", string.format(CHS[4200500], ECLOSION_STAGE[pet:queryBasicInt("eclosion_stage") + 1]))
    end

    -- 成长
    self:setPetGrowing(pet)

    -- 成长预览
    self:setPetGrowingPreview(pet)

    -- 进度条
    self:setYuhuaProgressBar(pet)

    self:setYuhuaState(pet)

    self:setYuhuaDanPanel()

    self:setYuhuaItems()
end

function PetYuhuaDlg:setSingItem(panel, item)
    if not item then
        panel:setVisible(false)
        return
    end

    panel:setVisible(true)
    local isGet = self.selectItems[tostring(panel)] and true or false
    self:setCtrlVisible("GetImage", isGet, panel)

    if item.name == "buy" then
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4100994])), panel)
        self:setItemImageSize("ItemImage", panel)
        gf:grayImageView(self:getControl("ItemImage", nil, panel))
        gf:grayImageView(self:getControl("BackImage", nil, panel))
        self:setCtrlVisible("BugImage", true, panel)
        self:setCtrlVisible("GetImage", false, panel)
        self:bindTouchEndEventListener(panel, function ()
            gf:askUserWhetherBuyItem({[CHS[4100994]] = 1}, true)
        end)
        return
    end

    self:setCtrlVisible("BugImage", false, panel)
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(item.name), panel)
    self:setItemImageSize("ItemImage", panel)

    local ctrl = self:getControl("ItemImage", nil, panel)

    if InventoryMgr:isTimeLimitedItem(item) then
        InventoryMgr:addLogoTimeLimit(ctrl)
    else
        InventoryMgr:removeLogoTimeLimit(ctrl)
    end

    if InventoryMgr:isLimitedItem(item) then
        InventoryMgr:addLogoBinding(ctrl)
    else
        InventoryMgr:removeLogoBinding(ctrl)
    end

    if item.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(self:getControl("ItemImage", nil, panel))
    else
        InventoryMgr:removeLogoUnidentified(self:getControl("ItemImage", nil, panel))
    end

    if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level and item.req_level > 0 then
        self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
    else
        self:removeNumImgForPanel(panel, LOCATE_POSITION.LEFT_TOP)
    end

    -- 法宝相性标记
    if item and item.item_type == ITEM_TYPE.ARTIFACT then
        if item.item_polar and item.item_polar >= 1 and item.item_polar <= 5 then
            InventoryMgr:addArtifactPolarImage(ctrl, item.item_polar)
        end

        if item.level and item.level > 0 then
            -- 如果是法宝，要在左上角显示法宝等级
            self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 21)
        else
            self:removeNumImgForPanel(panel, LOCATE_POSITION.LEFT_TOP)
        end
    else
        InventoryMgr:removeArtifactPolarImage(ctrl)
    end

    self:bindTouchEndEventListener(panel, function ()
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local isVisible = self:getCtrlVisible("GetImage", panel)
        if not isVisible then
            if self:getSelectItemsCount() >= 6 then
                gf:ShowSmallTips(CHS[4000388])
            elseif Formula:getPetYuhuaNimbusByItems(self:getSelectItems()) + self.pet:queryBasicInt("eclosion_nimbus") >= Formula:getPetYuhuaMaxNimbus(self.pet) then
                gf:ShowSmallTips(CHS[4101004])
            else
                self:setCtrlVisible("GetImage", not isVisible, panel)
                self:setSelectItems(tostring(panel), item, not isVisible)
            end
        else
            self:setCtrlVisible("GetImage", not isVisible, panel)
            self:setSelectItems(tostring(panel), item, not isVisible)
        end
        self:setPetGrowingPreview(self.pet)
        self:setYuhuaProgressBar(self.pet)
        StoreMgr:showItemDlg(item.pos, rect)
    end)
end


-- 设置羽化消耗物品
function PetYuhuaDlg:setYuhuaItems()
    if not self.pet then return end

    self.loadedData  = self:getItems()

    local items = gf:deepCopy(self.loadedData)

    self:setCtrlVisible("ListView", self.pet:queryBasicInt("eclosion") == 1)
    self:setCtrlVisible("StartLabel", self.pet:queryBasicInt("eclosion") == 0)
    self:setCtrlVisible("InfoLabel", self.pet:queryBasicInt("eclosion") == 2)
    self:setCtrlVisible("CompletePanel", self.pet:queryBasicInt("eclosion") == 2, "UseItemPanel")

    local items = self:getItems()
    local count = #items / ITEM_NUM
    if #items % ITEM_NUM ~= 0 then count = count + 1 end

    local function setOneRow(panel, items, i)
        local item1 = self:getControl("ItemPanel_1", nil, panel)
        self:setSingItem(item1, items[(i - 1) * ITEM_NUM + 1])

        local item2 = self:getControl("ItemPanel_2", nil, panel)
        self:setSingItem(item2, items[(i - 1) * ITEM_NUM + 2])

        local item3 = self:getControl("ItemPanel_3", nil, panel)
        self:setSingItem(item3, items[(i - 1) * ITEM_NUM + 3])

        local item4 = self:getControl("ItemPanel_4", nil, panel)
        self:setSingItem(item4, items[(i - 1) * ITEM_NUM + 4])
    end

    if self.isInitList then
        -- 如果已经初始化过了，判断数据变化
        local list = self:getControl("ListView")
        if count == #list:getItems() then
            -- 数目没有发生变化，直接设置即可
            for i, panel in pairs(list:getItems()) do
                setOneRow(panel, items, i)
            end
        else
            local orgCount = #list:getItems()
            if count > orgCount then
                -- 如果新数据多，push进list中
                for i = 1, count - orgCount do
                    local panel = self.itemPanel:clone()
                    panel:setVisible(true)
                    list:pushBackCustomItem(panel)
                end

                -- 设置数据
                for i, panel in pairs(list:getItems()) do
                    setOneRow(panel, items, i)
                end
            else
                -- 如果新数据少，remove一些
                for i = orgCount, count + 1, -1 do
                    list:removeItem(i - 1) -- C++0开始
                end

                -- 设置数据
                for i, panel in pairs(list:getItems()) do
                    setOneRow(panel, items, i)
                end
            end
        end
        self:setCtrlVisible("NoneLabel", #items == 1 and self.pet:queryBasicInt("eclosion") == 1)
        return
    end

    self.isInitList = true
    local list = self:resetListView("ListView", 6, ccui.ListViewGravity.centerVertical)
   -- list:setBounceEnabled(false)
    for i = 1, count do
        local panel = self.itemPanel:clone()
        panel:setVisible(true)

        local item1 = self:getControl("ItemPanel_1", nil, panel)
        self:setSingItem(item1, items[(i - 1) * ITEM_NUM + 1])

        local item2 = self:getControl("ItemPanel_2", nil, panel)
        self:setSingItem(item2, items[(i - 1) * ITEM_NUM + 2])

        local item3 = self:getControl("ItemPanel_3", nil, panel)
        self:setSingItem(item3, items[(i - 1) * ITEM_NUM + 3])

        local item4 = self:getControl("ItemPanel_4", nil, panel)
        self:setSingItem(item4, items[(i - 1) * ITEM_NUM + 4])

        list:pushBackCustomItem(panel)
    end

    self:setCtrlVisible("NoneLabel", #items == 1 and self.pet:queryBasicInt("eclosion") == 1)
end


function PetYuhuaDlg:setSelectItems(index, item, isAdd)
    if InventoryMgr:isItemTimeout(item) then  -- 道具已经过期
        InventoryMgr:notifyItemTimeout(item)
    end

    if isAdd then
        self.selectItems[index] = item
    else
        self.selectItems[index] = nil
    end
end

function PetYuhuaDlg:getItems(items)
    local meetItems = self:getMeetItems(InventoryMgr:getAllBagItems()) or {}

    local ret = {}
    local addCount = 0
    for i = 1, self.listLoadCount do
        if meetItems[i] then
            addCount = addCount + 1
            table.insert(ret, meetItems[i])
        end
    end

    return ret
end

function PetYuhuaDlg:getMeetItems(items)
    if not items then return end
    local dianhuadan = {}
    local equip = {}
    local arftifact = {}
    local isLimit = self:isCheck("CheckBox")
    local count = items.count or #items
    for k = 1, count do
        local item = items[k]
        if isLimit then
            if item.name == CHS[4100994] then
                for i = 1, item.amount do
                    table.insert(dianhuadan, item)
                end
            end

            -- 是装备
            if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and not gf:isExpensive(item) and not InventoryMgr:isTimeLimitedItem(item) then

                local isMeetPrice = InventoryMgr:getSellPriceValue(item) > 5000
                -- 颜色、未改造、价格 或者未鉴定
                if ((item.color == CHS[3003981] or item.color == CHS[3003982] or item.color == CHS[3003983]) and item.rebuild_level == 0 and item.value >= 1000)
                    or item.unidentified == 1 then

                    if isMeetPrice then
                        if item.unidentified == 1 then
                            -- WDSY-27661未鉴定装备可叠加了，但点化界面需要拆开显示
                            for i = 1, item.amount do
                                table.insert(equip, item)
                            end
                        else
                            table.insert(equip, item)
                        end
                    end
                end
            end

            -- 法宝
            if item.item_type == ITEM_TYPE.ARTIFACT and not gf:isExpensive(item) and not InventoryMgr:isTimeLimitedItem(item) then
                table.insert(arftifact, item)
            end
        else
            if item.name == CHS[4100994] and not InventoryMgr:isLimitedItemForever(item) then
                for i = 1, item.amount do
                    table.insert(dianhuadan, item)
                end
            end

            -- 是装备
            if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and not InventoryMgr:isLimitedItemForever(item) and not gf:isExpensive(item) and not InventoryMgr:isTimeLimitedItem(item) then
                -- 颜色、未改造、价格 或者未鉴定
                local isMeetPrice = InventoryMgr:getSellPriceValue(item) > 5000
                if ((item.color == CHS[3003981] or item.color == CHS[3003982] or item.color == CHS[3003983]) and item.rebuild_level == 0 and item.value >= 1000)
                    or item.unidentified == 1 then
                    if isMeetPrice then
                        if item.unidentified == 1 then
                            -- WDSY-27661未鉴定装备可叠加了，但点化界面需要拆开显示
                            for i = 1, item.amount do
                                table.insert(equip, item)
                            end
                        else
                            table.insert(equip, item)
                        end
                    end
                end
            end

            -- 法宝
            if item.item_type == ITEM_TYPE.ARTIFACT and not gf:isExpensive(item) and not InventoryMgr:isTimeLimitedItem(item) and not InventoryMgr:isLimitedItemForever(item) then
                table.insert(arftifact, item)
            end
        end
    end

    local meetItems = {}

    -- 第一个购买的panel
    table.insert(meetItems, {name = "buy"})

    -- 道具
    for i, item in pairs(dianhuadan) do
        table.insert(meetItems, item)
    end

    -- 装备
    for i, item in pairs(equip) do
        table.insert(meetItems, item)
    end

    -- 法宝
    for i, item in pairs(arftifact) do
        table.insert(meetItems, item)
    end

    return meetItems
end

-- 根据羽化状态设置界面
function PetYuhuaDlg:setYuhuaState(pet)

    local eclosion = pet:queryBasicInt("eclosion")
    -- eclosion 0 未开启羽化                     1  开启羽化             2  完成羽化

    -- 物品栏
    local itemPanel = self:getControl("UseItemPanel")
    self:setCtrlVisible("StartLabel", eclosion == 0, itemPanel)         -- 提示
    self:setCtrlVisible("StartLabel2", eclosion == 0, itemPanel)        -- 提示
    self:setCtrlVisible("NoneLabel", false, itemPanel)
    self:setCtrlVisible("InfoLabel", false, itemPanel)
    self:setCtrlVisible("ListView", false, itemPanel)

    self:setCtrlVisible("CompleteImage", eclosion == 2, "NimbusPanel")    -- 完成图片
    self:setCtrlVisible("UnCompletePanel", eclosion == 1, "NimbusPanel")    -- 进度条，非完成都显示
    self:setCtrlVisible("DefaultPanel", eclosion == 0, "NimbusPanel")

    self:setCtrlVisible("StartButton", eclosion == 0)   --  开启羽化按钮
    self:setCtrlVisible("OneClickYuHuaButton", eclosion == 1)   --  一键羽化按钮
    self:setCtrlVisible("YuHuaButton", eclosion == 1)   --  羽化按钮

    self:setCtrlVisible("UntradePanel", eclosion ~= 2)   --  限制交易
end

function PetYuhuaDlg:setYuhuaDanPanel()
    local panel = self:getControl("YuhuadanPanel")
    panel:setVisible(self.pet:queryBasicInt("eclosion") == 0)

    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4100994])), panel)
    local count = InventoryMgr:getAmountByNameIsForeverBind(CHS[4100994], self:isCheck("CheckBox"))
    local color = COLOR3.GREEN
    if count < 1 then color = COLOR3.RED end
    self:setLabelText("ItemUseNumLabel", count, nil, color)
end

function PetYuhuaDlg:getSelectItemsCount()

    local count = 0
    for pos, item in pairs(self.selectItems) do
        count = count + 1
    end

    return count
end

function PetYuhuaDlg:getSelectItems()

    return self.selectItems
end

function PetYuhuaDlg:setYuhuaProgressBar(pet)
    if not pet then return end

    self:setCtrlVisible("CompleteImage", pet:queryBasicInt("eclosion") == 2, "NimbusPanel")
    self:setCtrlVisible("UnCompletePanel", pet:queryBasicInt("eclosion") == 1, "NimbusPanel")
    self:setCtrlVisible("DefaultPanel", pet:queryBasicInt("eclosion") == 0, "NimbusPanel")
--
    local unCompletePanel = self:getControl("UnCompletePanel")
    if pet:queryBasicInt("eclosion") == 0 then
        unCompletePanel = self:getControl("DefaultPanel")
    end

    -- xx阶灵气
    self:setLabelText("NimbusLabel", string.format(CHS[4200501], ECLOSION_STAGE[pet:queryBasicInt("eclosion_stage") + 1]), "UnCompletePanel")
    self:setLabelText("NimbusLabel", string.format(CHS[4200501], ECLOSION_STAGE[pet:queryBasicInt("eclosion_stage") + 1]), "DefaultPanel")

    local now = self.pet:queryBasicInt("eclosion_nimbus")
    local preView = Formula:getPetYuhuaNimbusByItems(self:getSelectItems()) + now
    local total = Formula:getPetYuhuaMaxNimbus(self.pet)
    self:setProgressBar("NimbusProgressBar", now, total, unCompletePanel)
    self:setProgressBar("NimbusProgressBar_1", preView, total, unCompletePanel)

    local pers = math.floor(preView / total * 100 * 100)
    self:setLabelText("NimbusValueLabel", string.format("%d/%d (%0.2f", preView, total, math.min(100, pers * 0.01)) .. "%)", unCompletePanel)
    self:setLabelText("NimbusValueLabel_1", string.format("%d/%d (%0.2f", preView, total, math.min(100, pers * 0.01)) .. "%)", unCompletePanel)

    if total < 3000 and preView > total then
        -- 如果携带等级低的，开启点化灵气小于6000，则显示total .. "/" .. total
        self:setLabelText("NimbusValueLabel", string.format("%d/%d (%d", total, total, 100) .. "%)", unCompletePanel)
        self:setLabelText("NimbusValueLabel_1", string.format("%d/%d (%d", total, total, 100) .. "%)", unCompletePanel)
    end
    --]]
end

function PetYuhuaDlg:setPetGrowingPreview(pet)
    -- 羽化完成
    if pet:queryBasicInt("eclosion") == 2 then
        self:setLabelText("LifeEffectLabel_1", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("ManaEffectLabel_1", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("SpeedEffectLabel_1", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("PhyEffectLabel_1", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("MagEffectLabel_1", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("TotalEffectLabel_1", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("LifeEffectLabel_2", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("ManaEffectLabel_2", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("SpeedEffectLabel_2", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("PhyEffectLabel_2", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("MagEffectLabel_2", "", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("TotalEffectLabel_2", "", nil, COLOR3.TEXT_DEFAULT)
        return
    end
--[[
    if self:getSelectItemsCount() == 0 then
        self:setLabelText("LifeEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("ManaEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("SpeedEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("PhyEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("MagEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("TotalEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        return
    end
    --]]
    local items = self:getSelectItems()

    -- 成长
    local life_shape = pet:queryBasicInt("pet_life_shape")
    local life_basic = pet:queryBasicInt("life_effect") + 40
    life_shape = life_shape + Formula:petYuhuaAdd(life_basic, pet, items, "life")
    self:setLabelText("LifeEffectLabel_2", life_shape, nil, COLOR3.GREEN)

    local mana_shape = pet:queryBasicInt("pet_mana_shape")
    local mana_basic = pet:queryBasicInt("mana_effect") + 40
    mana_shape = mana_shape + Formula:petYuhuaAdd(mana_basic, pet, items, "mana")
    self:setLabelText("ManaEffectLabel_2", mana_shape, nil, COLOR3.GREEN)

    local speed_shape = pet:queryBasicInt("pet_speed_shape")
    local speed_basic = pet:queryBasicInt("speed_effect") + 40
    speed_shape = speed_shape + Formula:petYuhuaAdd(speed_basic, pet, items, "speed")
    self:setLabelText("SpeedEffectLabel_2", speed_shape, nil, COLOR3.GREEN)

    local phy_shape = pet:queryBasicInt("pet_phy_shape")
    local phy_basic = pet:queryBasicInt("phy_effect") + 40
    phy_shape = phy_shape + Formula:petYuhuaAdd(phy_basic, pet, items, "phy")
    self:setLabelText("PhyEffectLabel_2", phy_shape, nil, COLOR3.GREEN)

    local mag_shape = pet:queryBasicInt("pet_mag_shape")
    local mag_baisc = pet:queryBasicInt("mag_effect") + 40
    mag_shape = mag_shape + Formula:petYuhuaAdd(mag_baisc, pet, items, "mag")
    self:setLabelText("MagEffectLabel_2", mag_shape, nil, COLOR3.GREEN)

    local totalShape = life_shape + mana_shape + speed_shape + phy_shape + mag_shape
    self:setLabelText("TotalEffectLabel_2", totalShape, nil, COLOR3.GREEN)
end

function PetYuhuaDlg:setPetGrowing(pet)
    -- 成长
    local life_shape = pet:queryBasicInt("pet_life_shape")
    self:setLabelText("LifeEffectLabel", life_shape)

    local mana_shape = pet:queryBasicInt("pet_mana_shape")
    self:setLabelText("ManaEffectLabel", mana_shape)

    local speed_shape = pet:queryBasicInt("pet_speed_shape")
    self:setLabelText("SpeedEffectLabel", speed_shape)

    local phy_shape = pet:queryBasicInt("pet_phy_shape")
    self:setLabelText("PhyEffectLabel", phy_shape)

    local mag_shape = pet:queryBasicInt("pet_mag_shape")
    self:setLabelText("MagEffectLabel", mag_shape)

    local totalShape = life_shape + mana_shape + speed_shape + phy_shape + mag_shape
    self:setLabelText("TotalEffectLabel", totalShape)
end

function PetYuhuaDlg:onOneClickYuHuaButton(sender, eventType)
    if not self:isCanDo() then return end
    DlgMgr:openDlgEx("PetOneClickYuhuaDlg", self.pet)
end

function PetYuhuaDlg:onYuHuaCloseButton(sender, eventType)
    self:onCloseButton()
end

function PetYuhuaDlg:onYuHuaButton(sender, eventType)
    if self.isLock then return end
    if not self:isCanDo() then return end
    if self.pet:queryBasicInt("eclosion") == 1 then
        -- 默认有已个+号，所以没有可选择物品，#self:getItems() == 1
        if #self:getItems() == 1 then
            gf:askUserWhetherBuyItem({[CHS[4100994]] = 1})
            return
        end

        if self:getSelectItemsCount() == 0 then
            gf:ShowSmallTips(CHS[4100995])
            return
        end

        sender:stopAllActions()

        self.isLock = true
        PetMgr:upgradePet(self.pet, self.selectItems, "pet_eclosion", "item")

        performWithDelay(sender, function ()
            -- body 容错，防止失败的时候被锁死
            self.isLock = false
        end, 3)
    end
end

function PetYuhuaDlg:isCanDo()
    if not self.pet then return end

    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(string.format(CHS[4200493], 70))
        return
    end

    -- 限时宠物无法羽化
    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[4100996])
        return
    end

    -- 角色处于禁闭状态，当前无法进行此操作
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    -- 战斗中
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000229])
        return
    end

    -- 野生宠物
    if self.pet:queryInt("rank") == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4100992])
        return
    end

    if not PetMgr:isDianhuaOK(self.pet) then
        gf:ShowSmallTips(CHS[4100997])
        return
    end

    return true
end

function PetYuhuaDlg:onStartButton(sender, eventType)
    if not self:isCanDo() then return end
    local isLimit = self:isCheck("CheckBox")
    if self.pet:queryBasicInt("eclosion") ~= 0 then return end

    local item = InventoryMgr:getPriorityUseInventoryByName(CHS[4100994], isLimit)

    if not item then
        gf:askUserWhetherBuyItem({[CHS[4100994]] = 1})
        return
    end

    local str, day = gf:converToLimitedTimeDay(self.pet:queryInt("gift"))
    if isLimit and InventoryMgr:isLimitedItemForever(item) and day <= Const.LIMIT_TIPS_DAY then
        gf:confirm(string.format(CHS[4000385], 10), function ()
            gf:CmdToServer("CMD_UPGRADE_PET", {type = "pet_open_eclosion", no = self.pet:queryBasicInt("no"), pos = tostring(item.pos), other_pet = "", cost_type = "item", ids = tostring(item.item_unique),})
        end)
    else
        gf:CmdToServer("CMD_UPGRADE_PET", {type = "pet_open_eclosion", no = self.pet:queryBasicInt("no"), pos = tostring(item.pos), other_pet = "", cost_type = "item", ids = tostring(item.item_unique),})
    end
end

function PetYuhuaDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("OfflineRulePanel_0", true)
end

function PetYuhuaDlg:onBKImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[4100994], rect)
end

function PetYuhuaDlg:onSelectListView(sender, eventType)
end

function PetYuhuaDlg:MSG_INVENTORY(data, isRefresh)
    if not self.pet then return end

    if data and data.count == 0 then return end

    if DistMgr:getIsSwichServer() then return end

    if not isRefresh then
        for i = 1, data.count do
            if data[i].name == CHS[4100994] then
                isRefresh = true
            end
        end
    end

    if not isRefresh then return end


    self.selectItems = {}
    self:setYuhuaDanPanel()
    self:setYuhuaProgressBar(self.pet)
    self:setYuhuaItems()
end

function PetYuhuaDlg:MSG_PET_ECLOSION_RESULT(data)
    self.isLock = false
    self:getControl("YuHuaButton"):stopAllActions()
    if not self.pet then return end
    self.pet = PetMgr:getPetByNo(self.pet:queryBasicInt("no"))
    if not self.pet then return end
    PetMgr:setLastSelectPet(self.pet)
    self.selectItems = {}

    self:initPet()
end

function PetYuhuaDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_SEND_INIT_DATA_DONE == data.notify then
        if not self.selectItems then return end
        for idx, item in pairs(self.selectItems) do
            local newItem = InventoryMgr:getItemByPos(item.pos)
            self.selectItems[idx] = newItem
        end

        self:setYuhuaItems()
    end
end


return PetYuhuaDlg
