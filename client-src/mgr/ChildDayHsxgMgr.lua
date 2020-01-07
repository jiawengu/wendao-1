-- ChildDayHsxgMgr.lua
-- created by lixh Nov/23/2018
-- 2019年儿童节护送小龟

ChildDayHsxgMgr = Singleton()

-- 儿童节-护送小龟  小龟id
local CHILD_DAY_NPC_ID = 999
local CHILD_DAY_NPC_ICON = 50208

-- 儿童节-护送小龟：追踪定时器时间间隔
local FOLLOW_NPC_CHECK_TIME = 0.1

-- 儿童节-护送小龟 路线配置
local FOLLOW_NPC_ROUTE = {
    {{x = 85, y = 17}, {x = 62, y = 33}, {x = 101, y = 56}, {x = 64, y = 81}, {x = 106, y = 113}, {x = 67, y = 129}, {x = 27, y = 107}},
    {{x = 85, y = 17}, {x = 125, y = 39}, {x = 101, y = 56}, {x = 64, y = 81}, {x = 106, y = 113}, {x = 67, y = 129}, {x = 27, y = 107}},
}

-- 儿童节-护送小龟 减少体力值距离
local MINUS_ABILITY_DIS = 1

-- 儿童节-护送小龟 警告距离
local TIP_WAINING_DIS = 10

-- 儿童节-护送小龟 失败距离
local TIP_FAIL_DIS = 50

-- 儿童节-护送小龟 跟踪状态
local FOLLOW_STATUS = {
    NONE = 1,           -- 护送未开始或已经结束
    IN_WAIT = 2,        -- 等待(准备进入下一段、也许会触发事件)
    IN_FOLLOW = 3,      -- 护送过程中
    TO_GATHER = 4,      -- 前往采集物
}

-- 儿童节-护送小龟 正常状态速度
local CHILD_DAY_NORMAL_SPEED_PERCENT = -65

-- 儿童节-护送小龟 饥饿状态速度
local CHILD_DAY_HUNGRY_SPEED_PERCENT = -80

-- 儿童节-护送小龟 小龟体能
local CHILD_DAY_NPC_ABILITY = 100

-- 儿童节-护送小龟 小龟每走一格减少体力值
local CHILD_DAY_NPC_ABILITY_MINUSE = 1

-- 儿童节-护送小龟 错误选中指令次数
local CHILD_DAY_WRONG_CHOOSE_TIME = 3

-- 儿童节-护送小龟 小龟walk时的状态
local CHILD_DAY_WALK_STATUS = {
    NONE = 0,     -- 普通状态
    HUNGRY = 1,   -- 饥饿
    NEGATIVE = 2, -- 消极
}

-- 儿童节-护送小龟 npc头顶光效偏移
local MAGIC_OFFESET_Y = 20
local CHAT_OFFSET_Y = MAGIC_OFFESET_Y + 20

-- 儿童节-护送小龟 触发事件 概率
local SPECIAL_EVENT_PROBABILITY = 35
local SPECIAL_EVENT_TYPE = {
    FEED_PLAYER = 1,      -- 美食家
    POISON_GATHER = 2,    -- 有毒的采集物
    TO_GATHER_POISON = 3, -- 触碰到毒果子
}
local SPECIAL_EVENT_RESULT = {
    CONTINUE_GAME = 1,  -- 继续游戏
    TO_FEED_PLAYER = 2, -- 刷出美食家
    TO_GATHER = 3,      -- 刷出采集物
    FIGHT_SUCC = 4,     -- 战胜美食家并继续游戏
    GATHER_SUCC = 5,    -- 采集成功并继续游戏
}

-- 儿童节-护送小龟 游戏结果类型
local GAME_RESULT_TYPE = {
    SUCCESS = 0,    -- 成功
    TO_FAR = 1,     -- 距离太远
    NO_ABILITY = 2, -- 体力值不足
    FEED_MUCH = 3,  -- 喂养错误次数过多
    STONE_MUCH = 4, -- 扔石子错误次数太多
    FIGHT_FAIL = 5, -- 与美食家战斗失败
    TO_POISON = 6,  -- 奇怪的果子中护送失败
    FORCE_FAIL = 7, -- 强制失败(任务析构的情况)
}

-- NPC喊话
function ChildDayHsxgMgr:setPropaganda(char, text)
    -- 跟踪时定时器中会喊话，达到终点时也会喊话，所以喊话前先清掉其他喊话
    char:removeAllChat()

    ChatMgr:sendCurChannelMsgOnlyClient({
        id = char:getId(),
        gid = 0,
        icon = char:queryBasicInt("icon"),
        name = char:getName(),
        msg =  text,
    })
