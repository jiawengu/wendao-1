-- CheckNetMgr.lua
-- Created by chenyq Aug/4/2017
-- 负责检测网络
-- 在自动更新阶段会使用该模块，此时还未加载 Singleton，故就不使用 Singleton()

local socket = require("socket")

CheckNetMgr = {}

local ICMP_TYPE_ECHO_REPLY = 0
local ICMP_TYPE_ECHO = 8
local ICMP_HEADER_MIN_LEN = 8

function CheckNetMgr:traceroute(cb, ip, maxTTL, timeout)
    if DeviceMgr:isIos() then
        self:_traceroute(cb, ip, maxTTL, timeout)
    elseif DeviceMgr:isAndroid() then
        maxTTL = maxTTL or 30   -- 默认做多尝试 30 个跃点
        timeout = timeout or 2  -- 默认超时为 2 秒
        local TRACE_MAX_TIMES = 3
        for i = 1, maxTTL do
            local info = string.format("%d:", i)
            local lastIp
            for j = 1, TRACE_MAX_TIMES do
                local t1 = gfGetTickCount()
                local pd = io.popen(string.format("ping -c 1 -w %d 10.2.51.97", timeout), "r")
                local info = pd:read("*a")
                pd:close()
                local t2 = gfGetTickCount()
                lastIp = self:parseIPFromPing(info)
                if lastIp then
                    info = info .. string.format("  %dms", t2 - t1)
                else
                    info = info .. "  timeout"
                end
            end

            if lastIp then
                info = info .. " " .. lastIp
            end
        end
        cb(info)
    else
        cb("error")
    end
end

function CheckNetMgr:parseIPFromPing(str)
    local startPos = string.find(str, "from ") or string.find(str, "From ")
    if startPos and #str > startPos + 5 then
        local endPos = string.find(str, ": ", startPos + 5)
        if endPos and endPos > 1 then
            local ip = string.sub(str, startPos + 5, endPos - 1)
            return ip
        end
    end
end

function CheckNetMgr:ping(cb, ip, count, timeout)
    if DeviceMgr:isIos() then
        self:_ping(cb, ip, count, timeout)
    elseif DeviceMgr:isAndroid() then
        count = count or 5      -- 默认发送 5 次
        timeout = timeout or 2  -- 默认超时未 2 秒
        local pd = io.popen(string.format("ping -c %d -w %d %s", count, timeout, ip), "r")
        local info = pd:read("*a")
        pd:close()
        cb(info)
    else
        count = count or 5      -- 默认发送 5 次
        timeout = timeout or 2  -- 默认超时未 2 秒
        local pd = io.popen(string.format("ping -n %d -w %d %s", count, timeout * 1000, ip), "r")
        local info = pd:read("*a")
        cb(gfGBKToUTF8(info))
    end
end

-- cb 回调函数，回调函数的参数是一个字符串
-- ip 要跟踪路由的 ip
-- maxTTL 做多尝试跃点数，默认 30
-- timeout 发送/接收数据的超时时间，默认 2 秒
function CheckNetMgr:_traceroute(cb, ip, maxTTL, timeout)
    maxTTL = maxTTL or 30   -- 默认做多尝试 30 个跃点
    timeout = timeout or 2  -- 默认超时为 2 秒

    cb("traceroute: " .. ip)
    local icmp, errorIcmp = socket:udp_icmp()
    if not icmp then
        cb("error: socket:udp_icmp() failed: " .. tostring(errorIcmp))
        return
    end

    icmp:settimeout(timeout)
    local TRACE_MAX_TIMES = 3
    local seq = 0
    for i = 1, maxTTL do
        local ret, errorMsg = icmp:setoption('ip-ttl', i)
        if 1 ~= ret then
            cb("error: icmp:setoption('ip-ttl', " .. tostring(i) .. ") failed: " .. tostring(errorMsg))
            break
        end

        local suc = false
        local id = os.time() % 65536
        local info = string.format("%d:", i)
        local lastIp
        for j = 1, TRACE_MAX_TIMES do
            seq = seq + 1
            local timeStart = gfGetTickCount()
            local data = self:makeIcmpEchoPacket(id, seq, timeStart, "0123")
            local ret, errorMsg = icmp:sendto(data, ip, 0)
            if not ret then
                cb(string.format("error: icmp:sendto %s failed: %s", ip, errorMsg))
                break
            end

            local data, errorMsgOrIp, port = icmp:receivefrom()
            local timeUsed = gfGetTickCount() - timeStart
            if data then
                info = info .. string.format("  %dms", timeUsed)
                lastIp = errorMsgOrIp
                if errorMsgOrIp == ip then
                    -- 收到指定 ip 的回复了
                    suc = true
                end
            elseif errorMsgOrIp == "timeout" then
                info = info .. "  timeout"
            else
                info = info .. string.format("  error:%s", errorMsgOrIp)
            end
        end

        if lastIp then
            info = info .. " " .. lastIp
        end

        cb(info)
        if suc then
            break
        end
    end

    icmp:close()
end

