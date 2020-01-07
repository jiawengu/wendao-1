-- Map.lua
-- created by cheny Nov/16/2014
-- 地图，处理障碍点、遮挡等

local ZORDER_BACK = -2
local ZORDER_OBSTACLE = -1
local FPS = 1 / 30
local EFFET_DELAY_TIME = 0.3                    -- 特效延迟时间
local UPDATE_DELAY_TIME = 0.3                   -- 更新延迟时间

local Map = class("Map", function()
    return cc.Layer:create()
end)

local CarpetLayer = require("obj/CarpetLayer")
local MapInfo = require(ResMgr:getCfgPath('MapInfo.lua'))
local LIGHT_EFFECT = require(ResMgr:getCfgPath('LightEffect.lua'))

Map.curEffectDelayTime = EFFET_DELAY_TIME
Map.curUpdateDelayTime = UPDATE_DELAY_TIME

local PER_FRAME_LOAD_COUNT = 3 -- 定义每一帧加载地图量

local TILE_INDEX = 1
local WALL_INDEX = 1

-- 由于可能地图在其他地方会复用，
-- 如果isOther 为 true 时，不对地图信息进行管理器记录
function Map:ctor(map_id, isOther)
    self.mapType = MAP_TYPE.NORMAL
    self.map_id = map_id
    self.curBlockMap = 0
    self.totalBlockMap = 0
    self.loadedBlockCount = 0

    TILE_INDEX = MapMgr:getTileIndex()
    WALL_INDEX = MapMgr:getWallIndex()

    self.info = require (ResMgr:getMapInfoPath(map_id))
    if nil == self.info then return end

    local curMapInfo = MapInfo[MapMgr:getCurrentMapId()]
    if curMapInfo then
        self.range = curMapInfo.range
        self.map_obstacle_id = curMapInfo.map_obstacle_id
        self.flipX = true == curMapInfo.flipX
    end

    -- 存储初始的地图缩放大小
    if nil == self.info.rawScale then
        self.info.rawScale = self.info.scale
    end

    local width = self.info.source_width or 0
    local height = self.info.source_height or 0
    self:setContentSize(cc.size(width * Const.MAP_SCALE, height  * Const.MAP_SCALE))

    if not isOther then
        self:loadObstacle()
        MapMgr.mapSize = self:getContentSize()
    end

    -- 地图的宽块数、高块数
    local mapWidthCell = math.ceil(width / Const.RAW_PANE_WIDTH)
    local mapHeightCell = math.ceil(height / Const.RAW_PANE_HEIGHT)

    if not isOther then
        MapMgr:setMapSize(mapWidthCell, mapHeightCell)
    end

    -- scale 为之前原图缩小的比例，除以 Const.MAP_SCALE 相当于将原图放大 Const.MAP_SCALE 被
    self.info.scale = self.info.rawScale / Const.MAP_SCALE

    if not isOther then
        gf:bindTouchListener(self, function(touch, event)
            return self:onMap(touch, event)
        end, {
            cc.Handler.EVENT_TOUCH_BEGAN,
            cc.Handler.EVENT_TOUCH_MOVED,
            cc.Handler.EVENT_TOUCH_ENDED
        }, true)
    end

    -- 初始化请求加载地图块的序列和需要加载地图块的序列
    self.requestedBlock = {}
    self.needLoadBlock = {}
    self.needLoadBlockMap = {}

    if not isOther then
        GameMgr:registFrameFunc(tostring(self), self.update, self, true)
        schedule(self, function() self:removeInvisibleBlock() end, 3)
    end

    -- 根据地图缩放比例，计算一个地图块大小，及可见范围的地图块数量
    -- 放大后一块大小
    local scale = 1 / self.info.scale
    self.bw = self.info.block_width * scale
    self.bh = self.info.block_height * scale

    -- 可见范围的块数
    self.nx = math.floor(Const.WINSIZE.width / self.bw) + 1
    self.ny = math.floor(Const.WINSIZE.height / self.bh) + 1

    -- self:processMapObjs()

    self.curEffectDelayTime = EFFET_DELAY_TIME  -- 当前特效延迟时间
    self.curUpdateDelayTime = UPDATE_DELAY_TIME -- 当前更新延迟时间

    local NODE_CLEANUP = Const.NODE_CLEANUP
    local function onNodeEvent(event)
        if NODE_CLEANUP == event then
            self:onNodeCleanup()
        end
    end

    self:registerScriptHandler(onNodeEvent)

    self:init()
end

function Map:init()
end

function Map:onNodeCleanup()
    self.requestedBlock = {}
    self.loadQueue = {}
    GameMgr:unRegistFrameFunc(tostring(self))
end

function Map:getCurPosition(x, y)
    local size = self:getContentSize()
    -- me当前位置（像素）
    local cx, cy = self:getCenterCharPos()
    x, y = x or cx, y or cy
    -- 屏幕大小的一半
    local w2 = Const.WINSIZE.width / 2
    local h2 = Const.WINSIZE.height / 2
    -- 背景相对于视窗的位置
    local bx = w2 - x
    local by = h2 - y
    -- 处理边界情况
    local x1 = self.range and self.range.x1 or 0
    local x2 = self.range and self.range.x2 or 0
    local y1 = self.range and self.range.y1 or 0
    local y2 = self.range and self.range.y2 or 0
    bx = math.min(math.max(Const.WINSIZE.width - size.width + x2, bx), - x1)
    by = math.min(math.max(Const.WINSIZE.height - size.height + y1, by), - y2)

    return bx, by
