-- StateMgr.lua
-- Create by liuhb Sep/02/2017
-- 状态管理器
-- 主要用于各种客户端自动流程的操作

StateMgr = Singleton()

-- 状态处理函数
local lStateInfo = {
    [AUTO_OPER_STATE.NORMAL] = { ["module"] = "StateMgr" },
    [AUTO_OPER_STATE.SHUAD]  = { ["module"] = "StateShudMgr" },
}

-- 状态数据
local lCurState             = AUTO_OPER_STATE.NORMAL    -- 默认当前状态为正常的状态
local lScheduleId           = nil                       -- 启动当前的守护定时器

-- 初始化函数
function StateMgr:init()
    self:startSchedule()
end

-- 清除数据
function StateMgr:cleanup()
    -- 停止定时器
    self:stopSchedule()

    -- 直接进行重置数据操作
    -- 重连，重登，或者换线全部重置数据
    -- 由客户端进行通知切换状态
    self:resetAllData()
end

-- 重置数据
function StateMgr:resetAllData()
    for state, _ in pairs(lStateInfo) do
        self:callSubModulFunc(state, "resetData")
    end

    -- 重置状态
    lCurState = AUTO_OPER_STATE.NORMAL
end

-- 开始定时器
function StateMgr:startSchedule()
    if lScheduleId then
        gf:Unschedule(lScheduleId)
        lScheduleId = nil
    end

    lScheduleId = gf:Schedule(function() StateMgr:checkState() end, 3)
end

-- 停止定时器
function StateMgr:stopSchedule()
    if lScheduleId then
        gf:Unschedule(lScheduleId)
        lScheduleId = nil
    end
end

-- 检查当前状态的处理逻辑
function StateMgr:checkState()
    if not lCurState then return end

    -- 调用子模块函数
    self:callSubModulFunc(lCurState, "updateCheck")
end

-- 尝试切换状态
function StateMgr:changeState(toState)
    if lCurState == toState then
        -- 状态一致，无需处理
        return
    end

    local checkFlag = false
    for k, _ in pairs(lStateInfo) do
        if toState == k then
            checkFlag = true
            break
        end
    end

    if not checkFlag then
        -- 没有此状态，返回
        return
    end

    -- 修改当前状态
    lCurState = toState

    -- 通知服务端数据
    self:setServerUserState(lCurState)

    -- 切换状态成功，检查一下状态
    self:checkState()
end

-- 获取当前的状态
function StateMgr:getCurState()
    return lCurState
end

-- 告诉服务端当前的任务状态
function StateMgr:setServerUserState(state)
    local para = self:callSubModulFunc(state, "getServerUserStatePara")
    if not para then
        para = ""
    end

    gf:CmdToServer("CMD_SET_CLIENT_USER_STATE", {
        state = state,
        para  = para,
    })
end

-- 服务端通知切换状态
function StateMgr:MSG_CHANGE_ME_STATE(data)
    local ret = self:callSubModulFunc(data.toState, "doWhenServerChangeState", data)
    if false == ret then
        -- 子模块不允许切换
        -- 不包含nil的情况
        -- 通知服务端刷新当前状态
        self:setServerUserState(lCurState)
        return
    end

    data.oldState = lCurState
    self:callSubModulFunc(lCurState, "doBeforeServerChangeState", data)
    self:changeState(data.toState)
end

-- 正常状态
function StateMgr:updateCheck()
    -- 主要是清理各种状态
    self:resetAllData()
end

-- 调用模块的函数
function StateMgr:GlobalCall(mgr, func, paras)
    if "table" == type(_G[mgr]) and "function" == type(_G[mgr][func]) then
        return _G[mgr][func](_G[mgr], paras)
    end
end

-- 调用子模块的某个函数
function StateMgr:callSubModulFunc(state, func, paras)
    -- 获取状态处理逻辑
    local stateInfo = lStateInfo[state]
    if not stateInfo then return end

    if "string" == type(stateInfo.module) then
        -- 执行对应的回调
        return self:GlobalCall(stateInfo.module, func, paras)
    end
end

MessageMgr:regist("MSG_CHANGE_ME_STATE", StateMgr)

return StateMgr
