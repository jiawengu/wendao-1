-- ChunjieRedBagDlg.lua
-- Created by huangzz Dec/20/2016
-- 春节幸运红包界面

local ChunjieRedBagDlg = Singleton("ChunjieRedBagDlg", Dialog)

local ROW_COUNT = 3
local COLUMN_COUNT = 5

local TALKPANEL_TAG = 300 -- 提示框tag

local TOTALTIME = 10 * 60 -- 最多耗时10分钟（秒）
local CARTOON_TIME = 3 -- 卡通播放时间（秒）

local STATUS_RED_EMPTY = 0   -- 红包游戏未开始
local STATUS_RED_CLOSE = 1   -- 红包状态未开启
local STATUS_RED_OPEND = 2   -- 红包状态已开启未中奖
local STATUS_RED_PRIZE = 3   -- 红包状态已中奖
local STATUS_RED_BREAK = 4   -- 红包游戏已结束

function ChunjieRedBagDlg:init()
    self:bindListener("OneButton", self.onOneButton)
    self:bindListener("InfoButton", self.onInfoButton)
    
    self.listPanel = self:getControl("ListUnitOutPanel")
    self.unitPanel = self:getControl("ListUnitMidPanel1")
    
    self.talkPanel = self:getControl("TalkPanel")
    self.talkPanel:retain()
    self.talkPanel:removeFromParent()

    self.gameStatus = STATUS_RED_EMPTY
    self.lastSelectTag = 0
    self.sropGame = false
    
    self:initListUnitPanel()
    self:initData()
    
    -- 初始化红包状态
    self:MSG_FESTIVAL_LOTTERY_RESULT(GiftMgr:getLotteryResult("spring_day_2017"))
    
    self:hookMsg("MSG_FESTIVAL_LOTTERY_RESULT")
    self:hookMsg("MSG_SPRING_LOTTERY_MSG")
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function ChunjieRedBagDlg:initData()
    -- 红包状态
    self.redBagStatus = {}
    for i = 1, ROW_COUNT * COLUMN_COUNT do
        self.redBagStatus[i] = STATUS_RED_EMPTY
    end
    
    local data = GiftMgr:getWelfareData()
    if not data or not data["lottery"] or not data["lottery"]["spring_day_2017"] then return end
    
    -- 剩余次数
    self.leftCount = data["lottery"]["spring_day_2017"].amount
    self:setLabelText("TimesLabel", CHS[5420017] .. self.leftCount)
   
    -- 活动时间
    local startTime = gf:getServerDate(CHS[4300158], tonumber(data["lottery"]["spring_day_2017"].startTime))
    local endTime = gf:getServerDate(CHS[4300158], tonumber(data["lottery"]["spring_day_2017"].endTime))
    self:setLabelText("TitleLabel", CHS[5420025] .. startTime .. " - " .. endTime)

end

function ChunjieRedBagDlg:initListUnitPanel()
    for i = 1, ROW_COUNT do
        for j = 1, COLUMN_COUNT do
            local tag = ((i - 1) * 5) + j
            local unitPanel = self:getControl("ListUnitMidPanel" .. tag)

            self:setCtrlVisible("Image1", true, unitPanel)
            self:setCtrlVisible("Image2", false, unitPanel)
            self:setCtrlVisible("Image3", false, unitPanel)
            
            local unitPanel2 = self:getControl("ListUnitPanel", nil, unitPanel)
            self:bindTouchEndEventListener(unitPanel, self.onClickRedBag)
        end
    end
end

function ChunjieRedBagDlg:onClickRedBag(sender, eventType)
    local tag = sender:getTag()
    
    -- 已打开点击不响应
    if self.redBagStatus[tag] == STATUS_RED_OPEND 
        or self.redBagStatus[tag] == STATUS_RED_PRIZE
        or self.sropGame then
        return
    end
    
    -- 活动未开始
    if self.gameStatus == STATUS_RED_EMPTY then
        gf:ShowSmallTips(CHS[5420020])
        return
    end
    
    -- 活动已结束
    if self.gameStatus == STATUS_RED_BREAK or self.gameStatus == STATUS_RED_PRIZE then
        gf:ShowSmallTips(CHS[5420022])
        return
    end
    
    self.sropGame = true
    GiftMgr:drawChunjieRedBag(tag)
    
    self.lastSelectTag = tag
    
    self:setCtrlVisible("Image3", true, sender)
end

function ChunjieRedBagDlg:setRedBagStatus(redBagStatus, tag)
    local panel = self.listPanel:getChildByTag(tag)
    self:setCtrlVisible("Image3", false, panel)
    
    self:setCtrlVisible("RedBagPanel1", false, panel)
    if redBagStatus == STATUS_RED_OPEND then
        self:setCtrlVisible("RedBagPanel1", false, panel)
        self:setCtrlVisible("RedBagPanel2", true, panel)
        self:setCtrlVisible("RedBagPanel3", false, panel)
        self:setCtrlVisible("Image2", true, panel)
       
    elseif redBagStatus == STATUS_RED_PRIZE then
        self:setCtrlVisible("RedBagPanel1", false, panel)
        self:setCtrlVisible("RedBagPanel2", false, panel)
        self:setCtrlVisible("RedBagPanel3", true, panel)
        self:setCtrlVisible("Image2", true, panel)
        self.gameStatus = redBagStatus
    else
        self.gameStatus = redBagStatus
        self:setCtrlVisible("RedBagPanel1", true, panel)
        self:setCtrlVisible("RedBagPanel2", false, panel)
        self:setCtrlVisible("RedBagPanel3", false, panel)
        self:setCtrlVisible("Image2", false, panel)
    end
