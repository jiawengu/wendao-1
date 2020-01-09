-- SkillMgr.lua
-- Created by chenyq Nov/29/2014
-- 技能管理器

local Bitset = require('core/Bitset')
local guard_open_level = require(ResMgr:getCfgPath('SkillsGuardOpenLevel.lua'))

SkillMgr = Singleton()

-- 两级映射表
-- 第一级为角色 id 映射到该角色的所有技能信息
-- 第二级为技能编号映射到对应的技能信息
SkillMgr.idSkills = {}

-- 技能属性信息
SkillMgr.skillAttrib = nil

-- 技能描述信息
SkillMgr.skillDesc = nil

-- 最大技能等级
local MAX_SKILL_LEVEL = 1000

SkillMgr.DUNWU_SKILL_COST_NIMBUS = 50

-- 相性到技能 class 的映射表
local POLAR2CLASS = {
    [POLAR.METAL]   = SKILL.CLASS_METAL,
    [POLAR.WOOD]    = SKILL.CLASS_WOOD,
    [POLAR.WATER]   = SKILL.CLASS_WATER,
    [POLAR.FIRE]    = SKILL.CLASS_FIRE,
    [POLAR.EARTH]   = SKILL.CLASS_EARTH,
}

-- 学习技能的技能限制条件
local SKILL_LIMITS = {
    [SKILL.SUBCLASS_B] = {[SKILL.LADDER_2] = 30,
                          [SKILL.LADDER_3] = 50,
                          [SKILL.LADDER_4] = 80,
                          [SKILL.LADDER_5] = 100,
    },
    [SKILL.SUBCLASS_C] = {[SKILL.LADDER_2] = 40,
                          [SKILL.LADDER_3] = 60,
                          [SKILL.LADDER_4] = 80,
                          [SKILL.LADDER_5] = 100,
    },
    [SKILL.SUBCLASS_D] = {[SKILL.LADDER_2] = 30,
                          [SKILL.LADDER_3] = 50,
                          [SKILL.LADDER_4] = 80,
                          [SKILL.LADDER_5] = 100,
    },
}

-- 学习技能的等级限制(只对零阶、一阶技能有限制)
local LEVEL_LIMITS = {
    [SKILL.SUBCLASS_B] = 10,
    [SKILL.SUBCLASS_C] = 25,
    [SKILL.SUBCLASS_D] = 40,
    [SKILL.SUBCLASS_J] = 10,
    [SKILL.SUBCLASS_F] = 80,
}

-- 宠物B类技能开放显示
local PET_LEVEL_LIMITS = {
    [SKILL.LADDER_1] = 20,
    [SKILL.LADDER_2] = 40,
    [SKILL.LADDER_4] = 60,
}

local GOD_BOOK = {
    [CHS[5000032]] = "moyin",
    [CHS[5000033]] = "kuangbao",
    [CHS[5000035]] = "potian",
    [CHS[5000030]] = "xiangmozhan",
    [CHS[5000031]] = "xiuluoshu",
    [CHS[5000036]] = "fanji",
    [CHS[5000037]] = "yunti",
    [CHS[5000038]] = "xianfeng",
    [CHS[5000039]] = "jinzhong",
    [CHS[5000034]] = "nuji",
    [CHS[3000138]] = "jinglei",
    [CHS[3000139]] = "qingmu",
    [CHS[3000140]] = "hanbing",
    [CHS[3000141]] = "lieyan",
    [CHS[3000142]] = "suishi",
}

-- WDSY-128 宠物天生技能顺序
local PET_NATURAL_ORDER = {
    [CHS[3004313]] = 1,
    [CHS[3004314]] = 2,
    [CHS[3004315]] = 3,
    [CHS[3004316]] = 4,
    [CHS[3004317]] = 5,
    [CHS[3004318]] = 6,
    [CHS[3004319]] = 7,
    [CHS[3004320]] = 8,
    [CHS[3004321]] = 9,
    [CHS[3004322]] = 10,
    [CHS[3004323]] = 11,
    [CHS[3004324]] = 12,
    [CHS[3004325]] = 13,
    [CHS[3004326]] = 14,
}

local PET_STUDY_ORDER = {
    [CHS[3004327]] = 1,
    [CHS[3004328]] = 2,
    [CHS[3004329]] = 3,
    [CHS[3004330]] = 4,
}

local PET_JINJIE_ORDER = {
    [CHS[3001987]] = 1,
    [CHS[3001988]] = 2,
    [CHS[3001989]] = 3,
    [CHS[3001990]] = 4,
    [CHS[3001991]] = 5,
}

local PHY_ATTACK =
{
    ["name"]=CHS[3004331],
    ["skill_no"]=-1,
    ["skill_icon"]=9001,
}

local SKILL_CMD_DESC = {
    [SKILL.SUBCLASS_B] = {[POLAR.METAL] = CHS[3004332], [POLAR.EARTH] = CHS[3004332],
            [POLAR.WOOD] = CHS[3004332], [POLAR.WATER] = CHS[3004332],
           [POLAR.FIRE] = CHS[3004332]},
    [SKILL.SUBCLASS_C] = {[POLAR.METAL] = CHS[3004333], [POLAR.EARTH] = CHS[3004334],
            [POLAR.WOOD] = CHS[3004335], [POLAR.WATER] = CHS[3004336],
            [POLAR.FIRE] = CHS[3004337]},
    [SKILL.SUBCLASS_D] = {[POLAR.METAL] = CHS[3004338], [POLAR.EARTH] = CHS[3004339],
        [POLAR.WOOD] = CHS[3004340], [POLAR.WATER] = CHS[3004341],
        [POLAR.FIRE] = CHS[3004342]},
                        }

local JINJIE_SKILL_CMD_DESC = {
    [CHS[3001987]] = CHS[7000256],
    [CHS[3001988]] = CHS[7000256],
    [CHS[3001989]] = CHS[7000256],
    [CHS[3001990]] = CHS[7000256],
    [CHS[3001991]] = CHS[3004344],
}

local ARTIFACT_SPSKILL_CMD_DESC = {
    [CHS[3001942]] = CHS[7000327],
    [CHS[3001943]] = CHS[7000327],
    [CHS[3001946]] = CHS[7000327],
}

local COUPLE_SKILL_DATA =
{
        {name = CHS[6000281], icon = 9301, no = 601}, -- 夫妻同心
        {name = CHS[6000282], icon = 9302, no = 602}, -- 夫妻双修
        {name = CHS[6000283], icon = 9303, no = 603}, -- 情意绵绵
}

local XIANMO_SKILL_DATA =
    {
        {name = CHS[4000442], icon = 9174, no = 303}, -- 后发制人
        {name = CHS[4000443], icon = 9175, no = 304}, -- 釜底抽薪
    }

local JIEBAI_SKILL_DATA =
{
    {name = CHS[7002210], icon = 9304, no = 604}, -- 肝胆相照
}

