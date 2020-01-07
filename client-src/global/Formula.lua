-- Formula.lua
-- created by cheny Dec/25/2014
-- 公式相关

Formula = {}

-- 守护强化的削减系数
local GUARD_STRENGTH_MAP = {
    0.512,
    0.576,
    0.64,
}

-- 守护装备属性的改造系数
local GUARD_ATTR_ADD_MAP = {
    def = 6.1,
    power = 4.5,
}

local UnidentifiedEquipPrice = require (ResMgr:getCfgPath("UnidentifiedEquipPrice.lua"))

local JinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

local StdValue = require(ResMgr:getCfgPath("StdValue.lua"))

-- 标准道行
function Formula:getStdTao(level)
    return math.pow(level,3) * 0.29
end

-- 标准武学
function Formula:getStdMartial(level)
    local res = math.pow(level,3) * 0.29 * 2
    if res < 1 then
        res = 1
    end

    return res
end

-- 标准攻击
function Formula:getStdAttack(level)
    if DistMgr:curIsTestDist() then
        if StdValue.stdAttack[level] then
            return StdValue.stdAttack[level]
        end
    end

    level = level - 1
    return math.floor(level * level * 1.39 + 85 * level + 100) * 4 / 10
end

-- 标准防御
function Formula:getStdDefense(level)
    if DistMgr:curIsTestDist() then
        if StdValue.stdDefense[level] then
            return StdValue.stdDefense[level]
        end
    end

    level = level - 1
    return math.floor((1.39 * level * level) + 85 * level + 100) / 15
end

-- 标准气血
function Formula:getStdLife(level)
    if DistMgr:curIsTestDist() then
        if StdValue.stdLife[level] then
            return StdValue.stdLife[level]
        end
    end

    level = level - 1
    return math.floor((1.39 * level * level) + 85 * level + 100)
end

-- 标准法力
function Formula:getStdMana(level)
    if DistMgr:curIsTestDist() then
        if StdValue.stdMana[level] then
            return StdValue.stdMana[level]
        end
    end

    level = level - 1
    return math.floor((0.93 * level * level) + 56 * level + 80)
end

-- 标准速度
function Formula:getStdSpeed(level)
    if DistMgr:curIsTestDist() then
        if StdValue.stdSpeed[level] then
            return StdValue.stdSpeed[level]
        end
    end

    level = level - 1
    return math.floor(level * 6 + 50);
end

function Formula:getAttribCost(level, point)
    if point <= 0 then
        return 0
    end
    return math.max(1, math.floor(math.max(0.1, (1.0 - 0.0005 * point) * math.min(1.0, math.pow(1.0 * level / 120, 2))) * point * 108))
end

function Formula:getPolarCost(point)
    return 164 * point
end

-- 单次物攻强化成长值
function Formula:getPhyRebuildDelta(std_value, rebuild_add)
    local delta = math.max(math.floor((std_value + 50) * 0.08), 1)
    if std_value + 50 + rebuild_add + delta > 165 then
        delta = math.max(0, 165 - (std_value + 50 + rebuild_add))
    end
    return delta
end

-- 单次法攻强化成长值
function Formula:getMagRebuildDelta(std_value, rebuild_add)
    local delta = math.max(math.floor((std_value + 50) * 0.08), 1)
    if std_value + 50 + rebuild_add + delta > 135 then
        delta = math.max(0, 135 - (std_value + 50 + rebuild_add))
    end
    return delta
end

-- 宠物物伤数值公式
function Formula:getPetPhyPower(str, phyShape, petLevel)
    local phyEffect = phyShape - 40
    local levelFactor = math.floor(petLevel / 4)
    if levelFactor > 30 then levelFactor = 30 end

    local rawValue = math.floor((str * levelFactor * 5 * 4 / 42 + str * 5) * 2 * (1.0 + phyEffect / 100) + 100)

    local phyFactor = 0.63 + 0.01 * (petLevel - 1)
    if phyFactor > 1 then phyFactor = 1 end

    return math.floor(rawValue * phyFactor)
end

