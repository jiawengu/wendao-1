-- KuafjjInfoDlg.lua
-- Created by huangzz Jan/04/2018
-- 跨服竞技信息界面

local KuafjjInfoDlg = Singleton("KuafjjInfoDlg", Dialog)

local titleInfo = KuafjjMgr:getTitleInfo()

function KuafjjInfoDlg:init()
    self:bindListener("TitleButton", self.onTitleButton)           -- 段位
    self:bindListener("RuleButton", self.onRuleButton)           -- 规则
    self:bindListener("PrepareButton", self.onPrepareButton)     -- 前往调整物资
    self:bindListener("SingelButton", self.onSingelButton)       -- 单人对战
    self:bindListener("3V3Button", self.on3V3Button)
    self:bindListener("5V5Button", self.on5V5Button)
    self:bindListener("ModifyTypeButton", self.onModifyTypeButton) -- 更改模式
    self:bindListener("TeamButton", self.onTeamButton)             -- 前往组队
    self:bindListener("MateButton", self.onMateButton)             -- 开始匹配
    self:bindListener("GotoButton", self.onGotoButton)             -- 前往战场
    self:bindListener("LeaveButton", self.onLeaveButton)             -- 离开跨服战场
    self:bindListener("RankButton", self.onRankButton)             -- 排名
    
    local data = KuafjjMgr.matchTimeData or {}
    local endTime
    if data.season_end_time then
        endTime = data.season_end_time - 5 * 60 * 60
    end
    
    local timeStr1 = gf:getServerDate("%m.%d", data.season_start_time or 0)
    local timeStr2 = gf:getServerDate("%m.%d", endTime or 0)
    self:setLabelText("TitleLabel_1", string.format(CHS[5400405], timeStr1, timeStr2), "MiddleTitleImage")
    self:setLabelText("TitleLabel_2", string.format(CHS[5400405], timeStr1, timeStr2), "MiddleTitleImage")
    
    self:setDlgView()

    self:hookMsg("MSG_CSC_NOTIFY_COMBAT_MODE")
    self:hookMsg("MSG_CSC_NOTIFY_AUTO_MATCH")
    self:hookMsg("MSG_CSC_PLAYER_CONTEST_DATA")
end

function KuafjjInfoDlg:onTitleButton(sender, eventType)
    DlgMgr:openDlg("KuafjjdwDlg")
end

function KuafjjInfoDlg:onRuleButton(sender, eventType)
    gf:showTipInfo(CHS[5400400], sender)
end

-- 调整物资
function KuafjjInfoDlg:onPrepareButton(sender, eventType)
    local isInKuafjjzc = MapMgr:isInKuafjjzc()
    if isInKuafjjzc then
        AutoWalkMgr:beginAutoWalk(gf:findDest(string.format(CHS[5400364], 4)))
    else
        AutoWalkMgr:beginAutoWalk(gf:findDest(string.format(CHS[5400364], 3)))
    end
    
    self:onCloseButton()
end

function KuafjjInfoDlg:onSingelButton(sender, eventType)
    KuafjjMgr:requestCombatMode("1V1")
end

function KuafjjInfoDlg:on3V3Button(sender, eventType)
    KuafjjMgr:requestCombatMode("3V3")
end

function KuafjjInfoDlg:on5V5Button(sender, eventType)
    KuafjjMgr:requestCombatMode("5V5")
end

function KuafjjInfoDlg:onModifyTypeButton(sender, eventType)
    if KuafjjMgr:checkKuafjjIsEnd() then
        return
    end

    self:setCtrlVisible("CombatTypePanel", true)
    self:setCtrlVisible("ModifyTypeButton",false)
    self:setCtrlVisible("TeamButton", false)
    self:setCtrlVisible("MateButton", false)
    self:setCtrlVisible("GotoButton", false)
end

function KuafjjInfoDlg:onTeamButton(sender, eventType)
    if KuafjjMgr:checkKuafjjIsEnd() then
        return
    end
    
    DlgMgr:openDlg("TeamDlg")
end

-- 开始匹配
function KuafjjInfoDlg:onMateButton(sender, eventType)
    if KuafjjMgr:checkKuafjjIsEnd() then
        return
    end
    
    if KuafjjMgr:getCurAutoMatchEnable() then
        KuafjjMgr:requestAutoMatch(0)
    else
        KuafjjMgr:requestAutoMatch(1)
    end
end

-- 前往战场
function KuafjjInfoDlg:onGotoButton(sender, eventType)
    if KuafjjMgr:checkKuafjjIsEnd() then
        return
    end
    
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5400392]))
    self:onCloseButton()
end

function KuafjjInfoDlg:onLeaveButton(sender, eventType)
    if Me:isTeamMember() then 
        gf:ShowSmallTips(CHS[5000078])
        return
    end

    if MapMgr:isInKuafjjzc() then
        if KuafjjMgr:getCurAutoMatchEnable() then
            gf:confirm(CHS[5410224], function()
                gf:CmdToServer("CMD_CSC_SET_AUTO_MATCH", {enable = 0})
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5410225]))
                DlgMgr:closeDlg("KuafjjInfoDlg")
            end)
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5410225]))
            self:onCloseButton()
        end
    else
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5410223]))
        self:onCloseButton()
    end
