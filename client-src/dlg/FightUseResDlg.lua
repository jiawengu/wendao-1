-- FightUseResDlg.lua
-- Created by liuhb Feb/9/2015
-- 战斗使用药品对话框

local GridPanel = require("ctrl/GridPanel")

local BAG_ROW_NUM = 10
local BAG_COL_NUM = 3
local BAG_GRID_MARGIN = 2
local GRID_W = 74
local GRID_H = 74
local ROW_SPACE = 6
local PER_PAGE_COUNT = 25

local FightUseResDlg = Singleton("FightUseResDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

function FightUseResDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", function(dlg, sender, eventType)
        self:setVisible(false)
        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
        if pet and Me:queryBasicInt('c_attacking_id') == pet:getId() then
            local dlg = DlgMgr:showDlg("FightPetMenuDlg", true)
            if dlg then
                dlg:updateFastSkillButton()
            end
        else
            local dlg = DlgMgr:showDlg("FightPlayerMenuDlg", true)
            if dlg then
                dlg:updateFastSkillButton()
            end
        end
    end)
    self.gridPanel = {}
    --self:resetFightBag()

    self.changeCardPanel = self:getControl("ChangeCardPanel", nil, "ChangeCardListViewPanel")
    self.changeCardPanel:retain()
    self.changeCardPanel:removeFromParent()

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"ItemCheckBox", "ChangeCardCheckBox"}, self.onCheckBox)
    self.radioGroup:selectRadio(1)


    -- 下拉加载
    self:bindListViewByPageLoad("ChangeCardListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 每次下拉时，加载PER_PAGE_COUNT个条目
            self:pushData()
        end
    end)

    -- 标记当前加载到的位置
    self.start = 1

    -- 设置点击窗口外回调函数
    --self:setClickOutCallBack(self.onCloseButton, true)

    self:hookMsg("MSG_INVENTORY")
end

function FightUseResDlg:resetFightBag()

end

function FightUseResDlg:onCheckBox(sender, eventType)
    local panelName = sender:getName()

    if panelName == "ItemCheckBox" then
        self:setCtrlVisible("ScrollView", true)
        self:setCtrlVisible("ChangeCardListViewPanel", false)
        self:setResMedicine()
    else
        self:setCtrlVisible("ScrollView", false)
        self:setCtrlVisible("ChangeCardListViewPanel", true)
        self:setChangeCard()
    end
end

function FightUseResDlg:showItems(index, data)

    local bagView = self:getControl('ScrollView', Const.UIScrollView)
    bagView:removeAllChildren()
    local size = bagView:getContentSize()
    local h = BAG_ROW_NUM * (GRID_H + ROW_SPACE)
    local rowNum = BAG_ROW_NUM
    if data.count > 30 then
        rowNum = math.ceil(data.count / BAG_COL_NUM)
        h = rowNum * (GRID_H + ROW_SPACE)
    end

    local grids = GridPanel.new(
        size.width, h,
        rowNum, BAG_COL_NUM,
        GRID_W, GRID_H,
        ROW_SPACE, BAG_GRID_MARGIN)
    grids:setTextMargin(8, 8)
    grids:setLevelMargin(-8, -8)
    --grids:setGridTextFontSize(15)

    grids:setDataLongClick(data, 1, function(idx, sender)
       -- 刷新标志位
        sender:updateBagGrid()

        -- 显示道具信息悬浮框
        local rect = self:getBoundingBoxInWorldSpace(sender)
        self.medicine = data[idx].medicine
        self:onUseButton()
    end, nil, function(idx, sender)
        -- 刷新标志位
        sender:updateBagGrid()

        -- 显示道具信息悬浮框
        local rect = self:getBoundingBoxInWorldSpace(sender)
        --InventoryMgr:showItemDlg(data[idx].pos, rect)
        InventoryMgr:showItemDescDlg(data[idx].pos, rect, {use = false, sell = false, more = false, resoure = false})
        self.root:requestDoLayout()
        self.medicine = data[idx].medicine
    end)

    bagView:addChild(grids)
    local size = grids:getContentSize()
    size.height = size.height
    bagView:setInnerContainerSize(size)
    self.showBag = data
    self.gridPanel[index] = grids

    bagView:jumpToTop()
    --[[ 默认选中第一个
    local sender = grids:setSelectedGridByIndex(1)
    if data.count > 0 then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showItemDescDlg(data[1].pos, rect, {use = false, sell = false, more = false, resoure = false})
        self.root:requestDoLayout()
        self.medicine = data[1].medicine
    end
    --]]
end

