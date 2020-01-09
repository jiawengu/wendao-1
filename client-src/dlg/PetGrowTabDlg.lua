-- PetGrowTabDlg.lua
-- Created by yangym May/16/2017
-- 宠物成长列表

local TabDlg = require('dlg/TabDlg')
local PetGrowTabDlg = Singleton("PetGrowTabDlg", TabDlg)

PetGrowTabDlg.defDlg = "PetGrowPandectDlg"

PetGrowTabDlg.dlgs = {
    PandectDlgCheckBox = "PetGrowPandectDlg",
    GrowingDlgCheckBox = "PetGrowingDlg",
    DevelopDlgCheckBox = "PetDevelopDlg",
    DianHuaDlgCheckBox = "PetDianhuaDlg",
    YuHuaDlgCheckBox = "PetYuhuaDlg",
    EvolveDlgCheckBox = "PetEvolveDlg",
    HuanHuaDlgCheckBox = "PetHuanHuaDlg",
}

PetGrowTabDlg.orderList = {
    ["PandectDlgCheckBox"]     = 1,
    ["GrowingDlgCheckBox"]     = 2,
    ["DevelopDlgCheckBox"]     = 3,
    ["DianHuaDlgCheckBox"]     = 4,
    ["YuHuaDlgCheckBox"]     = 5,
    ["EvolveDlgCheckBox"]      = 6,
    ["HuanHuaDlgCheckBox"]      = 7,
}

function PetGrowTabDlg:init()
    TabDlg.init(self)
    
    -- 记录初始位置
    if not self.checkBoxPosY then
        self.checkBoxPosY = {}
        for checkName, value in pairs(PetGrowTabDlg.orderList) do
            self.checkBoxPosY[value] = self:getControl(checkName):getPositionY()
        end
    end 
    
    local pet = PetMgr:getLastSelectPet()
    if pet then
        self:refreshButtons(pet)
    end
end

function PetGrowTabDlg:addMagicForYuHua()    
    local btn = self:getControl("YuHuaDlgCheckBox")
    local effect = btn:getChildByTag(ResMgr.magic.yuhua_btn)
    if not effect then    
        local magic = gf:createLoopMagic(ResMgr.magic.yuhua_btn)
        
        magic:setPosition(-14, btn:getContentSize().height + 21)
        magic:setTag(ResMgr.magic.yuhua_btn)
        btn:addChild(magic)
    end
end

-- keepCheckbox 需要保留的
function PetGrowTabDlg:refreshButtons(pet, keepCheckbox)
    local showCheckBos = {}
    local rank = pet:queryBasicInt("rank")

    -- 总览
    table.insert(showCheckBos, "PandectDlgCheckBox")

    -- 洗宠按钮，变异、神兽不显示
    if (rank ~= Const.PET_RANK_ELITE and rank ~= Const.PET_RANK_EPIC) or keepCheckbox == "GrowingDlgCheckBox" then
        table.insert(showCheckBos, "GrowingDlgCheckBox")
    end

    -- 强化按钮，变异、神兽不显示
    if (rank ~= Const.PET_RANK_ELITE and rank ~= Const.PET_RANK_EPIC) or keepCheckbox == "DevelopDlgCheckBox" then
        table.insert(showCheckBos, "DevelopDlgCheckBox")
    end

    -- 点化按钮，点化完成后不显示
    if not PetMgr:isDianhuaOK(pet) or keepCheckbox == "DianHuaDlgCheckBox" then
        table.insert(showCheckBos, "DianHuaDlgCheckBox")
    end  

    -- 羽化按钮，点化完成前不显示，羽化完成后显示
    if (PetMgr:isDianhuaOK(pet) and not PetMgr:isYuhuaCompleted(pet)) or keepCheckbox == "YuHuaDlgCheckBox" then
        table.insert(showCheckBos, "YuHuaDlgCheckBox")
    end


    -- 进化，变异、神兽不显示
    if (rank ~= Const.PET_RANK_ELITE and rank ~= Const.PET_RANK_EPIC) or keepCheckbox == "EvolveDlgCheckBox" then
        table.insert(showCheckBos, "EvolveDlgCheckBox")
    end

    -- 幻化，幻化完成后不显示
    if not PetMgr:isHuanhuaCompleted(pet) or keepCheckbox == "HuanHuaDlgCheckBox" then
        table.insert(showCheckBos, "HuanHuaDlgCheckBox")
    end

    -- 将所有隐藏
    for checkName, value in pairs(PetGrowTabDlg.orderList) do
        self:setCtrlVisible(checkName, false)            
    end

    -- 设置按钮位置
    for i, checkName in pairs(showCheckBos) do
        local ctl = self:getControl(checkName)
        ctl:setVisible(true)
        ctl:setPositionY(self.checkBoxPosY[i])
    end

    self:updateLayout("SwitchPanel")
