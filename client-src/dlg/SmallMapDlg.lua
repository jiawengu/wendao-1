-- SmallMapDlg.lua
-- created by songcw Dec/23/2014
-- 小地图对话框

local SmallMapDlg = Singleton("SmallMapDlg", Dialog)
local FurniturePoint = require(ResMgr:getCfgPath("FurniturePoint.lua"))

-- 小地图层顺序
local LAYER_TOM         = 10        -- 小地图最底层
local LAYER_MAP_NPC     = 15        -- 地图NPC
local LAYER_EXIT        = 20        -- 过图点和练功区
local LAYER_CARPET      = 25        -- 家具
local LAYER_FURNITURE   = 30        -- 家具
local LAYER_NPC_POINT   = 35        -- NPC
local LAYER_DEST        = 40        -- 寻路目的地
local LAYER_ME          = 45        -- HERO玩家角色
local LAYER_TEAM        = 50        -- 队伍
local LAYER_NPC_NAME    = 55        -- NPC名称
local LAYER_TOP         = 60        -- 置顶悬浮显示层

local SMALLMAP_TAG      = 1         -- 控件中小地图
-- 小地图 Tag
local TAG_MAP          = 100          -- 小地图中Layer中地图sprite
local TAG_ME           = 200          -- 小地图中me
local TAG_DEST         = 300          -- 小地图目的地旗帜
local TAG_TEAM         = 400          -- 小地图Team
local TAG_EXITS        = 500          -- 小地图过图点
local TAG_CARPET       = 600          -- 小地图上的地毯
local TAG_FURNITURE    = 700          -- 小地图上的家具
local TAG_MAP_NPC      = 800          -- 地图NPC
local TAG_MG_BLANK     = 900          -- 迷宫黑幕地图

local TAG_NPC          = 50

local DISTANCE         = 20         -- 小地图寻路途经点两点间距离   （按自动寻路轨迹）

local DISTANCE_NAME_POINT   = 15

local colorNpc = cc.c3b(0, 255, 255)
local colorNpc2 = cc.c3b(0, 0, 0)

function SmallMapDlg:init()
    self:bindListener("WorldMapButton", self.onWorldMapButton)
    self:bindListener("NPCListButton", self.onNPCListButton)

    self.singleNpc = self:getControl("SingleNPCPanel")
    self.singleNpc:retain()
    self.singleNpc:removeFromParent()

    -- 更新组队队员信息，以便小地图显示
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_EX_INFO)

    self:hookMsg("MSG_ROOM_GUANJIA_INFO")
end

function SmallMapDlg:initData()
    if not self:drawSmallMap() then
        -- 绘制小地图失败
        self:onCloseButton()
        gf:ShowSmallTips(CHS[3003649])
        return
    end

    schedule(self.root, function() self:updateSmallMap() end, 0.1)
    self:drawDestPoint(Me.paths, Me.posCount)
end

function SmallMapDlg:cleanup()
    self:releaseCloneCtrl("singleNpc")
    self.shelterLayer = nil
    self.obstacle = nil

    local furnitures = HomeMgr:getFurnitures()
    if furnitures then
        for _, v in pairs(furnitures) do
            local name = v:queryBasic("name")
            local info = HomeMgr:getFurnitureInfo(name)
            local icon = info.icon
            if info.dirs and info.dirs > 1 then
                ArmatureMgr:removeFurnitureArmature(icon)
            end
        end
    end
end

