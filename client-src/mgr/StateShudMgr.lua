-- StateShudMgr.lua
-- Create by liuhb Sep/02/2017
-- 自动刷道状态管理

StateShudMgr = Singleton()

local lShuadMap             = require(ResMgr:getCfgPath("ShuadMap.lua"))    -- 刷道地图配表
local lSHuadDefaultWalkDesc = {                                             -- 刷道任务默认自动寻路信息
    [CHS[5120001]] = CHS[5120003],
    [CHS[5120002]] = CHS[5120004],
    [CHS[5120005]] = CHS[5120006],
}

-- 刷道状态的数据
local lCurShuadTask         = nil                                           -- 当前刷道的任务
local lCurShuadWalkDesc     = nil                                           -- 当前刷道的自动寻路信息
local lTeleportCount        = 0                                             -- 当前飞行的次数
local lTeleportMap          = nil                                           -- 当前飞行的地图
local lNotCheckMap          = false                                         -- 当前是否需要检查地图
local lShuaDCombatFailNum   = 0                                             -- 刷道战斗失败的次数

-- 弹出确认框无需中断寻路
local showConfirmNotStop = {
    ["checkDoubleByShuad"] = true,
    ["checkShuaDaoLingByShuad"] = true,
    ["be_add_friend"] = true,
    ["bianshen"] = true,
    ["jiuqu_linglongbi"] = true,
    ["request_leader"] = true,
    ["baozang"] = true,
}

local breakCheckCou = 0

-- 清理刷道数据
function StateShudMgr:resetData()
    lCurShuadTask           = nil
    lCurShuadWalkDesc       = nil
    lTeleportCount          = 0
    lTeleportMap            = nil
    lNotCheckMap            = false
    lShuaDCombatFailNum     = 0
end

-- 是否是刷道任务
function StateShudMgr:isShuadaoTask(taskType)
    -- 遍历判断是否是刷道任务
    for k, _ in pairs(lSHuadDefaultWalkDesc) do
        if k == taskType then
            return true
        end
    end

    return false
end

-- 尝试切换到刷道状态
function StateShudMgr:tryChangeToShuad(taskType)
    if not Me:isTeamLeader() then
        -- 不是队长
        return
    end

    if not self:isShuadaoTask(taskType) then
        -- 不是刷道任务
        return
    end

    -- 获取当前的刷道任务
    local task     = TaskMgr:getTaskByName(taskType)
    local oldState = StateMgr:getCurState()

    -- 记录当前自动刷道任务和自动寻路信息
    self:setLastShuadTask(taskType)
    if not task then
        -- 任务清除
        self:setLastShuadWalkDesc(lSHuadDefaultWalkDesc[taskType])
    else
        -- 有任务
        self:setLastShuadWalkDesc(task.task_prompt)
    end

    -- 当前不能进行地图检测
    -- 否则会出现马上切换回来的问题
    lNotCheckMap = true
    StateMgr:changeState(AUTO_OPER_STATE.SHUAD)
    lNotCheckMap = false

    if oldState ~= AUTO_OPER_STATE.SHUAD then
        -- 记录日志
        -- 目前不存在 降妖转伏魔的情况，故而不考虑
        self:logShuadbjbh(oldState, AUTO_OPER_STATE.SHUAD, "1", "")
    end
end

-- 尝试停止刷道状态
function StateShudMgr:tryStopShuad()
    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    StateMgr:changeState(AUTO_OPER_STATE.NORMAL)
end

