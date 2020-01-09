-- RankMgr.lua
-- Created by chenyq Jan/09/2015
-- 排行榜管理器

RankMgr = Singleton()

RankMgr.rankInfo = {}

local REQUEST_TYPE = {
    NORMAL      = 1,
    BY_LEVEL    = 2,
}

local RNAK_LIST_BY_LEVEL = {
    [RANK_TYPE.EQUIP_WEAPON]  = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.EQUIP_HELMET]  = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.EQUIP_ARMOR]   = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.EQUIP_BOOT]    = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.CHAR_TAO]      = { "45-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.CHAR_MONTH_TAO]  = { "45-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.CHALLENGE_TOWER] = { "50-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.ZDD_METAL]    = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.ZDD_WOOD]    = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.ZDD_WATER]    = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.ZDD_FIRE]    = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.ZDD_EARTH]    = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
    [RANK_TYPE.HERO]    = { "70-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
}

local EQUIP_LEVEL_AND_TYPE = {
    ["70-79"] = {type = RANK_TYPE.EQUIP_LEVEL_ONE, index = 1},
    ["80-89"] = {type = RANK_TYPE.EQUIP_LEVEL_TWO, index = 2},
    ["90-99"] = {type = RANK_TYPE.EQUIP_LEVEL_THREE, index = 3},
    ["100-109"] = {type = RANK_TYPE.EQUIP_LEVEL_FOUR, index = 4},
    ["110-119"] = {type = RANK_TYPE.EQUIP_LEVEL_FIVE, index = 5},
    ["120-129"] = {type = RANK_TYPE.EQUIP_LEVEL_SIX, index = 6},
    [RANK_TYPE.EQUIP_LEVEL_ONE] = "70-79",
    [RANK_TYPE.EQUIP_LEVEL_TWO] = "80-89",
    [RANK_TYPE.EQUIP_LEVEL_THREE] = "90-99",
    [RANK_TYPE.EQUIP_LEVEL_FOUR] = "100-109",
    [RANK_TYPE.EQUIP_LEVEL_FIVE] = "110-119",
    [RANK_TYPE.EQUIP_LEVEL_SIX] = "120-129",
}

local RANK_LEVEL_TAO = {
    CHS[7150021], -- 45~79,
    CHS[7150022], -- 80~89,
    CHS[7150023], -- 90~99,
    CHS[7150024], -- 100~109,
    CHS[7150025], -- 110~119,
    CHS[7150026], -- 120~129,
}

-- 获取玩家当前等级落应当选择的类型
function RankMgr:getMeLevelToEquipType(rankType)
    -- 选择了等级段
    if rankType then
        local minLevel, maxLevel = self:getEquipLevelByType(rankType)
        return nil, minLevel, maxLevel, nil, RankMgr:getLastSearchEquip()
    end

    -- 没有选择等级段，用me所在等级段
    local myLevel = Me:queryInt("level")
    for k,v in pairs(EQUIP_LEVEL_AND_TYPE) do
        local minLevel, maxLevel = string.match(k, "(%d+)-(%d+)")
        if minLevel and maxLevel then
            minLevel = tonumber(minLevel)
            maxLevel = tonumber(maxLevel)
            if minLevel <= myLevel and myLevel <= maxLevel then
                return v.type, minLevel, maxLevel, v.index, RankMgr:getLastSearchEquip()
            end
        end
    end

    -- 没有角色对应等级段
    local minLevel, maxLevel = string.match(EQUIP_LEVEL_AND_TYPE[RANK_TYPE.EQUIP_LEVEL_ONE], "(%d+)-(%d+)")
    minLevel = tonumber(minLevel)
    maxLevel = tonumber(maxLevel)
    return RANK_TYPE.EQUIP_LEVEL_ONE, minLevel, maxLevel, 1, RankMgr:getLastSearchEquip()
end

-- 获取装备选择类型对应等级段
function RankMgr:getEquipLevelByType(type)
    local value = EQUIP_LEVEL_AND_TYPE[type]
    if value then
        local minLevel, maxLevel = string.match(value, "(%d+)-(%d+)")
        minLevel = tonumber(minLevel)
        maxLevel = tonumber(maxLevel)
        if minLevel and maxLevel then
            return minLevel, maxLevel
        end
    end

    -- 没有type类型对应对应区间
    local minLevel, maxLevel = string.match(EQUIP_LEVEL_AND_TYPE[RANK_TYPE.EQUIP_LEVEL_ONE], "(%d+)-(%d+)")
    minLevel = tonumber(minLevel)
    maxLevel = tonumber(maxLevel)
    return minLevel, maxLevel
end

-- 是否为装备等级段类型
function RankMgr:isEquipLevelType(type)
    if type and type >= RANK_TYPE.EQUIP_LEVEL_ONE and type <= RANK_TYPE.EQUIP_LEVEL_SIX then
        return true
    end

    return false
end

-- 是否为装备类型
function RankMgr:isEquipType(type)
    if type and type >= RANK_TYPE.EQUIP_WEAPON and type <= RANK_TYPE.EQUIP_BOOT then
        return true
    end

    return false
end

-- 获取玩家当前等级落在的区间内
function RankMgr:getMeLevelZone(subType)
    local myLevel = Me:queryInt("level")
    local rankListLimit = RNAK_LIST_BY_LEVEL[subType]
    if not rankListLimit and math.floor(subType / 100) == RANK_TYPE.ZDD then
        rankListLimit = RNAK_LIST_BY_LEVEL[RANK_TYPE.ZDD]
    end

    local lastSearchLevel = RankMgr:getLastSearchLevel()
    if rankListLimit then
        for i = 1, #rankListLimit do
            local minLevel, maxLevel = string.match(rankListLimit[i], "(%d+)-(%d+)")
            minLevel = tonumber(minLevel)
            maxLevel = tonumber(maxLevel)
            if (minLevel <= myLevel and myLevel <= maxLevel and not lastSearchLevel) or (lastSearchLevel == i) then
                return minLevel, maxLevel, i
            end
        end

        -- 没有区间
        local minLevel, maxLevel = string.match(rankListLimit[1], "(%d+)-(%d+)")
        minLevel = tonumber(minLevel)
        maxLevel = tonumber(maxLevel)
        return minLevel, maxLevel, 1
    end
end

-- index 为RNAK_LIST_BY_LEVEL中第几个
function RankMgr:getLevelZone(subType, index)
    local rankListLimit = RNAK_LIST_BY_LEVEL[subType]
    if rankListLimit and index and rankListLimit[index] then
        local minLevel, maxLevel = string.match(rankListLimit[index], "(%d+)-(%d+)")
        minLevel = tonumber(minLevel)
        maxLevel = tonumber(maxLevel)
        return minLevel, maxLevel
    end
end

-- 获取排行榜数据
function RankMgr:fetchRankInfo(rankType, minLevel, maxLevel)
    if not minLevel or not maxLevel then
        -- 没有指定范围
        rankType = rankType
    else
        rankType = string.format("%s:%d-%d", rankType, minLevel, maxLevel)
    end

    local cookie = 0
    local rankList = self.rankInfo[rankType]
    if rankList then
        cookie = rankList.cookie
    end

    gf:CmdToServer('CMD_GENERAL_NOTIFY', {
        type  = NOTIFY.GET_RANK_INFO,
        para1 = tostring(rankType),
        para2 = tostring(cookie)
    })
end

-- 获取排行榜数据Me
function RankMgr:queryMeRankInfo()
    self.myHouseRank = nil
    gf:CmdToServer('CMD_GENERAL_NOTIFY', {
        type  = NOTIFY.NOTIFY_RANK_ME_INFO,
    })
end

-- 获取排行榜数据
function RankMgr:getRankListByType(subType, minLevel, maxLevel, start, limit)
    local rankType = subType

    if not start then start = 1 end
    if not limit then limit = 10 end

    if minLevel == nil or maxLevel == nil then
        -- 如果只有等级相关的数据；那么，就取默认的第一个等级数据
        if RNAK_LIST_BY_LEVEL[rankType] ~= nil then
            rankType = string.format("%d:%s", subType, RNAK_LIST_BY_LEVEL[rankType][1])
        end

        if not self.rankInfo[rankType] then
            return nil
        end

        local count = self.rankInfo[rankType].count or 0

        if start + limit - 1 > count then
            limit = count - (start - 1)
        end

        local retData = {}
        for i = start, start + limit - 1 do
            local data = self.rankInfo[rankType][i]

            if data then
                data.sortIdx = i
                table.insert(retData, data)
            end


        end

        if #retData > 0 then
            return retData
        else
            return nil
        end

        --return self.rankInfo[rankType]
    end

    -- 根据等级获取
    rankType = string.format("%d:%d-%d", subType, minLevel, maxLevel)

    if not self.rankInfo[rankType] then
        return nil
    end
    local count = self.rankInfo[rankType].count or 0
    if start + limit - 1 > count then
        limit = count
    end

    local retData = {}
    for i = start, start + limit - 1 do
        local data = self.rankInfo[rankType][i]
        if data then
            data.sortIdx = i
            table.insert(retData, data)
        end
    end

    if #retData > 0 then
        return retData
    else
        return nil
    end
end

-- 获取道行，通天塔index的等级段字符串
function RankMgr:getTaoTitleLevel(index, type)
    if index > 0 and index <= #RANK_LEVEL_TAO then
        if type == RANK_TYPE.CHALLENGE_TOWER and index == 1 then
            return CHS[7150027]
        end

        if (type == RANK_TYPE.HERO or math.floor(type / 100 ) == RANK_TYPE.ZDD) and index == 1 then
            return "70~79"
        end

        return RANK_LEVEL_TAO[index]
    end
end

-- 排行榜数据需要在登录，退出游戏时清除WDSY-24906
function RankMgr:clearData(isLoginOrSwithLine)
    if not isLoginOrSwithLine then
        self.rankInfo = {}
        self.myHouseRank = nil
        self.meInfo = nil
        self.rankType = nil
        self.subType = nil
        self.openByPlace = nil
        self.lastSearchLevel = nil
        self.lastSearchEquip = nil
    end
end

function RankMgr:MSG_TOP_USER(data)
    local rankType = data.type
    if REQUEST_TYPE.BY_LEVEL == data.requestType then
        -- 如果是根据等级获取数据的
        rankType = string.format("%d:%d-%d", data.type, data.minLevel, data.maxLevel)
    end

    -- 获取数据，进行判断
    local oldData = self.rankInfo[rankType]
    if oldData and oldData.cookie == data.cookie then
        return
    end

    self.rankInfo[rankType] = data
end

function RankMgr:MSG_RANK_CLIENT_INFO(data)
    self.meInfo = data
end

function RankMgr:setLastSelectRankTypeAndSubType(rankType, subType)
    self.rankType = rankType
    self.subType = subType
end

function RankMgr:getLastSelectRankTypeAndSubType()
    return self.rankType, self.subType
end

-- 设置从哪个地方打开的排行榜，用于打开对应的标签
function RankMgr:setOpenByPlace(place)
    self.openByPlace = place
end

function RankMgr:getOpenByPlace()
    return self.openByPlace
end

function RankMgr:setLastSearchLevel(index)
    self.lastSearchLevel = index
end

function RankMgr:getLastSearchLevel()
    return self.lastSearchLevel
end

function RankMgr:setLastSearchEquip(type)
    self.lastSearchEquip = type
end

function RankMgr:getLastSearchEquip()
    if self.lastSearchEquip then
        return self.lastSearchEquip
    else
        return RANK_TYPE.EQUIP_WEAPON
    end
end

function RankMgr:MSG_ME_HOUSE_RANK_DATA(data)
    self.myHouseRank = data
end

MessageMgr:regist("MSG_TOP_USER", RankMgr)
MessageMgr:regist("MSG_RANK_CLIENT_INFO", RankMgr)
MessageMgr:regist("MSG_ME_HOUSE_RANK_DATA", RankMgr)
