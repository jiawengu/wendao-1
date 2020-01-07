-- created by cheny Feb/12/2014
-- 客户端

require "mgr/MessageMgr"
require "core/Log"
require "comm/CommThread"
local KeepAlive = require "comm/KeepAlive"
local Ver = require("VersionCode")

Client = {}
Client.channelId = "unknown"
Client.connectAgain = false -- 登入方式改了，初始化为false，登入成功后设置为true
Client.lineList ={}

-- 存放调试信息
Client.debugInfo = {}

-- 记录统计通讯模块发送、接收的数据大小
Client.recvDataSize = 0
Client.sendDataSize = 0

Client.notReplace = 1 -- 1 表示不能顶号，只展示角色列表  0 表示可以直接顶号

-- 重连 AAA 次数标记
local reTryConnectAAA = 0;

function Client:addRecvDataSize(size)
    self.recvDataSize = self.recvDataSize + (size or 0)
end

function Client:addSendDataSize(size)
    self.sendDataSize = self.sendDataSize + (size or 0)
end

function Client:getNetStatInfo()
    local info = "Total receive data size: "
    if self.recvDataSize > 1024 then
        info = info .. tostring(math.floor(self.recvDataSize / 1024)) .. 'k'
    else
        info = info .. tostring(self.recvDataSize)
    end

    info = info .. '        Total send data size: '
    if self.sendDataSize > 1024 then
        info = info .. tostring(math.floor(self.sendDataSize / 1024)) .. 'k'
    else
        info = info .. tostring(self.sendDataSize)
    end

    return info .. '\n'
end

-- 清除调试信息
function Client:clearDebugInfo()
    self.debugInfo = {}
end

-- 追加调试信息
function Client:pushDebugInfo(info)
    local timeStr = os.date("%m%d-%H%M%S", os.time())
    table.insert(self.debugInfo, timeStr .. ' ' .. info)
    Log:F(info) -- 记录到文件中
end

-- 获取调试信息
-- lastNum 表示要去最后的几条，0 表示全取
function Client:getDebugInfo(lastNum)
    local netStatInfo = self:getNetStatInfo()
    if #self.debugInfo > 0 then
        lastNum = lastNum or 0
        local i = 1;
        local j = #self.debugInfo
        if lastNum > 0 then
            i = j - lastNum + 1
            if i < 1 then
                i = 1
            end
        end

        return netStatInfo .. table.concat(self.debugInfo, '\n', i, j)
    end

    return netStatInfo
end

--[[function Client:init()
    if GameMgr.normalLogin then
        local pos = string.find(GameMgr.aaa, ":", 1, true)
        if pos then
            CommThread:startAAA(string.sub(GameMgr.aaa, 1, pos - 1), string.sub(GameMgr.aaa, pos + 1))
        end
    end
end]]

function Client:gmLogin(ip, port)
    CommThread:stop()
    CommThread:start(ip, port)
    self._isConnectingGS = true
    gf:setMeAsGD()
end

function Client:tryToKeepAlive(connection)
    if nil ~= self._keepAlive then
        -- 发送同步命令保持连接
        self._keepAlive:sendCmdEcho(connection)
    end
end

-- 获取上次延迟时间
function Client:getLastDelayTime()
    if not self._keepAlive then
        return 0
    end

    local sendTime = self._keepAlive._lastSendTime or 0
    local recvTime = self._keepAlive._lastRecvTime or 0

    if recvTime < sendTime then recvTime = gfGetTickCount() end
    return recvTime - sendTime
end

function Client:getLastRecvTime()
    if not self._keepAlive then
        return 0
    end

    return self._keepAlive._lastRecvTime or 0
end

function Client:hasNetworkStateChanged()
    return self.networkStateChanged
end

function Client:markNetworkStateChanged(isChanged)
    self.networkStateChanged = isChanged
end

function Client:connetAAA(aaa, isNeedLoginAAA, isNeedEnterGame, type)
    Client:pushDebugInfo('connetAAA: ' .. aaa .. ' [ConnectType:' .. tostring(type) .. ']')

    CommThread:stopAAA(type)
    self._authKey = nil

    local pos = string.find(aaa, ":", 1, true)
    if pos then
        CommThread:startAAA(string.sub(aaa, 1, pos - 1), string.sub(aaa, pos + 1), type)
    end

    if not type or type == CONNECT_TYPE.NORMAL then
        self.isNeedLoginAAA = isNeedLoginAAA or true
        self.isNeedEnterGame = isNeedEnterGame
    end
end

function Client:setSimlatorLogin(simlatorLogin)
    self.simlatorLogin = simlatorLogin
end

-- 登录GS
function Client:loginGS(cmd)
    -- 显示等待界面
    if Me:isInCombat() then
        GameMgr:onEndCombat()
    end

    Client:pushDebugInfo(string.format('SEND %s account=%s, sight_scope = %s', cmd, self:getAccount(), tostring(SystemSettingMgr:getSettingStatus("sight_scope", 0))))
    gf:CmdToServer(cmd, {
        user=self:getAccount(),
        seed=self._seed or 0,
        auth_key=self._authKey or 0,
        version=Ver.VER_CODE,
        emulator=DeviceMgr:isEmulator() and 1 or 0,
        sight_scope = SystemSettingMgr:getSettingStatus("sight_scope", 0),
        clientid = GetuiPushMgr:getClientId(),
        netStatus = BatteryAndWifiMgr:getNetworkState(),
        adult = self.adult or -1,
        signature = gfGetMd5(DeviceMgr:getSignInfo()),
        clientname = DeviceMgr:getPackageName(),
        redfinger = DeviceMgr:isRedFinger(),
    })

    self._keepAlive = KeepAlive.new()

    -- 记录网络状态
    local curNetworkState = BatteryAndWifiMgr:getNetType()
    self:markNetworkStateChanged(self.checkDirty and self.curNetworkState and self.curNetworkState ~= curNetworkState)
    self.curNetworkState = curNetworkState
    self.checkDirty = nil
end

