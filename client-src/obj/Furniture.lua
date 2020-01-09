-- Furniture.lua
-- Created by sujl, Jun/13/2017
-- 家具类

local Object = require("obj/Object")
local Furniture = class("Furniture", Object)
local FurniturePoint = require(ResMgr:getCfgPath("FurniturePoint.lua"))

-- 家具默认光效配置表：帧动画
local FURNITURE_DEFAULT_MAGIC = require(ResMgr:getCfgPath("FurnitureMagic.lua"))

-- 功能型家具特效对应编号:骨骼动画，龙骨动画
local FUNCTION_FURNITURE_MAGIC = require(ResMgr:getCfgPath("FuncFurnitureMagic.lua"))

local C_GRAY = cc.c3b(0xb2, 0xb2, 0xb2)
local C_RED = cc.c3b(0xcc, 0x62, 0x62)

-- UI限高
local MAX_UI_HEIGHT_LIMIT = 336

function Furniture:init()
    self.magics = {}
end

function Furniture:cleanup(notClearPet)
    self:removeMagicOnFuncFurniture()
    self:removeDefaultMagicOnFurniture()

    Object.cleanup(self)
    self.image = nil

    -- 删除食盆时要移除对应的饲养宠物
    if not notClearPet then
        HomeMgr:clearOnePetById(self:queryBasicInt("id"))
    end
end

function Furniture:onEnterScene(mapX, mapY)
    Object.onEnterScene(self, mapX, mapY)
    HomeMgr:regObj(self)
end

function Furniture:onExitScene()
    Object.onExitScene(self)
    HomeMgr:unRegObj(self)
end

function Furniture:action(isOper, flip)
    local icon = self:queryBasicInt("icon")
    local iconNo = self:queryBasicInt("icon_no") or 0

    if not icon or icon <= 0 then return end

    local path = ResMgr:getFurniturePath(icon, iconNo)
    local image = cc.Sprite:create(path)
    local furnitureInfo = HomeMgr:getFurnitureInfo(self:getName())
    if furnitureInfo and furnitureInfo.furniture_type == CHS[5400136] then
        -- 种植的农作物特殊处理
        -- 放入地图时，农作物图片底部与农田图片底部对齐
        local size = image:getContentSize()
        image:setPosition(0, 0 - Const.CULTIVATED_HEIGHT / 2)
        image:setAnchorPoint(0.5, 0)
    else
        image:setPosition(0, 0)
    end

    image:setFlippedX(flip)
    if isOper then
        self:addToTopLayer(image)
    elseif HomeMgr:getPutLayerByFurniture(self) == "carpet" then
        self:addToBottomLayer(image)
    else
        self:addToMiddleLayer(image)
    end

    -- 加载tmx信息
    path = ResMgr:getFurnitureTilePath(icon)
    self.tmx = ccexp.TMXTiledMap:create(path)
    if self.tmx then
        self.obstacle = self.tmx:getLayer("obstacle")
        image:addChild(self.tmx)
        self.tmx:setVisible(false)
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

        if furnitureInfo.furniture_type == CHS[5400136]
                or DlgMgr:isDlgOpened("HomePlantDlg")
                or DlgMgr:isDlgOpened("ItemPuttingDlg")
                or not self:getVisible() then
            -- 点击农作物不响应
            -- 打开种植界面时，点击家具不响应
            return false
        end

        if not HomeMgr:isCanClickFurniture(self) and not DlgMgr:isDlgOpened("HomePuttingDlg") then
            -- 布置界面未打开时，点击非功能型家具不响应
            return false
        end

        if furnitureInfo.name == CHS[4010428] and MarryMgr:getLoverInfo() and HomeMgr.curHouseHosters[MarryMgr:getLoverInfo().gid] then
            -- 配偶未合并的房子，摇篮也要可以点击
            return cc.rectContainsPoint(rect, pos)
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
                if not self:isOper() and DlgMgr:getDlgByName("HomePuttingDlg") then
                    -- 不处于操作中，长按0.5s后进入操作状态
                    longPressAction = performWithDelay(image, function()
                        HomeMgr:tryDragFurniture(self:getId())
                    end,0.5)
                end

            self.touchBeginCount = gfGetTickCount()
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
                    -- 布置界面打开期间，不响应功能型家具

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
    self:showOper(isOper)

--
    local furnitureName = self:getName()
    local magicInfo = FUNCTION_FURNITURE_MAGIC[furnitureName]
    if magicInfo and magicInfo.isAlwaysShowMaigc and not isOper then
        self:tryToAddMagicOnFuncFurniture()
        self.image:setVisible(false)
    end
