-- MessageMgr.lua
-- created by cheny Feb/20/2014
-- 消息管理器

local Msg = require "comm/global_send"

MessageMgr = Singleton()

-- 需要延迟到战斗后处理的消息
local CNMSG = {
    -- 只在收到战斗结束消息后，且客户端还未结束战斗时
    ["MSG_UPDATE_CHILDS"] = 1,
    ["MSG_SET_COMBAT_CHILD"] = 1,
    ["MSG_UPDATE_PETS"] = 1,
    ["MSG_UPDATE"] = 1,
    ["MSG_UPDATE_IMPROVEMENT"] = 1,
    ["MSG_LEVEL_UP"] = 1,
    ["MSG_REFRESH_PET_GODBOOK_SKILLS"] = 1,
    ["MSG_UPDATE_APPEARANCE_FIELDS"] = 1,
    ["MSG_UPDATE_SKILLS"] = 1,
    ["MSG_UPDATE_APPEARANCE"] = 1,
    ["MSG_SET_OWNER"] = 1,
    ["MSG_SET_CURRENT_PET"] = 1,
    ["MSG_TASK_PROMPT"] = 1,
    ["MSG_AUTO_WALK"] = 1,
    ["MSG_PET_ICON_UPDATED"] = 1,
}

-- 后面需要执行换线的消息
local SWITCH_SERVER_MSG =
{
    ["MSG_SPECIAL_SWITCH_SERVER"] = 1,
    ["MSG_SWITCH_SERVER"] = 1,
    ["MSG_SWITCH_SERVER_EX"] = 1,
}


local UNDISCARD_MSG =
{
    ["MSG_FRIEND_ADD_CHAR"] = 1,
    ["MSG_MAILBOX_REFRESH"] = 1,
    ["MSG_ADD_NPC_TEMP_MSG"] = 1,
    ["MSG_NOTIFICATION"] = 1,
}

-- 一帧处理的
local MAX_NUM_PER_FRAME = 50

MessageMgr.msgQueue = {}
MessageMgr.undiscardMsgQueue = {}
MessageMgr.callbacks = {}
MessageMgr.hooks = {}
MessageMgr.hookers = {}
MessageMgr.syncMsgs = {}
MessageMgr.id = 1
MessageMgr.hook_index = 1
MessageMgr.isFirstLoad = true
MessageMgr.msgIndex = nil
MessageMgr.combatMsgIndex = nil

MessageMgr.combatNormalMsgs = {} -- 战斗中的更新数据消息

-- 消息名字到消息编号的映射信息
MessageMgr.msgName2No = {}
for k, v in pairs(Msg) do
    MessageMgr.msgName2No[v] = k
end

-- 添加战斗中更新数据消息
function MessageMgr:addCNMsg(msgData)
    table.insert(self.combatNormalMsgs, msgData)
end

-- 执行所有的战斗中的更新数据消息
function MessageMgr:processAllCNMsgs()
    for i = 1, #self.combatNormalMsgs do
        local msgData = self.combatNormalMsgs[i]

        gf:PrintMap(msgData)
        self:callCallbackHook(msgData)
    end

    self.combatNormalMsgs = {}
end

-- 尝试添加进战斗更新数据消息队列
function MessageMgr:tryAddToCNMsgsList(msgData)
    if msgData and msgData.MSG and Msg[msgData.MSG] and CNMSG[Msg[msgData.MSG]] then
        self:addCNMsg(msgData)
        return true
    end

    return false
end

-- 添加同步消息
function MessageMgr:addSyncMsg(msgData)
    local key = msgData.MSG * 10000 + self.id
    if self.syncMsgs[key] then
        Log:W('key:' .. key .. ' already exists in MessageMgr:addSyncMsg')
    end

    self.syncMsgs[key] = msgData

    self.id = self.id + 1
    if self.id >= 10000 then
        self.id = 1
    end

    return key
end

-- 执行不可丢弃的消息
function MessageMgr:processUnDiscardMsg()
    local function popMsgQueue()
        return table.remove(self.undiscardMsgQueue, 1)
    end

    local map = popMsgQueue(self)
    local i = 0
    while map ~= nil do
        table.insert(self.msgQueue, map)
        map = popMsgQueue()
    end
end

-- 执行同步消息
function MessageMgr:processSyncMsg(key)
    key = tonumber(key)
    if not self.syncMsgs[key] then
        Log:W('Not found sync msg by key:' .. key)
        return
    end

    local data = self.syncMsgs[key]
    gf:PrintMap(data)
    self:callCallbackHook(data)

    self.syncMsgs[key] = nil
end

-- 删除指定的同步消息
function MessageMgr:deleteSyncMsg(key)
    key = tonumber(key)
    if not self.syncMsgs[key] then
        Log:W('Not found sync msg by key:' .. key)
        return
    end

    self.syncMsgs[key] = nil
end

-- 删除所有的同步消息
function MessageMgr:deleteAllSyncMsg()
    self.syncMsgs = {}
    self.id = 1
end

-- 打印队列中的消息
function MessageMgr:print()
    for _, v in pairs(self.msgQueue) do
        Log:D("================")
        gf:PrintMap(v)
        Log:D("================")
    end
