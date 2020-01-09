-- HomeShowDlg.lua
-- Created by sujl, Jun/23/2017
-- 居所展示界面

local HomeShowDlg = Singleton("HomeShowDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local FurniturePoint = require(ResMgr:getCfgPath("FurniturePoint.lua"))

local TAG_HOME          = 100           -- 小地图上的地表
local LAYER_HOME        = 10            -- 地表
local TAG_CARPET        = 200           -- 小地图上的家具
local LAYER_CARPET      = 20            -- 家具
local TAG_FURNITURE     = 300           -- 小地图上的家具
local LAYER_FURNITURE   = 30            -- 家具

local SEL_HOUSE_AREAS = {
    CHS[2000282],
    CHS[2000283],
    CHS[2000284]
}

local MAP_SCALE_SIZE = {
    ["1-1"] = cc.size(1210, 686),   -- 前庭
    ["2-1"] = cc.size(1048, 605),   -- 房屋
    ["3-1"] = cc.size(1210, 685),   -- 后院

    ["1-2"] = cc.size(887, 524),
    ["2-2"] = cc.size(1048, 605),
    ["3-2"] = cc.size(1210, 685),

    ["1-3"] = cc.size(887, 524),
    ["2-3"] = cc.size(1048, 605),
    ["3-3"] = cc.size(1210, 685),
}

function HomeShowDlg:init(args)
    self:bindListener("CleanButton", self.onCleanButton)
    self:bindListener("AssistCleanButton", self.onAssistCleanButton)
    self:bindListener("VisitButton", self.onVisitButton)
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("HomeButton1", self.onHomeButton1, "ChosePanel")
    self:bindListener("HomeButton3", self.onHomeButton3, "ChosePanel")
    self:bindListener("HomeButton5", self.onHomeButton5, "ChosePanel")

    self.houseData = args

    self:setCtrlVisible("VisitButton", not self:isMyHouse())
    self:setCtrlVisible("ReturnButton", self:isMyHouse())
    self:setCtrlVisible("AssistCleanButton", not self:isMyHouse())
    self:setCtrlVisible("CleanButton", self:isMyHouse())

    self:setCtrlVisible("InformationPanel_1", not self.houseData.isCouple, "HomeShowPanel")
    self:setCtrlVisible("InformationPanel_2", self.houseData.isCouple, "HomeShowPanel")

    -- 居所名称
    local houseName
    if args.house_prefix and args.house_prefix ~= "" then
        houseName = args.house_prefix .. HomeMgr:getHomeTypeCHS(self.houseData.house_type)
    else
        houseName = string.format(CHS[2000285], args.char_name, HomeMgr:getHomeTypeCHS(self.houseData.house_type))
    end

    self:setLabelText("TitleLabel_2", houseName, self:getControl("TitlePanel", nil, "BKPanel"))

    if self.houseData.isCouple then
        -- 夫妻居所

        -- 主人形象
        self:setPortrait("ShapePanel", 42101, nil, self:getControl("ShowPanel", nil, "InformationPanel_2"))
        self:setPortrait("ShapePanel_1", 42102, nil, self:getControl("ShowPanel", nil, "InformationPanel_2"))

        -- 居所男主人
        self:setLabelText("NameLabel_1", self.houseData.male_name, self:getControl("NamePanel", nil, "InformationPanel_2"))

        -- 居所男主人
        self:setLabelText("NameLabel_1", self.houseData.famale_name, self:getControl("NamePanel_1", nil, "InformationPanel_2"))

        -- 舒适度
        self:setLabelText("TimeLabel_1", self.houseData.comfort, self:getControl("ComfortPanel", nil, "InformationPanel_2"))

        -- 清洁度
        self:setLabelText("TimeLabel_1", string.format("%s/%s", tostring(self.houseData.cleanliness), tostring(HomeMgr:getMaxClean())), self:getControl("CleanPanel", nil, "InformationPanel_2"))

        -- 协助清扫
        self:setLabelText("TimeLabel_1", string.format("%s/%s", tostring(self.houseData.today_clean_times), tostring(HomeMgr:getMaxAssistCleanTimes())), self:getControl("HelpPanel", nil, "InformationPanel_2"))
    else
        -- 私人居所
        if self.houseData.suit_icon and 0 ~= self.houseData.suit_icon then
            -- 主人形象
            self:setPortrait("ShapePanel", self.houseData.suit_icon, self.houseData.weapon_icon, self:getControl("ShowPanel", nil, "InformationPanel_1"), false, nil, nil, nil, self.houseData.icon)
        else
            -- 主人形象
            self:setPortrait("ShapePanel", self.houseData.icon, self.houseData.weapon_icon, self:getControl("ShowPanel", nil, "InformationPanel_1"))
        end

        -- 仙魔光效
        if self.houseData["upgrade/type"] then
            self:addUpgradeMagicToCtrl("ShapePanel", self.houseData["upgrade/type"], "InformationPanel_1", true)
        end

        -- 居所主人
        self:setLabelText("NameLabel_1", self.houseData.char_name, self:getControl("NamePanel", nil, "InformationPanel_1"))

        -- 舒适度
        self:setLabelText("TimeLabel_1", self.houseData.comfort, self:getControl("ComfortPanel", nil, "InformationPanel_1"))

        -- 清洁度
        self:setLabelText("TimeLabel_1", string.format("%s/%s", tostring(self.houseData.cleanliness), tostring(HomeMgr:getMaxClean())), self:getControl("CleanPanel", nil, "InformationPanel_1"))

        -- 协助清扫
        self:setLabelText("TimeLabel_1", string.format("%s/%s", tostring(self.houseData.today_clean_times), tostring(HomeMgr:getMaxAssistCleanTimes())), self:getControl("HelpPanel", nil, "InformationPanel_1"))
    end

    self:bindScorllPanelEventListener("MapImage")

    self:checkButton(1)

    -- 显示预览信息
    self.contentSize = self:getControl("MapImage", nil, "MapPanel"):getContentSize()

    -- 记录一下原始尺寸用于计算缩放
    self.oriW = self.contentSize.width
    self.oriH = self.contentSize.height

    -- self:createMutiTouchLayer(self:getControl("MapImage", nil, "MapPanel"))

    self:hookMsg("MSG_HOUSE_ROOM_SHOW_DATA")
    self:hookMsg("MSG_VISIT_HOUSE_FAILED")
    self:hookMsg("MSG_HOUSE_SHOW_FARM_DATA")
end

function HomeShowDlg:cleanup()
    self.checkIndex = nil
    self.shelterLayer = nil
    self.obstacle = nil

    if GAME_RUNTIME_STATE.QUIT_GAME ~= GameMgr:getGameState() then
        -- 尝试回收贴图
        TextureMgr:collectCache()
    end

    if self.houseData and self.houseData.furnitures then
        for _, v in pairs(self.houseData.furnitures) do
            local info = HomeMgr:getFurnitureInfoById(v.furniture_id)
            local icon = info.icon
            if info.dirs and info.dirs > 1 then
                ArmatureMgr:removeFurnitureArmature(icon)
            end
        end
    end
end

-- 创建多点触控响应层
function HomeShowDlg:createMutiTouchLayer(layer)
    local touchPanel = layer

    if not touchPanel then
        return
    end

    local oldDistance, newDistance

    local function scaleImage(delta)
        local scale = layer:getScaleX()
        if scale < 1.5 and scale >= 1 then
            scale  = math.max(math.min(scale + delta, 1.5), 1)
        end
        self:setPreviewScale(scale)
        self:checkButtonState(scale)
    end

    local function onTouchesBegan(touches, eventType)
        return true
    end

    local function onTouchesMoved(touches, eventType)
        if #touches >= 2 then
            local pos1 = touches[1]:getLocation()
            local pos2 = touches[2]:getLocation()

            if not oldDistance then
                oldDistance = cc.pGetDistance(pos1, pos2)
            else
                newDistance = cc.pGetDistance(pos1, pos2)
            end
        end
    end

    local function onTouchesEnd(touches, eventType)
        if newDistance ~= 0 and oldDistance ~= 0 then
            local diff = newDistance - oldDistance
            scaleImage(math.abs(diff) / 500)
        end
    end

    self.multiTouchListener = cc.EventListenerTouchAllAtOnce:create()
    self.multiTouchListener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN )
    self.multiTouchListener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCHES_ENDED )
    self.multiTouchListener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    self.multiTouchListener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCHES_CANCELLED)
    local eventDispatcher = touchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.multiTouchListener, touchPanel)
