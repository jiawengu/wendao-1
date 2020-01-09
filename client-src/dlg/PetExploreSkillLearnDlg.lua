-- PetExploreSkillLearnDlg.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索小队技能学习界面

local PetExploreSkillLearnDlg = Singleton("PetExploreSkillLearnDlg", Dialog)

-- 探索技能配置
local EXPLORE_SKILL_CFG = PetExploreTeamMgr:getExploreSkillCfg()

function PetExploreSkillLearnDlg:init()
    self:bindListener("RefreshButton", self.onRefreshButton)

    self.selectImage = self:retainCtrl("ChoseImage", "SkillPanel")

    self:setNumImgForPanel("CostPanel", ART_FONT_COLOR.DEFAULT, "100", false, LOCATE_POSITION.MID, 23, "MoneyPanel")
end

-- 设置界面数据
function PetExploreSkillLearnDlg:setData(allSkillInfo, curSkillInfo)
    self.allInfo = allSkillInfo
    if curSkillInfo then
        self.curSkillId = curSkillInfo.skill_id

        self:setLabelText("Label_5", CHS[7190586], "RefreshButton")
        self:setLabelText("Label_6", CHS[7190586], "RefreshButton")
    else
        self:setLabelText("Label_5", CHS[7190585], "RefreshButton")
        self:setLabelText("Label_6", CHS[7190585], "RefreshButton")
    end

    if self.curSkillId then
        self:setCtrlVisible("MoneyPanel", true)
    else
        self:setCtrlVisible("MoneyPanel", false)
    end

    local havenSkill1 = allSkillInfo.skill_list[1]
    if havenSkill1 and curSkillInfo and havenSkill1.skill_id == curSkillInfo.skill_id then
        havenSkill1 = nil
    end

    local havenSkill2 = allSkillInfo.skill_list[2]
    if havenSkill2 and curSkillInfo and havenSkill2.skill_id == curSkillInfo.skill_id then
        havenSkill2 = nil
    end

    local function onSelectSkill(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:selectSkill(sender)
        end
    end

    local root = self:getControl("SkillPanel")
    for i = 1, 5 do
        local panel = self:getControl("ImagePanel" .. i, nil, root)
        self:setImage("FurnitureImage", EXPLORE_SKILL_CFG[i].iconPath, panel)
        panel.skill_id = i
        self:setCtrlVisible("NowImage", false, panel)
        if curSkillInfo and i == curSkillInfo.skill_id then
            self:setCtrlVisible("NowImage", true, panel)
            panel:addTouchEventListener(onSelectSkill)
            if not self.selectSkillId then self:selectSkill(panel) end
        elseif (havenSkill1 and i == havenSkill1.skill_id) or (havenSkill2 and i == havenSkill2.skill_id) then
            local image = self:getControl("FurnitureImage", nil, panel)
            gf:grayImageView(image)
        else
            panel:addTouchEventListener(onSelectSkill)
            if not self.selectSkillId then self:selectSkill(panel) end
        end
    end
end

function PetExploreSkillLearnDlg:selectSkill(panel)
    -- 选中效果
    if self.selectImage:getParent() then
        self.selectImage:removeFromParent()
    end

    panel:addChild(self.selectImage)

    self.selectSkillId = panel.skill_id

    -- 名称
    self:setLabelText("NameLabel", EXPLORE_SKILL_CFG[self.selectSkillId].name, "ExplainPanel")

    -- 描述
    self:setLabelText("DesLabel", EXPLORE_SKILL_CFG[self.selectSkillId].descrip, "ExplainPanel")
end

function PetExploreSkillLearnDlg:cleanup()
    self.selectSkillId = nil
    self.curSkillId = nil
end

function PetExploreSkillLearnDlg:onRefreshButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190529])
        return
    end

    if self.allInfo and self.allInfo.in_explore then
        gf:ShowSmallTips(CHS[7190552])
        return
    end

    if self.curSkillId and self.selectSkillId == self.curSkillId then
        gf:ShowSmallTips(CHS[7190553])
        return
    end

    if self:checkSafeLockRelease("onRefreshButton") then
        return
    end

    if self.curSkillId then
        -- 更换技能
        PetExploreTeamMgr:requestChangeSkill(self.allInfo.pet_id, self.curSkillId, self.selectSkillId)
    else
        -- 学习技能
        PetExploreTeamMgr:requestLearnSkill(self.allInfo.pet_id, self.selectSkillId)
    end
end

return PetExploreSkillLearnDlg
