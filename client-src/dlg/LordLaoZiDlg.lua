-- LordLaoZiDlg.lu
-- created by sujl Mar/29/2016
-- 老君查岗界面

local LordLaoZiDlg = Singleton("LordLaoZiDlg", Dialog)
local NumImg = require('ctrl/NumImg')

local numInterval = 0
local desKey = "jowenu"
local VIBRATE_TIME = 10
local MAX_LEFT_TIME = 180

function LordLaoZiDlg:init()
    self.blank:setLocalZOrder(Const.ZORDER_LORDLAOZI)
    self:bindListener("ChangeButton", self.onChangeButton)
    self:bindListener("ChoiceButton1", self.onChoiceButton1)
    self:bindListener("ChoiceButton2", self.onChoiceButton2)
    self:bindListener("ChoiceButton3", self.onChoiceButton3)
    self:bindListener("ChoiceButton4", self.onChoiceButton4)
    self:bindListener("InfoButton", self.onInfoBtn)
    self:bindListener("SendNotifyButton", self.onSendNotifyButton)

    self.codePanel = self:getControl("CodePanel", nil, "IdentifyingCodePanel")
    self.logtimes = 4

    -- 临时调整提示框层级，cleanup 中要调回
    SmallTipsMgr:setLocalZOrder(Const.ZORDER_LORDLAOZI_TIP, self.name)

    --self:hookMsg("MSG_NOTIFY_SECURITY_CODE")
    self:hookMsg("MSG_FINISH_SECURITY_CODE")
    self:hookMsg("MSG_OTHER_LOGIN")

    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self:bindTouchEndEventListener(self.root, self.onClickOut)

    -- 非队长显示震动
    if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
        self:setCtrlVisible("SendNotifyButton", true)
    else
        self:setCtrlVisible("SendNotifyButton", false)
    end
end

function LordLaoZiDlg:cleanup()
    DlgMgr:closeDlg("LordLaoZiRuleDlg")

    -- 调回提示框正常的层级
    SmallTipsMgr:setLocalZOrder(nil, self.name)

    if self.timerId then
        gf:Unschedule(self.timerId)
        self.timerId = nil
    end
end

function LordLaoZiDlg:refreshChoice(data)
    local choices = data.choices
    local value = gfDecrypt(data.answer, desKey)
    local ans = nil
    local dc = { 0, 0, 0, 0 }

    for i = 1, #choices do
        local ctrlName = string.format("ChoiceButton%d", i)
        self:setLabelText("Label", tostring(choices[i]), ctrlName)
        dc[i]= gf:getGiftValue(tonumber(choices[i]))
        if not ans and value == tostring(dc[i]) then
            ans = choices[i]
        end

        -- 如果我不是队长，显示 请等待答题者作答  选项
        if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
            self:setLabelText("Label", CHS[4200001], ctrlName)
        end

        self:setCtrlVisible("Label", true, ctrlName)
    end

    if not ans then
        if self.logtimes and self.logtimes > 0 then
            local t, v = gf:getGiftInfo()
            local pkt = {
                answer = data.answer,
                tactics = t,
                value = v,
                sa = string.format("%s, %s, %s, %s", tostring(choices[1]), tostring(choices[2]), tostring(choices[3]), tostring(choices[4])),
                ca = string.format("%s, %s, %s, %s", tostring(dc[1]), tostring(dc[2]), tostring(dc[3]), tostring(dc[4])),
            }
            gf:CmdToServer("CMD_LOG_LJCG_EXCEPTION", pkt)
            self.logtimes = self.logtimes - 1
        end
        gf:CmdToServer("CMD_REQUEST_SECURITY_CODE")
    end

    -- 显示答题者
    local leader = TeamMgr:getLeader()
    if leader and leader.name then
        self:setLabelText("NameLabel", gf:getRealName(leader.name), "MainPanel")
    end

    -- 如果我不是队长，显示 请等待答题者作答
    if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
        self:setCtrlVisible("InfoPanel", true)
        self:setCtrlVisible("ChangeButton", false)

        self:setCtrlVisible("CloseImage", true)
        self.canAnswer = true
    else
        self:setCtrlVisible("InfoPanel", false)
        self:setCtrlVisible("ChangeButton", true)
        self:showImgNum(tostring(ans))

        self:setCtrlVisible("CloseImage", false)
        self:disableButton(false)  -- 设置答案可以点击
        self.hasSend = false

        -- 5s后开始答题
        self.canAnswer = nil
        performWithDelay(self.root, function() self.canAnswer = true end, 5)
    end

    self:setHourglass(math.min(MAX_LEFT_TIME, data.finishTime - gf:getServerTime()))
end