end

function Furniture:setPos(x, y)
    local lastX, lastY = gf:convertToMapSpace(self.curX, self.curY)
    Object.setPos(self, x, y)
end

function Furniture:updateShelter(mapX, mapY)
    self:setShelter(self:isShelter(mapX, mapY))
end

-- 是否处于遮罩中，修改该接口实现时，需要同步调整HomeMgr:isShelter接口
function Furniture:isShelter(mapX, mapY)
    if DlgMgr:isDlgOpened("ItemPuttingDlg") then
        return true
    end

    local map = GameMgr.scene.map
    if map == nil then return end
    local icon = self:queryBasicInt("icon")
    local furniturePoint = FurniturePoint[icon]
    if not furniturePoint then
        return
    end

    local contentSize = self.image:getContentSize()
    local x1, y1, x2, y2, x3, y3, x, y
    if self:isFlip() then
        x = mapX + math.floor((contentSize.width / 2 - (furniturePoint.x or 0)) / Const.PANE_WIDTH)
        y = mapY + math.floor((contentSize.height / 2 - (furniturePoint.y or contentSize.height)) / Const.PANE_HEIGHT)
        x1 = mapX + math.floor((contentSize.width / 2 - (furniturePoint.x1 or 0)) / Const.PANE_WIDTH)
        y1 = mapY + math.floor((contentSize.height / 2 - (furniturePoint.y1 or contentSize.height)) / Const.PANE_HEIGHT)
        x2 = mapX + math.floor((contentSize.width / 2 - (furniturePoint.x2 or contentSize.width)) / Const.PANE_WIDTH)
        y2 = mapY + math.floor((contentSize.height / 2 - (furniturePoint.y2 or 0)) / Const.PANE_HEIGHT)
        if furniturePoint.x3 and furniturePoint.y3 then
            x3 = mapX + math.floor((contentSize.width / 2 - furniturePoint.x3) / Const.PANE_WIDTH)
            y3 = mapY + math.floor((contentSize.height / 2 - furniturePoint.y3) / Const.PANE_HEIGHT)
        end
    else
        x = mapX + math.floor((-contentSize.width / 2 + (furniturePoint.x or 0)) / Const.PANE_WIDTH)
        y = mapY + math.floor((contentSize.height / 2 - (furniturePoint.y or contentSize.height)) / Const.PANE_HEIGHT)
        x1 = mapX + math.floor((-contentSize.width / 2 + (furniturePoint.x1 or 0)) / Const.PANE_WIDTH)
        y1 = mapY + math.floor((contentSize.height / 2 - (furniturePoint.y1 or contentSize.height)) / Const.PANE_HEIGHT)
        x2 = mapX + math.floor((-contentSize.width / 2 + (furniturePoint.x2 or contentSize.width)) / Const.PANE_WIDTH)
        y2 = mapY + math.floor((contentSize.height / 2 - (furniturePoint.y2 or 0)) / Const.PANE_HEIGHT)
        if furniturePoint.x3 and furniturePoint.y3 then
            x3 = mapX + math.floor((-contentSize.width / 2 + (furniturePoint.x3 or contentSize.width)) / Const.PANE_WIDTH)
            y3 = mapY + math.floor((contentSize.height / 2 - (furniturePoint.y3 or 0)) / Const.PANE_HEIGHT)
    end
    end

    if map:isShelter(x, y) or map:isShelter(x1, y1) or map:isShelter(x2, y2) or (nil ~= x3 and nil ~= y3 and map:isShelter(x3, y3)) then
        -- 基准点在遮罩内
        return true
    end

    local layer = self.obstacle
    if not layer then
        return false
    end

    local size = layer:getLayerSize()
    local beginX, beginY = math.floor(mapX - size.width / 2 + 0.5), math.floor(mapY - size.height / 2 + 0.5)
    local tileValue
    local t = {}
    for i = 0, size.width - 1 do
        for j = 0, size.height - 1 do
            if self:isFlip() then
                tileValue = layer:getTileGIDAt(cc.p(size.width - 1 - i, j))
            else
                tileValue = layer:getTileGIDAt(cc.p(i, j))
            end

            if tileValue ~= 0 then
                if map:isShelter(beginX + i, beginY + j) then
                    -- 障碍点在遮罩内
                    return true
                end
            end
        end
    end

    return false
end

-- 设置遮挡
function Furniture:setShelter(shelter)
    local opacity = shelter and 0x7f or 0xff
    if self.image then
        self.image:setOpacity(opacity)
    end
