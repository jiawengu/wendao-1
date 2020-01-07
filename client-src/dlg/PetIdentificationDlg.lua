-- PetIdentificationDlg.lua
-- Created by huangzz Jan/12/2017
-- 宠物标识说明悬浮框

local PetIdentificationDlg = Singleton("PetIdentificationDlg", Dialog)

local ORIGIN_MAX = 7

function PetIdentificationDlg:init()
    self:bindListener("PetLogoAttributePanel", self.onCloseButton)
end

function PetIdentificationDlg:setData(pet)
    if not pet then
        return
    end
    
    local logoPath = {}
    
    -- 相性 
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    table.insert(logoPath, {path = polarPath, pList = 1, desc = CHS[5410020] .. polar})
    
    -- 点化
    if pet:queryBasicInt("enchant") == 2 then 
        table.insert(logoPath, {path = ResMgr.ui.dianhua_logo, pList = 0, desc = CHS[5410021]}) 
    end

    -- 羽化
    if PetMgr:isYuhuaCompleted(pet) then
        table.insert(logoPath, {path = ResMgr.ui.yuhua_logo, pList = 0, desc = CHS[4100993]})
    end

    -- 幻化
    if PetMgr:isMorphed(pet) then 
        table.insert(logoPath, {path = ResMgr.ui.huanhua_logo, pList = 0, desc = string.format(CHS[5410022], self:getMorphedCount(pet))}) 
    end
    
    -- 飞升
    if PetMgr:isFlyPet(pet) then
        table.insert(logoPath, {path = ResMgr.ui.fly_logo, pList = 0, desc = CHS[7002288]})
    end
    
    -- 风灵丸
    local day = PetMgr:getFenghuaDay(pet)
    if day > 0 then
        table.insert(logoPath, {path = ResMgr.ui.fenghua_logo, pList = 0, desc = string.format(CHS[5410023], day)}) 
    end

    -- 贵重
    if gf:isExpensive(pet, true) then
        table.insert(logoPath, {path = ResMgr.ui.expensive_logo, pList = 0, desc = CHS[5410024]})
    end
    
    for i = 1, #logoPath do
        if logoPath[i].pList == 1 then
            self:setImagePlist("logoImage", logoPath[i].path, "EntryPanel" .. i)
        else
            self:setImage("logoImage", logoPath[i].path, "EntryPanel" .. i)
        end
        
        self:setLabelText("AttributeLabel", logoPath[i].desc, "EntryPanel" .. i)
    end
    
    for i = #logoPath + 1, ORIGIN_MAX do
        local entryPanel = self:getControl("EntryPanel" .. i)
        entryPanel:removeFromParent()
    end
    
    local height = self.root:getContentSize().height - (ORIGIN_MAX - #logoPath) * 31
    
    local contentWidth = self.root:getContentSize().width
    local panel = self:getControl("BackImage")
    local mainPanel = self:getControl("MainPanel")
    self.root:setContentSize(contentWidth, height)
    mainPanel:setContentSize(contentWidth, height)
    panel:setContentSize(contentWidth, height)
    self:getControl("PetLogoAttributePanel"):setContentSize(contentWidth, height)

    self.root:requestDoLayout()
end

-- 获取宠物被幻化的总次数
function PetIdentificationDlg:getMorphedCount(pet)
    local field = {"life", "mana", "speed", "phy", "mag"}
    local count = 0
    for _, att in pairs(field) do
        local fieldTimes = string.format("morph_%s_times", att)
        count = count + pet:queryBasicInt(fieldTimes)
    end

    return count
end

return PetIdentificationDlg