local SKILL_SOUND =
{
    [SKILL.CLASS_METAL..SKILL.SUBCLASS_B] = "goldcast1", -- 金系法攻
    [SKILL.CLASS_METAL..SKILL.SUBCLASS_D] = "goldcast2", -- 金系辅助
    [SKILL.CLASS_METAL..SKILL.SUBCLASS_C] = "goldcast3", -- 金系障碍

    [SKILL.CLASS_WOOD..SKILL.SUBCLASS_B] = "woodcast1", -- 木系法攻
    [SKILL.CLASS_WOOD..SKILL.SUBCLASS_D] = "woodcast2", -- 木系辅助
    [SKILL.CLASS_WOOD..SKILL.SUBCLASS_C] = "woodcast3", -- 木系障碍

    [SKILL.CLASS_WATER..SKILL.SUBCLASS_B] = "watercast1", -- 水系法攻
    [SKILL.CLASS_WATER..SKILL.SUBCLASS_D] = "watercast2", -- 水系辅助
    [SKILL.CLASS_WATER..SKILL.SUBCLASS_C] = "watercast3", -- 水系障碍

    [SKILL.CLASS_FIRE..SKILL.SUBCLASS_B] = "firecast1", -- 火系法攻
    [SKILL.CLASS_FIRE..SKILL.SUBCLASS_D] = "firecast2", -- 火系辅助
    [SKILL.CLASS_FIRE..SKILL.SUBCLASS_C] = "firecast3", -- 火系障碍

    [SKILL.CLASS_EARTH..SKILL.SUBCLASS_B] = "earthcast1", -- 土系法攻
    [SKILL.CLASS_EARTH..SKILL.SUBCLASS_D] = "earthcast2", -- 土系辅助
    [SKILL.CLASS_EARTH..SKILL.SUBCLASS_C] = "earthcast3", -- 土系障碍
}

-- 法宝特殊技能
local ARTIFACT_SPSKILL =
{
    [CHS[3001942]] = "diandao_qiankun",  -- 颠倒乾坤
    [CHS[3001943]] = "jingangquan",  -- 金刚圈
    [CHS[3001944]] = "wuji_bifan",  -- 物极必反
    [CHS[3001945]] = "tianyan",  -- 天眼
    [CHS[3001946]] = "chaofeng",  -- 嘲讽
    [CHS[3001947]] = "qinmi_wujian",  -- 亲密无间
}

local ARTIFACT_SPSKILL_COST_NIMBUS =
{
    [CHS[3001942]] = 10,  -- 颠倒乾坤
    [CHS[3001943]] = 10,  -- 金刚圈
    [CHS[3001944]] = 10,  -- 物极必反
    [CHS[3001945]] = 10,  -- 天眼
    [CHS[3001946]] = 10,  -- 嘲讽
    [CHS[3001947]] = 10,  -- 亲密无间
}

-- 颠倒乾坤
local DDQK_ATTRIB_ORDER =
{
    { index = "con", name = CHS[3000330]}, -- 体质
    { index = "wiz", name = CHS[3000329]}, -- 灵力
    { index = "str", name = CHS[3000327]}, -- 力量
    { index = "dex", name = CHS[3000328]}, -- 敏捷
}

SkillMgr.selectGodbookSkillName = nil

SkillMgr.PET_SKILL_TYPE = {
    ATTACK = 1,
    INNATE = 2,
    STUDY  = 3,
    GODBOOK = 4,
    JINJIE = 5,
}

function SkillMgr:clearData()
    self.idSkills = {}
end

-- 获取守护技能开放等级
function SkillMgr:getGuardSkillOpenLevel()
    return guard_open_level
end

-- 获取宠物天生技能顺序列表
function SkillMgr:getNatureSkillOrder()
    return PET_NATURAL_ORDER
end

-- 获取宠物研发技能顺序列表
function SkillMgr:getStudySkillOrder()
    return PET_STUDY_ORDER
end

-- 获取宠物进阶技能顺序列表
function SkillMgr:getJinjieSkillOrder()
    return PET_JINJIE_ORDER
end

function SkillMgr:getPetSkillType(skillName)

    if not skillName then return end

    for k, v in pairs(PET_NATURAL_ORDER) do
        if k == skillName then
            return SkillMgr.PET_SKILL_TYPE.INNATE
        end
    end

    for k, v in pairs(PET_STUDY_ORDER) do
        if k == skillName then
            return SkillMgr.PET_SKILL_TYPE.STUDY
        end
    end

    for k, v in pairs(GOD_BOOK) do
        if k == skillName then
            return SkillMgr.PET_SKILL_TYPE.GODBOOK
        end
    end

    for k, v in pairs(PET_JINJIE_ORDER) do
        if k == skillName then
            return SkillMgr.PET_SKILL_TYPE.JINJIE
        end
    end

    return SkillMgr.PET_SKILL_TYPE.ATTACK
end

-- 对研发技能进行排序
-- reverse: true 表示逆序
function SkillMgr:sortStudySkill(skills, reverse)
    for i = 1, #skills do
        skills[i].order = PET_STUDY_ORDER[skills[i].name] or 100
    end

    table.sort(skills, function(l, r)
        if reverse then
            return l.order > r.order
        else
            return l.order < r.order
        end
    end)
end

function SkillMgr:getSkillCmdDesc(id, skillNo)
    local skill = self:getSkill(id, skillNo)
    if skill then
        local subClass = skill.subclass
        local range = skill.range
        local skillName = skill.skill_name
        local ob = nil
        local skillType = nil
        local fightKid = HomeChildMgr:getFightKid()

        if Me:getId() == id and not SkillMgr:isQinMiWuJianCopySkill(skillName, id) then
            -- 亲密无间可以让玩家拥有宠物的研发技能和天生技能
            ob = Me
        elseif fightKid and fightKid:getId() == id then
            ob = fightKid
        else
            ob = PetMgr:getFightPet()
            skillType = self:getPetSkillType(skillName)
        end

        -- 法宝特殊技能
        if SkillMgr:isArtifactSpSkillByNo(skillNo) then
            local skillName = SkillMgr:getSkillName(skillNo)
            return ARTIFACT_SPSKILL_CMD_DESC[skillName]
        end

        local polar = ob:queryInt("polar")
        if skillType then
            if skillType == SkillMgr.PET_SKILL_TYPE.INNATE then
                -- 天生技能按D类技能处理
               if skillName == CHS[3004322] or skillName == CHS[3004323] or
                  skillName == CHS[3004324] or skillName == CHS[3004325] or
                  skillName == CHS[3004326] then
                    local cmdDesc = SKILL_CMD_DESC[SKILL.SUBCLASS_D][polar]
                    cmdDesc = string.format(cmdDesc, range)
                    return cmdDesc
               else
                    return string.format(CHS[3004343], range)
               end
            elseif skillType == SkillMgr.PET_SKILL_TYPE.STUDY then
                -- 研发技能
                if skillName == CHS[3004328] or skillName == CHS[3004329] then
                    return  CHS[3004344]
                else
                    return string.format(CHS[3004343], range)
                end
            elseif skillType == SkillMgr.PET_SKILL_TYPE.JINJIE then
                return JINJIE_SKILL_CMD_DESC[skillName]
            else
                -- 其余按正常的处理方案
                local cmdDesc = SKILL_CMD_DESC[subClass][polar]
                cmdDesc = string.format(cmdDesc, range)
                return cmdDesc
            end
        else
            if skillName == CHS[3004345] then
                return string.format(CHS[3004346], range)
            end

            local cmdDesc = SKILL_CMD_DESC[subClass][polar]
            cmdDesc = string.format(cmdDesc, range)
            return cmdDesc
        end
    else
        -- 技能数据不存在
        Log:F("[SkillMgr:getSkillCmdDesc] 找不到技能数据。 id = %s, no = %s, idSkills = %s \n%s", tostring(id), tostring(skillNo), tostringex(self.idSkills), debug.traceback())
    end