end

function Furniture:checkPutable(canPut)
    if self.image then
        local color = C_RED
        if not self:isOper() then
            color = COLOR3.WHITE
        elseif HomeMgr:isCanPutFurniture(self) then
            color = C_GRAY
        end

        self.image:setColor(color)

        if HomeMgr:isPetBowl(self:getName()) then
            -- 宠物食盆上的食物改变颜色
            if self.icons then
                for _, v in pairs(self.icons) do
                    if v then
                        v:setColor(color)
    end
                end
            end
        end
    end
end

function Furniture:isOper()
    return self.operPanel and self.operPanel:isVisible()
end

-- 设置农作物标识的高度
function Furniture:setPlantPanelHeight()
    if not self.plantPanel then
        return
    end

    local dlg = self.plantPanel
    self.plantPanel:setAnchorPoint(0.5, 0)
    local info = HomeMgr:getFurnitureInfo(self:getName())
    local offsetY = info.statusOffsetY or 0
    if self.image then
        self.plantPanel:setPosition(0, self.image:getContentSize().height - 170 + offsetY)
    else
        self.plantPanel:setPosition(0, 0)
    end
end

function Furniture:clearCropAllStatus(land)
    land:removeChildByTag(Const.PLANT_EARTH_CRACKED_TAG)
    if self.middleLayer then
        self.middleLayer:removeChildByTag(Const.PLANT_WEED_TAG)
    end

    self:removeIcon(ResMgr.magic.plant_has_insect)
end

-- 显示农作物标识
function Furniture:showPlantPanel(show, status, farmNo)
    local plantPanel = self:createPlantPanel(status, farmNo)
    if not plantPanel then
        return
    end

    local land = HomeMgr.croplands[farmNo]
    if not show and land and not land.isPlayingMagic then
        -- 农作物标识消失，清除所有异常表现（杂草、裂地，飞虫）
        -- 正在播光效，由播完光效后的回调函数清除异常表现
        self:clearCropAllStatus(land)
    end

    plantPanel:setVisible(show)
end

-- 更新不同的农作物标识对应的图片
function Furniture:setPlantStatusImage(ctrl, status, farmNo)
    if status == HOME_CROP_STAUES.STATUS_HAS_REDERAL then
        -- 杂草丛生
        ctrl:loadTextureNormal(ResMgr.ui.farmland_has_rederal, ccui.TextureResType.localType)

        local land = HomeMgr.croplands[farmNo]
        if land and self.middleLayer then
            -- 增加杂草图片
            local img = self.middleLayer:getChildByTag(Const.PLANT_WEED_TAG)
            if not img then
                img = ccui.ImageView:create()
                local no = math.random(1, 2)
                img:loadTexture(ResMgr.ui["plant_weed" .. no])
            end

            img:retain()
            self:clearCropAllStatus(land)
            img:setPosition(0, 0)
            img:setAnchorPoint(0.5, 0.5)
            img:setTag(Const.PLANT_WEED_TAG)
            self:addToMiddleLayer(img)
            img:release()
        end
    elseif status == HOME_CROP_STAUES.STATUS_HAS_INSECT then
        -- 害虫生长
        ctrl:loadTextureNormal(ResMgr.ui.farmland_has_insect, ccui.TextureResType.localType)

        local land = HomeMgr.croplands[farmNo]
        if land then
            -- 增加害虫光效
            self:clearCropAllStatus(land)

            self:addIcon(ResMgr.magic.plant_has_insect, true, {frameInterval = 65})
        end
    elseif status == HOME_CROP_STAUES.STATUS_THIRST then
        -- 土壤缺水
        ctrl:loadTextureNormal(ResMgr.ui.farmland_has_thirst, ccui.TextureResType.localType)

        local land = HomeMgr.croplands[farmNo]
        if land then
            -- 增加干裂的土地
            self:clearCropAllStatus(land)

            local size = land:getContentSize()
            local img = ccui.ImageView:create()
            img:loadTexture(ResMgr.ui.plant_earth_cracked)
            img:setAnchorPoint(0.5, 0.5)
            img:setPosition(size.width / 2, size.height / 2)
            land:addChild(img, 0, Const.PLANT_EARTH_CRACKED_TAG)
        end
    elseif status == HOME_CROP_STAUES.STATUS_FINISH then
        -- 成熟
        local land = HomeMgr.croplands[farmNo]
        if land then
            self:clearCropAllStatus(land)
        end

        ctrl:loadTextureNormal(ResMgr.ui.farmland_crop_is_grown, ccui.TextureResType.localType)
    end
