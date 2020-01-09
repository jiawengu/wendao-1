-- HomeMgr.lua
-- Created by sujl, Jun/12/2017
-- 居所管理器
-- 主要负责维护进入居所的数据(houseData)，该居所不一定是自己的，另外提供了一些通用居所接口
-- HomeMgr.myData维护自身一些居所信息，可用通过getMyHomeData获取

local LightEffect = require(ResMgr:getCfgPath('LightEffect.lua'))

-- 功能型家具特效对应编号:骨骼动画，龙骨动画
local FUNCTION_FURNITURE_MAGIC = require(ResMgr:getCfgPath("FuncFurnitureMagic.lua"))

local EFFECT_TAG    = 766   -- 部分家具使用中光效。人物、法宝修炼阵

local List = require("core/List")

-- npc居所，居所家具mapId 和 对应配置文件map
local NpcHomeMap = require(ResMgr:getCfgPath('NpcHomeMapCfg.lua'))
-- npc居所家具数据，用到的时候再require
local NpcHomeData = {}

HomeMgr = Singleton()

-- 居所类型
local HOME_TYPES = {
    [1] = CHS[7002317],
    [2] = CHS[7002318],
    [3] = CHS[7002319],

    [CHS[7002317]] = 1,
    [CHS[7002318]] = 2,
    [CHS[7002319]] = 3,
}

local AUTOWALK_DEST_XY = {
    [CHS[7002317]] = {
        [CHS[7002328]] = {},
        [CHS[7002329]] = {},
        [CHS[7002330]] = {
            ["HomeFishingDlg"] = {
                x = 44, y = 34
            },

            ["dashui1"] = {
                x = 44, y = 34
            },
        },
    },

    [CHS[7002318]] = {
        [CHS[7002328]] = {},
        [CHS[7002329]] = {},
        [CHS[7002330]] = {
            ["HomeFishingDlg"] = {
                x = 52, y = 36
            },
            ["dashui1"] = {
                x = 52, y = 36
            },
        },
    },

    [CHS[7002319]] = {
        [CHS[7002328]] = {},
        [CHS[7002329]] = {},
        [CHS[7002330]] = {
            ["HomeFishingDlg"] = {
                x = 56, y = 47
            },
            ["dashui1"] = {
                x = 56, y = 47
            },
        },
    },
}

local HOME_PLACE = {
    CHS[7002328],
    CHS[7002329],
    CHS[7002330],
}

-- 最大舒适度
local MAX_COMFORT = {
    [1] = 250,
    [2] = 500,
    [3] = 1000,
}

-- 最大清洁度
local MAX_CLEAN = 100

-- 最大协助清扫次数
local MAX_ASSIST_CLEAN_TIMES = 10

-- 最大休息次数
local MAX_SLEEP_TIMES = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
}

local EFFECT_POS = {
    foot = 1,
    waist = 2,
    head = 3,
}

local EFFECT_NO = {
    tao = ResMgr.magic.pet_feed_get_tao,
    exp = ResMgr.magic.pet_feed_get_exp,
}

local FOOD_ICON = {
    [1] = {foodIcon = {ResMgr.ui.pet_bowl_food11, ResMgr.ui.pet_bowl_food12, ResMgr.ui.pet_bowl_food13}, bowlIcon = 10040},
    [2] = {foodIcon = {ResMgr.ui.pet_bowl_food21, ResMgr.ui.pet_bowl_food22, ResMgr.ui.pet_bowl_food23}, bowlIcon = 10041},
    [3] = {foodIcon = {ResMgr.ui.pet_bowl_food31, ResMgr.ui.pet_bowl_food32, ResMgr.ui.pet_bowl_food33}, bowlIcon = 10042},
}

local PET_ALPHA = 255 * 0.7 -- 宠物透明度
local PET_WALK_UNIT_RANDE = 30 -- 宠物行走已食盆为中心30个单位范围

local FURNITURE_TYPE_INFO = require (ResMgr:getCfgPath("FurnitureTypeInfo.lua"))
local ITEM_INFO = require (ResMgr:getCfgPath("ItemInfo.lua"))
local Furniture = require("obj/Furniture")
local FurnitureEx = require("obj/FurnitureEx")
local FurnitureInfo = require (ResMgr:getCfgPath("FurnitureInfo.lua"))
local FurniturePoint = require(ResMgr:getCfgPath("FurniturePoint.lua"))
local XiaoLanZhiJia = require(ResMgr:getCfgPath("XiaoLanZhiJia.lua"))

-- 家具类型对应上限
local FURNITURE_TYPE_LIMIT = {
    [CHS[2000290]] = 50,
    [CHS[2000291]] = 300,
    [CHS[2000292]] = -1,
    [CHS[2000293]] = -1,
    [CHS[2000294]] = 20,
    [CHS[2000295]] = 50,
    [CHS[2000296]] = 50,
    [CHS[2000297]] = 300,
    [CHS[2000298]] = 20,
    [CHS[2000299]] = 80,
    [CHS[2000300]] = -1,
    [CHS[2000301]] = 20,
    [CHS[2000302]] = 50,
    [CHS[2000303]] = 50,
    [CHS[5400253]] = 10,
}

local RANDOM_TALK = {
    [1] = CHS[5410076],
    [2] = CHS[5410077],
    [3] = CHS[5410078],
    [4] = CHS[5410079],
    [5] = CHS[5410080],
    [6] = CHS[5410081],
    [7] = CHS[5410082],
}

-- 每个玩家最大可使用的农田数目
local CROPLAND_MAX_LAND = {
    [CHS[5400167]] = 4,  -- 小舍
    [CHS[5400166]] = 6,  -- 雅筑
    [CHS[5400165]] = 8,  -- 豪宅
}

-- 家具等级1,2,3对应中文等级
local FURNITURE_LEVEL = {
    CHS[7100032],
    CHS[7100033],
    CHS[7100034],
}

local FISH_TOOL_TYPE = {
    POLE = 1, -- 鱼竿
    BAIT = 2 -- 鱼饵
}

-- 丫鬟上限
local MAID_NUM_LIMIT = {
    [1] = 1,
    [2] = 1,
    [3] = 2,
}

-- 丫鬟配置
local MAIDS = {
    { name = CHS[2000420], type = "qiaoer", icon = 51515},
    { name = CHS[2000421], type = "yaoer", icon = 51516},
}

-- 管家配置
local MANAGERS = {
    { name = CHS[2000408], type = "nqnvgj", icon = 51514, desc = CHS[2000409], price = 688, coin_type = 1 },
    { name = CHS[2000410], type = "nqnangj", icon = 51513, desc = CHS[2000411], price = 288, coin_type = 2 },
    { name = CHS[2000412], type = "nznangj", icon = 06011, desc = CHS[2000413], price = 0 },
}

-- 夫妻睡醒喊话
local DOUBLE_WAKE_UP_CALL_TEXT = {
    [1] = {
        [1] = {text = CHS[5410130], isFirst = true},
        [2] = {text = CHS[5410131]},
    },
    [2] = {
        [1] = {text = CHS[5410132], isFirst = true},
        [2] = {text = CHS[5410133]},
    },
    [3] = {
        [1] = {text = CHS[5410134]},
        [2] = {text = CHS[5410135], isFirst = true},
    },
    [4] = {
        [1] = {text = CHS[5410136], isFirst = true},
        [2] = {text = CHS[5410137]},
    },
    [5] = {
        [1] = {text = CHS[5410138], isFirst = true},
        [2] = {text = CHS[5410139]},
    },
    [6] = {
        [1] = {text = CHS[5410140], isFirst = true},
        [2] = {text = CHS[5410141]},
    },
    [7] = {
        [1] = {text = CHS[5410142], isFirst = true},
        [2] = {text = CHS[5410143]},
    },
}

-- 单人睡醒喊话
local ONE_WAKE_UP_CALL_TEXT = {
    [3] = {text = CHS[5410144]},
    [2] = {text = CHS[5410145]},
    [1] = {text = CHS[5410146]},
    [4] = {text = CHS[5410147]},
    [5] = {text = CHS[5410150]},
    [6] = {text = CHS[5410151]},
    [7] = {text = CHS[5410148]},
    [8] = {text = CHS[5410149]},
}

-- 打造列表家具名称  与FurnitureMakeDlg鲁班台的furnitureList表一致，由于用到地方少、两个表结构不一致，所以没有独立出文件
local LuBanFur = {
    [CHS[7100003]] = 1,
    [CHS[7100004]] = 1,
    [CHS[7100005]] = 1,
    [CHS[7100006]] = 1,
    [CHS[7100007]] = 1,
    [CHS[7100008]] = 1,
    [CHS[7100009]] = 1,
    [CHS[7100010]] = 1,
    [CHS[7100011]] = 1,
    [CHS[7100012]] = 1,
    [CHS[7100013]] = 1,
    [CHS[7100014]] = 1,
    [CHS[7100015]] = 1,
    [CHS[7100016]] = 1,
    [CHS[7100017]] = 1,
    [CHS[7100018]] = 1,
    [CHS[7100019]] = 1,
    [CHS[7100020]] = 1,
    [CHS[7100021]] = 1,
    [CHS[7100022]] = 1,
    [CHS[7190000]] = 1,
    [CHS[7190001]] = 1,
    [CHS[7190002]] = 1,
    [CHS[5400255]] = 1,
    [CHS[5400256]] = 1,
    [CHS[2500061]] = 1,
}

-- 宠物小屋喊话
PET_HOUSE_RANDOM_TALK = {
    [1] = {
        { 30, CHS[2100216] },
        { 30, CHS[2100217] },
        { 40, CHS[2100218] },
    },
    [2] = {
        { 15, CHS[2100219] },
        { 15, CHS[2100220] },
        { 15, { CHS[2100221], CHS[2100239], CHS[2100240]} },
        { 15, CHS[2100222] },
        { 10, CHS[2100223] },
        { 10, CHS[2100224] },
        { 10, CHS[2100225] },
        { 10, CHS[2100227] },
    }
}

local SLEEP_MAGIC_TAG = 10


function HomeMgr:init()
    self.furnitures = {}
    self.opers = {}
    self.regObs = {}
    self.homePets = {}
    self.feedPetValue = {}
    self.petFoodInfo = {}
    self.selectPetFeed = {}
    self.bowlFeedStatus = {}
    self.leftTime = {}
    self.artifactEffData = {}
    self:processFurnitureInfo()
    self.croplands = {}
    self.plantCrops = {}
    self.harvestCrops = {}
    self.croplandInfo = {}
    self.playerFishingInfo = {}
    self.storeShowPets = {}

    EventDispatcher:addEventListener("Shelter_changed", HomeMgr.onShelterChanged, HomeMgr)
end

function HomeMgr:clearData(isEnterRoom)
    self:clearFurnitures("furnitures", true)
    self:clearFurnitures("opers")
    self:clearRegObj()
    self.curHouseHosters = {}
    self.house_id = nil
    DlgMgr:closeDlg("HomePuttingDlg")
    DlgMgr:closeDlg("HomePlantDlg")
    DlgMgr:closeDlg("CheekFarmDlg")
    DlgMgr:closeDlg("HomeFishingDlg")
    DlgMgr:closeDlg("HomePetFeedDlg")
    DlgMgr:closeDlg("ArtifactPracticeDlg")
    DlgMgr:closeDlg("HomeBedroomDlg")
    DlgMgr:closeDlg("MoneyTreeDlg")
    DlgMgr:closeDlg("HomeMaterialGiveDlg")
    DlgMgr:closeDlg("HomeMaterialAskDlg")
    DlgMgr:closeDlg("HomeCookingDlg")
    DlgMgr:closeDlg("FurnitureMakeDlg")
    DlgMgr:closeDlg("HomeEntrustDlg")
    DlgMgr:closeDlg("RenameHomeDlg")
    DlgMgr:closeDlg("HomeManagerDlg")
    DlgMgr:closeDlg("RenameHomeManagerDlg")
    DlgMgr:closeDlg("RenameHomeMaidDlg")
    DlgMgr:closeDlg("HomeMaidsSelectDlg")
    DlgMgr:closeDlg("RenameHomeGardenerDlg")
    DlgMgr:closeDlg("EffectFurnitureDlg")
    DlgMgr:closeDlg("EffectFurnitureRuleDlg")
    DlgMgr:closeDlg("WoodSoldierDlg")
    DlgMgr:closeDlg("WoodSoldierRuleDlg")

    self.effData = nil
    self.artifactEffData = {}
    self.homePets = {}
    self.feedPetValue = {}
    self.petFoodInfo = {}
    self.selectPetFeed = {}
    self.bowlFeedStatus = {}
    self.leftTime = {}
    self:clearAllPets()
    self:clearAllStoreShowPets()
    self:clearAllCropland()
    self:clearAllPlantCrops()
    self.croplandInfo ={}
    self.playerFishingInfo = {}
    self.allFishToolsInfo = nil
    self.exchangeMaterialInfo = nil
    self.chooseMoneyTreeId = nil
    self.allInvisbleDlgsBySleep = nil
    self.playSleepInHome = false
    self.practiceHelpTargets = nil
    self.storeShowPets = {}

    self.resetAskLastTime = true

    if not isEnterRoom then
        -- 过图时不清数据
        self.farmInfoForCheck = nil

        if not DistMgr:getIsSwichServer() then
        self.artifactPracticeInfo = {}
        self.playerPracticeInfo = {}
            self.allPracticeBuffData = {}
    end
    end

    if self.sleepColorLayer then
        gf:unfrozenScreen()
        self.sleepColorLayer:removeFromParent()
        self.sleepColorLayer = nil
    end
end

function HomeMgr:checkFly(isOwner)
    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000072])
        return
    end

    if TaskMgr:isExistTaskByName(CHS[3003799]) then
        gf:ShowSmallTips(CHS[3003800])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[2000280])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000281])
        return
    end

    if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
        gf:ShowSmallTips(CHS[3002659])
        return
    end

    return true
end

function HomeMgr:checkRedName(isOwner)
    if Me:isRedName() then
        if isOwner then
            gf:ShowSmallTips(CHS[2100102])
        else
            gf:ShowSmallTips(CHS[2100103])
        end
        return true
    end

    return false
end

function HomeMgr:clearRegObj()
    if not self.regObs then return end
    for _, v in pairs(self.regObs) do
        v:cleanup()
    end

    local count = #(self.regObs)
    self.regObs = {}
    assert(count <= 0)
end

function HomeMgr:regObj(obj)
    self.regObs[tostring(obj)] = obj
end

function HomeMgr:unRegObj(obj)
    self.regObs[tostring(obj)] = nil
end

-- 家具sp在shelterLayer的(x,y)处是否处于遮罩状态
function HomeMgr:isShelter(sp, shelterLayer, bx, by, is_flip, furniturePoint, obstacle)
    if nil == shelterLayer or nil == furniturePoint then return end
    local contentSize = sp:getContentSize()
    local x, y, x1, y1, x2, y2, x3, y3
    if 1 == is_flip then
        x = bx + math.floor((contentSize.width / 2 - (furniturePoint.x or 0)) / Const.PANE_WIDTH)
        y = by + math.floor((contentSize.height / 2 - (furniturePoint.y or contentSize.height)) / Const.PANE_HEIGHT)
        x1 = bx + math.floor((contentSize.width / 2 - (furniturePoint.x1 or 0)) / Const.PANE_WIDTH)
        y1 = by + math.floor((contentSize.height / 2 - (furniturePoint.y1 or contentSize.height)) / Const.PANE_HEIGHT)
        x2 = bx + math.floor((contentSize.width / 2 - (furniturePoint.x2 or contentSize.width)) / Const.PANE_WIDTH)
        y2 = by + math.floor((contentSize.height / 2 - (furniturePoint.y2 or 0)) / Const.PANE_HEIGHT)
        if furniturePoint.x3 and furniturePoint.y3 then
            x3 = bx + math.floor((contentSize.width / 2 - furniturePoint.x3) / Const.PANE_WIDTH)
            y3 = by + math.floor((contentSize.height / 2 - furniturePoint.y3) / Const.PANE_HEIGHT)
        end
    else
        x = bx + math.floor((-contentSize.width / 2 + (furniturePoint.x or 0)) / Const.PANE_WIDTH)
        y = by + math.floor((contentSize.height / 2 - (furniturePoint.y or contentSize.height)) / Const.PANE_HEIGHT)
        x1 = bx + math.floor((-contentSize.width / 2 + (furniturePoint.x1 or 0)) / Const.PANE_WIDTH)
        y1 = by + math.floor((contentSize.height / 2 - (furniturePoint.y1 or contentSize.height)) / Const.PANE_HEIGHT)
        x2 = bx + math.floor((-contentSize.width / 2 + (furniturePoint.x2 or contentSize.width)) / Const.PANE_WIDTH)
        y2 = by + math.floor((contentSize.height / 2 - (furniturePoint.y2 or 0)) / Const.PANE_HEIGHT)
        if furniturePoint.x3 and furniturePoint.y3 then
            x3 = bx + math.floor((-contentSize.width / 2 + (furniturePoint.x3 or contentSize.width)) / Const.PANE_WIDTH)
            y3 = by + math.floor((contentSize.height / 2 - (furniturePoint.y3 or 0)) / Const.PANE_HEIGHT)
        end
    end

    if shelterLayer:getTileGIDAt(cc.p(x, y)) ~= 0 or shelterLayer:getTileGIDAt(cc.p(x1, y1)) ~= 0 or shelterLayer:getTileGIDAt(cc.p(x2, y2)) ~= 0
        or (nil ~= x3 and nil ~= y3 and shelterLayer:getTileGIDAt(cc.p(x3, y3)) ~= 0) then
        -- 基准点在shelterLayer遮罩内
        return true
    end

    local layer = obstacle
    if not layer then
        return false
    end

    local size = layer:getLayerSize()
    local beginX, beginY = math.floor(bx - size.width / 2 + 0.5), math.floor(by - size.height / 2 + 0.5)
    local tileValue
    local t = {}
    local p
    for i = 0, size.width - 1 do
        for j = 0, size.height - 1 do
            if 1 == is_flip then
                p = cc.p(size.width - 1 - i, j)
            else
                p = cc.p(i, j)
            end

            tileValue = layer:getTileGIDAt(p)
            if tileValue ~= 0 then
                if shelterLayer:getTileGIDAt(cc.p(beginX + i, beginY + j)) ~= 0 then
                    -- 障碍点在shelterLayer遮罩内
                    return true
                end
            end
        end
    end

    return false
end

function HomeMgr:getZOrder(id, sp, y)
    local furnitureInfo = HomeMgr:getFurnitureInfoById(id)
    local icon = furnitureInfo.icon
    local offset = FurniturePoint[icon] or cc.p(0, 0)
    if furnitureInfo and furnitureInfo.furniture_type == CHS[5400136] then
        -- 种植的农作物特殊处理，层级直接从基准点 y 值获取，不用做偏移
        return y
    else
        return y + sp:getContentSize().height / 2 - offset.y
    end
end

-- 处理家具信息
function HomeMgr:processFurnitureInfo()
    self.id2info    = {}
    self.type2info  = {}
    local item
    local id
    local type1, type2
    for k, v in pairs(FurnitureInfo) do
        item = v
        item.name = k
        id = item.id or item.icon
        self.id2info[id] = item
        if not self.type2info[item.furniture_type] then
            self.type2info[item.furniture_type] = {}
        end
        table.insert(self.type2info[item.furniture_type], item)
    end
end

