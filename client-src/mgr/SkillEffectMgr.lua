-- SkillEffectMgr.lua
-- Created by chenyq Nov/27/2014
-- 技能光效管理器

local Bitset = require('core/Bitset')
SkillEffectMgr = Singleton('SkillEffectMgr')
local CartoonInfo = require "magic/Cartoon.lua" or {}

function SkillEffectMgr:getAlign(layer, pos)
    local bs = Bitset.new(0)
    if layer and (layer == 'bottom' or layer == 'bottom_most') then
        bs:setBit(Const.MAGIC_ALIGN_TYPE_BOTTOM, true)
    elseif layer and (layer == 'top' or layer == 'top_most') then
        bs:setBit(Const.MAGIC_ALIGN_TYPE_TOP, true)
    else
        bs:setBit(Const.MAGIC_ALIGN_TYPE_MIDDLE, true)
    end

    if pos == "head" then
        bs:setBit(Const.MAGIC_ALIGN_TYPE_HEAD, true)
    elseif pos == "waist" then
        bs:setBit(Const.MAGIC_ALIGN_TYPE_WAIST, true)
    else
        bs:setBit(Const.MAGIC_ALIGN_TYPE_FOOT, true)
    end

    if layer and (layer == 'top_most' or layer == 'bottom_most') then
        bs:setBit(Const.MAGIC_ALIGN_TYPE_CENTER, true)
    end

    return bs:getI32()
end

-- 获取技能信息，返回 icon, align
function SkillEffectMgr:getMagicInfo(skillNo, toOthers)
    local info = SkillMgr:getskillAttrib(skillNo)
    if not info then
        return
    end

    local effect = info.skill_effect
    if info.skill_effect_to_whom == SKILL.EFFECT_TO_BOTH and toOthers == 1 and info.skill_effect_ex then
        effect = info.skill_effect_ex
    end

    if not effect or type(effect) ~= 'table' then
        return
    end

    local shake_screen = info.shake_screen

    local info = {}
    info.count = 1
    info[1] = { icon = effect.icon,
                align = self:getAlign(effect.layer, effect.pos),
                type = effect.type,
                shake_screen = tonumber(shake_screen),
                blendMode = effect.blendMode}

    if effect.icon_ex then
        info.count = 2
        info[2] = {icon = effect.icon_ex,
                   align = self:getAlign(effect.layer_ex, effect.pos_ex),
                   type = effect.type_ex,
                   blendMode = effect.blendMode_ex}
    end

    return info;
end

function SkillEffectMgr:getMagicScale(icon)
    local iconName = string.format("%05d", icon)
    if CartoonInfo[iconName] and CartoonInfo[iconName].scale then
        return CartoonInfo[iconName].scale
    end

    return nil
end

-- 设置正在播放的全屏光效
function SkillEffectMgr:setFightPlayFullScreen(icon, type, fightPos)
    if not self.playingEffectList then
        self.playingEffectList = {}
    end

    local key = icon .. "|" ..type
    self.playingEffectList[key] = fightPos
end

function SkillEffectMgr:setPlayFullScreenFightPos(fightPos)
    if not self.fightPoslist then
        self.fightPoslist = {}
    end

    table.insert(self.fightPoslist, fightPos)
end

-- 是否是正在播放的全屏光效
function SkillEffectMgr:isPlayingFullScreenEffect(icon, type)
    local key = icon .. "|" ..type

    if self.playingEffectList then
        return self.playingEffectList[key]
    end
end

-- 清除播放的全屏光效
function SkillEffectMgr:clearFullScreenEffect()
    if self.fightPoslist then
        for k, v in pairs(self.fightPoslist) do
            local obj = FightMgr:getCreatedObj(v)
            if obj then
                obj:onMagicFinish_ex()
            end
        end
    end

    self.fightPoslist = {}
    self.playingEffectList = {}
end