end

-- 创建农作物标识
function Furniture:createPlantPanel(status, farmNo)
    if self.plantPanel then
        local cell = Dialog.getControl(self, "TurnButton", nil, self.plantPanel)
        self:setPlantStatusImage(cell, status, farmNo)
        return self.plantPanel
    end

    local cfgFile = ResMgr:getDlgCfg("FurniturePuttingDlg")
    self.plantPanel = ccs.GUIReader:getInstance():widgetFromJsonFile(cfgFile)
    local dlg = self.plantPanel
    dlg:setAnchorPoint(0.5, 0)
    local info = HomeMgr:getFurnitureInfo(self:getName())
    local offsetY = info.statusOffsetY or 0
    if self.image then
        dlg:setPosition(0, self.image:getContentSize().height - 170 + offsetY)
    else
        dlg:setPosition(0, 0)
    end

    dlg:setLocalZOrder(10)
    self:addToTopLayer(dlg)

    local confirmButton = ccui.Helper:seekWidgetByName(dlg, "ConfirmButton")
    local cancelButton = ccui.Helper:seekWidgetByName(dlg, "CancelButton")
    local turnButton = ccui.Helper:seekWidgetByName(dlg, "TurnButton")
    confirmButton:setVisible(false)
    cancelButton:setVisible(false)

    local function turnListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.cropStatus == HOME_CROP_STAUES.STATUS_FINISH then
                -- 收获
                HomeMgr:requestFarmAction(3, farmNo, self.cropStatus)
            else
                -- 打理
                HomeMgr:requestFarmAction(2, farmNo, self.cropStatus)
            end
        end
    end

    turnButton:addTouchEventListener(turnListener)
    if status ~= HOME_CROP_STAUES.STATUS_HEALTH then
        self:setPlantStatusImage(turnButton, status, farmNo)
    else
        dlg:setVisible(false)
        return
    end

    return self.plantPanel
end

function Furniture:createOperPanel()
    if self.operPanel then return self.operPanel end

    local cfgFile = ResMgr:getDlgCfg("FurniturePuttingDlg")
    self.operPanel = ccs.GUIReader:getInstance():widgetFromJsonFile(cfgFile)
    local dlg = self.operPanel
    dlg:setAnchorPoint(0.5, 0.5)
    if self.image then
        dlg:setPosition(0, math.min(self.image:getContentSize().height, MAX_UI_HEIGHT_LIMIT) - self.image:getContentSize().height / 2 - 50)
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
            if HomeMgr:isCanPutFurniture(self) then
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

            if self.image then
                self:setFlip(not self.image:isFlippedX())
                self:checkPutable()
            end
        end
    end

    turnButton:addTouchEventListener(turnListener)

    return self.operPanel
end

function Furniture:isFlip()
    return self.image and self.image:isFlippedX()
end

function Furniture:getDirToServer()
    return self:isFlip() and 1 or 0
end

-- 目前只是自动寻路到床需要家具朝向，若要精确每个家具的朝向，可自行修改
function Furniture:getDir()
    if self:isFlip() then
        return 7
    else
        return 5
    end
end

function Furniture:setFlip(value)
    if self.image then
        self.image:setFlippedX(value)

        if HomeMgr:isPetBowl(self:getName()) then
            -- 宠物食盆上的食物也需要翻转
            if self.icons then
                for _, v in pairs(self.icons) do
                    if v then
                        v:setFlippedX(value)
    end
                end
            end
        end
    end
end

-- 获取家具基准点相对于地图的位置
function Furniture:getBasicPointInMap()
    return gf:convertToMapSpace(self:getBasicPoint())
end

function Furniture:getBasicPoint()
    local icon = self:queryBasicInt("icon")
    local offset = FurniturePoint[icon] or cc.p(0, 0)
    local size = self.image:getContentSize()
    local x = self.curX - size.width / 2 + offset.x
    local y = self.curY - size.height / 2 + offset.y
    return x, y
end

function Furniture:showOper(show)
    local operPanel = self:createOperPanel()
    if not operPanel then return end

    operPanel:setVisible(show)
    self:checkPutable()
end

function Furniture:getLayer()
    return self.obstacle
end

function Furniture:setZOrder(zOrder)
    if HomeMgr:getPutLayerByFurniture(self) == "carpet" then
        zOrder = zOrder - GameMgr:getSceneHeight()
    end

    Object.setZOrder(self, self:getZOrder(zOrder))
end

