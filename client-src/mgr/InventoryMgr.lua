-- InventoryMgr.lua
-- created by cheny Dec/26/2014
-- 物品管理器

local Bitset = require('core/Bitset')
local ItemInfo = require (ResMgr:getCfgPath("ItemInfo.lua"))
local AutoWalkItem = require (ResMgr:getCfgPath("AutoWalkItem.lua"))
local EquipmentAtt = require(ResMgr:getCfgPath("EquipmentAttribute.lua"))
local changeCardAtt = require(ResMgr:getCfgPath("ChangeCardAttrib.lua"))
local changeCardInfo = require(ResMgr:getCfgPath("ChangeCardInfo.lua"))
local ChangeCardShapeOffset = require(ResMgr:getCfgPath("ChangeCardShapeOffset.lua"))
local SkillDesc = require(ResMgr:getCfgPath("SkillDesc.lua"))
local FurnitureInfo = require (ResMgr:getCfgPath("FurnitureInfo.lua"))
local QuickUseItemCfg = require (ResMgr:getCfgPath("QuickUseItemConfig.lua"))
local CrossDistCantUseItem = require (ResMgr:getCfgPath("CrossDistCantUseItem.lua"))
local FashionItem = require("cfg/FashionItem")
local CanDecomposeItem = require("cfg/CanDecomposeItem")

-- 使用付费道具时道具名与处理函数的映射
local useSpecialItemCallFunc = require('mgr.Inventory/UseSpecialItemCallFunc')

InventoryMgr = Singleton("InventoryMgr")
InventoryMgr.inventory = {}
InventoryMgr.isShowNeedVip = {["bag"] = {[3] = false, [4] = false}, ["store"] = {[3] = false, [4] = false}}
InventoryMgr.isShowNeedVipInHomeStore = {["store"] = {[1] = false, [2] = false}}
-- 变身卡获取信息（用于变身卡套，是否获取过）
InventoryMgr.changeCardGetInfo = {}

-- 物品连续出售三次的记录信息
InventoryMgr.sellAllTipsFlag = {}

-- 需要记录限制交易道具的界面,每一位表示的是单独对应checkbox
local USE_LIMIT_ITEM_DLG = {
    ["JewelryUpgradeDlg"] = 1,
    ["EquipmentSplitDlg"] = 1,
    ["EquipmentStrengthenDlg"] = 1,
    ["EquipmentRefiningPinkDlg"] = 1,
    ["EquipmentRefiningYellowDlg"] = 1,
    ["AlchemyDlg"] = 1,
    ["EquipmentRefiningSuitDlg"] = 1,
    ["PetDevelopDlg"] = 1,
    ["PetEffectDlg"] = 1,
    ["EquipmentUpgradeDlg"] = 1,
    ["PetSkillDlg"] = 1,
    ["PetAddLongevityDlg"] = 1,
    ["PetAttribDlg"] = 11,
    ["EquipmentSplitDlghundunyu"] = 0,
    ["EquipmentEvolveDlg"] = 0,
    ["PetGrowingDlg"] = 1,
    ["PetDianhuaDlg"] = 1,
    ["PetFuseDlg"] = 1,
    ["PetHorseTameDlg"] = 1,
    ["PetHorseDlg"] = 1,
    ["PetSkillDlg_DunWu"] = 1,
    ["PetDunWuDlg_Forget"] = 1,
    ["PetDunWuDlg_DunWu"] = 1,
    ["ArtifactSkillUpDlg"] = 1,
    ["EquipmentDegenerationDlg"] = 1,
    ["WatchCentreBattleInterfaceDlg"] = 0,  -- 是否跳过
    ["EquipmentRefiningSuitDlgGem"] = 0,
    ["EquipmentRefiningYellowDlgGem"] = 0,
    ["EquipmentRefiningPinkDlgGem"] = 0,
    ["PartyBeatMonsterDlg"] = 0,
    ["PetYuhuaDlg"] = 1,
    ["EquipmentRefiningGongmingDlg"] = 1,
    ["EquipmentRefiningGongmingDlgGem"] = 0,
    ["AlchemyDlg_naijiu"] = 0,
    ["JewelryDecomposeDlg"] = 1,
    ["XunBaoDlg"] = 0,
    ["WenquanDlg"] = 0,
}

local USE_LIMIT_ITEM_DLG_KEY = {
    [1] = "JewelryUpgradeDlg",
    [2] = "EquipmentSplitDlg",
    [3] = "EquipmentStrengthenDlg",
    [4] = "EquipmentRefiningPinkDlg",
    [5] = "EquipmentRefiningYellowDlg",
    [6] = "AlchemyDlg",
    [7] = "EquipmentRefiningSuitDlg",
    [8] = "PetDevelopDlg",
    [9] = "PetEffectDlg",
    [10] = "EquipmentUpgradeDlg",
    [11] = "PetSkillDlg",
    [12] = "PetAddLongevityDlg",
    [13] = "PetAttribDlg",
    [14] = "EquipmentSplitDlghundunyu",
    [15] = "EquipmentEvolveDlg",
    [16] = "PetGrowingDlg",
    [17] = "PetDianhuaDlg",
    [18] = "PetFuseDlg",
    [19] = "PetHorseTameDlg",
    [20] = "PetSkillDlg_DunWu",
    [21] = "PetHorseDlg",
    [22] = "PetDunWuDlg_Forget",
    [23] = "PetDunWuDlg_DunWu",
    [24] = "ArtifactSkillUpDlg",
    [25] = "EquipmentDegenerationDlg",
    [26] = "WatchCentreBattleInterfaceDlg",
    [27] = "EquipmentRefiningSuitDlgGem",
    [28] = "EquipmentRefiningYellowDlgGem",
    [29] = "EquipmentRefiningPinkDlgGem",
    [30] = "PartyBeatMonsterDlg",
    [31] = "PetYuhuaDlg",
    [32] = "EquipmentRefiningGongmingDlg",
    [33] = "EquipmentRefiningGongmingDlgGem",
    [34] = "AlchemyDlg_naijiu",
    [35] = "JewelryDecomposeDlg",
    [36] = "XunBaoDlg",
    [37] = "WenquanDlg",
}

-- 装备类型对应位置
local MaterialTypeAtt = {
    [EQUIP_TYPE.BALDRIC] = EQUIP.BALDRIC,
    [EQUIP_TYPE.NECKLACE] = EQUIP.NECKLACE,
    [EQUIP_TYPE.WRIST] = EQUIP.LEFT_WRIST,
}

-- 跟随宠物类型
local FOLLOW_PET_BY_TYPE = {
    CHS[2000544],
    CHS[2000545],
}

-- 包裹、行囊均可放25 个物品，位置范围为 41 - 166
local BAG_PAGE_SIZE = 25
local BAG1_START = 41
local BAG2_START = BAG1_START + BAG_PAGE_SIZE
local BAG3_START = BAG2_START + BAG_PAGE_SIZE
local BAG4_START = BAG3_START + BAG_PAGE_SIZE
local BAG5_START = BAG4_START + BAG_PAGE_SIZE
local BAG_START = BAG1_START
local BAG_END = BAG5_START + BAG_PAGE_SIZE - 1

-- 可叠加的数量
local ITEM_MAX_AMOUNT = {
    [0] = 999,
    [1] = 10,
    [2] = 1,
}

-- 天生技能秘笈
local PET_RAW_SKILL_BOOKS = {
    [CHS[3000071] .. CHS[3000087]] = CHS[3000071],
    [CHS[3000072] .. CHS[3000087]] = CHS[3000072],
    [CHS[3000073] .. CHS[3000087]] = CHS[3000073],
    [CHS[3000074] .. CHS[3000087]] = CHS[3000074],
    [CHS[3000075] .. CHS[3000087]] = CHS[3000075],
    [CHS[3000076] .. CHS[3000087]] = CHS[3000076],
    [CHS[3000077] .. CHS[3000087]] = CHS[3000077],
    [CHS[3000078] .. CHS[3000087]] = CHS[3000078],
    [CHS[3000079] .. CHS[3000087]] = CHS[3000079],
    [CHS[3000080] .. CHS[3000087]] = CHS[3000080],
    [CHS[3000081] .. CHS[3000087]] = CHS[3000081],
    [CHS[3000082] .. CHS[3000087]] = CHS[3000082],
    [CHS[3000083] .. CHS[3000087]] = CHS[3000083],
    [CHS[3000084] .. CHS[3000087]] = CHS[3000084],
}

-- 使用物品的对象
InventoryMgr.USE_ITEM_OBJ = {
    USER    = 1,
    PET     = 2,
    GUARD   = 3,
}

-- 装备地图
local EQUIPMENT_BACKIMAGE =
    {
        [EQUIP.WEAPON] = ResMgr.ui.equip_weapon_img,
        [EQUIP.HELMET] = ResMgr.ui.equip_helmet_img,
        [EQUIP.BOOT] = ResMgr.ui.equip_boot_img,
        [EQUIP.ARMOR] = ResMgr.ui.equip_armor_img,
        [EQUIP.BALDRIC] = ResMgr.ui.equip_yupei_img,
        [EQUIP.NECKLACE] = ResMgr.ui.equip_xianglian_img,
        [EQUIP.LEFT_WRIST] = ResMgr.ui.equip_shouzhuo_img,
        [EQUIP.RIGHT_WRIST] = ResMgr.ui.equip_shouzhuo_img,
        [EQUIP.TALISMAN] = ResMgr.ui.equip_talisman_img,
        [EQUIP.ARTIFACT] = ResMgr.ui.equip_artifact_img,
        [EQUIP.FASION_DRESS] = ResMgr.ui.equip_armor_img,
        [EQUIP.FASION_BALDRIC] = ResMgr.ui.equip_yupei_img,
        [EQUIP.FASION_HAIR] = ResMgr.ui.equip_hair_img,
        [EQUIP.FASION_UPPER] = ResMgr.ui.equip_upper_img,
        [EQUIP.FASION_LOWER] = ResMgr.ui.equip_lower_img,
        [EQUIP.FASION_ARMS] = ResMgr.ui.equip_arms_img,
        [EQUIP.EQUIP_FOLLOW_PET] = ResMgr.ui.equip_pet_img,
        [EQUIP.FASION_BACK] = ResMgr.ui.equip_back_img,
    }

local BINDING_STATE = {
    BINDING = 1,
    UNBINDING = 0,
}

local MALE = "1"
local FEMALE = "2"
local GENDER_ITEM =
{
    [MALE..MALE]        = {[CHS[6000262]] = true},                         -- 百合
    [MALE..FEMALE]      = {[CHS[6000263]] = true, [CHS[6000262]] = true},  -- 玫瑰,百合
    [FEMALE..MALE]      = {[CHS[6000264]] = true, [CHS[6000262]] = true},  -- 巧克力,百合
    [FEMALE..FEMALE]    = {[CHS[6000262]] = true},                         -- 百合
}


local FEED_JINGGUAI_ITEM =
{
    [CHS[6000508]] = 1, -- 拘首环
    [CHS[6000509]] = 2, -- 困灵砂
    [CHS[6000510]] = 3, -- 驱力刺
    [CHS[6000511]] = 4, -- 定鞍石
    [CHS[6000512]] = 5, -- 控心玉
}

local QINGMING_ITEM =
{
    [CHS[7002029]] = 1,  -- 黑驴蹄子
    [CHS[7002030]] = 2,  -- 桃木剑
    [CHS[7002031]] = 3,  -- 照妖镜
}

-- 获取道具可堆叠的最大个数
local function getItemDoubleMax(item)
    return InventoryMgr:getItemDoubleMax(item)
end

function InventoryMgr:getItemDoubleMax(item)
    local itemName = item
    if type(item) == 'table' then
        if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
            -- 未鉴定装备直接返回最大叠加10个
            local itemInfo = ItemInfo[CHS[3002820]]
            return ITEM_MAX_AMOUNT[itemInfo.double_type or 0]
        else
            -- 其他物品数据用物品名称去ItemInfo中取
            itemName = item.name
        end
    end

    local itemInfo = ItemInfo[itemName]
    if not itemInfo then
        -- 还可能是家具
        local furnitureInfo = FurnitureInfo[itemName]
        if furnitureInfo then
            return ITEM_MAX_AMOUNT[furnitureInfo.double_type or 0]
        end

        if CHS[2200045] == itemName then
            return 1
        end

        return 0
    end

    local doubleType = itemInfo.double_type or 0
    return ITEM_MAX_AMOUNT[doubleType]
end



local function sortItems(l, r)
    if l.layer < r.layer then return true end
    if l.layer > r.layer then return false end

    -- 是否是装备
    local function isEquip(item)
        if item.item_type and l.item.item_type == ITEM_TYPE.EQUIPMENT then
           return true
        end

        return false
    end

    -- 道具编号进行排序
    if l.item.item_type and l.item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD and r.item.item_type and r.item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        local lCardInfo = changeCardInfo[l.item.name]
        local rCardInfo = changeCardInfo[r.item.name]
        if ORDER_BY_CARD_TYPE[lCardInfo.card_type] < ORDER_BY_CARD_TYPE[rCardInfo.card_type] then return true end
        if ORDER_BY_CARD_TYPE[lCardInfo.card_type] > ORDER_BY_CARD_TYPE[rCardInfo.card_type] then return false end
        if lCardInfo.order < rCardInfo.order then return true end
        if lCardInfo.order > rCardInfo.order then return false end
    elseif isEquip(l.item) and isEquip(r.item) and l.item.equip_type == r.item.equip_type then
        -- 非未鉴定装备排序比较复杂，同一部位的，等级高的装备icon乱，需要根据req_level排序，详见任务  WDSY-25624 装备排序异常
        -- isEquip(l.item) 是否是    装备
        if l.item.req_level < r.item.req_level then return true end
        if l.item.req_level > r.item.req_level then return false end
        if l.item.icon < r.item.icon then return true end
        if l.item.icon > r.item.icon then return false end
    else
    if l.item.icon < r.item.icon then return true end
    if l.item.icon > r.item.icon then return false end
    end
    -- 如果是装备（非未鉴定装备），按照装备品质排序（绿、黄、粉、蓝）
    local lEquipColor = 0
    local rEquipColor = 0
    if l.item.item_type and l.item.item_type == ITEM_TYPE.EQUIPMENT and l.item.unidentified == 0 then
        lEquipColor = EQUIPMENT_COLOR_ORDER[l.item.color] or 0
    end

    if r.item.item_type and r.item.item_type == ITEM_TYPE.EQUIPMENT and r.item.unidentified == 0 then
        rEquipColor = EQUIPMENT_COLOR_ORDER[r.item.color] or 0
    end

    if lEquipColor < rEquipColor then return true end
    if lEquipColor > rEquipColor then return false end

    -- 物品等级进行排序
    local lLevel = l.item.level or 0
    local rLevel = r.item.level or 0
    if lLevel < rLevel then return true end
    if lLevel > rLevel then return false end

    -- 物品当前灵气进行排序
    local lNimbus = l.item.nimbus or 0
    local rNimbus = r.item.nimbus or 0
    if lNimbus < rNimbus then return true end
    if lNimbus > rNimbus then return false end

    if ITEM_TYPE.MEDICINE == l.item.item_type then
        -- 药品，根据补充的数值排序
        local lExtra = l.item.extra or {}
        local rExtra = r.item.extra or {}
        local lv = (lExtra.mana_1 or 0) + (lExtra.life_1 or 1)
        local rv = (rExtra.mana_1 or 0) + (rExtra.life_1 or 1) -- 设置 1 是为了让蓝药排后

        if lv < rv then return true end
        if lv > rv then return false end
    else
        -- 按 icon 排序
        if l.item.icon < r.item.icon then return true end
        if l.item.icon > r.item.icon then return false end
    end

    -- 耐久度
    local ld = l.item.durability or 0
    local rd = r.item.durability or 0
    if ld < rd then return true end
    if ld > rd then return false end

    -- 限时道具排序
    if InventoryMgr:getItemTimeLimitedOrder(l.item) < InventoryMgr:getItemTimeLimitedOrder(r.item) then return true end
    if InventoryMgr:getItemTimeLimitedOrder(l.item) > InventoryMgr:getItemTimeLimitedOrder(r.item) then return false end

    -- 限制道具排序
    if InventoryMgr:getItemLimitedOrder(l.item) < InventoryMgr:getItemLimitedOrder(r.item) then return true end
    if InventoryMgr:getItemLimitedOrder(l.item) > InventoryMgr:getItemLimitedOrder(r.item) then return false end

    -- 数量
    if l.item.amount < r.item.amount then return true end
    if l.item.amount > r.item.amount then return false end

    -- 结婚日期
    local ltime = l.item.marriage_start_time or 0
    local rtime = r.item.marriage_start_time or 0

    if ltime < rtime then return false end
    if ltime > rtime then return true end

    -- 名字
    return l.item.name < r.item.name
end


function InventoryMgr:getSortItems()
    return sortItems
end

InventoryMgr.UseLimitItemDlgs = {}
InventoryMgr.isUseGoldBuyFenglingwan = false
InventoryMgr.isUseGoldRefillNimbus = false
InventoryMgr.isUseGoldRefineArtifact = false

function InventoryMgr:getLimitItemDlgsFromXml()
    local strUseLimitItemDlgs = cc.UserDefault:getInstance():getStringForKey("UseLimitItemDlgs")
    InventoryMgr.UseLimitItemDlgs = USE_LIMIT_ITEM_DLG

    if strUseLimitItemDlgs == "" then
        self:saveLimitItemDlgsToXml()
    else
        local tempTable = gf:split(strUseLimitItemDlgs, ",")

        for k, v in pairs(USE_LIMIT_ITEM_DLG_KEY) do
            if tempTable[k] then
                InventoryMgr.UseLimitItemDlgs[v] = tonumber(tempTable[k])
            end
        end

    end

end

function InventoryMgr:getEquipment_Backimage()
    return EQUIPMENT_BACKIMAGE
end

function InventoryMgr:setLimitItemDlgs(dlgName, value)
    InventoryMgr.UseLimitItemDlgs[dlgName] = value
    InventoryMgr:saveLimitItemDlgsToXml()
end

function InventoryMgr:getLimitItemFlag(dlgName, def)
    return InventoryMgr.UseLimitItemDlgs[dlgName] or def
end

function InventoryMgr:saveLimitItemDlgsToXml()
    local strUseLimitItemDlgs = ""
    for k, v in pairs(USE_LIMIT_ITEM_DLG_KEY) do
        if InventoryMgr.UseLimitItemDlgs[v] then
            strUseLimitItemDlgs = strUseLimitItemDlgs .. InventoryMgr.UseLimitItemDlgs[v] .. ","
        end
    end

    if strUseLimitItemDlgs ~= "" then
        strUseLimitItemDlgs = string.sub(strUseLimitItemDlgs, 1, -2)
        cc.UserDefault:getInstance():setStringForKey("UseLimitItemDlgs", strUseLimitItemDlgs)
    end
end

function InventoryMgr:clearData()
    self.inventory = {}
    self.isArranging = false

    InventoryMgr.dynamicCardKey = nil
end

function InventoryMgr:getItemByPos(pos)
    if self.inventory == nil or nil == pos then return end
    local item = self.inventory[pos]
    if not item then item = StoreMgr:getItemByPos(pos) end
    return item
end

-- 获取精魄类型道具
function InventoryMgr:getPetConvertItems()
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and (item['name'] == CHS[2100020] or item['name'] == CHS[2100023] or item['name'] == CHS[2100026]) then
            table.insert(items, item)
        end
    end

    return items
end

-- 获取可用的最大位置   vip不同激活的背包位置不同
function InventoryMgr:getCanUseMaxPos()
    local maxPos
    if Me:getVipType() == 0 then
        maxPos = BAG3_START - 1
    elseif Me:getVipType() == 1 or Me:getVipType() == 2 then
        maxPos = BAG4_START - 1
    elseif Me:getVipType() == 3 then
        maxPos = BAG5_START - 1
    else
        maxPos = BAG3_START - 1
    end

    local rideId = PetMgr:getRideId()
    if rideId and 0 ~= rideId and PetMgr:isHaveFenghuaTimeById(rideId) then
        maxPos = maxPos + BAG_PAGE_SIZE
    end

    return maxPos
end

-- 获取背包第一个空位置
function InventoryMgr:getFirstEmptyPos()
    local maxUseMaxPos = InventoryMgr:getCanUseMaxPos()
    for i = BAG_START, maxUseMaxPos do
        if not self.inventory[i] then
            return i
        end
    end

    return nil
end

-- 获取背包空位置的个数
function InventoryMgr:getEmptyPosCount()
    local count = 0
    for i = BAG_START, InventoryMgr:getCanUseMaxPos() do
        if not self.inventory[i] then
            count = count + 1
        end
    end

    return count
end

-- 获取包裹物品信息
-- 返回数组，每个元素包含如下字段：pos、imgFile、text
function InventoryMgr:getBag1Items()
    return self:getBagItems(BAG1_START, BAG1_START + BAG_PAGE_SIZE - 1)
end

-- 获取行囊1物品信息
-- 返回数组，每个元素包含如下字段：pos、imgFile、text
function InventoryMgr:getBag2Items()
    return self:getBagItems(BAG2_START, BAG2_START + BAG_PAGE_SIZE - 1)
end

-- 获取获取行囊2物品信息
function InventoryMgr:getBag3Items()
    return self:getBagItems(BAG3_START, BAG3_START + BAG_PAGE_SIZE - 1)
end

-- 获取获取行囊3物品信息
function InventoryMgr:getBag4Items()
    return self:getBagItems(BAG4_START, BAG4_START + BAG_PAGE_SIZE - 1)
end

function InventoryMgr:getBag5Items()
    return self:getBagItems(BAG5_START, BAG5_START + BAG_PAGE_SIZE - 1)
end

-- 获取指定物品
-- filter.name  选取的物品名称
-- filter.level 选取的物品等级(可选)
function InventoryMgr:filterBagItems(filter)
    return self:getBagItems(BAG_START, BAG_END, filter)
end

-- 根据物品类别获取指定物品
function InventoryMgr:filterBagItemsByType(itemType)
    return self:getBagItemsByType(BAG_START, BAG_END, itemType)
end

-- 获取所有装备的属性
function InventoryMgr:getAllEquipAttr()
    return InventoryMgr:getEquipAttrByArray({EQUIP.HELMET, EQUIP.ARMOR, EQUIP.WEAPON, EQUIP.BOOT})
end

-- 获取所有装备的属性
function InventoryMgr:getEquipAttrByArray(array)
    local equipPos = array
    local equips = {}

    for i = 1, #equipPos do
        local equip = InventoryMgr:getEquipAttr(equipPos[i])
        if equip then
            table.insert(equips, equip)
        end
    end

    return equips
end

-- 获取装备的属性
function InventoryMgr:getEquipAttr(pos)
    return self.inventory[pos]
end

-- 获取指定道具类型的物品
function InventoryMgr:getBagItemsByType(posStart, posEnd, itemType)
    local data = {}
    data.count = 0
    for i = posStart, posEnd do
        local item = self.inventory[i]
        local info = { pos = i }
        if item then
            info.imgFile = ResMgr:getItemIconPath(item.icon)

            if item.amount > 1 then
                info.text = tostring(item.amount)
            end

            if item.level and item.level > 0 then
                info.level = item.level
            end

            info.icon = item.icon
        end

        if item and item['item_type'] == itemType then
            table.insert(data, info)
            data.count = data.count + 1
        end
    end

    return data
end

-- 包括 武器 衣服 鞋子 帽子
function InventoryMgr:getBagAllEquip()
    local data = {}
    data.count = 0
    for i = BAG_START, BAG_END do
        local item = self.inventory[i]
        local info = { pos = i }
        if item then
            info.imgFile = ResMgr:getItemIconPath(item.icon)

            if item.amount > 1 then
                info.text = tostring(item.amount)
            end

            if item.level and item.level > 0 then
                info.level = item.level
            end

            info.icon = item.icon
        end

        if item and item['item_type'] == ITEM_TYPE.EQUIPMENT and  self:isEquip(item["equip_type"]) then
            table.insert(data, info)
            data.count = data.count + 1
        end
    end

    return data