end

-- 儿童节-护送小龟  重置小龟体能
function ChildDayHsxgMgr:resetChildNpcAbility()
    if self.followStatus == FOLLOW_STATUS.IN_WAIT or self.followStatus == FOLLOW_STATUS.TO_GATHER then
        local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
        if npc then
            npc.walkAbility = CHILD_DAY_NPC_ABILITY
        end
    else
        -- 此接口由主线程调用，定时器中也会设置体能，为避免数据异常，先停止定制器
        -- 主线程重置完小龟体能后，在启动定时器
        self.followStatus = FOLLOW_STATUS.IN_WAIT
        performWithDelay(gf:getUILayer(), function()
            local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
            if npc then
                npc.walkAbility = CHILD_DAY_NPC_ABILITY
            end
            self.followStatus = FOLLOW_STATUS.IN_FOLLOW
        end, 0)
    end
end

-- 儿童节-护送小龟  启动定时器
function ChildDayHsxgMgr:childDayStartSchedule()
    self:childDayStopSchedule()
    if not self.childDayScheduleId then
        self.childDayScheduleId = gf:Schedule(function()
            local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
            local toMeDistance, curX, curY
            if npc then
                curX, curY = gf:convertToMapSpace(npc.curX, npc.curY)
                local meX, meY = gf:convertToMapSpace(Me.curX, Me.curY)
                toMeDistance = gf:distance(curX, curY, meX, meY)

                if toMeDistance > TIP_FAIL_DIS then
                    -- 大于50格，直接失败
                    self:cmdGameResult(GAME_RESULT_TYPE.TO_FAR)
                    self:outOfFollowStatus()
                    return
                end
            end

            if self.followStatus ~= FOLLOW_STATUS.NONE then
                -- 同步游戏数据
                self:checkCmdData()
            end

            if self.followStatus == FOLLOW_STATUS.NONE then
                -- 未开始护送或护送失败
                self:outOfFollowStatus()
            elseif self.followStatus == FOLLOW_STATUS.IN_WAIT then
                -- 等待事件处理阶段
                return
            elseif self.followStatus == FOLLOW_STATUS.TO_GATHER then
                -- 前往采集物
                if not npc then
                    -- npc 不存在了，停止定时器(有可能已经成功了，有可能失败了)
                    self:childDayStopSchedule()
                    return
                end

                if npc.gatherX and npc.gatherY then
                    if math.abs(curX - npc.gatherX) + math.abs(curY - npc.gatherY) <= 2 then
                        performWithDelay(gf:getUILayer(), function()
                            -- 延迟2s处理成功或失败
                            if npc.gatherSuccess then
                                -- 采集成功时需要额外的喊话:果子不见了...算子，继续赶路吧
                                self:setPropaganda(npc, CHS[7100395])

                                -- 更新小龟计步坐标，防止小龟很快死亡
                                npc.lastX, npc.lastY = curX, curY

                                if npc.routine[npc.routineInfo.index + 1] then
                                    -- 存在下一段寻路，直接继续寻路
                                    self.followStatus = FOLLOW_STATUS.IN_FOLLOW
                                    npc.routineInfo.index = npc.routineInfo.index + 1
                                    self:continueAutoWalk()
                                else
                                    self:cmdGameResult(GAME_RESULT_TYPE.SUCCESS)
                                end
                            else
                                -- 采集失败，触碰到毒果子
                                ChildDayHsxgMgr:cmdSpecialEvent(SPECIAL_EVENT_TYPE.TO_GATHER_POISON)
                            end

                            npc.gatherSuccess = nil
                        end, 2)

                        npc.gatherX = nil
                        npc.gatherY = nil
                    end
                end
                return
            elseif self.followStatus == FOLLOW_STATUS.IN_FOLLOW then
                -- 正在护送
                if not npc then
                    -- npc 不存在了，停止定时器(有可能已经成功了，有可能失败了)
                    self:childDayStopSchedule()
                    return
                end

                if npc.lastX and npc.lastY then
                    local steps = math.abs(curX - npc.lastX) + math.abs(curY - npc.lastY)
                    if steps > MINUS_ABILITY_DIS then
                        -- 更新体力值
                        npc.walkAbility = npc.walkAbility - CHILD_DAY_NPC_ABILITY_MINUSE * steps
                        npc.lastX, npc.lastY = curX, curY
                    end
                end

                -- 更新警惕特效
                self:childDayUpdateTipWarning(npc, toMeDistance)

                if npc.walkAbility <= 0 then
                    -- 体力值为0，直接失败
                    self:cmdGameResult(GAME_RESULT_TYPE.NO_ABILITY)
                elseif npc.walkAbility < 40 then
                    -- 体力值小于40
                    if not npc.walkStatus or npc.walkStatus == CHILD_DAY_WALK_STATUS.NONE then
                        -- 当前不是负面状态，增加负面状态
                        npc.walkStatus = math.random(CHILD_DAY_WALK_STATUS.HUNGRY, CHILD_DAY_WALK_STATUS.NEGATIVE)
                    end
                end

                self:childDaySetNpcWalkEffect(npc)
            end
        end, 0)
    end