-- 宠物法伤数值公式
function Formula:getPetMagPower(wiz, magShape, petLevel)
    local magEffect = magShape - 40
    local levelFactor = math.floor(petLevel / 4)
    if levelFactor > 30 then levelFactor = 30 end

    return math.floor(1.3 * (wiz * levelFactor * 5 * 4  / 42 + wiz * 5) * 2 * (1.0 + magEffect / 100) + 100)
end

-- 获取宠物天生技能升级所消耗的资金
function Formula:getCostCashPetInnateSkill(curLevel, addLevel)
    local needCash = 0
    local toLevel = curLevel + addLevel

    for i = curLevel, toLevel - 1 do
        if i >= 0 and i <= 179 then
            needCash = needCash + (15 * (i + 1) * (i + 1) + 240 * (i + 1) + 1600)
        elseif i > 179 and i <= 235 then
            needCash = needCash + (0.6 * i * i * i - 91 * i * i)
        end
    end

    return math.floor(needCash)
end

-- 获取宠物天生技能所消耗的帮贡
function Formula:getCostConribPetInnateSkill(curLevel, addLevel)
    local needContrib = 0
    local toLevel = curLevel + addLevel

    for i = curLevel, toLevel - 1 do
        if i >= 0 and i <= 179 then
            needContrib = needContrib + math.ceil(0.02 * i * i + 2 * i)
        elseif i > 179 and i <= 235 then
            needContrib = needContrib + (0.001 * i * i * i - 30 * i + 615)
        end
    end

    return math.floor(needContrib)
end

-- 获取宠物研发技能升级所消耗的资金
function Formula:getCostCashPetDevelopSkill(curLevel, addLevel)
    local needCash = 0
    local toLevel = curLevel + addLevel

    for i = curLevel, toLevel - 1 do
        needCash = needCash + (15 * (i) * (i) + 240 * (i) + 1600)
    end

    return math.floor(needCash)
end

-- 获取宠物研发技能所消耗的帮贡
function Formula:getCostConribPetDevelopSkill(curLevel, addLevel)
    local needContrib = 0
    local toLevel = curLevel + addLevel

    for i = curLevel, toLevel - 1 do
        needContrib = needContrib + math.ceil(0.02 * i * i + 2 * i)
    end

    return math.floor(needContrib)
end

-- 获取宠物进阶技能升级所消耗的资金
function Formula:getCostCashPetJinjieSkill(curLevel, addLevel)
    local needCash = 0
    local toLevel = curLevel + addLevel

    for i = curLevel, toLevel - 1 do
        needCash = needCash + math.floor(0.5643 * math.pow(i, 3.5) / 10)
    end

    return math.floor(needCash)
end

-- 获取宠物进阶技能升级所消耗的潜能
function Formula:getCostPotPetJinjieSkill(curLevel, addLevel)
    local needPot = 0
    local toLevel = curLevel + addLevel

    for i = curLevel, toLevel - 1 do
        needPot = needPot + math.floor(0.5643 * math.pow(i + 1, 3) * 21)
    end

    return math.floor(needPot)
end

-- 释放进阶技能消耗怒气
function Formula:getCostAnger(level)
    return math.floor(100 - math.floor(level * 40 / 160))
end

-- 根据装备等级获取进化完成度
function Formula:getEvolveDegree(req_level)
    --[[
    local evolve_level = 0
    if (req_level == 1) then
        evolve_level = 0
    elseif (req_level == 5) then
        evolve_level = 1
    elseif (req_level == 8) then
        evolve_level = 2
    else
        evolve_level = req_level - 7
    end

    if (evolve_level < 20) then
        return math.floor(evolve_level / 10) + 1
    else
        return math.floor((evolve_level - 20) / 3) + 3
    end
    --]]

    local x = Formula:getEvolveLevel(req_level + 1)
    local Y = 1

    if 1 <= x and x < 55 then
        Y = 1
    elseif 55 <= x then
        Y = math.floor((x - 55) / 5) + 2
    end

    return Y
end