-- 绘制小地图
function SmallMapDlg:drawSmallMap()
    local panel = self:getControl("SmallMapPanel")
    if nil == panel then return end

    --  小地图map
    local smallMapLayer = cc.Layer:create()
    local fileName
    local mapSprite
    local mapName = MapMgr:getCurrentMapName()
    local mapId = MapMgr:getCurrentMapId()
    local mapInfo = MapMgr:getMapinfo()[mapId]
    if not mapInfo then return end
    if MapMgr:isInHouse(mapName) or mapName == CHS[5410203]
        or mapName == CHS[7190283] or mapName == CHS[7190284]
        or mapName == CHS[7190285] or mapName == CHS[7190286] then
        -- fileName = self:getSmallMapFile(MapMgr:getCurrentMapId(), MapMgr:getTileIndex(), MapMgr:getWallIndex())
        local map_id = mapInfo.map_id
        mapSprite = self:drawHomeMap(map_id, MapMgr:getTileIndex(), MapMgr:getWallIndex())
    elseif MapMgr:isInMiGong() then
        local map_id = mapInfo.map_id
        mapSprite = self:drawMiGong(map_id, MapMgr:getTileIndex(), MapMgr:getWallIndex())
    else
        fileName = self:getSmallMapFile(mapId)

        if nil == fileName then return end
        mapSprite = cc.Sprite:create(fileName)

        if mapInfo and mapInfo.flipX then
            mapSprite:setFlippedX(true)
        else
            mapSprite:setFlippedX(false)
        end
    end
    if nil == mapSprite then return end

    local x, y = 0, 0
    local spSize = mapSprite:getContentSize()
    local showSize
    local scale = 1
    if mapInfo.range and MapMgr:isInMiGong() then
        showSize = {}
        showSize.width = spSize.width - (mapInfo.range.x1 + mapInfo.range.x2)
        showSize.height = spSize.height - (mapInfo.range.y1 + mapInfo.range.y2)
        x = - mapInfo.range.x1
        y = - mapInfo.range.y2
    else
        showSize = spSize
    end

    if showSize.height > 640 then
        local r = showSize.width / showSize.height
        local width, height
        if r >= 1.26214 and (520 * r) < Const.WINSIZE.width / Const.UI_SCALE - 40 then
            scale = 520 / showSize.height
            height = showSize.height * scale
            width = height * r
        else
            scale = 412 / showSize.height
            height = showSize.height * scale
            width = height * r
        end

        mapSprite:setContentSize(spSize.width * scale, spSize.height * scale)
        mapSprite:setScaleX(scale)
        mapSprite:setScaleY(scale)

        showSize = cc.size(width, height)
    end

    local panelSize = panel:getContentSize()
    self.contentSize = mapSprite:getContentSize()
    panel:setContentSize(showSize.width, showSize.height)
    panel:setClippingEnabled(true)

    local size = panel:getContentSize()
    self:getControl("BKImage"):setContentSize(size.width + 10, size.height + 10)
    local mainPanel = self:getControl("MainPanel")
    local rootSize = mainPanel:getContentSize()
    mainPanel:setContentSize(rootSize.width - (panelSize.width - showSize.width), rootSize.height - ((panelSize.height - showSize.height)))
    mainPanel:setPositionY(mainPanel:getPositionY() + 20)
    self.root:setContentSize(mainPanel:getContentSize().width, mainPanel:getContentSize().height + 66)

    panel:setAnchorPoint(0.5,0.5)
    panel:setPosition(self.root:getContentSize().width * 0.5, self.root:getContentSize().height * 0.5)

    smallMapLayer:setContentSize(spSize)
    smallMapLayer:setPosition(x * scale, y * scale)
    panel:addChild(smallMapLayer, 1, SMALLMAP_TAG)

    mapSprite:setAnchorPoint(0, 0)
    mapSprite:setPosition(0,0)
    smallMapLayer:addChild(mapSprite, LAYER_TOM, TAG_MAP)

    -- 绘制地图NPC
    self:drawMapNpcs()

    -- 小地图绘制Me点
    self:drawMePoint()

    -- 小地图NPC
    self:drawNPCPoint()
    self:setNPCList()

    -- 小地图绘制队伍
    self:drawTeam()

    if not mapInfo.notShowExitInSmallMap then
        -- 小地图过图点
        self:drawExits()
    end

    -- 绘制地图上的家具
    self:drawFurniture()

    -- 绘制迷宫黑幕
    if MapMgr:isInMiGong() then
        self:drawMiGongBlank(scale)
    end

    -- 小地图点击事件
    local function onTouchBegan(touch, event)
        local pos = smallMapLayer:convertTouchToNodeSpace(touch)
        local rect = smallMapLayer:getBoundingBox()
        rect.x = 0
        rect.y = 0
        if cc.rectContainsPoint(rect, pos) then
            if not Me:isControlMove() or GameMgr.inCombat then return false end
            if MapMgr:isInMiGong() then return end

            Me:setEndPos(self:smallMapToClientSpace(pos.x,pos.y))
            self:drawDestPoint(Me.paths, Me.posCount)
            return true
        end
    end

    --监听地图点击事件
    gf:bindTouchListener(smallMapLayer, onTouchBegan)

    self:align(ccui.RelativeAlign.centerInParent)
    self:updateLayout("SmallMapDlg")

    return true
end

function SmallMapDlg:drawMiGong(mapId, tileIndex, wallIndex)
    local info = require(ResMgr:getMapInfoPath(mapId))
    if not info then return end
    local mapSprite = cc.Layer:create()
    local width = info.source_width or 0
    local height = info.source_height or 0
    local scale = 1 / info.scale
    local size = cc.size(width * Const.MAP_SCALE, height  * Const.MAP_SCALE)
    mapSprite:setContentSize(size)

    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), size.width, size.height)
    mapSprite:addChild(layer)

    for k, v in pairs(info.blocks) do
        local path = ResMgr:getMapBlockPathByName(mapId, info.blocks[k], tileIndex, wallIndex)
        local texture = cc.Director:getInstance():getTextureCache():addImage(path)
        local sprite = cc.Sprite:createWithTexture(texture)
        local x, y = string.match(k, "(-?%d+)_(-?%d+)")
        x = tonumber(x)
        y = tonumber(y)
        sprite:setAnchorPoint(cc.p(0,1))
        sprite:setPosition(x, height - y)
        sprite:setScale(scale)
        sprite:setName(k)
        mapSprite:addChild(sprite)
    end