end

function HomeShowDlg:isMyHouse()
    if not self.houseData then return end
    return Me:queryBasic("house/id") == self.houseData.house_id
end

function HomeShowDlg:bindScorllPanelEventListener(ctrlName, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    local ctrlName = ctrl:getName()
    local startX, startY = ctrl:getPosition()

    -- 事件监听
    local lastTouchPos
    ctrl:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            lastTouchPos = GameMgr.curTouchPos
        elseif eventType == ccui.TouchEventType.moved then
            if not lastTouchPos then return end
            local touchPos = GameMgr.curTouchPos
            local offsetX, offsetY = touchPos.x - lastTouchPos.x, touchPos.y - lastTouchPos.y
            local x, y = ctrl:getPosition()
            ctrl:setPosition(self:adjustXY(ctrl, x + offsetX, y + offsetY))
            lastTouchPos = touchPos
        elseif eventType == ccui.TouchEventType.ended then
            lastTouchPos = nil
        end
    end)
end

function HomeShowDlg:adjustXY(ctrl, x, y)
    local startX, startY = self.oriW/2, self.oriH / 2
    local ctrlSize = ctrl:getContentSize()
    local scaleX = ctrl:getScaleX()
    local scaleY = ctrl:getScaleY()
    x = math.min(math.max(-(ctrlSize.width * scaleX - self.oriW) / 2 + startX, x), (ctrlSize.width * scaleX - self.oriW) / 2 + startX)
    y = math.min(math.max(-(ctrlSize.height * scaleY - self.oriH) / 2 + startY, y), (ctrlSize.height * scaleY - self.oriH) / 2 + startY)
    return x, y
