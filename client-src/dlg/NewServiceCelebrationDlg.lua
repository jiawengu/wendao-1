-- NewServiceCelebrationDlg.lua
-- Created by lixh Apr/01/2019
-- 新服盛典界面

local NewServiceCelebrationDlg = Singleton("NewServiceCelebrationDlg", Dialog)

local REWARD_CFG = {
    CHS[7120181], -- 道行盛典礼包
    CHS[7120182], -- 等级盛典礼包
    CHS[7120183], -- 盛典礼包
}

function NewServiceCelebrationDlg:init()
    self:bindListener("RuleButton", self.onRuleButton)

    self:hookMsg("MSG_NEW_DIST_CHONG_BANG_DATA")

    for i = 1, #REWARD_CFG do
        local panel = self:getControl("ItemPanel_" .. i)
        self:setImage("ItemImage", ResMgr:getIconPathByName(REWARD_CFG[i]), panel)

        panel:addTouchEventListener(function(sender)
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageDlg(REWARD_CFG[i], rect)
        end)
    end

    self.rankPanel = self:getControl("RankPanel")
    self:setLabelText("LevelLabel_1", "", self.rankPanel)
    self:setLabelText("LevelLabel_2", "", self.rankPanel)
    self:setLabelText("TaoLabel_1", "", self.rankPanel)
    self:setLabelText("TaoLabel_2", "", self.rankPanel)

    GiftMgr:openNewServiceCelebration()
end

function NewServiceCelebrationDlg:setData(data)
    local meLevel = Me:getLevel()

    if meLevel < 70 then
        self:setCtrlVisible("TipsLabel_1", true, self.rankPanel)
        self:setCtrlVisible("TipsLabel_2", true, self.rankPanel)
    else
        self:setCtrlVisible("TipsLabel_1", false, self.rankPanel)
        self:setCtrlVisible("TipsLabel_2", false, self.rankPanel)

        -- 道行排行
        local taoDes = CHS[7120190]
        if data.tao_rank_index > 0 then
            taoDes = string.format(CHS[7120189], data.tao_rank_index)
        end

        self:setLabelText("TaoLabel_1", taoDes, self.rankPanel)
        self:setLabelText("TaoLabel_2", taoDes, self.rankPanel)

        -- 等级排行
        local levelDes = CHS[7120188]
        if data.level_rank_index > 0 then
            levelDes = string.format(CHS[7120187], data.level_rank_index)
        end

        self:setLabelText("LevelLabel_1", levelDes, self.rankPanel)
        self:setLabelText("LevelLabel_2", levelDes, self.rankPanel)
    end

    -- 活动时间
    local starTimeDes = gf:getServerDate(CHS[7120184], data.start_time)
    local endTimeDes = gf:getServerDate(CHS[7120185], data.end_time)
    self:setLabelText("TitleLabel", string.format(CHS[7120186], starTimeDes, endTimeDes), "TimePanel")
end

function NewServiceCelebrationDlg:onRuleButton(sender, eventType)
    DlgMgr:openDlg("NewServiceCelebrationRuleDlg")
end

function NewServiceCelebrationDlg:MSG_NEW_DIST_CHONG_BANG_DATA(data)
    self:setData(data)
end

return NewServiceCelebrationDlg