end

function KuafjjInfoDlg:onRankButton(sender, eventType)
    DlgMgr:openDlg("KuafjjjfDlg", nil, nil, true)
end

function KuafjjInfoDlg:setButtonLabelText(ctrlName, text)
    local button = self:getControl(ctrlName, nil)
    self:setLabelText("Label1", text, button)
    self:setLabelText("Label2", text, button)
end

function KuafjjInfoDlg:setDlgView()
    local isInKuafjjzc = MapMgr:isInKuafjjzc()
    local combatMode, needNum = KuafjjMgr:getCurCombatMode()
    local num = TeamMgr:getTeamTotalNum()
    num = num == 0 and 1 or num
    
    self:setCtrlVisible("CombatTypePanel", false)
    self:setCtrlVisible("ModifyTypeButton",false)
    self:setCtrlVisible("TeamButton", false)
    self:setCtrlVisible("MateButton", false)
    self:setCtrlVisible("GotoButton", false)
    
    if not combatMode then
        self:setCtrlVisible("CombatTypePanel", true)
        self:setLabelText("LeftLabel", CHS[5400386], "NotePanel_1")
    else
        self:setCtrlVisible("ModifyTypeButton",true)
        if num == needNum then
            if isInKuafjjzc then
                self:setCtrlVisible("MateButton", true)
                self:setLabelText("LeftLabel", CHS[5400388], "NotePanel_1")
            else
                self:setCtrlVisible("GotoButton", true)
                self:setLabelText("LeftLabel", CHS[5400387], "NotePanel_1")
            end
        else
            self:setCtrlVisible("TeamButton", true)
            self:setLabelText("LeftLabel", CHS[5400391], "NotePanel_1")
        end
    end
    
    if KuafjjMgr:checkKuafjjIsEnd(true) then
        -- 今日比赛已结束，请返回天墉城
        self:setLabelText("LeftLabel", CHS[5410219], "NotePanel_1")
    end
    
    if KuafjjMgr:getCurAutoMatchEnable() then
        -- 取消匹配
        self:setButtonLabelText("MateButton", CHS[5400395])
    else
        self:setButtonLabelText("MateButton", CHS[5400349])
    end
end

function KuafjjInfoDlg:setData(data)
    if not data then
        return
    end
    
    -- 头像
    self:setImage("Image", ResMgr:getCirclePortraitPathByIcon(Me:queryBasicInt("icon")), "PortraitPanel")
    
    -- 名称
    self:setLabelText("NameLabel", Me:getShowName(), "PortraitPanel")

    -- 本届名次
    local panel = self:getControl("RankPanel", nil, "CombantInfoPanel")
    if data.rank < 3000 and data.rank > 0 then
        self:setLabelText("LeftLabel_2", data.rank, panel)
    else
        self:setLabelText("LeftLabel_2", 3000 .. CHS[5400383], panel)
    end
    
    -- 本段积分
    local curScore = data.contrib - data.cur_stage_contrib
    local panel = self:getControl("ScorePanel", nil, "CombantInfoPanel")
    if data.last_stage_contrib == -1 then
        self:setLabelText("LeftLabel_2", curScore .. "/" .. CHS[4200046], panel)
    else
        local totalScore = data.last_stage_contrib - data.cur_stage_contrib
        self:setLabelText("LeftLabel_2", curScore .. "/" .. totalScore, panel)
    end

    -- 战斗场次
    local panel = self:getControl("FightTimesPanel", nil, "CombantInfoPanel")
    self:setLabelText("LeftLabel_2", data.combat, panel)
    
    -- 胜利场次
    local panel = self:getControl("WinTimesPanel", nil, "CombantInfoPanel")
    self:setLabelText("LeftLabel_2", data.win, panel)

    -- 胜率
    local panel = self:getControl("WinRatesPanel", nil, "CombantInfoPanel")
    if data.combat == 0 or data.win == 0 then
        self:setLabelText("LeftLabel_2", "0%", panel)
    else
        local rate = data.win / data.combat * 100        
        self:setLabelText("LeftLabel_2", string.format("%.1f%%", rate), panel)
    end
    
    -- 段位
    local bigStage = math.floor((data.stage - 1) / 3) + 1
    local subStage = (data.stage - 1) % 3 + 1
    if titleInfo[bigStage] then
        self:setLabelText("TitleLabel", titleInfo[bigStage].name .. gf:changeNumber(subStage) .. CHS[5400385], "RankTitlePanel")
        
        for i = 1, 3 do
            local canShow = i <= subStage
            self:setCtrlVisible("StarImage_" .. i, not canShow, "RankTitlePanel")
            self:setCtrlVisible("RealStarImage_" .. i, canShow, "RankTitlePanel")
        end
        
        self:setImage("BKImage_2", titleInfo[bigStage].icon, "RankTitlePanel")
    end
end

function KuafjjInfoDlg:MSG_CSC_NOTIFY_COMBAT_MODE(data)
    self:setDlgView()
end

function KuafjjInfoDlg:MSG_CSC_NOTIFY_AUTO_MATCH(data)
    self:setDlgView()
end

function KuafjjInfoDlg:MSG_CSC_PLAYER_CONTEST_DATA(data)
    self:setData(data)
end

return KuafjjInfoDlg
