-- ArtifactListDlg.lua
-- Created by yangym Dec/23/2016
-- 法宝列表界面

local ArtifactListDlg = Singleton("ArtifactListDlg", Dialog)


function ArtifactListDlg:init()
    self.selectArtifact = nil
    
    self.artifactPanel = self:getControl("ArtifactPanel", Const.UIPanel)
    self.artifactPanel:retain()
    self.artifactPanel:removeFromParent()
    
    self.listView = self:getControl("ArtifactListView")
    
    self:initArtifactList()
    
    self:hookMsg("MSG_INVENTORY")
end

function ArtifactListDlg:initArtifactList()
    self.listView:removeAllChildren()
    self:setCtrlVisible("NonePanel", false)
    local artifactsInfo = EquipmentMgr:getAllArtifacts()
    if #artifactsInfo == 0 then
        self:setCtrlVisible("NonePanel", true)
        return
    end
    
    for i = 1, #artifactsInfo do
        local artifact = artifactsInfo[i]
        local cell = self.artifactPanel:clone()
        cell:setTag(artifact.pos)
        self:setCellInfo(cell, artifact)
        
        local function func(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local tag = sender:getTag()
                self:onSelectArtifact(tag)
            end
        end
        
        cell:addTouchEventListener(func)
        self.listView:pushBackCustomItem(cell)
    end
    
    -- 默认选择第一个法宝
    if not self.selectArtifact or self.selectArtifact.item_type ~= ITEM_TYPE.ARTIFACT then
        local cell = self.listView:getItem(0)
        self:onSelectArtifact(cell:getTag())
    else
        self:onSelectArtifact(self.selectArtifact.pos)
    end
end

function ArtifactListDlg:onSelectArtifact(tag)
    for k, v in pairs(self.listView:getChildren()) do
        self:setCtrlVisible("ChosenEffectImage", false, v)
    end
    
    local selectItem = self.listView:getChildByTag(tag)
    self:setCtrlVisible("ChosenEffectImage", true, selectItem)
    
    self.selectArtifact = InventoryMgr:getItemByPos(tag)
    DlgMgr:sendMsg("ArtifactRefineDlg", "setArtifactInfo", self.selectArtifact)
    DlgMgr:sendMsg("ArtifactSkillUpDlg", "setArtifactInfo", self.selectArtifact)
end

function ArtifactListDlg:setCellInfo(cell, artifact)
    if not artifact then
        return
    end
    
    local isEquippedArtifact = false
    if artifact.pos then
        if artifact.pos == EQUIP.ARTIFACT or artifact.pos == EQUIP.BACK_ARTIFACT then
            isEquippedArtifact = true
        end
    end
    
    -- 已装备标签
    self:setCtrlVisible("StatusImage", isEquippedArtifact, cell)

    -- 法宝图标
    self:setImage("GuardImage", InventoryMgr:getIconFileByName(artifact.name), cell)
    self:setItemImageSize("GuardImage", cell)

    -- 图标左上角等级
    self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT,
        artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
        
    -- 图标右下角相性标志
    local img = self:getControl("GuardImage", nil, cell)
    if artifact.item_polar then
        InventoryMgr:addArtifactPolarImage(img, artifact.item_polar)
    end
    
    -- 图标左下角限制交易/限时标记
    if InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:addLogoTimeLimit(img)
    elseif InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:addLogoBinding(img)
    end
    
    -- 法宝名称
    if isEquippedArtifact then
        self:setLabelText("NameLabel", artifact.name, cell, COLOR3.GREEN)
    else
        self:setLabelText("NameLabel", artifact.name, cell)
    end
    
    -- 法宝特殊技能名称与等级
    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if artifactSpSkillName then
        local artifactSpSkillLevel = tonumber(artifact.extra_skill_level)
        self:setLabelText("SkillNameLabel", artifactSpSkillName, cell)
        self:setLabelText("SkillLevelLabel", string.format(CHS[2000131], artifactSpSkillLevel), cell)
    else
        self:setLabelText("SkillNameLabel", CHS[7000329], cell, COLOR3.GRAY)
    end
end

function ArtifactListDlg:MSG_INVENTORY(data)
    self:initArtifactList()
end

function ArtifactListDlg:cleanup()
    self.selectArtifact = nil
    
    self:releaseCloneCtrl("artifactPanel")
end

return ArtifactListDlg
