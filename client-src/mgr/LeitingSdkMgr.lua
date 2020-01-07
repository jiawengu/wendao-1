-- LeitingSdkMgr.lua
-- created by chenyq Sep/17/2015
-- 雷霆 SDK 管理器

LeitingSdkMgr = Singleton()

-- 是否启用 sdk
LeitingSdkMgr.enable = (not gf:isWindows() and true)

local json = require('json')
local LOGIN_ACCOUNT_TYPE =
{
    qqType = 1,
    wxType = 2,
}

local LOGINFO_OVERTIME = 2 * 24 * 60 *60

local CHAR_REPORT_KEY = "leiting!@#123"

local LOGIN_ERROR =
{
    eFlag_QQ_NoAcessToken = "1000",   -- 手Q登录失败，未获取到accesstoken  返回登录界面，引导玩家重新登录授权
    eFlag_QQ_UserCancel = "1001",     -- 玩家取消手Q授权登录  返回登录界面，并告知玩家已取消手Q授权登录
    eFlag_QQ_LoginFail = "1002",      -- 手Q登录失败  返回登录界面，引导玩家重新登录授权
    eFlag_QQ_NetworkErr = "1003",     -- 网络错误    重试
    eFlag_QQ_NotInstall = "1004",     -- 玩家设备未安装手Q客户端    引导玩家安装手Q客户端
    eFlag_QQ_NotSupportApi = "1005",  -- 玩家手Q客户端不支持此接口   引导玩家升级手Q客户端
    eFlag_QQ_AccessTokenExpired = "1006",  -- accesstoken过期   返回登录界面，引导玩家重新登录授权
    eFlag_QQ_PayTokenExpired = "1007", -- paytoken过期  返回登录界面，引导玩家重新登录授权
    eFlag_WX_NotInstall = "2000",     -- 玩家设备未安装微信客户端    引导玩家安装微信客户端
    eFlag_WX_NotSupportApi = "2001",  -- 玩家微信客户端不支持此接口   引导玩家升级微信客户端
    eFlag_WX_UserCancel = "2002",     -- 玩家取消微信授权登录  返回登录界面，并告知玩家已取消微信授权登录
    eFlag_WX_UserDeny = "2003",       -- 玩家拒绝微信授权登录  返回登录界面，并告知玩家已拒绝微信授权登录
    eFlag_WX_LoginFail = "2004",      -- 微信登录失败  返回登录界面，引导玩家重新登录授权
    eFlag_WX_RefreshTokenSucc = "2005", -- 微信刷新票据成功    获取微信票据，登录进入游戏
    eFlag_WX_RefreshTokenFail = "2006", -- 微信刷新票据失败    返回登录界面，引导玩家重新登录授权
    eFlag_WX_AccessTokenExpired = "2007", -- 微信accessToken过期     尝试用refreshtoken刷新票据
    eFlag_WX_RefreshTokenExpired = "2008", --微信refreshtoken过期    返回登录界面，引导玩家重新登录授权
}

