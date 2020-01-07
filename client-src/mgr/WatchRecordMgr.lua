-- WatchRecordMgr.lua
-- Created by songcw Feb/07/2017
-- 观战录像管理器

WatchRecordMgr = Singleton()

local m_recordData = {}

local m_curCombatId = nil                       -- 正在播放的战斗id
local m_curCombatRound = nil                    -- 当前回合数
local m_isPause = false                         -- 暂停状态
local m_isSkipDelayReady = false                -- 是否跳过准备阶段

local m_lastUpdateTime = 0                      -- 上一次刷新时间

local m_timeTickCount = 0                       -- 时间错
local m_lastPushMsgIndex = 1                    -- 上一次加载消息的序号
local m_lastBarrageTime = 0                    -- 上一次加载弹幕的时间戳号
local m_recordByTime = {}
local m_pauseTime = 0                           -- 暂停中消耗的事件

local m_combatMsgData = {}

WatchRecordMgr.skipMagic = false                -- 跳回合时，不需要播放光效，当为 true，其他光效接口有return操作
WatchRecordMgr.isNeedToAotuPlay = false         -- 如果在准备阶段被暂停，需要做个标记，开始播放时候加载新

local MSG_MAP = {
    ["MSG_MESSAGE_EX"] = 16383,
    ["MSG_LC_CUR_ROUND"] = 10692,
    ["MSG_LC_START_LOOKON"] = 2559,
    ["MSG_LC_ACTION"] = 18935,
    ["MSG_LC_END_LOOKON"] = 2557,
    ["MSG_LC_WAIT_COMMAND"] = 6635,
    ["MSG_DIALOG_OK"] = 8165,
    ["MSG_MESSAGE_IN_RECORD_COMBAT"] = 24078,
    ["MSG_NOTIFY_MISC"] = 20480,
}

-- 上一回合时重新加载所有，所以部分消息不用管
local RELOAD_NOT_CARE_MSG = {
    [8165] =    "MSG_DIALOG_OK",
    [20480] =   "MSG_NOTIFY_MISC",
    [16383] =   "MSG_MESSAGE_EX",
    [24078] = "MSG_MESSAGE_IN_RECORD_COMBAT",
}

function WatchRecordMgr:skipMSG()
    self.skipMagic = true
    MessageMgr:process(true)
    FightMgr:CleanAllAction()
    self.skipMagic = false
    -- 如果跳过准备

    self:gotoNextMSG("MSG_LC_ACTION", m_curCombatRound)

    -- 要开始执行动作了，标记一下需要等动画播放完成才能执行 MSG_LC_WAIT_COMMAND
    WatchRecordMgr.waitingAnimationEnd = true
    m_lastUpdateTime = gf:getTickCount()
    m_pauseTime = 0
end

