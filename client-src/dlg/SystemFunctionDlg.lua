-- SystemFunctionDlg.lua
-- created by cheny Nov/28/2014
-- 系统功能对话框

local SystemFunctionDlg = Singleton("SystemFunctionDlg", Dialog)
local BtnList = {}
local btnPosMap = {
    ["SmallMapButton"]  = 1,
    --["ArenaButton"]     = 2,
    ["LiangongButton"]  = 3,
   -- ["ExerciseButton"]  = 4,
    ["ShuadaoButton"]   = 5,
    ["ActivityButton"]  = 6,
    ["AnniversaryButton"]  = 7,
    ["QQButton"]   = 8,
    ["GoodVoiceButton"] = 9,
    ["H5DownloadButton"]   = 10,
    ["PromoteButton"]   = 11,

    -- 可以伸展的按钮
    -- 向左展开按钮
    ["ShengSiButton"] = 101,
    ["RankingListButton"]   = 102,

    -- 向右展开按钮
    ["MallButton"]          = 201,
    ["TradeButton"]        = 202,
    ["GiftsButton"]         = 203,
}

local NEED_HIDE_IN_SERVER = {
    ["LiangongButton"]      = true,
    ["ShuadaoButton"]       = true,
    ["ActivityButton"]      = true,
    ["AnniversaryButton"]   = true,
    ["QQButton"]            = true,
    ["RankingListButton"]   = true,
    ["MallButton"]          = true,
    ["TradeButton"]         = true,
    ["GiftsButton"]         = true,
    ["ShengSiButton"]       = true,
    ["GoodVoiceButton"]     = true,
    ["H5DownloadButton"]    = true,
}

local STATUS_BTN = SFD_STATUS_BTN

local ButtonState = {
    status1 = 1,   -- 按钮展开状态
    status2 = 2,   -- 按钮收起状态
}

local TYPE_HORIZONTAL = 1
local TYPE_VERTICAL = 2
local MOVE_SPEED = 10
local NOT_OPERATE_SECONDS = 20
local JUBAO_DIS = 10 + 68

local TEMP_BUTTON_TAG = 100

-- 收起和展开的时间
local ACTION_TIME = 0.25

local DIF_TIME_BETWEEN_ACTION_AND_HIDE = 0.15

local BUTTON_SIZE = 68

local BUTTON_MARGIN = 0

SystemFunctionDlg.touchPoints = {}
SystemFunctionDlg.crossPoints = {}

local MUTITOUCH_DIRECTION = {
    NO_DIRECTION = 0,
    LEFT = 1,
    RIGHT = 2,
    UP = 3,
    DOWN = 4,
}

function SystemFunctionDlg:init()
    self:setFullScreen()
    self:bindListener("GiftsButton", self.onGiftsButton)
    -- self:bindListener("ArenaButton", self.onArenaButton)
    self:bindListener("ShuadaoButton", self.onShuadaoButton)
    self:bindListener("RankingListButton", self.onRankingListButton)
    self:bindListener("MallButton", self.onMallButton)
    self:bindListener("ActivityButton", self.onActivityButton)
    self:bindListener("SmallMapTouchPanel", self.onSmallMapButton)
    self:bindListener("WorldMapButton", self.onWorldMapButton)
    self:bindListener("ExerciseButton", self.onExerciseButton)
    self:bindListener("ShowTradeButton", self.onTradeButton)
    self:bindListener("HideTradeButton", self.onTradeButton)
    self:bindListener("MarketButton", self.onMarketButton)
    self:bindListener("TreasureButton", self.onTreasureButton)
    self:bindListener("AuctionButton", self.onAuctionButton)
    self:bindListener("SignalTouchPanel", self.onSignalButton)
    self:bindListener("JubaoButton", self.onJubaoButton)
    self:bindListener("TradingSpotButton", self.onTradingSpotButton)
    self:bindListener("QQButton", self.onQQButton)
    self:bindListener("AnniversaryButton", self.onAnniversaryButton)
    self:bindListener("ShengSiButton", self.onShengSiButton)
    self:bindListener("StatusButton1", self.onStatusButton1)
    self:bindListener("StatusButton2", self.onStatusButton2)
    self:bindListener("GoodVoiceButton", self.onGoodVoiceButton)
    self:setCtrlVisible("H5DownloadButton", false)
    self:setCtrlVisible("TimeLabel_3", false)
    self:setCtrlVisible("TimeLabel_4", false)


    self:bindListener("ShowAllUIButton", function()
        GameMgr:showAllUI()
    end)

    self:setCtrlVisible("JubaoButton", not DeviceMgr:isReviewVer())

    self:setStatusButtonPos()

    self.tradeSize = self.tradeSize or self:getControl("TradePanel"):getContentSize()
    self.tradeFristPosX = self:getControl("MarketButton"):getPositionX()

    self.curStatus = ButtonState.status1
    self:onStatusButton1()

    -- 由于喇叭提示要显示在 SystemFunctionDlg 上层，
    -- 所以如果该界面后打开，要重新排序  ChatDlg 的层级
    if DlgMgr:getDlgByName("ChatDlg") then
        DlgMgr:reorderDlgByName("ChatDlg")
    end

    self:setCtrlVisible("TrusteeshipPanel", false)
    self:setCtrlVisible("ShouxlpPanel", false)

    gf:align(self:getControl("ShowAllUIButton"), Const.WINSIZE, ccui.RelativeAlign.alignParentRightBottom)
    self:setCtrlVisible("ShowAllUIButton", false)

    -- 初始化判断是否满足触发条件（是否显示可提升按钮）并绑定按钮
    self.promoteButton = self:getControl("PromoteButton", Const.UIButton)
    self:setPromoteButtonVisible(PromoteMgr:promoteBtnDisplay())
    self:bindListener("PromoteButton", self.onPromoteButton)

    -- 点击换线功能
    self:bindListener("SwitchLineTouchPanel", self.onDistPanel)

    -- 时间刷新
    schedule(self:getControl("TimeLabel_1"), function()
        self:updateTime()
        self:refreshSignalColor()
    end, 1)

    self:blindLongPress("LiangongButton", self.liangongLongpress, self.onLiangongButton)
    -- self:hookMsg("MSG_LIVENESS_INFO")

    self.signalImages =  {
        self:getControl("SignalImage_1", nil, "SignalPanel_0"),
        self:getControl("SignalImage_2", nil, "SignalPanel"),
        self:getControl("SignalImage_3", nil, "SignalPanel"),
        self:getControl("SignalImage_4", nil, "SignalPanel"),
    }
    self:refreshSignalColor()

    self:hookMsg("MSG_OPEN_WELFARE")
    self:hookMsg("MSG_ENTER_GAME")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_REFRESH_SHUAD_TRUSTEESHIP")
    self:hookMsg("MSG_TRADING_ENABLE")
    self:hookMsg("MSG_SPOT_ENABLE")
    self:hookMsg("MSG_LD_LIFEDEATH_ID")
    self:hookMsg("MSG_LD_MATCH_DATA")

    self:updateTime()

    -- 刷新一下线
    self:MSG_ENTER_GAME()

    -- 双倍点数
    self:MSG_UPDATE()

    -- 标志是否打开交易界面
    self.isOpenTrade = false
    self:setMarketPanelVisible(self.isOpenTrade)

    -- 更新一下网络状态
    self:updateNetwork(BatteryAndWifiMgr:getNetworkState())