end

-- 如果还未加载技能配置，则加载技能配置
function SkillMgr:loadskillAttribIfNeed()
    if not self.skillAttrib then
        self.skillAttrib = require(ResMgr:getCfgPath('Skills.lua'))
    end
end

-- 根据技能编号获取配置文件中的技能属性信息
function SkillMgr:getskillAttrib(skillNo)
    if nil == skillNo then return end

    self:loadskillAttribIfNeed()

    if self.skillAttrib[skillNo] then
        return self.skillAttrib[skillNo]
    else
        Log:W('Not found skill info for skill no: ' .. skillNo)
    end
end

-- 根据技能名字获取配置文件中的技能属性信息
function SkillMgr:getskillAttribByName(skillName)
    self:loadskillAttribIfNeed()

    for no, attrib in pairs(self.skillAttrib) do
        if attrib.name == skillName then
            return attrib
        end
    end

    Log:W('Not found skill info for skill name: ' .. skillName)
end

-- 获取技能描述信息
-- 返回 {desc=xx, tip=xx, type=xx}
function SkillMgr:getSkillDesc(skillName)
    if not self.skillDesc then
        self.skillDesc = require(ResMgr:getCfgPath('SkillDesc.lua'))
    end

    return self.skillDesc[skillName]
end

-- 获取指定角色指定编号的技能信息
-- 返回的表包含如下字段：
--      skill_no        技能编号
--      skill_attrib    技能属性
--      skill_level     技能等级
--      level_improved  额外提升的等级数
--      skill_mana_cost 消耗的法力
--      range           当前目标数
--      max_range       最大目标数
--      skill_name      技能名称
--      class           技能 class
--      subclass        技能 subclass
--      ladder          技能阶数
--      cost_xxx        升到下一级需要消耗的 xxx 属性的数值，如 cost_cash
function SkillMgr:getSkill(id, skillNo)

    if skillNo == -1 then
        return PHY_ATTACK
    end

    -- 法宝特殊技能（不在管理器中保存，需要获取时构建技能信息）
    if SkillMgr:isArtifactSpSkillByNo(skillNo) then
        local isPet
        if Me:getId() ~= id then
            isPet = true
        end

        local skill = SkillMgr:getArtifactSpSkill(isPet)
        if skill.skill_no ~= skillNo then
            return
        end

        return skill
    end

    local skills = self.idSkills[id]
    if skills then
        return skills[skillNo]
    end
end

-- 获取物理技能
function SkillMgr:getPhySkill()

end

-- 是否学习过技能
function SkillMgr:isLeardedSkill()
    local skill = {}

    -- 力破千钧
    local phySkill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_J)
    if next(phySkill) then
        return true
    end

    skill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_B)

    if #skill > 0 then
        return true
    end

    skill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_C)

    if #skill > 0 then
        return true
    end

    skill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_D)

    if #skill > 0 then
        return true
    end

    return false
end

-- 是否学习过谋介技能
function SkillMgr:isleardedFiveLadderSkill(ladder)
    local skill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_B)
    if #skill > 0 then
        for i = 1, #skill do
            if skill[i].ladder == ladder then
                return true
            end
        end
    end

    skill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_C)

    if #skill > 0 then
        for i = 1, #skill do
            if skill[i].ladder == ladder then
                return true
            end
        end
    end

    skill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_D)

       if #skill > 0 then
        for i = 1, #skill do
            if skill[i].ladder == ladder then
                return true
            end
        end
    end

    return false
end

-- 获取阶数描述
function SkillMgr:getLadderDescr(ladder)
    if SKILL.LADDER_1 == tonumber(ladder) or 0 == tonumber(ladder) then
        return CHS[3004347]
    elseif SKILL.LADDER_2 == tonumber(ladder) then
        return CHS[3004348]
    elseif SKILL.LADDER_3 == tonumber(ladder) then
        return CHS[3004349]
    elseif SKILL.LADDER_4 == tonumber(ladder) then
        return CHS[3004350]
    elseif SKILL.LADDER_5 == tonumber(ladder) then
        return CHS[3004351]
    end
end

-- 是否有技能
function SkillMgr:haveSkill(id)
    local skills = self.idSkills[id]
    if skills then
        return #skills
    else
        return false
    end
end

-- 是否有战斗技能
function SkillMgr:haveCombatSkill(id)
    -- 不在管理器中保存的技能（法宝特殊技能不在管理器中保存，需要特殊判断）
    local artifactSpSkill
    if Me:getId() == id then
        artifactSpSkill = SkillMgr:getArtifactSpSkill()
    else
        artifactSpSkill = SkillMgr:getArtifactSpSkill(true)
    end

    if artifactSpSkill and artifactSpSkill.skill_no then
        -- 该对象有法宝特殊技能
        return true
    end

    -- 在管理器中保存的技能
    local skills = self.idSkills[id]
    if not skills then
        return false
    end

    for no, skill in pairs(skills) do
        local att = Bitset.new(skill.skill_attrib)
        if att:isSet(SKILL.MAY_CAST_IN_COMBAT) then
            -- 可以在战斗中使用
            return true
        end
    end

    return false
end

-- 获取技能图片路径
function SkillMgr:getSkillIconPath(skillNo)
    local info = self:getskillAttrib(skillNo)
    if info then
        return ResMgr:getSkillIconPath(info['skill_icon'])
    end
end