-- 回收预览家具
function HomeMgr:revokePreview(furniture)
    if not furniture then return end
    local cookie = furniture.cookie
    if cookie then
        self.opers[cookie] = nil
    end

    furniture:cleanup()

    -- 通知界面刷新数据
    DlgMgr:sendMsg("HomePuttingDlg", "markDirty")
end

function HomeMgr:sortFurnitureList(list)
    if not list then
        return
    end

    table.sort(list, function(l, r)
        if l.level < r.level then return true end
        if l.level > r.level then return false end
        if l.comfort < r.comfort then return true end
        if l.comfort > r.comfort then return false end
        if l.icon < r.icon then return true end
        if l.icon > r.icon then return false end
    end)
end

-- 家具是否是地砖地面
function HomeMgr:isFloor(itemName)
    local info = HomeMgr:getFurnitureInfo(itemName)
    local furniture_type = info.furniture_type
    if string.match(furniture_type, CHS[7002373]) or
          string.match(furniture_type, CHS[7002374]) then
        return true
    end
end

-- 家具是否是围墙
function HomeMgr:isWall(itemName)
    local info = HomeMgr:getFurnitureInfo(itemName)
    local furniture_type = info.furniture_type
    if string.match(furniture_type, CHS[7002375]) then
        -- 围墙
        return true
    end
end

-- 根据cookie获取当前操作的家具
function HomeMgr:getOperFurniture(cookie)
    return self.opers and self.opers[cookie]
end

-- 获取家具列表
function HomeMgr:getFurnitures()
    return self.furnitures
end

function HomeMgr:getFurnitureById(id)
    return self.furnitures[id]
end

-- 通过furniture_pos获取操作列表中的家具
function HomeMgr:getFurnitureFromOpersById(id)
    for k, v in pairs(self.opers) do
        if v:getId() == id then
            return k, v
        end
    end
end

-- 根据类型获取
function HomeMgr:getLimitByType(ftype)
    return FURNITURE_TYPE_LIMIT[ftype]
end

-- 获取某类家具的数量
function HomeMgr:getCurAmountByType(ftype)
    local amount = 0
    for k, v in pairs(FurnitureInfo) do
        if v.furniture_type == ftype then
            amount = amount + self:getItemCountByName(k)
        end
    end

    return amount
end

-- 获取某类家具在包裹及列表中的数量
function HomeMgr:getAllAmountByType(ftype)
    local amount = 0

    for k, v in pairs(FurnitureInfo) do
        if v.furniture_type == ftype then
            amount = amount + self:getAllItemCountByName(k)
        end
    end

    return amount
end

-- 获取家具信息
function HomeMgr:getFurnitureInfo(name)
    return FurnitureInfo[name]
end

function HomeMgr:getFurnitureNameByPos(pos)
    local item = self:getFurnitureByPos(pos)
    if item then
        return item.name
    end
end

function HomeMgr:getFurnitureByPos(pos)
    local item = InventoryMgr:getItemByPos(pos)
    if not item then
        item = StoreMgr:getFurnitureByPos(pos)
    end

    return item
end

-- 获取家具数量(已经去除了预览的数据)
function HomeMgr:getItemCountByName(name)
    local bagItems = InventoryMgr:getItemByName(name)
    local storeItems = StoreMgr:getFurnitureByName(name)
    local count = 0

    for i = 1, #bagItems do
        count = count + (bagItems[i].amount - (bagItems[i].placed_amount or 0))
    end

    for i = 1, #storeItems do
        count = count + (storeItems[i].amount - (storeItems[i].placed_amount or 0))
    end

    -- 去除预览的数据
    for _, v in pairs(self.opers) do
        if 0 == v:getId() and v:queryBasic("name") == name then
            count = count - 1
        end
    end

    return count
end

-- 获取家具的所有数量(含预览及加载)
function HomeMgr:getAllItemCountByName(name)
    local bagItems = InventoryMgr:getItemByName(name)
    local storeItems = StoreMgr:getFurnitureByName(name, true)
    local count = 0
    for i = 1, #bagItems do
        count = count + bagItems[i].amount
    end

    for i = 1, #storeItems do
        count = count + storeItems[i].amount
    end
    return count
end

-- 获取家具列表和背包中的所有家具（去掉预览）
function HomeMgr:getFurnituresByName(name)
    local allFurnitures = {}
    local furnitures = {}
    local bagItems = InventoryMgr:getItemByName(name)
    local storeItems = StoreMgr:getFurnitureByName(name)

    for i = 1, #bagItems do
        local item = bagItems[i]
        item.realAmount = item.amount - item.placed_amount
        table.insert(allFurnitures, item)
    end

    for i = 1, #storeItems do
        local item = storeItems[i]
        item.realAmount = item.amount - item.placed_amount
        table.insert(allFurnitures, item)
    end

    self:sortFurniture(allFurnitures)
    for k, v in pairs(self.opers) do
        if v:queryBasic("name") == name and 0 == v:getId() then
            if v:queryBasicInt("item_pos") > 0 then
                -- 当前预览中的该家具是有pos的，即知道其是在背包/装备列表的哪一个位置
                for i = 1, #allFurnitures do
                    if allFurnitures[i].pos == v:queryBasicInt("item_pos") then
                        allFurnitures[i].realAmount = allFurnitures[i].realAmount - 1
                    end
                end
            else
                -- 当前预览的该家具是凭空预览的，其没有从属
                -- 但事实上其是占用（背包/装备列表）一个位置的，找到这个位置
                local hasFound = false
                for i = 1, #allFurnitures do
                    if allFurnitures[i].realAmount > 0 and (not hasFound) then
                        allFurnitures[i].realAmount = allFurnitures[i].realAmount - 1
                        hasFound = true
                    end
                end
            end
        end
    end

    for i = 1, #allFurnitures do
        local furniture = allFurnitures[i]
        if furniture.realAmount > 0 then
            table.insert(furnitures, furniture)
        end
    end

    self:sortFurniture(furnitures)
    return furnitures
end

-- 清除所有家具
function HomeMgr:clearFurnitures(list, isTake, notClearPet)
    for _, v in pairs(self[list]) do
        if v then
            if isTake then
                self:takeFurniture(v)
            end
            v:cleanup(notClearPet)
        end
    end
    self[list] = {}
end

-- 根据家具类型获取排放位置
function HomeMgr:getPutLayerByFurniture(furniture)
    local furnitureType = furniture:queryBasic("furniture_type")
    return self:getPutLayerByFurnitureType(furnitureType)
end

function HomeMgr:getPutLayerByFurnitureType(furnitureType)
    if string.match(furnitureType, CHS[2000304]) or string.match(furnitureType, CHS[2000305]) or string.match(furnitureType, CHS[2000306])
        or string.match(furnitureType, CHS[2000307]) or string.match(furnitureType, CHS[2000308]) or string.match(furnitureType, CHS[2000309])
        or string.match(furnitureType, CHS[2000310]) then
        return "floor"
    elseif string.match(furnitureType, CHS[2000311]) then
        return "wall"
    elseif string.match(furnitureType, CHS[2000312]) then
        return "carpet"
    end

    return furnitureType
end

-- 检查指定区域是否可用
function HomeMgr:isCanPutFurniture(furniture, x, y)
    if not furniture or not GameMgr.scene.map then return end

    local layer = furniture:getLayer()
    local putLayer = self:getPutLayerByFurniture(furniture)
    x, y = gf:convertToMapSpace(x or furniture.curX, y or furniture.curY)
    if 'wall' == putLayer then
        putLayer = GameMgr.scene.map:isMarkable('leftWall', x, y) and 'rightWall' or 'leftWall'
        --putLayer = "leftWall"
    end
    local size = layer:getLayerSize()
    local beginX, beginY = math.floor(x - size.width / 2 + 0.5), math.floor(y - size.height / 2 + 0.5)
    local tileValue
    for i = 0, size.width - 1 do
        for j = 0, size.height - 1 do
            if furniture:isFlip() then
                tileValue = layer:getTileGIDAt(cc.p(size.width - 1 - i, j))
            else
                tileValue = layer:getTileGIDAt(cc.p(i, j))
            end

            if tileValue ~= 0 and GameMgr.scene.map:isMarkable(putLayer, beginX + i, beginY + j) then
                return
            end
        end
    end

    if 'rightWall' == putLayer or 'leftWall' == putLayer then
        if furniture:getType() == "FurnitureEx" then
            return ('rightWall' == putLayer and furniture:getDir() == 7) or ('leftWall' == putLayer and furniture:getDir() == 5)
        else
            return ('rightWall' == putLayer and furniture:isFlip()) or ('leftWall' == putLayer and not furniture:isFlip())
        end
    else
        return true
    end
end

-- 摆放家具
function HomeMgr:putFurniture(furniture, x, y, notCheckPuttable)
    if not furniture or not GameMgr.scene.map then return end

    local layer = furniture:getLayer()
    if not layer then return end

    local size = layer:getLayerSize()
    local contentSize = layer:getContentSize()
    local rawX, rawY = x, y
    x, y = gf:convertToMapSpace(x or furniture.curX, y or furniture.curY)

    if not notCheckPuttable then
    local putLayer = self:getPutLayerByFurniture(furniture)
    if 'wall' == putLayer then
        putLayer = GameMgr.scene.map:isMarkable('leftWall', x, y) and 'rightWall' or 'leftWall'
    end

    local beginX, beginY = math.floor(x - size.width / 2 + 0.5), math.floor(y - size.height / 2 + 0.5)
    local tileValue
    local t = {}
    for i = 0, size.width - 1 do
        for j = 0, size.height - 1 do
            if furniture:isFlip() then
                tileValue = layer:getTileGIDAt(cc.p(size.width - 1 - i, j))
            else
                tileValue = layer:getTileGIDAt(cc.p(i, j))
            end
            if tileValue ~= 0 then
                if GameMgr.scene.map:isMarkable(putLayer, beginX + i, beginY + j) then
                    -- 还原已经设置的数据
                    for k = 1, #t do
                        GameMgr.scene.map:unMarkLayer(putLayer, t[k].x, t[k].y)
                        if 'floor' == putLayer then
                            -- 更新障碍信息
                            GameMgr.scene.map:unMarkLayer('obstacleLayer', t[k].x, t[k].y)
                        end
                    end
                    return
                end
                GameMgr.scene.map:markLayer(putLayer, beginX + i, beginY + j, 0x7FFFFFFF)
                if 'floor' == putLayer then
                    -- 更新障碍信息
                    assert(not GameMgr.scene.map:isMarkable('obstacleLayer', beginX + i, beginY + j), string.format("tile(%d, %d) is obstacle", beginX + i, beginY + j))
                    GameMgr.scene.map:markLayer('obstacleLayer', beginX + i, beginY + j, 0x7FFFFFFF)
                end
                table.insert(t, cc.p(beginX + i, beginY + j))
            end
        end
    end

    if 'floor' == putLayer then GameMgr.scene.map:updateObstacle() end
    end

    -- 家具摆放成功后，更新半透明状态
    furniture:updateShelter(x, y)

    -- 记录摆放的家具信息
    self.furnitures[furniture:getId()] = furniture

    -- 由于顶号时，可能由于没有家具，所以受到家具回头检测下居所生产信息
    if HomeChildMgr.birthAnimateData and HomeChildMgr.birthAnimateData.furniture_pos == furniture:getId() then
        HomeChildMgr:MSG_CHILD_BIRTH_ANIMATE(HomeChildMgr.birthAnimateData)
    end

    EventDispatcher:dispatchEvent("PUT_FURNITURE")

    return true
end

-- 收回家具
function HomeMgr:takeFurniture(furniture, x, y)
    if not furniture or not GameMgr.scene.map then return end

    local layer = furniture:getLayer()
    if not layer then return end

    local size = layer:getLayerSize()
    local contentSize = layer:getContentSize()
    x, y = gf:convertToMapSpace(x or furniture.curX, y or furniture.curY)
    local putLayer = self:getPutLayerByFurniture(furniture)
    if 'wall' == putLayer then
        putLayer = furniture:isFlip() and 'rightWall' or 'leftWall'
    end

    local beginX, beginY = math.floor(x - size.width / 2 + 0.5), math.floor(y - size.height / 2 + 0.5)
    local tileValue
    for i = 0, size.width - 1 do
        for j = 0, size.height - 1 do
            if furniture:isFlip() then
                tileValue = layer:getTileGIDAt(cc.p(size.width - 1 - i, j))
            else
                tileValue = layer:getTileGIDAt(cc.p(i, j))
            end
            if tileValue ~= 0 then
                if GameMgr.scene.map:isMarkable(putLayer, beginX + i, beginY + j) then
                    GameMgr.scene.map:unMarkLayer(putLayer, beginX + i, beginY + j)
                    if 'floor' == putLayer then
                        -- 更新障碍信息
                        GameMgr.scene.map:unMarkLayer('obstacleLayer', beginX + i, beginY + j)
                    end
                end
            end
        end
    end

    if 'floor' == putLayer then GameMgr.scene.map:updateObstacle() end

    HomeMgr:clearOnePetById(furniture:getId())

    -- 家具摆放收起后，更新正常颜色状态
    furniture:setShelter(false)

    -- 家具收起后尝试移除默认特效
    furniture:removeDefaultMagicOnFurniture()

    -- 功能型家具收起后尝试移除特效
    furniture:removeMagicOnFuncFurniture()

    -- 记录摆放的家具信息
    self.furnitures[furniture:getId()] = nil
    return true
end

-- 尝试提取家具
function HomeMgr:tryDragFurniture(furnitureId)
    gf:CmdToServer('CMD_HOUSE_DRAG_FURNITURE', {furniture_pos = furnitureId})
end

-- 根据道具id获取道具类型
function HomeMgr:getFurnitureInfoById(id)
    if not self.id2info then return end
    return self.id2info[id]
end

-- cookie生成器，用于预览操作
function HomeMgr:tryGenId()
    self.fid = self.fid or 0
    self.fid = self.fid + 1
    return self.fid
end

-- 预览摆放
-- pos：道具位置，无则表示无道具预览，摆放时需要购买
function HomeMgr:previewPut(itemName, pos)
    local info = FurnitureInfo[itemName]
    local data = {
        icon = info.icon,
        furniture_type = info.furniture_type,
        name = itemName,
        item_pos = pos,
        dirs = info.dirs,
        dir = self:getDirByFlip(info)
    }

    self:doPut(data, true)
end

-- 尝试摆放家具(oper=true时为预览摆放)
function HomeMgr:doPut(data, oper, notCheckPuttable)
    local item

    if data.dirs and data.dirs > 1 then
        item = FurnitureEx.new()
    else
        item = Furniture.new()
    end

    item:absorbBasicFields({
        icon = data.icon,
        furniture_type = data.furniture_type,
        id = data.furniture_pos,
        item_pos = data.item_pos,
        durability = data.durability,
        name = data.name,
        dir = data.dir
    })

    item:setVisible(true)
    item:action(oper, 1 == data.flip)

    local centerX = Const.WINSIZE.width / 2
    local centerY = Const.WINSIZE.height / 2

    item:onEnterScene(0, 0)

    local pos
    local x, y = data.x, data.y
    if not x or not y then
        pos = gf:getCharMiddleLayer():convertToNodeSpace(cc.p(centerX, centerY))
    else
        x, y = self:calcPosition(data.bx, data.by, data.x, data.y)
        pos = cc.p(x, y)
    end

    item:setPos(pos.x, pos.y)

    if not notCheckPuttable then
    item:checkPutable()
    end

    if not oper then
        if not self:putFurniture(item, nil, nil, notCheckPuttable) then
            item:cleanup()
            assert(false, string.format("bad pos(%f, %f) for furniture(%d)", pos.x, pos.y, data.furniture_pos))
            return
        end
    else
        local cookie = self:tryGenId()
        self.opers[cookie] = item
        item.cookie = cookie
    end

    self:updateBowlAfterPalceFurn(data.furniture_pos)

    -- 家具(功能型家具单独加)摆放成功后尝试添加默认特效
    if not oper then
        item:addDefaultMagicOnFurniture()
        item:createMagicOnFuncFurniture()
    end

    return item
end

function HomeMgr:convertToOffset(x, y, bx, by)
    local cx, cy = gf:convertToClientSpace(bx, by)
    return x - cx, y - cy
end

function HomeMgr:calcPosition(bx, by, ox, oy)
    local x, y = gf:convertToClientSpace(bx, by)
    return x + ox, y + oy
end

-- 通知服务器摆放操作
function HomeMgr:cmdPut(furniture)
    if not furniture then return end
    local bx, by = gf:convertToMapSpace(furniture.curX, furniture.curY)
    local ox, oy = self:convertToOffset(furniture.curX, furniture.curY, bx, by)

    if 0 == furniture:getId() then
        local itemPos = furniture:queryBasicInt("item_pos")
        if 0 == itemPos then
            -- 预览状态
            local itemName = furniture:queryBasic("name")
            local items = StoreMgr:getFurnitureByName(itemName)
            if not items or #items <= 0 then
                items = InventoryMgr:getItemByName(itemName)
            end

            if not items or #items <= 0 then
                local furnitureInfo = self:getPurchaseCost(itemName)
                if furnitureInfo and furnitureInfo <= 0 then
                    if not LuBanFur[itemName] then
                    gf:ShowSmallTips(CHS[7100035])
                else
                        gf:ShowSmallTips(CHS[4200450])
                    end
                else
                    gf:confirm(string.format(CHS[2000313], itemName), function()
                        if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                            gf:ShowSmallTips(CHS[5410117])
                            return
                        end

                        DlgMgr:sendMsg("HomePuttingDlg", "setCurOperCookie", furniture.cookie)
                        DlgMgr:openDlgEx("FurnitureBuyDlg", itemName)
                    end)
                end
                return
            else
                items = self:sortFurniture(items)
                itemPos = items[1].pos
            end
        end

        local item = InventoryMgr:getItemByPos(itemPos)
        if item and not InventoryMgr:isTimeLimitedItem(item) and not InventoryMgr:isLimitedItemForever(item) then
            if string.isNilOrEmpty(furniture.cookie) then
                -- WDSY-36571 报错，未找到 furniture.cookie 为 nil 的原因，所以在此记录日志，方便核查问题
                if not self.ftpUpLoadLog then
                    gf:ftpUploadEx(string.format("HomeMgr cmdPut furniture with nil cookie, isInbackground:%s\n%s", tostring(GameMgr:isInBackground()), debug.traceback()))
                    self.ftpUpLoadLog = true
                end

                return
            end

            gf:confirm(string.format(CHS[2000314], furniture:queryBasic("name")), function()
                if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                    gf:ShowSmallTips(CHS[5410117])
                    return
                end

                gf:CmdToServer('CMD_HOUSE_PLACE_FURNITURE', { furniture_pos = itemPos, x = ox, y = oy, flip = furniture:getDirToServer(), bx = bx, by = by, cookie = furniture.cookie })
            end)
        else
            gf:CmdToServer('CMD_HOUSE_PLACE_FURNITURE', { furniture_pos = itemPos, x = ox, y = oy, flip = furniture:getDirToServer(), bx = bx, by = by, cookie = furniture.cookie })
        end
    else
        gf:CmdToServer('CMD_HOUSE_MOVE_FURNITURE', { furniture_pos = furniture:getId(), x = ox, y = oy, flip = furniture:getDirToServer(), bx = bx, by = by, cookie = furniture.cookie })
    end
end