end

-- 获取背包中所有法宝
function InventoryMgr:getBagAllArtifacts()
    local data = {}
    for i = BAG_START, BAG_END do
        local item = self.inventory[i]
        if item and item.item_type == ITEM_TYPE.ARTIFACT then
            table.insert(data, item)
        end
    end

    return data
end

-- 获取起始位置by  page
function InventoryMgr:getStartByPage(page)
    if not page or page == 1 then
        return BAG_START
    elseif page == 2 then
        return BAG2_START
    elseif page == 3 then
        return BAG3_START
    elseif page == 4 then
        return BAG4_START
    end
end

-- 是否是武器 衣服 鞋子 帽子
function InventoryMgr:isEquip(type)
    if type >=1 and type < 4 then
        return true
    elseif type == 10 then
        return 10
    end

    return false
end

function InventoryMgr:isJewelry(equipType)
    if equipType == EQUIP_TYPE.BALDRIC or equipType == EQUIP_TYPE.WRIST or equipType == EQUIP.NECKLACE then
       return true
    else
       return false
    end
end

function InventoryMgr:isBagItemByPos(pos)
    if not pos then
        return false
    end

    if pos >= BAG_START and pos <= BAG_END then
        return true
    else
        return false
    end
end

-- 获取物品信息
-- filter 可选
-- filter.name 选取的物品名称
-- filter.level 选取的物品等级
function InventoryMgr:getBagItems(posStart, posEnd, filter)
    local data = {}
    local name = false
    local level = false
    if filter then
        name = filter.name
        level = filter.level
    end

    data.count = 0
    for i = posStart, posEnd do
        local item = self.inventory[i]
        local info = { pos = i }
        if item then
            if InventoryMgr:getIsGuard(item.name) then
                info.imgFile = ResMgr:getSmallPortrait(item.icon)
            else
                info.imgFile = ResMgr:getItemIconPath(item.icon)
            end

            if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level > 0 then
                info.req_level = item.req_level
            end

            if item.amount > 1 then
                info.text = tostring(item.amount)
            end

            if item.level and item.level > 0 then
                info.level = item.level
            end

            if item.item_type then
                info.item_type = item.item_type
            end

            local itemInfo = InventoryMgr:getItemInfoByName(item.name)

            info.isNotAddLinkAndExpressionDlg = itemInfo and itemInfo.before_use_cmd

            info.amount = item.amount

            -- 法宝相性
            if item.item_type == ITEM_TYPE.ARTIFACT and item.item_polar then
                info.item_polar = item.item_polar
            end

            info.item_unique = item.item_unique

            EventDispatcher:dispatchEvent(EVENT.GET_BAG_ITEM, info)

        end

        if not name or (item and item.name == name and (not level or item.level == level)) then
            table.insert(data, info)
            data.count = data.count + 1
        end
    end

    return data
end

-- 显示名片数据
function InventoryMgr:showOnlyFloatCardDlgEx(item, rect, notCompare)
    if not item then return end

    local equipType = item["equip_type"]
    if equipType then
        if (equipType >= 1 and equipType <= 3) or equipType == EQUIP.BOOT then
            --  装备
            if item.unidentified == 1 then
                -- 未鉴定状态
                self:showBasicMessageByItem(item, rect)
            else
                if notCompare or self:isEquipFloat(item) then
                    self:showEquipByEquipment(item, rect, true)
                else
                    local dlg = DlgMgr:openDlg("EquipmentInfoCampareDlg")
                    dlg:setFloatingCompareInfo(item)
                end
            end
        elseif equipType == EQUIP_TYPE.BALDRIC or equipType == EQUIP_TYPE.WRIST or equipType == EQUIP.NECKLACE then
            -- 首饰
            self:showJewelryByJewelry(item, rect, true, notCompare)
        elseif EquipmentMgr:GetEquipType(equipType) == 3 then
            -- 时装
            self:showFashioEquip(item, rect, true)
        elseif equipType == EQUIP_TYPE.ARTIFACT then
            -- 法宝
            self:showArtifactByArtifact(item, rect, true, notCompare)
        end
    else
        if item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
            local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
            dlg:setInfoFromItem(item, true)
            dlg:setFloatingFramePos(rect)
        elseif self:isFurniture(item) then -- 家具
            self:showFurniture(item, rect, true)
        else
            local dlg = DlgMgr:openDlg('ItemInfoDlg')   -- 道具
            dlg:setInfoFormCard(item)
            dlg:setFloatingFramePos(rect)
        end
    end
end

-- 显示各种悬浮框，不对比，
function InventoryMgr:showOnlyFloatCardDlg(item, rect)
    if not item then return end

    if (item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 0)
            or item.item_type == ITEM_TYPE.EFFECT
            or item.item_type == ITEM_TYPE.CUSTOM then
        -- 非未鉴定的装备，效果类道具
        if not item.equip_type or EquipmentMgr:GetEquipType(item.equip_type) == 3 then
            -- 时装，有些装备(聚宝斋出售的角色鸾凤宝玉数据)可能没有equip_type字段，但需要走时装逻辑
            self:showFashioEquip(item, rect, true)
        elseif EquipmentMgr:GetEquipType(item.equip_type) == 1 then
            self:showEquipByEquipment(item, rect, true)
        elseif EquipmentMgr:GetEquipType(item.equip_type) == 2 then
            self:showJewelryFloatDlg(item, rect, true)
        end
        return
    elseif item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
        dlg:setInfoFromItem(item, true)
        dlg:setFloatingFramePos(rect)
        return
    elseif item.item_type == ITEM_TYPE.ARTIFACT then  -- 法宝
        self:showArtifact(item, rect, true)
        return
    elseif self:isFurniture(item) then -- 家具
        self:showFurniture(item, rect, true)
        return
    end

    local dlg = DlgMgr:openDlg('ItemInfoDlg')
    dlg:setInfoFormCard(item)
    dlg:setFloatingFramePos(rect)
end

-- 显示道具信息悬浮框
function InventoryMgr:showItemDlg(pos, rect)
    local item = self:getItemByPos(pos)
    if not item then return end

    local itemInfo = InventoryMgr:getItemInfoByName(item.name)
    if itemInfo and itemInfo.before_use_cmd then
        gf:CmdToServer( itemInfo.before_use_cmd, {pos = pos, id = item.item_unique})
        InventoryMgr.dynamicCardKey = {pos = pos, id = item.item_unique, rect = rect, item = item}
        return
    end

    InventoryMgr.dynamicCardKey = nil
    if (item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 0) or item.item_type == ITEM_TYPE.EFFECT or item.item_type == ITEM_TYPE.CUSTOM then
        -- 非未鉴定的装备
        if EquipmentMgr:GetEquipType(item.equip_type) == 1 then
            -- 装备对比
            if self:isEquipFloat(item) then
                self:showEquipByEquipment(item, rect)
            else
                local dlg = DlgMgr:openDlg("EquipmentInfoCampareDlg")
                dlg:setFloatingCompareInfo(item)
            end
        elseif EquipmentMgr:GetEquipType(item.equip_type) == 2 then
            -- 首饰
            self:showJewelryByJewelry(item, rect)
        elseif EquipmentMgr:GetEquipType(item.equip_type) == 3 then
            -- 时装
            self:showFashioEquip(item, rect)
        end

        return
    elseif item.item_type == ITEM_TYPE.ARTIFACT then  -- 法宝
        self:showArtifactByArtifact(item, rect)
        return
    elseif item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
        dlg:setInfoFromItem(item)
        dlg:setFloatingFramePos(rect)
        return
    elseif self:isFurniture(item) then -- 家具
        self:showFurniture(item, rect)
        return
    end

    self:showItemDescDlg(pos, rect)
end

function InventoryMgr:showFashioEquip(equip, rect, isCard)
    local dlg = DlgMgr:openDlg("FashionDressInfoDlg")
    dlg:setEquipInfo(equip, isCard)
    dlg:setFloatingFramePos(rect)
end

-- 显示道具信息悬浮框
function InventoryMgr:showItemDescDlg(pos, rect, showBtnCfg)
    if self.inventory[pos] then
        local func = cc.CallFunc:create(function()
            local item = self.inventory[pos]
            if item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
                local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
                dlg:setInfoFromItem(item, true)
                dlg:setFloatingFramePos(rect)
            elseif InventoryMgr:isFurniture(item) then  -- 家具
                InventoryMgr:showFurniture(item, rect)
            else
                local dlg = DlgMgr:openDlg('ItemInfoDlg')
                dlg:setInfoFormMe(pos)
                dlg:setFloatingFramePos(rect)

                if showBtnCfg then
                    dlg:setShowButtons(showBtnCfg)
                end
            end
        end)

        gf:getUILayer():runAction(func)
    elseif StoreMgr:getCardByPos(pos) then
        local func = cc.CallFunc:create(function()
            local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
            dlg:setInfoFromItem(StoreMgr:getCardByPos(pos), true)
            dlg:setFloatingFramePos(rect)
        end)

        gf:getUILayer():runAction(func)
    end

end

-- 显示道具基本信息
function InventoryMgr:showBasicMessageDlg(name, rect, limted, args)
    if name ~= "" and name ~= nil then
        local item = {}
        item["Icon"] = self:getIconByName(name)
        item["name"] = name
        item["extra"] = nil
        item["desc"] = self:getDescript(name)
        item["isGuard"] = self:getIsGuard(name)
        item["limted"] = limted
        if args then
            for k, v in pairs(args) do
                item[k] = v
            end
        end
        local dlg = DlgMgr:openDlg('ItemInfoDlg')
        dlg:setInfoFormCard(item)
        dlg:setFloatingFramePos(rect)
    end
end

-- 显示道具基本信息通过item(外面可以修改描述)
function InventoryMgr:showBasicMessageByItem(item, rect)
    if item ~= "" and item ~= nil then
        local dlg = DlgMgr:openDlg('ItemInfoDlg')
        dlg:setInfoFormCard(item)
        dlg:setFloatingFramePos(rect)
        return dlg
    end
end

-- 显示装备信息悬浮框
function InventoryMgr:showEquipDescDlg(pos, rect, isCard)
    local equip = self:getItemByPos(pos)
    if equip == nil then return end
    self:showEquipByEquipment(equip, rect, isCard)

end

function InventoryMgr:getEquipEffectByPos(pos)
    local equip = self:getItemByPos(pos)

    if not equip then return end

    return InventoryMgr:getEquipEffect(equip)
end

function InventoryMgr:getEquipEffect(equip)

    if not equip then return end

    if equip.equip_type ~= EQUIP.WEAPON and equip.equip_type ~= EQUIP.HELMET
        and equip.equip_type ~= EQUIP.ARMOR and equip.equip_type ~= EQUIP.BOOT then
        return
    end

    local color, greenTab, yellowTab, pinkTab, blueTab
    color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)

    if equip.suit_enabled == 1 then
        return ResMgr.ui.suit_equip_back_image
    end

    if color == COLOR3.GREEN then
        return ResMgr.ui.green_equip_back_image
    elseif color == COLOR3.YELLOW then
        return ResMgr.ui.yellow_equip_back_image
    elseif color == COLOR3.MAGENTA then
        return ResMgr.ui.pink_equip_back_image
    elseif color == COLOR3.BLUE then
        return ResMgr.ui.blue_equip_back_image
    else
       return ResMgr.ui.blue_equip_back_image
    end


  --[[  if #greenTab > 0 then
        return ResMgr.ui.green_equip_back_image
    elseif #yellowTab > 0 then
        return ResMgr.ui.yellow_equip_back_image
    elseif #pinkTab > 0 then
        return ResMgr.ui.pink_equip_back_image
    elseif #blueTab > 0 then
        return ResMgr.ui.blue_equip_back_image
    end]]
end

-- 获取装备信息
function InventoryMgr:getItemInfoByName(name)
    if nil == name then return end

    local itemName = self:getParentName(name) or name
    local itemInfo

    itemInfo = ItemInfo[name] or ItemInfo[itemName]

    if not itemInfo then
        -- 可能是家具
        itemInfo = FurnitureInfo[name] or FurnitureInfo[itemName]
    end

    return itemInfo
end

-- 外面传一个道具弹出对话框
function InventoryMgr:showEquipByEquipment(equipment, rect, isCard)
    if equipment == nil then return end

    local dlg = DlgMgr:openDlg("EquipmentFloatingFrameDlg")
    dlg:setFloatingFrameInfo(equipment, isCard)
    if rect then
        dlg:setFloatingFramePos(rect)
    else
        dlg:align(ccui.RelativeAlign.centerInParent)
    end
end

-- 法宝悬浮框
function InventoryMgr:showArtifact(artifact, rect, isCard)
    if not artifact then
        return
    end

    local dlg = DlgMgr:openDlg("ArtifactInfoDlg")
    dlg:setBasicInfo(artifact, isCard)
    if rect then
        dlg:setFloatingFramePos(rect)
    else
        dlg:align(ccui.RelativeAlign.centerInParent)
    end
end

function InventoryMgr:showFurniture(furniture, rect, isCard, isNeedHidePrice)
    if not furniture then
        return
    end

    local dlg = DlgMgr:openDlg("FurnitureInfoDlg")
    dlg:setBasicInfo(furniture, isCard, false, isNeedHidePrice)
    if rect then
        dlg:setFloatingFramePos(rect)
    else
        dlg:align(ccui.RelativeAlign.centerInParent)
    end
end

-- 显示首饰信息悬浮框
function InventoryMgr:showJewelryDescDlg(pos, rect)
    local equip = self:getItemByPos(pos)
    if equip == nil then return end

    local dlg = DlgMgr:openDlg("JewelryInfoDlg")
    dlg:setJewelryInfo(equip, pos)
    dlg:setFloatingFramePos(rect)
end

-- 显示首饰悬浮框，外面传入首饰
function InventoryMgr:showJewelryFloatDlg(jewelry, rect, isCard)
    if jewelry == nil then return end
    local dlg = DlgMgr:openDlg("JewelryInfoDlg")
    dlg:setJewelryInfo(jewelry, MaterialTypeAtt[jewelry["equip_type"]], isCard)
    if rect then
        dlg:setFloatingFramePos(rect)
    else
        dlg:align(ccui.RelativeAlign.centerInParent)
    end

end

-- 从外面传一个首饰
function InventoryMgr:showJewelryByJewelry(jewelry, rect, isCard, notCompare)
    if jewelry == nil then return end

    if notCompare or self:isJewelryFloat(jewelry) then
        InventoryMgr:showJewelryFloatDlg(jewelry, rect, isCard)
    else
        local dlg = DlgMgr:openDlg("JewelryInfoCampareDlg")
        dlg:setJewelryInfoByItem(jewelry, isCard)
    end
end

-- 从外面传一个法宝
function InventoryMgr:showArtifactByArtifact(artifact, rect, isCard, notCompare)
    if not artifact then
        return
    end

    if notCompare or self:isArtifactFloat(artifact) then
        InventoryMgr:showArtifact(artifact, rect, isCard)
    else
        local dlg = DlgMgr:openDlg("ArtifactInfoCampareDlg")
        dlg:setCompareInfo(artifact, isCard)
    end
end


function InventoryMgr:isArtifactFloat(artifact)
    if self:getItemByPos(artifact.equip_type) then
        return false
    end

    return true
end

function InventoryMgr:isEquipFloat(equip)
    if self:getItemByPos(equip.equip_type) then
        return false
    end

    return true
end

function InventoryMgr:isJewelryFloat(jewelry)
    local count = 1
    if jewelry.equip_type == EQUIP_TYPE.WRIST then
        -- 手镯可能有3个
        if self:getItemByPos(EQUIP.LEFT_WRIST) then
            if self:getItemByPos(EQUIP.LEFT_WRIST).pos ~= jewelry.pos then
                count = count + 1
            else
                return true
            end
        end

        if self:getItemByPos(EQUIP.RIGHT_WRIST) then
            if self:getItemByPos(EQUIP.RIGHT_WRIST).pos ~= jewelry.pos then
                count = count + 1
            else
                return true
            end
        end
    else
        if self:getItemByPos(jewelry.equip_type) and self:getItemByPos(jewelry.equip_type).pos ~= jewelry.pos then
            count = count + 1
        end
    end

    if count == 1 then return true end
    return nil
end

-- 武器数据
-- 返回数组，每个元素包含如下字段：pos、imgFile、text
function InventoryMgr:getEquipments()
    return self:getItemsByPosArray({EQUIP.HELMET, EQUIP.ARMOR, EQUIP.WEAPON, EQUIP.BOOT})
end

-- 第二套武器数据
function InventoryMgr:getBackEquipments()
    return self:getItemsByPosArray({EQUIP.BACK_HELMET, EQUIP.BACK_ARMOR, EQUIP.BACK_WEAPON, EQUIP.BACK_BOOT})
end

-- 首饰数据
-- 返回数组，每个元素包含如下字段：pos、imgFile、text
function InventoryMgr:getJewelrys()
    return self:getItemsByPosArray({EQUIP.BALDRIC, EQUIP.NECKLACE, EQUIP.LEFT_WRIST, EQUIP.RIGHT_WRIST})
end

-- 第二套首饰数据
function InventoryMgr:getBackJewelrys()
    return self:getItemsByPosArray({EQUIP.BACK_BALDRIC, EQUIP.BACK_NECKLACE, EQUIP.BACK_LEFT_WRIST, EQUIP.BACK_RIGHT_WRIST})
end

-- 第一套法宝数据
function InventoryMgr:getArtifact()
    return self:getItemsByPosArray({EQUIP.ARTIFACT})
end

-- 第二套法宝数据
function InventoryMgr:getBackArtifact()
    return self:getItemsByPosArray({EQUIP.BACK_ARTIFACT})
end

-- 获取时装数据
function InventoryMgr:getFashionData()
    return self:getItemsByPosArray({EQUIP.FASION_DRESS, EQUIP.FASION_BALDRIC})
end

-- 获取时装穿戴数据
function InventoryMgr:getFashionValue(fashionOnly)
    local p = {EQUIP.FASION_DRESS}
    if not fashionOnly then
        table.insert(p, EQUIP.FASION_BALDRIC)
    end
    local t = {}

    for i = 1, #p do
        if self.inventory[p[i]] then
            table.insert(t, self.inventory[p[i]])
        end
    end

    return t
end

-- 获取跟宠数据
function InventoryMgr:getFollowPetData()
    return self:getItemsByPosArray({EQUIP.EQUIP_FOLLOW_PET })
end

-- 获取跟宠穿戴数据
function InventoryMgr:getFollowPetValue()
    local p = {EQUIP.EQUIP_FOLLOW_PET }
    local t = {}

    for i = 1, #p do
        if self.inventory[p[i]] then
            table.insert(t, self.inventory[p[i]])
        end
    end

    return t
end

-- 获取自定义外观数据
function InventoryMgr:getCustomData()
    return self:getItemsByPosArray({EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS})
end

-- 获取自定义外观穿戴数据
function InventoryMgr:getCustomValue()
    local p = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
    local t = {}

    for i = 1, #p do
        if self.inventory[p[i]] then
            table.insert(t, self.inventory[p[i]])
        end
    end

    return t
end

-- 获取自定义外观穿戴是否满足外观展示条件
function InventoryMgr:isCustomValueFull()
    local p = {EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}

    for i = 1, #p do
        if not self.inventory[p[i]] then
            return false
        end
    end

    return true
end

function InventoryMgr:getUnOpenFunction()
    return self:getItemsByPosArray({EQUIP.TALISMAN, EQUIP.ARTIFACT})
end

-- 检查装备属于第几套装
function InventoryMgr:checkSuitNo(item)
    if item.pos <= EQUIP.BOOT then
        if Me:queryBasicInt("equip_page") == 0 then
            return 1
        else
            return 2
        end
    elseif item.pos <= EQUIP.BACK_ARTIFACT then
        if Me:queryBasicInt("equip_page") == 0 then
            return 2
        else
            return 1
        end
    else
        return 0
    end
end

-- 检查装备否在战斗中生效(包括备用装备)
function InventoryMgr:checkEquipHasUseInCombat(item)
    -- 穿戴中的装备
    if item.pos <= EQUIP.BOOT then
        return true
    end

    -- 处于备用状态，若对应的位置没有穿戴装备则战斗中会生效
    if item.pos == EQUIP.BACK_NECKLACE and not self.inventory[EQUIP.NECKLACE] then
        return true
    end

    if item.pos == EQUIP.BACK_BALDRIC and not self.inventory[EQUIP.BALDRIC] then
        return true
    end

    if item.pos == EQUIP.BACK_LEFT_WRIST and not self.inventory[EQUIP.LEFT_WRIST] then
        return true
    end

    if item.pos == EQUIP.BACK_RIGHT_WRIST and not self.inventory[EQUIP.RIGHT_WRIST] then
        return true
    end

    if item.pos == EQUIP.BACK_ARTIFACT and not self.inventory[EQUIP.ARTIFACT] then
        return true
    end


    return false
end

-- 获取指定位置的物品数据
-- 返回数组，每个元素包含如下字段：pos、imgFile、text
function InventoryMgr:getItemsByPosArray(posArray)
    local data = {}
    local count = #posArray
    for i = 1, count do
        local item = self.inventory[posArray[i]]
        local info = { pos = posArray[i] }
        if item then
            info.imgFile = ResMgr:getItemIconPath(item.icon)

            if item.amount > 1 then
                info.text = tostring(item.amount)
            end

            if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level > 0 then
                info.req_level = item.req_level
            end

            -- 法宝相性
            if item.item_type == ITEM_TYPE.ARTIFACT then
                if item.item_polar then
                    info.item_polar = item.item_polar
                end

                if item.level then
                    info.level = item.level
                end
            end
        elseif item == nil and EQUIPMENT_BACKIMAGE[posArray[i]] then
            info.imgFile = EQUIPMENT_BACKIMAGE[posArray[i]]
            info.noItemImg = true
        end

        table.insert(data, info)
    end

    data.count = count
    return data
end

-- 根据道具名称获取道具所在位置
function InventoryMgr:getItemPosByName(itemName, excludeLimited)
    for pos, item in pairs(self.inventory) do
        if item.name == itemName and (not excludeLimited or (excludeLimited and not self:isLimitedItem(item))) then
            return pos
        end
    end
end


function InventoryMgr:getBagItemPosByName(itemName)
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and itemName == item.name then
            return i - 40
        end
    end
end

-- 能否使用物品
-- pos 物品在物品栏中的位置
-- useType 物品的使用对象 InventoryMgr.USE_ITEM_OBJ
function InventoryMgr:canUseItem(pos, useType)
    local item = self.inventory[pos]

    if not item then
        return false
    end

    if not GameMgr.inCombat and not item.attrib:isSet(ITEM_ATTRIB.IN_NORMAL) then
        -- 只能在战斗中使用
        local useTips = CHS[3000066]
        if item.item_type == ITEM_TYPE.MEDICINE then
            useTips = CHS[3004065] .. useTips
        end

        gf:ShowSmallTips(useTips)
        return false
    end

    if GameMgr.inCombat and not item.attrib:isSet(ITEM_ATTRIB.IN_COMBAT) then
        -- 不能在战斗中使用
        local itemInfo = InventoryMgr:getItemInfoByName(item.name)
        if itemInfo.fight_tip then
            gf:ShowSmallTips(itemInfo.fight_tip)
        else
            gf:ShowSmallTips(CHS[3000069])
        end
        return false
    end

    if not item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_PET) and InventoryMgr.USE_ITEM_OBJ.PET == useType then
        -- 不能对宠物使用
        gf:ShowSmallTips(CHS[3000068])
        return false
    end

    if not item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_GUARD) and InventoryMgr.USE_ITEM_OBJ.GUARD == useType then
        -- 不能对守护使用
        gf:ShowSmallTips(CHS[5000050])
        return false
    end

    if not item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_USER) and InventoryMgr.USE_ITEM_OBJ.USER == useType then
        -- 不能对人使用
        gf:ShowSmallTips(CHS[3000067])
        return false
    end

    return true
end

-- 是否通过战斗指令使用的物品
function InventoryMgr:isApplyInFightCmd(item)
    if item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_VICTIM) or item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_FRIEND)
        or item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_MYSELF) or item.attrib:isSet(ITEM_ATTRIB.APPLY_NO_TARGET) then
            return true
    end

    return false
