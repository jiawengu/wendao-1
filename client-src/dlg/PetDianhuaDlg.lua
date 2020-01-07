-- PetDianhuaDlg.lua
-- Created by songcw
-- 宠物点化

local PetDianhuaDlg = Singleton("PetDianhuaDlg", Dialog)

-- 每一行点化丹个数
local ITEM_NUM = 4

local LOAD_COUNT = 20

function PetDianhuaDlg:init()
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("DianHuaButton", self.onDianHuaButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("CheckBox", self.onCheckBox)
    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("DianHuaCloseButton", self.onCloseButton)
    self:bindListener("BKImage", self.onBKImage, "DianhuadanPanel")
    self:bindListener("BKPanel", function ()
        self:setCtrlVisible("OfflineRulePanel_0", false)
    end)
    self:bindListener("OfflineRulePanel_0", function ()
        self:setCtrlVisible("OfflineRulePanel_0", false)
    end)

    self:bindListener("ItemImage", self.onItemImage, "DianhuadanPanel")

    self.isLock = false

    -- 克隆
    self.itemPanel = self:getControl("ItemPanel")
    for i = 1, ITEM_NUM do
        self:setCtrlVisible("GetImage", false, self:getControl("ItemPanel_" .. i, nil, self.itemPanel))
        self:setCtrlVisible("BugImage", false, self:getControl("ItemPanel_" .. i, nil, self.itemPanel))
    end
    self.itemPanel:removeFromParent()
    self.itemPanel:retain()

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("CheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("CheckBox", false)
    end

    self.selectItems = {}
    self:setDlgInit()
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4000383])), "DianhuadanPanel")
    self:setItemImageSize("ItemImage", "DianhuadanPanel")
    self:MSG_INVENTORY(nil, true)

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
                self:setDianhuaItems()
            end, 0.5)

        end
    end

    -- 下拉请求数据
    self:bindListViewByPageLoad("ListView", "TouchPanel", callback)

    self:hookMsg("MSG_INVENTORY")

    self:hookMsg("MSG_PET_ENCHANT_END")

    self:hookMsg("MSG_GENERAL_NOTIFY")

    self:initPet()
end

function PetDianhuaDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then
        self:setPet(pet)
        self:setDianhuaItems()
    end
end

function PetDianhuaDlg:cleanup()
    self:releaseCloneCtrl("itemPanel")
    self.pet = nil
    self.isInitList = nil
end

-- 设置宠物属性标志
function PetDianhuaDlg:setPetLogoPanel(pet)
    PetMgr:setPetLogo(self, pet)
end

function PetDianhuaDlg:setPetGrowing(pet)
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

