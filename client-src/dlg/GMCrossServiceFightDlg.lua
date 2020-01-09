-- GMCrossServiceFightDlg.lua
-- Created by songcw Aug/25/2015
--

local GMCrossServiceFightDlg = Singleton("GMCrossServiceFightDlg", Dialog)

function GMCrossServiceFightDlg:init(data)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)

    self:bindListener("ConfirmButton", self.onGuanJun, "EndMatchPanel")
    self:bindListener("CancelButton", self.onGuanJun, "EndMatchPanel")

    self:hookMsg("MSG_CSB_GM_REQUEST_CONTROL_INFO")
end

function GMCrossServiceFightDlg:onStartButton(sender, eventType)
    GMMgr:startFightGM_MRZB()
end

function GMCrossServiceFightDlg:onConfirmButton(sender, eventType)
    GMMgr:setGM_MRZB_RESULT(1)
end

function GMCrossServiceFightDlg:onCancelButton(sender, eventType)
    GMMgr:setGM_MRZB_RESULT(0)
end

function GMCrossServiceFightDlg:MSG_CSB_GM_REQUEST_CONTROL_INFO(data)

    if data.captain == "" then
        -- 未有比赛结果
        self:setColorText(CHS[4300362], "TipsPanel", "ResultPanel", 0, 30, COLOR3.WHITE, 23, true)

    else
        self:setColorText(string.format(CHS[4300363], data.session, data.captain), "TipsPanel", "ResultPanel", 0, 15, COLOR3.WHITE, 23, true)
    end

    self:setCtrlVisible("ConfirmButton", data.captain ~= "")
    self:setCtrlVisible("CancelButton", data.captain ~= "")

    local leftTeamBtn = self:getControl("ConfirmButton", nil, "EndMatchPanel")
    leftTeamBtn.team_id = data.one_team_id
    self:setLabelText("Label", data.one_team_name, leftTeamBtn)

    local rightTeamBtn = self:getControl("CancelButton", nil, "EndMatchPanel")
    rightTeamBtn.team_id = data.other_team_id
    self:setLabelText("Label", data.other_team_name, rightTeamBtn)
end

function GMCrossServiceFightDlg:onGuanJun(sender, eventType)
    if not sender.team_id then
        return
    end

    gf:CmdToServer("CMD_CSB_GM_COMMIT_FINAL_WINNER", {team_id = sender.team_id})
end

function GMCrossServiceFightDlg:cleanup()
    GMMgr:cancleGM_MRZB_CONTROL()
end

function GMCrossServiceFightDlg:onCloseButton()
    gf:confirm(CHS[4300364], function ()
        DlgMgr:closeDlg(self.name)
    end)
end

return GMCrossServiceFightDlg
