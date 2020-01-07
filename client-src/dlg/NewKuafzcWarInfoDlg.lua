-- NewKuafzcWarInfoDlg.lua
-- Created by
--

local NewKuafzcWarInfoDlg = Singleton("NewKuafzcWarInfoDlg", Dialog)

function NewKuafzcWarInfoDlg:init()
    self:bindListener("KuafzcWarButton", self.onKuafzcWarButton)


    self:setCtrlVisible("KuafzcWarButton", false)

    self.time = nil
    self.isExp = true   -- 展开状态
    self.schedule = nil
    self.data = nil

    self.isStart = false
    self:onDisplayDlg()
    self:bindListener("ExpandTimePanel", self.onDisplayDlg)
    self:bindListener("ShrinkTimePanel", self.onDisplayDlg)

    self:hookMsg("MSG_CSML_LIVE_SCORE")

    gf:CmdToServer('CMD_CSML_LIVE_SCORE', {})
end

function NewKuafzcWarInfoDlg:onDisplayDlg(sender, eventType)
    if self.isExp then
        self.isExp = false

        self:setCtrlVisible("ShrinkPanel", true)
        self:setCtrlVisible("ExpandPanel", false)
    else
        self.isExp = true

        self:setCtrlVisible("ShrinkPanel", false)
        self:setCtrlVisible("ExpandPanel", true)
    end
end


function NewKuafzcWarInfoDlg:onKuafzcWarButton(sender, eventType)
    -- 请求一次数据
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUSET_PW_BATTLE_INFO)

    local mainPanel = self:getControl("MainPanel")
    self:setCtrlVisible("MainPanel", (mainPanel:isVisible() == false))
    self:setCtrlVisible("KuafzcWarButton", false)
end

-- 设置双方帮派活跃度信息
function NewKuafzcWarInfoDlg:setPartyWarInfo(data)
    self:setMyPartyInfo(data)
    self:setEnemyPartyInfo(data)

    -- 我帮人数
    self:setLabelText("MyPartyNumLabel_2", data.ourPersonCount)
    -- 敌帮人数
    self:setLabelText("OtherPartyNumLabel_2", data.enermyPersonCount)

    local shrinkPanel = self:getControl("ShrinkPanel")
    self:setLabelText("MyActiveLabel", CHS[3003295] .. data.personScore, shrinkPanel)
    self:setLabelText("MyStaminaLabel", CHS[4010329] .. data.personTilizhi, shrinkPanel)

    shrinkPanel:requestDoLayout()
end



-- 设置己方帮派活跃度信息
function NewKuafzcWarInfoDlg:setMyPartyInfo(data)
    local panel = self:getControl("MyPartyPanel")
    -- 设置总活跃
    self:setLabelText("TotalActiveLabel_2", data.ourTotalScore, panel)

    for i = 1,5 do
        if data.ourRankInfo[i] then
            self:setLabelText("NameLabel" .. i, gf:getRealName(data.ourRankInfo[i].name), panel)
            self:setLabelText("ActiveLabel" .. i, data.ourRankInfo[i].score, panel)
        else
            self:setLabelText("NameLabel" .. i, "", panel)
            self:setLabelText("ActiveLabel" .. i, "", panel)
        end
    end

    -- 我的活跃
    self:setLabelText("MyActiveLabel", CHS[3003295] .. data.personScore, panel)
    panel:requestDoLayout()
end

-- 设置敌方帮派活跃度信息
function NewKuafzcWarInfoDlg:setEnemyPartyInfo(data)
    local panel = self:getControl("OtherPartyPanel")
    -- 设置总活跃
    self:setLabelText("TotalActiveLabel_2", data.enermyTotalScore, panel)

    for i = 1,5 do
        if data.enermyRankInfo[i] then
            self:setLabelText("NameLabel" .. i, gf:getRealName(data.enermyRankInfo[i].name), panel)
            self:setLabelText("ActiveLabel" .. i, data.enermyRankInfo[i].score, panel)
        else
            self:setLabelText("NameLabel" .. i, "", panel)
            self:setLabelText("ActiveLabel" .. i, "", panel)
        end
    end

    self:setLabelText("MyStaminaLabel", CHS[4010329] .. data.personTilizhi, panel)
    panel:requestDoLayout()
end

function NewKuafzcWarInfoDlg:MSG_CSML_LIVE_SCORE(data)
    self.data = data

    -- 设置帮派名称
    self:setLabelText("NameLabel_1", data.myDist, "MyPartyImage")
    self:setLabelText("NameLabel_2", data.myDist, "MyPartyImage")

    self:setLabelText("NameLabel_1", data.enermyDist, "OtherPartyImage")
    self:setLabelText("NameLabel_2", data.enermyDist, "OtherPartyImage")
--[[
    -- 设置倒计时
    if gf:getServerTime() < data.startTime then
        self:setHourglass(data.startTime - gf:getServerTime())

        self:setLabelText("WinPointLabel", CHS[4300003])
    else
        self:setHourglass(data.endTime - gf:getServerTime())

        self:setLabelText("WinPointLabel", string.format( CHS[4300004], data.needActive))
    end
--]]

    self:setHourglass(data.endTime - gf:getServerTime())
    self:setPartyWarInfo(data)

    self:updateLayout("MyPartyPanel")
    self:updateLayout("OtherPartyPanel")
end

function NewKuafzcWarInfoDlg:setHourglass(hourglassTime)
    self.time = hourglassTime
   -- self:setTimeInfo()
    if not self.schedule then
        self.schedule = schedule(self.root, function() self:setTimeInfo() end, 1)
    end
end

function NewKuafzcWarInfoDlg:setTimeInfo()
    local displayTime = 0
    local panel = self:getControl("TitleImage_2")
    if self.data then
        displayTime = self.data.endTime - gf:getServerTime()

        if self.isStart and self:isOutLimitTime("lastRequestTime", 10000) then
            gf:CmdToServer('CMD_CSML_LIVE_SCORE', {})
            self:setLastOperTime("lastRequestTime", gfGetTickCount())
        end

        self.isStart = true
    else
        self:setCtrlVisible("TitleImage2", false, panel)
        self:setCtrlVisible("TitleImage1", false, panel)
        return
    end

    displayTime = math.max(displayTime, 0)

    self:setLabelText("LeftTimeLabel_1", string.format("%02d", math.floor(displayTime / 60 / 60)) .. gf:getServerDate(":%M:%S", tonumber(displayTime)), "ExpandTimePanel")
    self:setLabelText("LeftTimeLabel_2", string.format("%02d", math.floor(displayTime / 60 / 60)) .. gf:getServerDate(":%M:%S", tonumber(displayTime)), "ExpandTimePanel")

    self:setLabelText("LeftTimeLabel_1", string.format("%02d", math.floor(displayTime / 60 / 60)) .. gf:getServerDate(":%M:%S", tonumber(displayTime)), "ShrinkTimePanel")
    self:setLabelText("LeftTimeLabel_2", string.format("%02d", math.floor(displayTime / 60 / 60)) .. gf:getServerDate(":%M:%S", tonumber(displayTime)), "ShrinkTimePanel")

    self:updateLayout("ShrinkTimePanel")
end

function NewKuafzcWarInfoDlg:onCloseButton(sender, eventType)
    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("KuafzcWarButton", true)
end

return NewKuafzcWarInfoDlg