-- 连接gs结果
function Client:MSG_CLIENT_CONNECTED(map)
    Client:pushDebugInfo('gs connected: result=' .. tostring(map.result) .. ' [ConnectType:' .. tostring(map.connect_type) .. ']')
    if map.connect_type == CONNECT_TYPE.LINE_UP then
        -- 排队开启的连接
        if not map.result or not DlgMgr:isDlgOpened("LineUpDlg") then
            CommThread:stop(map.connect_type)
        end

        DlgMgr:closeDlg("WaitDlg")
        return
    end

    if not map.result then -- 连不上gs
        -- 重置换线标志位
        DistMgr:setIsSwichServer(false)
        self:doCannotConnectGS(map)
    else
        if self.simlatorLogin then
            self:loginGS('CMD_SIMULATOR_LOGIN')
            self.simlatorLogin = nil
        else
            self:loginGS('CMD_LOGIN')
        end
    end
end

-- aaa链接成功
function Client:MSG_AAA_CONNECTED(map)
    Client:pushDebugInfo('AAA connected: result='.. tostring(map.result) .. ' [ConnectType:' .. tostring(map.connect_type) .. ']')
    if map.connect_type == CONNECT_TYPE.LINE_UP then
        -- 排队开启的连接
        if not map.result or (
                not DlgMgr:isDlgOpened("LineUpDlg")
                and not DlgMgr:isDlgOpened("ReserveRechargeDlg")
                and not DlgMgr:isDlgOpened("ReserveRechargeExDlg")
            )
            then

            CommThread:stopAAA(map.connect_type)
        end

        DlgMgr:closeDlg("WaitDlg")
        return
    end

    if not map.result then -- 连不上aaa
        self:doCannotConnectAAA(map)
    else
        -- 请求队列信息
        reTryConnectAAA = 0;
        self:requestLoginWaitInfo()
    end
end

-- 断开连接
function Client:MSG_CLIENT_DISCONNECTED(map)
    Client:pushDebugInfo('disconnected: isAAA=' .. tostring(map.isAAA) .. ' [ConnectType:' .. tostring(map.connect_type) .. ']')

    if map.connect_type == CONNECT_TYPE.LINE_UP then
        -- 排队开启的连接
        if map.isAAA then
            CommThread:stopAAA(map.connect_type)
        else
            CommThread:stop(map.connect_type)
        end

        DlgMgr:closeDlg("WaitDlg")
        return
    end

    if Me:isInCombat() or Me:isLookOn() then
        GameMgr:onEndCombat()
    end

    DlgMgr:closeDlg("WaitDlg")
    self.checkDirty = nil

    if map.isAAA then
        self:doAAADisConnect(map)
    else
        self:doGSDisConnect(map)
    end

    DlgMgr:resetMainDlgVisible()
end

-- 断开游戏连接
function Client:clientDisconnectedServer(map)
    if not map["isAAA"] then
        -- GS 断开连接
        if Me:isInCombat() then
            -- 在战斗中，先退出战斗
            GameMgr:onEndCombat()
        end

        MessageMgr:clearMsg()
        CharMgr:clearAllChar()
        GameMgr:clearData()
        GameMgr:changeScene('LoginScene', true)

        self:setWaitData()
    else
        -- aaa 断开连接
        if not map.noLineup then
            if not self:hasWaitData() then
                -- 没有排队信息
                self:reConnetServer()
                return
            else
                -- 有排队信息
                local dlg = DlgMgr:getDlgByName("LineUpDlg")
                if dlg then
                    local data = self:getWaitData()
                    data.keep_alive = 0
                    dlg:refreshInfo(data)
                end
            end
        end

        MessageMgr:clearMsg()
    end

    if DlgMgr.dlgs["CreateCharDlg"] then
        DlgMgr:closeDlg("CreateCharDlg")
    end

    self._keepAlive = nil
    Client._isConnectingGS = false
end

-- 没有收到MSG_L_WAIT_IN_LINE消息
-- 过n秒继续重连
function Client:reConnetServer()
    DlgMgr:closeDlg("WaitDlg")
    local dlg = DlgMgr:openDlg("LineUpDlg")
    local waitCode = math.random(36000, 54000)
    if self:hasWaitData() then
        -- 有收到过 AAA 的排队信息
        local data = self:getWaitData()
        data.keep_alive = 0
        dlg:refreshInfo(data)
    else
        local data = {
            line_name = WAIT_LINE_NAME.NORMAL,
            expect_time = self:getWaitLineTime(),
            reconnet_time = math.random(1, 10),
            waitCode = waitCode,
            count = math.random(waitCode, 54000),
            keep_alive = 0,
            notRealLine = true,
            indsider_lv = -1,
            gold_coin = 0,
        }

        dlg:refreshInfo(data)
    end
end

-- 处理服务器aaa断开连接
function Client:doAAADisConnect(map)
    if not self:waitInLine() then
        -- 不在排队中，显示错误信息
        local dlg = DlgMgr:openDlg("LoginOperateDlg")
        dlg:setTips(self.errorStr)

        self:tipWhenCannotConnect()
    elseif self:hasWaitData() and DlgMgr:getDlgByName("LineUpDlg") then
        -- 有排队数据，并且排队界面打开着，刷新排队界面
        local data = self:getWaitData()
        data.keep_alive = 0
        local dlg = DlgMgr:getDlgByName("LineUpDlg")
        if dlg then
            dlg:refreshInfo(data)
        end
    else
        -- 没有排队数据
        self:reConnetServer()
    end
end

-- 处理aaa连不上
function Client:doCannotConnectAAA(map)
    self:tipWhenCannotConnect()

    GameMgr:setGameState(GAME_RUNTIME_STATE.PRE_LOGIN)
    map["isAAA"] = true

    if DlgMgr:getDlgByName("LineUpDlg") and self:hasWaitData() and reTryConnectAAA < 5 then
        reTryConnectAAA = reTryConnectAAA + 1
        local data = self:getWaitData()
        data.keep_alive = 0
        local dlg = DlgMgr:getDlgByName("LineUpDlg")
        if dlg then
            dlg:refreshInfo(data)
        end
    else
        DlgMgr:closeDlg("LineUpDlg")
        self:setWaitData()
        DlgMgr:openDlg("LoginOperateDlg")
    end

    map.noLineup = true
    self:clientDisconnectedServer(map)
    DlgMgr:closeDlg("WaitDlg")

    if 'table' == type(map.netCheckLog) then
        map.netCheckLog["account"] = self._account
        map.netCheckLog["gameZone"] = self:getWantLoginDistName()
        CheckNetMgr:logReportNetCheck(map.netCheckLog)
    end
end

