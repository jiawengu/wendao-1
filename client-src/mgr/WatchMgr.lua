-- WatchMgr.lua
-- Created by sujl, Nov/12/2018
-- 手表管理器

WatchMgr = {}

-- 回调接口
WatchMgr.callbacks = {}

-- 调用 java 函数
local callJavaFun = function(fun, sig, args)
    assert(false)
end

-- 调用ios函数
local callOCFun = function (fun, args)
    local luaoc = require('luaoc')
    local ok = nil

    if args then
        ok, ret = luaoc.callStaticMethod('WatchSessionManager', fun, args)
    else
        ok, ret = luaoc.callStaticMethod('WatchSessionManager', fun)
    end

    if not ok then
        gf:ShowSmallTips("call oc function:" .. fun .. " failed!")
    else
        return ret
    end
end

-- 注册回调
function WatchMgr:registe(name, callback)
    if 'function' == type(callback) then
        self.callbacks[name] = callback
    elseif (type(callback) == "table" or type(callback) == "userdata") then
        local class = callback
        callback = class[name]
        if type(callback) == "function" then
            self.callbacks[name] = function(data) callback(class, data) end
        end
    end
end

-- 反注册回调
function WatchMgr:unregist(name, callback)
    if not callback or self.callbacks[name] == callback then
        self.callbacks[name] = nil
    end
end

-- 发送消息，参数为表
function WatchMgr:sendMessage(data)
    if 'table' ~= type(data) then  return end

    if gf:isAndroid() then
    elseif gf:isIos() then
        callOCFun("_sendMessage", data)
    end
end

-- 发送数据
function WatchMgr:sendData(data)
    if 'string' ~= data then end
    local t = { bytes = data, len = #data }

    if gf:isAndroid() then
    elseif gf:isIos() then
        callOCFun("_sendData", t)
    end
end

-- 收到手表数据
function WatchMgr:onReceiveMessage(data)
    local jdata = json.decode(data)
    local funcName = jdata["action"]
    local callback = self.callbacks[funcName]
    if 'function' == type(callback) then
        callback(jdata)
    else
        self:sendMessage({ action = funcName, result = false })
    end
end

-- 设置服务器信息
function WatchMgr:setHttpToken(data)
    if gf:isIos() then
        local luaoc = require('luaoc')
        luaoc.callStaticMethod('AppController', 'setWatch', { data = json.encode(data) })
    end
end