function HomeMgr:printObstance(data, width, path)
    local t = {}
    local st = {}
    for i = 1, #data, width do
        st = {}
        for j = 1, width do
            table.insert(st, data[j + i])
        end
        table.insert(t, table.concat(st))
    end
    gfSaveFile(table.concat(t, '\n'), path)
end

function HomeMgr:updateObstacle(data)
    local mapSize = MapMgr:getMapSize()
    local width = mapSize.width
    local x, y, tileValue
    for i = 0, #data - 1 do
        -- 更新障碍信息
        x, y = (i % width), math.floor(i / width)
        tileValue = data[i + 1]
        if tileValue and tileValue ~= 0 then
            if tileValue == 1 or tileValue == 3 then
                if not GameMgr.scene.map:isMarkable('floor', x, y) then
                    GameMgr.scene.map:markLayer("floor", x, y, 0x7FFFFFFF)
                end
                if not GameMgr.scene.map:isMarkable('obstacleLayer', x, y) then
                    GameMgr.scene.map:markLayer('obstacleLayer', x, y, 0x7FFFFFFF)
                end
            end
            if tileValue == 2 or tileValue == 3 then
                if not GameMgr.scene.map:isMarkable('carpet', x, y) then
                    GameMgr.scene.map:markLayer("carpet", x, y, 0x7FFFFFFF)
                end
                if not GameMgr.scene.map:isMarkable('leftWall', x, y) then
                    GameMgr.scene.map:markLayer("leftWall", x, y, 0x7FFFFFFF)
                end
                if not GameMgr.scene.map:isMarkable('rightWall', x, y) then
                    GameMgr.scene.map:markLayer("rightWall", x, y, 0x7FFFFFFF)
                end
            end
        end
    end
    GameMgr.scene.map:updateObstacle()
end

-- 保存tmx信息到文件中
function HomeMgr:saveTmxLayer(path, layerName, x, o)
    x = x or '1'
    o = o or '0'
    if GameMgr.scene and GameMgr.scene.map then
        local layer = GameMgr.scene.map[layerName]
        if not layer then return end

        local layerSize = layer:getLayerSize()
        local all = {}
        for j = 0, layerSize.height - 1 do
            local col = {}
            for i = 0, layerSize.width - 1 do
                table.insert(col, layer:getTileGIDAt(cc.p(i, j)) ~= 0 and x or o)
            end
            table.insert(all, table.concat(col))
        end

        gfSaveFile(table.concat(all, '\n'), path)
    end
end

-- 根据家具类型获取家具列表
function HomeMgr:getFurnituresByType(ftype)
    if not self.type2info then return end
    return self.type2info[ftype]
end

-- 显示居所信息    现在！只能！通过gid请求，因为居所右侧标签页直接和个人空间联系，个人空间需要gid
function HomeMgr:showHomeData(gid, queryType)
    -- 请求个人空间的装饰信息

    local distName = BlogMgr:getDistByGid(gid) or GameMgr:getDistName()
    gf:CmdToServer("CMD_BLOG_DECORATION_LIST", {user_gid = gid, user_dist = distName})

    gf:CmdToServer('CMD_HOUSE_SHOW_DATA', { name = gid, queryType = queryType or HOUSE_QUERY_TYPE.QUERY_BY_CHAR_GID })
end

function HomeMgr:requestBedRoom()
    gf:CmdToServer("CMD_REQUEST_FURNITURE_APPLY_DATA", {type = "bedroom"})
end

function HomeMgr:requestData(dlgName)
    local houseId = self:getHouseId()
    gf:CmdToServer("CMD_REQUEST_HOUSE_DATA", { dlg = dlgName or "" })
end

function HomeMgr:requestSpecialFurnitures()
    gf:CmdToServer("CMD_HOUSE_FUNCTION_FURNITURE_LIST")
end

function HomeMgr:getFurnitureDesc(name)
    local itemInfo = self:getFurnitureInfo(name)
    return itemInfo.descript
end

function HomeMgr:getFurnitureSpecialDesc(name)
    local itemInfo = self:getFurnitureInfo(name)
    if not itemInfo then
        return
    end

    return itemInfo.special_func
end

function HomeMgr:getFurnitureResource(name)
    local itemInfo = self:getFurnitureInfo(name)
    if not itemInfo then
        return
    end

    return itemInfo.rescourse
end

function HomeMgr:getFurnitureIcon(name)
    local itemInfo = self:getFurnitureInfo(name)
    return itemInfo and itemInfo.icon
end

function HomeMgr:getFurnitureLevel(name)
    local itemInfo = self:getFurnitureInfo(name)
    return itemInfo.level or 1
end

function HomeMgr:getPurchaseCost(name)
    local itemInfo = self:getFurnitureInfo(name)
    if not itemInfo then
        return
    end

    return itemInfo.purchase_cost or 0
end

function HomeMgr:getPurchaseType(name)
    local itemInfo = self:getFurnitureInfo(name)
    return itemInfo.purchase_type or 0
end

-- 获取家具出售价格（单位：文钱）
function HomeMgr:getFurnitureSellPrice(name)
    local itemInfo = self:getFurnitureInfo(name)
    if itemInfo then
        return itemInfo.sell_price or 0
    end
end

-- 获取某家具的最大耐久度
function HomeMgr:getMaxDur(name)
    local itemInfo = self:getFurnitureInfo(name)
    if itemInfo then
        return itemInfo.max_dur
    end
end

function HomeMgr:getFurnitureCapacity(name)
    local itemInfo = self:getFurnitureInfo(name)
    if itemInfo then
        return itemInfo.max_capacity
    end
end

function HomeMgr:getFurnitureComfort(name)
    local itemInfo = self:getFurnitureInfo(name)
    if itemInfo then
        return itemInfo.comfort or 0
    end
end

function HomeMgr:isSpecialFurniture(name)
    local itemInfo = self:getFurnitureInfo(name)
    if itemInfo.max_dur then
        return true
    end
end

-- 获取对应类型的已摆放家具 （当前地图内的）
function HomeMgr:getSpecialFurnitureByType(type)
    local furnitures = self.furnitures
    local res = {}
    for k, v in pairs(furnitures) do
        local furnitureType = v:queryBasic("furniture_type")
        local name = v:queryBasic("name")
        if self:isSpecialFurniture(name) and (type == furnitureType or type == CHS[4100075]) then
            table.insert(res, v)
        end
    end

    -- 按照icon排序
    table.sort(res, function(l, r)
        local lName = l:queryBasic("name")
        local rName = r:queryBasic("name")
        -- 等级
        local lLevel = HomeMgr:getFurnitureLevel(lName)
        local rLevel = HomeMgr:getFurnitureLevel(rName)
        if lLevel < rLevel then return true end
        if lLevel > rLevel then return false end

        -- 舒适度
        local lComfort = HomeMgr:getFurnitureComfort(lName)
        local rComfort = HomeMgr:getFurnitureComfort(rName)
        if lComfort < rComfort then return true end
        if lComfort > rComfort then return false end

        -- 耐久度
        local lDur = l:queryBasicInt("durability")
        local rDur = r:queryBasicInt("durability")
        if lDur < rDur then return true end
        if lDur > rDur then return false end

        -- 编号
        if l:queryInt("icon") < r:queryInt("icon") then return true end
        if l:queryInt("icon") > r:queryInt("icon") then return false end
    end)

    return res
end

-- 获取对应类型的已摆放家具（居所内所有，有服务器单独发消息通知）
function HomeMgr:getAllSpecialFurnitureByType(type)
    local furnitures = self.specialFurnitureList or {}
    local res = {}
    for i = 1, #furnitures do
        local furniture = furnitures[i]
        local furnitureId = furniture.furniture_id
        local furnitureInfo = self:getFurnitureInfoById(furnitureId)
        furniture.name = furnitureInfo.name
        furniture.furniture_type = furnitureInfo.furniture_type
        furniture.icon = furnitureInfo.icon
        furniture.id = furniture.furniture_pos
        furniture.max_dur = furnitureInfo.max_dur
        furniture.level = furnitureInfo.level

        if furniture.furniture_type == type or type == CHS[4100075] then
            table.insert(res, furniture)
        end
    end
    -- 按照icon排序
    table.sort(res, function(l, r)
        -- 耐久度差值
        local lDurC = l.max_dur - l.durability
        local rDurC = r.max_dur - r.durability
        if lDurC > rDurC then return true end
        if lDurC < rDurC then return false end

        local lIcon = l.icon
        local rIcon = r.icon
        if lIcon < rIcon then return true end
        if lIcon > rIcon then return false end
    end)

    return res
end

-- 获取某种储物类型居所的储物室最大格子数
function HomeMgr:getMaxGridByHomeStoreType(type)
    if not type then
        type = HomeMgr:getHomeStoreType()
    end

    if type == HOME_STORE_TYPE.SMALL then
        return 10
    elseif type == HOME_STORE_TYPE.MIDDLE then
        return 25
    elseif type == HOME_STORE_TYPE.BIG then
        return 50
    else
        return 0
    end
end

-- 获取储物类型
function HomeMgr:getHomeStoreType()
    if self.myData then
        return self.myData.storeType or 0
    else
        return 0
    end
end

-- 获取已摆放的床类家具
function HomeMgr:getBedFurniture()
    -- 目前指的是可供休息（有耐久度）的床类家具
    local furnitures = self:getSpecialFurnitureByType(CHS[7002320])
    return furnitures
end

-- 是否是床类家具
function HomeMgr:isBedFurniture(char)
    -- 目前指的是可供休息（有耐久度）的床类家具
    local furnitureType = char:queryBasic("furniture_type")
    local id = char:getId()
    local name = char:queryBasic("name")
    if furnitureType == CHS[7002320] and self:isSpecialFurniture(name) and self.furnitures and self.furnitures[id] then
        return true
    end
end

-- 是否是可点击弹出悬浮框的家具
function HomeMgr:isCanClickFurniture(obOrName)
    local name
    if type(obOrName) == "string" then
        name = obOrName
    else
        local id = obOrName:getId()
        if not self.furnitures or not self.furnitures[id] then return end
        name = obOrName:queryBasic("name")
    end

    local furnitureType = HomeMgr:getFurnitureInfo(name).furniture_type

    local furnInfo = self:getFurnitureInfo(name)
    if (furnitureType == CHS[7002320] and self:isSpecialFurniture(name))
        or furnitureType == CHS[7002321] -- 房屋-功能
        or furnitureType == CHS[5410072] -- 前庭-功能
        or furnitureType == CHS[5400253] -- 后院-功能
        or furnInfo.canTouch then
        return true
    end
end

-- 获取已摆放的可点击的家具
function HomeMgr:getCanClickFurniture()
    local furnitures = {}
    for k, v in pairs(self.furnitures) do
        if self:isCanClickFurniture(v) then
            table.insert(furnitures, v)
        end
    end

    return furnitures
end

-- 获取当前类型居所的最大舒适度
function HomeMgr:getMaxComfort(homeType)
    return MAX_COMFORT[homeType or self:getHomeType()]
end

-- 获取当前类型居所的最大清洁度
function HomeMgr:getMaxClean()
    return MAX_CLEAN
end

-- 获取最大协助清扫次数
function HomeMgr:getMaxAssistCleanTimes()
    return MAX_ASSIST_CLEAN_TIMES
end

-- 获取当前居所的类型
function HomeMgr:getHomeType()
    if self.myData then
        return self.myData.houseType or HOME_TYPE.xiaoshe
    else
        return HOME_TYPE.xiaoshe
    end
end

function HomeMgr:getHomeTypeCHS(homeType)
    return HOME_TYPES[homeType or self:getHomeType()]
end

-- 获取一定耐久度下修理的消耗
function HomeMgr:getFixCost(nowDur, maxDur)
    return (maxDur - nowDur) * 50000
end

-- 获取一定清洁度下打扫的消耗
function HomeMgr:getCleanCost(nowClean, maxClean)
    return (maxClean - nowClean) * 10000
end

-- 获取初级/中级/高级卧室的每日最大休息次数
function HomeMgr:getMaxSleepTimes(bedroomType)
    if not bedroomType then
        bedroomType = self:getBedroomType()
    end

    return MAX_SLEEP_TIMES[bedroomType]
end

-- 获取某家具的小类别（例如功能、桌椅、摆设等）
function HomeMgr:getFurnitureTypeByName(name)
    local info = FurnitureInfo[name]
    if not info then
        return
    end

    local furnitureType = info.furniture_type
    if furnitureType then
        local firstClass, secondClass = string.match(furnitureType, "(.*)-(.*)")
        return secondClass
    end
end

-- 获取某家具的大类别（前庭、房屋、后院）
function HomeMgr:getFurnitureMainTypeByName(name)
    local info = FurnitureInfo[name]
    if not info then
        return
    end

    local furnitureType = info.furniture_type
    if furnitureType then
        local firstClass, secondClass = string.match(furnitureType, "(.*)-(.*)")
        return firstClass
    end
end

function HomeMgr:getFurnitureType(name)
    local info = FurnitureInfo[name]
    if not info then
        return
    end

    return info.furniture_type
end

-- 获取自己居所的舒适度
function HomeMgr:getComfort()
    if self.myData then
        return self.myData.comfort or 0
    else
        return 0
    end
end

-- 获取自己居所的清洁度
function HomeMgr:getClean()
    if self.myData then
        return self.myData.cleanliness or 0
    else
        return 0
    end
end

-- 获取自己居所的清洁度消耗
function HomeMgr:getCleanCostTime()
    if self.myData then
        return self.myData.cleanCostTime or 0
    else
        return 0
    end
end

function HomeMgr:getHouseId()
    return self.house_id or 0
end

function HomeMgr:getBedroomSleepTimes()
    return self.curSleepTimes or 0
end

function HomeMgr:getBedroomType()
    return self.bedroomType or BEDROOM_TYPE.SMALL
end

function HomeMgr:isFurniture(name)
    if FurnitureInfo[name] then
        return true
    else
        return false
    end
end

function HomeMgr:isFunitureCanGetCashBySell(furniture)
    local pos = furniture.pos
    if not pos then return end
    local useInventory = InventoryMgr:isBagItemByPos(pos)
    local isForeverLimit = InventoryMgr:isLimitedItemForever(furniture)
    if useInventory and (not isForeverLimit) then
        return true
    end
end

-- 根据名字及家具对应地图的基准点获取家具
function HomeMgr:getFurnByNameAndBasicPos(name, pos)
    local furnitures = HomeMgr:getFurnitures()
    for _, furn in pairs(furnitures) do
        local x, y = furn:getBasicPointInMap()
        if furn:getName() == name and pos.x == x and pos.y == y then
            return furn
        end
    end
end

function HomeMgr:talkToFurniture(data)
    local furnitures = HomeMgr:getFurnitures()
    local id = data.npcId
    local furniture = furnitures[id]
    local name = data.npc
    local map = data.map
    if not furniture then
        if map and MapMgr:isInHouse(map) and self:getFurnitureInfo(name) then
            -- 居所地图，且是名字能在配表中找到对应家具
            gf:ShowSmallTips(CHS[5410105])
            ChatMgr:sendMiscMsg(CHS[5410105])
            AutoWalkMgr:setTalkToNpcIsEnd(true)
            return true
        end

        return
    end

    -- 自动寻路家具的目的坐标不是放置家具的位置而是家具脚底准点对应地图的位置
    local x, y = furniture:getBasicPointInMap()
    if  x ~= data.rawX or y ~= data.rawY then
        -- 对应家具位置已发生改变，无法进行此操作。
        gf:ShowSmallTips(CHS[4200418])
        ChatMgr:sendMiscMsg(CHS[4200418])
        AutoWalkMgr:setTalkToNpcIsEnd(true)
        return true
    end

    -- 寻路到家具，有回调，先执行回调
    if data.destCallback and data.destCallback.func
        and type(data.destCallback.func) == 'function' then
            data.destCallback.func(data.destCallback.para)
    end

    local rawX, rawY = gf:convertToMapSpace(furniture.curX, furniture.curY)
    furniture:removeFocusMagic()
    local furnitureType = furniture:queryBasic("furniture_type")
    if furnitureType == CHS[7002320] then
        -- 床
        AutoWalkMgr:setTalkToNpcIsEnd(true)
        if not self.bedRoomSleepInfo then return true end

        local count = self.bedRoomSleepInfo[1]
        local type = self.bedRoomSleepInfo[2]
        if type == 2 then
            -- 行夫妻之礼
            if not HomeMgr:isCoupleStore() then
                gf:ShowSmallTips(CHS[5450479])
                return true
            elseif not TeamMgr:coupleIsInTeam() or TeamMgr:getTeamNum() ~= 2 then
                gf:ShowSmallTips(CHS[5450480])
                return true
            end

            DlgMgr:openDlgEx("KidsCreateDlg", {id, rawX, rawY})
            return true
        elseif count == 2 then
            -- 双人休息
            if not HomeMgr:isCoupleStore() then
                gf:ShowSmallTips(CHS[5410154])
                return true
            elseif not TeamMgr:coupleIsInTeam() or TeamMgr:getTeamNum() ~= 2 then
                gf:ShowSmallTips(CHS[5410153])
                return true
            end
        end

        DlgMgr:openDlgEx("HomeBedroomDlg", {id, rawX, rawY, count})
    elseif furnitureType == CHS[5410072] then
        if name == CHS[5400111] then
            -- 招财树
            self:cmdHouseUseFurniture(id, "zhaocai", "0")
            self.chooseMoneyTreeId = id
        elseif name == CHS[7190000] then
            -- 金丝鸟笼
            HomeMgr:cmdHouseUseFurniture(id, "practice_buff", "data", "")
        elseif furniture:queryBasic("name") == CHS[2500061] then
            DlgMgr:openDlgEx("WoodSoldierDlg", { id, rawX, rawY})
        elseif name == CHS[5400255] then
            -- 西域飞毯
            gf:CmdToServer("CMD_HOUSE_OPER_XYFT", {furniture_pos = id})
        elseif name == CHS[4010415] then
            -- 宠物小屋
            HomeMgr:cmdHouseUseFurniture(id, "pet_store", "data")
        elseif name == CHS[4010414] then    -- 天地灵石
            AutoWalkMgr:setTalkToNpcIsEnd(true)
            if not self.childLSType then return end

            if self.childLSType == CHS[4010393] then
                gf:CmdToServer("CMD_HOUSE_TDLS_INJECT_ENERGY", {pos = id})
            elseif self.childLSType == CHS[4010432] then
                gf:CmdToServer("CMD_HOUSE_TDLS_CHILD_BIRTH", {furniture_id = id})
            elseif self.childLSType == CHS[4010430] then
                gf:CmdToServer("CMD_HOUSE_TDLS_VIEW", {furniture_id = id})
            end


        else
            -- 宠物食盆
            HomeMgr:setCurChooseBowlId(id)
            HomeMgr:cmdHouseUseFurniture(id, "feed_pet", "feed_info")
        end

        AutoWalkMgr:setTalkToNpcIsEnd(true)
    elseif furnitureType == CHS[7002321] then
        if furniture:queryBasic("name") == CHS[4100675] or furniture:queryBasic("name") == CHS[4100676] then
            HomeMgr:cmdHouseUseFurniture(furniture:queryBasicInt("id"), "artifact_practice", "artifact_practice_info", "")
        elseif furniture:queryBasic("name") == CHS[4100681] or furniture:queryBasic("name") == CHS[4100682] then
            HomeMgr:queryHourPlayerPractice("use", furniture:queryBasicInt("id"))
        elseif furniture:queryBasic("name") == CHS[2000386] or furniture:queryBasic("name") == CHS[2000387] then
            DlgMgr:openDlgEx("HomeCookingDlg", { id, rawX, rawY})
        elseif furniture:queryBasic("name") == CHS[7100000] or furniture:queryBasic("name") == CHS[7100001] then
            -- 鲁班台
            DlgMgr:openDlgEx("FurnitureMakeDlg", { id, rawX, rawY})
        elseif name == CHS[7190001] or name == CHS[7190002] then
            -- 白玉观音像,七宝如意
            HomeMgr:cmdHouseUseFurniture(id, "practice_buff", "data", "")
        elseif name == CHS[4010428] then    -- 摇篮
            gf:CmdToServer("CMD_HOUSE_CRADLE_TALK", {pos = id})
            --furniture:tryToAddMagicOnFuncFurniture()
        end

        AutoWalkMgr:setTalkToNpcIsEnd(true)
    elseif furnitureType == CHS[5400253] then
        if name == CHS[5400256] then
            -- 西域飞毯
            gf:CmdToServer("CMD_HOUSE_OPER_XYFT", {furniture_pos = id})
        end

        AutoWalkMgr:setTalkToNpcIsEnd(true)
    elseif furnitureType == CHS[5450218] then  -- 房屋-墙饰
        if name == CHS[5450219] then
            -- 生死状
            self.curRequestShengSidataId = id
            gf:CmdToServer("CMD_LD_MY_HISTORY_PAGE", {pos = id, last_time = 0, needGenaral = 1})
        end

        AutoWalkMgr:setTalkToNpcIsEnd(true)
    end

    return true