function Furniture:getZOrder(zOrder)
    local icon = self:queryBasicInt("icon")
    local offset = FurniturePoint[icon] or cc.p(0, 0)
    local furnitureInfo = HomeMgr:getFurnitureInfo(self:getName())
    if furnitureInfo and furnitureInfo.furniture_type == CHS[5400136] then
        -- 种植的农作物特殊处理，层级直接从基准点 y 值获取，不用做偏移
        return zOrder
    else
        return zOrder + self.image:getContentSize().height / 2 - offset.y
    end
end

function Furniture:onClickFurniture(touchLocation)
    -- 点击家具，弹出悬浮选项
    if not HomeMgr:isCanClickFurniture(self) then
        return
    end

    if self:getName() == CHS[7003097] then
        -- 仕女图图只弹出提示
        gf:ShowSmallTips(CHS[7003098])
        return
    end

    if self:getName() == CHS[4010392] then
        -- 天地灵石发送消息
        gf:CmdToServer('CMD_HOUSE_TDLS_MENU', {no = self:getId()})
        HomeMgr.furnitureListDlgrect = {height = 0, width = 0, x = touchLocation.x, y = touchLocation.y}
        return
    end

    -- 点击床
    if self:queryBasic("furniture_type") == CHS[7002320] then
        if HomeChildMgr.birthAnimateData and HomeChildMgr.birthAnimateData.furniture_pos == self:getId() then
            gf:ShowSmallTips(CHS[4200732])
            return
        end
    end


    if self:getName() == CHS[5400255] or self:getName() == CHS[5400256] or self:getName() == "摇篮" then
        -- 西域飞毯
        self:startAutoWalk()
        return
    end

    -- 点了家具需要停住
    Me:setAct(Const.SA_STAND, true)
    AutoWalkMgr:endAutoWalk()

    self:addFocusMagic()

    local dlg = DlgMgr:openDlg("FurnitureListDlg")
    local dlgContentSize = dlg.root:getContentSize()
    dlg:setInfo("furniture", self)
    local rect = {height = 0, width = 0, x = touchLocation.x, y = touchLocation.y}
    dlg:setFloatingFramePos(rect)
end

function Furniture:startAutoWalk()
    local dest = {}
    dest.map = MapMgr:getCurrentMapName()
    dest.action = "$0"
    dest.npc = self:queryBasic("name")
    dest.isClickNpc = true
    dest.npcId = self:getId()

    -- 家具放置位置与脚底基准点不是同一点，此处应以脚底基准点作为目的地
    dest.x, dest.y = self:getBasicPointInMap()

    AutoWalkMgr:beginAutoWalk(dest)
end

function Furniture:addFocusMagic()
    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end

    local info = HomeMgr:getFurnitureInfo(self:getName())
    if info and info.furniture_type == CHS[5450218] then
        -- 墙饰
        return
    end

    Me.selectTarget = self
    -- 增加选中光效
    local icon = ResMgr.magic.focus_target
    return self:addMagic(icon)
end

function Furniture:removeFocusMagic()
    -- 移除选中光效
    local key = ResMgr.magic.focus_target
    Me.selectTarget = nil
    self:removeMagic(key)
end

-- 部分家具需要添加默认光效
function Furniture:addDefaultMagicOnFurniture()
    local magicInfo = FURNITURE_DEFAULT_MAGIC[self:getName()]
    if magicInfo then
        self:addIcon(magicInfo.icon, true, magicInfo.extraPara, true, magicInfo.offsetX, magicInfo.offsetY, magicInfo.place)

        if magicInfo.hideFurntiue and self.image then
            -- 播放光效时隐藏家具图片
            self.image:setVisible(false)
        end
    end
end

-- 部分家具移除默认光效
function Furniture:removeDefaultMagicOnFurniture()
    local magicInfo = FURNITURE_DEFAULT_MAGIC[self:getName()]
    if magicInfo then
        self:removeIcon(magicInfo.icon)

        if self.image and magicInfo.hideFurntiue then
            -- 移除光效时显示家具图片
            self.image:setVisible(true)
        end
    end
end

-- 尝试在功能型家具上添加骨骼，龙骨动画
function Furniture:tryToAddMagicOnFuncFurniture()
    local furnitureName = self:getName()
    local magicInfo = FUNCTION_FURNITURE_MAGIC[furnitureName]
    if not magicInfo then
        return
    end

    local magic
    if magicInfo.isDragonBones then
        magic = self.middleLayer:getChildByTag(magicInfo.icon)
    elseif magicInfo.isAlwaysShowMaigc then
        magic = self.middleLayer:getChildByTag(magicInfo.icon)
    else
        magic= self.image:getChildByTag(magicInfo.icon)
    end

    if not magic then
        self:absorbBasicFields({ isOpen = 1 })
        self:createMagicOnFuncFurniture()
    end