-- 定时器
function WatchRecordMgr:update()

    if m_isPause then return end
    if not m_curCombatId or not m_recordByTime[m_curCombatId] then return end
    if not m_recordData[m_curCombatId].isReceiveDown then return end

    -- 时间戳计算
    local dis = gf:getTickCount() - m_lastUpdateTime - m_pauseTime

    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()

    m_timeTickCount = m_timeTickCount + dis * timeScale
    if m_pauseTime ~= 0 then m_pauseTime = 0 end
    local tempIndex
    local isEnd
    local gotoAct   -- 表示是否跳过准备阶段
    for i = m_lastPushMsgIndex + 1, #m_recordByTime[m_curCombatId] do
        local unitMsg = m_recordByTime[m_curCombatId][i]
        if unitMsg.interval_tick < m_timeTickCount then
            if WatchRecordMgr.waitingAnimationEnd and unitMsg.para.MSG == MSG_MAP["MSG_LC_WAIT_COMMAND"] then
                -- 动作未播放完成，不允许执行 MSG_LC_WAIT_COMMAND
                -- 此时需要累积 m_pauseTime
                m_timeTickCount = m_recordByTime[m_curCombatId][i - 1].interval_tick
                break
            end

            if unitMsg.para.MSG == MSG_MAP["MSG_LC_WAIT_COMMAND"]  then
                gotoAct = true
            end

            if unitMsg.para.MSG == MSG_MAP["MSG_LC_ACTION"]  then
                -- 要开始执行动作了，标记一下需要等动画播放完成才能执行 MSG_LC_WAIT_COMMAND
                WatchRecordMgr.waitingAnimationEnd = true
            end

            MessageMgr:pushMsg(unitMsg.para)
            tempIndex = i

            if unitMsg.para.MSG == MSG_MAP["MSG_LC_END_LOOKON"] then
                isEnd = true
            end

            if unitMsg.para.MSG == MSG_MAP["MSG_LC_CUR_ROUND"] then
                m_curCombatRound = unitMsg.para.round
            end

        else
            break
        end
    end
    m_lastPushMsgIndex = tempIndex or m_lastPushMsgIndex

    if isEnd then
        -- 如果结束了
        WatchCenterMgr:quitLookOnWatchCombat()
        return
    end

    if gotoAct and m_isSkipDelayReady then
        WatchRecordMgr:skipMSG()
    end

    -- 弹幕逻辑
    if BarrageTalkMgr:isOpen() then
        -- 获取当前时间对应的弹幕数据
        local barrageData = BarrageTalkMgr:getBarrageData(m_curCombatId, m_timeTickCount)
        if not barrageData then
            -- 每页该页弹幕，请求
            BarrageTalkMgr:queryBarrageDataByTime(m_curCombatId, m_timeTickCount)
        else
            local tempBarrageIndex


            for barrageTime, data in ipairs(barrageData) do
                if m_lastBarrageTime < data.interval_tick and m_timeTickCount > data.interval_tick then
                    tempBarrageIndex = data.interval_tick
                    BarrageTalkMgr:addBarrage(data)
                    -- 时间大于，则推出无用循环
                    if data.interval_tick > m_timeTickCount then break end
                end
            end

            m_lastBarrageTime = tempBarrageIndex or m_lastBarrageTime
        end
    end

    m_lastUpdateTime = gf:getTickCount()
end

-- 加载到下一个消息之前
function WatchRecordMgr:gotoBeforeMSG(msgStrm, round)
    for i = m_lastPushMsgIndex + 1, #m_recordByTime[m_curCombatId] do
        local unitMsg = m_recordByTime[m_curCombatId][i]

        -- 重新加载，不用关杂项等消息
        if RELOAD_NOT_CARE_MSG[unitMsg.para.MSG] then
        else
            if unitMsg.para.MSG == MSG_MAP["MSG_LC_END_LOOKON"] then
                MessageMgr:pushMsg(unitMsg.para)
                WatchCenterMgr:quitLookOnWatchCombat()
                break
            end

            if unitMsg.para.MSG == MSG_MAP[msgStrm] and round == unitMsg.para.round then
                m_curCombatRound = round
                m_lastPushMsgIndex = i
                m_timeTickCount = unitMsg.interval_tick
                m_lastBarrageTime = m_timeTickCount
                break
            end
            MessageMgr:pushMsg(unitMsg.para)
        end
    end
end

-- 加载到下一个消息   如果有destMsg，则代表，走到 msgStrm消息下一个 destMsg
function WatchRecordMgr:gotoNextMSG(msgStrm, round, destMsg)
    local isNewDest

    for i = m_lastPushMsgIndex + 1, #m_recordByTime[m_curCombatId] do
        local unitMsg = m_recordByTime[m_curCombatId][i]

        -- 重新加载，不用关杂项等消息
        if RELOAD_NOT_CARE_MSG[unitMsg.para.MSG] then
        else
            if isNewDest and unitMsg.para.MSG == MSG_MAP[destMsg] then
                m_lastPushMsgIndex = i - 1
                m_timeTickCount = m_recordByTime[m_curCombatId][i - 1].interval_tick
                m_lastBarrageTime = m_timeTickCount
                return
            end

            MessageMgr:pushMsg(unitMsg.para)
            if unitMsg.para.MSG == MSG_MAP["MSG_LC_END_LOOKON"] then
                WatchCenterMgr:quitLookOnWatchCombat()
                break
            end

            if unitMsg.para.MSG == MSG_MAP[msgStrm] and round == unitMsg.para.round then
                m_curCombatRound = round
                if not destMsg then
                    m_lastPushMsgIndex = i
                    m_timeTickCount = unitMsg.interval_tick
                    m_lastBarrageTime = m_timeTickCount
                    return
                else
                    isNewDest = true
                end
            end
        end
    end