end

function HomeShowDlg:showPreview()
    -- local mapPanel = self:getControl("MapPanel")
    local mapInfo = MapMgr:getMapinfo()
    local selectedIndex = self.checkIndex
    local mapName = string.format("%s-%s", HomeMgr:getHomeTypeCHS(self.houseData.house_type), SEL_HOUSE_AREAS[selectedIndex])
    local mapKey = MapMgr:getMapByName(mapName)
    local map = mapInfo[mapKey]
    self.mapName = mapName
    self.map_id = map.map_id
    self:drawHomeMap(map.map_id, self.houseData.floor_index + 1, self.houseData.wall_index + 1)
    self:loadShelter()
end

function HomeShowDlg:drawHomeMap(mapId, tileIndex, wallIndex)
    local info = require(ResMgr:getMapInfoPath(mapId))
    if not info then return end
    local mapSprite = self:getControl("MapImage", nil, "MapPanel")
    -- mapSprite:removeAllChildren()
    mapSprite:removeChildByTag(TAG_HOME)
    local destLayer = cc.Layer:create()
    mapSprite:addChild(destLayer, LAYER_HOME, TAG_HOME)
    local width = info.source_width or 0
    local height = info.source_height or 0
    local scale = 1 / info.scale * 0.42
    mapSprite:setContentSize(cc.size(width * Const.MAP_SCALE * 0.42, height  * Const.MAP_SCALE * 0.42))
    self.contentSize = mapSprite:getContentSize()

    for k, v in pairs(info.blocks) do
        local path = ResMgr:getMapBlockPathByName(mapId, info.blocks[k], tileIndex, wallIndex)
        local texture = cc.Director:getInstance():getTextureCache():addImage(path)
        local sprite = cc.Sprite:createWithTexture(texture)
        local x, y = string.match(k, "(-?%d+)_(-?%d+)")
        x = tonumber(x)
        y = tonumber(y)
        x, y = self:mapSpaceToSmallMap(x, height - y, mapId)
        sprite:setAnchorPoint(cc.p(0,1))
        sprite:setPosition(x, y)
        sprite:setScale(scale)
        sprite:setName(k)
        destLayer:addChild(sprite)
    end

    for i = #info.objs, 1, -1 do
        local obj = info.objs[i]
        local path = ResMgr:getMapBlockPathByName(mapId, obj.name, tileIndex, wallIndex)
        local texture = cc.Director:getInstance():getTextureCache():addImage(path)
        local sprite = cc.Sprite:createWithTexture(texture)
        local x, y = tonumber(obj.x), tonumber(obj.y)
        sprite:setAnchorPoint(cc.p(0,1))
        x, y = self:mapSpaceToSmallMap(x, height - y, mapId)
        sprite:setPosition(x, y)
        sprite:setScale(scale)
        if obj.flip then
            sprite:setFlippedX(true)
        end
        sprite:setName(k)
        destLayer:addChild(sprite)
    end

    mapSprite:setScaleX(1)
    mapSprite:setScaleY(1)
    mapSprite:setVisible(true)
    local panelSize = self:getControl("MapPanel"):getContentSize()
    mapSprite:setPosition(panelSize.width / 2, panelSize.height / 2)
    self:checkButtonState(1)

    return mapSprite
