-- EquipmentMgr.lua
-- Created by songcw Api/21/2015
-- 装备管理器

EquipmentMgr = Singleton()
local EquipmentAtt = require(ResMgr:getCfgPath("EquipmentAttribute.lua"))
local EquipAllAtt = require(ResMgr:getCfgPath("EquipAttribute.lua"))
local JewelryCompose = require(ResMgr:getCfgPath("JewelryCompose.lua"))
local ResonanceAttrib = require(ResMgr:getCfgPath("GongmingAttribConfig.lua"))

-- 装备属性最大值最小值
local EquipAttchMax = require(ResMgr:getCfgPath("EquipAttchMax.lua"))
local EquipAttchMin = require(ResMgr:getCfgPath("EquipAttchMin.lua"))
local EquipSuitMax = require(ResMgr:getCfgPath("EquipSuitMax.lua"))
local EquipSuitMin = require(ResMgr:getCfgPath("EquipSuitMin.lua"))

local Bitset = require('core/Bitset')

local active_blue_level   = 25
local active_pink_level   = 40
local active_yellow_level = 50

local active_jewelry_level = 35

local attrib_blue = 1
local attrib_pink = 2
local attrib_yellow = 3
local attrib_green = 4

local UPGRADE_LEVEL_MAX = 120

local EQUIP_REQ_LEVEL_MAX = 100

-- 装备进化等级最大
local EQUIP_EVOLVE_LEVEL_MAX = 19

-- 装备共鸣人物等级要求
local GONGMING_PLAYER_LEVEL = 70

-- 装备共鸣装备等级要求
local GONGMING_EQUIP_LEVEL = 70

local EQUIP_MAX_LEVEL = 125

local POLAR_CONFIG =
    {
        [POLAR.METAL] = CHS[3002405],
        [POLAR.WOOD] = CHS[3002406],
        [POLAR.WATER] = CHS[3002407],
        [POLAR.FIRE] = CHS[3002408],
        [POLAR.EARTH] = CHS[3002409],
    }

local equipPosMap = {
    [1] = EQUIP.WEAPON,
    [2] = EQUIP.HELMET,
    [3] = EQUIP.ARMOR,
    [4] = EQUIP.BOOT,
}

local equipBackPosMap = {
    [1] = EQUIP.BACK_WEAPON,
    [2] = EQUIP.BACK_HELMET,
    [3] = EQUIP.BACK_ARMOR,
    [4] = EQUIP.BACK_BOOT,
}

-- 首饰属性基本评分信息表
local JEWELRY_SCORE = {
    ["str"] = 100,      ["dex"] = 100,      ["wiz"] = 100,      ["con"] = 89,
    ["all_polar"] = 134,
    ["all_skill"] = 100,
    ["ignore_resist_confusion"] = 89,
    ["ignore_resist_sleep"] = 89,
    ["ignore_resist_frozen"] = 89,
    ["ignore_resist_poison"] = 89,
    ["ignore_resist_forgotten"] = 89,
    ["ignore_all_resist_except"] = 89,
    ["all_resist_except"] = 89,

    ["resist_forgotten"] = 20,
    ["resist_poison"] = 20,
    ["resist_frozen"] = 20,
    ["resist_sleep"] = 20,
    ["resist_confusion"] = 20,

    ["basic_att"] = 100,
    ["basic_resist"] = 134,

    -- 取最大值
    ["the_max_arrtib_count"] = 2,
    ["the_max_arrtib_1"] = {["str"] = 1, ["wiz"] = 1},
    ["the_max_arrtib_2"] = {["ignore_resist_confusion"] = 1, ["ignore_resist_sleep"] = 1, ["ignore_resist_frozen"] = 1, ["ignore_resist_poison"] = 1, ["ignore_resist_forgotten"] = 1},
}

local weaponType = { CHS[3003962], CHS[3003963], CHS[3003964], CHS[3003965], CHS[3003966] }
local hatType = { CHS[3003967], CHS[3003968] }
local clothType = { CHS[3003969], CHS[3003970] }
local bootType = { CHS[3003971] }

-- 武器基础属性
local weaponAttri = {
    [1]     = { phy_power = 38,   mag_power = 38  },
    [10]    = { phy_power = 106,  mag_power = 106 },
    [20]    = { phy_power = 199,  mag_power = 199 },
    [30]    = { phy_power = 312,  mag_power = 312 },
    [40]    = { phy_power = 444,  mag_power = 444 },
    [50]    = { phy_power = 594,  mag_power = 594 },
    [60]    = { phy_power = 763,  mag_power = 763 },
    [70]    = { phy_power = 952,  mag_power = 952 },
    [80]    = { phy_power = 1159, mag_power = 1159 },
    [90]    = { phy_power = 1385, mag_power = 1385 },
    [100]   = { phy_power = 1630, mag_power = 1630 },
    [110]   = { phy_power = 1894, mag_power = 1894 },
    [120]   = { phy_power = 2176, mag_power = 2176 },
}

-- 衣服基础属性
local clothAttri = {
    [1]     = { max_life = 35,  max_mana = 24,    def = 14 },
    [10]    = { max_life = 98,  max_mana = 65,    def = 41 },
    [20]    = { max_life = 185,  max_mana = 123,  def = 78 },
    [30]    = { max_life = 289,  max_mana = 192,  def = 122 },
    [40]    = { max_life = 411,  max_mana = 273,  def = 174 },
    [50]    = { max_life = 550,  max_mana = 366,  def = 233 },
    [60]    = { max_life = 707,  max_mana = 470,  def = 299 },
    [70]    = { max_life = 882,  max_mana = 586,  def = 373 },
    [80]    = { max_life = 1074, max_mana = 714,  def = 454 },
    [90]    = { max_life = 1283, max_mana = 854,  def = 543 },
    [100]   = { max_life = 1963, max_mana = 1307, def = 639 },
    [110]   = { max_life = 2281, max_mana = 1519, def = 742 },
    [120]   = { max_life = 2621, max_mana = 1746, def = 853 },
}

-- 帽子基础属性
local hatAttri = {
    [1]     = { max_life = 20,  max_mana = 13,  def = 8, },
    [10]    = { max_life = 56,  max_mana = 37,  def = 24, },
    [20]    = { max_life = 105, max_mana = 70,  def = 47, },
    [30]    = { max_life = 165, max_mana = 110, def = 73, },
    [40]    = { max_life = 235, max_mana = 156, def = 104, },
    [50]    = { max_life = 314, max_mana = 209, def = 139, },
    [60]    = { max_life = 404, max_mana = 269, def = 179, },
    [70]    = { max_life = 504, max_mana = 335, def = 224, },
    [80]    = { max_life = 613, max_mana = 408, def = 272, },
    [90]    = { max_life = 733, max_mana = 488, def = 325, },
    [100]   = { max_life = 1121, max_mana = 747, def = 383, },
    [110]   = { max_life = 1303, max_mana = 868, def = 445, },
    [120]   = { max_life = 1498, max_mana = 997, def = 512, },
}

-- 鞋子基础属性
local bootAttri = {
    [1]     = { speed = 24,  def = 5, },
    [10]    = { speed = 40,  def = 16, },
    [20]    = { speed = 58,  def = 31, },
    [30]    = { speed = 76,  def = 49, },
    [40]    = { speed = 94,  def = 69, },
    [50]    = { speed = 112, def = 93, },
    [60]    = { speed = 130, def = 119, },
    [70]    = { speed = 148, def = 149, },
    [80]    = { speed = 166, def = 181, },
    [90]    = { speed = 184, def = 217, },
    [100]   = { speed = 202, def = 255, },
    [110]   = { speed = 220, def = 297, },
    [120]   = { speed = 238, def = 341, },
}

local EQUIP_ATTRI = {
    [EQUIP.WEAPON]  = weaponAttri,
    [EQUIP.ARMOR]   = clothAttri,
    [EQUIP.HELMET]  = hatAttri,
    [EQUIP.BOOT]    = bootAttri,
}

local EQUIP_TYPE_TO_POS =
{
    [EQUIP_TYPE.WEAPON] = EQUIP.WEAPON,
    [EQUIP_TYPE.HELMET] = EQUIP.HELMET,
    [EQUIP_TYPE.ARMOR] = EQUIP.ARMOR,
    [EQUIP_TYPE.NECKLACE] = EQUIP.NECKLACE,
    [EQUIP_TYPE.BALDRIC] = EQUIP.BALDRIC,
    [EQUIP_TYPE.WRIST] = EQUIP.LEFT_WRIST,
    [EQUIP_TYPE.TALISMAN] = EQUIP.TALISMAN,
    [EQUIP_TYPE.ARTIFACT] = EQUIP.ARTIFACT,
    [EQUIP_TYPE.BOOT] = EQUIP.BOOT,
    [EQUIP_TYPE.FASHION_SUIT] = EQUIP.FASHION_SUIT,
    [EQUIP_TYPE.FASHION_JEWELRY] = EQUIP.FASHION_JEWELRY,
}

-- 装备附加字段
local EQUIP_ADD_ATTRIB =
{
    [EQUIP_TYPE.WEAPON] = {"power","str","con","wiz","dex","accurate","double_hit_rate","counter_attack_rate","stunt_rate","metal","wood","water","fire","earth","all_polar","all_skill","ignore_all_resist_polar","ignore_all_resist_except",},
    [EQUIP_TYPE.ARMOR] = {"def","max_life","max_mana","str","con","wiz","dex","all_attrib","damage_sel_rate","resist_metal","resist_wood","resist_water","resist_fire","resist_earth","resist_poison","resist_frozen","resist_sleep","resist_forgotten","resist_confusion","all_resist_polar","all_resist_except"},
    [EQUIP_TYPE.HELMET] = {"def","max_life","max_mana","str","con","wiz","dex","all_attrib","double_hit","counter_attack","damage_sel"},
    [EQUIP_TYPE.BOOT] = {"def","speed","str","con","wiz","dex","all_attrib","double_hit","counter_attack","damage_sel"},

    [EQUIP_TYPE.WRIST] = {"str", "con", "wiz", "dex","all_polar", "all_skill", "ignore_resist_metal", "ignore_resist_wood", "ignore_resist_water", "ignore_resist_fire", "ignore_resist_earth", "ignore_resist_forgotten", "ignore_resist_poison", "ignore_resist_frozen", "ignore_resist_sleep", "ignore_resist_confusion", "ignore_all_resist_except"},
    [EQUIP_TYPE.NECKLACE] = {"str", "con", "wiz", "dex", "resist_metal", "resist_wood", "resist_water", "resist_fire", "resist_earth", "resist_poison", "resist_frozen", "resist_sleep", "resist_forgotten", "resist_confusion", "all_polar", "all_resist_except", "all_skill"},
    [EQUIP_TYPE.BALDRIC] = {"str", "con", "wiz", "dex", "resist_metal", "resist_wood", "resist_water", "resist_fire", "resist_earth", "resist_poison", "resist_frozen", "resist_sleep", "resist_forgotten", "resist_confusion", "all_polar", "all_resist_except", "all_skill"},
}

-- 绿属性
local GREEN_ADD_ATTRIB =
{
    [CHS[3003965]] = {"enhanced_metal", "super_forgotten", "ignore_resist_metal", "ignore_resist_forgotten"},   -- 枪
    [CHS[3003966]] = {"enhanced_wood", "super_poison", "ignore_resist_wood", "ignore_resist_poison"},           -- 爪
    [CHS[3003964]] = {"enhanced_water", "super_frozen", "ignore_resist_water", "ignore_resist_frozen"},         -- 剑
    [CHS[3003962]] = {"enhanced_fire", "super_sleep", "ignore_resist_fire", "ignore_resist_sleep"},             -- 扇
    [CHS[3003963]] = {"enhanced_earth", "super_confusion", "ignore_resist_earth", "ignore_resist_confusion"},   -- 锤
    [EQUIP_TYPE.WEAPON] = {"super_excluse_metal", "super_excluse_wood", "super_excluse_water", "super_excluse_fire", "super_excluse_earth", "enhanced_phy", "ignore_mag_dodge", "penetrate_rate"},
    [EQUIP_TYPE.HELMET] = {"B_skill_low_cost", "C_skill_low_cost", "D_skill_low_cost", "penetrate"},
    [EQUIP_TYPE.ARMOR] = {"resist_poison", "resist_frozen", "resist_sleep", "resist_forgotten", "resist_confusion", "release_forgotten", "release_poison", "release_frozen", "release_sleep", "release_confusion", "penetrate"},
    [EQUIP_TYPE.BOOT] = {"mag_dodge", "B_skill_low_cost", "C_skill_low_cost", "D_skill_low_cost", "penetrate"}
}

-- 套装暗属性
local SUIT_ADD_ATTRIB =
{
    "mag_power", "max_life", "def", "speed", "phy_power"
}

-- 装备鉴定花费
local equipIndentifyCost =
{
        [EQUIP.WEAPON]  = {[50] = 50000, [60] = 100000, [70] = 150000, [80] = 200000, [90] = 300000, [100] = 400000, [110] = 500000, [120] = 600000},
        [EQUIP.ARMOR]   = {[50] = 50000, [60] = 100000, [70] = 150000, [80] = 200000, [90] = 300000, [100] = 450000, [110] = 600000, [120] = 750000},
        [EQUIP.HELMET]  = {[50] = 25000, [60] = 50000, [70] = 75000, [80] = 100000, [90] = 200000, [100] = 300000, [110] = 400000, [120] = 500000},
        [EQUIP.BOOT]    = {[50] = 25000, [60] = 50000, [70] = 75000, [80] = 100000, [90] = 200000, [100] = 300000, [110] = 400000, [120] = 500000},
}

-- 鉴定闹事花费表 cost消耗金钱，outPut为产出
local IDENTIFY_GEM_COST =
{
        [70] = {cost = 280000, outPut = {[1] = CHS[4100421], [2] = CHS[4100421]}},
        [80] = {cost = 380000, outPut = {[1] = CHS[4100421], [2] = CHS[4100422]}},
        [90] = {cost = 490000, outPut = {[1] = CHS[4100421], [2] = CHS[4100422]}},
        [100] = {cost = 670000, outPut = {[1] = CHS[4100421], [2] = CHS[4100422]}},
        [110] = {cost = 900000, outPut = {[1] = CHS[4100422], [2] = CHS[4100423]}},
        [120] = {cost = 1120000, outPut = {[1] = CHS[4100422], [2] = CHS[4100423]}},
        [130] = {cost = 1240000, outPut = {[1] = CHS[4100422], [2] = CHS[4100423]}},
        [140] = {cost = 1560000, outPut = {[1] = CHS[4100423], [2] = CHS[4100424]}},
        [150] = {cost = 1730000, outPut = {[1] = CHS[4100423], [2] = CHS[4100424]}},
        [160] = {cost = 1910000, outPut = {[1] = CHS[4100423], [2] = CHS[4100424]}},
        [170] = {cost = 2140000, outPut = {[1] = CHS[4100423], [2] = CHS[4100424]}},
        [180] = {cost = 2300000, outPut = {[1] = CHS[4100424], [2] = CHS[4100424]}},

}

local JEWELRY_EXPENSIVE_ATTRIB =
{
    ["all_skill"] = 5,
    ["all_polar"] = 3,
    ["ignore_all_resist_except"] = 12,
    ["ignore_resist_forgotten"] = 18,
    ["ignore_resist_poison"] = 18,
    ["ignore_resist_frozen"] = 18,
    ["ignore_resist_sleep"] = 18,
    ["ignore_resist_confusion"] = 18,
    ["all_resist_except"] = 12,
}

