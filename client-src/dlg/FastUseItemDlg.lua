-- FastUseItemDlg.lua
-- Created by songcw Api/27/2015
-- 快速使用物品界面

local FastUseItemDlg = Singleton("FastUseItemDlg", Dialog)
local NumImg = require('ctrl/NumImg')

FastUseItemDlg.items = {}

local need_use_effect = {
    CHS[3002595], CHS[3002596], CHS[3002597], -- 血池
    CHS[3002598], CHS[3002599], CHS[3002600], -- 灵池
    CHS[3002601], CHS[3002602],    -- 驯兽决
    CHS[7100055],    -- 搜邪罗盘
}

local fail_not_close = {
    [CHS[5400691]] = true,
    [CHS[5400692]] = true,
    [CHS[5400693]] = true,
    [CHS[5420352]] = true,
}

local NEED_FIRST_USE = {
    [CHS[5400691]] = true,
    [CHS[5400692]] = true,
    [CHS[5400693]] = true,
    [CHS[5420352]] = true,
}

FastUseItemDlg.preUseItemCount = 0

function FastUseItemDlg:init()
    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("ItemImage", self.onItemCardButton)
    self.blank:setLocalZOrder(Const.FAST_USE_ITEM_DLG_ZORDER)
    self:blindLongPress("UseButton", self.onLongUseButton, self.onUseButton)
    self.itemName = nil
    self.applyTime = 0

    self.root:setAnchorPoint(0, 0)
    local dlgSize = self.root:getContentSize()
    self.root:setPosition(Const.WINSIZE.width, 0)

    -- 动作结束回调
    local actCallBack = cc.CallFunc:create(function()
        if GuideMgr:isRunning() then
            self.iamok= true
        end
    end)

    local move = cc.MoveTo:create(0.5, cc.p(Const.WINSIZE.width / Const.UI_SCALE - dlgSize.width - (Const.WINSIZE.width - self:getWinSize().width) / 2, 0))
    local moveAct = cc.EaseBounceOut:create(move)
    self.root:runAction(cc.Sequence:create(moveAct, actCallBack))
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_ITEM_APPLY_FAIL")
end

function FastUseItemDlg:onUpdate()
    if self.iamok and self.giveGuideNotify and not self.justOnce then
        self.justOnce = true
        GuideMgr:youCanDoIt(self.name, "iamok")
    end
end

function FastUseItemDlg:cleanup()
    self.giveGuideNotify = nil
    self.iamok = nil
    self.justOnce = false
end

function FastUseItemDlg:forceUseItem()
    self.itemName = nil
    self.items = {}
    self.iamok = true
end

function FastUseItemDlg:setInfo(itemName, itemId)
    if self.itemName and self.itemName ~= itemName then
        if NEED_FIRST_USE[itemName] then
            self:addItem(itemName, true)
        else
            self:addItem(itemName)
            return
        end
    end

    self.itemName = itemName
    self.itemId = itemId
    local pos = InventoryMgr:getItemPosById(tonumber(itemId))
    if pos then
        self.usePos = pos
    else
        self.usePos = InventoryMgr:getItemPosByName(self.itemName)
    end

    if not self.usePos then
        -- 如果找不到物品位置，说明，已经被用了
        --self:onCloseButton()
        DlgMgr:closeDlg(self.name)
        return
    end

    local item = InventoryMgr:getItemByPos(self.usePos)
    if not item then
        -- 物品不存在
        DlgMgr:closeDlg(self.name)
        return
    end

    if item.equip_type == ITEM_TYPE.EQUIPMENT then
        local button = self:getControl("UseButton")
        self:setLabelText("Label_1", CHS[3002603], button)
        self:setLabelText("Label_2", CHS[3002603], button)
        local color = InventoryMgr:getEquipmentNameColor(item)
        self:setLabelText("NameLabel", string.isNilOrEmpty(item.alias) and item.name or item.alias, nil, color)

        if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level and item.req_level > 0 then
            self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
        end
    else
        self:setLabelText("NameLabel", string.isNilOrEmpty(item.alias) and item.name or item.alias)
        local amount = InventoryMgr:getAmountByName(itemName)
        if amount > 999 then amount = 999 end
        --使用接口，为Panel设置NumImg控件：setNumImgForPanel()
        self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.DEFAULT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    end

    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName)))
    self:setItemImageSize("ItemImage")
end

function FastUseItemDlg:addItem(itemName, front)
    local useType = InventoryMgr:getFastUseTypeByItemName(itemName)

    for i, item in pairs(self.items) do
        if itemName == item.itemName then
            if front then
                table.remove(self.items, i)
                break
            else
                return
            end
        end
    end

    useType = useType or itemName
    if front then
        table.insert(self.items, 1, { itemName = itemName, useType = useType})
    else
        table.insert(self.items, { itemName = itemName, useType = useType})
    end
end

function FastUseItemDlg:onItemCardButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local pos = InventoryMgr:getItemPosByName(self.itemName)
    if not pos then return end
    local item = InventoryMgr:getItemByPos(pos)
    local dlg = DlgMgr:openDlg('ItemInfoDlg')
    dlg.blank:setLocalZOrder(Const.FAST_USE_ITEM_DLG_ZORDER + 1)

    dlg:setInfoFormCard(item)
    dlg:setFloatingFramePos(rect)
end

