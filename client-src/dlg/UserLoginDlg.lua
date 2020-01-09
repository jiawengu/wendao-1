-- UserLoginDlg.lua
-- Created by zhengjh Sep/2015/15
-- 游戏进入界面

local UpdateCheck = require("global/UpdateCheck")
require("mgr/CheckNetMgr")

local UserLoginDlg = Singleton("UserLoginDlg", Dialog)
local MOVE_DISTANCE = 30
local WELCOME_LABEL_TAG = 99

function UserLoginDlg:init()
    self:setFullScreen()
    self.updateCheck = UpdateCheck.new()
    self:bindListener("AccountInfoButton", self.onAccountInfoButton)
    self:bindListener("UserAgreementButton", self.onUserAgreementButton)
    self:bindListener("RepairButton", self.onRepairButton)
    self:bindListener("StateButton", self.onStateButton)
    --self:bindListener("ChangeDistButton", self.onChangeDistButton)
    self:bindListener("EnterGameButton", self.onEnterGameButton)
    self:bindListener("DistSelectPanel", self.onChangeDistButton)
    self:bindListener("ServiceButton", self.onServiceButton)
    self:bindListener("CheckNetButton", self.onCheckNetButton)
    self:bindListener("PlayButton", self.onPlayButton)

    self:setCtrlVisible("PlayButton", cc.FileUtils:getInstance():isFileExist("cg.mp4") and (gf:isIos() or gf:isAndroid()))

    local serviceBtn = self:getControl("ServiceButton")
    if gf:isIos() or (gf:gfIsFuncEnabled(FUNCTION_ID.HELPER_UNLOGIN) and
        (LeitingSdkMgr:isLeiting() or LeitingSdkMgr:isOverseas())) then
        serviceBtn:setVisible(true)
    else
        serviceBtn:setVisible(false)
    end

    local checkNetBtn = self:getControl("CheckNetButton")
    if CheckNetMgr:isEnabled() then
        checkNetBtn:setVisible(true)
    else
        checkNetBtn:setVisible(false)
    end

    self.welcomePanel = self:getControl("WelComePanel")
    self.welcomePanel:retain()
    self.welcomePanel:removeFromParent()

    self:initDistInfo()
    self:setVersionInfo()

	-- 健康公告
	--[[
	local panel = self:getControl("HealthAdvicePanel")
	local bkImage = self:getControl("BKImage", nil, panel)
	bkImage:setContentSize(cc.size(winsize.width, bkImage:getContentSize().height))
    ]]
    -- 设置一些渠道ui的差异性
    self:doChannelUI()

    gf:doLinearVerticalLayout(self:getControl("InfoPanel"))

    self:hookMsg("MSG_EXISTED_CHAR_LIST")
end

-- 设置一些渠道的差异性
function UserLoginDlg:doChannelUI()
    if gf:isAndroid() and not LeitingSdkMgr:isLeiting() and not LeitingSdkMgr:isOverseas() then
        local accountInfoBtn = self:getControl("AccountInfoButton")
        accountInfoBtn:setVisible(false)
    end
end

function UserLoginDlg:cleanup()
    self:releaseCloneCtrl("welcomePanel")

    if self.updateCheck then
        self.updateCheck:dispose()
        self.updateCheck = nil
    end

    self.coOpen = nil
end

function UserLoginDlg:showWelcome()
    if LeitingSdkMgr:isEnable() then
        -- sdk 会给相应的提示
        return
    end

    self:initWelcomLabel()
end

function UserLoginDlg:initWelcomLabel()
    local panel = self.welcomePanel
    self:setLabelText("WelcomeLabel", string.format(CHS[3003790], Client:getAccount()), panel)
    local scene = cc.Director:getInstance():getRunningScene()

    if not scene:getChildByTag(WELCOME_LABEL_TAG) then
        panel:setAnchorPoint(0.5, 0)
        scene:addChild(panel, 99, WELCOME_LABEL_TAG)
    end

    panel:setPosition(Const.WINSIZE.width / 2, Const.WINSIZE.height)
    local moveto = cc.MoveTo:create(0.5, cc.p(panel:getPositionX(), panel:getPositionY() - panel:getContentSize().height - MOVE_DISTANCE))
    local delay = cc.DelayTime:create(1.5)
    local moveback = cc.MoveTo:create(0.5, cc.p(panel:getPositionX(), panel:getPositionY()))
    local sep = cc.Sequence:create(moveto, delay, moveback)
    panel:runAction(sep)

end