-- 首饰基本属性
local MaterialAtt = {
    [EQUIP.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
}

-- 蓝属性
EquipmentMgr.equipBlueData = {}

-- 粉属性
EquipmentMgr.equipPinkData = {}

-- 黄属性
EquipmentMgr.equipYellowData = {}

-- 套装
EquipmentMgr.equipSuitData = {}

-- 改造
EquipmentMgr.equipUpgradeData = {}
EquipmentMgr.equipUpgradeCost = {}

-- 首饰
EquipmentMgr.equipJewelryData = {}
EquipmentMgr.equipJewelryCost = {}

EquipmentMgr.preEvolveEquip = {}
EquipmentMgr.preDegenerationEquip = {}

-- 法宝不同相性所带来的属性加成描述
local POLAR_ATTRIB = {
    [1] = CHS[7000146],
    [2] = CHS[7000147],
    [3] = CHS[7000148],
    [4] = CHS[7000149],
    [5] = CHS[7000150],
    [6] = CHS[4100937],
    [7] = CHS[4100938],
    [8] = CHS[4100939],
    [9] = CHS[4100940],
    [10] = CHS[4100941],
}

local ARTIFACT_ORDER = {
    [CHS[7000137]] = 3,
    [CHS[7000138]] = 4,
    [CHS[7000139]] = 5,
    [CHS[7000140]] = 2,
    [CHS[7000141]] = 7,
    [CHS[7000142]] = 6,
    [CHS[7000143]] = 1,
}

-- 共鸣属性与改造等级有关
local GONGMING_ATTRIB_CONFIG = {
    [1] = {min = 0, rate = 0},
    [2] = {min = 0, rate = 0},
    [3] = {min = 0, rate = 0},
    [4] = {min = 1, rate = 5},
    [5] = {min = 2, rate = 15},
    [6] = {min = 3, rate = 50},
    [7] = {min = 4, rate = 100},
    [8] = {min = 5, rate = 160},
    [9] = {min = 6, rate = 230},
    [10] = {min = 7, rate = 310},
    [11] = {min = 8, rate = 400},
    [12] = {min = 9, rate = 500},
}

-- 首饰重铸消耗的精华
local JEWELRY_REFINE_COST_ESSENCE = {
    [80]  = 70,
    [90]  = 120,
    [100] = 180,
}

-- 首饰分解可获得的精华
local JEWELRY_DECO_GET_ESSENCE = {
    [80] = 35,
    [90] = 60,
    [100] = 90,
    [110] = 120,
    [120] = 150,
}

local allEquipmentInfo = nil

function EquipmentMgr:dataClean()
    self.equipBlueData = {}
    self.equipPinkData = {}
    self.equipYellowData = {}
    self.equipSuitData = {}
    self.equipUpgradeData = {}
    self.equipUpgradeCost = {}
    self.equipJewelryData = {}
    self.equipJewelryCost = {}

    EquipmentMgr.preEvolveEquip = {}
    EquipmentMgr.preDegenerationEquip = {}

    self.lastSwithTime = nil
end

-- 装备共鸣人物等级要求
function EquipmentMgr:getEquipGongmingPlayerLevel()
    return GONGMING_PLAYER_LEVEL
end

-- 装备共鸣装备等级要求
function EquipmentMgr:getEquipGongmingPlayerLevel()
    return GONGMING_EQUIP_LEVEL
end

-- 法宝相性带来的属性加成
function EquipmentMgr:getPolarAttribByArtifact(artifact)

    local polar = artifact.item_polar or 0
    local eff = artifact.artifact_upgraded_enabled or 0

    return POLAR_ATTRIB[polar + eff * 5]
end

-- 法宝相性带来的属性加成
function EquipmentMgr:getPolarAttrib(polar)
    return POLAR_ATTRIB[polar]
end

-- 法宝技能描述
function EquipmentMgr:getArtifactSkillDesc(name)
    local skillDesc = SkillMgr:getSkillDesc(name)
    return skillDesc and skillDesc.desc
end

function EquipmentMgr:getEquipAttribCfgInfo()
    return EQUIP_ADD_ATTRIB
end

function EquipmentMgr:getEquipGreenCfgInfo()
    return GREEN_ADD_ATTRIB
end

function EquipmentMgr:getEquipSuitCfgInfo()
    return SUIT_ADD_ATTRIB
end

function EquipmentMgr:getEquipEvolveLevelMax()
    return EQUIP_EVOLVE_LEVEL_MAX
end

function EquipmentMgr:getEquipMaxLevel()
    return EQUIP_MAX_LEVEL
end

function EquipmentMgr:getEquipReqLevelMax()
    return EQUIP_REQ_LEVEL_MAX
end

function EquipmentMgr:isActiveByCrystal(crystal)
    local meLevel = Me:queryBasicInt("level")
    if crystal == CHS[4000064] then
        if meLevel < active_blue_level then
            gf:ShowSmallTips(string.format(CHS[4000348], active_blue_level))
            return false
        end
    elseif crystal == CHS[4000078] then
        if meLevel < active_pink_level then
            gf:ShowSmallTips(string.format(CHS[4000348], active_pink_level))
            return false
        end
    elseif crystal == CHS[4000105] then
        if meLevel < active_yellow_level then
            gf:ShowSmallTips(string.format(CHS[4000348], active_yellow_level))
            return false
        end
    end

    return true
end

function EquipmentMgr:getAllAttField()
    return EquipmentAtt[CHS[3003972]]
end

function EquipmentMgr:getJewelryLevel()
    return active_jewelry_level
end

function EquipmentMgr:getAttribsTabByName(str)
    return EquipmentAtt[str]
end

function EquipmentMgr:getAttribChsOrEng(field)
    return EquipmentAtt[field]
end

function EquipmentMgr:getBlueAttrib(pos)
    local atrib = self:getAttrib(pos, attrib_blue)
    return atrib
end

function EquipmentMgr:getPinkAttrib(pos)
    local atrib = self:getAttrib(pos, attrib_pink)
    return atrib
end

function EquipmentMgr:getMeNeedPinkMaterialName()
    local polar = Me:queryBasicInt("polar")
    if polar == 1 then
        return CHS[4000349]
    elseif polar == 2 then
        return CHS[4000350]
    elseif polar == 3 then
        return CHS[4000351]
    elseif polar == 4 then
        return CHS[4000352]
    elseif polar == 5 then
        return CHS[4000353]
    end
end

function EquipmentMgr:getYellowAttrib(pos)
    local atrib = self:getAttrib(pos, attrib_yellow)
    return atrib
end

function EquipmentMgr:getAttrib(pos, attribType)
    local greenTab = {}
    local yellowTab = {}
    local pinkTab = {}
    local blueTab = {}
    local equip = InventoryMgr:getItemByPos(pos)
    for _,v in pairs(EquipmentAtt[CHS[4000098]]) do
        -- 绿属性
        local greenStr = string.format("%s_%d", v, Const.FIELDS_PROP4)
        if equip.extra[greenStr] ~= nil then
            local data = {value = equip.extra[greenStr], field = v}
            table.insert(greenTab, {value = equip.extra[greenStr], field = v})
        end

        -- 黄属性
        local yellowStr = string.format("%s_%d", v, Const.FIELDS_PROP3)
        if equip.extra[yellowStr] ~= nil then
            table.insert(yellowTab, {value = equip.extra[yellowStr], field = v})
        end

        -- 粉属性
        local pinkStr = string.format("%s_%d", v, Const.FIELDS_EXTRA2)
        if equip.extra[pinkStr] ~= nil then
            table.insert(pinkTab, {value = equip.extra[pinkStr], field = v})
        end

        -- 蓝属性
        local blueStr = string.format("%s_%d", v, Const.FIELDS_EXTRA1)
        if equip.extra[blueStr] ~= nil and v ~= "phy_power" and v ~= "mag_power" then
            table.insert(blueTab, {value = equip.extra[blueStr], field = v})
        end
    end

    if attribType == attrib_blue then
        return blueTab
    elseif attribType == attrib_pink then
        return pinkTab
    elseif attribType == attrib_yellow then
        return yellowTab
    elseif attribType == attrib_green then
        return greenTab
    end
end

function EquipmentMgr:getAttribOrder(pos)
    local wiz = Me:queryBasicInt("wiz")
    local str = Me:queryBasicInt("str")

    if str >= wiz then
        --物攻类型
        if pos == EQUIP.WEAPON then
            return EquipmentAtt[CHS[4000068]]
        elseif pos == EQUIP.ARMOR then
            return EquipmentAtt[CHS[4000069]]
        elseif pos == EQUIP.HELMET then
            return EquipmentAtt[CHS[4000070]]
        elseif pos == EQUIP.BOOT then
            return EquipmentAtt[CHS[4000071]]
        end
    else
        --法功类型
        if pos == EQUIP.WEAPON then
            return EquipmentAtt[CHS[4000072]]
        elseif pos == EQUIP.ARMOR then
            return EquipmentAtt[CHS[4000073]]
        elseif pos == EQUIP.HELMET then
            return EquipmentAtt[CHS[4000074]]
        elseif pos == EQUIP.BOOT then
            return EquipmentAtt[CHS[4000075]]
        end
    end

end

function EquipmentMgr:getMaterialLevelByEquipLevel(equipLevel)
    equipLevel = equipLevel or 0
    if equipLevel < 40 then
        return 3
    else
        return math.floor(equipLevel / 10)
    end
end

function EquipmentMgr:queryValuByField(field, type ,pos)
    if type == attrib_blue then
        if EquipmentMgr.equipBlueData[pos] then
            return EquipmentMgr.equipBlueData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE)] or 0
        end
    elseif type == attrib_pink then
        if EquipmentMgr.equipPinkData[pos] then
            return EquipmentMgr.equipPinkData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE)] or 0
        end
    elseif type == attrib_yellow then
        if EquipmentMgr.equipYellowData[pos] then
            return EquipmentMgr.equipYellowData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE)] or 0
        end
    end
end

function EquipmentMgr:MSG_UPGRADE_EQUIP_COST(data)
    if data.upgrade_type == Const.UPGRADE_EQUIP_UPGRADE then
        self.equipUpgradeCost[data.pos] = data
    elseif data.upgrade_type == Const.UPGRADE_EQUIP_JEWELRY then
        self.equipJewelryCost[data.pos] = data
    end
end

function EquipmentMgr:MSG_PRE_UPGRADE_EQUIP(data)
    if data.upgrade_type == Const.UPGRADE_EQUIP_REFINE_BLUE or data.upgrade_type == Const.UPGRADE_EQUIP_REFINE_BLUE_ALL then
        if self.equipBlueData[data.pos] == nil then
            self.equipBlueData[data.pos] = data
            DlgMgr:sendMsg("EquipmentRefiningAttributeDlg", "setDegreeAndMax")
        end
        self.equipBlueData[data.pos] = data
        DlgMgr:sendMsg("EquipmentRefiningAttributeDlg","setAttribDlgInfo")
    elseif data.upgrade_type == Const.UPGRADE_EQUIP_REFINE_PINK or data.upgrade_type == Const.UPGRADE_EQUIP_REFINE_PINK_ALL then
        if self.equipPinkData[data.pos] == nil then
            self.equipPinkData[data.pos] = data
            DlgMgr:sendMsg("EquipmentRefiningAttributeDlg", "setDegreeAndMax")
        end
        self.equipPinkData[data.pos] = data
        DlgMgr:sendMsg("EquipmentRefiningAttributeDlg","setAttribDlgInfo")
    elseif data.upgrade_type == Const.UPGRADE_EQUIP_REFINE_YELLOW or data.upgrade_type == Const.UPGRADE_EQUIP_REFINE_YELLOW_ALL then
        if self.equipYellowData[data.pos] == nil then
            self.equipYellowData[data.pos] = data
            DlgMgr:sendMsg("EquipmentRefiningAttributeDlg", "setDegreeAndMax")
        end
        self.equipYellowData[data.pos] = data
        DlgMgr:sendMsg("EquipmentRefiningAttributeDlg","setAttribDlgInfo")
    elseif data.upgrade_type == Const.UPGRADE_EQUIP_SUIT then
        if not self.equipSuitData[data.pos] then
            self.equipSuitData[data.pos] = data
            DlgMgr:sendMsg("EquipmentRefiningSuitDlg", "setProssBar")
        else
            self.equipSuitData[data.pos] = data
        end
        DlgMgr:sendMsg("EquipmentRefiningSuitDlg","setEquipment")
    elseif data.upgrade_type == Const.UPGRADE_EQUIP_UPGRADE then
        self.equipUpgradeData[data.pos] = data
        DlgMgr:sendMsg("EquipmentUpgradeDlg","MSG_PRE_UPGRADE_EQUIP")
    elseif data.upgrade_type == Const.UPGRADE_EQUIP_JEWELRY then
        self.equipJewelryData[data.pos] = data
        DlgMgr:sendMsg("JewelryMakeDlg","MSG_PRE_UPGRADE_EQUIP")
    elseif data.upgrade_type == Const.EQUIP_EVOLVE_PREVIEW then
        EquipmentMgr.preEvolveEquip[data.pos] = data
    elseif data.upgrade_type == Const.EQUIP_DEGENERATION_PREVIEW then
        EquipmentMgr.preDegenerationEquip[data.pos] = data
    end
end

-- 进化预览装备是否会丢失绿属性
function EquipmentMgr:evolvePreEquipLoseGreen(equip, missType)
    if equip.pos > 40 then return false end    -- 包裹中的装备
    if equip.suit_enabled ~= 1 then return end -- 绿暗属性不生效

    local minLevel = 150
    local equipMap = equipPosMap
    if equip.pos > 10 then equipMap = equipBackPosMap end
    if Me:queryBasicInt("equip_page") + 1 == 1 then
        for i = 1,4 do
            local equipTemp = InventoryMgr:getItemByPos(equipMap[i])
            if not equipTemp then return false end
            minLevel = math.min(minLevel, equipTemp.req_level)
        end

        local tips1 = ""
        local tips2 = ""
        if equip.pos <= 10 then
            tips1 = CHS[4200161]  -- 1
            tips2 = string.format(CHS[4200162], equip.req_level + 1)
        else
            tips1 = CHS[4200163]
            tips2 = string.format(CHS[4200164], equip.req_level + 1)
        end

        if missType == 1 then
            if equip.req_level - minLevel == 3 then
                return true, tips1
            end
        else
            if equip.req_level % 10 == 9 then
                return true, tips2
            end
        end
        return false
    end

    minLevel = 150
    if Me:queryBasicInt("equip_page") + 1 == 2 then
        for i = 1,4 do
            local equipTemp = InventoryMgr:getItemByPos(equipMap[i])
            if not equipTemp then return false end
            minLevel = math.min(minLevel, equipTemp.req_level)
        end

        local tips1 = ""
        local tips2 = ""
        if equip.pos <= 10 then
            tips1 = CHS[4200163] -- 2
            tips2 = string.format(CHS[4200164], equip.req_level + 1)
        else
            tips1 = CHS[4200161] -- 1
            tips2 = string.format(CHS[4200162], equip.req_level + 1)
        end

        if missType == 1 then
            if equip.req_level - minLevel == 3 then
                return true, tips1
            end
        else
            if equip.req_level % 10 == 9 then
                return true, tips2
            end
        end
        return false
    end
end

-- 退化预览装备是否会丢失绿属性
function EquipmentMgr:degenerationPreEquipLoseGreen(equip, missType)
    if equip.pos > 40 then return false end    -- 包裹中的装备
    if equip.suit_enabled ~= 1 then return end -- 绿暗属性不生效

    local maxLevel = 0
    local equipMap = equipPosMap
    if equip.pos > 10 then equipMap = equipBackPosMap end
    if Me:queryBasicInt("equip_page") + 1 == 1 then
        for i = 1, 4 do
            local equipTemp = InventoryMgr:getItemByPos(equipMap[i])
            if not equipTemp then return false end
            maxLevel = math.max(maxLevel, equipTemp.req_level)
        end

        local tips1 = ""
        local tips2 = ""
        if equip.pos <= 10 then
            tips1 = CHS[7002063]
            tips2 = string.format(CHS[7002065], equip.req_level - 1)
        else
            tips1 = CHS[7002064]
            tips2 = string.format(CHS[7002066], equip.req_level - 1)
        end

        if missType == 1 then
            if maxLevel - equip.req_level == 3 then
                return true, tips1
            end
        else
            if equip.req_level % 10 == 0 then
                return true, tips2
            end
        end
        return false
    end

    maxLevel = 0
    if Me:queryBasicInt("equip_page") + 1 == 2 then
        for i = 1,4 do
            local equipTemp = InventoryMgr:getItemByPos(equipMap[i])
            if not equipTemp then return false end
            maxLevel = math.max(maxLevel, equipTemp.req_level)
        end

        local tips1 = ""
        local tips2 = ""
        if equip.pos <= 10 then
            tips1 = CHS[7002064] -- 2
            tips2 = string.format(CHS[7002066], equip.req_level - 1)
        else
            tips1 = CHS[7002063] -- 1
            tips2 = string.format(CHS[7002065], equip.req_level - 1)
        end

        if missType == 1 then
            if maxLevel - equip.req_level == 3 then
                return true, tips1
            end
        else
            if equip.req_level % 10 == 0 then
                return true, tips2
            end
        end

        return false
    end
end


function EquipmentMgr:getEquipParentType(equipType)
    if nil == equipType then return end

    for i = 1, 5 do
        if weaponType[i] and equipType == weaponType[i] then
            return EQUIP.WEAPON
        end

        if hatType[i] and equipType == hatType[i] then
            return EQUIP.HELMET
        end

        if clothType[i] and equipType == clothType[i] then
            return EQUIP.ARMOR
        end

        if bootType[i] and equipType == bootType[i] then
            return EQUIP.BOOT
        end
    end
end

function EquipmentMgr:getTenLvEquipNameByPolar(polar)
    if polar == POLAR.METAL then
        return CHS[3003973]
    elseif polar == POLAR.WOOD then
        return CHS[3003974]
    elseif polar == POLAR.WATER then
        return CHS[3003975]
    elseif polar == POLAR.FIRE then
        return CHS[3003976]
    elseif polar == POLAR.EARTH then
        return CHS[3003977]
    end
end

function EquipmentMgr:MSG_EQUIP_CARD(data)
    local cardInfo = data["cardInfo"]
    local item = gf:deepCopy(InventoryMgr:getItemInfoByName(cardInfo["name"]))
    if cardInfo and cardInfo.item_type then
    else
        cardInfo.equip_type = self:getEquipParentType(item.equipType)
        cardInfo.polar = item.polar
        cardInfo.pos = nil -- 排行榜不需要显示已装备图片
        cardInfo.item_type = ITEM_TYPE.EQUIPMENT -- 需要物品类型来判断是不是贵重物品
    end
    InventoryMgr:showEquipByEquipment(cardInfo, nil, true)
end

function EquipmentMgr:identifyEquip(pos, para)

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.UPGRADE_EQUIP_IDENTIFY,
        para = para,
    })
end

function EquipmentMgr:delicateIdentifyEquip(pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_DELICATE,
        para = para,
    })
end

function EquipmentMgr:evolveEquip(pos, limit)

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_EVOLVE,
        para = limit,
    })
end

function EquipmentMgr:evolvePreEquip(pos)
    gf:CmdToServer("CMD_PRE_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_EVOLVE_PREVIEW,
        para = 1
    })
end

-- 装备退化请求
function EquipmentMgr:degenerationEquip(pos, limit)

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_DEGENERATION,
        para = limit,
    })
end

-- 装备退化预览信息请求
function EquipmentMgr:degenerationPreEquip(pos)
    gf:CmdToServer("CMD_PRE_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_DEGENERATION_PREVIEW,
        para = 1
    })
end

-- 获取装备类型，1为装备，2为首饰，3为时装，4为法宝
function EquipmentMgr:GetEquipType(itemType)
    if itemType == EQUIP.NECKLACE or itemType == EQUIP.BALDRIC
        or itemType == EQUIP.LEFT_WRIST or itemType == EQUIP.RIGHT_WRIST  then

        return 2
    end

    if itemType == EQUIP_TYPE.FASHION_SUIT
        or itemType == EQUIP_TYPE.FASHION_JEWELRY
        or itemType == EQUIP_TYPE.FASHION_PART then
        return  3
    end

    if itemType == EQUIP_TYPE.ARTIFACT then
        return 4
    end

    if  itemType <= 10 then
        return 1
    end

    return
end

function EquipmentMgr:CMD_EQUIP(pos, jewelryType)
    local equip = InventoryMgr:getItemByPos(pos)
    if not equip then return end
    local equip_part = jewelryType or EQUIP_TYPE_TO_POS[equip.equip_type]

    if not equip_part then
        return
    end

  --[[  if equip_part == EQUIP_TYPE.WRIST and InventoryMgr:getItemByPos(equip_part) and not InventoryMgr:getItemByPos(equip_part + 1) then
        equip_part = equip_part + 1
    end]]

    if equip.req_level > Me:queryBasicInt("level") then
        gf:ShowSmallTips(CHS[3003978])
		return
    end

    -- 背包判断
    if pos > InventoryMgr:getCanUseMaxPos() then
        -- 如果装备的位置在禁用的包裹中
        if not InventoryMgr:getFirstEmptyPos() then
            gf:ShowSmallTips(CHS[7000176])
            return
        end
    end

    -- 婚服性别判断
    if equip.fasion_type == FASION_TYPE.WEDDING and equip.gender ~= Me:queryInt("gender") then
        gf:confirm(string.format(CHS[4100660], equip.name), function()
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4100661]))
            end)
        return
    end

    -- 时装性别判断
    if equip.fasion_type == FASION_TYPE.FASION and equip.gender ~= Me:queryInt("gender") then
        gf:confirm(string.format(CHS[4100662], equip.name), function()
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4100663]))
        end)
        return
    end

    gf:CmdToServer("CMD_EQUIP", {
        pos = pos,
        equip_part = equip_part,
    })