-- 刷道状态
function StateShudMgr:updateCheck()
    local reason = "0"
    local reasonDetail = ""

    repeat
        if not Me:isTeamLeader() then
            -- 不是队长，不能进行自动刷道流程
            reason = "6"
            break
        end

        if Me:isLookOn() then
            -- 当前在观战中，记录日志
            -- 停止自动寻路
            Me:resetGotoEndPos()
            AutoWalkMgr:stopAutoWalk()
            reason = "16"
            break
        end

        if Me:isInCombat() then
            -- 如果当前处于战斗中
            return
        end

        if GameMgr:isInBackground() then
            -- 如果当前在后台，无需执行相应的逻辑
            return
        end

        if DlgMgr:isDlgOpened("LoadingDlg") then
            -- 如果是加载界面，则不触发
            return
        end

        if not GetTaoMgr:getRuYiZHLState()
            or GetTaoMgr:getRuYiZHLPoint() < 10 then
            -- 若如意刷道令不处于开启状态
            -- 或者如意刷道令点数 < 10
            -- 如果刷道点数增加，需要继续刷道
            return
        end

        -- 检查当前的地图
        local curShuadType = self:getLastShuadTask()
        if not lNotCheckMap and lTeleportCount <= 0 then
            -- 当前无需检查地图，并且不在过图状态
            -- 需要检查地图
            if curShuadType  then
                -- 有任务，需要判断一下当前地图是否一致
                local allMaps = lShuadMap[curShuadType]
                if not allMaps then
                    -- 找不到当前任务的地图列表
                    reason = "11"
                    reasonDetail = curShuadType
                    break
                end

                -- 有任务，判断地图是否一致
                local mapName = MapMgr:getCurrentMapName()
                if not allMaps[mapName] then
                    -- 当前地图不是刷道地图
                    reason = "8"
                    reasonDetail = mapName
                    break
                end
            else
                -- 没有选择的自动刷道任务
                reason = "9"
                break
            end
        end

        -- 检查当前拥有的刷道任务
        local curShuadTask = self:getCurHasShuadTask()
        if not curShuadTask then
            -- 当前没有任务
            -- 无需处理
        else
            -- 有任务，当时与点击自动寻路的任务不一致
            if curShuadTask ~= curShuadType then
                -- 当前任务已经变化，无需处理
                reason = "10"
                reasonDetail = string.format("curShuadType:%s,curShuadTask:%s", curShuadType or "", curShuadTask or "")
                break
            end
        end

        if DlgMgr:isDlgOpened("ConfirmDlg") then
            local dlg = DlgMgr:getDlgByName("ConfirmDlg")

            if showConfirmNotStop[dlg.confirm_type] then
                -- 部分确认框，无需处理
            else
                -- 确认框打开时
                return
            end
        end

        if GameMgr.isAntiCheat then
            -- 老君查岗中
            reason = "14"
            break
        end

        if TaskMgr:getTaskByName("老君发怒") then
            -- 老君发怒中
            reason = "15"
            break
        end

        -- 相当于自动点击
        -- 更新一下最后一次点击的时间，使之无法进行
        Log:D(">>>> update last touch time.")
        GameMgr:updateLastTouchTime()
        if GameMgr:isClientSilentStatus() then
            -- 当前处于静止状态
            -- 修改激活状态，并通知服务端
            GameMgr:setClientActiveStatus()
            GameMgr:sendClientStatus()
        end

        if Const.SA_STAND ~= Me.faAct then
            -- 如果当前不是站着的
            -- 无需处理
            return
        end

        if Me:isInTalkWithNpc() and breakCheckCou < 2 then
            breakCheckCou = breakCheckCou + 1
            return
        end

        breakCheckCou = 0

        -- 辅助自动寻路
        if curShuadTask then
            -- 如果当前有刷道任务
            -- 直接使用任务数据进行寻路
            local task = TaskMgr:getTaskByName(curShuadTask)
            self:setLastShuadWalkDesc(task.task_prompt)
            local autoWalkInfo = gf:findDest(task.task_prompt)
            autoWalkInfo.curTaskWalkPath = {}
            autoWalkInfo.curTaskWalkPath.task_type = task.task_type
            autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt
            AutoWalkMgr:beginAutoWalk(autoWalkInfo)
        else
            -- 使用上一次刷道的寻路信息
            local autoWalkDesc = self:getLastShuadWalkDesc()
            local autoWalkInfo = gf:findDest(autoWalkDesc)
            AutoWalkMgr:beginAutoWalk(autoWalkInfo)
        end

        return
    until false

    -- 通知服务端记录日志
    self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, reason, reasonDetail)

    -- 判断失败，则切换到正常状态
    self:tryStopShuad()
end

-- 获取当前拥有的刷道任务
function StateShudMgr:getCurHasShuadTask()
    -- 遍历判断是否拥有刷道任务
    for k, _ in pairs(lSHuadDefaultWalkDesc) do
        if TaskMgr:getTaskByName(k) then
            return k
        end
    end

    return nil
end

-- 获取最后一次点击刷道任务的数据
function StateShudMgr:getLastShuadTask()
    return lCurShuadTask
end

-- 设置刷道任务
function StateShudMgr:setLastShuadTask(taskType)
    lCurShuadTask = taskType
end

-- 获取最后一次刷道的寻路信息
function StateShudMgr:getLastShuadWalkDesc()
    return lCurShuadWalkDesc
end

