-- InnGuest.lua
-- Created by lixh Api/22/2018
-- 客栈客人对象

local Char = require("obj/Char")
local InnGuest = class("InnGuest", Char)
local Progress = require('ctrl/Progress')

function InnGuest:init()
    Char.init(self)
    self.needBindClickEvent = false
    self.isVisible = true
    self.gatherBubber = nil
    self.barProgress = nil
    self.barText = nil
    self.scheduleId = nil
    self.isInAction = false
end

function InnGuest:getType()
    return OBJECT_TYPE.INN_GUEST
end

-- 客栈客人的显示与隐藏自己控制
function InnGuest:setVisible(flag)
    Char.setVisible(self, flag)
    self.isVisible = flag
end

-- 更新动作时，需要更新影子
function InnGuest:update()
    Char.update(self)
    if self.charAction and (self.charAction.action == Const.SA_SIT or self.charAction.action == Const.SA_EAT) then
        self:removeShadow()
    else
        self:addShadow()
    end
end

-- 非点击气泡的情况下进入读条状态(策划新增需求)
function InnGuest:toBarprogressStatus(type)
    -- 隐藏气泡
    self.gatherBubber:setVisible(false)

    if type == "room" then
        -- 房间需要隐藏角色，在门上播进度条，InnMgr中走自己的逻辑
        InnMgr:changeRoomStatus(self)
    elseif type == "table" then
        -- 桌子在角色头顶播进度条，桌子上摆放菜肴
        InnMgr:addFood(type, self.guestInfo)
        self:setBarProgressAction(type)
    end
end

-- 设置采集出现动画
function InnGuest:setBubberAction(type)
    local callBack = cc.CallFunc:create(function()
        if not self.gatherBubber then return end
        self.gatherBubber:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                -- 气泡点击
                self.gatherBubber:setVisible(false)

                if self.type == "room" then
                    -- 房间需要隐藏角色，在门上播进度条，InnMgr中走自己的逻辑
                    InnMgr:changeRoomStatus(self)
                elseif self.type == "table" then
                    -- 桌子在角色头顶播进度条，桌子上摆放菜肴
                    self:setBarProgressAction(type)
                    InnMgr:addFood(type, self.guestInfo)
                else
                    -- 点击金币气泡，播放贝塞尔抛物线运动
                    self:clearSchedule()
                    InnMgr:playCoinAction(sender, self.guestInfo)
                end
            end
        end)
    end)

    -- 创建气泡时，也许客人已经被析构了，比如退出客栈
    if not self.charAction then return end

    local resCfg = InnMgr:getInnGatherByType(type, self.guestInfo)
    if not resCfg then return end

    if self.gatherBubber then
        if self.gatherBubber.resCfg.pic == resCfg.pic then return end
        if type == "coin" then
            -- 策划要求金币用特效
            self.gatherBubber.pic:removeFromParent()
            self.gatherBubber.pic = nil
            self.gatherBubber.resCfg = nil
        else
            -- 有客人是时，允许家具升级，会调用到此处刷新家具，但是房间客人可能已经切换到金币状态了，pic已经被移除了
            if not self.gatherBubber.pic then return end

            self.gatherBubber.pic:loadTexture(resCfg.pic)
        end
    else
        -- 创建气泡背景
        self.gatherBubber = ccui.ImageView:create(resCfg.bg)
        self.gatherBubber:setTouchEnabled(true)
        local headX, headY = self.charAction:getHeadOffset()
        self.gatherBubber:setAnchorPoint(0.5, 0.5)
        self.gatherBubber:setLocalZOrder(Const.CHARACTION_ZORDER)
        self.gatherBubber:setPosition(0, headY + 45)

        if type ~= "coin" then
            -- 创建内容图片
            self.gatherBubber.pic = ccui.ImageView:create(resCfg.pic)
            self.gatherBubber.pic:setAnchorPoint(0.5, 0.5)
            local sz = self.gatherBubber:getContentSize()
            self.gatherBubber.pic:setPosition(cc.p(sz.width / 2, sz.height / 2))
            self.gatherBubber:addChild(self.gatherBubber.pic)
        end

        self:addToMiddleLayer(self.gatherBubber)
    end

    -- 右边房门需要翻转
    if type == "room" and (self.guestInfo.id == 1 or self.guestInfo.id == 4 or self.guestInfo.id == 6) then
        self.gatherBubber.pic:setFlippedX(true)
    end

    self.gatherBubber:setVisible(true)
    self.gatherBubber.resCfg = resCfg

    self.gatherBubber:setScale(0.2)
    local action = cc.ScaleTo:create(0.3, 1)
    self.gatherBubber:runAction(cc.Sequence:create(action, callBack))

    self.isInAction = true

    if type == "coin" then
        -- 金币采集时，需要旋转效果
        self:setCoinRotateAction()
    elseif type == "table" then
        -- 播放桌子采集动画，刷新客人位置与动作
        InnMgr:setGuestBasicStatus(type, self, Const.SA_SIT, self.guestInfo.pos, self.guestInfo.id)
    elseif type == "room" then
        InnMgr:setGuestBasicStatus(type, self, nil, self.guestInfo.pos, self.guestInfo.id)
    end

    if (type == "table" or type == "room") and self.guestInfo.barStartTime > 0 and self.guestInfo.barDuaration > 0 then
        -- 桌子，房间的客人，如果进度条时间大于0，则说明之前已经点击过气泡，直接切换到进度条状态
        self:toBarprogressStatus(type)
    end

    self.type = type