end

function HomeShowDlg:drawFurnitures(furnitures)
    local mapLayer = self:getControl("MapImage", nil, "MapPanel")
    mapLayer:removeChildByTag(TAG_FURNITURE)
    local furnitureLayer = cc.Layer:create()
    mapLayer:addChild(furnitureLayer, LAYER_FURNITURE, TAG_FURNITURE)
    mapLayer:removeChildByTag(TAG_CARPET)
    local carpetLayer = cc.Layer:create()
    mapLayer:addChild(carpetLayer, LAYER_CARPET, TAG_CARPET)

    local mapSize = GameMgr.scene.map:getContentSize()
    for _, v in pairs(furnitures) do
        local info = HomeMgr:getFurnitureInfoById(v.furniture_id)
        if HomeMgr:getPutLayerByFurnitureType(info.furniture_type) == "carpet" then
            local sp
            if info.dirs and info.dirs > 1 then
                sp = self:createAnimateFurniture(v, info)
            else
                sp = self:createImageFurniture(v, info)
            end

            carpetLayer:addChild(sp)
        end
    end
    for _, v in pairs(furnitures) do
        local info = HomeMgr:getFurnitureInfoById(v.furniture_id)
        if HomeMgr:getPutLayerByFurnitureType(info.furniture_type) ~= "carpet" then
            local sp
            if info.dirs and info.dirs > 1 then
                sp = self:createAnimateFurniture(v, info)
            else
                sp = self:createImageFurniture(v, info)
            end

            furnitureLayer:addChild(sp)
        end
    end
end

-- 创建骨骼动画家具
function HomeShowDlg:createAnimateFurniture(v, info)
    local wx, wy = self:convertToClientSpace(self.map_id, v.bx, v.by, v.x, v.y)
    local x, y = self:mapSpaceToSmallMap(wx, wy, self.map_id)
    local icon = info.icon
    local dir = HomeMgr:getDirByFlip(info, v.is_flip)
    local furn = ArmatureMgr:createFurnitureArmature(icon)
    furn:setScale(0.42)
    furn:setPosition(x, y)
    furn:setLocalZOrder(HomeMgr:getZOrder(v.furniture_id, furn, -wy))
    furn:getAnimation():play(string.format("%5d_%d", icon, dir), -1, 0)
    return furn