end

-- 尝试在功能型家具上移除骨骼，龙骨动画
function Furniture:tryToRemoveMagicOnFuncFurniture()
    self:absorbBasicFields({ isOpen = 0 })
    self:removeMagicOnFuncFurniture()
end

-- 功能型家具增加动画:骨骼，龙骨
function Furniture:createMagicOnFuncFurniture()
    local furnitureName = self:getName()
    local magicInfo = FUNCTION_FURNITURE_MAGIC[furnitureName]
    if magicInfo and self:queryInt('isOpen') == 1 then
        if magicInfo.isDragonBones then
            self:createDragonBonesOnFurniture(magicInfo.icon, magicInfo.armatureName, magicInfo.needHideImage, magicInfo.flipX, magicInfo.flipY,
                magicInfo.flipAction, magicInfo.notFlipX, magicInfo.notFlipY, magicInfo.notFlipAction, magicInfo.time)
        elseif magicInfo.isAlwaysShowMaigc then
            self:creatArmatureMagic(string.format("%05d", magicInfo.icon), magicInfo.icon, self:isFlip(), magicInfo.offsetX, magicInfo.offsetY,
                magicInfo.flipAction, magicInfo.notFlipAction, magicInfo.needHideImage)
        else
            self:addArmatureMagic(string.format("%05d", magicInfo.icon), magicInfo.icon, self:isFlip(), magicInfo.offsetX, magicInfo.offsetY,
                magicInfo.flipAction, magicInfo.notFlipAction)
        end
    elseif magicInfo and magicInfo.isAlwaysShowMaigc then
		-- 常显示的
        self:creatArmatureMagic(string.format("%05d", magicInfo.icon), magicInfo.icon, self:isFlip(), magicInfo.offsetX, magicInfo.offsetY,
            magicInfo.flipAction, magicInfo.notFlipAction, magicInfo.needHideImage)

    end


end

-- 功能型家具移除动画：骨骼，龙骨
function Furniture:removeMagicOnFuncFurniture()
    local furnitureName = self:getName()
    local magicInfo = FUNCTION_FURNITURE_MAGIC[furnitureName]
    if magicInfo then
        if magicInfo.isDragonBones then
            self:removeDragonBonesOnFurniture(magicInfo.icon, magicInfo.armatureName)
        elseif magicInfo.isAlwaysShowMaigc then
            self.image:setVisible(true)
            self.middleLayer:removeChildByTag(magicInfo.icon)
        else
            self.image:removeChildByTag(magicInfo.icon)
        end
    end
end

function Furniture:addMagic(icon, extraPara)
    if not self.image then
        return
    end

    -- 增加光效
    local magic
    if not self.magics then
        self.magics = {}
    end

    if self.magics[icon] then
        -- 已存在该光效，先移除
        self.magics[icon]:removeFromParent(true)
    end

    magic = gf:createLoopMagic(icon, nil, extraPara)
    self.magics[icon] = magic

    local furnIcon = self:queryBasicInt("icon")
    local offset = FurniturePoint[furnIcon] or cc.p(0, 0)
    local size = self.image:getContentSize()
    local headX, headY = size.width / 2, size.height / 2
    magic:setPosition(offset.x - headX, offset.y - headY)

    magic:setLocalZOrder(Const.MAGIC_BEHIND_ZORDER)
    self:addToBottomLayer(magic)
    return magic
end

function Furniture:removeMagic(icon)
    -- 移除光效
    if self.magics and self.magics[icon] and self.bottomLayer then
        -- 移除
        self.magics[icon]:removeFromParent(true)
        self.magics[icon] = nil
    end
end

-- 添加图片或光效到家具图片上
-- 图片传入路径
-- 光效传编号
function Furniture:addIcon(iconPath, isMagic, extraPara, checkFlip, px, py, place)
    if not self.image then
        return
    end

    if not px then
        px = 0
    end

    if not py then
        py = 0
    end

    -- 增加图片
    if not self.icons then
        self.icons = {}
    end

    if self.icons[iconPath] then
        -- 已存在该图片，先移除
        self.icons[iconPath]:removeFromParent(true)
    end

    local img
    if isMagic then
        img = gf:createCallbackMagic(iconPath, extraPara.callback, extraPara)
    else
        img = ccui.ImageView:create()
        img:loadTexture(iconPath)
    end

    if checkFlip and self:isFlip() then
        img:setFlippedX(true)
    end

    self.icons[iconPath] = img
    local size = self.image:getContentSize()
    img:setAnchorPoint(0.5, 0.5)
    if place == "mid" then
        self:addToMiddleLayer(img)
        img:setPosition(px, py)
    else
        img:setPosition(size.width / 2 + px, size.height / 2 + py)
        self.image:addChild(img)
    end

    return img
