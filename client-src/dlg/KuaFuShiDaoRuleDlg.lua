-- KuaFuShiDaoRuleDlg.lua
-- Created by huangzz Oct/09/2018
-- 跨服试道规则说明

local KuaFuShiDaoRuleDlg = Singleton("KuaFuShiDaoRuleDlg", Dialog)

function KuaFuShiDaoRuleDlg:init()
    if ShiDaoMgr:isMonthTaoKFSD() then
        self:setCtrlVisible("UsualRulePanel", false)
        self:setCtrlVisible("MonthPanel", true)
    else
        self:setCtrlVisible("UsualRulePanel", true)
        self:setCtrlVisible("MonthPanel", false)
    end
end

return KuaFuShiDaoRuleDlg
