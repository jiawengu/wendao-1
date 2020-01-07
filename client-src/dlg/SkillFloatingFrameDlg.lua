-- SkillFloatingFrameDlg.lua
-- Created by songcw Jan/4/2015
-- 技能悬浮对话框

local FONTSIZE  = 20
local DLG_SIZE  = 160
local DUNWU_SKILL_NIMBUS_COST = 50

local SkillFloatingFrameDlg = Singleton("SkillFloatingFrameDlg", Dialog)

function SkillFloatingFrameDlg:init()
    self:align(ccui.RelativeAlign.centerInParent)
    self:bindListener("SkillFloatingFrameDlg", self.onCloseButton)
    self.root:setAnchorPoint(0,0)
end

function SkillFloatingFrameDlg:setInfo(skillName, id, isPet, rect, DlgType, pet, notShowLimitLv)

    -- 技能名称和等级
    local skillInfo = {}
   
    local skill = SkillMgr:getskillAttribByName(skillName)
    skillInfo = SkillMgr:getSkill(id, skill.skill_no)
    
    if not skillInfo and pet then
        local skills = pet:queryBasic("skills")
        if type(skills) == "table" then 
            skill = SkillMgr:getskillAttribByName(skillName)

            for k, v in pairs(skills) do
                if v.skill_no == skill.skill_no then
                    skillInfo = v
                    break
                end 
            end
        end
    end
    
    -- 还未学得该技能
    if not skillInfo then
        skillInfo = {}
        skillInfo.skill_level = 0
        skillInfo.range = 0
    end
    
    -- 战斗下需要对技能消耗不足的那一行标红处理,其他情况不需要
    
    -- 顿悟技能的消耗信息补充：如果是进阶技能，格式为消耗怒气+消耗灵气；如果非进阶技能，格式为消耗法力+消耗灵气。
    local dunWuSkillsDesc
    local dunWuSkillsDescWithoutRed
    local myPet = PetMgr:getPetById(id)
    if myPet and SkillMgr:isPetDunWuSkill(id, skillName) then -- 是否是宠物的顿悟技能
        dunWuSkillsDesc = ""
        dunWuSkillsDescWithoutRed = ""        
        local skillDescTemp = SkillMgr:getSkillDesc(skillName).tips
        if isPet then
            skillDescTemp = SkillMgr:getSkillDesc(skillName).pet_tips or SkillMgr:getSkillDesc(skillName).tips
        end        
        
        dunWuSkillsDesc = dunWuSkillsDesc .. string.format(CHS[7000252], skillDescTemp, skillInfo.range)
        dunWuSkillsDescWithoutRed = dunWuSkillsDesc
        
        if SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.JINJIE then
            --消耗怒气
            local costAngerStr
            local costAnger = Formula:getCostAnger(skillInfo.skill_level)
            local angerNotEnoughStr = "#R" .. string.format(CHS[7000254], costAnger) .. "#n\n \n"
            local angerEnoughStr = string.format(CHS[7000254], costAnger) .. "\n \n"
            if myPet:queryBasicInt("pet_anger") < costAnger then
                costAngerStr = angerNotEnoughStr
            else
                costAngerStr = angerEnoughStr
            end
            
            dunWuSkillsDesc = dunWuSkillsDesc .. costAngerStr
            dunWuSkillsDescWithoutRed = dunWuSkillsDescWithoutRed .. angerEnoughStr
        else
            --消耗法力
            local costManaStr
            local manaNotEnoughStr = "#R" .. string.format(CHS[7000253], skillInfo.skill_mana_cost) .. "#n\n \n"
            local manaEnoughStr = string.format(CHS[7000253], skillInfo.skill_mana_cost) .. "\n \n"
            if myPet:queryInt("mana") < skillInfo.skill_mana_cost then
                costManaStr = manaNotEnoughStr
            else
                costManaStr = manaEnoughStr
            end
            
            dunWuSkillsDesc = dunWuSkillsDesc .. costManaStr
            dunWuSkillsDescWithoutRed = dunWuSkillsDescWithoutRed .. manaEnoughStr
        end
        
        -- 消耗灵气
        local costNimbusStr
        local nimbusNotEnoughStr = "#R" .. string.format(CHS[7000255], DUNWU_SKILL_NIMBUS_COST) .. "#n"
        local nimbusEnoughStr = string.format(CHS[7000255], DUNWU_SKILL_NIMBUS_COST)
        if skillInfo.skill_nimbus < DUNWU_SKILL_NIMBUS_COST then
            costNimbusStr = nimbusNotEnoughStr
        else
            costNimbusStr = nimbusEnoughStr
        end
        
        dunWuSkillsDesc = dunWuSkillsDesc .. costNimbusStr
        dunWuSkillsDescWithoutRed = dunWuSkillsDescWithoutRed .. nimbusEnoughStr
    end
    skillInfo.dunWuSkillsDesc = dunWuSkillsDesc
    skillInfo.dunWuSkillsDescWithoutRed = dunWuSkillsDescWithoutRed
    
    -- 法宝特殊技能消耗信息补充
    local artifactSpSkillDesc
    local artifactSpSkillDescWithoutRed
    if SkillMgr:isArtifactSpSkill(skillName) then
        artifactSpSkillDesc = ""
        artifactSpSkillDescWithoutRed = ""
        artifactSpSkillDesc = artifactSpSkillDesc .. string.format(CHS[7000252], SkillMgr:getSkillDesc(skillName).desc, skillInfo.range)
        artifactSpSkillDescWithoutRed = artifactSpSkillDesc
        
        -- 消耗法宝灵气
        local costNimbusStr
        local costNimbus = SkillMgr:getArtifactSpSkillCostNimbus(skillName)
        local nimbusNotEnoughStr = "#R" .. string.format(CHS[7000312], costNimbus) .. "#n"
        local nimbusEnoughStr = string.format(CHS[7000312], costNimbus)
        
        local nowNimbus = 0
        local artifact = EquipmentMgr:getEquippedArtifact()
        if artifact then
            nowNimbus = artifact.nimbus
        end
        
        if nowNimbus < costNimbus then
            costNimbusStr = nimbusNotEnoughStr
        else
            costNimbusStr = nimbusEnoughStr
        end
        
        artifactSpSkillDesc = artifactSpSkillDesc .. costNimbusStr
        artifactSpSkillDescWithoutRed = artifactSpSkillDescWithoutRed .. nimbusEnoughStr
    end
    skillInfo.artifactSpSkillDesc = artifactSpSkillDesc
    skillInfo.artifactSpSkillDescWithoutRed = artifactSpSkillDescWithoutRed
    
    -- 亲密无间复制技能信息补充
    local qmwjCopySkillDesc
    local qmwjCopySkillDescWithoutRed
    if SkillMgr:isQinMiWuJianCopySkill(skillName, id) then
        qmwjCopySkillDesc = ""
        qmwjCopySkillDescWithoutRed = ""
        qmwjCopySkillDesc = qmwjCopySkillDesc .. string.format(CHS[7000252], SkillMgr:getSkillDesc(skillName).tips, skillInfo.range)
        qmwjCopySkillDescWithoutRed = qmwjCopySkillDesc
        
        -- 消耗法力
        local costManaStr
        local manaNotEnoughStr = "#R" .. string.format(CHS[7000253], skillInfo.skill_mana_cost) .. "#n\n \n"
        local manaEnoughStr = string.format(CHS[7000253], skillInfo.skill_mana_cost) .. "\n \n"
        if Me:queryInt("mana") < skillInfo.skill_mana_cost then
            costManaStr = manaNotEnoughStr
        else
            costManaStr = manaEnoughStr
        end
        
        qmwjCopySkillDesc = qmwjCopySkillDesc .. costManaStr
        qmwjCopySkillDescWithoutRed = qmwjCopySkillDescWithoutRed .. manaEnoughStr
        
        -- 消耗法宝灵气 
        local costNimbusStr
        local costNimbus = SkillMgr:getArtifactSpSkillCostNimbus(CHS[3001947])
        local nimbusNotEnoughStr = "#R" .. string.format(CHS[7000312], costNimbus) .. "#n"
        local nimbusEnoughStr = string.format(CHS[7000312], costNimbus)

        local nowNimbus = 0
        local artifact = EquipmentMgr:getEquippedArtifact()
        if artifact then
            nowNimbus = artifact.nimbus
        end

        if nowNimbus < costNimbus then
            costNimbusStr = nimbusNotEnoughStr
        else
            costNimbusStr = nimbusEnoughStr
        end
        
        qmwjCopySkillDesc = qmwjCopySkillDesc .. costNimbusStr
        qmwjCopySkillDescWithoutRed = qmwjCopySkillDescWithoutRed .. nimbusEnoughStr
    end
    skillInfo.qmwjCopySkillDesc = qmwjCopySkillDesc
    skillInfo.qmwjCopySkillDescWithoutRed = qmwjCopySkillDescWithoutRed
    
    SkillFloatingFrameDlg:setSkillBySKill(skillInfo, skillName, id, isPet, rect, DlgType, pet, notShowLimitLv)
