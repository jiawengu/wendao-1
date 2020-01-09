-- AnniversaryLingMaoSkillDlg.lua
-- Created by huangzz Feb/08/2018
-- 灵猫技能界面

local AnniversaryLingMaoSkillDlg = Singleton("AnniversaryLingMaoSkillDlg", Dialog)

-- 纪念宠物列表
local jinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

local bailingInfo = jinianPetList[CHS[5450106]]

function AnniversaryLingMaoSkillDlg:init(data)
    self:bindListener("ReplaceButton", self.onReplaceButton)
    self:bindListener("LearnButton", self.onLearnButton)
    self:bindListener("SkillImage", self.onSkillPanel, "NewSkillPanel")
    
    self.lingmaoInfo = data
    self.newSkill = ""
    
    -- 法攻技能
    self:setMagicSkills(data)
    
    self:setCtrlVisible("Image_2", true, "NewSkillPanel")
    
    -- 剩余次数
    self:setLabelText("LeftLearnTimeLabel", string.format(CHS[5400472], data.learn_num))
    
    self:hookMsg("MSG_ZNQ_2018_MY_LINGMAO_INFO")
    self:hookMsg("MSG_ZNQ_2018_LINGMAO_SKILLS")
    self:hookMsg("MSG_ZNQ_2018_OPER_LINGMAO")
end

-- 顿悟技能
function AnniversaryLingMaoSkillDlg:setDunWuSkills(data, hasSkills)
    local skillName = next(hasSkills)

    local panel = self:getControl('SkillImagePanel', Const.UIPanel, "DunWuSkillPanel")
    local img = self:getControl('PortraitImage', Const.UIImage, panel)
    local index = 0
    if skillName then
        img:loadTexture(SkillMgr:getSkillIconFilebyName(skillName), ccui.TextureResType.localType)
        gf:setItemImageSize(img)
        
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, (data.level or 1) * 16, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
        
        panel.name = skillName
        self.dunwuSkill = skillName
        panel:addTouchEventListener(function(sender, eventType)
            self:onSkillPanel(sender, eventType)
        end)
        
        index = 1
    else
        self.dunwuSkill = nil
        img:ignoreContentAdaptWithSize(true)
        self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.LEFT_TOP, panel)
        img:loadTexture(ResMgr.ui.add_symbol, ccui.TextureResType.plistType)
    end
    
    self:setLabelText("SkillNumLabel", index .. "/1", "DunWuSkillPanel")
end

-- 天生技能
function AnniversaryLingMaoSkillDlg:setRawSkills(data, hasSkills)
    local skills = gf:deepCopy(bailingInfo.skills) or {}
    local index = 0
    
    -- 移除翻转乾坤
    for i = #skills, 1, -1 do
        if skills[i] == CHS[3000071] then
            table.remove(skills, i)
            break
        end
    end
    
    for i = 1, 2 do
        local panel = self:getControl('SkillImagePanel_' .. i, Const.UIPanel, "RawSkillPanel")
        local img = self:getControl('PortraitImage', Const.UIImage, panel)

        if skills[i] then
            img:loadTexture(SkillMgr:getSkillIconFilebyName(skills[i]), ccui.TextureResType.localType)
            gf:setItemImageSize(img)
            
            -- 如果宠物未拥有这个技能
            if hasSkills[skills[i]] then
                gf:resetImageView(img)
                self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, (data.level or 1) * 16, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
                index = index + 1
            else
                -- 置灰
                gf:grayImageView(img)
                self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.LEFT_TOP, panel)
            end
            
            panel.name = skills[i]
            panel:addTouchEventListener(function(sender, eventType)
                self:onSkillPanel(sender, eventType)
            end)
            
            hasSkills[skills[i]] = nil
        end
    end
    
    self:setLabelText("SkillNumLabel", index .. "/2", "RawSkillPanel")
end

-- 研发技能（只有五色光环）
function AnniversaryLingMaoSkillDlg:setDevelopSkills(data, hasSkills)
    local panel = self:getControl('SkillImagePanel', Const.UIPanel, "DevelopSkillPanel")
    local img = self:getControl('PortraitImage', Const.UIImage, panel)

    img:loadTexture(SkillMgr:getSkillIconFilebyName(CHS[4000183]), ccui.TextureResType.localType)
    gf:setItemImageSize(img)
    
    -- 如果宠物未拥有这个技能
    local index = 0
    if hasSkills[CHS[4000183]] then
        gf:resetImageView(img)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, (data.level or 1) * 16, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
        index = 1
    else
        -- 置灰
        gf:grayImageView(img)
        self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.LEFT_TOP, panel)
    end

    panel.name = CHS[4000183]
    panel:addTouchEventListener(function(sender, eventType)
        self:onSkillPanel(sender, eventType)
    end)
    
    hasSkills[CHS[4000183]] = nil
    self:setLabelText("SkillNumLabel", index .. "/1", "DevelopSkillPanel")
end

