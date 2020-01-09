-- DugeonVoteDlg.lua
-- Created by songcw Sep/09/2015
-- 副本创建投票对话框

local DugeonVoteDlg = Singleton("DugeonVoteDlg", Dialog)

local HOURGLASS = 30000        -- 沙漏时间30s   单位毫秒
local VIBRATE_TIME = 10         -- 震动间隔

function DugeonVoteDlg:init()
    self:bindListener("StopVoteButton", self.onStopVoteButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("SendNotifyButton", self.onSendNotifyButton)

    -- 显示队伍信息
    self:displayTeamInfo()

    -- 设置倒计时进度条
    self:setHourglass()

    -- 秒数更新
    schedule(self.root, function()
        self:setTimeHour()
    end, 0)

    self:setCloseDlgWhenRefreshUserData(true)

    self:hookMsg("MSG_BROACAST_TEAM_ASK_STATE")
    self:hookMsg("MSG_TEAM_ASK_CANCEL")

    self.sendNotifyTime = nil

end

function DugeonVoteDlg:cleanup()
end

function DugeonVoteDlg:onStopVoteButton()
    if Me:isTeamLeader() then
        gf:CmdToServer("CMD_CANCEL_ASK_MEMBER_ASSURE", {})
    else
        self:onRefuseButton()
    end
end

function DugeonVoteDlg:setUiInfo()
    -- 队长不需要同意拒绝
    if TeamMgr:getLeaderId() == Me:getId() then
        self:setCtrlVisible("RefuseButton", false)
        self:setCtrlVisible("AgreeButton", false)
        self:setCtrlVisible("NoteLabel_2", false)

        self:setCtrlVisible("SendNotifyButton", true)
    else
        self:setCtrlVisible("SendNotifyButton", false)
    end

    if self.voteData then
        if "release_brother" == self.voteData.type or "change_appellation" == self.voteData.type then
            -- 结拜相关的投票界面不需要显示震动提醒按钮
            self:setCtrlVisible("SendNotifyButton", false)
        elseif "delete_child" == self.voteData.type then
            self:setCtrlVisible("RefuseButton", true)
            self:setCtrlVisible("AgreeButton", true)
            self:setCtrlVisible("SendNotifyButton", false)
        end

    end
end

-- 设置倒计时进度条
function DugeonVoteDlg:setHourglass(time)
    time = math.min(math.max(0, time or HOURGLASS), HOURGLASS) -- 保证时间在0-30秒
    -- 进度条倒计时
    local function hourglassCallBack(parameters)
        performWithDelay(self.root, function()
            self:sendTimeoutCmd()
            self:onCloseButton()
        end, 0.1)
    end
    self:setProgressBarByHourglass("ProgressBar", HOURGLASS, 100 * time / HOURGLASS, hourglassCallBack, nil, true)
end

function DugeonVoteDlg:sendTimeoutCmd()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CONFIRE_RESULT)
end

-- 设置秒数
function DugeonVoteDlg:setTimeHour()
    local barCtrl = self:getControl("ProgressBar")
    local time = barCtrl:getPercent() * 30 * 0.01
    local timeHour = math.ceil(time)
    self:setLabelText("LeftTimeLabel", timeHour .. CHS[3002392])
end

-- 设置标题
function DugeonVoteDlg:setTitle(data)
    -- 标题
    self:setLabelText("TitleLabel_1", data.title)
    self:setLabelText("TitleLabel_2", data.title)

    -- 内容
    local panel = self:getControl("NotePanel")
    if panel then
        panel:removeAllChildren()
        local size = panel:getContentSize()
        local textCtrl = CGAColorTextList:create()
        textCtrl:setFontSize(19)
        textCtrl:setString(data.content)
        textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
        textCtrl:setContentSize(size.width, 0)
        textCtrl:updateNow()

        -- 垂直方向居中显示
        local textW, textH = textCtrl:getRealSize()
        textCtrl:setPosition((size.width - textW) * 0.5, size.height)
        panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    end

    -- 设置界面相关信息
    self.voteData = data

    self:setUiInfo()

    -- 退出投票按钮
    if data.is_team_leader == 1 then
        self:setCtrlVisible("StopVoteButton", true)
    else
        self:setCtrlVisible("StopVoteButton", false)
    end

    -- 刷新倒计时
    self:setHourglass(self.voteData.time)
end

