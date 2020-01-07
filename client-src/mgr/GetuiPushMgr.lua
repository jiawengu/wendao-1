-- GetuiPushMgr.lua
-- Created by sujl, Sept/8/2016
-- 个推推送管理器

GetuiPushMgr = Singleton("GetuiPushMgr")

local J_CLASS = "com/gbits/notification/GetuiPushUtil"
local O_CLASS = "GetuiSdkHelper"

if not gf:gfIsFuncEnabled(FUNCTION_ID.REMOTE_PUSH_V2950) then
    J_CLASS = "com/gbits/notification/GetuiPushService"
end

-- 调用 java 函数
local callJavaFun = function(fun, sig, args)
    if not gf:gfIsFuncEnabled(FUNCTION_ID.REMOTE_PUSH) then return end
    local luaj = require('luaj')
    local ok, ret = luaj.callStaticMethod(J_CLASS, fun, args, sig)
    if not ok then
        gf:ShowSmallTips("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end

-- 调用 iOS SDK 函数
local callOCSdkFun = function (fun, args)
    if not gf:gfIsFuncEnabled(FUNCTION_ID.REMOTE_PUSH) then return end
    local luaoc = require('luaoc')
    local ok, ret = luaoc.callStaticMethod(O_CLASS, fun, args)
    if not ok then
        return "fail"
    end

    Log:I('callOCSdkFun %s, ret: %s', fun, tostring(ret))
    return ret
end

-- 启动推送服务
-- public static void startService()
function GetuiPushMgr:startService()
    if gf:isAndroid() then
        callJavaFun("startService", "()V", {})
    elseif gf:isIos() then
        callOCSdkFun("startService")
    end
end

-- 停止推送服务
-- public static void stopService()
function GetuiPushMgr:stopService()
    if gf:isAndroid() then
        callJavaFun("stopService", "()V", {})
    elseif gf:isIos() then
        callOCSdkFun("stopService")
    end
end

-- 开启推送
-- public static void turnOnPush()
function GetuiPushMgr:turnOnPush()
    if gf:isAndroid() then
        callJavaFun("turnOnPush", "()V", {})
    elseif gf:isIos() then
        callOCSdkFun("turnOnPush", { false })
    end
end

-- 关闭推送
-- public static void turnOffPush()
function GetuiPushMgr:turnOffPush()
    if gf:isAndroid() then
        callJavaFun("turnOffPush", "()V", {})
    elseif gf:isIos() then
        callOCSdkFun("turnOffPush", { true })
    end
end

-- 设置标签
-- public static int setTag(String[] tags, String sn)
function GetuiPushMgr:setTag(tags, sn)
    if gf:isAndroid() then
        return callJavaFun("setTag", "(Ljava/lang/String;)I", {tags, sn})
    elseif gf:isIos() then
        return callOCSdkFun("setTag", {tags, sn})
    end
end

-- 设置静默时间
-- public static boolean setSilenTime(int beginHour, int duration)
function GetuiPushMgr:setSilenTime(beginHour, duration)
    if gf:isAndroid() then
        return callJavaFun("setSilenTime", "(II)Z", {beginHour, duration})
    elseif gf:isIos() then
        return callOCSdkFun("setSilenTime", {beginHour, duration})
    end
end

-- 发送自定义回执
-- public static boolean sendFeedbackMessage(String taskid, String messageid, int actionid)
function GetuiPushMgr:sendFeedbackMessage(taskid, messageid, actionid)
    if gf:isAndroid() then
        return callJavaFun("sendFeedbackMessage", "(Ljava/lang/String;Ljava/lang/String;I)Z", { taskid, messageid, actionid })
    elseif gf:isIos() then
        return callOCSdkFun("sendFeedbackMessage", { taskid, messageid, actionid })
    end
end

-- 绑定别名
-- public static boolean bindAlias(String alias)
function GetuiPushMgr:bindAlias(alias)
    if gf:isAndroid() then
        return callJavaFun("bindAlias", "(Ljava/lang/String;)Z", { alias })
    elseif gf:isIos() then
        return callOCSdkFun("bindAlias", { alias })
    end
end

-- 解绑别名
-- public static boolean unbindAlias(String alias, boolean isSelf)
function GetuiPushMgr:unbindAlias(alias, isSelf)
    if gf:isAndroid() then
        return callJavaFun("unbindAlias", "(Ljava/lang/String;)Z", { alias })
    elseif gf:isIos() then
        return callOCSdkFun("unbindAlias", { alias })
    end
end

-- 获取Clientid
-- public static String getClientId()
function GetuiPushMgr:getClientId()
    if gf:isAndroid() then
        return callJavaFun("getClientId", "()Ljava/lang/String;", {})
    elseif gf:isIos() then
        return callOCSdkFun("getClientId")
    end
end

-- 获取SDK服务状态
-- public static boolean isPushTurnOn()
function GetuiPushMgr:isPushTurnOn()
    if gf:isAndroid() then
        return callJavaFun("isPushTurnOn", "()Z", {})
    elseif gf:isIos() then
        return callOCSdkFun("isPushTurnOn")
    end
end

-- 获取SDK版本号
-- public static String getVersion()
function GetuiPushMgr:getVersion()
    if gf:isAndroid() then
        return callJavaFun("getVersion", "()Ljava/lang/String;", {})
    elseif gf:isIos() then
        return callOCSdkFun("getVersion")
    end
end

function GetuiPushMgr:setDeviceToken(token)
    self.deviceToken = token
    GetuiPushMgr:sendDeviceToken()
end

function GetuiPushMgr:getDeviceToken()
    if gf:isIos() and not self.deviceToken then
        self.deviceToken = callOCSdkFun('getDeviceToken')
    end

    return self.deviceToken
end

function GetuiPushMgr:sendDeviceToken()
    local token = GetuiPushMgr:getDeviceToken()
    if not token or not GameMgr or not GameMgr.isEnterGame then return end
    gf:CmdToServer('CMD_SEND_DEVICE_TOKEN', { ["token"] = token })
end