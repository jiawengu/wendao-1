-- PuttingItem.lua
-- Created by huangzz Aug/13/2017
-- 创建骨骼动画类家具

local PuttingObject = require("obj/PuttingObject")
local PuttingItem = class("PuttingItem", PuttingObject)

local ITEM_MAGIC = {
    --[52061] = {icon = 01364, extraPara = {blendMode = "add"}}, -- 红玫瑰
    --[52064] = {icon = 01365, extraPara = {blendMode = "add"}}, -- 蓝玫瑰
    --[52062] = {icon = 01366, extraPara = {blendMode = "add"}}, -- 白百合
    [52063] = {icon = 01367, extraPara = {blendMode = "add"}}, -- 蜡烛
    --[52065] = {icon = 01368, extraPara = {blendMode = "add"}}, -- 小酒碗
}

local C_GRAY = cc.c3b(0xb2, 0xb2, 0xb2)
local C_RED = cc.c3b(0xcc, 0x62, 0x62)

function PuttingItem:init()
    self.magics = {}
    self.moveOffsetPos = {x = 0, y = 0}
    self.isPreTake = false
end

function PuttingItem:action(isOper)
    local icon = self:queryBasicInt("icon")

    if not icon or icon <= 0 then return end

    self.layer.belongObj = self
    self.hasLoad = true

    if not self.image then
        local path = ResMgr:getSmallPortrait(icon)
        local image = cc.Sprite:create(path)
        local size = image:getContentSize()
        image:setPosition(0, 0)
        self:addToLayer(image)

        self.image = image

        --[[ 显示图片响应区域
        local layer = cc.LayerColor:create(cc.c4b(0, 0, 255, 90), 64, 84)
        layer:setPosition(size.width / 2 - 64 / 2, size.height / 2 - 64 / 2 - 20)
        self.image:addChild(layer)]]

        if ITEM_MAGIC[icon] then
            self:addMagic(ITEM_MAGIC[icon].icon, ITEM_MAGIC[icon].extraPara, "own_magic")
        end
    else
        if self.magics["own_magic"] then
            if ITEM_MAGIC[icon] then
                self.magics["own_magic"]:setVisible(true)
                self.magics["own_magic"]:setIcon(ITEM_MAGIC[icon].icon)
            else
                self.magics["own_magic"]:setVisible(false)
            end
        elseif ITEM_MAGIC[icon] then
            self:addMagic(ITEM_MAGIC[icon].icon, ITEM_MAGIC[icon].extraPara, "own_magic")
        end

        local path = ResMgr:getSmallPortrait(icon)
        self.image:setTexture(path)
    end

    -- self:updateDir()
    self:showOper(isOper)
end

function PuttingItem:containsTouchPos(pos)
    if not self.curX or not self.curY then
        return
    end

    return self.curX - pos.x > -32 and self.curX - pos.x < 32 and self.curY - pos.y < 52 and self.curY - pos.y > -32
end

function PuttingItem:onExitScene()
    if self.operPanel then
        self.operPanel:removeFromParent()
        self.operPanel = nil
    end

    PuttingObject.onExitScene(self)
end

function PuttingItem:removeAllMagics()
    if not self.magics then
        return
    end
    
    for _, v in pairs(self.magics) do
        v:removeFromParent()
    end

    self.magics = {}
end

function PuttingItem:addMagic(icon, extraPara, magicKey)
    if not self.image then
        return
    end

    -- 增加图片
    if not self.magics then
        self.magics = {}
    end

    if self.magics[magicKey] then
        -- 已存在该图片，先移除
        self.magics[magicKey]:removeFromParent(true)
    end

    local magic = gf:createLoopMagic(icon, nil, extraPara)

    self.magics[magicKey] = magic
    local size = self.image:getContentSize()

    magic:setPosition(size.width / 2, size.height / 2)
    self.image:addChild(magic)

    return magic
end

function PuttingItem:showOper(isOper)
    if isOper then
        local operPanel = self:createOperPanel()
        if not operPanel then return end

        operPanel:setVisible(true)
    else
        if self.operPanel then
            self.operPanel:removeFromParent()
            self.operPanel = nil
        end

        self:updateShelter(self:getCurMapPos())
    end

    self:checkPutable()
end

function PuttingItem:isOper()
    return self.operPanel and self.operPanel:isVisible()
end

