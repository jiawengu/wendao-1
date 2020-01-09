-- GMQuanmPKFightDlg.lua
-- Created by lixh Jul/13/2018
-- 全民PK GM控制界面

local GMQuanmPKFightDlg = Singleton("GMQuanmPKFightDlg", Dialog)

local MATCH_ID_CFG = QuanminPK2Mgr:getFinalMatchIdCfg()

-- 比赛内容描述
local COMPETE_DES = {
    CHS[7100315], -- 半决赛一
    CHS[7100316], -- 半决赛二
    CHS[7100317], -- 季殿军之战
    CHS[7100318], -- 冠亚军之战
}

-- 内测区倒计时
local TEST_DIST_TICK = 300

function GMQuanmPKFightDlg:init(curIndex)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ConfirmButton", self.onResultConfirmButton, "ResultPanel")
    self:bindListener("CancelButton", self.onResultCancelButton, "ResultPanel")
    self:bindListener("ConfirmButton", self.onEndConfirmButton, "EndMatchPanel")
    self:bindListener("CancelButton", self.onEndCancelButton, "EndMatchPanel")

    self.index = curIndex
    GMMgr:openGM_QMPK_CONTROL()
    self:hookMsg("MSG_CSQ_GM_REQUEST_CONTROL_INFO")
end

function GMQuanmPKFightDlg:onStartButton(sender, eventType)
    if not self.data then return end
    GMMgr:startFightGM_QMPK(self.data.matchId)
end

function GMQuanmPKFightDlg:onResultConfirmButton(sender, eventType)
    if not self.data then return end
    GMMgr:setGM_QMPK_RESULT(self.data.matchId, 1)
end

function GMQuanmPKFightDlg:onResultCancelButton(sender, eventType)
    if not self.data then return end
    GMMgr:setGM_QMPK_RESULT(self.data.matchId, 0)
end

function GMQuanmPKFightDlg:onEndConfirmButton(sender, eventType)
    if not self.data then return end
    GMMgr:setGM_QMPK_LAST_WINNER(self.data.matchId, self.data.oneTeamId)
end

function GMQuanmPKFightDlg:onEndCancelButton(sender, eventType)
    if not self.data then return end
    GMMgr:setGM_QMPK_LAST_WINNER(self.data.matchId, self.data.otherTeamId)
end

function GMQuanmPKFightDlg:MSG_CSQ_GM_REQUEST_CONTROL_INFO()
    self.data = GMMgr:getQmpkGmData().list[self.index]
    if not self.data then return end

    -- 战斗开始
    self:setLabelText("Label_2", COMPETE_DES[tonumber(self.data.matchId)], "StartPanel")
    self:setLabelText("Label_3", self.data.oneTeamName .. "VS" .. self.data.otherTeamName, "StartPanel")

    -- 比赛结果
    if self.data.winnerLeaderName == "" then
        self:setLabelText("Label_4", CHS[4300362], "ResultPanel")
    else
        self:setLabelText("Label_4", string.format(CHS[4300363], self.data.combatNum, self.data.winnerLeaderName), "ResultPanel")
    end

    -- 是否有效
    self:setCtrlVisible("ConfirmButton", self.data.winnerLeaderName ~= "", "ResultPanel")
    self:setCtrlVisible("CancelButton", self.data.winnerLeaderName ~= "", "ResultPanel")

    -- 晋级
    local leftTeamBtn = self:getControl("ConfirmButton", nil, "EndMatchPanel")
    self:setLabelText("Label", self.data.oneTeamName, leftTeamBtn)

    local rightTeamBtn = self:getControl("CancelButton", nil, "EndMatchPanel")
    self:setLabelText("Label", self.data.otherTeamName, rightTeamBtn)

    -- 根据matchId 更新一下直接晋级底板信息
    local matchId = tonumber(self.data.matchId)
    if matchId == MATCH_ID_CFG.HALF_FINAL_ONE or matchId == MATCH_ID_CFG.HALF_FINAL_TWO then
        self:setLabelText("TipsLabel_1", CHS[7100269], "EndMatchPanel")
    elseif matchId == MATCH_ID_CFG.FINAL_BEFORE then
        self:setLabelText("TipsLabel_1", CHS[7100270], "EndMatchPanel")
    elseif matchId == MATCH_ID_CFG.FINAL then
        self:setLabelText("TipsLabel_1", CHS[7100271], "EndMatchPanel")
    else
        Log:I("Qmpk Gm Control match id wrong \n")
    end

    self:setLabelText("TipsLabel_2", CHS[7100272], "EndMatchPanel")

    if DistMgr:curIsTestDist() then
        -- 内测区需要增加倒计时
        local startButton = self:getControl("StartButton")
        self:setLabelText("Label", CHS[7100319],"StartButton")
        local curTime = gf:getServerTime()
        local qmpkInfo = QuanminPK2Mgr:getFubenData()
        local countTime = qmpkInfo.pairTime - gf:getServerTime()
        if self.data.lastCobEndTime > 0 then
            countTime = self.data.lastCobEndTime - curTime + TEST_DIST_TICK
        end

        startButton:stopAllActions()

        local function func()
            if countTime <= 0 then
                startButton:stopAllActions()
            else
                countTime = countTime - 1
                if countTime <= TEST_DIST_TICK and countTime >= 0 then
                    self:setLabelText("Label", CHS[7100319] .. "(" .. countTime  .. "s)" ,"StartButton")
                else
                    self:setLabelText("Label", CHS[7100319], "StartButton")
                end
            end
        end

        schedule(startButton, func, 1)
    end
end

function GMQuanmPKFightDlg:cleanup()
    GMMgr:cancleGM_QMPK_CONTROL()
    self:getControl("StartButton"):stopAllActions()
end

function GMQuanmPKFightDlg:cleanup()
    GMMgr:cancleGM_QMPK_CONTROL()
end

function GMQuanmPKFightDlg:onCloseButton()
    gf:confirm(CHS[4300364], function ()
        DlgMgr:closeDlg(self.name)
    end)
end

return GMQuanmPKFightDlg