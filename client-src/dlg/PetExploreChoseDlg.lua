-- PetExploreChoseDlg.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索小队选择宠物界面

local PetExploreChoseDlg = Singleton("PetExploreChoseDlg", Dialog)

-- 探索技能配置
local EXPLORE_SKILL_CFG = PetExploreTeamMgr:getExploreSkillCfg()

function PetExploreChoseDlg:init()
    self.selectEffect = self:retainCtrl("ChosenEffectImage")
    self.itemPanel = self:retainCtrl("PetPanel")
    self.listView = self:getControl("PetListView")
end

function PetExploreChoseDlg:setData(list, index)
    self.index = index
    self.listView:removeAllItems()

    for i = 1, #list do
        local item = self.itemPanel:clone()
        self:setSingleItemInfo(item, list[i])
        self.listView:pushBackCustomItem(item)
    end
end

function PetExploreChoseDlg:setSingleItemInfo(item, pet)
    local petId = pet:getId()

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), item)

    -- 名字
    local nameLabel = self:getControl("NameLabel", nil, item)
    nameLabel:setString(pet:getShowName())

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, pet:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP, 25, item)

    -- 相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    self:setImagePlist("Image", ResMgr:getPolarImagePath(polar), item)

    -- 技能信息
    self:setCtrlVisible("SkillImage1", false, item)
    self:setCtrlVisible("LevelLabel1", false, item)
    self:setCtrlVisible("SkillImage2", false, item)
    self:setCtrlVisible("LevelLabel2", false, item)
    local skillInfo = PetExploreTeamMgr:getPetSkillInfo(petId)
    if skillInfo then
        local count = #skillInfo
        if count >= 1 then
            self:setCtrlVisible("SkillImage1", true, item)
            self:setCtrlVisible("LevelLabel1", true, item)
            self:setImage("SkillImage1", EXPLORE_SKILL_CFG[skillInfo[1].skill_id].iconPath, item)
            self:setLabelText("LevelLabel1", skillInfo[1].skill_level, item)
        end

        if count >= 2 then
            self:setCtrlVisible("SkillImage2", true, item)
            self:setCtrlVisible("LevelLabel2", true, item)
            self:setImage("SkillImage2", EXPLORE_SKILL_CFG[skillInfo[2].skill_id].iconPath, item)
            self:setLabelText("LevelLabel2", skillInfo[2].skill_level, item)
        end
    end

    -- 探索中
    if PetExploreTeamMgr:isPetInExplore(petId) then
        self:setCtrlVisible("DoingImage", true, item)
    else
        self:setCtrlVisible("DoingImage", false, item)
    end

    item.pet = pet

    local function onSelectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:selectPet(sender.pet:getId())
        end
    end

    item:addTouchEventListener(onSelectPet)

    -- 点击头像，打开宠物名片
    local shapePanel = self:getControl("ShapePanel", nil, item)
    local function onShapePanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local dlg =  DlgMgr:openDlg("PetCardDlg")
            dlg:setPetInfo(pet, true)
        end
    end

    shapePanel:addTouchEventListener(onShapePanel)
end

function PetExploreChoseDlg:selectPet(petId)
    if PetExploreTeamMgr:isPetInExplore(petId) then
        gf:ShowSmallTips(CHS[7100331])
        return
    end

    local dlg = DlgMgr.dlgs["PetExploreTeamDlg"]
    if dlg then
        dlg:changePet(self.index, petId)
        self:onCloseButton()
    end
end

return PetExploreChoseDlg