end


function SkillFloatingFrameDlg:setSkillBySKill(skillInfo, skillName, id, isPet, rect, DlgType, pet, notShowLimitLv)
    -- 头像
    self:setImage("SkillImage", SkillMgr:getSkillIconFilebyName(skillName))
    self:getControl("SkillImage"):removeAllChildren()
    
    local isGodbookSkill, level = self:isPetGodbookSkill(skillName, pet)
    
    if notShowLimitLv or (id ~= 0 and skillInfo.skill_level ~= 0) or (pet and not isGodbookSkill) then    
        self:setLabelText("SkillNameLabel", skillName)
        if not notShowLimitLv then
            self:setNumImgForPanel("SkillBackPanel", ART_FONT_COLOR.NORMAL_TEXT, skillInfo.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19)
        end    
    else
        local limitLv = SkillMgr:getPetSkillLimits(skillName)
        
        if limitLv then
            local skillNameDesc = skillName .. "(" .. limitLv .. CHS[3003647] 
            self:setLabelText("SkillNameLabel", skillNameDesc)
        else            
            if isGodbookSkill and level then
                -- 若为天书技能
                self:setLabelText("SkillNameLabel", skillName)
                self:setNumImgForPanel("SkillImage", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 19) 
            else
                self:setLabelText("SkillNameLabel", skillName)
            end
        end
    end

    -- 技能简介
    if isPet then
        self:setLabelText("SkillIntroLabel", SkillMgr:getSkillDesc(skillName).pet_type or SkillMgr:getSkillDesc(skillName).type or "")
    else
        self:setLabelText("SkillIntroLabel", SkillMgr:getSkillDesc(skillName).type or "")
    end

    local skillDescTemp = SkillMgr:getSkillDesc(skillName).tips
    if isPet then
        skillDescTemp = SkillMgr:getSkillDesc(skillName).pet_tips or SkillMgr:getSkillDesc(skillName).tips
    end

    -- 技能描述
    local str
    if skillInfo.dunWuSkillsDesc and 1 ~= DlgType then
        -- 宠物顿悟技能
        if 2 == DlgType then  
            -- 战斗下技能施放资源不足，资源不足的那一项需要标红
            str = skillInfo.dunWuSkillsDesc
        else
            str = skillInfo.dunWuSkillsDescWithoutRed
        end
    elseif skillInfo.artifactSpSkillDesc and 1 ~= DlgType then
        -- 法宝特殊技能
        if 2 == DlgType then
            str = skillInfo.artifactSpSkillDesc
        else
            str = skillInfo.artifactSpSkillDescWithoutRed
        end
    elseif skillInfo.qmwjCopySkillDesc and 1 ~= DlgType then
        -- 亲密无间复制技能
        if 2 == DlgType then
            str = skillInfo.qmwjCopySkillDesc
        else
            str = skillInfo.qmwjCopySkillDescWithoutRed
        end
    elseif (id ~= 0 and skillInfo.range ~= 0) then
        if nil ~= DlgType then
            if 1 == DlgType then
                str = string.format(CHS[5000027], skillDescTemp, skillInfo.range)
            elseif 2 == DlgType then
                str = string.format(CHS[3003648], 
                    skillDescTemp, 
                        skillInfo.range, skillInfo.skill_mana_cost)
            end
        else
            str = string.format(CHS[4000002], skillDescTemp, skillInfo.range, skillInfo.skill_mana_cost)
        end
    else
        str = skillDescTemp
    end
       
    local panel = self:getControl("DescriptPanel") 
    panel:removeAllChildren()
    local height1 = self:createLabelTextReturnHeight(str, panel)    
    local dlgSize = self.root:getContentSize()    
    self.root:setContentSize(dlgSize.width, DLG_SIZE + height1)

    -- 设置对话框悬浮区域
    self:setFloatingFramePos(rect) 