end

-- 是否跨服区组中不能使用该物品
function InventoryMgr:isCrossDistCanNotUse(itemName)
    if GameMgr:IsCrossDist() and CrossDistCantUseItem[itemName] then
        return true
    end

    return false
end

function InventoryMgr:applyItemForToy()
    local count = HomeChildMgr:getChildenCount()
    if not count then
        -- 数据没有收到，正常情况由于延迟，不给提示和反应
        return false
    elseif count <= 0 then
        gf:ShowSmallTips(CHS[4010394])  -- 你尚未拥有娃娃或天地灵石，可找#R风月谷#n的#Y送子娘娘#n了解如何获得娃娃。
        return false
    end


    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[4200778])
        return
    end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[4200779])
        return
    end


    local kids = HomeChildMgr:getChildByOrder()
    local selectId
    for _, info in pairs(kids) do
        if info.stage == HomeChildMgr.CHILD_TYPE.KID and not selectId then
            selectId = info.id
        end
    end
    if selectId then
        local dlg = DlgMgr:openDlgEx("KidInfoDlg", {selectId = selectId})
        dlg.kidsRadioGroup:setSetlctByName("CheckBox_2")

        local flag_child = Bitset.new(Me:queryBasicInt("flag_child") or 0)
        if not flag_child:isSet(FLAG_CHILD.TOY_EFF) then
            local icon = tonumber(ResMgr.ArmatureMagic.magic02074.name)
            local magic = ArmatureMgr:createUIArmature(icon)
            magic:setName(ResMgr.ArmatureMagic.magic02074.name)
            magic:getAnimation():play(ResMgr.ArmatureMagic.magic02074.action, -1, 1)
            local btn = dlg:getControl("CultureButton")
            magic:setPosition(btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5)
            btn:addChild(magic)
        end

        gf:ShowSmallTips(CHS[4200741])    -- 请选择需要佩戴玩具的儿童期娃娃！
    else
        gf:ShowSmallTips(CHS[4200742]) -- 你没有儿童期的娃娃哦！
    end
end

-- 使用物品
-- 对于只能对宠物使用的物品会调用  tryToFeedPet 接口，请在 tryToFeedPet 中做相应的处理
-- 否则直接对 Me 使用
-- 对宠物直接使用物品请调用 feedPet 接口
function InventoryMgr:applyItem(pos, amount)
    amount = amount or 1
    local item = self.inventory[pos]
    if not item then
        return
    end

    -- 某些物品跨服区组禁止使用
    if self:isCrossDistCanNotUse(item.name) then
        if not DistMgr:checkCrossDist() then return end
    end

    -- 组队情况判断
    if self:isNeedOnePerson(item) then
        gf:ShowSmallTips(CHS[3004066])
        return
    end

    -- 获取使用等级
    local meLevel = Me:queryBasicInt("level")
    local itemUseLevel = self:getItemInfoByNameAndField(item.name, "use_level")
    if itemUseLevel and itemUseLevel > meLevel then
        local itemInfo = InventoryMgr:getItemInfoByName(item.name)
        if itemInfo.level_tip then
            gf:ShowSmallTips(itemInfo.level_tip)
        else
            gf:ShowSmallTips(string.format(CHS[3004067], itemUseLevel))
        end
        return
    end

    if GameMgr.inCombat and self:isApplyInFightCmd(item) then
        gf:ShowSmallTips(CHS[5000079])

        return
    end

    -- 若同时可对宠物和玩家使用，则进入特殊处理
    if item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_PET) and item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_USER) then
        self:useToSpecial(item)
        return
    end

    if item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_PET) then
        -- 只能对宠物使用
        self:tryToFeedPet(pos)
        return
    end

    if item.attrib:isSet(ITEM_ATTRIB.APPLY_ON_GUARD) then
        self:tryToFeedGuard(pos)  -- 对守卫使用
        return
    end

    -- 装备升级方面
    if item.item_type == ITEM_TYPE.UPGRADE_ITEM then
        self:useToEquip(item)
        return
    end

    -- 付费道具
    if item.item_type == ITEM_TYPE.CHARGE_ITEM then
        if self:useToCharge(item) then
            return
        end
    end

    --  特殊处理
    if item.item_type == ITEM_TYPE.SPECIAL_ITEM
        or item.item_type == ITEM_TYPE.PLANT_MATERIAL
        or item.item_type == ITEM_TYPE.FURNITURE
        or item.item_type == ITEM_TYPE.CUSTOM
        or item.item_type == ITEM_TYPE.FIREWORK then
        if self:useToSpecial(item) then
            return
        end
    end

    if item.item_type == ITEM_TYPE.DISH then
        gf:CmdToServer('CMD_APPLY', {pos = pos, amount = amount})
        return
    end

    if item.item_type == ITEM_TYPE.TOY then
        InventoryMgr:applyItemForToy()
        return
    end

    -- 光效道具
    if item.item_type == ITEM_TYPE.EFFECT or item.item_type == ITEM_TYPE.FOLLOW_ELF then
        if self:useToEffect(item) then return end
        end

    -- 物品是装备，鉴定
    if item.item_type == ITEM_TYPE.EQUIPMENT then
        if item.unidentified == 1 then
            --EquipmentMgr:identifyEquip(item.pos)

            local bagTabDlg = DlgMgr.dlgs["BagTabDlg"]

            if bagTabDlg then
                bagTabDlg.group:setSetlctByName("EquipmentIdentifyDlgCheckBox")
                local dlg = DlgMgr:getDlgByName("EquipmentIdentifyDlg")
                dlg:initData(item.item_unique)
            else
                local dlg = DlgMgr:openDlg("EquipmentIdentifyDlg")
                dlg:initData(item.item_unique)
                DlgMgr.dlgs["BagTabDlg"].group:setSetlctByName("EquipmentIdentifyDlgCheckBox")
            end
        else
            EquipmentMgr:CMD_EQUIP(item.pos)
        end

        return
    end

    if not self:canUseItem(pos, InventoryMgr.USE_ITEM_OBJ.USER) then
        -- 不能对人使用
        return
    end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease(item) then
        SafeLockMgr:addModuleContinueCb("InventoryMgr", function() InventoryMgr:applyItem(pos, amount) end)
        return true
    end

    -- 特殊道具处理
    if AutoWalkItem[item.name] ~= nil and not CharMgr:isInScreenNPC(AutoWalkItem[item.name]) then
        AutoWalkMgr:beginAutoWalk(gf:findDest(AutoWalkItem[item.name]))
        return
    end

    -- "使用物品相当于点击当前任务提示"的道具
    local itemInfo = self:getItemInfoByName(item.name)
    if itemInfo.item_task then
        local task = TaskMgr:getTaskByName(itemInfo.item_task)
        if task then
            gf:doActionByColorText(task.task_prompt, task)
            return
        end

    end

    -- 使用物品前需要站住不动
    if itemInfo.need_stop_walk_before_use then
        Me:setAct(Const.SA_STAND, true)
        Me:sendAllLeftMoves()
    end

    -- 是否需要关闭背包,返回true则return
    if self:isCloseBag(item) then
        return
    end



    if item.attrib:isSet(ITEM_ATTRIB.EXT_DIALOG_BOX) then
        local confirm_tips = InventoryMgr:getItemInfoByNameAndField(item.name, "confirm_tips") or string.format(CHS[3000070], item.name)
        gf:confirm(confirm_tips, function()
            gf:CmdToServer('CMD_APPLY', {pos = pos, amount = amount})
        end)

        return
    else
        gf:CmdToServer('CMD_APPLY', {pos = pos, amount = amount})
    end

end

-- 是否要求单人
function InventoryMgr:isNeedOnePerson(item)
    local itemName = self:getParentName(item.name) or item.name
    local itemInfo = self:getItemInfoByName(itemName)
    if nil == itemInfo then
        gf:ShowSmallTips(CHS[3004068] .. item.name .. CHS[3004069])
        return true
    end

    if itemInfo.limit_one_person and Me:isTeamMember() then
        return true
    end
end

-- 该物品是否关闭背包,点击使用
function InventoryMgr:isCloseBag(item)
    if item.name == CHS[3004071]
        or item.name == CHS[3004070]
        or item.name == CHS[2200001] then
        DlgMgr:closeDlg("BagDlg")
        DlgMgr:closeDlg("ItemInfoDlg")
    end
end

-- 对宠物使用物品
function InventoryMgr:feedPet(petNo, itemPos, para)
    if not self:canUseItem(itemPos, InventoryMgr.USE_ITEM_OBJ.PET) then
        -- 不能对宠物使用
        return
    end

    gf:CmdToServer("CMD_FEED_PET", {
        no = petNo,
        pos = itemPos,
        para = para or ''
    })
end

-- 对守护使用物品
function InventoryMgr:feedGuard(guardId, itemPos, para)
    if not self:canUseItem(itemPos, self.USE_ITEM_OBJ.GUARD) then
        -- 不能对守护使用
        return
    end

    gf:CmdToServer("CMD_FEED_GUARD", {
        id = guardId,
        pos = itemPos,
        para = para or ''
    })
end

-- 使用装备方面物品
function InventoryMgr:useToEquip(item)
    local parentName = self:getParentName(item.name) or item.name
    local itemInfo = self:getItemInfoByName(parentName)
    if itemInfo.same_as then
        if self:getItemInfoByName(itemInfo.same_as).apply == "EquipmentRefiningAttributeDlg" then
            if EquipmentMgr:isActiveByCrystal(parentName) then
                local dlg = DlgMgr:openDlg(self:getItemInfoByName(itemInfo.same_as).apply)
                dlg:setAttribByItem(item)
            end
        else
            DlgMgr:openDlg(self:getItemInfoByName(itemInfo.same_as).apply)
        end
    else
        if itemInfo.apply == "EquipmentRefiningAttributeDlg" then
            if EquipmentMgr:isActiveByCrystal(parentName) then
                local dlg = DlgMgr:openDlg(itemInfo.apply)
                dlg:setAttribByItem(item)
            end
        elseif item.name == CHS[3004072] then
            DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
            DlgMgr:sendMsg("EquipmentChildDlg", "setEquipmentSelected", EQUIP.NECKLACE)
        elseif item.name == CHS[3004073] then
            DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
            DlgMgr:sendMsg("EquipmentChildDlg", "setEquipmentSelected", EQUIP.LEFT_WRIST)
        elseif item.name == CHS[3004074] then
            DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
            DlgMgr:sendMsg("EquipmentChildDlg", "setEquipmentSelected", EQUIP.BALDRIC)
        elseif item.name == CHS[3004075] then
            local isRefining = false
            for i,field in pairs(EquipmentMgr:getAllAttField()) do
                local str = field .. "_2"
                if item.extra[str] then
                    isRefining = true
                end
            end
            if isRefining then
                DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
            else
                DlgMgr:openDlg("EquipmentSplitDlg")
            end
        else
            if self:getItemInfoByName(item.name).apply then
                DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
            end
        end

    end
end

-- 特殊处理道具
function InventoryMgr:useToSpecial(item)
    if not GameMgr.inCombat and not item.attrib:isSet(ITEM_ATTRIB.IN_NORMAL) then
        -- 只能在战斗中使用
        local useTips = CHS[3000066]
        if item.item_type == ITEM_TYPE.MEDICINE then
            useTips = CHS[3004065] .. useTips
        end

        gf:ShowSmallTips(useTips)
        return true
    end

    if GameMgr.inCombat and not item.attrib:isSet(ITEM_ATTRIB.IN_COMBAT) then
        -- 不能在战斗中使用
        local itemInfo = InventoryMgr:getItemInfoByName(item.name)
        if itemInfo.fight_tip then
            gf:ShowSmallTips(itemInfo.fight_tip)
        else
            gf:ShowSmallTips(CHS[3000069])
        end
        return true
    end

    local itemInfo = self:getItemInfoByName(item.name)


    if useSpecialItemCallFunc[item.name] then
        return useSpecialItemCallFunc[item.name](item)
    end

    if item.name == CHS[3004071] or item.name == CHS[3004070] then
        for name,task in pairs(TaskMgr.tasks) do
            if task.task_type == CHS[3004076] or task.task_type == CHS[3004077]  then
                gf:ShowSmallTips(CHS[3004078])
                return true
            end
        end

        if not InventoryMgr:getFirstEmptyPos() then
            gf:ShowSmallTips(CHS[3004079])
            return true
        end
    elseif item.name == CHS[6000262] or item.name == CHS[6000263] or item.name == CHS[6000264] then
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        elseif GameMgr.inCombat then
            gf:ShowSmallTips(CHS[3002197])
            return
        elseif not FriendMgr:getFriends() or #FriendMgr:getFriends() == 0 then
            gf:ShowSmallTips(CHS[6000271])
            return
        else
            DlgMgr:openDlg("SubmitFDIDlg")
        end
    elseif item.name == CHS[4300001] or item.name == CHS[4100323] then
        -- 修行卷轴、修炼卷轴
        local pet = PetMgr:getFightPet()
        if not pet then
            gf:ShowSmallTips(CHS[4300002])
            return true
        end

                    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
        return true
    elseif self:getItemInfoByName(item.name).item_class == ITEM_CLASS.WUXING_FU then -- 五行符咒
        if InventoryMgr:getAmountByName(CHS[6200096], true) > 0 and InventoryMgr:getAmountByName(CHS[6200097], true) > 0 and InventoryMgr:getAmountByName(CHS[6200098], true) > 0
        and InventoryMgr:getAmountByName(CHS[6200099], true) > 0 and InventoryMgr:getAmountByName(CHS[6200100], true) > 0 then
            gf:confirm(CHS[6200095], function ()
                gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
            end)
        else
            gf:ShowSmallTips(CHS[6200101])
        end

        return true
    elseif item.name == CHS[4300132] or item.name == CHS[5410008] then
        local welfareData = GiftMgr:getWelfareData()
        if not welfareData or not welfareData["lottery"] then
            return false
        end

        local curTime = gf:getServerTime()
        if self:getItemInfoByName(item.name).apply  then
            if welfareData["lottery"]["singles_day_2016"] and welfareData["lottery"]["singles_day_2016"].endTime > curTime and item.name == CHS[4300132] or
                (welfareData["lottery"]["winter_day_2017"] and welfareData["lottery"]["winter_day_2017"].endTime > curTime and item.name == CHS[5410008]) then
            GiftMgr:openGiftDlg(self:getItemInfoByName(item.name).apply)
            return true
        end
        end


    elseif item.name == CHS[7000044] or item.name == CHS[7000045] then
        -- 经验心得/道武心得
        DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
        DlgMgr:sendMsg("SubmitXinDeDlg", "setUseItemPos", item.pos)
        return true
    elseif item.name == CHS[2000188] or item.name == CHS[2000189] or item.name == CHS[2000190] then
        local isTestDist = DistMgr:curIsTestDist()
        if not isTestDist then
            OnlineMallMgr.isUseGold = true
        end
        OnlineMallMgr:openOnlineMall("OnlineMallDlg")
        gf:ShowSmallTips(CHS[2100001])
        return true
    elseif CHS[2100020] == item.name or CHS[2100023] == item.name or CHS[2100026] == item.name then
        if not PetMgr:haveMountPet() then
            gf:ShowSmallTips(CHS[2100035])
            return true
        end

        DlgMgr:openDlg("PetHorseDlg")
        gf:ShowSmallTips(CHS[2100036])
        return true
    elseif item.name == CHS[4100421] or item.name == CHS[4100422] or item.name == CHS[4100423] or item.name == CHS[4100424] then
        -- 宝石使用提示语又特殊，纠结半天，ItemInfo.lua为这4个宝石再增加提示语字段，还是这边特殊处理好了
        gf:ShowSmallTips(CHS[4100426])
        return true
    elseif item.name == CHS[4200337] then
        -- 处于禁闭状态
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return true
        end

        -- 若在战斗中直接返回
        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return true
        end

        if Me:queryBasicInt("level") < 60 then
            gf:ShowSmallTips(CHS[4200338])
            return true
        end

        if Me:isRedName() then
            gf:ShowSmallTips(CHS[4200339])
            return true
        end

        if not TaskMgr.baxian_left_times or TaskMgr.baxian_left_times <= 0 then
            gf:ShowSmallTips(CHS[4200340])
            return true
        end

        if TaskMgr:getBaxianTask() then
            gf:ShowSmallTips(CHS[4200341])
            return true
        end

        DlgMgr:closeDlg("ItemInfoDlg")
        DlgMgr:closeDlg("BagDlg")
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4200342]))
        return true
    elseif item.name == CHS[4200378] then
        -- 九曲玲珑笔,正常情况下，使用该道具不会走到这，容错
        local dlg = DlgMgr:openDlg("ShapePenDlg", nil, true)
        dlg:setItem(item)

        local itemInfoDlg = DlgMgr:getDlgByName("ItemInfoDlg")
        if itemInfoDlg then
            local rect = self:getBoundingBoxInWorldSpace(self.root)
            dlg:setPositionByRect(rect)
        end
    elseif itemInfo and itemInfo.item_class == ITEM_CLASS.HOME_PLANT_SEED then
        -- 居所种植道具
        local homeId = Me:queryBasic("house/id")
        if homeId ~= "" then
            local destStr = "#Z" .. CHS[7002319] .. "-" .. CHS[7002330] .. "|H=me|Dlg=HomePlantDlg#Z"
            AutoWalkMgr:beginAutoWalk(gf:findDest(destStr))
            DlgMgr:closeDlg("ItemInfoDlg")
            DlgMgr:closeDlg("BagDlg")
        else
            gf:ShowSmallTips(CHS[5400153])
        end

        return true
    elseif itemInfo and itemInfo.item_class == ITEM_CLASS.HOME_LUBAN_MATERIAL then
        -- 居所鲁班原材料
        HomeMgr:useHomeMaterial(item, CHS[5400129], CHS[7100000], CHS[7100001], "FurnitureMakeDlg", CHS[7100260], CHS[7100261])
        return true
    elseif itemInfo and itemInfo.item_class == ITEM_CLASS.HOME_COOK_MATERIAL then
        -- 居所烹饪原材料
        HomeMgr:useHomeMaterial(item, CHS[5400130], CHS[2000386], CHS[2000387], "HomeCookingDlg", CHS[7100263], CHS[7100262])
        return true
    elseif item.item_type == ITEM_TYPE.CUSTOM then
        if itemInfo and itemInfo.gender and itemInfo.gender ~= Me:queryBasicInt("gender") then
            local tips = string.format(CHS[5420312], item.alias ~= "" and item.alias or item.name) .. "\n"
            if itemInfo.item_class == ITEM_CLASS.WEDDING_CLOTHES then
                gf:confirmEx(tips .. CHS[5420313], CHS[5420323], function()
                    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
                end, CHS[5420324], function()
                    DlgMgr:closeDlg("BagDlg")
                    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4100661]))
                end)
            elseif itemInfo.item_class == ITEM_CLASS.FASHION then
                gf:confirmEx(tips .. CHS[5420314], CHS[5420323], function()
                    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
                end, CHS[5420324], function()
                    DlgMgr:closeDlg("BagDlg")
                    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4100663]))
                end)
    else
                gf:confirm(tips .. CHS[5420315], function()
                gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
            end)
            end
        else
            gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
        end

        return true
    else
        if self:getItemInfoByName(item.name).apply then
            DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
            return true
        end
    end
end

-- 是否是第一次使用某个物品
function InventoryMgr:isFirstUseItem(name)
    local isUsed = cc.UserDefault:getInstance():getIntegerForKey(name .. gf:getShowId(Me:queryBasic("gid")), 0)

    if isUsed == 0 then
        cc.UserDefault:getInstance():setIntegerForKey(name .. gf:getShowId(Me:queryBasic("gid")), 1)
        return true
    end

    return false
end

-- 使用光效道具
function InventoryMgr:useToEffect(item)
    if not item then return true end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return true
    elseif GameMgr.inCombat and not item.attrib:isSet(ITEM_ATTRIB.IN_COMBAT) then
        -- 不能在战斗中使用
        local itemInfo = InventoryMgr:getItemInfoByName(item.name)
        if itemInfo.fight_tip then
            gf:ShowSmallTips(itemInfo.fight_tip)
        else
            gf:ShowSmallTips(CHS[3000069])
        end
        return true
    end
end

-- 是否是今日第一次使用急急如律令
function InventoryMgr:isTodayFirstUseJJRLL()
    if not self.isUsed then
        self.isUsed = true
        local lastTime = cc.UserDefault:getInstance():getIntegerForKey("isTodayFristUseJJRLL" .. gf:getShowId(Me:queryBasic("gid")))
        local serTime = gf:getServerTime()
        cc.UserDefault:getInstance():setIntegerForKey("isTodayFristUseJJRLL" .. gf:getShowId(Me:queryBasic("gid")), serTime)
        if tonumber(gf:getServerDate("%d", lastTime - 5 * 60 * 60))  == tonumber(gf:getServerDate("%d", serTime - 5 * 60 * 60)) then
            return false
        else
            return true
        end
    end

    return false
end

-- 付费道具
function InventoryMgr:useToCharge(item)
    if item.name == CHS[3004080] then
        DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
        DlgMgr:sendMsg("EquipmentChildDlg", "setEquipmentSelected", EQUIP.WEAPON)
        return true
    elseif item.name == CHS[3004081] then
        DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
        DlgMgr:sendMsg("EquipmentChildDlg", "setEquipmentSelected", EQUIP.HELMET)
        return true
    elseif item.name == CHS[7000043] then
        -- 无量心经
        DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
        DlgMgr:sendMsg("WulxjApplyDlg", "setUseItemPos", item.pos)
        return true
    elseif CHS[2000095] == item.name then
        -- 改头换面卡
        if GameMgr:isShiDaoServer() or MapMgr:isInShiDao() then
            gf:ShowSmallTips(CHS[5420200])
        else
            DlgMgr:openDlg("UserRenameDlg")
        end

        return true
    elseif FEED_JINGGUAI_ITEM[item.name] then -- 驯化精怪
        gf:confirm(CHS[6000516], function ()
            local dest = gf:findDest(CHS[6000517])
            DlgMgr:closeDlg("BagDlg")
            DlgMgr:closeDlg("FastUseItemDlg")
            AutoWalkMgr:beginAutoWalk(dest)
        end, nil)

        return true
    elseif CHS[2000128] == item.name then  -- 聚灵石
        if not PetMgr:haveMountPet() then
            gf:ShowSmallTips(CHS[2000153])
        else
            DlgMgr:openDlg("PetHorseDlg")
            gf:ShowSmallTips(CHS[2000154])
        end

        return true
    elseif CHS[4100884] == item.name then  -- 仙魔散
        if Me:queryInt("upgrade/level") < 120 then
            local babyStr = CHS[4100560]
            if Me:getChildType() == 2 then babyStr = CHS[4100561] end
            gf:ShowSmallTips(string.format(CHS[4100878], babyStr))
            return true
        end

        -- 任务是否完成
        if not Me:isFlyToXianMo() then
        gf:ShowSmallTips(CHS[4100879])
            return true
        end

        -- 是否未分配任何仙魔点
        if Me:isNoAllotmentXianMo() then
        gf:ShowSmallTips(CHS[4100885])
            return true
        end

        -- 满足条件不能反悔true，后续还有判断，安全锁等等 by songcw
    else
        if self:getItemInfoByName(item.name).apply then
            DlgMgr:openDlg(self:getItemInfoByName(item.name).apply)
            return true
        end
    end
end