local CHANNEL_NO =
{
    ["leiting"] ={name = CHS[3004114], channelNo = "110001", channelIosNo = "210009"},
    ["ltqihoo"] ={name = CHS[3004115], channelNo = "110002", quitWay = "B"},
    ["ltuc"] = {name = "UC", channelNo = "110003", quitWay = "B"},
    ["ltdl"] = {name = CHS[3004116], channelNo = "110004", quitWay = "B"},
    ["ltbaidu"] = {name = CHS[3004117], channelNo = "110005", quitWay = "B"},
    ["ltxiaomi"] = {name = CHS[3004118], channelNo = "110006"},
    ["ltarz"] = {name = CHS[3004119], channelNo = "110007"},
    ["ltxmy"] = {name = CHS[3004120], channelNo = "110008"},
    ["ltmsdk"] = {name = CHS[3004121], channelNo = "120001"},
    ["ltwandou"] = {name = CHS[3004122], channelNo = "120002"},
    ["ltanzhi"] = {name = CHS[3004123], channelNo = "120003", quitWay = "B"},
    ["ltappchina"] = {name = CHS[3004124], channelNo = "120004"},
    ["ltlenovo"] = {name = CHS[3004125], channelNo = "130001", quitWay = "B"},
    ["ltoppo"] = {name = "OPPO", channelNo = "130002", quitWay = "B"},
    ["ltjinli"] = {name = CHS[3004126], channelNo = "130003"},
    ["lt37"] = {name = CHS[3004127], channelNo = "130004"},
    ["lthuawei"] = {name = CHS[3004128], channelNo = "130005"},
    ["ltcoolPad"] = {name = CHS[3004129], chanenlNo = "130007"},
    ["ltvivo"] = {name = "VIVO", channelNo = "130008"},
    ["lt4399"] = {name = "4399", channelNo = "130009", quitWay = "B"},
    ["ltmzw"] = {name = CHS[3004130], channelNo = "130010"},
    ["ltmz"] = {name = CHS[3004131], channelNo = "130011"},
    ["ltyl"] = {name = CHS[3004132], channelNo = "130012", quitWay = "B"},
    ["ltyd"] = {name = CHS[3004133], channelNo = "130013", quitWay = "B"},
    ["ltlb"] = {name = CHS[3004134], channelNo = "130014"},
    ["ltyk"] = {name = CHS[3004135], channelNo = "130015", quitWay = "B"},
    ["ltgp"] = {name = CHS[3004136], channelNo = "130016", quitWay = "B"},
    ["lttoutiao"] = {name = CHS[3004137], channelNo = "130017"},
    ["ltkugou"] = {name = CHS[3004138], channelNo = "130018"},
    ["ltyiwan"] = {name = CHS[3004139], channelNo = "130019", quitWay = "B"},
    ["ltyiyou"] = {name = CHS[3004140], channelNo = "130020"},
    ["ltkaopu"] = {name = CHS[3004141], channelNo = "130021"},
    ["ltyijie"] = {name = CHS[3004142], channelNo = "130022",},
    ["ltly"] = {name = CHS[6000233], channelNo = "130023"},
    ["ltiapppay"] = {name = CHS[5420359], channelNo = "130044"},
    ["ltaiqiyi"] = {name = CHS[5000298], channelNo = "130051"},
    ["ltoverseas"] = {name = CHS[2400001], channelNo = "310002", channelIosNo = "410001"},
}

-- 包名对应的渠道市场包名
local PACAGENAEM_TO_MAKETPACKAGENAME = {
    ["com.tencent.tmgp.gbits.atm"] = "com.tencent.android.qqdownloader",
    ["com.gbits.atm.mi"] = "com.xiaomi.market",
    ["com.gbits.atm.huawei"] = "com.huawei.appmarket",
    ["com.gbits.atm.nearme.gamecenter"] = "com.oppo.market",
    ["com.gbits.atm.vivo"] = "com.bbk.appstore",
    ["com.gbits.atm.mz"] = "com.meizu.mstore",
}

LeitingSdkMgr.callingPayAction = nil

-- 登录回调函数
loginLeitingSdkCB = function(para)
    Log:I("loginLeitingSdkCB: " .. para)
    Client:pushDebugInfo("loginLeitingSdkCB: " .. para)
    LeitingSdkMgr:processLoginInfo(para)
    DebugMgr:endLogin() -- WDSY-33170
end

-- 激活回调函数
activateLeitingSdkCB = function(para)
    Log:I("activateLeitingSdkCB: " .. para)
    LeitingSdkMgr:processLoginInfo(para)
    DebugMgr:endLogin() -- WDSY-33170
end

-- 充值回调函数
payLeitingSdkCB = function(para)
    if LeitingSdkMgr.callingPayAction then
        DlgMgr:closeDlg("WaitDlg")
        gf:getUILayer():stopAction(LeitingSdkMgr.callingPayAction)
        LeitingSdkMgr.callingPayAction = nil
    end

    Log:I("payLeitingSdkCB: " .. para)
    LeitingSdkMgr:processPayInfo(para)
end

-- 充值失败回调函数 WDSY-36733 处理
payFailLeitingSdkCB = function(para)
    Log:I("payFailLeitingSdkCB: " .. para)

    DlgMgr:sendMsg("ReserveOnlineRechargeDlg", "stopUpdate")
    DlgMgr:sendMsg("LineUpOnlineRechargeDlg", "stopUpdate")
end

-- 登出回调函数
logoutLeitingSdkCB = function(para)
    Log:I("logoutLeitingSdkCB: " .. tostring(para))
    LeitingSdkMgr:processLogout(para or "")
end

-- SDK 退出回调函数
quitLeitingSdkCB = function(para)
    Log:I("quitLeitingSdkCB: " .. para)
    if LeitingSdkMgr.quitting then
        -- 结束游戏
        LeitingSdkMgr.quitting = false
        Log:I("quitLeitingSdkCB: call gf:EndGame()")
        gf:EndGame(LOGOUT_CODE.LGT_SDK_QUIT)
    end