end

-- 设置是否跳过准备阶段
function WatchRecordMgr:setSkipReady(isSkipDelayReady)
    m_isSkipDelayReady = isSkipDelayReady
end

-- 清除当前播放战斗信息
function WatchRecordMgr:cleanData()
    m_curCombatId = nil                       -- 正在播放的战斗id
    m_curCombatRound = nil                    -- 当前回合数
    m_isPause = false                         -- 暂停状态
    m_isSkipDelayReady = false                -- 是否跳过准备阶段
    m_lastUpdateTime = 0
    m_timeTickCount = 0
    m_lastPushMsgIndex = 1
    m_lastBarrageTime = 0
    m_recordByTime = {}
    m_pauseTime = 0
    m_combatMsgData = {}
end

-- 解析消息
function WatchRecordMgr:paraRecord(data)
    local roundFirstActTime = {}    -- 每回合 第一次 MSG_LC_ACTION时间

    for i = 1, data.count do
        if data.msg[i].para.MSG == MSG_MAP["MSG_MESSAGE_EX"] then
            data.msg[i].para.MSG = MSG_MAP["MSG_MESSAGE_IN_RECORD_COMBAT"]
        end

        if data.msg[i].para.MSG == MSG_MAP["MSG_NOTIFY_MISC"] then
            data.msg[i].para.updateTime = true --gf:getServerTime()
        end

        table.insert(m_recordByTime[data.combat_id], data.msg[i])

        if data.msg[i].para.MSG == MSG_MAP["MSG_LC_CUR_ROUND"] then
            m_recordData[data.combat_id].receiveRound = data.msg[i].para.round
            -- 保存每回合战斗开始的时间戳
            m_recordData[data.combat_id]["round_time"][data.msg[i].para.round] = data.msg[i].interval_tick
        end

        local round = m_recordData[data.combat_id].receiveRound
        if not m_recordData[data.combat_id][round] then
            m_recordData[data.combat_id][round] = {}
        end

        local unitMsg = data.msg[i]
        -- 战斗相关信息
        table.insert(m_recordData[data.combat_id][round], unitMsg.para)

        if not m_combatMsgData[data.combat_id][round] then
            m_combatMsgData[data.combat_id][round] = {}
        end

        table.insert(m_combatMsgData[data.combat_id][round], unitMsg)
    end
end

-- 获取当前播放的战斗id
function WatchRecordMgr:getCurReocrdCombatId()
    return m_curCombatId
end

-- 获取当前播放的战斗时间
function WatchRecordMgr:getCurReocrdCombatTime()
    return m_timeTickCount
end

-- 是否请求下回合数据
function WatchRecordMgr:toBeQuestNextPage(msgs, curPage)
    -- 是否完结
    local isEnd = false
    for i = 1, #msgs do
        if msgs[i].para.MSG == MSG_MAP["MSG_LC_END_LOOKON"] then
            isEnd = true
        end
    end
    if not isEnd then
        -- 请求下一页
        WatchRecordMgr:queryCombatByPage(curPage + 1)
    else
        m_recordData[m_curCombatId].isReceiveDown = true
    end
end