end

-- 生死状家具的基础数据
function HomeMgr:MSG_LD_GENERAL_INFO(data)
    DlgMgr:openDlgEx("ShengSiMySelfHistoryDlg", self.curRequestShengSidataId)
end

-- 是否是夫妻储物室
function HomeMgr:isCoupleStore()
    local class = Me:queryBasicInt("house/house_class")
    if class > 1 then
        return true
    end
end

-- 在夫妻居所中是否是丈夫（true:丈夫，false:妻子）
function HomeMgr:isHusband()
    local gender = tonumber(gf:getGenderByIcon(Me:queryBasicInt("icon")))
    if gender == GENDER_TYPE.MALE then
        return true
    elseif gender == GENDER_TYPE.FEMALE then
        return false
    end
end

-- 根据居所类型获取某NPC所在地图
function HomeMgr:getMapNameByNpcAndHomeType(npcName, homeTypeCHS)
    for i = 1, #HOME_PLACE do
        local mapName = homeTypeCHS .. "-" .. HOME_PLACE[i]
        local mapId = MapMgr:getMapByName(mapName)
        local npcs = MapMgr:getNpcs(mapId)
        for i = 1, #npcs do
            local npc = npcs[i]
            local name = npc.name
            if string.match(name, npcName) then
                return mapName
            end
        end
    end
end

-- 随机获取某家具名对应的家具对象
function HomeMgr:getFurnObjById(id)


    for _, v in pairs(self.furnitures) do
        if v:queryBasicInt("id") == id then
            return v
        end
    end

end

-- 随机获取某家具名对应的家具对象
function HomeMgr:getFurnObjByName(name)
    local info = self:getFurnitureInfo(name)
    if not info then
        return
    end

    local furns = {}
    for _, v in pairs(self.furnitures) do
        if v:queryBasicInt("icon") == info.icon then
            table.insert(furns, v)
        end
    end

    -- 获取可到达的距离最近的家具
    local minLen = -1
    local obj = nil
    for _, v in pairs(furns) do
        local badPath, paths = gf:findPath(Me, v:getBasicPointInMap())
        if not badPath then
            local count =  paths:QueryInt("count")
            local len = paths:QueryInt(string.format("len%d", count))
            if minLen < 0 or minLen > len then
                -- 取步数最少的
                minLen = len
                obj = v
            end
        end
    end

    return obj, minLen
end

-- 获取前庭、房屋、后院对应的中文名
function HomeMgr:getHomePalceType(str)
    if str == CHS[2000282] then
        return "qianting"
    elseif str == CHS[2000283] then
        return "fangwu"
    elseif str == CHS[2000284] then
        return "houyuan"
    end
end

-- 获取前庭、房屋、后院排序优先级
function HomeMgr:getFurnOrderByPlace(str)
    if str == CHS[2000282] then
        return 1
    elseif str == CHS[2000283] then
        return 2
    elseif str == CHS[2000284] then
        return 3
    else
        return 4
    end
end

-- 根据不同的居所类型获取自动寻路的目的地坐标点
function HomeMgr:getHomeWalkToXYByDlg(homeType, homePlace, dlgName)
    local pos = AUTOWALK_DEST_XY[homeType][homePlace][dlgName]
    if pos then
        return pos.x, pos.y
    end
end

-- 根据居所类型和NPC原始名称，获取该NPC用于寻路的名称
function HomeMgr:getRealNpcNameByNpcAndHomeType(npcName, homeTypeCHS)
    for i = 1, #HOME_PLACE do
        local mapName = homeTypeCHS .. "-" .. HOME_PLACE[i]
        local mapId = MapMgr:getMapByName(mapName)
        local npcs = MapMgr:getNpcs(mapId)
        for i = 1, #npcs do
            local npc = npcs[i]
            local name = npc.name
            if string.match(name, npcName) then
                return name
            end
        end
    end
end

function HomeMgr:sortFurniture(list)
    local function sortFunc(l, r)
        if l.pos >= StoreMgr:getFurnitureStartPos() and r.pos < StoreMgr:getFurnitureStartPos() then return true
        elseif r.pos >= StoreMgr:getFurnitureStartPos() and l.pos < StoreMgr:getFurnitureStartPos() then return false
        elseif l.durability and not r.durability then return true
        elseif not l.durability and r.durability then return false
        elseif l.durability < r.durability then return true
        elseif r.durability < l.durability then return false
        elseif l.food_num and not r.food_num then return true
        elseif not l.food_num and r.food_num then return false
        elseif l.food_num and r.food_num then
            if l.food_num < r.food_num then return true
            elseif r.food_num < l.food_num then return false
            end
        else
            return l.pos < r.pos
        end
    end

    table.sort(list, sortFunc)
    return list
end


-- 进入新地图时处理
function HomeMgr:doWhenEnterRoom(map, lastMap)
    -- 如果是居所
    local mapName = MapMgr:getCurrentMapName()
    local mapId = MapMgr:getCurrentMapId()
    if NpcHomeMap[mapId] then
        -- 如果是NPC居所
        if not NpcHomeData[mapId] then
            NpcHomeData[mapId] = require(ResMgr:getCfgPath(NpcHomeMap[mapId]))
        end

        HomeMgr:putFurniturnsOnMapByCfg(NpcHomeData[mapId])
        GameMgr.scene.map:setLoadCountPerFrame(20)

    elseif MapMgr:isInHouse(mapName) or mapName == CHS[5410203] then
        -- 进入居所、小岚之家
        --DlgMgr:sendMsg("GameFunctionDlg", "addListIcon", "PuttingButton")
        --DlgMgr:sendMsg("GameFunctionDlg", "addListIcon", "TakeButton")
        if mapName == CHS[5410203] then
            self:putFurniturnsBySLZYCfg()
        else
            StoreMgr:cmdFurniture()
        end

        if MapMgr:isInHouseVestibule(mapName) then
            self:clearAllPets()
            self:clearAllStoreShowPets()
        end

        --DlgMgr:sendMsg("GameFunctionDlg", "refreshIcon")
        GameMgr.scene.map:setLoadCountPerFrame(20)

        local function loadAllBlocksAfterLoadEnd()
            if not MapMgr.isLoadEnd then
                performWithDelay(GameMgr.scene.map, function()
                    loadAllBlocksAfterLoadEnd()
                end, 0)
                return
            end

            GameMgr.scene.map:loadBlocksByMyPos(true, nil, true)
        end

        loadAllBlocksAfterLoadEnd()

    elseif MapMgr:isInTanAnMxza() then
        -- 【探案】迷仙镇案
        TanAnMgr:doWhenEnterMxzRoom()
    elseif MapMgr:isInHouse(lastMap.map_name) or lastMap.map_name == CHS[5410203]  then
        -- 离开居所
        --DlgMgr:sendMsg("GameFunctionDlg", "removeListIcon", "PuttingButton")
        --DlgMgr:sendMsg("GameFunctionDlg", "removeListIcon", "TakeButton")
        --DlgMgr:sendMsg("GameFunctionDlg", "refreshIcon")
        GameMgr.scene.map:setLoadCountPerFrame(Const.PER_FRAME_LOAD_COUNT)
    end
end

-- 水岚之缘活动的小岚之家显示家具
function HomeMgr:putFurniturnsBySLZYCfg()
    HomeMgr:putFurniturnsOnMapByCfg(XiaoLanZhiJia)
end

-- 根据家具配置信息在地图上摆放家具
function HomeMgr:putFurniturnsOnMapByCfg(cfg)
    self:clearFurnitures("furnitures", true)
    self.house_id = nil
    self.map_index = nil
    self:clearFurnitures("opers")
    local furns = {}
    for i, v in pairs(cfg) do

        if v.class_id then
            local info = self:getFurnitureInfoById(v.class_id)
            if info then
                info.furniture_type = info.furniture_type
                info.icon = info.icon
                info.name = info.name
                info.dirs = info.dirs
                info.bx = v.x
                info.by = v.y
                info.y = v.cy
                info.x = v.cx
                info.furniture_id = v.class_id
                info.furniture_pos = i
                info.flip = v.dir
                info.dir = self:getDirByFlip(info, v.dir)
                self:doPut(info, false)
            end
        elseif v.wall_index then
            GameMgr.scene.map:setWallIndex(v.wall_index)
        elseif v.floor_index then

            GameMgr.scene.map:setTileIndex(v.floor_index)

        end
    end
end

function HomeMgr:getMyHomeData()
    return self.myData
end

function HomeMgr:getMyHomePrefix()
    if self.myData then
        return self.myData.housePrefix
    end
end

function HomeMgr:onShelterChanged()
    for _, v in pairs(self.furnitures) do
        if v and 'function' == type(v.updateShelter) then
            local mapX, mapY = gf:convertToMapSpace(v.curX, v.curY)
            v:updateShelter(mapX, mapY)
        end
    end
end

-- 根据食盆名称及其食粮饱满度获取图片
function HomeMgr:getFoodImageInfo(bowlName, percent)
    local num = 0
    if percent > 0.6 then
        num = 3
    elseif percent > 0.3 then
        num = 2
    elseif percent > 0 then
        num = 1
    end

    if bowlName == CHS[5410099] then
        return FOOD_ICON[1].foodIcon[num], ResMgr:getFurniturePath(FOOD_ICON[1].bowlIcon)
    elseif bowlName == CHS[5410100] then
        return FOOD_ICON[2].foodIcon[num], ResMgr:getFurniturePath(FOOD_ICON[2].bowlIcon)
    elseif bowlName == CHS[5410101] then
        return FOOD_ICON[3].foodIcon[num], ResMgr:getFurniturePath(FOOD_ICON[3].bowlIcon)
    end
end

function HomeMgr:setPetRandomWalk(pet, petWalkcenter)
    local time
    pet.attckTime = pet.attckTime or 0
    if pet.attckTime and pet.attckTime >= 10 then
        -- 每隔[10, 15]s停留一次，每次停留时先随机播放物攻/施法动作，然后站立1秒，再继续行走流程
        time = 2
        pet.attckTime = 0

        local act = math.random(1, 2)
        pet:setAct(Const.SA_STAND)
        if act == 1 then
            pet.charAction:playActionOnce()
        else
            pet.charAction:playActionOnce(nil, Const.SA_CAST)
        end
    else
        -- 每隔[3, 5]s，在该宠物对应饲养的家具为中心点的50个单位范围内，随机选取一个方向进行行走
        local badPath = self:petRandomWalkInHome(pet, petWalkcenter)
        time = math.random(3, 5)

        if badPath then
            pet.charAction:playWalkThreeTimes()
        end

        pet.attckTime = pet.attckTime + time
    end

    if pet.walkAction then
        pet.bottomLayer:stopAction(pet.walkAction)
        pet.walkAction = nil
    end

    pet.walkAction = performWithDelay(pet.bottomLayer, function()
        self:setPetRandomWalk(pet, petWalkcenter)
    end, time)
end

function HomeMgr:setPetRandomTalkEx(pet, showTimes, delay, interval, talksOrCallback, talkItemCallback)
    if not delay then
        local talks
        if 'function' == type(talksOrCallback) then
            talks = talksOrCallback()
        else
            talks = talksOrCallback
        end

        -- 获取权重
        local weight = {}
        for i = 1, #talks do
            table.insert(weight, talks[i][1])
        end

        local index = gf:weightRandom(weight)
        if not index then return end

        local msg
        if 'function' == type(talkItemCallback) then
            msg =  talkItemCallback(talks[index][2])
        else
            msg = talks[index][2]
        end

        pet:setChat({msg = msg, show_time = 3}, nil, true)

        showTimes = showTimes - 1

        if showTimes > 0 then
            performWithDelay(pet.bottomLayer, function()
                self:setPetRandomTalkEx(pet, showTimes, nil, interval, talksOrCallback, talkItemCallback)
            end, interval)
        end
    else
        if showTimes > 0 then
            performWithDelay(pet.bottomLayer, function()
                self:setPetRandomTalkEx(pet, showTimes, nil, interval, talksOrCallback, talkItemCallback)
            end, delay)
        end
    end
end

function HomeMgr:setPetRandomTalk(pet, bowlId, furniture)
    local time = math.random(5, 10)

    local w
    local percent = 0.2
    if self.petFoodInfo[bowlId] then
        if self.leftTime[bowlId] then
            local num = math.ceil(self.leftTime[bowlId] / (self.oneFoodExpendTime * 60))
            percent = num / self.petFoodInfo[bowlId].max_num
        else
            percent = 0.2
        end
    end

    local name = furniture:queryBasic("name")
    local icon = HomeMgr:getFoodImageInfo(name, percent)
    if icon then
        furniture:removeAllIcon()
        furniture:addIcon(icon, nil, nil, true)
    else
        furniture:removeAllIcon()
    end

    if percent >= 0.5 then
        w = math.random(1, 6)
    elseif percent < 0.2 then
        w = math.random(1, 10)
        if w >= 6 then
            w = 7
        end
    else
        w = math.random(1, 5)
    end

    local msg = RANDOM_TALK[w]

    pet:setChat({msg = msg, show_time = 3}, nil, true)

    performWithDelay(pet.bottomLayer, function()
        self:setPetRandomTalk(pet, bowlId, furniture)
    end, time)
end

-- 设置宠物小屋宠物喊话
function HomeMgr:setPetHouseRandomTalk(pet, index)

end

-- 播放角色光效
function HomeMgr:playEffect(effectIcon, pet, extraPara)
    local efftct = LightEffect[effectIcon]

    if efftct == nil then
        Log:W(effectIcon.." is no config in LightEffect.lua")
        return
    end

    local magicKey = nil
    if efftct["magicKey"] == true then
        magicKey = efftct["icon"]
    end

    if efftct["pos"] == EFFECT_POS["foot"] then
        pet:addMagicOnFoot(efftct["icon"], efftct["behind"], magicKey, efftct["armatureType"], extraPara)
    elseif efftct["pos"] == EFFECT_POS["waist"] then
        pet:addMagicOnWaist(efftct["icon"], efftct["behind"], magicKey, efftct["armatureType"], extraPara)
    elseif efftct["pos"] == EFFECT_POS["head"] then
        pet:addMagicOnHead(efftct["icon"], efftct["behind"], magicKey, efftct["armatureType"], extraPara)
    end
end

-- 停止播放光效
function HomeMgr:stopEffect(effectIcon, pet)
    local effect = LightEffect[effectIcon]

    if not effect then
        Log:W(data.effectIcon.." is no config in LightEffect.lua")
        return
    end

    if pet and effect.magicKey then
        pet:deleteMagic(effect.icon)
    end
end


function HomeMgr:petRandomWalkInHome(pet, center)
    if GObstacle:Instance():IsObstacle(pet.lastMapPosX, pet.lastMapPosY) then
        -- 如果当前位置处于障碍点
        local nx, ny = self:getNearFirstPos(pet.lastMapPosX, pet.lastMapPosY)
        if nx and ny then
            pet:setPos(gf:convertToClientSpace(nx, ny))
        else
            Log:D(CHS[3003916])
            return
        end
    end

    if center == nil then return end

    local petX, petY = gf:convertToMapSpace(pet.curX, pet.curY)

    local x, y
    local count = 0
    local badPath
    local unit = PET_WALK_UNIT_RANDE / 2
    repeat
        -- 在周围50格内随机走动
        x = math.random(-unit, unit) + center.x
        y = math.random(-unit, unit) + center.y
        count = count + 1

        -- 矫正地图边界
        x, y = MapMgr:adjustPosition(x, y)
        badPath, _ = gf:findPath(pet, x, y)
    until not badPath or (count > 10)

    -- 设置pet的终点
    pet:setEndPos(x, y)

    -- 在寻路失败的情况下，获取的x,y坐标可能为nil
    return badPath
end


-- 初始生成形象在对应饲养家具2个单位的随机非障碍点上，若2个单位范围内都是障碍点，则生成在距离最近的非障碍点内。
function HomeMgr:getNearFirstPos(mapX, mapY)
    -- 最近2个单位，最远30个单位
    local unit = PET_WALK_UNIT_RANDE / 2

    for i = 2, unit do
        for j = -i, i do
            local x, y = mapX + i, mapY + j
            if not GObstacle:Instance():IsObstacle(x, y) then
                return x, y
            end
        end

        for j = -(i - 1), i - 1 do
            local x, y = mapX + j, mapY + i
            if not GObstacle:Instance():IsObstacle(x, y) then
                return x, y
            end
        end
    end
end

function HomeMgr:clearAllPets()
    for id, v in pairs(self.homePets) do
        self:clearOnePetById(id)
    end

    self.homePets = {}
end

function HomeMgr:clearAllStoreShowPets()
    for _, v in pairs(self.storeShowPets) do
        v:cleanup()
    end

    self.storeShowPets = {}
end

function HomeMgr:clearOnePetById(id)
    if self.homePets[id] then
        self.homePets[id]:cleanup()
    end

    if self.furnitures[id] then
        self.furnitures[id]:removeHint()
    end

    self.homePets[id] = nil
end

function HomeMgr:isPetBowl(name)
    if string.format(name, CHS[5410120]) then
        return true
    end
end