end

-- 儿童节-护送小龟  停止定时器
function ChildDayHsxgMgr:childDayStopSchedule()
    if self.childDayScheduleId then
        gf:Unschedule(self.childDayScheduleId)
        self.childDayScheduleId = nil
    end
end

-- 儿童节-护送小龟  停止定时器
function ChildDayHsxgMgr:childDaySetNpcWalkEffect(npc)
    if npc.walkStatus == CHILD_DAY_WALK_STATUS.HUNGRY then
        -- 饥饿状态，行走速度降低20%，每隔6秒喊话
        npc:setSeepPrecentByClient(CHILD_DAY_HUNGRY_SPEED_PERCENT)
        local curTick = gfGetTickCount()
        if not npc.lastHungryPropagandaTick or (curTick - npc.lastHungryPropagandaTick) >= 6000 then
            -- 首次喊话，或距离上次喊话已经过了6秒
            self:setPropaganda(npc, CHS[7190380])
            npc.lastHungryPropagandaTick = curTick 
        end
    elseif npc.walkStatus == CHILD_DAY_WALK_STATUS.NEGATIVE then
        -- 消极状态，走动3~5秒后停1秒，再继续行走，每隔6秒喊话
        local curTick = gfGetTickCount()
        if not npc.negativeStopTick or npc.negativeStopTick < curTick then
            -- 首次进入消极状态，或者已经到达消极表现的计时了,停止走动，3秒后再继续走
            npc:setAct(Const.FA_STAND)

            -- 先设置消极表现tick为10秒后，保存不重复创建action，延迟中会校正当前值为随机3-5秒
            npc.negativeStopTick = curTick + 10000
            
            performWithDelay(gf:getUILayer(), function()
                local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
                if not npc then
                    -- 角色不存在，通知追踪失败
                    self:cmdGameResult(GAME_RESULT_TYPE.TO_FAR)
                    return
                end

                if self.followStatus == FOLLOW_STATUS.IN_FOLLOW then
                    local routineInfo = npc.routineInfo
                    local tarX, tarY = npc.routine[routineInfo.index].x, npc.routine[routineInfo.index].y
                    npc:setEndPos(tarX, tarY, {func = routineInfo.callBack, para = routineInfo.index})

                    -- 3~5秒后进行下一次消极表现
                    npc.negativeStopTick = gfGetTickCount() + math.random(3, 5) * 1000
                end
            end, 3)
        end

        if not npc.lastNegativePropagandaTick or (curTick - npc.lastNegativePropagandaTick) >= 6000 then
            -- 首次喊话，或距离上次喊话已经过了6秒
            self:setPropaganda(npc, CHS[7190381])
            npc.lastNegativePropagandaTick = curTick 
        end
    end
end

-- 儿童节-护送小龟  进入下一段寻路
function ChildDayHsxgMgr:continueAutoWalk()
    -- npc到达上一段终点后，会在下一帧清除到达终点的回调，此处需要延迟一帧设置下一段寻路
    performWithDelay(gf:getUILayer(), function()
        local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
        if npc then
            local routineInfo = npc.routineInfo
            if routineInfo then
                npc:setEndPos(npc.routine[routineInfo.index].x, npc.routine[routineInfo.index].y,
                    {func = routineInfo.callBack, para = routineInfo.index})
            end
        end
    end, 0)
end

-- 儿童节-护送小龟  设置下一段寻路
function ChildDayHsxgMgr:setNextAutoWalk(index)
    local function callBack(nextIndex)
        self:setNextAutoWalk(nextIndex)
    end

    -- 追踪npc到达终点后，尝试进行下一段寻路
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if not npc then return end

    if index == 1 then
        -- 寻路起始点不用判断特殊事件，直接开始寻路
        npc.routineInfo = {callBack = callBack, index = 2}
        self:continueAutoWalk()
        return
    end

    if npc.routine[index] then
        self:createSpecialEvent()
    else
        self.followStatus = FOLLOW_STATUS.NONE
    end
