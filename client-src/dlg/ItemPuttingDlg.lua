-- ItemPuttingDlg.lua
-- Created by huangzz Oct/21/2018
-- 道具摆放界面

local ItemPuttingDlg = Singleton("ItemPuttingDlg", Dialog)

local ITEM_INFO = {
    {name = CHS[5450367], portrait = 52061},  -- 红玫瑰
    {name = CHS[5450368], portrait = 52064},  -- 蓝玫瑰
    {name = CHS[5450369], portrait = 52062},  -- 白百合
    {name = CHS[5450370], portrait = 52063},  -- 蜡烛
    {name = CHS[5450371], portrait = 52065},  -- 小酒碗
}

function ItemPuttingDlg:init()
    self:setFullScreen()
    self:bindListener("UpButton", self.onUpButton)
    self:bindListener("DownButton", self.onDownButton)
    self:bindListener("MoveLockButton", self.onMoveLockButton)
    self:bindListener("MoveOnButton", self.onMoveOnButton)
    self:bindListener("ItemPanel", self.onItemPanel, nil, true)

    self.itemPanel = self:retainCtrl("ItemPanel")
    self.isHideMainPanel = false

    self.winSize = self:getWinSize()

    self.itemsInfo = self:getPuttingItems()

    AutoWalkMgr:stopAutoWalk()

    self.selectItem = nil
    self.selectItemFromMap = nil

    local scrollView = self:getControl("ListScrollView")
    self:initScrollViewPanel(self.itemsInfo, self.itemPanel, self.setOneItemPanel, scrollView, #self.itemsInfo, 10, 10, 20, 10, ccui.ScrollViewDir.horizontal)
    self.scrollView = scrollView

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    self:onMoveOnButton()

    self:updateObjShelter()

    self:bindTouchLayout()

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_ENTER_ROOM")
end

function ItemPuttingDlg:updateObjShelter()
    for _, v in pairs(CharMgr.chars) do
        if v.curX and v.curY and v.updateShelter then
            v:updateShelter(gf:convertToMapSpace(v.curX, v.curY))
        end
    end

    for _, v in pairs(HomeMgr.furnitures) do
        if v.curX and v.curY and v.updateShelter then
            v:updateShelter(gf:convertToMapSpace(v.curX, v.curY))
        end
    end
end

function ItemPuttingDlg:bindTouchLayout()
    local panel = ccui.Layout:create()
    local function getTouchItem(touch)
        if self.selectItem then return end

        if self.selectItemFromMap then return end

        if DlgMgr:getDlgByName("HomePlantDlg") then
            return
        end

        local childrens = gf:getPuttingObjLayer():getChildren()
        local pos = gf:getPuttingObjLayer():convertTouchToNodeSpace(touch)
        local selectInfo = {minDis = 1000000}
        for i = #childrens, 1, -1 do
            local children = childrens[i]
            if children.belongObj and children:isVisible() then
                local item = children.belongObj
                if item.image then
                    if item:containsTouchPos(pos) then
                        local dis = math.abs(item.curX - pos.x) + math.abs(item.curY - pos.y)
                        if item:isOper() then
                            -- 已经拿起来了，不用判断距离
                            return item
                        elseif selectInfo.minDis > dis then
                            -- 选离触点最近的道具
                            selectInfo.minDis = dis
                            selectInfo.item = item
                        end
                    end
                end
            end
        end

        return selectInfo.item
    end

    local checkAction, longPressAction
    local function onTouch(touch, event)
        if event:getEventCode() == cc.EventCode.BEGAN then
            local item = getTouchItem(touch)
            if not item then return false end

            self.selectItemFromMap = item

            if item:isOper() then
                item:takeUp()
            else
                -- 不处于操作中，长按0.3s后进入操作状态
                longPressAction = performWithDelay(item.image, function()
                    longPressAction = nil
                    if PuttingItemMgr:hasOperItem() then
                        gf:ShowSmallTips(CHS[5450366])
                        return
                    end

                    if not item:isPreItem() then
                        gf:CmdToServer("CMD_MAP_DECORATION_CHECK", {id = item:getId()})
                        item.isPreTake = true
                    else
                        item:takeUp()
                    end
                end, GameMgr:getLongPressTime())
            end
            return true
        elseif event:getEventCode() == cc.EventCode.MOVED then
            if not self.selectItemFromMap then return end

            local item = self.selectItemFromMap
            if not item:isTakeUp() then
                local pos = gf:getPuttingObjLayer():convertTouchToNodeSpace(touch)
                if not item:containsTouchPos(pos) then
                    item.isPreTake = false
                    item.image:stopAction(longPressAction)
                    longPressAction = nil
                    self.selectItemFromMap = nil
                end

                return
            end

            item:setDragItemPos()
        elseif event:getEventCode() == cc.EventCode.ENDED
                or event:getEventCode() == cc.EventCode.CANCELLED then
            if not self.selectItemFromMap then return end

            local item = self.selectItemFromMap
            if longPressAction then
                item.image:stopAction(longPressAction)
                longPressAction = nil

                -- 触发角色走路
                local pos = touch:getLocation()
                Me:touchMapBegin(pos)
                Me:touchMapEnd(pos)
            end
            
            if item:isTakeUp() then
                item:putDown()
            end

            item.isPreTake = false
            self.selectItemFromMap = nil
        end
    end

    gf:getPuttingObjLayer():addChild(panel, -1, 0)
    gf:bindTouchListener(panel, onTouch, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)

    self.touchPanel = panel
end

function ItemPuttingDlg:createPreItem(data, pos)
    pos = pos or {}
    return PuttingItemMgr:createPreItem({
            icon = data.portrait,
            name = data.name,
            client_id = PuttingItemMgr:getClientId(),
            x = pos.x,
            y = pos.y,
        }, true)
end

function ItemPuttingDlg:onItemPanel(sender, eventType)
    local scrollView = self:getControl("ListScrollView")
    local data = sender.data
    if eventType == ccui.TouchEventType.began then
        if self.selectItemFromMap then return end

        if self.selectItem then return end

        if self.longPress ~= nil then
            sender:stopAction(self.longPress)
            self.longPress = nil
        end

        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002307])
            return
        end
 
        local amount = self:getItemAmount(data.name)
        if amount > 0 then
            local callFunc = cc.CallFunc:create(function()
                self.longPress = nil
                if not sender:isHighlighted() then
                    return
                end

                if PuttingItemMgr:hasOperItem() then
                    self.selectItem = nil
                    gf:ShowSmallTips(CHS[5450366])
                    return
                end

                self.selectItem = self:createPreItem(data, GameMgr.curTouchPos and gf:getPuttingObjLayer():convertToNodeSpace(GameMgr.curTouchPos))
                self.selectItem:takeUp()
                scrollView:setDirection(ccui.ScrollViewDir.none)

                self:updateItemAmount(sender)
            end)

            self.longPress = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
            sender:runAction(self.longPress)
        end
    elseif eventType == ccui.TouchEventType.moved then
        if self.selectItemFromMap then return end
        if not self.selectItem or not self.selectItem:isTakeUp() then
            return
        end

        self.selectItem:setDragItemPos()
    else
        local amount = self:getItemAmount(data.name)
        if self.longPress ~= nil then
            sender:stopAction(self.longPress)
            self.longPress = nil
            if PuttingItemMgr:hasOperItem() then
                gf:ShowSmallTips(CHS[5450366])
            else
                self:createPreItem(data)

                self:updateItemAmount(sender)
            end
        end

        if self.selectItem then
            self.selectItem:putDown()
        elseif amount == 0 and eventType == ccui.TouchEventType.ended and not Me:isInJail() and not Me:isInCombat() then
            gf:CmdToServer("CMD_MAP_DECORATION_BUY", {item_name = data.name})
        end

        performWithDelay(scrollView , function()
            scrollView:setDirection(ccui.ScrollViewDir.horizontal)
        end, 0)

        self.selectItem = nil
    end