function HomeMgr:update()
    for _, pet in pairs(self.homePets) do
        pet:update()
    end

    for _, pet in pairs(self.storeShowPets) do
        pet:update()
    end

    if self.effData and self.effData.count > 0 then
        for pos, data in pairs(self.effData.eff) do
            local fur = HomeMgr:getFurnitureById(pos)
            if fur then
                local furnitureName = fur:getName()
                local magicInfo = FUNCTION_FURNITURE_MAGIC[furnitureName]
                if data.endTime >= gf:getServerTime() then
                    if magicInfo then
                        -- 功能型家具需要增加开启字段，方便移动，摆放判断是否需要增加特效
                        fur:tryToAddMagicOnFuncFurniture()
                    else
                        -- 默认帧光效
                        local magic = fur.image:getChildByTag(EFFECT_TAG)
                        if not magic then
                            magic = gf:createLoopMagic(data.effIcon, nil, {blendMode = "add"})
                            magic:setTag(EFFECT_TAG)
                            fur.image:addChild(magic)
                        end
                    end
                else
                    local magic = fur.image:getChildByTag(EFFECT_TAG)
                    if magic then magic:removeFromParent() end
                end
            end
        end
    end

    -- 居所种植刷新农作物生长状态
    for id, v in pairs(self.croplandInfo) do
        if type(v) == "table" and v.class_id > 0 then
            local crop = self.plantCrops[id]
            if crop then
                local icon, no, canHar = self:getCropIcon(v)
                local curIconNo = crop:queryInt("icon_no")
                if no ~= curIconNo then
                    -- 农作物生长状态发生变化，更新农作物图片
                    crop:setBasic("icon", icon)
                    crop:setBasic("icon_no", no)
                    crop.image:setTexture(ResMgr:getFurniturePath(icon, no))

                    -- 图片更改调整农作物高度
                    crop:setPlantPanelHeight()

                    if canHar and v.isMy == 1 then
                        -- 农作物成熟显示收获标识
                        crop.cropStatus = HOME_CROP_STAUES.STATUS_FINISH
                        crop:showPlantPanel(true, HOME_CROP_STAUES.STATUS_FINISH, v.farm_index)
                    end
                end
            end
        end
    end
end

-- 当前处理鲁班，种植材料
function HomeMgr:useHomeMaterial(item, notInHomeTips, findFurName1, findFurName2, endOpenDlg, endTips, openPuttingDlgTips)
    local mapName = MapMgr:getCurrentMapName()
    if not MapMgr:isInHouse(mapName) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(notInHomeTips)
        return
    end

    DlgMgr:closeDlg("BagDlg")
    DlgMgr:closeDlg("ItemInfoDlg")
    if MapMgr:isInHouseRoom(mapName) then
        -- 在房屋内
        local obj1, len1 = HomeMgr:getFurnObjByName(findFurName1)
        local obj2, len2 = HomeMgr:getFurnObjByName(findFurName2)
        local obj = obj1 or obj2
        if not obj then
            -- 没有对应家具，则打开布置界面，并滑到对应家具
            local dlg = DlgMgr:openDlg("HomePuttingDlg")
            local itemCtrl = dlg:getItemByName(findFurName1)
            dlg:scrollToOneItemAndChoose(itemCtrl, true)
            gf:ShowSmallTips(openPuttingDlgTips)

            return
        elseif obj1 and obj2 then
            -- 两种家具都有，选距离近的
            obj = len1 < len2 and obj1 or obj2
        end

        local function autoWalkCallBack(para)
            gf:ShowSmallTips(endTips)
        end

        local autoWalkInfo = {}
        autoWalkInfo.map = MapMgr:getCurrentMapName()
        autoWalkInfo.action = "$0"
        autoWalkInfo.npc = obj:queryBasic("name")
        autoWalkInfo.isClickNpc = true
        autoWalkInfo.npcId = obj:getId()
        autoWalkInfo.x, autoWalkInfo.y = obj:getBasicPointInMap()
        autoWalkInfo.destCallback = {func = autoWalkCallBack, para = ""}
        AutoWalkMgr:beginAutoWalk(autoWalkInfo)
    else
        -- 不在房屋内，先进房屋，再使用该道具
        local function callBack(para)
            -- 回调需要在进入房屋后再执行，因为寻路如果通过飞毯道具进入房屋，也会触发以下逻辑，但以下逻辑在房屋外不希望被执行
            if not MapMgr:isInHouseRoom(MapMgr:getCurrentMapName()) then return end

            -- 过图后，需要延迟一帧，再开始寻路逻辑。否则会在Me:onEnterScene中走过图寻路逻辑
            -- notfirstUnFlyAutoWalk标记为true，不保存着当前寻路信息，导致第2段寻路不能调用到回调
            performWithDelay(gf:getUILayer(), function()
                HomeMgr:useHomeMaterial(item, notInHomeTips, findFurName1, findFurName2,
                    endOpenDlg, endTips, openPuttingDlgTips)
            end, 0)
        end

        local autoWalkInfo = {}
        autoWalkInfo.action = "$2"
        autoWalkInfo.homeInfo = "me"
        autoWalkInfo.map = CHS[7100259]
        autoWalkInfo.destCallback = {func = callBack, para = ""}

        AutoWalkMgr:beginAutoWalk(autoWalkInfo)
    end
end

function HomeMgr:setCurChooseBowlId(id)
    self.curChooseBowlId = id
end

function HomeMgr:getCurChooseBowlId()
    return self.curChooseBowlId or 0
end

-- 宠物饲养收益
function HomeMgr:MSG_HOUSE_PET_FEED_VALUE_INFO(data)
    self.feedPetValue[data.bowl_id] = data

    local pet = self.homePets[data.bowl_id]
    if pet then
        -- 宠物光效
        if data.type == 0 then
            self:stopEffect(EFFECT_NO.tao, pet)
            self:playEffect(EFFECT_NO.exp, pet, {blendMode = "add"})
        else
            self:stopEffect(EFFECT_NO.exp, pet)
            self:playEffect(EFFECT_NO.tao, pet, {blendMode = "add"})
        end
            end
    end

-- 宠物食粮信息
function HomeMgr:MSG_HOUSE_PET_FEED_FOOD_INFO(data)
    self.petFoodInfo[data.bowl_id] = data
    local furniture = self.furnitures[data.bowl_id]
    if furniture then
        local type = furniture:queryBasic("furniture_type")
        if type ~= CHS[5410072] then
            self.furnitures[data.bowl_id] = nil
            return
        end

        data.name = furniture:queryBasic("name")
        local percent = data.num / data.max_num
        local icon = HomeMgr:getFoodImageInfo(data.name, percent)
        if icon then
            furniture:removeAllIcon()
            furniture:addIcon(icon, nil, nil, true)
        else
            furniture:removeAllIcon()
        end
    end

    if data.num > 0 then
        self.oneFoodExpendTime = data.remain_time / data.num
    end

    if data.remain_time > 0 then
        data.remain_time = data.remain_time - self.oneFoodExpendTime
    end

    -- 更新宠物食料预计可维持时间，用于客户端倒计时移除宠物
    self.leftTime[data.bowl_id] = data.remain_time * 60 + data.next_bonus_time
end

-- 选择饲养的宠物
function HomeMgr:MSG_HOUSE_PET_FEED_SELECT_PET(data)
    if data.fasion_id and data.fasion_id ~= 0 and data.fasion_visible ~= 0 then
        data.special_icon = data.fasion_id
    elseif data.dye_icon and data.dye_icon ~= 0 then
        data.special_icon = data.dye_icon
    else
        data.special_icon = data.pet_icon
    end

    local bowlId = data.bowl_id
    local furniture = self.furnitures[bowlId]
    self.selectPetFeed[bowlId] = data

    if not MapMgr.mapData or not MapMgr.mapData.map_name or not string.match(MapMgr:getCurrentMapName(), CHS[5410104]) then
        return
    end

    if not furniture then
        if self.homePets[bowlId] then
            HomeMgr:clearOnePetById(bowlId)
        end

        return
    end

    local type = furniture:queryBasic("furniture_type")
    if data.is_show_pet == 0
        or type ~= CHS[5410072] then
        if self.homePets[bowlId] then
            HomeMgr:clearOnePetById(bowlId)
            furniture:removeHint()
        end

        if type ~= CHS[5410072] then
            self.feedPetValue[bowlId] = nil
        end

        return
    end

    local pet = self.homePets[bowlId]
    if not pet then
        local mapX, mapY = gf:convertToMapSpace(furniture.curX, furniture.curY)

        -- 获取宠物起始坐标
        local x, y = self:getNearFirstPos(mapX, mapY)

        if not x or not y then
            return
        end

        pet = require("obj/Pet").new()

        pet:absorbBasicFields({
            name = string.format(CHS[5410096], data.pet_name),
            icon = data.pet_icon,
            special_icon = data.special_icon
        })

        -- 行走速度 = 正常人物行走速度 * 0.7
        pet:setSeepPrecent(-30)

        pet:onEnterScene(x, y)

        -- 初始位置
        pet:setPos(gf:convertToClientSpace(x, y))

        pet:setAct(Const.SA_STAND)

        -- 透明度设置为70%
        pet.charAction:setCharOpacity(PET_ALPHA)

        if self.feedPetValue[bowlId] and self.feedPetValue[bowlId].type == 0 then
            self:stopEffect(EFFECT_NO.tao, pet)
            self:playEffect(EFFECT_NO.exp, pet, {blendMode = "add"})
        else
            self:stopEffect(EFFECT_NO.exp, pet)
            self:playEffect(EFFECT_NO.tao, pet, {blendMode = "add"})
        end

        -- 随机行走
        local petWalkcenter = {x = mapX, y = mapY}
        self:setPetRandomWalk(pet, petWalkcenter)

        -- 随机喊话
        self:setPetRandomTalk(pet, bowlId, furniture)

        -- 添加头像气泡提示
        furniture:addHint(data.pet_icon, 2)

        self.homePets[bowlId] = pet

        schedule(pet.middleLayer, function()
            if self.leftTime[bowlId] then
                self.leftTime[bowlId] = self.leftTime[bowlId] - 1


                if self.leftTime[bowlId] < 0 then
                    HomeMgr:clearOnePetById(bowlId)
                    furniture:removeAllIcon()
                    furniture:removeHint()
                    self.leftTime[bowlId] = nil
                end
            end
        end, 1)
    else
        local mapX, mapY = gf:convertToMapSpace(furniture.curX, furniture.curY)
        local petWalkcenter = {x = mapX, y = mapY}

        -- 更新数据
        pet:absorbBasicFields({
            name = string.format(CHS[5410096], data.pet_name),
            icon = data.pet_icon,
            special_icon = data.special_icon
        })

        self:setPetRandomWalk(pet, petWalkcenter)
    end
end

-- 食盆的饲养状态
function HomeMgr:MSG_HOUSE_PET_FEED_STATUS_INFO(data)
    self.bowlFeedStatus[data.bowl_id] = data
end

-- 摆放家具后如果有相关数据则刷新宠物及食盆信息
function HomeMgr:updateBowlAfterPalceFurn(id)
    if self.selectPetFeed[id] then
        self:MSG_HOUSE_PET_FEED_SELECT_PET(self.selectPetFeed[id])
    end

    if self.petFoodInfo[id] then
        self:MSG_HOUSE_PET_FEED_FOOD_INFO(self.petFoodInfo[id])
    end
end

function HomeMgr:MSG_OPEN_MODIFY_HOUSE_SPACE_DLG(data)
    -- 打开界面
    DlgMgr:openDlgEx("HomeSpaceDlg", data)
end

-- 刷新当前居所数据
function HomeMgr:MSG_HOUSE_FURNITURE_DATA(data)
    self:clearFurnitures("furnitures", true)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then return end
    self.house_id = data.house_id
    self.map_index = data.map_index
    -- self:clearFurnitures("furnitures", true)
    self:clearFurnitures("opers")
    self:updateObstacle(data.obstacle)
    self.loadFurnitureList = List.new()
    self.curHouseHosters = data.hosters
end

function HomeMgr:placeFurnitures()
    if not MapMgr.isLoadEnd then
        performWithDelay(GameMgr.scene.map, function()
            self:placeFurnitures()
        end, 0)
        return
    end

    local v
    local loadCountPerFrame = 5

    while loadCountPerFrame > 0 and self.loadFurnitureList:size() > 0 do
        v = self.loadFurnitureList:popFront()
        local info = self:getFurnitureInfoById(v.furniture_id)
        if info then
            v.furniture_type = info.furniture_type
            v.icon = info.icon
            v.name = info.name
            v.dirs = info.dirs
            v.dir = self:getDirByFlip(info, v.flip)
            self:doPut(v, false, true)
        end
        loadCountPerFrame = loadCountPerFrame - 1
    end

    if self.loadFurnitureList:size() > 0 then
        performWithDelay(GameMgr.scene.map, function()
            self:placeFurnitures()
        end, 0)
    end
    
    if DlgMgr:getDlgByName("ChildDailyMission1Dlg") then
        HomeMgr:setFurnitureAndCropsVisible(false)
    end
end

function HomeMgr:MSG_HOUSE_FURNITURE_DATA_PAGE(data)
    if not self.loadFurnitureList then return end

    if self.loadFurnitureList:size() <= 0 then
        -- 下一帧开始摆放家具
        performWithDelay(GameMgr.scene.map, function()
            self:placeFurnitures()
        end, 0)
    end

    -- 寻路相关的家具直接放进场景
    local delayLoad = {}
    for i = 1, #data.furnitures do
        local info = data.furnitures[i]


        local item = self:getFurnitureInfoById(info.furniture_id)
        if HomeMgr:isCanClickFurniture(item.name) then
            info.furniture_type = item.furniture_type
            info.icon = item.icon
            info.name = item.name
            info.dirs = item.dirs
            info.dir = self:getDirByFlip(item, info.flip)
            self:doPut(info, false, true)
        else
            table.insert(delayLoad, info)
    end
    end

    for i = 1, #delayLoad do
        self.loadFurnitureList:pushBack(delayLoad[i])
    end
end

function HomeMgr:getDirByFlip(info, flip)
    if not info.dirs or  info.dirs <= 1 then
       return
    end

    local dir
    if not flip then
        -- 预览时给个默认方向
        dir = info.defaultDir or 5
    elseif flip > 10 then
        -- 服务端方向为 10 ~ 17，转换为 0~7
        dir = flip - 10
    else
        -- 兼容部分旧数据，
        if flip == 0 then
            dir = 5
        else
            dir = 7
        end
    end

    return dir
end

-- 家具操作
function HomeMgr:MSG_HOUSE_FURNITURE_OPER(data)
    local info = self:getFurnitureInfoById(data.furniture_id)
    if not info then return end
    local operId = data.cookie
    local action = data.action

    if 'place' == action or "other_place" == action then
        -- 摆放
        local furniture = self.opers[operId]
        if not furniture then
            if info.dirs and info.dirs > 1 then
                furniture = FurnitureEx.new()
            else
                furniture = Furniture.new()
            end

            furniture:absorbBasicFields({
                icon = info.icon,
                furniture_type = info.furniture_type,
                id = data.furniture_pos,
                durability = data.durability,
                name = info.name,
                dir = self:getDirByFlip(info, data.flip)
            })

            furniture:setVisible(true)
            furniture:action(false, 1 == data.flip)
            furniture:onEnterScene(0, 0)
        else
            furniture:absorbBasicFields({
                icon = info.icon,
                furniture_type = info.type,
                id = data.furniture_pos,
                name = info.name,
                durability = data.durability,
                dir = self:getDirByFlip(info, data.flip)
            })
        end
        local x, y = self:calcPosition(data.bx, data.by, data.x, data.y)
        furniture:setPos(x, y)
        furniture.cookie = nil
        if self:putFurniture(furniture) then
            furniture:showOper(false)
            if furniture.image then
                furniture.image:retain()
                furniture.image:removeFromParent()
                if 'carpet' == self:getPutLayerByFurniture(furniture) then
                    furniture:addToBottomLayer(furniture.image)
                else
                    furniture:addToMiddleLayer(furniture.image)
                end
                furniture.image:release()
            end
            self.opers[operId] = nil
        end

        self:updateBowlAfterPalceFurn(data.furniture_pos)

        -- 家具摆放成功后尝试添加默认特效
        furniture:addDefaultMagicOnFurniture()

        -- 功能型家具
        furniture:createMagicOnFuncFurniture()
    elseif 'drag' == action then
        -- 开始拖动
        local furniture = self.furnitures[data.furniture_pos]
        if not furniture then return end

        -- 只有在布置界面才会打开
        local x, y = self:calcPosition(data.bx, data.by, data.x, data.y)
        furniture:setPos(x, y)
        if self:takeFurniture(furniture) then
            furniture:showOper(true)

            -- 移动到顶层层
            if furniture.image then
                furniture.image:retain()
                furniture.image:removeFromParent()
                furniture:addToTopLayer(furniture.image)
                furniture.image:release()

                local magic = furniture.image:getChildByTag(EFFECT_TAG)
                if magic then
                    magic:setVisible(false)
            end
            end

            local cookie = self:tryGenId()
            self.opers[cookie] = furniture
            furniture.cookie = cookie
        end

    elseif 'move' == action or "other_move" == action then
        -- 移动
        local furniture = self.opers[operId]
        if not furniture then
            furniture = self.furnitures[data.furniture_pos]
            if not self:takeFurniture(furniture) then return end
        end
        if not furniture then return end
        local x, y = self:calcPosition(data.bx, data.by, data.x, data.y)
        furniture:setPos(x, y)
        furniture:setFlip(1 == data.flip)
        furniture:setBasic("dir", self:getDirByFlip(info, data.flip))
        furniture.cookie = nil
        if self:putFurniture(furniture) then
            furniture:showOper(false)
            if furniture.image then
                furniture.image:retain()
                furniture.image:removeFromParent()
                if 'carpet' == self:getPutLayerByFurniture(furniture) then
                    furniture:addToBottomLayer(furniture.image)
                else
                    furniture:addToMiddleLayer(furniture.image)
                end
                furniture.image:release()

                local magic = furniture.image:getChildByTag(EFFECT_TAG)
                if magic then magic:removeFromParent() end
            end
            self.opers[operId] = nil
        else
            furniture:cleanup()
            assert(false, string.format("cannot move furniture(%d)", data.furniture_pos))
        end

        -- 家具摆放成功后尝试添加默认特效
        furniture:addDefaultMagicOnFurniture()

        -- 功能型家具
        furniture:createMagicOnFuncFurniture()
    elseif 'take' == action or "other_take" == action then
        -- 取回
        local furniture = self.opers[operId]
        if furniture then
            -- 返回包裹，直接从场景中析构
            furniture:cleanup()
            self.opers[operId] = nil
        else
            furniture = self.furnitures[data.furniture_pos]
            if furniture then
                if self:takeFurniture(furniture) then
                    furniture:cleanup()
                end
            end
        end
    elseif 'update' == action then
        local furniture = self.furnitures[data.furniture_pos]
        if furniture then
            furniture:absorbBasicFields({
                icon = info.icon,
                furniture_type = info.type,
                id = data.furniture_pos,
                name = info.name,
                durability = data.durability,
            })
        end

        -- 同时更新一下self.specialFurnitureList
        local specialFurnitureList = self.specialFurnitureList or {}
        for i = 1, #specialFurnitureList do
            if specialFurnitureList[i].furniture_pos == data.furniture_pos then
                self.specialFurnitureList[i].durability = data.durability
            end
        end
    elseif 'repair' == action then
        local furniture = self.furnitures[data.furniture_pos]
        if furniture then
            furniture:absorbBasicFields({
                icon = info.icon,
                furniture_type = info.type,
                id = data.furniture_pos,
                name = info.name,
                durability = data.durability,
            })
        end

        -- 同时更新一下self.specialFurnitureList
        local specialFurnitureList = self.specialFurnitureList or {}
        for i = 1, #specialFurnitureList do
            if specialFurnitureList[i].furniture_pos == data.furniture_pos then
                self.specialFurnitureList[i].durability = data.durability
            end
        end
    end

    if DlgMgr:getDlgByName("ChildDailyMission1Dlg") then
        HomeMgr:setFurnitureAndCropsVisible(false)
    end
end