end


-- 通过名字设置攻击和防御...（自动战斗中的悬浮框）
function SkillFloatingFrameDlg:setSKillByName(skillName, rect, isPet, skillDes)
    -- 图片
    self:setImage("SkillImage", SkillMgr:getSkillIconFilebyName(skillName))
    
    -- 名字
    self:setLabelText("SkillNameLabel", skillName)
    
    -- 简介
    self:setLabelText("SkillIntroLabel", SkillMgr:getSkillDesc(skillName).type)
    
    -- 技能描述
    local str = SkillMgr:getSkillDesc(skillName).tips
    if isPet then
        str = SkillMgr:getSkillDesc(skillName).pet_tips or SkillMgr:getSkillDesc(skillName).tips
    end
    
    local panel = self:getControl("DescriptPanel") 
    panel:removeAllChildren()
    local height1 = self:createLabelTextReturnHeight(skillDes or str, panel)    
    local dlgSize = self.root:getContentSize()    
    self.root:setContentSize(dlgSize.width, DLG_SIZE + height1)

    -- 设置对话框悬浮区域
    self:setFloatingFramePos(rect) 
    
end

-- 自动换行
function SkillFloatingFrameDlg:createLabelTextReturnHeight(str, node)
    local size = node:getContentSize(); 
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(FONTSIZE)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:updateNow()
    
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0,textH)
    node:setContentSize(size.width, textH)
    node:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    return textH