-- 守护装备改造等级，计算守护装备是*改*星
-- 返回值 lev, star
function Formula:getGuardLevAndStar(rebuildLev)
    return math.floor(rebuildLev / 10), rebuildLev % 10
end

-- 守护强化过程中， 每等级强化的伤害
function Formula:getGuardStrengthPower(guardStrenLev, guardRank)
    if guardStrenLev == 0 then
        return 0
    else
        return math.floor((1.39 * (guardStrenLev - 1) * (guardStrenLev - 1) + 85 * (guardStrenLev - 1) + 100)* 0.4 * 0.4 * 0.7 * 2 * GUARD_STRENGTH_MAP[guardRank])
    end
end

-- 守护装备改造，获取装备的加成百分比
function Formula:getGuardEquip(key, rebuildLev)
    return GUARD_ATTR_ADD_MAP[key] * (rebuildLev)
end

function Formula:calGuardWeaponFightscore(power, rebuildLevel)
    local score = math.floor((power + 0.045 * rebuildLevel * power) * 5.67)
    score = score + (power + 0.045 * rebuildLevel * power * 0.75) * 10.68

    return math.floor(score)
end

function Formula:calGuardHelmetOrArmorFightscore(maxLife, def, rebuildLevel)
    local score = maxLife;
    score = score + (def + (0.061 * rebuildLevel) * def) * 3;

    return math.floor(score)
end

function Formula:calGuardBootFightscore(speed, def, rebuildLevel)
    local score = math.floor(speed * 48.33);
    score = score + (def + (0.061 * rebuildLevel) * def) * 3;

    return math.floor(score)
end

-- 装备进化消耗数值
-- level 为目标进化等级， 即为当前等级+1
function Formula:getEquipEvoleveCost(level)
    -- 天星石消耗
    local x = level + 1
    local y = 1

    -- 每点完成度需要消耗的天星石
    if 1 <= x and x < 55 then
        y = 1
    else
        y = math.floor((x - 55) / 5) + 2
    end

    -- 金钱消耗
    local money = level * 1000

    return y, money
end

-- 根据装备等级获取
function Formula:getEvolveLevel(reqLevel)
    return reqLevel - 1
end

-- 根据装备等级获取下一等级
function Formula:getNextEvolveLevel(level)
    if level == 1 then
        return 5
    end

    if level == 5 then
        return 8
    end

    if level == 8 then
        return 10
    end

    return level + 1;
end

-- 武器改造消耗的数值
-- level 为目标进化等级， 即为当前等级+1
function Formula:getEquipRebuidWeaponCost(level)
    -- 武器改造消耗数值
    local x = level + 1

    --[[
    local y = 1
    if 1 <= x and x < 71 then
    y = math.pow(2, math.floor((x + 9) / 20)) * 1
    elseif 71 <= x and x <= 120 then
    y = math.pow(2, math.floor((x - 61) / 10)) * 8
    end
    --]]

    -- 超级灵石消耗
    local Y = 1
    if 1 <= x and x < 61 then
        Y = math.pow(2, math.floor((x - 1) / 20)) * 1
    elseif 61 <= x and x < 71 then
        Y = math.pow(2, math.floor((x - 51) / 10)) * 4
    elseif 71 <= x and x < 81 then
        Y  = 12
    elseif 81 <= x and x < 120 then
        Y = math.pow(2, math.floor((x - 71) / 10)) * 12
    end

    local money = x * 3000

    return CHS[3003801], Y, money
end

-- 装备改造消耗的数值
-- level 为目标进化等级， 即为当前等级+1
function Formula:getEquipRebuidSuitCost(level)
    -- 武器改造消耗数值
    local x = level + 1

    --[[
    local y = 1
    if 1 <= x and x < 71 then
        y = math.pow(2, math.floor((x + 9) / 20)) * 1
    elseif 71 <= x and x <= 120 then
        y = math.pow(2, math.floor((x - 61) / 10)) * 8
    end
    --]]

    -- 超级灵石消耗
    local Y = 1
    if 1 <= x and x < 61 then
        Y = math.pow(2, math.floor((x - 1) / 20)) * 1
    elseif 61 <= x and x < 71 then
        Y = math.pow(2, math.floor((x - 51) / 10)) * 4
    elseif 71 <= x and x < 81 then
        Y  = 12
    elseif 81 <= x and x < 120 then
        Y = math.pow(2, math.floor((x - 71) / 10)) * 12
    end

    local money = x * 1000

    return CHS[3003802], Y, money