-- cb 回调函数，回调函数的参数是一个字符串
-- ip 要 ping 的 ip
-- count 发包次数，默认 5 次
-- timeout 发送/接收数据的超时时间，默认 2 秒
function CheckNetMgr:_ping(cb, ip, count, timeout)
    count = count or 5      -- 默认发送 5 次
    timeout = timeout or 2  -- 默认超时未 2 秒

    cb("ping " .. ip)
    local icmp, errorIcmp = socket:udp_icmp()
    if not icmp then
        cb("error: socket:udp_icmp() failed: " .. tostring(errorIcmp))
        return
    end

    icmp:settimeout(timeout)
    local id = os.time() % 65536
    for i = 1, count do
        local data = self:makeIcmpEchoPacket(id, i, gfGetTickCount(), "fedcba0123456789")
        local ret, errorMsg = icmp:sendto(data, ip, 0)
        if not ret then
            cb("error: icmp:sendto " .. tostring(ip) .. " failed: " .. tostring(errorMsg))
            break
        end

        local data, errorMsgOrIp, port = icmp:receivefrom()
        if data then
            local packet, errorMsg = self:parseIcmpPacket(data)
            if packet then
                if packet.icmpType ~= ICMP_TYPE_ECHO_REPLY then
                    cb("error: Not echo reply packet")
                else
                    local info = string.format("receive from %s: icmp_seq=%d bytes=%d TTL=%d TimeUsed=%d",
                        errorMsgOrIp, packet.icmpSeq, string.len(data), packet.ttl, gfGetTickCount() - packet.icmpTimestamp)
                    cb(info)
                end
            else
                cb("error: " .. errorMsg)
            end
        elseif errorMsgOrIp == "timeout" then
            cb("timeout")
        else
            cb("error: " .. errorMsgOrIp)
        end
    end

    icmp:close()
end

function CheckNetMgr:ipChecksum(buf)
    local len = string.len(buf)
    local i = 1
    local sum = 0
    while i < len do
        sum = sum + string.byte(buf, i) + string.byte(buf, i + 1) * 256
        i = i + 2
    end

    if i == len then
        sum = sum + string.byte(buf, i)
    end

    sum = math.floor(sum / 65536) + sum % 65536
    sum = sum + math.floor(sum / 65536)
    sum = 65535 - sum % 65536

    return sum
end

-- 组织 icmp echo 包
function CheckNetMgr:makeIcmpEchoPacket(id, seqNo, t, data)
    local buf = {}
    local tl = t % 65536
    local th = math.floor(t / 65536)
    local type = ICMP_TYPE_ECHO
    local code = 0
    buf[1] = string.char(type)
    buf[2] = string.char(code)
    buf[3] = string.char(0)
    buf[4] = string.char(0)
    buf[5] = string.char(id % 256)
    buf[6] = string.char(math.floor(id / 256))
    buf[7] = string.char(seqNo % 256)
    buf[8] = string.char(math.floor(seqNo / 256))
    buf[9] = string.char(tl % 256)
    buf[10] = string.char(math.floor(tl / 256))
    buf[11] = string.char(th % 256)
    buf[12] = string.char(math.floor(th / 256))

    local checksum = self:ipChecksum(table.concat(buf) .. data)
    buf[3] = string.char(checksum % 256)
    buf[4] = string.char(math.floor(checksum / 256))

    return table.concat(buf) .. data
end

function CheckNetMgr:parseIcmpPacket(buf)
    local packet = {}
    local bufLen = string.len(buf)
    if bufLen < 4 then
        return nil, "Invalid data"
    end

    local icmpData = buf
    packet.ipHeaderLen = string.byte(buf, 1) % 16 * 4
    if packet.ipHeaderLen > 0 then
        -- 含有 ip 头
        packet.tos = string.byte(buf, 2)
        packet.totalLen = string.byte(buf, 3) + string.byte(buf, 4) * 256 + packet.ipHeaderLen
        if bufLen < packet.totalLen then
            return nil, "Invalid data"
        end

        packet.ttl = string.byte(buf, 9)
        icmpData = string.sub(buf, packet.ipHeaderLen + 1, packet.totalLen)
    else
        packet.ttl = -1
    end

    local checksum = self:ipChecksum(icmpData)
    if checksum ~= 0 then
        return nil, "Checksum error"
    end

    packet.icmpType = string.byte(icmpData, 1)
    packet.icmpCode = string.byte(icmpData, 2)
    packet.icmpId = string.byte(icmpData, 5) + string.byte(icmpData, 6) * 256
    packet.icmpSeq = string.byte(icmpData, 7) + string.byte(icmpData, 8) * 256


    local tl = string.byte(icmpData, 9) + string.byte(icmpData, 10) * 256
    local th = string.byte(icmpData, 11) + string.byte(icmpData, 12) * 256
    packet.icmpTimestamp = tl + th * 65536

    return packet
end

function CheckNetMgr:getIpByHost(host)
    require "socket"
    local addr, _ = socket.dns.getaddrinfo(host)
    if addr and #addr > 0 then
        return addr[1].addr
    end

    return host
end

function CheckNetMgr:isEnabled()
    if DeviceMgr:isIos() then
        return nil ~= socket.udp_icmp
    else
        return true
    end
end

-- 上报网络异常
function CheckNetMgr:logReportNetCheck(data, callback)
    if not data then return end -- 没有数据可以上报

    local url = "http://logmonitor.leiting.com/wdNetCheckReport"
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('POST', url, true)

    local delayAction
    local runScene =  cc.Director:getInstance():getRunningScene()
    delayAction = performWithDelay(runScene, function()
        xhr = nil
        delayAction = nil
        if 'function' == type(callback) then
            callback({ status = "failed" })
        end
    end, 30)

    local function onReadyStateChange()
        runScene =  cc.Director:getInstance():getRunningScene()
        if delayAction and runScene then runScene:stopAction(delayAction) end
        if not xhr then return end

        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
        local info = json.decode(xhr.response)
        if 'function' == type(callback) then
            callback(info)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(string.format("params=%s", json.encode(data)))
end
