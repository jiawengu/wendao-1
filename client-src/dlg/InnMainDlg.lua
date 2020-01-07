-- InnMainDlg.lua
-- Created by lixh2 Api/19/2018
-- 客栈主界面

local InnMainDlg = Singleton("InnMainDlg", Dialog)

-- 客栈手册按钮位置需要随着聊天界面放大缩小进行移动
local MANUAL_BUTTON_MOVE_HEIGHT = 56

-- 客栈家具类型
local INN_FURNITURE_TYPE = InnMgr:getInnFurnitureType()

-- 客栈乞丐类型
local INN_BEGGAR_TYPE = InnMgr:getInnBeggarType()

-- 客栈客人状态
local INN_GUEST_STATE = InnMgr:getInnGuestType()

-- 客栈内可以打开的其他界面
local INN_OTEHR_DLG = {
    "InnElevateDlg",
    "InnManualDlg",
    "InnRenameDlg",
    "InnRuleDlg",
    "InnEventDlg",
}

function InnMainDlg:init()
    self:setFullScreen()
    self.blank:setLocalZOrder(-1)
    self:bindListener("OutButton", self.onOutButton)
    self:bindListener("MapPanel", self.onOutButton)
    self:bindListener("ComeInButton", self.onComeInButton)
    self:bindListener("InfoButton", self.onInfoButton, "OutPanel")
    self:bindListener("HideDialogButton", self.onHideButton)
    self:bindListener("ShowDialogButton", self.onShowButton)
    self.root:requestDoLayout()
    self:getControl("ShowDialogButton"):setVisible(false)
    self:bindListener("MoneyPanel", self.onMoneyPanel)
    self:bindListener("DeluxePanel", self.onDeluxePanel)
    self:bindListener("LevelPanel", self.onLevelPanel)
    self:bindListener("NumPanel", self.onPersonNumPanel)
    self:bindListener("UnitTimePanel", self.onPersonTimePanel)
    self:bindListener("TotalTimePanel", self.onTotalTimePanel)
    self:bindListener("ManualButton", self.onManualButton)

    -- 刷新手册按钮
    self:refreshManualBtn()
    local chatDlg = DlgMgr:getDlgByName("ChatDlg")
    if self:isVisible() and chatDlg and chatDlg.isExpend then
        performWithDelay(self.root, function()
            -- 延迟一帧保证doLayout后，不同分辨率下手册按钮位置正确
            self:upManualButton(true)
        end, 0)
    end

    self.signalImages =  {
        self:getControl("SignalImage_1", nil, "SignalPanel_0"),
        self:getControl("SignalImage_2", nil, "SignalPanel"),
        self:getControl("SignalImage_3", nil, "SignalPanel"),
        self:getControl("SignalImage_4", nil, "SignalPanel"),
    }

    -- 定时器
    self.scheduleId = self:startSchedule(function()
        -- 每秒刷新一下时间，网络，电池信息
        self:onRefreshTimeBatteryWifi()

        local newInnSleepFlag = InnMgr:isInnSleepTime()

        -- 每秒刷新客满倒计时，客栈非休息时间才需要倒计时
        if self.waitGuestFullTime and self.waitGuestFullTime > 0 and not newInnSleepFlag then
            self.waitGuestFullTime = self.waitGuestFullTime - 1
            self:refreshGuestFullTime()
        end

        -- 每秒刷新乞丐状态
        if self.beggerTime and self.beggerTime > 0 then
            self.beggerTime = self.beggerTime - 1
            self:refreshGuestSpeed()
        end

        -- 客栈休息状态发生了变化，需要刷新候客区休息期提示
        if (newInnSleepFlag and not self.inInnSleep) or (not newInnSleepFlag and self.inInnSleep) then
            self:refreshWaitInfo()
        end

        self.inInnSleep = newInnSleepFlag
    end, 1)
end

function InnMainDlg:setVisible(show)
    if show then
        for i = 1, #INN_OTEHR_DLG do
            if DlgMgr:isDlgOpened(INN_OTEHR_DLG[i]) then
                -- 客栈有其他界面是打开状态时，不允许显示客栈主界面
                return
            end
        end
    end

    -- 隐藏本界面需要延迟一帧，保证打开界面doLayout结束后再隐藏
    -- WDSY-31945 发现 客栈其他界面打开时，延迟一帧隐藏 InnMainDlg 时，若快速关闭 客栈其他界面，会出现
    -- 本界面先显示后隐藏的情况，导致本主界面没有被显示
    performWithDelay(self.root, function()
        Dialog.setVisible(self, show)
    end, 0)