end

function SystemFunctionDlg:setStatusButtonPos()
    local winSize = self:getWinSize()
    local width = winSize.width / Const.UI_SCALE
    local height = winSize.height / Const.UI_SCALE
    local mapSize = self:getControl("SmallMapButton"):getContentSize()
    local statusButton = self:getControl("StatusButton1")
    statusButton:setPosition(BUTTON_SIZE / 2, height - mapSize.height - BUTTON_SIZE / 2)

    local statusButton = self:getControl("StatusButton2")
    statusButton:setPosition(BUTTON_SIZE / 2, height - mapSize.height - BUTTON_SIZE / 2)
end

function SystemFunctionDlg:MSG_UPDATE()
    if Me:queryBasicInt("enable_double_points") == 1 then -- 开启双倍点数
        local point =  Me:queryBasicInt("double_points")
        self:setLabelText("DoublePointLabel", point..CHS[3003690])
        self:setLabelText("DoublePointLabel2", point..CHS[3003690])
        self:setCtrlVisible("DoublePointPanel", true)
    else
        self:setCtrlVisible("DoublePointPanel", false)
    end
end

-- 更新电池状态
function SystemFunctionDlg:updateBattery(rawlevel, scale, status, health)
    local level;
    if rawlevel >= 0 and scale > 0 then
        level = (rawlevel * 100) / scale;
    end

    local batterProcessBar = self:getControl("ProgressBar")
    local chargeImage = self:getControl("ChargeImage")

    if BATTERY_STATE.OVERHEAT == health then
        -- gf:ShowSmallTips("电池过热！")
    else
        if BATTERY_STATE.UNKNOWN == status then
            -- gf:ShowSmallTips("这神器没有电池！")
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.CHARGING == status then
            -- 充电状态
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        elseif BATTERY_STATE.DISCHARGING == status
            or BATTERY_STATE.NOT_DISCHARGING == status then
            -- 更新电池状态即可
            batterProcessBar:setVisible(true)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.FULL == status then
            -- 充满了
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        end
    end

    -- 更新电池状态
    batterProcessBar:setPercent(level)
end

-- 更新网络状态
function SystemFunctionDlg:updateNetwork(networkState)
    GameMgr.networkState = networkState
    if NET_TYPE.WIFI ~= networkState then
        self:setCtrlVisible("SignalPanel", false)
        self:setCtrlVisible("SignalPanel_0", true)
        return
    end

    self:setCtrlVisible("SignalPanel", true)
    self:setCtrlVisible("SignalPanel_0", false)
end

-- 更新wifi状态
-- 0 - -50信号最好， -50 - -70信号差点， 小于 -70 的信号最差
function SystemFunctionDlg:updateWifiStatus(wifiState, level)
    local levelStatus
    if level < -70 then
        levelStatus = 1
    elseif level < -50 then
        levelStatus = 2
    else
        levelStatus = 3
    end

    self:updateWifiUI(levelStatus)
end

function SystemFunctionDlg:updateWifiUI(levelStatus)
    local wifiLevelImg = {
        [1] = "SignalImage_2",
        [2] = "SignalImage_3",
        [3] = "SignalImage_4",
    }

    for k, v in pairs(wifiLevelImg) do
        self:setCtrlVisible(v, false)
    end

    self:setCtrlVisible(wifiLevelImg[levelStatus], true)
end

function SystemFunctionDlg:updateTime()
    local curTime = os.date("%H:%M")
    self:setLabelText("TimeLabel_1", curTime)
    self:setLabelText("TimeLabel_2", curTime)
end

function SystemFunctionDlg:cleanup()
    BtnList = {}

    if self.tradeButtonSeq then
        self.root:stopAction(self.tradeButtonSeq)
        self.tradeButtonSeq = nil
    end
end

function SystemFunctionDlg:setMapName(name)
    local label = self:getControl("MapNameLabel", Const.UILabel)
    if gf:getTextLength(name) > 11 then
        label:setFontSize(14)
    elseif gf:getTextLength(name) > 10 then
        label:setFontSize(16)
    else
        label:setFontSize(17)
    end
    label:setString(name)

    -- 跨服竞技/化妆舞会/万妖窟/百兽之王过图时要刷新线路信息
    self:MSG_ENTER_GAME()
end

function SystemFunctionDlg:refreshSignalColor()
    if not self.signalImages or #self.signalImages <= 0 then return end

    local delay = Client:getLastDelayTime()
    local color
    if delay < 500 then
        color = SIGNAL_COLOR.WHITE
    else
        color = SIGNAL_COLOR.RED
    end

    local singleImage
    for i = 1, #self.signalImages do
        singleImage = self.signalImages[i]
        singleImage:setColor(color)
    end
end

function SystemFunctionDlg:onGiftsButton(sender)
    if not DistMgr:checkCrossDist() then return end

    -- 改为先请求消息等收到消息后再打开界面
    -- GiftMgr:openGiftDlg()
    GiftMgr:openGift(true)
    sender = sender or self:getControl("GiftsButton")
    local magic = sender:getChildByTag(Const.ARMATURE_MAGIC_TAG)
    if magic then
        magic:removeFromParent()
    end
end

-- 神秘大礼倒计时
function SystemFunctionDlg:MSG_OPEN_WELFARE()
    local welfareData = GiftMgr:getWelfareData()

    local timeCountLabel = self:getControl("CountDownLabel")
    local timeCountLabel2 = self:getControl("CountDownLabel2")

    if  welfareData["leftTimes"] > 0 and welfareData["times"] == 0 then
        self:setCtrlVisible("CountDownPanel", true)
        local time = welfareData["leftTime"]
        timeCountLabel:setString(self:getTimeStr(time))
        timeCountLabel:stopAllActions()
        schedule(timeCountLabel ,
             function()
                if time == 0 then
                    GiftMgr:openGift()
                    timeCountLabel:stopAllActions()
                    return
                end
                time = time - 1
                timeCountLabel:setString(self:getTimeStr(time))
                timeCountLabel2:setString(self:getTimeStr(time))
            end, 1)
    else
        self:setCtrlVisible("CountDownPanel", false)
    end
