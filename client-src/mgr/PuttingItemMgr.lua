-- PuttingItemMgr.lua
-- Created by huangzz Oct/24/2018
-- 丢在地上的物品的管理器

local PuttingItem = require("obj/PuttingItem")
local List = require("core/List")
PuttingItemMgr = Singleton()

local CASHE_ITEM_MAX_NUM = 1500

local notUseItems = {}

-- 初始化加载地图上道具的队列
local ItemLoadList = List.new()

-- 物品信息，id --> 对象的映射表
PuttingItemMgr.items = {}      -- 已放下的 Item

PuttingItemMgr.preItems = {}  -- 还未放下的 item

local clientId = 0

-- 获取多少帧加载一个模型
function PuttingItemMgr:getMaxFrameForLoad()
    return 1
end

-- 获取一帧需要加载的队列
function PuttingItemMgr:getLoadCharsOneFPS()
    if not self.frameCounterForLoad then
        self.frameCounterForLoad = 0
    end

    self.frameCounterForLoad = self.frameCounterForLoad + 1

    if 0 == ItemLoadList:size() then
        return {}
    end

    if self.frameCounterForLoad >= self:getMaxFrameForLoad() then
        self.frameCounterForLoad = 0
        local loadNum = 6
        local datas = {}
        repeat
            local data = ItemLoadList:popFront()
            if self.items[data.id] then
                loadNum = loadNum - 1
                table.insert(datas, data)
            end

            if 0 == ItemLoadList:size() or loadNum == 0 then
                break
            end
        until false

        return datas
    end
end

-- 加载道具
function PuttingItemMgr:loadItemOneFPS()
    if 0 == ItemLoadList:size() then
        return
    end

    local datas = self:getLoadCharsOneFPS()

    for _, v in ipairs(datas) do
        self:loadItem(v)
    end
end

-- 往角色加载队列后添加一个角色
function PuttingItemMgr:pushOneToLoadCharList(data)
    ItemLoadList:pushBack(data)
end

-- 设置场景中地板上的物品是否可见
function PuttingItemMgr:setVisible(flag)
    for _, v in pairs(self.items) do
        v:setVisible(flag and self:canVisible())
    end
end

function PuttingItemMgr:canVisible()
    if Me:isInCombat() or Me:isLookOn() then
        return false
    end

    return true
end

function PuttingItemMgr:getPreItemAmount(name)
    local amount = 0
    for _, v in pairs(self.preItems) do
        if v:getName() == name then
            amount = amount + 1
        end
    end

    return amount
end


function PuttingItemMgr:cancleAllTakeUpItem()
    for _, item in pairs(self.items) do
        item:cancleTakeUp()
    end

    self:clearAllPreItems()
end

function PuttingItemMgr:clearAllItems()
    for _, item in pairs(self.items) do
        item:cleanup()
    end

    self.items = {}

    ItemLoadList = List.new()
end

function PuttingItemMgr:clearAllPreItems()
    for _, item in pairs(self.preItems) do
        item:cleanup()
    end

    self.preItems = {}

    clientId = 0
end

function PuttingItemMgr:clearData()
    for _, v in pairs(notUseItems) do
        v:cleanup()
    end

    notUseItems = {}
end

function PuttingItemMgr:deleteItem(id)
    local item = self.items[id]
    self.items[id] = nil
    if item then
        self:cleanupItem(item)
    end
end

function PuttingItemMgr:cleanupItem(item)
    if #notUseItems < CASHE_ITEM_MAX_NUM then
        item:onExitScene()
        item:putDown()
        item:setBasic("isPreItem", 0)
        item:setBasic("id", 0)
        item:setBasic("client_id", 0)
        item.hasLoad = nil
        table.insert(notUseItems, item)
    else
        item:cleanup()
    end
end

function PuttingItemMgr:getOneItem()
    if #notUseItems > 0 then
        local item = table.remove(notUseItems)
        return item
    else
        return PuttingItem.new()
    end
end