end

-- 获取宠物羽化灵气最大值
function Formula:getPetYuhuaMaxNimbus(pet)
    if pet:queryBasicInt("max_eclosion_nimbus") ~= 0 then return pet:queryBasicInt("max_eclosion_nimbus") end

    local rank = pet:queryBasicInt("rank")
    local perMap = {[0] = 0.2, [1] = 0.3, [2] = 0.5}
    local stage = pet:queryBasicInt("eclosion_stage")
    local per = perMap[stage]

    if rank == Const.PET_RANK_EPIC then
        -- 神兽
        return math.floor(1400000 * per)
    elseif rank == Const.PET_RANK_ELITE then
        return math.floor(700000 * per)
    else
        if PetMgr:isMountPet(pet) then
            return math.floor(300000 * per)
        else
            -- 纪念300000
            local realPet = pet:queryBasic("evolve") ~= "" and pet:queryBasic("evolve") or pet:queryBasic("raw_name")

            if JinianPetList[realPet] then
                return math.floor(math.floor(3000 * math.pow(1, 0.85) + 39 * 3000) * per)
            end

            local level = pet:queryInt("req_level")
            if realPet == CHS[7190018] then
                level = Const.BAIGUOER_PET_COST_REQ_LEVEL
            end

            return math.floor(math.floor(3000 * math.pow(level, 0.85) + 39 * 3000) * per)
        end
    end
end

-- 获取宠物点化灵气最大值
function Formula:getPetDianhuaMaxNimbus(pet)
    local level = pet:queryInt("req_level")
    if pet:queryBasic("raw_name") == CHS[7190018] then
        -- 如果服务器有下发最大灵气上限则使用服务器的下发值
        if pet:queryInt("max_enchant_nimbus") > 0 then
            return pet:queryInt("max_enchant_nimbus")
        end

        -- 如果未进化过
        if pet:queryBasic("evolve") == "" then
        level = Const.BAIGUOER_PET_COST_REQ_LEVEL
    end
    end

    local totalNimbus = 30 * math.pow(level, 2)
    local rank = pet:queryBasicInt("rank")
    if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
        totalNimbus = 400000
    end

    if PetMgr:isMountPet(pet) then
        totalNimbus = 300000
    end

    return totalNimbus
end

function Formula:getPetYuhuaNimbusByItems(items)
    local nimbus = 0
    for i, item in pairs(items) do
        if item.item_type == ITEM_TYPE.ARTIFACT then
            nimbus = nimbus + 1000000 / 5000
        elseif item.name == CHS[4000383] then
            nimbus = nimbus + 6000
        elseif item.name == CHS[4100994] then   -- 羽化丹
            nimbus = nimbus + 3000
        else
            -- 符合条件的装备
            if item.unidentified == 1 then
                nimbus = nimbus + math.floor(UnidentifiedEquipPrice[item.req_level][item.equip_type] * (1 + 2 * 3) / 5 / 1000 / 5)
            else
                nimbus = nimbus + math.floor(item.value / 1000 / 5 / 5)
            end
        end
    end

    return nimbus
end

-- 获取items转化的灵气
function Formula:getPetDianhuaNimbusByItems(items)
    local nimbus = 0
    for i, item in pairs(items) do
        if item.item_type == ITEM_TYPE.ARTIFACT then
            nimbus = nimbus + 1000000 / 1000
        elseif item.name == CHS[4000383] then
            nimbus = nimbus + 6000
        elseif item.name == CHS[4100994] then   -- 羽化丹
            nimbus = nimbus + 3000
        else
            -- 符合条件的装备
            if item.unidentified == 1 then
                nimbus = nimbus + UnidentifiedEquipPrice[item.req_level][item.equip_type] * (1 + 2 * 3) / 5 / 1000
            else
                nimbus = nimbus + math.floor(item.value / 1000 / 5)
            end
        end
    end

    return nimbus
