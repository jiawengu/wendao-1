-- RegressionRechargeDlg.lua
-- Created by lixh2 Jan/29/2019
-- 回归累充界面

local RegressionRechargeDlg = Singleton("RegressionRechargeDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function RegressionRechargeDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self:initDlg()

    gf:CmdToServer("CMD_REENTRY_ASKTAO_RECHARGE_DATA", {})

    self:hookMsg("MSG_REENTRY_ASKTAO_RECHARGE_DATA")
end

-- 初始化界面
function RegressionRechargeDlg:initDlg()
    self:setColorText(CHS[7150116], "TipsPanel", nil, nil, nil, nil, 17)
    self:setCtrlVisible("ItemPanel1", false)
    self:setCtrlVisible("ItemPanel2", false)
    self:setLabelText("NumLabel", "", "ProgressNumPanel")
    self:createMagic()
end

-- 播放骨骼动画
function RegressionRechargeDlg:createMagic()
    local panel = self:getControl("MagicPanel")
    if panel:getChildByName("ArmatureMagic") then return end

    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.shenm_baohe.name)
    magic:setAnchorPoint(0.5, 0.5)
    local size = panel:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2)
    magic:setName("ArmatureMagic")
    magic:getAnimation():play("Top01")
    panel:addChild(magic)

    return magic
end

-- 更新骨骼动画动作
function RegressionRechargeDlg:updateMagicAction(doOpen)
    local magic = self:getControl("MagicPanel"):getChildByName("ArmatureMagic")
    if not magic then
        magic = self:createMagic()
    end

    if doOpen then
        -- 先打开效果，再常驻效果
        local function func(sender, etype, id)
            if etype == ccs.MovementEventType.complete then
                magic:getAnimation():play("Top03", -1, 1)
            end
        end

        magic:getAnimation():setMovementEventCallFunc(func)

        magic:getAnimation():play("Top02")
    else
        -- 直接显示常驻效果
        magic:getAnimation():play("Top03", -1, 1)
    end
end

-- 创建圆形进度条
function RegressionRechargeDlg:createProgressBar()
    local panel = self:getControl("ProgressPanel")
    panel:removeAllChildren()

    local contentSize = panel:getContentSize()
    
    local bkImage = cc.Sprite:create(ResMgr.ui.recharge_bar_bk)
    bkImage:setPosition(contentSize.width / 2, contentSize.height / 2)
    bkImage:setRotation(180)
    panel:addChild(bkImage)

    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(ResMgr.ui.recharge_bar_progress))
    progressTimer:setName("ProgressTimer")
    progressTimer:setReverseDirection(false)
    progressTimer:setPercentage(0)
    progressTimer:setPosition(contentSize.width / 2, contentSize.height / 2)
    progressTimer:setRotation(180)
    panel:addChild(progressTimer)

    return progressTimer
end

-- 设置进度
function RegressionRechargeDlg:setPercent(percent, maxPercent)
    self.percent = percent

    local panel = self:getControl("ProgressPanel")
    local progressTimer = panel:getChildByName("ProgressTimer")
    if not progressTimer then
        progressTimer = self:createProgressBar()
    end

    local showPercent = self.percent * 0.7 + 15
    progressTimer:setPercentage(showPercent)

    if percent >= maxPercent then
        self:setLabelText("NumLabel", CHS[7150115], "ProgressNumPanel")
    else
        self:setLabelText("NumLabel", string.format("%d/%d", self.percent, maxPercent), "ProgressNumPanel")
    end
end

-- 设置奖励信息
function RegressionRechargeDlg:setBonusPanel(bonusDes)
    self:setCtrlVisible("ItemPanel1", false)
    self:setCtrlVisible("ItemPanel2", false)

    local root = self:getControl("ItemPanel1")
    local rewardList = TaskMgr:getRewardList(bonusDes)
    if rewardList and rewardList[1] and #rewardList[1] > 3 then
        root = self:getControl("ItemPanel2")
    end

    root:setVisible(true)
    local rewardPanel = self:getControl("RewardPanel", nil, root)
    rewardPanel:removeAllChildren()
    local rewardContainer = RewardContainer.new(bonusDes, rewardPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(1, rewardPanel:getContentSize().height / 2)
    rewardPanel:addChild(rewardContainer)
    rewardPanel:setScale(0.8)
end

-- 设置时间信息
function RegressionRechargeDlg:refreshTimePanel()
    local curTime = gf:getServerTime()
    if not self.dlgData then return end

    local str = ""
    if curTime >= self.dlgData.start_time and curTime <= self.dlgData.end_time then
        local str1 = gf:getServerDate(CHS[7150112], self.dlgData.start_time)
        local str2 = gf:getServerDate(CHS[7150112], self.dlgData.end_time)
        str = string.format("%s - %s", str1, str2)

        self:setLabelText("TitleLabel", string.format(CHS[7150114], str), "TimePanel")
    elseif curTime > self.dlgData.end_time and curTime <= self.dlgData.gift_end_time then
        str = gf:getServerDate(CHS[7150113], self.dlgData.gift_end_time)

        self:setLabelText("TitleLabel", string.format(CHS[7150118], str), "TimePanel")
    end
end

-- 设置按钮状态
function RegressionRechargeDlg:setButtonStatus(flag)
    if not flag then
        self:setLabelText("Label_1", CHS[7150117], "ConfirmButton")
        self:setLabelText("Label_2", CHS[7150117], "ConfirmButton")
        self:setCtrlEnabled("ConfirmButton", false)
    end
end

function RegressionRechargeDlg:onConfirmButton(sender, eventType)
    local curTime = gf:getServerTime()
    if self.lastClickTime then
        if curTime - self.lastClickTime <= 10 then
            gf:ShowSmallTips(CHS[7150109])
            return
        end
    end

    self.lastClickTime = curTime

    if not self.dlgData then return end

    if curTime < self.dlgData.start_time then
        -- 不在活动时间内
        gf:ShowSmallTips(CHS[7150110])
        return
    end

    if curTime > self.dlgData.gift_end_time then
        -- 过了领礼包截止时间
        gf:showTipAndMisMsg(gf:getServerDate(CHS[7150111], self.dlgData.gift_end_time))
        return
    end

    gf:CmdToServer("CMD_REENTRY_ASKTAO_RECHARGE_FETCH_BONUS", {})
end

function RegressionRechargeDlg:cleanup()
    self.dlgData = nil
    self.lastClickTime = nil
end

function RegressionRechargeDlg:MSG_REENTRY_ASKTAO_RECHARGE_DATA(data)
    if self.dlgData and self.dlgData.flag == 1 and data.flag == 2 then
        -- 由未领取刷新成已领取，则播放一次打开宝箱的效果
        self:updateMagicAction(true)
        self:setButtonStatus(false)
    elseif data.flag == 2 then
        -- 已领取状态，播放宝箱打开常驻效果
        self:updateMagicAction()
        self:setButtonStatus(false)
    end

    self.dlgData = data
    self:setPercent(data.progress, data.max_progress)
    self:setBonusPanel(data.bonus_desc)
    self:refreshTimePanel()
end

return RegressionRechargeDlg
