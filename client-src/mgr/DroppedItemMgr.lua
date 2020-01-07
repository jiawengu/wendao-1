-- DroppedItemMgr.lua
-- Created by chenyq Apr/21/2015
-- 丢在地上的物品的管理器

local Carpet = require("obj/Carpet")

DroppedItemMgr = Singleton()

-- 物品信息，id --> 对象的映射表
DroppedItemMgr.items = {}

function DroppedItemMgr:clearAllItems()
    for _, item in pairs(self.items) do
        item:cleanup()
    end

    self.items = {}
end

function DroppedItemMgr:update()
    for _, v in pairs(self.items) do
        v:update()
    end
end

-- 设置场景中地板上的物品是否可见
function DroppedItemMgr:setVisible(flag)
    for _, v in pairs(self.items) do
        v:setVisible(flag and self:canVisible())
    end
end

function DroppedItemMgr:canVisible()
    if Me:isInCombat() or Me:isLookOn() then
        return false
    end

    if MapMgr:isInBaiHuaCongzhong() and not ActivityMgr:canShowItemInQixi() then
        return false
    end

    return true
end

function DroppedItemMgr:MSG_ITEM_APPEAR(data)
    if self.items[data.id] then
        -- 已存在，不重复处理
         
        local item = self.items[data.id]
        if item.delayDisappear and item.bottomLayer then
            -- 百花丛中地图的道具会被延迟移除，如果重新刷新了该道具则停止延迟移除的 action
            item.bottomLayer:stopAction(item.delayDisappear)
            item.delayDisappear = nil
        end
        return
    end

    local item
    local itemType = data["item_type"]
    if itemType and itemType == ITEM_TYPE.CARPET then
        item = Carpet.new()
    else
        item = Dropped.new()
    end

    item:absorbBasicFields(data)
    item:setVisible(self:canVisible())
    item:action()
    item:onEnterScene(data.x, data.y)

    self.items[data.id] = item
end

function DroppedItemMgr:MSG_ITEM_DISAPPEAR(data)
    local item = self.items[data.id]
    if not item then
        return
    end
    if MapMgr:isInBaiHuaCongzhong() and not Me:isTeamLeader() then
        item.delayDisappear = performWithDelay(item.bottomLayer, function() 
            if self.items[data.id] then
                self.items[data.id]:cleanup()
                self.items[data.id] = nil
            end
        end, 0.7)
    else
        self.items[data.id] = nil
        item:cleanup()
    end
end

function DroppedItemMgr:MSG_CLEAR_ALL_CHAR(data)
    DroppedItemMgr:clearAllItems()
end

MessageMgr:hook("MSG_CLEAR_ALL_CHAR", DroppedItemMgr, "DroppedItemMgr")
MessageMgr:regist("MSG_ITEM_APPEAR", DroppedItemMgr)
MessageMgr:regist("MSG_ITEM_DISAPPEAR", DroppedItemMgr)

return DroppedItemMgr