function PetDianhuaDlg:setPetGrowingPreview(pet)
    -- 点化完成
    if pet:queryBasicInt("enchant") == 2 then
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

    local items = self:getSelectItems()
    if self:getSelectItemsCount() == 0 then
        self:setLabelText("LifeEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("ManaEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("SpeedEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("PhyEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("MagEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("TotalEffectLabel_2", "?", nil, COLOR3.TEXT_DEFAULT)
        return
    end

    -- 成长
    local life_shape = pet:queryBasicInt("pet_life_shape")
    local life_basic = pet:queryBasicInt("life_effect") + 40
    life_shape = life_shape + Formula:petDianhuaAdd(life_shape, life_basic, pet, items)
    self:setLabelText("LifeEffectLabel_2", life_shape, nil, COLOR3.GREEN)

    local mana_shape = pet:queryBasicInt("pet_mana_shape")
    local mana_basic = pet:queryBasicInt("mana_effect") + 40
    mana_shape = mana_shape + Formula:petDianhuaAdd(mana_shape, mana_basic, pet, items)
    self:setLabelText("ManaEffectLabel_2", mana_shape, nil, COLOR3.GREEN)

    local speed_shape = pet:queryBasicInt("pet_speed_shape")
    local speed_basic = pet:queryBasicInt("speed_effect") + 40
    speed_shape = speed_shape + Formula:petDianhuaAdd(speed_shape, speed_basic, pet, items)
    self:setLabelText("SpeedEffectLabel_2", speed_shape, nil, COLOR3.GREEN)

    local phy_shape = pet:queryBasicInt("pet_phy_shape")
    local phy_basic = pet:queryBasicInt("phy_effect") + 40
    phy_shape = phy_shape + Formula:petDianhuaAdd(phy_shape, phy_basic, pet, items)
    self:setLabelText("PhyEffectLabel_2", phy_shape, nil, COLOR3.GREEN)

    local mag_shape = pet:queryBasicInt("pet_mag_shape")
    local mag_baisc = pet:queryBasicInt("mag_effect") + 40
    mag_shape = mag_shape + Formula:petDianhuaAdd(mag_shape, mag_baisc, pet, items)
    self:setLabelText("MagEffectLabel_2", mag_shape, nil, COLOR3.GREEN)

    local totalShape = life_shape + mana_shape + speed_shape + phy_shape + mag_shape
    self:setLabelText("TotalEffectLabel_2", totalShape, nil, COLOR3.GREEN)
end

function PetDianhuaDlg:setSelectItems(index, item, isAdd)
    if InventoryMgr:isItemTimeout(item) then  -- 道具已经过期
        InventoryMgr:notifyItemTimeout(item)
    end

    if isAdd then
        self.selectItems[index] = item
    else
        self.selectItems[index] = nil
    end
end

function PetDianhuaDlg:getSelectItemsCount()

    local count = 0
    for pos, item in pairs(self.selectItems) do
        count = count + 1
    end

    return count
end

function PetDianhuaDlg:getSelectItems()

    return self.selectItems
end

-- 设置进度条
function PetDianhuaDlg:setDianhuaProgressBar()
    if not self.pet then return end

    self:setCtrlVisible("CompleteImage", self.pet:queryBasicInt("enchant") == 2, "NimbusPanel")
    self:setCtrlVisible("UnCompletePanel", self.pet:queryBasicInt("enchant") ~= 2, "NimbusPanel")

    local now = self.pet:queryBasicInt("enchant_nimbus")
    local preView = Formula:getPetDianhuaNimbusByItems(self:getSelectItems()) + now
    local total = Formula:getPetDianhuaMaxNimbus(self.pet)
    self:setProgressBar("NimbusProgressBar", now, total)
    self:setProgressBar("NimbusProgressBar_1", preView, total)

    local pers = math.floor(preView / total * 100 * 100) * 0.01
    self:setLabelText("NimbusValueLabel", string.format("%d/%d (%0.2f", preView, total, pers) .. "%)")
    self:setLabelText("NimbusValueLabel_1", string.format("%d/%d (%0.2f", preView, total, pers) .. "%)")

    if total < 6000 and preView > total then
        -- 如果携带等级低的，开启点化灵气小于6000，则显示total .. "/" .. total
        self:setLabelText("NimbusValueLabel", string.format("%d/%d (%d", total, total, 100) .. "%)")
        self:setLabelText("NimbusValueLabel_1", string.format("%d/%d (%d", total, total, 100) .. "%)")
    end
end

function PetDianhuaDlg:setPet(pet)
    self.pet = pet
    if not pet then return end
    -- 名字
    local nameLevel = string.format("%s %d级", pet:getShowName(), pet:queryBasicInt("level"))
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
    self:setPetLogoPanel(pet)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    -- 成长
    self:setPetGrowing(pet)
    -- 成长预览
    self:setPetGrowingPreview(pet)

    -- 进度条
    self:setDianhuaProgressBar()

    if pet:queryBasicInt("enchant") == 0 then
        self:setCtrlVisible("StartButton", true, "PetDianhuaPanel")
        self:setCtrlVisible("DianHuaButton", false, "PetDianhuaPanel")
        self:setCtrlVisible("DianHuaCloseButton", false, "PetDianhuaPanel")
        self:setLabelText("Label_1", CHS[4000386], "StartButton")
        self:setLabelText("Label_2", CHS[4000386], "StartButton")
        self:setCtrlVisible("DianhuadanPanel", true)
        self:setCtrlVisible("StartLabel", true)

    elseif pet:queryBasicInt("enchant") == 1 then
        self:setLabelText("Label_1", CHS[4000387], "StartButton")
        self:setLabelText("Label_2", CHS[4000387], "StartButton")
        self:setCtrlVisible("StartButton", false, "PetDianhuaPanel")
        self:setCtrlVisible("DianHuaButton", true, "PetDianhuaPanel")
        self:setCtrlVisible("DianHuaCloseButton", false, "PetDianhuaPanel")
        self:setCtrlVisible("DianhuadanPanel", false)
    else
        self:setCtrlVisible("DianhuadanPanel", false)
        self:setCtrlVisible("StartButton", false, "PetDianhuaPanel")
        self:setCtrlVisible("DianHuaButton", false, "PetDianhuaPanel")
        self:setCtrlVisible("DianHuaCloseButton", false, "PetDianhuaPanel")
    end

    -- 勾选限制交易的，完成后隐藏
    self:setCtrlVisible("UntradePanel", pet:queryBasicInt("enchant") ~= 2)
end

-- 对话框初始化（json文件未隐藏规则说明等其他，同一隐藏）
function PetDianhuaDlg:setDlgInit()
    self:setCtrlVisible("OfflineRulePanel_0", false)
    self:setCtrlVisible("DianHuaCloseButton", false, "PetDianhuaPanel")
    self:setCtrlVisible("StartButton", false, "PetDianhuaPanel")
end

function PetDianhuaDlg:setSingItem(panel, item)
    if not item then
        panel:setVisible(false)
        return
    end

    panel:setVisible(true)

    local isGet = self.selectItems[tostring(panel)] and true or false

    self:setCtrlVisible("GetImage", isGet, panel)

    if item.name == "buy" then
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4000383])), panel)
        self:setItemImageSize("ItemImage", panel)
        gf:grayImageView(self:getControl("ItemImage", nil, panel))
        gf:grayImageView(self:getControl("BackImage", nil, panel))
        self:setCtrlVisible("BugImage", true, panel)

        self:bindTouchEndEventListener(panel, function ()
            gf:askUserWhetherBuyItem({[CHS[4000383]] = 1}, true)
        end)
        return
    end

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
        InventoryMgr:addLogoUnidentified(ctrl)
    else
        InventoryMgr:removeLogoUnidentified(ctrl)
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
            elseif Formula:getPetDianhuaNimbusByItems(self:getSelectItems()) + self.pet:queryBasicInt("enchant_nimbus") >= Formula:getPetDianhuaMaxNimbus(self.pet) then
                gf:ShowSmallTips(CHS[4000389])
            else
                self:setCtrlVisible("GetImage", not isVisible, panel)
                self:setSelectItems(tostring(panel), item, not isVisible)
            end
        else
            self:setCtrlVisible("GetImage", not isVisible, panel)
            self:setSelectItems(tostring(panel), item, not isVisible)
        end
        self:setPetGrowingPreview(self.pet)
        self:setDianhuaProgressBar()
        StoreMgr:showItemDlg(item.pos, rect)
    end)