end

disMisGMContractCB = function()
    Log:I("disMisGMContractCB")
    SoundMgr:replayMusicAndSound()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        performWithDelay(gf:getUILayer(), function()
            luaoc.callStaticMethod("AppController", "finishVolumnView")
        end, 1)
    end
end

-- 调用 java 函数
local callJavaFun = function(fun, sig, args)
    local luaj = require('luaj')
    local className = 'com/gbits/LeitingSdkHelper'
    local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
    if not ok then
        Log:W("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end

-- 调用ios函数
local callOCFun = function (fun, args)
    local luaoc = require('luaoc')
    local ok, ret

    if args then
        ok, ret = luaoc.callStaticMethod('LeitingSdkHelper', fun, args)
    else
        ok, ret = luaoc.callStaticMethod('LeitingSdkHelper', fun)
    end

    if not ok then
        Log:W("call oc function:" .. fun .. " failed!")
    end

    return ret or ""
end

-- 清除登录信息
function LeitingSdkMgr:clearLoginInfo()
    self.loginInfo = nil
    Client:clearAccountInfo()
    Client:setNoShowLoginOperateDlg(true)
end

function LeitingSdkMgr:getChannelNO()
    if not self.channelNO then
        if gf:isAndroid() then
            self.channelNO = callJavaFun("getPropertiesValue", "(Ljava/lang/String;)Ljava/lang/String;", { 'channelType' })
        elseif gf:isIos() then
            self.channelNO = callOCFun("getPropertiesValue", {name='CHANNEL_NO'})
        end
    end

    return self.channelNO
end

-- 是否可用
function LeitingSdkMgr:isEnable()
    return (self.enable and gf:isAndroid())
end

-- 初始化
function LeitingSdkMgr:init()
    if self.enable then
        if gf:isAndroid() then
            callJavaFun("setLuaCallbackSuffix", "(Ljava/lang/String;)V", { 'LeitingSdkCB' })
        elseif gf:isIos() then
            callOCFun("initSdk")
        end

        -- 尝试加载渠道脚本
        pcall(function() self.curChannel = require(string.format("mgr/channels/Channel_%s", tostring(self:getChannelNO()))) end)
    end
end

-- 有些渠道不需要弹出游戏的退出框
function LeitingSdkMgr:needNotShowGameQuitDlg()
    if gf:gfIsFuncEnabled(FUNCTION_ID.QUIT_WAY_QUERY) then
        return "0" == LeitingSdkMgr:getPropertiesValue("exitGame")
    else
        if self.loginInfo and self.loginInfo.channelNo then
            local channelNo = self.loginInfo.channelNo

            for k, v in pairs(CHANNEL_NO) do
                if v.channelNo == channelNo then
                    if v.quitWay == "B"  then
                        return true
                    else
                        return false
                    end
                end
            end
        end
    end

    return false
end

-- 如果是靠谱渠道且指定的是“左右逢源”区组，则需要将账号中的渠道编号替换为应用宝渠道编号
-- 否则直接返回传入的账号即可
function LeitingSdkMgr:reviseAccount(account, dist)
    if not account then
        return ""
    end

    if not dist or dist ~= CHS[3004441] then
        -- 非“左右逢源”区组
        return account
    end

    if string.sub(account, 1, 6) ~= CHANNEL_NO["ltkaopu"].channelNo then
        -- 非靠谱渠道
        return account
    end

    -- 是靠谱渠道的“左右逢源”区组，渠道编号信息需要替换为应用宝渠道编号
    return CHANNEL_NO["ltmsdk"].channelNo .. string.sub(account, 7)
end

-- 登录
function LeitingSdkMgr:login()
    Client:pushDebugInfo("LeitingSdkMgr:login()")
    DebugMgr:beginLogin("LeitingSdkMgr:login()") -- WDSY-33170
    if self.enable then
        if gf:isAndroid() then
            if self:isYYB() then -- 运用宝
                DlgMgr:openDlg("AppTreasureLoginDlg")
            end

            callJavaFun("login", "()V", {})
        elseif gf:isIos() then
            callOCFun("login")
        end
    else
        DlgMgr:openDlg("AccountInputDlg")
    end

    self.lastLoginSdkTime = os.time()
end

function LeitingSdkMgr:logInfoIsOverTime()
    if self.lastLoginSdkTime and os.time() - self.lastLoginSdkTime > LOGINFO_OVERTIME then
        return true
    else
        return false
    end
end

-- qq登录
function LeitingSdkMgr:qqLogin()
    callJavaFun("qqLogin", "()V", {})
    self.loginType = LOGIN_ACCOUNT_TYPE.qqType
end

-- 微信登录
function LeitingSdkMgr:wxLogin()
    callJavaFun("wxLogin", "()V", {})
    self.loginType = LOGIN_ACCOUNT_TYPE.wxType
end

-- 登录上报
function LeitingSdkMgr:loginReport(info)
    local para = json.encode(info)
    if self.enable then
        if gf:isAndroid() then
            callJavaFun("loginReport", "(Ljava/lang/String;)V", {para})
        elseif gf:isIos() then
            if gf:gfIsFuncEnabled(FUNCTION_ID.IOS_LOGINREPORT) then
                callOCFun("loginReport", { jsonStr = para })
            end
        end
    end
end

-- 统计信息
function LeitingSdkMgr:sendEvent(info)
    local para = json.encode(info)
    if self.enable then
        if gf:isAndroid() then
            -- callJavaFun("sendEvent", "(Ljava/lang/String;)V", {para})
        elseif gf:isIos() then
            callOCFun("sendEvent", { jsonStr = para })
        end
    end
end

-- 加入帮派
function LeitingSdkMgr:joinGroupReport(info)
    local para = json.encode(info)
    if self.enable then
        if gf:isAndroid() then
            callJavaFun("joinGroupReport", "(Ljava/lang/String;)V", {para})
        elseif gf:isIos() then
            callOCFun("joinGroupReport", { jsonStr = para })
        end
    end
end

-- 上传角色信息
function LeitingSdkMgr:loginCharReport(info)
    if gf:isWindows() then return end
    if not info then return end

    -- 追加必须的字段
    info.gameCode = "wd"
    info.cookie = string.lower(gfGetMd5(string.format("%s%%%s%%%s%%%s%%%s%%%s%%%s", info.gameCode, info.sid, info.gid, info.level, info.icon, info.lastLoginTime, CHAR_REPORT_KEY)))

    local t = {}
    for k, v in pairs(info) do
        table.insert(t, string.format("%s=%s", tostring(k), tostring(v)))
    end

    local requestBody = table.concat(t, "&")
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('POST', "https://crm.leiting.com/game/char_info_report", false)

    local function onReadyStateChange()
        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(requestBody)

    if not info.gid or #(info.gid) < 20 then    -- WDSY-26362
        gf:ftpUploadEx(string.format(">>>>>>>>>>>>>>>>loginCharReport error:\n%s", tostring(requestBody)))
    end
end

-- 角色删除/恢复上报
function LeitingSdkMgr:deleteCharReport(info)
    if gf:isWindows() then return end
    if not info then return end

    -- 追加必须的字段
    info.gameCode = "wd"
    info.cookie = string.lower(gfGetMd5(string.format("%s%%%s%%%s%%%s", info.gameCode, info.sid, info.gid, CHAR_REPORT_KEY)))

    local t = {}
    for k, v in pairs(info) do
        table.insert(t, string.format("%s=%s", tostring(k), tostring(v)))
    end

    local requestBody = table.concat(t, "&")
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('POST', "https://crm.leiting.com/game/char_info_del", false)

    local function onReadyStateChange()
        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(requestBody)
end

-- 查询全服已有角色
function LeitingSdkMgr:queryAllChars(info, callback, timeout)
    if gf:isWindows() then
        if callback and 'function' == type(callback) then
            callback(nil)
        end
        return
    end
    if not info then return end

    timeout = timeout or 5  -- 超时时间，默认为5s
    if gf:isWindows() then timeout = 0 end

    -- 追加必须的字段
    info.gameCode = "wd"
    info.cookie = string.lower(gfGetMd5(string.format("%s%%%s%%%s", info.gameCode, info.sid, CHAR_REPORT_KEY)))

    local t = {}
    for k, v in pairs(info) do
        table.insert(t, string.format("%s=%s", tostring(k), tostring(v)))
    end

    local url = string.format("https://crm.leiting.com/game/char_info_query?%s", table.concat(t, "&"))
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('GET', url, false)

    if self.queryAllCharAction then
        cc.Director:getInstance():getRunningScene():stopAction(self.queryAllCharAction)
        self.queryAllCharAction = nil
    end
    self.queryAllCharAction = performWithDelay(cc.Director:getInstance():getRunningScene(), function()
        if callback and 'function' == type(callback) then
            callback(nil)
        end

        callback = nil
        self.queryAllCharAction = nil
    end, timeout)

    local function onReadyStateChange()
        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)

        if callback and 'function' == type(callback) then
            callback(tostring(xhr.response))
        end

        callback = nil
        if self.queryAllCharAction then
            cc.Director:getInstance():getRunningScene():stopAction(self.queryAllCharAction)
        end
        self.queryAllCharAction = nil
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