end

function EquipmentMgr:CMD_UNEQUIP(pos)
    local equip = InventoryMgr:getItemByPos(pos)
    if not equip then return end

    if not InventoryMgr:getFirstEmptyPos() then
        if equip.item_type == ITEM_TYPE.ARTIFACT then  -- 法宝
            gf:ShowSmallTips(CHS[7000176])
            return
        end

        gf:ShowSmallTips(CHS[7000176])
        return
    end

    gf:CmdToServer("CMD_UNEQUIP", {
        from_pos = pos,
        to_pos = InventoryMgr:getFirstEmptyPos(),
    })

end

function EquipmentMgr:isSplitEquip(equip)
    if equip
        and equip.item_type == ITEM_TYPE.EQUIPMENT
        and equip.req_level >= 50
        and equip.rebuild_level == 0
        and equip.unidentified == 0
        and (equip.equip_type == EQUIP_TYPE.WEAPON or equip.equip_type == EQUIP_TYPE.HELMET or equip.equip_type == EQUIP_TYPE.BOOT or equip.equip_type == EQUIP_TYPE.ARMOR)
        and (equip.color == CHS[3003981] or equip.color == CHS[3003982] or equip.color == CHS[3003983])
        and not InventoryMgr:isTimeLimitedItem(equip) then
        return true
    end

    return false
end

function EquipmentMgr:getSplitEquip()
    -- 先取穿上的装备
    local equipOrderTab = {}
 --[[   for i = 1, 4 do
        local equip = InventoryMgr:getItemByPos(equipPosMap[i])
        if EquipmentMgr:isSplitEquip(equip) then
            table.insert(equipOrderTab, equipPosMap[i])
        end
    end]]

    -- 取背包里的装备
    local bagEquipTab = InventoryMgr:filterBagItemsByType(ITEM_TYPE.EQUIPMENT)
    local bagSplitEquips = {}
    for _,v in ipairs(bagEquipTab) do
        local equip = InventoryMgr:getItemByPos(v.pos)
        if EquipmentMgr:isSplitEquip(equip) then
            table.insert(bagSplitEquips, {pos = v.pos, icon = v.icon})
        end
    end

    table.sort(bagSplitEquips, function(l, r)
        if l.icon < r.icon then return true end
        if l.icon > r.icon then return false end
        if l.pos < r.pos then return true end
        if l.pos > r.pos then return false end
    end)

    for _,v in ipairs(bagSplitEquips) do
        table.insert(equipOrderTab, v.pos)
    end

    return equipOrderTab
end

function EquipmentMgr:getSplitCostMoney(equip)
    if not equip then return 0 end
    local lv = equip.req_level

    if lv < 70 then
        return 0
    end

    local cost = lv * 700 + 3000

    -- 装备拆分手续费受占卜任务影响
    cost = cost * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_ZBCF)

    return cost
end

function EquipmentMgr:cmdSplitEquip(pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.UPGRADE_EQUIP_SPLIT,
        para = para
    })
end

function EquipmentMgr:getEquipChs(equipType)
    if equipType == EQUIP_TYPE.WEAPON then
        return CHS[3003984]
    elseif equipType == EQUIP_TYPE.ARMOR then
        return CHS[3003985]
    elseif equipType == EQUIP_TYPE.HELMET then
        return CHS[3003986]
    elseif equipType == EQUIP_TYPE.BOOT then
        return CHS[3003987]
    end
end

function EquipmentMgr:getJewelryFromBag()
    local items = InventoryMgr:getAllInventory()
    local jewelries = {}
    for pos, equip in pairs(items) do
        if equip.item_type == ITEM_TYPE.EQUIPMENT and self:isJewelry(equip)
                and InventoryMgr:isBagItemByPos(pos) then
            table.insert(jewelries, equip)
        end
    end

    return jewelries
end

function EquipmentMgr:isValidEquipPos(pos)
    return pos <= 10;
end

function EquipmentMgr:isJewelry(equip)
    if equip.item_type ~= ITEM_TYPE.EQUIPMENT then return false end

    if equip.equip_type == EQUIP_TYPE.NECKLACE or equip.equip_type == EQUIP_TYPE.BALDRIC or equip.equip_type == EQUIP_TYPE.WRIST then
        return true
    end

    return false
end

-- 是否存在对应的未鉴定装备
function EquipmentMgr:isExistUnidentifiedEquip(type)
    if type == EQUIP_TYPE.WEAPON or type == EQUIP_TYPE.HELMET
        or type == EQUIP_TYPE.ARMOR or type == EQUIP_TYPE.BOOT then
        return true
    end

    return false
end

-- 根据等级获取装备的基础属性
function EquipmentMgr:getBasicAttriByLevel(equipType, level)
    if EQUIP_ATTRI[equipType] then
        return EQUIP_ATTRI[equipType][math.floor(level / 10) * 10]
    end
end

function EquipmentMgr:getPolarRes(polar)
    if polar == POLAR.METAL then
        return ResMgr.ui.polar_metal
    elseif polar == POLAR.WOOD then
        return ResMgr.ui.polar_wood
    elseif polar == POLAR.WATER then
        return ResMgr.ui.polar_water
    elseif polar == POLAR.FIRE then
        return ResMgr.ui.polar_fire
    elseif polar == POLAR.EARTH then
        return ResMgr.ui.polar_earth
    end
end

-- 获取身上的装备和背包装备
function EquipmentMgr:getAllEquipments(isExcludeTimeLimited)
    local equipments = {}

    -- 身上的装备
    for i = 1, 4 do
        local equip = InventoryMgr:getItemByPos(equipPosMap[i])
        if equip then
            if isExcludeTimeLimited and not InventoryMgr:isTimeLimitedItem(equip) or not isExcludeTimeLimited then
                table.insert(equipments, equipPosMap[i])
            end
        end
    end

    -- 身上的备用装备
    for i = 1, 4 do
        local equip = InventoryMgr:getItemByPos(equipBackPosMap[i])
        if equip then
            if isExcludeTimeLimited and not InventoryMgr:isTimeLimitedItem(equip) or not isExcludeTimeLimited then
                table.insert(equipments, equipBackPosMap[i])
            end
        end
    end

    -- 背包的装备
    local bagEquipTab = InventoryMgr:getBagAllEquip()
    local bagSplitEquips = {}
    for _,v in ipairs(bagEquipTab) do
        local equip = InventoryMgr:getItemByPos(v.pos)
        if  equip.unidentified == 0
            and (isExcludeTimeLimited and not InventoryMgr:isTimeLimitedItem(equip) or not isExcludeTimeLimited) then
            table.insert(bagSplitEquips, {pos = v.pos, icon = v.icon})
        end
    end

    table.sort(bagSplitEquips, function(l, r)
        if l.icon < r.icon then return true end
        if l.icon > r.icon then return false end
    end)

    for _,v in ipairs(bagSplitEquips) do
        table.insert(equipments, v.pos)
    end

    return equipments
end

function EquipmentMgr:getAllArtifacts()
    local artifacts = {}

    -- 身上的法宝
    local equippedArtifact = InventoryMgr:getItemByPos(EQUIP.ARTIFACT)
    if equippedArtifact then
        table.insert(artifacts, equippedArtifact)
    end

    -- 身上的备用法宝
    local backArtifact = InventoryMgr:getItemByPos(EQUIP.BACK_ARTIFACT)
    if backArtifact then
        table.insert(artifacts, backArtifact)
    end

    -- 背包的装备
    local bagArtifacts = InventoryMgr:getBagAllArtifacts()
    if #bagArtifacts == 0 then
        return artifacts
    end

    for i = 1, #bagArtifacts do
        bagArtifacts[i].order = ARTIFACT_ORDER[bagArtifacts[i].name]
    end

    table.sort(bagArtifacts, function(l, r)
        if l.level > r.level then return true end
        if l.level < r.level then return false end

        if l.intimacy > r.intimacy then return true end
        if l.intimacy < r.intimacy then return false end

        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    for i = 1, #bagArtifacts do
        table.insert(artifacts, bagArtifacts[i])
    end

    return artifacts
end

-- 获取武器的改造费用
function EquipmentMgr:getUpgradeCost(level)
    local cost = 0
    if not level or level < 70 then return cost end

    cost = level * level * 16 + 5000

    -- 装备改造手续费受占卜任务影响
    cost = cost * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_ZBGZ)

    return cost
end

-- 获取炼化粉属性金钱消耗
function EquipmentMgr:getRefiningPinkCost(level)
    local cost = 0
    if level < 70 then return cost end
    cost = level * level * 16 + 5000

    -- 装备炼化：炼化粉属性手续费受占卜任务影响
    cost = cost * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_ZBLH)

    return cost
end


-- 获取属性强化
function EquipmentMgr:getStrengthenCost(level, color)
    local cost = 0
    if level < 70 then return cost end
    if color == CHS[3002568] or color == CHS[3002569] then
        cost = level * level * 16 + 5000
    elseif color == CHS[3002570] or color == CHS[3002571] then
        cost = level * level * 24 + 7500
    end

    return cost
end

-- 改造
function EquipmentMgr:cmdUpgradeEquip(pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.UPGRADE_EQUIP_UPGRADE,
        para = para
    })

end

function EquipmentMgr:getSuitMinAndMax(equip, field)
    if not equip then return end
    local equip_type = equip.equip_type or EQUIP_TYPE.WEAPON

    -- 套装
    local min, max

    if EquipSuitMin[field] and EquipSuitMin[field][equip_type] and EquipSuitMin[field][equip_type][equip.req_level] then
        min = EquipSuitMin[field][equip_type][equip.req_level]
    end

    if EquipSuitMax[field] and EquipSuitMax[field][equip_type] and EquipSuitMax[field][equip_type][equip.req_level] then
        max = EquipSuitMax[field][equip_type][equip.req_level]
    end

    if max then
        return min, max
    end

    if field == "max_life" then
        min = math.floor(self:formulaStdLife(equip.req_level) * 0.06)
        max = math.floor(math.floor(self:formulaStdLife(equip.req_level)) * 0.06 * 3.6)
    elseif field == "def" then
        min = math.floor(math.floor(self:formulaStdLife(equip.req_level) / 15) * 0.5 * 0.25)
        max = math.floor(math.floor(self:formulaStdLife(equip.req_level) / 15) * 0.5 * 1.4)
    elseif field == "speed" then
        min = math.floor(equip.req_level * 2 * 0.1)
        max = math.floor(equip.req_level * 2 * 0.41)
    elseif field == "phy_power" then
        min = math.floor(math.floor(self:formulaStdLife(equip.req_level) * 0.4) * 0.4 * 0.1)
        max = math.floor(math.floor(self:formulaStdLife(equip.req_level) * 0.4) * 0.4 * 0.32)
    elseif field == "mag_power" then
        min = math.floor(math.floor(self:formulaStdLife(equip.req_level) * 0.4) * 0.4 * 0.03)
        max = math.floor(math.floor(self:formulaStdLife(equip.req_level) * 0.4) * 0.4 * 0.18)
    else

    end

    return min, max
end

-- 附加属性最大值
function EquipmentMgr:getAttribMaxValueByField(equip, field)
    if not equip then return end
    local equipType = tonumber(equip.equip_type)

    if EquipAttchMax[field] and EquipAttchMax[field][equipType] and EquipAttchMax[field][equipType][equip.req_level] then
        return EquipAttchMax[field][equipType][equip.req_level]
    end

    if EquipmentAtt[CHS[3003988]][field] then
        return EquipmentAtt[CHS[3003988]][field].max
    end

    -- 正常情况不会走到这
    if field == "power" then
        return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.4 * 0.4 * 0.7), field)
    elseif field == "def" then
        local maxPercent = 0 -- 最大值系数
        if equip.req_level >= 100 then
            maxPercent = 1.2
        else
            maxPercent = 0.95
        end

        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) / 15 * 0.5 * maxPercent), field)
        else
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) / 15 * 0.25 * maxPercent), field)
        end
    elseif field == "max_life" then
        local maxPercent = 0 -- 最大值系数
        if equip.req_level >= 100 then
            maxPercent = 1.05
        else
            maxPercent = 0.85
        end

        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.105 * maxPercent), field)
        else
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.06 * maxPercent), field)
        end
    elseif field == "max_mana" then
        local maxPercent = 0 -- 最大值系数
        if equip.req_level >= 100 then
            maxPercent = 5
        else
            maxPercent = 2.1
        end

        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdMana(equip.req_level) * 0.105 * maxPercent), field)
        else
            return self:getIntValue(math.floor(self:formulaStdMana(equip.req_level) * 0.06 * maxPercent), field)
        end
    elseif field == "speed" then
        return self:getIntValue(math.floor(equip.req_level * 2 * 0.67), field)
    elseif field == "str" then
        return math.floor(equip.req_level * 0.25)
    elseif field == "con" then
        return math.floor(equip.req_level * 0.25)
    elseif field == "wiz" then
        return math.floor(equip.req_level * 0.25)
    elseif field == "dex" then
        return math.floor(equip.req_level * 0.25)
    elseif field == "all_attrib" then
        return math.floor(equip.req_level * 0.2)
    elseif field == "mstunt_rate" then
        -- 目前装备法术必杀率只能从装备共鸣中产出，数值只与改造等级有关
        if equip.rebuild_level then
            local ind = tonumber(equip.rebuild_level)
            if GONGMING_ATTRIB_CONFIG[ind] then
                return math.max(GONGMING_ATTRIB_CONFIG[ind].rate * 10 / 100, GONGMING_ATTRIB_CONFIG[ind].min)
            end
        end

        return 0
    end
end

-- 附加属性最小值
function EquipmentMgr:getAttribMinValueByField(equip, field)
    if not equip then return end
    local equipType = tonumber(equip.equip_type)

    if EquipAttchMin[field] and EquipAttchMin[field][equipType] and EquipAttchMin[field][equipType][equip.req_level] then
        return EquipAttchMin[field][equipType][equip.req_level]
    end

    if EquipmentAtt[CHS[3003988]][field] then
        return EquipmentAtt[CHS[3003988]][field].min
    end

    -- 正常情况不会走到这
    if field == "power" then
        return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.4 * 0.4 * 0.05), field)
    elseif field == "def" then
        local maxPercent = 0 -- 最大值系数
        if equip.req_level >= 100 then
            maxPercent = 0.3
        else
            maxPercent = 0.25
        end

        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) / 15 * 0.5 * maxPercent), field)
        else
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) / 15 * 0.25 * maxPercent), field)
        end
    elseif field == "max_life" then
        local maxPercent = 0 -- 最大值系数
        if equip.req_level >= 100 then
            maxPercent = 0.3
        else
            maxPercent = 0.25
        end

        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.105 * maxPercent), field)
        else
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.06 * maxPercent), field)
        end
    elseif field == "max_mana" then
        local maxPercent = 0 -- 最大值系数
        if equip.req_level >= 100 then
            maxPercent = 1
        else
            maxPercent = 0.5
        end

        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.105 * maxPercent), field)
        else
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.06 * maxPercent), field)
        end
    elseif field == "speed" then
        return self:getIntValue(math.floor(equip.req_level * 2 * 0.15), field)
    elseif field == "str" then
        return math.floor(equip.req_level * 0.1)
    elseif field == "con" then
        return math.floor(equip.req_level * 0.1)
    elseif field == "wiz" then
        return math.floor(equip.req_level * 0.1)
    elseif field == "dex" then
        return math.floor(equip.req_level * 0.1)
    elseif field == "all_attrib" then
        return math.floor(equip.req_level * 0.05)
    elseif field == "mstunt_rate" then
        -- 目前装备法术必杀率只能从装备共鸣中产出，数值只与改造等级有关
        return 0
    end
end

-- 附加属性标称值
function EquipmentMgr:getAttribStdValueByField(equip, field)
    local equipType = tonumber(equip.equip_type)
    if field == "power" then
        return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.4 * 0.4 * 0.3), field)
    elseif field == "def" then
        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) / 15 * 0.5 * 0.55), field)
        else
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) / 15 * 0.25 * 0.55), field)
        end
    elseif field == "max_life" then
        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.105 * 0.5), field)
        else
            return self:getIntValue(math.floor(self:formulaStdLife(equip.req_level) * 0.06 * 0.5), field)
        end
    elseif field == "max_mana" then
        if equipType == EQUIP_TYPE.ARMOR then
            return self:getIntValue(math.floor(self:formulaStdMana(equip.req_level) * 0.105 * 0.7), field)
        else
            return self:getIntValue(math.floor(self:formulaStdMana(equip.req_level) * 0.06 * 0.7), field)
        end
    elseif field == "speed" then
        return self:getIntValue(math.floor(equip.req_level * 2 * 0.3), field)
    elseif field == "str" then
        return math.floor(equip.req_level * 0.15)
    elseif field == "con" then
        return math.floor(equip.req_level * 0.15)
    elseif field == "wiz" then
        return math.floor(equip.req_level * 0.15)
    elseif field == "dex" then
        return math.floor(equip.req_level * 0.15)
    elseif field == "all_attrib" then
        return math.floor(equip.req_level * 0.1)
    else
        if EquipmentAtt[CHS[3003988]][field] then
            return EquipmentAtt[CHS[3003988]][field].norm
        end
    end
end

-- 标准气血
function EquipmentMgr:getIntValue(score, field)
    if field == "power" or field == "def" or  field == "max_life" or field == "max_mana" or field == "speed" then
        if score >= 10000 then
            return math.floor(score / 1000) * 1000
        elseif score >= 5000 then
            if field == "power" then
                return math.floor(score / 200) * 200
            end
            return math.floor(score / 500) * 500
        elseif score >= 2000 then
            return math.floor(score / 200) * 200
        elseif score >= 1000 then
            return math.floor(score / 100) * 100
        elseif score >= 500 then
            return math.floor(score / 50) * 50
        elseif score >= 200 then
            return math.floor(score / 20) * 20
        elseif score >= 100 then
            return math.floor(score / 10) * 10
        elseif score >= 30 then
            return math.floor(score / 5) * 5
        else
            return score
        end
    else
        return score
    end
end

-- 标准法力
function EquipmentMgr:formulaStdMana(level)
    return 0.93 * (level - 1) * (level - 1) + 56 * (level - 1) + 80
end

-- 标准气血
function EquipmentMgr:formulaStdLife(level)
    return math.floor(1.39 * (level - 1) * (level - 1) + 85 * (level - 1) + 100)
end

-- 血量公式
function EquipmentMgr:formulaFLife(level)
    return 1.39 * (level - 1) * (level - 1) + 85 * (level - 1) + 100