end

function InnMainDlg:refreshManualBtn()
    if InnMgr:canShowManualBtn() then
        self:setCtrlVisible("ManualButton", true)
        if InnMgr:canShowManualRedPoint() then
            RedDotMgr:insertOneRedDot(self.name, "ManualButton")
        else
            RedDotMgr:removeOneRedDot(self.name, "ManualButton")
        end
    else
        self:setCtrlVisible("ManualButton", false)
    end
end

-- 客栈手册按钮位置需要随着聊天界面放大缩小进行移动
function InnMainDlg:upManualButton(flag)
    local manualBtn = self:getControl("ManualButton", Const.UIButton)
    local curX, curY = manualBtn:getPosition()
    curY = flag and (curY + MANUAL_BUTTON_MOVE_HEIGHT) or (curY - MANUAL_BUTTON_MOVE_HEIGHT)
    manualBtn:setPosition(cc.p(curX, curY))
end

function InnMainDlg:refreshBaseInfo()
    self.baseData = InnMgr:getBaseData()
    if not self.baseData then return end

    if not InnMgr:getPlayAddCoinFlag() then
        -- 不需要播放金币增加特效，则此处更新金币数量
        self:refreshCoinNum(self.baseData.tongCoin)
    end

    self:refreshDeluxe(self.baseData.deluxe)
    self:refreshLevelAndExp(self.baseData.level, self.baseData.exp, self.baseData.expToNext)

    self:refreshMapName(self.baseData.innName)
end

-- 刷新候客区信息
function InnMainDlg:refreshWaitInfo()
    self.waitData = InnMgr:getWaitData()
    if not self.waitData then return end

    -- 右侧候客区信息
    self:setLabelText("NumLabel", string.format("%d/%d", self.waitData.guestCount, self.waitData.guestCountMax), "NumPanel")

    -- 候客速度
    self:refreshGuestSpeed()
    if self.waitData.beggerType == INN_BEGGAR_TYPE.INN_BEGGAR_NONE then
        self.beggerTime = nil
    else
        self.beggerTime = self.waitData.beggerEndTime
    end

    if InnMgr:isInnSleepTime() then
        -- 客栈处于休息期
        self:setCtrlVisible("RestLabel", true, "WaitPanel")
        self:setCtrlVisible("TotalTimePanel", false, "WaitPanel")

        self.waitGuestFullTime = nil
    else
        self:setCtrlVisible("RestLabel", false, "WaitPanel")
        self:setCtrlVisible("TotalTimePanel", true, "WaitPanel")

        -- 客满倒计时
        self.waitGuestFullTime = self.waitData.guestFullTime
        self:refreshGuestFullTime()
    end
end

-- 刷新候客速度，乞丐事件倒计时有影响
function InnMainDlg:refreshGuestSpeed()
    if not self.waitData then return end
    local speedColor = COLOR3.WHITE
    local beggerEventType = InnMgr:getInnBeggarEventType()
    if beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_BE then
        -- 乞丐报恩
        speedColor = COLOR3.GREEN
    elseif beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_NS then
        -- 乞丐闹事
        speedColor = COLOR3.RED
    end

    local minute = math.floor(self.waitData.waitTime / 60)
    local second = math.floor(self.waitData.waitTime % 60)
    self:setLabelText("NumLabel", string.format(CHS[7190188], minute, second), "UnitTimePanel", speedColor)

    DlgMgr:sendMsg("InnElevateDlg", "refreshGuestSpeed", minute, second, speedColor)
end

-- 刷新等待客满倒计时
function InnMainDlg:refreshGuestFullTime()
    local hour = 0
    local minute = 0
    local second = 0
    if self.waitGuestFullTime then
        hour = math.floor(self.waitGuestFullTime / 3600)
        minute = math.floor(self.waitGuestFullTime % 3600 / 60)
        second = math.floor(self.waitGuestFullTime % 60)
    end

    local color = COLOR3.GREEN
    local beggerEventType = InnMgr:getInnBeggarEventType()
    if beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_NS then
        -- 乞丐闹事
        color = COLOR3.RED
    end

    self:setLabelText("NumLabel", string.format(CHS[7190189], hour, minute, second), "TotalTimePanel", color)