-- 队伍信息
function DugeonVoteDlg:displayTeamInfo(panelName)
    if not panelName then panelName = "MemberPanel" end

    local tempList = gf:deepCopy(TeamMgr.members_ex)
    local members = {}
    for i = 1, 5 do
        if tempList[i] and tempList[i].team_status == 1 then
            table.insert(members, tempList[i])
        end
    end

    if #members == 0 or TeamMgr:getExMemberById(Me:getId()).team_status ~= 1 then
        members = {{team_status = 1, name = Me:queryBasic("name"), level = Me:queryBasicInt("level"), org_icon = Me:queryBasicInt("org_icon")}}
    end

    self.memberName = {}
    for i = 1,5 do
        local memberPanel = self:getControl("MemberPanel_" .. i, nil, panelName)
        if memberPanel then
            if members[i] == nil or members[i].team_status ~= 1 then
                memberPanel:setVisible(false)
            else
                self.memberName[i] = members[i].name
                self:setMemberInfo(members[i], memberPanel)
            end
        end
    end
end

function DugeonVoteDlg:setMemberInfo(info, panel)
    self:setLabelText("NameLabel", gf:getRealName(info.name), panel)
    self:setVoteState(0, panel)

    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, info.level, false, LOCATE_POSITION.LEFT_TOP, 23, panel)

    self:setImage("ShapeImage", ResMgr:getSmallPortrait(info.org_icon), panel)
    self:setItemImageSize("ShapeImage", panel)
    if info.team_status == 2 or info.team_status == 3 then
        -- 暂离
        self:setCtrlVisible("ZanliImage", true, panel)
        self:setCtrlEnabled("ShapeImage", false, panel)
    end
end

function DugeonVoteDlg:setVoteState(state, panel)
    if state == 0 then
        self:setCtrlVisible("WaitLabel", true, panel)
        self:setCtrlVisible("AgreeImage", false, panel)
        self:setCtrlVisible("RefuseImage", false, panel)
    elseif state == 1 then
        self:setCtrlVisible("WaitLabel", false, panel)
        self:setCtrlVisible("AgreeImage", true, panel)
        self:setCtrlVisible("RefuseImage", false, panel)
    else
        self:setCtrlVisible("WaitLabel", false, panel)
        self:setCtrlVisible("AgreeImage", false, panel)
        self:setCtrlVisible("RefuseImage", true, panel)
    end
end

function DugeonVoteDlg:onRefuseButton(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TEAM_ASK_REFUSE)
end

function DugeonVoteDlg:onAgreeButton(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TEAM_ASK_AGREE)
end

-- 设置队伍投票情况
function DugeonVoteDlg:MSG_BROACAST_TEAM_ASK_STATE(data)

    -- 如果服务器给的时间 >= 0，则设置当前倒计时时间    为ios后台处理，平时值为-1   65535
    if data.meTime >= 0 and data.meTime <= 30 then
        self:setHourglass(data.meTime * 1000)
    end

    for i = 1,data.count do
        local dataInfo = data.memberInfo[i]
        for j = 1, 5 do
            local memberPanel = self:getControl("MemberPanel_" .. j, nil, "MemberPanel")
            if self.memberName[j] == dataInfo.name then
                self:setVoteState(dataInfo.state, memberPanel)
            end

            if dataInfo.name == Me:queryBasic("name") then
                if dataInfo.state == 0 then
                    self:setCtrlVisible("RefuseButton", true)
                    self:setCtrlVisible("AgreeButton", true)
                    self:setCtrlVisible("NoteLabel_2", false)
                elseif dataInfo.state  == 1 then
                    self:setCtrlVisible("RefuseButton", false)
                    self:setCtrlVisible("AgreeButton", false)
                    self:setCtrlVisible("NoteLabel_2", true)
                else
                    self:setCtrlVisible("RefuseButton", false)
                    self:setCtrlVisible("AgreeButton", false)
                    self:setCtrlVisible("NoteLabel_2", true)
                end
            end
        end
    end

    if TeamMgr:getLeaderId() == Me:getId() then
        self:setCtrlVisible("NoteLabel_2", false)
    end
end

function DugeonVoteDlg:onSendNotifyButton()
    if self.sendNotifyTime and gf:getServerTime() - self.sendNotifyTime < VIBRATE_TIME then
        gf:ShowSmallTips(string.format(CHS[6400092], VIBRATE_TIME))
        return
    end

    self.sendNotifyTime = gf:getServerTime()

    local notifyType = "dungeon"
    if self.voteData then
        notifyType = self.voteData.type or notifyType
        elseif "qmpk" == self.voteData.type then
            notifyType = "qmpk"
    end

    VibrateMgr:sendVibrate(notifyType)
end

-- 关闭对话框
function DugeonVoteDlg:MSG_TEAM_ASK_CANCEL(data)
    self:onCloseButton()
end

return DugeonVoteDlg