end

-- 创建图片类型的家具
function HomeShowDlg:createImageFurniture(v, info)
    local wx, wy = self:convertToClientSpace(self.map_id, v.bx, v.by, v.x, v.y)
    local x, y = self:mapSpaceToSmallMap(wx, wy, self.map_id)
    local path = self:getSmallMapFurniture(info.icon)
    local sp = cc.Sprite:create(path)
    sp:setScale(0.42)
    sp:setPosition(x, y)
    sp:setFlippedX(1 == v.is_flip)
    sp:setLocalZOrder(HomeMgr:getZOrder(v.furniture_id, sp, -wy))
    local furniturePoint = FurniturePoint[info.icon]

    local tilePath = ResMgr:getFurnitureTilePath(info.icon)
    local furnitureTmx = ccexp.TMXTiledMap:create(tilePath)
    local furnitureObstacle = furnitureTmx:getLayer("obstacle")
    sp:setOpacity(HomeMgr:isShelter(sp, self.shelterLayer, v.bx, v.by, v.is_flip, furniturePoint, furnitureObstacle) and 0x7f or 0xff)
    return sp
end

function HomeShowDlg:drawFarmlands(farmlands)
    local mapLayer = self:getControl("MapImage", nil, "MapPanel")
    local furnitureLayer = mapLayer:getChildByTag(TAG_FURNITURE)
    local carpetLayer = mapLayer:getChildByTag(TAG_CARPET)
    if not furnitureLayer or not carpetLayer then
        return
    end

    local mapInfo = MapMgr:getMapInfoByName(self.mapName)
    local lands = mapInfo.croplands

    if not lands or not farmlands then
        return
    end

    for i = 1, #lands do
        local land = lands[i]
        local cropland
        -- 设置开垦的农田
        if farmlands then
            local imagePath
            if i <= farmlands.active_farm_count then
                imagePath = ResMgr.ui.cultivated_farmland
            else
                imagePath = ResMgr.ui.uncultivated_farmland
            end

            local x, y = self:mapSpaceToSmallMap(land.x, land.y, self.map_id)
            local image = ccui.ImageView:create(imagePath)
            image:setScale(0.42)
            image:setPosition(x, y)
            carpetLayer:addChild(image)
        end

        -- 显示农作物
        if farmlands[i] then
            local x, y = self:mapSpaceToSmallMap(land.x, land.y - Const.CULTIVATED_HEIGHT / 2, self.map_id)
            local fInfo = HomeMgr:getFurnitureInfoById(farmlands[i].class_id)
            local icon, iconNo = HomeMgr:getCropIcon(farmlands[i])
            local path = ResMgr:getFurniturePath(icon, iconNo)
            local sp = cc.Sprite:create(path)
            sp:setScale(0.42)
            sp:setAnchorPoint(0.5, 0)
            sp:setPosition(x, y)
            sp:setLocalZOrder(HomeMgr:getZOrder(farmlands[i].class_id, sp, -land.y))
            furnitureLayer:addChild(sp)
        end
    end
end

function HomeShowDlg:loadShelter()
    local path = ResMgr:getMapObstaclePath(self.map_id)
    local obstacle = ccexp.TMXTiledMap:create(path)
    if nil == obstacle then return end

    if self.obstacle then
        self.obstacle:removeFromParent()
    end
    self.obstacle = obstacle
    self.obstacle:setVisible(false)
    self.root:addChild(self.obstacle)
    local shelterLayer = obstacle:getLayer(string.format("shelter%d", self.houseData.wall_index + 1))
    if not shelterLayer then
        shelterLayer = obstacle:getLayer("shelter")
    end

    self.shelterLayer = shelterLayer
    return shelterLayer
