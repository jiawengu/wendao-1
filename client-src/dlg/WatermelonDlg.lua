-- WatermelonDlg.lua
-- Created by huangzz Apr/16/2018
-- 暑假-吃瓜准备界面

local DugeonVoteDlg = require('dlg/DugeonVoteDlg')
local WatermelonDlg = Singleton("WatermelonDlg", DugeonVoteDlg)

function WatermelonDlg:init()
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("StopVoteButton", self.onStopVoteButton)

    self.meIsAgress = false

    -- 设置倒计时进度条
    self:setHourglass()
    
    -- 秒数更新
    schedule(self.root, function()
        self:setTimeHour()
    end, 0)
    
    self:setCloseDlgWhenRefreshUserData(true)
    
    self:hookMsg("MSG_BROACAST_TEAM_ASK_STATE")
    self:hookMsg("MSG_TEAM_ASK_CANCEL")
end

-- 设置标题
function WatermelonDlg:setTitle(data)
    -- 设置界面相关信息
    self.voteData = data

    -- 刷新倒计时
    self:setHourglass(self.voteData.time)

    if TeamMgr:getTeamTotalNum() < 2 then
        self:onCloseButton()
    else
        -- 显示队伍信息
        self:displayTeamInfo()
    end
end

-- 队伍信息
function WatermelonDlg:displayTeamInfo()
    local tempList = gf:deepCopy(TeamMgr.members_ex)
    self.memberName = {}
    for i = 1, 2 do
        local memberPanel = self:getControl("MemberPanel_" .. i)
        if memberPanel and tempList[i] then
            self.memberName[i] = tempList[i].name
            self:setMemberInfo(tempList[i], memberPanel)
        end
    end
end

function WatermelonDlg:setMemberInfo(info, panel)
    self:setLabelText("NameLabel", gf:getRealName(info.name), panel)
    self:setVoteState(0, panel)

    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, info.level, false, LOCATE_POSITION.LEFT_TOP, 23, panel)

    self:setImage("ShapeImage", ResMgr:getSmallPortrait(info.org_icon), panel)
end

function WatermelonDlg:setVoteState(state, panel)
    if state == 1 then
        self:setCtrlVisible("AgreeImage", true, panel)
    else
        self:setCtrlVisible("AgreeImage", false, panel)
    end
end

function WatermelonDlg:onAgreeButton(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TEAM_ASK_AGREE)
end

function WatermelonDlg:onStopVoteButton()
    if self.meIsAgress then
        gf:ShowSmallTips(CHS[5400592])
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TEAM_ASK_REFUSE)
    end
end

-- 设置队伍投票情况
function WatermelonDlg:MSG_BROACAST_TEAM_ASK_STATE(date)

    -- 如果服务器给的时间 >= 0，则设置当前倒计时时间    为ios后台处理，平时值为-1   65535
    if date.meTime >= 0 and date.meTime <= 30 then
        self:setHourglass(date.meTime * 1000)
    end

    for i = 1, date.count do
        local dataInfo = date.memberInfo[i]
        for j = 1, 2 do
            local memberPanel = self:getControl("MemberPanel_" .. j)
            if self.memberName[j] == dataInfo.name then
                self:setVoteState(dataInfo.state, memberPanel)
            end

            if dataInfo.name == Me:queryBasic("name") then
                if dataInfo.state  == 1 then
                    self.meIsAgress = true
                    self:setCtrlEnabled("AgreeButton", false)
                else
                    self.meIsAgress = false
                    self:setCtrlEnabled("AgreeButton", true)
                end
            end
        end
    end
end

return WatermelonDlg