end

-- 点化完成回调
function PetGrowTabDlg:compeledDianhuaCallback(pet)
    self:refreshButtons(pet, "DianHuaDlgCheckBox")
   self:addMagicForYuHua()
--    self:onSelected(self:getControl("PandectDlgCheckBox"), 1)
end

function PetGrowTabDlg:onSelected(sender, idx)

    local effect = sender:getChildByTag(ResMgr.magic.yuhua_btn)
    if effect then
        effect:removeFromParent()
    end

    -- 点击列表项之后需要判断该宠物是否满足打开该界面的条件
    if not self:canOpenDlg(sender:getName()) then
        self:setSelectDlg(self.lastDlg)
        return
    end
    
    TabDlg.onSelected(self, sender, idx)
end

function PetGrowTabDlg:canOpenDlg(checkBoxName)
    local pet = PetMgr:getLastSelectPet()
    if not pet then
        return false
    end
    
    if checkBoxName == "GrowingDlgCheckBox" then
        local rank = pet:queryInt("rank")
        if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
            -- 当前宠物为变异（、神兽、元灵）宠物，无法进行成长洗炼。
            gf:ShowSmallTips(string.format(CHS[7002301], gf:getPetRankDesc(pet)))
            return false
        end
    elseif checkBoxName == "DevelopDlgCheckBox" then
        local rank = pet:queryInt("rank")
        if rank == Const.PET_RANK_WILD then
            -- 野生宠物不可强化
            gf:ShowSmallTips(CHS[3004092])
            return false
        end

        if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
            -- 变异、神兽宠物无需强化
            gf:ShowSmallTips(CHS[5300007]) 
            return false
        end
    elseif checkBoxName == "DianHuaDlgCheckBox" then
        if pet:queryInt("rank") == Const.PET_RANK_WILD then
            -- 野生宠物不可点化
            gf:ShowSmallTips(CHS[4000384])
            return false
        end
    elseif checkBoxName == "YuHuaDlgCheckBox" then
        if Me:queryBasicInt("level") < 70 then        
            gf:ShowSmallTips(string.format(CHS[4200493], 70))
            return false
        end
    
        if pet:queryInt("rank") == Const.PET_RANK_WILD then
            -- 野生宠物不可点化
            gf:ShowSmallTips(CHS[4100992])
            return false
        end
    elseif checkBoxName == "EvolveDlgCheckBox" then
        if pet:queryInt('rank') == Const.PET_RANK_WILD then
            gf:ShowSmallTips(string.format(CHS[4100150], CHS[3003810]))
            return false
        elseif pet:queryInt('rank') == Const.PET_RANK_ELITE then
            gf:ShowSmallTips(string.format(CHS[4100150], CHS[3003813]))
            return false
        elseif pet:queryInt('rank') == Const.PET_RANK_EPIC then
            gf:ShowSmallTips(string.format(CHS[4100150], CHS[3003814]))
            return false
        end
        
        if pet:getLevel() > Me:getLevel() + 15 then
            gf:ShowSmallTips(CHS[4100152])
            return false
        end

        if pet:queryInt("req_level") > Me:getLevel() then
            if (pet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_YULING or
                 pet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI) and
                 (not PetMgr:isEvolved(pet)) then
                gf:ShowSmallTips(CHS[7002299]) 
            else
                gf:ShowSmallTips(CHS[4100151])
            end
            
            return false
        end
    elseif checkBoxName == "HuanHuaDlgCheckBox" then
        if pet:queryInt("rank") == Const.PET_RANK_WILD then
            -- 野生宠物不可幻化
            gf:ShowSmallTips(CHS[7002300])
            return false
        end
    end
    
    return true
end

return PetGrowTabDlg