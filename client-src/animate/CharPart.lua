-- CharPart.lua
-- created by cheny Nov/14/2014
-- 角色部件，从char目录下读取的动画，包括人物、武器等

local TAG_CHAR_ACTION = 100

local CharPart = class("CharPart", function()
    return cc.Sprite:create()
end)

-- syncLoad : true 为异步加载，否则为同步加载
function CharPart:ctor(icon, weapon, action, direction, basicPoint, interval, syncLoad, loadType)
    self.icon = icon or 0
    self.weapon = weapon or 0
    self.action = action or Const.SA_STAND
    self.direction = direction or 5
    self.basicPoint = basicPoint or cc.p(0, 0)
    self.interval = interval or Const.INTERVAL
    self.contentSize = cc.size(0,0)
    self.firstFrame = Const.CHAR_FRAME_START_NO
    self.lastFrame = Const.CHAR_FRAME_START_NO + 99
    self.loopTimes = 0
    self.reverse = false
    self.syncLoad = syncLoad
    self.loadType = loadType
    self.frameIntervalRate = 1
    self.blendMode = nil

    -- 标志是否是新创建的角色对象
    self.firstNew = true

    local function onNodeEvent(event)
        if Const.NODE_CLEANUP == event then
            self:clearUpdateEvent()
        end
    end

    self:registerScriptHandler(onNodeEvent)

    self:setCascadeOpacityEnabled(true)
end

function CharPart:setBlendMode(blendMode)
    self.blendMode = blendMode
end

function CharPart:clearUpdateEvent()
    if self.updateEvent then
        EventDispatcher:removeEventListener(self.updateEvent.key, self.updateEvent.func)
        self.updateEvent = nil
    end
end

-- 设置播放的起始帧
function CharPart:setFirstFrame(first)
    if first ~= self.firstFrame then
        self.firstFrame = first
        self.dirty = true
    end
end

-- 设置播放的结束帧
function CharPart:setLastFrame(last)
    if last ~= self.lastFrame then
        self.lastFrame = last
        self.dirty = true
    end
end

-- 设置播放次数，如果为 0 则表示循环播放
function CharPart:setLoopTimes(times)
    if self.loopTimes ~= times then
        self.loopTimes = times
        self.dirty = true
    end
end

-- 设置是否逆序播放
function CharPart:setReverse(reverse)
    if self.reverse ~= reverse then
        self.reverse = reverse
        self.dirty = true
    end
end

-- 设置播放结束的回调函数，如果没有设置，则循环播放
function CharPart:setCallback(cb)
    self.callback = cb

    if cb and self.loopTimes == 0 then
        self.loopTimes = 1
    end

    self.dirty = true
end

-- 设置编号
function CharPart:setIcon(icon, weapon)
    weapon = weapon or 0
    if self.icon == icon and self.weapon == weapon then return end

    self.icon = icon
    self.weapon = weapon
    self.dirty = true
end

-- 设置动作
function CharPart:setAction(act)
    if self.action == act then return end
    self.action = act
    self.dirty = true
end

-- 设置方向
function CharPart:setDirection(dir)
    if self.direction == dir then return end
    self.direction = dir
    self.dirty = true
end

-- 设置骑宠摆动信息
function CharPart:setPetSwingInfo(info)
    self.swingInfo = info
end

-- 设置基准点
function CharPart:setBasicPoint(point)
    if point == nil then return end
    self.basicPoint = point
    self.dirty = true
end

-- 设置帧间隔
function CharPart:setInterval(interval)
    if interval == nil or self.interval == interval then return end
    self.interval = interval
    self.dirty = true
end

-- 暂停播放
function CharPart:pausePlay()
    self:stopAllActions()
end

-- 继续播放
function CharPart:continuePlay()
    self.dirty = true
    self:updateNow()

    Log:D('char part children num' .. self:getChildrenCount())
end

function CharPart:recordCallIndex(index)
    if self.owner and self.owner.recordCallLog then
        self.owner:recordCallLog(index)
    end
end

-- 立即更新
function CharPart:updateNow()
    if self.dirty ~= true then return end
    self.dirty = false

    self:recordCallIndex(301)

    if self.icon == 0 or
        self.action == nil or self.action <= Const.SA_NONE or self.action >= Const.SA_NUM or
        self.direction == nil or self.direction < 0 or self.direction > 8 or
        self.basicPoint == nil or self.interval == nil then
        if self.callback then
            self.calback()
        end

        local parent = self:getParent()
        if parent then
            parent:setPartAniLoaded(self:getType())
        end

        return
    end

    self:recordCallIndex(302)

    local updateNowEx = function(animation)
        if 'function' ~= type(self.clearUpdateEvent) then return end

        self:recordCallIndex(310)

        self:clearUpdateEvent()

        -- 新建的角色,并且需要异步加载
        self.firstNew = nil

        if not animation then
            if self.callback then
                self.callback(self)
            end
            self:recordCallIndex(311)
            return
        end

        self:recordCallIndex(312)

        -- 告诉父节点，我们已经搞定了
        local parent = self:getParent()
        if parent then
            parent:setPartAniLoaded(self:getType())
        end

        self:recordCallIndex(313)

        if self.delayAction then
            self:stopAction(self.delayAction)
            self.delayAction = nil
        end
        self:recordCallIndex(314)
    end

    self:recordCallIndex(303)

    if self.firstNew and self.syncLoad then
        self:recordCallIndex(304)
        self:clearUpdateEvent()
        self:recordCallIndex(305)
        local key = AnimationMgr:getKey(self.icon, self.weapon, self.action, self.direction, self.firstFrame, self.lastFrame)
        self.updateEvent = { ["key"] = key, ["func"] = updateNowEx }
        EventDispatcher:addEventListener(key, self.updateEvent.func)
        self:recordCallIndex(306)

        -- 异步操作
        AnimationMgr:syncGetCharAnimation(self.icon, self.weapon, self.action,
                                    self.direction, self.firstFrame, self.lastFrame, self.loadType)
        self:recordCallIndex(307)
    else
        -- 同步操作
        self:recordCallIndex(308)
        local animation = AnimationMgr:getCharAnimation(self.icon, self.weapon, self.action,
                                           self.direction, self.firstFrame, self.lastFrame)
        self:recordCallIndex(309)
        updateNowEx(animation)
    end
