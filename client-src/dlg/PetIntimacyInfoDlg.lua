-- PetIntimacyInfoDlg.lua
-- Created by 
-- 

local PetIntimacyInfoDlg = Singleton("PetIntimacyInfoDlg", Dialog)

function PetIntimacyInfoDlg:init(pet)
    self:bindListener("InfoButton", self.onInfoButton)    
    self:bindListener("IntimacyInfoPanel", self.onCloseButton)    
    self:setDataByPet(pet)
end

function PetIntimacyInfoDlg:setDataByPet(pet)

    local petRankStr = CHS[3001219]
    if pet:queryBasicInt("rank") == Const.PET_RANK_ELITE then
        petRankStr = CHS[3001220]
    elseif pet:queryBasicInt("rank") == Const.PET_RANK_EPIC then
        petRankStr = CHS[5450057]
    end
    
    self:setLabelText("Label1", string.format(CHS[4200447], petRankStr, pet:queryInt("intimacy")), "RulePanel1")      
    
    self:setLabelText("Label3", "", "RulePanel1")    
    self:setLabelText("Label4", "", "RulePanel1")    
    self:setLabelText("Label5", "", "RulePanel1")    
    
    local nextLv, curLevel = self:getIntimacyLevel(pet)
    if not nextLv then
        self:setColorText(CHS[4200448], "Panel2", "RulePanel1", nil, nil, COLOR3.WHITE, 19)
        self:setLabelText("Label3", "", "RulePanel1")    
        self:setLabelText("Label4", "", "RulePanel1")    
        self:setLabelText("Label5", "", "RulePanel1")        
    else        
        self:setColorText(string.format(CHS[4100866], nextLv), "Panel2", "RulePanel1", nil, nil, COLOR3.WHITE, 19)
    end    

    -- 设置完下一阶段亲密度后,刷新界面高度
    self:refreshDlgHeight()

    local addInfo = self:getCurAdd(curLevel, pet)
    local panel = self:getControl("RulePanel2")
    
    -- 物伤
    self:setLabelText("PhyLabel2", string.format("+ %d%%", addInfo.pow), panel)
    -- 法伤
    self:setLabelText("MagLabel2", string.format("+ %d%%", addInfo.pow), panel)
    -- 防御
    self:setLabelText("DefLabel2", string.format("+ %d%%", addInfo.def), panel)
    -- 复活率
    self:setLabelText("ReviveLabel2", string.format("+ %d%%", addInfo.revivification_rate), panel)
    -- 复活次数
    self:setLabelText("ReviveTimesLabel2", string.format("+ %d", addInfo.revivification_time), panel)
    -- 物理必杀率
    self:setLabelText("CriticalHitLabel2", string.format("+ %d%%", addInfo.stunt_rate), panel)
    -- 物理连击率
    self:setLabelText("DoubleHitLabel2", string.format("+ %d%%", addInfo.double_hit_rate), panel)
    -- 物理连击数
    self:setLabelText("DoubleHitTimesLabel2", string.format("+ %d", addInfo.double_hit_time), panel)
end

function PetIntimacyInfoDlg:getCurAdd(intimacyLv, pet)
    local intimacyCfg = PetMgr:getIntimacyCfg()
    if pet:queryBasicInt("rank") == Const.PET_RANK_ELITE then
        return intimacyCfg[CHS[3001220]][intimacyLv]
    elseif pet:queryBasicInt("rank") == Const.PET_RANK_EPIC then  
        return intimacyCfg[CHS[5450057]][intimacyLv]
    else
        return intimacyCfg[CHS[3001219]][intimacyLv]
    end
end

-- 刷新界面高度
function PetIntimacyInfoDlg:refreshDlgHeight()
    -- 亲密度部分Panel的高度
    local rulePanelSz = self:getCtrlContentSize("RulePanel1")
    local intimacyContentHeight = self:getCtrlContentSize("TitleLabel", "RulePanel1").height
        + self:getCtrlContentSize("Label1", "RulePanel1").height + self:getCtrlContentSize("Panel2", "RulePanel1").height + 10
    self:setCtrlContentSize("RulePanel1", rulePanelSz.width, intimacyContentHeight)

    -- 界面高度
    local dlgSz = self:getCtrlContentSize("IntimacyInfoPanel")
    local dlgContentHeight = self:getCtrlContentSize("RulePanel1").height
        + self:getCtrlContentSize("RulePanel2").height + self:getCtrlContentSize("RulePanel3").height
        + self:getCtrlContentSize("InfoButton").height + 15
    self:setCtrlContentSize("IntimacyInfoPanel", dlgSz.width, dlgContentHeight)
    self:setImageSize("BackImage", {width = dlgSz.width, height = dlgContentHeight})
end

function PetIntimacyInfoDlg:getIntimacyLevel(pet)
    local intimacy = pet:queryInt("intimacy")
    
    local intimacyCfg = PetMgr:getIntimacyCfg()
    local nextLevel
    local curLevel = 0
    
    
    local function getLevelByType(type, intimacy)
        local eliteCfg = intimacyCfg[type] 
        for lv, data in pairs(eliteCfg) do  
            if intimacy < lv then
                nextLevel = nextLevel or lv
                nextLevel = math.min(lv, nextLevel)
            end

            if intimacy >= lv and curLevel < lv then
                curLevel = lv
            end
        end

        return nextLevel, curLevel
    end
    
    
    if pet:queryBasicInt("rank") == Const.PET_RANK_ELITE then
        local eliteCfg = intimacyCfg[CHS[3001220]] 
        nextLevel, curLevel = getLevelByType(CHS[3001220], intimacy)
    elseif pet:queryBasicInt("rank") == Const.PET_RANK_EPIC then    
        nextLevel, curLevel = getLevelByType(CHS[5450057], intimacy) 
    else
        nextLevel, curLevel = getLevelByType(CHS[3001219], intimacy) 
    end
    
    return nextLevel, curLevel
end

function PetIntimacyInfoDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PetIntimacyRuleDlg")
    self:onCloseButton()
end

return PetIntimacyInfoDlg