end

-- 宠物羽化预览  items需经过筛选后, 如果基础成长为0，羽化成功时，需要变成1
function Formula:petYuhuaAdd(shapeBasic, pet, items, shapeType)
    -- shapeBasic可能为负值，为保证使用点化丹后，宠物获得的属性加成值为正值，在此取绝对值
    shapeBasic = math.abs(shapeBasic)

    if type(items) ~= "table" then return end
    if not pet then return end

    local nimbus = self:getPetYuhuaNimbusByItems(items)
    local totalNimbus = self:getPetYuhuaMaxNimbus(pet)

    local rateMap = {
        [Const.PET_RANK_EPIC] = {phy = 0.5, mag = 0.7, speed = 0.45, mana = 0.4, life = 0.8},
        [Const.PET_RANK_ELITE] = {phy = 0.4, mag = 0.5, speed = 0.4, mana = 0.25, life = 0.6},
        ["default"] = {phy = 0.2, mag = 0.2, speed = 0.3, mana = 0.2, life = 0.5},
     }

--  int（int（rate * 当前灵气值 / 满灵气值 * 100 ）/ 100 * 基础成长）
    local rank = pet:queryInt('rank')
    local stage = pet:queryInt('eclosion_stage') + 1
    local rate = rateMap[rank] and rateMap[rank][shapeType] or rateMap["default"][shapeType]
    --
    local stageMap = {0, 1 / 3, 2 / 3,  1}

    -- 服务器先算  rate * stageMap[stage + 1]，取5位精度再 * shapeBasic

    local para1 = math.floor(rate * stageMap[stage + 1] * 100000)
    local para2 = math.floor(rate * stageMap[stage] * 100000)

    local retValue = math.floor(para1 / 100000 * shapeBasic)
    local beforeValue = math.floor(para2 / 100000 * shapeBasic)


    if shapeBasic == 0 and stage + 1 > 3 then
        return 1
    end

    return retValue - beforeValue

--[[
    -- math.floor(math.floor( 29 / 100 * 100)) == 28!!!!!!!!!!!!   防止该问题，tosting再tonumber
    local temp = math.floor(0.3 * math.min(pet:queryBasicInt("enchant_nimbus") / totalNimbus, 1) * 100) / 100 * shapeBasic
    local valueLocal = math.floor(tonumber(tostring(temp)))

    local temp2 = math.floor(0.3 * math.min((nimbus + pet:queryBasicInt("enchant_nimbus")) / totalNimbus, 1) * 100) / 100 * shapeBasic
    local totalEff = math.floor(tonumber(tostring(temp2)))
    local add = totalEff - valueLocal
    return add

    --]]
end

-- 宠物点化预览  items需经过筛选后
function Formula:petDianhuaAdd(shape, shapeBasic, pet, items)
    -- shapeBasic可能为负值，为保证使用点化丹后，宠物获得的属性加成值为正值，在此取绝对值
    shapeBasic = math.abs(shapeBasic)

    if type(items) ~= "table" then return end
    if not pet then return end

    local nimbus = self:getPetDianhuaNimbusByItems(items)
    local totalNimbus = self:getPetDianhuaMaxNimbus(pet)

    -- math.floor(math.floor( 29 / 100 * 100)) == 28!!!!!!!!!!!!   防止该问题，tosting再tonumber
    local temp = math.floor(0.3 * math.min(pet:queryBasicInt("enchant_nimbus") / totalNimbus, 1) * 100) / 100 * shapeBasic
    local valueLocal = math.floor(tonumber(tostring(temp)))

    local temp2 = math.floor(0.3 * math.min((nimbus + pet:queryBasicInt("enchant_nimbus")) / totalNimbus, 1) * 100) / 100 * shapeBasic
    local totalEff = math.floor(tonumber(tostring(temp2)))
    local add = totalEff - valueLocal
    return add