-- 处理服务器断开gs
function Client:doGSDisConnect(map)
    if self:waitInLine() then return end

    CharMgr:clearAllChar()
    if DistMgr:getIsSwichServer() then
        GameMgr:clearData(true)
    else
        AutoWalkMgr:storeAutoWalk() -- 缓存当前的寻路信息备用
        GameMgr:clearData()
    end

    if  self.other_login then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[3003952])
        dlg:setCallFunc(function()
            performWithDelay(gf:getUILayer(), function()
                self:clientDisconnectedServer(map)
                DlgMgr:closeDlg("OnlyConfirmDlg")
                DlgMgr:closeDlg("CreateCharDlg")
                DlgMgr:closeDlg("LoginChangeDistDlg")
                DlgMgr:setVisible("UserLoginDlg", true)
            end, 0)
        end)

        self.other_login = nil
        -- 清除登录信息（顶号需要重新登录sdk）
        LeitingSdkMgr:clearLoginInfo()
    elseif self.block_msg then
        GameMgr:changeScene('LoginScene', true)
        local dlg = DlgMgr:openDlg("LoadingFailedDlg")
        dlg:setTips(self.block_msg)
        MessageMgr:clearMsg()
        self.block_msg = nil
    elseif DistMgr:getSwitchServerData() then
        local switchData = DistMgr:getSwitchServerData()
        DistMgr:clearSwitchServerData()

        if GameMgr:isInBackground() then
            Client:MSG_L_AGENT_RESULT(switchData, true)
        else
            DlgMgr:openDlg("WaitDlg")

            -- 换线，在1.5s内随机去连接
            performWithDelay(gf:getUILayer(),function()
                Client:MSG_L_AGENT_RESULT(switchData, true)
            end, math.random(1, 1500) / 1000)
        end

        return
    elseif self.connectAgain then
        self:setCanTipDisconnect(true)
        MessageMgr:clearMsg()
        self.connectAgain = false
        GameMgr.disTime = gfGetTickCount()
        local aaa =DistMgr:getDistInfoByName(Client:getWantLoginDistName())["aaa"]
        Client:checkVersionAndReconnect(aaa, true)
    elseif self.dontDoLogin then
        -- 不需要弹账号验证界面，只需要显示登录界面
        GameMgr:changeScene('LoginScene', true)
        self:clientDisconnectedServer(map)

        if not DlgMgr.dlgs["LoginChangeDistDlg"] then
            DlgMgr:setVisible("UserLoginDlg", true) -- 隐藏角色界面
        end

        self.dontDoLogin = nil
    elseif self.reNameData then -- 改名重连
        MessageMgr:clearMsg()
        DlgMgr:openDlg("WaitDlg")
        local data = DistMgr:splitSwichServerInfo({msg = self.reNameData.msg})
        self:MSG_L_AGENT_RESULT(data, true)
        self.reNameData = nil
        return
    elseif self.charInOtherServer then -- 要登录的线和玩家在线上的线不一同不弹出重连的框
        self.charInOtherServer = false
    else
        self:tipWhenCannotConnect()

        self:clientDisconnectedServer(map)

        if Client.notReplace == 1 then
            self.noShowLoginOperateDlg = true
        end

        if not self.noShowLoginOperateDlg then
            -- 需要显示 LoginOperateDlg
            local dlg = DlgMgr:openDlg("LoginOperateDlg")
            dlg:setTips(self.errorStr)
        end

        self.noShowLoginOperateDlg = nil
        if self.backLoginTip and "" ~= self.backLoginTip then
            local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
            dlg:setTip(self.backLoginTip)
            self.backLoginTip = nil
        end

        if self.forbidSimulatorData then
            gf:showForbidSimulatorDlg(self.forbidSimulatorData)
            self.forbidSimulatorData = nil
        end
    end

    Client._isConnectingGS = false
end

-- 处理gs连不上
function Client:doCannotConnectGS(map)
    self:tipWhenCannotConnect()

    GameMgr:setGameState(GAME_RUNTIME_STATE.PRE_LOGIN)
    DlgMgr:openDlg("LoginOperateDlg")
    self:clientDisconnectedServer(map)

    if 'table' == type(map.netCheckLog) then
        map.netCheckLog["account"] = self._account
        map.netCheckLog["gameZone"] = self:getWantLoginDistName()
        CheckNetMgr:logReportNetCheck(map.netCheckLog)
    end
end

-- 是否不显示 LoginOperateDlg
function Client:setNoShowLoginOperateDlg(noShow)
    self.noShowLoginOperateDlg = noShow
end

function Client:CMD_ECHO(map)
    if not self._keepAlive then
        return
    end

    self._keepAlive:onRecvCmdEcho()
end

function Client:MSG_REPLY_ECHO(map)
    if not self._keepAlive then
        return
    end

    local peer_time = map["peer_time"]
    self._keepAlive:onRecvMsgReplyEcho(peer_time)
end

function Client:MSG_L_ANTIBOT_QUESTION(map)
    Client:pushDebugInfo('SEND CMD_L_CHECK_USER_DATA')

    gf:CmdToAAAServer("CMD_L_CHECK_USER_DATA", { data = ""})----todo
end

function Client:MSG_L_CHECK_USER_DATA(map)
    Client:pushDebugInfo('RECV MSG_L_CHECK_USER_DATA result=' .. tostring(map.result)
                         .. ', NeedLoginAAA=' .. tostring(self.isNeedLoginAAA))

    if map["result"] == 0 then
        -- 不符合要求，给出提示
        gf:ShowSmallTips(CHS[1000953])
    else
        -- 保存密钥
        self._cookie = map["cookie"]
    end

    if self.isNeedLoginAAA then
        self:longinAAA(Client.notReplace)
    end
end

function Client:setReplaceData(state)
    Client.notReplace = state
end

-- 清除当前登录的账号信息
function Client:clearAccountInfo()
    self._account = nil
    self.password = nil
end

-- 保存和密码
function Client:setNameAndPassword(name, password, from3rdSdk)
    -- 保存登录信息
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey("user", name)

    self._account = name
    self.password = password

    -- 通知区组管理器当前使用的账号信息，以便判断是否为评审账号
    DistMgr:setCurAccount(name)

    -- 清除aaa缓存的角色信息
    DistMgr:clearDistRoleInfo()

    -- 设置该账号上次登录的信息
    DistMgr:setHaveRoleDist(name)

    -- 清除排队信息
    self:setWaitData()

    if from3rdSdk then
        self.from3rdSdk = 1
    else
        self.from3rdSdk = 0
    end