end

function SystemFunctionDlg:getTimeStr(time)
    local hours = math.floor(time / 3600)
    local minute = math.floor(time % 3600 /60)
    local second = time % 60

    local str = string.format("%02d:%02d", minute, second )

    return str
end

function SystemFunctionDlg:onArenaButton()
    if Me:queryBasicInt("level") >= 20 then
        DlgMgr:openDlg('ArenaDlg')
    else
        gf:ShowSmallTips(CHS[6000105])
    end
end

function SystemFunctionDlg:liangongLongpress()
    if not DistMgr:checkCrossDist() then return end

    PracticeMgr:autoWalkOnCurMap(false)
end

function SystemFunctionDlg:onLiangongButton()
    if not DistMgr:checkCrossDist() then return end

    if Me:queryBasicInt("level") >= 20 then
        DlgMgr:openDlg('PracticeDlg')
    else
        gf:ShowSmallTips(CHS[6000152])
    end
end

function SystemFunctionDlg:onShuadaoButton()
    -- CG外挂记录log
    RecordLogMgr:isMeetCGPluginCondition("SystemFunctionDlg")

    if not DistMgr:checkCrossDist() then return end

    local limitLevel = 45
    if Me:queryBasicInt("level") < limitLevel then
        gf:ShowSmallTips(string.format(CHS[4000214], limitLevel))
        return
    end

    local last = DlgMgr:getLastDlgByTabDlg('GetTaoTabDlg') or 'GetTaoDlg'
    DlgMgr:openDlg(last)
end

function SystemFunctionDlg:onRankingListButton()
    if not DistMgr:checkCrossDistOpenRank() then
        gf:ShowSmallTips(CHS[5000267])
        return
    end

    DlgMgr:openDlg('RankingListDlg')
end

function SystemFunctionDlg:onMallButton()
    if not DistMgr:checkCrossDist() then return end

    -- 请求商城信息
    OnlineMallMgr:openOnlineMall()
end

function SystemFunctionDlg:onDistPanel()
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if TeamMgr:inTeamEx(Me:getId()) and not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[3003691])
        return
    end

    -- 有一般性界面存在
    if DlgMgr:isExsitGeneralDlg() then
        gf:ShowSmallTips(CHS[3003692])
        return
    end

    -- 是否在副本中
    if DugeonMgr:isInDugeon() and not MapMgr:getCurrentMapName() == CHS[4100734] then
        gf:ShowSmallTips(CHS[3003693])
        return
    end

    -- 换线
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003694])
        return
    end

    if Me:isLookOn() then
        gf:ShowSmallTips(CHS[3003695])
        return
    end

    if TeamMgr:inTeamEx(Me:getId()) and not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[3003691])
        return
    end

    if (DistMgr:isInKFZC2019Server() or KuafzcMgr:isInKuafzc2019()) and not GMMgr:isGM() and not KuafzcMgr:isKFZCJournalist() then
        gf:ShowSmallTips(CHS[4010373])
        return
    end

    if (GameMgr:isShiDaoServer() or MapMgr:isInShiDao()) and not GMMgr:isGM() and not ShiDaoMgr:isSDJournalist() then
        gf:ShowSmallTips(CHS[2100051])
        return
    end

    if MapMgr:getCurrentMapName() == CHS[5400352]
          or DistMgr:isHomeServer()
          or DistMgr:isInKFSDServer() then
        gf:ShowSmallTips(CHS[5000236])
        return
    end

    if MapMgr:isInQMLoulan() then
        -- 全民楼兰城
        if not QuanminPKMgr:isQMJournalist() and not GMMgr:isGM() and not GMMgr:isWarAdmin(CHS[4300464]) then
            gf:ShowSmallTips(CHS[7001023])
            return
        end
    end

    if MapMgr:isInQMSaiChang() then
        -- 全民赛场
        if not QuanminPKMgr:isQMJournalist() and not GMMgr:isGM() and not GMMgr:isWarAdmin(CHS[4300464]) then
            gf:ShowSmallTips(CHS[7001024])
            return
        end
    end

    if MapMgr:isInMRZB() then
        if not TaskMgr:isMRZBJournalist() and not GMMgr:isGM() and not GMMgr:isWarAdmin(CHS[4300465]) then
            gf:ShowSmallTips(CHS[5000236])
            return
        end
    end

    if MapMgr:getCurrentMapName() == CHS[4100734] then
        if GMMgr:isGM() or KuafzcMgr:isKFZCJournalist() then
        else
            gf:ShowSmallTips(CHS[4100735])
            return
        end
    end

    if MapMgr:getCurrentMapName() == CHS[4100736] then
        if GMMgr:isGM() or KuafzcMgr:isKFZCJournalist() then
        else
            gf:ShowSmallTips(CHS[4100737])
            return
        end
    end

    if not MapMgr:checkDlgSwitchLine() then
        gf:ShowSmallTips(CHS[2100051])
        return
    end

    DlgMgr:openDlg("SystemSwitchLineDlg")
end

function SystemFunctionDlg:setTradeVisible(isVisible)
    self.isOpenTrade = isVisible
    self:setMarketPanelVisible(self.isOpenTrade)

    if self.tradeButtonSeq then
        self.root:stopAction(self.tradeButtonSeq)
    end
end

function SystemFunctionDlg:onTradeButton()
    self.isOpenTrade = not self.isOpenTrade
    self:setMarketPanelVisible(self.isOpenTrade)

    if self.tradeButtonSeq then
        self.root:stopAction(self.tradeButtonSeq)
    end

    if self.isOpenTrade then
        self.tradeButtonSeq = performWithDelay(self.root, function()
            if self.isOpenTrade then
                self:onTradeButton()
            end

            self.tradeButtonSeq = nil
        end, NOT_OPERATE_SECONDS)
    else
        self.tradeButtonSeq = nil
    end
end

function SystemFunctionDlg:getOpenTradeStatus()
    return self.isOpenTrade
end

function SystemFunctionDlg:setMarketPanelVisible(isVisible)
    self:setCtrlVisible("HideTradeButton", isVisible)
    self:setCtrlVisible("ShowTradeButton", not isVisible)

    self:setCtrlVisible("TreasureButton", MarketMgr:isShowGoldMarket())

    self:setCtrlVisible("TradingSpotButton", GuideMgr:isIconExist(34) and TradingSpotMgr:isTradingSpotEnable())

    self:updateTradePanel()