end

-- 儿童节-护送小龟 更新警惕特效
function ChildDayHsxgMgr:childDayUpdateTipWarning(npc, distance)
    if distance > TIP_WAINING_DIS then
        -- 距离玩家过远, 停止走动
        npc:setAct(Const.FA_STAND)

        -- 增加警惕特效
        if not npc.warningTips then
            local headX, headY = npc.charAction:getHeadOffset()
            local magic = gf:createLoopMagic(ResMgr.magic.tanan_jhll_too_close, nil, {blendMode = "add"})
            magic:setAnchorPoint(0.5, 0.5)
            magic:setLocalZOrder(Const.CHARACTION_ZORDER)
            magic:setPosition(0, headY + MAGIC_OFFESET_Y)
            magic:setTag(icon)
            npc:addToMiddleLayer(magic)
            npc.warningTips = magic
        end

        -- 距离小龟过远，喊话
        local curTick = gfGetTickCount()
        if not npc.lastStopPropagandaTick or (curTick - npc.lastStopPropagandaTick) >= 6000 then
            -- 首次距离过远，或距离上一次喊话时间已经过了6秒
            self:setPropaganda(npc, CHS[7190385])
            npc.lastStopPropagandaTick = curTick 
        end
    else
        if npc.faAct and npc.faAct == Const.FA_STAND and CHILD_DAY_WALK_STATUS.NEGATIVE ~= npc.walkStatus then
            -- 当前处于站立状态，恢复走动，消极状态的站立由消极状态更新时处理
            local routineInfo = npc.routineInfo
            local tarX, tarY = npc.routine[routineInfo.index].x, npc.routine[routineInfo.index].y
            local curX, curY = gf:convertToMapSpace(npc.curX, npc.curY)
            if curX == tarX and curY == tarY then
                -- 已经到达了下一段寻路起点
                routineInfo.callBack(routineInfo.index - 1)
            else
                npc:setEndPos(tarX, tarY, {func = routineInfo.callBack, para = routineInfo.index})
            end

            npc.lastStopPropagandaTick = nil
        end

        -- 移除警惕特效
        if npc.warningTips then
            npc.warningTips:removeFromParent()
            npc.warningTips = nil
        end
    end
end

