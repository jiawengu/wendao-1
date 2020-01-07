-- GetTaoTrusteeshipRuleDlg.lua
-- Created by songcw Oct/13/2016
-- 刷道托管规则界面

local GetTaoTrusteeshipRuleDlg = Singleton("GetTaoTrusteeshipRuleDlg", Dialog)

function GetTaoTrusteeshipRuleDlg:init()
    self:bindListener("GetTaoTrusteeshipRulePanel", self.onCloseButton)

    local nomal = GetTaoMgr:getLevelTrusteeshipTimeByType(1, Me:getVipType())
    local night = GetTaoMgr:getLevelTrusteeshipTimeByType(2, Me:getVipType())
--
    self:setLabelText("Label22", string.format(CHS[4200546], nomal))
    self:setLabelText("Label23", string.format(CHS[4200547], night)) --   夜间（22:00-02:00）托管时间上限增加至%d分钟，但夜间托管期间无法主动暂停托管，且
    self:setLabelText("Label24", string.format(CHS[4200548], nomal))
    self:setLabelText("Label27", string.format(CHS[4200549], nomal))
    self:setLabelText("Label28", string.format(CHS[4200550], nomal))

end

return GetTaoTrusteeshipRuleDlg
