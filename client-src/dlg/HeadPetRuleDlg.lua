-- HeadPetRuleDlg.lua
-- Created by lixh Mar/05/2018
-- 点击宠物头像弹出的状态信息界面

local HeadPetRuleDlg = Singleton("HeadPetRuleDlg", Dialog)

function HeadPetRuleDlg:init(data)
    self.petRuleOriSz = self:getCtrlContentSize("PetRulePanel")
    self:setPetInfo(data)
end

function HeadPetRuleDlg:setPetInfo(data)
    local pet = PetMgr:getFightPet()
    if not pet then return end

    local life, max_life = 0,0
    local mana, max_mana = 0,0
    local exp, exp_to_next_level = 0,0

    max_life = pet:queryInt("max_life")
    max_mana = pet:queryInt("max_mana")
    exp = pet:queryInt("exp")
    exp_to_next_level = pet:queryInt("exp_to_next_level")

    self:setLabelText("LifeLabel", string.format(CHS[2000006], data.curPetLife, max_life), "PetRulePanel")
    self:setLabelText("ManaLabel", string.format(CHS[2000007], data.curPetMana, max_mana), "PetRulePanel")
    self:setLabelText("ExpLabel", string.format(CHS[2000008], exp, exp_to_next_level, math.floor(100 * exp / exp_to_next_level)), "PetRulePanel")

    local width = self.petRuleOriSz.width
    local numLength = string.len(tostring(exp) .. tostring(exp_to_next_level))
    if numLength >= 20 then
        -- 界面宽度需要放大0.2倍，不然ExpLabel的值会超出界面
        width = self.petRuleOriSz.width * 1.2
    elseif numLength >= 18 then
        -- 界面宽度需要放大0.15倍，不然ExpLabel的值会超出界面
        width = self.petRuleOriSz.width * 1.15
    elseif numLength >= 16 then
        -- 界面宽度需要放大0.1倍，不然ExpLabel的值会超出界面
        width = self.petRuleOriSz.width * 1.1
    end

    self.root:setContentSize(width, self.petRuleOriSz.height)
    self:setCtrlContentSize("PetRulePanel", width, self.petRuleOriSz.height)
    self:setCtrlContentSize("BackImage", width, self.petRuleOriSz.height, "PetRulePanel")

    local rect = data.node:getBoundingBox()
    local pt = data.node:convertToWorldSpace(cc.p(0, 0))
    self.root:setAnchorPoint(0, 0)
    self:setPosition(cc.p(pt.x - width + data.node:getContentSize().width + 5, pt.y - self.petRuleOriSz.height))
end

return HeadPetRuleDlg