end

-- 获取原始账号
function Client:getRawAccount()
    return self._account
end

-- 获取账号
function Client:getAccount()
    return LeitingSdkMgr:reviseAccount(self._account, self:getWantLoginDistName())
end

-- 设置渠道 id
function Client:setChannelId(channelId)
    self.channelId = channelId or "unknown"
end

-- 设置成人 id
function Client:setAdult(adult)
    self.adult = tonumber(adult)
end

-- 获取渠道 id
function Client:getChannelId()
    return self.channelId
end

-- 登录aaa    not_replace;   // 1 表示不能顶号，只展示角色列表  0 表示可以直接顶号
function Client:longinAAA(not_replace)
    if not LeitingSdkMgr:isLogined() then
        -- 还未登录，需要先登录
        LeitingSdkMgr:login()
        DlgMgr:closeDlg("WaitDlg")
        return
    end

    self:cmdAccount(not_replace, ACCOUNT_TYPE.NORMAL)
end

function Client:cmdAccount(not_replace, type, conType)
    local pwd = gfEncrypt(self.password, self._cookie)
    local mac = DeviceMgr:getMac()

    if gf:isAndroid() then
        mac = mac .. "|".. DeviceMgr:getImei() .. '|' .. DeviceMgr:getSerialno() .. '|' .. DeviceMgr:getAndroidId()
    end

    self:pushDebugInfo('SEND CMD_L_ACCOUNT account = ' .. self:getAccount())

    local termInfo = DeviceMgr:getTermInfo()

    -- to be delete 如果是测试区组，则在设备信息中追加 0 对应的时间信息，以便定位问题 WDSY-21394
    if DistMgr:curIsTestDist() then
        local timeInfo = os.date("*t", 0)
        termInfo = string.format("%s %d:%d:%d", termInfo, timeInfo.hour, timeInfo.min, timeInfo.sec)
    end

    gf:CmdToAAAServer("CMD_L_ACCOUNT", {
        account = self:getAccount(),
        data = "",
        mac = mac,
        channel = self:getChannelId(),
        os_ver = DeviceMgr:getOSVer(),
        term_info = termInfo,
        imei = DeviceMgr:getImei(),
        client_original_ver = DeviceMgr:getOriginalVer(),
        lock = "",----todo
        password = pwd,
        dist = self.wantLoginDistName,
        from3rdSdk = self.from3rdSdk,
        not_replace = not_replace,
        type = type or "",
    }, conType)
end

-- aaa登录成功
function Client:MSG_L_AUTH(map)
    if map.type == ACCOUNT_TYPE.CHARGE or map.type == ACCOUNT_TYPE.INSIDER then
        -- 进入游戏前的充值、购买会员时的账号验证失败
        local dlg = DlgMgr:openDlg("LoginOperateDlg")
        dlg:setTips(map["msg"])
        return
    end

    if map["result"] == 1 then

        local dist = GameMgr.dist
        local authKey = map["auth_key"]
        self._authKey = authKey

        self:tryLogin()
        --[[if self.isNeedEnterGame then
            self:tryLogin()  -- 需要登录gs
        else
            DistMgr:requireDistRoleInfo()   -- 不要登录就请求角色列表
        end]]

    else
        -- aaa登录不成功 断开aaa
        CommThread:stopAAA()
        self:setWaitData()
        self.errorStr = map["msg"];

        -- 清除登录信息（aaa验证需要重新登录sdk）
        LeitingSdkMgr:clearLoginInfo()
        self:doAAADisConnect()
    end
end

-- 通知客户端账号转换失败原因（发送该消息时，不会再发送 MSG_L_AUTH 消息）
-- 失败原因：平台存在账号但本区组该账号未激活记为 1，平台不存在账号记为 2
function Client:MSG_L_CHANGE_ACCOUNT_ABORT(data)
    if not self.updateCheck then
        local UpdateCheck = require("global/UpdateCheck")
        self.updateCheck = UpdateCheck.new()

        local function onNodeEvent(event)
            if "cleanup" == event then
                self:onNodeCleanup()
            end
        end
        gf:getUILayer():registerScriptHandler(onNodeEvent)
    end

    if data.flag == 1 or data.flag == 2 or data.flag == 3 then
        -- 平台账号验证失败，断开aaa，清除登录信息(需要重新登录sdk)
        CommThread:stopAAA()
        LeitingSdkMgr:clearLoginInfo()
        DlgMgr:closeDlg("WaitDlg")
    end

    if data.flag == 1 then
        gf:confirmEx(CHS[7150037], CHS[7150039], function()
            -- 前往下载
            self.updateCheck:loadFullPackage()
        end, CHS[7150038], function()
            -- 重选区组
            local dlg = DlgMgr:getDlgByName("LoginChangeDistDlg")
            if not dlg then
                DlgMgr:openDlg("LoginChangeDistDlg")
            end
        end)
    elseif data.flag == 2 then
        -- 退出游戏    前往下载
        gf:confirmEx(CHS[7150037], CHS[7150039], function()
            self.updateCheck:loadFullPackage()
        end, CHS[7150040], function()
            performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                cc.Director:getInstance():endToLua()
                if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
                    cc.Director:getInstance():mainLoop()
                end
            end, 0.1)
        end)
    elseif data.flag == 3 then
        -- 平台存在该账号，但当前旧账号仍使用原渠道包登录进入游戏，且游戏中的角色处于不可被踢下线的状态
        self.updateCheck:createConfirmDlg(CHS[7150043])
    end
end

-- 尝试登录
function Client:tryLogin()
    CharMgr:clearAllChar()
    GameMgr:clearData()

    -- 如果aaa断开重连
    local connectionAAA = CommThread:getConnectionAAA()
    if (not connectionAAA or not connectionAAA._socketObject) and self.wantLoginDistName then
        DistMgr:connetAAA(self.wantLoginDistName , true, true)
    else
        self:requireLineList()
    end
end

-- 请求线服务器
function Client:requireLineList()
    if self:getAccount() and self._authKey then
        gf:CmdToAAAServer("CMD_L_GET_SERVER_LIST", {
            account = self:getAccount(),
            auth_key = self._authKey,
            dist = self.wantLoginDistName
        })
    end
end