function WatchRecordMgr:MSG_LOOKON_COMBAT_RECORD_DATA(data)
    if not m_recordData[data.combat_id] then m_recordData[data.combat_id] = {} end
    if not m_combatMsgData[data.combat_id] then m_combatMsgData[data.combat_id] = {} end

    -- 检测下是不是开始
    local isStart = false
    for i = 1, data.count do
        if data.msg[i].para.MSG == MSG_MAP["MSG_LC_START_LOOKON"] then
            m_recordData[data.combat_id] = {}
            m_curCombatRound = 0
            m_recordData[data.combat_id].receiveRound = 0
            m_recordData[data.combat_id]["round_time"] = {}
            m_combatMsgData[data.combat_id] = {}
            m_recordByTime[data.combat_id] = {}
            isStart = true
            WatchRecordMgr.waitingAnimationEnd = false

            if BarrageTalkMgr:isOpen() then
                BarrageTalkMgr:queryBarrageDataByPage(data.combat_id, 1)
            end

            -- 加载赛事
            DlgMgr:openDlg("WaitDlg")
            gf:ShowSmallTips("赛事载入中，请稍后...")

            break
        end
    end

    -- 将消息按回合保存
    m_curCombatId = data.combat_id

    -- 解析消息成我想要的样子
    self:paraRecord(data)

    -- 检测是否结束，没有结束则请求新数据
    WatchRecordMgr:toBeQuestNextPage(data.msg, data.page)

    -- 如果接收完成播放
    if m_recordData[data.combat_id].isReceiveDown then
        DlgMgr:closeDlg("WaitDlg")

        -- 第 0 回合 即战斗开始等信息
        for _, unitMsg in pairs(m_recordByTime[m_curCombatId]) do
            MessageMgr:pushMsg(unitMsg.para)

            if unitMsg.para.MSG == MSG_MAP["MSG_LC_START_LOOKON"] then
                m_timeTickCount = unitMsg.interval_tick
                m_lastPushMsgIndex = _
                m_lastUpdateTime = gf:getTickCount()
                m_lastBarrageTime = 0
                break
            end
            --]]
        end

    end
end


-- 设置暂停
function WatchRecordMgr:setPause(isPause)
    m_isPause = isPause

    self.lastPauseTime = self.lastPauseTime or 0

    if isPause then
        self.lastPauseTime = gf:getTickCount()
    else
        m_pauseTime = m_pauseTime + gf:getTickCount() - self.lastPauseTime
    end

    WatchRecordMgr:setFightObjsAction(isPause)
end

-- 是否暂停
function WatchRecordMgr:isPause()
    return m_isPause
end

-- 跳转下一回合
function WatchRecordMgr:gotoNextRound()
    if not m_curCombatId or not m_recordData[m_curCombatId] then return end
    if not m_curCombatRound then return end

    -- 清除当前弹幕
    BarrageTalkMgr:removeAllBarrages()

    self.skipMagic = true

    self:gotoNextMSG("MSG_LC_WAIT_COMMAND", m_curCombatRound + 1, "MSG_LC_ACTION")
    MessageMgr:process(true)
    FightMgr:CleanAllAction()
    self.skipMagic = false

    m_lastUpdateTime = gf:getTickCount()
    m_pauseTime = 0


    if m_isPause then
        WatchRecordMgr:setFightObjsAction(m_isPause)
    end
end

-- 请求某页的战斗回合数据
function WatchRecordMgr:queryCombatByPage(page)
    if not m_curCombatId or not m_recordData[m_curCombatId] then return end
    gf:CmdToServer("CMD_LOOKON_COMBAT_RECORD_DATA", {combat_id = m_curCombatId, page = page})
end

-- 将战斗对象设置静止、动作
function WatchRecordMgr:setFightObjsAction(isPause)
    if isPause then
        for _, obj in pairs(FightMgr.objs) do
            obj:pauseAllPlay()
        end

        -- 五法是加载到 gf:getCharTopLayer()中
        local children = gf:getCharTopLayer():getChildren()
        for _, v in pairs(children) do
            if type(v.pausePlay) == "function" then
                v:pausePlay()
            elseif type(v.pause) == "function" then
                v:pause()
            elseif type(v.stopAllActions) == "function" then
                v:stopAllActions()
            end
        end
    else
        for _, obj in pairs(FightMgr.objs) do
            obj:continueAllPlay()
        end

        local children = gf:getCharTopLayer():getChildren()
        for _, v in pairs(children) do
            if type(v.continuePlay) == "function" then
                v:continuePlay()
            elseif type(v.play) == "function" then
                v:play()
            elseif type(v.resume) == "function" then
                v:resume()
            end
        end
    end
end

function WatchRecordMgr:MSG_MESSAGE_IN_RECORD_COMBAT(data)
    if data.show_extra then
        data.show_extra = data.show_extra == 1
    end

    local msg = gf:filtText(data.msg, nil, true)
    data.msg = msg

    FightMgr:setChat(data, true)
end

MessageMgr:regist("MSG_MESSAGE_IN_RECORD_COMBAT", WatchRecordMgr)
MessageMgr:regist("MSG_LOOKON_COMBAT_RECORD_DATA", WatchRecordMgr)