-- 法攻技能
function AnniversaryLingMaoSkillDlg:setMagicSkills(data)
    local polar = bailingInfo.polar

    -- 获取宠物相性技能
    local normalSkills = SkillMgr:getSkillsByPolarAndSubclass(gf:getIntPolar(polar), SKILL.SUBCLASS_B)
    if nil == normalSkills then return end

    local index = 0
    for i = 1, #normalSkills do
        if (SKILL.LADDER_1 == normalSkills[i].ladder or
            SKILL.LADDER_2 == normalSkills[i].ladder or
            SKILL.LADDER_4 == normalSkills[i].ladder) then
            index = index + 1
            
            local panel = self:getControl('SkillImagePanel_' .. index, Const.UIPanel, "MagicSkillPanel")
            local img = self:getControl('PortraitImage', Const.UIImage, panel)

            -- 获取技能图标
            local skillIconPath = SkillMgr:getSkillIconPath(normalSkills[i].no)
            if nil == skillIconPath then return end

            -- 设置技能图标
            self:setImage("PortraitImage", skillIconPath, panel)
            self:setItemImageSize("PortraitImage", panel)
            
            if data.level ~= 0 then
                gf:resetImageView(img)
                self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, (data.level or 1) * 16, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
            else
                -- 置灰
                gf:grayImageView(img)
            end
            
            panel.name = normalSkills[i].name
            panel:addTouchEventListener(function(sender, eventType)
                self:onSkillPanel(sender, eventType)
            end)
        end
    end
    
    if data.level == 0 then
        index = 0
    end
    
    self:setLabelText("SkillNumLabel", index .. "/3", "MagicSkillPanel")
end

function AnniversaryLingMaoSkillDlg:onSkillPanel(sender, eventType)
    local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setSKillByName(sender.name, rect, true)
end

function AnniversaryLingMaoSkillDlg:onReplaceButton(sender, eventType)
    if self.newSkill == "" then
        self:setCtrlVisible("ReplaceButton", false)
        return
    end
    
    gf:confirm(string.format(CHS[5420280], self.newSkill, self.dunwuSkill), function()
        gf:CmdToServer("CMD_ZNQ_2018_REPLACE_SKILL", {})
    end)
end

function AnniversaryLingMaoSkillDlg:onLearnButton(sender, eventType)
    if not self.lingmaoInfo then
        return
    end

    -- 若玩家当前处于禁闭状态，予以如下弹出提示：
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若当前宠物学习次数不足，则予以如下弹出提示：
    if self.lingmaoInfo.level < 12 and self.lingmaoInfo.learn_num == 0 then
        gf:ShowSmallTips(CHS[5400471])
        return
    end
     
    if self.newSkill ~= "" then
        gf:confirm(string.format(CHS[5420281], self.newSkill), function()
            AnniversaryMgr:requestOperateLingMao("dunwu_skill")
        end)
    else
        AnniversaryMgr:requestOperateLingMao("dunwu_skill")
    end
end

function AnniversaryLingMaoSkillDlg:MSG_ZNQ_2018_LINGMAO_SKILLS(data)
    local skills = gf:deepCopy(data.skills)

    -- 天生技能
    self:setRawSkills(self.lingmaoInfo, skills)

    -- 研发技能
    self:setDevelopSkills(self.lingmaoInfo, skills)

    -- 顿悟技能
    self:setDunWuSkills(self.lingmaoInfo, skills)
    
    if data.newSkill ~= "" then
        -- 有可替换的技能
        self:setCtrlVisible("ReplaceButton", true)
        self:setCtrlVisible("Image_2", false, "NewSkillPanel")
        local img = self:getControl('SkillImage', Const.UIImage, "NewSkillPanel")
        img:setVisible(true)
        img:loadTexture(SkillMgr:getSkillIconFilebyName(data.newSkill), ccui.TextureResType.localType)
        img.name = data.newSkill
        self.newSkill = data.newSkill
    else
        self:setCtrlVisible("Image_2", true, "NewSkillPanel")
        self:setCtrlVisible("ReplaceButton", false)
        local img = self:getControl('SkillImage', Const.UIImage, "NewSkillPanel")
        img:setVisible(false)
        img.name = nil
        self.newSkill = ""
    end 
    
    self.skills = data.skills
    
    self.hasForgetSkill = nil
    self.hasDunWuSkill = nil
end

function AnniversaryLingMaoSkillDlg:MSG_ZNQ_2018_MY_LINGMAO_INFO(data)
    self.lingmaoInfo = data
    
    -- 剩余次数
    self:setLabelText("LeftLearnTimeLabel", string.format(CHS[5400472], data.learn_num))
    
    if data.status ~= 1 then
        self:onCloseButton()
    end
end

-- 通知客户端操作灵猫成功（forget_skill:遗忘技能，dunwu_skill:顿悟技能，scratch:抚摸，feed:喂食）
function AnniversaryLingMaoSkillDlg:MSG_ZNQ_2018_OPER_LINGMAO(data)
    if data.oper == "forget_skill" then
        self.hasForgetSkill = true
    elseif data.oper == "dunwu_skill" then
        self.hasDunWuSkill = true
    end
end

return AnniversaryLingMaoSkillDlg