-- 升级上报
function LeitingSdkMgr:levelUpReport(info)
    if self.enable then
        local para = json.encode(info)
        if gf:isAndroid() then
            if gf:gfIsFuncEnabled(FUNCTION_ID.LEVEL_LOGIN_REPORT) then
                callJavaFun("levelUpReport", "(Ljava/lang/String;)V", {para})
            else
                if self.curChannel and self.curChannel.levelUpReport then
                   self.curChannel:levelUpReport(info)
                end
            end
        else
            if gf:gfIsFuncEnabled(FUNCTION_ID.IOS_LEVELUPREPORT) then
                callOCFun("levelUpReport", { jsonStr = para })
            end
        end
    end
end

-- 角色创建上报
function LeitingSdkMgr:createRole(roleInfo)
    if self.enable and gf:isIos() then
        local info = { type = "1", roleName = roleInfo.roleName }
        local para = json.encode(info)
        callOCFun("createRole", {jsonStr = para})
    elseif self.enable and gf:isAndroid() and gf:gfIsFuncEnabled(FUNCTION_ID.CREATE_ROLE_REPORT) then
        local para = json.encode(roleInfo)
        callJavaFun("createRoleReport", "(Ljava/lang/String;)V", { para })
    end
end

-- 日志上报
function LeitingSdkMgr:logReport(data)
    if self.enable and gf:isAndroid() then
        if self.curChannel then
            self.curChannel:logReport(data)
        end
    end