end


-- 设置点化消耗物品
function PetDianhuaDlg:setDianhuaItems()
    if not self.pet then return end

    self:setCtrlVisible("ListView", self.pet:queryBasicInt("enchant") == 1)
    self:setCtrlVisible("StartLabel", self.pet:queryBasicInt("enchant") == 0)
    self:setCtrlVisible("InfoLabel", self.pet:queryBasicInt("enchant") == 2)
    self:setCtrlVisible("CompletePanel", self.pet:queryBasicInt("enchant") == 2, "UseItemPanel")

    -- 0 点化未开始，1点化开始，2点化完成
    if self.pet:queryBasicInt("enchant") ~= 1 then
        return
    end

    self.loadedData  = self:getItems()

    local items = gf:deepCopy(self.loadedData)

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

        self:setCtrlVisible("NoneLabel", #items == 1 and self.pet:queryBasicInt("enchant") == 1)
        return
    end

    self.isInitList = true
    local list = self:resetListView("ListView", 6, ccui.ListViewGravity.centerVertical)
 --   list:setBounceEnabled(false)
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
    self:setCtrlVisible("NoneLabel", #items == 1 and self.pet:queryBasicInt("enchant") == 1)
end

function PetDianhuaDlg:getMeetItems(items)
    if not items then return end
    local dianhuadan = {}
    local equip = {}
    local arftifact = {}
    local isLimit = self:isCheck("CheckBox")
    local count = items.count or #items
    for k = 1, count do
        local item = items[k]
        if isLimit then
            if item.name == CHS[4000383] then
                for i = 1, item.amount do
                    table.insert(dianhuadan, item)
                end
            end

            -- 是装备
            if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and not gf:isExpensive(item) and not InventoryMgr:isTimeLimitedItem(item) then
                -- 颜色、未改造、价格 或者未鉴定
                if ((item.color == CHS[3003981] or item.color == CHS[3003982] or item.color == CHS[3003983]) and item.rebuild_level == 0 and item.value >= 1000)
                    or item.unidentified == 1 then
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

            -- 法宝
            if item.item_type == ITEM_TYPE.ARTIFACT and not gf:isExpensive(item) and not InventoryMgr:isTimeLimitedItem(item) then
                table.insert(arftifact, item)
            end
        else
            if item.name == CHS[4000383] and not InventoryMgr:isLimitedItemForever(item) then
                for i = 1, item.amount do
                    table.insert(dianhuadan, item)
                end
            end

            -- 是装备
            if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and not InventoryMgr:isLimitedItemForever(item) and not gf:isExpensive(item) and not InventoryMgr:isTimeLimitedItem(item) then
                -- 颜色、未改造、价格 或者未鉴定
                if ((item.color == CHS[3003981] or item.color == CHS[3003982] or item.color == CHS[3003983]) and item.rebuild_level == 0 and item.value >= 1000)
                    or item.unidentified == 1 then
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

function PetDianhuaDlg:getItems()
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

function PetDianhuaDlg:isCanDo()
    if not self.pet then return end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000229])
        return
    end

    -- 限时宠物无法点化
    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[7000082])
        return
    end

    if self.pet:queryInt("rank") == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4000384])
        return
    end

    return true