function FightUseResDlg:setResMedicine()
    self:setLabelText("NameLabel", "")
    self:setLabelText("Label1", "")
    self:setLabelText("Label4", "")

    -- 获取药品
    local data = {}
    local medicines = InventoryMgr:getItemForFightUseResDlg()

    for _, v in pairs(medicines) do
        local imgFile = InventoryMgr:getIconFileByName(v.name)
        local text = ""
        if v.amount > 1 then
            text = tostring(v.amount)
        end

        local medicine = v
        -- 指引状态下 一叶草为第一个
        if GuideMgr:getCurGuidId() == 19 then
            if v.name == CHS[6000183] then  --一叶草排在第一个
                table.insert(data, 1, {imgFile = imgFile, pos = v.pos, text = text, level = v.level,medicine = medicine})
            else
                table.insert(data, {imgFile = imgFile, pos = v.pos, text = text, level = v.level,medicine = medicine})
            end
        else
            table.insert(data, {imgFile = imgFile, pos = v.pos , text = text, level = v.level, medicine = medicine})
        end
    end

    if 30 - #data > 0 then
        for i = 1, 30-#data do
            table.insert(data, {imgFile = ResMgr.ui.bag_no_item_bg_img})
        end
    end

    data.count = #data

    self:showItems(1, data)
end

function FightUseResDlg:setMedicineDes(medicine)
    if nil == medicine then return end

    -- 放置显示
    self:setLabelText("NameLabel", medicine.name)
    self:setLabelText("Label1", medicine.des)
    self:setLabelText("Label4", medicine.useDes)
end

function FightUseResDlg:setChangeCard()
    local listView = self:getControl("ChangeCardListView")
    listView:removeAllChildren()
    local data = StoreMgr:getAllChangeCardDisplayAmount()
    self.changeCardList = data
    self.start = 1
    self:pushData()
end

function FightUseResDlg:pushData()
    local listView = self:getControl("ChangeCardListView")
    local start = self.start
    local data = self.changeCardList
    if not start or not data then
        return
    end

    if #data < start then
        return
    end

    for i = start, start + PER_PAGE_COUNT - 1 do
        if data[i] then
            local cardName = data[i].name
            local polar = data[i].polar
            local count = data[i].count
            local imgFile = InventoryMgr:getIconFileByName(cardName)
            local cell = self.changeCardPanel:clone()
            local imgCtrl = self:getControl("IconImage", nil, cell)

            self:setLabelText("NameLabel", cardName, cell)
            self:setLabelText("NumLabel", CHS[4100091] .. count, cell)
            self:setImage("IconImage", imgFile, cell)
            self:setItemImageSize("IconImage", cell)
            InventoryMgr:addPolarChangeCard(imgCtrl, cardName)
            cell:setName(cardName)

            -- 长按与点击
            self:blindLongPress(cell,
                function(dlg, sender, eventType)
                    local cardName = sender:getName()
                    local costCard = InventoryMgr:getChangeCardByCostOrder(cardName)
                    local rect = self:getBoundingBoxInWorldSpace(sender)
                    InventoryMgr:showItemDescDlg(costCard.pos, rect)
                    self.medicine = costCard
                    self:addSelectEffect(cardName)
                end,

                function(dlg, sender, eventType)
                    local cardName = sender:getName()
                    local costCard1,costCard2 = InventoryMgr:getChangeCardByCostOrder(cardName)

                    if Me:queryBasicInt('c_attacking_id') == Me:getId() then
                        self.medicine = costCard1
                        Me:setFightUseChangeCardPos(costCard1.pos)
                    else
                        if Me:getFightUseChangeCardPos() == costCard1.pos and costCard2 then
                            -- 宠物使用跟人物同一张变身卡，且当前变身卡大于1张时，才使用第二张
                            self.medicine = costCard2
                        else
                            self.medicine = costCard1
                        end
                    end

                    self:onUseButton()
                    self:addSelectEffect(cardName)
                end)

            listView:pushBackCustomItem(cell)
            self.start = self.start + 1
        end
    end

    local innerContainer = listView:getInnerContainerSize()
    innerContainer.height = (self.start - 1) * self.changeCardPanel:getContentSize().height
    listView:setInnerContainerSize(innerContainer)
end

function FightUseResDlg:addSelectEffect(cardName)
    local listView = self:getControl("ChangeCardListView")
    for k, v in pairs(listView:getChildren()) do
        self:setCtrlVisible("BChosenEffectImage", false, v)
    end

    local selectedCard = listView:getChildByName(cardName)
    self:setCtrlVisible("BChosenEffectImage", true, selectedCard)
end

function FightUseResDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    if Me:queryBasicInt('c_enable_input') == 0 then
        return
    end

    if Me:queryBasicInt('c_attacking_id') == Me:getId() then
        local dlg = DlgMgr:showDlg("FightPlayerMenuDlg", true)
        if dlg then
            dlg:updateFastSkillButton()
        end
    else

        local dlg = DlgMgr:showDlg("FightPetMenuDlg", Me:queryBasicInt('c_pet_finished_cmd') == 0)
        if dlg then
            dlg:updateFastSkillButton()
        end
    end
end