end

function InnMainDlg:cleanup()
    self:clearSchedule()
    self:stopAddTcoinMagic()
    self.waitData = nil
    self.baseData = nil
    self.waitGuestFullTime = 0
    self.inInnSleep = false
end

function InnMainDlg:clearSchedule()
    if self.scheduleId then
        self:stopSchedule(self.scheduleId)
        self.scheduleId  = nil
    end
end

-- 刷新地图名称信息
function InnMainDlg:refreshMapName(str)
    self:setLabelText("NameLabel_1", str, "MapPanel")
    self:setLabelText("NameLabel_2", str, "MapPanel")
end

-- 刷新喜来通宝数量
function InnMainDlg:refreshCoinNum(tongCoin)
    local str = gf:getArtFontMoneyDesc(tongCoin or 0)
    self:setLabelText("NumLabel", str, "MoneyPanel")
end

-- 刷新客栈豪华度
function InnMainDlg:refreshDeluxe(deluxe)
    local str = gf:getArtFontMoneyDesc(deluxe or 0)
    self:setLabelText("NumLabel", str, "DeluxePanel")
end

-- 刷新客栈等级与经验
function InnMainDlg:refreshLevelAndExp(level, exp, expToNext)
    local root = self:getControl("LevelPanel", nil, "ResourceInfoPanel")
    root.level = level
    root.exp = exp
    root.expToNext = expToNext

    if expToNext == 0 then
        -- 满级
        self:setCtrlVisible("MaxNumLabel", true, root)
        self:setCtrlVisible("NumLabel", false, root)
        self:setCtrlVisible("ProgressPanel", false, root)
        self:setLabelText("MaxNumLabel", string.format(CHS[7190184], level), root)
    else
        self:setCtrlVisible("MaxNumLabel", false, root)
        self:setCtrlVisible("NumLabel", true, root)
        self:setCtrlVisible("ProgressPanel", true, root)
        self:setLabelText("NumLabel", string.format(CHS[7190184], level), root)
        self:setProgressBar("ProgressBar", exp, expToNext, root)
    end
end

-- 喜来通宝，货币名片
function InnMainDlg:onMoneyPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    dlg:setRewardInfo({["basicInfo"] = {CHS[7100257]}, ["imagePath"] = ResMgr.ui.big_inn_coin,
        ["limted"] = false,["resType"] = 1,["time_limited"] = false,
        desc = CHS[7100258]})
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

-- 豪华度悬浮框
function InnMainDlg:onDeluxePanel(sender, eventType)
    local dlg = DlgMgr:openDlg("InnMainRuleDlg")
    dlg:setType("DeluxeRule")
end

-- 客栈等级悬浮框
function InnMainDlg:onLevelPanel(sender, eventType)
    if not sender.exp or not sender.expToNext or not sender.level then return end
    local str1 = string.format(CHS[7190185], sender.level)
    local str2 = CHS[7120077]
    if sender.expToNext ~= 0 then
        str2 = string.format(CHS[7190186], sender.exp, sender.expToNext)
    end

    local dlg = DlgMgr:openDlg("InnMainRuleDlg")
    dlg:setType("LevelRule", str1, str2)
end

-- 候客人数悬浮框
function InnMainDlg:onPersonNumPanel(sender, eventType)
    local dlg = DlgMgr:openDlg("InnMainRuleDlg")
    dlg:setType("PersonNumRule")
end

-- 候客速度悬浮框
function InnMainDlg:onPersonTimePanel(sender, eventType)
    local dlg = DlgMgr:openDlg("InnMainRuleDlg")
    dlg:setType("PersonTimeRule")
end

-- 候客时间悬浮框
function InnMainDlg:onTotalTimePanel(sender, eventType)
    local dlg = DlgMgr:openDlg("InnMainRuleDlg")
    dlg:setType("TotalTimeRule")
end