end

-- 创建地图缩略图
function Map:createThumbnail(cx, cy)
    self:destroyThumbnail()

    local x, y = self:getCurPosition(cx, cy)
    x, y = -x, -y

    local filePath = self:getSmallMapFile(self.map_id)
    if not cc.FileUtils:getInstance():isFileExist(filePath) then return end
    self.thumbnail = cc.Sprite:create(filePath)
    if not self.thumbnail then return end
    local size = self:getContentSize()
    local tsize = self.thumbnail:getContentSize()
    local sx, sy = size.width / tsize.width, size.height / tsize.height

    local rect = cc.rect(x / sx, tsize.height - self.bh * self.ny / sy - y / sy, self.bw * self.nx / sx, self.bh * self.ny / sy )
    self.thumbnail:setTextureRect(rect)
    self.thumbnail:setAnchorPoint(0, 0)
    self.thumbnail:setPosition(x, y)
    self.thumbnail:setScale(sx, sy)
    self:addChild(self.thumbnail)
    return self.thumbnail
end

-- 销毁地图缩略图
function Map:destroyThumbnail()
    if not self.thumbnail then return end
    self.thumbnail:removeFromParent()
    self.thumbnail = nil
end

-- 获取小地图文件
function Map:getSmallMapFile(map_id, floor_index, wall_index)
    if floor_index and wall_index then
        return string.format("maps/smallMaps/%05d_%02d_%02d.jpg", map_id, floor_index, wall_index)
    else
        return string.format("maps/smallMaps/%05d.jpg", map_id)
    end
end

function Map:processMapObjs()
    if not self.info or not self.info.objs then return end
    self.xy2objs = {}
    for k = 1, #self.info.objs do
        local ob = self.info.objs[k]
        local xbegin = math.floor(ob.x / self.bw)
        local ybegin = math.floor(ob.y / self.bh)
        local xend = math.floor((ob.x + ob.w) / self.bw + 0.5)
        local yend = math.floor((ob.y + ob.h) / self.bh + 0.5)
        for i = ybegin, yend do
            if not self.xy2objs[i] then self.xy2objs[i] = {} end
            for j = xbegin, xend do
                if not self.xy2objs[i][j] then self.xy2objs[i][j] = {} end
                    table.insert(self.xy2objs[i][j], ob)
            end
        end
    end
end

function Map:setLoadCountPerFrame(count)
    PER_FRAME_LOAD_COUNT = count
end

function Map:getTileIndex()
    return TILE_INDEX
end

function Map:getWallIndex()
    return WALL_INDEX
end

-- 设置地表索引，用于更换地表方案
function Map:setTileIndex(index)
    if TILE_INDEX ~= index then
        TILE_INDEX = index
        self:unloadBlocks()
        self.loadAll = nil
        self:loadBlocksByMyPos(true, true, true)
    end
end

-- 设置墙壁索引
function Map:setWallIndex(index, isPreview)
    if WALL_INDEX ~= index then
        WALL_INDEX = index
        self:unloadWalls()
        self.loadAll = nil
        self:loadBlocksByMyPos(true, true, true)
    end

    if isPreview then
        -- 预览时不更新地图障碍点，暂时只在居所围墙预览时使用
        return
    end

    if self.obstacle then
        self.shelterLayer = self.obstacle:getLayer(string.format("shelter%d", WALL_INDEX))
        local changeShelter = true
        if not self.shelterLayer then
            self.shelterLayer = self.obstacle:getLayer("shelter")
            changeShelter = nil
        end

        if changeShelter then
            EventDispatcher:dispatchEvent("Shelter_changed")
        end
    end
end

-- 卸载当前地图块
function Map:unloadBlocks()
    local children = self:getChildren()
    local name, x, y
    for _, v in pairs(children) do
        if v ~= self.obstacle then
            name = v:getName()
            x, y = string.match(name, "(-?%d+)_(-?%d+)")
            if x ~= nil and y ~= nil then
                x = tonumber(x)
                y = tonumber(y)

                v:removeFromParent()
                --MapMagicMgr:removeCurZoneMagic(x, y, x + bw, y + bh)
            end
        end
    end

    -- gf:getMapObjLayer():removeAllChildren()
    children = gf:getMapObjLayer():getChildren()
    for _, v in pairs(children) do
        if v and string.match(v:getName(), "o:.*") then
            v:removeFromParent()
        end
    end

    self.requestedBlock = {}
    self.loadQueue = {}
    self.needLoadBlock = {}
    self.needLoadBlockMap = {}
    self.lastX = nil
    self.lastY = nil
end

function Map:unloadWalls()
    local children = gf:getMapObjLayer():getChildren()
    for _, v in pairs(children) do
        if v and string.match(v:getName(), "w:.*") then
            v:removeFromParent()
        end
    end

    self.requestedBlock = {}
    self.needLoadBlock = {}
    self.needLoadBlockMap = {}
    self.lastX = nil
    self.lastY = nil
end