end

-- 设置金币y轴旋转效果
function InnGuest:setCoinRotateAction()
    local magic = gf:createLoopMagic(ResMgr.magic.inn_coin_rotate)
    local sz = self.gatherBubber:getContentSize()
    magic:setPosition(sz.width / 2, sz.height / 2 - 20)
    self.gatherBubber:addChild(magic)
end

-- 设置采集出现动画
function InnGuest:setBarProgressAction(type)
    local function callBack()
        self:removeGatherMagic()
        self.charAction:setAction(Const.SA_SIT)
        self.barProgress:setVisible(false)
        InnMgr:sendGuestStatusToServer(self.guestInfo, 2)

        -- 移除桌子上的菜肴
        InnMgr:removeFood(InnMgr:getFoodIndex(self.guestInfo))
    end

    -- 进度条
    if not self.barProgress then
        self.barProgress = Progress.new(ResMgr.ui.inn_bar_bg, ResMgr.ui.inn_bar_content)
        self.barProgress:setLocalZOrder(Const.CHAR_PROGRESS_ZORDER)
        self:addToMiddleLayer(self.barProgress)
    end

    local headX, headY = self.charAction:getHeadOffset()
    self.barProgress:setPosition(0, headY + 45)
    self.barProgress:setVisible(true)
    self.barProgress:setPercent(0)

    -- 进度条上放动画表现
    self:removeGatherMagic()
    self.gatherMagic = InnMgr:createProgressTextMagic(type)
    self:addToMiddleLayer(self.gatherMagic)
    self.gatherMagic:setPosition(0, headY + 65)

    -- 播放进度条的同时播放吃饭动作
    self.charAction:setAction(Const.SA_EAT)

    -- 用餐的客人读条时间与客人用餐动作时间有关，随机3-6次该动作的时间
    local times = self.charAction:getTotalDelayUnits() * self.charAction:getInterval() * math.random(3, 6) / 0.2

    -- 时间
    local tickTime = 0
    local curTime = gf:getServerTime()
    local leftTime = self.guestInfo.barStartTime + self.guestInfo.barDuaration - curTime
    self.guestInfo.barStartTime = math.min(self.guestInfo.barStartTime, curTime)

    if self.guestInfo.barStartTime > 0 and self.guestInfo.barDuaration > 0 then
        if leftTime > 0 then
            -- 进度条需要从中间位置开始读
            times = math.floor(self.guestInfo.barDuaration / 0.2)
            tickTime = (curTime - self.guestInfo.barStartTime) / 0.2
        else
            -- 时间已经到了，直接回调切换状态
            callBack()
            return
        end
    else
        self.guestInfo.barStartTime = curTime
        self.guestInfo.barDuaration = times / 5 
        InnMgr:cmdStartBarprogressToServer("table", self.guestInfo.id, self.guestInfo.pos,
            curTime, self.guestInfo.barDuaration)
    end

    -- 播放进度条与文字表现
    if not self.scheduleId then

        local maxNotUpTimeTicks = 0
        local countNotUpTimeTicks = 0
        local lastServerTime = 0

        self.scheduleId = gf:Schedule(function()
            tickTime = tickTime + 1
            local percent = tickTime / times * 100
            self.barProgress:setPercent(percent)

            local curTime = gf:getServerTime()
            if curTime <= lastServerTime then
                -- schedule tick 之后 时间没有增长，累计时间没有增加时 tick 的次数
                countNotUpTimeTicks = countNotUpTimeTicks + 1
                maxNotUpTimeTicks = math.max(maxNotUpTimeTicks, countNotUpTimeTicks)
            else
                countNotUpTimeTicks = 0
            end

            lastServerTime = curTime

            if tickTime >= times then
                callBack()
            end
        end, 0.2)
    end
end

-- 移除采集出现动画
function InnGuest:removeGatherMagic()
    self:clearSchedule()

    if self.gatherMagic then
        self.gatherMagic:removeFromParent()
        self.gatherMagic = nil
    end
end

function InnGuest:clearSchedule()
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

function InnGuest:cleanup()
    self:removeGatherMagic()
    self:clearSchedule()
    Char.cleanup(self)
end

return InnGuest
