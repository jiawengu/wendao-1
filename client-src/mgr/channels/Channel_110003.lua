-- Channel_110003.lua
-- Created by sujl, May/19/2016
-- UC渠道

local UCChannel = Singleton("UCChannel")
local json = require("json")

-- 常量
local REPORT_URL = "http://collect.sdknc.g.uc.cn:8080/ng/cpserver/gamedata/ucid.game.gameData"
local API_KEY = "58a2533f8e83a6af38e42da7cb65752e"

local function getSign(accountId, gameData, apiKey)
    local str = "accountId=" .. accountId .. "gameData=" .. gameData .. apiKey
    return string.lower(gfGetMd5(str))
end

-- 等级变化上报
function UCChannel:levelUpReport(info)
    if not info then return end

    -- 追加必须的字段
    info.os = "android"
    info.roleLevelMTime = gf:getServerTime()

    -- 构建请求
    local params = {}
    params.id = gf:getServerTime()
    params.service = "ucid.game.gameData"
    local data = {}
    data.accountId = LeitingSdkMgr.loginInfo and tostring(LeitingSdkMgr.loginInfo.userId) or ""
    local gameData = {}
    gameData.category = "loginGameRole"
    gameData.content = info
    data.gameData = gf:encodeURI(json.encode(gameData))
    params.data = data
    params.game = { gameId = '543459' }
    params.sign = getSign(data.accountId, data.gameData, API_KEY)

    local requestBody = json.encode(params)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('POST', REPORT_URL, false)

    local function onReadyStateChange()
        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(requestBody)
end

return UCChannel