--    mapSprite:setScaleX(0.63)
--    mapSprite:setScaleY(0.63)
    -- self:loadShelter(mapId, tileIndex, wallIndex)
    return mapSprite
end

function SmallMapDlg:drawHomeMap(mapId, tileIndex, wallIndex)
    local info = require(ResMgr:getMapInfoPath(mapId))
    if not info then return end
    local mapSprite = cc.Layer:create()
    local width = info.source_width or 0
    local height = info.source_height or 0
    local scale = 1 / info.scale
    mapSprite:setContentSize(cc.size(width * Const.MAP_SCALE, height  * Const.MAP_SCALE))

    for k, v in pairs(info.blocks) do
        local path = ResMgr:getMapBlockPathByName(mapId, info.blocks[k], tileIndex, wallIndex)
        local texture = cc.Director:getInstance():getTextureCache():addImage(path)
        local sprite = cc.Sprite:createWithTexture(texture)
        local x, y = string.match(k, "(-?%d+)_(-?%d+)")
        x = tonumber(x)
        y = tonumber(y)
        sprite:setAnchorPoint(cc.p(0,1))
        sprite:setPosition(x, height - y)
        sprite:setScale(scale)
        sprite:setName(k)
        mapSprite:addChild(sprite)
    end

    for i = #info.objs, 1, -1 do
        local obj = info.objs[i]
        local path = ResMgr:getMapBlockPathByName(mapId, obj.name, tileIndex, wallIndex)
        local texture = cc.Director:getInstance():getTextureCache():addImage(path)
        local sprite = cc.Sprite:createWithTexture(texture)
        local x, y = tonumber(obj.x), tonumber(obj.y)
        sprite:setAnchorPoint(cc.p(0,1))
        sprite:setPosition(x, height - y)
        sprite:setScale(scale)
        if obj.flip then
            sprite:setFlippedX(true)
        end
        sprite:setName(k)
        mapSprite:addChild(sprite)
    end

--    mapSprite:setScaleX(0.63)
--    mapSprite:setScaleY(0.63)
    -- self:loadShelter(mapId, tileIndex, wallIndex)
    return mapSprite
end

function SmallMapDlg:loadShelter(map_id, tileIndex, wallIndex)
    local path = ResMgr:getMapObstaclePath(map_id)
    local obstacle = ccexp.TMXTiledMap:create(path)
    if nil == obstacle then return end

    if self.obstacle then
        self.obstacle:removeFromParent()
    end
    self.obstacle = obstacle
    self.obstacle:setVisible(false)
    self.root:addChild(self.obstacle)
    local shelterLayer = obstacle:getLayer(string.format("shelter%d", wallIndex + 1))
    if not shelterLayer then
        shelterLayer = obstacle:getLayer("shelter")
    end

    self.shelterLayer = shelterLayer
    return shelterLayer
end

-- 是否遮挡点
function SmallMapDlg:isShelter(mapX, mapY)
    if not GameMgr.scene or not GameMgr.scene.map then return end
    return GameMgr.scene.map:isShelter(mapX, mapY)
end

-- 获取有效的NPC，排除过期的节日活动
function SmallMapDlg:getNPCList()
    local retNpc = {}
    local mapNpcs = MapMgr:getNpcs(MapMgr:getCurrentMapId())
    for _,npc in pairs(mapNpcs) do
        if not npc.isActiveNPC and (not npc.npcShowFunc or (self[npc.npcShowFunc] and self[npc.npcShowFunc](self, npc, 1))) then
            table.insert(retNpc, npc)
        end
    end

    return retNpc
end

