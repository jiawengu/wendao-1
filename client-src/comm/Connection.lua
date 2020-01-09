-- created by cheny Feb/02/2014
-- 通讯模块

require "socket"
local Msg = require "comm/global_send"
local CmdParser = require "comm/CmdParser"
local MsgParser = require "comm/MsgParser"
local GlobalSendNoPacket = require "cfg/GlobalSendNoPacket"
local json = require("json")
-- 数据包读写
local PACKET_READ = 1
local PACKET_WRITE = 2

-- 连接超时时间
local CONNECT_OUT_TIME = 10

-- 发送的数据包的buffer大小
local SEND_BUFFER_SIZE = 5 * 2^10

local g_socket_no = 100

local multiPacketInfo = nil

local Connection = class("Connection")

local function isDisableIPv6()
    local userDefault = cc.UserDefault:getInstance()
    if userDefault then
        return userDefault:getBoolForKey("disable_ipv6")
    end
end

-- 检测是否使用 ipv6
-- 返回值：isIpv6, host
local function checkIpv6(host)
    local isIpv6 = false
    if gf:isIos() and not isDisableIPv6() then
        -- iOS 中需要判断是使用 ipv6
        local addrInfo, err = socket.dns.getaddrinfo(host)
        if addrInfo then
            for k, v in pairs(addrInfo) do
                if v.family == "inet6" then
                    isIpv6 = true
                    host = v.addr
                    Log:I("Use IPv6!")
                    break;
                end
            end
        end
    end

    return isIpv6, host
end

-- 初始化
function Connection:ctor(isAAA, type)
    self.type = type or CONNECT_TYPE.NORMAL
    self.isAAA = isAAA
    self._socketObject = nil
    self._nextReceiveSize = Packet:GetHeaderLen()
    self._processHeader = true
    self._socketNo = g_socket_no
    self._cacheData = nil
    g_socket_no = g_socket_no + 1
    self.sendBuf = string.rep('\0', SEND_BUFFER_SIZE)
end

-- 非阻塞连接
local function _connect(tcp, host, port, onConnected, onDisconnected)
    if not tcp then return end

    tcp:settimeout(0)
    local startTime = os.time()

    local function _checkConn()
        local r, err = tcp:connect(host, port)
        if "closed" == err then                             -- 连接关闭
            if onDisconnected then onDisconnected() end
            return false, true
        elseif 1 == r or "already connected" == err then    -- 连接成功或连接已建立
            -- 连接成功
            if onConnected then onConnected() end
            return true, false
        elseif os.time() - startTime >= 10 then             -- 连接超时
            if onDisconnected then onDisconnected() end
            tcp:close()
            return false, true
        end
        return false, false
    end

    local checkLoop = nil
    checkLoop = function()
        GameMgr:registFrameFunc(FRAME_FUNC_TAG.CHECK_CONNECT, function()
            local conn, timeout = _checkConn()
            if conn or timeout then
                -- 连接上了，或者超时了，取消注册
                GameMgr:unRegistFrameFunc(FRAME_FUNC_TAG.CHECK_CONNECT)
            end
        end)
    end

    checkLoop()
end