end

-- 幻化的效果
function Formula:petHuanhuaAdd(pet, field)
    local hmax = PetMgr:getHuanProgressMax(pet)
    local fieldMap = {life_effect = "life", mana_effect = "mana", speed_effect = "speed", phy_effect = "phy", mag_effect = "mag"}
    local cur = pet:queryBasicInt(string.format("morph_%s_stat", fieldMap[field]))
    if cur + 1 ~= hmax then return 0 end

    local per = 0.06

    local basic = PetMgr:getPetBasicShape(pet, field)
    -- 变异系数为8%   变异宠物的法功系数为12%   ,变异宠物不计算附加成长(神兽与变异宠物计算方式相同)
    local rank = pet:queryInt('rank')
    if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
        if field == "mag_effect" then
            per = 0.12
        else
            per = 0.08
        end

        basic = basic - PetMgr:getPetAdditionalValue(pet, field)
    end


    return math.max(math.floor(basic * per), 1)
end

-- 当前等级升级每天可得总经验      mainPetReqLevel主宠携带等级
function Formula:getPetEvolveCost(mainPetReqLevel, otherPetReqLevel)
    local costMap = {
        [1] = 10,        [5] = 50,        [15] = 150,
        [20] = 200,      [25] = 300,      [30] = 400,
        [35] = 500,      [40] = 600,      [45] = 750,
        [50] = 900,      [55] = 1050,     [60] = 1200,
        [65] = 1400,     [70] = 1600,     [75] = 1800,
        [80] = 2000,     [85] = 2250,     [90] = 2500,
        [95] = 2750,     [100] = 3000,    [105] = 3300,
        [110] = 3600,    [115] = 3900,    [120] = 4200,
    }

    if mainPetReqLevel > otherPetReqLevel then return 0 end

    if mainPetReqLevel == otherPetReqLevel then return costMap[mainPetReqLevel] end

    local totalCost = 0
    for level, cost in pairs(costMap) do
        if mainPetReqLevel < level and otherPetReqLevel >= level then
            totalCost = totalCost + cost
        end
    end

    return totalCost
end


-- 当前等级升级每天可得总经验
function Formula:getDayExp(level)

    return (level * 3 + 7) * 51750;
end

function Formula:getElitePetBasicAddByValue(value)
    return math.floor((value + 40) * 0.2)
end

-- 获取宠物飞升后成长增加值
function Formula:getPerFlyUpgradeAddValue(basic, pet_type, field)
    local GROWTH_TYPE = {
        ["life"] = 1.2,     ["mana"] = 1.1,
        ["speed"] = 1.3,    ["mag"] = 1.2,      ["phy"] = 1.2,
    }

    local PET_TYPE = {
        [CHS[3000025]] = 1.2,  -- 变异
        [CHS[3003814]] = 1.2, --神兽
        [CHS[6000519]] = 1.05, -- 精怪
    }

    local ds1 = GROWTH_TYPE[field]
    local ds2 = PET_TYPE[pet_type] or 1
    local addValue
    if pet_type == CHS[3000025] or pet_type == CHS[3003814] then -- 变异，神兽
        addValue = (ds1 * ds2 - 1) * (100 + basic - 40) - math.floor(basic * 0.2)
    else
        addValue = (ds1 * ds2 - 1) * (100 + basic - 40)
    end
    -- Log:D("INT:" .. field .. math.floor(tonumber(tostring(addValue))))
    return math.floor(tonumber(tostring(addValue)))
end

-- 获取宠物妖石属性的计算公式
function Formula:getPetStoneAttri(item_name, level)
    local item = {}
    item.name = item_name
    item.extra = {}
    item.nimbus = math.floor(level * 1000 + 3000)
    item.extra["2_group"] = 1
    if item_name == CHS[3002738] then
        item.extra.max_life_2 = math.floor(100 * level * level)
    elseif item_name == CHS[3004454] then
        item.extra.max_mana_2 = math.floor(66 * level * level)
    elseif item_name == CHS[3002739] then
        item.extra.speed_2 = math.floor(32 * level)
    elseif item_name == CHS[3002740] then
        item.extra.def_2 = math.floor(30 * level * level)
    elseif item_name == CHS[3002741] then
        item.extra.phy_power_2 = math.floor(66 * level * level)
    elseif item_name == CHS[3002742] then
        item.extra.mag_power_2 = math.floor(66 * 0.66 * level * level)
    else
        return {}
    end

    return item
