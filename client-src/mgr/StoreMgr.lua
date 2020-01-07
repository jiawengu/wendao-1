-- StoreMgr.lua
-- Created by songcw Aug/26/2015
-- 仓库管理器

StoreMgr = Singleton()
local Bitset = require('core/Bitset')
local Pet = require('obj/Pet')
local ItemInfo = require (ResMgr:getCfgPath("ItemInfo.lua"))
local FurnitureInfo = require (ResMgr:getCfgPath("FurnitureInfo.lua"))

StoreMgr.storeItems = {}
StoreMgr.homeStoreItems = {}
StoreMgr.coupleHomeStoreItems = {}
StoreMgr.storePets = {}
StoreMgr.storeCards = {}
StoreMgr.storeFunritures = {}
StoreMgr.storeFashions = {}
StoreMgr.storeCustoms = {}
StoreMgr.storeEffects = {}
StoreMgr.storeFollowPets = {}
StoreMgr.storeHousePets = {}

local ONE_STORE_COUNT = 25
local STORE_POS_START = 201
local PET_POS_START = 351
local HOME_STORE_POS_START = 501  -- 个人储物室中的物品起始pos
local COUPLE_HOME_STORE_START = 601 -- 夫妻储物室中对方的物品起始pos
local HOUSE_PET_POS_START = 801

local STORE_START_1 = ONE_STORE_COUNT * 0 + STORE_POS_START
local STORE_START_2 = ONE_STORE_COUNT * 1 + STORE_POS_START
local STORE_START_3 = ONE_STORE_COUNT * 2 + STORE_POS_START
local STORE_START_4 = ONE_STORE_COUNT * 3 + STORE_POS_START
local STORE_END = STORE_START_4 + ONE_STORE_COUNT - 1

local HOME_STORE_START_1 = ONE_STORE_COUNT * 0 + HOME_STORE_POS_START
local HOME_STORE_START_2 = ONE_STORE_COUNT * 1 + HOME_STORE_POS_START
local HOME_STORE_END = HOME_STORE_START_2 + ONE_STORE_COUNT - 1

local COUPLE_HOME_STORE_START_1 = ONE_STORE_COUNT * 0 + COUPLE_HOME_STORE_START
local COUPLE_HOME_STORE_START_2 = ONE_STORE_COUNT * 1 + COUPLE_HOME_STORE_START
local COUPLE_HOME_STORE_END = COUPLE_HOME_STORE_START_2 + ONE_STORE_COUNT - 1


-- 家具列表
local FURNITURE_STORE_START = 3001
local FURNITURE_STORE_COUNT = 500

-- 可叠加的数量
local ITEM_MAX_AMOUNT = {
    [0] = 999,
    [1] = 10,
    [2] = 1,
}

local CARD_START = 2001
local CARD_OPEN_COUNT = 500        -- 最大500，又服务器通知，所以默认500。MSG_CL_CARD_INFO修改
local CARD_OPEN_COUNT_MAX = 500

-- 宠物仓库最大数量   根据vip等级
local PET_MAX_COUNT = {
    8, 10, 12, 14,
}

local TYPE_TO_DLG = {
    [STORE_TYPE.NORMAL_STORE] = "StoreItemDlg",
    [STORE_TYPE.HOME_STORE] = "HomeStoreDlg",
}

-- 获取道具可堆叠的最大个数
local function getItemDoubleMax(item)
    return InventoryMgr:getItemDoubleMax(item)
end

-- 清除数据
function StoreMgr:cleanup()
    StoreMgr.storeItems = {}
    StoreMgr.storePets = {}
    StoreMgr.homeStoreItems = {}
    StoreMgr.coupleHomeStoreItems = {}
    StoreMgr.storeCards = {}
    StoreMgr.storeFunritures = {}
    StoreMgr.storeFashions = {}
    StoreMgr.storeCustoms = {}
    StoreMgr.storeEffects = {}
    StoreMgr.storeFollowPets = {}

    StoreMgr.cardGotInfo = nil
    StoreMgr.cardTop = nil

    StoreMgr.isArranging = false

    CARD_OPEN_COUNT = 500
end

function StoreMgr:setStoreType(type)
    self.storeType = type
end

function StoreMgr:getStoreType()
    return self.storeType or STORE_TYPE.NORMAL_STORE
end

function StoreMgr:getStoreItems()
    local type = self:getStoreType()
    if type == STORE_TYPE.HOME_STORE then
        return self.homeStoreItems
    elseif type == STORE_TYPE.NORMAL_STORE then
        return self.storeItems
    end
end

function StoreMgr:getCoupleStoreItems()
    return self.coupleHomeStoreItems
end

function StoreMgr:getStartPos()
    local type = self:getStoreType()
    if type == STORE_TYPE.HOME_STORE then
        return HOME_STORE_POS_START
    elseif type == STORE_TYPE.NORMAL_STORE then
        return STORE_POS_START
    end
end

function StoreMgr:getEndPos()
    local type = self:getStoreType()
    if type == STORE_TYPE.HOME_STORE then
        return HOME_STORE_END
    elseif type == STORE_TYPE.NORMAL_STORE then
        return STORE_END
    end
end

-- 获取起始位置
function StoreMgr:getStartPosByType(storeType)
    if storeType == "pet" then
        return PET_POS_START
    elseif storeType == "home_store" then
        return HOME_STORE_POS_START
    else
        return STORE_POS_START
    end
