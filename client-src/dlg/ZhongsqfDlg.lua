-- ZhongsqfDlg.lua
-- Created by huangzz Sep/27/2018
-- 春节敲钟界面

local ZhongsqfDlg = Singleton("ZhongsqfDlg", Dialog)

local QIFU_INTERVAL = 3600

function ZhongsqfDlg:init(param)
    self:setCtrlFullClientEx("BKPanel")
    self:setFullScreen()

    local winSize = self:getWinSize()
    local bKImage = self:getControl("BKImage", nil, "ClockPanel")
    bKImage:setContentSize(winSize.width / Const.UI_SCALE, bKImage:getContentSize().height)

    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("KnockButton", self.onKnockButton)
    self:bindListener("StartButton", self.onStartButton)

    self.data = param
    param = param or {}
    self.startTime = param.time or gf:getServerTime()
    if param.hour == 0 then
        param.hour = 24
    end

    self.hour = param.hour or 19
    self.interval = param.interval or QIFU_INTERVAL

    self:setNumImgForPanel("TimePanel", ART_FONT_COLOR.B_FIGHT, self:getShowTime(0), false, LOCATE_POSITION.MID, 12.5, panel)
    self:setLabelText("NumLabel", "?", "LuckyPanel")

    self.isStart = false
    self.curTime = 0
    self.randomNum = 0
    self.knockNum = 0
    self.knockTime = nil

    self:setCtrlEnabled("SubmitButton", false)

    self:createArmature()

    self:setCtrlVisible("StartButton", true)
    self:setCtrlVisible("KnockButton", false)
end

function ZhongsqfDlg:createArmature()
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.zhongsqf_knock.name)
    local showPanel = self:getControl("Panel", nil, "ClockPanel")
    magic:setAnchorPoint(0.5, 0.5)
    local size = showPanel:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2)
    magic:setVisible(false)
    showPanel:addChild(magic)

    self.clock = magic
end

function ZhongsqfDlg:getRandomChangeTime()
    return math.random(40, 125) * (math.random(0, 1) == 0 and -1 or 1)
end

function ZhongsqfDlg:onUpdate(delayTime)
    if not self.isStart then
        return
    end

    if self.curTime >= 10000 then
        self.curTime = 0
    end

    delayTime = delayTime * 1000

    local curS = math.floor((self.curTime + delayTime) / 1000)
    local lastS = math.floor(self.curTime / 1000)

    -- 从55秒到60秒，客户端界面刷新该段时间流逝表现所花费的时长，不用使用标准的5秒，而是每秒内都增加[40,125]毫秒，
    -- 或每秒内都减少[40,125]毫秒，这样界面流逝实际所花时长会比标准时间长或短200-500
    if self.curTime + delayTime < 5000 then
        if lastS < curS then
            self.randomNum = self:getRandomChangeTime()
        end
    else
        self.randomNum = 0
    end

    delayTime = delayTime + (delayTime / 1000) * self.randomNum

    self.curTime = self.curTime + delayTime

    if self.curTime > 10000 then
        self.curTime = 0
        self.isStart = false
        if self.knockTime then
            local num = self:getLuckyNum(self.knockTime)
            self:setLabelText("NumLabel", num, "LuckyPanel")
        end

        self:setCtrlVisible("StartButton", true)
        self:setCtrlVisible("KnockButton", false)
        gf:ShowSmallTips(CHS[5400697])
    end

    local timeStr = self:getShowTime(self.curTime)

    self:setNumImgForPanel("TimePanel", ART_FONT_COLOR.B_FIGHT, timeStr, false, LOCATE_POSITION.MID, 12.5, panel)
end

function ZhongsqfDlg:getShowTime(time)
    local timeStr
    if time < 5000 then
        local s = math.floor(time / 1000)
        local ms = time % 1000
        timeStr = string.format("%02d:%02d:%02d.%03d", self.hour - 1, 59, s + 55, ms)
    else
        local s = math.floor(time / 1000) - 5
        local ms = time % 1000
        timeStr = string.format("%02d:%02d:%02d.%03d", self.hour % 24, 0, s, ms)
    end

    return timeStr
end

function ZhongsqfDlg:getLuckyNum(time)
    local num = 5
    local cTime = math.abs(time - 5000)
    if cTime >= 500 then
        num = 1
    elseif cTime >= 200 then
        num = 2
    elseif cTime >= 50 then
        num = 3
    elseif cTime >= 6 then
        num = 4
    end

    return num
end

-- 提交
function ZhongsqfDlg:onSubmitButton(sender, eventType)
    if self.isStart then
        gf:ShowSmallTips(CHS[5400784])
        return
    end

    -- 若当前时间已超过祝福开放时间1个小时
    if gf:getServerTime() - self.startTime > self.interval * 5 then
        gf:ShowSmallTips(CHS[5400695])
        self:onCloseButton()
        return
    end

    -- 若当前尚无敲响的时间记录，给与弹出提示
    if not self.knockTime then
        gf:ShowSmallTips(CHS[5400696])
        return
    end

    if not self.data then
        return
    end

    local num = self:getLuckyNum(self.knockTime)

    local str = gfEncrypt(tostring(num) .. "_" .. math.floor(math.abs(self.knockTime - 5000)) .. "_" .. self.knockNum, self.data.encryptId)
    gf:CmdToServer("CMD_SPRING_2019_ZSQF_COMMIT_GAME", {result = str, index = self.data.index})
end

function ZhongsqfDlg:onKnockButton(sender, eventType)
    -- 若当前时间已超过敲响时刻60分钟
    if gf:getServerTime() - self.startTime > self.interval * 5 then
        gf:ShowSmallTips(CHS[5400695])
        self:onCloseButton()
        return
    end

    self.knockNum = self.knockNum + 1
    self.knockTime = self.curTime
    self.isStart = false
    self:setCtrlVisible("StartButton", true)
    self:setCtrlVisible("KnockButton", false)

    local num = self:getLuckyNum(self.knockTime)
    self:setLabelText("NumLabel", num, "LuckyPanel")

    self.clock:setVisible(true)
    self.clock:getAnimation():play("Top", -1, 0)

    self:setCtrlEnabled("SubmitButton", true)
end

function ZhongsqfDlg:onStartButton(sender, eventType)
    -- 若当前时间已超过敲响时刻60分钟
    if gf:getServerTime() - self.startTime > self.interval * 5 then
        gf:ShowSmallTips(CHS[5400695])
        self:onCloseButton()
        return
    end

    self.isStart = true
    self.curTime = 0
    self.randomNum = self:getRandomChangeTime()

    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("KnockButton", true)

    self:setLabelText("NumLabel", "?", "LuckyPanel")
end

function ZhongsqfDlg:cleanup()
    gf:CmdToServer("CMD_SPRING_2019_ZSQF_QUIT_GAME", {})
end

return ZhongsqfDlg
