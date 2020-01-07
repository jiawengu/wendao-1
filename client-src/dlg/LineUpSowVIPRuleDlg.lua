-- LineUpSowVIPRuleDlg.lua
-- Created by huangzz Sep/05/2018
-- 仙班资格查看界面 - 登录排队

local LineUpSowVIPRuleDlg = Singleton("LineUpSowVIPRuleDlg", Dialog)

function LineUpSowVIPRuleDlg:init(param)
    for i = 1, 3 do
        self:setCtrlVisible("VIPDetailListView" .. i, i == param)
    end

    if param == 1 then
        self:setTitleText(CHS[5400650] .. CHS[5400649])
    elseif param == 2 then
        self:setTitleText(CHS[5400651] .. CHS[5400649])
    else
        self:setTitleText(CHS[5400652] .. CHS[5400649])
    end
end

function LineUpSowVIPRuleDlg:setTitleText(str)
    self:setLabelText("TitleLabel_1", str)
    self:setLabelText("TitleLabel_2", str)
end

return LineUpSowVIPRuleDlg
