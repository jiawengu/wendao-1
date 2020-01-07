-- FightPet.lua
-- Created by chenyq Nov/22/2014
-- 战斗中的宠物

local Bitset = require('core/Bitset')
local FightObj = require('obj/fight/FightObj')
local FightPet = class('FightPet', FightObj)

FightPet.isFightDead = false

-- 是否能施法
function FightPet:canProcessSkill(skill)
    if not skill then
        return false
    end
    
    if SkillMgr:isArtifactSpSkillByNo(skill.skill_no)
            and SkillMgr:getSkillName(skill.skill_no) == CHS[3001943] then
        -- 金刚圈可以对宠物使用
        return true
    end
    
    if skill.subclass == SKILL.SUBCLASS_B or skill.subclass == SKILL.SUBCLASS_C then
        -- B、C类技能不能对队友使用
        return false
    end

    local att = Bitset.new(skill.skill_attrib)
    if not att:isSet(SKILL.MAY_CAST_IN_COMBAT) then
        -- 不能在战斗中使用
        return false
    end

    if not att:isSet(SKILL.MAY_CAST_SELF) and not att:isSet(SKILL.MAY_CAST_FRIEND) then
        -- 不可以对自己使用也不能对队友使用
        return false
    end

    if att:isSet(SKILL.CANNT_CAST_SELF) and self:getId() == Me:queryBasicInt('c_attacking_id') then
        -- 不能对自己使用
        return false
    end

    if att:isSet(SKILL.MAY_CAST_SELF) and self:getId() ~= Me:queryBasicInt('c_attacking_id') then
        -- 只能对自己使用
        return false
    end

    return true
end

-- 是否能够使用药品
function FightPet:canUseMedicine(mediPos)
    if nil == mediPos then return false end

    local item = InventoryMgr:getItemByPos(mediPos)

    if not item or not item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_FRIEND) then
        return false
    end

    return true
end

function FightPet:onAbsorbBasicFields()
    if Me:isLookOn() then -- 观战中不显示血条
        self.showLife = false -- 不显示敌方的血条信息
        self.showMana = false -- 不显示敌方的法力信息
    else
        self.showLife = true -- 显示敌方的血条信息
        self.showMana = true -- 显示敌方的法力信息
    end

    FightObj.onAbsorbBasicFields(self)
end

function FightPet:canShowAnger()
    -- 观战中心录像，显示怒气
    if WatchRecordMgr:getCurReocrdCombatId() and self:queryBasic("pet_anger") ~= "" then 
        return true 
    end

    if Me:isLookOn() then
        -- 观战中不显示怒气条
        return false
    end
    
    if self:queryBasic("pet_anger") ~= "" then
        -- pet_anger字段非空时显示怒气条
        return true
    else
        return false
    end
end

return FightPet