-- 儿童节-护送小龟 创建小龟对象
function ChildDayHsxgMgr:childDayCreatChar(reconnectedInfo)
    local char = require("obj/activityObj/HsxgNpc").new()
    char:absorbBasicFields({
        id = CHILD_DAY_NPC_ID,
        icon = CHILD_DAY_NPC_ICON,
        dir = 7,
        name = CHS[7190378],
        opacity = 0,
    })

    if not reconnectedInfo then
        -- 生成随机路线
        char.routineIndex = math.random(1, #FOLLOW_NPC_ROUTE)
        char.routine = FOLLOW_NPC_ROUTE[char.routineIndex]

        -- 初始化体力值
        char.walkAbility = CHILD_DAY_NPC_ABILITY

        char:onEnterScene(char.routine[1].x, char.routine[1].y)
        char.lastX, char.lastY = char.routine[1].x, char.routine[1].y

        char:setSeepPrecentByClient(CHILD_DAY_NORMAL_SPEED_PERCENT)
    else
        -- 使用重连数据初始化创建小龟
        char.routineIndex = reconnectedInfo.routineIndex
        char.routine = FOLLOW_NPC_ROUTE[char.routineIndex]

        char.walkAbility = reconnectedInfo.walkAbility

        char:onEnterScene(reconnectedInfo.x, reconnectedInfo.y)
        char.lastX, char.lastY = reconnectedInfo.x, reconnectedInfo.y

        char:setSeepPrecentByClient(reconnectedInfo.speedPercent)
    end

    char:setAct(Const.FA_STAND)
    char:setSpeed(0.2)

    CharMgr:deleteChar(CHILD_DAY_NPC_ID)
    CharMgr.chars[CHILD_DAY_NPC_ID] = char
end

-- 儿童节-护送小龟  进入护送状态
function ChildDayHsxgMgr:goToFollowStatus()
    self:childDayCreatChar()

    -- 开始游戏就同步一次数据
    self.followStatus = FOLLOW_STATUS.IN_FOLLOW
    self:cmdGameData()

    -- npc出现后0.5秒走动，一出来就在跑的效果不好
    performWithDelay(gf:getUILayer(), function()
        -- 设置npc走到终点，到达终点后回调
        if not CharMgr:getCharById(CHILD_DAY_NPC_ID) then
            -- 角色不存在，通知护送失败
            self:cmdGameResult(GAME_RESULT_TYPE.TO_FAR)
            return
        end

        self:setNextAutoWalk(1)

        -- 延迟一帧启动定时器，保证小龟已经开始寻路
        performWithDelay(gf:getUILayer(), function()
            self:childDayStartSchedule()
        end, 0)
    end, 0.5)
end

-- 儿童节-护送小龟  退出护送状态
function ChildDayHsxgMgr:outOfFollowStatus()
    -- 停止定时器
    self:childDayStopSchedule()

    -- 析构npc
    CharMgr:deleteChar(CHILD_DAY_NPC_ID)

    -- 增加跟踪失败标记
    self.followStatus = FOLLOW_STATUS.NONE

    -- 移除战斗结束事件的监听
    EventDispatcher:removeEventListener(EVENT.EVENT_END_COMBAT, self.onEventEndCombat, self)
end

-- 儿童节-护送小龟  喂养小龟、扔石子
function ChildDayHsxgMgr:childDatFeedNpc(type)
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if npc.isDead then return end

    local npcX, npcY = gf:convertToMapSpace(npc.curX, npc.curY)
    local meX, meY = gf:convertToMapSpace(Me.curX, Me.curY)
    if gf:distance(meX, meY, npcX, npcY) > 15 then
        -- 距离小龟太远了
        gf:ShowSmallTips(CHS[7190382])
        return
    end

    if type == CHILD_DAY_WALK_STATUS.HUNGRY then
        -- 喂食
        gf:ShowSmallTips(CHS[7190383])
        if not npc.wrongFeedTimes then npc.wrongFeedTimes = 0 end
        if npc.walkStatus == type then
            -- 对应小鬼状态为饥饿状态，则解除饥饿状态，恢复体力，重置喂养错误次数，恢复行走速度
            self:resetChildNpcAbility()
            npc.walkStatus = CHILD_DAY_WALK_STATUS.NONE
            npc.lastHungryPropagandaTick = nil
            npc.wrongFeedTimes = 0
            npc:setSeepPrecentByClient(CHILD_DAY_NORMAL_SPEED_PERCENT)
        else
            npc.wrongFeedTimes = npc.wrongFeedTimes + 1
            if npc.wrongFeedTimes >= CHILD_DAY_WRONG_CHOOSE_TIME then
                -- 喂食错误次数上限
                self:cmdGameResult(GAME_RESULT_TYPE.FEED_MUCH)
            end
        end
    elseif type == CHILD_DAY_WALK_STATUS.NEGATIVE then
        -- 扔石子
        gf:ShowSmallTips(CHS[7190384])
        if not npc.wrongStoneTimes then npc.wrongStoneTimes = 0 end
        if npc.walkStatus == type then
            -- 对应小鬼状态为消极状态，则解除消极状态，恢复体力，重置扔石子错误次数
            self:resetChildNpcAbility()
            npc.walkStatus = CHILD_DAY_WALK_STATUS.NONE
            npc.lastNegativePropagandaTick = nil
            npc.wrongStoneTimes = 0
        else
            npc.wrongStoneTimes = npc.wrongStoneTimes + 1
            if npc.wrongStoneTimes >= CHILD_DAY_WRONG_CHOOSE_TIME then
                -- 扔石子错误次数上限
                self:cmdGameResult(GAME_RESULT_TYPE.STONE_MUCH)
            end
        end
    end
end

-- 儿童节-护送小龟 触发事件
function ChildDayHsxgMgr:createSpecialEvent()
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if not npc then
        -- 角色不存在，通知护送失败
        self:cmdGameResult(GAME_RESULT_TYPE.TO_FAR)
        return
    end

    if npc.routine[npc.routineInfo.index + 1] and math.random(1, 100) <= SPECIAL_EVENT_PROBABILITY then
        -- 非最后一站，尝试创建随机事件
        local type = math.random(SPECIAL_EVENT_TYPE.FEED_PLAYER, SPECIAL_EVENT_TYPE.POISON_GATHER)
        self:cmdSpecialEvent(type)
    else
        -- 未进入随机事件
        if npc.routine[npc.routineInfo.index + 1] then
            -- 存在下一段寻路，直接继续寻路
            npc.routineInfo.index = npc.routineInfo.index + 1
            self:continueAutoWalk()
        else
            self:cmdGameResult(GAME_RESULT_TYPE.SUCCESS)
        end
    end
end

-- 儿童节-护送小龟 通知触发事件
function ChildDayHsxgMgr:cmdSpecialEvent(type)
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if not npc then return end
    local x, y = gf:convertToMapSpace(npc.curX, npc.curY)
    gf:CmdToServer("CMD_CHILD_DAY_2019_TRIGGER_EVENT", {type = type, x = x, y = y})
    self.followStatus = FOLLOW_STATUS.IN_WAIT
    npc:setAct(Const.FA_STAND)

    if type == SPECIAL_EVENT_TYPE.FEED_PLAYER then
        -- 遇到美食家时，需要进入战斗，添加战斗结束事件的监听
        EventDispatcher:addEventListener(EVENT.EVENT_END_COMBAT, self.onEventEndCombat, self)
    end
end

-- 儿童节-护送小龟 是否处于护送状态
function ChildDayHsxgMgr:isChildDayInFollow()
    return self.followStatus and self.followStatus ~= FOLLOW_STATUS.NONE
end

-- 儿童节-护送小龟 任务失败的通用处理
function ChildDayHsxgMgr:childDayFailTask(propaganda, tips)
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)

    -- 死亡动作
    npc:doDiedAction()

    -- 喊话
    self:setPropaganda(npc, propaganda)

    -- 先停止小龟的护送状态，延迟给提示并退出状态
    self.followStatus = FOLLOW_STATUS.IN_WAIT
    performWithDelay(gf:getUILayer(), function()
        -- gf:showTipAndMisMsg(tips)
        self.followStatus = FOLLOW_STATUS.NONE
    end, 2)