end

-- 发送消息请求仓库信息   para1: 1仓库  2宠物  4居所储物室      para2:1 需要获取数据
function StoreMgr:cmdStoreItemsInfo()
    if not next(StoreMgr.storeItems) then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 1, 1)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 1)
    end
end

-- 居所储物室-请求信息
function StoreMgr:cmdHomeStoreItemsInfo(needRefresh)
    if (not next(StoreMgr.homeStoreItems)) or needRefresh then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 4, 1)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 4)
    end
end

function StoreMgr:cmdCloseStoreItems()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_STORE, 1)
end

function StoreMgr:cmdCloseStorePets()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_STORE, 2)
end

function StoreMgr:isExistData()
    if not next(StoreMgr.storeItems) then
        return false
    end

    return true
end

function StoreMgr:cmdStorePetsInfo()
    if not next(StoreMgr.storePets) then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 2, 1)
        return true
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 2)
        return false
    end
end

function StoreMgr:cmdHouseStorePetsInfo()
    if not next(StoreMgr.storePets) then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 7, 1)
        return true
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 7)
        return false
    end
end

function StoreMgr:cmdCloseHouseStorePets()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_STORE, 7)
end

function StoreMgr:cmdBagToStore(pos)
    local type = self:getStoreType()
    local storeItems = self:getStoreItems()

    local item = InventoryMgr:getItemByPos(pos)
    if not item then return end

    if type == STORE_TYPE.HOME_STORE then
        if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
            gf:ShowSmallTips(CHS[7003106])
            return
        end
    end

    if not StoreMgr:isCanStoreByItem(item) then
        if type == STORE_TYPE.HOME_STORE then
            gf:ShowSmallTips(CHS[7002346])
        elseif type == STORE_TYPE.NORMAL_STORE then
            gf:ShowSmallTips(CHS[3004353])
        end

        return
    end

    DlgMgr:sendMsg(TYPE_TO_DLG[type], "removeLastSelect")

    -- 向服务器发送存入消息前，先判断是否已经过期了
    if InventoryMgr:isItemTimeout(storeItems[pos]) then
        InventoryMgr:notifyItemTimeout(storeItems[pos])
        return
    end

    gf:CmdToServer("CMD_STORE", {id = 0, from_pos = pos, to_pos = 0, amount = 0, container = type })
end

function StoreMgr:cmdStoreToBag(pos)
    local type = self:getStoreType()
    local storeItems = self:getStoreItems()

    if not storeItems[pos] then
        return
    end

    if not StoreMgr:isCanTakeByItem(storeItems[pos]) then
        gf:ShowSmallTips(CHS[3004354])
        return
    end

    DlgMgr:sendMsg(TYPE_TO_DLG[type], "removeLastSelect")

    -- 向服务器发送取出消息前，先判断是否已经过期了
    if InventoryMgr:isItemTimeout(storeItems[pos]) then
        InventoryMgr:notifyItemTimeout(storeItems[pos])
        return
    end

    gf:CmdToServer("CMD_TAKE", {id = 0, from_pos = pos, to_pos = 0, amount = 0})
end

function StoreMgr:cmdStoreToBagForCard(pos)
    if not StoreMgr.storeCards[pos] then return end

    gf:CmdToServer("CMD_TAKE", {id = 0, from_pos = pos, to_pos = 0, amount = 0})
end

function StoreMgr:cmdBagToStoreForCard(pos)
    if StoreMgr:getChangeCardsAmount() == StoreMgr:getCardSize() then
        gf:ShowSmallTips(CHS[4200030])
        return
    end

    local item = InventoryMgr:getItemByPos(pos)
    if not item then return end

    gf:CmdToServer("CMD_STORE", {id = 0, from_pos = pos, to_pos = 0, amount = 0, container = "card_store" })
end

-- 宠物
function StoreMgr:cmdPetToStore(id)

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3004352])
        return
    end

    if not id then
        gf:ShowSmallTips(CHS[3003657])
        return
    end

    local pos = PetMgr.idNoMap[id]
    local pet = PetMgr:getPetById(id)
    local pet_status = pet:queryInt("pet_status")
    gf:ShowSmallTips(pet_status)
    if pet_status == 1 then
        gf:ShowSmallTips(CHS[3004355])
        return
    elseif pet_status == 2 then
        gf:ShowSmallTips(CHS[3004356])
        return
    elseif PetMgr:isFeedStatus(pet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    elseif PetMgr:isRidePet(id) then
        gf:ShowSmallTips(CHS[4200518])
        return
    end
    if StoreMgr.petCount >= StoreMgr:getPetStoreMax() then
        if not self.isFirstPetOp then self.isFirstPetOp = {} end
        if Me:getVipType() < 3 then
            -- 可提高位列仙班的需要给确认框
            if self.isFirstPetOp[Me:getId() .. Me:getVipType()] then
                gf:ShowSmallTips(CHS[3004357])
                return
            end
            self.isFirstPetOp[Me:getId() .. Me:getVipType()] = 1
            if Me:getVipType() == 0 then
                gf:confirm(CHS[4200515],
                function ()
                    OnlineMallMgr:openOnlineMall("OnlineMallVIPDlg", nil, {vip = 1})
                end)
            else
                gf:confirm(CHS[4200516],
                    function ()
                        OnlineMallMgr:openOnlineMall("OnlineMallVIPDlg", nil, {vip = Me:getVipType() + 1})
                    end)
            end
            return
        end
        gf:ShowSmallTips(CHS[3004357])
        return
    end

    gf:CmdToServer("CMD_OPERATE_PET_STORE", {type = 1, pos = pos, id = 0})
    return true
end

-- 宠物
function StoreMgr:cmdPetToHousePetStore(id)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3004352])
        return
    end

    if not id then
        gf:ShowSmallTips(CHS[3003657])
        return
    end

    local pos = PetMgr.idNoMap[id]
    local pet = PetMgr:getPetById(id)

    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        gf:ShowSmallTips(CHS[3004355])
        return
    elseif pet_status == 2 then
        gf:ShowSmallTips(CHS[3004356])
        return
    elseif PetMgr:isFeedStatus(pet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    elseif PetMgr:isRidePet(id) then
        gf:ShowSmallTips(CHS[4200518])
        return
    end

    gf:CmdToServer("CMD_HOUSE_PET_STORE_OPERATE", {type = 1, pos = pos})
end

function StoreMgr:cmdStoreMagicItems()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 5, 1)
end