end

-- 获取小地图家具文件
function HomeShowDlg:getSmallMapFurniture(icon)
    return string.format("furniture/%05d.png", icon)
end

-- 大地图坐标转化成小地图坐标
function HomeShowDlg:mapSpaceToSmallMap(x, y, mapId)
    local mapSize

    local info = require (ResMgr:getMapInfoPath(mapId))
    if nil == info then
        return 0, 0
    end

    local width = info.source_width or 0
    local height = info.source_height or 0

    local mapY = y / height
    local mapX = x / width

    return mapX * self.contentSize.width, mapY * self.contentSize.height
end

-- 获取小地图文件
function HomeShowDlg:getSmallMapFile(map_id, floor_index, wall_index)
    return string.format("maps/smallMaps/%05d_%02d_%02d.jpg", map_id, floor_index + 1, wall_index + 1)
end

function HomeShowDlg:setPreviewScale(scale)
    local ctrl = self:getControl("MapImage", nil, "MapPanel")
    ctrl:setScaleX(scale)
    ctrl:setScaleY(scale)
    local x, y = ctrl:getPosition()
    x, y = self:adjustXY(ctrl, x, y)
    ctrl:setPosition(x, y)
end

function HomeShowDlg:checkButtonState(scale)
    self:setCtrlEnabled("AddButton", scale < 1.5)
    self:setCtrlEnabled("ReduceButton", scale > 1)
end

function HomeShowDlg:onCleanButton(sender, eventType)
    if not self.houseData then return end

    if self.houseData.cleanliness >= HomeMgr:getMaxClean() then
        gf:ShowSmallTips(CHS[2000286])
        return
    end

    gf:CmdToServer('CMD_HOUSE_GOTO_CLEAN', { char_name = Me:getName() })
    self:onCloseButton()
end

function HomeShowDlg:onAssistCleanButton(sender, eventType)
    if not self.houseData then return end

    if self.houseData.cleanliness >= HomeMgr:getMaxClean() then
        gf:ShowSmallTips(CHS[2000288])
        return
    end

    gf:CmdToServer('CMD_HOUSE_GOTO_CLEAN', { char_name = self.houseData.char_name })
    self:onCloseButton()
end

function HomeShowDlg:onVisitButton(sender, eventType)
    if not self.houseData then return end

    if not HomeMgr:checkFly() then return end

    if HomeMgr:checkRedName() then
        self:onCloseButton()
        return
    end

    gf:CmdToServer('CMD_HOUSE_FRIEND_VISIT', { char_name = self.houseData.char_name })

    self:onCloseButton()
end

function HomeShowDlg:onReturnButton(sender, eventType)
    if not self.houseData then return end

    if string.isNilOrEmpty(Me:queryBasic("house/id")) then
        gf:ShowSmallTips(CHS[2000289])
        self:onCloseButton()
        return
    end

    if not HomeMgr:checkFly(true) then return end

    if HomeMgr:checkRedName() then
        self:onCloseButton()
        return
    end

    gf:CmdToServer('CMD_HOUSE_GO_HOME')
    self:onCloseButton()
end

function HomeShowDlg:onHomeButton1(sender, eventType)
    self:checkButton(1)
    self:doCheck(1)
end

function HomeShowDlg:onHomeButton3(sender, eventType)
    self:checkButton(2)
    self:doCheck(2)
end

function HomeShowDlg:onHomeButton5(sender, eventType)
    self:checkButton(3)
    self:doCheck(3)
end

function HomeShowDlg:checkButton(index)
    for i = 1, 3 do
        if i == index then
            self:setCtrlVisible(string.format("HomeButton%d", i * 2 - 1), false, "ChosePanel")
            self:setCtrlVisible(string.format("HomeButton%d", i * 2), true, "ChosePanel")
        else
            self:setCtrlVisible(string.format("HomeButton%d", i * 2 - 1), true, "ChosePanel")
            self:setCtrlVisible(string.format("HomeButton%d", i * 2), false, "ChosePanel")
        end
    end
    self.checkIndex = index