end

-- 儿童节-护送小龟 检查发送数据给服务器
function ChildDayHsxgMgr:checkCmdData()
    local curTime = gf:getServerTime()
    if self.lastCmdDataTime and math.abs(curTime - self.lastCmdDataTime) > 2 then
        self:cmdGameData()
        self.lastCmdDataTime = curTime
    end

    if not self.lastCmdDataTime then self.lastCmdDataTime = curTime end
end

-- 儿童节-护送小龟 客户端通知游戏数据，方便重连时使用
function ChildDayHsxgMgr:cmdGameData()
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if not npc then return end

    local data = {}
    data.x, data.y = gf:convertToMapSpace(npc.curX, npc.curY)
    data.routineIndex = npc.routineIndex
    data.walkAbility = npc.walkAbility
    data.speedPercent = npc:getSeepPrecent()
    data.gatherX, data.gatherY = npc.gatherX, npc.gatherX
    data.gatherSuccess = npc.gatherSuccess
    data.wrongFeedTimes = npc.wrongFeedTimes or 0
    data.wrongStoneTimes = npc.wrongStoneTimes or 0
    data.followStatus = self.followStatus
    data.childDayGameId = self.childDayGameId

    if npc.routineInfo then
        data.nextPosIndex = npc.routineInfo.index
    end

    local gameDataStr = ""
    for k, v in pairs(data) do
        if gameDataStr ~= "" then
            gameDataStr = gameDataStr .. "|"
        end

        if 'childDayGameId' == k or 'gatherSuccess' == k then
            gameDataStr = gameDataStr .. string.format("%s=%s", k, tostring(v))
        else
            gameDataStr = gameDataStr .. string.format("%s=%d", k, v)
        end
    end

    gf:CmdToServer("CMD_CHILD_DAY_2019_NOTIFY_DATA", {gameData = gameDataStr})
end

-- 儿童节-护送小龟 客户端通知游戏结果
function ChildDayHsxgMgr:cmdGameResult(result)
    local checkSum = string.lower(gfGetMd5(Me:queryBasic("gid") .. self.childDayGameId .. result))
    gf:CmdToServer("CMD_CHILD_DAY_2019_RESULT", {result = result, checkSum = checkSum})
    self.followStatus = FOLLOW_STATUS.IN_WAIT
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if npc then
        npc:setAct(Const.FA_STAND)
    end
end