-- 尝试喂养宠物
function InventoryMgr:tryToFeedPet(pos)
    local item = self.inventory[pos]
    if not item then
        return
    end
    if not self:canUseItem(pos, InventoryMgr.USE_ITEM_OBJ.PET) then
        -- 不能对宠物使用
        return
    end


    if CHS[6000522] == item.name  then -- 风灵丸
        if PetMgr:haveYuling() then
            DlgMgr:openDlg("PetHorseDlg")
            gf:ShowSmallTips(CHS[6000556])
        else
            gf:ShowSmallTips(CHS[6000555])
        end

        return
    end

    if not PetMgr:havePet() then
        -- "%s只可对宠物使用，你当前未携带宠物。"
        gf:ShowSmallTips(string.format(CHS[2000064], item.name))
        return
    end

    if item['item_type'] == ITEM_TYPE.GODBOOK then
        -- 天书散卷
        if not PetMgr:haveNotWildPet() then
            -- 只有野生宠物
            gf:ShowSmallTips(CHS[3000061]) -- "你当前携带的野生宠物无法领悟高深的天书技能。"
            return
        end

        -- 显示宠物属性界面中的天书技能信息
        local dlg = DlgMgr:openDlg("PetSkillDlg")
        local petList = DlgMgr:openDlg('PetListChildDlg')
        petList:initPetList('notWildFirst')
        dlg.curPanelName = "BookPanel"
        dlg:showSkill(dlg.curPanelName)
        gf:ShowSmallTips(CHS[3000062])     -- "请点击天书技能图标学习天书技能或补充灵气。"
        return
    end

    if PET_RAW_SKILL_BOOKS[item.name] then
        -- 天技秘笈
        local skillName = PET_RAW_SKILL_BOOKS[item.name]

        local wildPetCanLearn = PetMgr:haveWildPetCanLearnRawSkill(skillName)
        local notWildPetCanLearn = PetMgr:haveNotWildPetCanLearnRawSkill(skillName)
        if not wildPetCanLearn and not notWildPetCanLearn then
            -- 没有宠物可学习该技能
            gf:ShowSmallTips(string.format(CHS[3000086], skillName))
            return
        end

        -- 显示宠物属性界面中的技能信息
        local dlg = DlgMgr:openDlg("PetSkillDlg")
        local petList = DlgMgr:openDlg('PetListChildDlg')
        petList:initPetList('tianji', skillName)
        dlg.curPanelName = "BornPanel"
        dlg:showSkill(dlg.curPanelName)

        gf:ShowSmallTips(string.format(CHS[3000088], skillName))
        return
    end

    if item.name == CHS[3000093] or item.name == CHS[3000095] or item.name == CHS[3004454] or
        item.name == CHS[3000096] or item.name == CHS[3000097]  or item.name == CHS[3000098] then
        -- 妖石

        if not PetMgr:haveNotWildPet() then
            -- 只有野生宠物
            gf:ShowSmallTips(CHS[3000091])
            return
        end

        -- 显示宠物妖石界面
        local dlg = DlgMgr:openDlg('PetAttribDlg')
        local petList = DlgMgr:openDlg('PetListChildDlg')
        petList:initPetList('notWildFirst')
        gf:ShowSmallTips(CHS[3004082])

        -- 临时处理下
        return
    end

    if item.name == CHS[2000037] or item.name == CHS[2000038] then
        -- 神兽丹、超级神兽丹
        if not PetMgr:haveNotWildPet() then
            -- "野生宠物不可补充寿命。"
            gf:ShowSmallTips(CHS[2000065])
            return
        end

        -- 显示宠物属性界面
        local dlg = DlgMgr:openDlg('PetAttribDlg')
        local petList = DlgMgr:openDlg('PetListChildDlg')
        petList:initPetList('notWildFirst')
        gf:ShowSmallTips(CHS[3004083])
        return
    end

    if item.name == CHS[3004084] or item.name == CHS[4200404] then
        if not PetMgr:haveNotWildPet() then
            -- "野生宠物不可 使用该道具。"
            gf:ShowSmallTips(CHS[3004085])
            return
        end

        if not PetMgr:havePet() then
            gf:showSmallTips(CHS[3004086])
            return
        end

        local atrDlg = DlgMgr:openDlg('PetAttribDlg')
        DlgMgr:getDlgByName("PetListChildDlg"):initPetList('notWildFirst')
        gf:ShowSmallTips(CHS[3004087])
        DlgMgr:closeDlg("BagDlg")
        DlgMgr:closeDlg("ItemInfoDlg")
        return
    end

    if  item.name == CHS[2000049] then
        -- 超级归元露
        local retRank = PetMgr:isAllPetsInRank({Const.PET_RANK_ELITE, Const.PET_RANK_EPIC})
        if retRank then
            -- 没有野生、宝宝类型宠物
            local str = ""
            if retRank[Const.PET_RANK_ELITE] then
                -- 有变异
                str = CHS[3003813]
            end

            if retRank[Const.PET_RANK_EPIC] then
                if str == "" then
                    -- 没有变异，只有神兽
                    str = CHS[3003814]
                else
                    str = str .. "、" .. CHS[3003814]
                end
            end

            gf:ShowSmallTips(string.format(CHS[7190033], str))
            return
        end

        -- 显示宠物属性界面
        local dlg = DlgMgr:openDlg('PetAttribDlg')
        -- "请点击洗炼按钮对#Y%s#n的基础成长进行洗炼。"
        gf:ShowSmallTips(CHS[3004090])
        return
    end

    if item.name == CHS[4100994] then
        local retRank = PetMgr:isAllPetsInRank({Const.PET_RANK_WILD})
        if retRank then
            -- 没有宝宝

            gf:ShowSmallTips(CHS[4100992])
            return
        end

        DlgMgr:openDlg(ItemInfo[item.name].apply)
        gf:ShowSmallTips(CHS[4101000])
        return
    end

    if item.name == CHS[3004091] then
        local retRank = PetMgr:isAllPetsInRank({Const.PET_RANK_WILD, Const.PET_RANK_ELITE, Const.PET_RANK_EPIC})
        if retRank then
            -- 没有宝宝
            local str = ""
            if retRank[Const.PET_RANK_WILD] then
                -- 有野生
                str = CHS[3003810]
            end

            if retRank[Const.PET_RANK_ELITE] then
                if str == "" then
                    -- 没有有野生，有变异
                    str = CHS[3003813]
                else
                    str = str .. "、" .. CHS[3003813]
                end
            end

            if retRank[Const.PET_RANK_EPIC] then
                if str == "" then
                    -- 没有野生，变异，有神兽
                    str = CHS[3003814]
                else
                    str = str .. "、" .. CHS[3003814]
                end
            end

            gf:ShowSmallTips(string.format(CHS[7190032], str))
            return
        end

        DlgMgr:openDlg(ItemInfo[item.name].apply)
        gf:ShowSmallTips(CHS[3004095])
        return
    end

    if item.name == CHS[4000383] then
        -- 点化丹
        if not PetMgr:haveNotWildPet() then
            -- "野生不能进行点化。"
            gf:ShowSmallTips(CHS[4000384])
            return
        end

        -- 显示宠物属性界面
        local dlg = DlgMgr:openDlg('PetAttribDlg')
        local petList = DlgMgr:openDlg('PetListChildDlg')
        petList:initPetList('notWildFirst')
        gf:ShowSmallTips(CHS[4000396])
        return
    end

    if item.name == CHS[7000210] then -- 宠物顿悟丹
        if not PetMgr:havePet() then
            gf:showSmallTips(CHS[7000233])
            return
        end

        if PetMgr:haveOnlyWildPet() then
            gf:ShowSmallTips(CHS[7000234])
            return
        end

        -- 显示宠物 技能界面，并打开顿悟技能
        local dlg = DlgMgr:openDlg("PetSkillDlg")
        local petList = DlgMgr:openDlg('PetListChildDlg')
        petList:initPetList('notWildFirst')
        dlg.curPanelName = "DunWuPanel"
        dlg:showSkill(dlg.curPanelName)
        gf:ShowSmallTips(CHS[7000235])
        return
    end
end

-- 尝试喂养守护
function InventoryMgr:tryToFeedGuard(pos)
    local item = self.inventory[pos]
    if not item then
        return
    end

    if not self:canUseItem(pos, self.USE_ITEM_OBJ.GUARD) then
        return
    end

    -- 如果有守护存在，才进行一下的动作
    if GuardMgr:haveGuard() then
        -- 元气丹
        if CHS[5000048] == item.name then
            local Dlg = DlgMgr:openDlg("GuardAttribDlg")
            gf:ShowSmallTips(CHS[6000010])
            DlgMgr:closeDlg("BagDlg")
            return
        end

        -- 成长丹
        if CHS[6000007] == item.name then
            local Dlg = DlgMgr:openDlg("GuardDevelopDlg")
            gf:ShowSmallTips(CHS[6000010])  -- "请点击培养按钮对守护属性进行培养。"
            DlgMgr:closeDlg("BagDlg")
            return
        end
    else
        gf:ShowSmallTips(string.format(CHS[5000051], item.name))  -- 只可对守护使用，你当前未携带守护。
    end

end

-- 整理包裹和行囊中的道具
function InventoryMgr:arrangeBag()
    if self.isArranging then
        -- 正在整理中
        return
    end

    -- 取出可合并物品
    local toMergeItems = {}
    local mergeNum = 0
    local toArrangeItems = {}



    for pos, item in pairs(self.inventory) do
        local amount = item.amount
        if pos >= BAG_START and pos <= BAG_END and amount > 0 then
            local data = {pos = pos, item = item}

            -- 设置道具的比较层次
            self:setItemLayer(data);

            -- 对物品进行分类
            if ITEM_COMBINED.ITEM_COMBINED_NO ~= item.combined and amount < getItemDoubleMax(item) then
                -- 可合并
                table.insert(toMergeItems, data)
                mergeNum = mergeNum + 1
            else
                -- 不可合并道具加入临时容器
                table.insert(toArrangeItems, data)
            end
        end
    end

    local mergeRules = ""

    -- 将可合并物品进行预排序，然后合并
    if mergeNum > 0 then
        table.sort(toMergeItems, function(l, r)
            if l.item.icon < r.item.icon then return true end
            if l.item.icon > r.item.icon then return false end
            if l.item.name < r.item.name then return true end
            if l.item.name > r.item.name then return false end

            local lLevel = l.item.level or 0
            local rLevel = r.item.level or 0
            if lLevel < rLevel then return true end
            if lLevel > rLevel then return false end

            -- 物品当前灵气进行排序
            local lNimbus = l.item.nimbus or 0
            local rNimbus = r.item.nimbus or 0
            if lNimbus < rNimbus then return true end
            if lNimbus > rNimbus then return false end

            local lColor = l.item.color or ""
            local rColor = r.item.color or ""
            if lColor < rColor then return true end
            if lColor > rColor then return false end

            if l.item.gift > r.item.gift then return true end
            if l.item.gift < r.item.gift then return false end

            return l.item.amount < r.item.amount
        end)

        -- 物品合并
        mergeRules = self:mergeItems(toMergeItems, mergeNum, toArrangeItems)
    end

    -- 按指定的排序规则对容器进行排序
    table.sort(toArrangeItems, sortItems)

    local cardCount = StoreMgr:getChangeCardEmptyCount()
    local cardInfo = ""
    local len = #toArrangeItems
    local posInfo = ''
    local count = 0
    local pos = BAG1_START
    for i = 1, len do
        local item = toArrangeItems[i].item
        if item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD and cardCount > 0 then
            -- 变身卡道具需存入仓库
            if cardInfo ~= '' then
                cardInfo = cardInfo .. '|'
            end

            cardInfo = cardInfo .. toArrangeItems[i].pos
            cardCount = cardCount - 1
        else
        if pos ~= toArrangeItems[i].pos then
            if posInfo ~= '' then
                posInfo = posInfo .. ','
            end

            posInfo = posInfo .. toArrangeItems[i].pos .. '-' .. pos
            count = count + 1
        end

            pos = pos + 1
        end
    end

    if mergeRules == '' and posInfo == '' and cardInfo == '' then
        -- 没有变化
        return
    end

    if posInfo == '' and mergeRules ~= '' then
        -- 需要合并物品，必在起始位置
        posInfo = '' .. BAG1_START .. '-' .. BAG1_START
        count = 1
    end

    gf:CmdToServer('CMD_SORT_PACK', {
        count = count,
        range = mergeRules .. '|' .. posInfo,
        start_pos = BAG1_START,
        to_store_cards = cardInfo
    })

    self.isArranging = true
end

-- 获取道具的限制交易权重
function InventoryMgr:getItemLimitedOrder(item)
    if self:isLimitedItem(item) then
        if 2 == item.gift then
            -- 永久限制交易物品，排在非永久限制交易物品前面
            return - 1
    else
            return math.abs(item.gift)
    end
    else
        -- 非限制交易物品返回最大值，排序排在最后
        return 0xFFFFFFFF
    end
end

-- 获得道具的限时权重
function InventoryMgr:getItemTimeLimitedOrder(item)
    if InventoryMgr:isTimeLimitedItem(item) then
        return item.deadline
    else
        -- 非限时物品返回最大值，排序排在最后
        return 0xFFFFFFFF
    end
end

-- 设置道具的比较层次
function InventoryMgr:setItemLayer(data)
    if not data then return end

    local itemType = data.item.item_type
    if CHS[2100149] == data.item.name then
        -- 纪念册
        data.layer = 0
    elseif ITEM_TYPE.DISH == itemType then
        -- 菜肴
        data.layer = 1
    elseif ITEM_TYPE.MEDICINE == itemType and not gf:findStrByByte(data.item.name, CHS[4200154]) then
        -- 非玲珑类药品
        data.layer = 2
    elseif ITEM_TYPE.MEDICINE == itemType and gf:findStrByByte(data.item.name, CHS[4200154]) then
        -- 玲珑类药品，按“袖珍血/法玲珑”，“血/法玲珑”，“中级血/法玲珑”，“高级血/法玲珑”排序
        if gf:findStrByByte(data.item.name, CHS[3004112]) then     -- 袖珍血法玲珑
            data.layer = 3
        elseif gf:findStrByByte(data.item.name, CHS[4000186]) then -- 中级血法玲珑
            data.layer = 4
        elseif gf:findStrByByte(data.item.name, CHS[4000187]) then -- 高级血法玲珑
            data.layer = 5
        else                                                       -- 血法玲珑
            data.layer = 6
        end
    elseif ITEM_TYPE.SERVICE_ITEM == itemType or ITEM_TYPE.CHARGE_ITEM == itemType then
        -- 付费道具
        data.layer = 7
    elseif ITEM_TYPE.EQUIPMENT == itemType then
        -- 已鉴定装备的unidentified为0，未鉴定装备的unidentified为1，二者偏差为10
        local offset = data.item.unidentified * 10
        -- 按照装备->未鉴定 装备->首饰的顺序排序
        -- 装备，包括武器(扇、锤、剑、枪、爪)、帽子(男帽、女帽)、衣服(男衣、女衣)、鞋子(男女通用)
        local equipType = ItemInfo[data.item.name].equipType
        if EQUIP.WEAPON == data.item.equip_type then   -- 武器
            if equipType == CHS[3003962] then     -- 扇
                data.layer = 8 + offset
            elseif equipType == CHS[3003963] then -- 锤
                data.layer = 9 + offset
            elseif equipType == CHS[3003964] then -- 剑
                data.layer = 10 + offset
            elseif equipType == CHS[3003965] then -- 枪
                data.layer = 11 + offset
            elseif equipType == CHS[3003966] then -- 爪
                data.layer = 12 + offset
            end
        elseif EQUIP.HELMET == data.item.equip_type then -- 帽子
            if equipType == CHS[3003967] then      -- 男帽
                data.layer = 13 + offset
            elseif equipType == CHS[3003968] then  -- 女帽
                data.layer = 14 + offset
            end
        elseif EQUIP.ARMOR == data.item.equip_type then  -- 衣服
            if equipType == CHS[3003969] then      -- 男衣
                data.layer = 15 + offset
            elseif equipType == CHS[3003970] then  -- 女衣
                data.layer = 16 + offset
            end
        elseif EQUIP.BOOT == data.item.equip_type then   -- 鞋子（男女通用）
            data.layer = 17 + offset
        elseif EQUIP.BALDRIC == data.item.equip_type then   -- 玉佩
            data.layer = 29
        elseif EQUIP.NECKLACE == data.item.equip_type then   -- 项链
            data.layer = 30
        elseif EQUIP_TYPE.WRIST == data.item.equip_type then   -- 手镯
            data.layer = 31
        else
            data.layer = 34  --若是其他类型的装备，则属于其他物品
        end
    elseif ITEM_TYPE.ARTIFACT == itemType then  -- 法宝
        data.layer = 27
    elseif ITEM_TYPE.CHANGE_LOOK_CARD == itemType then -- 变身卡
        data.layer = 32
    elseif ITEM_TYPE.TOY == itemType then -- 玩具
        -- 先按照icon
        data.layer = 33 + tonumber(data.item.icon) * 0.00001 

        -- 同icon按照品质
        if data.item.color == "蓝色" then
            data.layer = data.layer + 0.00000001
        elseif data.item.color == "紫色" then
            data.layer = data.layer + 0.00000002
        elseif data.item.color == "金色" then
            data.layer = data.layer + 0.00000003
        end
    else
        -- 其他
        data.layer = 34
    end

    -- 急急如律令、超级藏宝图、超级黑水晶，需要设置layer = 6
    if gf:findStrByByte(data.item.name, CHS[3001146]) or gf:findStrByByte(data.item.name, CHS[3001145]) or gf:findStrByByte(data.item.name, CHS[3001225]) then
        data.layer = 7
    end
end

-- 判断这个道具是否可合并
function InventoryMgr:isSameItemByGift(item1, item2)
    local gift1, gift2

    gift1 = item1.gift or 0
    if (gift1 < 0 and gift1 + gf:getServerTime() >= 0) then
        -- 限制交易时间已到期
        gift1 = 0;
    end

    gift2 = item2.gift or 0
    if (gift2 < 0 and gift2 + gf:getServerTime() >= 0) then
        -- 限制交易时间已到期
        gift2 = 0;
    end

    local deadline1, deadline2

    deadline1 = item1.deadline or 0
    deadline2 = item2.deadline or 0

    if deadline1 ~= 0 or deadline2 ~= 0 then
        if deadline1 ~= 0 and deadline2 ~= 0 then  -- 两个道具都为限时道具
            return deadline1 == deadline2  -- 根据限时时间是否相等判断
        else  -- 其中一个道具为限时道具
            return false
        end
    end

    return gift1 == gift2;
end

-- 合并可叠加物品，并将合并后的物品加入 toArrangeItems 中
function InventoryMgr:mergeItems(toMergeItems, mergeNum, toArrangeItems)
    if mergeNum == 1 then
        table.insert(toArrangeItems, toMergeItems[1])
        return ''
    end

    local idxBegin = 1
    local last = toMergeItems[1].item
    local total = last.amount
    local mergeRules = ''
    for i = 2, mergeNum do
        local cur = toMergeItems[i].item
        if InventoryMgr:isSameItemToMerge(last, cur) then
            -- 与前一个物品相同
            total = total + cur.amount
        else
            -- 与前一个物品不同
            -- 处理相同的物品
            mergeRules = self:doMerge(toMergeItems, idxBegin, i - 1, total, toArrangeItems, mergeRules)

            idxBegin = i
            last = cur
            total = cur.amount
        end
    end

    -- 处理相同的物品
    return self:doMerge(toMergeItems, idxBegin, mergeNum, total, toArrangeItems, mergeRules)
end

function InventoryMgr:isSameItemToMerge(left, right)
    -- 2017寒假作业  作业副本道具 只有real_desc不同
    if left.name == right.name and left.name == CHS[7100102] and left.real_desc ~= right.real_desc then
        return false
    end

    -- 两个装备的鉴定状态不同，或者都为已鉴定装备，则不可合并
    if left.item_type == ITEM_TYPE.EQUIPMENT and right.item_type == ITEM_TYPE.EQUIPMENT
        and EquipmentMgr:isExistUnidentifiedEquip(left.equip_type)
        and EquipmentMgr:isExistUnidentifiedEquip(right.equip_type)
        and (left.unidentified ~= right.unidentified or left.unidentified == 0) then
        return false
    end

    if left.name == right.name and left.level == right.level and left.color == right.color and left.nimbus == right.nimbus
        and InventoryMgr:isSameItemByGift(left, right) then
        return true
    end

    return false
end

-- 合并相同的物品
function InventoryMgr:doMerge(toMergeItems, idxBegin, idxEnd, total, toArrangeItems, mergeRules)
    if idxBegin == idxEnd then
        -- 只有一个物品
        table.insert(toArrangeItems, toMergeItems[idxBegin])
        return mergeRules
    end

    -- 有多个物品
    local rule = tostring(toMergeItems[idxBegin].pos)

    for j = idxBegin, idxEnd do
        if j > idxBegin then rule = rule .. '-' .. toMergeItems[j].pos end

        if total > 0 then
            -- 该位置还有物品，加入 tmpItems 中
            table.insert(toArrangeItems, toMergeItems[j])
            total = total - getItemDoubleMax(toMergeItems[j].item)
        end
    end

    if mergeRules ~= '' then
        mergeRules = mergeRules .. ','
    end

    return mergeRules .. rule
end

----- 根据名称获取该道具数量
function InventoryMgr:getAmountByNameLevel(name, value)
    local inventory = self.inventory
    local count = 0
    for _, v in pairs(inventory) do

        if v.name == name and v.level == value then
            count = count + v.amount
        end
    end
    return count
end

-- 获取满足条件的袖珍
function InventoryMgr:getMiniBylevel(name, level, isBind)
    level = math.floor(level / 10) * 10
    local inventory = self.inventory
    local count = 0
    if isBind then
        for _, v in pairs(inventory) do
            if v.name == name and (level == math.floor(v.level / 10) * 10 or level == 0) then
                count = count + v.amount
            end
        end
        return count
    else
        for _, v in pairs(inventory) do
            if v.name == name and v.gift ~= 2 and (level == math.floor(v.level / 10) * 10 or level == 0) then
                count = count + v.amount
            end
        end
        return count
    end
end

-- 根据名称绑定状态
function InventoryMgr:getAmountByNameOnlyBind(name, level)
    if level then
        local inventory = self.inventory
        local count = 0
        for _, v in pairs(inventory) do
            if v.name == name and self:isLimitedItem(v) and level == math.floor(v.level / 10) * 10 then
                count = count + v.amount
            end
        end
        return count
    end

    local inventory = self.inventory
    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name and self:isLimitedItem(v) then
            count = count + v.amount
        end
    end
    return count
end

-- 根据名称和绑定状态获取道具  isBind == true 则获取绑定和非绑定的盒
function InventoryMgr:getAmountByNameBind(name, isBind, onlyFormBag)
    if isBind then
        return self:getAmountByName(name, onlyFormBag)
    else
        return self:getUnlimtedAmountByName(name, onlyFormBag)
    end
end

-- 获取背包所有物品
function InventoryMgr:getAllInventory()
    return self.inventory
end

function InventoryMgr:getAllBagItems()
    local inventory = self.inventory
    local allBagItem = {}
    for _, v in pairs(inventory) do
        if v.pos >= BAG_START and v.pos <= BAG_END then
            table.insert(allBagItem, v)
        end
    end

    table.sort(allBagItem, function(l, r)
        if l.pos < r.pos then return true end
        if l.pos > r.pos then return false end
    end)

    return allBagItem
end

function InventoryMgr:getAllBagUnidentifiedEquip()
    local inventory = self.inventory
    local equipWithLayer = {}
    local allUnidentifiedEquip = {}

    for _, v in pairs(inventory) do
        if v.pos >= BAG_START and v.pos <= BAG_END and v.item_type == ITEM_TYPE.EQUIPMENT and  v.unidentified == 1 then
            local data = {item = v}
            InventoryMgr:setItemLayer(data)
            table.insert(equipWithLayer, data)
        end
    end

    table.sort(equipWithLayer, function(l, r)
        if l.item.req_level > r.item.req_level then return true end
        if l.item.req_level < r.item.req_level then return false end
        if l.item.equip_type < r.item.equip_type then return true end
        if l.item.equip_type > r.item.equip_type then return false end
        if l.layer < r.layer then return true end
        if l.layer > r.layer then return false end
        -- 限时道具排序
        if InventoryMgr:getItemTimeLimitedOrder(l.item) < InventoryMgr:getItemTimeLimitedOrder(r.item) then return true end
        if InventoryMgr:getItemTimeLimitedOrder(l.item) > InventoryMgr:getItemTimeLimitedOrder(r.item) then return false end

        -- 限制道具排序
        if InventoryMgr:getItemLimitedOrder(l.item) > InventoryMgr:getItemLimitedOrder(r.item) then return true end
        if InventoryMgr:getItemLimitedOrder(l.item) < InventoryMgr:getItemLimitedOrder(r.item) then return false end

        -- 数量
        if l.item.amount > r.item.amount then return true end
        if l.item.amount < r.item.amount then return false end
    end)

    for i = 1, #equipWithLayer do
        table.insert(allUnidentifiedEquip, equipWithLayer[i].item)
    end

    return allUnidentifiedEquip