end

-- 获取全部装备信息
function EquipmentMgr:getAllEquipmentInfo()
    if not allEquipmentInfo then
        allEquipmentInfo = {}
        for i, v in pairs(InventoryMgr:getAllItemInfo()) do
            if v.equipType then
                v.name = i
                table.insert(allEquipmentInfo, v)
            end
        end
    end
    return allEquipmentInfo
end

-- 分解首饰
-- 使用 “|” 拼接需要分解首饰的背包位置
function EquipmentMgr:cmdDecomposeJewelry(data)
    if not data or not next(data) then
        return
    end

    local str = ""
    for i = 1, #data do
        if data[i].pos then
            if str ~= "" then
                str = str .. "|"
            end

            str = str .. data[i].pos
        end
    end

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = 0,
        type = Const.EQUIP_SPLITE_JEWELRY,
        para = str,
    })
end

-- 获取可分解的首饰
function EquipmentMgr:getCanDecomposeJewelry(getExpensive)
    local jewelrys = self:getJewelryFromBag()
    local cdJewelrys = {}
    for _, v in ipairs(jewelrys) do
        if v.req_level >= 80
            and not InventoryMgr:isTimeLimitedItem(v) then
            -- 首饰等级>=80级、非限时首饰、未穿戴、
            if getExpensive then
                if gf:isExpensive(v) then
            table.insert(cdJewelrys, v)
        end
            elseif not gf:isExpensive(v) then
                -- 非贵重首饰
                table.insert(cdJewelrys, v)
    end
        end
    end

    return cdJewelrys
end

-- 分解首饰可获得的精华
function EquipmentMgr:getDecJewelryGetEssence(level)
    return JEWELRY_DECO_GET_ESSENCE[level]
end

-- 重铸首饰需要消耗的精华
function EquipmentMgr:getRefineJewelryCostEssence(level)
    return JEWELRY_REFINE_COST_ESSENCE[level]
end

-- 获取可重铸的首饰
function EquipmentMgr:getCanRefineJewelry()
    local items = InventoryMgr:getAllInventory()
    local crJewelrys = {}
    for _, v in pairs(items) do
        if v.item_type == ITEM_TYPE.EQUIPMENT
            and self:isJewelry(v)
            and v.req_level >= 80
            and v.req_level <= 100
            and not InventoryMgr:isTimeLimitedItem(v) then
            -- 100级>=首饰等级>=80级、非限时首饰
            table.insert(crJewelrys, v)
        end
    end

    table.sort(crJewelrys, function(l, r)
        if l.pos < r.pos then return true end
    end)

    return crJewelrys
end

-- 获取重铸首饰信息
function EquipmentMgr:getAllRefineJewelry()
    local classRefineJewelry = {}
    for i = 1, #JewelryCompose do
        local class = JewelryCompose[i]["kind"]
        if not classRefineJewelry[class] then
            classRefineJewelry[class] = {}
        end

        -- 目前可重铸首饰等级限制80~100
        if JewelryCompose[i].level >= 80 and JewelryCompose[i].level <= 100 then
            table.insert(classRefineJewelry[class], JewelryCompose[i])
        end
    end

    return classRefineJewelry
end

-- 首饰合成的材料
function EquipmentMgr:getAllComposeJewelry()
    local classComposeJewelry = {}
    for i = 1, #JewelryCompose do
        local class = JewelryCompose[i]["kind"]
        if not classComposeJewelry[class] then
            classComposeJewelry[class] = {}
        end

        -- 低级首饰不需要合成
        if JewelryCompose[i].level > 20 then
            table.insert(classComposeJewelry[class], JewelryCompose[i])
        end
    end

    return classComposeJewelry
end

-- 获取首饰属性
function EquipmentMgr:getComposeJewelryInfoByName(itemName)
    local equipment = {}
    for i = 1, #JewelryCompose do
        if JewelryCompose[i].name == itemName  then
            equipment.name = itemName
            equipment.req_level = JewelryCompose[i].level
            equipment.kind = JewelryCompose[i].kind
            equipment.extra = {}
            local attrib = string.match(JewelryCompose[i]["attrib"], CHS[3003989])
            if JewelryCompose[i].kind == CHS[3003990] then
                equipment.extra.max_life_1 = attrib
            elseif JewelryCompose[i].kind == CHS[3003991] then
                equipment.extra.max_mana_1 = attrib
            elseif JewelryCompose[i].kind == CHS[3003992] then
                equipment.extra.phy_power_1 = attrib
            end
            break
        end
    end

    return equipment
end

function EquipmentMgr:getBaseAttStr(extra)
    if extra.max_life_1 then
        return CHS[3002422] .. ":" .. extra.max_life_1
    elseif extra.max_mana_1 then
        return CHS[3002423] .. ":" .. extra.max_mana_1
    elseif extra.phy_power_1 then
        return CHS[4000032] .. ":" .. extra.phy_power_1
    end
end

-- 获取某等级的所有装备
function EquipmentMgr:getEquipmentsByLevel(level)

    level = math.floor(level / 10) * 10

    local equipment = {}
    if not allEquipmentInfo then
        allEquipmentInfo = self:getAllEquipmentInfo()
    end

    for i, v in pairs(allEquipmentInfo) do
        if v.req_level == level and
            (v.equipType == CHS[3001208]   -- "枪"
            or v.equipType == CHS[3001209] -- "爪"
            or v.equipType == CHS[3001210] -- "剑"
            or v.equipType == CHS[3001211] -- "扇"
            or v.equipType == CHS[3001212] -- "锤"
            or v.equipType == CHS[3001213] -- "男帽"
            or v.equipType == CHS[3001214] -- "女帽"
            or v.equipType == CHS[3001215] -- "男衣"
            or v.equipType == CHS[3001216] -- "女衣"
            or v.equipType == CHS[3001217]) then -- "鞋"
            table.insert(equipment, v)
        end
    end

    table.sort(equipment, function(l, r)
        if l.icon < r.icon then return true end
        if l.icon > r.icon then return false end
    end)
    return equipment
end

-- 装备重组
function EquipmentMgr:equipReform(pos, posStr)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.UPGRADE_EQUIP_REFORM,
        para = posStr,
    })
end

-- 套装  para ＝ "0|0"    是否使用限定、相性
function EquipmentMgr:equipSuitRefining(pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_REFINE_SUIT,
        para = para,
    })
end

-- 装备共鸣
function EquipmentMgr:equipResonance(resonanceType, pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = resonanceType,
        para = para,
    })
end

-- 装备炼化
function EquipmentMgr:equipRefining(refiningType, pos, para)
    local type
    if refiningType == "EquipmentRefiningYellowDlg" then
        type = Const.UPGRADE_EQUIP_REFINE_GOLD
    elseif refiningType == "EquipmentRefiningPinkDlg" then
        type = Const.UPGRADE_EQUIP_REFINE_PINK
    else
        return
    end

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = type,
        para = para,
    })

end

-- 装备强化
function EquipmentMgr:equipStrength(strengthType, pos, para)
    local type
    if strengthType == attrib_blue then
        type = Const.UPGRADE_EQUIP_STRENGTHEN_BLUE
    elseif strengthType == attrib_pink then
        type = Const.UPGRADE_EQUIP_STRENGTHEN_PINK
    elseif strengthType == attrib_yellow then
        type = Const.UPGRADE_EQUIP_STRENGTHEN_GOLD
    else
        return
    end

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = type,
        para = para,
    })
end

-- 装备强化完成度
function EquipmentMgr:getAttribCompletion(equip, field, attType)
    local prop
    if attType == attrib_blue then
        prop = Const.BLUE_COMPLETION
    elseif attType == attrib_pink then
        prop = Const.PINK_COMPLETION
    elseif attType == attrib_yellow then
        prop = Const.GOLD_COMPLETION
    else
        return
    end

    if field then
        local str = field .. "_" .. prop
        return equip.extra[str] or 0
    end
end

function EquipmentMgr:getPercentSymbolByField(field)
    if field == "" then return "" end
    if EquipmentMgr:getAttribsTabByName(CHS[3003993])[field] then return "%" end
    return ""
end

-- 通过属性表获取中文，例如（con, true）    体质：x/max
function EquipmentMgr:getAttribChs(attrib, isMax, equip)
    local bai = EquipmentMgr:getPercentSymbolByField(attrib.field)

    if EquipmentMgr:getAttribChsOrEng(attrib.field) ~= nil then
        local str = EquipmentMgr:getAttribChsOrEng(attrib.field) .. ":" .. attrib.value .. bai
        if isMax then
            local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, attrib.field) or ""
            str = str .. "/" .. maxValue .. bai
        end
        return str
    end
    return ""
end

-- 通过属性表获取中文，例如（con, true）    体质：x/max
function EquipmentMgr:getAttribChsSuit(attrib, isMax, equip)
    local bai = ""

    if EquipmentMgr:getAttribsTabByName(CHS[3003993])[attrib.field] then bai = "%" end

    if EquipmentMgr:getAttribChsOrEng(attrib.field) ~= nil then
        local str = EquipmentMgr:getAttribChsOrEng(attrib.field) .. ":" .. attrib.value .. bai
     --   local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, attrib.field) or ""
        if isMax then
            local min, max = EquipmentMgr:getSuitMinAndMax(equip, attrib.field)
            str = str .. "/" .. max .. bai
        end
        return str
    end
    return ""
end

function EquipmentMgr:getEquipPolarChs(suit_polar)
    if suit_polar == POLAR.METAL then
        return CHS[3003994]
    elseif suit_polar == POLAR.WOOD then
        return CHS[3003995]
    elseif suit_polar == POLAR.WATER then
        return CHS[3003996]
    elseif suit_polar == POLAR.FIRE then
        return CHS[3003997]
    elseif suit_polar == POLAR.EARTH then
        return CHS[3003998]
    end
end

-- 装备进化花费
function EquipmentMgr:getEvolveCost(level)
    local cost = level * 10000

    -- 装备进化手续费受占卜任务影响
    cost = cost * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_ZBJH)

    return cost
end

-- 首饰重铸花费
function EquipmentMgr:getJewelryUpgradeCost(level)
    local cost = level * 10000

    -- 首饰重铸手续费受占卜任务影响
    cost = cost * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_SSCZ)

    return cost
end

-- 首饰合成花费天星石
function EquipmentMgr:getEvolveCostItem(level)
    if not level then return 1 end
    return math.max(1, math.floor(level / 10) - 7)
end

-- 首饰合成花费
function EquipmentMgr:getJewelryXomposeCost(level)
    local cost = 0

    if level >= 110 then
        cost = 10000 * level
    elseif level >= 80 then
        cost = 6000 * level
    elseif level >= 50 then
        cost = 500 * level
    elseif level == 35 then
        cost = 0
    end

    -- 首饰合成手续费受占卜任务影响
    cost = cost * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_HCSS)

    return cost
end

function EquipmentMgr:getJewelryBule(jewelry)
    local atrribTable = jewelry["extra"]
    local buleAttrib = {}
    for k, v in pairs(atrribTable)do
        if string.match(k,".+_(%d*)") and tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB then
            local key = string.match(k,"(.+)_%d*")
            local order = atrribTable[key .. "_" .. Const.JEWELRY_BLUE_ORDER] or 1

            -- 需要增加最大值的显示
            local maxValue = EquipmentMgr:getAttribMaxValueByField(jewelry, key) or ""

            if EquipmentMgr:getAttribsTabByName(CHS[3003993])[key] then
                table.insert(buleAttrib, {str = string.format("%s  %d%%/%d",self:getAttribChsOrEng(key), v, maxValue) .. "%", order = order, transform = "prop/" .. key})
            else
                table.insert(buleAttrib, {str = string.format("%s  %d/%d",self:getAttribChsOrEng(key), v, maxValue), order = order, transform = "prop/" .. key})
            end
        end

        if string.match(k,".+_(%d*)") and tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB_EX then
            local key = string.match(k,"(.+)_%d*")
            local order = atrribTable[key .. "_" .. Const.JEWELRY_BLUE_ORDER_EX] or 1

            -- 需要增加最大值的显示
            local maxValue = EquipmentMgr:getAttribMaxValueByField(jewelry, key) or ""

            if EquipmentMgr:getAttribsTabByName(CHS[3003993])[key] then
                table.insert(buleAttrib, {str = string.format("%s  %d%%/%d",self:getAttribChsOrEng(key), v, maxValue) .. "%", order = order, transform = "prop2/" .. key})
            else
                table.insert(buleAttrib, {str = string.format("%s  %d/%d",self:getAttribChsOrEng(key), v, maxValue), order = order, transform = "prop2/" .. key})
            end
        end
    end

    table.sort(buleAttrib, function(l, r)
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    local orderAttrib = {}
    local transform = {}
    for _, att in pairs(buleAttrib)do
        table.insert(orderAttrib, att.str)

        table.insert(transform, att.transform)
    end

    return orderAttrib, transform
end

function EquipmentMgr:isCanWearEquip(equip, melevel)
    if equip.item_type ~= ITEM_TYPE.EQUIPMENT then return false end
    if equip.unidentified == 1 then return false end
    local mePolar = Me:queryBasicInt("polar")
    melevel =  melevel or Me:queryBasicInt("level")
    if melevel < equip.req_level then return false end

    if equip.equip_type == EQUIP_TYPE.WEAPON then
        if mePolar == equip.polar then return true end
    elseif equip.equip_type == EQUIP_TYPE.ARMOR or equip.equip_type == EQUIP_TYPE.HELMET then
        if Me:queryBasicInt("gender") == equip.gender then return true end
    else
        return true
    end

    return false
end

function EquipmentMgr:setLastTabKey(key)
	self.key = key
end

function EquipmentMgr:getLastTabKey()
    return self.key or "EquipmentSplitDlg"
end

function EquipmentMgr:setTabList(key)
    local dlg = DlgMgr.dlgs["EquipmentChildDlg"]
    if dlg then
        dlg:setListType(key)
    else
        self:setLastTabKey(key)
    end
end

-- 直接获取武器最终改造属性
function EquipmentMgr:caculateAttribOneKey(equipType, equipLevel, rebuildLevel)
    local totleAttrib = {}
    for i = 1, rebuildLevel do
        local resultAttrib = EquipmentMgr:caculateAttrib(equipType, equipLevel, rebuildLevel)
        for k, v in pairs(resultAttrib) do
            if nil == totleAttrib[k] then
                totleAttrib[k] = 0
            end

            totleAttrib[k] = totleAttrib[k] + v
        end
    end

    return totleAttrib
end

-- 获取武器单次的改造属性
function EquipmentMgr:caculateAttrib(equipType, equipLevel, rebuildLevel)
    local resultAttrib = { }

    if rebuildLevel > 12 then
        -- 超过最高改造等级
        return
    end

    if EQUIP_TYPE.WEAPON == equipType then
        if rebuildLevel > 4 then
            -- 添加所有属性
            result_attrib["all_attrib_10"] = 3
        end

        resultAttrib["phy_power_10"] = math.floor((0.38 * Formula:getStdAttack(equipLevel + 5)) / 5)
        resultAttrib["mag_power_10"] = math.floor((0.38 * Formula:getStdAttack(equipLevel + 5)) * 0.75)
    elseif  EQUIP_TYPE.HELMET == equipType or
            EQUIP_TYPE.ARMOR == equipType or
            EQUIP_TYPE.BOOT == equipType then

        if rebuildLevel > 4 and equipLevel >= 100 then
            -- 添加气血
            resultAttrib["max_life_10"] = math.floor(Formula:getStdLife(equipLevel + 5) * 0.0152)
        end

        resultAttrib["def_10"] = math.floor(0.61 * Formula:getStdDefense(equipLevel + 5) * 4 / 15)
    end

    return resultAttrib
end

-- 通过类型获取所有附加属性值
function EquipmentMgr:getAllAddAttribByEquipType(key, excepetAttribute)
    local attribStringList = {}
    local attribTable = EQUIP_ADD_ATTRIB[key]
    for i = 1, #attribTable do
        if not excepetAttribute  then
           table.insert(attribStringList, self:getAttribChsOrEng(attribTable[i]))
        else
            local needExcept = false
            for j = 1, #excepetAttribute do
                if attribTable[i] == excepetAttribute[j] then
                    needExcept = true
                    break
                end
            end

            if not needExcept then
                table.insert(attribStringList, self:getAttribChsOrEng(attribTable[i]))
            end
        end
    end

    return attribStringList
end

-- 获取共鸣属性中文名称列表
function EquipmentMgr:getGongmingAttribList()
    return ResonanceAttrib
end

-- 通过列项获取所有附加的绿属性
function EquipmentMgr:getAllSuitAttribByEquipType(key)
    local attribStringList = {}

    -- 具体的装备属性
    local attribTable = GREEN_ADD_ATTRIB[key]

    if attribTable then
        for i = 1, #attribTable do
            table.insert(attribStringList, self:getAttribChsOrEng(attribTable[i]))
        end
    end

    -- 同类型的装备属性
    local equipType = self:getEquipParentType(key)
    attribTable = GREEN_ADD_ATTRIB[equipType]

    if attribTable then
        for i = 1, #attribTable do
            table.insert(attribStringList, self:getAttribChsOrEng(attribTable[i]))
        end
    end

    return attribStringList
end

-- 获取全部武器的绿属性
function EquipmentMgr:getAllWeaponSuitAttrib()
    local attribStringList = {}

    -- 具体的装备属性
    local attribTable = {}

    local keyList = {CHS[3003962], CHS[3003963], CHS[3003964], CHS[3003965], CHS[3003966]}

    for i = 1, #keyList do
        local key = keyList[i]
        attribTable = GREEN_ADD_ATTRIB[key]
        if attribTable then
            for i = 1, #attribTable do
                table.insert(attribStringList, self:getAttribChsOrEng(attribTable[i]))
            end
        end

    end

    -- 同类型的装备属性
    attribTable = GREEN_ADD_ATTRIB[EQUIP_TYPE.WEAPON]

    if attribTable then
        for i = 1, #attribTable do
            table.insert(attribStringList, self:getAttribChsOrEng(attribTable[i]))
        end
    end

    return attribStringList
end

-- 获取炼化黄属性金钱消耗
function EquipmentMgr:getRefiningYellowCost(level)
    local cost = 0
    if not level or level < 70 then return cost end

    cost = level * level * 24 + 7500

    -- 装备炼化黄属性手续费受占卜任务影响
    cost = cost * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_ZBLH)

    return cost
end

-- 获取装备共鸣花费
function EquipmentMgr:getGongMingCost(level)
    return level * level * 32 + 10000
end