-- 根据当前技能的等级获取对应的描述
function SkillMgr:getSkillReqDescBId(skillNo)
    local skill = self:getskillAttrib(skillNo)

    -- 五阶技能
    if SKILL.LADDER_5 == skill.skill_ladder then
        if not TaskMgr:isCompleteBaijiTask() then -- 未完成百级任务
            if Me:queryBasicInt("level") < 100 then
                return CHS[6000373]
            else
                return CHS[6000374]
            end
        end
    end

    local skillName =self:getSkillName(skillNo)
    local skillDesc = self:getSkillDesc(skillName)

    if not skillDesc or not skillDesc.req_tips then return end

    local mySkill = SkillMgr:getSkill(Me:getId(), skillNo)

    -- 被动技能
    if skill.skill_subclass == SKILL.SUBCLASS_F then
        if SkillMgr:isXianMoSkill(skillNo) then

            if Me:queryInt("upgrade/level") < 120 then
                return skillDesc.req_tips[1]
            end

            if not Me:isFlyToXianMo() then
                return skillDesc.req_tips[2]
            end

            if not mySkill then
                return skillDesc.req_tips[2]
            end

            -- 仙魔技能是否可以学习
            return skillDesc.req_tips[3]
        else
            if Me:queryInt("level") < LEVEL_LIMITS[SKILL.SUBCLASS_F] then
                return skillDesc.req_tips[1]
            else
                return skillDesc.req_tips[2]
            end
        end
    end

    if type(skillDesc.req_tips) == "table" then

        if not mySkill then
            return skillDesc.req_tips[1]
        end

        if mySkill.ladder == SKILL.LADDER_5 then
            -- 五阶技能
            if mySkill.skill_level <= 0 then
                return skillDesc.req_tips[1]
            elseif mySkill.skill_level < skillDesc.req_tips[2].maxLevel then
                return skillDesc.req_tips[2].tips
            elseif skillDesc.req_tips[3] and mySkill.skill_level < skillDesc.req_tips[3].maxLevel then
                return skillDesc.req_tips[3].tips
            elseif skillDesc.req_tips[4] and mySkill.skill_level < skillDesc.req_tips[4].maxLevel then
                return skillDesc.req_tips[4].tips
            elseif skillDesc.req_tips[5] and mySkill.skill_level < skillDesc.req_tips[5].maxLevel then
                return skillDesc.req_tips[5].tips
            else
                return CHS[5420000]
        end
        elseif mySkill.ladder == SKILL.LADDER_4 then
            -- 四阶技能
            if mySkill.skill_level <= 0 then
                return skillDesc.req_tips[1]
            else
                return CHS[5420000]
            end
        elseif mySkill.ladder == SKILL.LADDER_3 or skillNo == 501 then
            -- 三阶技能
            if mySkill.skill_level <= 0 then
                return skillDesc.req_tips[1]
            elseif mySkill.skill_level < 60 then
                return skillDesc.req_tips[2]
            elseif mySkill.skill_level < 120 then
                return skillDesc.req_tips[3]
            elseif mySkill.skill_level < 160 then
                return skillDesc.req_tips[4]
            else
                return CHS[5420000]
            end
        elseif mySkill.ladder == SKILL.LADDER_2 then
            -- 二阶技能
            if mySkill.skill_level <= 0 then
                return skillDesc.req_tips[1]
            elseif mySkill.skill_level < skillDesc.req_tips[2].maxLevel then
                return skillDesc.req_tips[2].tips
            else
                return CHS[5420000]
            end
        else
            -- 一阶技能
            if mySkill.skill_level <= 0 then
            return skillDesc.req_tips[1]
            else
                return CHS[5420000]
        end
        end

    elseif type(skillDesc.req_tips) == "string" then
        return skillDesc.req_tips
    end

end

-- 获取指定角色指定 subclass、skillClass 的技能编号、等级与阶数信息
-- skillClass 可以不设置，表示不区分 skillClass
function SkillMgr:getSkillNoAndLadder(id, subclass, skillClass)
    local skills = self.idSkills[id]
    if not skills then
        return {}
    end

    return SkillMgr:getSkillNoAndLadderBySkills(skills, subclass, skillClass)
end

-- 获取指定角色指定 subclass、skillClass 的技能编号、等级与阶数信息
-- skillClass 可以不设置，表示不区分 skillClass
function SkillMgr:getSkillNoAndLadderBySkills(skills, subclass, skillClass)
    if type(subclass) ~= 'table' then
        subclass = {subclass}
    end

    local len = #subclass

    local result = {}
    for no, info in pairs(skills) do
        for i = 1, len do
            if info.subclass == subclass[i] and (not skillClass or skillClass == info.class) then
                table.insert(result, {no = no, ladder = info.ladder, level = info.skill_level or info.level, name = info.skill_name})
            end
        end
    end

    table.sort(result, function(l, r) return l.ladder < r.ladder end)
    return result
end

-- 获取指定宠物天生技能的编号与阶数信息
-- 天生技能由如下两类技能组成：
--     subclass 为 SKILL.SUBCLASS_D 的技能
--     subclass 为 SKILL.SUBCLASS_E 且 class 为  SKILL.CLASS_PUBLIC 的技能
-- reverse: true 表示逆序
function SkillMgr:getPetRawSkillNoAndLadder(id, reverse)
    local dSkill = self:getSkillNoAndLadder(id, SKILL.SUBCLASS_D)
    local eSkill = self:getSkillNoAndLadder(id, SKILL.SUBCLASS_E,  SKILL.CLASS_PUBLIC)

    -- 删除顿悟技能
    for i = #dSkill, 1, -1 do
        if SkillMgr:isPetDunWuSkill(id, dSkill[i].name) then
            table.remove(dSkill, i)
        end
    end

    for i = 1, #eSkill do
        if not SkillMgr:isPetDunWuSkill(id, eSkill[i].name) then  -- 非顿悟技能的天生技能
            table.insert(dSkill, eSkill[i])
        end
    end

    for i = 1, #dSkill do
        dSkill[i].order = PET_NATURAL_ORDER[dSkill[i].name] or 100
    end

    table.sort(dSkill, function(l, r)
        if reverse then
            return l.order > r.order
        else
            return l.order < r.order
        end
    end)

    return dSkill
end

function SkillMgr:getPetRawSkillNoAndLadderBySkills(skills, reverse, raw_name)
    local dSkill = self:getSkillNoAndLadderBySkills(skills, SKILL.SUBCLASS_D)
    local eSkill = self:getSkillNoAndLadderBySkills(skills, SKILL.SUBCLASS_E,  SKILL.CLASS_PUBLIC)


    for i = 1, #eSkill do

        if eSkill[i] then
            local skillName = SkillMgr:getskillAttrib(eSkill[i].no).name
            eSkill[i].name = skillName
        end

        if PetMgr:mayPetHaveRawSkill(raw_name, eSkill[i].name) then
            table.insert(dSkill, eSkill[i])
        end
    end

    for i = 1, #dSkill do
        dSkill[i].order = PET_NATURAL_ORDER[dSkill[i].name] or 100
    end

    table.sort(dSkill, function(l, r)
        if reverse then
            return l.order > r.order
        else
            return l.order < r.order
        end
    end)

    return dSkill
end

-- 获取亲密无间复制的宠物研发技能
function SkillMgr:getQinMiWuJianStudySkills()
    local skills = self.idSkills[Me:getId()]
    if not skills then
        return {}
    end

    local result = {}
    for no, info in pairs(skills) do
        if PET_STUDY_ORDER[info.skill_name] and info.isTempSkill == 1 then
            table.insert(result, {no = no, ladder = 0, level = info.skill_level or info.level,
                                  name = info.skill_name, order = PET_STUDY_ORDER[info.skill_name]})
        end
    end

    table.sort(result, function(l, r) return l.order < r.order end)
    return result
end

-- 获取亲密无间复制的宠物天生技能(包括顿悟出来的天生技能)
function SkillMgr:getQinMiWuJianRawSkills(pet)
    local skills = self.idSkills[Me:getId()]
    if not skills or not pet then
        return {}
    end

    local result = {}
    local rawSkills = {}
    local dunwuSkills = {}
    for no, info in pairs(skills) do

        if PET_NATURAL_ORDER[info.skill_name] and info.isTempSkill == 1 and info.skill_disabled == 0 then
            -- 不包括被禁用的技能
            if PetMgr:mayPetHaveRawSkill(pet:queryBasic("raw_name"), info.skill_name) then
                -- 固有天生技能
                table.insert(rawSkills, {no = no, ladder = 0, level = info.skill_level or info.level,
                                         name = info.skill_name, order = PET_NATURAL_ORDER[info.skill_name]})
            else
                -- 顿悟所得天生技能
                table.insert(dunwuSkills, {no = no, ladder = 0, level = info.skill_level or info.level,
                                         name = info.skill_name, order = PET_NATURAL_ORDER[info.skill_name]})
            end
        end
    end

    table.sort(rawSkills, function(l, r) return l.order < r.order end)
    table.sort(dunwuSkills, function(l, r) return l.order < r.order end)

    for i = 1, #rawSkills do
        table.insert(result, rawSkills[i])
    end

    for i = 1, #dunwuSkills do
        table.insert(result, dunwuSkills[i])
    end

    return result
