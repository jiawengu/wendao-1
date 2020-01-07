-- EquipmentChildDlg.lua
-- Created by songcw Jul/23/2015
-- 装备列表界面

local EquipmentChildDlg = Singleton("EquipmentChildDlg", Dialog)

local splitIndex = 0  -- 拆分列表当前选择的索引位置

function EquipmentChildDlg:init()

    self:bindListViewListener("EquipmentListView", self.onSelectEquipmentListView)

    self.equipPanel = self:getControl("EquipmentUnitPanel")
    self:setCtrlVisible("EquipmentUpgradeLevelLabel", false, self.equipPanel)
    self.equipPanel:retain()
    self.equipPanel:removeFromParent()

    self.reformPanel = self:getControl("EquipmentReformPanel")
    self.reformPanel:setTag(0)
    self.reformPanel:retain()
    self.reformPanel:removeFromParent()

    self.selectPos = nil
    splitIndex = 0
    self:setListType(EquipmentMgr:getLastTabKey(), true)
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function EquipmentChildDlg:cleanup()
    self:releaseCloneCtrl("equipPanel")
    self:releaseCloneCtrl("reformPanel")

    self.showEquips = nil
end

function EquipmentChildDlg:setEquipListView()
    self.equipOrder = EquipmentMgr:getSplitEquip()
    self:setNoEquip( (#self.equipOrder == 0), "EquipmentSplitDlg")
    local equipListView = self:resetListView("EquipmentListView")
    if #self.equipOrder == 0 then
        self:sendToDlg()
        return
    end

    local showList = {}
    self.selectPos  = nil
    equipListView:setGravity(ccui.ListViewGravity.centerVertical)

    for i,pos in pairs(self.equipOrder) do
        local equip = InventoryMgr:getItemByPos(pos)
        local panel = self.equipPanel:clone()
        panel.index = i
        panel:setTag(pos)
        self:setUnitEquipPanel(equip, panel)
        equipListView:pushBackCustomItem(panel)
        showList[pos] = pos

    end

    local panel = equipListView:getItem(splitIndex-1)
    if not panel then
        panel = equipListView:getItem(0)
        splitIndex = 1
    end
    self.selectPos = panel:getTag()
    self:setCtrlVisible("ChosenEffectImage", true, panel)
  --  self.selectPos = self.equipOrder[splitIndex]
    self:sendToDlg(self.selectPos)

    local equip = InventoryMgr:getItemByPos(self.selectPos)
    if equip then
        DlgMgr:sendMsg("EquipmentTabDlg", "setLastSelectItemId", equip.item_unique)
    end

    equipListView:requestRefreshView()
    performWithDelay(panel, function ()
        local size = equipListView:getContentSize()
        if splitIndex * panel:getContentSize().height >= size.height then
            equipListView:getInnerContainer():setPositionY(-(#self.equipOrder - splitIndex) * panel:getContentSize().height)
        end
    end)

    -- 记录当前显示的装备用于刷新
    self.showEquips = showList
end

function EquipmentChildDlg:setNoEquip( isShow, key)
    self:setCtrlVisible("NonePanel", isShow)
    if not isShow then return end
    self:setCtrlVisible("NoneSplitPanel", false)
    self:setCtrlVisible("NoneUpgradePanel", false)
    self:setCtrlVisible("NoneSuitPanel", false)
    if key == "EquipmentUpgradeDlg" then
        self:setCtrlVisible("NoneUpgradePanel", true)
    elseif key == "EquipmentSplitDlg" then
        self:setCtrlVisible("NoneSplitPanel", true)
    elseif key == "EquipmentRefiningSuitDlg" then
        self:setCtrlVisible("NoneSuitPanel", true)
    elseif key == "EquipmentEvolveDlg" then
        self:setCtrlVisible("NoneEvolvePanel", true)
    else
        self:setCtrlVisible("NonePanel", false)
    end
end

function EquipmentChildDlg:setEquipReformListView(itemId, keepSelectPos)
    local reformList = EquipmentMgr:getAllEquipments(true)
    self.reformList = {}
    self:setNoEquip(false)
    if not keepSelectPos then
        self.selectPos  = nil
    end
    self:setCtrlVisible("ChosenEffectImage", false, self.reformPanel)
    for i, pos in pairs(reformList) do
        local equip = InventoryMgr:getItemByPos(pos)
        if equip.req_level >= 50 and equip.unidentified == 0 and (equip.color == CHS[3002400] or equip.color == CHS[3002401] or equip.color == CHS[3002402] or equip.color == CHS[3002403])  then
            table.insert(self.reformList, pos)
        end
    end
    local equipListView = self:resetListView("EquipmentListView", 0, ccui.ListViewGravity.centerHorizontal)
    equipListView:pushBackCustomItem(self.reformPanel)

    local showList = {}
    for i,pos in pairs(self.reformList) do
        local equip = InventoryMgr:getItemByPos(pos)
        local panel = self.equipPanel:clone()
        panel:setTag(pos)
        self:setUnitEquipPanel(equip, panel)
        equipListView:pushBackCustomItem(panel)

        if itemId == equip.item_unique or (not itemId and self.selectPos == pos) then
            self.selectPos = pos
            self:sendToDlg(self.selectPos)

            if self.selectPos ~= 0 then
                self:setCtrlVisible("ChosenEffectImage", true, panel)
                DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
                local dlg = DlgMgr:openDlg("EquipmentRefiningDlg")
                dlg:setInfoByPos(self.selectPos)
            end
        end

        showList[pos] = pos
    end

    if not self.selectPos then
        local panel = equipListView:getItem(0)
        if #self.reformList ~= 0 then
            panel = equipListView:getItem(1)
        end
        self:setCtrlVisible("ChosenEffectImage", true, panel)
        self.selectPos = panel:getTag()
        self:sendToDlg(self.selectPos)
        if self.selectPos ~= 0 then
            local dlg = DlgMgr:openDlg("EquipmentRefiningDlg")
            dlg:setInfoByPos(self.selectPos)
        end
        local equip = InventoryMgr:getItemByPos(self.selectPos)
        if equip then
            DlgMgr:sendMsg("EquipmentTabDlg", "setLastSelectItemId", equip.item_unique)
        end
    end

    -- 记录当前显示的装备用于刷新
    self.showEquips = showList
end

-- 获取套装装备列表   1装备等级大于70。2金色或者绿色装备
function EquipmentChildDlg:getSuitEquipList(allEquip)
    local suitEquipList = {}
    for i, pos in pairs(allEquip) do
        local equip = InventoryMgr:getItemByPos(pos)
        if equip.req_level >= 70 and (equip.color == CHS[3002402] or equip.color == CHS[3002403]) then
            table.insert(suitEquipList, equip)
        end
    end
    return suitEquipList
end

function EquipmentChildDlg:setEquipSuitListView(keepSelectPos)
    local allEquipList = EquipmentMgr:getAllEquipments(true)
    local suitEquipList = self:getSuitEquipList(allEquipList)
    local showList = {}
    self:setNoEquip((#suitEquipList == 0), "EquipmentRefiningSuitDlg")
    local equipListView = self:resetListView("EquipmentListView", 0, ccui.ListViewGravity.centerHorizontal)
    if not keepSelectPos then
        self.selectPos  = nil
    end

    local selectIndex = 0
    for i,equip in pairs(suitEquipList) do
        local panel = self.equipPanel:clone()
        panel:setTag(equip.pos)
        self:setUnitEquipPanel(equip, panel)
        equipListView:pushBackCustomItem(panel)
        showList[equip.pos] = equip.pos
        if self.selectPos == equip.pos then
            selectIndex = i - 1
        end
    end

    if selectIndex then
        local panel = equipListView:getItem(selectIndex)
        if not panel then return end
        self:setCtrlVisible("ChosenEffectImage", true, panel)
        self.selectPos = panel:getTag()
        self:sendToDlg(self.selectPos)

        local equip = InventoryMgr:getItemByPos(self.selectPos)
        if equip then
            DlgMgr:sendMsg("EquipmentTabDlg", "setLastSelectItemId", equip.item_unique)
        end
    end

    -- 记录当前显示的装备用于刷新
    self.showEquips = showList
end


function EquipmentChildDlg:getEvolveEquipList(allEquip)
    local suitEquipList = {}
    for i, pos in pairs(allEquip) do
        local equip = InventoryMgr:getItemByPos(pos)
        if equip.req_level >= 70 and equip.color == CHS[3002403] then
            table.insert(suitEquipList, equip)
        end
    end
    return suitEquipList
end

function EquipmentChildDlg:setEquipEvolveListView(keepSelectPos)
    local allEquipList = EquipmentMgr:getAllEquipments(true)
    local suitEquipList = self:getEvolveEquipList(allEquipList)
    local showList = {}
    self:setNoEquip((#suitEquipList == 0), "EquipmentEvolveDlg")
    local equipListView = self:resetListView("EquipmentListView", 0, ccui.ListViewGravity.centerHorizontal)
    if not keepSelectPos then
        self.selectPos  = nil
    end
    local selectIndex = 0
    for i,equip in pairs(suitEquipList) do
        local panel = self.equipPanel:clone()
        panel:setTag(equip.pos)
        self:setUnitEquipPanel(equip, panel)
        equipListView:pushBackCustomItem(panel)
        showList[equip.pos] = equip.pos
        if equip.pos == self.selectPos then
            selectIndex = i - 1
        end
    end

    if selectIndex then
        local panel = equipListView:getItem(selectIndex)
        if not panel then return end
        self:setCtrlVisible("ChosenEffectImage", true, panel)
        self.selectPos = panel:getTag()
        self:sendToDlg(self.selectPos)
    end

    -- 记录当前显示的装备用于刷新
    self.showEquips = showList
end

function EquipmentChildDlg:updateListRefining()
    local equipListView = self:getControl("EquipmentListView")
    local items = equipListView:getItems()
    local index = 1
    if self.tabKey == "EquipmentReformDlg" then
        for _,panel in pairs(items) do
            if index ~= 1 then
                local equip = InventoryMgr:getItemByPos(self.reformList[index - 1])
                self:setUnitEquipPanel(equip, panel)
            end
            index = index + 1
        end
    elseif self.tabKey == "EquipmentRefiningSuitDlg" then
        local allEquipList = EquipmentMgr:getAllEquipments(true)
        local suitEquipList = self:getSuitEquipList(allEquipList)
        for _,panel in pairs(items) do
            local equip = suitEquipList[index]
            self:setUnitEquipPanel(equip, panel)
            index = index + 1
        end
    end
end

function EquipmentChildDlg:setUnitEquipPanel(equip, panel)
    panel.equip = equip

    if not EquipmentMgr:isEquipment(equip) then
        self:closeRelationDlg()
        return
    end

    -- 是否装备中
    if equip.pos <= 10 then
        if Me:queryBasicInt("equip_page") == 0 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    elseif equip.pos <= 20 then
        if Me:queryBasicInt("equip_page") == 1 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    else
        self:setImagePlist("TipImage", ResMgr.ui.touming, panel)
    end

    -- icon
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)

    -- name
    local color = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, panel, color)

    -- lv
    self:setLabelText("EquipmentLevelValueLabel", equip.req_level, panel)


    -- 装备类型（枪。剑等）
    local equipStr = InventoryMgr:getItemInfoByNameAndField(equip.name, "equipType") or ""
    self:setLabelText("EquipmentTypeLabel", equipStr, panel)

    if self.tabKey == "EquipmentEvolveDlg" then
        if equip.evolve_level then
            self:setLabelText("EquipmentLevelValueLabel", (equip.req_level - equip.evolve_level) .. " + " .. equip.evolve_level, panel)
        end
        self:setLabelText("EquipmentTypeLabel", "", panel)
    end

    -- 如果是套装界面，并且是套装，显示相性
    if equip.suit_polar ~= 0 then
        self:setLabelText("EquipmentPolarLabel", "(" .. gf:getPolar(equip.suit_polar) .. ")", panel)
        self:setLabelText("EquipmentPolarLabel2", "(" .. gf:getPolar(equip.suit_polar) .. ")", panel)
    else
        self:setLabelText("EquipmentPolarLabel", "", panel)
        self:setLabelText("EquipmentPolarLabel2", "", panel)
    end

    self:setCtrlVisible("EquipmentUpgradeLevelLabel", false, panel)
    self:setCtrlVisible("EquipmentLevelValueLabel", true, panel)
    self:setCtrlVisible("EquipmentTypeLabel", true, panel)
    self:setCtrlVisible("EquipmentLevelNameLabel", true, panel)
    self:setCtrlVisible("UpgradeCompletionLabel", false, panel)

    panel:requestDoLayout()
end


function EquipmentChildDlg:setUpgradeListView(keepSelectPos)
    if not keepSelectPos then
        self.selectPos  = nil
    end
    self.equipments = EquipmentMgr:getAllEquipments(true)
    self:setNoEquip( (#self.equipments == 0), "EquipmentUpgradeDlg")
    local equipListView = self:resetListView("EquipmentListView")
    if #self.equipments == 0 then
        self:sendToDlg()
        return
    end

    local showList = {}
    --if self.selectPos ~= self.equipments[1] then self.selectPos = nil end
    local selectIndex = 0
    equipListView:setGravity(ccui.ListViewGravity.centerVertical)
    for i,pos in pairs(self.equipments) do
        local equip = InventoryMgr:getItemByPos(pos)
        local panel = self.equipPanel:clone()
        panel:setTag(pos)
        self:setUpgradePanel(equip, panel)
        equipListView:pushBackCustomItem(panel)
        showList[pos] = pos
        if self.selectPos == pos then
            selectIndex = i - 1
        end
    end

    if selectIndex then
        local panel = equipListView:getItem(selectIndex)
        self:setCtrlVisible("ChosenEffectImage", true, panel)

        self.selectPos = panel:getTag()
        local equip = InventoryMgr:getItemByPos(self.selectPos)
        self:sendToDlg(self.selectPos)
        if equip then
            DlgMgr:sendMsg("EquipmentTabDlg", "setLastSelectItemId", equip.item_unique)
        end
    end

    -- 记录当前显示的装备用于刷新
    self.showEquips = showList
end

function EquipmentChildDlg:closeRelationDlg()

    DlgMgr:sendMsg("EquipmentRefiningDlg", "onCloseButton")
    DlgMgr:sendMsg("EquipmentReformDlg", "onCloseButton")
    DlgMgr:sendMsg("EquipmentSplitDlg", "onCloseButton")
    DlgMgr:sendMsg("EquipmentUpgradeDlg", "onCloseButton")
    DlgMgr:sendMsg("EquipmentRefiningSuitDlg", "onCloseButton")
    DlgMgr:sendMsg("EquipmentEvolveDlg", "onCloseButton")
end

function EquipmentChildDlg:setUpgradePanel(equip, panel)

    if not EquipmentMgr:isEquipment(equip) then
        self:closeRelationDlg()
        return
    end

    -- 是否装备中
    if equip.pos <= 10 then
        if Me:queryBasicInt("equip_page") == 0 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    elseif equip.pos <= 20 then
        if Me:queryBasicInt("equip_page") == 1 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    else
        self:setImagePlist("TipImage", ResMgr.ui.touming, panel)
    end

    -- icon
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)

    -- name
    local color = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, panel, color)

    self:setCtrlVisible("EquipmentLevelNameLabel", false, panel)
    self:setCtrlVisible("EquipmentLevelValueLabel", false, panel)
    self:setCtrlVisible("EquipmentTypeLabel", false, panel)
    self:setCtrlVisible("EquipmentUpgradeLevelLabel", true, panel)
    self:setCtrlVisible("UpgradeCompletionLabel", true, panel)

    -- 改造等级
    self:setLabelText("EquipmentUpgradeLevelLabel", CHS[3002404]..equip.rebuild_level, panel)

    -- 改造进度
    local completionLabel = self:getControl("UpgradeCompletionLabel", Const.UILabel, panel)

    -- 如果是套装界面，并且是套装，显示相性
    if equip.suit_polar ~= 0 then
        self:setLabelText("EquipmentPolarLabel", "(" .. gf:getPolar(equip.suit_polar) .. ")", panel)
        self:setLabelText("EquipmentPolarLabel2", "(" .. gf:getPolar(equip.suit_polar) .. ")", panel)
    else
        self:setLabelText("EquipmentPolarLabel", "", panel)
        self:setLabelText("EquipmentPolarLabel2", "", panel)
    end

    if not equip["degree_32"] then
        completionLabel:setString("")
    else
        local degree = math.floor(equip["degree_32"] / 100) *100 / 1000000
        if degree == 0 then
            completionLabel:setString("")
        else
            completionLabel:setString(string.format("(+%0.4f%%)", degree))
        end
    end
end


function EquipmentChildDlg:selectPanel(panel)
    local equipListView = self:getControl("EquipmentListView")
    local items = equipListView:getItems()
    for _,item in pairs(items) do
        self:setCtrlVisible("ChosenEffectImage", false, item)
    end

    self:setCtrlVisible("ChosenEffectImage", true, panel)
    local idx = panel:getTag()

    self.selectPos = idx
    self:sendToDlg(idx)

    if self.tabKey == "EquipmentReformDlg" and idx then
        if idx == 0 then
            local dlg = DlgMgr:openDlg("EquipmentReformDlg")
        else
            DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
            local dlg = DlgMgr:openDlg("EquipmentRefiningDlg")
            dlg:setInfoByPos(idx)
        end
    elseif self.tabKey == "EquipmentSplitDlg" then
        if panel.index then
            splitIndex = panel.index
        end
    end

    local equip = InventoryMgr:getItemByPos(self.selectPos)
    if equip then
        DlgMgr:sendMsg("EquipmentTabDlg", "setLastSelectItemId", equip.item_unique)
    end
end

function EquipmentChildDlg:onSelectEquipmentListView(sender, eventType)
    -- 选中效果
    local panel = self:getListViewSelectedItem(sender)
    self:selectPanel(panel)
end


function EquipmentChildDlg:sendToDlg(pos)
    if pos == 0 then
        DlgMgr:openDlg("EquipmentReformDlg")
        DlgMgr:closeThisDlgOnly("EquipmentRefiningDlg")
   --     DlgMgr:closeDlg("EquipmentRefiningDlg")

        return
    end
    DlgMgr:sendMsg("EquipmentSplitDlg", "setInfoByPos", pos)
    DlgMgr:sendMsg("EquipmentUpgradeDlg", "setInfoByPos", pos)
    DlgMgr:sendMsg("EquipmentRefiningSuitDlg", "setInfoByPos", pos)
    DlgMgr:sendMsg("EquipmentEvolveDlg", "setInfoByPos", pos)
end

function EquipmentChildDlg:isShowEquip(pos)
    if not self.showEquips then return end

    -- 装备进化和装备退化时导致装备完全改变，此时会清掉原本的装备，导致处理后来的消息时isShowEquip()判断错误，故特殊处理
    if EquipmentMgr:getLastTabKey() == "EquipmentEvolveDlg" then
        local allEquipList = EquipmentMgr:getAllEquipments(true)
        local suitEquipList = self:getEvolveEquipList(allEquipList)
        local showList = {}
        for i, equip in pairs(suitEquipList) do
            showList[equip.pos] = equip.pos
        end



        self.showEquips = showList
    end

    return nil ~= self.showEquips[pos]
end

function EquipmentChildDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    if self:isShowEquip(data[1].pos) then

        -- 如果消息延迟（装备拆分后，装备被析构，玩家点到改造，此时收到黑水晶道具信息，位置为装备位置，会走到这里），需要判断 data[1]是否为装备
        -- 如果物品没了，data[1].item_type == nil 也需要刷新界面
        if data[1].item_type ~= ITEM_TYPE.EQUIPMENT then
            self:setListType(EquipmentMgr:getLastTabKey(), true)
            return
        end

        -- 列表中的装备，刷新列表
        local listView = self:getControl("EquipmentListView")
        local items = listView:getItems()
        if self.tabKey == "EquipmentReformDlg" then
            for _, panel in pairs(items) do
                if panel:getTag() == data[1].pos then
                    self:setUnitEquipPanel(data[1], panel)
                end
            end
        elseif self.tabKey == "EquipmentUpgradeDlg" then
            for _, panel in pairs(items) do
                if panel:getTag() == data[1].pos then
                    self:setUpgradePanel(data[1], panel)
                end
            end
        elseif self.tabKey == "EquipmentRefiningSuitDlg" then
        -- 炼化套装不刷新，MSG_GENERAL_NOTIFY有专门消息刷新 EquipmentRefiningSuitDlg:MSG_GENERAL_NOTIFY(data)
        elseif self.tabKey == "EquipmentEvolveDlg" then
        -- 进化也在MSG_GENERAL_NOTIFY
        elseif self.tabKey == "EquipmentSplitDlg" then
        else
            self:setListType(EquipmentMgr:getLastTabKey(), true, true)
        end
    end

    if self.selectPos ~= data[1].pos then
        return
    end

    if self.tabKey == "EquipmentSplitDlg" then
        local item = InventoryMgr:getItemByPos(self.selectPos)
        if EquipmentMgr:isSplitEquip(item) then
            self:sendToDlg(data[1].pos)
        else
            if not data[1].name and self.selectPos then
                -- 这个武器被拆分没了
                self:removeSplitEquipByTag(data[1].pos)
            else
                -- 容错，正常不会走到这
                self:setEquipListView()
            end
        end
    end
end

function EquipmentChildDlg:removeSplitEquipByTag(tag)
    local equipListView = self:getControl("EquipmentListView")
    local children = equipListView:getItems()
    local isReset = false
    for _, panel in pairs(children) do
        if panel:getTag() == tag then
            equipListView:removeChild(panel)
            if children[_ + 1] then
                self:selectPanel(children[_ + 1])
            elseif children[_ - 1] then
                self:selectPanel(children[_ - 1])
            else
                isReset = true
            end
        end
    end

    if isReset then self:setEquipListView() end

    equipListView:removeChildByTag(tag)
    equipListView:refreshView()
end

-- 显示不同列表内容
function EquipmentChildDlg:setListType(key, isCommand, keepSelectPos)
    self.showEquips = nil

    if key == "EquipmentUpgradeDlg" then
        self.tabKey = key
        self:setUpgradeListView(keepSelectPos)
        DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
    elseif key == "EquipmentSplitDlg" then
        self.tabKey = key
        self:setEquipListView()
        DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
    elseif key == "EquipmentReformDlg" then
        if self.tabKey ~= key or isCommand then
            self.tabKey = key
            self:setEquipReformListView(nil, keepSelectPos)
        end
    elseif key == "EquipmentRefiningSuitDlg" then
        self.tabKey = key
        self:setEquipSuitListView(keepSelectPos)
        DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
    elseif key == "EquipmentEvolveDlg" then
        self.tabKey = key -- 设置单个panel时候需要对self.tabKey判断，进化显示和其他的有区别
        self:setEquipEvolveListView(keepSelectPos)
        DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
    end

end

-- 改造回来通知
function EquipmentChildDlg:MSG_GENERAL_NOTIFY(data)
    local listView = self:getControl("EquipmentListView")
    if NOTIFY.NOTIFY_EQUIP_UPGRADE_OK == data.notify  then
        local paraList = gf:split(data.para, "_")
        local pos = tonumber(paraList[1])
        local isSuccess = tonumber(paraList[2])
        local item = listView:getChildByTag(pos)

        local completionLabel = self:getControl("UpgradeCompletionLabel", Const.UILabel, item)
        local equip = InventoryMgr:getItemByPos(pos)
        -- 改造等级
        self:setLabelText("EquipmentUpgradeLevelLabel", CHS[3002404]..equip.rebuild_level, item)

        if completionLabel then
           if not equip["degree_32"] then
                completionLabel:setString("")
            else
                local degree = math.floor(equip["degree_32"] / 100) *100 / 1000000
                if degree == 0 then
                    completionLabel:setString("")
                else
                    completionLabel:setString(string.format("(+%0.4f%%)", degree))
                end
            end
        end
    elseif (NOTIFY.NOTIFY_EQUIP_EVOLVE_OK == data.notify or NOTIFY.NOTIFY_EQUIP_DEGENERATION_OK == data.notify) and self.tabKey == "EquipmentEvolveDlg" then
        local items = listView:getItems()
        for i, panel in pairs(items) do
            local pos = panel:getTag()
            local equip = InventoryMgr:getItemByPos(pos)
            self:setUnitEquipPanel(equip, panel)
        end
    end
end

function EquipmentChildDlg:updateOtherDlg()
    if self.selectPos then
        DlgMgr:sendMsg("EquipmentRefiningDlg", "setInfoByPos", self.selectPos)
    end
end

function EquipmentChildDlg:youMustGiveMeOneNotify(identify)
    GuideMgr:youCanDoIt(self.name, identify)
end

function EquipmentChildDlg:selectPanelByEquipId(id)
    if not id then return end
    local equipListView = self:getControl("EquipmentListView")
    local items = equipListView:getItems()
    local equip = InventoryMgr:getItemByIdFromAll(id)
    if not equip then return end
    for index, panel in pairs(items) do
        if panel:getTag() == equip.pos then
            self:selectPanel(panel)
        end
    end
end

function EquipmentChildDlg:getSelectItem(clickItem)
    local tag = nil
    local index = 0
    local equipListView = self:getControl("EquipmentListView")
    local equipList = {}
    if self.tabKey == "EquipmentRefiningSuitDlg" then
        local allEquipList = EquipmentMgr:getAllEquipments(true)
        local suitEquipList = self:getSuitEquipList(allEquipList)
        equipList = suitEquipList
        for i,equip in pairs(suitEquipList) do
            if equip.attrib:isSet(ITEM_ATTRIB.ITEM_APPLY_ON_GUIDE) then
                tag = equip.pos
                index = i
            end
        end
    elseif self.tabKey == "EquipmentReformDlg" or self.tabKey == "EquipmentRefiningDlg" then
        equipList = self.reformList
        for i, pos in pairs(self.reformList) do
            local equip = InventoryMgr:getItemByPos(pos)
            if equip.attrib:isSet(ITEM_ATTRIB.ITEM_APPLY_ON_GUIDE) then
                tag = equip.pos
                index = i
            end
        end
    elseif self.tabKey == "EquipmentSplitDlg" then
        equipList = self.equipOrder
        for i, pos in pairs(self.equipOrder) do
            local equip = InventoryMgr:getItemByPos(pos)
            if equip.attrib:isSet(ITEM_ATTRIB.ITEM_APPLY_ON_GUIDE) then
                tag = equip.pos
                index = i
            end
        end
    elseif self.tabKey == "EquipmentUpgradeDlg" then
        local panel = equipListView:getItem(0)
        if panel then return panel end
    end

    if tag then
        if self.selectPos == tag then return end

        local panel = equipListView:getChildByTag(tag)
        local size = equipListView:getContentSize()
        if (index + 1) * panel:getContentSize().height >= size.height then
            equipListView:getInnerContainer():setPositionY(-(#equipList - index) * panel:getContentSize().height)
        end
        return panel
    end
    local panel = equipListView:getItem(0)
    if panel then return panel end
end

function EquipmentChildDlg:getSelectItemBox(clickItem)
    local item = self:getSelectItem(clickItem)
    if item then return self:getBoundingBoxInWorldSpace(item) end
end

return EquipmentChildDlg