-- 获取套装暗属性
function EquipmentMgr:getSuitAttribute()
    local attribStringList = {}

    for i = 1, #SUIT_ADD_ATTRIB do
        table.insert(attribStringList, self:getAttribChsOrEng(SUIT_ADD_ATTRIB[i]))
    end

    return attribStringList
end

function EquipmentMgr:getGuideNextEquip(willEquip)
    local index = 0
    if GuideMgr.equipList then
        for i, equip in ipairs(GuideMgr.equipList) do
            if willEquip.item_unique == equip.equipId then
                local wearEquip = InventoryMgr:getItemByPos(willEquip.equip_type)
                if not wearEquip or willEquip.req_level - wearEquip.req_level >= 9 then
                    -- 寻找到当前选择的装备是礼包的装备并且大于卸下的装备9级
                    index = i
                    DlgMgr:sendMsg("BagDlg", "setCleanGuideEquip", true)
                end

                if willEquip.equip_type == EQUIP.LEFT_WRIST and not InventoryMgr:getItemByPos(EQUIP.RIGHT_WRIST) then
                    index = i
                    DlgMgr:sendMsg("BagDlg", "setCleanGuideEquip", true)
                end
            end
        end
    end

    if index > 0 then
        local pos = GuideMgr:getNextGiftEquipByIndex(index)
        if pos ~= willEquip.pos then
            DlgMgr:sendMsg("BagDlg", "selectByPos", pos)
        end
    end
end

function EquipmentMgr:getIndentifyCost(equip, indentyType)
    local euipType = equip.equip_type
    local level = equip.req_level

    local cost = equipIndentifyCost[euipType][level] or 0

    if indentyType == 2 then -- 精致鉴定
        cost = cost * 5
    end

    return cost
end

function EquipmentMgr:MSG_SUBMIT_EQUIP(data)
    local list = {}
    local bagList = InventoryMgr:getAllInventory()
    local found
    for i = 1, data.count do
        found = nil
        for k, v in pairs(bagList) do
            if data.equipList[i].id == v.item_unique then
                table.insert(list, v)
                found = true
                break
            end
        end

        if not found then
            for k, v in pairs(StoreMgr.storeFashions) do
                if data.equipList[i].id == v.item_unique then
                    table.insert(list, v)
                    break
                end
            end
        end

        if not found then
            for k, v in pairs(StoreMgr.storeEffects) do
                if data.equipList[i].id == v.item_unique then
                    table.insert(list, v)
                    break
                end
            end
        end
    end

    if self:isJewelry(list[1]) then
        local dlg = DlgMgr:openDlg("SubmitJewelryDlg")
        dlg:setIsTask()
        dlg:pushData(list)
    else
        local dlg = DlgMgr:openDlg("SubmitEquipDlg")
        dlg:setData(list, nil, data.prompt)
    end
end


function EquipmentMgr:MSG_DESTROY_VALUABLE_LIST(data)
    if data.type == Const.BUYBACK_TYPE_PET then
        -- 销毁贵重宠物
        local idList = gf:split(data.id_str, "|")
        local petList = {}
        for i = 1, #idList do
            local pet = PetMgr:getPetById(tonumber(idList[i]))
            if pet then
                table.insert(petList, pet)
            end
        end

        local dlg = DlgMgr:openDlg("SubmitPetDlg")
        dlg:setSubmintPet(petList, SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_BUYBACK)
    elseif data.type == Const.BUYBACK_TYPE_EQUIPMENT then
        -- 销毁贵重装备、首饰、法宝
        local idList = gf:split(data.id_str, "|")
        local equipList = {}
        local bagList = InventoryMgr:getAllInventory()
        for i = 1, #idList do
            local equip = InventoryMgr:getItemByPos(tonumber(idList[i]))
            if equip then
                table.insert(equipList, equip)
            end
        end

        local dlg = DlgMgr:openDlg("SubmitEquipDlg")
        dlg:setData(equipList, Const.BUYBACK_TYPE_EQUIPMENT)
    end
end

function EquipmentMgr:MSG_DESTROY_VALUABLE(data)
    local dlg = DlgMgr:openDlg("ItemDelDlg")
    dlg:setData(data)
end

function EquipmentMgr:cmdBackEquip()
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002296])
        return
    end

    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4300006])
        return
    end

    self.lastSwithTime = self.lastSwithTime or 0
    if gfGetTickCount() - self.lastSwithTime < 3000 then
        gf:ShowSmallTips(CHS[4300007])
        return
    end

    self.lastSwithTime = gfGetTickCount()
    gf:CmdToServer("CMD_SWITCH_BACK_EQUIP")
end

function EquipmentMgr:getBackEquipPos(pos)
    if pos == EQUIP.WEAPON then
        return EQUIP.BACK_WEAPON
    elseif pos == EQUIP.HELMET then
        return EQUIP.BACK_HELMET
    elseif pos == EQUIP.ARMOR then
        return EQUIP.BACK_ARMOR
    elseif pos == EQUIP.NECKLACE then
        return EQUIP.BACK_NECKLACE
    elseif pos == EQUIP.BALDRIC then
        return EQUIP.BACK_BALDRIC
    elseif pos == EQUIP.LEFT_WRIST then
        return EQUIP.BACK_LEFT_WRIST
    elseif pos == EQUIP.RIGHT_WRIST then
        return EQUIP.BACK_RIGHT_WRIST
    elseif pos == EQUIP.ARTIFACT then
        return EQUIP.BACK_ARTIFACT
    elseif pos == EQUIP.BOOT then
        return EQUIP.BACK_BOOT
    end
end

-- 获取改造属性
function EquipmentMgr:getUpgradeAtt(equip)
    local attrTab = {}
    local color = COLOR3.EQUIP_BLUE
    if EQUIP_TYPE.WEAPON == equip.equip_type then
        if equip.extra.phy_power_10 and equip.extra.phy_power_10 ~= 0 then
            table.insert(attrTab, {str = CHS[3002426] .. equip.extra.phy_power_10, color = color, field = "phy_power", value = equip.extra.phy_power_10})
        end

        if equip.extra.all_attrib_10 and equip.extra.all_attrib_10 ~= 0 then
            table.insert(attrTab, {str = CHS[3002427]..equip.extra.all_attrib_10, color = color, field = "all_attrib", value = equip.extra.all_attrib_10})
        end

    else
        if equip.extra.def_10 and equip.extra.def_10~= 0 then
            table.insert(attrTab, {str = CHS[3002428]..equip.extra.def_10, color = color, field = "def", value = equip.extra.def_10})
        end

        if equip.extra.max_life_10 and equip.extra.max_life_10 ~= 0 then
            table.insert(attrTab, {str = CHS[3002429]..equip.extra.max_life_10, color = color, field = "max_life", value = equip.extra.max_life_10})
        end
    end

    return attrTab
end

-- 获取总基本属性，即加上蓝、粉、金、改造加成后
function EquipmentMgr:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)
    local baseTab = {}
    for i = 1, #attribTab do
        local field = attribTab[i].field
        baseTab[i] = {}
        baseTab[i] = gf:deepCopy(attribTab[i])

        local isAdd = false
        for j = 1, #blueTab do
            if blueTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0) then
                    baseTab[i].value = baseTab[i].value + blueTab[j].value
                    isAdd = true
                end
            end
            if field == blueTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + blueTab[j].value
                isAdd = true
            end
        end

        for j = 1, #pinkTab do
            if pinkTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0)  then
                    baseTab[i].value = baseTab[i].value + pinkTab[j].value
                    isAdd = true
                end
            end
            if field == pinkTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + pinkTab[j].value
                isAdd = true
            end
        end

        for j = 1, #yellowTab do
            if yellowTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0)  then
                    baseTab[i].value = baseTab[i].value + yellowTab[j].value
                    isAdd = true
                end
            end
            if field == yellowTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + yellowTab[j].value
                isAdd = true
            end
        end

        for j = 1, #upgradeTab do
            if field == upgradeTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + upgradeTab[j].value
                isAdd = true
            end
        end

        baseTab[i].str = attribTab[i].attChs .. baseTab[i].value
        if isAdd or baseTab[i]["phy_power_isTotal"] == 1 or baseTab[i][field .. "_isTotal"] == 1 then
            baseTab[i].str = attribTab[i].attChs .. "#B" .. baseTab[i].value .. "#n"
            baseTab[i].value_color = COLOR3.BLUE
        end
    end

    return baseTab
end

-- 获取装备属性值信息(不显示完成度)
function EquipmentMgr:getColorAtt(attTab, colorStr, equip, isComplete)
    local destTab = {}
    local color
    local maxValue
    local colorType = 0
    if colorStr == "blue" then
        color = COLOR3.EQUIP_BLUE
        colorType = 1
    elseif colorStr == "pink" then
        color = COLOR3.EQUIP_PINK
        colorType = 2
    elseif colorStr == "yellow" then
        color = COLOR3.YELLOW
        colorType = 3
    elseif colorStr == "green" then
        color = COLOR3.EQUIP_GREEN
    elseif colorStr == "upgrade" then
        color = COLOR3.EQUIP_BLUE
    end
    --]]
    for i, att in pairs(attTab) do
        local bai = ""
        if EquipmentAtt[CHS[3002425]][att.field] then bai = "%" end

        if EquipmentAtt[att.field] ~= nil then
            local str = EquipmentAtt[att.field] .. " " .. att.value .. bai
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""
            if colorStr == "green" and att.dark == 1 then
                -- 绿属性最大值和其他不一样
                local min , max = EquipmentMgr:getSuitMinAndMax(equip, att.field)
                maxValue = max or maxValue
                -- 绿属性未激活未灰色
                if not equip.suit_enabled or equip.suit_enabled == 0 then
                    color = COLOR3.EQUIP_BLACK
                end
            end

            if isComplete then
                local completion = EquipmentMgr:getAttribCompletion(equip, att.field, colorType)
                if colorType ~= 0 and completion and completion ~= 0 then
                    str = str .. "/" .. maxValue .. bai .. " #R(+" .. completion * 0.01 .. "%)#n"
                    table.insert(destTab, {str = str, color = color, field = att.field, value = att.value, maxValue = maxValue})
                else
                    str = str .. "/" .. maxValue .. bai
                    table.insert(destTab, {str = str, color = color, field = att.field, value = att.value, maxValue = maxValue})
                end
            else
                str = str .. "/" .. maxValue .. bai
                table.insert(destTab, {str = str, color = color, field = att.field, value = att.value, maxValue = maxValue})
            end
        end
    end

    return destTab
end

-- 设置进化进度的星星
function EquipmentMgr:setEvolveStar(dlg, equip, panel)
    local evolveDeep = equip.evolve_level or 0
    local lightS = math.floor((evolveDeep + 1) / 2)
    if not panel then panel = "StarPanel" end
    for i = 1, 10 do
        -- 亮星
        if lightS >= i then
            dlg:setImage("StarImage" .. i, ResMgr.ui.evolve_star_compelete, panel)
        elseif lightS + 1 == i and evolveDeep % 2 == 0 then
            dlg:setImage("StarImage" .. i, ResMgr.ui.evolve_star_tobe, panel)
        else
            dlg:setImage("StarImage" .. i, ResMgr.ui.evolve_star_gray, panel)
        end
    end

    dlg:updateLayout("StarPanel")
end

function EquipmentMgr:getJewelryAttrib(equip)

    local attValueStr = string.format("%s_%d", MaterialAtt[equip.equip_type].field, Const.FIELDS_NORMAL)
    local attValue = equip.extra[attValueStr] or equip.fromCardValue or 0


    local totalAtt = {}
    local _, __, funStr = EquipmentMgr:getJewelryAttributeInfo(equip)
    table.insert(totalAtt, {str = funStr, color = COLOR3.LIGHT_WHITE})


    local blueAtt = EquipmentMgr:getJewelryBule(equip)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end

    return totalAtt
end

function EquipmentMgr:getMainInfoMap(equip)
    local function getRequire(equip)
        local color = COLOR3.EQUIP_NORMAL
        if equip.equip_type == EQUIP_TYPE.WEAPON then
            if equip.polar ~= Me:queryBasicInt("polar") then color = COLOR3.RED end
            return CHS[3002412] .. POLAR_CONFIG[equip.polar] .. CHS[3002413], color
        elseif equip.equip_type == EQUIP_TYPE.HELMET then
            if equip.gender ~= Me:queryBasicInt("gender") and equip.gender ~= 0 then color = COLOR3.RED end
            if equip.gender == 1 then
                return CHS[3002415] , color
            elseif equip.gender == 2 then
                return CHS[3002416], color
            else
                return CHS[3002414], color
            end
        elseif equip.equip_type == EQUIP_TYPE.ARMOR then
            if equip.gender ~= Me:queryBasicInt("gender") and equip.gender ~= 0 then color = COLOR3.RED end
            if equip.gender == 1 then
                return CHS[3002415], color
            elseif equip.gender == 2 then
                return CHS[3002416], color
            else
                return CHS[3002414], color
            end
        elseif equip.equip_type == EQUIP_TYPE.BOOT then
            return CHS[3002417], color
        else
            return "", color
        end
    end

    local mainInfo = {}

    if equip.rebuild_level ~= 0 and equip["degree_32"] then
        local degree = math.floor(equip["degree_32"] / 100) *100 / 1000000

        local completionStr
        if degree == 0 then
            completionStr = ""
        else
            completionStr = string.format("(+%0.4f%%)", degree)
        end
        local str = string.format(CHS[3002418], equip.rebuild_level, completionStr)
        table.insert(mainInfo, {str = str, color = COLOR3.EQUIP_BLUE})
    end

    local str, color = getRequire(equip)
    table.insert(mainInfo, {str = getRequire(equip), color = color})

    return mainInfo
end

function EquipmentMgr:getBaseAtt(equip)
    local baseAtt = {}
    local color = COLOR3.TEXT_DEFAULT
    if equip.equip_type == EQUIP.WEAPON then
        -- CHS[4000032]:伤害
        local basePower = equip.extra.phy_power_1 or 0
        local attChs = CHS[4000032] .. ":"
        local phy_power_isTotal = equip.extra.phy_power_isTotal or 0
        table.insert(baseAtt, {phy_power_isTotal = phy_power_isTotal, attChs = attChs, value = basePower, field_color = color, value_color = color, field = "phy_power", basic = 1})
        return baseAtt
    end

    -- CHS[4000091]:防御
    local defValue = equip.extra.def_1 or 0
    local defChs = CHS[4000091] .. ":"
    local def_isTotal = equip.extra.def_isTotal or 0
    table.insert(baseAtt, {def_isTotal = def_isTotal, attChs = defChs, value = defValue, field_color = color, value_color = color, field = "def", basic = 1})

    -- 最大气血
    local lifeStr = ""
    if equip.extra.max_life_1 ~= nil then
        local max_life_isTotal = equip.extra.max_life_isTotal or 0
        table.insert(baseAtt, {max_life_isTotal = max_life_isTotal, attChs = CHS[3002422] .. ":", value = equip.extra.max_life_1, field_color = color, value_color = color, field = "max_life", basic = 1})
    end

    -- 最大魔法
    local manaStr = ""
    if equip.extra.max_mana_1 ~= nil then
        local max_mana_isTotal = equip.extra.max_mana_isTotal or 0
        table.insert(baseAtt, {max_mana_isTotal = max_mana_isTotal, attChs = CHS[3002423] .. ":", value = equip.extra.max_mana_1, field_color = color, value_color = color, field = "max_mana", basic = 1})
    end

    -- 速度
    local speedStr = ""
    if equip.extra.speed_1 ~= nil then
        local speed_isTotal = equip.extra.speed_isTotal or 0
        table.insert(baseAtt, {speed_isTotal = speed_isTotal, attChs = CHS[3002424] .. ":", value = equip.extra.speed_1, field_color = color, value_color = color, field = "speed", basic = 1})
    end

    return baseAtt
end

-- 获取装备共鸣属性与颜色
function EquipmentMgr:getGongmingValueAndColor(equip)
    local ret = {}
    local upgradeLevel, att = EquipmentMgr:getGongmingActiveAttrib(equip)
    if upgradeLevel and att and EquipmentMgr:getAttribChsOrEng(att.field) then
        local item = {}
        item.str = string.format(CHS[7190143], tonumber(upgradeLevel), EquipmentMgr:getAttribChsOrEng(att.field) .. " "
           .. att.value .. EquipmentMgr:getPercentSymbolByField(att.field))
        item.color = COLOR3.BLUE
        item.field = att.field
        item.value = att.value
        table.insert(ret, item)
        if equip.rebuild_level == tonumber(upgradeLevel)  then
            -- 当前激活属性对应的改造等级与当前装备改造等级相同，则只返回激活属性
            return ret
        end
    end

    local att = EquipmentMgr:getGongmingAttrib(equip)
    if att and EquipmentMgr:getAttribChsOrEng(att.field) then
        local item = {}
        item.str = string.format(CHS[7190143], equip.rebuild_level, EquipmentMgr:getAttribChsOrEng(att.field) .. " "
            .. att.value .. EquipmentMgr:getPercentSymbolByField(att.field))
        item.color = COLOR3.GRAY
        item.field = att.field
        item.value = att.value
        table.insert(ret, item)
    end

    return ret
end