end

function SystemFunctionDlg:onTreasureButton()
    if not DistMgr:checkCrossDist() then return end

    MarketMgr:setTradeType(MarketMgr.TradeType.goldType)
    local dlgName = DlgMgr:getLastDlgByTabDlg("MarketGoldTabDlg") or "MarketGoldBuyDlg"
    DlgMgr:openDlg(dlgName)
    self:onTradeButton()
end

function SystemFunctionDlg:onAuctionButton()
    if not DistMgr:checkCrossDist() then return end

    DlgMgr:openDlg("MarketAuctionDlg")

    self:onTradeButton()
end

function SystemFunctionDlg:onJubaoButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[4100402])
        return
    end

    local last = DlgMgr:getLastDlgByTabDlg('JuBaoZhaiTabDlg') or 'JuBaoZhaiNoteDlg'
    DlgMgr:openDlg(last)
    --DlgMgr:openDlg("JuBaoZhaiNoteDlg")

    self:onTradeButton()
end

-- 货站
function SystemFunctionDlg:onTradingSpotButton(sender, eventType)
    if not TradingSpotMgr:isTradingSpotOpen() then return end
    if not TradingSpotMgr:checkCanOepnTradingSpot() then return end

    -- 设置打开货站标记，请求数据，数据回来再打开界面
    TradingSpotMgr.needOpenTradingSpot = true
    TradingSpotMgr:requestMainSpotData(1)

    self:onTradeButton()
end

function SystemFunctionDlg:onQQButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    DlgMgr:openDlgWithParam({"ActivitiesDlg", CHS[6400009] .. ":" .. CHS[2200018]})
    ActivityMgr:cmdClickQQGiftButton(1)
end

-- 生死状按钮
function SystemFunctionDlg:onShengSiButton(sender, eventType)
    local id = sender.shengSiId
    if id then
        gf:CmdToServer("CMD_LD_MATCH_DATA", {id = id})
    end

    self:removeMagic(sender, Const.ARMATURE_MAGIC_TAG)
end

-- 显示延时
function SystemFunctionDlg:onSignalButton(sender, eventType)
    self:refreshSignalColor()
    local delay = Client:getLastDelayTime()
    if delay > 5000 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", "5000+"), sender)
    elseif delay < 200 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#c30E50B", tostring(delay)), sender)
    elseif delay >= 200 and delay <= 500 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF2DF0C", tostring(delay)), sender)
    else
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", tostring(delay)), sender)
    end

    if printProfile and 'function' == type(printProfile) then
        printProfile()
    end
end

function SystemFunctionDlg:onMarketButton()
    if not DistMgr:checkCrossDist() then return end

    MarketMgr:setTradeType(MarketMgr.TradeType.marketType)
    local dlgName = DlgMgr:getLastDlgByTabDlg("MarketTabDlg") or "MarketBuyDlg"
    DlgMgr:openDlg(dlgName)
    self:onTradeButton()
end

function SystemFunctionDlg:onActivityButton()
    if not DistMgr:checkCrossDist() then return end

    DlgMgr:openDlgWithParam('ActivitiesDlg')

 --[[   if tonumber(Me:queryBasicInt("level")) >= 10 then
        ActivityMgr:getActiviInfo()
    else
        gf:ShowSmallTips(CHS[6000151])
    end]]
end

function SystemFunctionDlg:onAnniversaryButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local last = DlgMgr:getLastDlgByTabDlg('AnniversaryTabDlg') or 'AnniversaryRewardDlg'

    if last == "AnniversaryLingMaoDlg" then
        local task = TaskMgr:getTaskByName(CHS[5400448])
        if not task or string.match(task.task_prompt, CHS[5400517]) then
            DlgMgr:openDlg("AnniversaryRewardDlg")
        else
            AnniversaryMgr:tryOpenLingMaoDlg()
        end
    else
        DlgMgr:openDlg(last)
    end

    -- 移除光效
    if sender then
        local magic = sender:getChildByTag(ResMgr.magic.first_login_during_znq)
        if magic then
            magic:removeFromParent()
        end
    end
end

-- 隐藏可提升按钮
function SystemFunctionDlg:setPromoteButtonVisible(isShow)
    if not DistMgr:getIsSwichServer() then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "PromoteButton")
    end

    if not isShow or self:isContainIcon("PromoteButton") then
        self.promoteButton:setVisible(isShow)
    end
end

-- 触摸提升按钮则打开提升对话框
function SystemFunctionDlg:onPromoteButton(sender)
   local dlg = DlgMgr:openDlg("PromoteDlg")

    RedDotMgr:removeOneRedDot("SystemFunctionDlg", "PromoteButton")

   -- 设置展开的可提升对话框的位置
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setFloatingFramePos(rect)

end

function SystemFunctionDlg:checkIsExsitIcon(buttons)
    for k = 1, #buttons do
        if self:isContainIcon(buttons[k]) then
            return true
        end
    end

    return false
end

function SystemFunctionDlg:onStatusButton1(sender)
    if GameMgr:mainUIIsMoving() or (sender and not sender:isVisible()) then
        -- WDSY-27237 修改
        return
    end

    -- 展开时判断是否有按钮可展开，没有则隐藏
    if not self:checkIsExsitIcon(STATUS_BTN) then
        self:doStateChangeButton("")
        return
    end

    self:doStateChangeButton(ButtonState.status1)
    self:showButton(STATUS_BTN, ACTION_TIME, function()
        self.curStatus = ButtonState.status1
        self:doShowOrHideButton()
    end)

    DlgMgr:sendMsg("ChatDlg", "onShrinkButton")
    DlgMgr:sendMsg("SouxlpSmallDlg", "setVisible", false)
end


function SystemFunctionDlg:onGoodVoiceButton(sender)
    gf:CmdToServer("CMD_GOOD_VOICE_OPEN_DLG")
end

function SystemFunctionDlg:onStatusButton2(sender)
    if GameMgr:mainUIIsMoving() or (sender and not sender:isVisible()) then
        -- WDSY-27237 修改
        return
    end

    -- 展开时判断是否有按钮可展开，没有则隐藏
    if not self:checkIsExsitIcon(STATUS_BTN) then
        self:doStateChangeButton("")
        return
    end

    self:doStateChangeButton(ButtonState.status2)
    self:hideButton(STATUS_BTN, ACTION_TIME, function()
        self.curStatus = ButtonState.status2
        self:doShowOrHideButton()

        if not Me:isInCombat() then
            DlgMgr:sendMsg("SouxlpSmallDlg", "setVisible", true)
        end
    end)

    RedDotMgr:updateSFDShowBtnRedDot()