end

-- 激活
function LeitingSdkMgr:activate()
    DebugMgr:beginLogin("LeitingSdkMgr:activate()") -- WDSY-33170
    if self.enable and gf:isAndroid() then
        callJavaFun("activate", "()V", {})
    else
    end
end

-- 切换账号
function LeitingSdkMgr:switchAccount()
    if self.enable and gf:isAndroid() then
        callJavaFun("switchAccount", "()V", {})
    else
        DlgMgr:openDlg("AccountInputDlg")
    end
end

-- 个人中心
function LeitingSdkMgr:accountCenter()
    if self.enable then
        if gf:isAndroid() then
            if self:isYYB() then
                local dlg = DlgMgr:openDlg("AppTreasureAcconutDlg")
                dlg:setString(self.loginType)
            else
                callJavaFun("accountCenter", "()V", {})
            end
        elseif gf:isIos() then
            callOCFun("accountCenter")
        end
    else
        DlgMgr:openDlg("AccountInputDlg")
    end
end

-- 充值
function LeitingSdkMgr:pay(info)
    local para = json.encode(info)
    if self.enable then
        if gf:isAndroid() then
            DlgMgr:openDlg("WaitDlg")
            -- 延时1s关闭界面
            self.callingPayAction = performWithDelay(gf:getUILayer(), function()
                DlgMgr:closeDlg("WaitDlg")
                self.callingPayAction = nil
            end, 1)
            callJavaFun("pay", "(Ljava/lang/String;)V", {para})
        elseif gf:isIos() then
            callOCFun("pay",{jsonStr = para})
        end
    end
end

-- 登出
function LeitingSdkMgr:logout()
    if self.enable then
        if gf:isAndroid() then
            callJavaFun("logout", "()V", {})
        elseif gf:isIos() then
            callOCFun("logout")
        end
    end
end

-- 退出
function LeitingSdkMgr:quit()
    if self.enable and gf:isAndroid() then
        self.quitting = true
        callJavaFun("quit", "()V", {})
    else
        gf:EndGame(LOGOUT_CODE.LGT_SDK_QUIT)
    end
end