-- 线列表
function Client:MSG_L_SERVER_LIST(map)
    --self.lineList = map
    local serverName = self.enterServerName or map["server1"]
    self:enterLine(serverName)

    -- 第一个线是要进入的线，会和后面线重复掉，所有要去除
   self.lineList ={}
    self.lineList.count = map.count - 1
   for i = 1, self.lineList.count do
        self.lineList[string.format("server%d", i)] = map[string.format("server%d", i + 1)]
        self.lineList[string.format("ip%d", i)] = map[string.format("ip%d", i + 1)]
        self.lineList[string.format("status%d", i)] = map[string.format("status%d", i + 1)]
    end
end

function Client:setEnterLineServerName(enterServerName)
    self.enterServerName = enterServerName
end

-- 获取线列表
function Client:getLineList()
    return self.lineList or {}
end


-- 获取gs列表
function Client:getGsList()
    gf:CmdToServer("CMD_REQUEST_SERVER_STATUS")
end
-- gs列表
function Client:MSG_REQUEST_SERVER_STATUS(data)
     self:setIsLineInfoChange(data)
     self.lineList = data
end

-- 这次请求的gs对比上次是否变化(用来要不要刷新线列表界面)
function Client:setIsLineInfoChange(data)
	self.isLineInfoChange = false

	if nil == self.lineList or self.lineList.count ~= data.count then
	   self.isLineInfoChange = true
	else
	   for i = 1, data.count do
	      if data["status"..i] ~= self.lineList["status"..i] then
                self.isLineInfoChange = true
                break
	      end
	   end
	end
end

function Client:getIsLineInfoChange()
    return self.isLineInfoChange
end

-- 进入某条线
function Client:enterLine(lineName)
    if nil == lineName then return end
    Client:pushDebugInfo('SEND CMD_L_CLIENT_CONNECT_AGENT account = ' .. self:getAccount())
    gf:CmdToAAAServer("CMD_L_CLIENT_CONNECT_AGENT", {
        account = self:getAccount(),
        auth_key = Client._authKey,
        server = lineName,
    });

    self.enterServerName = nil
end

-- 登录
function Client:MSG_L_AGENT_RESULT(map, isChangeLine)
    Client:pushDebugInfo('RECV MSG_L_AGENT_RESULT result=' .. tostring(map.result or 0) .. ' msg=' .. (map.msg or ""))

    self._seed = map["seed"]
    self._authKey = map["auth_key"] or 0
    if nil == self.lineList then
        self.lineList = {}
    end

    -- 设置当前服务器的状态
    if nil == self.lineList.count or 0 >= self.lineList.count then
        self.lineList.count = 1
        self.lineList["server1"] = map.serverName or self.lineList["server1"] or ""
        self.lineList["status1"] = map.serverStatus or self.lineList["status1"] or ""
        self.lineList["id"] = map.id or self.lineList["id1"] or ""
        end

    local result = map["result"]

    if 1 == result then
        CommThread:stopAAA()
        CommThread:stop()
        Client._isConnectingGS = true
        CommThread:start(map["ip"], map["port"])
        Client:pushDebugInfo('connect gs: ' .. (map.serverName or (map.ip .. ':' .. map.port)))
    else
        self.errorStr = CHS[3003954] ..map["msg"]
    end

    Me:setBasic("privilege", map["privilege"])
    if not isChangeLine then
        GMMgr.mePrivilege = map["privilege"]
    end
end

-- 设置要登录的角色
function Client:setLoginChar(name)
    self.loginCharName = name
    self._ssLoginChar = nil
end


-- 设置要登录的区组
function Client:setWantLoginDistName(distName)
    self.wantLoginDistName = distName
end

-- 获取要登录区组
function Client:getWantLoginDistName()
    if self.wantLoginDistName then
        return self.wantLoginDistName
    end

    local info = DistMgr.defaultInfo
    if info then
        return info["dist"] or ""
    end

    return ""
end

function Client:setIsNeedEnterGame(isNeedEnterGame)
    self.isNeedEnterGame = isNeedEnterGame
end

-- 登录成功返回角色列表
function Client:MSG_EXISTED_CHAR_LIST(data)
    Client:pushDebugInfo('RECV MSG_EXISTED_CHAR_LIST count = ' .. data.count)

    if DlgMgr:getDlgByName("LoginChangeDistDlg") then
        DlgMgr:closeDlg("WaitDlg")
    end

    self.loginCharList = data

    -- 刷新角色数量
    if data.count > 0 then
        DistMgr:refreshHaveRole(self:getWantLoginDistName(), data.count )
    end

    -- 设置连上gs时刻
    GameMgr:setLoginGsTime()

    -- 寄售相关判断
    local char = self:getWillLoginChar(data)
    local tradingState = 0 -- 寄售状态
    local online_state = 0
    for i = 1, data.count do
        if data[i].name == char.name then
            tradingState = data[i].trading_state
        end

        if data[i].char_online_state > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
            online_state = data[i].char_online_state
        end
    end

    -- 如果没有角色，并且无角色在线，则创建角色
    if data.account_online == CHAR_ONLINE_STATE.CHAR_LIST_T_NONE and data.count == 0 and self.loginCharName == CHS[4200267] then
        DlgMgr:closeDlg("WaitDlg")
        local dlg = DlgMgr:getDlgByName("LoginChangeDistDlg")
        if not dlg then
            dlg = DlgMgr:openDlg("LoginChangeDistDlg")
            dlg:setSelectDistName(self:getWantLoginDistName())
            performWithDelay(dlg.root, function ()
                dlg:selectCharBydist(self:getWantLoginDistName())
                --dlg:MSG_EXISTED_CHAR_LIST(data)
            end, 0)
        end

        DlgMgr:openDlg("CreateCharDlg")
        self.loginCharName = nil
        DistMgr:clearDistRoleInfo()
        return
    end

    -- 3002921:创建
    if (data.count == 0 and self.loginCharName ~= CHS[3002921]) or tradingState > TRADING_STATE.SHOW or (data.account_online > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE and self.loginCharName ~= CHS[3002921]) then
        -- 该角色寄售状态不应许登入
        -- 若不能顶号，只展示角色列表情况下，有角色在线，也不能登入
        DlgMgr:closeDlg("WaitDlg")
        local dlg = DlgMgr:getDlgByName("LoginChangeDistDlg")
        if not dlg then
            dlg = DlgMgr:openDlg("LoginChangeDistDlg")
            dlg:setSelectDistName(self:getWantLoginDistName())
            performWithDelay(dlg.root, function ()
                dlg:selectCharBydist(self:getWantLoginDistName())
                --dlg:MSG_EXISTED_CHAR_LIST(data)
            end, 0)
        end

        if data.account_online > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
            -- 当有角色在线，服务器1秒后会断开，若客户端不断开，目前发现有些模拟器上会    服务器断开，客户端认为正常连接中的情况，所以客户端主动断开
            CommThread:stopAAA()
            CommThread:stop()
        end
        return
    end

    if self.isNeedEnterGame then
        self:loginGame()
    end

    if online_state > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
        DlgMgr:closeDlg("WaitDlg")
        local dlg = DlgMgr:getDlgByName("LoginChangeDistDlg")
        if not dlg then
            dlg = DlgMgr:openDlg("LoginChangeDistDlg")
            performWithDelay(dlg.root, function ()
                dlg:selectCharBydist(self:getWantLoginDistName())
                --dlg:MSG_EXISTED_CHAR_LIST(data)
            end, 0)
        end

        return
    end

    -- 清除排队信息
    self:setWaitData()
    self._ssLoginChar = nil