end

function SystemFunctionDlg:doStateChangeButton(status)
    self:setCtrlVisible("StatusButton1", status == ButtonState.status2)
    self:setCtrlVisible("StatusButton2", status == ButtonState.status1)
end

function SystemFunctionDlg:doShowOrHideButton()
    -- 控制各按钮的显示与隐藏
    for i = 1, #STATUS_BTN do
        local needShow = (self.curStatus == ButtonState.status1) and self:isContainIcon(STATUS_BTN[i])
        self:setCtrlVisible(STATUS_BTN[i], needShow)
    end
end


function SystemFunctionDlg:MSG_LIVENESS_INFO()
    DlgMgr:openDlg('ActivitiesDlg')
end
function SystemFunctionDlg:onSmallMapButton()
    if Me:isInCombat() then
        return
    end

    local dlg = DlgMgr:openDlg("SmallMapDlg")
    dlg:initData()
end

function SystemFunctionDlg:onWorldMapButton()
    if Me:isInCombat() then
        return
    end

    DlgMgr:openDlg("WorldMapDlg")
end

function SystemFunctionDlg:onExerciseButton()
    -- 获取当前等级
    local curLev = Me:queryBasicInt("level")
    if curLev < 20 then
        gf:ShowSmallTips(CHS[5000077])  -- 20级开放练功功能。
    else
        gf:sendGeneralNotifyCmd(NOTIFY.GET_EXERCISE)
        DlgMgr:openDlg("ExerciseDlg")
    end
end

function SystemFunctionDlg:isContainIcon(ctrlName)
    for i = 1, #BtnList do
        if BtnList[i] == ctrlName then
            return true
        end
    end

    return false
end

function SystemFunctionDlg:needHideButtonInSomeServer(ctrlName)
    local curServerType = DistMgr:getCurServerType()
    if not GameMgr:IsCrossDist() or not NEED_HIDE_IN_SERVER[ctrlName] then
        return false
    end

    if ctrlName == "RankingListButton" and DistMgr:checkCrossDistOpenRank() then
        return false
    end

    return true
end

function SystemFunctionDlg:checkCanShow(ctrlName)
    if MapMgr:isInYuLuXianChi() and ctrlName ~= "SmallMapButton" then
        return false
    end

    return not self:needHideButtonInSomeServer(ctrlName)
end

function SystemFunctionDlg:addListIcon(ctrlName)
    if self:checkCanShow(ctrlName) then
        if nil ~= self:getControl(ctrlName) and nil ~= btnPosMap[ctrlName] and not self:isContainIcon(ctrlName) then
            table.insert(BtnList, ctrlName)
        end
    end
end

function SystemFunctionDlg:clearAllIcon()
    BtnList = {}
end

function SystemFunctionDlg:removeListIcon(ctrlName)
    for i = #BtnList, 1, -1 do
        if BtnList[i] == ctrlName then
            table.remove(BtnList, i)
            self:doSomeAfterRemoveIcon(ctrlName)
            return true
        end
    end
end

function SystemFunctionDlg:doSomeAfterRemoveIcon(ctrlName)
    if ctrlName == "AnniversaryButton" then
        -- 删除周年按钮要关闭周年庆界面
        local tabDlg = DlgMgr:getDlgByName("AnniversaryTabDlg")
        if tabDlg then
            DlgMgr:closeDlg(tabDlg.lastDlg)
            gf:ShowSmallTips(CHS[5410036])
            ChatMgr:sendMiscMsg(CHS[5410036])
        end
    end
end

function SystemFunctionDlg:addRedDoForZaixqyFirstLogin()
    local data = GiftMgr:getWelfareData()
    if not data then return end
    if data.isShowHuiGui > 0 then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton8")
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
    end

    if data.isShowZhaohui > 0 and Me:queryBasicInt("level") >= 70 then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton14")
        RedDotMgr:insertOneRedDot("CallBackDlg", "GoCallBackButton")
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
    end

end

function SystemFunctionDlg:addMarginInButton(ctrlName)
    local btn = self:getControl("AnniversaryButton")
    if btn and ctrlName == "AnniversaryButton" then
        local notFirstLoginInZNQ = cc.UserDefault:getInstance():getIntegerForKey("lastZNQLoginTime" .. gf:getShowId(Me:queryBasic("gid"))) or 0
        if false and not gf:isSameDay5(notFirstLoginInZNQ, gf:getServerTime()) then
            -- 暂时屏蔽2018周年庆图标光效，后续任务再增加
            -- 周年庆活动期间每天5点第一次登入，光效

            local effect = btn:getChildByTag(ResMgr.magic.first_login_during_znq)
            if not effect then
                local effect =  gf:createLoopMagic(ResMgr.magic.first_login_during_znq, nil, {blendMode = "add"})
                effect:setAnchorPoint(0.5, 0.5)
                effect:setPosition(btn:getContentSize().width / 2,btn:getContentSize().height / 2)
                effect:setContentSize(btn:getContentSize())
                btn:addChild(effect, 1, ResMgr.magic.first_login_during_znq)
            end

            cc.UserDefault:getInstance():setIntegerForKey("lastZNQLoginTime" .. gf:getShowId(Me:queryBasic("gid")), gf:getServerTime())
        end
    end
end


function SystemFunctionDlg:unVisibleAllCtrl()
    for k, v in pairs(btnPosMap) do
        local ctrl = self:getControl(k)
        ctrl:setVisible(false)
    end
end

-- 停止界面所有按钮action
function SystemFunctionDlg:clearAllAction()
    local statusBtn1 = self:getControl("StatusButton1")
    statusBtn1:stopAllActions()
    local statusBtn2 = self:getControl("StatusButton2")
    statusBtn2:stopAllActions()

    for k, v in pairs(btnPosMap) do
        local ctrl = self:getControl(k)
        ctrl:stopAllActions()
    end
end

-- 将所有控件进行排序
function SystemFunctionDlg:sortIcon(list)
    -- 获取所有的控件进行排序
    table.sort(list, function(l, r)
        if btnPosMap[l] >= btnPosMap[r] then
            return false
        end

        return true
    end)
end