end


-- 获取宠物顿悟技能by Pet
function SkillMgr:getPetDunWuSkillsByPet(pet, isJubao)
    local petDunWuSkills = {}

    if PetMgr:getPetById(pet:queryBasicInt("id")) then
        petDunWuSkills = SkillMgr:getPetDunWuSkillsInfo(pet:queryBasicInt("id")) or {}
        return petDunWuSkills
    end


    local skills = pet:queryBasic("skills")
    if not skills or (type(skills) == "table" and not next(skills)) or skills == "" then return {} end

    local raw_name = pet:queryBasic("raw_name")
    for k, v in pairs(skills) do
        if not isJubao then
            -- 游戏中
            local skillName = SkillMgr:getskillAttrib(v.skill_no).name
            if SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.JINJIE then  -- 进阶技能
                v.skill_name = skillName
                table.insert(petDunWuSkills, v)
            elseif SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.INNATE and
                not PetMgr:mayPetHaveRawSkill(raw_name, skillName) then  -- 宠物本身没有的天生技能
                v.skill_name = skillName
                table.insert(petDunWuSkills, v)
            end
        else
            -- 聚宝斋，通过json转化的，这里需要处理下
            if k == "skill_dunwu" then
                for field, tempSkill in pairs(skills.skill_dunwu) do
                    local skillCfg = SkillMgr:getskillAttribByName(tempSkill.name)

                    local data = {skill_nimbus = tempSkill.nimbus,skill_name = tempSkill.name, skill_no = skillCfg.skill_no, skill_level = tempSkill.level}

                    table.insert(petDunWuSkills, data)
                end
            end


        end
    end

    return petDunWuSkills
end

function SkillMgr:getPetDunWuSkills(id)
    local petDunWuSkills = {}
    -- 宠物顿悟技能包括进阶技能和宠物本身没有的天生技能
    local skills = self.idSkills[id]
    local pet = PetMgr:getPetById(id)
    if not pet then
        return petDunWuSkills
    end

    local raw_name = pet:queryBasic("raw_name")

    if skills then
        for k, v in pairs(skills) do
            local skillName = v.skill_name
            if SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.JINJIE then  -- 进阶技能
                table.insert(petDunWuSkills, skillName)
            elseif SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.INNATE and
                    not PetMgr:mayPetHaveRawSkill(raw_name, skillName) then  -- 宠物本身没有的天生技能
                table.insert(petDunWuSkills, skillName)
            end
        end
    end

    petDunWuSkills = SkillMgr:getOrderPetDunwuSkillsByTab(petDunWuSkills)

    return petDunWuSkills
end

function SkillMgr:getPetDunWuSkillsInfo(id, excludeDisabled)
    local petDunWuSkills = SkillMgr:getPetDunWuSkills(id)
    local petDunWuSkillsInfo = {}

    for i = 1, #petDunWuSkills do
        local skillName = petDunWuSkills[i]
        local skillNo = SkillMgr:getskillAttribByName(skillName).skill_no
        local skillWithPet = SkillMgr:getSkill(id, skillNo)
        local data = {
            level = skillWithPet.skill_level,
            name = skillName,
            no = skillWithPet.skill_no,
            order = PET_JINJIE_ORDER[skillName],
            skill_nimbus = skillWithPet.skill_nimbus,
            skill_disabled = skillWithPet.skill_disabled,
            }

        if (not excludeDisabled) or data.skill_disabled == 0 then
            -- 战斗界面不显示被禁用的顿悟技能
            table.insert(petDunWuSkillsInfo, data)
        end
    end

    return petDunWuSkillsInfo
end

function SkillMgr:isPetDunWuSkill(id, skillName)
    local petDunWuSkills = SkillMgr:getPetDunWuSkills(id)
    for i = 1, #petDunWuSkills do
        if skillName == petDunWuSkills[i] then
            return true
        end
    end

    return false
end

-- 当前法宝特殊技能是否可以使用（法宝特殊技能消耗当前装备法宝的法宝灵气）
function SkillMgr:isArtifactSpSkillCanUse(skillName)
    if not SkillMgr:isArtifactSpSkill(skillName) then
        return true
    end

    local hasNimbus = 0
    local artifact = EquipmentMgr:getEquippedArtifact()
    if artifact then
        hasNimbus = artifact.nimbus
    end

    if hasNimbus < SkillMgr:getArtifactSpSkillCostNimbus(skillName) then
        return false
    end

    return true
end

function SkillMgr:isPetDunWuSkillCanUse(id, skillInfo)
    local skillName = skillInfo.skill_name
    local pet = PetMgr:getPetById(id)

    if not SkillMgr:isPetDunWuSkill(id, skillName) then
        -- 不是顿悟技能，直接return true
        return true
    end

    if SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.JINJIE then
        if pet:queryBasicInt("pet_anger") < Formula:getCostAnger(skillInfo.skill_level) then
            -- 怒气不足
            return false
        end
    else
        if pet:queryInt("mana") < skillInfo.skill_mana_cost then
            -- 法力不足
            return false
        end
    end

    if skillInfo.skill_nimbus < SkillMgr.DUNWU_SKILL_COST_NIMBUS then
        -- 当前技能灵气不足
        return false
    end

    return true
end

-- 是否是法宝特殊技能byNo
function SkillMgr:isArtifactSpSkillByNo(no)
    local skillName = SkillMgr:getSkillName(no)
    if SkillMgr:isArtifactSpSkill(skillName) then
        return true
    else
        return false
    end
end

-- 是否是法宝特殊技能
function SkillMgr:isArtifactSpSkill(skillName)
    if ARTIFACT_SPSKILL[skillName] then
        return true
    else
        return false
    end
end

-- 获取法宝特殊技能名称
function SkillMgr:getArtifactSpSkillName(extra_skill)
    if not extra_skill then
        return
    end

    for k, v in pairs(ARTIFACT_SPSKILL) do
        if v == extra_skill then
            return k
        end
    end

    if ARTIFACT_SPSKILL[extra_skill] then
        return extra_skill
    end
end

-- 法宝特殊技能消耗灵气
function SkillMgr:getArtifactSpSkillCostNimbus(skillName)
    return ARTIFACT_SPSKILL_COST_NIMBUS[skillName]
end

