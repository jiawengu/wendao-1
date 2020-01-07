-- LordLaoZiMemberDlg.lua
-- Created by songcw Sep/27/2016
-- 老君查岗、队员界面

local LordLaoZiMemberDlg = Singleton("LordLaoZiMemberDlg", Dialog)
local LESS_HEIGHT = 47
local MAX_LEFT_TIME = 180

function LordLaoZiMemberDlg:init()
    self.blank:setLocalZOrder(Const.ZORDER_LORDLAOZI)
    self:bindListener("SendNotifyButton", self.onSendNotifyButton)

    -- 临时调整提示框层级，cleanup 中要调回
    SmallTipsMgr:setLocalZOrder(Const.ZORDER_LORDLAOZI_TIP, self.name)

    -- 重刷数据时关闭界面
    self:setCloseDlgWhenRefreshUserData(true)

    self:setCtrlVisible("SendNotifyButton", true)

    self:hookMsg("MSG_FINISH_SECURITY_CODE")
    self:hookMsg("MSG_OTHER_LOGIN")
    self:hookMsg("MSG_UPDATE_TEAM_LIST")
    self:hookMsg("MSG_LOGIN_DONE")
end

function LordLaoZiMemberDlg:setData(data)
    self:refreshTeamLeader()
    self:setHourglass(math.min(MAX_LEFT_TIME, data.finishTime - gf:getServerTime()))
end

function LordLaoZiMemberDlg:refreshTeamLeader()
    local teamLeader = TeamMgr:getLeader()
    if teamLeader then  -- 从后台切回前台后或顶号登录时，有可能出现队伍消息不存在的情况
        self:setLabelText("NameLabel", gf:getRealName(teamLeader.name), "TargetPanel")
        self:setImage("ShapeImage", ResMgr:getSmallPortrait(teamLeader.org_icon), "TargetPanel")
        self:setItemImageSize("ShapeImage", "TargetPanle")

        -- 人物等级使用带描边的数字图片显示
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, teamLeader.level, false, LOCATE_POSITION.LEFT_TOP, 21, "TargetPanel")
    end
    self:setCtrlVisible("TargetPanel", nil ~= teamLeader)
    self:setCtrlVisible("LoadingPanel", nil == teamLeader)
end

function LordLaoZiMemberDlg:cleanup()

    -- 调回提示框正常的层级
    SmallTipsMgr:setLocalZOrder(nil, self.name)

    if self.timerId then
        gf:Unschedule(self.timerId)
        self.timerId = nil
    end
end

function LordLaoZiMemberDlg:setHourglass(time)
    -- 开始180s倒计时
    local startTime = gf:getServerTime()
    local elapse = 0
    self:setLabelText("LeftTimeLabel", tostring(time), "TimePanel")
    if self.timerId then
        gf:Unschedule(self.timerId)
    end
    self.timerId = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - startTime)
        self:setLabelText("LeftTimeLabel", tostring(math.max(0, time - elapse)), "TimePanel")
        if math.max(0, time - elapse) == 0 then
            self:onCloseButton()
        end
    end, 1);

    local function hourglassCallBack(parameters)
        if self.timerId then
            gf:Unschedule(self.timerId)
            self.timerId = nil
        end
        self:onCloseButton()
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

function LordLaoZiMemberDlg:onSendNotifyButton(sender, eventType)
    if not self:isOutLimitTime("lastTime", 10 * 1000) then
        gf:ShowSmallTips(CHS[4300116])
        return
    end

    self:setLastOperTime("lastTime", gfGetTickCount())
    local teamLeader = TeamMgr:getLeader()
    if teamLeader then
        VibrateMgr:sendVibrate("laojun", teamLeader.gid)
    end
end

function LordLaoZiMemberDlg:MSG_FINISH_SECURITY_CODE(data)
    DlgMgr:closeDlg(self.name)
end

function LordLaoZiMemberDlg:MSG_OTHER_LOGIN(data)
    -- 被顶号的时候，关闭
    DlgMgr:closeDlg(self.name)
end

-- 关闭界面
function LordLaoZiMemberDlg:MSG_UPDATE_TEAM_LIST(data)
    if TeamMgr:getTeamNum() <= 0 then
        self:onCloseButton()
    else
        self:refreshTeamLeader()
    end
end

function LordLaoZiMemberDlg:MSG_LOGIN_DONE(data)
    self:onCloseButton()
end

return LordLaoZiMemberDlg
