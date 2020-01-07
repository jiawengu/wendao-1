-- ItemDecomposeDlg.lua
-- Created by huangzz Jan/30/2019
-- 道具分解

local ItemDecomposeDlg = Singleton("ItemDecomposeDlg", Dialog)
local ScrollView = require("ctrl/ScrollViewLoadPart")

local MAX_COUNT = 6

local MAX_POINT = 999999

function ItemDecomposeDlg:init()
    self:bindListener("DecomposeButton", self.onDecomposeButton)
    self:bindListener("ShopButton", self.onShopButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:blindLongPress("ItemPanel", self.onLongItemPanel, self.onItemPanel)

    self:bindFloatPanelListener("RulePanel")

    local cloneCtrl = self:retainCtrl("ItemPanel")
    self.choosingImg = self:retainCtrl("ChoosingEffectImage", cloneCtrl)
    self.scrollView = ScrollView.new(self, "ScrollView", cloneCtrl, self.setOneItemPanel, 4, 12, 12, 0, 0)

    self.needWaitServerMsg = nil
    self:initItemList()

    self:setOwnPoint()

    self:hookMsg("MSG_DECOMPOSE_ITEM_RESULT")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
end

function ItemDecomposeDlg:initItemList(needSelect)
    self.clickItemTag = nil
    self.totalPoint = 0

    self.items = InventoryMgr:geCanDecomposeItems()
    if needSelect then
        local selects = gf:deepCopy(self.selectItems)
        self.selectItems = {}
        for tag, item in pairs(self.items) do
            if selects[item.index] then
                self.selectItems[item.index] = tag
            end
        end

        gf:PrintMap(self.selectItems)
    else
        self.selectItems = {}
    end

    if #self.items > 0 then
        self:setCtrlVisible("NoticePanel", false)
        self.scrollView:initList(self.items)
    else
        self:setCtrlVisible("NoticePanel", true)
        self.scrollView:initList({})
    end

    self:setGetPoint()
end

-- 显示拥有的灵尘点数
function ItemDecomposeDlg:setOwnPoint()
    local str = gf:getArtFontMoneyDesc(Me:queryBasicInt("lingchen_point"))
    self:setNumImgForPanel("OwnLingchenPanel", ART_FONT_COLOR.DEFAULT, str, false, LOCATE_POSITION.CENTER, 21)
end

-- 显示可获取的灵尘点数
function ItemDecomposeDlg:setGetPoint()
    local str = gf:getArtFontMoneyDesc(self.totalPoint)
    self:setNumImgForPanel("GetLingchenPanel", ART_FONT_COLOR.DEFAULT, str, false, LOCATE_POSITION.CENTER, 21)
end

-- 显示单个道具
function ItemDecomposeDlg:setOneItemPanel(cell, data, tag)
    self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), cell)

    -- 一定是限制交易道具
    InventoryMgr:addLogoBinding(self:getControl("ItemImage", nil, cell))

    self:setCtrlVisible("GetImage", self.selectItems[data.index] and true or false, cell)

    cell.data = data
end

-- 获取当前选中的道具数量
function ItemDecomposeDlg:getSelectCount()
    local cou = 0
    for _, v in pairs(self.selectItems) do
        if v then
            cou = cou + 1
        end
    end

    return cou
end

-- 分解
function ItemDecomposeDlg:onDecomposeButton(sender, eventType)
    -- 若角色处于禁闭状态，则给予弹出提示
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若角色处于战斗中，弹出提示
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002257])
        return
    end

    -- 若分解后灵尘数量超过可持有上限，则予以弹出提示
    if self.totalPoint + Me:queryBasicInt("lingchen_point") > MAX_POINT then
        gf:ShowSmallTips(CHS[5400796])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onDecomposeButton", sender) then
        return
    end

    local info = {}
    for index, tag in pairs(self.selectItems) do
        if tag and self.items[tag] and self.items[tag].item_unique then
            local item = InventoryMgr:getItemByPos(self.items[tag].pos)
            if not item or item.item_unique ~= self.items[tag].item_unique then
                -- 部分道具状态已发生变化。
                gf:ShowSmallTips(CHS[5400794])

                self:initItemList()
                return
            end

            table.insert(info, self.items[tag].item_unique)
        end
    end

    if #info <= 0 then
        gf:ShowSmallTips(CHS[5400795])
        return
    end

    if self.needWaitServerMsg then
        return
    end

    self.needWaitServerMsg = true
    performWithDelay(self.root, function()
        -- 容错
        self.needWaitServerMsg = nil
    end, 3)

    gf:CmdToServer("CMD_DECOMPOSE_LINGCHEN_ITEM", info)
end

-- 长按弹出悬浮框
function ItemDecomposeDlg:onLongItemPanel(sender, eventType)
    local tag = sender:getTag()
    -- self.choosingImg:removeFromParent()
    -- sender:addChild(self.choosingImg)
    -- self.clickItemTag = tag

    if not sender.data then return end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    local item = InventoryMgr:getItemByPos(sender.data.pos)
    InventoryMgr:showOnlyFloatCardDlg(item,rect)
end

-- 点击道具选中
function ItemDecomposeDlg:onItemPanel(sender, eventType)
    local tag = sender:getTag()
    -- self.choosingImg:removeFromParent()
    -- sender:addChild(self.choosingImg)
    -- self.clickItemTag = tag

    if not sender.data then return end
    local index = sender.data.index
    if self.selectItems[index] then
        self.selectItems[index] = nil

        self:setCtrlVisible("GetImage", false, sender)

        self.totalPoint = self.totalPoint - InventoryMgr:getItemLingchenPoint(sender.data.name)
    else
        if self:getSelectCount() >= MAX_COUNT then
            gf:ShowSmallTips(CHS[5400793])
            return
        end

        self.selectItems[index] = tag

        self:setCtrlVisible("GetImage", true, sender)

        self.totalPoint = self.totalPoint + InventoryMgr:getItemLingchenPoint(sender.data.name)
    end

    self:setGetPoint()
end

-- 打开灵尘商店
function ItemDecomposeDlg:onShopButton(sender, eventType)
    -- 若角色处于禁闭状态，则给予弹出提示
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若角色处于战斗中，弹出提示
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002257])
        return
    end

    gf:CmdToServer("CMD_OPEN_LINGCHEN_SHOP", {})
end

function ItemDecomposeDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function ItemDecomposeDlg:MSG_INVENTORY(data)
    if self.needWaitServerMsg then return end
    self:initItemList(true)
end

function ItemDecomposeDlg:MSG_UPDATE(data)
    self:setOwnPoint()
end

function ItemDecomposeDlg:MSG_DECOMPOSE_ITEM_RESULT(data)
    if data.result == 1 then
        self:initItemList()
    end

    self.needWaitServerMsg = nil
end

return ItemDecomposeDlg