function StoreMgr:getPetStoreMax()
    return PET_MAX_COUNT[Me:getVipType() + 1]
end

function StoreMgr:getPetFromStore(pos)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3004352])
        return
    end

    if not pos then
        gf:ShowSmallTips(CHS[3003657])
        return
    end

    if PetMgr:getFreePetCapcity() <= 0 then
        gf:ShowSmallTips(CHS[3004358])
        return
    end

    gf:CmdToServer("CMD_OPERATE_PET_STORE", {type = 2, pos = pos, id = 0})

    return true
end

function StoreMgr:getPetFromHousePetStore(pos)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3004352])
        return
    end

    if not pos then
        gf:ShowSmallTips(CHS[3003657])
        return
    end

    if PetMgr:getFreePetCapcity() <= 0 then
        gf:ShowSmallTips(CHS[3004358])
        return
    end

    gf:CmdToServer("CMD_HOUSE_PET_STORE_OPERATE", {type = 2, pos = pos})

    return true
end

function StoreMgr:getBagItems(posStart, posEnd, filter)
    local type = self:getStoreType()
    local storeItems = self:getStoreItems()
    if posStart >= COUPLE_HOME_STORE_START then
        -- 非自身的数据，而是夫妻储物室中对方的数据
        storeItems = self:getCoupleStoreItems()
    end

    local data = {}
    local name = false
    local level = false
    if filter then
        name = filter.name
        level = filter.level
    end

    data.count = 0
    for i = posStart, posEnd do
        local item = storeItems[i]
        local info = { pos = i}
        if item then
            info.imgFile = ResMgr:getItemIconPath(item.icon)

            if item.amount > 1 then
                info.text = tostring(item.amount)
            end

            if item.level and item.level > 0 then
                info.level = item.level
            end

            if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level and item.req_level > 0 then
                info.req_level = item.req_level
            end

            -- 法宝相性
            if item.item_type == ITEM_TYPE.ARTIFACT and item.item_polar then
                info.item_polar = item.item_polar
            end
        end

        if not name or (item and item.name == name and (not level or item.level == level)) then
            table.insert(data, info)
            data.count = data.count + 1
        end
    end

    return data
end

function StoreMgr:getStor1Items()
    if not StoreMgr.storeItems then return end
    return self:getBagItems(STORE_START_1, STORE_START_2 - 1)
end

function StoreMgr:getStor2Items()
    if not StoreMgr.storeItems then return end
    return self:getBagItems(STORE_START_2, STORE_START_3 - 1)
end

function StoreMgr:getStor3Items()
    if not StoreMgr.storeItems then return end
    return self:getBagItems(STORE_START_3, STORE_START_4 - 1)
end

function StoreMgr:getStor4Items()
    if not StoreMgr.storeItems then return end
    return self:getBagItems(STORE_START_4, STORE_START_4 + ONE_STORE_COUNT - 1)
end

-- 居所储物室包裹1
function StoreMgr:getHomeStore1Items()
    if not StoreMgr.homeStoreItems then return end
    return self:getBagItems(HOME_STORE_START_1, HOME_STORE_START_2 - 1)
end
-- 居所储物室包裹2
function StoreMgr:getHomeStore2Items()
    if not StoreMgr.homeStoreItems then return end
    return self:getBagItems(HOME_STORE_START_2, HOME_STORE_END)
end

-- 夫妻居所中对方的储物室一
function StoreMgr:getCoupleHomeStore1Items()
    if not StoreMgr.coupleHomeStoreItems then
        return
    end

    return self:getBagItems(COUPLE_HOME_STORE_START_1, COUPLE_HOME_STORE_START_2 - 1)
end

-- 夫妻居所中对方的储物室二
function StoreMgr:getCoupleHomeStore2Items()
    if not StoreMgr.coupleHomeStoreItems then
        return
    end

    return self:getBagItems(COUPLE_HOME_STORE_START_2, COUPLE_HOME_STORE_END)
end

function StoreMgr:getCardAmountByName(cardName)
    local amount = 0
    for i = CARD_START, CARD_START + CARD_OPEN_COUNT - 1 do
        local card = self.storeCards[i]
        if card and card.name == cardName then
            amount = amount + 1
        end
    end

    return amount