function HomeMgr:MSG_ADD_HOUSE_FURNITURE_DATA(data)
    if data.house_id == self:getHouseId() then
        if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then return end
        self.house_id = data.house_id
        self.map_index = data.map_index
        local v
        for i = 1, data.count do
            v = data.furnitures[i]
            local k = self:getFurnitureFromOpersById(v.furniture_pos)
            if not k then
                local f = self.opers[k]
                if f then
                    f:cleanup()
                    self.opers[k] = nil
                end
            end
            local info = self:getFurnitureInfoById(v.furniture_id)
            if info then
                v.furniture_type = info.furniture_type
                v.icon = info.icon
                v.name = info.name
                v.dirs = info.dirs
                v.dir = self:getDirByFlip(info, v.flip)
                self:doPut(v, false)
            end
        end
    end

    for i = 1, data.count do
        local fur = data.furnitures[i]
        -- 法宝有场景光效时，抓起，再右下角X按钮取消摆放，那时候服务器消息顺序 MSG_HOUSE_ARTIFACT_VALUE下发时，该家具尚未摆放，所以等摆放完后，再加光效
        if self.artifactEffData[fur.furniture_pos] then
            self.artifactEffData[fur.furniture_pos].isOpen = 0
            self:MSG_HOUSE_ARTIFACT_VALUE(self.artifactEffData[fur.furniture_pos])
            self.artifactEffData[fur.furniture_pos] = nil
end
    end
end

-- 刷新居所信息
function HomeMgr:MSG_HOUSE_DATA(data)
    self.myData = {}
    self.myData.house_id = data.house_id
    self.myData.houseType = data.house_type
    self.myData.comfort = data.comfort
    self.myData.cleanliness = data.cleanliness
    self.myData.cleanCostTime = data.clean_costtime
    self.myData.storeType = data.store_type
    self.myData.housePrefix = data.house_prefix
end

function HomeMgr:MSG_BEDROOM_FURNITURE_APPLY_DATA(data)
    self.bedroomType = data.bedroom_type
    self.maxSleepTimes = data.max_times
    if self.bedRoomSleepInfo and self.bedRoomSleepInfo[1] == 1 then
        self.curSleepTimes = data.cur_times
    else
        self.curSleepTimes = data.couple_rest_times
    end

    if data.cur_times == data.max_times then
        RedDotMgr:removeOneRedDot("HomeTabDlg", "OtherDlgCheckBox", nil, "rest")
        RedDotMgr:removeOneRedDot("GameFunctionDlg", "HomeButton", nil, "rest")
    end
end

-- 显示居所卧室休息的动画
-- notZZZ 没有ZZZ的睡觉效果
function HomeMgr:showSleepMagic(furn, count, gender, notZZZ)
    if not furn then return end
	if furn.image:getChildByTag(SLEEP_MAGIC_TAG) then return end

    gender = gender or Me:queryBasicInt("gender")

    local name = furn:queryBasic("name")
    local magic
    if name == CHS[5420206] then
        magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.diji_bed_sleep.name)
    elseif name == CHS[5420207] then
        magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.zhongji_bed_sleep.name)
    else
        magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.gaoji_bed_sleep.name)
    end

    if count == 2 then
        -- 双人
        if furn:isFlip() then
            magic:getAnimation():play("Top06")
        else
            magic:getAnimation():play("Top05")
        end
    else
        -- 单人
        if gender == GENDER_TYPE.MALE then
            if furn:isFlip() then
                if not notZZZ then
                    magic:getAnimation():play("Top03")

                else
                    magic:getAnimation():play("Top09")
                end
            else
                if not notZZZ then
                    magic:getAnimation():play("Top01")

                else
                    magic:getAnimation():play("Top07")
                end
            end
        else
            if furn:isFlip() then
                if not notZZZ then
                    magic:getAnimation():play("Top04")
                else
                    magic:getAnimation():play("Top10")
                end
            else
                if not notZZZ then
                    magic:getAnimation():play("Top02")
                else
                    magic:getAnimation():play("Top08")
                end
            end
        end
    end

    if not furn.image then
        return
    end

    local size = furn.image:getContentSize()
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width / 2, size.height / 2)
    furn.image:addChild(magic, 0, SLEEP_MAGIC_TAG)
end

function HomeMgr:setLSClickType(lsType)
    self.childLSType = lsType
end

function HomeMgr:setBedroomSleepInfo(count, type)
    self.bedRoomSleepInfo = {count, type}
end

-- 通知客户端播放夫妻之礼动画
function HomeMgr:MSG_HOUSE_SEX_LOVE_ANIMATE(data)
    local furn = self:getFurnitureById(data.furniture_pos)
    local function endAnimate()
        -- 显示所有隐藏的界面
        local t = {}
        if self.allInvisbleDlgsBySleep then
            for i = 1, #(self.allInvisbleDlgsBySleep) do
                t[self.allInvisbleDlgsBySleep[i]] = 1
            end

            DlgMgr:showAllOpenedDlg(true, t)
        end

        --显示主界面
        if self.hasHideAllUIInSleep and GameMgr:isHideAllUI() then
            GameMgr:showAllUI()
        end

        self.hasHideAllUIInSleep = false
        self.allInvisbleDlgsBySleep = nil

        local tiem1 = data.start_time - Const.FIVE_HOURS + Const.ONE_DAY_SECOND
        local tiem2 = data.start_time - Const.FIVE_HOURS + Const.ONE_DAY_SECOND * 2
        gf:confirm(string.format(CHS[5450484], gf:getServerDate(CHS[4300233], tiem1), gf:getServerDate(CHS[4300233], tiem2))
                    , nil, nil, nil, nil, nil, nil, true)

        -- 解冻
        gf:unfrozenScreen()

        GameMgr:unRegistFrameFunc(FRAME_FUNC_TAG.COUPLE_LOVE_SLEEP)
    end

    local function showChars()
        -- 移除休息动画
        if furn and furn.image then
            furn.image:removeChildByTag(SLEEP_MAGIC_TAG)
        end

        -- 显示角色
        self.playSleepInHome = false
        CharMgr:doCharHideStatus(Me)
    end

    -- 先停掉上一个动画
    showChars()
    endAnimate()

    GameMgr:registFrameFunc(FRAME_FUNC_TAG.COUPLE_LOVE_SLEEP, function()
        if gf:getServerTime() - data.start_time > 10 then
            -- 超时直接停掉
            showChars()
            endAnimate()
        end
    end, nil, true)

    -- 清除队伍匹配信息
    TeamMgr:stopMatchTeam()
    TeamMgr:stopMatchMember()

    DlgMgr:closeDlg("KidsCreateDlg")

    -- 隐藏主界面按钮
    self.hasHideAllUIInSleep = false
    if not GameMgr:isHideAllUI() then
        GameMgr:hideAllUI(0)
        self.hasHideAllUIInSleep = true
    end

    -- 先获取当前被隐藏的界面，防止停止动画时被显示出来
    self.allInvisbleDlgsBySleep = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false)

    -- 冻屏
    local frozenScreenLayer = gf:frozenScreen(10000, 0, 10000, true)

    local function setTalk(char, gender)
        ChatMgr:sendCurChannelMsgOnlyClient({
            id = char:getId(),
            gid = char:queryBasic("gid"),
            time = gf:getServerTime(),
            icon = char:queryBasicInt("org_icon"),
            name = char:getName(),
            msg = "#17",
            show_extra = tonumber(char:queryBasicInt("vip_type")) > 0,
            gender = gender
        })
    end

    local action = cc.Sequence:create(
        cc.FadeIn:create(1),
        cc.CallFunc:create(function()
            -- 隐藏角色，并播睡觉光效
            self.playSleepInHome = true
            CharMgr:doCharHideStatus(Me)
            self:showSleepMagic(furn, 2)
        end),

        cc.FadeOut:create(1),
        cc.DelayTime:create(2),
        cc.FadeIn:create(1),
        cc.CallFunc:create(function()
            -- 移除光效，并显示角色
            showChars()
        end),
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            -- 男方喊话
            local gender = Me:queryInt("gender")
            local char = Me
            if gender == 2 then
                char = CharMgr:getCouple()
            end

            if not char then return end

            setTalk(char, 1)
        end),
        cc.DelayTime:create(0.8),
        cc.CallFunc:create(function()
            -- 女方喊话
            local gender = Me:queryInt("gender")
            local char = Me
            if gender == 1 then
                char = CharMgr:getCouple()
            end

            if not char then return end

            setTalk(char, 2)

            gf:CmdToServer('CMD_HOUSE_REST_ANIMATE_DONE', {})
        end),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(endAnimate)
    )

    frozenScreenLayer:runAction(action)
end

function HomeMgr:MSG_HOUSE_REST_ANIMATE(data)
    if self.sleepColorLayer then
        self.sleepColorLayer:removeFromParent()
        self.sleepColorLayer = nil
    end

    local furn = self:getFurnitureById(data.furniture_pos)
    local function endAnimate()
        local t = {}
        if self.allInvisbleDlgsBySleep then
            for i = 1, #(self.allInvisbleDlgsBySleep) do
                t[self.allInvisbleDlgsBySleep[i]] = 1
            end

            DlgMgr:showAllOpenedDlg(true, t)
        end

        if self.hasHideAllUIInSleep and GameMgr:isHideAllUI() then
            GameMgr:showAllUI()
        end

        self.hasHideAllUIInSleep = false
        self.allInvisbleDlgsBySleep = nil

        -- 解冻
        gf:unfrozenScreen()
    end

    if data.isPlay ~= 1 then
        -- 停止休息动画
        if furn and furn.image then
            furn.image:removeChildByTag(SLEEP_MAGIC_TAG)
        end

        self.playSleepInHome = false
        CharMgr:doCharHideStatus(Me)
        endAnimate()
        return
    end

    -- 清除队伍匹配信息
    TeamMgr:stopMatchTeam()
    TeamMgr:stopMatchMember()

    DlgMgr:closeDlg("HomeBedroomDlg")

    -- 隐藏主界面按钮
    self.hasHideAllUIInSleep = false
    if not GameMgr:isHideAllUI() then
        GameMgr:hideAllUI(0)
        self.hasHideAllUIInSleep = true
    end

    -- 先获取当前被隐藏的界面，防止停止动画时被显示出来
    self.allInvisbleDlgsBySleep = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false)

    -- 冻屏
    local frozenScreenLayer = gf:frozenScreen(0)

    -- 添加黑幕
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    colorLayer:setContentSize(frozenScreenLayer:getContentSize())
    frozenScreenLayer:addChild(colorLayer)

    local function oneRandomTalk()
        -- 单人喊话
        local num = math.random(1, 7)
        if num == 1 then
            local curTime = gf:getServerTime()
            local hour = tonumber(gf:getServerDate("%H", curTime))
            if hour >= 14 or hour < 12 then
                num = math.random(2, 7)
            end
        end

        if num == 7 then
            if Me:queryBasicInt("gender") == GENDER_TYPE.MALE then
                num = 8
            else
                num = 7
            end
        end

        performWithDelay(colorLayer, function()
            ChatMgr:sendCurChannelMsgOnlyClient({
                id = Me:getId(),
                gid = Me:queryBasic("gid"),
                time = gf:getServerTime(),
                icon = Me:queryBasicInt("icon"),
                name = Me:getName(),
                msg = ONE_WAKE_UP_CALL_TEXT[num].text,
                show_extra = Me:isVip(),
                gender = Me:queryInt("gender")
            })

            gf:CmdToServer('CMD_HOUSE_REST_ANIMATE_DONE', {})
        end, 0)
    end

    local dur = furn:queryBasicInt("durability")
    local function twoRandomTalk()
        -- 夫妻喊话
        local num = ((dur / 10) % 7) + 1

        -- me
        local char = CharMgr:getCouple()
        local gender = Me:queryInt("gender")
        local talk1 = DOUBLE_WAKE_UP_CALL_TEXT[num][gender]

        performWithDelay(colorLayer, function()
            ChatMgr:sendCurChannelMsgOnlyClient({
                id = Me:getId(),
                gid = Me:queryBasic("gid"),
                time = gf:getServerTime(),
                icon = Me:queryBasicInt("icon"),
                name = Me:getName(),
                msg = talk1.text,
                show_extra = Me:isVip(),
                gender = gender
            })

            if not talk1.isFirst then
                gf:CmdToServer('CMD_HOUSE_REST_ANIMATE_DONE', {})
            end
        end, talk1.isFirst and 0 or 0.8)

        -- 伴侣
        local char = CharMgr:getCouple()
        if not char then return end

        local gender2 = gender == 1 and 2 or 1
        local talk2 = DOUBLE_WAKE_UP_CALL_TEXT[num][gender2]
        performWithDelay(colorLayer, function()
            ChatMgr:sendCurChannelMsgOnlyClient({
                id = char:getId(),
                gid = char:queryBasic("gid"),
                time = gf:getServerTime(),
                icon = char:queryBasicInt("icon"),
                name = char:getName(),
                msg = talk2.text,
                show_extra = tonumber(char:queryBasicInt("vip_type")) > 0,
                gender = gender2
            })

            if not talk2.isFirst then
                gf:CmdToServer('CMD_HOUSE_REST_ANIMATE_DONE', {})
            end
        end, talk2.isFirst and 0 or 0.8)
    end

    local action = cc.Sequence:create(
        cc.FadeIn:create(1),
        cc.CallFunc:create(function()
            -- 隐藏角色，并播睡觉光效
            self.playSleepInHome = true
            CharMgr:setVisible(false)
            self:showSleepMagic(furn, data.count)
        end),

        cc.FadeOut:create(1),
        cc.DelayTime:create(1.5),
        cc.FadeIn:create(1),
        cc.CallFunc:create(function()
            -- 移除光效，并显示角色
            self.playSleepInHome = false
            CharMgr:doCharHideStatus(Me)
            if furn.image then
                furn.image:removeChildByTag(SLEEP_MAGIC_TAG)
            end
        end),
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            -- 喊话
            if data.count == 1 then
                oneRandomTalk()
            else
                twoRandomTalk()
            end
        end),

        cc.DelayTime:create(0.5),
        cc.CallFunc:create(endAnimate)
    )

    colorLayer:runAction(action)

    self.sleepColorLayer = colorLayer
end

function HomeMgr:MSG_HOUSE_SHOW_DATA(data)

    if not BlogMgr.userInfo[data.char_gid] then
        BlogMgr.userInfo[data.char_gid] = {}
        BlogMgr.userInfo[data.char_gid].user_gid = data.char_gid
    else
        BlogMgr.userInfo[data.char_gid].user_gid = data.char_gid
    end


    if DlgMgr:getDlgByName("BlogEXTabDlg") then
        -- 如果第二层已经打开了
        -- 这个时候要判断第一层空间和要打开的空间是否相同，相同则关闭第二层就好
        local tabDlg = DlgMgr:getDlgByName("BlogTabDlg")
        if tabDlg and tabDlg:getUserGid() == data.char_gid then
            DlgMgr:closeDlg("BlogEXTabDlg")
        else
            -- 覆盖第二层
            DlgMgr:openDlgEx("HomeShowEXDlg", data)
        end
    else
        local dlg = DlgMgr:getDlgByName("BlogTabDlg")
        if dlg and dlg:getUserGid() ~= data.char_gid then
            -- 第一个已经打开了，打开第二个
            DlgMgr:openDlgEx("HomeShowEXDlg", data)
            DlgMgr:sendMsg("BlogEXTabDlg", "setUserGid", data.char_gid)
        else
            -- 正常打开第一个就好
            DlgMgr:openDlgEx("HomeShowDlg", data)
            DlgMgr:sendMsg("BlogTabDlg", "setUserGid", data.char_gid)
        end
    end
end

function HomeMgr:MSG_MARRY_HOUSE_SHOW_DATA(data)
    data.isCouple = true
	self:MSG_HOUSE_SHOW_DATA(data)
end

function HomeMgr:MSG_HOUSE_ROOM_SHOW_DATA(data)
end

function HomeMgr:MSG_HOUSE_QUIT_MANAGE(data)
    self:clearFurnitures("opers", nil, true)
end

function HomeMgr:MSG_VISIT_HOUSE_FAILED(data)
end

function HomeMgr:isUsingById(id)
    if not self.specialFurnitureList then return end

    for i = 1, self.specialFurnitureList.count do
        if self.specialFurnitureList[i].id == id then
            return self.specialFurnitureList[i].isUseing == 1
        end
    end

    return false
end

function HomeMgr:MSG_HOUSE_FUNCTION_FURNITURE_LIST(data)
    self.specialFurnitureList = data
end

function HomeMgr:MSG_HOUSE_UPDATE_DATA(data)
    local storeType = data.store_type
    if self.myData and self.myData.storeType then
        self.myData.storeType = data.store_type
    end

    if DlgMgr:isDlgOpened("HomeStoreDlg") then
        -- 储物室空间已发生变化，请重新操作
        DlgMgr:closeDlg("HomeStoreDlg")
        DlgMgr:closeDlg("FurnitureInfoDlg")
        gf:ShowSmallTips(CHS[7003110])
        ChatMgr:sendMiscMsg(CHS[7003110])
    end
end

-- 请求居所玩家修炼数据
function HomeMgr:queryHourPlayerPractice(action, para)
--[[
    || action || memo || para ||
    | my_data | 居所外通过界面，获取修炼数据 | 无 |
    | use | 居所内通过家具，获取修炼数据 | furniture_pos |
    | friend_data | 好友的修炼数据 | 好友gid|
    | enter | 入阵 | furniture_pos |
    | leave | 出阵 | furniture_pos |
    | start | 开始修炼 | 无 |
    | stop | 停止修炼 | 无 |
    | bonus | 领取奖励 | 无 |
--]]
    gf:CmdToServer('CMD_HOUSE_PLAYER_PRACTICE', {action = action, para = para})
end

function HomeMgr:cmdHouseUseFurniture(pos, action, para1, para2)
    gf:CmdToServer("CMD_HOUSE_USE_FURNITURE", {furniture_pos = pos, action = action, para1 = para1 or "", para2 = para2 or ""})
end


function HomeMgr:getLevelStr(level)
    if level == 1 then
        return CHS[4100683]
    elseif level == 2 then
        return CHS[4100684]
    elseif level == 3 then
        return CHS[4100685]
    end

    return ""
end

function HomeMgr:MSG_PLAYER_PRACTICE_DATA(data)

    -- 更新下居所的清洁度
    if not self.myData then self.myData = {} end
    self.myData.cleanliness = data.cleanliness

    local fur = HomeMgr:getFurnitureById(data.furniture_pos)

    -- 居所外打开人物修炼界面fur为nil
    local dlg
    if fur then
        dlg = DlgMgr:openDlgEx("HomePlayerPracticeDlg", { furnitureId = data.furniture_pos, pX = fur.curX, pY = fur.curY })
    else
        dlg = DlgMgr:openDlg("HomePlayerPracticeDlg")
    end

    dlg:setPraticeData(data)
end

function HomeMgr:setPracticeHelpTargets(data)
    self.practiceHelpTargets = data
end

-- 获得耐久度信息（当前耐久度，最大耐久度）
function HomeMgr:getDurInfo(item)
    local dur = item.durability or item:queryBasicInt("durability")
    local maxDur = HomeMgr:getMaxDur(item.name or item:queryBasic("name"))
    return dur, maxDur
end