-- 连接服务器，成功返回true，失败返回false
function Connection:connect(host, port)
    self.curHost = host

    local isIpv6 = false
    local netCheckLog = {}
    if gf:isIos() and not isDisableIPv6() then
        -- iOS 中需要判断是使用 ipv6
		local newHost
		local r, e = pcall(function() isIpv6, newHost = checkIpv6(host) end)
		if not r then
			-- 出错了，不转换
			isIpv6 = false
			Client:pushDebugInfo('checkIpv6 error: ' .. tostring(e))
			netCheckLog["getInto"] = "ipv4"
		else
			-- 使用转换后的地址
			netCheckLog["memo"] = string.format("ipv4:%s:%s", tostring(host), tostring(port))
			host = newHost
			netCheckLog["getInto"] = "ipv6"
		end
    else
        netCheckLog["getInto"] = "ipv4"
    end

    local tcp, e
    if isIpv6 then
        tcp, e = socket.tcp6()
    else
        tcp, e = socket.tcp()
    end

    netCheckLog["getIntoIp"] = host
    netCheckLog["getIntoPort"] = port

    if not tcp then
        Log:E(string.format("connection create tcp socket failed(error : %s)!", e))
        return
    end

    _connect(tcp, host, port, function()
        self:disconnect()
        self._socketObject = tcp
        tcp:settimeout(60)
        if self.isAAA then
            self:pushMsg({ MSG = 0xB036, result = true})
        else
            self:pushMsg({ MSG = 0x1366, result = true})
        end

        Log:D(":Connect to "..host..":"..port.." successfully. [ConnectType:" .. self.type .. "]")
    end, function()
        if self.isAAA then
            if CommThread:getConnectionAAA(self.type) == self then
                self:pushMsg({ MSG = 0xB036, result = false, netCheckLog = netCheckLog })
            end
        else
            if CommThread:getConnection(self.type) == self then
                self:pushMsg({ MSG = 0x1366, result = false, netCheckLog = netCheckLog })
            end
        end
    end)
    return true
end

-- 断开socket
function Connection:disconnect()
    if nil == self._socketObject then return end
    self._socketObject:close()
    self._socketObject = nil
    Log:D("disconnect socket.")
end

-- 是否已连接
function Connection:isConnected()
    return self._socketObject ~= nil
end

-- 发送数据
function Connection:sendBuffer(buffer, length)
    local sock = self._socketObject
    if nil == sock then
        return
    end

    -- 如果连接失败，则直接返回登录界面
    if not sock:send(buffer, 1, length) then
        self._socketObject = nil
        self:pushMsg({ MSG = 0x1368, isAAA = self.isAAA})
        return
    end
end