end

-- 获取非限制道具
function InventoryMgr:getUnlimtedAmountByName(name, onlyFormBag)
    local inventory = self.inventory

    if onlyFormBag then
        inventory = self:getAllBagItems()
    end

    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name and not self:isLimitedItem(v) then
            count = count + v.amount
        end
    end
    return count
end

-- 获取限制交易的数量
function InventoryMgr:getLimtedAmoutByName(name)
    local inventory = self.inventory
    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name and self:isLimitedItem(v) and v.pos > EQUIP.BOOT then
            count = count + v.amount
        end
    end
    return count
end

-- 根据名称获取该道具数量
function InventoryMgr:getAmountByName(name, onlyFormBag, color)
    local inventory = self.inventory

    if onlyFormBag then
        inventory = self:getAllBagItems()
    end

    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name and (not color or color == v.color) then
             count = count + v.amount
        end
    end

    return count
end

-- 永久限制交易物品个数
function InventoryMgr:getAmountByNameForeverBind(name, onlyFormBag)
    local inventory

    if onlyFormBag then
        inventory = self:getAllBagItems()
    else
        inventory = self.inventory
    end

    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name and v.gift == 2 then
            count = count + v.amount
        end
    end
    return count
end

function InventoryMgr:getAmountByNameForeverBindLevel(name, level)
    level = math.floor(level / 10) * 10
    local inventory = self.inventory
    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name and v.gift == 2 and v.level == level then
            count = count + v.amount
        end
    end
    return count
end

-- 获取物品个数，isForeverBind == true则获取所有物品个数，否则获取去除永久限制交易物品的数量
function InventoryMgr:getAmountByNameIsForeverBind(name, isForeverBind)
    local amount = 0
    if isForeverBind then
        amount = InventoryMgr:getAmountByNameBind(name, isForeverBind)
    else
        amount = InventoryMgr:getAmountByNameNotForeverBind(name)
    end
    return amount
end

-- 排除身上位置
function InventoryMgr:getAmountByNameIsForeverBindBag(name, isForeverBind)
    local inventory = self:getAllBagItems()
    local count = 0
    for _, v in pairs(inventory) do
        if isForeverBind then
            if v.name == name then
                count = count + v.amount
            end
        else
            if v.name == name and not InventoryMgr:isLimitedItemForever(v) then
                count = count + v.amount
    end
        end
    end
    return count
end

function InventoryMgr:getAmountByNameIsForeverBindLevel(name, isForeverBind, level)
    local inventory = self.inventory
    local count = 0
    local bindCount = 0
    for _, v in pairs(inventory) do
        if isForeverBind then
            if v.name == name and level == v.level then
                count = count + v.amount

                if InventoryMgr:isLimitedItemForever(v) then
                    bindCount = bindCount + 1
            end
            end
        else
            if v.name == name and level == v.level and not InventoryMgr:isLimitedItemForever(v) then
                count = count + v.amount
    end
        end
    end
    return count, bindCount
end

function InventoryMgr:getItemsByName(names, isOnlyForeverBind)
    if not names then return end
    if type(names) ~= "table" then
        names = {names}
    end

    local inventory = self.inventory
    local items = {}
    for i = 1, #names do
        for _, v in pairs(inventory) do
            if isOnlyForeverBind then
                if v.name == names[i] and InventoryMgr:isLimitedItemForever(v) then
                    table.insert(items, gf:deepCopy(v))
                end
            else
                if v.name == names[i] then
                    table.insert(items, gf:deepCopy(v))
                end
            end
        end
    end

    return items
end

-- 非永久限制交易物品个数
function InventoryMgr:getAmountByNameNotForeverBind(name)
    local inventory = self.inventory
    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name and v.gift ~= 2 then
            count = count + v.amount
        end
    end
    return count
end

-- 获取出售价格， 返回具体数值
function InventoryMgr:getSellPriceValue(item)
    local ret = 0
    if item and item.value then
        if item.item_type == ITEM_TYPE.FURNITURE then
            ret = HomeMgr:getFurnitureSellPrice(item.name)
        else
            ret = item.value * 0.2
            if ret >= 800000 then ret = 800000 end
        end
    end

    return ret
end

function InventoryMgr:canShowZeroSellPrice(item)
    if item.name == CHS[5410230] then
        return true
    end
end

-- 获取出售价格， 返回str。
function InventoryMgr:getSellPriceStr(item)
    local priceStr = ""
    if item.attrib and type(item.attrib) == "table" and item.attrib:isSet(ITEM_ATTRIB.CANT_SELL) == true then
        priceStr = CHS[4000320]
    elseif InventoryMgr:getItemInfoByName(item.name).not_sell == 1 then
        priceStr = CHS[4000320]
    else
        if item.value and (item.value ~= 0 or self:canShowZeroSellPrice(item)) then
            local moneyStr = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(item), false)
            priceStr = string.format(CHS[4000025], moneyStr)
        end
    end

    return priceStr
end

-- 获取可以邮寄的物品
function InventoryMgr:getCanMailItems()
    local inventory = self.inventory
    local items = {}
    for _, v in pairs(inventory) do
        if v.attrib:isSet(ITEM_ATTRIB.ITEM_CAN_MAIL) then
            table.insert(items, v)
        end
    end

    return items
end

-- 根据位置获取该道具数量
function InventoryMgr:getAmountByPos(pos)
    local inventory = self.inventory
    local count = 0
    for _, v in pairs(inventory) do
        if v.pos == pos then
            count = count + v.amount
        end
    end
    return count
end

-- 根据名称，等级获取道具数量
function InventoryMgr:getAmountByNameAndLevel(name, level)
    local inventory = self.inventory
    local count = 0
    for _, v in pairs(inventory) do
        if v.name == name then
            if level == v.level then
                count = count + v.amount
            end
        end

    end
    return count
end

-- 根据名称 等级 获取道具非限制数量
function InventoryMgr:getAmountNotLimitedByNameAndLevel(name, level)
    local inventory = self.inventory
    local count = 0

    for _, v in pairs(inventory) do

        if v.name == name and v.level ==level and not self:isLimitedItem(v) then
            count = count + v.amount
        end

    end

    return count
end

-- 根据名字等级 获取道具是否是绑定
function InventoryMgr:getBindAmountByNameAndLevel(name, level)
    local inventory = self.inventory
    local count = 0

    for _, v in pairs(inventory) do

        if v.name == name and v.level ==level and  self:isLimitedItem(v) then
            count = count + v.amount
        end

    end

    return count
end


-- 根据名字等级 获取道具是否是绑定
function InventoryMgr:getIsGiftByNameAndLevel(name, level)
    local inventory = self.inventory
    local isGift = false

    for _, v in pairs(inventory) do

        if v.name == name and v.level ==level then
            if v.gift ~= 0 then
                isGift = true
                break
            end
        end

    end

    return isGift
end

function InventoryMgr:getPriorityUseInventoryByName(name, isForeverBind)
    local item
    if isForeverBind then
        item = InventoryMgr:getFirstTimeLimitedItemByName(name)
        if not item then item = InventoryMgr:getFirstBindForeverItemByName(name) end
        if not item then item = InventoryMgr:getFirstBindNotForeverItemByName(name) end
        if not item then item = InventoryMgr:getFirstNotBindItemByName(name) end
    else
        item = InventoryMgr:getFirstBindNotForeverItemByName(name)
        if not item then item = InventoryMgr:getFirstNotBindItemByName(name) end
    end
    return item
end

-- 根据消耗顺序排列拥有的某个道具
function InventoryMgr:getItemArrayByCostOrder(name, isUseLimited)
    -- 限时道具>永久限制交易道具>非永久的限制交易道具>非限制交易道具
    local inventory = self.inventory
    local result = {}
    if isUseLimited then
        for _, v in pairs(inventory) do
            if v.name == name then
                if InventoryMgr:isTimeLimitedItem(v) and not InventoryMgr:isItemTimeout() then
                    -- 限时道具
                    v.order = 1
                elseif InventoryMgr:isLimitedItemForever(v) then
                    -- 永久限制交易道具
                    v.order = 2
                elseif InventoryMgr:isLimitedItem(v) then
                    -- 非永久的限制交易道具
                    v.order = 3
                else
                    -- 非限制交易道具
                    v.order = 4
                end

                table.insert(result, v)
            end
        end

        table.sort(result, function(l, r)
            if l.order < r.order then return true end
            if l.order > r.order then return false end
        end)
    else
        for _, v in pairs(inventory) do
            if v.name == name and not InventoryMgr:isLimitedItemForever(v) then
                if InventoryMgr:isLimitedItem(v) then
                    -- 非永久的限制交易道具
                    v.order = 1
                else
                    -- 非限制交易道具
                    v.order = 2
                end

                table.insert(result, v)
            end
        end

        table.sort(result, function(l, r)
            if l.order < r.order then return true end
            if l.order > r.order then return false end
        end)
    end

    return result
end

-- 获取该名称的第一个道具
function InventoryMgr:getFirstInventoryByName(name)
    local inventory = self.inventory
    for _, v in pairs(inventory) do
        if v.name == name then
            return v
        end
    end
    return nil
end

-- 获取第一个绑定道具
function InventoryMgr:getFirstBindItemByName(name)
    local inventory = self.inventory
    for _, v in pairs(inventory) do
        if v.name == name and InventoryMgr:isLimitedItem(v) then
            return v
        end
    end
    return nil
end

-- 获取第一个非限制道具
function InventoryMgr:getFirstNotBindItemByName(name)
    local inventory = self.inventory
    for _, v in pairs(inventory) do
        if v.name == name and not InventoryMgr:isLimitedItem(v) then
            return v
        end
    end
    return nil
end

-- 获取第一个限时道具
function InventoryMgr:getFirstTimeLimitedItemByName(name)
    local inventory = self.inventory
    for _, v in pairs(inventory) do
        if v.name == name and InventoryMgr:isTimeLimitedItem(v)
             and not InventoryMgr:isItemTimeout() then
            return v
        end
    end
    return nil
end

-- 获取第一个永久道具
function InventoryMgr:getFirstBindForeverItemByName(name)
    local inventory = self.inventory
    for _, v in pairs(inventory) do
        if v.name == name and InventoryMgr:isLimitedItemForever(v) then
            return v
        end
    end
    return nil
end

-- 获取第一个限制 and 非永久道具
function InventoryMgr:getFirstBindNotForeverItemByName(name)
    local inventory = self.inventory
    for _, v in pairs(inventory) do
        if v.name == name and not InventoryMgr:isLimitedItemForever(v) and InventoryMgr:isLimitedItem(v) then
            return v
        end
    end
    return nil
end

-- 根据道具名称截断"·"
function InventoryMgr:getParentName(name)
    if nil == name then return end
    local itemInfo = ItemInfo[name] or FurnitureInfo[name]
    if nil == itemInfo then
        local cutPos = gf:findStrByByte(name, CHS[3004096])
        if cutPos then
            local parentName = string.sub(name, 1, cutPos - 1)
            itemInfo = ItemInfo[parentName] or FurnitureInfo[parentName]
            if itemInfo then
                return parentName
            else
                return
            end
        else
            return
        end
    end
end

-- 根据道具名称获取 icon
function InventoryMgr:getIconByName(name)
    local parentName = self:getParentName(name) or name
    if nil == ItemInfo[parentName] then
        -- 可能是家具
        local furnitureInfo = FurnitureInfo[name]
        if furnitureInfo then
            return furnitureInfo.icon
        end

        return
    end

    -- 若为金钱和银元宝图标直接返回他们的名称
    if parentName == CHS[3004097] or parentName == CHS[3004098] or parentName == CHS[3004099] then
        return parentName
    end

    if ItemInfo[parentName].same_as ~= nil then
        return ItemInfo[ItemInfo[parentName].same_as].icon or 1001
    end
    return ItemInfo[parentName].icon or 1001
end

-- 根据道具名称获取 icon 对应的文件名
function InventoryMgr:getIconFileByName(name)
    return ResMgr:getItemIconPath(self:getIconByName(name))
end

-- 是否是守护类道具
function InventoryMgr:getIsGuard(name)
    if ItemInfo[name] and ItemInfo[name].isGuard then
        return true
    end
    return false
end

-- icon是否plist类型资源
function InventoryMgr:isPlist(name)
    if ItemInfo[name] and ItemInfo[name].isUsePlist then
        return true
    end
    return false
end

function InventoryMgr:getFollowPetNameByType(type)
    if type >= 0 then
        return FOLLOW_PET_BY_TYPE[type + 1] -- 配置的数组，下标从1开始
    end
end

function InventoryMgr:getDescriptByItem(item)
    local descriptStr = ""

    if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        descriptStr = InventoryMgr:getDescript(CHS[3002820])
    elseif InventoryMgr:isUpgrade(item.name)  and item.level then       -- 粉才描述
        if item.level == 3 then
            descriptStr = CHS[3002821]
    	elseif item.level > 3 then
        	descriptStr = string.format(CHS[3002822], item.level *10, item.level *10 + 9)
    	end
    else
        if item.desc and item.desc ~= "" then
            descriptStr = item.desc
        elseif item.real_desc and item.real_desc ~= "" then
            -- 部分物品描述，使用动态字段，需要服务器告知
            descriptStr = item.real_desc
        else
            descriptStr = InventoryMgr:getDescript(item.name)
        end
    end

    if ResMgr.icon.item_ruyinian == item["icon"] or ResMgr.icon.item_jixiangtian == item["icon"] then
        local follow_pet_type = item["follow_pet_type"] or 0
        if follow_pet_type >= 0 then
            descriptStr = descriptStr .. string.format(self:getFuncFromItemCfg(item.name), self:getFollowPetNameByType(follow_pet_type))
        end
    end

    if item["expired_time"] and item["expired_time"] ~= 0 then
        descriptStr = descriptStr .. gf:getServerDate(CHS[4300028], item["expired_time"])
    end

    return descriptStr
end

-- 获取描述信息
function InventoryMgr:getDescript(name)
    local isCut = self:getParentName(name)
    name = self:getParentName(name) or name
    if nil == ItemInfo[name] then
        local furnitureInfo = FurnitureInfo[name]
        if furnitureInfo then
            -- 是家具
            return furnitureInfo.descript
        end

        return
    end

    local isTestDist = DistMgr:curIsTestDist()

    if ItemInfo[name].same_as ~= nil then
        if isTestDist then
            return ItemInfo[ItemInfo[name].same_as].test_descript or ItemInfo[ItemInfo[name].same_as].descript or ""
        else
            return ItemInfo[ItemInfo[name].same_as].descript or ""
        end
    end

    local desc = ""
    -- 如果测试区组而且有配置test_descript，则取test_descript否则取descript
    if isTestDist then
        desc = ItemInfo[name].test_descript or ItemInfo[name].descript
    else
        desc = ItemInfo[name].descript
    end

    if isCut then
        return ItemInfo[name].attdescript or desc or ""
    end
    return desc or ""
end

-- 获取物品来源
function InventoryMgr:getRescourse(name, item)
    -- 如果有开始时间的来源
    if ItemInfo[name] and ItemInfo[name]["time_limit_res"] then
        local nowTime = tonumber(gf:getServerDate("%Y%m%d%H", gf:getServerTime()))
        if nowTime >= ItemInfo[name]["time_limit_res"].time_start then
            return ItemInfo[name]["time_limit_res"].rescourse or ""
        end
    end

    local parentName = self:getParentName(name) or name
    if nil == ItemInfo[parentName] then
        local furnitureResource = HomeMgr:getFurnitureResource(parentName)
        return furnitureResource
    end

    if ItemInfo[parentName].same_as ~= nil then
        return ItemInfo[ItemInfo[parentName].same_as].rescourse or ""
    end

    if item then
        local rescourse = clone(ItemInfo[parentName].rescourse)

        -- 对未鉴定装备作特殊处理
        if item and item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
            for i = 1, #rescourse do
                if string.match(rescourse[i], CHS[3000792]) and string.match(rescourse[i], CHS[3001022]) and not string.match(rescourse[i], CHS[3001166]) then
                    rescourse[i] = string.gsub(rescourse[i], CHS[3001022], CHS[3001166])
                end
            end
        end

        -- 对妖石作特殊处理，各等级来源信息如下
        --  -----------------------
        -- |  等级      |     来源              |
        --  -------- --------------
        -- |   1    |     杂货              |
        -- |  2-3   |   杂货|合成       |
        -- |   4    |     合成              |
        -- |  5-max |   合成|集市       |
        --  -----------------------
        if item.name == CHS[3000093]
            or item.name == CHS[3004454]
              or item.name == CHS[3000095]
              or item.name == CHS[3000096]
              or item.name == CHS[3000097]
              or item.name == CHS[3000098] then
            local itemLevel = item.level or 1
            local resKeyList = {}
            if itemLevel == 1 then
                resKeyList = {CHS[7002021]}
            elseif itemLevel >= 2 and itemLevel <= 3 then
                resKeyList = {CHS[7002021], CHS[7002020]}
            elseif itemLevel == 4 then
                resKeyList = {CHS[7002020]}
            elseif itemLevel >= 5 then
                resKeyList = {CHS[7002020], CHS[3000792]}
            end

            local res = {}
            for i = 1, #rescourse do
                for j = 1, #resKeyList do
                    if string.match(rescourse[i], resKeyList[j]) then
                        table.insert(res, rescourse[i])
                    end
                end
            end

            for i = 1, #res do
                if string.match(res[i], CHS[3000792]) and not string.match(res[i], item.name .. ":") then
                    -- “集市”中添加等级信息
                    res[i] = string.gsub(res[i], item.name, item.name .. ":" .. tostring(itemLevel))
                elseif string.match(res[i], CHS[7002020]) and not string.match(res[i], item.name .. ":") then
                    -- “合成”中添加等级信息
                    res[i] = string.gsub(res[i], item.name, item.name .. ":" .. tostring(itemLevel))
                end
            end
            return res
        end

        -- 对经验心得/道武心得作特殊处理
        if (item.name == CHS[7000044] or item.name == CHS[7000045]) and item.level then
            for i = 1, #rescourse do
                if string.match(rescourse[i], CHS[3000792]) and not string.match(rescourse[i], item.name .. ":") then
                    rescourse[i] = string.sub(rescourse[i], 1, string.len(rescourse[i]) - 2)
                    rescourse[i] = rescourse[i] .. ":" .. MarketMgr:getXindeLVByLevel(item.level, item.name) .. "#@"
                end
            end
        end

        return rescourse
    end

    return ItemInfo[parentName].rescourse or ""
end

-- 获取带属性的超级黑水晶来源
function InventoryMgr:getRescourseByHasAttBlackCrystal(item)
    local name = item.name
    local parentName = self:getParentName(name) or name
    if nil == ItemInfo[parentName] then return end
    if ItemInfo[parentName].same_as ~= nil then
        return ItemInfo[ItemInfo[parentName].same_as].rescourse or ""
    end

    -- 对带属性超级黑水晶的集市逛摊作特殊处理，需要链接到对应部位对应等级
    if not ItemInfo[parentName].hasAttrRscourse then
        return ""
    end

    local rescourse = clone(ItemInfo[parentName].hasAttrRscourse)
    for i = 1, #rescourse do
        if string.match(rescourse[i], CHS[3000792]) and not string.match(rescourse[i], CHS[3001096] .. ":") then
            if item and item.upgrade_type and item.level then
                local type = EquipmentMgr:getEquipChs(item.upgrade_type)
                local level = item.level
                rescourse[i] = string.gsub(rescourse[i], CHS[3001096],
                    CHS[3001096] .. ":" .. type .. ":" .. level)
           end
        end
    end

    return rescourse
end

-- 获取物品指定字段信息
function InventoryMgr:getItemInfoByNameAndField(name, field)
    local parentName = self:getParentName(name) or name
    local itemInfo = self:getItemInfoByName(parentName)
    if not itemInfo then return end

    if itemInfo.same_as ~= nil then
        return self:getItemInfoByName(itemInfo.same_as)[field]
    end

    return itemInfo[field]
end

-- 获取装备名称显示颜色       绿->黄->粉->蓝->白
function InventoryMgr:getEquipmentNameColor(equip)

    local isGreen, isYellow, isPink, isBlue
    local greenTab = {}
    local yellowTab = {}
    local pinkTab = {}
    local blueTab = {}

    for _,v in pairs(EquipmentAtt[CHS[4000098]]) do
        -- 是否有绿属性
        local greenStr = string.format("%s_%d", v, Const.FIELDS_PROP4)
        if equip.extra[greenStr] ~= nil then
            table.insert(greenTab, {value = equip.extra[greenStr], field = v, dark = 0})
            isGreen = true
        end

        local greenDarkStr = string.format("%s_%d", v, Const.FIELDS_SUIT)
        if equip.extra[greenDarkStr] ~= nil then
            table.insert(greenTab, {value = equip.extra[greenDarkStr], field = v, dark = 1})
        end

        -- 是否有黄属性
        local yellowStr = string.format("%s_%d", v, Const.FIELDS_PROP3)
        if equip.extra[yellowStr] ~= nil then
            table.insert(yellowTab, {value = equip.extra[yellowStr], field = v})
            isYellow = true
        end

        -- 是否有粉属性
        local pinkStr = string.format("%s_%d", v, Const.FIELDS_EXTRA2)
        if equip.extra[pinkStr] ~= nil then
            table.insert(pinkTab, {value = equip.extra[pinkStr], field = v})
            isPink = true
        end

        -- 是否有蓝属性
        local blueStr = string.format("%s_%d", v, Const.FIELDS_EXTRA1)
        if equip.extra[blueStr] ~= nil and v ~= "phy_power" and v ~= "mag_power" then
            table.insert(blueTab, {value = equip.extra[blueStr], field = v})
            isBlue = true
        end
    end

    table.sort(greenTab, function(l, r)
        if l.dark < r.dark then return true end
        if l.dark > r.dark then return false end
    end)

    local color
    if equip.color == CHS[3004100] or equip.color == "" then
        color = COLOR3.BROWN
    elseif equip.color == CHS[3004101] then
        color = COLOR3.GREEN
    elseif equip.color == CHS[3004102] then
        color = COLOR3.BLUE
    elseif equip.color == CHS[3004103] then
        color = COLOR3.MAGENTA
    elseif equip.color == CHS[3004104] then
        color = COLOR3.YELLOW
    end

    if not color then
        if isGreen then
            color = COLOR3.GREEN
        elseif isYellow then
            color = COLOR3.YELLOW
        elseif isPink then
            color = COLOR3.MAGENTA
        elseif isBlue then
            color = COLOR3.BLUE
        else
            color = COLOR3.BROWN
        end
    end

    return color, greenTab, yellowTab, pinkTab, blueTab
end

function InventoryMgr:getItemsUseInFight()
    local items = {}

    -- 获取战斗中使用物品
    for pos, item in pairs(self.inventory) do
        if item.attrib:isSet(ITEM_ATTRIB.IN_COMBAT) then
            table.insert(items, {name = item.name, icon = InventoryMgr:getIconByName(item.name),
                num = item.amount, des = InventoryMgr:getDescript(item.name),
                useDes = InventoryMgr:getItemFunc(item), pos = pos, attrib = item.attrib})
        end
    end

    return items
end

-- 是否有战斗中使用的补血药品
function InventoryMgr:isHaveLifeItem()
    for pos, item in pairs(self.inventory) do
        if ITEM_TYPE.MEDICINE == item.item_type and item.attrib:isSet(ITEM_ATTRIB.IN_COMBAT) and item.extra.life_1 ~= nil then
            return true
        end
    end

    return false