function FastUseItemDlg:onLongUseButton(sender, eventType)
    for k, v in pairs(need_use_effect) do
        if v == self.itemName then
            local amount = InventoryMgr:getAmountByPos(self.usePos)
            InventoryMgr:applyItem(self.usePos, amount)  -- 使用该道具
            FastUseItemDlg.preUseItemCount = amount

            -- 搜邪罗盘长按使用成功后需要关闭界面
            if self.itemName == CHS[7100055] then
                DlgMgr:closeDlg(self.name)
            end
        end
    end
end

function FastUseItemDlg:useItemEffect()
    local imageNode = self:getControl("ItemPanel")
    local size = imageNode:getContentSize()
    local rect = self:getBoundingBoxInWorldSpace(imageNode)
    local pos = {}
    pos.x = rect.x + rect.width * 0.5
    pos.y = rect.y + rect.height * 0.5
    local magic = gf:addMagicToUILayer(ResMgr.ArmatureMagic.quick_use_item, pos)

    -- 本界面特殊，ZOrder在init中设置过，而美术需求特效在此界面之上，所以需要设置特效ZOrder
    magic:setLocalZOrder(Const.FAST_USE_ITEM_DLG_ZORDER + 1)
    FastUseItemDlg.preUseItemCount = 0
end

function FastUseItemDlg:onUseButton(sender, eventType)
    local pos = InventoryMgr:getItemPosById(tonumber(self.itemId))
    if pos then
        self.usePos = pos
    else
        self.usePos = InventoryMgr:getItemPosByName(self.itemName)
    end

    local item = InventoryMgr:getItemByPos(self.usePos)
    if not item then
        gf:ShowSmallTips(CHS[3002604])  -- 使用失败，找不到道具！
        InventoryMgr:setFastUseItemFlag(self.itemName, false)

        if #self.items == 0 then DlgMgr:closeDlg(self.name) return end
        while #self.items ~= 0 and not InventoryMgr:isCanFastUseByItemName(self.items[1].useType) do
            table.remove(self.items, 1)
        end


        if #self.items == 0 then DlgMgr:closeDlg(self.name) return end
        self.itemName = self.items[1].itemName
        self:setInfo(self.items[1].itemName)
        table.remove(self.items, 1)
        return
    end

    self:setCtrlOnlyEnabled("UseButton", false)
    InventoryMgr:applyItem(self.usePos)
    if item.item_type == ITEM_TYPE.EQUIPMENT
        or self.itemName == CHS[7100055]
        or self.itemName == CHS[2200001]
        or self.itemName == CHS[5400322]
        or self.itemName == CHS[7190125]
        or self.itemName == CHS[5410238]
        or item.attrib:isSet(ITEM_ATTRIB.ITEM_FAST_USE) then
        DlgMgr:closeDlg(self.name)
    end

    for k, v in pairs(need_use_effect) do
        if v == self.itemName then
            self.applyTime = self.applyTime + 1
            FastUseItemDlg.preUseItemCount = item.amount
            if self.applyTime == 3 then
                gf:ShowSmallTips(CHS[3002605])
                self.applyTime = 0
            end
        end
    end
end

function FastUseItemDlg:onCloseButton(sender, eventType)
    if self.itemName ~= CHS[7100055] then

        InventoryMgr:setFastUseItemFlag(self.itemName, false)
            end

    if #self.items == 0 then DlgMgr:closeDlg(self.name) return end
    while #self.items ~= 0 and not InventoryMgr:isCanFastUseByItemName(self.items[1].useType) do
        table.remove(self.items, 1)
    end
    if #self.items == 0 then DlgMgr:closeDlg(self.name) return end
    self.itemName = self.items[1].itemName
    self:setInfo(self.items[1].itemName)
    table.remove(self.items, 1)
end

function FastUseItemDlg:onDlgOpened(list)
    self:setInfo(list[1])
end

function FastUseItemDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    self:setCtrlOnlyEnabled("UseButton", true)
    if not self.usePos or self.usePos ~= data[1].pos then return end

    if self.preUseItemCount > 0 and (not data[1].amount or self.preUseItemCount > data[1].amount) then
        self:useItemEffect()
    end

    if InventoryMgr:getAmountByName(self.itemName) ~= 0 then
        self:setInfo(self.itemName)
        return
    else
        if #self.items == 0 then
            DlgMgr:closeDlg(self.name)
        else
            self.applyTime = 0
            self.itemName = self.items[1].itemName
            self:setInfo(self.items[1].itemName)
            table.remove(self.items, 1)
        end
    end
end

function FastUseItemDlg:MSG_ITEM_APPLY_FAIL(data)
    self:setCtrlOnlyEnabled("UseButton", true)
    if fail_not_close[self.itemName] and InventoryMgr:getAmountByName(self.itemName) ~= 0 then
        -- 策划设定，烟花播放失败不关闭快捷框
        self:setInfo(self.itemName)
    elseif not self.items or #self.items == 0 then
        DlgMgr:closeDlg(self.name)
    else
        self.applyTime = 0
        self.itemName = self.items[1].itemName
        self:setInfo(self.items[1].itemName)
        table.remove(self.items, 1)
    end
end

-- 如果需要使用指引通知类型，需要重载这个函数
function FastUseItemDlg:youMustGiveMeOneNotify(param)
    if param == "iamok" then
        self.giveGuideNotify = true
    end
end

return FastUseItemDlg
