-- ShiJieBeiRewardDlg.lua
-- Created by
--

local ShiJieBeiRewardDlg = Singleton("ShiJieBeiRewardDlg", Dialog)

local PANEL_MAPS = {
    "XiaoZuPanel", "EightPanel", "FourPanel", "JuePanel",
}

local STAGE_KEY = {
    ["group"] = CHS[4300415],
    ["top8"] = CHS[4300429],
    ["top4"] = CHS[4300430],
    ["semi_final"] = CHS[4300440],
}

function ShiJieBeiRewardDlg:init(data)

    self:bindListener("PromptButton", self.onPromptButton)

    self:hookMsg("MSG_WORLD_CUP_2018_BONUS_INFO")
end

function ShiJieBeiRewardDlg:setUnitPanel(data, panel)
    self:setLabelText("GameNameLabel", STAGE_KEY[data.stage], panel)
    if data.support_team == "" then
        self:setLabelText("TeamLabel", CHS[4300446], panel)

        self:setCtrlVisible("ConditionLabel_1", false, panel)
        self:setCtrlVisible("ConditionLabel_2", false, panel)
    else
        self:setLabelText("TeamLabel", data.support_team, panel)

        -- 已晋级和未晋级需要在有支持队伍显示
        if data.promotion == -1 then
            -- 未开始
            self:setCtrlVisible("ConditionLabel_1", false, panel)
            self:setCtrlVisible("ConditionLabel_2", false, panel)
        else
            self:setCtrlVisible("ConditionLabel_1", data.promotion ~= 0, panel)
            self:setCtrlVisible("ConditionLabel_2", data.promotion == 0, panel)

            -- 如果是半决赛、决赛，需要显示晋级名次
            if data.stage == "semi_final" then
                for i = 1, 4 do
                    self:setCtrlVisible("ConditionLabel_" .. i, false, panel)
                end

                if data.promotion == 0 then
                    self:setCtrlVisible("ConditionLabel_4", true, panel)
                else
                    self:setCtrlVisible("ConditionLabel_" .. data.promotion, true, panel)
                end
            end
        end

    end

    self:setCtrlVisible("ReceiveImage", data.has_bonus == 2, panel)
    self:setCtrlVisible("GoButton", data.has_bonus ~= 2, panel)
    self:setCtrlEnabled("GoButton", data.has_bonus == 1, panel)



    panel.stage = data.stage
end

function ShiJieBeiRewardDlg:onGoButton(sender, eventType)
    gf:CmdToServer('CMD_WORLD_CUP_2018_FETCH_BONUS', {stage = sender:getParent().stage})
end

function ShiJieBeiRewardDlg:onPromptButton(sender, eventType)
    DlgMgr:openDlg("ShiJieBeiTimeDlg")
end

function ShiJieBeiRewardDlg:MSG_WORLD_CUP_2018_BONUS_INFO(data)
    for i = 1, 4 do
        local panel = self:getControl(PANEL_MAPS[i])
        self:setUnitPanel(data[i], panel)
        self:bindListener("GoButton", self.onGoButton, panel)
    end
end

return ShiJieBeiRewardDlg