end

function PetDianhuaDlg:onDianHuaButton(sender, eventType)
    if self.isLock then return end
    if not self:isCanDo() then return end
    if self.pet:queryBasicInt("enchant") == 1 then
        -- 默认有已个+号，所以没有可选择物品，#self:getItems() == 1
        if #self:getItems() == 1 then
            gf:askUserWhetherBuyItem({[CHS[4000383]] = 1})
            return
        end

        if self:getSelectItemsCount() == 0 then
            gf:ShowSmallTips(CHS[4100995])
            return
        end

        sender:stopAllActions()

        self.isLock = true
        PetMgr:upgradePet(self.pet, self.selectItems, "pet_enchant")

        performWithDelay(sender, function ()
            -- body 容错，防止失败的时候被锁死
            self.isLock = false
        end, 3)
    end
end

function PetDianhuaDlg:onStartButton(sender, eventType)
    if not self:isCanDo() then return end
    local isLimit = self:isCheck("CheckBox")
    if self.pet:queryBasicInt("enchant") == 0 then
        PetMgr:openDianhua(self.pet, isLimit)
    end
end

function PetDianhuaDlg:onCheckBox(sender, eventType)
    self.isInitList = false
    self:MSG_INVENTORY(nil, true)
    self.selectItems = {}
    self.listLoadCount = 20
    if self.pet then
        self:setPet(self.pet)
    end
    self:setDianhuaItems()

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

function PetDianhuaDlg:onRuleButton(sender, eventType)
    local isVisible = self:getCtrlVisible("OfflineRulePanel_0")
    self:setCtrlVisible("OfflineRulePanel_0", not isVisible)
end

function PetDianhuaDlg:onItemImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[4000383], rect)
end

function PetDianhuaDlg:MSG_PET_ENCHANT_END(data)
   -- if data.opType ~= "pet_enchant" then return end

    self.isLock = false
    self:getControl("DianHuaButton"):stopAllActions()
    self:MSG_INVENTORY({count = 1}, true)

    if not self.pet then return end
    self.pet = PetMgr:getPetByNo(self.pet:queryBasicInt("no"))
    if not self.pet then
        self:onCloseButton()
        return
    end

    -- 设置宠物
    self:setPet(self.pet)

    if PetMgr:isDianhuaOK(self.pet) then
        DlgMgr:sendMsg("PetGrowTabDlg", "compeledDianhuaCallback", self.pet)
    end
end


function PetDianhuaDlg:MSG_INVENTORY(data, isRefresh)
    if data and data.count == 0 then return end

    if DistMgr:getIsSwichServer() then return end

    if not isRefresh then
        for i = 1, data.count do
            if data[i].name == CHS[4000383] then
                isRefresh = true
            end
        end
    end

    if not isRefresh then return end

    local meetItems = self:getMeetItems(InventoryMgr:getAllBagItems())
    local count = InventoryMgr:getAmountByNameIsForeverBind(CHS[4000383], self:isCheck("CheckBox"))
    local color = COLOR3.GREEN
    if count < 1 then color = COLOR3.RED end
    self:setLabelText("ItemUseNumLabel", count, nil, color)
    self:updateLayout("DianhuadanPanel")

    if meetItems and #meetItems > 0 then
        self.selectItems = {}
        self:setDianhuaItems()
        self:setPet(self.pet)
    end
end

function PetDianhuaDlg:onBKImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[4000383], rect)
end

function PetDianhuaDlg:onCloseButton()
    DlgMgr:closeDlg(self.name)
end

function PetDianhuaDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_SEND_INIT_DATA_DONE == data.notify then
        if not self.selectItems then return end
        for idx, item in pairs(self.selectItems) do
            local newItem = InventoryMgr:getItemByPos(item.pos)
            self.selectItems[idx] = newItem
        end

        self:setDianhuaItems()
    end
end




return PetDianhuaDlg