-- 退出客栈
function InnMainDlg:onOutButton(sender, eventType)
    gf:CmdToServer("CMD_LEAVE_ROOM", {type = CHS[7190182], extra = ""})
end

function InnMainDlg:onComeInButton(sender, eventType)
    self:removeWaitGuestBtnMagic()

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if InnMgr:getInnBeggarType() == INN_BEGGAR_TYPE.INN_BEGGAR_NS then
        -- 恶霸堵门
        gf:ShowSmallTips(CHS[7190191])
        return
    end

    -- 请求迎客
    gf:CmdToServer("CMD_INN_GUEST_COME_IN")
end

function InnMainDlg:onInfoButton(sender, eventType)
    if not self.waitData then return end
    local dlg = DlgMgr:openDlg("InnMainRuleDlg")
    local str = string.format(CHS[7190192], self.waitData.level)
    local beggerEventType = InnMgr:getInnBeggarEventType()
    if beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_BE then
        -- 乞丐报恩
        dlg:setType("WaitRule2", str, 1)
    elseif beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_NS then
        -- 乞丐闹事
        dlg:setType("WaitRule2", str, 2)
    else
        dlg:setType("WaitRule", str)
    end
end

-- 点击手册
function InnMainDlg:onManualButton(sender, eventType)
    DlgMgr:openDlg("InnManualDlg")
end

-- 隐藏/显示 候客区
function InnMainDlg:hide(flag)
    -- WaitPanel的位置需要在首次使用时计算一下，init函数中计算可能不准确，因为setFullScreen会requestDoLayout
    -- 如果界面被隐藏，那么requestDoLayout将会被延迟到界面显示时在进行，init函数中不知道什么时候会显示界面
    if not self.waitOrgX or not self.waitOrgY then
        self.waitOrgX, self.waitOrgY = self:getControl("WaitPanel"):getPosition()
    end

    local root = self:getControl("WaitPanel")
    local size = root:getContentSize()
    local move = nil
    local dlgSize = self.root:getContentSize()
    if flag then
        move = cc.MoveTo:create(0.25, cc.p(dlgSize.width + size.width + 10, self.waitOrgY))
    else
        move = cc.MoveTo:create(0.25, cc.p(self.waitOrgX, self.waitOrgY))
    end

    root:stopAllActions()
    root:runAction(move)
end

-- 隐藏/显示 候客区箭头
function InnMainDlg:hideArrow(flag)
    -- ShowDialogButton的位置需要在首次使用时计算一下，init函数中计算可能不准确，因为setFullScreen会requestDoLayout
    -- 如果界面被隐藏，那么requestDoLayout将会被延迟到界面显示时在进行，init函数中不知道什么时候会显示界面
    if not self.arrowOrgX or not self.arrowOrgX then
        self.arrowOrgX, self.arrowOrgY = self:getControl("ShowDialogButton"):getPosition()
    end

    local move = nil
    local dlgSize = self.root:getContentSize()
    if flag then
        local action1 = cc.MoveTo:create(0.25, cc.p(dlgSize.width - 20, self.arrowOrgY))
        local action2 = cc.CallFunc:create(function()
            self:getControl("HideDialogButton"):setVisible(false)
            local showButton = self:getControl("ShowDialogButton")
            showButton:setVisible(true)
            showButton:setPosition(cc.p(dlgSize.width - 20, self.arrowOrgY))
        end)
        move = cc.Sequence:create(action1,action2)
    else
        local action1 = cc.MoveTo:create(0.25, cc.p(self.arrowOrgX, self.arrowOrgY))
        local action2 = cc.CallFunc:create(function()
            self:getControl("ShowDialogButton"):setVisible(false)
            local hideButton = self:getControl("HideDialogButton")
            hideButton:setVisible(true)
            hideButton:setPosition(cc.p(self.arrowOrgX, self.arrowOrgY))
        end)

        move = cc.Sequence:create(action1,action2)
    end

    local root
    if flag then
        root = self:getControl("HideDialogButton")
    else
        root = self:getControl("ShowDialogButton")
    end

    root:stopAllActions()
    root:runAction(move)
end

-- 隐藏候客区
function InnMainDlg:onHideButton()
    self:hide(true)
    self:hideArrow(true)
end

