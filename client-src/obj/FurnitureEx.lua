-- FurnitureEx.lua
-- Created by huangzz Aug/13/2017
-- 创建骨骼动画类家具

local Furniture = require("obj/Furniture")
local FurnitureEx = class("FurnitureEx", Furniture)
local FurniturePoint = require(ResMgr:getCfgPath("FurniturePoint.lua"))

local C_GRAY = cc.c3b(0xb2, 0xb2, 0xb2)
local C_RED = cc.c3b(0xcc, 0x62, 0x62)

function FurnitureEx:action(isOper, dir)
    local icon = self:queryBasicInt("icon")

    if not icon or icon <= 0 then return end

    local image = ArmatureMgr:createFurnitureArmature(icon)
    image:setPosition(0, 0)
    if isOper then
        self:addToTopLayer(image)
    elseif HomeMgr:getPutLayerByFurniture(self) == "carpet" then
        self:addToBottomLayer(image)
    else
        self:addToMiddleLayer(image)
    end
    
    if Me:isInCombat() or Me:isLookOn() then
        -- 战斗中新创建出来的家具需设为隐藏
        self:setVisible(false)
    else
        self:setVisible(true)
    end

    local lastTouchPos

    local function canTouch(touch)
        local pos = self.image:getParent():convertTouchToNodeSpace(touch)
        local rect = self.image:getBoundingBox()
        local name = self:getName()
        local furnitureInfo = HomeMgr:getFurnitureInfo(name)
        if furnitureInfo.clickRect then
            rect = furnitureInfo.clickRect
        end
        
        if DlgMgr:isDlgOpened("HomePlantDlg")
            or DlgMgr:isDlgOpened("ItemPuttingDlg")
            or not self:getVisible() then
            -- 打开种植界面时，点击家具不响应
            -- 家具隐藏时，点击不响应
            return false
        end

        if not HomeMgr:isCanClickFurniture(self) and not DlgMgr:isDlgOpened("HomePuttingDlg") then
            -- 布置界面未打开时，点击非功能型家具不响应
            return false
        end
        
        if HomeMgr:getHouseId() ~= Me:queryBasic("house/id") and not furnitureInfo.otherCanClick then
            -- 目前飞毯可供非居所内的玩家使用
            return false
        end

        return cc.rectContainsPoint(rect, pos)
    end

    local checkAction, longPressAction
    local function onTouch(sender, event)
        if event:getEventCode() == cc.EventCode.BEGAN then
            if not canTouch(sender) then return false end
            lastTouchPos = GameMgr.curTouchPos
            self.touchBeginCount = gfGetTickCount()
            if not self:isOper() and DlgMgr:getDlgByName("HomePuttingDlg") then
                -- 不处于操作中，长按0.5s后进入操作状态
                longPressAction = performWithDelay(image, function()
                    HomeMgr:tryDragFurniture(self:getId())
                end,0.5)
            end
            return true
        elseif event:getEventCode() == cc.EventCode.MOVED then
            if not self:isOper() then return end
            local touchPos = GameMgr.curTouchPos
            local offsetX, offsetY = touchPos.x - lastTouchPos.x, touchPos.y - lastTouchPos.y
            self:setPos(math.floor(self.curX + offsetX + 0.5), math.floor(self.curY + offsetY + 0.5))
            if checkAction then
                image:stopAction(checkAction)
                checkAction = nil
            end
            checkAction = performWithDelay(image, function()
                self:checkPutable()
                checkAction = nil
            end, 0)
            lastTouchPos = touchPos
        elseif event:getEventCode() == cc.EventCode.ENDED then
            self.image:stopAction(longPressAction)
            if self.touchBeginCount and
                  ((gfGetTickCount() - self.touchBeginCount) > 0) and
                  ((gfGetTickCount() - self.touchBeginCount) < 200) then
                if HomeMgr:isCanClickFurniture(self) and not DlgMgr:isDlgOpened("HomePuttingDlg") then
                 -- 需弹出悬浮框的家具 如果是点击，而不是长按（按下松开时间在0.2s之内），则弹出悬浮选项

                    -- 如果有重叠的家具，则弹出列表
                    local showFurnitureList = CharMgr:openCharMenuContentDlg(sender)

                    -- 如果没有重叠的家具，则直接弹出“我要休息”选项
                    if not showFurnitureList then
                        self:onClickFurniture(sender:getLocation())
                    end

                    return true
                end
            end

            if not self:isOper() and Me:isControlMove() and not Me:isInCombat() then
                local toPos = sender:getLocation()
                Me:touchMapBegin(toPos)
                Me:touchMapEnd(toPos)
            end
        end
    end

    gf:bindTouchListener(image, onTouch, {
            cc.Handler.EVENT_TOUCH_BEGAN,
            cc.Handler.EVENT_TOUCH_MOVED,
            cc.Handler.EVENT_TOUCH_ENDED
        }, false)
        
    self.image = image
    
    self:updateDir()
    self:showOper(isOper)