function PuttingItemMgr:deletePreItem(id)
    local item = self.preItems[id]
    self.preItems[id] = nil
    if item then
        DlgMgr:sendMsg("ItemPuttingDlg", "updateItemAmountByName", item:queryBasic("name"))
        self:cleanupItem(item)
    end
end

function PuttingItemMgr:getClientId()
    clientId = clientId % 65530 + 1
    return clientId
end

function PuttingItemMgr:hasOperItem()
    for _, v in pairs(self.items) do
        if v:isOper() then
            return true
        end
    end

    for _, v in pairs(self.preItems) do
        if v:isOper() then
            return true
        end
    end
end

function PuttingItemMgr:loadItem(data)
    local item = self.items[data.id]
    if not item then
        return
    end

    item:action()
    item:onEnterScene(0, 0)
    item:setVisible(self:canVisible())
    item:updatePos()
end

function PuttingItemMgr:createPreItem(data, isOper)
    data.isPreItem = 1

    local item = self:getOneItem()
    item:absorbBasicFields(data)
    item:action(isOper)
    item:onEnterScene(0, 0)
    item:setVisible(self:canVisible())

    if data.x and data.y then
        item:setPos(data.x, data.y)
    else
        local centerX = Const.WINSIZE.width / 2
        local centerY = Const.WINSIZE.height / 2
        pos = gf:getCharMiddleLayer():convertToNodeSpace(cc.p(centerX, centerY))
        item:setPos(pos.x, pos.y)
    end

    if self.preItems[data.client_id] then self:deletePreItem(data.client_id) end
    self.preItems[data.client_id] = item

    return item
end

function PuttingItemMgr:MSG_MAP_DECORATION_APPEAR(data)
    local item = self.items[data.id]
    if item then
        -- 已存在，不重复处理
        item:absorbBasicFields(data)
        return
    end

    local item = self:getOneItem()
    item:absorbBasicFields(data)
    item:setVisible(false)
    self.items[data.id] = item

    self:pushOneToLoadCharList(data)
end

function PuttingItemMgr:MSG_MAP_DECORATION_DISAPPEAR(data)
    self:deleteItem(data.id)
end

function PuttingItemMgr:MSG_MAP_DECORATION_START(data)
    local dlg = DlgMgr:openDlg("ItemPuttingDlg")
    dlg:onDlgOpened({data.name})
end

function PuttingItemMgr:MSG_MAP_DECORATION_FINISH(data)
    DlgMgr:closeDlg("ItemPuttingDlg")
end

function PuttingItemMgr:MSG_MAP_DECORATION_RESULT(data)
    if data.result == 0 then
        return
    end

    if data.action == "move" then
        local item = self.items[data.cookie]
        if item then
            item:showOper(false)
            item:updatePos()
        end
    elseif data.action == "place" then
        if self.preItems[data.cookie] then
            self:deletePreItem(data.cookie)
        end
    elseif data.action == "remove" then
        self:deleteItem(data.cookie)
    end
end

function PuttingItemMgr:MSG_MAP_DECORATION_CHECK(data)
    local item = self.items[data.id]
    if data.result == 1 and item and item.isPreTake then
        item:takeUp()
    end
end

GameMgr:registFrameFunc(FRAME_FUNC_TAG.PUTTING_ITEM_LOAD, PuttingItemMgr.loadItemOneFPS, PuttingItemMgr, true)
MessageMgr:regist("MSG_MAP_DECORATION_APPEAR", PuttingItemMgr)
MessageMgr:regist("MSG_MAP_DECORATION_DISAPPEAR", PuttingItemMgr)
MessageMgr:regist("MSG_MAP_DECORATION_START", PuttingItemMgr)
MessageMgr:regist("MSG_MAP_DECORATION_FINISH", PuttingItemMgr)
MessageMgr:regist("MSG_MAP_DECORATION_RESULT", PuttingItemMgr)
MessageMgr:regist("MSG_MAP_DECORATION_CHECK", PuttingItemMgr)


return PuttingItemMgr