-- 接收数据
function Connection:receive()
    local sock = self._socketObject
    if sock == nil then
        --Log:D("COM DEBUG: Connection:receive[sock == nil]")
        return
    end

    if not gf:isWindows() then
        -- 非windows下的操作
        if sock:getfd() >= socket._SETSIZE then
            Log:D(string.format("Socket fd(%d) is larger then %d", sock:getfd(), socket._SETSIZE))
            Client:pushDebugInfo(string.format("Socket fd(%d) is larger then %d", sock:getfd(), socket._SETSIZE))
            self._socketObject = nil
            self:pushMsg({ MSG = 0x1368, isAAA = self.isAAA})
            return
        end
    end

    local forread, _, _ = socket.select({sock}, nil, 0)

    for _, v in ipairs(forread) do
        if v ~= sock then
            Log:D("COM DEBUG: Connection:receive[Socket:select]")
            return
        end

        -- 每次最多取 6K 字节
        local maxSizePerTime = 6 * 1024
        local canReceiveSize = maxSizePerTime

        -- 计算缓冲区现在的数据大小
        local cacheDataLen = 0
        if  nil ~= self._cacheData then
            cacheDataLen = string.len(self._cacheData)
        else
            cacheDataLen = 0
        end

        -- 计算本次要从 socket 读取的数据大小
        if self._nextReceiveSize - cacheDataLen <= maxSizePerTime then
            -- 剩余的要从 socket 中读取的数据小于单次能读取的数据，则全部读取
            canReceiveSize = self._nextReceiveSize - cacheDataLen
        else
            -- 读取的大小为单次能读取的最大值
            canReceiveSize = maxSizePerTime
        end

        local s, e, s2 = sock:receive(canReceiveSize)

        if (e == 'closed') then
            -- 连接断开
            Log:D("Socket status is : " .. e .. ' [ConnectType:' .. tostring(self.type) .. ']')
            Client:pushDebugInfo("Socket status is : " .. e .. ' [ConnectType:' .. tostring(self.type) .. ']')
            self._socketObject = nil
            self:pushMsg({ MSG = 0x1368, isAAA = self.isAAA})
            return
        end

        --Log:D("COM DEBUG: Connection:receive[sock:receive] "

        --if self._nextReceiveSize ~= nil then
        --    Log:D("receive size is "..self._nextReceiveSize)
        --else
        --    Log:D("receive size is nil")
        --end

        if e ~= nil then
            -- 此时收到的部分数据存放在 s2 中
            s = s2
            --Log:D("receive result is "..e)
        else
            --Log:D("receive result is nil")
        end

        --if s ~= nil then
            --Log:D("receive buffer's length is "..string.len(s))
        --else
           --Log:D("receive buffer s is nil")
        --end

        if s == nil then
            return
        end

        if self._cacheData == nil then
            self._cacheData = s
        else
            self._cacheData = self._cacheData..s
        end

        if self._cacheData == nil then
            return
        end

        if string.len(self._cacheData) < self._nextReceiveSize then
            return
        end

        return self:onReceiveData(self._cacheData)
        --end
    end
end

function Connection:pushMsg(msg)
    msg.connect_type = self.type
    MessageMgr:pushMsg(msg)
end

-- 接收数据后处理
function Connection:onReceiveData(data)
    if nil == data then
        return 0
    end

    -- 从缓冲内存中取当前数据包的数据
    local size = self._nextReceiveSize

    -- 统计收到的数据大小
    Client:addRecvDataSize(size)

    if string.len(self._cacheData) == size then
        -- 全部取完
        self._cacheData = nil
    else
        -- 剩余数据，从中截取一段
        self._cacheData = string.sub(self._cacheData, size + 1, -1)
    end

    if self._processHeader then
        -- 正在接收消息头
        self._nextReceiveSize = string.byte(data, -2)*(2^8) + string.byte(data, -1)
        self._processHeader = false

        --Log:D("COM DEBUG: Connection:onReceiveData[_processHeader] size is["..size.."] next size is["..self._nextReceiveSize.."]")
        return size
    else
        -- 正在接收数据
        self._nextReceiveSize = Packet:GetHeaderLen()
        self._processHeader = true

        --Log:D("COM DEBUG: Connection:onReceiveData[_processBody] size is:"..size)
        return size, self:parseData(data)
    end
end

function Connection:MSG_PREPARE_MULTI_PACKET(pkt, data)
    if multiPacketInfo then
        Log:W("MSG_PREPARE_MULTI_PACKET error")
        return
    end

    local msg = pkt:GetShort()
    local totalNum = pkt:GetShort()
    local totalLen = pkt:GetLong()

    multiPacketInfo = {}
    multiPacketInfo.msg = msg
    multiPacketInfo.totalNum = totalNum
    multiPacketInfo.totalLen = totalLen
    multiPacketInfo.buf = {}
    multiPacketInfo.receiveLen = 0
end

function Connection:MSG_SEND_MULTI_PACKET(data)
    if not multiPacketInfo or not next(multiPacketInfo) then
        Log:W("MSG_SEND_MULTI_PACKET error")
        return
    end

    local b3, b4 = string.byte(data, 3, 4)
    local bufLen = (b3 or 0) * 256 + (b4 or 0)
    local binaryStr = string.sub(data, 5, 4 + bufLen)
    table.insert(multiPacketInfo.buf, binaryStr)
    multiPacketInfo.receiveLen = multiPacketInfo.receiveLen + #binaryStr
    if multiPacketInfo.receiveLen == multiPacketInfo.totalLen then
        multiPacketInfo.buf = table.concat(multiPacketInfo.buf)
        local data = Connection:parseData(multiPacketInfo.buf)
        multiPacketInfo = nil
        return data
    end
end

-- 解析数据
function Connection:parseData(data)
    -- MSG_SEND_MULTI_PACKET 的数据量较大，如果使用 Packet 进行解析，非常耗时
    -- 所以根据 data 中的数据直接解析
    local b1, b2 = string.byte(data, 1, 2)
    local msg = b1 * 256 + b2
    local msgStr = Msg[msg]
    if msgStr == 'MSG_SEND_MULTI_PACKET' then
        return  self:MSG_SEND_MULTI_PACKET(data);
    end

    local pkt = Packet:New(data, string.len(data), PACKET_READ)
    local ret = self:parsePacket(pkt, data)
    pkt:Destroy()
    return ret
end

function Connection:parsePacket(pkt, rawData)
    local msg = pkt:GetShort()
    local msgStr = Msg[msg]
    if nil == msgStr then
        -- 没有定义该消息
        --Log:D("COM DEBUG: Connection:parseData[msg_str==nil] No msg %04X in Msg.", msg)
        Log:W(string.format("No msg %04X in global_send.", msg))
        return
    end

    if ATM_IS_DEBUG_VER and msgStr ~= 'MSG_REPLY_ECHO' then
        Log:D("[RECV MSG : ".. msgStr .."]" .. '  [ConnectType:' .. tostring(self.type) .. ']')
    end

    if msgStr == 'MSG_PREPARE_MULTI_PACKET' then
        return self:MSG_PREPARE_MULTI_PACKET(pkt, {});
    end

    -- 解析消息
    local func = MsgParser[msgStr]
    if nil == func then
        if GlobalSendNoPacket[msgStr] then
            func = MsgParser["MSG_NO_PACKET"]
        else
            -- 没有解析函数
            Log:W(msgStr.." has no parser in MsgParser.")
            return
        end

    end

    local data = {
        MSG = msg,
        socket_no = self._socketNo,
        timestamp = gfGetTickCount(),
        connect_type = self.type,
    }
    func(MsgParser, pkt, data, rawData)

    if ATM_IS_DEBUG_VER and msgStr ~= 'MSG_REPLY_ECHO' then
       -- 打印log
       gf:PrintMap(data)
    end

    return data
end

-- 发送命令给服务器
function Connection:sendCmdToServer(cmd, data)
    local size = SEND_BUFFER_SIZE
    local buf = self.sendBuf
    local pkt = Packet:New(buf, size, PACKET_WRITE)

    -- 初始化数据包
    pkt:PutChar(string.byte('M'))
    pkt:PutChar(string.byte('Z'))
    pkt:PutShort(0)
    pkt:PutLong(gfGetTickCount())
    pkt:PutShort(0)
    local cmd_int = Cmd[cmd]
    if nil == cmd_int then
        -- 没有定义该命令
        Log:W("No cmd "..cmd.." in global_send.")
        pkt:Destroy()
        return
    end
    pkt:PutShort(cmd_int)

    if ATM_IS_DEBUG_VER and cmd ~= 'CMD_ECHO' then
       Log:D("[SEND CMD : " ..cmd.. "]"  .. '  [ConnectType:' .. tostring(self.type) .. ']')
    end

    -- 解析命令，放入数据
    local func = CmdParser[cmd]

    if nil == func then
        if GlobalSendNoPacket[cmd] then
            func = CmdParser["CMD_NO_PACKET"]
        else
            -- 没有解析函数
            Log:W(cmd.." has no parser in CmdParser.")
            pkt:Destroy()
            return
        end
    end

    if nil ~= data then
      local vv=json.encode(data)
     -- local v=gfGetMd5(json.encode(data))
     -- data["v"]=v
      --            pkt:PutLenString(v)
        -- if  cmd~='CMD_SORT_PACK'  then
        --     data["check"]=vv
        --     pkt:PutLenString(vv)
        --     --系统时间
        --     local ttt=gf:getServerTime()
        --     data["ttt"]=ttt
        --     pkt:PutLenString(ttt)
        -- end
        
        func(CmdParser, pkt, data)
    end

    -- 发送命令
    pkt:SetMsgLen()
    local len = Packet:GetHeaderLen() + pkt:GetMsgLen()
    self:sendBuffer(buf, len)

    -- 统计发送的数据大小
    Client:addSendDataSize(len)

    if ATM_IS_DEBUG_VER and cmd ~= 'CMD_ECHO' then
       -- 打印log
       gf:PrintMap(data)
    end

    pkt:Destroy()
end

return Connection