function SystemFunctionDlg:refreshIcon(isGuide, ctrlName)
    local status = self.curStatus
    if isGuide and ctrlName then
        if STATUS_BTN[ctrlName] then
            status = ButtonState.status1
        end
    end

    -- WDSY-26616 退出战斗时，在比较卡的情况下，可能出现GameMgr.hideAllUI未执行结束，以下逻辑先执行的情况，导致
    self:clearAllAction()

    self:unVisibleAllCtrl()

    -- 获取所有的控件进行排序
    self:sortIcon(BtnList)

    local dlgContentSize = self.root:getContentSize()
    -- 首先排列第一列横排
    local topX = 0
    local topY = dlgContentSize.height
    local leftTop = nil
    for i = 1, #BtnList do
        if btnPosMap[BtnList[i]] < 100 then
            local ctrlName = BtnList[i]
            local ctrl = self:getControl(ctrlName)
            local contentSize = ctrl:getContentSize()
            if i > 1 then
                ctrl:setPosition(topX + contentSize.width / 2, topY - contentSize.height / 2)
            else
                ctrl:setAnchorPoint(0.5, 0.5)
                ctrl:setPosition(topX + contentSize.width / 2 - 2, topY - contentSize.height / 2)
            end

            topX = topX + contentSize.width

            -- 刷新图标的时候应该判断显示逻辑特殊的情况：提升按钮有自身的显示逻辑
            if ctrlName ~= 'PromoteButton' then
                ctrl:setVisible(true)
            elseif  ctrlName == 'PromoteButton' then
                self:setPromoteButtonVisible(PromoteMgr:promoteBtnDisplay())
            end

            if nil == leftTop then
                leftTop = contentSize
            end
        end
    end

    if nil == leftTop then
        leftTop = {width = 0, height = 0}
    end

    -- 第二横排状态按钮的位置可能因为GameMgr.hideAllUI,showAllUI改变，所以重新设置下位置
    self:setStatusButtonPos()

    -- 排列第二列横排
    local y = (topY - leftTop.height)
    local x = BUTTON_SIZE
    for i = 1, #BtnList do
        if btnPosMap[BtnList[i]] > 100 and btnPosMap[BtnList[i]] < 200 then
            local ctrl = self:getControl(BtnList[i])
            local contentSize = ctrl:getContentSize()
            ctrl:setPosition(x + contentSize.width / 2, y - contentSize.height / 2)
            x = x + contentSize.width
            ctrl:setVisible(status == ButtonState.status1)
        end
    end

    -- 在排列竖排
    local y = (topY - leftTop.height - BUTTON_SIZE)
    local x = 0
    for i = 1, #BtnList do
        if btnPosMap[BtnList[i]] > 200 then
            local ctrl = self:getControl(BtnList[i])
            local contentSize = ctrl:getContentSize()
            ctrl:setPosition(x + contentSize.width / 2, y - contentSize.height / 2)
            y = y - contentSize.height
            ctrl:setVisible(status == ButtonState.status1)
        end
    end

    self.root:requestDoLayout()
    self.leftTop = leftTop

    if status == ButtonState.status1 then
        self:onStatusButton1()
    else
        self:onStatusButton2()
    end
end

function SystemFunctionDlg:showButton(buttons, time, callBackFunc)
    -- 在一定时间内展开部分按钮的通用逻辑
    if self.leftTop == nil then
        return
    end

    -- 横排按钮
    local basicBtn = self:getControl("StatusButton1", Const.UIButton)
    local dlgContentSize = self.root:getContentSize()
    local y = (dlgContentSize.height - self.leftTop.height)
    local x = BUTTON_SIZE
    for i = 1, #buttons do
        if btnPosMap[buttons[i]] > 100 and btnPosMap[buttons[i]] < 200 then
            if self:isContainIcon(buttons[i]) then
                local v = self:getControl(buttons[i])
                local contentSize = v:getContentSize()
                local move = cc.MoveTo:create(time, cc.p(x + contentSize.width / 2, y - contentSize.height / 2))

                x = x + contentSize.width
                v:setVisible(true)

                v:stopAllActions()
                v:runAction(move)
            end
        end
    end

    -- 竖排按钮
    local y = (y - BUTTON_SIZE)
    local x = 0
    for i = 1, #buttons do
        if btnPosMap[buttons[i]] > 200 then
            if self:isContainIcon(buttons[i]) then
                local v = self:getControl(buttons[i])
                local contentSize = v:getContentSize()
                local move = cc.MoveTo:create(time, cc.p(x + contentSize.width / 2, y - contentSize.height / 2))

                y = y - contentSize.height
                v:setVisible(true)

                v:stopAllActions()
                v:runAction(move)
            end
        end
    end

    if callBackFunc then
        local delay = time - DIF_TIME_BETWEEN_ACTION_AND_HIDE
        basicBtn:stopAllActions()
        basicBtn:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callBackFunc)))
    end

    if self.isOpenTrade then
        self:onTradeButton()
    end
end

function SystemFunctionDlg:hideButton(buttons, time, callBackFunc)
    -- 在一定时间内收起部分按钮的通用逻辑
    local basicBtn = self:getControl("StatusButton1", Const.UIButton)
    local x, y = basicBtn:getPosition()

    -- 横排按钮
    for i = 1, #buttons do
        if btnPosMap[buttons[i]] > 100 and btnPosMap[buttons[i]] < 200 then
            local v = self:getControl(buttons[i])
            local contentSize = v:getContentSize()
            local move = cc.MoveTo:create(time, cc.p(x + contentSize.width / 3, y))

            v:stopAllActions()
            v:runAction(move)
        end
    end

    -- 竖排按钮
    for i = 1, #buttons do
        if btnPosMap[buttons[i]] > 200 then
            local v = self:getControl(buttons[i])
            local contentSize = v:getContentSize()
            local move = cc.MoveTo:create(time, cc.p(x, y - contentSize.height / 3))

            v:stopAllActions()
            v:runAction(move)
        end
    end

    if callBackFunc then
        local delay = time - DIF_TIME_BETWEEN_ACTION_AND_HIDE
        basicBtn:stopAllActions()
        basicBtn:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callBackFunc)))
    end

    if self.isOpenTrade then
        self:onTradeButton()
    end
end

function SystemFunctionDlg:getIconCtrl(iconName)
    return self:getControl(iconName)
end

