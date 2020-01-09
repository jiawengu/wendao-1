-- EquipmentRuleRecommendDlg.lua
-- Created by
--

local EquipmentRuleRecommendDlg = Singleton("EquipmentRuleRecommendDlg", Dialog)

function EquipmentRuleRecommendDlg:init(panelName)
    local children = self.root:getChildren()
    for _, panel in pairs(children) do
        panel:setVisible(panel:getName() == panelName)
    end
end

return EquipmentRuleRecommendDlg
