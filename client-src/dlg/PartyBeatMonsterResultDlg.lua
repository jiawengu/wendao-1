-- PartyBeatMonsterResultDlg.lua
-- Created by songcw Oct/9/2017
-- 挑战巨兽结算界面

local PartyBeatMonsterResultDlg = Singleton("PartyBeatMonsterResultDlg", Dialog)

local RES_IMAGE = {
    [1] = ResMgr.ui.mvp_word,  -- MVP
    [2] = ResMgr.ui.shenyi_word,  -- 表示神医
    [3] = ResMgr.ui.shenfeng_word,  -- 表示神封
}

function PartyBeatMonsterResultDlg:init(data)
    self:bindListener("ComfireButton", self.onCloseButton)
    self:bindListener("InfoButton", self.onInfoButton)
    
    
    self:setData(data)
end

function PartyBeatMonsterResultDlg:setData(data)
    -- 道行
    self:setLabelText("RewardLabel", data.tao, "RewardPanel1")

    -- 武学
    self:setLabelText("RewardLabel", string.format(CHS[4200467], data.martial), "RewardPanel2")

    -- 帮贡
    self:setLabelText("RewardLabel", string.format(CHS[4200468], data.contribution), "RewardPanel3")

    -- 帮派活力值
    self:setLabelText("RewardLabel", string.format(CHS[4300278], data.active), "RewardPanel4")

    -- 排名信息
    for i = 1, 5 do
        if data[i] then
            local panel = self:getControl("TextPanel" .. i)

            -- 评价
            self:setCtrlVisible("EvaluateImage", data[i].pingjia ~= 0, panel)
            self:setImage("EvaluateImage", RES_IMAGE[data[i].pingjia], panel)

            -- 角色
            self:setLabelText("ContentLabel1", data[i].name, panel)

            -- 贡献度
            self:setLabelText("ContentLabel2", data[i].contribution, panel)

                -- 排名  
            if data[i].rankChange > 0 then
                self:setLabelText("ContentLabel3", data[i].curRank .. "↑", panel, COLOR3.GREEN)
            elseif data[i].rankChange < 0 then
                self:setLabelText("ContentLabel3", data[i].curRank .. "↓", panel, COLOR3.RED)
            else
                self:setLabelText("ContentLabel3", data[i].curRank, panel, COLOR3.TEXT_DEFAULT)
            end
        end
    end
end

function PartyBeatMonsterResultDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PartyBeatMonsterResultRuleDlg")
end

return PartyBeatMonsterResultDlg