-- 设置最后一次刷道的寻路信息
function StateShudMgr:setLastShuadWalkDesc(walkDesc)
    lCurShuadWalkDesc = walkDesc
end

-- 判断当前是否是自动刷道状态
function StateShudMgr:isShuadState()
    if StateMgr:getCurState() ~= AUTO_OPER_STATE.SHUAD then
        -- 当前不是自动刷道状态
        return false
    end

    return true
end

-- 获取服务端需要缓存的数据
function StateShudMgr:getServerUserStatePara()
    return self:getLastShuadTask()
end

-- 处理服务端发送过来切换状态的数据
function StateShudMgr:doWhenServerChangeState(data)
    if not data.para then
        return false
    end

    local task = TaskMgr:getTaskByName(data.para)
    if not task then
        -- 任务清除
        self:setLastShuadWalkDesc(lSHuadDefaultWalkDesc[data.para])
    else
        -- 有任务
        self:setLastShuadWalkDesc(task.task_prompt)
    end

    -- 设置自动刷道任务
    self:setLastShuadTask(data.para)
    return true
end

-- 切换状态事件
function StateShudMgr:doBeforeServerChangeState(data)
    if data.oldState == AUTO_OPER_STATE.SHUAD
        and data.toState == AUTO_OPER_STATE.NORMAL then
        -- 从刷道状态切换到正常状态
        -- 记录日志
        self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, nil, nil, data.logStr)
    end
end

-- 当任务刷新时
function StateShudMgr:doWhenTaskRefresh(data)
    if not data or not data.taskData then return end

    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    local task_type = data.taskData.task_type
    if not self:isShuadaoTask(task_type) then
        -- 不是刷道任务
        return
    end

    if task_type ~= self:getLastShuadTask() then
        -- 与当前的任务不一致
        return
    end

    local task_prompt = data.taskData.task_prompt
    if string.len(task_prompt) == 0 then
        -- 任务清除
        self:setLastShuadWalkDesc(lSHuadDefaultWalkDesc[task_type])
    else
        -- 有任务
        self:setLastShuadWalkDesc(task_prompt)
    end
end

-- 当触发自动行路时
function StateShudMgr:doWhenAutoWalk(data)
    if not data or not data.autoWalkData then return end

    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    local autoWalkDesc = self:getLastShuadWalkDesc()
    local curTaskType  = self:getLastShuadTask()
    if not autoWalkDesc then return end

    local autoWalkInfo = gf:findDest(autoWalkDesc)
    if not autoWalkInfo then return end

    if data.autoWalkData.curTaskWalkPath
        and data.autoWalkData.curTaskWalkPath.task_type == curTaskType then
        -- 同一个任务
        -- 无需处理
        return
    end

    if autoWalkInfo.npc == data.autoWalkData.npc then
        -- 不是同一个NPC
        return
    end

    local reasonDetail = ""
    for k, v in pairs(data.autoWalkData) do
        reasonDetail = reasonDetail .. tostring(k) .. ":" .. tostring(v) .. ";"
    end

    reasonDetail = reasonDetail .. ";curAutoWalkDesc:" .. autoWalkDesc

    -- 记录日志
    self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, "2", reasonDetail)

    -- 尝试停止刷道
    self:tryStopShuad()
end

-- 当点击地板时
function StateShudMgr:doWhenTouchMapBegin(data)
    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    -- 记录日志
    self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, "3", "")

    self:tryStopShuad()
end

-- 当队伍解散时
function StateShudMgr:doWhenTeamDismiss(data)
    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    -- 记录日志
    self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, "5", "")

    self:tryStopShuad()
end

-- 被顶号时
function StateShudMgr:doWhenOtherLogin(data)

end

-- 开始观战时
function StateShudMgr:doWhenStartLookon(data)
    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    -- 记录日志
    self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, "16", "")

    self:tryStopShuad()

    -- 停止自动寻路
    Me:resetGotoEndPos()
    AutoWalkMgr:stopAutoWalk()
end

-- 当向服务端发送自动寻路数据时
function StateShudMgr:doWhenCmdTeleport(data)
    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    if lTeleportMap == data.map_name then
        -- 防重入
        return
    end

    lTeleportCount = lTeleportCount + 1
    lTeleportMap = data.map_name

    -- 获取自动寻路信息
    local autoWalkDesc = self:getLastShuadWalkDesc()
    if not autoWalkDesc then return end

    local autoWalkInfo = gf:findDest(autoWalkDesc)
    if data.map_name == autoWalkInfo.map then
        -- 跟目的地一样，无需处理
        return
    end

    -- 记录日志
    self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, "13", "")

    self:tryStopShuad()
