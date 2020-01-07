-- FightOpponent.lua
-- Created by chenyq Nov/22/2014
-- 战斗中的敌方

local Bitset = require('core/Bitset')
local FightObj = require('obj/fight/FightObj')
local FightOpponent = class('FightOpponent', FightObj)
local Progress = require('ctrl/Progress')

-- 血条、法力条相对于头顶基准点的偏移
local MANA_OFFSET_Y = 30
local MANA_OFFSET_X = 3
local LIFE_OFFSET_Y = 20

function FightOpponent:init(fightPos)
    FightObj.init(self, fightPos)

    self.showLife = false -- 不显示敌方的血条信息
    self.showMana = false -- 不显示敌方的法力信息
end

-- 获取初始朝向
function FightOpponent:getRawDir()
    return 5
end

-- 设置防御/格挡动作移动路线
function FightOpponent:setMoveLine(dis)
    self.moveLine = {
        startX = self.curX,
        startY = self.curY,
        endX = self.curX - dis,
        endY = self.curY + dis
    }
end

-- 获取物理伤害上升状态光效 key
function FightOpponent:getPhyPowerUpEffectKey()
    return 'phy_power_up_ex'
end

-- 是否可捕捉
function FightOpponent:canProcessCatch()
    return true
end

-- 是否能施法
function FightOpponent:canProcessSkill(skill)
    if not skill or skill.subclass == SKILL.SUBCLASS_D then
        -- D 类技能不能对敌人使用
        return false
    end

    local att = Bitset.new(skill.skill_attrib)
    if not att:isSet(SKILL.MAY_CAST_IN_COMBAT) then
        -- 不能在战斗中使用
        return false
    end

    if not att:isSet(SKILL.MAY_CAST_ENEMY) and not att:isSet(SKILL.MAY_CAST_ALL_ENEMIES) then
        -- 不能对敌人使用
        return false
    end

    -- 进阶技能（除养精蓄锐）只能对敌方的角色、娃娃使用
    local skillName = skill.skill_name
    if SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.JINJIE and skillName ~= CHS[3001991] then
        if self:queryBasicInt("type") ~= OBJECT_TYPE.CHAR and self:queryBasicInt("type") ~= OBJECT_TYPE.CHILD then
            return false
        end
    end

    return true
end

-- 是否能够使用药品
function FightOpponent:canUseMedicine(mediPos)
    if nil == mediPos then return false end

    local item = InventoryMgr:getItemByPos(mediPos)

    if item and item.attrib and item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_VICTIM) then
        -- 物品可以对敌方使用
        return true
    end

    -- 不能对敌方使用药品
    return false
end

-- 是否需要显示怒气条
-- 目前只有“有进阶技能的宠物”可以显示怒气条，在FightPet中进行是否需要显示怒气条的判断
function FightOpponent:canShowAnger()
   -- 观战中心录像，敌方宠物显示怒气
    if self:queryBasicInt("type") == OBJECT_TYPE.PET and WatchRecordMgr:getCurReocrdCombatId() and self:queryBasic("pet_anger") ~= "" then
        return true
    end

    if self:queryBasic("boss_anger") ~= "" then
        return true
    end

    return false
end

function FightOpponent:updateJTStatus()
    if self:queryBasicInt("youtj_effect_flag") > 0 then
        local dlg = DlgMgr:showDlg("JiuTianBuffDlg", true)
        dlg:refreshData(self)

        -- CombatViewDlg要在JiuTianBuffDlg上
        DlgMgr:reorderDlgByName("CombatViewDlg")
    end
end

function FightOpponent:onAbsorbBasicFields()
    self.showLife = (self:queryInt("show_life") == 1)
    EventDispatcher:dispatchEvent(EVENT.FIGHT_OPPONENT_SHOW_LIFE, self.showLife)

    FightObj.onAbsorbBasicFields(self)

end

return FightOpponent
