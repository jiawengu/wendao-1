-- LordLaoZiRuleDlg.lua
-- Created by sujl, Mar/30/2016
-- 老君查岗规则界面

local LordLaoZiRuleDlg = Singleton("LordLaoZiRuleDlg", Dialog)

function LordLaoZiRuleDlg:init()
    self.blank:setLocalZOrder(Const.ZORDER_LORDLAOZI)
end

return LordLaoZiRuleDlg