end

function StoreMgr:getFirstNotBindItemByName(name)
    local ret = nil
    for i = CARD_START, CARD_START + CARD_OPEN_COUNT - 1 do
        local card = self.storeCards[i]
        if card and card.name == name and not InventoryMgr:isLimitedItem(card) then
            ret = card
        end
    end
    return ret
end

function StoreMgr:MSG_STORE(data)
    for i = 1, data.count do
--        if data[i] and data[i].pos < PET_POS_START then
        if data.store_type == "normal_store" then
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.storeItems[data[i].pos] = nil
            else
                -- 添加物品
                if self.storeItems[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.storeItems[data[i].pos] = data[i]
                else
                    if self.storeItems[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.storeItems[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "home_store" then
            -- 储物室
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.homeStoreItems[data[i].pos] = nil
            else
                -- 添加物品
                if self.homeStoreItems[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.homeStoreItems[data[i].pos] = data[i]
                else
                    if self.homeStoreItems[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.homeStoreItems[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "couple_store" then
            -- 夫妻储物室中对方的物品
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.coupleHomeStoreItems[data[i].pos] = nil
            else
                -- 添加物品
                if self.coupleHomeStoreItems[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.coupleHomeStoreItems[data[i].pos] = data[i]
                else
                    if self.coupleHomeStoreItems[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.coupleHomeStoreItems[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "card_store" then
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.storeCards[data[i].pos] = nil
            else
                -- 添加物品
                if self.storeCards[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.storeCards[data[i].pos] = data[i]
                else
                    if self.storeItems[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.storeCards[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "furniture_store" then
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.storeFunritures[data[i].pos] = nil
            else
                -- 添加物品
                if self.storeFunritures[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.storeFunritures[data[i].pos] = data[i]
                else
                    if self.storeItems[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.storeFunritures[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "fasion_store" then
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.storeFashions[data[i].pos] = nil
            else
                -- 添加物品
                if self.storeFashions[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.storeFashions[data[i].pos] = data[i]
                else
                    if self.storeFashions[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.storeFashions[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "custom_store" then
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.storeCustoms[data[i].pos] = nil
            else
                -- 添加物品
                if self.storeCustoms[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.storeCustoms[data[i].pos] = data[i]
                else
                    if self.storeCustoms[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.storeCustoms[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "effect_store" then
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.storeEffects[data[i].pos] = nil
            else
                -- 添加物品
                if self.storeEffects[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.storeEffects[data[i].pos] = data[i]
                else
                    if self.storeEffects[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.storeEffects[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "follow_pet_store" then
            if not data[i].amount or data[i].amount <= 0 or not data[i].icon or data[i].icon <= 0 then
                -- 删除物品
                StoreMgr.storeFollowPets[data[i].pos] = nil
            else
                -- 添加物品
                if self.storeFollowPets[data[i].pos] == nil then
                    data[i].attrib = Bitset.new(data[i].attrib)
                    self.storeFollowPets[data[i].pos] = data[i]
                else
                    if self.storeFollowPets[data[i].pos] ~= data[i]  then
                        data[i].attrib = Bitset.new(data[i].attrib)
                        self.storeFollowPets[data[i].pos] = data[i]
                    end
                end
            end
        elseif data.store_type == "house_pet_store" then
            StoreMgr.storeHousePets[data[i].pos] = nil
            if data[i].cardInfo then
                StoreMgr.storeHousePets[data[i].pos] = data[i].cardInfo
            end
        else
            StoreMgr.storePets[data[i].pos] = nil
            if data[i].cardInfo then
                StoreMgr.storePets[data[i].pos] = data[i].cardInfo
            end
        end
    end

    StoreMgr.petCount = 0
    for i, pet in pairs(StoreMgr.storePets) do
        StoreMgr.petCount = StoreMgr.petCount + 1
    end
end

function StoreMgr:getItemByPos(pos)
    if StoreMgr.storeItems and self.storeItems[pos] then return self.storeItems[pos] end
    if StoreMgr.homeStoreItems and self.homeStoreItems[pos] then return self.homeStoreItems[pos] end
    if StoreMgr.coupleHomeStoreItems and self.coupleHomeStoreItems[pos] then return self.coupleHomeStoreItems[pos] end
    if self.storeCards and self.storeCards[pos] then return self.storeCards[pos] end
    return
end

function StoreMgr:getCardByPos(pos)
    if StoreMgr.storeCards == nil then return end
    return self.storeCards[pos]
end

-- 显示道具信息悬浮框  有存入按钮
function StoreMgr:showHasStoreDlg(pos, rect)
    local item = self:getItemByPos(pos)
    if not item then item = InventoryMgr:getItemByPos(pos) end
    if not item then return end

    if (item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 0)
            or item.item_type == ITEM_TYPE.EFFECT
            or item.item_type == ITEM_TYPE.CUSTOM then
        -- 非未鉴定的装备
        if EquipmentMgr:GetEquipType(item.equip_type) == 1 then
            InventoryMgr:showEquipByEquipment(item, rect, true)
            local dlg = DlgMgr:getDlgByName("EquipmentFloatingFrameDlg")
            if dlg then
                dlg:setStoreDisplayType()
                dlg:setFloatingFramePos(rect)
            end
        elseif EquipmentMgr:GetEquipType(item.equip_type) == 2 then
            InventoryMgr:showJewelryFloatDlg(item, rect, true)
            local dlg = DlgMgr:getDlgByName("JewelryInfoDlg")
            if dlg then
                dlg:setStoreDisplayType()
                dlg:setFloatingFramePos(rect)
            end
        elseif EquipmentMgr:GetEquipType(item.equip_type) == 3 then
            -- 时装
            InventoryMgr:showFashioEquip(item, rect, true)
            local dlg = DlgMgr:getDlgByName("FashionDressInfoDlg")
            if dlg then
                dlg:setStoreDisplayType()
                dlg:setFloatingFramePos(rect)
            end
        end
        return
    elseif item.item_type == ITEM_TYPE.ARTIFACT then -- 法宝
        InventoryMgr:showArtifact(item, rect, true)
        local dlg = DlgMgr:getDlgByName("ArtifactInfoDlg")
        if dlg then
            dlg:setStoreDisplayType()
            dlg:setFloatingFramePos(rect)
        end
        return
    elseif InventoryMgr:isFurniture(item) then
        -- 家具
        InventoryMgr:showFurniture(item, rect, true)
        local dlg = DlgMgr:openDlg("FurnitureInfoDlg")
        if dlg then
            dlg:setStoreDisplayType()
            dlg:setFloatingFramePos(rect)
        end
        return
    elseif item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
        dlg:setInfoFromItem(item, true)
        dlg:setStoreDisplayType()
        dlg:setFloatingFramePos(rect)
        return
    end


    local dlg = DlgMgr:openDlg('ItemInfoDlg')
    dlg:setInfoFormStore(item)
    dlg:setFloatingFramePos(rect)
end

-- 显示道具信息悬浮框
function StoreMgr:showItemDlg(pos, rect)

    local item = self:getItemByPos(pos)
    if not item then item = InventoryMgr:getItemByPos(pos) end
    if not item then return end

    if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 0 then
        -- 非未鉴定的装备
        if EquipmentMgr:GetEquipType(item.equip_type) == 1 then
            InventoryMgr:showEquipByEquipment(item, rect, true)
        elseif EquipmentMgr:GetEquipType(item.equip_type) == 2 then
--            InventoryMgr:showJewelryByJewelry(item, rect, true)
            InventoryMgr:showJewelryFloatDlg(item, rect, true)
        end
        return
    elseif item.item_type == ITEM_TYPE.ARTIFACT then -- 法宝
        InventoryMgr:showArtifact(item, rect, true)
        return
    elseif InventoryMgr:isFurniture(item) then  -- 家具
        InventoryMgr:showFurniture(item, rect, true)
        return
    elseif item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
        dlg:setInfoFromItem(item, true)
        dlg:setFloatingFramePos(rect)
        return
    end


    local dlg = DlgMgr:openDlg('ItemInfoDlg')
    dlg:setInfoFormCard(item)
    dlg:setFloatingFramePos(rect)
end

-- 设置道具的比较层次
function StoreMgr:setItemLayer(data)
    if not data then return end

    local itemType = data.item.item_type
    if ITEM_TYPE.DISH == itemType then
        -- 菜肴
        data.layer = 0
    elseif ITEM_TYPE.MEDICINE == itemType and not gf:findStrByByte(data.item.name, CHS[4200154]) then
        -- 非玲珑类药品
        data.layer = 1
    elseif ITEM_TYPE.MEDICINE == itemType and gf:findStrByByte(data.item.name, CHS[4200154]) then
        -- 玲珑类药品，按“袖珍血/法玲珑”，“血/法玲珑”，“中级血/法玲珑”，“高级血/法玲珑”排序
        if gf:findStrByByte(data.item.name, CHS[3004112]) then     -- 袖珍血法玲珑
        data.layer = 2
        elseif gf:findStrByByte(data.item.name, CHS[4000186]) then -- 中级血法玲珑
            data.layer = 4
        elseif gf:findStrByByte(data.item.name, CHS[4000187]) then -- 高级血法玲珑
            data.layer = 5
        else                                                       -- 血法玲珑
            data.layer = 3
        end
    elseif ITEM_TYPE.SERVICE_ITEM == itemType or ITEM_TYPE.CHARGE_ITEM == itemType then
        -- 付费道具
        data.layer = 6
    elseif ITEM_TYPE.EQUIPMENT == itemType and data.item.unidentified == 0 then
        -- 装备，包括武器(扇、锤、剑、枪、爪)、帽子(男帽、女帽)、衣服(男衣、女衣)、鞋子(男女通用)
        local equipType = ItemInfo[data.item.name].equipType
        if EQUIP.WEAPON == data.item.equip_type then   -- 武器
            if equipType == CHS[3003962] then     -- 扇
                data.layer = 7
            elseif equipType == CHS[3003963] then -- 锤
                data.layer = 8
            elseif equipType == CHS[3003964] then -- 剑
                data.layer = 9
            elseif equipType == CHS[3003965] then -- 枪
                data.layer = 10
            elseif equipType == CHS[3003966] then -- 爪
                data.layer = 11
            end
        elseif EQUIP.HELMET == data.item.equip_type then -- 帽子
            if equipType == CHS[3003967] then      -- 男帽
                data.layer = 12
            elseif equipType == CHS[3003968] then  -- 女帽
                data.layer = 13
            end
        elseif EQUIP.ARMOR == data.item.equip_type then  -- 衣服
            if equipType == CHS[3003969] then      -- 男衣
                data.layer = 14
            elseif equipType == CHS[3003970] then  -- 女衣
                data.layer = 15
            end
        elseif EQUIP.BOOT == data.item.equip_type then   -- 鞋子（男女通用）
            data.layer = 16
        else
            data.layer = 29  --若是其他类型的装备，则属于其他物品
        end
    elseif ITEM_TYPE.EQUIPMENT == itemType and data.item.unidentified == 1 then
        -- 未鉴定装备，包括武器(扇、锤、剑、枪、爪)、帽子(男帽、女帽)、衣服(男衣、女衣)、鞋子(男女通用)
        local equipType = ItemInfo[data.item.name].equipType
        if EQUIP.WEAPON == data.item.equip_type then   -- 武器
            if equipType == CHS[3003962] then     -- 扇
                data.layer = 17
            elseif equipType == CHS[3003963] then -- 锤
                data.layer = 18
            elseif equipType == CHS[3003964] then -- 剑
                data.layer = 19
            elseif equipType == CHS[3003965] then -- 枪
                data.layer = 20
            elseif equipType == CHS[3003966] then -- 爪
                data.layer = 21
            end
        elseif EQUIP.HELMET == data.item.equip_type then -- 帽子
            if equipType == CHS[3003967] then      -- 男帽
                data.layer = 22
            elseif equipType == CHS[3003968] then  -- 女帽
                data.layer = 23
            end
        elseif EQUIP.ARMOR == data.item.equip_type then  -- 衣服
            if equipType == CHS[3003969] then      -- 男衣
                data.layer = 24
            elseif equipType == CHS[3003970] then  -- 女衣
                data.layer = 25
            end
        elseif EQUIP.BOOT == data.item.equip_type then   -- 鞋子（男女通用）
            data.layer = 26
        else
            data.layer = 29  --若是其他类型的未鉴定装备，则属于其他物品
        end
    elseif ITEM_TYPE.ARTIFACT == itemType then  -- 法宝
        data.layer = 27
    elseif ITEM_TYPE.CHANGE_LOOK_CARD == itemType then -- 变身卡
        data.layer = 28
    else
        -- 其他
        data.layer = 29
    end
end

function StoreMgr:MSG_FINISH_SORT_PACK(data)
    if data.start_range == 1 then
        -- 开始整理
        self.isArranging = true
    else
        -- 结束整理
        self.isArranging = false
    end
end

function StoreMgr:arrangeBag()
    if self.isArranging then
        -- 正在整理中
        return
    end

    -- 现在可以整理包裹的页面包括：仓库，居所储物室
    local type = self:getStoreType()
    local storeItems = self:getStoreItems()
    local  posStart = self:getStartPos()
    local posEnd = self:getEndPos()

    -- 取出可合并物品
    local toMergeItems = {}
    local mergeNum = 0
    local toArrangeItems = {}
    for pos, item in pairs(storeItems) do
        local amount = item.amount
        if pos >= posStart and pos <= posEnd and amount > 0 then
            local data = {pos = pos, item = item}

            -- 设置道具的比较层次
            InventoryMgr:setItemLayer(data);

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
        mergeRules = InventoryMgr:mergeItems(toMergeItems, mergeNum, toArrangeItems)
    end

    -- 按指定的排序规则对容器进行排序
    table.sort(toArrangeItems, InventoryMgr:getSortItems())

    local len = #toArrangeItems
    local posInfo = ''
    local count = 0
    for i = 1, len do
        local pos = posStart + i - 1
        if pos ~= toArrangeItems[i].pos then
            if posInfo ~= '' then
                posInfo = posInfo .. ','
            end

            posInfo = posInfo .. toArrangeItems[i].pos .. '-' .. pos
            count = count + 1
        end
    end

    if mergeRules == '' and posInfo == '' then
        -- 没有变化
        return
    end

    if posInfo == '' then
        -- 需要合并物品，必在起始位置
        posInfo = '' .. posStart .. '-' .. posStart
        count = 1
    end

    gf:CmdToServer('CMD_SORT_PACK', {count = count, range = mergeRules .. '|' .. posInfo, start_pos = posStart, to_store_cards = ""})

    self.isArranging = true
end

-- 获取可用的最大位置   vip不同激活的背包位置不同
function StoreMgr:getCanUseMaxPos()
    local type = self:getStoreType()
    if type == STORE_TYPE.NORMAL_STORE then
        if Me:getVipType() == 0 then
            return STORE_START_3 - 1
        elseif Me:getVipType() == 1 or Me:getVipType() == 2 then
            return STORE_START_4 - 1
        elseif Me:getVipType() == 3 then
            return STORE_END
        end
    elseif type == STORE_TYPE.HOME_STORE then
        -- 根据居所储物室空间不同，最大可用位置不同
        local maxGrid = HomeMgr:getMaxGridByHomeStoreType(HomeMgr:getHomeStoreType())
        return HOME_STORE_POS_START + maxGrid - 1
    end
end

-- 是否能取物品
function StoreMgr:isCanTakeByItem(item)
    if InventoryMgr:getFirstEmptyPos() then
        return true
    end

    -- 对物品进行分类
    local amount = item.amount
    if ITEM_COMBINED.ITEM_COMBINED_NO ~= item.combined and item.amount < getItemDoubleMax(item) then
        -- 可合并
        for i = InventoryMgr:getStartByPage(1), InventoryMgr:getCanUseMaxPos() do
            if InventoryMgr.inventory[i].name == item.name then
                amount = amount - (getItemDoubleMax(item) - InventoryMgr.inventory[i].amount)
                if amount <= 0 then return true end
            end
        end
    end

    return false
end

function StoreMgr:isCanStoreByItem(item)
    if StoreMgr:getFirstEmptyPos() then
        return true
    end

    local storeItems = self:getStoreItems()
    local startPos = self:getStartPos()

    -- 对物品进行分类
    local amount = item.amount
    if ITEM_COMBINED.ITEM_COMBINED_NO ~= item.combined then
        -- 可合并
        for i = startPos, StoreMgr:getCanUseMaxPos() do
            if storeItems[i].name == item.name and InventoryMgr:isLimitedItem(item) == InventoryMgr:isLimitedItem(storeItems[i]) then
                if getItemDoubleMax(item) - storeItems[i].amount > 0 then
                    return true
                end
            end
        end
    end

    return false
end

function StoreMgr:getFirstEmptyPos()
    local startPos = self:getStartPos()
    local storeItems = self:getStoreItems()
    for i = startPos, StoreMgr:getCanUseMaxPos() do
        if not storeItems[i] then
            return i
        end
    end

    return nil
end

function StoreMgr:getChangeCard()
    local cards = {}
    for i = CARD_START, CARD_START + CARD_OPEN_COUNT - 1 do
        local card = self.storeCards[i]
        if card then
            table.insert(cards, card)
        end
    end

    return cards
end

function StoreMgr:getChangeCardsAmount()
    local total = 0
    for i = CARD_START, CARD_START + CARD_OPEN_COUNT - 1 do
        local card = self.storeCards[i]
        if card then
            total = total + 1
        end
    end

    return total
end

-- 获取卡套剩余空间
function StoreMgr:getChangeCardEmptyCount()
    local cou = 0
    for i = CARD_START, CARD_START + CARD_OPEN_COUNT - 1 do
        local card = self.storeCards[i]
        if not card then
            cou = cou + 1
        end
    end

    return cou
end

-- 根据变身卡名称获取变身卡
function StoreMgr:getChangeCardByName(name, notLimit, notLimitForever)
    local cards = {}
    local limitCards = {}       -- 限制交易（不包含永久限制交易）
    local limitForeverCard = {} -- 永久限制交易
    local notLimitCards = {}    -- 非限制交易
    for i = CARD_START, CARD_START + CARD_OPEN_COUNT - 1 do
        local card = self.storeCards[i]
        if card and card.name == name then
            if InventoryMgr:isLimitedItem(card) then
                if InventoryMgr:isLimitedItemForever(card) then
                    table.insert(limitForeverCard, card)
                else
                    table.insert(limitCards, card)
                end
            else
                table.insert(notLimitCards, card)
            end
        end
    end

    if notLimit then
        -- 返回非限制交易的
        return notLimitCards
    end

    for _, card in pairs(notLimitCards) do
                table.insert(cards, card)
            end

    for _, card in pairs(limitCards) do
        table.insert(cards, card)
        end

    if notLimitForever then
        -- 返回非永久限制交易的
        return cards
    end

    -- 剩下的返回  永久限制-限制-非限制
    cards = {}
    for _, card in pairs(limitForeverCard) do
        table.insert(cards, card)
    end

    for _, card in pairs(limitCards) do
        table.insert(cards, card)
    end

    for _, card in pairs(notLimitCards) do
        table.insert(cards, card)
    end

    return cards
end

function StoreMgr:getCardStartPos()
    return CARD_START
end


function StoreMgr:getCardSize()
    return CARD_OPEN_COUNT
end

function StoreMgr:getCardSizeMax()
    return CARD_OPEN_COUNT_MAX
end

function StoreMgr:addCardSize(count)
    gf:CmdToServer('CMD_CL_CARD_ADD_SIZE', {count = count})
end

-- 获取已经收集过的
function StoreMgr:getCardIsGotInfo()
    if not self.cardGotInfo then return {[1] = 0, [2] = 0, [3] = 0, [4] = 0} end
    return self.cardGotInfo
end

-- 变身卡置顶列表
function StoreMgr:getCardTop()
    return self.cardTop or {}
end

function StoreMgr:getCardsInCardBagDisplayAmount(storeCard)
    if not storeCard then
        storeCard = StoreMgr:getChangeCard()
    end

    local totalCards = {}

    local function colectCards(cards)
        for _, info in pairs(cards) do
            local cardName = info.name
            local cardInfo = InventoryMgr:getCardInfoByName(cardName)
            if totalCards[cardName] then
                totalCards[cardName].count = totalCards[cardName].count + (info.amount or 1)
            else
                totalCards[cardName] = {polar = cardInfo.polar,count = info.amount or 1, name = cardName, order = cardInfo.order, card_type = cardInfo.card_type}
            end
        end
    end

    colectCards(storeCard)

    local topKey = StoreMgr:getCardTop()
    local orderCard = {}
    for id, info in pairs(totalCards) do
        local top = 100
        for i = 1,#topKey do
            if topKey[i] == info.order then
                top = i
            end
        end
        info.topOrder = top
        table.insert(orderCard, info)
    end

    table.sort(orderCard, function(l, r)
        if l.topOrder < r.topOrder then return true end
        if l.topOrder > r.topOrder then return false end
        if ORDER_BY_CARD_TYPE[l.card_type] < ORDER_BY_CARD_TYPE[r.card_type] then return true end
        if ORDER_BY_CARD_TYPE[l.card_type] > ORDER_BY_CARD_TYPE[r.card_type] then return false end
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)
    return orderCard
end

-- 所有变身卡数量汇总信息
function StoreMgr:getAllChangeCardDisplayAmount()
    -- 卡套中的变身卡
    local totalCards = StoreMgr:getCardsInCardBagDisplayAmount()

    local nameToIndex = {}
    for i = 1, #totalCards do
        local card = totalCards[i]
        nameToIndex[card.name] = i
    end

    -- 包裹中的变身卡
    local bagCard = InventoryMgr:getChangeCardByOrder()

    for i = 1, #bagCard do
        local card = bagCard[i]
        local cardName = card.name
        local cardInfo = InventoryMgr:getCardInfoByName(cardName)
        local index = nameToIndex[cardName]
        if index then
            -- 如果卡套中已经有此变身卡，则直接将变身卡累加到卡套变身卡中
            totalCards[index].count = totalCards[index].count + 1
        else
            -- 如果卡套中还没有此变身卡，则添加此变身卡信息
            table.insert(totalCards, {polar = cardInfo.polar,count = 1, name = cardName, order = cardInfo.order, card_type = cardInfo.card_type})
            nameToIndex[cardName] = #totalCards
        end
    end

    return totalCards
end

-- 变身卡信息
function StoreMgr:MSG_CL_CARD_INFO(data)
    if self.cardGotInfo and not next(self.cardGotInfo) and next(data.history_val) then
        -- 如果历史获得为0，获得第一张卡片，则是这辈子第一次获得卡片
        local dlg = DlgMgr:getDlgByName("BagTabDlg")
        if dlg and dlg:getCurSelect() ~= "ChangeCardBagDlg" then
            RedDotMgr:insertOneRedDot("BagTabDlg", "ChangeCardDlgCheckBox")
        end

        if not dlg then
            RedDotMgr:insertOneRedDot("GameFunctionDlg", "BagButton")
            RedDotMgr:insertOneRedDot("BagTabDlg", "ChangeCardDlgCheckBox")
            DlgMgr:sendMsg("HomeFishingDlg", "addRedDotOnBagButton")
        end
    end

    self.cardGotInfo = data.history_val
    self.cardTop = data.top_id
    CARD_OPEN_COUNT = data.size
end

function StoreMgr:getStoreMoney()
    return Me:queryBasicInt("balance")
end

-- 家具列表
function StoreMgr:getFurnitureByName(name, isAll)
    local items = {}
    for i = FURNITURE_STORE_START, FURNITURE_STORE_START + FURNITURE_STORE_COUNT - 1 do
        local item = self.storeFunritures[i]
        if item and item.name == name and (isAll or item.amount > item.placed_amount) then
            table.insert(items, item)
        end
    end

    return items
end

-- 获取仓库中家具的数量
function StoreMgr:getFurnitureCountByName(name, isAll)
    local count = 0
    for i = FURNITURE_STORE_START, FURNITURE_STORE_START + FURNITURE_STORE_COUNT - 1 do
        local item = self.storeFunritures[i]
        if item and item.name == name then
            if isAll then
                count = count + item.amount
            elseif item.amount > item.placed_amount then
                count = count + item.amount - item.placed_amount
            end
        end
    end

    return count
end

function StoreMgr:getFurnitureByPos(pos)
    if StoreMgr.storeFunritures and self.storeFunritures[pos] then
        return self.storeFunritures[pos]
    end
end

function StoreMgr:cmdFurniture()
    if not next(StoreMgr.storeFunritures) then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STORE, 3, 1)
    end
end

function StoreMgr:getFurnitureStartPos()
    return FURNITURE_STORE_START
end

-- 自定义道具
function StoreMgr:getCustomItemByName(name)
    if not self.storeCustoms then return end
    for k, v in pairs(self.storeCustoms) do
        if v and v.name == name then
            return v
        end
    end
end

-- 自定义时装道具
function StoreMgr:getFashionItemByName(name)
    if not self.storeFashions then return end
    for k, v in pairs(self.storeFashions) do
        if v and v.name == name then
            return v
        end
    end
end

-- 特效道具
function StoreMgr:getEffectItemByName(name)
    if not self.storeEffects then return end
    for k, v in pairs(self.storeEffects) do
        if v and v.name == name then
            return v
        end
    end
end

-- 跟随宠物
function StoreMgr:getFollowPetByName(name)
    if not self.storeFollowPets then return end
    for k, v in pairs(self.storeFollowPets) do
        if v and v.name == name then
            return v
        end
    end
end

MessageMgr:hook("MSG_FINISH_SORT_PACK", StoreMgr, "StoreMgr")
MessageMgr:regist("MSG_STORE", StoreMgr)
MessageMgr:regist("MSG_CL_CARD_INFO", StoreMgr)