end

-- 播放当前动画播放单元数量
function CharPart:getTotalDelayUnits()
    local animation = AnimationMgr:getCharAnimation(self.icon, self.weapon, self.action,
        self.direction, self.firstFrame, self.lastFrame)

    if animation then
        return animation:getTotalDelayUnits()
    else
        return 0
    end
end

-- 设置动画播放速率
function CharPart:setFrameIntervalRate(rate)
    if rate <= 0 then return end
    self.frameIntervalRate = rate
end

-- 播放动画
function CharPart:playAnimation()
    local animation = AnimationMgr:getCharAnimation(self.icon, self.weapon, self.action,
        self.direction, self.firstFrame, self.lastFrame)

    -- 数据
    if not animation then return end
    local frame = animation:getSpriteFrame(0)
    if nil == frame then
        return
    end

    if "function" ~= type(self.updateAnchorPoint) then
        -- 这种情况，可能对象已经丢失
        return
    end

    self:updateAnchorPoint(frame)

    -- 如果在战斗中则需要除以战斗加速倍数
    local interval = FightMgr:divideSpeedFactorIfInCombat(self.interval)
    interval = interval * self.frameIntervalRate
    animation:setDelayPerUnit(interval)

    -- 创建动作
    local action = nil
    local animate = cc.Animate:create(animation)
    if self.reverse then
        -- 逆向播放
        animate = animate:reverse()
    end

    if self.loopTimes == 0 then
        if self.swingInfo then
            if type(self.swingInfo.x) == 'table' then
                local xn = self.swingInfo.x
                local yn = self.swingInfo.y
                local n = #xn
                local moveByActions = {}
                for i = 1, n - 1 do
                    table.insert(moveByActions, cc.MoveBy:create(interval, cc.p(xn[i + 1] - xn[i], yn[i] - yn[i + 1])))
                end

                table.insert(moveByActions, cc.MoveBy:create(interval, cc.p(xn[1] - xn[n], yn[n] - yn[1])))
                action = cc.Sequence:create(moveByActions)
            else
                local tEnd = animation:getDuration()
                local tbegin = tEnd * self.swingInfo.percent / 100
                tEnd = tEnd - tbegin
                action = cc.Sequence:create(
                    cc.MoveBy:create(tbegin, cc.p(self.swingInfo.x, self.swingInfo.y)),
                    cc.MoveBy:create(tEnd, cc.p(-self.swingInfo.x, -self.swingInfo.y))
                )
            end

            action = cc.RepeatForever:create(cc.Spawn:create(animate, action))
        else
            action = cc.RepeatForever:create(animate)
        end
    else
        if self.loopTimes > 1 then
            animate = cc.Repeat:create(animate, self.loopTimes)
        end

        if self.callback then
            action = cc.Sequence:create(animate, cc.CallFunc:create(function()
                if self.callback then
                    self.callback(self)
                end
            end))
        else
            action = animate
        end
    end

    self:stopActionByTag(TAG_CHAR_ACTION)
    action:setTag(TAG_CHAR_ACTION)
    self:runAction(action)

    -- 立即调度一帧，防止因为某些原因(如：冰冻)导致动画被停止，无法渲染
    action:step(0)

    if self.blendMode == "add" then
        self:setBlendFunc(gl.ONE, gl.ONE)
    end

    -- 需要重置父节点的宽度
    -- 在CharAction自己调用，避免每个部件更新都调用CharAction:resetArea
    -- self:getParent():resetArea()
end

-- 清理(此处只清理 lua 的数据，不能重写 cc.Node.cleanup 接口)
function CharPart:clear()
end

-- 根据基准点信息，更新锚点信息
function CharPart:updateAnchorPoint(frame)
    if frame == nil then return end

    local flip = self:isFlippedX()

    local size = frame:getOriginalSize()
    local basicX = self.basicPoint.x
    if flip then basicX = size.width - basicX end
    local basicY = size.height - self.basicPoint.y
    self:setAnchorPoint(basicX/size.width, basicY/size.height)

    self.contentSize = size

    local x = basicX
    local y = basicY
    self.anchorPoint = cc.p(basicX/size.width, basicY/size.height)
    self.offsetPos = cc.p(x, y)

    -- 裁剪后的动画区域，拥有判断是否被点中了
    local rcTmp = frame:getRect()
    local offset = frame:getOffset()
    self.contentRect = cc.rect(
        offset.x + (size.width - rcTmp.width) / 2,
        offset.y + (size.height - rcTmp.height) / 2,
        rcTmp.width,
        rcTmp.height
    )

    if flip then
        self.contentRect.x = size.width - self.contentRect.x - self.contentRect.width
    end


    --[[if not self.testLayer then
        self.testLayer = cc.LayerColor:create(cc.c4b(128, 0, 0, 128))
        self:addChild(self.testLayer)
    end

    self.testLayer:setContentSize(self.contentRect.width, self.contentRect.height)
    self.testLayer:setPosition(self.contentRect.x, self.contentRect.y)]]

end

-- 设置部件的类型
function CharPart:setType(type)
    self.type = type
end

-- 取部件的类型
function CharPart:getType()
    return self.type
end

return CharPart