function FightUseResDlg:onUseButton(sender, eventType)
    -- 切换战斗选择界面，隐藏此界面
    if nil == self.medicine then
        return
    end

    if self.medicine.attrib:isSet(ITEM_ATTRIB.APPLY_NO_TARGET) then
        local function useItem()
            Me.op = ME_OP.FIGHTING_PROPERTY_ME
            local attackId = Me:queryBasicInt('c_attacking_id')
            gf:sendFightCmd(attackId, Me:getId(), FIGHT_ACTION.APPLY_ITEM, self.medicine.pos)
            FightMgr:changeMeActionFinished()
            self:onCloseButton()
        end

        local item
        local combatMode =  FightMgr:getCombatMode()
        if self.medicine.pos >= StoreMgr:getCardStartPos() then
            item = StoreMgr:getCardByPos(self.medicine.pos)
        else
            item = InventoryMgr:getItemByPos(self.medicine.pos)
        end
        if self.medicine.name == CHS[3002615]
              or self.medicine.name == CHS[5410239] then
            -- 火眼金睛
            local dlg = gf:confirm(string.format(CHS[3002616], self.medicine.name), function()
                useItem()
            end)

            dlg:setCombatOpenType()
        elseif self.medicine.name == CHS[2000246] then
            -- 妖劫咒
            gf:confirm(CHS[2100088], function()
                useItem()
            end)
        elseif item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        -- 如果为变身卡，增加确认框
            local changeCardTask = TaskMgr:getTaskByName(CHS[4200010])
            local dlg = nil

            if changeCardTask and not string.match(changeCardTask.task_prompt, item.name) then
                -- 当前已使用其他变身卡，提示是否需要覆盖原变身卡
                if Me:queryBasicInt('c_attacking_id') == Me:getId() then
                    dlg = gf:confirm(string.format(CHS[7150010], item.name), function ()
                        useItem()
                    end)
                else
                    dlg = gf:confirm(string.format(CHS[7150012], item.name), function ()
                        useItem()
                    end)
                end
            else
                if Me:queryBasicInt('c_attacking_id') == Me:getId() then
                    dlg = gf:confirm(string.format(CHS[7150011], item.name), function ()
                        useItem()
                    end)
                else
                    dlg = gf:confirm(string.format(CHS[7150013], item.name), function ()
                        useItem()
                    end)
                end
            end

            dlg:setCombatOpenType()

        elseif item.item_type == ITEM_TYPE.DISH then
            -- 菜肴
            if string.match(item.name, CHS[2000378]) or string.match(item.name, CHS[2000379]) then
                local task = TaskMgr:getTaskByName(CHS[2000380])
                if task and task.task_extra_para == item.name and (task.task_end_time - gf:getServerTime()) > 20 * 60 then
                    gf:ShowSmallTips(string.format(CHS[2000381], item.name, 30))
                    return
                end

                if task and task.task_extra_para ~= item.name then
                    local tip = Me:queryBasicInt('c_attacking_id') == Me:getId() and CHS[2000403] or CHS[2000382]
                    local dlg = gf:confirm(string.format(tip, item.name), function ()
                        useItem()
                    end)

                    dlg:setCombatOpenType()
                elseif not task or task.task_extra_para == item.name then
                    local tip = Me:queryBasicInt('c_attacking_id') == Me:getId() and CHS[2000404] or CHS[2000383]
                    local dlg = gf:confirm(string.format(tip, item.name), function ()
                        useItem()
                    end)

                    dlg:setCombatOpenType()
                end
            else
                useItem()
            end
        elseif self.medicine.name == CHS[5400090] then
            -- 金光符
            if combatMode == COMBAT_MODE.COMBAT_MODE_GHOST_02 then
                gf:confirm(string.format(CHS[3000070], item.name), function ()
                    useItem()
                end)
            else
                gf:ShowSmallTips(CHS[5400091])
            end
        else
            useItem()
        end
        return
    end

    local medicine = self.medicine
    local medicinePos = medicine.pos
    local item = InventoryMgr:getItemByPos(medicinePos)
    Me.op = ME_OP.FIGHTING_PROPERTY_ME
    Me:setBasic("sel_medicine_pos", medicinePos)

    if nil == InventoryMgr:getIconByName(medicine.name) then
        gf:ShowSmallTips(CHS[5000089])
    end

    DlgMgr:showDlg(self.name, false)
    local dlg = DlgMgr:openDlg("FightTargetChoseDlg")
    local tips = InventoryMgr:getItemFuncInCombat(item)

    dlg:setTips(medicine.name, tips)
end

function FightUseResDlg:onSelectItemDisplayListView(sender, eventType)
end

function FightUseResDlg:getItemsInFight()
    self.radioGroup:selectRadio(1)
end

function FightUseResDlg:cleanup()
    self:releaseCloneCtrl("changeCardPanel")
end

function FightUseResDlg:MSG_INVENTORY(data)
    local ctrl = self.radioGroup:getSelectedRadio()
    self:onCheckBox(ctrl)
end

return FightUseResDlg
