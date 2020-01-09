-- ArtifactRuleNewDlg.lua
-- Created by songcw Oct/2018/9
-- 法宝规则说明总界面

local ArtifactRuleNewDlg = Singleton("ArtifactRuleNewDlg", Dialog)
local QMPK_CFG = require (ResMgr:getCfgPath("QuanmmPKCfg.lua"))

-- 一级菜单
local MENU_BIG_CLASS = {
    CHS[4200589],     CHS[4200588],     CHS[4200590]
}

-- 菜单对应显示的panel
local MENU_PANEL_MAP = {
    [CHS[4200589]] = "FirstPagePanel",
    [CHS[4200588]] = "RefinePanel",
    [CHS[4200590]] = "SkillUpPanel",
}

local ARTIFACT_SPSKILL_LIST =
{
    CHS[3001942],
    CHS[3001943],
    CHS[3001944],
    CHS[3001945],
    CHS[3001946],
    CHS[3001947],
}

--
function ArtifactRuleNewDlg:init(data)
    self:bindListener("IntimacyLink", self.onIntimacyLink)
    self:bindListener("PolarLink", self.onPolarLink)
    self:bindListener("AllSkillLink", self.onAllSkillLink)
    self:bindListener("RefineLink", self.onRefineLink)
    self:bindListener("SkillUpLink", self.onSkillUpLink)

    for i = 0, 5 do
        local skillName = ARTIFACT_SPSKILL_LIST[i + 1]
        local panelName = self:getControl("SkillPanel_" .. i)
        local skillImage = self:getControl("SkillImage_1", nil, panelName)
        local skillAttrib = SkillMgr:getskillAttribByName(skillName)
        local skillIconPath = SkillMgr:getSkillIconPath(skillAttrib.skill_no)
        self:setImage("SkillImage_1", skillIconPath, panelName)
        self:setItemImageSize("SkillImage_1", panelName)

        local function skillTouchListener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local rect = self:getBoundingBoxInWorldSpace(sender)
                local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
                dlg:setSKillByName(skillName, rect)
            end
        end
        skillImage:addTouchEventListener(skillTouchListener)
    end


    self.bigMenuPanel = self:retainCtrl("BigPanel")
    self.smallMenuPanel = self:retainCtrl("SPanel")

    -- 左侧菜单处理
    self:setMenuList("CategoryListView", MENU_BIG_CLASS, self.bigMenuPanel, nil, nil, self.onClickBigMenu, nil, data)
end

-- 点击一级菜单
function ArtifactRuleNewDlg:onClickBigMenu(sender, isDef)
    for menuName, panelName in pairs(MENU_PANEL_MAP) do
        self:setCtrlVisible(panelName, menuName == sender:getName())
    end
end

-- 查看亲密加成
function ArtifactRuleNewDlg:onIntimacyLink(sender, isDef)
    DlgMgr:openDlg("ArtifactIntimacyRuleDlg")
end

-- 查看相性加成
function ArtifactRuleNewDlg:onPolarLink(sender, isDef)
    DlgMgr:openDlg("ArtifactRulePolarDlg")
end

-- 所有技能一览
function ArtifactRuleNewDlg:onAllSkillLink(sender, isDef)
    DlgMgr:openDlg("ArtifactRuleSkillDlg")
end

-- 模拟点击一级菜单，和 onClickBigMenu 区别在于，要设置选中的光效
function ArtifactRuleNewDlg:onGotoMenu(menuName)
    local list = self:getControl("CategoryListView")
    local menus = list:getItems()
    for _, panel in pairs(menus) do
        self:setCtrlVisible("BChosenEffectImage", panel:getName() == menuName, panel)

        if panel:getName() == menuName then
            self:onClickBigMenu(self:getControl(menuName))
        end
    end
end

-- 洗练
function ArtifactRuleNewDlg:onRefineLink(sender, isDef)
    self:onGotoMenu(CHS[4200588])
end

-- 技能升级
function ArtifactRuleNewDlg:onSkillUpLink(sender, isDef)
    self:onGotoMenu(CHS[4200590])
end


return ArtifactRuleNewDlg