function Map:onMap(touch, event)
    if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() then
        -- 已经在退出的流程了
        return
    end

    -- 如果不能移动
    if not Me:isControlMove() then return end

    -- 如果在战斗中/加载中
    if Me:isInCombat() or not MapMgr.isLoadEnd then return end

    local toPos = touch:getLocation()
    local eventCode = event:getEventCode()
    if eventCode == cc.EventCode.BEGAN then
        if MapMgr:isInYuLuXianChi() and WenQuanMgr:isInThrowSoap() then
            WenQuanMgr:mePlayThrowSoap(toPos)
            return
        end

        Me:touchMapBegin(toPos)
        return true
    elseif eventCode == cc.EventCode.MOVED then
        Me:touchMapMoved(toPos)
    elseif eventCode == cc.EventCode.ENDED then
        -- 设置移动的结束
        Me:touchMapEnd(toPos)
    end
end

function Map:removeInvisibleBlock()
    local bw = self.info.block_width
    local bh = self.info.block_height
    local xbegin, xend, ybegin, yend = self:getVisibleArea()
    if self.loadAll or self.mapType == MAP_TYPE.DRAG_MAP then
        -- 已经全部加载，无需处理
        return
    end
    xbegin = xbegin * bw
    xend = xend * bw
    ybegin = ybegin * bh
    yend = yend * bh

    local children = self:getChildren()
    local name, x, y
    -- local visRect = cc.rect(xbegin, ybegin, xend - xbegin, yend - ybegin)
    for _, v in pairs(children) do
        if v ~= self.obstacle then
            name = v:getName()
            x, y = string.match(name, "(-?%d+)_(-?%d+)")
            if x ~= nil and y ~= nil then
                x = tonumber(x)
                y = tonumber(y)

                -- if not cc.rectIntersectsRect(cc.rect(x, y, self.info.block_width, self.info.block_height), visRect) then
                if x >= xend or y >= yend or x + self.info.block_width <= xbegin or y + self.info.block_height <= ybegin then
                    v:removeFromParent()
                    MapMagicMgr:removeCurZoneMagic(x, y, x + bw, y + bh)
                end
            end
        end
    end

    -- 移除光效层
    children = gf:getMapObjLayer():getChildren()
    local st, size
    for _, v in pairs(children) do
        name = v:getName()
        size = v:getContentSize()
        st = gf:split(name, "_")
        if st and 3 == #st then
            x, y = tonumber(st[2]), tonumber(st[3])
        else
            x, y = nil, nil
        end

        if x ~= nil and y ~= nil then
            -- if not cc.rectIntersectsRect(cc.rect(x, y, size.width, size.height), visRect) then
            if x >= xend or y >= yend or x + size.width <= xbegin or y + size.height <= ybegin then
                v:removeFromParent()
            end
        end
    end
end

-- 设置以 Id 角色为中心视角，未设置默认使用 Me
function Map:setCenterChar(id)
    self.centerCharId = id
end

-- 判断是否可移动地图
function Map:canMoveMap(forceUpdatePos)
    if self.centerCharId then
        local char = CharMgr:getCharById(self.centerCharId)
        if char then
            return true
        end
    end

    if not Me:isFixedView() and not Me:isInCombat() and not Me:isLookOn() or forceUpdatePos then
        return true
    end
end

-- 判断是否需要加载地图
function Map:canLoadBlocks()
    if self.centerCharId then
        local char = CharMgr:getCharById(self.centerCharId)
        if char then
            if self.lastX == char.curX and self.lastY == char.curY then
                -- 没有移动不需要加载地图
                return false
            else
                return true
            end
        end
    end

    -- 判断Me有没有移动，没有移动不需要加载地图
    -- 刚从战斗中出来需要加载地图
    if not Me.isFightJustNow then
        if self.lastX == Me.curX and self.lastY == Me.curY then
            return false
        end
    else
        Me.isFightJustNow = false
    end

    return true
end

-- 获取中心视角的角色的位置
function Map:getCenterCharPos()
    if self.centerCharId then
        local char = CharMgr:getCharById(self.centerCharId)
        if char then
            return char.curX, char.curY
        end
    end

    return Me.curX, Me.curY
end