function UserLoginDlg:initDistInfo()
    local userDefault = cc.UserDefault:getInstance()
    local lastLoginDist = userDefault:getStringForKey("lastLoginDist", "")
    local noUpdate = userDefault:getIntegerForKey("noupdate", 0)
    local dist

    -- 默认处理
    local function defaultProcess()
        repeat
            -- 获取默认配置区组
            if 0 == noUpdate then
                local defaultDist = DistMgr:getDefaultDist()
                if defaultDist then
                    dist = DistMgr:getDistInfoByName(defaultDist)
                    break
                end
            elseif gf:isWindows() and 1 == noUpdate then
                -- 没配区列表先用默认（测试用）
                dist = {}
                dist.state = 2
                dist.group = CHS[3003791]
                dist.name = userDefault:getStringForKey("dist", "patch_pack_test")
                dist.aaa = userDefault:getStringForKey("aaa", "117.121.4.183:7701")
                if not DistMgr.allDistInfo then
                    DistMgr.allDistInfo = {}
                end

                if not DistMgr.allDistInfo[dist.name] then
                    -- DistMgr.allDistInfo[dist.name] = { [dist.name] = dist, groups = { CHS[3003791] }, default = {} }
                    DistMgr.allDistInfo[dist.name] = dist
                    if not DistMgr.allDistInfo.groups or #(DistMgr.allDistInfo.groups) <= 0 then
                        DistMgr.allDistInfo.groups = { CHS[3003791] }
                    else
                        local exist
                        for i = 1, #(DistMgr.allDistInfo.groups) do
                            if DistMgr.allDistInfo.groups[i] == CHS[3003791] then exist = true break end
                        end

                        if not exist then
                            table.insert(DistMgr.allDistInfo.groups, CHS[3003791])
                        end
                    end

                    if not DistMgr.allDistInfo.default then
                        DistMgr.allDistInfo.default = {}
                    end
                    DistMgr:setDistList(DistMgr.allDistInfo)
                end
                break
            end

            dist = nil
        until true
    end

    -- 没有上次登录信息
    if lastLoginDist == "" then
        defaultProcess()
    else
        local list = gf:split(lastLoginDist, ",")
        local distName = list[1]
        local charName = list[2]
        dist = DistMgr:getDistInfoByName(distName)
        if not dist then defaultProcess() end
    end

    self:setCtrlVisible("ThreeYearDistNamePanel", false)

    if dist then
        -- 状态
        local stateImage = self:getControl("StateImage")
        stateImage:loadTexture(DistMgr:getServerStateImage(dist.state))

        -- 大区
        self:setLabelText("DistTypeLabel", dist.group)

        -- 区组
        if dist.name == CHS[5410328] then
            -- 三周年特殊显示
            self:setCtrlVisible("ThreeYearDistNamePanel", true)
            self:setLabelText("DistNameLabel", "")
        else
            self:setLabelText("DistNameLabel", dist.name)
        end

        self.distName = dist.name

        self.dist = dist
        self:updateLayout('DistSelectPanel')
    else
        -- 大区
        self:setLabelText("DistTypeLabel", "")

        -- 区组
        self:setLabelText("DistNameLabel", "")

        local function coOpenDistDlg()
            if not LeitingSdkMgr:isLogined() then
                -- 还未登录，需要先登录
                LeitingSdkMgr:login()
            end

            while not LeitingSdkMgr:isLogined() do
                coroutine.yield()
            end

            DlgMgr:openDlg("WaitDlg")
            LeitingSdkMgr:queryAllChars({
                    sid = Client:getAccount(),
                }, function(s)
                    local json = require("json")
                    local s, t = pcall(function() return s and json.decode(s) or {} end)
                    if not s then
                        gf:ShowSmallTips(CHS[2100144])
                        t = {}
                    end
                    DlgMgr:openDlgEx("LoginChangeDistDlg", t.data)
                    DlgMgr:closeDlg("WaitDlg")
            end, 5)

            self.coOpen = nil
        end

        -- 启动协程
        if not self.coOpen then
            self.coOpen = coroutine.create(coOpenDistDlg)
            coroutine.resume(self.coOpen)
        end
    end
end

function UserLoginDlg:onUpdate()
    if self.coOpen then
        coroutine.resume(self.coOpen)
    end
end

function UserLoginDlg:onAccountInfoButton(sender, eventType)
    LeitingSdkMgr:accountCenter()
end


function UserLoginDlg:setVersionInfo()
    local version = cc.UserDefault:getInstance():getStringForKey("local-version", "")
    local curLabel = self:getControl("CurrentLabel_1")
    curLabel:setString(CHS[3003792]..version)
    local curLabel2 = self:getControl("CurrentLabel_2")
    curLabel2:setString(CHS[3003792]..version)
end