function LordLaoZiDlg:setHourglass(time)
    -- 开始180s倒计时
    local startTime = gf:getServerTime()
    local elapse = 0
    local leftTimeLabel = self:getControl("LeftTimeLabel", Const.UILabel, "TimePanel")
    leftTimeLabel:setString(tostring(time))
    if self.timerId then
        gf:Unschedule(self.timerId)
    end
    self.timerId = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - startTime)
        leftTimeLabel:setString(tostring(math.max(0, time - elapse)))
        if math.max(0, time - elapse) == 0 then
            self:onCloseButton()
        end
    end, 1);

    local function hourglassCallBack(parameters)
        if self.timerId then
            gf:Unschedule(self.timerId)
            self.timerId = nil
        end

        -- 超时关闭
        GameMgr.isAntiCheat = false
    end
    local bar = self:getControl("ProgressBar", nil, "TimePanel")
    if bar then
        bar:stopAllActions()
        local percent = time / 180 * 100

        if percent > 0 then
            self:setProgressBarByHourglass("ProgressBar", 180 * 1000, percent, hourglassCallBack, "TimePanel", true)
        else
            hourglassCallBack()
        end
    end
end

function LordLaoZiDlg:showImgNum(num)
    local w = 0, 0
    local parentSize = self.codePanel:getContentSize()
    local imgs = {}
    self.codePanel:removeAllChildren()
    for i = 1, string.len(num) do
        local image =  NumImg.new(ART_FONT_COLOR.NORMAL_TEXT, tonumber(string.sub(num, i, i)), false)
        image:setScale(math.random(800, 1400) / 1000, math.random(800, 1400) / 1000)
        image:setRotation(math.random(-45, 45))
        self.codePanel:addChild(image)
        table.insert(imgs, image)
        local size = image:getContentSize()
        w = w + size.width + numInterval
    end

    local x = (parentSize.width - w + numInterval) / 2
    for i = 1, #imgs do
        local image = imgs[i]
        image:setPosition(x, parentSize.height / 2)
        x = x + image:getContentSize().width + numInterval
    end
end

function LordLaoZiDlg:disableButton(disable)
    self:setCtrlEnabled("ChoiceButton1", not disable)
    self:setCtrlEnabled("ChoiceButton2", not disable)
    self:setCtrlEnabled("ChoiceButton3", not disable)
    self:setCtrlEnabled("ChoiceButton4", not disable)
end

function LordLaoZiDlg:sendChoice(btnName)
    RecordLogMgr:isMeetCGPluginCondition("LordLaoZiDlg")

    if not self.canAnswer then gf:ShowSmallTips(CHS[2000107]) return end
    if self.hasSend then return end     -- 避免因为多点触控一道题目发送多个答案

    local v = self:getLabelText("Label", btnName)
    if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[3004066])
        return
    end

    Log:D(string.format("sendChoice, choice=%s", v))
    gf:CmdToServer("CMD_ANSWER_SECURITY_CODE", {answer = tonumber(v)})
    self.logtimes = 4
    self:disableButton(true)
    self.hasSend = true
end

function LordLaoZiDlg:onChoiceButton1(sender, eventType)

    self:sendChoice("ChoiceButton1")
end

function LordLaoZiDlg:onChoiceButton2(sender, eventType)
    self:sendChoice("ChoiceButton2")
end

function LordLaoZiDlg:onChoiceButton3(sender, eventType)
    self:sendChoice("ChoiceButton3")
end

function LordLaoZiDlg:onChoiceButton4(sender, eventType)
    self:sendChoice("ChoiceButton4")
end

function LordLaoZiDlg:onClickOut(sender, eventType)
    -- 如果我不是队长，显示 请等待答题者作答  选项
    if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
        self:onCloseButton()
    end
end

function LordLaoZiDlg:onChangeButton(sender, eventType)
    -- 发送消息通知刷新验证码
    gf:CmdToServer("CMD_REQUEST_SECURITY_CODE")
    self.logtimes = 4
end

function LordLaoZiDlg:onInfoBtn(sender, eventType)
    DlgMgr:openDlg("LordLaoZiRuleDlg")
end

--function LordLaoZiDlg:MSG_NOTIFY_SECURITY_CODE(data)
--    self:refreshChoice(data)
--end

function LordLaoZiDlg:MSG_FINISH_SECURITY_CODE(data)
    DlgMgr:closeDlg(self.name)
end

function LordLaoZiDlg:MSG_OTHER_LOGIN(data)
    -- 被顶号的时候，关闭
    DlgMgr:closeDlg(self.name)
end

function LordLaoZiDlg:onSendNotifyButton()
    if self.sendNotifyTime and gf:getServerTime() - self.sendNotifyTime < VIBRATE_TIME then
        gf:ShowSmallTips(string.format(CHS[6400092], VIBRATE_TIME))
        return
    end

    self.sendNotifyTime = gf:getServerTime()

    VibrateMgr:sendVibrate("laojun")
end

return LordLaoZiDlg