function Map:update(now, forceUpdatePos)
    if self.obstacleDirty then
        self.obstacle:removeFromParent()
        self.obstacle = nil
        self:loadObstacle()
        EventDispatcher:dispatchEvent(EVENT.RELOAD_OBSTACLE)
        self.obstacleDirty = nil
    end

    -- 判断是否鼠标点击移动
    if Me.isMoved and Me.toPos then

        self.curUpdateDelayTime  = self.curUpdateDelayTime +  1 / Const.FPS

        if self.curUpdateDelayTime >= UPDATE_DELAY_TIME then
            local toPos = self:convertToNodeSpace(Me.toPos)
            Me:setEndPos(gf:convertToMapSpace(toPos.x, toPos.y))
            self.curUpdateDelayTime = self.curUpdateDelayTime - UPDATE_DELAY_TIME
        end

        self.curEffectDelayTime  = self.curEffectDelayTime + 1 / Const.FPS

        if  self.curEffectDelayTime >= EFFET_DELAY_TIME then
            self:addClickMagicToMap(Me.toPos)
            self.curEffectDelayTime = self.curEffectDelayTime - EFFET_DELAY_TIME
        end

        -- 预防界面不显示
        DlgMgr:preventDlg()

    else
    --  Me:setAct(Const.SA_STAND)
    end

    if self:canMoveMap(forceUpdatePos) then
        local size = self:getContentSize()
        -- me当前位置（像素）
        local x, y = self:getCenterCharPos()
        -- 屏幕大小的一半
        local w2 = Const.WINSIZE.width / 2
        local h2 = Const.WINSIZE.height / 2
        -- 背景相对于视窗的位置
        local bx = w2 - x
        local by = h2 - y
        -- 处理边界情况
        local x1 = self.range and self.range.x1 or 0
        local x2 = self.range and self.range.x2 or 0
        local y1 = self.range and self.range.y1 or 0
        local y2 = self.range and self.range.y2 or 0
        bx = math.min(math.max(Const.WINSIZE.width - size.width + x2, bx), - x1)
        by = math.min(math.max(Const.WINSIZE.height - size.height + y1, by), - y2)
        gf:getMapLayer():setPosition(bx, by)
        gf:getCharLayer():setPosition(bx, by)
        gf:getWeatherLayer():setPosition(bx, by)
    end

    -- 检测是否要更新地图
    self:loadBlocksByMyPos(true, now)

    -- 限制每一帧加载固定的数量的地图
    local frameLoadCount = math.min(PER_FRAME_LOAD_COUNT, #self.needLoadBlock)
    for i = 1, frameLoadCount do
        local mapData = self:popUnLoadBlock()

        if mapData then
            if mapData.name then
                self:doLoadBlock(mapData.x, mapData.y, false, mapData.name, mapData.w, mapData.h, mapData.z, mapData.flip)
            else
                self:doLoadBlock(mapData.x, mapData.y, false, nil, mapData.w, mapData.h, mapData.z)
            end
        end
    end
end

-- 设置地图位置
function Map:setCurMapPos(x, y, now)
    local size = self:getContentSize()

    -- 屏幕大小的一半
    local w2 = Const.WINSIZE.width / 2
    local h2 = Const.WINSIZE.height / 2

    -- 背景相对于视窗的位置
    local bx = w2 - x
    local by = h2 - y

    -- 处理边界情况
    bx = math.min(math.max(Const.WINSIZE.width - size.width, bx), 0)
    by = math.min(math.max(Const.WINSIZE.height - size.height, by), 0)
    gf:getMapLayer():setPosition(bx, by)
    gf:getCharLayer():setPosition(bx, by)
    gf:getWeatherLayer():setPosition(bx, by)

    if self.firstFrame then
        self:loadBlocksByMyPos(true, now)
        self.firstFrame = false
    else
        self:loadBlocksByMyPos(false)
    end
end

-- 计算可视范围，返回xbegin, xend, ybegin, yend
function Map:getVisibleArea(loadAll)
    if self.info and self.info.blocks and (loadAll or self.loadAll) then
        return 0, math.floor(self:getContentSize().width / self.bw), 0, math.floor(self:getContentSize().height / self.bh)
    end

    -- 换算地图块起始位置（左上角为坐标原点）
    local size = self:getContentSize()
    local x, y = gf:getMapLayer():getPosition()

    x = -x
    if self.flipX then
        -- 将坐标转换为距右边界的距离
        x = size.width - x - Const.WINSIZE.width
    end

    y = size.height + y - Const.WINSIZE.height

    -- 起始块编号和结束块编号
    local xbegin = math.floor(x / self.bw)
    local ybegin = math.floor(y / self.bh)

    local xend = xbegin + self.nx + 1
    local yend = ybegin + self.ny + 1

    --xbegin = xbegin - 1
    --ybegin = ybegin - 1

    xbegin = xbegin - 1
    ybegin = ybegin - 1

    if xbegin < 0 then xbegin = 0 end
    if ybegin < 0 then ybegin = 0 end

    return xbegin, xend, ybegin, yend
end

-- 获取一个未加载过的地图块
function Map:popUnLoadBlock()
    -- for k, v in pairs(self.needLoadBlock) do
    repeat
        local mapData = table.remove(self.needLoadBlock, 1)
        if mapData then
            self.needLoadBlockMap[string.format("%d_%d_%s", mapData.x, mapData.y, tostring(mapData.name))] = nil
            if (mapData.name and self:checkMapObjCanLoad(mapData.name, mapData.y, mapData.w, mapData.h)) or self:checkMapCanLoad(mapData.x, mapData.y, mapData.w, mapData.h) then
                return mapData
            end
            self.loadedBlockCount = self.loadedBlockCount + 1
            self.totalBlockMap = self.curBlockMap +  self.loadedBlockCount
        end
    until #self.needLoadBlock <= 0
end

-- 返回当前所需要加载的总地图块
function Map:getTotalBlock()
    --[[local xbegin, xend, ybegin, yend = self:getVisibleArea()
    return (xend - xbegin + 1) * (yend - ybegin + 1)
    --]]
    return self.totalBlockMap + #self.needLoadBlock
end

-- 返回当前加载地图块数量
function Map:getCurBlock()
    return self.curBlockMap + self.loadedBlockCount
end

-- 当前视野内地图是否加载完成
function Map:isCurSightLoadOver()
    local curLoadNum = self:getCurBlock()
    local totalLoadNum = self:getTotalBlock()
    return curLoadNum > 0 and curLoadNum >= totalLoadNum
end

-- 根据Me当前的位置加载周围的地图
function Map:loadBlocksByMyPos(syncLoad, firstEnterRoom, loadAll)
    if self.loadAll then return end

    if not self:canLoadBlocks() and not loadAll then
        return
    end

    self.lastX, self.lastY = self:getCenterCharPos()

    local xbegin, xend, ybegin, yend = self:getVisibleArea(loadAll)
    self.loadAll = loadAll
    local count = 0

    --- todo
    if firstEnterRoom then
        for i = xbegin, xend, 1 do
            for j = ybegin, yend, 1 do
                self:doLoadBlock(i * self.info.block_width, j * self.info.block_height, syncLoad)
            end
        end

        if self.info.blocks then
            for i = xbegin - 0.5, xend + 0.5, 1 do
                for j = ybegin - 0.5, yend + 0.5, 1 do
                    self:doLoadBlock(i * self.info.block_width, j * self.info.block_height, syncLoad)
                end
            end
        end

        -- 地图物件
        if self.info and self.info.objs and #(self.info.objs) > 0 then
            -- 存在地图物件信息
            local mapObjs = self.info.objs
            --local rect1 = cc.rect(xbegin * self.info.block_width, ybegin * self.info.block_height, (xend - xbegin) * self.info.block_width, (yend - ybegin) * self.info.block_height)
            --local rect2
            local o
            for i = 1, #mapObjs do
                o = mapObjs[i]
                if self:checkMapObjCanLoad(o.name, o.x, o.y, o.w, o.h) then
                    --rect2 = cc.rect(o.x, o.y, o.w, o.h)
                    --if cc.rectIntersectsRect(rect1, rect2) then
                    if not (o.x >= xend * self.info.block_width or o.y >= yend * self.info.block_height or (o.x + o.w) <= xbegin * self.info.block_width or (o.y + o.h) <= ybegin * self.info.block_height) then
                        local tempData = {}
                        tempData.name = o.name
                        tempData.x = o.x
                        tempData.y = o.y
                        tempData.z = 1000 + (o.z or (#mapObjs - i + 1))
                        tempData.w = o.w
                        tempData.h = o.h
                        tempData.syncLoad = syncLoad
                        tempData.loaded = false
                        tempData.flip = o.flip

                        self:doLoadBlock(tempData.x, tempData.y, syncLoad, tempData.name, tempData.w, tempData.h, tempData.z, tempData.flip)
                    end
                end
            end
        end
    else
        -- 如果是移动中更新地图，先保存下来
        for i = xbegin, xend, 1 do
            for j = ybegin, yend, 1 do
                local tempData = {}
                tempData.x = i * self.info.block_width
                tempData.y = j * self.info.block_height
                tempData.syncLoad = syncLoad
                tempData.loaded = false

                if self:checkMapCanLoad(tempData.x, tempData.y) then
                    table.insert(self.needLoadBlock, tempData)
                    self.needLoadBlockMap[string.format("%d_%d_%s", tempData.x, tempData.y, tostring(tempData.name))] = 1
                end
            end
        end

        if self.info.blocks then
            for i = xbegin - 0.5, xend + 0.5, 1 do
                for j = ybegin - 0.5, yend + 0.5, 1 do
                    local tempData = {}
                    tempData.x = i * self.info.block_width
                    tempData.y = j * self.info.block_height
                    tempData.syncLoad = syncLoad
                    tempData.loaded = false

                    if self:checkMapCanLoad(tempData.x, tempData.y, tempData.w, tempData.h) then
                        table.insert(self.needLoadBlock, tempData)
                        self.needLoadBlockMap[string.format("%d_%d_%s", tempData.x, tempData.y, tostring(tempData.name))] = 1
                    end
                end
            end
        end

        -- 地图物件
        if self.info and self.info.objs and #(self.info.objs) > 0 then
            -- 存在地图物件信息
            local mapObjs = self.info.objs
            --local rect1 = cc.rect(xbegin * self.info.block_width, ybegin * self.info.block_height, (xend - xbegin) * self.info.block_width, (yend - ybegin) * self.info.block_height)
            --local rect2
            local o
            for i = 1, #mapObjs do
                o = mapObjs[i]
                if self:checkMapObjCanLoad(o.name, o.x, o.y, o.w, o.h) then
                    --rect2 = cc.rect(o.x, o.y, o.w, o.h)
                    --if cc.rectIntersectsRect(rect1, rect2) then
                    if not (o.x >= xend * self.info.block_width or o.y >= yend * self.info.block_height or (o.x + o.w) <= xbegin * self.info.block_width or (o.y + o.h) <= ybegin * self.info.block_height) then
                        local tempData = {}
                        tempData.name = o.name
                        tempData.x = o.x
                        tempData.y = o.y
                        -- tempData.z = 1000 + (#mapObjs - i + 1)
                        tempData.z = 1000 + (o.z or (#mapObjs - i + 1))
                        tempData.w = o.w
                        tempData.h = o.h
                        -- tempData.z = 1000 + i
                        tempData.syncLoad = syncLoad
                        tempData.loaded = false
                        tempData.flip = o.flip
                        table.insert(self.needLoadBlock, tempData)
                        self.needLoadBlockMap[string.format("%d_%d_%s", tempData.x, tempData.y, tostring(tempData.name))] = 1
                    end
                end
            end
        end
    end
end

function Map:checkMapCanLoad(x, y, w, h)

    -- 超出范围，无法加载
    w = w or self.info.block_width
    h = h or self.info.block_height
    local xbegin, xend, ybegin, yend = self:getVisibleArea()
    local bw = self.info.block_width
    local bh = self.info.block_height
    xbegin = xbegin * bw
    xend = xend * bw
    ybegin = ybegin * bh
    yend = yend * bh

    --[[
    local visRect = cc.rect(xbegin, ybegin, xend - xbegin, yend - ybegin)
    local rc = cc.rect(x, y, w, h)

    local rect = cc.rectIntersection(rc, visRect)
    if rect.width <= 0 or rect.height <= 0 then
        return false
    end

    rect = cc.rectIntersection(rc, cc.rect(0, 0, self.info.new_width, self.info.new_height))
    if rect.width <= 0 or rect.height <= 0 then
        return false
    end
    ]]

    if x >= xend or y >= yend or x + w <= xbegin or y + h <= ybegin then return false end
    if x >= self.info.new_width or y >= self.info.new_height or x + w <= 0 or y + h <= 0 then return false end

    local name = string.format("%d_%d", x, y)

    -- 如果已经加载了该块，不重复加载
    if nil ~= self:getChildByName(name) then
        return false
    end

    -- 该块如果有请求了，不重复请求
    if self.requestedBlock[name] == 1 then
        return false
    end

    if self.needLoadBlockMap[string.format("%d_%d_%s", x, y, tostring(nil))] then
        return false
    end

    return true
end

function Map:checkMapObjCanLoad(name, x, y, w, h)
    -- 超出范围，无法加载
    w = w or self.info.block_width
    h = h or self.info.block_height
    local bw = self.info.block_width
    local bh = self.info.block_height
    local xbegin, xend, ybegin, yend = self:getVisibleArea()
    xbegin = xbegin * bw
    xend = xend * bw
    ybegin = ybegin * bh
    yend = yend * bh

    --[[
    local rc = cc.rect(x, y, w, h)
    local visRect = cc.rect(xbegin, ybegin, xend - xbegin, yend - ybegin)
    if not cc.rectIntersectsRect(rc, visRect) then
        return false
    end]]

    --[[
    if not cc.rectIntersectsRect(rc, cc.rect(0, 0, self.info.new_width, self.info.new_height)) then
        return false
    end
    ]]

    if x >= xend or y >= yend or x + w <= xbegin or y + h <= ybegin then return false end

    local name = string.format("%s_%d_%d", name, x, y)

    -- 如果已经加载了该块，不重复加载
    if nil ~= gf:getMapObjLayer():getChildByName(name) then
        return false
    end

    -- 该块如果有请求了，不重复请求
    if self.requestedBlock[name] == 1 then
        return false
    end

    if self.needLoadBlockMap[string.format("%d_%d_%s", x, y, tostring(name))] then
        return false
    end

    return true
end

-- 根据x,y的位置加载周围的地图
function Map:loadBlocksByPos(syncLoad, x, y)
    self.lastX, self.lastY = x, y

    local xbegin, xend, ybegin, yend = self:getVisibleArea()
    local count = 0
    -- 同步/异步载入
    for i = xbegin, xend, 1 do
        for j = ybegin, yend, 1 do
            self:doLoadBlock(i* self.info.block_width, j*self.info.block_height, syncLoad)
        end
    end
end

-- 整张地图加载进来
function Map:loadAllBlocks()
    local bw = self.info.block_width
    local bh = self.info.block_height
    local mapW = math.ceil(self.info.new_width / bw) - 1
    local mapH = math.ceil(self.info.new_height / bh) - 1
    for x = 0, mapW do
        for y = 0, mapH do
            self:doLoadBlock(x * bw, y * bh)
        end
    end
end

function Map:flipLayer(layerData)
    if not self.flipX or not layerData then return layerData end

    local oriLayer = {}
    local size = layerData:getLayerSize()
    for j = 1, size.height do
        for i = 1, size.width do
            local v, _ = layerData:getTileGIDAt(cc.p(i - 1, j - 1))
            table.insert(oriLayer, v)
        end
    end

    local ix, iy
    for j = 1, size.height do
        for i = 1, size.width do
            if self.flipX then ix = size.width - i + 1 else ix = i end
            iy = j
            layerData:setTileGID(oriLayer[ix + (iy - 1) * size.width], cc.p(i - 1, j - 1))
        end
    end

    return layerData
end

-- 加载障碍点
function Map:loadObstacle()
    local path = ResMgr:getMapObstaclePath(self.map_id)
    if self.map_obstacle_id then
        path = ResMgr:getMapObstaclePath(self.map_obstacle_id)
    end

    local obstacle = ccexp.TMXTiledMap:create(path)
    if nil == obstacle then return end

    self.obstacle = obstacle
    self.obstacleLayer = self:flipLayer(obstacle:getLayer("obstacle"))
    self.shelterLayer = self:flipLayer(obstacle:getLayer(string.format("shelter%d", WALL_INDEX)))
    if not self.shelterLayer then
        self.shelterLayer = self:flipLayer(obstacle:getLayer("shelter"))
    end
    self.leftWall = obstacle:getLayer("L-wall")
    if self.leftWall then self.leftWall:setVisible(false) end
    self.rightWall = obstacle:getLayer("R-wall")
    if self.rightWall then self.rightWall:setVisible(false) end
    self.floor = obstacle:getLayer("floor")
    if self.floor then
        self.floor:setVisible(false)
        -- 使用地板层生成地毯层
        self.carpet = CarpetLayer.new(self.floor)
    end

    self:addChild(obstacle,ZORDER_OBSTACLE)
    GObstacle:Instance():Create(tolua.cast(obstacle, "experimental::TMXTiledMap"))
    obstacle:setVisible(false)
    obstacle:setScale(Const.MAP_SCALE)
end

-- 标记障碍信息
function Map:markObstacleDirty()
    self.obstacleDirty = true
end

-- 是否是有效的位置
function Map:isValidPos(mapX, mapY)
    if not self.obstacle then
        return
    end

    local mapSize = self.obstacle:getMapSize()
    if mapX < mapSize.width and mapX >= 0 and
        mapY < mapSize.height and mapY >= 0 then
        return true
    end
end

-- 是否遮挡点
function Map:isShelter(mapX, mapY)
    if nil == self.shelterLayer then return end
    if nil == self.obstacle then return end

    if not self:isValidPos(mapX, mapY) then
        -- 如果出现这种情况，默认为没有遮挡
        return false
    end

    return self.shelterLayer:getTileGIDAt(cc.p(mapX, mapY)) ~= 0
end

-- 是否被标记
function Map:isMarkable(name, x, y)
    if 'wall' == name then
        return self:isMarkable('leftWall') or self:isMarkable('rightWall')
    end

    if not self[name] then return end

    if not self:isValidPos(x, y) then return end

    return self[name]:getTileGIDAt(cc.p(x, y)) ~= 0
end

-- 标记Layer
function Map:markLayer(name, x, y, value)
    if not self[name] then return end
    if not self:isValidPos(x, y) then return end

    value = value or 1

    self[name]:setTileGID(value, cc.p(x, y))
end

-- 取消标记Layer
function Map:unMarkLayer(name, x, y, value)
    if not self[name] then return end
    if not self:isValidPos(x, y) then return end

    value = value or 0

    local curValue = self[name]:getTileGIDAt(cc.p(x, y))
    self[name]:setTileGID(0, cc.p(x, y))
end

-- 更新障碍信息
function Map:updateObstacle()
    if not self.obstacle then return end

    GObstacle:Instance():Create(tolua.cast(self.obstacle, "experimental::TMXTiledMap"))
end

-- 异步加载地图块
function Map:doLoadBlock(x, y, syncLoad, o_name, w, h, z, flip)
    local bw = self.info.block_width
    local bh = self.info.block_height

    -- 超出范围，无法加载
    w = w or self.info.block_width
    h = h or self.info.block_height
    local rect = cc.rectIntersection(cc.rect(x, y, w, h), cc.rect(0, 0, self.info.new_width, self.info.new_height))
    if rect.width <= 0 or rect.height <= 0 then
        return
    end

    local name = o_name and string.format("%s_%d_%d", o_name, x, y) or string.format("%d_%d", x, y)

    -- 如果已经加载了该块，不重复加载
    if (o_name and nil ~= gf:getMapObjLayer():getChildByName(name)) or nil ~= self:getChildByName(name) then
        self.loadedBlockCount = self.loadedBlockCount + 1
        self.totalBlockMap = self.curBlockMap +  self.loadedBlockCount
        return
    end

    -- 该块如果有请求了，不重复请求
    if self.requestedBlock[name] == 1 then
        self.loadedBlockCount = self.loadedBlockCount + 1
        self.totalBlockMap = self.curBlockMap +  self.loadedBlockCount
        return
    end

    -- 获取路径
    local path
    if o_name then
        path = ResMgr:getMapBlockPathByName(self.map_id, o_name, TILE_INDEX, WALL_INDEX)
    elseif self.info and self.info.blocks then
        if not self.info.blocks[name] then return end
        path = ResMgr:getMapBlockPathByName(self.map_id, self.info.blocks[name], TILE_INDEX, WALL_INDEX)
    else
        path = ResMgr:getMapBlockPath(self.map_id, x, y)
    end
    local size = self:getContentSize()

    -- 根据放大后大小确定位置
    local scale = 1 / self.info.scale
    x = x * scale
    y = y * scale

    -- 标记已请求
    self.requestedBlock[name] = 1

    local function loadCallback(texture)
        if nil == texture then return end
        if self.requestedBlock then
            if not self.requestedBlock[name] then return end    --  已经不需要继续处理了
            self.requestedBlock[name] = nil
        end

        local sprite = cc.Sprite:createWithTexture(texture)
        local anchorPointX, anchorPointY = 0, 1
        if self.flipX then
            anchorPointX = 1
            x = size.width - x
        end

        sprite:setAnchorPoint(cc.p(anchorPointX, anchorPointY))
        sprite:setPosition(x, size.height - y)
        sprite:setScale(scale)
        sprite:setName(name)
        if flip or self.flipX then
            sprite:setFlippedX(true)
        end

        if z then
            self:setLocalZOrder(z)
        end
        if o_name then
            gf:getMapObjLayer():addChild(sprite, z)
        else
            self:addChild(sprite, ZORDER_BACK)
        end

        -- 当前加载地图块计算
        if self.curBlockMap == nil then self.curBlockMap = 0 end

        self.curBlockMap = self.curBlockMap + 1

        if not o_name then
            -- 地图块
            MapMagicMgr:showCurZoneMagic(x, y, x + bw, y + bh)
            MapMagicMgr:showCurZoneStaticMagic(x, y, x + bw, y + bh)
        end
    end

    self.totalBlockMap = self.totalBlockMap + 1

    if syncLoad then
        -- 同步加载
        loadCallback(cc.Director:getInstance():getTextureCache():addImage(path))
    else
        -- 异步加载
        if not self.loadQueue then
            self.loadQueue = {}
        end
        if not self.loadQueue[path] then
            self.loadQueue[path] = {}
        end

        table.insert(self.loadQueue[path], loadCallback)
        if #(self.loadQueue[path]) > 1 then return end

        local function _loadCallback(texture)
            if not self.loadQueue then
                return
            end
            if nil == texture then return end
            if self.requestedBlock then
                if not self.requestedBlock[name] then return end    --  已经不需要继续处理了
            end

            local queues = self.loadQueue[path]
            self.loadQueue[path] = nil
            if not queues or #queues <= 0 then return end
            local func
            for i = 1, #queues do
                func = queues[i]
                if func then func(texture) end
            end
        end

        TextureMgr:loadAsync(LOAD_TYPE.MAP, path, _loadCallback, nil, function(path)
            return self.requestedBlock and nil ~= self.requestedBlock[name]
        end)
    end
end

function Map:addMapMagic()
    local bw = self.info.block_width
    local bh = self.info.block_height
    local xbegin, xend, ybegin, yend = self:getVisibleArea()
    xbegin = xbegin * bw
    xend = xend * bw
    ybegin = ybegin * bh
    yend = yend * bh

    local children = self:getChildren()
    local name, x, y
    for _, v in pairs(children) do
        if v ~= self.obstacle then
            name = v:getName()
            x, y = string.match(name, "(%d+)_(%d+)")
            if x ~= nil and y ~= nil then
                x = tonumber(x)
                y = tonumber(y)
                if x >= xbegin or x <= xend or
                    y >= ybegin or y <= yend then
                    MapMagicMgr:showCurZoneMagic(x, y, x + bw, y + bh)
                end
            end
        end
    end
end

function Map:removeMapMagic()
    local bw = self.info.block_width
    local bh = self.info.block_height

    local children = self:getChildren()
    local name, x, y
    for _, v in pairs(children) do
        if v ~= self.obstacle then
            name = v:getName()
            x, y = string.match(name, "(%d+)_(%d+)")
            if x ~= nil and y ~= nil then
                x = tonumber(x)
                y = tonumber(y)
                MapMagicMgr:removeCurZoneMagic(x, y, x + bw, y + bh)
            end
        end
    end
end

function Map:addMapStaticMagic()
    local bw = self.info.block_width
    local bh = self.info.block_height

    local children = self:getChildren()
    local name, x, y
    for _, v in pairs(children) do
        if v ~= self.obstacle then
            name = v:getName()
            x, y = string.match(name, "(%d+)_(%d+)")
            if x ~= nil and y ~= nil then
                x = tonumber(x)
                y = tonumber(y)
                MapMagicMgr:showCurZoneStaticMagic(x, y, x + bw, y + bh)
            end
        end
    end
end

-- 播放点击地图光效
function Map:addClickMagicToMap(toPos)
    local icon = ResMgr.magic.walk_pos_effect
    local extraPara = nil
    if MapMgr:isInYuLuXianChi() then
        local toPos = self:convertToNodeSpace(Me.toPos)
        if GObstacle:Instance():IsObstacle(gf:convertToMapSpace(toPos.x, toPos.y)) then
            icon = ResMgr.magic.walk_pos_effect
        else
            icon = ResMgr.magic.swim_pos_effect
            extraPara = {blendMode = "add"}
        end
    end

    local magic = gf:createSelfRemoveMagic(icon, extraPara)
    local toPos = self:convertToNodeSpace(toPos)
    magic:setPosition(toPos)
    gf:getMapEffectLayer():addChild(magic, 1)
end

-- 在地图上播放光效
function Map:addMagicToMap(key, toPos, dir, extraPara, actionName)
    local effect = LIGHT_EFFECT[key]
    local armatureType = effect and effect.armatureType
    local icon = effect and effect.icon
    local extraPara = extraPara and effect.extraPara
    local magic
    if not armatureType or armatureType == 0 then
        magic = gf:createSelfRemoveMagic(icon, extraPara)
    else
        if LIGHT_EFFECT[icon] and LIGHT_EFFECT[icon]["action"] and dir then
            -- 如果骨骼动画已经配置了动作名，则使用配置的
            actionName = LIGHT_EFFECT[icon]["action"][dir]
        end

        if not actionName then
            actionName = "Top"
            if LIGHT_EFFECT[icon] and LIGHT_EFFECT[icon]["behind"] then
                actionName = "Bottom"
            end
        end

        magic = ArmatureMgr:createArmatureByType(armatureType, icon, actionName)

        -- 仅播一次的骨骼动画
        ArmatureMgr:setArmaturePlayOnce(magic, actionName)
    end

    magic:setPosition(toPos)
    gf:getMapEffectLayer():addChild(magic, 1)
end

-- 重置定时器延迟时间
function Map:resetDelayTime()
    self.curEffectDelayTime = EFFET_DELAY_TIME
    self.curUpdateDelayTime = UPDATE_DELAY_TIME
end

return Map
