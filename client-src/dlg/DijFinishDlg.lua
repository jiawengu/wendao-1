-- DijFinishDlg.lua
-- Created by sujl, May/9/2017
-- 地劫完成界面

local DijFinishDlg = Singleton("DijFinishDlg", Dialog)

function DijFinishDlg:init()
    self:setCtrlFullClientEx("BKPanel")

    self:bindListener("ConfrimButton", self.onConfirmButton)

    local childType = Me:getChildType()
    self:setCtrlVisible("BabyImage1", 2 == childType, "ShapePanel")
    self:setCtrlVisible("BabyImage2", 1 == childType, "ShapePanel")
end

-- 设置奖励信息
function DijFinishDlg:setRewardInfo(data, type)
    self.dlgType = type
    self:setCtrlVisible("DijieBonusPanel", false, "MainPanel")
    self:setCtrlVisible("TianjieBonusPanel", false, "MainPanel")
    self:setCtrlVisible("NanTianMenPanel", false, "MainPanel")
    self:setCtrlVisible("NoteImage1", false, "TitlePanel")
    self:setCtrlVisible("NoteImage2", false, "TitlePanel")
    self:setCtrlVisible("NoteImage3", false, "TitlePanel")
    self:setCtrlVisible("NoteImage4", false, "TitlePanel")
    if type == "diji" or type == "tianjie" then
        -- 地劫任务奖励
        self:setLabelText("ExpValueLabel1", string.format("+%d", data.bonus_exp), "DijieBonusPanel")
        self:setLabelText("LevelLimitValueLabel1", data.level_upper1, "DijieBonusPanel")
        self:setLabelText("LevelLimitValueLabel2", data.level_upper1 >= 179 and CHS[4000102] or data.level_upper2, "DijieBonusPanel")
        self:setLabelText("LifeGrowValueLabel1", data.polar_upper1, "DijieBonusPanel")
        self:setLabelText("LifeGrowValueLabel2", data.polar_upper2, "DijieBonusPanel")
        self:setCtrlVisible("DijieBonusPanel", true, "MainPanel")
        self:setCtrlVisible("NoteImage1", true, "TitlePanel")
        self:setCtrlVisible("NoteImage2", true, "TitlePanel")
    elseif type == "yuanshen" then
        -- 元神突破奖励奖励
        self:setLabelText("ExpValueLabel1", string.format("+%d", data.bonus_exp), "TianjieBonusPanel")
        self:setLabelText("LevelLimitValueLabel1", data.level_upper1, "TianjieBonusPanel")
        self:setLabelText("LevelLimitValueLabel2", data.level_upper2, "TianjieBonusPanel")
        self:setCtrlVisible("NoteImage3", true, "TitlePanel")
        self:setCtrlVisible("TianjieBonusPanel", true, "MainPanel")
    elseif type == "ntm" then
        self:setCtrlVisible("NoteImage4", true, "TitlePanel")
        self:setCtrlVisible("NanTianMenPanel", true, "MainPanel")
        self:setLabelText("TitleValueLabel1", data.chengwei, "NanTianMenPanel")
        self:setLabelText("ExpLabel1", "+" .. data.exp, "NanTianMenPanel")
        self:setLabelText("LimitLabel1", "+" .. data.xianmoPoint, "NanTianMenPanel")
    end
end

function DijFinishDlg:onConfirmButton(sender, eventType)
    self:onCloseButton()
    if self.dlgType == "yuanshen" then
        gf:CmdToServer("CMD_LEAVE_JIANZHONG", {})
    end
end

return DijFinishDlg
