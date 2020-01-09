-- PetStruggleRuleDlg.lua
-- Created by huangzz Sep/20/2017
-- 斗宠大会规则说明界面

local PetStruggleRuleDlg = Singleton("PetStruggleRuleDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local WUXUE = {
    [1] = {str = "1", num = 752},
    [2] = {str = "2", num = 725.1428571},
    [3] = {str = "3", num = 700.137931},
    [4] = {str = "4", num = 676.8},
    [5] = {str = "5", num = 654.9677419},
    [6] = {str = "6-10", num = 634.5},
    [7] = {str = "11-20", num = 615.2727273},
    [8] = {str = "21-50", num = 588.5217391},
    [9] = {str = "51-100", num = 564},
    [10] = {str = "101-200", num = 507.6},
    [11] = {str = "201-500", num = 461.4545455},
    [12] = {str = "501-1000", num = 423},
    [13] = {str = "1001-2000", num = 390.4615385},
    [14] = {str = "2001-5000", num = 362.5714286},
    [15] = {str = "5001-10000", num = 338.4},
    [16] = {str = "10001-20000", num = 270.72},
    [17] = {str = "20001-30000", num = 225.6},
}

function PetStruggleRuleDlg:init(data)
    local radioGroup = RadioGroup.new()
    radioGroup:setItems(self, {"NoteCheckBox", "TitleCheckBox"}, self.onCheckBox)
    radioGroup:selectRadio(1)

    self:setWuXuwInRule(data)

    self:hookMsg("MSG_DC_INFO")
end

function PetStruggleRuleDlg:onCheckBox(sender, eventType)
    local flag = sender:getName() == "NoteCheckBox"
    self:setCtrlVisible("NotePanel", flag, "MainPanel")
    self:setCtrlVisible("TitlePanel", not flag, "MainPanel")
end

-- 显示不同等级段每 20 分钟可获取的武学数值
function PetStruggleRuleDlg:setWuXuwInRule(data)
    if not data then
        return
    end

    local level = data.server_level
    local panel = self:getControl("BonusPanel", nil, "ListView")
    for i = 1, 17 do
        local label = self:getControl("ResourceLabel_" .. i, nil, panel)
        -- math.ceil(270.72 * 100 / 32)由于浮点数的原因，数值错误，所以采用如下处理
        local num = math.ceil(tonumber(tostring(WUXUE[i].num * level / 32)))
        local str = string.format(CHS[6000101], WUXUE[i].str) .. "："  .. num .. CHS[5410085] .. "/20" .. CHS[3003847]
        label:setString(str)
    end
end

function PetStruggleRuleDlg:MSG_DC_INFO(data)
    self:setWuXuwInRule(data)
end

return PetStruggleRuleDlg
