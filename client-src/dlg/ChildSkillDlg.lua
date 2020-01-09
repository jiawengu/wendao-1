-- ChildSkillDlg.lua
-- Created by lixh Apr/01/2019
-- 娃娃技能界面

local ChildSkillDlg = Singleton("ChildSkillDlg", Dialog)

-- 技能页签
local TAB_SKILL_TYPE = {"PhyType", "BType", "DType", "CType"}

function ChildSkillDlg:init(cid)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListViewListener("SkillListView", self.onSelectSkillListView)

    self.kid = HomeChildMgr:getKidByCid(cid)

    for i = 1, 4 do
        local tabPanel = self:getControl("TabPanel" .. i)
        tabPanel.type = TAB_SKILL_TYPE[i]
        self:bindListener("TabPanel" .. i, self.onTabPanel)
    end

    self.listView = self:getControl("SkillListView")
    self.selectEffect = self:retainCtrl("SChosenEffectImage", "SkillPanel")
    self.skillItemPanel = self:retainCtrl("SkillPanel1", "SkillPanel")
    self.scrollView = self:getControl("ScrollView")

    -- 默认选择物攻
    self:onTabPanel(self:getControl("TabPanel1"))
end

function ChildSkillDlg:onTabPanel(sender, eventType)
    for i = 1, 4 do
        local tabPanel = self:getControl("TabPanel" .. i)
        self:setCtrlVisible("BChosenEffectImage", false, tabPanel)
    end

    self:setCtrlVisible("BChosenEffectImage", true, sender)

    self:setSkillListByType(sender.type)
end

function ChildSkillDlg:setSkillListByType(skillType)
    self.listView:removeAllItems()
    self.selectItem = nil

    local skillCfg = HomeChildMgr:getSkillCfgByFamily(self.kid:queryBasicInt("polar"))[skillType]
    for i = 1, #skillCfg do
        local skillPanel = self.skillItemPanel:clone()

        -- 图标
        self:setImage("SkillImage", SkillMgr:getSkillIconPath(skillCfg[i]), skillPanel)
        self:setItemImageSize("SkillImage", item)

        local skillAttrib = SkillMgr:getskillAttrib(skillCfg[i])

        -- -- 等级
        -- local skillLevel = math.floor(1.6 * (self.kid:getLevel() + 15))

        -- 类型
        local ladderDes = CHS[3003641]
        if skillCfg[i] ~= 501 then
            -- 力破千钧外的技能需要显示具体阶数
            ladderDes = SkillMgr:getLadderDescr(skillAttrib.skill_ladder)
        end

        -- -- 目标数量
        -- local targetNum = 1
        -- if skillCfg[i] == 501 then
        --     -- 力破千军特殊处理
        --     if skillLevel >= 120 then
        --         targetNum = 3
        --     else
        --         targetNum = 2
        --     end
        -- else
        --     -- 法术、障碍、辅助3阶技能 在技能等级到达60级时，目标为2 
        --     if skillAttrib.skill_ladder == SKILL.LADDER_3 and skillLevel >= 60 then
        --         targetNum = 2
        --     end
        -- end

        -- 名称
        local kid = HomeChildMgr:getKidByCid(self.kid:queryBasic("cid"))
        local skill = SkillMgr:getSkill(kid:getId(), skillCfg[i])
        if skill then
            -- 已拥有
            gf:resetImageView(self:getControl("SkillImage", Const.UIImage, skillPanel))
            self:setLabelText('SkillNameLabel', skillAttrib.name, skillPanel, COLOR3.TEXT_DEFAULT)
            self:setLabelText('SkillLVLabel', skill.skill_level, skillPanel, COLOR3.TEXT_DEFAULT)
            self:setLabelText('SkillTypeLabel', ladderDes, skillPanel, COLOR3.TEXT_DEFAULT)
            self:setLabelText("ManaCostLabel", tonumber(skill.skill_mana_cost), skillPanel, COLOR3.TEXT_DEFAULT)
            self:setLabelText("TargetNumLabel", skill.range, skillPanel, COLOR3.TEXT_DEFAULT)
        else
            -- 该技能未拥有
            gf:grayImageView(self:getControl("SkillImage", Const.UIImage, skillPanel))
            self:setLabelText('SkillNameLabel', skillAttrib.name, skillPanel, COLOR3.GRAY)
            self:setLabelText('SkillLVLabel', 0, skillPanel, COLOR3.GRAY)
            self:setLabelText('SkillTypeLabel', ladderDes, skillPanel, COLOR3.GRAY)
            self:setLabelText("ManaCostLabel", 0, skillPanel, COLOR3.GRAY)
            self:setLabelText("TargetNumLabel", 0, skillPanel, COLOR3.GRAY)
        end

        self:setCtrlVisible("BackImage1", i % 2 ~= 0, skillPanel)
        self:setCtrlVisible("BackImage2", i % 2 == 0, skillPanel)

        skillPanel.skillName = skillAttrib.name
        skillPanel.skillNo = skillCfg[i]

        self.listView:pushBackCustomItem(skillPanel)

        if not self.selectItem then
            self:onSelectSkillListView(nil, nil, skillPanel)
        end
    end
end

function ChildSkillDlg:onSelectSkillListView(sender, eventType, item)
    local selectItem = item
    if not selectItem then
        selectItem = self:getListViewSelectedItem(sender)
    end

    if not self.selectItem or self.selectItem ~= selectItem then
        self.selectEffect:removeFromParent()
        selectItem:addChild(self.selectEffect)
    end

    self.selectItem = selectItem

    local kid = HomeChildMgr:getKidByCid(self.kid:queryBasic("cid"))
    if SkillMgr:getSkill(kid:getId(), selectItem.skillNo) then
        -- 已拥有该技能
        self:setColorText(string.format(CHS[7100435], HomeChildMgr:getSkillDesc(selectItem.skillName)), "DescribePanel", "InfoPanel", nil, nil, nil, 19)
    else
        -- 未拥有
        self:setColorText(CHS[7100437], "DescribePanel", "InfoPanel", nil, nil, nil, 19)
    end

    local panelSize = self:getControl("DescribePanel", nil, "InfoPanel"):getContentSize()
    local scrollViewSize = self.scrollView:getContentSize()
    self.scrollView:getInnerContainer():setContentSize(cc.size(panelSize.width, panelSize.height + 10))
    self.scrollView:getInnerContainer():setPositionY(scrollViewSize.height - panelSize.height - 10)
end

function ChildSkillDlg:clearup()
    self.selectItem = nil
    self.kid = nil
end

function ChildSkillDlg:onConfirmButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

return ChildSkillDlg