end

-- 是否有战斗中补蓝药品
function InventoryMgr:isHaveManaItem()
    for pos, item in pairs(self.inventory) do
        if ITEM_TYPE.MEDICINE == item.item_type and item.attrib:isSet(ITEM_ATTRIB.IN_COMBAT) and item.extra.mana_1 ~= nil then
            return true
        end
    end

    return false
end

function InventoryMgr:getItemForFightUseResDlg()
    local items = {}

    -- 清明节活动物品（黑驴蹄子，桃木剑，照妖镜）, 只有在当前战斗是清明节战斗时才显示
    local battleType = FightMgr:getBattleType()
    if battleType and battleType == CHS[7002033] then
        for pos, item in pairs(self.inventory) do
            if QINGMING_ITEM[item.name] then
                table.insert(items, {name = item.name, icon = InventoryMgr:getIconByName(item.name),
                    amount = item.amount, des = InventoryMgr:getDescript(item.name), item_type = item.item_type,
                    useDes = InventoryMgr:getItemFunc(item), pos = pos, attrib = item.attrib })
        end
    end

    -- 排序一下清明节活动物品
    table.sort(items, function(l, r)
            if QINGMING_ITEM[l.name] < QINGMING_ITEM[r.name] then return true end
            if QINGMING_ITEM[l.name] > QINGMING_ITEM[r.name] then return false end
        end)
    end

    local combatMode =  FightMgr:getCombatMode()
    if COMBAT_MODE.COMBAT_MODE_DIJIE == combatMode then
        -- 可以使用妖劫咒
        for pos, item in pairs(self.inventory) do
            if CHS[2000246] == item.name then
                table.insert(items, {name = item.name, icon = InventoryMgr:getIconByName(item.name),
                    amount = item.amount, des = InventoryMgr:getDescript(item.name), item_type = item.item_type,
                    useDes = InventoryMgr:getItemFunc(item), pos = pos, attrib = item.attrib })
            end
        end
    end

    if COMBAT_MODE.COMBAT_MODE_GHOST_01 == combatMode
        or COMBAT_MODE.COMBAT_MODE_GHOST_02 == combatMode then
        -- 可以使用金光符
        for pos, item in pairs(self.inventory) do
            if CHS[5400090] == item.name then
                table.insert(items, {name = item.name, icon = InventoryMgr:getIconByName(item.name),
                    amount = item.amount, des = InventoryMgr:getDescript(item.name), item_type = item.item_type,
                    useDes = InventoryMgr:getItemFunc(item), pos = pos, attrib = item.attrib })
            end
        end
    end

    -- 药品
    local medicines = InventoryMgr:getMedicines()
    for i = 1, #medicines do
        table.insert(items, medicines[i])
    end

    -- 火眼金睛或菜肴
    for pos, item in pairs(self.inventory) do
        if item.name == CHS[3004105] or item.name == CHS[5410239] then
            table.insert(items, {name = item.name, icon = InventoryMgr:getIconByName(item.name),
                amount = item.amount, des = InventoryMgr:getDescript(item.name), item_type = item.item_type,
                useDes = InventoryMgr:getItemFunc(item), pos = pos, attrib = item.attrib })
        elseif item.item_type == ITEM_TYPE.DISH then
            table.insert(items, {name = item.name, icon = InventoryMgr:getIconByName(item.name),
                amount = item.amount, des = InventoryMgr:getDescript(item.name), item_type = item.item_type,
                useDes = InventoryMgr:getItemFunc(item), pos = pos, attrib = item.attrib, level = item.level })
        end
    end

    return items
end

-- 获取药品信息，血玲珑跟法玲珑放在前两位
-- name         药品名称
-- icon         药品图标
-- num          药品数量
-- des          药品描述
-- useDes       药品功能
-- pos          药品位置
function InventoryMgr:getMedicines()
    local medicines = {}

    -- 获取其他药品
    for pos, item in pairs(self.inventory) do
        if ITEM_TYPE.MEDICINE == item.item_type then
            table.insert(medicines, {name = item.name, icon = InventoryMgr:getIconByName(item.name),
                amount = item.amount, des = InventoryMgr:getDescript(item.name), item_type = item.item_type,
                useDes = InventoryMgr:getItemFunc(item), pos = pos, attrib = item.attrib })
        end
    end

    local toArrangeItems = {}
    for pos, item in pairs(medicines) do
        local data = {pos = pos, item = item}

        -- 设置药品的比较层次
        self:setMedicinesLayer(data);

        table.insert(toArrangeItems, data)
    end

    table.sort(toArrangeItems, sortItems)

    medicines = {}
    for pos, data in pairs(toArrangeItems) do
        table.insert(medicines, data.item)
    end

    return medicines
    end

function InventoryMgr:setMedicinesLayer(data)
    if not data then return end

    local itemType = data.item.item_type
    if ITEM_TYPE.MEDICINE == itemType and not gf:findStrByByte(data.item.name, CHS[4200154]) then
        -- 非玲珑类药品
        data.layer = 5
    elseif ITEM_TYPE.MEDICINE == itemType and gf:findStrByByte(data.item.name, CHS[4200154]) then
        -- 玲珑类药品，按“袖珍血/法玲珑”，“血/法玲珑”，“中级血/法玲珑”，“高级血/法玲珑”排序
        if gf:findStrByByte(data.item.name, CHS[3004112]) then     -- 袖珍血法玲珑
        data.layer = 1
        elseif gf:findStrByByte(data.item.name, CHS[4000186]) then -- 中级血法玲珑
            data.layer = 3
        elseif gf:findStrByByte(data.item.name, CHS[4000187]) then -- 高级血法玲珑
            data.layer = 4
        else                                                       -- 血法玲珑
            data.layer = 2
end
    else
        data.layer = 6
    end
end

function InventoryMgr:getItemFunc(item)
    local funStr = ""
    if item.durability ~= "" and item.durability ~= nil and item.durability ~= 0 then
        if item.max_durability ~= nil and item.max_durability ~= 0 then
            funStr = string.format(CHS[4000021], item.durability, item.max_durability)
        else
            funStr = string.format(CHS[4000022], item.durability)
        end
    elseif item.extra_desc ~= nil and item.extra_desc ~= "" then
        funStr = item.extra_desc
    elseif item.extra.life_1 ~= nil then
        funStr = string.format(CHS[4000023], item.extra.life_1, item.extra.life_1)
    elseif item.extra.mana_1 ~= nil then
        funStr = string.format(CHS[4000024], item.extra.mana_1, item.extra.mana_1)
    end

    return funStr
end

-- 战斗中选择物品后，下方显示的说明
function InventoryMgr:getItemFuncInCombat(item)
    local funStr = ""

    if gf:findStrByByte(item.name, CHS[3002619]) then -- 血玲珑
        funStr = CHS[3002620] -- 策划要求血玲珑固定显示此内容
    elseif gf:findStrByByte(item.name, CHS[3002621]) then -- 法玲珑
        funStr = CHS[3002622] -- 策划要求法玲珑固定显示此内容
    elseif item.extra.life_1 ~= nil then
        funStr = string.format(CHS[3002618], item.extra.life_1) -- "气血恢复%d点",
        elseif item.extra.mana_1 ~= nil then
        funStr = string.format(CHS[3002617], item.extra.mana_1)
    end

    -- 如果是高级物品，显示高级物品的战斗描述
    if InventoryMgr:getItemInfoByNameAndField(item.name, "effect_in_combat") then
        return InventoryMgr:getItemInfoByNameAndField(item.name, "effect_in_combat")
                end

    return funStr
end

function InventoryMgr:MSG_INVENTORY(data)
    local inventory = self.inventory
    for _, v in ipairs(data) do
        if not v.amount or v.amount <= 0 or not v.icon or v.icon <= 0 then
            -- 删除物品
            inventory[v.pos] = nil
        else
            -- 添加物品
            self:addItemToBag(v)
        end
    end
end

-- 添加物品到背包
-- item.pos         物品位置
-- item.amount      物品数量
-- item.icon        物品图标
-- item.attrib
function InventoryMgr:addItemToBag(item)
    if self.inventory[item.pos] == nil then
        item.attrib = Bitset.new(item.attrib)
        self.inventory[item.pos] = item
    else
        if self.inventory[item.pos] ~= item  then
            item.attrib = Bitset.new(item.attrib)
            self.inventory[item.pos] = item
        end
    end
end
function InventoryMgr:MSG_FINISH_SORT_PACK(data)
    if data.start_range == 1 then
        -- 开始整理
        self.isArranging = true
    else
        -- 结束整理
        self.isArranging = false
    end
end

-- 目前只提供药店
function InventoryMgr:getFuncFromItemCfg(itemName)
    if nil == ItemInfo[itemName] then return "" end
    return ItemInfo[itemName].func or ""
end

-- 获取道具的功效
function InventoryMgr:getFuncStr(item)
    local info = self:getItemInfoByName(item.name) or {}
    if item.item_type == ITEM_TYPE.MEDICINE and not gf:findStrByByte(item.name, CHS[4200154]) then
        return "#G" .. InventoryMgr:getFuncFromItemCfg(item.name) .. "\n"
    elseif item.item_type == ITEM_TYPE.FISH
            or info.item_class == ITEM_CLASS.FISH then
        if InventoryMgr:getFuncFromItemCfg(item.name) == "" then return "" end
        return "#G" .. InventoryMgr:getFuncFromItemCfg(item.name) .. "\n"
    elseif item.item_type == ITEM_TYPE.DISH or item.item_type == ITEM_TYPE.TOY then
        return InventoryMgr:getFuncFromItemCfg(item.name)
    end

    -- func
    local funStr = ""

    -- 灵气
    if item.nimbus and item.nimbus ~= "" then
        if item.nimbus ~= 0 then
        funStr = funStr .. CHS[3004106] .. item.nimbus .. "\n"
        else
            funStr = funStr .. CHS[3004106] .. "#R0#n\n" -- 灵气为零时，显示为红色字体的数字0
    end
    end

    -- 耐久
    if item.durability ~= "" and item.durability ~= nil and item.durability ~= 0 and item.durability ~= -1 then
        if item.max_durability ~= nil and item.max_durability ~= 0 then
            funStr = funStr .. string.format(CHS[4000021], item.durability, item.max_durability) .. "\n"
        else
            funStr = funStr .. string.format(CHS[4000022], item.durability) .. "\n"
        end
    end

    if item.extra and not string.match(item.name, CHS[3001096]) then
        -- 功效,超级黑水晶不显示功效WDSY-27950
        if item.extra.life_1 ~= nil then
            funStr = funStr .. "#G" .. string.format(CHS[4000023], item.extra.life_1, item.extra.life_1) .. "#n\n"
        end

        if item.extra.mana_1 ~= nil then
            funStr = funStr .. "#G" .. string.format(CHS[4000024], item.extra.mana_1, item.extra.mana_1) .. "#n\n"
        end

        if item.extra.def_2 ~= nil then
            funStr = funStr .. CHS[3004107] .. item.extra.def_2 .. "\n"
        end

        if item.extra.mag_power_2 ~= nil then
            funStr = funStr .. CHS[3004108] .. item.extra.mag_power_2 .. "\n"
        end

        if item.extra.phy_power_2 ~= nil then
            funStr = funStr .. CHS[3004109] .. item.extra.phy_power_2 .. "\n"
        end

        if item.extra.max_life_2 ~= nil then
            funStr = funStr .. CHS[3004110] .. item.extra.max_life_2 .. "\n"
        end

        if item.extra.max_mana_2 ~= nil then
            funStr = funStr .. CHS[3004456] .. item.extra.max_mana_2 .. "\n"
        end

        if item.extra.speed_2 ~= nil then
            funStr = funStr .. CHS[3004111] .. item.extra.speed_2 .. "\n"
        end
    end

    -- 描述
    if item.extra_desc ~= nil and item.extra_desc ~= "" then
        funStr = item.extra_desc .. "\n"
    end

    -- 经验
    if item.exp then
        funStr = funStr .. CHS[3003157] .. CHS[7000078] .. item.exp .. "\n"
    end

    -- 道行
    if item.tao then
        funStr = funStr .. CHS[3003158] .. CHS[7000078] .. gf:getTaoStr(item.tao, 0) .. "\n"
    end

    -- 武学
    if item.martial then
        funStr = funStr .. CHS[3002149] .. CHS[7000078] .. item.martial .. "\n"
    end

    return funStr
end

-- 获取试用等级字符串
function InventoryMgr:getTryLevelTip(item)
    local itemInfo = self:getItemInfoByName(item.name)
    if nil == itemInfo then return "" end

    -- 袖珍类道具
    if gf:findStrByByte(item.name, CHS[3004112]) then
        if item.level and item.level > 1 then
        return string.format(itemInfo["try_level_tip"], item.level, item.level + 9)
        else
            return ""
    end
    end

    -- 经验心得与道武心得
    if item.name == CHS[7000044] or item.name == CHS[7000045] then
        if item.level then
            local maxLimitLevel = item.level + 9
            if Const.PLAYER_MAX_LEVEL - item.level == 10 then
                maxLimitLevel = item.level + 10
            end

            return string.format(itemInfo["try_level_tip"], item.level, maxLimitLevel)
        else
            return ""
        end
    end

    if itemInfo["try_level_tip"] then
        return string.format(itemInfo["try_level_tip"], itemInfo.use_level)
    end

    return ""
end

-- 获取量词
function InventoryMgr:getUnit(itemName)
    -- 有可能是家具
    local furnitureInfo = FurnitureInfo[itemName]
    if furnitureInfo then
        return furnitureInfo.unit
    end

    local parentName = self:getParentName(itemName) or itemName
    local itemInfo = self:getItemInfoByName(itemName)
    if nil == itemInfo then
        itemInfo = self:getItemInfoByName(parentName)
        if itemInfo == nil then
            return CHS[6000043]
        else
        return itemInfo["unit"] or CHS[6000043]
    end
    end

    return itemInfo["unit"] or CHS[6000043]
end

-- 背包能不能筛入当前的道具数量(大于number返回数量number   小于number返回具体的数量)
function InventoryMgr:isCanAddToBag(item, number, price)
    local itemName = item
    if type(item) == 'table' then
        itemName = item.name
    end

    -- 指定了单价，则需要分开计算金元宝和银元宝
    local countBySilver
    price = tonumber(price)
    if price and price > 0 then
        local silver = Me:queryBasicInt("silver_coin")
        countBySilver = math.floor(silver / price)
        local leftSilver = silver - price * countBySilver
        if leftSilver > 0 then
            countBySilver = countBySilver + 1
        end
    else
        return InventoryMgr:getCountCanAddToBag(item, number, false)
    end

    if countBySilver >= number then
        return self:getCountCanAddToBag(item, number, true)
    else
        -- 银元宝可以购买的数量
        local c1, nc1 = self:getCountCanAddToBag(item, countBySilver, true)
        if c1 < countBySilver then
            -- 银元宝已经无法全部装下了
            return c1
        end

        -- 可以装下银元宝购买的数量，在计算金元宝可以购买的数量
        local c2, _ = self:getCountCanAddToBag(item, number - countBySilver, false, nc1)
    local maxItemCount = getItemDoubleMax(item)
        return c2 + c1
    end
end

function InventoryMgr:getCountCanAddToBag(item, number, isLimit, hasPrevUse)
    if number <= 0 then return 0, 0 end

    local itemName = item
    local itemLevel = 0
    if type(item) == 'table' then
        itemName = item.name
        itemLevel = item.level or 0
    end

    local maxItemCount = getItemDoubleMax(item)

    local canAddNumber = 0
    local nullCount = 0 -- 新占用的空位置
    if not hasPrevUse then hasPrevUse = 0 end
    for i = BAG_START, InventoryMgr:getCanUseMaxPos() do
        local tmpItem = self:getItemByPos(i)

        if tmpItem == nil then
            if hasPrevUse <= 0 then
            if self:itemIsCanDouble(itemName) == true then
                canAddNumber = canAddNumber + maxItemCount
            else
                canAddNumber = canAddNumber+ 1
            end
                nullCount = nullCount + 1
            else
                hasPrevUse = hasPrevUse - 1
            end
        elseif tmpItem["name"] == itemName and (itemLevel == 0 or itemLevel == tmpItem["level"]) and self:itemIsCanDouble(itemName) then

            if (nil ~= isLimit and self:isLimitedItemForever(tmpItem) == isLimit) or (nil == isLimit) then
                canAddNumber = canAddNumber + maxItemCount - tmpItem["amount"]
        end
        end

        if canAddNumber >= number then
            canAddNumber = number
            break
        end
    end

    return canAddNumber, nullCount
end

-- 变身卡相性logo
function InventoryMgr:addPolarChangeCard(ctr, cardName)
    local info = self:getCardInfoByName(cardName)
    if not info then return end
    local sp = ctr:getChildByName("polarLogo")
    if sp then return end
    local polar = info.polar
    if not polar then
        return
    end

    local polarPath = ResMgr:getPolarImagePath(gf:getPolar(polar))
    local sp = ccui.ImageView:create()
    sp:loadTexture(polarPath, ccui.TextureResType.plistType)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, spSize.height * 0.5)
    sp:setName("polarLogo")
    ctr:addChild(sp)
end

-- 移除变身卡相性标记
function InventoryMgr:removePolarChangeCard(ctr)
    if not ctr then
        return
    end

    local sp = ctr:getChildByName("polarLogo")
    if sp then
        sp:removeFromParent()
    end
end

-- 增加法宝相性标记
function InventoryMgr:addPetPolarImage(ctr, polar)
    local sp = ctr:getChildByName("PetPolarLogo")
    if sp then return end

    if not polar then
        return
    end

    if polar < 0 or polar > 5 then
        return
    end

    local polarPath = ResMgr:getPolarImagePath(gf:getPolar(polar))
    local sp = ccui.ImageView:create()
    sp:loadTexture(polarPath, ccui.TextureResType.plistType)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, spSize.height * 0.5)
    sp:setName("PetPolarLogo")
    ctr:addChild(sp)
end

function InventoryMgr:removeArtifactGongtongLogo(ctr)
    local sp = ctr:getChildByName("artifactGongtong")
    if sp then
        sp:removeFromParent()
    end
end

-- 增加法宝共通标记
function InventoryMgr:addArtifactGongtongLogo(ctr)
    local sp = ctr:getChildByName("artifactGongtong")
    if sp then
        return
    end

    local polarPath = ResMgr:getPolarImagePath(gf:getPolar(1))
    local sp = ccui.ImageView:create()
    sp:loadTexture(ResMgr.ui.fabao_gongtong_flag)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, size.height - spSize.height * 0.5)
    sp:setName("artifactGongtong")
    ctr:addChild(sp)
end

-- 增加法宝相性标记
function InventoryMgr:addArtifactPolarImage(ctr, polar)
    local sp = ctr:getChildByName("artifactPolarLogo")
    if sp then
        InventoryMgr:removeArtifactPolarImage(ctr)
    end

    if not polar then
        return
    end

    if polar < 1 or polar > 5 then
        return
    end

    local polarPath = ResMgr:getPolarImagePath(gf:getPolar(polar))
    local sp = ccui.ImageView:create()
    sp:loadTexture(polarPath, ccui.TextureResType.plistType)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, spSize.height * 0.5)
    sp:setName("artifactPolarLogo")
    ctr:addChild(sp)
end

-- 移除法宝相性标记
function InventoryMgr:removeArtifactPolarImage(ctr)
    if not ctr then
        return
    end

    local sp = ctr:getChildByName("artifactPolarLogo")
    if sp then
        sp:removeFromParent()
    end
end

-- 根据道具 icon 对应的文件名
function InventoryMgr:getIconPathByItem(item)
    if InventoryMgr:getIsGuard(item.name) then
        local icon = InventoryMgr:getIconByName(item.name)
        return ResMgr:getSmallPortrait(item.Icon or item.icon or icon)
    else
        return ResMgr:getItemIconPath(item.icon)
    end
end

-- 是否是未鉴定装备
function InventoryMgr:isUnidentifiedByItem(item)
    if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        return true
    end

    return false
end
-- 未鉴定装备加logo
function InventoryMgr:addLogoUnidentified(ctr)
    local isExitSp = ctr:getChildByName(ResMgr.ui.undefine_equip)
    if isExitSp then return end
    local sp = cc.Sprite:create(ResMgr.ui.undefine_equip)
    sp:setName(ResMgr.ui.undefine_equip)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, spSize.height * 0.5)
    ctr:addChild(sp)
end

-- 去掉未鉴定装备加logo
function InventoryMgr:removeLogoUnidentified(ctr)
    if nil == ctr then return end
    local sp = ctr:getChildByName(ResMgr.ui.undefine_equip)
    if sp then
        sp:removeFromParent()
    end
end

-- 绑定logo
function InventoryMgr:addLogoBinding(ctr)
    local sp = ctr:getChildByName("bindingLogo")
    if sp then return end
    local sp = cc.Sprite:create(ResMgr.ui.gift)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(spSize.width * 0.5, spSize.height * 0.5)
    sp:setName("bindingLogo")
    ctr:addChild(sp)
end

-- 时限logo
function InventoryMgr:addLogoTimeLimit(ctr)
    local sp = ctr:getChildByName("timeLimitLogo")
    if sp then return end
    local sp = cc.Sprite:create(ResMgr.ui.time_limit)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(spSize.width * 0.5, spSize.height * 0.5)
    sp:setName("timeLimitLogo")
    ctr:addChild(sp)
end

-- 去掉邦定logo
function InventoryMgr:removeLogoBinding(ctr)
    if nil == ctr then return end
    local sp = ctr:getChildByName("bindingLogo")
    if sp then
        sp:removeFromParent()
    end
end

-- 去掉时限logo
function InventoryMgr:removeLogoTimeLimit(ctr)
    if nil == ctr then return end
    local sp = ctr:getChildByName("timeLimitLogo")
    if sp then
        sp:removeFromParent()
    end
end

-- 融合logo
function InventoryMgr:addLogoFuse(ctr)
    local sp = ctr:getChildByName(ResMgr.ui.fuse)
    if sp then return end
    local sp = cc.Sprite:create(ResMgr.ui.fuse)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width * 0.5, spSize.height * 0.5)
    sp:setName(ResMgr.ui.fuse)
    ctr:addChild(sp)
end

-- 移除融合 logo
function InventoryMgr:removeLogoFuse(ctr)
    if nil == ctr then return end
    local sp = ctr:getChildByName(ResMgr.ui.fuse)
    if sp then
        sp:removeFromParent()
    end
end

-- 道具是否可叠加
function InventoryMgr:itemIsCanDouble(name, isLimit)
    local item = self:getItemInfoByName(name)
    if item == nil then return true end

    if item["double_type"] ~= nil and item["double_type"] == 2 then
        return false
    else
        return true
    end

end

-- 获取所有非邦定物品
function InventoryMgr:getAllBindingItems()
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and not InventoryMgr:isLimitedItem(item) then
            table.insert(items, item)
        end
    end

    return items
end

-- 获取背包所有存在的物品
function InventoryMgr:getAllExistItem()
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil then
            table.insert(items, item)
        end
    end

    return items
end


-- 获取排的最前面的20级未鉴定装备位置
function InventoryMgr:getUndefineEquipLevel20()
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and 1 == item.unidentified and ITEM_TYPE.EQUIPMENT == item.item_type and 20 == item.req_level then
            return i - 40
        end
    end
end

-- 获取某种类型的所有道具
function InventoryMgr:getItemByType(itemType)
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and item['item_type'] == itemType then
            table.insert(items, item)
        end
    end

    return items
end

-- 获取某种类型的所有道具,对完全相同的道具进行合并，未处理叠加数量
-- 适用在包裹里只能叠加10个，但在其他地方可以叠加999用来显示的情况(比如天书)
-- 包裹最多有10 x 25 x 5 = 1250个，策划说玩家不会这么玩，所以暂时未处理超过999的情况
function InventoryMgr:getItemByTypeWithMerge(itemType)
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = gf:deepCopy(self.inventory[i])
        if item ~= nil and item['item_type'] == itemType then
            local findIt = false
            for j = 1, #items do
                if item.name == items[j].name and item.level == items[j].level and item.color == items[j].color and
                    item.nimbus == items[j].nimbus and InventoryMgr:isSameItemByGift(item, items[j]) then
                    items[j].amount = items[j].amount + item.amount
                    findIt = true
                    break
                end
            end

            if not findIt then
                table.insert(items, item)
            end
        end
    end

    return items
