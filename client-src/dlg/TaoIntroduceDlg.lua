-- TaoIntroduceDlg.lua
-- Created by huangzz Sep/19/2018
-- 人物界面-道行规则说明界面

local TaoIntroduceDlg = Singleton("TaoIntroduceDlg", Dialog)

function TaoIntroduceDlg:init()
    self:bindListener("MainPanel", self.onCloseButton)
    
    local tao = Formula:getStdTao(Me:queryInt("level"))
    self:setLabelText("Label2", gf:getTaoStr(tao, 0), "STDTaoPanel")


    self:setLabelText("Label2", gf:getTaoStr(Me:queryBasicInt("mon_tao"), Me:queryBasicInt("mon_tao_ex")), "MonthTaoPanel")
    self:setLabelText("Label2", gf:getTaoStr(Me:queryBasicInt("last_mon_tao"), Me:queryBasicInt("last_mon_tao_ex")), "MonthTaoPanel_1")
end

return TaoIntroduceDlg