-- 通知Dlg要添加一个icon了
function SystemFunctionDlg:preAddIcon(iconName)
    local iconCtrl = self:getControl(iconName)

    if nil == iconCtrl then
        return
    end

    -- 获取外侧Icon
    -- 判断是横排Icon还是竖排Icon
    local icons = {}
    local type = 0
    if btnPosMap[iconName] > 200 then
        -- 可收缩伸展的竖排Icon
        -- 获取大于它的Icon
        for k, v in pairs(btnPosMap) do
            if v > 200 and v > btnPosMap[iconName] and self:isContainIcon(k) then
                table.insert(icons, k)
            end
        end

        type = TYPE_VERTICAL
    elseif btnPosMap[iconName] > 100 then
        -- 可收缩伸展的横排 Icon
        for k, v in pairs(btnPosMap) do
            if v > 100 and v < 200 and v > btnPosMap[iconName] and self:isContainIcon(k) then
                table.insert(icons, k)
            end
        end

        type = TYPE_HORIZONTAL
    else
        -- 横排Icon
        -- 获取大于它的Icon
        for k, v in pairs(btnPosMap) do
            if v < 100 and v > btnPosMap[iconName] and self:isContainIcon(k) then
                table.insert(icons, k)
            end
        end

        type = TYPE_HORIZONTAL
    end

    -- 获取控件的contentSize
    local iconContentSize = iconCtrl:getContentSize()

    -- 获取第一个icon的原始位置，即为当前需要移动的位置
    local pos = {}
    local anchorPoint = {}
    if 0 ~= #icons then
        self:sortIcon(icons)
        local ctrl = self:getControl(icons[1])
        pos.x, pos.y = ctrl:getPosition()
        anchorPoint = ctrl:getAnchorPoint()
    else
        -- 为最后一个位置
        -- 获取前一个已存在Icon的位置
        self:sortIcon(BtnList)
        local lastIcon = 0
        local lastIconCtrl = nil
        for i = 1, #BtnList do
            if btnPosMap[BtnList[i]] < btnPosMap[iconName]
              and lastIcon < btnPosMap[BtnList[i]]
              and math.floor(btnPosMap[iconName] / 100) == math.floor(btnPosMap[BtnList[i]] / 100) then
                lastIconCtrl = self:getControl(BtnList[i])
                lastIcon = btnPosMap[BtnList[i]]
            end
        end

        if nil ~= lastIconCtrl then
            anchorPoint = lastIconCtrl:getAnchorPoint()
            pos.x, pos.y = lastIconCtrl:getPosition()
            local contentSize = lastIconCtrl:getContentSize()
            if TYPE_HORIZONTAL == type then
                pos.x = pos.x + contentSize.width
            elseif TYPE_VERTICAL == type then
                pos.y = pos.y - contentSize.height
            end
        else
            -- 是第一个图标
            if TYPE_HORIZONTAL == type then
                local dlgContentSize = self.root:getContentSize()
                if btnPosMap[iconName] > 100 then
                    -- 可收缩伸展的横排 Icon
                    local basicBtn = self:getControl("StatusButton1", Const.UIButton)
                    pos.x, pos.y = basicBtn:getPosition()
                    pos.x = pos.x + BUTTON_SIZE
                    anchorPoint = {x = 0.5, y = 0.5}
                else
                    pos.x = 0
                    pos.y = Const.WINSIZE.height
                    anchorPoint = {x = 1, y = 0}
                end
            elseif TYPE_VERTICAL == type then
                local basicBtn = self:getControl("StatusButton1", Const.UIButton)
                pos.x, pos.y = basicBtn:getPosition()
                pos.y = pos.y - BUTTON_SIZE
                anchorPoint = {x = 0.5, y = 0.5}
            end
        end
    end

    -- 集体向外移
    for i = 1, #icons do
        local ctrl = self:getControl(icons[i])
        local x, y = ctrl:getPosition()

        local action = nil

        if btnPosMap[icons[i]] > 200 then
            action = cc.MoveTo:create(0.2, cc.p(x, y - iconContentSize.height))
        else
            action = cc.MoveTo:create(0.2, cc.p(x + iconContentSize.width, y))
        end

        local seq = cc.Sequence:create(cc.DelayTime:create(2.6), action)

        ctrl:runAction(seq)
    end

    iconCtrl:setPosition(pos.x, pos.y)
    pos = iconCtrl:convertToWorldSpace(cc.p(iconContentSize.width * (1 - anchorPoint.x), iconContentSize.height * (1 - anchorPoint.y)))
    pos.x = pos.x / Const.UI_SCALE
    pos.y = pos.y / Const.UI_SCALE

    return pos
end

function SystemFunctionDlg:MSG_ENTER_GAME(map)
    self:updateServerInfo()
end

-- 设置线路信息
function SystemFunctionDlg:updateServerInfo()
    -- 设置区组信息
    local serverName = GameMgr:getServerName()

    -- 与策划确认，服务器的线名将配置为“梦回问道99线”，中间固定阿拉伯数字表示线数
    local distName, serverId = DistMgr:getServerShowName(serverName)
    if nil == distName then
        distName = serverName
    end

    if nil == serverId then
        serverId = "N"
    end

    self:setCtrlVisible("LineImage", true)
    local timeInfo = TaskMgr:getMasqueradeTimeInfo()
    if MapMgr:isInMasquerade() and timeInfo then
        -- 在化妆舞会场地中，调整显示规则
        self:setLabelText("ServerLabel", string.format(CHS[6000590], serverId, timeInfo.whcd_id))
        self:setCtrlVisible("LineImage", false)
    elseif MapMgr:isInWyk() then
        -- 万妖窟场地中，调整显示规则
        local wykInfo = TaskMgr:getWykInfo()
        if wykInfo then
            self:setLabelText("ServerLabel", string.format(CHS[6000590], serverId, wykInfo.dungeon_index))
            self:setCtrlVisible("LineImage", false)
        else
            self:setLabelText("ServerLabel", string.format(CHS[6000591], serverId))
            self:setCtrlVisible("LineImage", false)
        end
    elseif MapMgr:isInBeastsKing() then
        -- 百兽战场，调整显示规则
        local bskTimeInfo = TaskMgr:getBeastsKingTimeInfo()
        if bskTimeInfo then
            self:setLabelText("ServerLabel", string.format(CHS[6000590], serverId, bskTimeInfo.dungeonIndex))
            self:setCtrlVisible("LineImage", false)
        else
            self:setLabelText("ServerLabel", string.format(CHS[6000591], serverId))
            self:setCtrlVisible("LineImage", false)
        end
    elseif "" == serverId then
        self:setLabelText("ServerLabel", serverName)
        self:setCtrlVisible("LineImage", false)
    elseif MapMgr:isInKuafjjzc() then
        self:setLabelText("ServerLabel", CHS[5400419])
        self:setCtrlVisible("LineImage", false)
    else
        self:setLabelText("ServerLabel", serverId .. CHS[3003696])
        self:setCtrlVisible("LineImage", true)
    end

    self:updateLayout("DistPanel")
end