function EquipmentMgr:getAttInfoForGive(equip)
    -- 获取装备名称颜色         各个颜色属性
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)

    -- 改造属性
    local upgradeTab = EquipmentMgr:getUpgradeAtt(equip)

    -- 基础属性
    local attribTab = self:getBaseAtt(equip)
    local basicAtt = EquipmentMgr:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)

    -- 共鸣属性
    local gongmingTab = EquipmentMgr:getGongmingValueAndColor(equip)

    local allAttribTab = {}
    for _,v in pairs(basicAtt) do
        table.insert(allAttribTab, v)
    end

    local blueInfo = EquipmentMgr:getColorAtt(blueTab, "blue", equip, true)
    for _,v in pairs(blueInfo) do
        v.color = COLOR3.BLUE
        table.insert(allAttribTab, v)
    end

    local pinkInfo = EquipmentMgr:getColorAtt(pinkTab, "pink", equip, true)
    for _,v in pairs(pinkInfo) do
        v.color = COLOR3.PURPLE
        table.insert(allAttribTab, v)
    end

    local yellowInfo = EquipmentMgr:getColorAtt(yellowTab, "yellow", equip, true)
    for _,v in pairs(yellowInfo) do
        v.color = COLOR3.YELLOW
        table.insert(allAttribTab, v)
    end

    local greenInfo = EquipmentMgr:getColorAtt(greenTab, "green", equip)
    for _,v in pairs(greenInfo) do
        if greenTab[_].dark == 1 then
            if equip.suit_enabled == 1 then
                v.color = COLOR3.GREEN
            else
                v.color = COLOR3.GRAY
            end
            table.insert(allAttribTab, v)
        else
            table.insert(allAttribTab, v)
        end
    end

    for _,v in pairs(upgradeTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(gongmingTab) do
        table.insert(allAttribTab, v)
    end

    return allAttribTab
end

function EquipmentMgr:getAttInfoForEvolve(equip)
    -- 获取装备名称颜色         各个颜色属性
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)

    -- 改造属性
    local upgradeTab = EquipmentMgr:getUpgradeAtt(equip)

    -- 基础属性
    local attribTab = self:getBaseAtt(equip)
    local basicAtt = EquipmentMgr:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)

    -- 共鸣属性
    local gongmingAtt = EquipmentMgr:getGongmingValueAndColor(equip)

    local allAttribTab = {}
    for _,v in pairs(basicAtt) do
        table.insert(allAttribTab, v)
    end

    local blueInfo = EquipmentMgr:getColorAtt(blueTab, "blue", equip)
    for _,v in pairs(blueInfo) do
        v.color = COLOR3.BLUE
        table.insert(allAttribTab, v)
    end

    local pinkInfo = EquipmentMgr:getColorAtt(pinkTab, "pink", equip)
    for _,v in pairs(pinkInfo) do
        v.color = COLOR3.PURPLE
        table.insert(allAttribTab, v)
    end

    local yellowInfo = EquipmentMgr:getColorAtt(yellowTab, "yellow", equip)
    for _,v in pairs(yellowInfo) do
        v.color = COLOR3.YELLOW
        table.insert(allAttribTab, v)
    end

    local greenInfo = EquipmentMgr:getColorAtt(greenTab, "green", equip)
    for _,v in pairs(greenInfo) do
        if greenTab[_].dark == 1 then
            if equip.suit_enabled == 1 then
                v.color = COLOR3.GREEN
            else
                v.color = COLOR3.GRAY
            end
            table.insert(allAttribTab, v)
        end
    end

    for _,v in pairs(gongmingAtt) do
        table.insert(allAttribTab, v)
    end

    return allAttribTab
end

-- 获取有效的首饰（当前装备位置无，备用位置有，则也有效）  返回字段pos、imgFile、noItemImg、isBack：是否是备用
function EquipmentMgr:getEffJewelry()
    local posArray = {EQUIP.BALDRIC, EQUIP.NECKLACE, EQUIP.LEFT_WRIST, EQUIP.RIGHT_WRIST}
    local data = {}
    local count = #posArray
    for i = 1, count do
        local item = InventoryMgr:getItemByPos(posArray[i])
        local info = { pos = posArray[i], isBack = false }
        if item then
            info.imgFile = ResMgr:getItemIconPath(item.icon)

            if item.amount > 1 then
                info.text = tostring(item.amount)
            end

            if item.req_level and item.req_level > 0 then
                info.req_level = item.req_level
            end
        elseif item == nil then
            local backPos = EquipmentMgr:getBackEquipPos(posArray[i])
            local backItem = InventoryMgr:getItemByPos(backPos)
            if backItem then
                info.imgFile = ResMgr:getItemIconPath(backItem.icon)
                info.isBack = true
                info.pos = backPos
                info.req_level = backItem.req_level
            else
                info.imgFile = InventoryMgr:getEquipment_Backimage()[posArray[i]]
                info.noItemImg = true
            end
        end

        table.insert(data, info)
    end

    data.count = count
    return data
end

-- 获取有效的法宝（当前装备位置无，备用位置有，则也有效）  返回字段pos、imgFile、noItemImg、isBack：是否是备用、isNimbusExhaust：灵气是否耗尽
function EquipmentMgr:getEffArtifact()
    local posArray = {EQUIP.ARTIFACT, EQUIP.TALISMAN}
    local data = {}
    local count = #posArray
    for i = 1, count do
        local item = InventoryMgr:getItemByPos(posArray[i])
        local info = { pos = posArray[i], isBack = false }
        if item then
            info.imgFile = ResMgr:getItemIconPath(item.icon)

            if item.amount > 1 then
                info.text = tostring(item.amount)
            end

            if item.req_level and item.req_level > 0 then
                info.req_level = item.req_level
            end

            if item.level and item.level > 0 then
                info.level = item.level
            end

            if item.nimbus == 0 then
                info.isNimbusExhaust = true
            end

            if item.item_polar and item.item_polar >= 1 and item.item_polar <= 5 then
                info.item_polar = item.item_polar
            end
        elseif item == nil then
            local backPos = EquipmentMgr:getBackEquipPos(posArray[i])
            local backItem = InventoryMgr:getItemByPos(backPos)
            if backItem then
                info.imgFile = ResMgr:getItemIconPath(backItem.icon)
                info.isBack = true
                info.pos = backPos
                info.level = backItem.level
                if backItem.item_polar and backItem.item_polar >= 1 and backItem.item_polar <= 5 then
                    info.item_polar = backItem.item_polar
                end
            else
                info.imgFile = InventoryMgr:getEquipment_Backimage()[posArray[i]]
                info.noItemImg = true
            end
        end

        table.insert(data, info)
    end

    data.count = count
    return data
end

-- 首饰单条属性评分
function EquipmentMgr:getJewelryAttScore(jewelry, field, curValue)
    local maxValue = EquipmentMgr:getAttribMaxValueByField(jewelry, field) or 0
    if maxValue == 0 then return 0 end
    local basicScore = JEWELRY_SCORE[field]
    return math.floor(curValue / maxValue * basicScore)
end

-- 获取评分表
function EquipmentMgr:getJewelryEffScore(jewelry)
    local atrribTable = jewelry["extra"] or {}
    local scoreTemp = {}

    -- 将所有属性积分算进表 scoreTemp 中
    for k, v in pairs(atrribTable) do
        if string.match(k,".+_(%d*)") and (tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB or tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB_EX) then
            local key = string.match(k,"(.+)_%d*")

            -- 如果有所相
            if key == "all_polar" and v >= 3 then
                -- 如果是所相3以上，则就是贵重物品，外层不想在循环一遍，所以索性将分值提高一个很大值，达到目的。by songcw
                scoreTemp[key] = 100000
            end

            if JEWELRY_SCORE[key] then
                if not scoreTemp[key] then
                    scoreTemp[key] = EquipmentMgr:getJewelryAttScore(jewelry, key, v)
                else
                    scoreTemp[key] = scoreTemp[key] + EquipmentMgr:getJewelryAttScore(jewelry, key, v)
                end
            end

        end
    end

    local ret = {}  -- 最终能计算评分的属性，排除互斥的
    ret["basic_att"] = 0
    ret["basic_resist"] = 0
    for field ,value in pairs(scoreTemp) do
        if not JEWELRY_SCORE["the_max_arrtib_1"][field] and not JEWELRY_SCORE["the_max_arrtib_2"][field] then
            ret[field] = value
        end

        if JEWELRY_SCORE["the_max_arrtib_1"][field] then
            if value > ret["basic_att"] then ret["basic_att"] = value end
        end

        if JEWELRY_SCORE["the_max_arrtib_2"][field] then
            if value > ret["basic_resist"] then ret["basic_resist"] = value end
        end
    end
    return ret
end