-- 获取对象的法宝特殊技能（颠倒乾坤是宠物才有的法宝特殊技能，其他法宝特殊技能为人物所有）
-- 法宝特殊技能不属于技能，不会在技能管理器中保存，需要自己构建数据
function SkillMgr:getArtifactSpSkill(isPet)
    local artifact = EquipmentMgr:getEquippedArtifact()
    if not artifact then
        return {}
    end

    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if not artifactSpSkillName
        or (isPet and artifactSpSkillName ~= CHS[3001942])
        or (not isPet and artifactSpSkillName == CHS[3001942]) then
        return {}
    end

    local skillNo = SkillMgr:getskillAttribByName(artifactSpSkillName).skill_no
    local skillRange = SkillMgr:getArtifactSpSkillRange(artifactSpSkillName, artifact.extra_skill_level)
    local skillCostNimbus = SkillMgr:getArtifactSpSkillCostNimbus(artifactSpSkillName)

    local result = {
        skill_name = artifactSpSkillName,
        skill_no = skillNo,
        skill_level = artifact.extra_skill_level,
        ladder = 0,
        range = skillRange,
        skill_nimbus_cost = skillCostNimbus,
        skill_mana_cost = 0}
    return result
end

-- 获取法宝特殊技能简略信息
function SkillMgr:getArtifactSpSkillInfo(isPet)
    local artifact = EquipmentMgr:getEquippedArtifact()
    if not artifact then
        return {}
    end

    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if not artifactSpSkillName
          or (isPet and artifactSpSkillName ~= CHS[3001942])
          or (not isPet and artifactSpSkillName == CHS[3001942]) then
        return {}
    end

    local skillNo = SkillMgr:getskillAttribByName(artifactSpSkillName).skill_no
    local skillRange = SkillMgr:getArtifactSpSkillRange(artifactSpSkillName, artifact.extra_skill_level)

    local result = {}
    table.insert(result, {
        no = skillNo,
        ladder = 0,
        level = artifact.extra_skill_level,
        name = artifactSpSkillName,})
    return result
end

-- 获取法宝特殊技能作用目标数
function SkillMgr:getArtifactSpSkillRange(skillName, skillLevel)
    local range = 1
    if skillName == CHS[3001945] then
        -- 天眼作用目标数
        range = math.ceil(4 + skillLevel / 4)
    end

    return range
end

-- 获取宠物物攻技能（目前仅包括颠倒乾坤）
-- 法宝特殊技能不在管理器中保存
function SkillMgr:getPetPhySkills(petId)
    local result = {}

    -- 颠倒乾坤
    local artifact = EquipmentMgr:getEquippedArtifact()
    if not artifact then
        return result
    end

    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if not artifactSpSkillName or artifactSpSkillName ~= CHS[3001942] then
        return result
    end

    local skillNo = SkillMgr:getskillAttribByName(CHS[3001942]).skill_no
    table.insert(result, {no = skillNo, ladder = 0, level = artifact.extra_skill_level, name = artifactSpSkillName})

    return result
end

-- 是否是亲密无间复制的宠物技能
function SkillMgr:isQinMiWuJianCopySkill(skillName, id)
    local isTempSkill
    local skillNo = SkillMgr:getskillAttribByName(skillName).skill_no
    local skill = self:getSkill(id, skillNo)
    if skill and skill.isTempSkill and skill.isTempSkill == 1 then
        isTempSkill = true
    end

    if Me:getId() == id and isTempSkill and
          (SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.INNATE or
           SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.STUDY) then
        -- 是人物身上的临时技能，且从属于宠物的天生/研发技能的范畴，则此技能是亲密无间复制的技能
        return true
    end

    return false
end

-- 判断技能是否只能对自己使用
function SkillMgr:canUseSkillOnlyToSelf(skillNo, user)
    local skill = nil
    if user == "me" then
        skill = SkillMgr:getSkill(Me:getId(), skillNo)
    elseif user == "pet" then
        local pet = PetMgr:getFightPet()
        skill = SkillMgr:getSkill(pet:getId(), skillNo)
    end

    if skill then
        local att = Bitset.new(skill.skill_attrib)
        if att:isSet(SKILL.MAY_CAST_SELF) and not att:isSet(SKILL.MAY_CAST_FRIEND) and not att:isSet(SKILL.MAY_CAST_ENEMY) and
            not att:isSet(SKILL.MAY_CAST_ALL_FRIENDS) and not att:isSet(SKILL.MAY_CAST_ALL_ENEMIES) and
            not att:isSet(SKILL.CANNT_CAST_SELF) then
            return true
        end
    end

    return false
end

-- 获取天书技能对应的拼音
function SkillMgr:getGodBookByChinese( skillName )
    local skill = GOD_BOOK[skillName]
    return skill
end

-- 根据技能编号获取技能名称
function SkillMgr:getSkillName(skillNo)
    local info = self:getskillAttrib(skillNo)
    if info then
        return info.name
    end
end

-- 根据技能编号获取飘字
function SkillMgr:getFlyWordByNo(skillNo)
    local info = self:getskillAttrib(skillNo)
    if info then
        return info.flyWord or info.name
    end
end

-- 获取夫妻技能
function SkillMgr:getCoupleSkill()
    return COUPLE_SKILL_DATA
end

-- 获取结拜技能
function SkillMgr:getJiebaiSkill()
    return JIEBAI_SKILL_DATA
end

function SkillMgr:isXianMoSkill(no)
    for i = 1, #XIANMO_SKILL_DATA do
        if no == XIANMO_SKILL_DATA[i]["no"] then
            return true
        end
    end

    return false
end

function SkillMgr:isCoupleSkill(no)
    for i = 1, #COUPLE_SKILL_DATA do
        if no == COUPLE_SKILL_DATA[i]["no"] then
            return true
        end
    end

    return false
end

function SkillMgr:isJiebaiSkill(no)
    for i = 1, #JIEBAI_SKILL_DATA do
        if no == JIEBAI_SKILL_DATA[i]["no"] then
            return true
        end
    end

    return false
end

function SkillMgr:getCoupleSkillInfo()
    local skillsInfo = {}
    if self:isHaveCoupleSkill()  then
        for i = 1, #COUPLE_SKILL_DATA do
            table.insert(skillsInfo, self.skillAttrib[COUPLE_SKILL_DATA[i]["no"]])
        end
    end
    return skillsInfo
end

function SkillMgr:getJiebaiSkillInfo()
    local skillsInfo = {}
    if self:isHaveJiebaiSkill()  then
        for i = 1, #JIEBAI_SKILL_DATA do
            table.insert(skillsInfo, self.skillAttrib[JIEBAI_SKILL_DATA[i]["no"]])
        end
    end
    return skillsInfo
end

-- 是否拥有夫妻技能
function SkillMgr:isHaveCoupleSkill()
    if Me:queryBasic("marriage/marry_id") ~= "" then
        return true
    else
        return false
    end
end

-- 是否拥有结拜技能
function SkillMgr:isHaveJiebaiSkill()
    if JiebaiMgr:hasJiebaiRelation() then
        return true
    else
        return false
    end
end

-- 获取结拜技能目标数
function SkillMgr:getJiebaiSkillRange()
    local jiebaiInfo = JiebaiMgr:getJiebaiInfo()
    return #jiebaiInfo + 1
end