end

-- 获取道具
function InventoryMgr:getItemByNameAndLevel(name, level, color)
    local items = InventoryMgr:getItemByName(name)
    local destItems = {}
    for i = 1, #items do
        if (not level or items[i].level == level) and (not color or items[i].color == color) then
            table.insert(destItems, items[i])
        end
    end

    -- 按照限时道具、永久限制交易道具、非永久限制交易道具、非限制交易道具排序
    for i = 1, #destItems do
        if InventoryMgr:isTimeLimitedItem(destItems[i]) and not InventoryMgr:isItemTimeout(destItems[i]) then
            destItems[i].layer = 1
        elseif InventoryMgr:isLimitedItemForever(destItems[i]) then
            destItems[i].layer = 2
        elseif InventoryMgr:isLimitedItem(destItems[i]) then
            destItems[i].layer = 3
        else
            destItems[i].layer = 4
        end
    end

    table.sort(destItems, function(l, r)
        if l.layer < r.layer then return true end
        if l.layer > r.layer then return false end
    end)

    return destItems
end

-- 获取道具
function InventoryMgr:getItemByName(name, excludeLimited, excludeTimeLimited, excludeLimitForever)
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and item['name'] == name then
            if not excludeLimited and not excludeTimeLimited then
                table.insert(items, item)
            elseif excludeLimited and not self:isLimitedItem(item) and not excludeTimeLimited then
                table.insert(items, item)
            elseif excludeTimeLimited and not self:isTimeLimitedItem(item) then
                table.insert(items, item)
            end
        end
    end

    local list = {}
    if excludeLimitForever then
        for i = 1, #items do
            if not self:isLimitedItemForever(items[i]) then
                table.insert(list, items[i])
        end
        end
    else
        list = items
    end

    return list
end

-- 获取某一类道具
function InventoryMgr:getItemByClass(class, excludeLimited)
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item and InventoryMgr:getClassByName(item.name) ~= nil and InventoryMgr:getClassByName(item.name) == class then
            if not excludeLimited then
                table.insert(items, item)
            elseif excludeLimited and not self:isLimitedItem(item) then
                table.insert(items, item)
            end
        end
    end

    return items
end

function InventoryMgr:getClassByName(name)
    local info = InventoryMgr:getItemInfoByName(name)
    return info.item_class
end

-- 道具是否为粉才
function InventoryMgr:isUpgrade(itemName)
    local itemInfo = self:getItemInfoByName(itemName)
    if nil == itemInfo then return end

    return itemInfo["isUpgrade"]
end

-- 根据物品ID获取物品位置，不包含装备的位置
function InventoryMgr:getItemPosById(itemId)
    if nil == itemId or 0 == itemId then return end

    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and itemId == item.item_unique and ITEM_TYPE.EQUIPMENT == item.item_type then
            return item.pos
        end
    end
end

-- 根据物品ID获取物品，开始位置为41
function InventoryMgr:getItemById(itemId)
    if nil == itemId or 0 == itemId then return end

    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and itemId == item.item_unique then
            return item
        end
    end
end

-- 根据物品ID获取物品，开始位置为1，即包括身上装备的
function InventoryMgr:getItemByIdFromAll(itemId, includeStoreItems)
    if nil == itemId or 0 == itemId then return end

    for i = 1, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and itemId == item.item_unique then
            return item
        end
    end

    if includeStoreItems then
        for key, item in pairs(StoreMgr.storeItems) do
            if item ~= nil and itemId == item.item_unique then
                return item
            end
        end

        -- 同时还要包括卡套的变身卡
        for key, item in pairs(StoreMgr.storeCards) do
            if item ~= nil and itemId == item.item_unique then
                return item
            end
        end
    end
end

function InventoryMgr:getItemByIIdFromBag(iid_str)
    for i = 1, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and item.iid_str == iid_str then
            return item
        end
    end
end

function InventoryMgr:getItemByIIdFromAll(iid_str, name)
    if iid_str == nil or iid_str == "" then
        if name then  -- 如果参数iid_str无值，但配置了name参数，则可以根据道具名称获取该道具
            for i = 1, BAG_END do
                local item = self.inventory[i]
                if item ~= nil and item.name == name then
                    return item
                end
            end

            -- 如果背包中无法找到，则从仓库中寻找
            for key, item in pairs(StoreMgr.storeItems) do
                if item ~= nil and item.name == name then
                    return item
                end
            end
        end
    else
        for i = 1, BAG_END do
            local item = self.inventory[i]
            if item ~= nil and item.iid_str == iid_str then
                return item
            end
        end

        -- 如果背包中无法找到，则从仓库中寻找
        for key, item in pairs(StoreMgr.storeItems) do
            if item.iid_str == iid_str then
                return item
            end
        end
    end

    return
end

-- 获取所有物品信息
function InventoryMgr:getAllItemInfo()
    return ItemInfo
end

-- 获取超级黑水晶，根据等级和部位
function InventoryMgr:getBlackCrystalByLevelAndPart(level, equipPart)
    local inventory = self.inventory
    local crystals = {}
    for _, v in pairs(inventory) do
        if gf:findStrByByte(v.name, CHS[3004075]) then
            if v.level == level and v.upgrade_type == equipPart then
                table.insert(crystals, v)
            end
        end
    end

    return crystals
end


-- 获取限时字符串
function InventoryMgr:getTimeLimitStr(item)
    local timeLimitStr
    if item.isTimeLimitedReward then
        timeLimitStr = CHS[4100654]
    elseif item.leftTime then
        local timeLeft = item.leftTime
        local str
        if timeLeft >= 86400 then -- 60 * 60 * 24
            str = string.format(CHS[34050], math.floor(timeLeft / 86400))
        elseif timeLeft >= 3600 then
            str = string.format(CHS[4100093], math.ceil(timeLeft / 3600))
        else
            str = string.format(CHS[4300223], math.ceil(timeLeft / 60))
        end

        timeLimitStr = string.format(CHS[4200451], str)
    else
        timeLimitStr = string.format(CHS[7000184], gf:getServerDate(CHS[4200022], item.deadline))
    end

    return timeLimitStr
end


-- 是否是限时道具
function InventoryMgr:isTimeLimitedItem(item)
    if item and item.deadline and item.deadline ~= 0 then
        return true
    else
        return false
    end
end

-- 道具是否已经超时
function InventoryMgr:isItemTimeout(item)
    if InventoryMgr:isTimeLimitedItem(item) and item.deadline < gf:getServerTime() then
        return true
    else
        return false
    end
end

-- 是否限制交易
function InventoryMgr:isLimitedItem(item)
    if nil == item or nil == item.gift then return end
    local gift = item.gift

    if gift < 0 then
        if gift + gf:getServerTime() + Const.DELAY_TIME_BALANCE < 0 then
            return true
        end

        gift = 0
    end

    return gift == 2
end

-- 是否是永久性限制交易
function InventoryMgr:isLimitedItemForever(item)
    if nil == item or nil == item.gift then return end
    return item.gift == 2
end


-- 获得限制交易字符串
function InventoryMgr:getLimitAtt(equip, ctrl)
    local attrTab = {}
    local str = ""
    local day = 0
    local color = COLOR3.EQUIP_RED
    if equip and InventoryMgr:isLimitedItem(equip) then

        str, day = gf:converToLimitedTimeDay(equip.gift)
        table.insert(attrTab, {str = str, color = color})
    end

    return attrTab, str, day
end

-- 获取超级黑水晶，根据等级和部位
function InventoryMgr:getBlackCrystalByLevelAndField(level, field)
    local req_level = math.floor(level / 10) * 10
    local inventory = self.inventory
    local crystals = {}
    local fieldStr = string.format("%s_%d", field, Const.FIELDS_EXTRA1)
    for _, v in pairs(inventory) do
        if gf:findStrByByte(v.name, CHS[3004075]) then
            if v.level == req_level and v.extra[fieldStr] then
                table.insert(crystals, v)
            end
        end
    end

    return crystals
end

-- 喂养宠物是否是绑定道具
function InventoryMgr:feedPetByIsLimitItem(name, pet, para, isUseLimitItem, isNotIgnorTips, checkFunc)

    local amount = InventoryMgr:getAmountByNameIsForeverBind(name, isUseLimitItem)
    if amount < 1 then
        gf:askUserWhetherBuyItem(name)
        return
    end

    local items = InventoryMgr:getItemByName(name, true)
    local item = InventoryMgr:getPriorityUseInventoryByName(name, isUseLimitItem)

    if not item then return end

    if item and not self:canUseItem(item.pos, InventoryMgr.USE_ITEM_OBJ.PET) then
        return
    end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease(item) then
        SafeLockMgr:addModuleContinueCb("InventoryMgr", function() InventoryMgr:feedPetByIsLimitItem(name, pet, para, isUseLimitItem, isNotIgnorTips, checkFunc) end)
        return
    end

    local str, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
    if not isNotIgnorTips and isUseLimitItem and InventoryMgr:getAmountByNameForeverBind(name) > 0 and day <= Const.LIMIT_TIPS_DAY and CHS[3004084] ~= name then
        gf:confirm(string.format(CHS[3004113], 10), function()
            if "function" == type(checkFunc) and not checkFunc() then
                return
            end

            gf:CmdToServer("CMD_FEED_PET", { no = pet:queryBasicInt("no"), pos = item.pos, para = para})
            DlgMgr:sendMsg("PetAttribDlg", "checkLimitedTip", name)
            DlgMgr:sendMsg("PetHorseDlg", "checkLimitedTip")
        end)
    else
        if "function" == type(checkFunc) and not checkFunc() then
            return
        end

        gf:CmdToServer("CMD_FEED_PET", { no = pet:queryBasicInt("no"), pos = item.pos, para = para })
    end
end

-- 获取当前身上最好的装备等级
-- 规则：装备改造等级、完美度
function InventoryMgr:getPerfectEquip(equipType)
    local perfectItem

    -- 包括身上的武器装备
    for i = 1, BAG_END do
        repeat
        local item = self.inventory[i]
        if not item then
            -- 这个位置没有物品
            break
        end

        if ITEM_TYPE.EQUIPMENT ~= item.item_type then
            -- 这个物品不是装备
            break
        end

        if equipType ~= item.equip_type then
            -- 不是需要的类型
            break
        end

        if not perfectItem then
            -- 第一个找到的装备
            perfectItem = item
            break
        end

        if item.rebuild_level > perfectItem.rebuild_level then
            -- 如果改造等级比较高
            perfectItem = item
        elseif item.rebuild_level == perfectItem.rebuild_level
            and item.equip_perfect_percent > perfectItem.equip_perfect_percent then
            -- 如果完美度比较高
            perfectItem = item
        end

        until true
    end

    return perfectItem
end

function InventoryMgr:openItemRescourse(itemName, rect, btnRect, item)
    if not DistMgr:checkCrossDist() then return end
    local dlg = DlgMgr:openDlg("ItemRecourseDlg")
    dlg:setInfo(itemName, rect, btnRect, item)
    return dlg
end

-- 黑水晶专用打开来源界面
function InventoryMgr:openItemRescourseByBlackCrystal(item, rect)
    if not DistMgr:checkCrossDist() then return end

    -- 如果是超级黑水晶，带属性和不带属性的黑水晶显示来源不一样
    local isAttrib = false
    if string.match(item.name, CHS[3001225] .. "·") then isAttrib = true end

    local dlg = DlgMgr:openDlg("ItemRecourseDlg")
    dlg:setBlackCrystakType(isAttrib)
    dlg:setInfo(item.name, rect, nil, item)
    return dlg
end

-- 通过一个物品对象显示悬浮信息
function InventoryMgr:showItemByItemData(item, rect)
    local equipType = item["equip_type"]

    if equipType then
        if (equipType >= 1 and equipType <= 3) or equipType == EQUIP.BOOT then      --  装备
            if item.unidentified == 1 then
                -- 未鉴定状态
                InventoryMgr:showBasicMessageByItem(item, rect)
            else
                InventoryMgr:showEquipByEquipment(item, rect, true)
            end
        elseif equipType == EQUIP_TYPE.BALDRIC or equipType == EQUIP_TYPE.WRIST or equipType == EQUIP.NECKLACE then  -- 首饰
            InventoryMgr:showJewelryFloatDlg(item, rect, true)
        elseif equipType == EQUIP_TYPE.ARTIFACT then  -- 法宝
            InventoryMgr:showArtifact(item, rect, true)
        end
    else
        if InventoryMgr:isFurniture(item) then  -- 家具
            -- 种子和材料弹的是道具悬浮框
            InventoryMgr:showFurniture(item, rect, true)
            return
        end

        local dlg = DlgMgr:openDlg('ItemInfoDlg')   -- 道具
        dlg:setInfoFormCard(item)
        dlg:setFloatingFramePos(rect)
    end
end

-- 获取当前玩家包裹中正在使用的武器icon
function InventoryMgr:getMeUsingWeaponIcon()
    local weaponIcon = 0
    local weapon = InventoryMgr:getItemsByPosArray({EQUIP.WEAPON})
    if weapon then
        local item = InventoryMgr:getItemByPos(weapon[1].pos)
        if item then
            weaponIcon = item.icon
        end
    end

    return weaponIcon
end

-- 种植相关（如：种子、烹饪材料）服务端当做家具处理，但客户端显示的是道具悬浮框，此处做特殊判断
function InventoryMgr:isFurniture(item)
    local itemInfo = self:getItemInfoByName(item.name)

    if item.item_type == ITEM_TYPE.FURNITURE
        and itemInfo
        and itemInfo.furniture_type ~= CHS[5400136]
        and itemInfo.furniture_type ~= CHS[5400137] then  -- 家具
        -- 种子和材料弹的是道具悬浮框
        return true
    end

    return false
end

-- 获取变身卡
function InventoryMgr:getChangeCard()
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
            table.insert(items, item)
        end
    end

    return items
end