end

function Client:getCharListInfo()
    return self.loginCharList
end

function Client:clearCharListInfo()
    self.loginCharList = nil
end

function Client:loginGame()
    -- 如果gs断开，直接重连aaa，gs进入游戏
    if  self._isConnectingGS == false then
        DistMgr:connetAAA(self:getWantLoginDistName(), true, true)
        return
    end

    if not self.loginCharList then
        return
    end

    local data = self.loginCharList
    if self.loginCharName == CHS[3003957] or (data.count == 0 and not self._ssLoginChar) then
        DlgMgr:openDlg("CreateCharDlg")
        DistMgr:clearDistRoleInfo()
        return
    end

    -- 设置登录角色区组信息信息
    DistMgr:refreshLastLoginDist(self:getWantLoginDistName(), self.loginCharName or "")

    --data.severState = 0 ----- cyq
    if data.severState == 0 then -- 服务器尚未开放
        if NoticeMgr:isShowPreChargeAndPreCreateChar() then
            -- 显示预充值活动，带页签，可以切换到预创角活动
            NoticeMgr:showNewDistPreChargeDlg(true)
        elseif NoticeMgr:isShowNewDistPreChargeDlg() then
            -- 只显示预充值活动
            NoticeMgr:showNewDistPreChargeDlg()
        elseif NoticeMgr:isShowPreCreatDescDlg() then
            -- 只显示预创角色活动
            NoticeMgr:showPreCreateDescDlg()
        else
            -- 如果不需要显示预创角的公告，也不需要显示预充值活动
        local dlg = DlgMgr:openDlg("AccountVerifyFailedDlg")
            dlg:setTips(gf:getServerDate(CHS[6000234], data.openServerTime) .. CHS[3003958])
        dlg:setIsCreatCharTips(true) --用来标识要不要重连aaa刷新区组列表
        end

        -- 如果是创建角色成功,弹出创建角色成功提示
        local dlg = DlgMgr.dlgs["CreateCharDlg"]
        if dlg then
            gf:ShowSmallTips(CHS[3003956])
        end

        CommThread:stop() -- 断开gs
    else

        if data.count == 0 then return end

        local char = self:getWillLoginChar(data)
        Client:createNewPlayerBattle(char)
    end
end

function Client:getWillLoginChar(data)
    local char = nil
    for i = 1, data.count do
        if data[i].name == self.loginCharName then
            char = data[i]
            break
        end
    end

    if not char then
        if self._ssLoginChar then
            for i = 1, data.count do
                if data[i].name == self._ssLoginChar then
                    char = data[i]
                end
            end

            if not char then
                char = Client:getDefaultChar(data)
            end
        else
            char = Client:getDefaultChar(data)
        end
    end

    return char
end

-- 该账号中没有上次登录的信息登录等级最高那个
function Client:getDefaultChar(data)
    -- 优先查找改名
    local char = nil
    local userDefault = cc.UserDefault:getInstance()
    local name = userDefault:getStringForKey("renameStr", "")

    for i = 1, data.count do
        if data[i].name == name then
            char = data[i]
        end
    end

    -- 从角色列表中选出等级最高的角色
    if not char then
        for i = 1, data.count do
            if not char or char.level < data[i].level then
                char = data[i]
            end
        end
    end

    return char or data[1]
end

function Client:createNewPlayerBattle(char)
    local showNewPlayerBattle = char.last_login_time == 0
    local function __createNewPlayerBattle()
        if showNewPlayerBattle then
        -- 新手战斗,需要判断是否服务器繁忙
            local status = tonumber(self.lineList["status1"])
            local serverName = self.lineList["server1"]
            if status == SERVER_STATUS.ALLFULL then
                -- 服务器已满不让进
                local dlg = DlgMgr:openDlg("AccountVerifyFailedDlg")
                dlg:setTips(serverName .. CHS[3003959])
                return
            end

            -- 需要读条啊
            MapMgr:beginLoad(1.4)
            local data = require("cfg/NewComerCombat")
            local dlg = DlgMgr:getDlgByName("LoadingDlg")
            local magicArr = BattleSimulatorMgr:getAllMagicIcon(data)
            for k, v in pairs(magicArr) do
                magicArr[k] = function()
                    BattleSimulatorMgr:loadOneMagic(v)
                end
            end

            dlg:setUserDlg(magicArr)
            if dlg then
                dlg:registerExitCallBack(function()
                    self:startWelcomNewOne(char)
                end)
            end

            -- 新手指引，清空快捷操作
            ShortcutMgr:setOper(0)

            -- 清除gs连接空闲时间
            GameMgr:clearLoginGsTime()

            -- 进入新手开场战斗，算作已经用新建角色登录了，此时要进行“是否保留之前聊天记录”的判断
            GameMgr:setLoginRole(char.gid)
        else
            Client:pushDebugInfo('SEND CMD_LOAD_EXISTED_CHAR char = ' .. char["name"])
            gf:CmdToServer("CMD_LOAD_EXISTED_CHAR", {
                char_name=char["name"]
            })

            -- 切换游戏状态
            GameMgr:setGameState(GAME_RUNTIME_STATE.LOGINING)
        end
    end

    if (gf:isWindows() or GMMgr:isGM()) and showNewPlayerBattle then
        gf:confirm(CHS[2200091], function()
            showNewPlayerBattle = false
            __createNewPlayerBattle()
        end, function()
            __createNewPlayerBattle()
        end)
    else
        __createNewPlayerBattle()
    end