end

function ChunjieRedBagDlg:onOneButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[5420024])
        return
    elseif Me:queryInt("level") < 30 then
        gf:ShowSmallTips(CHS[5420018])
        return
    elseif self.gameStatus == STATUS_RED_CLOSE then
        gf:ShowSmallTips(CHS[5420063])
        return
    elseif self.leftCount == 0 and (self.gameStatus == STATUS_RED_BREAK or self.gameStatus == STATUS_RED_PRIZE) then
        gf:ShowSmallTips(CHS[5420019])
        return
    end
    
    GiftMgr:drawChunjieRedBag(0)
end

function ChunjieRedBagDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("ChunjieRedBagDlgRuleDlg")
end

function ChunjieRedBagDlg:MSG_FESTIVAL_LOTTERY_RESULT(data)
    if not data or data.activeName ~= "spring_day_2017" then 
        return 
    end
    
    self.sropGame = false
    
    self.gameStartTime = data.gameStartTime
    for i = 1, ROW_COUNT * COLUMN_COUNT do
        self:setRedBagStatus(data.redBagStatus[i], i)
        self.redBagStatus[i] = data.redBagStatus[i]
    end
    
    -- 活动未开启
    if self.gameStatus == STATUS_RED_EMPTY then
        self:stopSchedule()
        return
    end
    
    -- 活动已完成
    if self.gameStatus == STATUS_RED_BREAK or self.gameStatus == STATUS_RED_PRIZE then
        self:stopSchedule()
        if data.spentTime <= TOTALTIME then
            self:setSpendTime(data.spentTime)
        else
            self:setSpendTime(TOTALTIME)
        end
        
        return
    end
    
    self.leftCount = 0
    self:setLabelText("TimesLabel", CHS[5420017] .. '0')
    
    -- 耗时计时
    if not self.schedulId then
        local time = math.max(0, gf:getServerTime() - self.gameStartTime)
        if time <= TOTALTIME then
            self:setSpendTime(time)
        else
            self:setSpendTime(TOTALTIME)
            return
        end
        
        self.schedulId = gf:Schedule(function()
            time = math.max(0, gf:getServerTime() - self.gameStartTime)
            if time <= TOTALTIME then
                self:setSpendTime(time)
            else
                self:stopSchedule()
                self:setSpendTime(TOTALTIME)
            end
        end, 1)
    end
end

function ChunjieRedBagDlg:setSpendTime(time)
    local min = math.floor(time / 60)
    local sec = time % 60
    if min < 10 then
        min = '0' .. min
    end
    
    if sec < 10 then
        sec = '0' .. sec
    end
    local timeDesc = string.format("%s %s:%s", CHS[5420021], min, sec)
    self:setLabelText("Label1", timeDesc, "ListTitlePanel")
end

function ChunjieRedBagDlg:stopSchedule()
    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end
end

function ChunjieRedBagDlg:MSG_SPRING_LOTTERY_MSG(data)
    if not data then return end

    local row = math.floor((data.redBagNo - 1) / COLUMN_COUNT) + 1
    local column = data.redBagNo - (row - 1) * COLUMN_COUNT
    
    local off = self:getBoundingBoxInWorldSpace(self.listPanel)
    
    -- 提示框显示
    local talkPanel = self.talkPanel:clone()
    talkPanel:setTag(TALKPANEL_TAG)
    local x = off.x + self.unitPanel:getContentSize().width * (column - 1) + self.unitPanel:getContentSize().width / 2 + 4
    local y = off.y + self.unitPanel:getContentSize().height * (ROW_COUNT - row + 1) - 20
    talkPanel:setPosition(cc.p(x, y))
    talkPanel:setAnchorPoint(cc.p(0.5, 0))
    if data.msg then
        talkPanel:setVisible(true)
        self:setColorText(data.msg, "TalkLabelPanel", talkPanel, 0, 0, {r = 255, g = 255, b = 255})
    end
    
    DlgMgr:sendMsg("WelfareDlg", "addOtherChild", TALKPANEL_TAG,talkPanel)
    
    local unitPanel = self.listPanel:getChildByTag(data.redBagNo)
    
    performWithDelay(self.listPanel, function ()
        DlgMgr:sendMsg("WelfareDlg", "romoveOtherChildByTag", TALKPANEL_TAG)
    end, CARTOON_TIME)
end

function ChunjieRedBagDlg:MSG_GENERAL_NOTIFY(data)
    if data.notify == NOTIFY.NOTIFY_CLOSE_GIFT_DLG then
        DlgMgr:closeDlg("ChunjieRedBagDlg")
    end
end

function ChunjieRedBagDlg:cleanup()
    self:releaseCloneCtrl("talkPanel")
    self:stopSchedule()
end

-- 换线流程会中断，需重置点击的按钮状态
function ChunjieRedBagDlg:resetClickStatus()
    self.sropGame = false
    self:setCtrlVisible("Image3", false, "ListUnitMidPanel" .. self.lastSelectTag)
end

return ChunjieRedBagDlg