-- 客服中心
function LeitingSdkMgr:helper()
    local para = json.encode({
        roleLevel = Me:queryInt("level"),
        roleName = Me:getName(),
        gameZone = GameMgr:getServerName()
    })
    if self.enable and (self:isLeiting() or self:isOverseas()) then
        if gf:isAndroid() then
            callJavaFun("helper", "(Ljava/lang/String;)V", {para})
        elseif gf:isIos() then
            if gf:gfIsFuncEnabled(FUNCTION_ID.QIYU_INSIDE) then
                SoundMgr:stopMusicAndSound()
            end
            callOCFun("helper", {jsonStr = para})
        end
    end
end

-- 非登录的客服中心
function LeitingSdkMgr:helperUnLogin()
    if self.enable and (self:isLeiting() or self:isOverseas()) then
        if gf:isAndroid() and gf:gfIsFuncEnabled(FUNCTION_ID.HELPER_UNLOGIN) then
            callJavaFun("helperUnLogin", "()V", {})
        elseif gf:isIos() then
            if gf:gfIsFuncEnabled(FUNCTION_ID.QIYU_INSIDE) then
                SoundMgr:stopMusicAndSound()
            end
            callOCFun("helperUnLogin")
        end
    end
end

-- 是否已登录
function LeitingSdkMgr:isLogined()
    if self.enable and gf:isAndroid() then
        return (self.loginInfo and self.loginInfo.token and self.loginInfo.token ~= "" and self.loginInfo.status == "1" and not self:logInfoIsOverTime())
    else
        -- 没用使用 SDK，如果设置过 name 和 password 则认为是已经登录过
        return Client:getAccount() and Client.password and not self:logInfoIsOverTime()
    end
end

-- 处理登录信息
function LeitingSdkMgr:processLoginInfo(info)
    if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() or GameMgr.isStop then return end

    if not pcall(function() self.loginInfo = json.decode(info) end) then
        -- 参数格式错误
        self.loginInfo = { status = "2", memo = CHS[7000205] }
    end

    if self.loginInfo.status == "9" then
        -- 需要激活
        self:activate()
        self.activating = true
        self.lastUserId = self.loginInfo.userId
    elseif self.loginInfo.status == "1" then
        -- 登录成功
        local userName = self.loginInfo.channelNo .. self.loginInfo.userId
        local pwd = "userId=" .. self.loginInfo.userId
        pwd = pwd .. "&game=" .. self.loginInfo.game
        pwd = pwd .. "&channelNo=" .. self.loginInfo.channelNo
        pwd = pwd .. "&token=" .. self.loginInfo.token
        local isUserNameChanged = userName ~= Client:getRawAccount()
        Client:setNameAndPassword(userName, pwd, true)
        Client:setChannelId(self.loginInfo.channelNo)
        Client:setAdult(self.loginInfo.adult)

        if self.enable and gf:isAndroid() and self:isYYB() then
            DlgMgr:closeDlg("AppTreasureLoginDlg")
        elseif self.activating == true and self.lastUserId  == self.loginInfo.userId then
            gf:ShowSmallTips(CHS[3004143])
            self.activating = false
        end

        if Client._isConnectingGS then
            if isUserNameChanged then
                -- 已连接 gs（此时应该是更换账号了）需要回到登录阶段
                -- 先登出
                gf:CmdToServer("CMD_LOGOUT", {reason = LOGOUT_CODE.LGT_SDK_SWITCH})
                CommThread:stop()

                -- 已验证成功，不需要执行 login 了
                Client.dontDoLogin = true

                -- 断开连接
                MessageMgr:pushMsg({MSG = 0x1368})
            end

            DebugMgr:saveLoginInfo() -- WDSY-33170
        end

        -- 检查是否有快捷操作需要处理
        if gf:isIos() then
            local luaoc = require('luaoc')
            luaoc.callStaticMethod('AppController', 'postQuickActionWithShortcutItem')
        end
    elseif self.loginInfo.status == LOGIN_ERROR.eFlag_QQ_UserCancel or self.loginInfo.status == LOGIN_ERROR.eFlag_WX_UserCancel_UserCancel then
        gf:ShowSmallTips(CHS[3004144])
    else
        -- 登录失败
        if not string.isNilOrEmpty(self.loginInfo.memo) then
            gf:ShowSmallTips(self.loginInfo.memo .. "(status: " .. self.loginInfo.status .. ")")
        end
    end
end

