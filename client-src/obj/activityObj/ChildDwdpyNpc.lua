-- ChildDwdpyNpc.lua
-- Created by songcw, Jan/19/2018
-- 娃娃日常-踩影子

local Char = require("obj/Char")
local ChildDwdpyNpc = class("ChildDwdpyNpc", Char)

local INIT_SPEED = 0.06

function ChildDwdpyNpc:setSpeed(speed)
    self.speed = INIT_SPEED
end

function ChildDwdpyNpc:addSpeed()
    if not self.speed then self.speed = INIT_SPEED end
    self.speed = self.speed + self.speed * 0.05

end

-- 更新角色速度
function ChildDwdpyNpc:updateSpeed()

   self.speed = self.speed

end

-- 播放死亡动作
function ChildDwdpyNpc:doDiedAction()

    self:setActAndCB(Const.FA_DIE_NOW, function()
        if self.faAct == Const.FA_DIE_NOW then
            self:setAct(Const.FA_DIED)
        end
    end)
end

function ChildDwdpyNpc:getSpeed()


    return self.speed or INIT_SPEED
end

-- 更新人物位置
function ChildDwdpyNpc:updatePos()


    if not self:isFightObj() and Me:getId() ~= self:getId() then
        if MarryMgr:checkWeddingActionZone(self) then
            -- 在对应的婚礼动作区域，隐藏
            self:setNeedDelete()
        else
            -- 否则，按照正常的逻辑进行
            CharMgr:doCharHideStatus(self)
        end
    end


    -- 更新速度
    self:updateSpeed()


    if not self.posCount or self.posCount <= 1 then
        return
    end

    local curLen = 0
    local len = self.lastLen
    local curTime = gfGetTickCount()
    if curTime <= self.startTime then
        -- 时间有误，不需要移动
        curLen = 0
    else
        local dist = (TeamMgr:getOrderById(self:getId()) - 1) * Const.CHAR_FOLLOW_DISTANCE
        if self:inMeTeam() and gf:inOffset(Me.curX, Me.curY, self.curX, self.curY, dist) then
            -- 玩家在 me 的队伍中，且离 me 的距离够近了
            curLen = self.lastLen
            if not self:canFollow() then
                self:setAct(Const.FA_STAND)
            end
        else
            self:setAct(Const.FA_WALK)

            -- 修正移动距离
            local _, _, _, _, ct = gf:getTickCount()
            local stepLen = self:getSpeed() * ct
            stepLen = self:reviseStepLen(stepLen)
            curLen = self.lastLen + stepLen
        end

        self.lastTime = curTime
    end

    if self.faAct ~= Const.FA_WALK then
        return
    end

    while len < curLen do
        -- 计算当前走了多少距离
        local d = 12
        len = len + d
        if len > curLen then
            d = d - (len - curLen)
            len = curLen
        end

        local i = 2
        while i <= self.posCount do
            if len < self:getPathValue("len", i) then
                break
            end

            i = i + 1
        end

        if i > self.posCount then
            -- 计步工具可以输入两个目标点，如果计步工具界面存在，考虑是否有第二目的地
            local dlg = DlgMgr:getDlgByName("PedometerDlg")
            if dlg and dlg.isNeedAutoNext then
                dlg:autoNextDest()
                return
            end

            -- 没有后续的寻路信息
            self:setPos(self:getPathValue("x", i - 1), self:getPathValue("y", i - 1))
            self:sendFollow()
            if not self:canFollow() then
         --       self:setAct(Const.FA_STAND)

                -- 到达终点的回调,调用完就清除
                if self.endPosCallBack and type(self.endPosCallBack.func) == 'function' then
                    self.endPosCallBack.func(self.endPosCallBack.para)
              --      self.endPosCallBack = nil
                end

                return
            end
        else
            -- 根据当前步的步长计算当前移动的位置及方向
            local dx = self:getPathValue("x", i) - self:getPathValue("x", i - 1)
            local dy = self:getPathValue("y", i) - self:getPathValue("y", i - 1)
            local ds = math.sqrt(dx * dx + dy * dy)
            local lastX, lastY = self.curX, self.curY

            local curX, curY
            if 0 == dx and 0 == dy then
                curX = self:getPathValue("x", i)
                curY = self:getPathValue("y", i)
            else
                curX = self:getPathValue("x", i - 1) + dx * (len - self:getPathValue("len", i - 1)) / ds
                curY = self:getPathValue("y", i - 1) + dy * (len - self:getPathValue("len", i - 1)) / ds
            end

            self:setPos(curX, curY)

            local dir = gf:defineDir(cc.p(0, 0), cc.p(dx, dy), self:getIcon())
            self:setDir(dir)
            self:sendFollow()

            -- 如果有外部手动设置停止动作，则直接跳过移动动作
            if self.faAct == Const.FA_STAND then
                break
            end
        end
    end

    self.lastLen = curLen
    self:updateToAddFocusMagic()
end

-- 对象进入场景,慧眼识娃
function ChildDwdpyNpc:onEnterSceneForHYSW(x, y, layer)
    -- 将对象的 3 层分别添加到角色层对应的子层中
    if self.bottomLayer:getParent() == nil then
        layer:addChild(self.bottomLayer)
    end

    if self.middleLayer:getParent() == nil then
        layer:addChild(self.middleLayer)
    end

    if self.topLayer:getParent() == nil then
        layer:addChild(self.topLayer)
    end

    self:setPos(x, y)

--    gf:ShowSmallTips(x .. "    " .. y)

    -- 更新名字
    self:updateName()



    -- 添加阴影
    self:addShadow()
--[[
    local image = ccui.ImageView:create(ResMgr.ui.fish_background)
   -- image:setPosition(x, y)
    layer:addChild(image)
    --]]
end

function ChildDwdpyNpc:playYanhua()
    local yanjhua = {ResMgr.ArmatureMagic.yanhua_ssfh, ResMgr.ArmatureMagic.yanhua_mtxy, ResMgr.ArmatureMagic.yanhua_xlcy}
    local ran = math.random( 1, 3)
    local magigc = ArmatureMgr:createMapArmature(yanjhua[ran].name)
    magigc:getAnimation():play("Top")
    magigc:setPosition(0, 150)
 --   magigc:getAnimation():setMovementEventCallFunc(func)
    self.topLayer:addChild(magigc)
end

--[[
function ChildDwdpyNpc:setEndPos(x, y, fun)



    local srcX, srcY = self.bottomLayer:getPosition()
    local dir = gf:defineDir(cc.p(srcX, srcY), cc.p(x, y), self:getIcon())
    self:setDir(dir)
    self:setAct(Const.FA_WALK)

    local function getMoveAct( )
        return cc.MoveTo:create(1, cc.p(x, y))
    end

    self.bottomLayer:runAction(getMoveAct())
    self.middleLayer:runAction(getMoveAct())
    self.topLayer:runAction(cc.Sequence:create(getMoveAct(), cc.CallFunc:create(function()
        if fun then

        end
    end)))

end
--]]
return ChildDwdpyNpc