function InventoryMgr:getChangeCardByOrder()
    local changeCards = InventoryMgr:getChangeCard()

    for i = 1, #changeCards do
        local cardName = changeCards[i].name
        local info = InventoryMgr:getCardInfoByName(cardName)
        changeCards[i].order = info.order
    end

    table.sort(changeCards, function(l, r)
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    return changeCards
end

-- 获取最优先消耗的变身卡
function InventoryMgr:getChangeCardByCostOrder(name)
    -- 优先考虑限制：永久限制交易>非永久限制交易>非限制交易
    -- 其次考虑位置：包裹>卡套
    local totalCards = {}
    local storeCard = StoreMgr:getChangeCard()
    local bagCard = InventoryMgr:getChangeCard()

    for i = 1, #bagCard do
        local card = bagCard[i]
        if card.name == name then
            if InventoryMgr:isTimeLimitedItem(card) then
                card.order = 1
            elseif InventoryMgr:isLimitedItemForever(card) then
                card.order = 3
            elseif InventoryMgr:isLimitedItem(card) then
                card.order = 5
            else
                card.order = 7
            end
            table.insert(totalCards, card)
        end
    end

    for i = 1, #storeCard do
        local card = storeCard[i]
        if card.name == name then
            if InventoryMgr:isTimeLimitedItem(card) then
                card.order = 2
            elseif InventoryMgr:isLimitedItemForever(card) then
                card.order = 4
            elseif InventoryMgr:isLimitedItem(card) then
                card.order = 6
            else
                card.order = 8
            end
            table.insert(totalCards, card)
        end
    end

    table.sort(totalCards, function(l, r)
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    local nextUseCard = nil
    if #totalCards > 1 then
        nextUseCard =  totalCards[2]
    end

    return totalCards[1], nextUseCard
end

-- 获取经验心得/道武心得
function InventoryMgr:getXinDe(xinDeName)
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item ~= nil and item.name == xinDeName then
            table.insert(items, item)
        end
    end

    return items
end

-- 获取变身卡基本信息
function InventoryMgr:getAllCardInfo()
    return  changeCardInfo
end

-- 获取变身卡基本信息
function InventoryMgr:getChangeCardShapeOffset(icon)
    if ChangeCardShapeOffset and ChangeCardShapeOffset[icon] then
        return ChangeCardShapeOffset[icon]
    else
        return {x = 0, y = 0}
    end
end

-- 获取变身卡总类个数
function InventoryMgr:getAmountCardsKind()
    if self.changeCardKindAmount then return self.changeCardKindAmount end

    local amont = 0
    for cardName, cardInfo in pairs(changeCardInfo) do
        amont = amont + 1
    end
    self.changeCardKindAmount = amont
    return  self.changeCardKindAmount
end

-- 获取变身卡属性表
function InventoryMgr:getAllCardAttrib()
    return  changeCardAtt
end

-- 获取变身卡效果
function InventoryMgr:getChangeCardEff(cardName)
    local cardInfo = InventoryMgr:getCardInfoByName(cardName)
    local totalInfo = {}
    -- 基本属性
    local attribTab = cardInfo.attrib
    for i = 1, #attribTab do
        local info = {}
        local att = attribTab[i]
        local perce = InventoryMgr:isPercentChangeAtt(att.field)
        local attValue = att.value
        if attValue > 0 then
            info.str = att.chs .. " +" .. attValue .. perce
        else
            info.str = att.chs .. " " .. attValue .. perce
        end
        info.color = COLOR3.BLUE
        table.insert(totalInfo, info)
    end

    -- 阵法属性
    local battleArrayAttribTab = cardInfo.battle_arr
    for i = 1, #battleArrayAttribTab do
        local info = {}
        local att = battleArrayAttribTab[i]
        local perce = InventoryMgr:isPercentChangeAtt(att.field)
        if att.value > 0 then
            info.str = att.chs .. " +" .. att.value .. perce
        else
            info.str = att.chs .. " " .. att.value .. perce
        end

        info.color = COLOR3.GRAY
        table.insert(totalInfo, info)
    end

    return totalInfo
end

-- 获取变身卡基本信息
function InventoryMgr:getCardInfoByName(cardName)
    if changeCardInfo[cardName] then
        return  changeCardInfo[cardName]
    end
end

function InventoryMgr:isPercentChangeAtt(field)
    if field == "double_hit" or field == "counter_attack" or field == "damage_sel" then
        return ""
    end

    return "%"
end

-- 获取变身卡基本属性
function InventoryMgr:getCardAttrib(item)
    if item.item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD then return end
    local hasAtt = {}
    for i = 1, #changeCardAtt do
        local attCfg = changeCardAtt[i]
        local field = attCfg.field .. "_" .. Const.FIELDS_CHANGE_CARD
        if item.extra[field] then
            if "phy_absorb" == attCfg.field or "mag_absorb" == attCfg.field then
                table.insert(hasAtt, {["chs"] = attCfg.chs,["field"] = field, value = -item.extra[field]})
            else
                table.insert(hasAtt, {["chs"] = attCfg.chs,["field"] = field, value = item.extra[field]})
            end
        end
    end
    return hasAtt
end

-- 获取变身卡阵法属性
function InventoryMgr:getCardBattleArrayAttrib(item)
    if item.item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD then return end
    local hasAtt = {}
    for i = 1, #changeCardAtt do
        local attCfg = changeCardAtt[i]
        local field = attCfg.field .. "_" .. Const.FIELDS_BATTLE_ARRAY
        if item.extra[field] then
            if "phy_absorb" == attCfg.field or "mag_absorb" == attCfg.field then
                table.insert(hasAtt, {["chs"] = attCfg.chs,["field"] = field, value = -item.extra[field]})
            else
                table.insert(hasAtt, {["chs"] = attCfg.chs,["field"] = field, value = item.extra[field]})
            end
        end
    end
    return hasAtt
end

-- 使用变身卡
function InventoryMgr:applyChangCard(id, pos)
    gf:CmdToServer('CMD_APPLY_CARD', {id = id, pos = pos})
end

-- 通知客户端采集
function InventoryMgr:MSG_START_GATHER(data)
    local dlg = DlgMgr:openDlg("UseBarDlg")
    dlg:setInfo(data)

    -- 清除自动寻路标志
    AutoWalkMgr:setTalkToNpcIsEnd(true)

    -- 站住不动
    Me:setAct(Const.SA_STAND, true)
end

function InventoryMgr:MSG_STOP_GATHER(data)
    if DlgMgr:isDlgOpened("UseBarDlg") then
        gf:unfrozenScreen(true) -- 需要立刻解除，端午节可能受到解除冻屏幕后立刻又冻伤，如果传nil，时延迟0.5帧，会异常解冻
        DlgMgr:closeDlg("UseBarDlg")
    end
end

-- 获取变身变身时间
function InventoryMgr:getCardChangeTime(cardType)
    if cardType == CARD_TYPE.MONSTER then
        return 12
    elseif cardType == CARD_TYPE.ELITE then
        return 6
    elseif cardType == CARD_TYPE.BOSS then
        return 8
    elseif cardType == CARD_TYPE.EPIC then
        return 6
    end
end

function InventoryMgr:getItemColor(equip)
    local color = COLOR3.TEXT_DEFAULT
    if equip.color == CHS[3004100] then
        color = COLOR3.LIGHT_WHITE
    elseif equip.color == CHS[3004101] then
        color = COLOR3.GREEN
    elseif equip.color == CHS[3004102] then
        color = COLOR3.BLUE
    elseif equip.color == CHS[3004103] then
        color = COLOR3.MAGENTA
    elseif equip.color == CHS[3004104] then
        color = COLOR3.YELLOW
    elseif equip.color == CHS[4200743] then
        color = COLOR3.PURPLE
    end

    return color
end

-- 获取折扣券
function InventoryMgr:getDiscountCoupon(discount)
    local items = {}
    local curTime = gf:getServerTime()
    for _, v in pairs(self.inventory) do
        if ((not discount and (v.name == CHS[2000188] or v.name == CHS[2000189] or v.name == CHS[2000190]))
            or v.name == discount) and (0 == v.deadline or v.deadline >= curTime) then
            if not items[v.name] then items[v.name] = 0 end
            items[v.name] = items[v.name] + v.amount
        end
    end

    return items
end

-- 是否有折扣券
function InventoryMgr:hasDiscountCoupon()
    local curTime = gf:getServerTime()
    for _, v in pairs(self.inventory) do
        if (v.name == CHS[2000188] or v.name == CHS[2000189] or v.name == CHS[2000190]) and (0 == v.deadline or v.deadline >= curTime) then
            return true
        end
    end
end

-- 优惠前是否有效
function InventoryMgr:isCouponValid(name, time)
    local items = InventoryMgr:getItemByName(name)
    if not items or #items <= 0 then return false end

    if not time then time = gf:getServerTime() end

    return 0 == items[1].deadline or items[1].deadline > time
end

function InventoryMgr:getGenderItemOrder(name)
    if name == CHS[6000263] then
        return 1
    elseif name == CHS[6000264] then
        return 2
    elseif name == CHS[6000262] then
        return 3
    else
        return 4
    end
end

-- 获取赠送好友的礼物
function InventoryMgr:getGenderItems(gender)
    local myGender = Me:queryBasic("gender")
    local itemsName = GENDER_ITEM[myGender..gender]

    local genderImtes = {}
    local inventory = self.inventory
    local allBagItem = {}
    for _, v in pairs(inventory) do
        if v.pos >= BAG_START and v.pos <= BAG_END  and itemsName[v.name] then
            local amount = v.amount
            if amount > 1 then
                local item = {}
                for k, s in pairs(v) do
                    if 'amount' ~= k then
                        item[k] = s
                    else
                        item[k] = 1
                    end
                end

                for j = 1, amount do
                    table.insert(genderImtes, item)
                end
            else
                table.insert(genderImtes, v)
            end
        end
    end

    table.sort(genderImtes, function(l, r)
        local lName = InventoryMgr:getGenderItemOrder(l.name)
        local tName = InventoryMgr:getGenderItemOrder(r.name)
        if lName < tName then return true end
        if lName > tName then return false end

        local lt = InventoryMgr:getItemLimitedOrder(l)
        local rt = InventoryMgr:getItemLimitedOrder(r)
        if lt < rt then return true end
        if lt > rt then return false end
    end)

    return genderImtes
end

function InventoryMgr:isEquipFashionByPos(pos)
    if pos == EQUIP.FASHION_SUIT
        or pos == EQUIP.FASHION_JEWELRY
        or pos == EQUIP.FASION_HAIR
        or pos == EQUIP.FASION_UPPER
        or pos == EQUIP.FASION_LOWER
        or pos == EQUIP.FASION_ARMS then
        return true
    else
        return false
    end
end

-- 通知服务器包裹内物品已过期
function InventoryMgr:notifyItemTimeout(item)
    if not item then
        return
    end

    if not item.pos then
        return
    end

    local str
    if item.pos >= StoreMgr:getStartPosByType("home_store") then
        -- 居所储物室
        str = "home_store"
    elseif item.pos > BAG_END then
        str = "normal_store"
    else
        str = "bag"
    end

    if InventoryMgr:isTimeLimitedItem(item) then
        gf:CmdToServer("CMD_NOTIFY_ITEM_TIMEOUT", {
            pos = item.pos,
            str = str,
        })
    end
end

-- 获取本地配置的道具颜色
function InventoryMgr:getLocalConfigColor(itemName)
    local itemInfo = self:getItemInfoByName(itemName)
    if not itemInfo then
        return
    end

    if itemInfo.color then
        return itemInfo.color
    elseif itemInfo.coin then
        return CHS[3004104]
    end

    return
end

-- 是否商城道具
function InventoryMgr:isOnlineItem(itemName)
    local itemInfo = self:getItemInfoByName(itemName)
    if itemInfo and itemInfo.coin then
        return true
    end
end

function InventoryMgr:MSG_NEW_ITEM_INFO(data)
    local items = {}

    if pcall(function() items = loadstring(data.itemStr)() end) then
    end

    if type(items) ~= "table" then return end
    for itemName, newItem in pairs(items) do
        ItemInfo[itemName] = newItem
    end
end

function InventoryMgr:MSG_ASK_SUBMIT_ZIKA(data)
    local  dlg = DlgMgr:openDlg("Confirm2Dlg")
    dlg:setData(data)
end

-- 是否被使用过的物品
function InventoryMgr:isUsedItem(item)
    local cfg = InventoryMgr:getItemInfoByName(item.name)
    if not cfg then return end
    local max_expend = cfg.max_expend

    -- 血玲珑
    if string.match(item.name, CHS[3001136]) then
        if item.extra.life_1 ~= max_expend then
            return true
        end
    end

    -- 法玲珑
    if string.match(item.name, CHS[3001139]) then
        if item.extra.mana_1 ~= max_expend then
            return true
        end
    end

    -- 天书
    if item.item_type == ITEM_TYPE.GODBOOK then
        if item.nimbus ~= max_expend then
            return true
        end
    end

    -- 火眼金睛、通天令牌等
    if item.max_durability and item.max_durability ~= 0 and item.max_durability ~= item.durability then
        return true
    end

    return false
end

-- 目前只通知部分物品
function InventoryMgr:MSG_APPLY_SUCCESS(data)
    if data.itemName == CHS[4300061] then -- 急急如律令
        if self:isFirstUseItem(data.itemName) and GetTaoMgr:getJijiStatus() ~= 1 then
            -- 是否是第一次使用急急如律令
            gf:confirm(CHS[4300062], function ()
                local dlg = DlgMgr:openDlg("GetTaoDlg")
                local rootPanel = dlg:getControl("ButtonPanel")
                local addPanel = dlg:getControl("OpenStatePanel", nil, rootPanel)
                gf:createArmatureMagic(ResMgr.ArmatureMagic.use_double_point, addPanel, Const.ARMATURE_MAGIC_TAG)
            end, nil)
        end
    elseif data.itemName == CHS[6200026] then -- 宠风散
        if self:isFirstUseItem(data.itemName) and 0 == GetTaoMgr:getChongfengsanStatus() then
            gf:confirm(CHS[6200033],
                function ()
                    local dlg = DlgMgr:openDlg("GetTaoDlg")
                    local addPanel = dlg:getControl("ChongfsOpenPanel")
                    gf:createArmatureMagic(ResMgr.ArmatureMagic.use_double_point, addPanel, Const.ARMATURE_MAGIC_TAG)
                end, nil)
        end
    elseif data.itemName == CHS[4200391] then -- 如意刷道令
        if self:isFirstUseItem(data.itemName) and not GetTaoMgr:getRuYiZHLState() then
            gf:confirm(CHS[4200392],
                function ()
                    local dlg = DlgMgr:openDlg("GetTaoDlg")
                    local rootPanel = dlg:getControl("ButtonPanel4")
                    local addPanel = dlg:getControl("OpenPanel", nil, rootPanel)
                    gf:createArmatureMagic(ResMgr.ArmatureMagic.use_double_point, addPanel, Const.ARMATURE_MAGIC_TAG)
                end, nil)
         end
    end
end

-- 变身卡置顶
function InventoryMgr:setChangeCardTop(cardName)
    gf:CmdToServer('CMD_CL_CARD_TOP_ONE', {card_name = cardName})
end

-- 来源打开的物品
function InventoryMgr:getRecourseItem()
    return self.recourseItem
end

-- 来源打开的物品
function InventoryMgr:setRecourseItem(item)
    self.recourseItem = item
end

-- 打开便捷使用框
function InventoryMgr:getQuickUseItemCfg()
    return QuickUseItemCfg
end

-- 打开便捷使用框
function InventoryMgr:MSG_QUICK_USE_ITEM(data)
    if data then
        local quickUseItemCfg = InventoryMgr:getQuickUseItemCfg()
        local item = InventoryMgr:getItemByPos(data.pos)
        if item and quickUseItemCfg[item.name] then
            DlgMgr:openDlgEx(quickUseItemCfg[item.name].dlgName, data)
        end
    end
end

-- 是否融合道具
function InventoryMgr:isFuseItem(name)
    if name and string.match(name, CHS[5410258]) then
        return true
    end
end

function InventoryMgr:checkBagMorePageTips()
    local rideId = PetMgr:getRideId() or 0
    local pet = PetMgr:getPetById(rideId)
    if pet and not PetMgr:isHaveFenghuaTime(pet) then
        gf:confirm(CHS[5420311], function()
            DlgMgr:openDlg("PetHorseDlg")
        end)
    elseif Me:getVipType() <= 0 then
        gf:confirm(gf:replaceVipStr(CHS[3002300]), function()
            OnlineMallMgr:openOnlineMall("OnlineMallVIPDlg", nil, {vip = 1})
        end)
    elseif Me:getVipType() < 3 then
        gf:confirm(gf:replaceVipStr(CHS[5420301]), function()
            OnlineMallMgr:openOnlineMall("OnlineMallVIPDlg", nil, {vip = 3})
        end)
    else
        gf:confirm(CHS[6000550], function()
            DlgMgr:openDlg("PetHorseDlg")
        end)
    end
end

function InventoryMgr:checkStoreMorePageTips()
    if Me:getVipType() <= 0 then
        gf:confirm(gf:replaceVipStr(CHS[3003651]), function()
            OnlineMallMgr:openOnlineMall("OnlineMallVIPDlg", nil, {vip = 1})
        end)
    elseif Me:getVipType() < 3 then
        gf:confirm(gf:replaceVipStr(CHS[3003652]), function()
            OnlineMallMgr:openOnlineMall("OnlineMallVIPDlg", nil, {vip = 3})
        end)
    end
end

-- 获取当前外观状态
function InventoryMgr:getDressLabel()
    return self.dressData and self.dressData.label or 0
end


function InventoryMgr:getPetDressLabel()
    return self.petDressData and self.petDressData.label or 0
end

function InventoryMgr:hasDress(item)
    return item and item.pos and item.pos <= EQUIP.FASIONG_END
end

-- 获取外观道具数据
function InventoryMgr:getDressData(storeType, sex, part, checkState)
    local datas = {}
    local item, items, hasItems

    local function getItemName(name)
        return self:getParentName(name) or name
    end

    if self.dressData then
        local label = self:getDressLabel()
        hasItems = {}
        if true then
            -- 已有道具
            local item, itemCount, itemInfo

            if 'fasion_store' == storeType and(- 1 == label or 0 == label) then
                items = StoreMgr.storeFashions
                for k, v in pairs(items) do
                    item = v
                    if item.gender == sex and(not part or item.part == part) then
                        table.insert(datas, item)
                        hasItems[getItemName(item.name)] = true
                    end
                end

                item = self.inventory[EQUIP.FASION_DRESS]
                if item and item.gender == sex and(not part or item.part == part) then
                    table.insert(datas, item)
                    hasItems[getItemName(item.name)] = true
                end
            elseif 'custom_store' == storeType and(1 == label) then
                items = StoreMgr.storeCustoms
                local customItemInfo = require("cfg/CustomItem")
                for k, v in pairs(items) do
                    item = v
                    itemInfo = self:getItemInfoByName(item.name)
                    if itemInfo.gender == sex and(not part or itemInfo.part == part) then
                        local nitem = gf:deepCopy(item)
                        local custItem = customItemInfo[item.name]
                        nitem.part = itemInfo.part
                        nitem.gender = itemInfo.gender
                        nitem.partIndex = custItem.fasion_part
                        nitem.colorIndex = custItem.fasion_dye
                        table.insert(datas, nitem)
                        hasItems[getItemName(item.name)] = true
                    end
                end

                local inPos = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
                for i = 1, #inPos do
                    if not part or part == i then
                        item = self.inventory[inPos[i]]
                        if item then
                            itemInfo = self:getItemInfoByName(item.name)
                            if itemInfo.gender == sex then
                                local nitem = gf:deepCopy(item)
                                local custItem = customItemInfo[item.name]
                                nitem.part = itemInfo.part
                                nitem.gender = itemInfo.gender
                                nitem.partIndex = custItem.fasion_part
                                nitem.colorIndex = custItem.fasion_dye
                                table.insert(datas, nitem)
                                hasItems[getItemName(item.name)] = true
                            end
                        end
                    end
                end
            elseif 'effect_store' == storeType then
                items = StoreMgr.storeEffects
                local fasionEffectInfo = DressMgr:getFashionEffect()
                for k, v in pairs(items) do
                    item = v
                    local nitem = gf:deepCopy(item)
                    itemInfo = self:getItemInfoByName(item.name)
                    table.insert(datas, nitem)
                    hasItems[getItemName(item.name)] = true
                end

                item = self.inventory[EQUIP.FASION_BALDRIC]
                if item then
                    local nitem = gf:deepCopy(item)
                    itemInfo = self:getItemInfoByName(item.name)
                    table.insert(datas, nitem)
                    hasItems[getItemName(item.name)] = true
                end

                -- 非道具类特效，是否已拥有由服务端通知，不存于仓库及背包
                local ownEffect = self.dressData and self.dressData.effect_own
                if ownEffect then
                    for i = 1, #ownEffect do
                        local name = ownEffect[i]
                        local itemName = getItemName(name)
                        local itemInfo = self:getItemInfoByName(name)
                        if itemInfo and not hasItems[itemName] then
                            table.insert(datas, {name = name, icon = itemInfo.icon, amount = 1})
                            hasItems[itemName] = true
                        end
                    end
                end
            elseif 'pet_store' == storeType then
                items = StoreMgr.storeFollowPets
                local followPetInfo = DressMgr:getFollowPet()
                for k, v in pairs(items) do
                    item = v
                    local nitem = gf:deepCopy(item)
                    itemInfo = self:getItemInfoByName(item.name)
                    table.insert(datas, nitem)
                    hasItems[getItemName(item.name)] = true
                end

                item = self.inventory[EQUIP.EQUIP_FOLLOW_PET]
                if item then
                    local nitem = gf:deepCopy(item)
                    itemInfo = self:getItemInfoByName(item.name)
                    table.insert(datas, nitem)
                    hasItems[getItemName(item.name)] = true
                end
            end
        end

        if 2 == checkState then
            datas = {}
        end

        if not checkState or 2 == checkState then
            -- 未获得的道具
            local malls
            if 'fasion_store' == storeType or 'custom_store' == storeType then
                malls = self.dressData.malls
            elseif 'effect_store' == storeType then
                malls = self.dressData.effect_malls
            elseif 'pet_store' == storeType then
                malls = self.dressData.pet_malls
            end

            local mallCount = malls and #malls or 0

            local mallItem
            for i = 1, mallCount do
                mallItem = malls[i]
                if not hasItems[getItemName(mallItem.name)] then
                    local itemInfo = self:getItemInfoByName(mallItem.name)
                    if itemInfo.gender and itemInfo.gender == sex and (not part or itemInfo.part == part) then
                        if 1 == label and 'custom_store' == storeType then
                            local customItemInfo = require("cfg/CustomItem")
                            local custItem = customItemInfo[mallItem.name]
                            table.insert(datas, {name = mallItem.name, icon = itemInfo.icon, part = itemInfo.part, partIndex = custItem.fasion_part, colorIndex = custItem.fasion_dye, price = mallItem.goods_price})
                            hasItems[getItemName(mallItem.name)] = true
                        elseif(-1 == label or 0 == label) and 'fasion_store' == storeType then
                            table.insert(datas, {name = mallItem.name, icon = itemInfo.icon, coin = mallItem.goods_price})
                            hasItems[getItemName(mallItem.name)] = true
                        end
                    elseif 'effect_store' == storeType then
                        table.insert(datas, {name = mallItem.name, icon = itemInfo.icon, price = mallItem.goods_price})
                        hasItems[getItemName(mallItem.name)] = true
                    elseif 'pet_store' == storeType then
                        table.insert(datas, {name = mallItem.name, icon = itemInfo.icon, price = mallItem.goods_price})
                        hasItems[getItemName(mallItem.name)] = true
                    end
                end
            end

            if(- 1 == label or 0 == label) and 'fasion_store' == storeType then
                -- 不可出售部件
                local name
                for k, v in pairs(FashionItem) do
                    if not hasItems[k] then
                        local itemInfo = self:getItemInfoByName(k)
                        if itemInfo and itemInfo.gender == sex
                                and (not v.start_show_time
                                    or DistMgr:curIsTestDist()
                                    or gf:getServerTime() > v.start_show_time)
                                and (not v.test_start_show_time
                                    or not DistMgr:curIsTestDist()
                                    or gf:getServerTime() > v.test_start_show_time)
                                and (v.hide_unofficial ~= 1 or DistMgr:isOfficalDist()) then
                                -- hide_unofficial 部分跟随宠非官方不显示
                            table.insert(datas, {name = k, icon = itemInfo.icon})
                        end
                    end
                end
            end

            if 'effect_store' == storeType then
                local fasionEffectInfo = DressMgr:getFashionEffect()
                if not hasItems then
                    hasItems = {}
                    items = StoreMgr.storeEffects
                    for k, v in pairs(items) do
                        item = v
                        hasItems[getItemName(item.name)] = true
                    end

                    item = self.inventory[EQUIP.FASION_BALDRIC]
                    if item then
                        hasItems[getItemName(item.name)] = true
                    end
                end

                for k, v in pairs(fasionEffectInfo) do
                    local itemInfo = self:getItemInfoByName(k)
                    if not hasItems[k] and itemInfo
                            and (v.hide_unofficial ~= 1 or DistMgr:isOfficalDist()) then
                            -- hide_unofficial 部分跟随宠非官方不显示
                        table.insert(datas, {name = k, icon = itemInfo.icon, price = v.price})
                    end
                end
            end

            if 'pet_store' == storeType then
                local followPetInfo = DressMgr:getFollowPet()
                if not hasItems then
                    hasItems = {}
                    items = StoreMgr.storeFollowPets
                    for k, v in pairs(items) do
                        item = v
                        hasItems[getItemName(item.name)] = true
                    end

                    item = self.inventory[EQUIP.EQUIP_FOLLOW_PET]
                    if item then
                        hasItems[getItemName(item.name)] = true
                    end
                end

                for k, v in pairs(followPetInfo) do
                    local itemInfo = self:getItemInfoByName(k)
                    if not hasItems[k] and itemInfo
                            and (v.hide_unofficial ~= 1 or DistMgr:isOfficalDist()) then
                            -- hide_unofficial 部分跟随宠非官方不显示
                        table.insert(datas, {name = k, icon = itemInfo.icon, price = v.price})
                    end
                end
            end
        end
    end

    if 'pet_store' == storeType then
        -- 按照编号从大到小
        table.sort(datas, function(l, r)
            return l.icon > r.icon
        end)
    else
        -- 按照编号从小到大
        table.sort(datas, function(l, r)
            return l.icon < r.icon
        end)
    end

    return datas
end

function InventoryMgr:MSG_FASION_CUSTOM_LIST(data)
    local effect_malls, pet_malls, effect_own
    if self.dressData then
        -- 数据已存在，先保存特效、宠物、已拥有的数据
        if self.dressData.effect_malls then
            effect_malls = gf:deepCopy(self.dressData.effect_malls)
        end

        if self.dressData.pet_malls then
            pet_malls = gf:deepCopy(self.dressData.pet_malls)
        end

        if self.dressData.effect_own then
            effect_own = gf:deepCopy(self.dressData.effect_own)
        end
    end

    self.dressData = data
    self.dressData.effect_malls = effect_malls
    self.dressData.pet_malls = pet_malls
    self.dressData.effect_own = effect_own

    if not DlgMgr:getDlgByName(data.para) and data.flag == 1 then
        DlgMgr:openDlg(data.para)
    end
end

function InventoryMgr:MSG_PET_FASION_CUSTOM_LIST(data)
    self.petDressData = data
    if not DlgMgr:getDlgByName(data.para) and data.flag == 1 then
        DlgMgr:openDlg(data.para)
    end
end

-- 初始化便捷道具配置，调用用，Const.lua 中 FAST_USE_ITEM 配置的均会再次弹出便捷使用
function InventoryMgr:initFastUseItemFlag()
    self.fastUseItemFlag = {}
    for i = 1, #FAST_USE_ITEM do
        self.fastUseItemFlag[FAST_USE_ITEM[i]] = true
    end
end

-- 设置该类型的物品为快速使用，还是屏蔽状态， itemName 可传入高级、中级血池，会自动将血池类设置为 isUse 状态
function InventoryMgr:setFastUseItemFlag(itemName, isUse)
    if not self.fastUseItemFlag then
        InventoryMgr:initFastUseItemFlag()
    end
    local name = InventoryMgr:getFastUseTypeByItemName(itemName)
    if not name then return end
    self.fastUseItemFlag[name] = isUse
end

-- 是否可以弹出便捷使用，itemName 可传入高级、中级血池，会自动判断血池类道具
function InventoryMgr:isCanFastUseByItemName(itemName)
    if not self.fastUseItemFlag then
        InventoryMgr:initFastUseItemFlag()
    end
    local name = InventoryMgr:getFastUseTypeByItemName(itemName)
    if not name then return end
    return self.fastUseItemFlag[name]
end

-- 根据道具名，获取对应类型，即传入高级血池，返回配置的血池
function InventoryMgr:getFastUseTypeByItemName(itemName)
    if not self.fastUseItemFlag then
        InventoryMgr:initFastUseItemFlag()
    end
    for name, isCan in pairs(self.fastUseItemFlag) do
        local pos = gf:findStrByByte(itemName, name)
        if pos ~= nil then
            return name
        end
    end
end

function InventoryMgr:isInBagByPos(pos)
    return pos and pos >= BAG1_START and pos <= BAG_END
end

function InventoryMgr:MSG_ZZQN_CARD_INFO(data)
    if not InventoryMgr.dynamicCardKey then return end
    if InventoryMgr.dynamicCardKey.id ~= data.id or InventoryMgr.dynamicCardKey.pos ~= data.pos then return end

    data.deadline = InventoryMgr.dynamicCardKey.item.deadline
    local dlg = DlgMgr:openDlgEx("NpcCardDlg", data)
    dlg:setFloatingFramePos(InventoryMgr.dynamicCardKey.rect)
end

function InventoryMgr:MSG_FASION_EFFECT_LIST(data)
    if not self.dressData then return end
    self.dressData.effect_malls = data.malls
    self.dressData.effect_own = data.effect_own
end

function InventoryMgr:MSG_FOLLOW_PET_VIEW(data)
    if not self.dressData then return end
    self.dressData.pet_malls = data.malls
end

function InventoryMgr:getFashionShapeIcon(name)
    local info = FashionItem[name]
    if info then
        return info.icon
    end

    local info = FashionItem[self:getParentName(name) or ""]
    if info then
        return info.icon
    end

    local icon = tonumber(name)
    if icon then
        for fasionName, info in pairs(FashionItem) do
            if icon == info.icon then
                return fasionName
            end
        end
    end
end

-- 获取外观道具数据
function InventoryMgr:getPetDressData(storeType, sex, part, checkState)
    local datas = {}
    local item, items, hasItems

    local function getItemName(name)
        return self:getParentName(name) or name
    end

    if self.petDressData then
        local label = self:getPetDressLabel()
        hasItems = {}
        if true then
            -- 已有道具
            local item, itemCount, itemInfo

            if 'fasion_store' == storeType and(- 1 == label or 0 == label) then
                items = StoreMgr.storeFashions
                for k, v in pairs(items) do
                    item = v
                    if item.gender == sex and(not part or item.part == part) then
                        table.insert(datas, item)
                        hasItems[getItemName(item.name)] = true
                    end
                end

                item = self.inventory[EQUIP.FASION_DRESS]
                if item and item.gender == sex and(not part or item.part == part) then
                    table.insert(datas, item)
                    hasItems[getItemName(item.name)] = true
                end
            end
        end
    end

    -- 按照编号从小到大
    table.sort(datas, function(l, r)
        return l.icon < r.icon
    end)

    return datas
end

-- 获取道具灵尘点数
function InventoryMgr:getItemLingchenPoint(itemName)
    if CanDecomposeItem[itemName] then
        return CanDecomposeItem[itemName].lingchen_point
    end

    return 0
end

-- 获取可分解的道具
function InventoryMgr:geCanDecomposeItems()
    local items = {}
    for i = BAG1_START, BAG_END do
        local item = self.inventory[i]
        if item and CanDecomposeItem[item['name']]
                and self:isLimitedItemForever(item)
                and not self:isTimeLimitedItem(item) then
                -- 永久限制交易
                -- 非限时道具
            local index = 0
            for i = 1, item.amount do
                index = index + 1
                table.insert(items, {name = item.name, pos = item.pos, item_unique = item.item_unique, index = item.pos * 100 + index})
            end
        end
    end

    return items
end

function InventoryMgr:MSG_LINGCHEN_DATA(data)
    if data.isOpen == 1 then
        DlgMgr:openDlg("LingchenShopDlg")
    end
end

InventoryMgr:getLimitItemDlgsFromXml()
MessageMgr:regist("MSG_PET_FASION_CUSTOM_LIST", InventoryMgr)
MessageMgr:regist("MSG_ZZQN_CARD_INFO", InventoryMgr)
MessageMgr:regist("MSG_NEW_ITEM_INFO", InventoryMgr)
MessageMgr:regist("MSG_INVENTORY", InventoryMgr)
MessageMgr:regist("MSG_FINISH_SORT_PACK", InventoryMgr)
MessageMgr:regist("MSG_START_GATHER", InventoryMgr)
MessageMgr:regist("MSG_STOP_GATHER", InventoryMgr)
MessageMgr:regist("MSG_ASK_SUBMIT_ZIKA", InventoryMgr)
MessageMgr:regist("MSG_APPLY_SUCCESS", InventoryMgr)
MessageMgr:regist("MSG_QUICK_USE_ITEM", InventoryMgr)
MessageMgr:regist("MSG_FASION_CUSTOM_LIST", InventoryMgr)
MessageMgr:regist("MSG_FASION_EFFECT_LIST", InventoryMgr)
MessageMgr:regist("MSG_FOLLOW_PET_VIEW", InventoryMgr)
MessageMgr:regist("MSG_LINGCHEN_DATA", InventoryMgr)

return InventoryMgr