function SystemFunctionDlg:updateTradePanel()
    local missCount = 0
    local displayCount = 1 -- 默认为1，因为集市肯定存在

    -- 处理珍宝，珍宝可能关闭了
    if not self:getCtrlVisible("TreasureButton") then
        missCount = missCount + 1
    else
        self:getControl("TreasureButton"):setPositionX(self.tradeFristPosX + JUBAO_DIS * displayCount)
        displayCount = displayCount + 1
    end

    if not self:getCtrlVisible("AuctionButton") then
        missCount = missCount + 1
    else
        self:getControl("AuctionButton"):setPositionX(self.tradeFristPosX + JUBAO_DIS * displayCount)
        displayCount = displayCount + 1
    end

    if not self:getCtrlVisible("JubaoButton") then
        missCount = missCount + 1
    else
        self:getControl("JubaoButton"):setPositionX(self.tradeFristPosX + JUBAO_DIS * displayCount)
        displayCount = displayCount + 1
    end

    if not self:getCtrlVisible("TradingSpotButton") then
        missCount = missCount + 1
    else
        self:getControl("TradingSpotButton"):setPositionX(self.tradeFristPosX + JUBAO_DIS * displayCount)
        displayCount = displayCount + 1
    end

    local panel = self:getControl("TradePanel")
    local image = self:getControl("BackImage", nil, panel)

    panel:setContentSize(self.tradeSize.width - JUBAO_DIS * missCount, self.tradeSize.height)
    image:setContentSize(self.tradeSize.width - JUBAO_DIS * missCount, self.tradeSize.height)
    image:setPositionX(image:getContentSize().width * 0.5)
end

function SystemFunctionDlg:MSG_SPOT_ENABLE(data)
    self:setCtrlVisible("TradingSpotButton", data.isOpen)
    self:updateTradePanel()
end

function SystemFunctionDlg:MSG_TRADING_ENABLE(data)
    -- 是否隐藏聚宝斋
    self:setCtrlVisible("JubaoButton", data.enable == 1 and not DeviceMgr:isReviewVer())

    self:updateTradePanel()
end

function SystemFunctionDlg:MSG_REFRESH_SHUAD_TRUSTEESHIP(data)
    local data = GetTaoMgr:getTrusteeshipData()
    if data.state == TRUSTEESHIP_STATE.OFF then
        self:setCtrlVisible("TrusteeshipPanel", false)
    else
        self:setCtrlVisible("TrusteeshipPanel", true)
        if data.state == TRUSTEESHIP_STATE.PAUSE then
            self:setLabelText("TrusteeshipLabel", CHS[4100398])
            self:setLabelText("TrusteeshipLabel2", CHS[4100398])
        else
            self:setLabelText("TrusteeshipLabel", CHS[4100399])
            self:setLabelText("TrusteeshipLabel2", CHS[4100399])
        end
    end
end

function SystemFunctionDlg:doActionWhenEndCombat()
    if self.newActionCache then
        self:playAddNewIcon(self.newActionCache)
        self.newActionCache = nil
        EventDispatcher:removeEventListener(EVENT.EVENT_END_COMBAT, self.doActionWhenEndCombat, self)
        return
    end
end

-- 按钮初次出现在主界面正中，然后向左上移动至按钮对应位置
function SystemFunctionDlg:playAddNewIcon(data)
    if data.type == "play" and (Me:isInCombat() or Me:isLookOn()) then
        self.newActionCache = data
        EventDispatcher:addEventListener(EVENT.EVENT_END_COMBAT, self.doActionWhenEndCombat, self)
        return
    end

    local button = self:getControl(data.ctrlName)
    if button then
        GuideMgr:refreshMainIcon(true, data.ctrlName)

        if data.type == "play" then
            local tempBtn = button:clone()
            local pos = self:preAddIcon(data.ctrlName)

            button:setVisible(false)
            tempBtn:setVisible(true)
            action = cc.Sequence:create({
                cc.DelayTime:create(0.1),
                cc.MoveTo:create(0.6, pos),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    tempBtn:removeFromParent()
                    button:setVisible(true)
                    self:addListIcon(data.ctrlName)
                    self:refreshIcon()
                end)
            })

            local size = self:getWinSize()
            tempBtn:runAction(action)
            tempBtn:setPosition(size.width / 2, size.height / 2)
            self.root:addChild(tempBtn, 10, TEMP_BUTTON_TAG)
        else
            self:addListIcon(data.ctrlName)
            self:refreshIcon()
        end
    end
end

-- 用于通知客户端显示生死状图标
function SystemFunctionDlg:MSG_LD_LIFEDEATH_ID(data)
    local ctrlName = "ShengSiButton"
    if data.id ~= "" then
        local button = self:getControl(ctrlName)
        self:setCtrlVisible("SSLeftTimePanel", false, button)

        if data.type == 1 then
            self:playAddNewIcon({ctrlName = ctrlName, type = "play"})
            gf:createArmatureMagic(ResMgr.ArmatureMagic.item_around, self:getControl(ctrlName), Const.ARMATURE_MAGIC_TAG)
        else
            self:playAddNewIcon({ctrlName = ctrlName})
        end

        local button = self:getControl(ctrlName)
        button.shengSiId = data.id

        local curTime = gf:getServerTime()
        if curTime < data["time"] then
            self:setCtrlVisible("SSLeftTimePanel", true, button)

            local timeCountLabel = self:getControl("SSLeftTimeLabel", nil, button)
            local timeCountLabel2 = self:getControl("SSLeftTimeLabel2", nil, button)

            timeCountLabel:stopAllActions()
            local function func()
                local curTime = gf:getServerTime()
                local time = data["time"] - curTime
                if time <= 0 then
                    self:setCtrlVisible("SSLeftTimePanel", false, button)
                    timeCountLabel:stopAllActions()
                    return
                end

                local m = math.floor((time / 60) % 60)
                local h = math.floor(time / 3600)
                local str = string.format("%02d:%02d", h, m)
                if h < 1 then
                    local s = math.floor(time % 60)
                    str = string.format("%02d:%02d", m, s)
                end

                timeCountLabel:setString(str)
                timeCountLabel2:setString(str)
            end

            schedule(timeCountLabel, func, 1)

            func()
        else
            self:setCtrlVisible("SSLeftTimePanel", false, button)
        end
    else
        local tempButton = self.root:getChildByTag(TEMP_BUTTON_TAG)
        if tempButton and tempButton:getName() == ctrlName then
            tempButton:removeFromParent()
        end

        if self:removeListIcon(ctrlName) then
        GuideMgr:refreshMainIcon(true, ctrlName)
        self:refreshIcon()
    end
    end
end

-- 打开生死状界面
function SystemFunctionDlg:MSG_LD_MATCH_DATA(data)
    local dlg = DlgMgr:openDlg("ShengSiSetDlg")
    dlg:MSG_LD_MATCH_DATA(data)
end

return SystemFunctionDlg