end

function ItemPuttingDlg:updateItemAmount(cell)
    if cell and cell.data then
        local amount = self:getItemAmount(cell.data.name)
        self:setLabelText("NumLabel", amount, cell)
    end
end

function ItemPuttingDlg:getItemAmount(name)
    return InventoryMgr:getAmountByName(name, true) - PuttingItemMgr:getPreItemAmount(name)
end

function ItemPuttingDlg:getPuttingItems()
    local info = {}
    for i = 1, #ITEM_INFO do
        local amount = self:getItemAmount(ITEM_INFO[i].name)
        -- if amount > 0 then
            table.insert(info, {portrait = ITEM_INFO[i].portrait, name = ITEM_INFO[i].name, amount = amount})
        -- end
    end

    return info
end

function ItemPuttingDlg:setOneItemPanel(cell, data)
    -- 名字
    self:setLabelText("NameLabel", data.name, cell)

    -- 图片
    local imgPath = ResMgr:getIconPathByName(data.name)
    self:setImage("FurnitureImage", imgPath, cell)

    -- 等级
    -- self:setLabelText("LevelLabel", data.level, cell)

    cell.data = data

    self:setLabelText("NumLabel", data.amount, cell)
end

function ItemPuttingDlg:onUpButton(sender, eventType)
    if not self.isHideMainPanel then
        return
    end
    
    local changeHeight = self:getControl("BKImage_2"):getContentSize().height
    local action = cc.MoveBy:create(0.5, {x = 0, y = changeHeight + self:getWinSize().oy})
    self:getControl("MainPanel"):runAction(action)
    
    sender:setVisible(false)
    self.isHideMainPanel = false