end

function Furniture:removeIcon(iconPath)
    -- 移除图片
    if self.icons and self.icons[iconPath] and self.image then
        -- 移除
        self.icons[iconPath]:removeFromParent(true)
        self.icons[iconPath] = nil
    end
end

function Furniture:removeAllIcon(iconPath)
    -- 移除图片
    if self.icons and self.image then
        -- 移除
        for _, v in pairs(self.icons) do
            if v then
                v:removeFromParent(true)
            end
        end
    end

    self.icons = nil
end

-- 家具middleLayer层创建龙骨动画
function Furniture:createDragonBonesOnFurniture(icon, armatureName, needHideImage, flipX, flipY, flipAction,notFlipX, notFlipY, notFlipAction, time)
    self:removeDragonBonesOnFurniture(icon, armatureName)
    local dragonArmature = DragonBonesMgr:createUIDragonBones(icon, armatureName)
    local nodeDragonArmature = tolua.cast(dragonArmature, "cc.Node")
    self.middleLayer:addChild(nodeDragonArmature)
    nodeDragonArmature:setTag(icon)

    if 1 == needHideImage then
        self.image:setVisible(false)
    end

    -- 摇篮需要显示娃娃形象、男孩形象、女孩形象
    flipAction, notFlipAction = HomeMgr:getSpcialFurnitureAction(self, flipAction, notFlipAction)


    if self:isFlip() then
        nodeDragonArmature:setPosition(flipX, flipY)
        DragonBonesMgr:toPlay(dragonArmature, flipAction, time)
    else
        nodeDragonArmature:setPosition(notFlipX, notFlipY)
        DragonBonesMgr:toPlay(dragonArmature, notFlipAction, time)
    end
end

-- 家具middleLayer层移除龙骨动画
function Furniture:removeDragonBonesOnFurniture(icon, armatureName)
    local dragonArmature = self.middleLayer:getChildByTag(icon)
    if dragonArmature then
        self.image:setVisible(true)
        self.middleLayer:removeChildByTag(icon)
        DragonBonesMgr:removeUIDragonBonesResoure(icon, armatureName)
    end
end

-- 设置家具气泡提示（目前仅实现食盆顶部的饲养宠物头像提示）
function Furniture:addHint(icon, time)
    if not self.image or not icon then  -- 空内容不需要显示
        return
    end

    if self.hint then
        self.hint:removeFromParent(true)
    end

    local size = self.image:getContentSize()
    local headX, headY = 0, size.height

    local dlg = DlgMgr:openDlg("HomePetBubbleDlg")
    local bubble = dlg:getBubbleHint(icon)
    DlgMgr:closeDlg("HomePetBubbleDlg")

    bubble:setAnchorPoint(0.5, 0)
    bubble:setPosition(headX + 20, headY / 4 + 5)

    self:addToTopLayer(bubble)

    local scheduleId
    local function showHint()
        local isVisible = bubble:isVisible()
        bubble:setVisible(not isVisible)
    end

    if not scheduleId then
        scheduleId = schedule(bubble, showHint, time)
    end

    self.hint = bubble
end

function Furniture:removeHint()
    -- 移除气泡
    if self.hint and self.topLayer then
        -- 移除
        self.hint:removeFromParent(true)
        self.hint = nil
    end
end