end

-- 获取最近所在地图的 id
function MessageMgr:getLastMapId()
    return MapMgr:getCurrentMapId()
end

function MessageMgr:ignoreMsg(msgName)
    if self.ignoreBeforeLoginDone then
        if 'MSG_LOGIN_DONE' == msgName or 'MSG_C_START_COMBAT' == msgName or 'MSG_LC_START_LOOKON' == msgName then
            self.ignoreBeforeLoginDone = nil
        elseif FightMgr[msgName] and 'MSG_GENERAL_NOTIFY' ~= msgName then
            return true
        end
    end
end

-- 客户端模拟服务器给自己发送 MSG
function MessageMgr:localPushMsg(msgName, data)
    if not self.msgName2No[msgName] then
        Log:W('Invalid msg name: ' .. msgName)
        return
    end

    data['MSG'] = self.msgName2No[msgName]
    self:pushMsg(data)
end

function MessageMgr:markRecvEndCombat(flag)
    self.recvEndCombatMark = flag
end

-- 添加消息到队尾
function MessageMgr:pushMsg(map)
    if map == nil then
        return
    end

    local msgName = Msg[map['MSG']]

    if self:ignoreMsg(msgName) then return end

    -- 如果是MSG_CLIENT_DISCONNECTED消息，那么前面一条如果是换线消息，则抛弃之
    if msgName == 'MSG_CLIENT_DISCONNECTED' then
        if #self.msgQueue >= 1 then
            local preMap = self.msgQueue[#self.msgQueue]
            local preMsgName = Msg[preMap['MSG']]
            if SWITCH_SERVER_MSG[preMsgName] then
                -- 如果是换线消息，则不需要处理
                return
            end
        end
    end

    if GameMgr:isInBackground() or self.isInBackground then
        -- 切换到后台了
        if msgName == 'MSG_CLIENT_DISCONNECTED' then
            -- 收到了断开连接的信息，清空所有缓存的信息
            GameMgr.canRefreshUserData = nil
            self:clearMsg()
            if DistMgr:getSwitchServerData() then
                MessageMgr:callCallbackHook(map)
                return
            end
        elseif msgName == 'MSG_ENTER_ROOM' then
            GameMgr.canRefreshUserData = true
        elseif msgName == 'MSG_CLIENT_CONNECTED' then
            self:clearMsgQueue()
            if map.result then
                MessageMgr:callCallbackHook(map)
                return
            end
        elseif UNDISCARD_MSG[msgName] then
            table.insert(self.undiscardMsgQueue, map)
            return
        elseif (msgName == "MSG_NOTIFY_MISC" or msgName == "MSG_NOTIFY_MISC_EX" or msgName == "MSG_MESSAGE" or msgName == "MSG_MESSAGE_EX" or msgName == "MSG_PERFORMANCE" or msgName == "MSG_ACHIEVE_CONFIG") then -- 后台性能统计信息
            MessageMgr:callCallback(map)
            return
        elseif SWITCH_SERVER_MSG[msgName]  then -- 换线消息
            self:clearMsgQueue()
            MessageMgr:callCallbackHook(map)
            return
        elseif msgName == 'CMD_ECHO' or msgName == 'MSG_REPLY_ECHO' then
            -- ECHO 相关消息，直接处理
            MessageMgr:callCallbackHook(map)
            return
        elseif FightMgr[msgName] and 'MSG_GENERAL_NOTIFY' ~= msgName and 'MSG_UPDATE' ~= msgName and 'MSG_SYNC_MESSAGE' ~= msgName then
            GameMgr.canRefreshUserData = true
        end

        map.receiverInBackground = true
    end

    if 'MSG_C_START_COMBAT' == msgName or 'MSG_LOGIN_DONE' == msgName then
        -- 客户端是先读取消息数据，再执行。
        -- 在 执行 MSG_LOGIN_DONE 消息时，会执行 GameMgr:onEndCombat() 清除此标记。
        -- 由于在读取消息时是成片数据执行的，所以在此处优先执行清除标记的操作。
        -- 否则会导致 MSG_LOGIN_DONE 后续的消息被插入到战斗结束队列中，在执行 GameMgr:onEndCombat() 时会被一同清除。
        -- 具体任务 WDSY-30095
        -- 取消标记
        MessageMgr:markRecvEndCombat()
    elseif 'MSG_C_END_COMBAT' == msgName then
        -- 标记
        MessageMgr:markRecvEndCombat(true)
    end

    if Me:isInCombat() and self.recvEndCombatMark then
        -- 战斗中的消息，需要同步执行
        if MessageMgr:tryAddToCNMsgsList(map) then
            -- 插入成功
            return
        end
    end

    table.insert(self.msgQueue, map)

    -- 尝试记录战斗中的消息
    DebugMgr:recordFightMsg(msgName, map)
end

-- 删除消息队列中还未处理的指定消息
function MessageMgr:deleteMsg(strMsg, conType)
    for i = #self.msgQueue, 1, -1 do
        if Msg[self.msgQueue[i]['MSG']] == strMsg and (not conType or not self.msgQueue[i]['connect_type'] or conType == self.msgQueue[i]['connect_type'])then
            table.remove(self.msgQueue, i)
        end
    end
end

-- 取出队头的消息
function MessageMgr:popMsg()
    return table.remove(self.msgQueue, 1)
end

-- 清空所有消息
function MessageMgr:clearMsg()
    MessageMgr.msgQueue = {}
    self.undiscardMsgQueue = {}
    MessageMgr.syncMsgs = {}
    MessageMgr.isInBackground = false
    MessageMgr.ignoreBeforeLoginDone = nil
end

function MessageMgr:clearMsgQueue()
    MessageMgr.msgQueue = {}
    MessageMgr.syncMsgs = {}
    MessageMgr.undiscardMsgQueue = {}
end

-- 注册消息回调
function MessageMgr:regist(msg, func)
    Log:D("Regist " .. msg)
    if type(func) == "function" then
        self.callbacks[msg] = func
    elseif (type(func) == "table" or type(func) == "userdata") then
        local class = func
        func = class[msg]
        if func ~= nil then
            self.callbacks[msg] = function(map) func(class, map) end
        end
    end
end

-- 注册消息钩子
-- hooker ：一般为对话框名字或者管理器名字，需要保证全局唯一
function MessageMgr:hook(msg, func, hooker)
    local list = self.hooks[msg]
    if list == nil then
        list = {}
        self.hooks[msg] = list
    end

    local handler = self.hook_index
    if type(func) == "function" then
        list[handler] = func
    elseif (type(func) == "table" or type(func) == "userdata") then
        local class = func
        func = class[msg]
        if func ~= nil then
            list[handler] = function(map) func(class, map) end
        end
    end
    self.hook_index = handler + 1
    Log:D("Hook " .. msg)

    -- 保存 type 注册的 hook 信息
    list = self.hookers[hooker]
    if not list then
        list = {}
        self.hookers[hooker] = list
    end

    table.insert(list, {msg, handler})

    return handler
end

-- 取消消息钩子
function MessageMgr:unhook(msg, handler)
    if nil == handler then return end

    local list = self.hooks[msg]
    if list ~= nil then
        list[handler] = nil
        Log:D("Unhook " .. msg)
    end
end

-- 取消某一类的消息钩子
function MessageMgr:unhookByHooker(hooker)
    local list = self.hookers[hooker]
    if not list then
        return
    end

    for _, info in pairs(list) do
        self:unhook(info[1], info[2])
    end

    self.hookers[hooker] = nil
end

function MessageMgr:callCallbackHook(map)
    if not map or self.msgDelayAction then
        return
    end

    local str = Msg[map["MSG"]]
    if str ~= nil then
        if str == "MSG_ENTER_ROOM" and map.enter_effect_index and map.enter_effect_index > 0 then
            -- 进入场景需要播放过图特效时，需要延迟一帧再把消息分发出去，保证当前场景截图正常
            EnterRoomEffectMgr:initScene(true)
            self.msgDelayAction = performWithDelay(gf:getUILayer(), function()
                MessageMgr:callCallbackAndHook(map)
                self.msgDelayAction = nil
            end, 0.1)
        else
            MessageMgr:callCallbackAndHook(map)
        end
    end
end

function MessageMgr:callCallbackAndHook(map)
    if not map then
        return
    end

    local str = Msg[map["MSG"]]
    if str ~= nil then
        local callback = self.callbacks[str]
        if callback ~= nil and type(callback) == "function" then
            callback(map)
        else
            Log:W(str .. " has no callback func.")
        end
        local hook_list = self.hooks[str]
        if hook_list ~= nil then
            for _, hook in pairs(hook_list) do
                if hook ~= nil and type(hook) == "function" then
                    hook(map)
                end
            end
        end
    end
end

function MessageMgr:callCallback(map)
    if not map then
        return
    end

    local str = Msg[map["MSG"]]
    if str ~= nil then
        local callback = self.callbacks[str]
        if callback ~= nil and type(callback) == "function" then
            callback(map)
        else
            Log:W(str .. " has no callback func.")
        end
    end
end

-- 处理队列中的消息，callback, hook, hook, hook...
function MessageMgr:process(processAll)
    if self.msgDelayAction then return end

    local i = 1
    local callCallbackHook = MessageMgr.callCallbackHook
    local popMsg = MessageMgr.popMsg
    local map = popMsg(self)

    while map ~= nil do
        callCallbackHook(self, map)

        i = i + 1

        -- 从后台切换回来后有可能会积压很多数据包，故需要限制一下每次处理的数量
        if not processAll and i > MAX_NUM_PER_FRAME then
            break
        end

        if self.msgDelayAction then return end

        map = popMsg(self)
    end
end

function MessageMgr:onEnterBackground()
    MessageMgr.isInBackground = true
    DebugMgr:addClientStatusLog("MessageMgr:onEnterBackground:" .. tostring(MessageMgr.isInBackground))-- WDSY-27195
end

EventDispatcher:addEventListener("ENTER_BACKGROUND", MessageMgr.onEnterBackground)

return MessageMgr