-- 获取指定相性及subclass的所有技能（不管玩家是否已学习）
function SkillMgr:getSkillsByPolarAndSubclass(polar, subclass)
    local skillClass = POLAR2CLASS[polar]
    if not skillClass then
        -- 没有对应的 class
        Log:W('Not found skill class for polar:' .. polar)
        return {}
    end

    return self:getSkillsByClass(skillClass, subclass)
end

-- 获取指定 class 及 subclass 的所有技能（不管玩家是否已学习）
function SkillMgr:getSkillsByClass(skillClass, subclass)
    self:loadskillAttribIfNeed()

    local skills = {}
    local idx = 0
    for no, v in pairs(self.skillAttrib) do
        if v.skill_class == skillClass and v.skill_subclass == subclass then
            if v.skill_para and v.skill_para == 1 then
                -- 该情况为和北斗战将战斗的特殊技能，不显示
            else
                idx = idx + 1
                skills[idx] = {no = v.skill_no, name = v.name, ladder = v.skill_ladder}
            end
        end
    end

    if idx > 1 then
        table.sort(skills, function(l, r) return l.ladder < r.ladder end)
    end

    return skills
end

-- 获取指定 class 、 subclass 及 ladder 的技能编号
function SkillMgr:getSkillNoByClassAndLadder(skillClass, subclass, ladder)
    self:loadskillAttribIfNeed()

    for no, v in pairs(self.skillAttrib) do
        -- v.skill_para 为特殊技能类型，需要排除
        if v.skill_class == skillClass and v.skill_subclass == subclass and v.skill_ladder == ladder and not v.skill_para then
            return v.skill_no
        end
    end
end

-- 获取指定 相性 、 subclass 及 ladder 的技能编号
function SkillMgr:getSkillNoByPolarAndLadder(polar, subclass, ladder)
    local skillClass = POLAR2CLASS[polar]
    if not skillClass then
        -- 没有对应的 class
        Log:W('Not found skill class for polar:' .. polar)
        return
    end

    return SkillMgr:getSkillNoByClassAndLadder(skillClass, subclass, ladder)
end

-- 是否有等级限制
function SkillMgr:haveLevelLimit(skillNo)
    local skill = self:getskillAttrib(skillNo)
    if skill.skill_ladder > SKILL.LADDER_1 and skill.skill_subclass ~= SKILL.SUBCLASS_F then
        -- 当前只对一阶以上技能有限制、被动技能当前每阶的技能都有限制
        return false
    end

    local levelLimit = LEVEL_LIMITS[skill.skill_subclass]
    if not levelLimit then
        return false
    end

    return Me:queryBasicInt('level') < levelLimit
end

-- 获取技能学习最低等级限制
function SkillMgr:getSkillLimit(skillNo)
    local skill = self:getskillAttrib(skillNo)

    if not LEVEL_LIMITS[skill.skill_subclass] then
        return 0
    end

    return LEVEL_LIMITS[skill.skill_subclass]
end

-- 获取宠物师门技能最低限制等级
function SkillMgr:getPetSkillLimits(skillName)
    local skill = SkillMgr:getskillAttribByName(skillName)
    if skill.skill_subclass == SKILL.SUBCLASS_B then
        return PET_LEVEL_LIMITS[skill.skill_ladder]
    end
end

-- 是否有技能限制
function SkillMgr:haveSkillLimit(skillNo)
    local skill = self:getskillAttrib(skillNo)
    if skill.skill_ladder <= SKILL.LADDER_1 then
        -- 零阶、一阶技能无限制
        return false
    end

    if not SKILL_LIMITS[skill.skill_subclass] then
        return false
    end

    local ladder = skill.skill_ladder
    if not SKILL_LIMITS[skill.skill_subclass][ladder] then
        return false
    end

    if ladder == SKILL.LADDER_5 and not TaskMgr:isCompleteBaijiTask() then -- 五介技能要求完成百级任务
        return true
    end

    -- 前一阶技能的等级要求
    local skillLimit = SKILL_LIMITS[skill.skill_subclass][ladder]

    -- 获取前一阶技能编号
    if ladder == SKILL.LADDER_2 then
        ladder = SKILL.LADDER_1
    elseif ladder == SKILL.LADDER_3 then
        ladder = SKILL.LADDER_2
    elseif ladder == SKILL.LADDER_4 then
        ladder = SKILL.LADDER_3
    elseif ladder == SKILL.LADDER_5 then
        ladder = SKILL.LADDER_4
    else
        return false
    end

    local no = self:getSkillNoByClassAndLadder(skill.skill_class, skill.skill_subclass, ladder)
    local mySkill = self:getSkill(Me:getId(), no)
    if not mySkill or mySkill.skill_level - mySkill.level_improved < skillLimit then
        -- 未学习，或者技能等级未达到要求
        return true
    end

    return false
end

-- 添加技能
function SkillMgr:addSkill(id, data)
    if id ~= Me:getId() and  not PetMgr:getPetById(id) and not HomeChildMgr:getKidById(id) and
        not CharMgr:getChar(id) and not GuardMgr:getGuard(id) then
        -- 技能所属的人的 id 不正确
        -- 非地图上的人物、非Me、非宠物、非守护
        return
    end

    -- 获取该玩家的技能信息，不存在则创建
    local skills = self.idSkills[id]
    if not skills then
        skills = {}
        self.idSkills[id] = skills
    end

    local skillNo = data.skill_no
    if data.skill_level <= 0 or data.skill_level > MAX_SKILL_LEVEL then
        -- 如果等级小于零或大于最大限制，删除技能
        if skills[skillNo] then
            Log:F("[SkillMgr:addSkill] 宠物技能异常。 id = %s, no = %s, level = %s", tostring(id), tostring(skillNo), tostring(data.skill_level))
        end

        skills[skillNo] = nil
    else
        local attrib = self:getskillAttrib(skillNo)
        data.skill_name = attrib.name
        data.class = attrib.skill_class
        data.subclass = attrib.skill_subclass
        data.ladder = attrib.skill_ladder

        -- 存储技能信息
        skills[skillNo] = data
    end
end

-- 直接删除某技能
function SkillMgr:deleteSkill(id, skillNo)
    if not self.idSkills[id] or not self.idSkills[id][skillNo] then
        return
    end

    self.idSkills[id][skillNo] = nil
end

-- 根据技能名字获取技能图标文件
function SkillMgr:getSkillIconFilebyName(skillName)
    local info = self:getskillAttribByName(skillName)
    if not info then
        return ""
    end

    return ResMgr:getSkillIconPath(info.skill_icon)
end

-- 显示技能描述信息界面   技能名，id    触发控件区域
-- DlgType：显示类型，DlgType=1时，将不显示法力值，需要其他类型可自行添加修改
-- DlgType = 2时，manacost显示为红色
function SkillMgr:showSkillDescDlg(skillName, id, isPet, rect, DlgType)
    local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
    dlg:setInfo(skillName, id, isPet, rect, DlgType)
end

-- 删除此人的所有技能
function SkillMgr:deleteAllOnesSkills(id)
    self.idSkills[id] = nil
end

function  SkillMgr:MSG_UPDATE_SKILLS(data)
    local id = data.id
    local count = data.count
    if count then
        for i = 1, count do
            self:addSkill(id, data[i])
        end
    else
        self:deleteAllOnesSkills(id)
    end
end