function UserLoginDlg:onUserAgreementButton(sender, eventType)
    DlgMgr:openDlg("UserAgreementDlg")
end

function UserLoginDlg:onRepair()
    gf:clearLocalCache()
    if self.updateCheck then
        self.updateCheck:reloadGame()
    end
end

function UserLoginDlg:onRepairButton(sender, eventType)
    local dlg = DlgMgr:openDlg("LoginOperateDlg")
    dlg:setRepairDisplay(true)
end

function UserLoginDlg:onStateButton(sender, eventType)
end

function UserLoginDlg:onChangeDistButton(sender, eventType)
    if not LeitingSdkMgr:isLogined() then
        -- 还未登录，需要先登录
        LeitingSdkMgr:login()
        return
    end

    DlgMgr:openDlg("WaitDlg")
    LeitingSdkMgr:queryAllChars({
            sid = Client:getAccount(),
        }, function(s)
        local json = require("json")
        local s, t = pcall(function() return s and json.decode(s) or {} end)
        if not s then
            gf:ShowSmallTips(CHS[2100144])
            t = {}
        end
        DlgMgr:openDlgEx("LoginChangeDistDlg", t.data)
        DlgMgr:closeDlg("WaitDlg")
    end, 5)
end

-- 客服按钮
function UserLoginDlg:onServiceButton(sender, eventType)
    if not GameMgr:isServiceEnabled() then
        gf:ShowSmallTips(CHS[5420262])
    else
    LeitingSdkMgr:helperUnLogin()
    end
end

-- 检查网络按钮
function UserLoginDlg:onCheckNetButton(sender, eventType)
    local CheckNetDlg = require('dlg/CheckNetDlg')
    local checkNetDlg = CheckNetDlg.create(1, nil, self.updateCheck and self.updateCheck:getNetCheckLog())
    gf:getUILayer():addChild(checkNetDlg)
end

-- 播放CG按钮
function UserLoginDlg:onPlayButton(sender, eventType)
    local filePath = cc.FileUtils:getInstance():fullPathForFilename("cg.mp4")
    local CgShow = require("dlg/CgShowDlg")
    local cgShow = CgShow.new(filePath)
    self.blank:addChild(cgShow)
end

-- 设置默认登入的角色名
function UserLoginDlg:setDefaultLoginName()
    Client:setLoginChar(CHS[4200267])    -- 默认一个 "登录" 用于区分是主界面点击登入，然后弹出区组选择界面，默认点击区组；  还是玩家主动点击选择区组

    -- 如果上一次该区组有角色登录，则设置上一次登录的角色名
    local roleInfo =  DistMgr:getHaveRoleInfo(self.distName)
    if roleInfo and roleInfo.roleName and roleInfo.roleName ~= "" then
        Client:setLoginChar(roleInfo.roleName)
    end
end

function UserLoginDlg:onEnterGameButton(sender, eventType)
    Client:setReplaceData(1) -- 0表示直接顶号； 1 表示服务器判断，同mac地址则直接顶号

    self:setDefaultLoginName()        -- 设置默认登入的角色
    self:enterGame()
end

function UserLoginDlg:enterGame()
    if not LeitingSdkMgr:isLogined() then
        -- 还未登录，需要先登录
        LeitingSdkMgr:login()
        return
    end

    local userDefault = cc.UserDefault:getInstance()
    local _enterGame = function()
        local ipstr = userDefault:getStringForKey("host", "117.121.4.183:7008")
        local isGm = userDefault:getIntegerForKey("gm", 0)

        if isGm == 1 then
            local pos = gf:findStrByByte(ipstr, ':')
            if pos == nil then return end
            local ip = string.sub(ipstr, 1, pos - 1)
            local port = string.sub(ipstr, pos + 1, -1)
            Client:setIsNeedEnterGame(true)
            Client:gmLogin(ip, tonumber(port))
        else
            DistMgr:connetAAA(self.distName, true, true)
        end
    end

    local noUpdate = userDefault:getIntegerForKey("noupdate", 0)
    if 0 == noUpdate and self.updateCheck then
        DlgMgr:openDlg("WaitDlg")
        self.updateCheck:doCheck(self.distName, function(succ)
            if succ then
                -- 重新加载公告
                NoticeMgr:reloadUpdateDesc()

                if NoticeMgr:isShowUpdate(1) then
                    DlgMgr:closeDlg("WaitDlg")
                    return
                end

                _enterGame()
            else
                self:initDistInfo()
            end

            DlgMgr:closeDlg("WaitDlg")
        end)

    else
        _enterGame()
    end
end

function UserLoginDlg:MSG_EXISTED_CHAR_LIST(data)
    self:initDistInfo()
end

return UserLoginDlg
