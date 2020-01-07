-- PartyWarInfoDlg.lua
-- Created by songcw Jan/11/2015
-- 帮战信息界面

local PartyWarInfoDlg = Singleton("PartyWarInfoDlg", Dialog)

function PartyWarInfoDlg:init()
    self:bindListener("PartyWarButton", self.onPartyWarButton)

    self.time = nil
    self.isExp = true   -- 展开状态
    self.schedule = nil
    self.data = nil

    self.isStart = false

    self:onDisplayDlg()
    self:bindListener("ExpandTimePanel", self.onDisplayDlg)
    self:bindListener("ShrinkTimePanel", self.onDisplayDlg)
    self:setCtrlVisible("PartyWarButton", false)

--    self:setPartyWarInfo()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUSET_PW_BATTLE_INFO)

    -- 每3分钟请求一次刷新数据
    schedule(self.root, function() gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUSET_PW_BATTLE_INFO) end, 180)

    self:hookMsg("MSG_PW_BATTLE_INFO")

end

-- 设置双方帮派活跃度信息
function PartyWarInfoDlg:setPartyWarInfo(data)
    self:setMyPartyInfo(data)
    self:setEnemyPartyInfo(data)

    -- 我帮人数
    self:setLabelText("MyPartyNumLabel_2", data.myPartyPlayerCount)
    -- 敌帮人数
    self:setLabelText("OtherPartyNumLabel_2", data.opponentPartyPlayerCount)

    local shrinkPanel = self:getControl("ShrinkPanel")
    self:setLabelText("MyActiveLabel", CHS[3003295] .. data.myActiveValue, shrinkPanel)
    self:setLabelText("MyStaminaLabel", CHS[3003296] .. data.myStaminaValue, shrinkPanel)

    shrinkPanel:requestDoLayout()
end

-- 设置己方帮派活跃度信息
function PartyWarInfoDlg:setMyPartyInfo(data)
    local panel = self:getControl("MyPartyPanel")
    -- 设置总活跃
    self:setLabelText("TotalActiveLabel_2", data.myTotalActive, panel)

    for i = 1,5 do
        if data.myPartyInfo[i] then
            self:setLabelText("NameLabel" .. i, gf:getRealName(data.myPartyInfo[i].name), panel)
            self:setLabelText("ActiveLabel" .. i, data.myPartyInfo[i].activeValue, panel)
        else
            self:setLabelText("NameLabel" .. i, "", panel)
            self:setLabelText("ActiveLabel" .. i, "", panel)
        end
    end

    -- 我的活跃
    self:setLabelText("MyActiveLabel", CHS[3003295] .. data.myActiveValue, panel)
    panel:requestDoLayout()
end

-- 设置敌方帮派活跃度信息
function PartyWarInfoDlg:setEnemyPartyInfo(data)
    local panel = self:getControl("OtherPartyPanel")
    -- 设置总活跃
    self:setLabelText("TotalActiveLabel_2", data.opponentTotalActive, panel)

    for i = 1,5 do
        if data.opponentPartyInfo[i] then
            self:setLabelText("NameLabel" .. i, gf:getRealName(data.opponentPartyInfo[i].name), panel)
            self:setLabelText("ActiveLabel" .. i, data.opponentPartyInfo[i].activeValue, panel)
        else
            self:setLabelText("NameLabel" .. i, "", panel)
            self:setLabelText("ActiveLabel" .. i, "", panel)
        end
    end

    self:setLabelText("MyStaminaLabel", CHS[3003296] .. data.myStaminaValue, panel)
    panel:requestDoLayout()
end

-- 定时器
function PartyWarInfoDlg:setHourglass(hourglassTime)
    self.time = hourglassTime
   -- self:setTimeInfo()
    if not self.schedule then
        self.schedule = schedule(self.root, function() self:setTimeInfo() end, 1)
    end
end

function PartyWarInfoDlg:setTimeInfo()
    local displayTime = 0
    local panel = self:getControl("TitleImage_2")
    if self.data then
        self:setCtrlVisible("TitleImage2", gf:getServerTime() < self.data.startTime, panel)
        self:setCtrlVisible("TitleImage1", gf:getServerTime() >= self.data.startTime, panel)

        if gf:getServerTime() < self.data.startTime then
            displayTime = self.data.startTime - gf:getServerTime()
        else
            displayTime = self.data.endTime - gf:getServerTime()


            if not self.isStart then
                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUSET_PW_BATTLE_INFO)
            end

            self.isStart = true
        end
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

function PartyWarInfoDlg:onPartyWarButton(sender, eventType)
    -- 请求一次数据
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUSET_PW_BATTLE_INFO)

    local mainPanel = self:getControl("MainPanel")
    self:setCtrlVisible("MainPanel", (mainPanel:isVisible() == false))
    self:setCtrlVisible("PartyWarButton", false)
end

function PartyWarInfoDlg:onCloseButton(sender, eventType)
    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("PartyWarButton", true)
end

function PartyWarInfoDlg:onDisplayDlg(sender, eventType)
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

function PartyWarInfoDlg:MSG_PW_BATTLE_INFO(data)
    self.data = data

    -- 设置帮派名称
    self:setLabelText("NameLabel_1", data.myPartyName, "MyPartyImage")
    self:setLabelText("NameLabel_2", data.myPartyName, "MyPartyImage")

    self:setLabelText("NameLabel_1", data.opponentPartyName, "OtherPartyImage")
    self:setLabelText("NameLabel_2", data.opponentPartyName, "OtherPartyImage")

    -- 设置倒计时
    if gf:getServerTime() < data.startTime then
        self:setHourglass(data.startTime - gf:getServerTime())

        self:setLabelText("WinPointLabel", CHS[4300003])
    else
        self:setHourglass(data.endTime - gf:getServerTime())

        self:setLabelText("WinPointLabel", string.format( CHS[4300004], data.needActive))
    end

    self:setPartyWarInfo(data)

    self:updateLayout("MyPartyPanel")
    self:updateLayout("OtherPartyPanel")
end

function PartyWarInfoDlg:getData()
    return self.data
end

return PartyWarInfoDlg