function HomeMgr:repairItem(item, cash)
    if not item then
        return
    end

    local furniture_pos = item.id or item:queryBasicInt("id")

    -- 这件家具的耐久度已达上限，无需进行修理。
    local dur, maxDur = HomeMgr:getDurInfo(item)
    if dur >= maxDur then
        gf:ShowSmallTips(CHS[7002350])
        return
    end

    if cash then
        local name = item.name or item:queryBasic("name")
        local moneyStr = gf:getMoneyDesc(cash)
        local tip = string.format(CHS[7002351], moneyStr, name)
        gf:confirm(tip, function()
            if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                gf:ShowSmallTips(CHS[5410117])
                return
            end

            gf:CmdToServer("CMD_HOUSE_REPAIR_FURNITURE", {furniture_pos = furniture_pos, cost = cash})
        end)
    end
end

-- 开始烹饪
function HomeMgr:startCookie(furniturePos, cookingName, num)
    gf:CmdToServer("CMD_HOUSE_START_COOKING", { furniture_pos = furniturePos, cooking_name = cookingName, num = num })
end

-- 获取招财纳福次数
function HomeMgr:MSG_ZCS_FURNITURE_APPLY_DATA(data)
    self.zhaoCaiNaFuNum = data
    if self.chooseMoneyTreeId then
        DlgMgr:openDlgEx("MoneyTreeDlg", self.chooseMoneyTreeId)
        self.chooseMoneyTreeId = nil
    end
end

function HomeMgr:MSG_HOUSE_ARTIFACT_VALUE(data)

    self.artifactEffData[data.furniture_pos] = data

        -- 更新下居所的清洁度
    if not self.myData then self.myData = {} end
    self.myData.cleanliness = data.cleanliness

    local fur = HomeMgr:getFurnitureById(data.furniture_pos)
    -- 炼器台和上古
    if fur and (fur:queryBasic("name") == CHS[4100675] or fur:queryBasic("name") == CHS[4100676]) then
        local icon = ResMgr.magic.shanggu_lianqi   -- 上古炼器
        if fur:queryBasic("name") == CHS[4100675] then  -- 炼器台
            icon = ResMgr.magic.lianqi
        end
        if data.cur_status == 1 then
            local magic = fur.image:getChildByTag(EFFECT_TAG)
            if not magic then
                magic = gf:createLoopMagic(icon, nil, {blendMode = "add"})
                magic:setTag(EFFECT_TAG)
                fur.image:addChild(magic)
            end
        else
            local magic = fur.image:getChildByTag(EFFECT_TAG)
            if magic then magic:removeFromParent() end
        end
    end

    if not self.artifactHomeData or not self.artifactHomeData[data.furniture_pos] then return end
    if data.isOpen == 1 then
        -- 居所外打开人物修炼界面fur为nil
        local dlg
        if fur then
            dlg = DlgMgr:openDlgEx("ArtifactPracticeDlg", { furnitureId = data.furniture_pos, pX = fur.curX, pY = fur.curY })
        else
            dlg = DlgMgr:openDlg("ArtifactPracticeDlg")
        end

        dlg:MSG_HOUSE_SELECT_ARTIFACT(self.artifactHomeData[data.furniture_pos])
    end
end

function HomeMgr:MSG_HOUSE_SELECT_ARTIFACT(data)
    self.artifactHomeData = self.artifactHomeData or {}
    self.artifactHomeData[data.furniture_pos] = data
end

-- 查看BUFF类家具数据
function HomeMgr:MSG_HOUSE_PRACTICE_BUFF_DATA(data)
    self.effectFurnitureData = data

    local dlg = DlgMgr:getDlgByName("EffectFurnitureDlg")
    if dlg then
        return
    end

    local furniture = HomeMgr:getFurnitureById(data.pos)
    if furniture then
        if furniture:queryBasic("name") == CHS[7190000] then -- 金丝鸟笼
            DlgMgr:openDlgEx("EffectFurnitureDlg", { type = 1, pos = data.pos, pX = furniture.curX, pY = furniture.curY })
        elseif furniture:queryBasic("name") == CHS[7190001] then -- 白玉观音像
            DlgMgr:openDlgEx("EffectFurnitureDlg", { type = 2, pos = data.pos, pX = furniture.curX, pY = furniture.curY })
        elseif furniture:queryBasic("name") == CHS[7190002] then -- 七宝如意
            DlgMgr:openDlgEx("EffectFurnitureDlg", { type = 3, pos = data.pos, pX = furniture.curX, pY = furniture.curY })
        end
    else

        local typeMap = {
            [1] = 2,
            [2] = 3,
            [3] = 1,
        }

        DlgMgr:openDlgEx("EffectFurnitureDlg", { type = typeMap[data.type], pos = data.pos })
    end
end

-- 获取当前已打开界面的Buff家具数据
function HomeMgr:getEffectFurnitureData()
    return self.effectFurnitureData
end

function HomeMgr:MSG_HOUSE_FURNITURE_EFFECT(data)
    -- 对比新旧数据差别，没有的先把光效干掉
    if self.effData and self.effData.count > 0 then
        for pos, oldData in pairs(self.effData.eff) do
            if not data.eff[pos] then
                local fur = HomeMgr:getFurnitureById(pos)
                if fur then
                    local furnitureName = fur:getName()
                    if FUNCTION_FURNITURE_MAGIC[furnitureName] then
                        -- 金丝鸟笼：龙骨动画,白玉观音像，七宝如意：骨骼动画，关闭
                        fur:tryToRemoveMagicOnFuncFurniture()
                    else
                        local magic = fur.image:getChildByTag(EFFECT_TAG)
                        if magic then magic:removeFromParent() end
                    end
                end
            end
        end
    end

    self.effData = data


end

function HomeMgr:MSG_HOUSE_CUR_ARTIFACT_PRACTICE(data)
    if data.furniture_pos > 0 then
        self.artifactPracticeInfo = data
    else
        self.artifactPracticeInfo = {}
    end
end

function HomeMgr:MSG_HOSUE_CUR_PLAYER_PRACTICE_INFO(data)
    if data.furniture_name ~= "" then
        self.playerPracticeInfo = data
    else
        self.playerPracticeInfo = {}
    end
end

-- 农田数据，用于居所入口界面显示
function HomeMgr:MSG_HOUSE_REQUEST_FARM_INFO(data)
    self.farmInfoForCheck = data
end

-- 获取所有种子或幼苗
function HomeMgr:getAllSeedsInfo()
     local seedsInfo = {}

     for _, v in pairs(FurnitureInfo) do
         if v.furniture_type == CHS[5400136] then
            local info = gf:deepCopy(v)
            table.insert(seedsInfo, info)
         end
     end

    return seedsInfo
end

-- 移除农田
function HomeMgr:clearAllCropland()
    if self.clickCroplandMagic then
        self.clickCroplandMagic:release()
        self.clickCroplandMagic = nil

        local path = ResMgr:getUIArmatureFilePath("01168")
        ArmatureMgr:removeArmatureFileInfoByName(path)
    end

    if self.croplandLayer then
        self.croplandLayer:removeFromParent()
        self.croplandLayer = nil
    end

    self.croplands = {}
end

-- 移除农作物
function HomeMgr:clearAllPlantCrops()
    for _, v in pairs(self.plantCrops) do
        if v then
            v:cleanup()
        end
    end

    for _, v in pairs(self.harvestCrops) do
        if v then
            v:cleanup()
        end
    end

    self.plantCrops = {}
    self.harvestCrops = {}
end

-- action 1 种植  2 打理  3 收获 4 铲除
function HomeMgr:requestFarmAction(action, farm_index, para)
    local mapInfo = MapMgr:getCurrentMapInfo()
    local str = CHS[5400149]
    if action == 1 then
        str = CHS[5400171]
    elseif action == 2 then
        str = CHS[5400163]
    elseif action == 3 then
        str = CHS[5400168]
    end

    -- 若玩家距离对应农田距离超过20格，则予以如下弹出提示：
    if mapInfo and mapInfo.croplands then
        local x, y = mapInfo.croplands[farm_index].x, mapInfo.croplands[farm_index].y
        if (x - Me.curX) * (x - Me.curX) + (y - Me.curY) * (y - Me.curY) > 480 * 480 then
            gf:ShowSmallTips(str)
            return
        end
    else
        gf:ShowSmallTips(str)
        return
    end

    gf:CmdToServer("CMD_HOUSE_FARM_ACTION", {action = action, farm_index = farm_index, para = para or ""})
end

-- 创建农田
function HomeMgr:creatCropland(icon, x, y)
    local image = ccui.ImageView:create(icon)
    image:setPosition(x, y)
    gf:getMapObjLayer():addChild(image, Const.ZORDER_CROPLAND)

    -- 点击农田的响应判断
    local function clickCroplandJudge(image)
        if HomeMgr:getHouseId() == Me:queryBasic("house/id") then
            -- 自己居所
            local ownCou, maxCou = self:getCropCount()
            if DlgMgr:isDlgOpened("HomePlantDlg") then
                if not self.croplandInfo[image.farmIndex] then
                    if ownCou == maxCou then
                        gf:ShowSmallTips(CHS[5400155])
                    else
                        DlgMgr:sendMsg("HomePlantDlg", "toPlant", image.farmIndex)
                    end
                elseif self.croplandInfo[image.farmIndex] then
                    DlgMgr:openDlgEx("CheekFarmDlg", image.farmIndex)
                end
            else
                if self.croplandInfo[image.farmIndex] then
                    DlgMgr:openDlgEx("CheekFarmDlg", image.farmIndex)
                elseif ownCou == maxCou then
                    gf:ShowSmallTips(CHS[5400155])
                else
                    gf:confirm(CHS[5400157], function()
                        if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
                            gf:ShowSmallTips(CHS[3002659])
                            return
                        end

                        local curMapName = MapMgr:getCurrentMapName()
                        if not curMapName or not string.match(curMapName, CHS[2000284]) then
                            gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000284]))
                            return
                        end

                        if not MapMgr:isInHouse(curMapName) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
                            gf:ShowSmallTips(CHS[5410115])
                            return
                        end

                        DlgMgr:openDlg("HomePlantDlg")
                    end)
                end
            end
        else
            -- 非自己居所
            if self.croplandInfo[image.farmIndex] then
                DlgMgr:openDlgEx("CheekFarmDlg", image.farmIndex)
            else
                gf:ShowSmallTips(CHS[5400156])
            end
        end

        return true
    end

    local rect = {["height"] = 60,["width"] = 120,["x"] = 36,["y"] = 22}

    if self.croplandLayer then
        return image
    end

    self.croplandLayer = cc.Layer:create()
    gf:getCharTopLayer():addChild(self.croplandLayer)

    local function containsTouchPos(touch)
        local croplands = self.croplands
        for _, v in ipairs(croplands) do
            if v.isDigUp then
                local pos = v:convertTouchToNodeSpace(touch)
                local rect = {["height"] = 60,["width"] = 120,["x"] = 36,["y"] = 22}
                if cc.rectContainsPoint(rect, pos) then
                    return v
                end
            end
        end
    end

    local clickObj
    local function clickCropLand(sender, event)
        if event:getEventCode() == cc.EventCode.BEGAN then
            if self.isClickCropland then
                return
            end

            clickObj = containsTouchPos(sender)
            if not clickObj
                or not clickObj.isDigUp
                or DlgMgr:isDlgOpened("HomePuttingDlg")
                or DlgMgr:isDlgOpened("ItemPuttingDlg")
                or Me:isInCombat()
                or Me:isLookOn() then
                -- 打开家具摆放界面，点击农田不响应
                return false
            end

            self.isClickCropland = true
            self.clickCroplandMagic:setPosition(96, 59)
            self.clickCroplandMagic:getAnimation():play("Bottom")
            clickObj:addChild(self.clickCroplandMagic)
        elseif event:getEventCode() == cc.EventCode.ENDED then
            self.clickCroplandMagic:removeFromParent()
            if gf:distance(Me.curX, Me.curY, clickObj.x, clickObj.y) > 480 then
                -- 距离超过 20 格开启自动寻路
                local clickAutoWalk = {}
                clickAutoWalk.map = MapMgr:getCurrentMapName()
                clickAutoWalk.action = "$2"
                clickAutoWalk.npc = ""
                clickAutoWalk.isClickNpc = true
                clickAutoWalk.npcId = ""
                local mx, my = gf:convertToMapSpace(clickObj.x, clickObj.y)
                -- 农田中心是障碍点
                clickAutoWalk.x = mx + 1
                clickAutoWalk.y = my + 2
                clickAutoWalk.destCallback = {func = clickCroplandJudge, para = clickObj}

                AutoWalkMgr:beginAutoWalk(clickAutoWalk)
            else
                -- 停止自动寻路
                Me:setAct(Const.SA_STAND, true)
                AutoWalkMgr:stopAutoWalk()

                clickCroplandJudge(clickObj)
            end

            self.isClickCropland = false
        elseif event:getEventCode() == cc.EventCode.CANCELLED then
            self.clickCroplandMagic:removeFromParent()
            self.isClickCropland = false
        end

        return true
    end

    gf:bindTouchListener(self.croplandLayer, clickCropLand, {
    cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)
    return image
end

function HomeMgr:getCropIcon(data)
    local info = HomeMgr:getFurnitureInfoById(data.class_id)
    if not info then
        return
    end

    local time = gf:getServerTime() - data.start_time
    local harvest_time = info.harvest_time * 3600
    if harvest_time > time * 3 then
        return info.harvest_icon, 1
    elseif harvest_time <= time then
        return info.harvest_icon, 3, true
    else
        return info.harvest_icon, 2
    end
end

-- 获取当前总农田数及已种植的农田数
function HomeMgr:getCropCount()
    local cou = 0
    for _, v in pairs(self.croplandInfo) do
       if type(v) == "table" and v.isMy == 1 then
          cou = cou + 1
       end
    end

    return cou, CROPLAND_MAX_LAND[MapMgr:getCurrentMapName()] or 0
end

-- 返回家具等级表：level,中文
function HomeMgr:furnitureLevelToChs()
    return FURNITURE_LEVEL
end

-- 完成居民委托
function HomeMgr:cmdEntrust(npc)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[2000280])
        return
    end

    gf:CmdToServer("CMD_HOUSE_ENTRUST", { index = npc.index })
end

-- 获取宠物小屋数据
function HomeMgr:getHousePetStoreData()
    return self.housePetStoreData
end

function HomeMgr:MSG_HOUSE_FARM_DATA(data)
    local mapInfo = MapMgr:getCurrentMapInfo()
    local lands = mapInfo.croplands

    if not lands then
        return
    end

    self.croplandInfo = data
    for i = 1, #lands do
        local land = lands[i]
        local cropland
        -- 设置开垦的农田
        if not self.croplands[i] then
            if i <= data.active_farm_count then
                cropland = self:creatCropland(ResMgr.ui.cultivated_farmland, land.x, land.y, i)
                cropland.isDigUp = true
                cropland.farmIndex = i
                cropland.x = land.x
                cropland.y = land.y
            else
                cropland = self:creatCropland(ResMgr.ui.uncultivated_farmland, land.x, land.y, i)
                cropland.isDigUp = false
                cropland.farmIndex = i
            end

            self.croplands[i] = cropland
        end

        -- 显示农作物
        if data[i] and data[i].class_id > 0 then
            local v = data[i]
            local info = self:getFurnitureInfoById(v.class_id)
            local crop = self.plantCrops[v.farm_index]
            local land = lands[v.farm_index]
            if land then
                local crop = self.plantCrops[v.farm_index]
                if not crop then
                    -- 创建农作物
                    crop = Furniture.new()
                    local icon, iconNo = self:getCropIcon(v)
                    crop:absorbBasicFields({
                        icon = icon,
                        icon_no = iconNo,
                        furniture_type = info.furniture_type,
                        name = info.name
                    })

                    crop:setVisible(true)
                    crop:action(false, false)
                    crop:onEnterScene(0, 0)
                    crop:setPos(land.x, land.y)

                    if v.status > 0 then
                        crop:showPlantPanel(true, v.status, v.farm_index)
                    end

                    crop.cropStatus = v.status
                    self.plantCrops[v.farm_index] = crop

                    if self.croplands[v.farm_index].isPlayingMagic then
                        -- 等播放完播种光效再显示
                        crop:setVisible(false)
                    end
                else
                    if v.status == HOME_CROP_STAUES.STATUS_FINISH then
                        if HomeMgr:getHouseId() == Me:queryBasic("house/id")
                            and v.isMy == 1 then
                            -- 农作物只有自己才可以看到收获标识
                            crop:showPlantPanel(true, v.status, v.farm_index)
                        else
                            crop:showPlantPanel(false, nil, v.farm_index)
                        end
                    elseif v.status > 0 then
                        crop:showPlantPanel(true, v.status, v.farm_index)
                    else
                        crop:showPlantPanel(false, nil, v.farm_index)
                    end

                    crop.cropStatus = v.status
                end
            end
        else
            local land = self.croplands[i]
            if self.plantCrops[i] then
                -- 农作物移除时用光效，要在播完光效的回调函数中移除
                if land and land.isPlayingHarvestMagic then
                    self.plantCrops[i]:showPlantPanel(false, nil, i)
                else
                self.plantCrops[i]:cleanup()
                end

                self.plantCrops[i] = nil
            end

            if land then
                land:removeChildByTag(Const.PLANT_EARTH_CRACKED_TAG)
            end
        end
    end

    if not self.clickCroplandMagic then
        -- 创建点击农田光效
        self.clickCroplandMagic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.click_cropland.name)
        self.clickCroplandMagic:setAnchorPoint(0.5, 0.5)
        self.clickCroplandMagic:retain()
        self.isClickCropland = false
    end
end

-- clear_status 0 种植，1 除草，2 除虫，3 浇水，4 收获
function HomeMgr:MSG_FARM_PLAY_EFFECT(data)
    local farmIndex = data.farm_index
    local crop = self.plantCrops[farmIndex]
    local land = self.croplands[farmIndex]
    if not land then
        return
    end

    local icon
    if data.clear_status == 0 then
        -- 播种
        icon = ResMgr.magic.plant_seed
        land.isPlayingMagic = true
        local function removeMagic()
            land:removeChildByTag(icon)
            if self.plantCrops[farmIndex] then
                if not Me:isInCombat() and not Me:isLookOn() then
                    self.plantCrops[farmIndex]:setVisible(true)
                end
            end

            land.isPlayingMagic = false
        end

        local magic = gf:createCallbackMagic(icon, removeMagic, {frameInterval = 65})

        local size = land:getContentSize()
        magic:setPosition(size.width / 2, size.height)
        magic:setAnchorPoint(0.5, 0.5)
        land:addChild(magic, 0, icon)
        return
    end

    if not crop then
        return
    end

    if data.clear_status == 1 and crop.image then
        -- 杂草丛生
        icon = ResMgr.magic.plant_weeding
        land.isPlayingMagic = true
        local function removeMagic()
            crop:removeIcon(icon)
            if crop.middleLayer then
                crop.middleLayer:removeChildByTag(Const.PLANT_WEED_TAG)
            end

            land.isPlayingMagic = false
        end

        if crop.middleLayer then
            local showImage = crop.middleLayer:getChildByTag(Const.PLANT_WEED_TAG)
        if showImage then
            local action = cc.FadeOut:create(0.8)
            showImage:runAction(action)
        end
        end

        crop:addIcon(icon, true, {callback = removeMagic, frameInterval = 65})
    elseif data.clear_status == 2 then
        -- 害虫生长
        icon = ResMgr.magic.plant_kill_insect
        land.isPlayingMagic = true
        local function removeMagic()
            crop:removeIcon(icon)
            crop:removeIcon(ResMgr.magic.plant_has_insect)
            land.isPlayingMagic = false
        end

        local showImage = crop.icons[ResMgr.magic.plant_has_insect]
        if showImage then
            local action = cc.FadeOut:create(0.8)
            showImage:runAction(action)
        end

        crop:addIcon(icon, true, {callback = removeMagic, scaleX = 0.93, scaleY = 0.93, blendMode = "add", frameInterval = 65})
    elseif data.clear_status == 3 then
        -- 土壤缺水
        icon = ResMgr.magic.plant_water
        land.isPlayingMagic = true
        local function removeMagic()
            crop:removeIcon(icon)
            land:removeChildByTag(Const.PLANT_EARTH_CRACKED_TAG)
            land.isPlayingMagic = false
        end

        local showImage = land:getChildByTag(Const.PLANT_EARTH_CRACKED_TAG)
        if showImage then
            local action = cc.FadeOut:create(1)
            showImage:runAction(action)
        end

        crop:addIcon(icon, true, {callback = removeMagic, frameInterval = 65})
    elseif data.clear_status == 4 then
        -- 收获
        icon = ResMgr.magic.plant_harvest
        land.isPlayingHarvestMagic = true

        if self.harvestCrops[farmIndex] then
            self.harvestCrops[farmIndex]:removeFromParent()
        end

        self.harvestCrops[farmIndex] = crop
        local function removeMagic()
            if self.harvestCrops[farmIndex] then
                self.harvestCrops[farmIndex]:cleanup()
                self.harvestCrops[farmIndex] = nil
        end

            land.isPlayingHarvestMagic = false
        end

        local action = cc.FadeOut:create(0.8)
        if crop.image then
            crop.image:runAction(action)
            local magic = gf:createCallbackMagic(icon, removeMagic, {frameInterval = 65, blendMode = "add"})

            magic:setPosition(0, -4 - Const.CULTIVATED_HEIGHT)
            magic:setAnchorPoint(0.5, 0)
            crop:addToMiddleLayer(magic)
        end
    end
