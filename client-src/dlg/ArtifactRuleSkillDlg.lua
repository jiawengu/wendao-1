-- ArtifactRuleSkillDlg.lua
-- Created by songcw Oct/2018/9
-- 法宝技能说明

local ArtifactRuleSkillDlg = Singleton("ArtifactRuleSkillDlg", Dialog)
local QMPK_CFG = require (ResMgr:getCfgPath("QuanmmPKCfg.lua"))

function ArtifactRuleSkillDlg:init()
    local fabao = QMPK_CFG[CHS[4100509]]
    for i, name in pairs(fabao) do
        local panel = self:getControl("UnitPanel" .. i)

        -- 图标
        self:setImage("ItemImage", InventoryMgr:getIconFileByName(name), panel)

        -- 法宝名称
        self:setLabelText("NameLabel", name, panel)

        -- 法宝技能
        self:setLabelText("DescLabel", EquipmentMgr:getArtifactSkillDesc(name), panel)
    end
end

return ArtifactRuleSkillDlg
