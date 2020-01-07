-- DragMap.lua
-- created by lixh Api/18/2018
-- 地图隐藏Me对象，点击可以拖动的地图

local Map = require("obj/Map")
local DragMap = class("DragMap", Map)

-- 记录点击地图的位置
local lastTouchPos = nil

local MAP_MOVE_SPEED = 1

local RATE = 0.8

function DragMap:init()
    self.mapType = MAP_TYPE.DRAG_MAP
    self.drapEnanled = true
end

function DragMap:setDrapEnabled(flag)
    self.drapEnanled = flag
end

function DragMap:isCanDrap()
    return self.drapEnanled
end

function DragMap:onMap(touch, event)
    if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() then
        -- 已经在退出的流程了
        return
    end

    local eventCode = event:getEventCode()
    if eventCode == cc.EventCode.BEGAN then
        if not self:isCanDrap() then
            return false
        end

        lastTouchPos = touch:getLocation()
        return true
    elseif eventCode == cc.EventCode.MOVED or eventCode == cc.EventCode.ENDED then
        if not lastTouchPos then return end
        local movePos = touch:getLocation()
        local offsetX, offsetY = movePos.x - lastTouchPos.x, movePos.y - lastTouchPos.y
        -- 拖动的方向与地图需要移动的方向相反
        self:setMeCurPosByOffset(-offsetX * RATE, -offsetY * RATE)

        lastTouchPos = movePos

        if eventCode == cc.EventCode.ENDED then
            self.lastTouchPos = nil
        end
    end
end

-- 设置Me的位置, map:update根据Me.curX,Me.curY更新地图位置
function DragMap:setMeCurPosByOffset(offsetX, offsetY)
    local targetX = math.max(math.min(Me.curX + offsetX, self.info.source_width - Const.WINSIZE.width / 2), Const.WINSIZE.width / 2)
    local targetY = math.max(math.min(Me.curY + offsetY, self.info.source_height - Const.WINSIZE.height / 2), Const.WINSIZE.height / 2)
    Me.curX = targetX
    Me.curY = targetY
end

function DragMap:onNodeCleanup()
    GameMgr:unRegistFrameFunc(FRAME_FUNC_TAG.DRAPMAP_MOVE_TO_UPDATA)
    Map.onNodeCleanup(self)
end

function DragMap:moveTo(x, y, moveTime)
    local x, y = gf:convertToClientSpace(x, y)
    local moveX = x - Me.curX
    local moveY = y - Me.curY
    local startTime = gfGetTickCount()
    local lastTime = startTime
    local lastMoveXY = -1
    GameMgr:registFrameFunc(FRAME_FUNC_TAG.DRAPMAP_MOVE_TO_UPDATA, function() 
        local curTime = gfGetTickCount()
        local rat = (curTime - lastTime) / moveTime
        Me.curX = Me.curX + moveX * rat
        Me.curY = Me.curY + moveY * rat

        local curMoveXY = math.abs(Me.curX - x) + math.abs(Me.curY - y)
        if curTime - startTime >= moveTime or (lastMoveXY > 0 and curMoveXY > lastMoveXY) then
            -- 到达移动时间或开始远离目的地
            Me.curX = x
            Me.curY = y
            GameMgr:unRegistFrameFunc(FRAME_FUNC_TAG.DRAPMAP_MOVE_TO_UPDATA)
            return
        end

        lastTime = curTime
        lastMoveXY = curMoveXY
    end, nil, true)
end

return DragMap