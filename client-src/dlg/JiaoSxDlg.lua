-- JiaoSxDlg.lua
-- Created by songcw Mar/05/2018
-- 教师节拔草

local JiaoSxDlg = Singleton("JiaoSxDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local HOURGLASS = 30000        -- 沙漏时间30s   单位毫秒

local CHECKBOX = {
    "Number0Button",
    "Number1Button",
    "Number2Button",
    "Number3Button",
    "Number4Button",
    "Number5Button",
}


function JiaoSxDlg:init()
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("SendNotifyButton", self.onSendNotifyButton)
    self:bindListener("StopVoteButton", self.onStopVoteButton)

    -- 秒数更新
    schedule(self.root, function()
        self:setTimeHour()
    end, 0)

    self.group = RadioGroup.new()
    self.group:setItemsByButton(self, CHECKBOX, self.onCheckBox, nil, nil, true)

    self.isGoing = false    -- 进度条是否正常走
    self.data = nil
    self.selectPower = nil

    self:hookMsg("MSG_TEACHER_2018_GAME_S2_END")
end

function JiaoSxDlg:onCheckBox(sender, eventType)
    self.selectPower = eventType - 1
    self:updateBottom()
end

function JiaoSxDlg:setData(data)
    self.data = data
    -- 合理力度
    self:setLabelText("ReasonablePowLabel", string.format("%d~%d", data.min_power, data.max_power))

    -- 总力度
    self:setLabelText("TotalPowLabel", data.total_power)

    for i = 1,5 do
        local memberPanel = self:getControl("MemberPanel_" .. i)
        self:setMemberInfo(data.members[i], memberPanel)
    end

    local function hourglassCallBack(parameters)
        performWithDelay(self.root, function()
            DlgMgr:closeDlg(self.name)
        end, 0.1)
    end

    if not self.isGoing then
        self.isGoing = true

        local leftTime = data.end_ti - gf:getServerTime()
        if leftTime < 0 then
            self:onCloseButton()
            return
        end

        local startPos = math.max(leftTime * 1000 / HOURGLASS * 100, 0)
        self:setProgressBarByHourglass("ProgressBar", HOURGLASS, startPos, hourglassCallBack, nil, true)
    end

    self:updateBottom()

end


function JiaoSxDlg:updateBottom()
    -- 如果我是队员
    self:setCtrlVisible("NoteLabel_2", false)
    self:setCtrlVisible("NoteLabel_3", false)
    self:setCtrlVisible("SendNotifyButton", false)
    self:setCtrlVisible("RefuseButton", false)


    if self:getMyPow() < 0 then
        -- 还没有确认选择（客户端表现）
        if self.selectPower then
            self:setCtrlVisible("RefuseButton", true)
        else
            self:setCtrlVisible("NoteLabel_2", true)
        end
    else
        -- 都已经告诉服务器我选择了
        if TeamMgr:getLeaderId() ~= Me:getId() then
            self:setCtrlVisible("NoteLabel_3", true)
        else
            -- 队长可以提醒别人选择
            self:setCtrlVisible("SendNotifyButton", true)
        end
    end
end

-- 设置秒数 抄袭 DugeonVoteDlg:setTimeHour()
function JiaoSxDlg:setTimeHour()
    local barCtrl = self:getControl("ProgressBar")
    local time = barCtrl:getPercent() * 30 * 0.01
    local timeHour = math.ceil(time)
    if timeHour < 11 then
        self:setLabelText("LeftTimeLabel", timeHour .. CHS[3002392], nil, COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("LeftTimeLabel", timeHour .. CHS[3002392], nil, COLOR3.GREEN)
    end
end

function JiaoSxDlg:getMyPow()
    local members = self.data.members
    for i, info in pairs(members) do
        if info.gid == Me:queryBasic("gid") then
            return info.power
        end
    end
end

function JiaoSxDlg:cleanup()
    gf:CmdToServer("CMD_TEACHER_2018_GAME_S2_SELECT", {power = 0})
end

function JiaoSxDlg:setMemberInfo(info, panel)
    if not info then
        panel:setVisible(false)
        return
    end
    self:setLabelText("NameLabel", gf:getRealName(info.name), panel)

    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, info.level, false, LOCATE_POSITION.LEFT_TOP, 23, panel)

    self:setImage("ShapeImage", ResMgr:getSmallPortrait(info.icon), panel)
    self:setItemImageSize("ShapeImage", panel)

    self:setLabelText("WaitLabel", "", panel)
    self:setCtrlVisible("SelectedLabel_1", true, panel)
    self:setCtrlVisible("SelectedLabel_2", true, panel)
    if info.power < 0 then
        self:setLabelText("SelectedLabel_1", CHS[4010125], panel, COLOR3.TEXT_DEFAULT)
        self:setLabelText("SelectedLabel_2", "", panel)
    else
        self:setLabelText("SelectedLabel_1", CHS[4010126], panel, COLOR3.TEXT_DEFAULT)
        self:setLabelText("SelectedLabel_2", info.power, panel)
    end
end

function JiaoSxDlg:onRefuseButton(sender, eventType)
    if not self.selectPower then return end

    for i, ctlName in pairs(CHECKBOX) do
        self:setCtrlEnabled(ctlName, self.selectPower == (i - 1))
    end

    gf:CmdToServer("CMD_TEACHER_2018_GAME_S2_SELECT", {power = self.selectPower})
end

function JiaoSxDlg:onSendNotifyButton(sender, eventType)
    gf:CmdToServer("CMD_TEACHER_2018_GAME_S2_SHOCK")
end

function JiaoSxDlg:MSG_TEACHER_2018_GAME_S2_END(sender, eventType)
    DlgMgr:closeDlg(self.name)
end


return JiaoSxDlg