-- 处理付费信息
function LeitingSdkMgr:processPayInfo(info)
    if not pcall(function() self.payInfo = json.decode(info) end) then
        -- 参数格式错误
        self.payInfo = { status = "2", resultMsg = 'invalid json format' }
    end

    if self.payInfo.status ~= "1" then
        gf:ShowSmallTips(self.payInfo.resultMsg)

        DlgMgr:sendMsg("ReserveOnlineRechargeDlg", "stopUpdate")
        DlgMgr:sendMsg("LineUpOnlineRechargeDlg", "stopUpdate")
    end
end

-- 处理 logout
function LeitingSdkMgr:processLogout(para)
    local logoutInfo = { status = "0" }
    if not pcall(function() logoutInfo = json.decode(para) end) then
        -- 参数格式错误
        logoutInfo = { status = "2", resultMsg = 'invalid json format' }
    end

    if logoutInfo.status ~= "1" then
        -- 状态不符合要求
        return
    end

    -- 清除登录信息
    LeitingSdkMgr:clearLoginInfo()

    -- 关闭区组选择界面
    DlgMgr:closeDlg("LoginChangeDistDlg")

    if Client._isConnectingGS then
        Log:I("logoutLeitingSdkCB: clear login info and logout")

        -- 不需要主动执行 login
        Client.dontDoLogin = true

        -- 不要重连
        Client.connectAgain = false

        -- 需要回到登录阶段
        -- 先登出
        gf:CmdToServer("CMD_LOGOUT", {reason = LOGOUT_CODE.LGT_SDK_LOGOUT})
        CommThread:stop()

        -- 断开连接
        MessageMgr:pushMsg({MSG = 0x1368})
    else
        DlgMgr:closeDlg("CreateCharDlg")
        DlgMgr:openDlg("UserLoginDlg")
    end
end

function LeitingSdkMgr:MSG_L_CHARGE_DATA(data)
    self:MSG_CHARGE_INFO(data)
end

-- 付费信息
function LeitingSdkMgr:MSG_CHARGE_INFO(data)
    if not self.loginInfo then return end
    local info = {
        userId = self.loginInfo.userId or "",
        userKey = self.loginInfo.userKey or "",
        zoneId = Client:getWantLoginDistName() or "",
        pf = self.loginInfo.pf or "",
        pfKey = self.loginInfo.pfKey or "",
        money = data.money,
        type = self.loginInfo.type or "",
        notifyUri = data.notify_uri,
        userName = self.loginInfo.userName or "",
        orderId = data.order_id,
        roleId = Me:queryBasic("gid"),
        roleName = Me:getName(),
        extInfo = "",
        arzExtend = "",
        serverId = self.loginInfo.serverId,
        gameCoin = "",
        productName = data.product_name,
        productNumber = 1,
        productId = data.product_id or "",
        gameUUID = DeviceMgr:getMac() or "",
    }

    if string.isNilOrEmpty(Me:queryBasic("gid")) and self:getChannelNO() == CHANNEL_NO["ltly"].channelNo then
        -- 登录上报
        LeitingSdkMgr:loginReport({
            roleId = "1",
            roleName = "1",
            roleLevel = 1,
            zoneId = Client:getWantLoginDistName(),
            roleCTime = 1,
            zoneName = Client:getWantLoginDistName(),
        })

        info.roleId = "1"
        info.roleName = "1"
    end

    LeitingSdkMgr:pay(info)

    -- 金额和数量需要转成字符串
    if gf:isIos() then
        info.money = tostring(info.money)
        info.productNumber = tostring(info.productNumber)
    end
end

-- 是否小米
function LeitingSdkMgr:isXM()
    -- 小米渠道号为  110006
    if self:getChannelNO() == CHANNEL_NO["ltxiaomi"].channelNo then
        return true
    end

    return false
end

-- 是否是雷霆
function LeitingSdkMgr:isLeiting()
    -- 雷霆渠道号为  110001
    if gf:isAndroid() and self:getChannelNO() == CHANNEL_NO["leiting"].channelNo then
        return true
    elseif gf:isIos() and self:getChannelNO() == CHANNEL_NO["leiting"].channelIosNo then
        return true
    end

    return false
end

function LeitingSdkMgr:isOverseas()
    if self:getChannelNO() == CHANNEL_NO["ltoverseas"].channelNo or
       self:getChannelNO() == CHANNEL_NO["ltoverseas"].channelIosNo then
        return true
    end

    return false
end

