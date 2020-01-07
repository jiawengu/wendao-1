-- StatisticsMgr.lua
-- Created by sujl, Feb/16/2017
-- 性能统计管理器

StatisticsMgr = Singleton()

local KEY_OF_LOCAL_VERSION = "local-version"

local lastSendTime = 0
local WARNING_MEM_SIZE = 500        -- 预警内存
local SEND_INTERVAL = 5 * 60 * 1000 -- 发送间隔

-- 计算帧率
function StatisticsMgr:calcFrameRate()
    self.lastTick = self.curTick
    self.curTick = gf:getTickCount()
end

-- 重置帧率
function StatisticsMgr:resetCurTick()
    self.curTick = gfGetTickCount()
end

-- 帧率
function StatisticsMgr:frameRate()
    if GameMgr:isInBackground() then return 0 end
    local t = (self.curTick or 0) - (self.lastTick or 0)
    local f,_ = math.modf(1000 / t)
    return f
end

-- 帧消耗时间(ms)
function StatisticsMgr:secondsPerFrame()
    if GameMgr:isInBackground() then return 0 end
    local t = (self.curTick or 0) - (self.lastTick or 0)
    local secs, _ = math.modf(t)
    return secs
end

-- 当前所在地图
function StatisticsMgr:mapId()
    return MapMgr:getCurrentMapId()
end

-- 当前所在坐标
function StatisticsMgr:curPos()
    return string.format("%d, %d", Me.curX, Me.curY)
end

-- 当前动作
function StatisticsMgr:curAct()
    return Me.faAct
end

-- 是否战斗或观战中
function StatisticsMgr:curState()
    if Me:isInCombat() then
        return 1
    elseif Me:isLookOn() then
        return 2
    else
        return 0
    end
end

-- 可用内存
function StatisticsMgr:availMemory()
    return math.ceil((DeviceMgr:getAvailMemory() or 0) / 1024 / 1024)
end

-- 总内存
function StatisticsMgr:totalMemory()
    return math.ceil((DeviceMgr:getTotalMemory() or 0) / 1024 / 1024)
end

-- 是否在后台
function StatisticsMgr:background()
    if GameMgr:isInBackground() then
        return 1
    else
        return 0
    end
end

-- 已接收流量
function StatisticsMgr:recvDataSize()
    return Client.recvDataSize
end

-- 已发送流量
function StatisticsMgr:sendDataSize()
    return Client.sendDataSize
end

-- 终端型号
function StatisticsMgr:termInfo()
    return DeviceMgr:getTermInfo()
end

-- 系统版本
function StatisticsMgr:osVer()
    return DeviceMgr:getOSVer()
end

-- 母包版本号
function StatisticsMgr:bundleVer()
    local PLATFORM_CONFIG = require("PlatformConfig")
    return PLATFORM_CONFIG.CUR_VERSION
end

-- 当前版本号
function StatisticsMgr:curVer()
    return cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, self:bundleVer())
end

-- 获取当前内存的贴图缓存
function StatisticsMgr:getTextureCacheSize()
    local textureCache = cc.Director:getInstance():getTextureCache()
    if not textureCache then return 0 end
    local strs = string.split(textureCache:getCachedTextureInfo(), "\n")
    if not strs or #strs <= 0 then return 0 end
    local tstr
    local i = #strs
    repeat
        tstr = strs[i]
        i = i - 1
    until i <= 0 or (tstr and #tstr > 0)

    if not tstr or #tstr <= 0 then return 0 end
    local tbs = string.match(tstr, "TextureCache dumpDebugInfo: %d+ textures, for (%d+) KB %(.+ MB%)")
    return math.ceil((tbs or 0) / 1024)
end

-- 发送统计数据到服务器
function StatisticsMgr:MSG_PERFORMANCE(data)
    local m = {
        fr = self:frameRate(),
        spf = self:secondsPerFrame(),
        mapId = self:mapId(),
        pos = self:curPos(),
        act = self:curAct(),
        state = self:curState(),
        am = self:availMemory(),
        tm = self:totalMemory(),
        bg = self:background(),
        rds = self:recvDataSize(),
        sds = self:sendDataSize(),
        ti = self:termInfo(),
        os = self:osVer(),
        bv = self:bundleVer(),
        cv = self:curVer(),
        tcs = self:getTextureCacheSize(),
    }

    gf:CmdToServer('CMD_PERFORMANCE', m)

    local tcs = m.tcs
    if tcs >= WARNING_MEM_SIZE and gf:getTickCount() - lastSendTime > SEND_INTERVAL then
        lastSendTime = gf:getTickCount()
        local textureCache = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
        gf:ftpUploadEx(string.format(">>>>>>>Memory Use(%d):\n%s", tcs, textureCache))
    end
end

MessageMgr:regist("MSG_PERFORMANCE", StatisticsMgr)