end

-- 判断当前技能名是否为宠物的天书技能
function SkillFloatingFrameDlg:isPetGodbookSkill(skillName, pet)
    local pet = DlgMgr:sendMsg("PetListChildDlg", "getCurrentPet") or pet
    
    if not pet or not skillName then return false end
    
    local godBookCount = pet:queryBasicInt('god_book_skill_count')
    local skills = {}
    
    for i = 1, godBookCount do
        -- 获取天书技能的各个属性
        local nameKey = 'god_book_skill_name_' .. i
        local levelKey = 'god_book_skill_level_' .. i
        local powerKey = 'god_book_skill_power_' .. i
        local name = pet:queryBasic(nameKey)
        local level = pet:queryBasic(levelKey)
        local power = pet:queryBasic(powerKey)

        if name == skillName then
            return true, level
        end
    end
    
    return false
end

-- 设置天书灵气
function SkillFloatingFrameDlg:setGodbookPower(skillName, pet)
    local nGodBookCount = pet:queryBasicInt('god_book_skill_count')

    for i = 1, nGodBookCount do
        -- 获取天书技能的各个属性
        local nameKey = pet:queryBasic("god_book_skill_name_" .. i)
        local powerKey = pet:queryBasic("god_book_skill_power_" .. i)

        if nameKey == skillName then
            self:setLabelText("SkillIntroLabel", CHS[3004106] .. powerKey)
        end
    end
end

return SkillFloatingFrameDlg