end

function HomeMgr:MSG_HOUSE_ENTRUST(data)
    DlgMgr:openDlgEx("HomeEntrustDlg", data)
end

function HomeMgr:MSG_HOUSE_FISH_BASIC(data)
    self.playerFishingInfo[data.gid] = data
end

function HomeMgr:MSG_HOUSE_USE_FISH_TOOL(data)
    local player = self.playerFishingInfo[data.gid]
    if player then
        player.pole_name = data.pole_name
        player.bait_name = data.bait_name
        player.pole_count = data.pole_count
        player.bait_count = data.bait_count
    end
end

function HomeMgr:MSG_HOSUE_QUIT_FISH(data)
    if Me:queryBasic("gid") == data.gid then
        self.playerFishingInfo = {}
    else
        self.playerFishingInfo[data.gid] = nil
    end
end

-- 更新所有鱼具消息
function HomeMgr:MSG_HOUSE_ALL_FISH_TOOL_INFO(data)
    if Me:queryBasic("gid") == data.gid then
        self.allFishToolsInfo = data
    end
end

-- 更新部分鱼具消息
function HomeMgr:MSG_HOUSE_FISH_TOOL_PART_INFO(data)
    if not self.allFishToolsInfo then
        return
    end

    if self.allFishToolsInfo.gid == data.gid then
        local tools
        if data.tool_type == 1 then
            tools = self.allFishToolsInfo.poles
        else
            tools = self.allFishToolsInfo.baits
        end

        for key, v in pairs(data.tools) do
            tools[key] = v
        end
    end

    local info = HomeMgr.playerFishingInfo[data.gid]
    if info then
        info.pole_count = data.tools[info.pole_name] or info.pole_count
        info.bait_count = data.tools[info.bait_name] or info.bait_count
    end
end

function HomeMgr:MSG_EXCHANGE_MATERIAL_TARGETS(data)
    self.exchangeMaterialInfo = data
end

-- 提交所需材料
function HomeMgr:submitNeedMaterial(index, item_name, num)
    index = index + 10
    gf:CmdToServer('CMD_SUBMIT_NEED_EXCHANGE_MATERIAL', {index = index, item_name = item_name, num = num})
end

-- 提交赠礼材料
function HomeMgr:submitGift(index, item_pos, num)
    index = index + 20
    gf:CmdToServer('CMD_SUBMIT_GIFT_EXCHANGE_MATERIAL', {index = index, item_pos = item_pos, num = num})
end

-- 移除赠礼材料
function HomeMgr:removeNeed(index)
    index = index + 10
    gf:CmdToServer('CMD_UNSUBMIT_NEED_EXCHANGE_MATERIAL', {index = index})
end

-- 移除赠礼材料
function HomeMgr:removeGift(index)
    index = index + 20
    gf:CmdToServer('CMD_UNSUBMIT_GIFT_EXCHANGE_MATERIAL', {index = index})
end

-- 发布
function HomeMgr:publishExchange(msg)
    msg = msg or ""
    gf:CmdToServer('CMD_PUBLISH_EXCHANGE_MATERIAL', {msg = msg})
end

-- 撤销
function HomeMgr:unPublishExchange()
    gf:CmdToServer('CMD_UNPUBLISH_EXCHANGE_MATERIAL')
end

-- 可领取的材料邮件
function HomeMgr:queryGetList()
    gf:CmdToServer('CMD_EXCHANGE_MATERIAL_MAILBOX')
end

function HomeMgr:getExchangeData()
    return self.exchangeData
end

-- 生活物品交互中，领取
function HomeMgr:getGiftBymail(id)
    local data = {}
    data.type = SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_MATERIAL
    data.id = id
    data.operate = 1 --详见 SystemMessageMgr中SYSMSG_OPERATE
    gf:CmdToServer("CMD_MAILBOX_OPERATE", data)
end


-- 玩家自己的材料交换数据
function HomeMgr:MSG_ME_EXCHANGE_MATERIAL_DATA(data)
    self.exchangeData = data

    if data.has_material_unfetch == 1 then
        RedDotMgr:insertOneRedDot("HomeMaterialTabDlg", "AskPanelCheckBox")
    end
end

function HomeMgr:setFurnitureAndCropsVisible(isVisible)
    -- 家具
    for _, v in pairs(self.furnitures) do
        v:setVisible(isVisible)
    end

    -- 农作物
    for _, v in pairs(self.plantCrops) do
        v:setVisible(isVisible)
    end
end

function HomeMgr:saveWoodSoldierValue(values)
    self.woodSoldierValue = values or {}
    cc.UserDefault:getInstance():setStringForKey("HomeWoodSoldier_" .. Me:queryBasic("gid"), json.encode(self.woodSoldierValue))
end

function HomeMgr:getWoodSoldierValue()
    if not self.woodSoldierValue then
        local str = cc.UserDefault:getInstance():getStringForKey("HomeWoodSoldier_" .. Me:queryBasic("gid"))
        if not string.isNilOrEmpty(str) then
            self.woodSoldierValue = json.decode(str)
        else
            self.woodSoldierValue = {}
        end
    end
    return self.woodSoldierValue or {}
end

function HomeMgr:MSG_HOUSE_COMBATING_PUPPET_LIST(data)
    if data.count <= 0 then return end

    local furniture
    for i = 1, #data.values do
        furniture = self:getFurnitureById(data.values[i].id)
        if furniture then
            furniture:setFightState(1 == data.values[i].state)
        end
    end
end

-- 管家相关

-- 获取管家数据
function HomeMgr:getGjData()
    return self.gjData
end

function HomeMgr:MSG_HOUSE_ALL_GUANJIA_INFO(data)
    self.gjData = data
end

function HomeMgr:MSG_HOUSE_GJ_ACTION(data)
    local function showAction(data)
        local npcId = data.npc_id
        local char = CharMgr:getChar(npcId)
        if char then
            if char:queryBasicInt("icon") == 51514 or char:queryBasicInt("icon") == 51513 then
                local onActionEnd = char.onActionEnd
                char.onActionEnd = function(self)
                    char:setAct(Const.FA_STAND)
                    char.onActionEnd = onActionEnd
                end
                char:setAct(Const.FA_BOW)
                -- char:setAct(Const.FA_ACTION_FLEE)
            end
            local chatData = {}
            chatData["channel"] = CHAT_CHANNEL["CURRENT"]
            chatData["msg"] = data.msg
            chatData["name"] = char:getName()
            chatData["icon"] = char:queryBasicInt("icon")
            chatData["time"] = gf:getServerTime()
            chatData["compress"] = 0
            chatData["orgLength"] = string.len(data.msg)
            ChatMgr:MSG_MESSAGE(chatData)
            char:setChat({time = gf:getServerTime(), show_time = 3, msg = data.msg})
        end
    end

    if DlgMgr:isDlgOpened("LoadingDlg") then
        local dlg = DlgMgr:getDlgByName("LoadingDlg")
        dlg:registerExitCallBack(function()
            showAction(data)
        end)
        return
    else
        showAction(data)
    end
end

-- 丫鬟数据
function HomeMgr:getMaidCfg()
    return MAIDS
end

function HomeMgr:getMaidInfoByType(mType)
    for i = 1, #MAIDS do
        if MAIDS[i].type == mType then
            return MAIDS[i]
        end
    end
end

function HomeMgr:getMaidData()
    return self.maidData
end

function HomeMgr:getMaidByType(yhType)
    if not self.maidData then return end

    local count = self.maidData.npcs and #(self.maidData.npcs) or 0
    for i = 1, count do
        if self.maidData.npcs[i].yh_type == yhType then
            return self.maidData.npcs[i]
        end
    end
end

function HomeMgr:getHomeMaidNumLimitByType(houseType)
    return MAID_NUM_LIMIT[houseType]
end

function HomeMgr:getHomeMaidNumLimit()
    local houseType = self:getHomeType()
    return MAID_NUM_LIMIT[houseType]
end

function HomeMgr:MSG_HOUSE_ALL_YH_INFO(data)
    self.maidData = data
end

-- 园丁数据
function HomeMgr:getYdData()
    return self.ydData or {}
end

function HomeMgr:MSG_HOUSE_ALL_YD_INFO(data)
    self.ydData = data
end

function HomeMgr:getLuBanFur()
    return LuBanFur
end

-- 居所管家配置
function HomeMgr:getHomeManagersConfig()
    return MANAGERS
end

function HomeMgr:requestCanHelpFriendNum()
    if not SystemMessageMgr:getIsSwichServer() then
        gf:CmdToServer("CMD_HOUSE_FARM_HELP_TARGETS_NUM", {})
    end
end

-- 根据需要帮助的好友列数量添加小红点
function HomeMgr:MSG_HOUSE_FARM_HELP_TARGETS_NUM(data)
    if data.num > 0 then
        RedDotMgr:insertOneRedDot("GameFunctionDlg", "HomeButton", nil, "helpPlant")
        RedDotMgr:insertOneRedDot("HomeTabDlg", "PlantDlgCheckBox", nil, "helpPlant")
        RedDotMgr:insertOneRedDot("HomePlantCheckDlg", "HelpButton", nil, "helpPlant")
    end
end

function HomeMgr:MSG_HOUSE_ALL_PRACTICE_BUFF_DATA(data)
    self.allPracticeBuffData = data
end

function HomeMgr:getPracticeBuffByType(type)
    -- type
    -- 1 人物
    -- 2 法宝
    -- 3 宠物
    if self.allPracticeBuffData and self.allPracticeBuffData[type] then
        return self.allPracticeBuffData[type]
    end
end

function HomeMgr:isInMyHouse()
    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) and HomeMgr:getHouseId() == Me:queryBasic("house/id") then
        return true
    end
end

function HomeMgr:getSpcialFurnitureAction(furm, flipAction, notFlipAction)
    if furm:queryBasic("name") == CHS[4010428] then
        local effData = HomeMgr.effData.eff[furm:queryBasicInt("id")]
        if effData then
            if effData.effIcon == 51531 or effData.effIcon == 51536 then
                flipAction = flipAction .. "_1"
                notFlipAction = notFlipAction .. "_1"
            elseif effData.effIcon == 51530 or effData.effIcon == 51535 then
                flipAction = flipAction .. "_2"
                notFlipAction = notFlipAction .. "_2"
            end
        end
    end

    return flipAction, notFlipAction
end

function HomeMgr:MSG_HOUSE_PET_STORE_DATA(data)
    if not self.housePetStoreData then
        self.housePetStoreData = {}
    end

    self.housePetStoreData.max_size = data.max_size
    self.housePetStoreData.cur_size = data.cur_size

    if not DlgMgr:getDlgByName("PetHouseDlg") then
        DlgMgr:openDlgEx("PetHouseDlg", data.furniture_pos)
    end
end

function HomeMgr:MSG_HOUSE_SHOW_PET_STORE_LIST(data)
    for i = 1, #data.pets do
        local pd = data.pets[i]
        local furniture = self:getFurnitureById(pd.furniture_pos)
        if furniture then
            local pid = i
            local pet = self.storeShowPets[pid]
            if not pet then
                local mapX, mapY = gf:convertToMapSpace(furniture.curX, furniture.curY)

                -- 获取宠物起始坐标
                local x, y = self:getNearFirstPos(mapX, mapY)

                if not x or not y then
                    return
                end

                pet = require("obj/Pet").new()

                pet:absorbBasicFields({
                    name = pd.name,
                    icon = pd.icon,
                })

                -- 行走速度 = 正常人物行走速度 * 0.7
                pet:setSeepPrecent(-30)

                pet:onEnterScene(x, y)

                -- 初始位置
                pet:setPos(gf:convertToClientSpace(x, y))

                pet:setAct(Const.SA_STAND)

                -- 随机行走
                local petWalkcenter = {x = mapX, y = mapY}
                self:setPetRandomWalk(pet, petWalkcenter)

                -- 随机喊话
                self:setPetRandomTalkEx(pet, 2, 20, 20, function()
                    if CharMgr:hasCharByGids(data.owner_gid, data.couple_gid) then
                        return PET_HOUSE_RANDOM_TALK[2]
                    else
                        return PET_HOUSE_RANDOM_TALK[1]
                    end
                end, function(arg)
                    if 'string' == type(arg) then
                        return arg
                    else
                        local ret = CharMgr:getCharByGids(data.owner_gid, data.couple_gid)
                        if ret then
                            if #ret > 1 then
                                return arg[3]
                            else
                                local char = ret[1]
                                local icon = char:queryBasicInt("org_icon")
                                local gender = gf:getGenderByIcon(icon)
                                return "1" == gender and arg[1] or arg[2]
                            end
                        end
                    end
                end)


                self.storeShowPets[pid] = pet
            else
                local mapX, mapY = gf:convertToMapSpace(furniture.curX, furniture.curY)
                -- 获取宠物起始坐标
                local x, y = self:getNearFirstPos(mapX, mapY)
                if x and y then
                    pet:setPos(gf:convertToClientSpace(x, y))
                end
                local petWalkcenter = {x = mapX, y = mapY}
                self:setPetRandomWalk(pet, petWalkcenter)

                -- 更新数据
                pet:absorbBasicFields({
                    name = pd.name,
                    icon = pd.icon,
                })
            end
        end
    end

    for i = #data.pets + 1, 3 do
        local pet = self.storeShowPets[i]
        if pet then
            pet:cleanup()
        end

        self.storeShowPets[i] = nil
    end
end

function HomeMgr:MSG_HOUSE_TDLS_MENU(data)
    if not HomeMgr.furnitureListDlgrect then return end
    local furnitureInfo = HomeMgr:getFurnitureById(data.no)
    if not furnitureInfo then return end

    local dlg = DlgMgr:openDlg("FurnitureListDlg")
    local dlgContentSize = dlg.root:getContentSize()
    dlg:setInfo("furniture", furnitureInfo, nil, data.menu)
    dlg:setFloatingFramePos(HomeMgr.furnitureListDlgrect)

    HomeMgr.furnitureListDlgrect = nil
end

MessageMgr:regist("MSG_HOUSE_TDLS_MENU", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FARM_HELP_TARGETS_NUM", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ALL_PRACTICE_BUFF_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FURNITURE_EFFECT", HomeMgr)
MessageMgr:regist("MSG_HOUSE_SELECT_ARTIFACT", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ARTIFACT_VALUE", HomeMgr)
MessageMgr:regist("MSG_OPEN_MODIFY_HOUSE_SPACE_DLG", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FURNITURE_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FURNITURE_DATA_PAGE", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FURNITURE_OPER", HomeMgr)
MessageMgr:regist("MSG_ADD_HOUSE_FURNITURE_DATA", HomeMgr)
MessageMgr:regist("MSG_BEDROOM_FURNITURE_APPLY_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_SEX_LOVE_ANIMATE",HomeMgr)
MessageMgr:regist("MSG_HOUSE_REST_ANIMATE", HomeMgr)
MessageMgr:regist("MSG_HOUSE_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_SHOW_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ROOM_SHOW_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_QUIT_MANAGE", HomeMgr)
MessageMgr:regist("MSG_VISIT_HOUSE_FAILED", HomeMgr)
MessageMgr:regist("MSG_MARRY_HOUSE_SHOW_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FUNCTION_FURNITURE_LIST", HomeMgr)
MessageMgr:regist("MSG_HOUSE_UPDATE_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_PET_FEED_VALUE_INFO", HomeMgr)
MessageMgr:regist("MSG_HOUSE_PET_FEED_FOOD_INFO", HomeMgr)
MessageMgr:regist("MSG_HOUSE_PET_FEED_SELECT_PET", HomeMgr)
MessageMgr:regist("MSG_HOUSE_PET_FEED_STATUS_INFO", HomeMgr)
MessageMgr:regist("MSG_PLAYER_PRACTICE_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_CUR_ARTIFACT_PRACTICE", HomeMgr)
MessageMgr:regist("MSG_HOSUE_CUR_PLAYER_PRACTICE_INFO", HomeMgr)
MessageMgr:regist("MSG_HOUSE_REQUEST_FARM_INFO", HomeMgr)
MessageMgr:regist("MSG_ZCS_FURNITURE_APPLY_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FARM_DATA", HomeMgr)
MessageMgr:regist("MSG_FARM_PLAY_EFFECT", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ENTRUST", HomeMgr)

MessageMgr:regist("MSG_HOUSE_FISH_BASIC", HomeMgr)
MessageMgr:regist("MSG_HOUSE_USE_FISH_TOOL", HomeMgr)
MessageMgr:regist("MSG_HOSUE_QUIT_FISH", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ALL_FISH_TOOL_INFO", HomeMgr)
MessageMgr:regist("MSG_HOUSE_FISH_TOOL_PART_INFO", HomeMgr)

MessageMgr:regist("MSG_EXCHANGE_MATERIAL_TARGETS", HomeMgr)
MessageMgr:regist("MSG_ME_EXCHANGE_MATERIAL_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ALL_GUANJIA_INFO", HomeMgr)
MessageMgr:regist("MSG_HOUSE_GJ_ACTION", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ALL_YH_INFO", HomeMgr)
MessageMgr:regist("MSG_HOUSE_ALL_YD_INFO", HomeMgr)

MessageMgr:regist("MSG_HOUSE_PRACTICE_BUFF_DATA", HomeMgr)

MessageMgr:regist("MSG_HOUSE_COMBATING_PUPPET_LIST", HomeMgr)
MessageMgr:regist("MSG_LD_GENERAL_INFO", HomeMgr)
MessageMgr:regist("MSG_HOUSE_PET_STORE_DATA", HomeMgr)
MessageMgr:regist("MSG_HOUSE_SHOW_PET_STORE_LIST", HomeMgr)

HomeMgr:init()