function LeitingSdkMgr:isSpecialRealNameChannel()
    if self:isYYB()
        or self:getChannelNO() == CHANNEL_NO["ltly"].channelNo
        or self:getChannelNO() == CHANNEL_NO["ltlenovo"].channelNo
        or self:getChannelNO() == CHANNEL_NO["ltiapppay"].channelNo
        or self:getChannelNO() == CHANNEL_NO["ltaiqiyi"].channelNo then
        return true
    end

    return false
end

-- 是否是应用宝
function LeitingSdkMgr:isYYB()
    -- 应用宝渠道号为  120001
    if self:getChannelNO() == CHANNEL_NO["ltmsdk"].channelNo then
        return true
    end

    return false
end

-- 是否OPPO
function LeitingSdkMgr:isOPPO()
    if self:getChannelNO() == CHANNEL_NO["ltoppo"].channelNo then
        return true
    end

    return false
end

-- 是否需要隐藏微信公众号信息
function LeitingSdkMgr:needHideWeixinInfo()
    -- 非官方的隐藏
    if not LeitingSdkMgr:isLeiting() then
        return true
    end

    return false
end

-- 获取SDK属性
function LeitingSdkMgr:getPropertiesValue(key)
    if gf:isAndroid() then
        return callJavaFun("getPropertiesValue", "(Ljava/lang/String;)Ljava/lang/String;", { key })
    elseif gf:isIos() then
        return callOCFun("getPropertiesValue", { name=key })
    end
end

-- 设置是否是客服版本
function LeitingSdkMgr:setForService(status)
    isForService = status
    LeitingSdkMgr.enable = not isForService
end

function LeitingSdkMgr:MSG_LEVEL_UP(map)
    if map.id ~= Me:getId() then return end

    -- 等级发生变化
    local info = {
        zoneId = Client:getWantLoginDistName(),
        zoneName = Client:getWantLoginDistName(),
        roleId = Me:queryBasic("gid"),
        roleName = Me:getName(),
        roleCTime = Me:queryBasicInt("create_time"),
        roleLevel = map.level,
    }

    self:levelUpReport(info)
end

function LeitingSdkMgr:startService(serviceName, callback)
    if gf:isAndroid() then
        callJavaFun("startService", "(Ljava/lang/String;Ljava/lang/String;)V", { serviceName, callback })
    end
end

function LeitingSdkMgr:goAndroidComment()
    local packageName = DeviceMgr:getPackageName()
    local marketPacakgeName = PACAGENAEM_TO_MAKETPACKAGENAME[packageName]
    if not marketPacakgeName or not DeviceMgr:isAppAvailable(marketPacakgeName) then return end
    local uri = AndroidUtil:callStatic("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", {string.format("market://details?id=%s", packageName)})
    if not uri then return end
    local intent = AndroidUtil:newInstance("android.content.Intent", {"java.lang.String", "android.net.Uri"}, {"android.intent.action.VIEW", uri})
    if not intent then return end
    ret = AndroidUtil:callInst("android/content/Intent", "setPackage", intent, "(Ljava/lang/String;)Landroid/content/Intent;", {marketPacakgeName})
    if not ret then return end
    ret = AndroidUtil:callInst("android/content/Intent", "addFlags", intent, "(I)Landroid/content/Intent;", {0x10000000})
    if not ret then return end
    ret = AndroidUtil:callStatic("org/cocos2dx/lua/AppActivity", "getContext", "()Landroid/content/Context;", {})
    if not ret then return end
    AndroidUtil:callInst("org/cocos2dx/lua/AppActivity", "startActivity", ret, "(Landroid/content/Intent;)V", { intent })
    return true
end

function LeitingSdkMgr:isYybBBSEnabled()
    return nil == self.communityEnabled or self.communityEnabled[CHANNEL_NO["ltmsdk"].channelNo] == 1
end

function LeitingSdkMgr:isOppoBBSEnabled()
    return nil == self.communityEnabled or self.communityEnabled[CHANNEL_NO["ltoppo"].channelNo] == 1
end

function LeitingSdkMgr:MSG_ENABLE_COMMUNITY(data)
    self.communityEnabled = data
end

LeitingSdkMgr:init()
MessageMgr:regist("MSG_CHARGE_INFO", LeitingSdkMgr)
MessageMgr:regist("MSG_L_CHARGE_DATA", LeitingSdkMgr)
MessageMgr:regist("MSG_ENABLE_COMMUNITY", LeitingSdkMgr)
MessageMgr:hook("MSG_LEVEL_UP", LeitingSdkMgr, "LeitingSdkMgr")

return LeitingSdkMgr