end

function Client:startWelcomNewOne(char)
    DlgMgr:closeDlg("CreateCharDlg")

    GameMgr:changeScene('GameScene')
    gf:getMapBgLayer():removeAllChildren()
    gf:getMapEffectLayer():removeAllChildren()
    gf:getMapObjLayer():removeAllChildren()
    local map = GameMgr.scene:initMap(01000)
    local mapContentSize = map:getContentSize()
    map:setCurMapPos(22 * Const.RAW_PANE_WIDTH, mapContentSize.height - 108 * Const.RAW_PANE_HEIGHT, true)
    BattleSimulatorMgr:newOneWelcome(char["polar"], char["name"], char["icon"])
    Me:absorbBasicFields({polar = char["polar"]})

    DlgMgr:setVisible("HeadDlg", false)

    DlgMgr:closeDlg("SkillStatusDlg")
    DlgMgr:closeDlg("CombatViewDlg")

    -- 注册回调，通知服务端，新手第一场战斗已经结束
    BattleSimulatorMgr:registerEndBattleFunc(function(battleData)

        DlgMgr:setAllDlgVisible(false)
        -- MapMgr:beginLoad(3)

        local dlg = DlgMgr:openDlg("LoadingDlg")
        dlg:setStartDlg()
        Client:pushDebugInfo('SEND CMD_LOAD_EXISTED_CHAR char = ' .. char["name"])
        gf:CmdToServer("CMD_LOAD_EXISTED_CHAR", {
            char_name=char["name"]
        })

        -- 切换游戏状态
        GameMgr:setGameState(GAME_RUNTIME_STATE.LOGINING)
    end)
end

-- 重置客户端计时
function Client:resetTickCount()
    gfResetTickCount()

    if nil ~= self._keepAlive then
        self._keepAlive._lastSendTime = gfGetTickCount()
    end
end

-- 当前的有角色存在
function Client:MSG_CHAR_ALREADY_LOGIN(data)
end

-- 角色已存在某线
function Client:MSG_ACCOUNT_IN_OTHER_SERVER(data)
    DistMgr:switchServer(data)
end

-- 顶号
function Client:MSG_OTHER_LOGIN(data)
    DistMgr:setIsSwichServer(false)
    if data.result == 0 then -- 登录失败
        CommThread:stop() -- 断开gs

       if GameMgr:getCurSceneType() == "GameScene" then -- 在游戏场景得退回到登录大厅
            self.block_msg = data.msg

            -- 这个是gs断开连接， 必须要回到主界面
            MessageMgr:pushMsg({ MSG = 0x1368, result = false })
        else
            local dlg = DlgMgr:openDlg("LoadingFailedDlg")
            dlg:setTips(data.msg)
            GameMgr:setGameState(GAME_RUNTIME_STATE.PRE_LOGIN)
        end
    elseif data.result == 1 then -- 顶号操作
        self.other_login = true

        -- 这个操作只能维持3秒
        performWithDelay(gf:getUILayer(),function()
            self.other_login = nil
        end, 3)

        EventDispatcher:dispatchEvent(EVENT.OTHER_LOGIN, { })
    elseif data.result == 2 then -- 封号断开
        CommThread:stop() -- 断开gs
        self.block_msg = data.msg

        -- 这个是gs断开连接， 必须要回到主界面
        MessageMgr:pushMsg({ MSG = 0x1368, result = false })
    elseif data.result == 3 then
        -- 重连 AAA
        self.block_msg = nil
        self.connectAgain = true
        self.other_login = nil
        DistMgr:clearSwitchServerData()

        -- 这个是gs断开连接， 必须要回到主界面
        MessageMgr:pushMsg({ MSG = 0x1368, result = false })
    end
end

-- 改名成功断开消息
function Client:MSG_OPER_RENAME(data)
    if data.result == 1 then
        self.reNameData = data
        DlgMgr:closeDlg("UserDlg")

        -- 改名卡住界面
        DlgMgr:openDlg("WaitDlg")
    else
        gf:ShowSmallTips(data.msg)
        DlgMgr:closeDlg("WaitDlg")
    end

    self:setRenameStr(data.new_name)
end

-- 设置改名的名字
function Client:setRenameStr(new_name)
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey("renameStr", new_name)
end

-- 退出排队
function Client:cancelWaitLine()
    self:setWaitData()
    CommThread:stopAAA()

    self:clientDisconnectedServer({})
end

-- 请求登录排队信息
function Client:requestLoginWaitInfo()
    Client:pushDebugInfo('SEND CMD_L_REQUEST_LINE_INFO')
    gf:CmdToAAAServer("CMD_L_REQUEST_LINE_INFO", {
        account = self:getAccount()
    })
end

-- 登录排队信息
function Client:MSG_L_WAIT_IN_LINE(data)
    Client:pushDebugInfo('RECV MSG_L_WAIT_IN_LINE status=' .. tostring(data.line_name))

    -- 缓存排队登录数据
    self:setWaitData(data)

    if not self:waitInLine() then
        -- 无需等待了
        local dlg = DlgMgr:getDlgByName("LineUpDlg")
        if dlg then
            -- 如果存在界面则刷新界面
            dlg:refreshInfo(data)
        end
    else
        -- 需要等待，打开界面
        DlgMgr:closeDlg("WaitDlg")
        local dlg = DlgMgr:openDlg("LineUpDlg")
        dlg:refreshInfo(data)
    end
end

function Client:MSG_NEW_DIST_PRECHARGE_DATA(data)
    self.newDistPreChargeData = data
end

function Client:getNewDistPreChargeData()
    return self.newDistPreChargeData
end

-- 开始登录流程
function Client:MSG_L_START_LOGIN(data)
    if data.type ~= ACCOUNT_TYPE.NORMAL then
        self._cookie = data.cookie
        return
    end

    Client:pushDebugInfo('RECV MSG_L_START_LOGIN isNeedLoginAAA' .. tostring(self.isNeedLoginAAA))
    DlgMgr:closeDlg("LineUpDlg")
    DlgMgr:openDlg("WaitDlg")

    -- 清除排队数据
    self:setWaitData()

    -- 保存密钥，准备登录
    self._cookie = data.cookie
    if self.isNeedLoginAAA then
        self:longinAAA(Client.notReplace)
    end
end