-- 显示候客区
function InnMainDlg:onShowButton()
    self:hide(false)
    self:hideArrow(false)
end

-- 增加通宝数量特效
function InnMainDlg:addTcoinNumMagic(lastNum, endNum)
    if lastNum >= endNum then
        -- InnMgr:getPlayAddCoinFlag()为true进入此分支，但lastNum >= endNum
        -- 说明其他原因刷新了客栈基础数据，直接InnMgr:setPlayAddCoinFlag(false)
        self:stopAddTcoinMagic()
        InnMgr:setPlayAddCoinFlag(false)
        return
    end

    local time = 0.8 / (endNum - lastNum) 

    if self.tcoinSchedule then
        -- 正在播放特效，先停止
        self:stopAddTcoinMagic()
    end

    self.tcoinSchedule = self:startSchedule(function()
        if lastNum < endNum then
            lastNum = lastNum + 1
            self:refreshCoinNum(lastNum)
            -- 策划要求暂时屏蔽金币闪动特效
            -- self:addTcoinBlinkMagic()
        else
            self:stopAddTcoinMagic()
            InnMgr:setPlayAddCoinFlag(false)
        end
    end, time)
end

-- 停止增加通宝数量特效
function InnMainDlg:stopAddTcoinMagic(endNum)
    if not endNum then
        local baseData = InnMgr:getBaseData()
        if not baseData then return end
        endNum = baseData.tongCoin
    end

    self:refreshCoinNum(endNum)

    if self.tcoinSchedule then
        self:stopSchedule(self.tcoinSchedule)
        self.tcoinSchedule  = nil
    end
end

-- 播放通宝闪动特效
function InnMainDlg:addTcoinBlinkMagic()
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.inn_add_tcoin.name, ResMgr.ArmatureMagic.inn_add_tcoin.action,
        self:getControl("IconImage", Const.UIImage, "MoneyPanel"))
end

-- 增加候客区候客按钮环绕特效
function InnMainDlg:addWaitGuestBtnMagic()
    gf:createArmatureMagic(ResMgr.ArmatureMagic.inn_get_guest_btn,
        self:getControl("ComeInButton", Const.UIButton, "WaitPanel"), Const.ARMATURE_MAGIC_TAG)
end

-- 移除候客区候客按钮环绕特效
function InnMainDlg:removeWaitGuestBtnMagic()
    local comeInBtn = self:getControl("ComeInButton", Const.UIButton, "WaitPanel")
    local magic = comeInBtn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
    if magic then
        magic:removeFromParent()
        magic = nil
    end
end

function InnMainDlg:onRefreshTimeBatteryWifi()
    self:updateTime()

    -- 更新电池状态
    local batteryInfo = BatteryAndWifiMgr:getBatteryInfo()

    if batteryInfo then
        self:updateBattery(batteryInfo.rawlevel, batteryInfo.scale, batteryInfo.status, batteryInfo.health)
    end

    -- 更新网络状态
    local networkState = BatteryAndWifiMgr:getNetworkState()

    if networkState then
        self:updateNetwork(networkState)

        -- 是wifi,更新wifi强度
        local wifiInfo = BatteryAndWifiMgr:getWifiInfo()
        if NET_TYPE.WIFI == networkState and wifiInfo then
            self:updateWifiStatus(wifiInfo.wifiState, wifiInfo.level)
        end
    end

    self:refreshSignalColor()
end

-- 更新电池状态
function InnMainDlg:updateBattery(rawlevel, scale, status, health)
    local level;
    if rawlevel >= 0 and scale > 0 then
        level = (rawlevel * 100) / scale;
    end

    local batterProcessBar = self:getControl("ProgressBar", nil, "UpPanel")
    local chargeImage = self:getControl("ChargeImage", nil, "UpPanel")

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
function InnMainDlg:updateNetwork(networkState)
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
function InnMainDlg:updateWifiStatus(wifiState, level)
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

function InnMainDlg:updateWifiUI(levelStatus)
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

function InnMainDlg:refreshSignalColor()
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

function InnMainDlg:updateTime()
    local curTime = os.date("%H:%M")
    self:setLabelText("TimeLabel_1", curTime)
    self:setLabelText("TimeLabel_2", curTime)
end

return InnMainDlg