function PuttingItem:isTakeUp()
    if not self.image then
        return
    end

    return self.image:getParent() == gf:getUILayer()
end

-- 更新拖动道具的位置
function PuttingItem:setDragItemPos()
    local pos = GameMgr.curTouchPos
    if pos then
        local pos = gf:getUILayer():convertToNodeSpace(pos)
        self:setPos(pos.x + self.moveOffsetPos.x, pos.y + self.moveOffsetPos.y)
    end
end

function PuttingItem:setPos(x, y)
    if not self.image then return end
    if self.image:getParent() ~= gf:getUILayer() then
        PuttingObject.setPos(self, x, y)
    else
        self.image:setPosition(x, y)
    end

    self:checkPutable()
    self:updateShelter(self:getCurMapPos())
end

function PuttingItem:putDown()
    self:moveToMapLayer()
end

function PuttingItem:takeUp()
    self:showOper(true)
    self:moveToUILayer()
end

function PuttingItem:cancleTakeUp()
    self:showOper(false)
    self:putDown()
    local x, y = HomeMgr:calcPosition(self:queryBasicInt("x"), self:queryBasicInt("y"), self:queryBasicInt("ox"), self:queryBasicInt("oy"))
    self:setPos(x, y)
end

function PuttingItem:moveToMapLayer()
    if not self.image then return end
    if self.image:getParent() ~= gf:getUILayer() then
        return
    end

    local x, y = self.image:getPosition()
    local pos = self.image:getParent():convertToWorldSpace(cc.p(x, y))
    pos = gf:getPuttingObjLayer():convertToNodeSpace(pos)
    local size = self.image:getContentSize()

    self.image:retain()
    self.image:removeFromParent(false)
    self.image:setScale(1)
    self:addToLayer(self.image)

    self.image:setPosition(0, 0)
    self:setPos(pos.x, pos.y)
    self.image:release()
end

function PuttingItem:moveToUILayer()
    if not self.image then return end

    if self.image:getParent() == gf:getUILayer() then
        return
    end

    local pos = gf:getPuttingObjLayer():convertToWorldSpace(cc.p(self.curX, self.curY))
    pos = gf:getUILayer():convertToNodeSpace(pos)

    self.image:retain()
    self.image:removeFromParent(false)
    self.image:setScale(1 / Const.UI_SCALE)
    gf:getUILayer():addChild(self.image, 10, 0)

    self.image:setPosition(pos.x, pos.y)
    self.image:release()

    if GameMgr.curTouchPos then
        local nPos = gf:getUILayer():convertToNodeSpace(GameMgr.curTouchPos)
        self.moveOffsetPos = {x = pos.x - nPos.x, y = pos.y - nPos.y}
    else
        self.moveOffsetPos = {x = 0, y = 0}
    end
end

function PuttingItem:cleanup()
    if self.operPanel then
        self.operPanel:removeFromParent()
        self.operPanel = nil
    end

    if self.image then
        self.image:removeFromParent()
        self.image = nil
    end

    PuttingObject.cleanup(self)
end