end

function FurnitureEx:cleanup()
    Furniture.cleanup(self)
    
    local icon = self:queryBasicInt("icon")
    if icon > 0 then
        ArmatureMgr:removeFurnitureArmature(icon)
    end
end

function FurnitureEx:updateDir()
    if not self.image then
        return
    end
    
    local icon = self:queryBasicInt("icon")
    local dir = self:queryBasicInt("dir")
    
    self.image:getAnimation():play(string.format("%05d_%d", icon, dir), -1, 0)
    
    if self.tmx then
       self.tmx:removeFromParent()
    end
    
    -- 加载tmx信息
    local path = ResMgr:getAnimateFurnitureTilePath(icon, dir)
    self.tmx = ccexp.TMXTiledMap:create(path)
    if self.tmx then
        self.obstacle = self.tmx:getLayer("obstacle")
        self.tmx:setAnchorPoint(0.5, 0.5)
        self.tmx:setPosition(0, 0)
        self:addToMiddleLayer(self.tmx)
        self.tmx:setVisible(false)
    end
end

function FurnitureEx:createOperPanel()
    if self.operPanel then return self.operPanel end

    local cfgFile = ResMgr:getDlgCfg("FurniturePuttingDlg")
    self.operPanel = ccs.GUIReader:getInstance():widgetFromJsonFile(cfgFile)
    local dlg = self.operPanel
    dlg:setAnchorPoint(0.5, 0.5)
    if self.image then
        dlg:setPosition(0, self.image:getContentSize().height / 2 - 50)
    else
        dlg:setPosition(0, 0)
    end
    dlg:setLocalZOrder(10)
    self:addToTopLayer(dlg)

    local confirmButton = ccui.Helper:seekWidgetByName(dlg, "ConfirmButton")
    local cancelButton = ccui.Helper:seekWidgetByName(dlg, "CancelButton")
    local turnButton = ccui.Helper:seekWidgetByName(dlg, "TurnButton")

    local function confirmListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if HomeMgr:isCanPutFurniture(self, nil, nil, true) then
                -- 可以正常摆放
                HomeMgr:cmdPut(self)
            else
                -- 再次刷新颜色
                self.image:setColor(self:isOper() and C_RED or COLOR3.WHITE)
                gf:ShowSmallTips(CHS[2100100])
            end
        end
    end

    confirmButton:addTouchEventListener(confirmListener)

    local function cancelListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if 0 ~= self:getId() then
                gf:CmdToServer('CMD_HOUSE_TAKE_FURNITURE', { furniture_pos = self:getId(), cookie = self.cookie })
            else
                HomeMgr:revokePreview(self)
            end
        end
    end

    cancelButton:addTouchEventListener(cancelListener)

    local function turnListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local info = HomeMgr:getFurnitureInfo(self:queryBasic("name"))
            if info and 1 == info.dirs then
                gf:ShowSmallTips(CHS[2100094])
                return
            end

            local image = self.image
            if image then
                local dir = self:queryBasicInt("dir")
                if info.dirs == 2 then
                    dir = dir == 5 and 7 or 5
                else
                    dir = dir + 2
                    if dir > 7 then
                        dir = 1
                    end
                end
                
                self:setBasic("dir", dir)
                self:updateDir()
                self:checkPutable()
                local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
                self:updateShelter(mapX, mapY)
            end
        end
    end

    turnButton:addTouchEventListener(turnListener)

    return self.operPanel
end

function FurnitureEx:checkPutable(canPut)
    if self.image then
        if not self:isOper() then
            self.image:setColor(COLOR3.WHITE)
        elseif HomeMgr:isCanPutFurniture(self, nil, nil, true) then
            self.image:setColor(self:isOper() and C_GRAY or COLOR3.WHITE)
        else
            self.image:setColor(C_RED)
        end
    end
end

function FurnitureEx:setFlip(value)
end

function FurnitureEx:isFlip()
    return false
end

function FurnitureEx:getDirToServer()
    -- 服务端处理的方向为 10 ~ 17
    return self:queryBasicInt("dir") + 10
end

function FurnitureEx:getDir()
    return self:queryBasicInt("dir")
end

return FurnitureEx