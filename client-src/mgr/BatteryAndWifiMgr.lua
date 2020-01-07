-- BatteryAndWifiMgr.lua
-- created by liuhb Oct/22/2015
-- 电池及网络

BatteryAndWifiMgr = Singleton()

local callPlatFormFun = function(func, sig)
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        if not sig then
            sig = '()V'
        end
        local args = {}
        local className = 'org/cocos2dx/lua/AppActivity'
        local ok, ret = luaj.callStaticMethod(className, func, args, sig)
        if ok then
            return ret
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require("luaoc")
        local ok, ret = luaoc.callStaticMethod('AppController', func)
        if ok then
            return ret
        end
    end
end

-- 开始更新电池信息
function BatteryAndWifiMgr:startUpdateBattery()
    callPlatFormFun("startUpdateBatteryState")
    self.startUpdateBatteryOk = true
end

-- 停止更新电池信息
function BatteryAndWifiMgr:stopUpdateBattery()
    if not self.startUpdateBatteryOk then
        return
    end

    callPlatFormFun("stopUpdateBatteryState")
    self.startUpdateBatteryOk = nil
end

-- 设置电池信息
function BatteryAndWifiMgr:setBatteryInfo(batteryInfo)
    self.batteryInfo = {}
    self.batteryInfo = batteryInfo
end

-- 获取电池的信息
function BatteryAndWifiMgr:getBatteryInfo()
    return self.batteryInfo
end

-- 设置网络信息
function BatteryAndWifiMgr:setNetworkState(networkState)
    self.networkState = networkState
end

-- 获取网络状态信息
function BatteryAndWifiMgr:getNetworkState()
    return self.networkState or NET_TYPE.NULL
end

-- 设置wifi信息
function BatteryAndWifiMgr:setWifiInfo(wifiInfo)
    self.wifiInfo = wifiInfo
end

-- 获取wifi信息
function BatteryAndWifiMgr:getWifiInfo()
    return self.wifiInfo
end


-- 开始更新网络状态
function BatteryAndWifiMgr:startUpdateNetWorkStatus()
    callPlatFormFun("startListenNetwork")
    self.startUpdateNetWorkStatusOk = true
end

-- 停止更新网络状态
function BatteryAndWifiMgr:stopUpdateNetWorkStatus()
    if not self.startUpdateNetWorkStatusOk then
        return
    end

    callPlatFormFun("stopListenNetwork")
    self.startUpdateNetWorkStatusOk = nil
end

-- 开始更新wifi状态
function BatteryAndWifiMgr:startUpdateWifi()
    -- 只有安卓平台更新wifi状态
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        callPlatFormFun("startListenWifi")
        self.startUpdateWifiOk = true
    end
end

-- 停止更新wifi状态
function BatteryAndWifiMgr:stopUpdateWifi()
    -- 只有安卓平台更新wifi状态
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        if not self.startUpdateWifiOk then
            return
        end

        callPlatFormFun("stopListenWifi")
        self.startUpdateWifiOk = nil
    end
end

function BatteryAndWifiMgr:getNetType()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local netType = callPlatFormFun("GetNetype", "()I")
        if -1 == netType then
            return 0
        elseif 1 == netType then
            return 1
        elseif 2 == netType or 3 == netType then
            return 2
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        return callPlatFormFun("getNetWorkStatus")
    end
end