end

-- 获取当前状态的日志标志
-- 1- 空闲、2- 降妖、3- 伏魔
function StateShudMgr:getLogFlag(state)
    if AUTO_OPER_STATE.NORMAL == state then
        return "1"
    end

    if AUTO_OPER_STATE.SHUAD == state then
        if self:getLastShuadTask() == CHS[5120001] then
            -- 降妖
            return "2"
        elseif self:getLastShuadTask() == CHS[5120002] then
            -- 伏魔
            return "3"
        elseif self:getLastShuadTask() == CHS[5120005] then
            -- 飞仙渡邪
            return "4"
        end
    end

    return "0"
end

-- 获取日志标识
function StateShudMgr:getFailDetail(task_name)
    if task_name == CHS[5120001] then
        -- 降妖
        return "1"
    elseif task_name == CHS[5120002] then
        -- 伏魔
        return "2"
    elseif task_name == CHS[5120005] then
        -- 飞仙渡邪
        return "4"
    end

    return "-1"
end

-- 通知服务端记录日志
function StateShudMgr:logShuadbjbh(bef_state, aft_state, reason, reason_detail, para)
    local logStr

    if not para or "" == para then
        logStr = string.format("before:%s;after:%s;reason:%s;reason_detail:%s",
            self:getLogFlag(bef_state), self:getLogFlag(aft_state), reason, reason_detail)
    else
        logStr = string.format("before:%s;after:%s;%s",
            self:getLogFlag(bef_state), self:getLogFlag(aft_state), para)
    end

    gf:CmdToServer("CMD_RECORD_SHUAD_LOG", {
        action = "shuadbjbh",
        log_str = logStr,
    })
end

-- 进入房间的事件
function StateShudMgr:MSG_ENTER_ROOM(data)
    if not self:isShuadState() then
        -- 当前不是刷道状态
        return
    end

    if lTeleportCount > 0 then
        lTeleportCount = lTeleportCount - 1
    end

    lTeleportMap = nil
end

-- 刷道战斗失败消息
function StateShudMgr:MSG_SHUADAO_COMBAT_FAIL(data)
    if data.task_name == "PK" then
        -- 如果是 PK 战斗，直接记录日志即可
        self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, "7", "3")
        return
    end

    lShuaDCombatFailNum = lShuaDCombatFailNum + 1
    if lShuaDCombatFailNum >= 3 then
        -- 通知记录日志并停止自动刷道
        local log_str = self:getFailDetail(data.task_name)
        self:logShuadbjbh(AUTO_OPER_STATE.SHUAD, AUTO_OPER_STATE.NORMAL, "7", log_str)
        self:tryStopShuad()
    end
end

-- 刷道战斗成功消息
function StateShudMgr:MSG_SHUADAO_COMBAT_SUCC(data)
    lShuaDCombatFailNum = 0
end

MessageMgr:hook("MSG_ENTER_ROOM", StateShudMgr, "StateShudMgr")
MessageMgr:hook("MSG_SHUADAO_COMBAT_FAIL", StateShudMgr, "StateShudMgr")
MessageMgr:hook("MSG_SHUADAO_COMBAT_SUCC", StateShudMgr, "StateShudMgr")

-- 注册监听事件
EventDispatcher:addEventListener(EVENT.TASK_REFRESH,    function(data) StateShudMgr:doWhenTaskRefresh(data) end)
EventDispatcher:addEventListener(EVENT.AUTO_WALK,       function(data) StateShudMgr:doWhenAutoWalk(data) end)
EventDispatcher:addEventListener(EVENT.CMD_TELEPORT,    function(data) StateShudMgr:doWhenCmdTeleport(data) end)
EventDispatcher:addEventListener(EVENT.TOUCH_MAP_BEGIN, function(data) StateShudMgr:doWhenTouchMapBegin(data) end)
EventDispatcher:addEventListener(EVENT.TEAM_DISMISS,    function(data) StateShudMgr:doWhenTeamDismiss(data) end)
EventDispatcher:addEventListener(EVENT.OTHER_LOGIN,     function(data) StateShudMgr:doWhenOtherLogin(data) end)
EventDispatcher:addEventListener(EVENT.START_LOOKON,    function(data) StateShudMgr:doWhenStartLookon(data) end)

return StateShudMgr
