-- MiGongMap.lua
-- created by lixh Api/18/2018
-- 地图隐藏Me对象，点击可以拖动的地图

local Map = require("obj/Map")
local MiGongMap = class("MiGongMap", Map)

local MapInfo = require(ResMgr:getCfgPath('MapInfo.lua'))

-- 记录点击地图的位置
local lastTouchPos = nil

local PER_FRAME_LOAD_COUNT = 20 -- 定义每一帧加载地图量

function MiGongMap:init()
    self.mapType = MAP_TYPE.MIGONG_MAP

    local size = self:getContentSize()
    MiGongMapMgr:generate(size, cc.size(self.info.block_width, self.info.block_height))

    self.info.blocks = MiGongMapMgr:getBlocks(size)

    self.info.range = MiGongMapMgr:getMapRange(size)

    local curMapInfo = MapInfo[MapMgr:getCurrentMapId()]
    if curMapInfo then
        self.range = MiGongMapMgr:getMapRange(size)
        curMapInfo.range = self.range
    end
end

-- 返回当前所需要加载的总地图块
function MiGongMap:getTotalBlock()
    if MiGongMapMgr.hasWalkMapPos then
        return Map.getTotalBlock(self) + #MiGongMapMgr.hasWalkMapPos
    else
        return Map.getTotalBlock(self)
    end
end

function MiGongMap:update(now, forceUpdatePos)
    Map.update(self, now, forceUpdatePos)

    local x, y = self:getCenterCharPos()
    MiGongMapMgr:updateWallStatus(x, y)

    MiGongMapMgr:update()
end

function MiGongMap:onMap(touch, event)
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
    local newToPos = self:convertToNodeSpace(toPos)
    if eventCode == cc.EventCode.BEGAN then
        if MiGongMapMgr:checkCanMove(newToPos.x, newToPos.y) then
            Me:touchMapBegin(toPos)
            return true
        end
    elseif eventCode == cc.EventCode.MOVED then
        if MiGongMapMgr:checkCanMove(newToPos.x, newToPos.y) then
            Me:touchMapMoved(toPos)
        else
            Me:touchMapEnd(toPos)
        end
    elseif eventCode == cc.EventCode.ENDED then
        -- 设置移动的结束
        Me:touchMapEnd(toPos)
    end
end

function Map:removeInvisibleBlock()
end

return MiGongMap