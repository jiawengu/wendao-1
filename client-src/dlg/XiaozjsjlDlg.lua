-- XiaozjsjlDlg.lua
-- Created by huangzz Feb/13/2019
-- 小舟竞赛奖励界面

local XiaozjsjlDlg = Singleton("XiaozjsjlDlg", Dialog)

function XiaozjsjlDlg:init()
    self:bindListener("CloseImage", self.onCloseButton)

    self:setCtrlVisible("BlackPanel", false)
end

function XiaozjsjlDlg:setData(data)
    -- self:setColorText(string.format(CHS[6000101]), "NumPanel", "ScorePanel", nil, nil, defColor, fontSize, locate, isPunct, isVip)
    if data.reward_type == "exp" and data.num > 0 then
        self:setLabelText("NumLabel_1", data.num, "ExpPanel")
        self:setLabelText("NumLabel_1", CHS[7100268], "DaoPanel")
    elseif data.reward_type == "tao" and data.num > 0 then
        self:setLabelText("NumLabel_1", CHS[7100268], "ExpPanel")
        self:setLabelText("NumLabel_1", gf:getTaoStr(data.num, 0) .. CHS[5410102], "DaoPanel")
    else
        self:setLabelText("NumLabel_1", CHS[7100268], "ExpPanel")
        self:setLabelText("NumLabel_1", CHS[7100268], "DaoPanel")
    end

    for i = 1, 3 do
        self:setCtrlVisible("RankImage_" .. i, i == data.rank)
    end

    self:setLabelText("NumLabel_1", string.format(CHS[5410090], math.floor(data.has_time / 60), data.has_time % 60), "ExpPanel_0")
end

function XiaozjsjlDlg:onCloseButton()
    DlgMgr:closeDlg("XiaozjsDlg")
end

function XiaozjsjlDlg:cleanup()
    gf:CmdToServer("CMD_CLOSE_DIALOG", { para1 = "summer_day_2019_xzjs", para2 = "" })
end

return XiaozjsjlDlg