end

function HomeShowDlg:doCheck(index)
    if not self.houseData then return end

    -- 调整等待框到居所界面的中部
    --DlgMgr:openDlg("WaitDlg")
    local waitDlg = DlgMgr:openDlgEx("WaitDlg", {order = Const.LOADING_DLG_ZORDER - 1})
    local bkImage = self:getControl("BKImage", Const.UIImage, "MapPanel")
    local itemBox = self:getBoundingBoxInWorldSpace(bkImage)
    waitDlg:setPosition(cc.p(itemBox.x + itemBox.width / 2, itemBox.y + itemBox.height / 2))

    self:setCtrlVisible("MapImage", false, "MapPanel")
    gf:CmdToServer("CMD_HOUSE_ROOM_SHOW_DATA", { house_id = self.houseData.house_id, type = index })
end

-- 将地图坐标(mapX, mapY)转换为客户端显示时使用的坐标
function HomeShowDlg:convertToClientSpace(mapId, mapX, mapY, ox, oy)
    local info = require(ResMgr:getMapInfoPath(mapId))
    if nil == info then
        return 0, 0
    end

    local height = info.source_height or 0
    return mapX * Const.PANE_WIDTH + Const.PANE_WIDTH / 2 + ox, height - mapY * Const.PANE_HEIGHT - Const.PANE_HEIGHT / 2 + oy
end

function HomeShowDlg:onAddButton(sender, eventType)
    local mapImage = self:getControl("MapImage", nil, "MapPanel")
    local size = mapImage:getContentSize()
    -- local scale  = size.width / self.contentSize.width
    local scale = math.floor(mapImage:getScaleX() * 10 + 0.5) / 10
    if scale < 1.5 then
        scale  = math.min(scale + 0.1, 1.5)
    end
    self:setPreviewScale(scale)
    self:checkButtonState(scale)
end

function HomeShowDlg:onReduceButton(sender, eventType)
    local mapImage = self:getControl("MapImage", nil, "MapPanel")
    local size = mapImage:getContentSize()
    --local scale  = size.width / self.contentSize.width
    local scale = math.floor(mapImage:getScaleX() * 10 + 0.5) / 10
    if scale > 1 then
        scale  = math.max(scale - 0.1, 1)
    end
    self:setPreviewScale(scale)
    self:checkButtonState(scale)
end

function HomeShowDlg:MSG_HOUSE_ROOM_SHOW_DATA(data)
     if self.houseData and data.house_id == self.houseData.house_id and self.checkIndex == data.type then
        self.houseData.house_type = data.house_type
        self.houseData.floor_index = data.floor_index
        self.houseData.wall_index = data.wall_index
        self.houseData.furnitures = data.furnitures

        if self.checkIndex ~= 3 then
            self:showPreview()
            self:drawFurnitures(self.houseData.furnitures)
        end
    end

    if self.checkIndex ~= 3 then
        DlgMgr:closeDlg("WaitDlg")
    end
end

function HomeShowDlg:MSG_HOUSE_SHOW_FARM_DATA(data)
    if self.houseData and data.house_id == self.houseData.house_id and self.checkIndex == 3 then
        self:showPreview()
        self:drawFurnitures(self.houseData.furnitures)

        self.houseData.farmlands = data
        self:drawFarmlands(data)
    end

    if self.checkIndex == 3 then
        DlgMgr:closeDlg("WaitDlg")
    end
end

function HomeShowDlg:MSG_VISIT_HOUSE_FAILED(data)
    if not self.houseData or self.houseData.char_name == data.char_name then
        self:onCloseButton()
    end
    DlgMgr:closeDlg("WaitDlg")
end

return HomeShowDlg