end

-- 获取经验等级差削减系数
function Formula:getExpBalance(delta) -- delta为自身等级减去目标等级
    if delta == 0 then
        return 1.0
    end

    if delta > 0 then
        local ret = 1.0 - 0.03 * delta
        if ret > 0.0 then
            return ret
        else
            return 0.0
        end
    end

    if delta < -15 then
        return 0.0
    end

    if delta == -11 then
        return 0.4
    elseif delta == -12 then
        return 0.16
    elseif delta == -13 then
        return 0.06
    elseif delta == -14 then
        return 0.03
    elseif delta == -15 then
        return 0.01
    end

    return 1.0
end

-- 是否在某个多边形内   pt 点，  Polygon多边形点的表
function Formula:ptInPolygon(pt, polygon)
    local nCross = 0
    for i = 1, #polygon do
        local p1 = {x = polygon[i].x, y = polygon[i].y}
        local nextIndex = i + 1
        if nextIndex > #polygon then nextIndex = 1 end
        local p2 = {x = polygon[nextIndex].x, y = polygon[nextIndex].y}

        -- 求解 y=p.y 与 p1p2 的交点
        if p1.y ~= p2.y and pt.y >= math.min(p1.y, p2.y) and pt.y < math.max(p1.y, p2.y) then
            local tempX = (pt.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;
            if tempX > pt.x then
                nCross = nCross + 1 -- 只统计单边交点
            end
        end
    end
    return (nCross % 2 == 1)
end

-- 当前等级法宝的最大灵气
function Formula:getArtifactMaxNimbus(level)
    if not level then
        return 0
    end

    return (100 * level * level + 300) * 5
end

-- 计算两个平行于x轴的矩形重叠部分面积
-- (x1, y1)矩形1左下角点， (x2, y2)矩形1右上角点
-- (x3, y3)矩形2左下角点， (x4, y4)矩形2右上角点
function Formula:getRectOvelLapArea(x1, y1, x2, y2, x3, y3, x4, y4)
    local area = 0
    local overLapX = (x2 - x1) + (x4 - x3) - (math.max(x2, x4) - math.min(x1, x3))
    local overLapY = (y2 - y1) + (y4 - y3) - (math.max(y2, y4) - math.min(y1, y3))
    if overLapX > 0 and overLapY > 0 then
        area = overLapX * overLapY
    end

    return area
end

-- 获取法宝触发几率
function Formula:getArtifactTriggerPercent(artifact)

    local level = artifact.level
    -- 获取亲密加成，文档中命名为P，所以getP
    local function getP( intimacy )
        -- body
        if intimacy <= 10000 then
            return 0.02
        elseif intimacy <= 100000 then
            return 0.03
        elseif intimacy <= 500000 then
            return 0.05
        else
            return 0.08
        end
    end

    local ret
    if level < 16 then
        local value1 = math.pow(level, 1.8) * 0.3 * ( 1 + getP(artifact.intimacy))
        value1 = math.floor( value1 * 100 ) / 100

        local value2 = math.pow(level, 1.8) * 0.3 * ( 1 + 0)
        value2 = math.floor( value2 * 100 ) / 100
        ret = value1 - value2
    else
        local value1 = math.pow(level, 1.12) * 2 * ( 1 + getP(artifact.intimacy))
        value1 = math.floor( value1 * 100 ) / 100

        local value2 = math.pow(level, 1.12) * 2 * ( 1 + 0)
        value2 = math.floor( value2 * 100 ) / 100

        ret = value1 - value2
    end


    ret = math.max(ret, 0.01)
    return ret
end

return Formula