-- 设置排队数据
function Client:setWaitData(data)
    self.waitData = data

    if not data then
        -- 进行清数据的操作
        self.waitLineRanTime = nil
    end
end

-- 获取排队数据
function Client:getWaitData()
    return self.waitData
end

-- 是否存在排队数据
function Client:hasWaitData()
    if not self.waitData then
        return false
    end

    return true
end

-- 是否处于排队队列中
function Client:waitInLine()
    if not self.waitData then
        return false
    end

    return self.waitData.need_wait ~= 0
end

-- 还没连上aaa是随机的时间，后面连不需要再随机事件直到连上
function Client:getWaitLineTime()
    if not self.waitLineRanTime then
        self.waitLineRanTime = math.random(450 * 60, 550 * 60)
    end

    return self.waitLineRanTime
end

-- 清楚相关数据
function Client:cleanData()
    self.lineList = {}
    self:clearReconnectShowPara()
end

-- 检查版本并重连
function Client:checkVersionAndReconnect(aaa, tryAagin)
    local noUpdate = cc.UserDefault:getInstance():getIntegerForKey("noupdate", 0)
    if 1 == noUpdate then
        GameMgr:keepAutoWalkWhenLoginDone(tryAagin)
        GameMgr:changeScene('LoginScene', true, true)
        self:connetAAA(aaa, true, true)
        return
    end

    if not self.updateCheck then
        local UpdateCheck = require("global/UpdateCheck")
        self.updateCheck = UpdateCheck.new()

        local function onNodeEvent(event)
            if "cleanup" == event then
                self:onNodeCleanup()
            end
        end
        gf:getUILayer():registerScriptHandler(onNodeEvent)
    end

    DlgMgr:openDlg("WaitDlg")
    self.updateCheck:doCheck(Client:getWantLoginDistName(), function(succ)
        DlgMgr:closeDlg("WaitDlg")
        if succ then
            self.checkDirty = true
            GameMgr:keepAutoWalkWhenLoginDone(tryAagin)
            GameMgr:changeScene('LoginScene', true, true)
            self:connetAAA(aaa, true, true)
        else
            -- 退回登录界面
            CommThread:stop()
            GameMgr:keepAutoWalkWhenLoginDone()
            Client:clientDisconnectedServer({})
        end
    end)
end

-- 节点析构
function Client:onNodeCleanup()
    if self.updateCheck then
        self.updateCheck:dispose()
        self.updateCheck = nil
    end
end

function Client:MSG_KICK_OFF(data)
    self.connectAgain = false
    self.noShowLoginOperateDlg = true
    self.backLoginTip = data and data.tip
    if not self.backLoginTip or "" == self.backLoginTip then
        self.backLoginTip = CHS[2000126]
    end
end

function Client:MSG_SIMULATOR_LOGIN(data)
    if 'LoginScene' == GameMgr:getCurSceneType() then
        gf:showForbidSimulatorDlg(data)
    else
        self.forbidSimulatorData = data
    end
end

function Client:setCanTipDisconnect(canTip)
    self.canTipDisconnect = canTip
end

-- 断开连接失败提示
function Client:tipWhenCannotConnect()
    if GameMgr:getCurSceneType() ~= "LoginScene" and self.canTipDisconnect then
        SoundMgr:playHint("friend")
        if SystemSettingMgr:getSettingStatus("refuse_shock", 0) == 0 then
            VibrateMgr:vibrate()
        end
    end

    self:setCanTipDisconnect(false)
end

-- GS 关机
function Client:MSG_GS_REBOOT(data)
    self:MSG_KICK_OFF({ tip = CHS[5000294] })
end

-- 显示角色重连参数
function Client:MSG_SHOW_RECONNECT_PARA(data)
    self.reconnect_show_para = data
end

-- 获取显示角色重连参数
function Client:getReconnectShowPara(distName)
    if not self.reconnect_show_para then
        -- 没有数据
        return
    end

    if (self.reconnect_show_para.dist_name ~= distName) then
        -- 不是同一个区组
        return
    end

    if self.reconnect_show_para.end_time <= gf:getServerTime() then
        -- 超时
        return
    end

    return self.reconnect_show_para.msg
end

-- 清除显示角色重连参数
function Client:clearReconnectShowPara()
    self.reconnect_show_para = nil
end

function Client:MSG_SF_LOGIN_CHAR_FAIL(data)
    self.noShowLoginOperateDlg = true
end

MessageMgr:regist("MSG_CLIENT_CONNECTED", Client)
MessageMgr:regist("MSG_CLIENT_DISCONNECTED", Client)
MessageMgr:regist("CMD_ECHO", Client)
MessageMgr:regist("MSG_REPLY_ECHO", Client)
MessageMgr:regist("MSG_L_ANTIBOT_QUESTION", Client)
MessageMgr:regist("MSG_L_CHECK_USER_DATA", Client)
MessageMgr:regist("MSG_AAA_CONNECTED", Client)
MessageMgr:regist("MSG_L_AUTH", Client)
MessageMgr:regist("MSG_L_CHANGE_ACCOUNT_ABORT", Client)
MessageMgr:regist("MSG_L_SERVER_LIST", Client)
MessageMgr:regist("MSG_L_AGENT_RESULT", Client)
MessageMgr:regist("MSG_EXISTED_CHAR_LIST", Client)
MessageMgr:regist("MSG_NEW_DIST_PRECHARGE_DATA", Client)
MessageMgr:regist("MSG_CHAR_ALREADY_LOGIN", Client)
MessageMgr:regist("MSG_ACCOUNT_IN_OTHER_SERVER", Client)
MessageMgr:regist("MSG_REQUEST_SERVER_STATUS", Client)
MessageMgr:regist("MSG_OTHER_LOGIN", Client)
MessageMgr:regist("MSG_OPER_RENAME", Client)
MessageMgr:regist("MSG_L_WAIT_IN_LINE", Client)
MessageMgr:regist("MSG_L_START_LOGIN", Client)
MessageMgr:regist("MSG_SERVER_TYPE", Client)
MessageMgr:regist("MSG_KICK_OFF", Client)
MessageMgr:regist("MSG_SIMULATOR_LOGIN", Client)
MessageMgr:regist("MSG_GS_REBOOT", Client)
MessageMgr:regist("MSG_SHOW_RECONNECT_PARA", Client)
MessageMgr:regist("MSG_SF_LOGIN_CHAR_FAIL", Client)

return Client
