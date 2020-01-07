-- Channel_Channel_120001.lua
-- Created by sujl, May/19/2016
-- 应用宝渠道

local YYBChannel = Singleton("YYBChannel")
local json = require("json")
require("core/sha1")
require("core/base64")

local REPORT_URL = "http://gamelog.3g.qq.com/game/log"
local FOR_TEST = false
local SECRET_WX = "wd_48b5d157fc2fdc24"
local APP_ID_WX = "1105040429"
local SECRET_QQ = "wd_48b5d157fc2fdc24"
local APP_ID_QQ = "1105040429"

local function isTest()
    return gf:isWindows() or FOR_TEST
end

local function getReportUrl()
    if isTest() then
        return REPORT_URL .. "/test"
    else
        return REPORT_URL
    end
end

local function getAppId()
    if 2 == LeitingSdkMgr.loginType then
        return APP_ID_WX
    elseif 1 == LeitingSdkMgr.loginType then
        return APP_ID_QQ
    else
        return ""
    end
end

local function getSecret()
    if 2 == LeitingSdkMgr.loginType then
        return SECRET_WX
    elseif 1 == LeitingSdkMgr.loginType then
        return SECRET_QQ
    else
        return ""
    end
end

local function authorization(body)
    local hmac = hmac_sha1_binary(getSecret(), body)
    local baseStr = to_base64(hmac)
    return baseStr
end

local function getOpenid()
    if LeitingSdkMgr.loginInfo then
        return LeitingSdkMgr.loginInfo.userId or ""
    end

    return ""
end

-- 构建固定的数据
local function buildData(data)
    if not data then
        data = {}
    end

    data.event_id = "2"
    data.event_time = gf:getServerTime()
    data.appid = getAppId()
    data.openid = getOpenid()
    data.zone_id = Client:getWantLoginDistName() or ""
    data.zone_name = Client:getWantLoginDistName()
    data.platform = "1"
    data.imei = DeviceMgr:getImei()

    return data
end

function YYBChannel:logReport(data)
    -- 构建请求
    local requestBody = json.encode(buildData(data))
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:setRequestHeader("Authorization", authorization(requestBody))
    xhr:open('POST', getReportUrl(), false)

    local function onReadyStateChange()
        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(requestBody)
end

return YYBChannel