function SkillMgr:MSG_REFRESH_PET_GODBOOK_SKILLS(data)
    PetMgr:setPetGodBookSkill(data)
end

function SkillMgr:getMePromotableSkillSum()
    local skills = {}              -- 玩家所有技能
    local skills_learned = {}      -- 玩家已经学习技能
    local sum = 0                  -- 可提升技能等级总数
    local maxLevel = math.floor(Me:queryBasicInt("level") * 1.6)
    local polar = Me:queryBasicInt('polar')
    local skills_attack = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_B)
    local skills_handicap = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_C)
    local skills_assist = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_D)
    local skills_phy = SkillMgr:getSkillsByClass(SKILL.CLASS_PHY, SKILL.SUBCLASS_J)
    skills[1] = skills_attack
    skills[2] = skills_handicap
    skills[3] = skills_assist
    skills[4] = skills_phy

    -- 提出玩家Me所有已经学习过的技能
    for i = 1, #skills do
        for j = 1, #skills[i] do
            local skillNo = skills[i][j].no
            if not SkillMgr:haveLevelLimit(skillNo) and
               not SkillMgr:haveSkillLimit(skillNo) then
                table.insert(skills_learned, skills[i][j])
            end
        end
    end

    -- 计算玩家Me所有可提升技能等级总数
    local meId = Me:getId()  -- 再循环外边计算这个常量值，避免每次循环都调用一次，原则：常量尽量只计算一次，保存为局部变量，反复使用
    for k = 1, #skills_learned do
        local skill = SkillMgr:getSkill(meId, skills_learned[k].no)
        if skill then
            local delta = maxLevel - (skill.skill_level - skill.level_improved)
            if delta > 0 then
                sum = sum + delta
            end
        end
    end

    return sum
end

-- ploar 相性（如SKILL.CLASS_METAL）
-- class 某类技能（如a，c）
function SkillMgr:getSkillCast(ploar, class)
    local key = (ploar or "") .. (class or "")
    return SKILL_SOUND[key]
end

function SkillMgr:addDunWuSkillImage(ctr)
    local sp = ctr:getChildByName("dunWuLogo")
    if sp then return end

    local path = ResMgr.ui.dunWu_skill_mark
    local sp = ccui.ImageView:create()
    sp:loadTexture(path, ccui.TextureResType.plistType)
    gf:setSkillFlagImageSize(sp)

    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, size.height - spSize.height * 0.5)
    sp:setName("dunWuLogo")
    ctr:addChild(sp)
end

function SkillMgr:removeDunWuSkillImage(ctr)
    if nil == ctr then return end
    local sp = ctr:getChildByName("dunWuLogo")
    if sp then
        sp:removeFromParent()
    end
end

-- 法宝特殊技能标记
function SkillMgr:addArtifactSpSkillImage(ctr)
    local sp = ctr:getChildByName("artifactSpSkillLogo")
    if sp then return end

    local path = ResMgr.ui.artifact_special_skill_mark
    local sp = ccui.ImageView:create()
    sp:loadTexture(path, ccui.TextureResType.plistType)
    gf:setSkillFlagImageSize(sp)

    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, size.height - spSize.height * 0.5)
    sp:setName("artifactSpSkillLogo")
    ctr:addChild(sp)
end

function SkillMgr:removeArtifactSpSkillImage(ctr)
    if nil == ctr then return end
    local sp = ctr:getChildByName("artifactSpSkillLogo")
    if sp then
        sp:removeFromParent()
    end
end

-- 获取颠倒乾坤最大持续回合数
function SkillMgr:getDDQKMaxRound(id)
    local ddqkData = self.ddqkData
    if ddqkData.id == id then
        return ddqkData.max_round
    end
end

-- 获取颠倒乾坤目标的相关属性
function SkillMgr:getDDQKAttrib(id)
    local ddqkData = self.ddqkData
    local result = {}

    -- 找到最大的那一项属性
    local maxNum = 0
    local maxIndex
    local maxAttribName
    for i = 1, #DDQK_ATTRIB_ORDER do
        local index = DDQK_ATTRIB_ORDER[i].index
        local name = DDQK_ATTRIB_ORDER[i].name
        local num = ddqkData[index]
        if num > maxNum then
            maxIndex = index
            maxNum = num
            maxAttribName = name
        end
    end
    result.maxAttrib = {name = maxAttribName, num = maxNum}

    -- 将剩余的其他属性按顺序排列
    for i = 1, #DDQK_ATTRIB_ORDER do
        local index = DDQK_ATTRIB_ORDER[i].index
        local name = DDQK_ATTRIB_ORDER[i].name
        local num = ddqkData[index]
        if index ~= maxIndex then
            table.insert(result, {name = name, num = num})
        end
    end

    return result
end

function SkillMgr:MSG_DUNWU_SKILL(data)
    local type = data.type
    local petId = data.pet_id
    local skillNo = data.skill_no
    if type == 2 then
        -- 删除顿悟技能
        SkillMgr:deleteSkill(petId, skillNo)
    end
end

function SkillMgr:MSG_VIEW_DDQK_ATTRIB(data)
    self.ddqkData = data
end

-- 获取可学习等级上限
function SkillMgr:getLearnLevelMax()
    return math.floor(Me:queryBasicInt("level") * 1.6)
end

-- 获取可精研等级上限
function SkillMgr:getStudyLevelMax()
    return math.floor(Me:queryBasicInt("level") * 2)
end

function SkillMgr:getOrderPetDunwuSkillsByTab(skillsTab)
    local orderSkills = {}
    for i = 1, #skillsTab do
        if PET_NATURAL_ORDER[skillsTab[i]] then
            table.insert( orderSkills, {skillName = skillsTab[i], order = PET_NATURAL_ORDER[skillsTab[i]]} )
        end

        if PET_JINJIE_ORDER[skillsTab[i]] then
            table.insert( orderSkills, {skillName = skillsTab[i], order = 50 + PET_JINJIE_ORDER[skillsTab[i]]} )   -- 50其实只要 PET_NATURAL_ORDER长度就好了
        end
    end

    table.sort( orderSkills, function(l,r)
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    local ret = {}

    for i = 1, #orderSkills do
        table.insert( ret, orderSkills[i].skillName )
    end

    return ret
end

-- 根据战斗模板获取对应的特殊技能，没有 mode 则返回空，当前只有 通天塔特殊战斗
function SkillMgr:getSkillsByCombatMode(mode)
    local skills = {}
    local skillsEx = {}
    if COMBAT_MODE.COMBAT_MODE_TONGTIANTADING == mode then

        for no, skillInfo in pairs(self.skillAttrib) do
            if skillInfo.skill_para == 1 then   -- 通天塔顶-北斗战将特殊技能
                table.insert(skills, no)
                skillsEx[no] = skillInfo.skill_para
            end
        end
    end

    return skills, skillsEx
end

MessageMgr:regist("MSG_UPDATE_SKILLS", SkillMgr)
MessageMgr:regist("MSG_REFRESH_PET_GODBOOK_SKILLS", SkillMgr)
MessageMgr:regist("MSG_DUNWU_SKILL", SkillMgr)
MessageMgr:regist("MSG_VIEW_DDQK_ATTRIB", SkillMgr)