-- 儿童节-护送小龟 退出战斗
function ChildDayHsxgMgr:onEventEndCombat()
    if self.fightFeedPlayerId then
        -- 美食家喊话
        local feedPlayer = CharMgr:getCharById(self.fightFeedPlayerId)
        if feedPlayer then
            self:setPropaganda(feedPlayer, CHS[7190398])
        end

        local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
        if npc then
            -- 1秒后小龟播放死亡动作，喊话
            performWithDelay(gf:getUILayer(), function()
                npc:doDiedAction()
                self:setPropaganda(npc, CHS[7190399])
            end, 1)
        end

        -- 延迟2秒后通知服务器析构美食家，退出护送状态
        self.followStatus = FOLLOW_STATUS.IN_WAIT
        performWithDelay(gf:getUILayer(), function()
            self.followStatus = FOLLOW_STATUS.NONE
            self:outOfFollowStatus()

            gf:CmdToServer("CMD_CHILD_DAY_2019_START_MSJ_FAIL", {})
        end, 2)

        self.fightFeedPlayerId = nil
    end
end

-- 通知客户端开始护送小龟游戏
function ChildDayHsxgMgr:MSG_CHILD_DAY_2019_START_GAME(data)
    self.childDayGameId = data.id
    self:goToFollowStatus()
end

-- 通知客户端停止游戏
function ChildDayHsxgMgr:MSG_CHILD_DAY_2019_STOP_GAME(data)
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if not npc then
        -- 小龟没有了，直接退出护送状态
        self.followStatus = FOLLOW_STATUS.NONE
        return
    end

    if data.result == GAME_RESULT_TYPE.SUCCESS then
        -- 成功
        self.followStatus = FOLLOW_STATUS.IN_WAIT
        performWithDelay(gf:getUILayer(), function()
            self.followStatus = FOLLOW_STATUS.NONE
        end, 2)
        return
    elseif data.result == GAME_RESULT_TYPE.TO_FAR then
        -- 距离太远
        -- gf:showTipAndMisMsg(CHS[7190391])
        self.followStatus = FOLLOW_STATUS.NONE
        return
    elseif data.result == GAME_RESULT_TYPE.NO_ABILITY then
        -- 体力值不足
        self:childDayFailTask(CHS[7190392], CHS[7190393])
        return
    elseif data.result == GAME_RESULT_TYPE.FEED_MUCH then
        -- 喂养错误次数过多
        self:childDayFailTask(CHS[7190394], CHS[7190395])
        return
    elseif data.result == GAME_RESULT_TYPE.STONE_MUCH then
        -- 扔石子错误次数太多
        self:childDayFailTask(CHS[7190396], CHS[7190397])
        return
    elseif data.result == GAME_RESULT_TYPE.FIGHT_FAIL then
        -- 与美食家战斗失败
        self.fightFeedPlayerId = data.npcId
        if not Me:isInCombat() then
            -- 战斗中逃跑时，客户端先退出了战斗，后收到此消息，所以需要自己做一次退出战斗处理
            self:onEventEndCombat()
        end
        return
    elseif data.result == GAME_RESULT_TYPE.TO_POISON then
        -- 奇怪的果子中护送失败
        self:childDayFailTask(CHS[7190401], CHS[7190402])
        return
    elseif data.result == GAME_RESULT_TYPE.FORCE_FAIL then
        -- 强制失败(任务析构的情况)
    end

    self.followStatus = FOLLOW_STATUS.NONE
end

