-- created by cheny Feb/13/2014
-- 通讯模块协程

local Connection = require "comm/Connection"

CommThread = {}

CommThread._connection = {}
CommThread._connectionAAA = {}

function CommThread:loop(isAll)
    for _, v in pairs(self._connection) do
        self:receiveMsg(v, isAll)
    end

    for _, v in pairs(self._connectionAAA) do
        self:receiveMsg(v, isAll)
    end

   --[[ while true do
        local conn = self._connection
        if conn == nil then break end

        -- 接收消息，直到没有数据
        local size = 0
        local data = nil
        while size ~= nil do
            -- 接收消息
            size, data = conn:receive()
            -- 放入消息队列
            MessageMgr:pushMsg(data)
        end

        -- 同步消息保持连接
        Client:tryToKeepAlive(conn)
        return
    end]]
end

function CommThread:getConnection(type)
    type = type or CONNECT_TYPE.NORMAL
    return self._connection[type]
end

function CommThread:getConnectionAAA(type)
    type = type or CONNECT_TYPE.NORMAL
    return self._connectionAAA[type]
end

function CommThread:receiveMsg(conn, isAll)
    while true do
        --local conn = self._connection
        if conn == nil then break end

        -- 接收消息，直到没有数据或超过最大读取值
        local size = 0
        local maxSize = 6 * 1024
        local data = nil
        while size ~= nil and (isAll or maxSize > 0) do
            -- 接收消息
            size, data = conn:receive()
            -- 放入消息队列
            MessageMgr:pushMsg(data)

            maxSize = maxSize - (size or 0)
        end

        -- 同步消息保持连接
        if conn.type == CONNECT_TYPE.NORMAL then
            Client:tryToKeepAlive(conn)
        end
        return
    end
end

-- 开始通讯
function CommThread:start(ip, port, type)
    type = type or CONNECT_TYPE.NORMAL

    -- 将重新创建连接前，要先把消息队列里的 MSG_CLIENT_DISCONNECTED 清除
    MessageMgr:deleteMsg("MSG_CLIENT_DISCONNECTED", type)

    -- 新建连接，连接是阻塞操作，需要延后执行，以便能够切换界面
    self._connection[type] = Connection.new(nil, type)

    if GameMgr:isInBackground() then
        self._connection[type]:connect(ip, port)
    else
        DlgMgr:openDlg("WaitDlg")
        performWithDelay(gf:getUILayer(), function()
            if self._connection[type] then
                self._connection[type]:connect(ip, port)
            end
        end, 0.2)
    end
end

function CommThread:getConnectionIp(type)
    type = type or CONNECT_TYPE.NORMAL

    if self._connection[type] and self._connection[type]._socketObject then
        return self._connection[type].curHost
    end
end

-- 结束通讯
function CommThread:stop(type)
    type = type or CONNECT_TYPE.NORMAL
    if self._connection[type] ~= nil then
        self._connection[type]:disconnect()
        self._connection[type] = nil

        if type == CONNECT_TYPE.NORMAL then
            Client._isConnectingGS = false
        end
    end
end

function CommThread:isConnectAAA(type)
    type = type or CONNECT_TYPE.NORMAL

    if not self._connectionAAA[type] or not self._connectionAAA[type]:isConnected() then
        return false
    end

    return true
end

-- 开始通讯
function CommThread:startAAA(ip, port, type)
    type = type or CONNECT_TYPE.NORMAL

    -- 将重新创建连接前，要先把消息队列里的 MSG_CLIENT_DISCONNECTED 清除
    MessageMgr:deleteMsg("MSG_CLIENT_DISCONNECTED", type)

    -- 新建连接，连接是阻塞操作，需要延后执行，以便能够切换界面
    DlgMgr:openDlg("WaitDlg")
    self._connectionAAA[type] = Connection.new(true, type)

    performWithDelay(gf:getUILayer(), function()
        if self._connectionAAA[type] then
            self._connectionAAA[type]:connect(ip, port)
        end
    end, 0.2)
end

-- 结束通讯
function CommThread:stopAAA(type)
    type = type or CONNECT_TYPE.NORMAL
    if self._connectionAAA[type] ~= nil then
        self._connectionAAA[type]:disconnect()
        self._connectionAAA[type] = nil
    end
end

function CommThread:getConnectionAAAIp(type)
    type = type or CONNECT_TYPE.NORMAL
    if self._connectionAAA[type] and self._connectionAAA[type]._socketObject then
        return self._connectionAAA[type].curHost
    end
end

return CommThread
