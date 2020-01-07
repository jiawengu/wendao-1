-- FightFriend.lua
-- Created by chenyq Nov/22/2014
-- 战斗中的己方

local Bitset = require('core/Bitset')
local FightObj = require('obj/fight/FightObj')
local FightFriend = class('FightFriend', FightObj)

-- 是否能施法
function FightFriend:canProcessSkill(skill)
    if not skill then
        return false
    end

    if skill.subclass == SKILL.SUBCLASS_B or skill.subclass == SKILL.SUBCLASS_C then
        -- B、C类技能不能对队友使用
        return false
    end
    
    if SkillMgr:isArtifactSpSkillByNo(skill.skill_no) then
        -- 法宝技能可对己方角色使用
        -- 颠倒乾坤和嘲讽仅可对玩家角色使用，不可对非玩家角色使用（eg:竹灵，守护等）
        local skillName = SkillMgr:getSkillName(skill.skill_no)
        if skillName == CHS[3001942] or skillName == CHS[3001946] then
            return self:isPlayer()
        end
        
        return true
    end
    
    local att = Bitset.new(skill.skill_attrib)
    if not att:isSet(SKILL.MAY_CAST_IN_COMBAT) then
        -- 不能在战斗中使用
        return false
    end

    if not att:isSet(SKILL.MAY_CAST_SELF) and not att:isSet(SKILL.MAY_CAST_FRIEND) then
        -- 不可以对自己使用也不能对友人使用
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
function FightFriend:canUseMedicine(mediPos)
    if nil == mediPos then return false end

    local item = InventoryMgr:getItemByPos(mediPos)
    -- 判断是否是法药
    if item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_FRIEND) then
        -- 需要对队友跟守护进行区分使用
        if self:isGuard() and nil ~= item.extra.mana_1 then
            gf:ShowSmallTips(CHS[5000058])
            return false
        end

        return true
    end

    return false
end

function FightFriend:onAbsorbBasicFields()
    if Me:isLookOn() then -- 观战中不显示血条
        self.showLife = false -- 不显示敌方的血条信息
        self.showMana = false -- 不显示敌方的法力信息
    else
        self.showLife = true -- 显示敌方的血条信息
        self.showMana = true -- 显示敌方的法力信息
    end

    FightObj.onAbsorbBasicFields(self)
end
return FightFriend