-- 通知客户端触发事件结果
function ChildDayHsxgMgr:MSG_CHILD_DAY_2019_EVENT_RESULT(data)
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if not npc then
        -- 角色不存在，通知护送失败
        self:cmdGameResult(GAME_RESULT_TYPE.TO_FAR)
        return
    end

    if data.result == SPECIAL_EVENT_RESULT.GATHER_SUCC then
        -- 采集成功
        npc.gatherSuccess = true
    elseif data.result == SPECIAL_EVENT_RESULT.CONTINUE_GAME
        or data.result == SPECIAL_EVENT_RESULT.FIGHT_SUCC then
        -- 继续游戏，战胜美食家，表示事件处理成功，继续下一段寻路
        if data.result == SPECIAL_EVENT_RESULT.FIGHT_SUCC then
            -- 战斗胜利时需要额外的喊话:呼，这个吓人的家伙终于被赶走了。
            self:setPropaganda(npc, CHS[7100396])
        end

        if npc.routine[npc.routineInfo.index + 1] then
            -- 存在下一段寻路，直接继续寻路
            self.followStatus = FOLLOW_STATUS.IN_FOLLOW
            npc.routineInfo.index = npc.routineInfo.index + 1
            self:continueAutoWalk()
        else
            self:cmdGameResult(GAME_RESULT_TYPE.SUCCESS)
        end
    elseif data.result == SPECIAL_EVENT_RESULT.TO_FEED_PLAYER then
        -- 刷出美食家，提示，喊话，等待玩家与美食家对话
        performWithDelay(gf:getUILayer(), function()
            local npc = CharMgr:getCharById(data.npcId)
            if npc then
                -- 这只小龟看起来肉质肥美哇
                self:setPropaganda(npc, CHS[7190387])
            end
        end, 1)

        performWithDelay(gf:getUILayer(), function()
            local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
            if npc then
                -- 救...救命啊
                self:setPropaganda(npc, CHS[7190388])
            end
        end, 2)

        performWithDelay(gf:getUILayer(), function()
            if not Me:isInCombat() then
                -- 非战斗中，提示
                gf:showTipAndMisMsg(CHS[7190386])
            end
        end, 3)
    elseif data.result == SPECIAL_EVENT_RESULT.TO_GATHER then
        -- 刷出采集物，提示，喊话，需要让小龟走向采集物
        gf:showTipAndMisMsg(CHS[7190389])

        local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
        if npc then
            -- 咦，什么香味如此诱人。
            self:setPropaganda(npc, CHS[7190390])
        end

        performWithDelay(gf:getUILayer(), function()
            local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
            if npc then
                self.followStatus = FOLLOW_STATUS.TO_GATHER
                npc:setEndPos(data.x, data.y)
                npc.gatherX = data.x
                npc.gatherY = data.y
            end
        end, 2)
    end
end

-- 重连时游戏数据
function ChildDayHsxgMgr:MSG_CHILD_DAY_2019_DATA(data)
    -- 解析游戏保存的数据
    if string.isNilOrEmpty(data.gameData) then return end
    local gameStrInfo = string.split(data.gameData, "|")
    local npcInfo = {}
    for i = 1, #gameStrInfo do
        local info = string.split(gameStrInfo[i], "=")
        if 'childDayGameId' == info[1] then
            npcInfo[info[1]] = info[2]
        elseif 'gatherSuccess' == info[1] then
            npcInfo[info[1]] = (info[2] == 'true' and true or false)
        else
            npcInfo[info[1]] = tonumber(info[2])
        end
    end

    -- 重新生成小龟
    self:childDayCreatChar(npcInfo)

    -- npc对象
    local npc = CharMgr:getCharById(CHILD_DAY_NPC_ID)
    if not npc then return end

    -- 路径信息
    local function continueWalkCallBack(nextIndex)
        self:setNextAutoWalk(nextIndex)
    end

    if not npcInfo.nextPosIndex then
        -- 没有下一个坐标点信息，说明是在起点还没开始走就切后台了，此时重现开始走
        self:setNextAutoWalk(1)
    else
        npc.routineInfo = {callBack = continueWalkCallBack, index = npcInfo.nextPosIndex}
    end

    -- 恢复数据，启动定时器，继续游戏
    self.childDayGameId = npcInfo.childDayGameId
    self.followStatus = npcInfo.followStatus
    self:childDayStartSchedule()

    if data.result ~= 0 then
        -- 模拟触发事件
        self:MSG_CHILD_DAY_2019_EVENT_RESULT(data)
    else
        -- 为0时，表示当前没有随机事件，继续行走下一站
        if self.followStatus == FOLLOW_STATUS.TO_GATHER then
            -- 前往采集物路程中，则需要多走一站
            if npc.routine[npc.routineInfo.index + 1] then
                npc.routineInfo.index = npc.routineInfo.index + 1
            end
        end

        self.followStatus = FOLLOW_STATUS.IN_FOLLOW
        self:continueAutoWalk()
    end
end

-- 过图
function ChildDayHsxgMgr:MSG_ENTER_ROOM()
    if self:isChildDayInFollow() then
        -- 处于护送状态
        self:outOfFollowStatus()
    end
end

MessageMgr:regist("MSG_CHILD_DAY_2019_START_GAME", ChildDayHsxgMgr)
MessageMgr:regist("MSG_CHILD_DAY_2019_STOP_GAME", ChildDayHsxgMgr)
MessageMgr:regist("MSG_CHILD_DAY_2019_DATA", ChildDayHsxgMgr)
MessageMgr:regist("MSG_CHILD_DAY_2019_EVENT_RESULT", ChildDayHsxgMgr)
MessageMgr:hook("MSG_ENTER_ROOM", ChildDayHsxgMgr, "ChildDayHsxgMgr")