-- 获取小地图层Layer
function SmallMapDlg:setNPCList(gjIcon)
    local mapNpcs = self:getNPCList()
    if not mapNpcs or not next(mapNpcs) then return end
    local listView = self:resetListView("ListView", 4)
    for _,npc in pairs(mapNpcs) do
        local panel = self.singleNpc:clone()
        local displayName = npc.alias or npc.name

        -- 名字长度限制为6个字
        displayName = gf:getTextByLenth(displayName, 12)

        self:setLabelText("NameLabel", displayName, panel)

        local icon = npc.icon
        if gjIcon and string.match(npc.name, CHS[2000418]) then
            -- 居所管家icon，不能使用MapInfo配置的固定icon
            icon = gjIcon
        end

        self:setImage("ShapeImage", ResMgr:getSmallPortrait(icon), panel)
        self:setItemImageSize("ShapeImage", panel)

        if npc.inTestDist then
            if DistMgr:curIsTestDist() then listView:pushBackCustomItem(panel) end
        else
            listView:pushBackCustomItem(panel)
        end
        local function ctrlTouch(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                self:setCtrlVisible("ChosenEffectImage", false, sender)

                local destStr = npc.name .. "|" .. MapMgr:getCurrentMapName() .. "(" .. npc.x .. "," .. npc.y .. ")"
                AutoWalkMgr:beginAutoWalk(gf:findDest("#P" .. destStr .. "#P"))
                self:drawDestPoint(Me.paths, Me.posCount)
                self:onNPCListButton()
            elseif ccui.TouchEventType.began == eventType then
                self:setCtrlVisible("ChosenEffectImage", true, sender)
            elseif ccui.TouchEventType.moved == eventType then
            else
                self:setCtrlVisible("ChosenEffectImage", false, sender)
            end
        end
        panel:setTouchEnabled(true)
        panel:addTouchEventListener(ctrlTouch)
    end
end

-- 获取小地图层Layer
function SmallMapDlg:getSmallMapLayer(id)
    local panel = self:getControl("SmallMapPanel")
    if nil == panel then return end

    local mapLayer = panel:getChildByTag(SMALLMAP_TAG)
    if nil == mapLayer then return end
    return mapLayer
end

-- 获取小地图文件
function SmallMapDlg:getSmallMapFile(id, floor_index, wall_index)
    if MapMgr:getMapinfo()[id] == nil then return end
    local map_id = MapMgr:getMapinfo()[id].map_id
    if floor_index and wall_index then
        return string.format("maps/smallMaps/%05d_%02d_%02d.jpg", map_id, floor_index, wall_index)
    else
        return string.format("maps/smallMaps/%05d.jpg", map_id)
    end
end

-- 获取小地图Me文件
function SmallMapDlg:getSmallMapHero()
    return string.format("maps/smallMaps/hero.png")
end

-- 获取小地图目的地文件
function SmallMapDlg:getSmallMapDest()
    return string.format("maps/smallMaps/dest.png")
end

-- 获取小地NPC文件
function SmallMapDlg:getSmallMapNPC()
    return string.format("maps/smallMaps/NPC.png")
end

-- 获取小地图Team暂离文件
function SmallMapDlg:getSmallMapTeamLeave()
    return string.format("maps/smallMaps/dest.png")
end

-- 获取小地图过图点文件
function SmallMapDlg:getSmallMapExitsFile()
    return string.format("maps/smallMaps/pastPoint.png")
end

-- 获取小地图途径点文件
function SmallMapDlg:getSmallMapWayFile()
    return string.format("maps/smallMaps/way.png")
end

-- 获取小地图家具文件
function SmallMapDlg:getSmallMapFurniture(icon)
    return string.format("furniture/%05d.png", icon)
end

-- 获取地图NPC文件
function SmallMapDlg:getMapNpcIcon(icon)
    return string.format("map_npcs/%05d.png", icon)
end

-- 小地图绘制Me点
function SmallMapDlg:drawMePoint()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then return end
    mapLayer:removeChildByTag(TAG_ME)
    local dx , dy = self:mapSpaceToSmallMap(Me.curX, Me.curY)
    local heroFile = self:getSmallMapHero()
    local heroPoint = cc.Sprite:create(heroFile)
    heroPoint:setPosition(dx, dy)
    mapLayer:addChild(heroPoint, LAYER_ME, TAG_ME)
end

-- 小地图绘制目的地旗帜       参数坐标为小地图的坐标
function SmallMapDlg:drawDestPoint(paths, count)
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer or paths == nil or count == nil then
        local destFlag = mapLayer:getChildByTag(TAG_DEST)
        if destFlag then mapLayer:removeChildByTag(TAG_DEST) end
        return
    end

    mapLayer:removeChildByTag(TAG_DEST)
    local destLayer = cc.Layer:create()
    mapLayer:addChild(destLayer, LAYER_DEST, TAG_DEST)

    -- 小地图途经点
    local function getPointByDistance(srcX, srcY, destX, destY, dis)    -- 获取src点往dest点距离dis的点的坐标    默认两点距离大于dis
        if srcX == destX then
            if destY - srcY > 0 then
                return srcX,srcY + dis
            else
                return srcX,srcY - dis
            end
    elseif srcY == destY then
        if destX - srcX > 0 then
            return srcX + dis,srcY
        else
            return srcX - dis,srcY
        end
    end

    local k = (destY - srcY) / (destX - srcX)
    local disX = math.sqrt(dis * dis / (k * k + 1))
    if  destX - srcX > 0 then
        disX = math.abs(disX)
    else
        disX = -math.abs(disX)
    end

    local disY = k * disX
    return srcX + disX, srcY + disY
    end

    local srcX, srcY = self:mapSpaceToSmallMap(paths[string.format("x%d", 1)], paths[string.format("y%d", 1)])
    local dis = DISTANCE
    local psthFile = self:getSmallMapWayFile()
    for i = 1, count - 1  do
        local nextX, nextY = self:mapSpaceToSmallMap(paths[string.format("x%d", i + 1)], paths[string.format("y%d", i + 1)])
        while gf:distance(srcX, srcY, nextX, nextY) >= dis do
            local posX, posY = getPointByDistance(srcX, srcY, nextX, nextY, dis)
            local psthSprite = cc.Sprite:create(psthFile)
            psthSprite:setPosition(posX, posY)
            destLayer:addChild(psthSprite)
            srcX = posX; srcY = posY; dis = DISTANCE
        end
        dis = dis - gf:distance(srcX, srcY, nextX, nextY)
        srcX = nextX; srcY = nextY
    end

    -- 小地图旗帜
    local destFile = self:getSmallMapDest()
    local destSprite = cc.Sprite:create(destFile)
    local x, y = self:mapSpaceToSmallMap(paths[string.format("x%d", count)], paths[string.format("y%d", count)])
    destSprite:setPosition(x, y)
    destLayer:addChild(destSprite)
end

-- 小地图绘制NPC点
function SmallMapDlg:drawNPCPoint()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then return end
    local NPCLayer = cc.Layer:create()
    mapLayer:addChild(NPCLayer,LAYER_NPC_POINT,TAG_NPC)
    local mapNpcs = MapMgr:getDisplayNpcs(MapMgr:getCurrentMapId())
    if not mapNpcs then return end
    local NPCFile = self:getSmallMapNPC()

    -- 创建NPC精灵等
    local function createNPC(npc)
        local NPCSprite = cc.Sprite:create(NPCFile)
        local smallX, smallY = self:leftXYToSmallMap(npc.x, npc.y)
        NPCSprite:setPosition(smallX, smallY)
        NPCLayer:addChild(NPCSprite, 1)

        -- 生成颜色字符串控件
        local tip = ccui.Text:create()
        local tip2 = ccui.Text:create()
        tip:setFontSize(19)
        tip2:setFontSize(19)
        tip:setColor(colorNpc)
        tip2:setColor(colorNpc2)

        local displayName = npc.alias or npc.name

        tip:setString(displayName)
        tip2:setString(displayName)
        tip:setPosition(smallX, smallY - DISTANCE_NAME_POINT)
        tip2:setPosition(smallX + 1, smallY - DISTANCE_NAME_POINT - 1)

        if npc.offsetPos then
            local x1,y1 = tip:getPosition()
            local x2,y2 = tip2:getPosition()
            tip:setPosition(x1 + npc.offsetPos.x, y1 + npc.offsetPos.y)
            tip2:setPosition(x2 + npc.offsetPos.x, y2 + npc.offsetPos.y)
        end

        NPCLayer:addChild(tip2, 2)
        NPCLayer:addChild(tip, 2)
    end

    for _,npc in pairs(mapNpcs) do

        -- inTestDist字段表示该npc只显示内测区
        if npc.inTestDist then
            if DistMgr:curIsTestDist() then createNPC(npc) end
        elseif not npc.npcShowFunc or (self[npc.npcShowFunc] and self[npc.npcShowFunc](self, npc, 2)) then
            createNPC(npc)
        end
    end
end

-- 小地图更新
function SmallMapDlg:updateSmallMap()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then return end
    -- me
    local heroSprite = mapLayer:getChildByTag(TAG_ME)
    if nil == heroSprite then return end
    local dx , dy = self:mapSpaceToSmallMap(Me.curX, Me.curY)
    heroSprite:setPosition(dx, dy)

    -- 途经点
    self:drawDestPoint(Me.paths, Me.posCount)

    -- Team
    local teamLayer = mapLayer:getChildByTag(TAG_TEAM)
    if nil == teamLayer then return end
    teamLayer:removeFromParent()
    self:drawTeam()

end

-- 小地图绘制过点及地图名称
function SmallMapDlg:drawExits()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then return end

    local exitLayer = cc.Layer:create()

    local fx, fy = mapLayer:getPosition()

    self:getControl("BKImage"):addChild(exitLayer,LAYER_EXIT,TAG_EXITS)
    local exitFile = self:getSmallMapExitsFile()
    local count = MapMgr.exits.count
    for i = 1, count do
        local posX, posY = self:leftXYToSmallMap(MapMgr.exits[i].x, MapMgr.exits[i].y)
        posX = posX + fx
        posY = posY + fy
        local exitSprite = cc.Sprite:create(exitFile)
        exitSprite:setPosition(posX, posY)
        exitLayer:addChild(exitSprite)

        local isOutMap = ((posY - DISTANCE_NAME_POINT * 2) < 0)

        -- 过图点name
        local exitName = ccui.Text:create()
        exitName:setFontSize(15)
        exitName:setColor(COLOR3.RED)
        exitName:setString(MapMgr.exits[i].room_name)

        if posX - exitName:getContentSize().width * 0.5 <= 0 then
            posX = exitName:getContentSize().width * 0.5 + 10
        elseif posX + exitName:getContentSize().width * 0.5  >= self:getControl("BKImage"):getContentSize().width then
            posX = self:getControl("BKImage"):getContentSize().width - exitName:getContentSize().width * 0.5 - 15
        end

        if isOutMap then
            exitName:setPosition(posX, posY + DISTANCE_NAME_POINT)
        else
            exitName:setPosition(posX, posY - DISTANCE_NAME_POINT)
        end
        exitLayer:addChild(exitName)
    end
end

function SmallMapDlg:drawMiGongBlank(scale)
    local mapLayer = self:getSmallMapLayer()
    local mgRText = gf:getCharTopLayer():getChildByName("MiGongRender")
    if mgRText then
        if not scale then return end
        local sprite = cc.Sprite:createWithTexture(mgRText:getSprite():getTexture())
        -- sprite:setScale(scale)
        sprite:setPosition(0, 0 )
        sprite:setAnchorPoint(0, 0)
        sprite:setScale(scale * mgRText:getScale())
        sprite:setFlippedY(true)
        mapLayer:addChild(sprite, LAYER_TOP, 0)
    end
end

-- 绘制小地图上的家具
function SmallMapDlg:drawFurniture()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then
        return
    end

    mapLayer:removeChildByTag(TAG_FURNITURE)
    mapLayer:removeChildByTag(TAG_CARPET)
    local furnitureLayer = cc.Layer:create()
    mapLayer:addChild(furnitureLayer, LAYER_FURNITURE, TAG_FURNITURE)
    local carpetLayer = cc.Layer:create()
    mapLayer:addChild(carpetLayer, LAYER_CARPET, TAG_CARPET)

    local furnitures = HomeMgr:getFurnitures()
    local mapSize = GameMgr.scene.map:getContentSize()
    local scale = cc.p(self.contentSize.width / mapSize.width, self.contentSize.height / mapSize.height)
    for _, v in pairs(furnitures) do
        if HomeMgr:getPutLayerByFurniture(v) == "carpet" then
            local sp
            local name = v:queryBasic("name")
            local info = HomeMgr:getFurnitureInfo(name)
            if info.dirs and info.dirs > 1 then
                sp = self:createAnimateFurniture(v, scale)
            else
                sp = self:createImageFurniture(v, scale)
            end

            carpetLayer:addChild(sp)
        end
    end

    for _, v in pairs(furnitures) do
        if HomeMgr:getPutLayerByFurniture(v) ~= "carpet" then
            local sp
            local name = v:queryBasic("name")
            local info = HomeMgr:getFurnitureInfo(name)
            if info.dirs and info.dirs > 1 then
                sp = self:createAnimateFurniture(v, scale)
            else
                sp = self:createImageFurniture(v, scale)
            end

            furnitureLayer:addChild(sp)
        end
    end

    -- 绘制农田
    self:drawFarmlands()
end

-- 绘制客栈家具
function SmallMapDlg:drawInnFurniture()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then
        return
    end

    local furnitures = InnMgr:getBaseData()
    local posCfg = InnMgr:getInnFurniturePosCfg()
    local mapSize = GameMgr.scene.map:getContentSize()
    local scale = cc.p(self.contentSize.width / mapSize.width, self.contentSize.height / mapSize.height)
    for i = 1, furnitures.roomCount do
        local x, y = posCfg["room"][i][1], posCfg["room"][i][2]
        local x, y = self:mapSpaceToSmallMap(x, y)
        local info = furnitures.roomInfo[i]
        local imagePath = InnMgr:getInnRoomCfg()[info.level].imagePath
        local sp = cc.Sprite:create(imagePath)
        if info.id == 1 or info.id == 4 or info.id == 6 then
            sp:setFlippedX(true)
        end

        sp:setAnchorPoint(0, 1)
        sp:setScale(scale.x, scale.y)
        sp:setPosition(x, y)
        mapLayer:addChild(sp, TAG_FURNITURE)
    end

    for i = 1, furnitures.tableCount do
        local x, y = posCfg["table"][i][1], posCfg["table"][i][2]
        local x, y = self:mapSpaceToSmallMap(x, y)
        local info = furnitures.tableInfo[i]
        local imagePath = InnMgr:getInnTabelCfg()[info.level].imagePath
        local sp = cc.Sprite:create(imagePath)
        sp:setAnchorPoint(0, 1)
        sp:setScale(scale.x, scale.y)
        sp:setPosition(x, y)
        mapLayer:addChild(sp, TAG_FURNITURE)
    end
end

-- 创建骨骼动画家具
function SmallMapDlg:createAnimateFurniture(v, scale)
            local x, y = self:mapSpaceToSmallMap(v.curX, v.curY)
            local icon = v:queryBasicInt("icon")
    local dir = v:queryBasicInt("dir")
    local furn = ArmatureMgr:createFurnitureArmature(icon)
    furn:setScale(scale.x, scale.y)
    furn:setPosition(x, y)
    furn:setLocalZOrder(v:getZOrder(-v.curY))
    furn:getAnimation():play(string.format("%5d_%d", icon, dir), -1, 0)
    return furn
end

-- 创建图片类型的家具
function SmallMapDlg:createImageFurniture(v, scale)
    local x, y = self:mapSpaceToSmallMap(v.curX, v.curY)
    local icon = v:queryBasicInt("icon")
    local path = self:getSmallMapFurniture(icon)
    local sp = cc.Sprite:create(path)
    sp:setScale(scale.x, scale.y)
    sp:setFlippedX(v:isFlip())
    sp:setPosition(x, y)
    -- sp:setAnchorPoint(0.5, 0)
    sp:setVisible(v:getVisible())
    sp:setLocalZOrder(v:getZOrder(-v.curY))
    sp:setOpacity(v:isShelter(gf:convertToMapSpace(v.curX, v.curY)) and 0x7f or 0xff)
    return sp
end

-- 绘制农田信息
function SmallMapDlg:drawFarmlands()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then
        return
    end

    local furnitureLayer = mapLayer:getChildByTag(TAG_FURNITURE)
    local carpetLayer = mapLayer:getChildByTag(TAG_CARPET)
    if not furnitureLayer or not carpetLayer then
        return
    end

    local mapInfo = MapMgr:getMapInfoByName(MapMgr:getCurrentMapName())
    local lands = mapInfo.croplands

    local farmlands = HomeMgr.croplandInfo
    if not lands or not farmlands then
        return
    end

    local mapSize = GameMgr.scene.map:getContentSize()
    local scale = cc.p(self.contentSize.width / mapSize.width, self.contentSize.height / mapSize.height)
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
            image:setScale(scale.x, scale.y)
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
            sp:setScale(scale.x, scale.y)
            sp:setAnchorPoint(0.5, 0)
            sp:setPosition(x, y)
            sp:setLocalZOrder(HomeMgr:getZOrder(farmlands[i].class_id, sp, -land.y))
            furnitureLayer:addChild(sp)
        end
    end
end

function SmallMapDlg:drawMapNpcs()
    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then return end
    local mapNpcLayer = cc.Layer:create()
    mapLayer:addChild(mapNpcLayer, LAYER_MAP_NPC, TAG_MAP_NPC)

    local mapNpcs = MapMgr:getAllMapNpcs()
    local mapSize = GameMgr.scene.map:getContentSize()
    local scale = cc.p(self.contentSize.width / mapSize.width, self.contentSize.height / mapSize.height)
    for _, v in pairs(mapNpcs) do
        local x, y = self:mapSpaceToSmallMap(v.curX, v.curY)
        local icon = v:queryBasicInt("icon")
        local path = self:getMapNpcIcon(icon)
        local sp = cc.Sprite:create(path)
        if not sp then return end
        sp:setScale(scale.x, scale.y)
        sp:setFlippedX(v:isFlip())
        sp:setPosition(x, y)
        sp:setLocalZOrder(gf:getObjZorder(y))
        mapNpcLayer:addChild(sp)
    end
end

-- 小地图绘制队伍成员信息
function SmallMapDlg:drawTeam()
    local mapInfo = MapMgr:getMapInfoByName(MapMgr:getCurrentMapName())
    if mapInfo.notDrawTeam then return end

    local myId = Me:getId()
    if not TeamMgr:inTeamEx(myId) then return end

    local mapLayer = self:getSmallMapLayer()
    if nil == mapLayer then return end
    local teamLayer = cc.Layer:create()
    local teamLayer = mapLayer:getChildByTag(TAG_TEAM)
    if nil == teamLayer then
        teamLayer = cc.Layer:create()
        mapLayer:addChild(teamLayer,LAYER_TEAM,TAG_TEAM)
    end
    teamLayer:removeAllChildren()
    local members = TeamMgr.members_ex
    if TeamMgr:getLeaderId() == myId then
        -- 队长是 Me，显示暂离队员
        local team = self:getSmallMapTeamLeave()
        for k, v in ipairs(members) do
            if v.team_status == 2 then
                if v.map_id == members[1].map_id then
                    local teamSprite = cc.Sprite:create(team)
                    local posX,posY = self:leftXYToSmallMap(v.pos_x, v.pos_y)
                    teamSprite:setPosition(posX, posY)
                    teamLayer:addChild(teamSprite)

                    -- 生成颜色字符串控件
                    local playName = ccui.Text:create()
                    playName:setFontSize(15)
                    playName:setColor(COLOR3.RED)
                    playName:setString(v.name)
                    playName:setPosition(posX, posY - DISTANCE_NAME_POINT)
                    teamLayer:addChild(playName)
                end
            end
        end
    else
        -- 判断队长是否与自己在同一地图上
        if MapMgr:getCurrentMapId() and TeamMgr:getLeader().map_id ~= MapMgr:getCurrentMapId() then
            return
        end

        -- Me不是队长,显示队长
        local captainFile = self:getSmallMapNPC()
        local captainSprite = cc.Sprite:create(captainFile)
        local posX, posY = self:leftXYToSmallMap(members[1].pos_x, members[1].pos_y)
        captainSprite:setPosition(posX, posY)
        teamLayer:addChild(captainSprite)

        -- 生成颜色字符串控件
        local playName = ccui.Text:create()
        playName:setFontSize(15)
        playName:setColor(COLOR3.RED)
        playName:setString(members[1].name)
        playName:setPosition(posX, posY - DISTANCE_NAME_POINT)
        teamLayer:addChild(playName)
    end
end

-- 大地图坐标转化成小地图坐标
function SmallMapDlg:mapSpaceToSmallMap(x, y)
    if nil == MapMgr.mapSize then
        local map_id = MapMgr:getCurrentMapId()
        if nil == map_id or 0 == map_id then
            return 0, 0
        end

        local info = require (ResMgr:getMapInfoPath(map_id))
        if nil == info then
            return 0, 0
        end

        local width = info.source_width or 0
        local height = info.source_height or 0

        local mapY = y / width
        local mapX = x / height

        return mapX * self.contentSize.width, mapY * self.contentSize.height
    end

    local mapY = y / MapMgr.mapSize.height
    local mapX = x / MapMgr.mapSize.width

    return mapX * self.contentSize.width, mapY * self.contentSize.height
end

-- 小地图坐标转化成左上角坐标
function SmallMapDlg:smallMapToClientSpace(x, y)
    local mapX = x / self.contentSize.width
    local mapY = y / self.contentSize.height

    return gf:convertToMapSpace(mapX * MapMgr.mapSize.width, mapY * MapMgr.mapSize.height)
end

-- 左上角坐标转化成小地图
function SmallMapDlg:leftXYToSmallMap(x, y)
    local bigMapX, bigMapY = gf:convertToClientSpace(x, y)
    return self:mapSpaceToSmallMap(bigMapX, bigMapY)
end

function SmallMapDlg:onWorldMapButton(sender, eventType)
    DlgMgr:openDlg("WorldMapDlg")
    self:onCloseButton()
end

-- NPC精灵按钮
function SmallMapDlg:onNPCListButton(sender, eventType)
    local panel = self:getControl("NPCListPanel")
    if not panel:isVisible() and MapMgr:isInHouseRoom(MapMgr:getCurrentMapName()) then
        -- 如果在居所房屋中，需要向服务器请求管家信息，数据回来后再打开npc列表
        gf:CmdToServer("CMD_ROOM_GUANJIA_INFO")
    else
        panel:setVisible(not panel:isVisible())
    end
end

function SmallMapDlg:showInNSZB(npc, type)
    return (DistMgr:isInNSZBServer() or DistMgr:isInXMZBServer()) and npc.name == CHS[2200038]
end

-- 居所管家数据刷新了
function SmallMapDlg:MSG_ROOM_GUANJIA_INFO(data)
    if MapMgr:isInHouseRoom(MapMgr:getCurrentMapName()) and data and data.name then
        -- 在居所房屋中
        self:setNPCList(data.icon)
        local panel = self:getControl("NPCListPanel")
        panel:setVisible(not panel:isVisible())
    end
end

function SmallMapDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    InnMgr:hideOrShowInnMainDlg(true)
end

return SmallMapDlg