function Furniture:addHeadMagic(x, y, icon, behind, magicKey, armatureType, extraPara)
    local magic, dbMagic
    if magicKey then
        if self.magics[magicKey] then
            -- 已存在该光效，先移除
            self.magics[magicKey]:removeFromParent(true)
        end

        if not armatureType or armatureType == 0 then
            magic = gf:createLoopMagic(icon, nil, extraPara)
        elseif armatureType == 3 then
            if type(icon) == "table" then
                dbMagic = DragonBonesMgr:createCharDragonBones(icon.icon, icon.armatureName)
                if dbMagic then
                    magic = tolua.cast(dbMagic, "cc.Node")
                end
            end
        else
            local actionName = "Top"
            if behind then
                actionName = "Bottom"
            end

            magic = ArmatureMgr:createArmatureByType(armatureType, icon, actionName)

            -- 需要循环播放骨骼动画
            magic:getAnimation():play(actionName, -1, 1)
        end

        self.magics[magicKey] = magic
    else
        if not armatureType or armatureType == 0 then
            if callback then
                magic = gf:createCallbackMagic(icon, callback, extraPara)
            else
                magic = gf:createSelfRemoveMagic(icon, extraPara)
            end
        else
            local actionName = "Top"
            if behind then
                actionName = "Bottom"
            end

            magic = ArmatureMgr:createArmatureByType(armatureType, icon, actionName)

            -- 仅播一次的骨骼动画
            ArmatureMgr:setArmaturePlayOnce(magic, actionName)
        end
    end

    local zorder = self:getMagicZorder(behind)
    magic:setPosition(x, y)
    magic:setLocalZOrder(zorder)
    self:addToMiddleLayer(magic)
    return magic, dbMagic
end

-- 家具图片上播放骨骼动画，支持方向
function Furniture:creatArmatureMagic(icon, magicKey, isFlip, px, py, flipAction, notFlipAction, needHideImage)
     self.middleLayer:removeChildByTag(magicKey)

    if 1 == needHideImage then
        self.image:setVisible(false)
    end

    if not px then px = 0 end
    if not py then py = 0 end

    local magic = ArmatureMgr:createArmature(icon)
    if isFlip then
        magic:getAnimation():play(flipAction)
    else
        magic:getAnimation():play(notFlipAction)
    end

    local size = self.image:getContentSize()
   -- magic:setAnchorPoint(0.5, 0.5)
   -- magic:setPosition(size.width / 2 + px, size.height / 2 + py)
    magic:setTag(magicKey)
    self.middleLayer:addChild(magic)
end

-- 家具图片上播放骨骼动画，支持方向
function Furniture:addArmatureMagic(icon, magicKey, isFlip, px, py, flipAction, notFlipAction)
    self.image:removeChildByTag(magicKey)

    if not px then px = 0 end
    if not py then py = 0 end

    local magic = ArmatureMgr:createArmature(icon)
    if isFlip then
        magic:getAnimation():play(flipAction)
    else
        magic:getAnimation():play(notFlipAction)
    end

    local size = self.image:getContentSize()
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width / 2 + px, size.height / 2 + py)
    magic:setTag(magicKey)
    self.image:addChild(magic)
end

-- 获取 zorder 值
-- behind: 人物后面
function Furniture:getMagicZorder(behind)
    local zorder = Const.MAGIC_FRONT_ZORDER
    if behind then
        zorder = Const.MAGIC_BEHIND_ZORDER
    end

    return zorder
end

-- 删除光效
function Furniture:deleteHeadMagic(key)
    if self.magics[key] then
        -- 移除
        self.magics[key]:removeFromParent(true)
        self.magics[key] = nil
    end
end

-- 更新 title 效果
function Furniture:setFightState(show)
    local magicType = "fighting"
    if show then
        -- 增加标志
        local x, y = self.image:getPosition()
        self:addHeadMagic(x, y + self.image:getContentSize().height / 2, ResMgr.magic[magicType], false, magicType)
        return
    end

    if not show then
        -- 删除标记
        self:deleteHeadMagic(magicType)
    end
end

--[[ 添加名字
function Furniture:addName(name, color, fontSize)
    local nameLabel = ccui.Text:create()
    nameLabel:setFontSize(fontSize)
    nameLabel:setString(name)
    nameLabel:setColor(color)
    local size = nameLabel:getContentSize()

    size.width = size.width + 8
    size.height = size.height + 8

    -- 创建一个底图
    local bgImage = ccui.ImageView:create(ResMgr.ui.chenwei_name_bgimg, ccui.TextureResType.plistType)
    local bgImgSize = bgImage:getContentSize()
    bgImage:setScale9Enabled(true)
    size.height = bgImgSize.height
    bgImage:setContentSize(size)
    nameLabel:setPosition(size.width / 2, size.height / 2)

    bgImage:addChild(nameLabel)

    local imageSize = self.image:getContentSize()
    bgImage:setPosition(imageSize.width / 2, -(size.height / 2))
    self.image:addChild(bgImage)
    bgImage:setLocalZOrder(Const.NAME_ZORDER)

    self.nameBgImage = bgImage
end

-- 添加名字
function Furniture:removeName()
    if self.nameBgImage then
        self.nameBgImage:removeFromParent()
        self.nameBgImage = nil
    end
end]]

return Furniture
