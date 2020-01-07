-- ShidaoInfoDlg.lua
-- Created by zhengjh Jan/13/2016
-- 试道大会界面

local ShidaoInfoDlg = Singleton("ShidaoInfoDlg", Dialog)
local stage2_refesh_time = 10
local stage1_refesh_time = 60
local margin_precent = 4.4

function ShidaoInfoDlg:init()
    self:bindListener("ShidaoButton", self.onShidaoButton)
    self:bindListener("CloseButton", self.onCloseButton)
    self.isShowUI = true
    
    self:setCtrlVisible("ShrinkPanel", false)
    self:setCtrlVisible("LeftTimePanel", false)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_SHIDAO_INFO)
    
    self:setFullScreen()
    self.root:setPositionY(self.root:getPositionY() - self:getWinSize().height  * margin_precent / 100)

    local activity = ActivityMgr:getActivityByName(CHS[5450336])
    if activity and ActivityMgr:checkLimitActCanShow(activity, nil, nil, ShiDaoMgr:isMonthTaoShiDao()) then
        self:setImage("TitleImage_3", ResMgr.ui.month_tao_sd_tip2)
        self:setImage("TitleImage_4", ResMgr.ui.month_tao_sd_tip3)
        self:setImage("TitleImage_5", ResMgr.ui.month_tao_sd_tip1)
    end
    
    self:onShidaoButton()
end

function ShidaoInfoDlg:setInfo(data)
    if data.stageId == 0 then -- 准备阶段
        self:setCtrlVisible("TitleImage_3", false)
        self:setCtrlVisible("TitleImage_4", false)
        self:setCtrlVisible("TitleImage_5", true)
        self:setCtrlVisible("MonsterPanel", true)
        self:setCtrlVisible("ShrinkPanel", false)
        self:setLabelText("NowPointLabel", CHS[3003630])

        -- 倒计时
        self:updateLeftTime(data.startTime - gf:getServerTime())
    elseif data.stageId == 1 then -- 挑战元魔
        self:setCtrlVisible("TitleImage_3", true)
        self:setCtrlVisible("TitleImage_4", false)
        self:setCtrlVisible("TitleImage_5", false)
        self:setCtrlVisible("MonsterPanel", true)
        self:setCtrlVisible("ShrinkPanel", false)
        self:setLabelText("NowPointLabel", CHS[3003631] .. data.monsterPoint)

        -- 倒计时
        self:updateLeftTime(data.stage1_duration_time + data.startTime - gf:getServerTime())
    elseif data.stageId == 2 then -- 巅峰对决
        self:setCtrlVisible("TitleImage_3", false)
        self:setCtrlVisible("TitleImage_4", true)
        self:setCtrlVisible("TitleImage_5", false)
        self:setCtrlVisible("MonsterPanel", false)


        if data.isPK == 0 then
            self:setCtrlVisible("ShrinkPanel", false)
            self:setCtrlVisible("PinkupPanel", true)
            local pkPanel = self:getControl("PinkupPanel")
            self:setLabelText("TotalScoreLabel", CHS[3003632] .. data.totalScore, pkPanel)
            self:setLabelText("PKTimesLabel", CHS[3003633] .. data.pkValue, pkPanel)
        else
            -- 决赛
            self:setCtrlVisible("ShrinkPanel", true)
            self:setCtrlVisible("PinkupPanel", false)
            local shrinkPanel = self:getControl("ShrinkPanel")
            self:setLabelText("TotalScoreLabel", CHS[3003632] .. data.totalScore, shrinkPanel)
            self:setLabelText("PKTimesLabel", CHS[3003633] .. data.pkValue, shrinkPanel)

            local rankStr = ""
            if data.rank > 10 or data.rank == 0 then
                rankStr= CHS[3003634]
            else
                rankStr= string.format(CHS[3003635], data.rank)
            end

            self:setLabelText("CurrentOrderLabel", rankStr)
        end


        -- 倒计时
        self:updateLeftTime(data.stage2_duration_time + data.stage1_duration_time + data.startTime - gf:getServerTime())
    end

    self.data = data
end

function ShidaoInfoDlg:refreshInfo(data)
    self:setInfo(data)
end

function ShidaoInfoDlg:setLeftTimeInfo(time)
    local hours = math.floor(time / 3600)
    local minute = math.floor((time % 3600) / 60 )
    local seconds = math.floor((time % 3600)% 60)
    local timeStr = string.format("%02d:%02d:%02d", hours, minute, seconds)

    self:setLabelText("LeftTimeLabel_1", timeStr)
    self:setLabelText("LeftTimeLabel_2", timeStr)
end

function ShidaoInfoDlg:updateLeftTime(time)
    self.isCreatedTimeLabel = true
    local leftTime = time
    local leftTimePanel = self:getControl("LeftTimePanel")
    leftTimePanel:setVisible(true)

    local function update()
        if leftTime <= 0 then
            leftTimePanel:stopAllActions()
            return
        end

        leftTime = leftTime - 1
        self:setLeftTimeInfo(leftTime)
        self:requestData(leftTime)
    end

    self:setLeftTimeInfo(leftTime)
    leftTimePanel:stopAllActions()
    schedule(leftTimePanel, update, 1)
end

-- 刷新试道数据
function ShidaoInfoDlg:requestData(time)
    -- 打开界面  并且巅峰对决阶段
    -- 每10秒刷新一次
    -- 元魔阶段一分钟刷新一次
    if self.isShowUI and self.data  then
        if (self.data.stageId == 2 and (time % stage2_refesh_time) == 0) or (self.data.stageId == 1 and (time % stage1_refesh_time) == 0) then
            -- 发送请求跟新对决数据
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_SHIDAO_INFO)
            ShidaoInfoDlg:refreshInfo(self.data)
        elseif self.data.stageId == 0 and (time % stage2_refesh_time) == 0 then
            -- 刷新倒计时时间
            ShidaoInfoDlg:refreshInfo(self.data)
        end
    end
end

function ShidaoInfoDlg:onShidaoButton(sender, eventType)
    self:setCtrlVisible("MainPanel", true)
    self:setCtrlVisible("ShidaoButton", false)
    self.isShowUI = true
end

function ShidaoInfoDlg:onCloseButton(sender, eventType)
    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("ShidaoButton", true)
    self.isShowUI = false
end

function ShidaoInfoDlg:cleanup()
    self.isCreatedTimeLabel = nil
end

return ShidaoInfoDlg
