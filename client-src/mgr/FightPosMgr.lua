-- FightPosMgr.lua
-- Created by chenyq Nov/22/2014
-- 战斗对象位置管理器

FightPosMgr = Singleton()

-- 一排的个数
FightPosMgr.NUM_PER_LINE = 5

-- 战斗对象个数
FightPosMgr.OBJ_NUM = 20

-- 攻击时，离目标位置的距离
FightPosMgr.ATTACK_DIS = 50

-- 保护时，离目标位置的距离
FightPosMgr.PROTECTED_DIS = 25

-- 格挡/防御时离开位置的距离
FightPosMgr.PARRY_BACK_DIS = 2
FightPosMgr.DEFENSE_BACK_DIS = 4

FightPosMgr.POS1 = 0
FightPosMgr.POS5 = 4

function FightPosMgr:init()
    self.baseX = -gf:getMapLayer():getPositionX()
    self.baseY = -gf:getMapLayer():getPositionY()

    self.centerX = Const.WINSIZE.width / 2
    self.centerY = Const.WINSIZE.height / 2
end

function FightPosMgr:getPos(index)
    local x, y = self:getRawPos(index)
    return self.baseX + x, self.baseY + y
end

-- 获取指定位置的世界坐标
function FightPosMgr:getRawPos(index)
    if index < 0  or index >= 20 then
        return 0, 0
    end

    self.centerX = Const.WINSIZE.width / 2
    self.centerY = Const.WINSIZE.height / 2

    local cx = self.centerX
    local cy = self.centerY
    local scale = Const.UI_SCALE

    local dx = 80 * scale       -- 同一排上  x 位置上的偏移
    local dy = 50 * scale       -- 同一排上  y 位置上的偏移

    local lineDx = 80 * scale   -- 不同排在  x 位置上的偏移
    local lineDy = -50 * scale  -- 不同排在  y 位置上的偏移

    if index == 0 then
        return cx - 415 * scale,  cy - 70 * scale   -- 第1排第1行与中心点的偏移
    elseif index < 10 then
        local x00, y00 = self:getRawPos(0)
        return x00 + dx * (index % 5) + lineDx * math.floor(index / 5), y00 + dy * (index % 5) + lineDy * math.floor(index / 5)
    elseif index == 10 then
        return cx + 60 * scale - 80 * scale,  cy + (- 260 + 50 + 25) * scale -- 第3排与中心点的偏移
    elseif index <= 20 then
        local x1010, y1010 = self:getRawPos(10)
        local tempIndex = index - 10
        return x1010 + dx * (tempIndex % 5) + lineDx * math.floor(tempIndex / 5), y1010 + dy * (tempIndex % 5) + lineDy * math.floor(tempIndex / 5)
    end
end

-- 获取屏幕中央点的世界坐标
function FightPosMgr:getScreenCenterPos()
    return math.floor(self.baseX + self.centerX), math.floor(self.baseY + self.centerY)
end

-- 在同  a 与  b 构成的线段中，找到离 a 距离为 dis 的点
-- 如果 a 与  b 之间的距离小于 dis，则返回 b
function FightPosMgr:getPointBetweenAB(aX, aY, bX, bY, dist)
    local distAB = gf:distance(aX, aY, bX, bY)
    if distAB < dist or math.abs(distAB - dist) < 0.0001 then
        return math.floor(bX), math.floor(bY)
    end

    return math.floor(aX + (bX - aX) * dist / distAB), math.floor(aY + (bY - aY) * dist / distAB)
end

-- 在 b 与 a 的反向延长线上找到一点离 a 的距离为 dis
function FightPosMgr:getPointDistanceFormA(aX, aY, bX, bY, dist)
    local distAB = gf:distance(aX, aY, bX, bY)
    if math.abs(distAB - dist) < 0.0001 then
        return math.floor(aX), math.floor(aY)
    end

    return math.floor(aX + (aX - bX) * dist / distAB), math.floor(aY + (aY - bY) * dist / distAB)
end