end

function ItemPuttingDlg:onDownButton(sender, eventType)
    if self.isHideMainPanel then
        return
    end
    
    local changeHeight = self:getControl("BKImage_2"):getContentSize().height
    local action = cc.Sequence:create(
        cc.MoveBy:create(0.5, {x = 0, y = -changeHeight - self:getWinSize().oy}),
        cc.CallFunc:create(function() 
            self:setCtrlVisible("UpButton", true)
        end)
    )
    
    self:getControl("MainPanel"):runAction(action)
    self.isHideMainPanel = true
end

function ItemPuttingDlg:onMoveOnButton(sender, eventType)
    Me:setCanMove(false)
    self:setCtrlVisible("MoveLockButton", true)
    self:setCtrlVisible("MoveOnButton", false)
end

function ItemPuttingDlg:onMoveLockButton(sender, eventType)
    Me:setCanMove(true)
    self:setCtrlVisible("MoveLockButton", false)
    self:setCtrlVisible("MoveOnButton", true)
end

function ItemPuttingDlg:updateItemAmountByName(itemName)
    local cell
    local layout = self.scrollView:getChildByTag(#self.itemsInfo * 99)
    for tag, info in pairs(self.itemsInfo) do
        cell = layout:getChildByTag(tag)
        if cell and (itemName == info.name or not itemName) then
            self:updateItemAmount(cell)
        end
    end
end

function ItemPuttingDlg:MSG_INVENTORY(data)
    self:updateItemAmountByName()
end

function ItemPuttingDlg:MSG_ENTER_ROOM()
    self:onCloseButton()
end

function ItemPuttingDlg:onDlgOpened(list)
    if not list[1] then
        return
    end

    for i = 1, #ITEM_INFO do
        if list[1] == ITEM_INFO[i].name then
            local amount = self:getItemAmount(ITEM_INFO[i].name)
            if amount > 0 then
                self:createPreItem(ITEM_INFO[i])
                self:updateItemAmountByName(ITEM_INFO[i].name)
            end
        end
    end
end

function ItemPuttingDlg:cleanup()
    Me:setCanMove(true)

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil

    gf:CmdToServer("CMD_MAP_DECORATION_FINISH", {})

    PuttingItemMgr:cancleAllTakeUpItem()

    performWithDelay(gf:getUILayer(), function()
        self:updateObjShelter()
    end)

    if self.touchPanel then
        self.touchPanel:removeFromParent()
        self.touchPanel = nil
    end
end

return ItemPuttingDlg