function EquipmentMgr:getJewelryZuhe(jewelry, needCount)
    needCount = needCount or 2
    local badCount, badInfo = self:getJewelryBadAttCount(jewelry)

    local attrib = {}
    local atrribTable = jewelry["extra"]
    for k, v in pairs(atrribTable) do
        if string.match(k,".+_(%d*)") and (tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB or tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB_EX) then
            local key = string.match(k,"(.+)_%d*")
            if not attrib[key] then
                attrib[key] = {field = key, count = 1}
            else
                attrib[key].count = attrib[key].count + 1
            end
        end
    end

    local ret = {0,0,0,0,0,0,0,0,0,0}

    local zuheConfig = {
        -- 组合二：所有相性+所有技能上升+所有抗异常/忽视所有抗异常 条件
        [2] = {
            ["all_polar"] = 0,
            ["all_skill"] = 0,
            ["one_in_all"] = {
                ["all_resist_except"] = 0,
                ["ignore_all_resist_except"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合三：力量/灵力+敏捷
        [3] = {
            ["dex"] = 0,
            ["one_in_all"] = {
                ["str"] = 0,
                ["wiz"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合四：所有技能上升+力量/灵力/敏捷/体质
        [4] = {
            ["all_skill"] = 0,
            ["one_in_all"] = {
                ["str"] = 0,
                ["wiz"] = 0,
                ["dex"] = 0,
                ["con"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合五：所有技能上升+忽视目标抗遗忘/中毒/冰冻/昏睡/混乱+敏捷
        [5] = {
            ["all_skill"] = 0,
            ["dex"] = 0,
            ["one_in_all"] = {
                ["ignore_resist_forgotten"] = 0,
                ["ignore_resist_poison"] = 0,
                ["ignore_resist_frozen"] = 0,
                ["ignore_resist_sleep"] = 0,
                ["ignore_resist_confusion"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合六：忽视所有抗异常+敏捷/体质
        [6] = {
            ["ignore_all_resist_except"] = 0,
            ["one_in_all"] = {
                ["dex"] = 0,
                ["con"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合七：忽视所有抗异常+忽视目标抗遗忘/中毒/冰冻/昏睡/混乱+敏捷
        [7] = {
            ["ignore_all_resist_except"] = 0,
            ["dex"] = 0,
            ["one_in_all"] = {
                ["ignore_resist_forgotten"] = 0,
                ["ignore_resist_poison"] = 0,
                ["ignore_resist_frozen"] = 0,
                ["ignore_resist_sleep"] = 0,
                ["ignore_resist_confusion"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合八：所有抗异常+力量/灵力/敏捷/体质
        [8] = {
            ["all_resist_except"] = 0,
            ["one_in_all"] = {
                ["str"] = 0,
                ["wiz"] = 0,
                ["dex"] = 0,
                ["con"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合九：所有相性+力量/灵力/敏捷/体质
        [9] = {
            ["all_polar"] = 0,
            ["one_in_all"] = {
                ["str"] = 0,
                ["wiz"] = 0,
                ["dex"] = 0,
                ["con"] = 0,
                ["isMeet"] = 0,
            }
        },

        -- 组合十：所有相性+忽视目标抗遗忘/中毒/冰冻/昏睡/混乱+敏捷
        [10] = {
            ["all_polar"] = 0,
            ["dex"] = 0,
            ["one_in_all"] = {
                ["ignore_resist_forgotten"] = 0,
                ["ignore_resist_poison"] = 0,
                ["ignore_resist_frozen"] = 0,
                ["ignore_resist_sleep"] = 0,
                ["ignore_resist_confusion"] = 0,
                ["isMeet"] = 0,
            }
        }
    }

    local function setZuheFlag( checkAttTab, info , isShowDebug, bagdField)
        -- body
        if checkAttTab[info.field] and not badInfo[info.field] then
            checkAttTab[info.field] = checkAttTab[info.field] + info.count
        else
            if checkAttTab["one_in_all"][info.field] and not badInfo[info.field] then
                checkAttTab["one_in_all"][info.field]= info.count + checkAttTab["one_in_all"][info.field]
                checkAttTab["one_in_all"]["isMeet"] = 1
            end
        end

        if isShowDebug then
            gf:PrintMap(checkAttTab)
        end

        return checkAttTab
    end

    local function isMeetZuhe(attrib, isShowDebug)
        local typeCount = 0 -- 需要两种
        local count = 0
        for field, value in pairs(attrib) do
            if field ~= "one_in_all" then
                if attrib[field] == 0 then

                else
                    count = count + attrib[field]
                    typeCount = typeCount + 1
                end
            end
        end

        local max = 0
        for f, v in pairs(attrib["one_in_all"]) do
            if max < v then
                max = v
            end
        end

        count = count + max

        if attrib["one_in_all"]["isMeet"] ~= 0 then
            typeCount = typeCount + 1
        end

        if isShowDebug then
            gf:PrintMap(attrib)
        end

        return (typeCount >= 2 and count >= needCount and count or 0)
    end

    -- 将达到的标记下
    for _, info in pairs(attrib) do
        -- 设置满足的组合
        -- 组合一：2条相同的非垃圾属性
        if info.count > 1 and not badInfo[info.field] then
            ret[1] = ret[1] + info.count
        end
    end

    for i = 2, 10 do

            -- 将达到的标记下
        for _, info in pairs(attrib) do
            if zuheConfig[i] then
                zuheConfig[i] = setZuheFlag(zuheConfig[i], info, nil, badInfo)
            end
        end

        ret[i] = isMeetZuhe(zuheConfig[i])
    end

    return ret
end


-- 获取垃圾属性条目数
function EquipmentMgr:getJewelryBadAttCount(jewelry)

-- 垃圾属性信息1   五行抗性，有该属性直接判断垃圾属性
    local badAttTab1 = {
        ["resist_metal"] = {count = 0, totalValue = 0},
        ["resist_wood"] = {count = 0, totalValue = 0},
        ["resist_water"] = {count = 0, totalValue = 0},
        ["resist_fire"] = {count = 0, totalValue = 0},
        ["resist_earth"] = {count = 0, totalValue = 0},
        ["ignore_resist_metal"] = {count = 0, totalValue = 0},
        ["ignore_resist_wood"] = {count = 0, totalValue = 0},
        ["ignore_resist_water"] = {count = 0, totalValue = 0},
        ["ignore_resist_fire"] = {count = 0, totalValue = 0},
        ["ignore_resist_earth"] = {count = 0, totalValue = 0},
    }

    -- 垃圾属性表2   抗五行障碍，需要与所有抗异常，算最终值大小判断
    local badAttTab2 = {
        ["resist_poison"] = {count = 0, totalValue = 0},
        ["resist_frozen"] = {count = 0, totalValue = 0},
        ["resist_sleep"] = {count = 0, totalValue = 0},
        ["resist_forgotten"] = {count = 0, totalValue = 0},
        ["resist_confusion"] = {count = 0, totalValue = 0},
        ["all_resist_except"] = {count = 0, totalValue = 0},
    }

    -- 垃圾属性表3，  需要互斥的
    local badAttTab3 = {
        ["str"] = {count = 0, totalValue = 0},
        ["wiz"] = {count = 0, totalValue = 0},
    }

    -- 垃圾属性表4，  需要互斥的
    local badAttTab4 = {
        ["ignore_resist_confusion"] = {count = 0, totalValue = 0},      -- 忽视抗混乱
        ["ignore_resist_sleep"] = {count = 0, totalValue = 0},          -- 忽视抗昏睡
        ["ignore_resist_frozen"] = {count = 0, totalValue = 0},         -- 忽视抗冰冻
        ["ignore_resist_poison"] = {count = 0, totalValue = 0},         -- 忽视抗中毒
        ["ignore_resist_forgotten"] = {count = 0, totalValue = 0},      -- 忽视抗遗忘
    }

    local retCount = 0  --  垃圾属性条目数
    local retBadAttrib = {}

    local atrribTable = jewelry["extra"]
    for k, v in pairs(atrribTable) do
        if string.match(k,".+_(%d*)") and (tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB or tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB_EX) then
            local key = string.match(k,"(.+)_%d*")

            -- 表一的直接是垃圾属性
            if badAttTab1[key] then
                retCount = retCount + 1
                retBadAttrib[key] = 1
            end

            -- 表2记录数据，循环后计算总值
            if badAttTab2[key] then
                badAttTab2[key].count = badAttTab2[key].count + 1
                badAttTab2[key].totalValue = badAttTab2[key].totalValue + v
            end

                        -- 表2记录数据，循环后计算总值
            if badAttTab3[key] then
                badAttTab3[key].count = badAttTab3[key].count + 1
                badAttTab3[key].totalValue = badAttTab3[key].totalValue + v
            end

                        -- 表2记录数据，循环后计算总值
            if badAttTab4[key] then
                badAttTab4[key].count = badAttTab4[key].count + 1
                badAttTab4[key].totalValue = badAttTab4[key].totalValue + v
            end
        end
    end

    -- 检测垃圾属性表2
    for field, info in pairs(badAttTab2) do
        -- 如果该抗性加 所有抗异常，小于 40，则是垃圾属性
        if info.totalValue > 0 and field ~= "all_resist_except" and info.totalValue + badAttTab2["all_resist_except"].totalValue < 40 then
            retCount = info.count + retCount
            retBadAttrib[field] = 1
        end
    end

    local function getMutexBadCount( badTab, retBadAttrib )
        local retCount = 0

        local goodAttField

        -- 获取互斥属性最大值
        local maxValue = 0
        for field, info in pairs(badTab) do
            if maxValue < info.totalValue and info.totalValue > 0 then
                maxValue = info.totalValue
            end
        end

        -- 获取最大属性值个数
        local sameCount = 0
        if maxValue ~= 0 then
            for field, info in pairs(badTab) do
                if maxValue == info.totalValue and info.totalValue > 0 then
                    sameCount = sameCount + 1
                    goodAttField = field
                end
            end
        end

        -- 如果只有一个最大的，将其他的加起来就好了
        if sameCount == 1 then
            for field, info in pairs(badTab) do
                if maxValue > info.totalValue and info.totalValue > 0 then
                    retCount = retCount + info.count
                    retBadAttrib[field] = info.count
                end
            end
        else
            -- 互斥属性中，总值相同的不止一个,取条目少的为垃圾属性
            local huci = {}
            local maxCount = 0
            local sameMaxCount = 0
            for field, info in pairs(badTab) do
                if maxValue == info.totalValue and info.totalValue > 0 then
                    huci[field] = info.count

                    if maxCount < info.count then
                        maxCount = info.count
                    end
                elseif maxValue > info.totalValue and info.totalValue > 0 then
                    retCount = info.count + retCount
                    retBadAttrib[field] = info.count
                end
            end


            for field, info in pairs(badTab) do
                if maxCount == info.count and info.totalValue > 0 then
                    sameMaxCount = sameMaxCount + 1
                end
            end

            if sameMaxCount ~= 1 then
                local isFrist = true
                for field, value in pairs(huci) do
                    if maxCount == value and not isFrist then
                        retCount = value +retCount
                        retBadAttrib[field] = value
                    else
                        goodAttField = field
                    end
                    isFrist = false
                end
            else
                for field, value in pairs(huci) do
                    if maxCount ~= value then
                        retCount = value +retCount
                        retBadAttrib[field] = value
                    else
                        goodAttField = field
                    end
                end
            end
        end

        return retCount, retBadAttrib, goodAttField
    end

    -- 垃圾属性表3,4 互斥检测
    local count3, retBadAttrib = getMutexBadCount(badAttTab3, retBadAttrib)
    retCount = retCount + count3

    local count4, retBadAttrib = getMutexBadCount(badAttTab4, retBadAttrib)
    retCount = retCount + count4

    return retCount, retBadAttrib
end


function EquipmentMgr:getJewelryScore(jewelry)
    local scoreMap = EquipmentMgr:getJewelryEffScore(jewelry)

  --  gf:PrintMap(scoreMap)
  --  Log:D("======-------")

    local sumScore = 0
    for k, v in pairs(scoreMap)do
        sumScore = sumScore + v
    end

    return sumScore
end

function EquipmentMgr:jewelryIsExpensive(jewelry)
    -- 聚宝斋的商品有是否贵重标记
    if jewelry.valuable and jewelry.valuable == 1 then
        return true
    end

   -- local scoreMap = EquipmentMgr:getJewelryEffScore(jewelry)
    local sumScore = EquipmentMgr:getJewelryScore(jewelry)

    -- 积分等级判断
    local levelScore = {
        [80] = 80,
        [90] = 95,
        [100] = 110,
        [110] = 125,
        [120] = 140,
    }

    if jewelry.req_level < 80 then return false end

        -- 有一条所相 3以上的
    if sumScore >= 100000 then
        return true
    end

    -- 小于等于 100 的，积分不满足，返回false
    if sumScore < levelScore[jewelry.req_level] and jewelry.req_level <= 100 then
        return false
    end

    -- 积分满足。<=90的都是贵重
    if jewelry.req_level <= 90 then
        return true
    end

    local badCount, retBadAttrib = self:getJewelryBadAttCount(jewelry)
  --  local zuheMeetRet2 = EquipmentMgr:getJewelryZuhe(jewelry, 2)
  --  local zuheMeetRet3 = EquipmentMgr:getJewelryZuhe(jewelry, 3)

    -- 100 级首饰，评分大于 110 ，垃圾属性<= 1
    if jewelry.req_level == 100 and badCount <= 1 then
        return true
    end



    -- 互斥属性 tab 中的其他属性值都设置为 1
    local function getNewJewelry(jewelry, tab, goodsField)
        local atrribTable = jewelry["extra"] or {}
        -- 将所有属性积分算进表 scoreTemp 中
        for k, v in pairs(atrribTable) do
            if string.match(k,".+_(%d*)") and (tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB or tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB_EX) then
                local key = string.match(k,"(.+)_%d*")

                if key ~= goodsField and tab[key] then
                    jewelry["extra"][k] = 1
                end

            end
        end
        return jewelry
    end

    -- 互斥属性 tab 中的 goodsField 属性值都设置为 1
    local function getNewJewelryEx(jewelry, tab, goodsField)
        local atrribTable = jewelry["extra"] or {}
        -- 将所有属性积分算进表 scoreTemp 中
        for k, v in pairs(atrribTable) do
            if string.match(k,".+_(%d*)") and (tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB or tonumber(string.match(k,".+_(%d*)")) == Const.JEWELRY_BLUE_ATTRIB_EX) then
                local key = string.match(k,"(.+)_%d*")

                if key == goodsField and tab[key] then
                    jewelry["extra"][k] = 1
                end

            end
        end
        return jewelry
    end


    local function levelUp100IsExpendsive(jewelry)
        local destScore = EquipmentMgr:getJewelryScore(jewelry)
        local badCount, retBadAttrib = self:getJewelryBadAttCount(jewelry)
    local zuheMeetRet2 = EquipmentMgr:getJewelryZuhe(jewelry, 2)
    local zuheMeetRet3 = EquipmentMgr:getJewelryZuhe(jewelry, 3)

    -- 首饰贵重判断相关信息打印
    --[[
    for i = 1, 20 do
        Log:D("                    ")
    end
    Log:D("================================")
    Log:D("垃圾属性个数        " .. badCount)
    local chsTab = {}
    for field, value in pairs(retBadAttrib) do
        table.insert( chsTab, self:getAttribChsOrEng(field) )
    end

    gf:PrintMap(chsTab)

    Log:D("=====!!!!!!!!!!!!!===========")
    gf:PrintMap(retBadAttrib)
    Log:D("================================")

    Log:D("================================")
    Log:D("分数               " .. sumScore)
    Log:D("++++++++++++++++++++++++++++++++")
    Log:D("以下是满足两条属性的")
    gf:PrintMap(zuheMeetRet2)
    Log:D("以下是满足三条属性的")
    gf:PrintMap(zuheMeetRet3)
    Log:D("++++++++++++++++++++++++++++++++")
    Log:D("--------------------------------")
    --]]

        -- 积分不满足，返回false
        if destScore < levelScore[jewelry.req_level] then
            return false
    end

        -- 110 级判断
        if jewelry.req_level == 110 then
    -- 110 级首饰，评分大于 125 ，(垃圾属性<= 1 or 满足组合）
    local isMeetZuhe = false
    for _, value in pairs(zuheMeetRet2) do
        if value > 0 then
            isMeetZuhe = true
        end
    end

    if jewelry.req_level == 110 and (badCount <= 1 or isMeetZuhe) then
        return true
    end
        end


    -- 120 级首饰，评分大于 140 ，(垃圾属性<= 1 or 满足组合）
    local isMeet120 = false
    for i = 2, 10 do
        if zuheMeetRet3[i] and zuheMeetRet3[i] >= 3 then
            isMeet120 = true
        end
    end

    if jewelry.req_level == 120 and (badCount <= 1 or zuheMeetRet2[2] > 0 or isMeet120) then
        return true
    end
    end


    -- 100以上，判断是否有互斥属性，并且互斥的属性条目2条
    local twoSameBadAttField
    for field, count in pairs(retBadAttrib) do
        if count >= 2 then
            twoSameBadAttField = field
        end
    end

    local destScore = sumScore
    --
    if twoSameBadAttField then
        -- 互斥属性中有两条一样的
        local tempJewelry = gf:deepCopy(jewelry)
        if JEWELRY_SCORE["the_max_arrtib_1"][twoSameBadAttField] then
            tempJewelry = getNewJewelryEx(tempJewelry, JEWELRY_SCORE["the_max_arrtib_1"], twoSameBadAttField)
        elseif JEWELRY_SCORE["the_max_arrtib_2"][twoSameBadAttField] then
            tempJewelry = getNewJewelryEx(tempJewelry, JEWELRY_SCORE["the_max_arrtib_2"], twoSameBadAttField)
        end


        if levelUp100IsExpendsive(tempJewelry) then return true end

        
        local tempJewelry = gf:deepCopy(jewelry)
        if JEWELRY_SCORE["the_max_arrtib_1"][twoSameBadAttField] then
            tempJewelry = getNewJewelry(tempJewelry, JEWELRY_SCORE["the_max_arrtib_1"], twoSameBadAttField)
        elseif JEWELRY_SCORE["the_max_arrtib_2"][twoSameBadAttField] then
            tempJewelry = getNewJewelry(tempJewelry, JEWELRY_SCORE["the_max_arrtib_2"], twoSameBadAttField)
        end

        if levelUp100IsExpendsive(tempJewelry) then return true end
    else
        if levelUp100IsExpendsive(jewelry) then return true end
    end
end

function EquipmentMgr:MSG_INVENTORY(data)
    if not data or data.count <= 0 or not data[1] then return end
    if EquipmentMgr.preEvolveEquip[data[1].pos] then
        EquipmentMgr.preEvolveEquip[data[1].pos] = nil
    end
end

function EquipmentMgr:MSG_OPEN_TIANXS_DIALOG(data)
    local dlg = DlgMgr:openDlg("ConvenientBuyTXSDlg")
    dlg:setData(data)
end

function EquipmentMgr:getUnidentifiedEquipForIdentifyGem()
    local ret = {}
    local items = InventoryMgr:getAllBagUnidentifiedEquip()
    for _, item in pairs(items) do
        if item.req_level >= 70 then
            table.insert(ret, item)
        end
    end

    return ret
end

-- 鉴定宝石
function EquipmentMgr:identyfyGem(pos)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_IDENTIFY_GEM,
        para = "",
    })
end

-- 根据等级获取消耗鉴定未鉴定装备（宝石）的花费
function EquipmentMgr:getIdentifyCostByLevel(level)
    if IDENTIFY_GEM_COST[level] then return IDENTIFY_GEM_COST[level].cost end

    return 0
end

-- 根据等级获取消耗鉴定未鉴定装备（宝石）的产出宝石
function EquipmentMgr:getIdentifyGemByLevel(level)
    if IDENTIFY_GEM_COST[level] then return IDENTIFY_GEM_COST[level].outPut end

    return {}
end

-- 装备对应消耗的宝石
function EquipmentMgr:getRefiningGemByEquip(equip)
    if not equip then return end

    local level = equip.req_level
    local retLevel = math.floor(level / 10) * 10
    if retLevel == 70 then
        return CHS[4100421]
    elseif retLevel == 80 or retLevel == 90 or retLevel == 100 then
        return CHS[4100422]
    elseif retLevel == 110 or retLevel == 120 then
        return CHS[4100423]
    end
end

-- 首饰转化属性
function EquipmentMgr:jewelryTransform(pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_TRANSFORM_JEWELRY,
        para = para,
    })
end

-- 替换炼化属性
function EquipmentMgr:equipApplyRefining(pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_REFINE_APPLY_PREVIEW,
        para = para,
    })
end

-- 还原炼化属性
function EquipmentMgr:equipClearRefining(pos, para)
    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = pos,
        type = Const.EQUIP_REFINE_CLEAR_PREVIEW,
        para = para,
    })
end

-- 获取预览属性，FIELDS_PROP2_PREVIEW - FIELDS_RESONANCE_ACTIVED
function EquipmentMgr:getEquipPre(equip, colorType)
    if not equip then return end

    local retTab
    for field, value in pairs(equip.extra) do
        local retField = string.match(field, "(.+)_" .. colorType)
        if retField then
            retTab = {field = retField, value = value}
        end
    end

    return retTab
end

-- 获取装备共鸣属性(当前共鸣属性信息，属性值对应当前装备改造等级对应)
function EquipmentMgr:getGongmingAttrib(equip)
    if not equip then return end
    local att = EquipmentMgr:getEquipPre(equip, Const.FIELDS_RESONANCE)
    if not att and equip.prop_resonance then
        -- 可能是聚宝斋数据(服务器在聚宝斋装备共鸣数据进行了调整，extra中此时取不到共鸣数据)
        att = {}
        for k, v in pairs(equip.prop_resonance) do
            att.field = k
            att.value = v.val
        end
    end

    return att
end

-- 获取装备共鸣激活属性(包含：属性信息，属性值对应已激活属性的改造等级)
function EquipmentMgr:getGongmingActiveAttrib(equip)
    if not equip then return end

    local activeUpgradeLevel = 0
    local retTab
    for field, value in pairs(equip.extra) do
        local retField = string.match(field, "(.+)_" .. Const.FIELDS_RESONANCE_ACTIVED)
        if retField then
            if retField == "rebuild_level" then
                activeUpgradeLevel = tonumber(value)
            else
                retTab = {field = retField, value = value}
            end
        end
    end

    if not retTab and equip.prop_resonance_actived then
        -- 可能是聚宝斋数据(服务器在聚宝斋装备共鸣数据进行了调整，extra中此时取不到共鸣数据)
        retTab = {}
        for k, v in pairs(equip.prop_resonance_actived) do
            if k == "rebuild_level" then
                activeUpgradeLevel = tonumber(v)
            else
                retTab.field = k
                retTab.value = v.val
            end
        end
    end

    return activeUpgradeLevel, retTab
end

-- 获取粉色预览属性
function EquipmentMgr:getPinkPre(equip)
    if not equip then return end

    local retTab
    for field, value in pairs(equip.extra) do
        local retField = string.match(field, "(.+)_" .. Const.FIELDS_PROP2_PREVIEW)
        if retField then
            retTab = {field = retField, value = value}
        end
    end

    return retTab
end

function EquipmentMgr:hasArtifactEquipped()
    local artifact = InventoryMgr:getItemByPos(EQUIP_TYPE.ARTIFACT)
    if artifact then
        return true
    else
        return false
    end
end

function EquipmentMgr:getEquippedArtifact()
    local artifact = InventoryMgr:getItemByPos(EQUIP.ARTIFACT)
    if artifact then
        return artifact
    end

    local backArtifact = InventoryMgr:getItemByPos(EQUIP.BACK_ARTIFACT)
    if backArtifact then
        return backArtifact
    end
end

-- 获取可以获得道法的法宝
function EquipmentMgr:getCanGetDaofaArtifact()
    local artifact = InventoryMgr:getItemByPos(EQUIP.ARTIFACT)
    local changeOn = 1 <= SystemSettingMgr:getSettingStatus("award_supply_artifact", 0)
    local backArtifact = InventoryMgr:getItemByPos(EQUIP.BACK_ARTIFACT)
    if artifact and (not changeOn or not backArtifact) then
        -- 法宝共通未开启或无备用法宝
        return artifact
    else
        return backArtifact
    end
end


function EquipmentMgr:getEquippedArtifactNimbus()
    local nimbus = 0
    local artifact = EquipmentMgr:getEquippedArtifact()
    if artifact then
        nimbus = artifact.nimbus
    end

    return nimbus
end

-- 获取法宝特殊技能升级消耗的材料
function EquipmentMgr:getArtifactSpSkillLevelUpCost(artifact)
    -- 如果法宝不存在或法宝无特殊技能，消耗材料按照“法宝特殊技能为1级”显示

    local data = {name = CHS[4100421], num = 2}
    if not artifact then
        return data
    end

    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if not artifactSpSkillName then
        return data
    end

    local level = artifact.extra_skill_level

    if level <= 4 then
        data.name = CHS[4100421]
        data.num = 2
    elseif level >= 5 and level <= 9 then
        data.name = CHS[4100422]
        data.num = 2
    elseif level >= 10 and level <= 14 then
        data.name = CHS[4100423]
        data.num = 1
    elseif level >= 15 then
        data.name = CHS[4100424]
        data.num = 1
    end

    return data
end

-- 装备退化所需要的宝石
function EquipmentMgr:getEquipmentDegenerationCost(level)
    local costItem = {}
    if level >= 71 and level <= 79 then
        costItem = {name = CHS[4100422], num = 2}
    elseif level >= 80 and level <= 89 then
        costItem = {name = CHS[4100422], num = 3}
    elseif level >= 90 and level <= 99 then
        costItem = {name = CHS[4100422], num = 4}
    elseif level >= 100 and level <= 109 then
        costItem = {name = CHS[4100423], num = 2}
    elseif level >= 110 and level <= 119 then
        costItem = {name = CHS[4100423], num = 3}
    elseif level >= 120 and level <= 129 then
        costItem = {name = CHS[4100423], num = 4}
    elseif level >= 130 and level <= 139 then
        costItem = {name = CHS[4100423], num = 5}
    elseif level >= 140 and level <= 149 then
        costItem = {name = CHS[4100424], num = 2}
    elseif level >= 150 and level <= 159 then
        costItem = {name = CHS[4100424], num = 3}
    elseif level >= 160 and level <= 169 then
        costItem = {name = CHS[4100424], num = 4}
    end

    return costItem
end

-- 聚宝先关界面设置武器
function EquipmentMgr:setEquipForJubao(dlg, equip)
    local panel = dlg:getControl("EquipmentInfoPanel")

    -- icon
    dlg:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name), panel)

    -- 等级
    dlg:setNumImgForPanel("EquipShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 获取装备名称颜色         各个颜色属性
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)
    dlg:setLabelText("EquipmentNameLabel", equip.name, panel, color)

    local mainInfo = EquipmentMgr:getMainInfoMap(equip)
    for i = 1,2 do
        if i > #mainInfo then
            dlg:setLabelText("MainLabel" .. i, "", panel)
        else
            dlg:setLabelText("MainLabel" .. i, mainInfo[i].str, panel, mainInfo[i].color)
        end
    end

    -- 限制交易
    if InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:addLogoBinding(dlg:getControl("EquipmentImage", nil, panel))
    end

    -- 贵重物品
    dlg:setCtrlVisible("PreciousImage", gf:isExpensive(equip, false), panel)

    -- 套装相性
    if equip.suit_polar ~= 0 and equip.color == CHS[3002419] then
        dlg:setImage("PolarImage",  EquipmentMgr:getPolarRes(equip.suit_polar), panel)
    else
        dlg:setImagePlist("PolarImage", ResMgr.ui.touming, panel)
    end

    -- 进化信息
    EquipmentMgr:setEvolveStar(dlg, equip)

    -- 属性
    local blueAttTab = EquipmentMgr:getColorAtt(blueTab, "blue", equip)
    local pinkAttTab = EquipmentMgr:getColorAtt(pinkTab, "pink", equip)
    local yellowAttTab = EquipmentMgr:getColorAtt(yellowTab, "yellow", equip)
    local greenAttTab = EquipmentMgr:getColorAtt(greenTab, "green", equip)
    local upgradeTab = EquipmentMgr:getUpgradeAtt(equip)
    local gongmingTab = EquipmentMgr:getGongmingValueAndColor(equip)

    local attribTab = EquipmentMgr:getBaseAtt(equip)
    attribTab = EquipmentMgr:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)
    local limitTab = InventoryMgr:getLimitAtt(equip)

    local allAttribTab = {}
    for _,v in pairs(attribTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(blueAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(pinkAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(yellowAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(greenAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(upgradeTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(gongmingTab) do
        table.insert(allAttribTab, v)
    end

    for _, v in pairs(limitTab) do
        table.insert(allAttribTab, v)
    end

    local count = #allAttribTab
    local missCount = 0

    for i = 1,15 do
        dlg:setLabelText("BaseAttributeLabel" .. i, "", panel)
        dlg:setCtrlVisible("BaseAttributePanel" .. i, false, panel)
    end

    for i = 1,15 do
        if i > count then
            missCount = missCount + 1
        else
            local desPanel = dlg:getControl("BaseAttributePanel" .. i, nil, panel)
            if desPanel then
                desPanel:setVisible(true)
                dlg:setColorText(allAttribTab[i].str, "BaseAttributePanel" .. i, panel, nil, nil, allAttribTab[i].color, 19, true)
            else
                dlg:setLabelText("BaseAttributeLabel" .. i, allAttribTab[i].str, panel, allAttribTab[i].color)
            end
        end
    end
    local missHeight = (25 + 2) * missCount
    local scroll = dlg:getControl("ScrollView", nil, panel)
    local size = scroll:getContentSize()
    local infoPanel = dlg:getControl("InfoPanel", nil, scroll)
    infoPanel.initSize = infoPanel.initSize or infoPanel:getContentSize()

    -- u有时候刚好现实，但是会比显示区域多几个像素导致能拖动
    local retHeight = math.max(infoPanel.initSize.height - missHeight, size.height)
    if retHeight > size.height and retHeight - 15 <= size.height then
        retHeight = size.height
    end

    infoPanel:setContentSize(infoPanel.initSize.width, retHeight)
    infoPanel:requestDoLayout()
    scroll:setInnerContainerSize(infoPanel:getContentSize())

    scroll:getInnerContainer():setPositionY(size.height - (infoPanel:getContentSize().height))
    scroll:requestDoLayout()

    dlg:setCtrlVisible("SlipButton", retHeight > scroll:getContentSize().height)
end

-- 聚宝先关界面设置首饰
function EquipmentMgr:setJewelryForJubao(dlg, equip)
    local panel = dlg:getControl("JewelryInfoPanel")
    dlg:setImage("ItemImage", InventoryMgr:getIconFileByName(equip.name), panel)

    dlg:setNumImgForPanel("JewelryShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 名称
    local color = InventoryMgr:getItemColor(equip)
    dlg:setLabelText("NameLabel", equip.name, panel, color)

    -- 描述
    dlg:setLabelText("DescLabel", InventoryMgr:getDescript(equip.name), panel)



    -- 部位和强化等级
    --- 如果没有强化的，原强化label需要显示部位
    local developStr, devLevel, devCom = EquipmentMgr:getJewelryDevelopInfo(equip)
    if devLevel == 0 and devCom == 0 then
                    -- 部位
        if equip.equip_type == EQUIP.BALDRIC then
            dlg:setLabelText("DevelopLevelLabel", CHS[3002877], panel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.NECKLACE then
            dlg:setLabelText("DevelopLevelLabel", CHS[3002878], panel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.LEFT_WRIST then
            dlg:setLabelText("DevelopLevelLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.RIGHT_WRIST then
            dlg:setLabelText("DevelopLevelLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        end

        dlg:setLabelText("CommondLabel", "", panel, COLOR3.LIGHT_WHITE)
    else
        -- 强化
        dlg:setLabelText("DevelopLevelLabel", developStr, panel, COLOR3.BLUE)


        -- 部位
        if equip.equip_type == EQUIP.BALDRIC then
            dlg:setLabelText("CommondLabel", CHS[3002877], panel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.NECKLACE then
            dlg:setLabelText("CommondLabel", CHS[3002878], panel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.LEFT_WRIST then
            dlg:setLabelText("CommondLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.RIGHT_WRIST then
            dlg:setLabelText("CommondLabel", CHS[3002879], panel, COLOR3.LIGHT_WHITE)
        end
    end


    -- 贵重物品
    dlg:setCtrlVisible("PreciousImage", gf:isExpensive(equip, false), panel)

    -- 属性
    local totalAtt = {}
    local _, __, funStr = EquipmentMgr:getJewelryAttributeInfo(equip)
    table.insert(totalAtt, {str = funStr, color = COLOR3.LIGHT_WHITE})

    local blueAtt = EquipmentMgr:getJewelryBule(equip)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end

    -- 转换次数
    if equip.transform_num and equip.transform_num > 0 then
        table.insert(totalAtt, {str = string.format(CHS[4010062], equip.transform_num), color = COLOR3.LIGHT_WHITE})
    end

    -- 冷却时间
    if EquipmentMgr:isCoolTimed(equip) then
        table.insert(totalAtt, {str = string.format(CHS[4010063], EquipmentMgr:getCoolTimedByDay(equip)), color = COLOR3.LIGHT_WHITE})
    end

    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(equip, dlg:getControl("ExChangeLabel"))
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = COLOR3.RED})
    end

    local missCount = 0
    for i = 1, Const.JEWELRY_ATTRIB_MAX do
        if i > #totalAtt then
            dlg:setLabelText("AttribLabel" .. i, "", panel)
            missCount = missCount + 1
        else

            local attPanel = dlg:getControl("AttribPanel" .. i, nil, panel)
            if attPanel then

                dlg:setColorTextEx(totalAtt[i].str, attPanel, totalAtt[i].color)
            else

                dlg:setLabelText("AttribLabel" .. i, totalAtt[i].str, panel, totalAtt[i].color)
            end
        end
    end
    local missHeight = (25 + 7) * missCount
    local scroll = dlg:getControl("ScrollView", nil, panel)
    local size = scroll:getContentSize()
    local infoPanel = dlg:getControl("InfoPanel", nil, scroll)
    infoPanel.initSize = infoPanel.initSize or infoPanel:getContentSize()

    -- u有时候刚好现实，但是会比显示区域多几个像素导致能拖动
    local retHeight = math.max(infoPanel.initSize.height - missHeight, size.height)
    if retHeight > size.height and retHeight - 15 <= size.height then
        retHeight = size.height
    end

    infoPanel:setContentSize(infoPanel.initSize.width, retHeight)
    infoPanel:requestDoLayout()
    scroll:setInnerContainerSize(infoPanel:getContentSize())

    scroll:getInnerContainer():setPositionY(size.height - (infoPanel:getContentSize().height))
    scroll:requestDoLayout()

    dlg:setCtrlVisible("SlipButton", retHeight > scroll:getContentSize().height)
end

-- 聚宝相关界面设置法宝
function EquipmentMgr:setArtifactForJubao(dlg, equip)
    local panel = dlg:getControl("ArtifactInfoPanel")

    local infoPanel = dlg:getControl("InfoPanel", nil, panel)
    infoPanel.initSize = infoPanel.initSize or infoPanel:getContentSize()

    -- 法宝图标
    dlg:setImage("ItemImage", InventoryMgr:getIconFileByName(equip.name), panel)

    if equip.item_polar or equip.artifact_polar then
        local polar = equip.item_polar or equip.artifact_polar
        local image = dlg:getControl("ItemImage", nil, panel)
        InventoryMgr:addArtifactPolarImage(image, polar)
    end

    -- 图标左上角等级
    dlg:setNumImgForPanel("ArtifactShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 法宝名称
    dlg:setLabelText("NameLabel", equip.name, panel, COLOR3.YELLOW)

    -- 法宝类型
    dlg:setLabelText("CommondLabel", CHS[7000145], panel)

    -- 贵重物品
    dlg:setCtrlVisible("PreciousImage", gf:isExpensive(equip, false), panel)

    -- 图标左下角限制交易/限时标记
    if InventoryMgr:isTimeLimitedItem(equip) then
        InventoryMgr:addLogoTimeLimit(dlg:getControl("ItemImage", nil, panel))
    elseif InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:addLogoBinding(dlg:getControl("ItemImage", nil, panel))
    end

    -- 道法、灵气、亲密度、金相
    local daoFa = string.format(CHS[7000190], equip.exp or 0, equip.exp_to_next_level or 0)
    local lingQi = string.format(CHS[7000190], equip.nimbus or 0, Formula:getArtifactMaxNimbus(equip.level or 0))
    local polarAttrib = EquipmentMgr:getPolarAttribByArtifact(equip)
    dlg:setLabelText("DaoFaLabel2", daoFa, panel)
    dlg:setLabelText("LingqiLabel2", lingQi, panel)
    dlg:setLabelText("PolarLabel2", polarAttrib, panel)
    dlg:setLabelText("PolarLabel1", string.format(CHS[7000183], gf:getPolar(equip.item_polar)), panel)

    -- 法宝技能
    local descPanel1 = dlg:getControl("DescPanel1", nil, infoPanel)
    descPanel1.initSize = descPanel1.initSize or descPanel1:getContentSize()
    local desc1 = string.format(CHS[7000151], CHS[7000152]) .. CHS[7000078] .. EquipmentMgr:getArtifactSkillDesc(equip.name)
   -- local height1 = dlg:setColorText(desc1, "DescPanel1", panel, nil, nil, COLOR3.WHITE, 19, true)

    -- 特殊技能
    local descPanel2 = dlg:getControl("DescPanel2", nil, infoPanel)
    descPanel2.initSize = descPanel2.initSize or descPanel2:getContentSize()
    local desc2
    if equip.extra_skill and equip.extra_skill ~= "" then
        local extraSkillName = SkillMgr:getArtifactSpSkillName(equip.extra_skill)
        local extraSkillLevel = equip.extra_skill_level
        local extraSkillDesc = SkillMgr:getSkillDesc(extraSkillName).desc
        desc2 = string.format(CHS[7000311], extraSkillName, extraSkillLevel)
            .. CHS[7000078] .. extraSkillDesc
    else
        desc2 = string.format(CHS[7000151], CHS[7000153]) .. CHS[7000078]
            .. CHS[3001385] .. "\n" .. CHS[7000310]
    end

    local height1 = dlg:setColorText(desc1 .. "\n" .. desc2, "DescPanel1", panel, nil, nil, COLOR3.LIGHT_WHITE, 19, true)
    -- 限制交易时间
    local bindLabel = dlg:getControl("BindLabel", nil, infoPanel)
    local bindLabelHeight = bindLabel:getContentSize().height
    local height3 = 0
    if InventoryMgr:isLimitedItem(equip) then
        local str, day = gf:converToLimitedTimeDay(equip.gift)
        dlg:setLabelText("BindLabel", str, infoPanel)
        height3 = 0
        dlg:setCtrlVisible("SeparateImage_3", true, infoPanel)
    else
        height3 = bindLabelHeight + 5
        dlg:setLabelText("BindLabel", " ", infoPanel)
        dlg:setCtrlVisible("SeparateImage_3", false, infoPanel)
    end

    -- 限时不会出现，直接扣
    local height4 = 28 + 5

    -- 调整滑动高度
    local realHeight = infoPanel.initSize.height - (descPanel1.initSize.height - height1) - (descPanel2.initSize.height) - height3 - height4
    local scroll = dlg:getControl("ScrollView", nil, panel)
    local size = scroll:getContentSize()
    local layer = scroll:getInnerContainer()
    layer:setContentSize(size.width, realHeight)
    infoPanel:setContentSize(size.width, realHeight)
    infoPanel:requestDoLayout()
    layer:requestDoLayout()
    -- 当滚动的实际高度小于控件高度，不让其滚动
    scroll:setEnabled(realHeight > scroll:getContentSize().height)

    scroll:getInnerContainer():setPositionY(size.height - realHeight)
    scroll:requestDoLayout()

    dlg:setCtrlVisible("SlipButton", realHeight > scroll:getContentSize().height)
end

-- 判断是否符合属性炼化条件
function EquipmentMgr:judgeEquipAttribRefining(pos, refiningType)
    if not DistMgr:checkCrossDist() then return end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(pos) then
        gf:ShowSmallTips(CHS[3002488])
        return
    end

    local limitLevel = 60
    local color = CHS[3002489]
    if refiningType == 3 then
        color = CHS[3002490]
        limitLevel = 65
    end

    if Me:queryBasicInt("level") < limitLevel then
        gf:ShowSmallTips(string.format(CHS[3002491], limitLevel))
        return
    end

    local equip = InventoryMgr:getItemByPos(pos)
    if nil == equip then return end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if equip.req_level < 60 then
        gf:ShowSmallTips(string.format(CHS[3002492], color))
        return
    end

    return true
end

-- 判断是否符合蓝属性强化条件
function EquipmentMgr:judgeEquipAttribBlueStrengthen(pos, selectAttrib)
    if not DistMgr:checkCrossDist() then return end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(pos) then
        gf:ShowSmallTips(CHS[7200003])
        return
    end

    local equip = InventoryMgr:getItemByPos(pos)
    if nil == equip then return end
    local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, selectAttrib.field)
    if selectAttrib.value >= maxValue then
        gf:ShowSmallTips(CHS[3002495])
        return
    end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    return true
end

-- 判断是否符合粉、黄属性强化条件
function EquipmentMgr:judgeEquipAttribStrengthen(pos, selectAttrib)
    if not DistMgr:checkCrossDist() then return end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(pos) then
        gf:ShowSmallTips(CHS[7200003])
        return
    end
    local levelMint = 60
    local color = CHS[3002489]
    if selectAttrib.refiningType == 3 then
        levelMint = 65
        color = CHS[3002490]
    end

    if Me:queryBasicInt("level") < levelMint then
        gf:ShowSmallTips(string.format(CHS[3002491], levelMint))
        return
    end
    local equip = InventoryMgr:getItemByPos(pos)
    if nil == equip then return end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if equip.req_level < 60 then
        gf:ShowSmallTips(string.format(CHS[3002494], color))
        return
    end

    local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, selectAttrib.field)
    if selectAttrib.value >= maxValue then
        gf:ShowSmallTips(CHS[3002495])
        return
    end

    return true
end

-- 是否冷却中，当前用于首饰转换
function EquipmentMgr:isCoolTimed(jewelry)
    if jewelry.transform_num and jewelry.transform_num >= Const.JEWELRY_TRANSFORM_MAX_COUNT then
        return false
    end

    if jewelry.transform_cool_ti and jewelry.transform_cool_ti > 0 and jewelry.transform_cool_ti > gf:getServerTime() then
        return true
    end

    return false
end

function EquipmentMgr:getCoolTimedByDay(jewelry)
    if not EquipmentMgr:isCoolTimed(jewelry) then return "" end
    local leftTime = jewelry.transform_cool_ti - gf:getServerTime()
    local day = math.min(7, math.ceil(leftTime / 86400))
    return string.format(CHS[2000139], day)
end

function EquipmentMgr:isEquipment(equip)
    if equip.item_type ~= ITEM_TYPE.EQUIPMENT then return false end

    if equip.equip_type == EQUIP_TYPE.WEAPON or equip.equip_type == EQUIP_TYPE.HELMET or equip.equip_type == EQUIP_TYPE.ARMOR or equip.equip_type == EQUIP_TYPE.BOOT then
        return true
    end

    return false
end

function EquipmentMgr:getArtifactBuffPercentStr(arf)
    local tiggerPercent = Formula:getArtifactTriggerPercent(arf)
    local str = string.format(CHS[4200554], tiggerPercent)

    if arf.name == CHS[7000142] then
        str = string.format(CHS[4400037], tiggerPercent)
    end

    return str
end

-- 获取首饰强化信息
function EquipmentMgr:getJewelryDevelopInfo(jewelry)
    if not jewelry then
        Log:D("别逗了，传入的首饰为空！！！！")
        return ""
    end

    local level = jewelry.strengthen_level or 0
    local degree = jewelry.strengthen_degree or 0

    local str

    if degree == 0 then
        str = string.format(CHS[4010208], level)
    else
        str = string.format(CHS[4010209], level, degree / 100)  --强化%d级(%0.2f%%)
    end

    if level == 0 and degree == 0 then
        return "", 0, 0
    end

    return str, level, degree
end

function EquipmentMgr:getJewelryDevelopValue(jewelryType, destLevel)
    if jewelryType == EQUIP_TYPE.NECKLACE then
        -- 项链
        return destLevel * 50
    elseif jewelryType == EQUIP_TYPE.BALDRIC then
        -- 玉佩
        return destLevel * 80
    elseif jewelryType == EQUIP_TYPE.WRIST then
        -- 手镯
        return destLevel * 10
    end
end

-- 获取两个强化等级段的差值
function EquipmentMgr:getJewelryDevelopDiff(jewelryType, lv, destLv)
    return EquipmentMgr:getJewelryDevelopValue(jewelryType, destLv) - EquipmentMgr:getJewelryDevelopValue(jewelryType, lv)
end

-- forceValue，正常的都为nil即可，名片好像会传入固定值
-- 返回字符串，例如  伤害：123
-- 第二个参数返回最后数值 基础 + 强化的
function EquipmentMgr:getJewelryAttributeInfo(jewelry)
    local attValueStr = string.format("%s_%d", MaterialAtt[jewelry.equip_type].field, Const.FIELDS_NORMAL)
    local attValue = jewelry.extra[attValueStr] or jewelry.fromCardValue or 0

    -- forceValue 正常为nil
    if forceValue and forceValue ~= 0 then
        attValue = forceValue
    end

    local attName = MaterialAtt[jewelry.equip_type].att

    local addField = string.format("%s_%d", MaterialAtt[jewelry.equip_type].field, Const.FIELDS_STRENGTHEN)
    local addValue = jewelry.extra[addField] or 0
    local funStr = string.format("%s: %d", MaterialAtt[jewelry.equip_type].att, attValue + addValue)

    local funStrForColorText = string.format("%s: %d", MaterialAtt[jewelry.equip_type].att, attValue + addValue)
    local level = jewelry.strengthen_level or 0
    if level > 0 then
        funStrForColorText = string.format("%s: #B%d#n", MaterialAtt[jewelry.equip_type].att, attValue + addValue)
    end

    return funStr, attValue + addValue, funStrForColorText
end

function EquipmentMgr:isShowGuideButton(dlgName)
--[[
    #define EQUIP_SPLIT_INSTRUCTION_MARK        0   // 装备拆分指引
    #define EQUIP_REFORM_INSTRUCTION_MARK       1   // 装备重组指引
    #define EQUIP_REFINE_INSTRUCTION_MARK       2   // 装备炼化指引
    #define EQUIP_UPGRADE_INSTRUCTION_MARK      3   // 装备改造指引
    #define EQUIP_SUIT_REFINE_INSTRUCTION_MARK  4   // 套装炼化指引
    #define EQUIP_EVOLVE_INSTRUCTION_MARK       5   // 装备进化指引
--]]

    local MAP = {
        EquipmentEvolveDlg = 6,
        EquipmentRefiningDlg = 3,
        EquipmentRefiningSuitDlg = 5,
        EquipmentReformDlg = 2,
        EquipmentSplitDlg = 1,
        EquipmentUpgradeDlg = 4,
    }

    local lv = Me:queryBasicInt("level")
    if lv < 80 then return true end

    local flag = Bitset.new(Me:queryBasicInt("graphic_instruction_mark"))
    if flag:isSet(MAP[dlgName]) then
        return false
    end

    return true
end

MessageMgr:regist("MSG_SUBMIT_EQUIP", EquipmentMgr)
MessageMgr:regist("MSG_DESTROY_VALUABLE_LIST", EquipmentMgr)
MessageMgr:regist("MSG_DESTROY_VALUABLE", EquipmentMgr)
MessageMgr:regist("MSG_OPEN_TIANXS_DIALOG", EquipmentMgr)
MessageMgr:regist("MSG_EQUIP_CARD", EquipmentMgr)
MessageMgr:hook("MSG_INVENTORY", EquipmentMgr, "EquipmentMgr")
MessageMgr:regist("MSG_PRE_UPGRADE_EQUIP", EquipmentMgr)
MessageMgr:hook("MSG_UPGRADE_EQUIP_COST", EquipmentMgr, "EquipmentMgr")