function PuttingItem:createOperPanel()
    if self.operPanel then return self.operPanel end

    if not self.image then return end

    local cfgFile = ResMgr:getDlgCfg("FurniturePuttingDlg")
    self.operPanel = ccs.GUIReader:getInstance():widgetFromJsonFile(cfgFile)
    local dlg = self.operPanel
    local size = self.image:getContentSize()
    dlg:setAnchorPoint(0.5, 0)
    dlg:setPosition(size.width / 2, size.height / 2 - 70)

    self.image:addChild(dlg, 10, 0)

    local confirmButton = ccui.Helper:seekWidgetByName(dlg, "ConfirmButton")  -- 确认放置
    local cancelButton = ccui.Helper:seekWidgetByName(dlg, "CancelButton")    -- 返回
    local removeButton = ccui.Helper:seekWidgetByName(dlg, "TurnButton")         -- 销毁

    removeButton:setVisible(not self:isPreItem())

    cancelButton:loadTextureNormal(ResMgr.ui.button_return, ccui.TextureResType.localType)
    removeButton:loadTextureNormal(ResMgr.ui.button_remove, ccui.TextureResType.localType)

    local function confirmListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local bx, by = gf:convertToMapSpace(self.curX, self.curY)
            local ox, oy = HomeMgr:convertToOffset(self.curX, self.curY, bx, by)
            if not self:isPreItem() then
                --[[if bx == self:queryBasicInt("x") and by == self:queryBasicInt("y") then
                    self:cancleTakeUp()
                else]]
                gf:CmdToServer('CMD_MAP_DECORATION_MOVE', {
                    cookie = self:getId(),
                    id = self:getId(),
                    x = bx,  -- 地图 x 坐标
                    y = by,  -- 地图 y 坐标
                    dir = 5,
                    ox = math.floor(ox), -- 偏移 x
                    oy = math.floor(oy), --  偏移 y
                })
                --end
            else
                gf:CmdToServer('CMD_MAP_DECORATION_PLACE', {
                    cookie = self:queryBasicInt("client_id"),
                    item_name = self:getName(),
                    x = bx,  -- 地图 x 坐标
                    y = by,  -- 地图 y 坐标
                    dir = 5,
                    ox = math.floor(ox), -- 偏移 x
                    oy = math.floor(oy), --  偏移 y
                })
            end
        end
    end

    confirmButton:addTouchEventListener(confirmListener)

    local function cancelListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not self:isPreItem() then
                self:cancleTakeUp()
            else
                PuttingItemMgr:deletePreItem(self:queryBasicInt("client_id"))
            end
        end
    end

    cancelButton:addTouchEventListener(cancelListener)

    local function turnListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            gf:confirm(CHS[5450372] , function()
                gf:CmdToServer("CMD_MAP_DECORATION_REMOVE", {cookie = self:getId(), id = self:getId()})
            end)
        end
    end

    removeButton:addTouchEventListener(turnListener)

    return self.operPanel
end

function PuttingItem:onAbsorbBasicFields()
    if not self:isOper() and self.hasLoad then
        self:updatePos()
    end
end

function PuttingItem:isPreItem()
    return self:queryBasicInt("isPreItem") == 1
end

function PuttingItem:updatePos()
    local x, y = HomeMgr:calcPosition(self:queryBasicInt("x"), self:queryBasicInt("y"), self:queryBasicInt("ox"), self:queryBasicInt("oy"))
    self:setPos(x, y)
end

function PuttingItem:updateShelter(mapX, mapY)
    self:setShelter(not self:isOper() and self:isShelter(mapX, mapY))
end

-- 设置遮挡
function PuttingItem:setShelter(shelter)
    local opacity = shelter and 0x7f or 0xff
    if self.image then
        self.image:setOpacity(opacity)
    end
end

-- 是否处于遮罩中
function PuttingItem:isShelter(mapX, mapY)
    local map = GameMgr.scene.map
    if map == nil then return end

    return map:isShelter(mapX, mapY)
end

function PuttingItem:getCurMapPos()
    if self.image and self.image:getParent() == gf:getUILayer() then
        local x, y = self.image:getPosition()
        local pos = gf:getUILayer():convertToWorldSpace(cc.p(x, y))
        pos = gf:getPuttingObjLayer():convertToNodeSpace(pos)
        return gf:convertToMapSpace(pos.x, pos.y)
    else
        return gf:convertToMapSpace(self.curX, self.curY)
    end
end

function PuttingItem:checkPutable()
    if self.image then
        if not self:isOper() then
            self.image:setColor(COLOR3.WHITE)
            
            if self.operPanel and self.operPanel.isCanPut ~= true then
                local btn = ccui.Helper:seekWidgetByName(self.operPanel, "ConfirmButton")  -- 确认放置
                btn:setEnabled(true)
                gf:resetImageView(btn)
                self.operPanel.isCanPut = true
            end

            return
        end

        local mx, my = self:getCurMapPos()
        local isEnabled = not GObstacle:Instance():IsObstacle(mx, my)
        if isEnabled then
            self.image:setColor(C_GRAY)
        else
            self.image:setColor(C_RED)
        end

        if self.operPanel and self.operPanel.isCanPut ~= isEnabled then
            local btn = ccui.Helper:seekWidgetByName(self.operPanel, "ConfirmButton")  -- 确认放置
            btn:setEnabled(isEnabled)

            if isEnabled then
                gf:resetImageView(btn)
            else
                gf:grayImageView(btn)
            end

            self.operPanel.isCanPut = isEnabled
        end
    end
end

function PuttingItem:getDir()
    return self:queryBasicInt("dir")
end

return PuttingItem