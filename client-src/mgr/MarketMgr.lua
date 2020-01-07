-- MarketMgr.lua
-- Created by liuhb Apr/22/2015
-- 集市管理器

local Bitset = require('core/Bitset')
local DataObject = require('core/DataObject')
local json = require('json')
MarketMgr = Singleton()
MarketMgr.allItems = {}                 -- 所有可摆摊的物品

MarketMgr.auctionInfo = {}              -- 拍卖商品信息
MarketMgr.auctionFavoritiesGoods = {}        -- 拍卖商品收藏夹物品
MarketMgr.auctionMyBidedGoods = {}      -- 我竞价过的商品
MarketMgr.secondClassScrollPosition = {}  -- 二级列表滑动位置
MarketMgr.TradeType =
{
    marketType = 1,
    goldType = 2,
}

local allSellItems = require("cfg/MarketSellItems")

local BUY_STATE = {
    SEARCH = 1,
    NORMAL = 2,
}

-- 摆摊装备等级对应的等级段
local MARKET_EQUIP_LEVEL_STR =
{
    [70] = CHS[6000397],
    [80] = CHS[6000398],
    [90] = CHS[6000399],
    [100] = CHS[6000400],
    [110] = CHS[4100553],
    [120] = CHS[7190108],
}

local LEVEL_LIMIT = 50
local GOLD_LEVEL_LIMIT = 60
local TIME_DELAY = 60 -- 客户和服务端的时间延迟

-- 超过该等级就不可参战和掠阵
local MAX_LEVEL_DIFF = 15

-- 商品的销售状态
local  GOOD_STATE_SHOWING = 1   -- 公示中
local  GOOD_STATE_SELLING = 2   -- 出售中
local  GOOD_STATE_OUT_SELLING = 3 -- 已下架
local  GOOD_STATE_FROZEN = 4   -- 冻结中

-- 这两个状态主要是在交易历史中使用
local GOOD_STATE_AUDIT = 5   -- 审核中
local GOOD_STATE_AUDITED = 6  -- 已审核

local MAX_COLLECT_NUM = 16 -- 最大搜藏数量

local SELL_RATE = 0.01
local MAX_PUBLIC_BOOTH_COST = 1000000
local MIN_PUBLIC__BOOTH_COST = 100000
local MAX_UNPUBLIC_BOOTH_COST = 100000
local MIN_UNPUBLIC__BOOTH_COST = 1000

local GOLD_SELL_RATE = 100
local GOLD_MAX_PUBLIC_BOOTH_COST = 5000000
local GOLD_MIN_PUBLIC__BOOTH_COST = 500000
local GOLD_MIN_MONEY_BOOTH_COST = 10000

local SEARCH_RESULT_MAX_TIME = 15 * 60

-- 交易系统名片发起时可以所处的界面情况
MarketMgr.CARD_EXCHANGE = {
    CARD_EXCHANGE_MINE = 1, -- 自己的货架
    CARD_EXCHANGE_COLLECTION = 2, -- 收藏
    CARD_EXCHANGE_LIST = 3, -- 逛摊/公示
    CARD_EXCHANGE_SEARCH = 4, -- 搜索
}

local PUBICITY_ITEM =
{
    [CHS[3004158]] = CHS[3004158],
    [CHS[3004159]] = CHS[3004159],
    [CHS[3004160]] = CHS[3004160],
    [CHS[3004161]] = CHS[3004161],
    [CHS[3004162]] = CHS[3004162],
    [CHS[3004163]] = CHS[3004163],
    [CHS[7000144]] = CHS[7000144],
}

-- 珍宝一集菜单
local TREASURE_ITEM_LIST =
{
    CHS[7000306],     -- 搜索结果
    CHS[3002999],     -- 装备
    CHS[3003000],     -- 宠物
    CHS[3003001],     -- 高级首饰
    CHS[7000144],
    CHS[3002143],     -- 金钱
}

-- 相性对应名字
local POLAR_TO_NAME =
{
    [0] = CHS[6200027],
    [1] = CHS[3000334],
    [2] = CHS[3000335],
    [3] = CHS[3000336],
    [4] = CHS[3000337],
    [5] = CHS[3000338]
}

-- 交易状态
MarketMgr.TRADE_GOLD_STATE = {
    SHOW        =   1,      -- 公示中
    ON_SELL        =   2,      -- 出售中
    OUT_SELL    = 3,        -- 已下架
    SHOW_VENDUE     = 11,   -- 拍卖公示
    ON_SELL_VENDUE  = 12,   -- 拍卖寄售
}

MarketMgr.STALL_BUY_COMMON  = 0     -- 普通购买
MarketMgr.STALL_BUY_SEARCH  = 1     -- 搜索购买
MarketMgr.STALL_BUY_COLLECT = 2     -- 收藏购买
MarketMgr.STALL_BUY_RUSH    = 3     -- 抢购
MarketMgr.STALL_BUY_AUCTION = 4     -- 我的竞拍

-- 可以批量购买的物品
local DOUBEL_ITEM =
{
    [CHS[3001111]] = true, -- 宠物经验丹
    [CHS[4100323]] = true, -- 修炼卷轴
    [CHS[6900000]] = true, -- 藏宝图
    [CHS[4100421]] = true,
    [CHS[4100422]] = true,
    [CHS[4100423]] = true,
    [CHS[4100424]] = true,
    [CHS[5400067]] = true, -- 元神碎片·问羽
    [CHS[5400068]] = true, -- 元神碎片·鸿道
    [CHS[5450117]] = true, -- 元神碎片·白灵
    [CHS[5450118]] = true, -- 元神碎片·迅影
    [CHS[5450373]] = true, -- 元神碎片·餐风
    [CHS[5450374]] = true, -- 元神碎片·饮露
    [CHS[2000037]] = true, --神兽丹
    [CHS[4200404]] = true,
    [CHS[2000370].."("..CHS[2000373]..")"] = true, --健体羹(3品)
    [CHS[2000370].."("..CHS[2000374]..")"] = true,
    [CHS[2000370].."("..CHS[2000375]..")"] = true,
    [CHS[2000376].."("..CHS[2000373]..")"] = true, --安神羹(3品)
    [CHS[2000376].."("..CHS[2000374]..")"] = true,
    [CHS[2000376].."("..CHS[2000375]..")"] = true,
    [CHS[2000377].."("..CHS[2000371]..")"] = true, --秘制鱼汤(1品)
    [CHS[2000377].."("..CHS[2000372]..")"] = true,
    [CHS[2000378].."("..CHS[2000371]..")"] = true, --灵芝鱼丸(1品)
    [CHS[2000378].."("..CHS[2000372]..")"] = true,
    [CHS[2000378].."("..CHS[2000373]..")"] = true,
    [CHS[2000378].."("..CHS[2000374]..")"] = true,
    [CHS[2000379].."("..CHS[2000371]..")"] = true, --人参鱼丸(1品)
    [CHS[2000379].."("..CHS[2000372]..")"] = true,
    [CHS[2000379].."("..CHS[2000373]..")"] = true,
    [CHS[2000379].."("..CHS[2000374]..")"] = true,
    [CHS[7000120]] = true, --藏宝箱
}

-- 可出售的金钱商品列表
local SELL_CASH_LIST = {
    10000000,
    50000000,
    100000000
}

local MAX_STALL_NUM = 16
local stallNum = 0

local REFRESH_TIME = 3 * 60

MarketMgr.buyState = BUY_STATE.NORMAL
MarketMgr.buyCurType = CHS[5000136]


local GOLD_VENDUE_MAX = 20000000
local GOLD_VENDUE_MIN = 3000

function MarketMgr:getVendueMax()
    return GOLD_VENDUE_MAX
end

function MarketMgr:getVendueMin()
    return GOLD_VENDUE_MIN
end


function MarketMgr:init()
    MarketMgr.allItems = require("cfg/MarketItems")
end

function MarketMgr:cleanData()
    if  not DistMgr.notClearChat then
        self:savePublicCollect()
        self:saveCollect()
        self:gold_saveCollect()
        self:gold_savePublicCollect()
        self.publicCollecItemList = nil
        self.publicCollecGoldItemList = nil
        self.collecItemList = nil
        self.collecGoldItemList = nil
        self.marketLastSelectData = nil
        self.upSort = nil
        self.sortType = nil
        self.goldSearchData = nil
        self.marketSearchData = nil
        self.cashGoodList = nil
        self.goldStallConfig = nil
        self.myMarketGoldVendueGoodsGids = nil
    end

    self.requirItemList = {}
    MarketMgr:cleanAuctionData()
end

function MarketMgr:setBuyStateNormal()
    MarketMgr.buyState = BUY_STATE.NORMAL
end

-- 更新数据
function MarketMgr:updateBuyData(data)
    if nil == data or nil == data.items then return end

    if nil == MarketMgr.buyItemList[data.type] then
        MarketMgr.buyItemList[data.type] = {}
    end

    MarketMgr.buyItemList[data.type].items = data.items or {}
    MarketMgr.buyItemList[data.type].time = os.time()
end

-- 更新摆摊物品
function MarketMgr:updataSellData(data)
    if nil == data or nil == data.items then return end

    self.sellDataInfo = data
    stallNum = data.stallNum
    MarketMgr.sellItemList.sellCash = data.sellCash
    MarketMgr.sellItemList.itemCount = data.itemCount
    local items = data.items
    MarketMgr.sellItemList.items = {}
    for k, item in pairs(items) do
        -- if nil == MarketMgr.sellItemList.items[item.sellPos] then
        item.attrib = Bitset.new(item.attrib)
        if item.amount <= 0 then
            MarketMgr.sellItemList.items[item.sellPos] = nil
        else
            MarketMgr.sellItemList.items[item.sellPos] = item
        end
        -- end
    end
end

-- 更新历史记录
function MarketMgr:updateStallRecord(data)
    MarketMgr.buyHistory.count = data.buyCount
    MarketMgr.buyHistory.items = data.buyItems

    MarketMgr.sellHistory.count = data.sellCount
    MarketMgr.sellHistory.items = data.sellItems
end

-- 更新搜索记录
function MarketMgr:updateSearchList(data)
    MarketMgr.searchList.items = {}
    MarketMgr.searchList = data
    MarketMgr.curSearchPage = 1
end

-- 获取集市有多少页，和当前显示的是第几页
function MarketMgr:getPageViewInfo(type)
    local list = {}
    local curPage = 1
    if self.buyState == BUY_STATE.NORMAL then
        list = MarketMgr.buyItemList[type]
        curPage = MarketMgr.curPage
    else
        list = MarketMgr.searchList
        curPage = MarketMgr.curSearchPage
    end

    if nil == list then
        return 0, 0
    end

    local itemsAmount = #(list.items)
    local totlePage = itemsAmount / pageItemsAmount
    totlePage = math.max(math.ceil(totlePage), 1)

    return curPage, totlePage
end

-- 根据当前页数请求数据
function MarketMgr:getPageDataByType(type)
    local list = {}
    local curPage = 1
    if self.buyState == BUY_STATE.NORMAL then
        list = MarketMgr.buyItemList[type]
        curPage = MarketMgr.curPage
    else
        list = MarketMgr.searchList
        curPage = MarketMgr.curSearchPage
    end

    if nil == list then
        return {}
    end

    local items = {}
    local startIndex = (curPage - 1) * pageItemsAmount + 1
    local endIndex = math.min(curPage * pageItemsAmount, #list.items)

    -- 根据当前页面进行提取数据
    for i = startIndex, endIndex do
        table.insert(items, list.items[i])
    end

    return items
end

-- 请求集市列表数据
-- page_str 其中第二个字段代表公示还是逛摊，调整为直接发送状态 1 公示、2 逛摊、11 拍卖公示、12 拍卖逛摊
function MarketMgr:requestBuyItem(key, page_str, tradeType)
    if MarketMgr.TradeType.goldType == tradeType then
        gf:CmdToServer("CMD_GOLD_STALL_OPEN", {key = key, page_str = page_str})
    else
        local isLegal = MarketMgr:checkMarketSearchKey(key, page_str)
        if not isLegal then
            return
        end

        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STALL_LIST, key, page_str)
    end
end

-- 检查请求集市数据的参数是否正确
function MarketMgr:checkMarketSearchKey(key, page_str, isFromYY)
    if not key then
        return false
    end

    local isIllegal = false
    local keyList = gf:split(key, "_")
    local firstClass = keyList[1]
    local secondClass = keyList[2]

    local firstClassData = allSellItems[firstClass]
    if not firstClassData then
        -- 一级项不存在
        isIllegal = true
    else
        -- 判断二级项是否可以与一级项匹配
        local secondClassIndex
        for i = 1, #firstClassData do
            if firstClassData[i].name == secondClass then
                secondClassIndex = i
            end
        end

        if not secondClassIndex then
            isIllegal = true
        end

        -- 暂且只考虑一级二级项的匹配
    end

    if isIllegal then
        return false
    end

    if page_str then
        local page, type, isUpSort, sortType = string.match(page_str, "(%d);(%d);(%d);(.*)")
        if (not PUBICITY_ITEM[firstClass]) and tonumber(isUpSort) == 2 then
            -- 非公示商品要求降序排列，此为本不应该出现的情况
            return false
        end
    end

    return true
end

-- 请求下一页数据
function MarketMgr:requestNextBuyPageByItem(type)
    local curPage, totlePage = MarketMgr:getPageViewInfo(type)
    curPage = curPage + 1
    if curPage >= totlePage then
        curPage = totlePage
    end

    if self.buyState == BUY_STATE.NORMAL then
        MarketMgr.curPage = curPage
    else
        MarketMgr.curSearchPage = curPage
    end

    MessageMgr:pushMsg({MSG = 0xC01F})
end

-- 请求上一页数据
function MarketMgr:requestLastBuyPageByItem(type)
    local curPage = 1
    if self.buyState == BUY_STATE.NORMAL then
        curPage = MarketMgr.curPage
    else
        curPage = MarketMgr.curSearchPage
    end

    curPage = curPage - 1
    if curPage <= 1 then
        curPage = 1
    end

    if self.buyState == BUY_STATE.NORMAL then
        MarketMgr.curPage = curPage
    else
        MarketMgr.curSearchPage = curPage
    end

    MessageMgr:pushMsg({MSG = 0xC01F})
end

-- 请求刷新集市列表数据
function MarketMgr:requestRefreshItemsByItem(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_STALL_LIST, type)
    MarketMgr.buyState = BUY_STATE.NORMAL
    MarketMgr.curPage = 1
end

-- 请求购买  type  0   // 普通购买        1   // 搜索购买      2   // 收藏购买            3   // 抢购     4 我的竞拍
function MarketMgr:BuyItem(itemId, key, pageStr, price, type, tradeType, amount)
    if self:isGoldtype(tradeType) then
        gf:CmdToServer("CMD_GOLD_STALL_BUY_GOODS", {id = itemId, key = key, pageStr = pageStr, price = price, type = type})
    else
        gf:CmdToServer("CMD_BUY_FROM_STALL", {id = itemId, key = key, pageStr = pageStr, price = price, type = type, amount = amount})
    end
end

-- 获取背包中可摆摊的物品
function MarketMgr:getBagCanSell(tradeType)
    -- 获取背包中的所有物品
    local bagItems = InventoryMgr:getAllExistItem()
    local items = {}
    for i = 1, #bagItems do
        local name = bagItems[i].name

        if nil == MarketMgr.allItems or nil == next(MarketMgr.allItems) then
            MarketMgr.allItems = require("cfg/MarketItems")
        end

		-- 时装的话，需要转化下
        if bagItems[i].fasion_type == FASION_TYPE.FASION then
            name = bagItems[i].alias
        end

        if nil ~= MarketMgr.allItems[name] then
            local levevlList = gf:split(MarketMgr.allItems[name]["level"], ",")
            local isCanAdd = false
            if not MarketMgr.allItems[name].needLevelCheck then  -- 不限等级
                isCanAdd = true
            else
                for j = 1, #levevlList do
                    if bagItems[i].level == tonumber(levevlList[j]) then
                        isCanAdd = true
                        break
                    end
                end
            end

            -- 如果是金元宝交易(只有装备和高级首饰才能摆摊)
            if self:isGoldtype(tradeType) and MarketMgr.allItems[name]["subClass"] ~= CHS[3001073]
                and MarketMgr.allItems[name]["subClass"] ~= CHS[3001022] and MarketMgr.allItems[name]["subClass"] ~= CHS[7000144]then
                isCanAdd = false
            end


            if isCanAdd then
                table.insert(items, bagItems[i])
            end
        end

        -- 带属性超级黑水晶
       if string.match(name, CHS[3004164]) and MarketMgr.TradeType.marketType == tradeType then
            table.insert(items, bagItems[i])
       end

    end

    -- 过滤永久限制交易道具
    local itemsFiltered = {}
    local index = 1
    for i = 1, #items do
        local isLimitedForever = InventoryMgr:isLimitedItemForever(items[i])

        if not isLimitedForever then
            itemsFiltered[index] = items[i]
            index = index + 1
        end
    end

    return itemsFiltered
end


-- 是否可以摆摊
function MarketMgr:isItemCanSell(item)
    local name = item.name
    if item.fasion_type == FASION_TYPE.FASION then
        name = item.alias
    end

    if nil ~= MarketMgr.allItems[name] then
        local levevlList = gf:split(MarketMgr.allItems[name]["level"], ",")
        if not MarketMgr.allItems[name].needLevelCheck then  -- 不限等级
            return true
        else
            for j = 1, #levevlList do
                if item.level == tonumber(levevlList[j]) then
                    return true
                end
            end
        end
    end

    -- 带属性超级黑水晶
    if string.match(name, CHS[3004164]) then
        return true
    end

    if item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        return true
    end
end

-- 购买宠物时，需要判断购买的宠物是否可以参战，如果不能参战，则添加提示
function MarketMgr:petCannotFightTip(item)
    if PetMgr:getPetIcon(item.name) then    -- 宠物
        local reqLevel = PetMgr:getPetLevelReq(item.name)
        if reqLevel and reqLevel > Me:getLevel() then
            return CHS[7200000]     -- 宠物携带等级超过自身等级
        elseif item.level - Me:getLevel() > MAX_LEVEL_DIFF then

            local goodsData = json.decode(item.extra)
            if goodsData.mount_type and goodsData.mount_type > 0 then
                return CHS[4101275]
            else
                return CHS[7200001]     -- 宠物等级超过自身等级15级
            end
        end
    end
    return ""
end

-- 获取用于判断是否公示物品的道具名
function MarketMgr:getItemNameForJudgePublicity(item)
    local itemName = item.name
    local itemInfo = MarketMgr:getSellItemInfo(itemName)

    -- 如果是未鉴定装备需要拼接 （未鉴定）去表查找
    if itemInfo and itemInfo.subClass and itemInfo.subClass == CHS[3004159] and item.unidentified == 1 then
        itemName = itemName .. CHS[3003087]
    end

    return itemName
end

-- 是否是公示物品
function MarketMgr:isPublicityItem(item)
    local name = item
    if type(item) == 'table' then
        name = MarketMgr:getItemNameForJudgePublicity(item)
    end

    local item = MarketMgr.allItems[name]

    if item then
        if PUBICITY_ITEM[item["subClass"]]then
            return true
        end
    elseif PetMgr:getPetIcon(name) then -- 宠物
        return true
    elseif name == CHS[3004165] or name == CHS[3004166] then
        return true
    else
        if  string.match(name, CHS[3004164]) then
            return true
        end
    end

    return  false
end

-- 获取相应的item
function MarketMgr:getSellItemInfo(name)
    return MarketMgr.allItems[name]
end

-- 请求我的摆摊信息
function MarketMgr:requestRefreshMySell(tradeType)
    if self:isGoldtype(tradeType) then
        gf:CmdToServer("CMD_GOLD_STALL_OPEN_MY")
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_MY_STALL)
    end
end

-- 获取我的摆摊信息
function MarketMgr:getMySellItems()
    local items = {}
    local sellCash = MarketMgr.sellItemList.sellCash
    for i = 1, MarketMgr:getMySellNum() do
        if nil ~= MarketMgr.sellItemList.items then
            local item = MarketMgr.sellItemList.items[i]
            if nil == item then
                table.insert(items, {})
            else
                table.insert(items, {sellPos = i, id = item.item_unique, icon = item.icon, sellCash = sellCash, name = item.name, level = item.level, amount = item.amount, price = item.price, isTimeOver = item.isTimeOver, detail = item})
            end
        else
            table.insert(items, {})
        end
    end

    return items
end

-- 获取摆摊帐户金钱
function MarketMgr:getMySellCashData(tradeType)
    return self:getMySellItemListInfo(tradeType).sellCash or 0
end

-- 获取摆摊总的摊位数
function MarketMgr:getMySellNum(tradeType)
    return self:getMySellItemListInfo(tradeType).stallTotalNum or 0
end

function MarketMgr:getMaxSellNum()
    return MAX_STALL_NUM
end

-- 收款
function MarketMgr:getMySellCash(tradeType)
    if self:getMySellCashData(tradeType) >0 then
        if self:isGoldtype(tradeType) then
            gf:CmdToServer("CMD_GOLD_STALL_TAKE_CASH")
        else
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_STALL_TAKE_CASH)
        end
    else
        gf:ShowSmallTips(CHS[3004167])
    end
end

-- 修改集市珍宝，公示期商品价格
function MarketMgr:changeGoldGoodsPrice(goods_gid, price)
    gf:CmdToServer("CMD_GOLD_STALL_CHANGE_PRICE", {goods_gid = goods_gid, price = price})
end

-- 修改集市，公示期商品价格
function MarketMgr:changeGoodsPrice(goods_gid, price)
    gf:CmdToServer("CMD_STALL_CHANGE_PRICE", {goods_gid = goods_gid, price = price})
end

-- 请求历史数据
function MarketMgr:requestHistoryInfo(tradeType)
    if MarketMgr.TradeType.goldType == tradeType then
        gf:CmdToServer("CMD_GOLD_STALL_RECORD")
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_STALL_OPEN_RECORD)
    end
end

-- 获取历史数据
function MarketMgr:getHistoryInfo()
    return MarketMgr.sellHistory.items, MarketMgr.buyHistory.items
end

-- 摆摊
--
function MarketMgr:startSell(bagPos, price, pos, type, tradeType, amount, appointee_gid, sellType)
    if self:isGoldtype(tradeType) then
        appointee_gid = appointee_gid or ""
        if not sellType then sellType = 0 end
        gf:CmdToServer("CMD_GOLD_STALL_PUT_GOODS", {inventoryPos = bagPos, price = price, pos = pos, type = type, appointee = appointee_gid, sell_type = sellType})
    else
        local isExpensive = false
        local name
        if type == 2 then
            -- 宠物
            local pet = PetMgr:getPetById(tonumber(bagPos))
            isExpensive = gf:isExpensive(pet, true)
            name = pet:queryBasic("name")
        else
            -- 非宠物
            local item = InventoryMgr:getItemByPos(bagPos)
            isExpensive = gf:isExpensive(item)
            name = item.name
        end

        if isExpensive then
            local str = string.format(CHS[7000300], name, gf:getMoneyDesc(price))
            gf:confirm(str, function()
        gf:CmdToServer("CMD_SET_STALL_GOODS", {inventoryPos = bagPos, price = price, pos = pos, type = type, amount = amount or 1})
            end)
            return
    end

        gf:CmdToServer("CMD_SET_STALL_GOODS", {inventoryPos = bagPos, price = price, pos = pos, type = type, amount = amount or 1})
    end
end

-- 重新摆摊
function MarketMgr:reStartSell(goodId, price, tradeType, sellType)
    if self:isGoldtype(tradeType) then
        sellType = sellType or 0
        gf:CmdToServer("CMD_GOLD_STALL_RESTART_GOODS", {goodId = goodId, price = price, sell_type = sellType})
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_STALL_RESTART_GOODS, goodId, price)
    end
end

-- 撤摊
function MarketMgr:stopSell(goodId, tradeType)
    if self:isGoldtype(tradeType) then
        gf:CmdToServer("CMD_GOLD_STALL_REMOVE_GOODS", {goodId = goodId})
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_STALL_REMOVE_GOODS, goodId)
    end
end

-- 设置上一次意图摆摊的非公示商品
function MarketMgr:setLastSellUnPublicItem(data)
    self.lastSellUnPublicItem = data
end

-- 获取上一次意图摆摊的非公示商品
function MarketMgr:getLastSellUnPublicItem()
    if not self.lastSellUnPublicItem then
        return {}
    else
        return self.lastSellUnPublicItem
    end
end

-- 获取空位，没有则返回nil
function MarketMgr:getSellPos(tradeType)
    if tradeType == MarketMgr.TradeType.marketType then
        -- WDSY-37261 集市废弃掉 sellPos 字段
        return 0
    end

    local maxNum = MarketMgr:getMySellNum(tradeType)
    local itemlist = self:getSellItemList(tradeType)
    local count = #itemlist
    if count >= maxNum then
        return nil
    end

    for i = 1, maxNum do
        local flag = true
        for j = 1, count do
            if i == itemlist[j].pos then
                flag = false
                break
            end
        end

        if flag then
            return i
        end
    end

    return nil
end

function MarketMgr:getSellPosCount(tradeType)
    return self:getMySellItemListInfo(tradeType).stallNum
end

-- 获取摊位费
function MarketMgr:getSellPosCash(totle)
    local cash = math.floor(totle * 0.01)
    if cash <= 1000 then
        cash = 1000
    end

    if cash >= 100000 then
        cash = 100000
    end

    return cash
end

-- 获取增益
function MarketMgr:getItemAddCash(price)
    if nil == price then
        price = 1
    end

    return math.floor(price * 0.05)
end

-- 获取最大增益
function MarketMgr:getItemAddMaxCash(price)
    return math.floor(price * 0.3)
end

-- 获取增益率
function MarketMgr:getItemAddCashRate(time)
    if nil == time then
        time = 0
    end

    return time * 0.05
end

-- 获取增益次数
function MarketMgr:getItemAddRateTime(curPrice, standPrice)
    local value = curPrice - standPrice

    if value < 0 then
        return math.floor(value / (standPrice * 0.05))
    end

    return math.ceil(value / (standPrice * 0.05))
end

-- 查询价格
function MarketMgr:requestItemPrice(itemName)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_STALL_QUERY_PRICE, itemName)
end

-- 根据字节获取搜索结果
function MarketMgr:matchTheChar(str, tradeType)
    local items = {}
    if nil == MarketMgr.allItems then
        MarketMgr.allItems = require("cfg/MarketItems")
    end

    for k, v in pairs(MarketMgr.allItems) do
        if nil ~= gf:findStrByByte(k, str) then
            if not DistMgr:curIsTestDist() and v["needHideInPublic"] then
            else
                if self:isGoldtype(tradeType) then
                    if v["subClass"] == CHS[3001073] or v["subClass"] == CHS[3001022] or v["subClass"] == CHS[7000144] then
                        table.insert(items, k)
                    end
                else
                    table.insert(items, k)
                end
            end
        end
    end

    return items
end

-- 判断是否存在这个物品
function MarketMgr:exsistItem(itemName)
    if MarketMgr.allItems[itemName] then
        return true
    else
        return false
    end
end

-- 搜索功能
function MarketMgr:searchItem(str)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_STALL_SEARCH_ITEM, str)
    MarketMgr.buyState = BUY_STATE.SEARCH
end

-- 获取集市切换之前的状态
function MarketMgr:getBuyItemStateData()
    return MarketMgr.buyState, MarketMgr.buyCurType
end

MarketMgr:init()

function MarketMgr:MSG_STALL_MINE(data)
    self.sellDataInfo = data

    -- 是否有过期商品
    local hasOutTimeGoods = false
    for i = 1, data.stallNum do
        if data.items[i] and data.items[i].status == 3 then
            hasOutTimeGoods = true
            break
        end
    end

    -- 主界面珍宝是否有小红点
    local goldHasRed = RedDotMgr:hasRedDotInfo("SystemFunctionDlg", "TreasureButton")

    -- 检测是否删除主界面相关小红点
    if not hasOutTimeGoods and data.sellCash == 0 then
        -- 集市无过期商品 and 收入为0，清除集市按钮小红点
        RedDotMgr:removeOneRedDot("SystemFunctionDlg", "MarketButton")

        -- 当珍宝没有小红点，清除交易按钮小红点
        if not goldHasRed then
            RedDotMgr:removeOneRedDot("SystemFunctionDlg", "ShowTradeButton")
        end
    end

    -- 更新选中的
    if self.selectItem then
        for i = 1, data.stallNum do
            local id = data.items[i].id
            if id == self.selectItem.id then
                self.selectItem = data.items[i]
            end
        end
    end
end


function MarketMgr:setSelectItemByField(field, value)
    if self.selectItem and self.selectItem[field] then
        self.selectItem[field] = value
    end
end

function MarketMgr:MSG_GOLD_STALL_MINE(data)
	self.goldSellDataInfo = data

    -- 是否有过期商品
    local hasOutTimeGoods = false
    for i = 1, data.stallNum do
        if data.items[i] and data.items[i].status == 3 then
            hasOutTimeGoods = true
            break
        end
    end

    -- 主界面珍宝是否有小红点
    local marketHasRed = RedDotMgr:hasRedDotInfo("SystemFunctionDlg", "MarketButton")

    -- 检测是否删除主界面相关小红点
    if not hasOutTimeGoods and data.sellCash == 0 then
        -- 珍宝无过期商品 and 收入为0，清除珍宝按钮小红点
        RedDotMgr:removeOneRedDot("SystemFunctionDlg", "TreasureButton")

        -- 当珍宝没有小红点，清除交易按钮小红点
        if not marketHasRed then
            RedDotMgr:removeOneRedDot("SystemFunctionDlg", "ShowTradeButton")
        end
    end

    -- 更新选中的
    if self.selectItem then
        for i = 1, data.stallNum do
            local id = data.items[i].id
            if id == self.selectItem.id then
                self.selectItem = data.items[i]
            end
        end
    end
end

-- 获取交易数量
function MarketMgr:getDealNum(tradeType)
    return self:getMySellItemListInfo(tradeType).dealNum or 0
end

-- 获取自己摆摊列表摆摊数据
function MarketMgr:getMySellItemListInfo(tradeType)
    if self:isGoldtype(tradeType) then
      gf:ShowSmallTips("获取自己摆摊列表摆摊数据"..tradeType)
        return self.goldSellDataInfo or {}
    else
        return self.sellDataInfo or {}
    end
end

-- 获取摆摊物品列表
function MarketMgr:getSellItemList(tradeType)
    local function sortList(a, b)
        return a.startTime > b.startTime
    end

    local items = {}
    if self:isGoldtype(tradeType) then
        items = self.goldSellDataInfo.items
    else
        items = self.sellDataInfo.items
    end

    if items then
        for i = 1, #items do
            table.sort(items, sortList)
        end
    end
    return items or {}
end

function MarketMgr:MSG_STALL_ITEM_LIST(data)
    if data.select_gid and data.select_gid ~= ""
        and data.path_str and data.path_str ~= "" then
        local dlg
        if data.sell_stage == 1 then
            dlg = DlgMgr:openDlg("MarketPublicityDlg")
            DlgMgr:reorderDlgByName("MarketPublicityDlg")
        else
            dlg = DlgMgr:openDlg("MarketBuyDlg")
            DlgMgr:reorderDlgByName("MarketBuyDlg")
        end
        DlgMgr:reorderDlgByName("MarketTabDlg")

        local list = gf:split(data.path_str, "_")
        list[4] = data.select_gid
        dlg:onDlgOpened(list)

        dlg.sortType = data.sort_key
        dlg.upSort = data.is_descending ~= 1 and true or false

        dlg:refreshUpDownImage()

    end

    data.isMarket = true

    if not self.requirItemList then self.requirItemList = {} end
    if data.sell_stage == 1 then
        self.requirItemList["MarketPublicityDlg"] = data
    else
        self.requirItemList["MarketBuyDlg"] = data
    end

    -- 列表发生变化，关闭当前选中的举报界面
    DlgMgr:closeDlg("BlogButtonListDlg")
end

function MarketMgr:MSG_GOLD_STALL_GOODS_LIST(data)
    if data.select_gid and data.select_gid ~= ""
        and data.path_str and data.path_str ~= "" then
        local dlg
        if data.sell_stage == MARKET_STATUS.STALL_GS_SHOWING then
            dlg = DlgMgr:openDlg("MarketGlodPublicityDlg")
            DlgMgr:reorderDlgByName("MarketGlodPublicityDlg")
        elseif data.sell_stage == MARKET_STATUS.STALL_GS_SELLING then
            dlg = DlgMgr:openDlg("MarketGoldBuyDlg")
            DlgMgr:reorderDlgByName("MarketGoldBuyDlg")
        elseif data.sell_stage == MARKET_STATUS.STALL_GS_AUCTION_SHOW or data.sell_stage == MARKET_STATUS.STALL_GS_AUCTION then
            dlg = DlgMgr:openDlgEx("MarketGoldVendueDlg", true)
            DlgMgr:reorderDlgByName("MarketGoldVendueDlg")
        end
        DlgMgr:reorderDlgByName("MarketGoldTabDlg")

        local list = gf:split(data.path_str, "_")
        list[4] = data.select_gid
        dlg:onDlgOpened(list, data)

        dlg.sortType = data.sort_key
        dlg.upSort = data.is_descending ~= 1 and true or false

        dlg:refreshUpDownImage()
    end


    if not self.requirItemList then self.requirItemList = {} end
    if data.sell_stage == MARKET_STATUS.STALL_GS_SHOWING then
        self.requirItemList["MarketGlodPublicityDlg"] = data
    elseif data.sell_stage == MARKET_STATUS.STALL_GS_SELLING then
        self.requirItemList["MarketGoldBuyDlg"] = data
    elseif data.sell_stage == MARKET_STATUS.STALL_GS_AUCTION_SHOW then--拍卖公示
        self.requirItemList["MarketGoldBuyDlgPublicityCheckBox"] = data
    elseif data.sell_stage == MARKET_STATUS.STALL_GS_AUCTION then--拍卖寄售
        self.requirItemList["MarketGoldBuyDlgSellingCheckBox"] = data
    end
end

function MarketMgr:getStallItemList(dlgName)
    if not self.requirItemList then return {} end

    return self.requirItemList[dlgName] or {}
    --[[
    if self:isGoldtype(tradeType) then
        return self.requirGoldItemList or {}
    else
        return self.requirItemList or {}
    end
    --]]
end

-- 历史交易
function MarketMgr:MSG_STALL_RECORD(data)
    self.buyItemList = {}
    self.sellItemList = {}

    self.buyItemList = data.buyList
    self.sellItemList = data.sellList
end

-- 珍宝历史交易
function MarketMgr:MSG_GOLD_STALL_RECORD(data)
    self.goldBuyItemList = {}
    self.goldSellItemList = {}

    self.goldBuyItemList = data.buyList
    self.goldSellItemList = data.sellList
end


-- 购买记录,(保存最多30条)
function MarketMgr:getBuyItemListRecord(tradeType)
    local buyList = {}
    local curBuyList = {}

    if MarketMgr.TradeType.goldType == tradeType then
        curBuyList = self.goldBuyItemList
    else
        curBuyList = self.buyItemList
    end

    if not curBuyList then return end


    for i = #curBuyList, 1, -1 do
        table.insert(buyList, curBuyList[i])
    end

    return buyList
end

-- 出售记录
function MarketMgr:getSellItemListRecord(tradeType)
    local sellList = {}
    local curSellList = {}

    if MarketMgr.TradeType.goldType == tradeType then
        curSellList = self.goldSellItemList
    else
        curSellList = self.sellItemList
    end

    if not curSellList then return end


    for i = #curSellList, 1, -1 do
        table.insert(sellList, curSellList[i])
    end

    return sellList
end

-- 审核记录
function MarketMgr:getVerifyItemRecord(tradeType)

    local verifyList = {}
    local curSellList = {}

    if MarketMgr.TradeType.goldType == tradeType then
        curSellList = self.goldSellItemList or {}
    else
        curSellList = self.sellItemList or {}
    end

    if not curSellList then return end

    for i = #curSellList, 1, -1 do
        if curSellList[i].status == 5 then -- 审核中
            table.insert(verifyList, curSellList[i])
        end
    end

    return verifyList
end

function MarketMgr:MSG_STALL_SERACH_ITEM_LIST(data)
    MarketMgr:updateSearchList(data)
end

function MarketMgr:getEquipmentSecondClassList()
    if not self.equipmentSecondClassList then
        self.equipmentSecondClassList = {}
        -- 根据添加一个全部武器，放在第一个
        table.insert(self.equipmentSecondClassList, CHS[6400000])

        for k, v in pairs(allSellItems) do
            if k == CHS[3004159] then
                local list = v
                for i = 1, #list do
                    if list[i].name ~= CHS[4300170] and list[i].name ~= CHS[4300171] then
                    table.insert(self.equipmentSecondClassList, list[i].name)
                end
                end
                break
            end
        end
    end

    return self.equipmentSecondClassList
end

function MarketMgr:setOpenType(openType)
    self.openType = openType
end

-- pram 悬浮框表示位置， 摆摊界面表示物品的基本信息
-- openType 显示类型 0我的操作， 1查看,2正常悬浮框
function MarketMgr:requireMarketGoodCard(goodIdAndEndTime, openType, pram, isPet, isFromBuyItem, tradeType)
    MarketMgr:setOpenType(openType)
    self.isPet = isPet
    self.tradeType = tradeType
    local list = gf:split(goodIdAndEndTime, "|")
    local goodId = list[1]
    local endTime = list[2]
    self.requireCardGoodId = goodId
    if self.openType == MARKET_CARD_TYPE.ME_ACTION or self.openType == MARKET_CARD_TYPE.VIEW_OTHERS then -- 如果是悬浮框则pram是区域
        self.selectItem = pram -- 这个选中物品对象
    else
        self.pram = pram
    end

    -- 存在缓存
    if self.cardInfoList and self.cardInfoList[goodId] and tostring(self.cardInfoList[goodId].endTime) == endTime and not self:isGoldtype(tradeType) and
            not self.isPet then  -- 宠物名片不使用缓存
        self:MSG_MARKET_GOOD_CARD(self.cardInfoList[goodId])
    else
        local type = nil
        if isFromBuyItem then
            type = 1
        else
            type = 2
        end

        if self:isGoldtype(tradeType) then
            gf:CmdToServer('CMD_GOLD_STALL_GOODS_INFO', {
                goodId = goodId, type = type
            })
        else

            gf:CmdToServer('CMD_REQUEST_ITEM_INFO', {
                item_cookie = goodId ..";" .. type
            })
        end
    end
end

-- 返回摆摊商品信息
function MarketMgr:MSG_MARKET_GOOD_CARD(data)
    if self.cardInfoList == nil then
        self.cardInfoList = {}
    end

    self.cardInfoList[data.id] = data

    if self.requireCardGoodId ~= data.id then
        return
    end

    data.item.isMarket = true
    if self.openType ~= MARKET_CARD_TYPE.ME_ACTION then
        -- 显示名片
        self:showItemFloatBox(data)
    else
        -- 显示摆摊信息
        self:showItemSellDlg(data)
    end
end

-- 珍宝返回摆摊商品信息
function MarketMgr:MSG_GOLD_STALL_GOODS_INFO_ITEM(data)
    self:MSG_MARKET_GOOD_CARD(data)
end

-- 显示道具名片
function MarketMgr:showItemFloatBox(data, rect)

    if self:isGoldtype(self.tradeType) and self.openType ~= MARKET_CARD_TYPE.FLOAT_DLG then
    --[[
        if  self:isweapon( data.item.item_type, data.item.equip_type, data.item.unidentified )then
            local dlg = DlgMgr:openDlg("MarketGoldItemInfoDlg")
            dlg:setData(data.item, self.selectItem)
        elseif EquipmentMgr:isJewelry(data.item) then
            local dlg = DlgMgr:openDlg("MarketGoldItemInfoDlg")
            dlg:setData(data.item, self.selectItem)
        elseif data.item.item_type == ITEM_TYPE.ARTIFACT then
            local dlg = DlgMgr:openDlg("MarketGoldItemInfoDlg")
            dlg:setData(data.item, self.selectItem)
        end
        ]]
        MarketMgr:openZhenbaoSellDlg(data.item, self.selectItem)
    else
        local cardInfo = data.item
        local equipType = cardInfo["equip_type"]

        cardInfo.attrib = Bitset.new(cardInfo.attrib)
        InventoryMgr:showOnlyFloatCardDlgEx(cardInfo, rect or self.pram, true)
    end






end

-- 显示摆摊中的信息
function MarketMgr:showItemSellDlg(data)

    if self:isGoldtype(self.tradeType) then
        MarketMgr:openZhenbaoSellDlg(data.item, self.selectItem, true)
    elseif self:isweapon( data.item.item_type, data.item.equip_type, data.item.unidentified )then
        local dlg = DlgMgr:openDlg("MarketSellEquipmentDlg")
        dlg:setTradeType(self.tradeType)
        dlg:setEquipInfo(data.item, self:statusToDlgType(self.selectItem.status), data.id)
    else
        self:openSellItemDlg(data.item, self:statusToDlgType(self.selectItem.status), self.tradeType, data.id)
    end
end

-- goodId 撤摊 和 重新摆摊所需要的 物品 id
-- tardeType 默认为集市
function MarketMgr:openSellItemDlg(item, dlgType, tardeType, goodId)
    if self:isCanDoubleSellAndBuy(item.name) then
        local dlg = DlgMgr:openDlg("MarketBatchSellItemDlg")
        dlg:setTradeType(tardeType)
        dlg:setItemInfo(item, dlgType, goodId)
    else
        local dlg = DlgMgr:openDlg("MarketSellItemDlg")
        dlg:setTradeType(tardeType)
        dlg:setItemInfo(item, dlgType, goodId)
    end
end

function MarketMgr:isCanDoubleSellAndBuy(name)
    return DOUBEL_ITEM[name]
end

function MarketMgr:statusToDlgType(status)
    local dlgType = 1
    if status == GOOD_STATE_SHOWING then
        -- 公示中
        dlgType = 4
    elseif status == GOOD_STATE_SELLING then
        -- 出售中
        dlgType = 1
    elseif status == GOOD_STATE_OUT_SELLING then
        -- 超时
        dlgType = 2
    end

    return dlgType
end

-- 判断是否是武器并且未鉴定
function MarketMgr:isweapon(item_type, equip_type, unidentified)
     if item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(equip_type) and  unidentified == 0 then
        return true
     end
end

-- 返回摆摊宠物信息
function MarketMgr:MSG_MARKET_PET_CARD(data)
    if self.cardInfoList == nil then
        self.cardInfoList = {}
    end

    self.cardInfoList[data.goodId] = data

    if self.requireCardGoodId ~= data.goodId then
        return
    end

    local objcet = DataObject.new()
    data.raw_name = PetMgr:getShowNameByRawName(data.raw_name)
    data.icon =  PetMgr:getPetIcon(data.raw_name)
    data.id = 0
    objcet:absorbBasicFields(data)

    if self.openType ~= MARKET_CARD_TYPE.ME_ACTION then
        -- 显示名片
        self:showPetFloatBox(objcet)
    else

        if self:isGoldtype(self.tradeType) then
  --          local dlg = DlgMgr:openDlg("MarketGoldItemInfoDlg")
  --          dlg:setData(objcet, self.selectItem, true)

            MarketMgr:openZhenbaoSellDlg(objcet, self.selectItem, true)
        else

            -- 显示摆摊信息
            local dlg = DlgMgr:openDlg("MarketSellPetDlg")
            dlg:setTradeType()
            dlg:setPetInfo(objcet, self:statusToDlgType(self.selectItem.status), data.goodId)
        end
    end
end

-- 珍宝返回摆摊宠物信息
function MarketMgr:MSG_GOLD_STALL_GOODS_INFO_PET(data)
    self:MSG_MARKET_PET_CARD(data)
end

function MarketMgr:showPetFloatBox(pet)

    if self:isGoldtype(self.tradeType) and self.openType ~= MARKET_CARD_TYPE.FLOAT_DLG then
            --local dlg = DlgMgr:openDlg("MarketGoldItemInfoDlg")
            --dlg:setData(pet, self.selectItem)

            MarketMgr:openZhenbaoSellDlg(pet, self.selectItem)
    else
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet)
        PetMgr:setIntimacyForCard(dlg, "isMarket", pet)
    end


end


-- 获取当前选中物品的基本信息
function MarketMgr:getSelectGoodInfo()
    return self.selectItem or {}
end

-- 获取公示时间字符串
-- displayType == 1,显示格式为  小时：分钟，仅集市显示
-- displayType == 其他,显示格式为  xx小时   以后要是显示其他格式，可以扩展
function MarketMgr:getTimeStr(leftTime, displayType)
    if not displayType then displayType = MarketMgr:getTradeType() end
    if displayType == 1 then
        -- 分钟向上取整，所以加上60秒
        local value = leftTime + 60

        if value >= 60 * 60 * 12 then
            return "12:00"
        end

        -- 上级界面只有再打开时刷新，未制作之前表现为，都显示1分钟，与张骋确认，显示为 00:01
        if value <= 0 then
            return "00:01"
        end

        local hours = math.floor(value / 3600)
        local minuts = math.floor((value % 3600) / 60)

        return string.format("%02d:%02d", hours, minuts)
    else
    if leftTime  <=  0 then
        return CHS[3004168]
    end

    local str = ""
    local day = leftTime / (3600 * 24)

    if day > 1 then
        day = math.ceil((leftTime - TIME_DELAY) / (3600 * 24))
        str = day..CHS[6000229]
    else
        local ours = leftTime / 3600
        if ours > 1 then
            ours =  math.ceil((leftTime - TIME_DELAY) / 3600)
            str = ours..CHS[3004169]
        else
            local minute = math.ceil(leftTime / 60)
            str = minute..CHS[3004170]
        end
    end

    return str
    end
end


function MarketMgr:insertHistroySearch(name, tradeType)
    if tradeType == MarketMgr.TradeType.marketType then
        if not self.histroySearchList then
        self.histroySearchList = {}
        end

        for i = #self.histroySearchList, 1, -1 do
            -- 在for循环中remove项，需要注意table的某一项被remove后，其后一项由于索引的改变不会被遍历
            -- 另外，如果倒数第二项满足remove条件，则“最后一项的索引改变”会导致remove后的table找不到原本要遍历的索引项
            -- 如果从后向前进行遍历，则可以避免以上情况的发生
            if name == self.histroySearchList[i] then
                table.remove(self.histroySearchList, i)
            end
        end

        -- 不能超过10个
        if #self.histroySearchList == 10 then
            table.remove(self.histroySearchList, 10)
        end

        table.insert(self.histroySearchList, 1, name)
    elseif tradeType == MarketMgr.TradeType.goldType then
        if not self.goldHistroySearchList then
            self.goldHistroySearchList = {}
        end

        for i = #self.goldHistroySearchList, 1, -1 do
            if name == self.goldHistroySearchList[i] then
                table.remove(self.goldHistroySearchList, i)
            end
        end

        -- 不能超过10个
        if #self.goldHistroySearchList == 10 then
            table.remove(self.goldHistroySearchList, 10)
        end

        table.insert(self.goldHistroySearchList, 1, name)
    end
end

-- 获取历史搜索记录
function MarketMgr:getHistorySearchList(tradeType)
    if tradeType == MarketMgr.TradeType.marketType then
        return self.histroySearchList or {}
    elseif tradeType == MarketMgr.TradeType.goldType then
        return self.goldHistroySearchList or {}
    end
end

-- 摆摊搜索
function MarketMgr:startSearch(key, eatra, type, tradeType)
    -- 珍宝修改后，原 type 反过来了，需要转换下,具体见任务 WDSY-31913 中方案
    -- type 客户端当前 1表示逛摊，2表示公示，服务器相反，做个转换
    if type == TradingMgr.LIST_TYPE.SALE_LIST then
        -- 表示请求逛摊中的商品
        type = 2
    elseif type == TradingMgr.LIST_TYPE.SHOW_LIST then
        -- 表示请求公示中的商品
        type = 1
    end

    if self:isGoldtype(tradeType) then
        gf:CmdToServer("CMD_GOLD_STALL_SEARCH_GOODS", {key = key, eatra = eatra, type = type})
    else
        local isLegal = MarketMgr:checkMarketSearchKey(key, nil, true)
        if not isLegal then
            return
        end

        gf:CmdToServer("CMD_MARKET_SEARCH_ITEM", {key = key, eatra = eatra, type = type})
    end
end

-- 搜索結果
function MarketMgr:MSG_MARKET_SEARCH_RESULT(data)
    local itemList = data.itemList
    if not itemList or #itemList == 0 then
        return
    end

    if data.is_free == 1 then
        -- 免费的搜索结果，目前指的是摆摊时商品的对比数据
        self.searchSellItemList = {}
        self.searchSellItemList = itemList
    else
        -- 收费的搜索结果，目前指的是鹰眼搜索
        if itemList[1].status == GOOD_STATE_SELLING then
            -- 摆摊数据
            self.searchItemLsit = {}
            self.searchItemLsit = itemList

            -- 记录此次得到搜索结果的时间，搜索结果最多保留15分钟
            self.searchItemLsit["dataTime"] = gf:getServerTime()

            self:setDownSearchList()
        elseif itemList[1].status == GOOD_STATE_SHOWING then
            -- 公示数据
            self.searchPublicityItemList = {}
            self.searchPublicityItemList = itemList

            -- 记录此次得到搜索结果的时间，搜索结果最多保留15分钟
            self.searchPublicityItemList["dataTime"] = gf:getServerTime()

            self:setDownSearchPublicityList()
        end
    end
end

-- 珍宝搜索結果
function MarketMgr:MSG_GOLD_STALL_SEARCH_GOODS(data)
    local itemList = data.itemList
    if not itemList or #itemList == 0 then
        return
    end
    if itemList[1].status == GOOD_STATE_SELLING then
        -- 摆摊数据
        self.goldSearchItemList = {}
        self.goldSearchItemList = itemList

        -- 记录此次得到搜索结果的时间，搜索结果最多保留15分钟
        self.goldSearchItemList["dataTime"] = gf:getServerTime()
        self:setGoldDownSearchList()
    elseif itemList[1].status == GOOD_STATE_SHOWING then
        -- 公示数据
        self.goldSearchPublicityItemList = {}
        self.goldSearchPublicityItemList = itemList

        -- 记录此次得到搜索结果的时间，搜索结果最多保留15分钟
        self.goldSearchPublicityItemList["dataTime"] = gf:getServerTime()
        self:setGoldDownSearchPublicityList()
    end
end

-- 获取摆摊“其他玩家出售物品”数据
function MarketMgr:getSearchSellItemList()
    if not self.searchSellItemList then
        return {}
    end

    return self.searchSellItemList
end

-- 搜索升序（摆摊）
function MarketMgr:getSearchItemList(tradeType)
    if self:isGoldtype(tradeType) then
        -- 如果珍宝的搜索结果超过15分钟，则失效
        if not self.goldSearchItemList then
            return {}
        end

        if gf:getServerTime() - (self.goldSearchItemList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.goldSearchItemList = {}
        end

        return self.goldSearchItemList
    else
        -- 如果集市的搜索结果超过15分钟，则失效
        if not self.searchItemLsit then
            return {}
        end

        if gf:getServerTime() - (self.searchItemLsit["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.searchItemLsit = {}
        end

        return self.searchItemLsit
    end
end

-- 搜索升序（公示）
function MarketMgr:getSearchPublicityItemList(tradeType)
    if self:isGoldtype(tradeType) then
        -- 如果珍宝的搜索结果超过15分钟，则失效
        if not self.goldSearchPublicityItemList then
            return {}
        end

        if gf:getServerTime() - (self.goldSearchPublicityItemList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.goldSearchPublicityItemList = {}
        end

        return self.goldSearchPublicityItemList
    else
        -- 如果集市的搜索结果超过15分钟，则失效
        if not self.searchPublicityItemList then
            return {}
        end

        if gf:getServerTime() - (self.searchPublicityItemList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.searchPublicityItemList = {}
        end

        return self.searchPublicityItemList
    end
end


-- 设置搜索的降序(摆摊）
function MarketMgr:setDownSearchList()
    self.downSearchList = {}
    for i = #self.searchItemLsit, 1 , -1 do
        table.insert(self.downSearchList, self.searchItemLsit[i])
    end

    self.downSearchList["dataTime"] = self.searchItemLsit["dataTime"]
end

-- 设置搜索的降序（公示）
function MarketMgr:setDownSearchPublicityList()
    self.downSearchPublicityList = {}
    for i = #self.searchPublicityItemList, 1 , -1 do
        table.insert(self.downSearchPublicityList, self.searchPublicityItemList[i])
    end

    self.downSearchPublicityList["dataTime"] = self.searchPublicityItemList["dataTime"]
end

-- 珍宝设置搜索的降序
function MarketMgr:setGoldDownSearchList()
    self.goldDownSearchList = {}
    for i = #self.goldSearchItemList, 1 , -1 do
        table.insert(self.goldDownSearchList, self.goldSearchItemList[i])
    end

    self.goldDownSearchList["dataTime"] = self.goldSearchItemList["dataTime"]
end

-- 珍宝设置搜索的降序（公示）
function MarketMgr:setGoldDownSearchPublicityList()
    self.goldDownSearchPublicityList = {}
    for i = #self.goldSearchPublicityItemList, 1 , -1 do
        table.insert(self.goldDownSearchPublicityList, self.goldSearchPublicityItemList[i])
    end

    self.goldDownSearchPublicityList["dataTime"] = self.goldSearchPublicityItemList["dataTime"]
end

-- 搜索降序（摆摊）
function MarketMgr:getDownSearchList(tradeType)
    if self:isGoldtype(tradeType) then
        -- 如果珍宝的搜索结果超过15分钟，则失效
        if not self.goldDownSearchList then
            return {}
        end

        if gf:getServerTime() - (self.goldDownSearchList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.goldDownSearchList = {}
        end

        return self.goldDownSearchList
    else
        -- 如果集市的搜索结果超过15分钟，则失效
        if not self.downSearchList then
            return {}
        end

        if gf:getServerTime() - (self.downSearchList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.downSearchList = {}
        end

        return self.downSearchList
    end
end

-- 搜索降序（公示）
function MarketMgr:getDownSearchPublicityList(tradeType)
    if self:isGoldtype(tradeType) then
        -- 如果珍宝的搜索结果超过15分钟，则失效
        if not self.goldDownSearchPublicityList then
            return {}
        end

        if gf:getServerTime() - (self.goldDownSearchPublicityList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.goldDownSearchPublicityList = {}
        end

        return self.goldDownSearchPublicityList
    else
        -- 如果集市的搜索结果超过15分钟，则失效
        if not self.downSearchPublicityList then
            return {}
        end

        if gf:getServerTime() - (self.downSearchPublicityList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.downSearchPublicityList = {}
        end

        return self.downSearchPublicityList
    end
end

-- 搜索结果按照上架时间的升降序进行排序
function MarketMgr:getSearchItemListByTime(upSort, tradeType)
    local itemList
    if tradeType == MarketMgr.TradeType.marketType then
        itemList = self.searchItemLsit
        if not itemList then
            return {}
        end

        if gf:getServerTime() - (itemList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.searchItemLsit = {}
            itemList = {}
        end
    else
        itemList = self.goldSearchItemList
        if not itemList then
            return {}
        end

        if gf:getServerTime() - (itemList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.goldSearchItemList = {}
            itemList = {}
        end
    end

    local searchItemList = gf:deepCopy(itemList)
    if upSort then
        table.sort(searchItemList, function(l, r)
            if l.endTime < r.endTime then return true end
            if l.endTime > r.endTime then return false end
        end)
    else
        table.sort(searchItemList, function(l, r)
            if l.endTime < r.endTime then return false end
            if l.endTime > r.endTime then return true end
        end)
    end

    return searchItemList
end

-- 搜索结果按照公示时间的升降序进行排序
function MarketMgr:getSearchPublicityItemListByTime(upSort, tradeType)

    -- 如果集市的搜索结果超过15分钟，则失效
    local itemList
    if tradeType == MarketMgr.TradeType.marketType then
        itemList = self.searchPublicityItemList
        if not itemList then
            return {}
        end

        if gf:getServerTime() - (itemList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.searchPublicityItemList = {}
            itemList = {}
        end
    else
        itemList = self.goldSearchPublicityItemList
        if not itemList then
            return {}
        end

        if gf:getServerTime() - (itemList["dataTime"] or 0) > SEARCH_RESULT_MAX_TIME then
            self.goldSearchPublicityItemList = {}
            itemList = {}
        end
    end

    local searchPublicityItemList = gf:deepCopy(itemList)
    if upSort then
        table.sort(searchPublicityItemList, function(l, r)
            if l.endTime < r.endTime then return true end
            if l.endTime > r.endTime then return false end
        end)
    else
        table.sort(searchPublicityItemList, function(l, r)
            if l.endTime < r.endTime then return false end
            if l.endTime > r.endTime then return true end
        end)
    end

    return searchPublicityItemList
end

-- 逛摊收藏
function MarketMgr:addCollectItem(item, tradeType)
    local collectItemList = self:getCollectItemList(tradeType)

    table.insert(collectItemList, 1, item)
end

-- 获取逛摊收藏
function MarketMgr:getCollectItemList(tradeType)
    if MarketMgr.TradeType.goldType == tradeType then
        if not self.collecGoldItemList then
            self:gold_loadCollect()
        end
        return self.collecGoldItemList or {}
    else
        if not self.collecItemList then
            self:loadCollect()
        end
        return self.collecItemList or {}
    end
end

-- 取消收藏
function MarketMgr:cancelCollect(goodId, tradeType)
    local collectItemList = self:getCollectItemList(tradeType)

    for i = 1, #collectItemList do
        local item = collectItemList[i]
        if goodId == item.id then
            table.remove(collectItemList, i)
            break
        end
    end
end

-- 是否处于收藏中 包括公示或者逛摊
function MarketMgr:isCollectedInAll(goodId, tradeType)
    local isCollect = false
    for i = 1, #self:getCollectItemList(tradeType) do
        local item = self:getCollectItemList(tradeType)[i]
        if goodId == item.id then
            isCollect = true
            break
        end
    end

    for i = 1, #self:getPublicCollectItem(tradeType) do
        local item = self:getPublicCollectItem(tradeType)[i]
        if goodId == item.id then
            isCollect = true
            break
        end
    end

    return isCollect
end

-- 是否逛摊中的收藏
function MarketMgr:isCollectItem(goodId, tradeType)
    local isCollect = false
    for i = 1, #self:getCollectItemList(tradeType) do
        local item = self:getCollectItemList(tradeType)[i]
        if goodId == item.id then
            isCollect = true
            break
        end
    end

    return isCollect
end

-- 加载逛摊收藏
function MarketMgr:loadCollect()
    self.collecItemList = {}
    local dataPara = DataBaseMgr:selectItems("marketCollect")
    for i = 1, dataPara.count do
        local goodsData = json.decode(dataPara[i].json_para)

        table.insert(self.collecItemList, goodsData)
    end
end

-- 根据gid检查单个商品
function MarketMgr:checkCollectItemStatusByGid(tradeType, gid)
    if self:isGoldtype(tradeType) then
        gf:CmdToServer('CMD_GOLD_STALL_GOODS_STATE', {
            goodStr = gid .. ";"
        })
    else
        gf:CmdToServer('CMD_MARKET_CHECK_RESULT', {
            goodStr = gid .. ";"
        })
    end
end

-- 加载珍宝逛摊收藏
function MarketMgr:gold_loadCollect()
    self.collecGoldItemList = {}
    local dataPara = DataBaseMgr:selectItems("marketGoldCollect")
    for i = 1, dataPara.count do
        local goodsData = json.decode(dataPara[i].json_para)
        table.insert(self.collecGoldItemList, goodsData)
    end
end

-- 保存逛摊收藏
function MarketMgr:saveCollect()
    if self.collecItemList  then
        DataBaseMgr:deleteItems("marketCollect")

        for i = 1, #self.collecItemList do
            local item = self.collecItemList[i]
            if nil ~= item then
                self:buildOneInsertSql("marketCollect", item)
            end
        end
    end
end

-- 保存珍宝逛摊收藏
function MarketMgr:gold_saveCollect()
    if self.collecGoldItemList  then
        DataBaseMgr:deleteItems("marketGoldCollect")
        for i = 1, #self.collecGoldItemList do
            local item = self.collecGoldItemList[i]
            if nil ~= item then
                self:buildOneInsertSql("marketGoldCollect", item)
            end
        end
    end
end

-- 逛摊是否可以收藏
function MarketMgr:isCanCollect(tradeType)
    return MarketMgr:getCurColletctCount(tradeType) < MAX_COLLECT_NUM
end


function MarketMgr:getMaxCount()
    return MAX_COLLECT_NUM
end

-- 公示是否可以收藏
function MarketMgr:isPublicCanCollect(tradeType)
    return MarketMgr:getCurColletctCount(tradeType) < MAX_COLLECT_NUM
end

function MarketMgr:getCurColletctCount(tradeType)
    local publicCollecItemList =  self:getPublicCollectItem(tradeType)
    local collectItemList = self:getCollectItemList(tradeType)

    return #publicCollecItemList + #collectItemList
end

-- 公示收藏列表
function MarketMgr:addPublicCollectItem(item, tradeType)
    local publicCollecItemList = self:getPublicCollectItem(tradeType)

    table.insert(publicCollecItemList, 1, item)
end

-- 取消公示收藏
function MarketMgr:cancelPublicCollect(goodId, tradeType)
    local publicCollecItemList = self:getPublicCollectItem(tradeType)
    if #publicCollecItemList == 0 then return end

    for i = 1, #publicCollecItemList do
        local item = publicCollecItemList[i]
        if goodId == item.id then
            table.remove(publicCollecItemList, i)
            break
        end
    end
end

-- 获取公示收藏
function MarketMgr:getPublicCollectItem(tradeType)
    if self:isGoldtype(tradeType) then
        if not self.publicCollecGoldItemList then
            self:gold_loadPublicCollect()
        end

        return self.publicCollecGoldItemList or {}
    else
        if not self.publicCollecItemList then
            self:loadPublicCollect()
        end

        return self.publicCollecItemList or {}
    end
end

function MarketMgr:getCollectDataByType(classType, tradeType)
    local listInfo = {}
    if classType == CHS[4100075] then
        -- 全部收藏
        local temp = MarketMgr:getCollectItemList(tradeType)
        local publicTemp = MarketMgr:getPublicCollectItem(tradeType)
        listInfo = {}
        for i = 1, #temp do
            temp[i].isPublic = false
            temp[i].order = 0
            table.insert(listInfo, temp[i])
        end
        for i = 1, #publicTemp do
            publicTemp[i].isPublic = true
            publicTemp[i].order = 1
            table.insert(listInfo, publicTemp[i])
        end
    elseif classType == CHS[4200200] then
        -- 逛摊收藏
        local temp = MarketMgr:getCollectItemList(tradeType)
        for i = 1, #temp do
            temp[i].isPublic = false
            temp[i].order = 0
            table.insert(listInfo, temp[i])
        end
    elseif classType == CHS[4200201] then
        -- 公示收藏
        local publicTemp = MarketMgr:getPublicCollectItem(tradeType)
        for i = 1, #publicTemp do
            publicTemp[i].isPublic = true
            publicTemp[i].order = 1
            table.insert(listInfo, publicTemp[i])
        end
    end

    return listInfo
end


-- 是否公示中的收藏
function MarketMgr:isPublicCollectItem(goodId, tradeType)
    local isCollect = false
    for i = 1, #self:getPublicCollectItem(tradeType) do
        local item = self:getPublicCollectItem(tradeType)[i]
        if goodId == item.id then
            isCollect = true
            break
        end
    end

    return isCollect
end

-- 加载公示收藏
function MarketMgr:loadPublicCollect()
    self.publicCollecItemList = {}
    local dataPara = DataBaseMgr:selectItems("marketPublicCollect")
    for i = 1, dataPara.count do
        local goodsData = json.decode(dataPara[i].json_para)

        table.insert(self.publicCollecItemList, goodsData)
    end
end

-- 加载公示收藏
function MarketMgr:gold_loadPublicCollect()
    self.publicCollecGoldItemList = {}
    local dataPara = DataBaseMgr:selectItems("marketPublicGoldCollect")
    for i = 1, dataPara.count do
        local goodsData = json.decode(dataPara[i].json_para)

        table.insert(self.publicCollecGoldItemList, goodsData)
    end
end

function MarketMgr:buildOneInsertSql(tableName, data)
    local values = {}
    values.name = data.name
    values.gid = data.gid or ""
    values.id = data.id or ""
    values.price = data.price or 0
    values.status = data.status or 0
	values.startTime = data.startTime or 0
    values.endTime = data.endTime or 0
    values.level = data.level or 0
    values.req_level = data.req_level or 0
    values.unidentified = data.unidentified or 0
    values.item_polar = data.item_polar
    values.extra = data.extra
    values.buyout_price = data.buyout_price
    values.appointee_name = data.appointee_name
    values.sell_type = data.sell_type

    local para = json.encode(values)
    return DataBaseMgr:insertItem(tableName, {json_para = para})
end

-- 保存公示收藏
function MarketMgr:savePublicCollect()
    if self.publicCollecItemList then
        -- 如果没有加载收藏列表，不进行数据清除和保存（判断有没加载收藏列表一定不用getPublicCollectItem接口，因为接口出来即使没加载过也不会为nil）
        DataBaseMgr:deleteItems("marketPublicCollect")
        for i = 1, #self.publicCollecItemList do
            local item = self.publicCollecItemList[i]
            if nil ~= item then
                self:buildOneInsertSql("marketPublicCollect", item)
            end
        end
    end
end

-- 珍宝保存公示收藏
function MarketMgr:gold_savePublicCollect()
    if self.publicCollecGoldItemList  then
        DataBaseMgr:deleteItems("marketPublicGoldCollect")
        for i = 1, #self.publicCollecGoldItemList do
            local item = self.publicCollecGoldItemList[i]
            if nil ~= item then
                self:buildOneInsertSql("marketPublicGoldCollect", item)
            end
        end
    end
end


-- 从告示中移到逛摊中
function MarketMgr:checkPublicMoveToCollect()
    if not self.publicCollecItemList then return end

    local leftPublicCollecItemList = {}
    if self.publicCollecItemList then
        for i = 1, #self.publicCollecItemList do
            local item = self.publicCollecItemList[i]
            if item.status == GOOD_STATE_SELLING then -- 公示中
                self:addCollectItem(item, MarketMgr.TradeType.marketType)
            else
                table.insert(leftPublicCollecItemList, item)
            end
        end
    end

    self.publicCollecItemList = nil
    self.publicCollecItemList = leftPublicCollecItemList
end

-- 珍宝从告示中移到逛摊中
function MarketMgr:gold_checkPublicMoveToCollect()
    if not self.publicCollecGoldItemList then return end

    local leftPublicCollecItemList = {}
    if self.publicCollecGoldItemList then
        for i = 1, #self.publicCollecGoldItemList do
            local item = self.publicCollecGoldItemList[i]
            if item.status == GOOD_STATE_SELLING or item.status == MARKET_STATUS.STALL_GS_AUCTION or item.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then -- 公示中
                self:addCollectItem(item, MarketMgr.TradeType.goldType)
            else
                table.insert(leftPublicCollecItemList, item)
            end
        end
    end

    self.publicCollecGoldItemList = nil
    self.publicCollecGoldItemList = leftPublicCollecItemList
end


-- 发送检查物品的指令
function MarketMgr:checkCollectItemStatus(tradeType)
    local str = ""
    local publicCollecItemList, collecItemList
    if self:isGoldtype(tradeType) then
        publicCollecItemList = self.publicCollecGoldItemList
        collecItemList = self.collecGoldItemList
    else
        publicCollecItemList = self.publicCollecItemList
        collecItemList = self.collecItemList
    end

    if publicCollecItemList then
        for i = 1, #publicCollecItemList do
            str = str .. publicCollecItemList[i].id..";"
        end
    end

    if collecItemList then
        for i = 1, #collecItemList do
            str = str .. collecItemList[i].id..";"
        end
    end

    if str ~= "" then
        if self:isGoldtype(tradeType) then
            gf:CmdToServer('CMD_GOLD_STALL_GOODS_STATE', {
                goodStr = str
            })
        else
            gf:CmdToServer('CMD_MARKET_CHECK_RESULT', {
                goodStr = str
            })
        end
        --gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_MARKET_CHECK_GOOD, str)
    else
        DlgMgr:sendMsg("MarketCollectionDlg", "MSG_MARKET_CHECK_RESULT")
        DlgMgr:sendMsg("MarketGoldCollectionDlg", "MSG_MARKET_CHECK_RESULT")
    end
end

-- 检查物品状态
function MarketMgr:MSG_MARKET_CHECK_RESULT(data)
    local sellInfoIsChange = false
    for i = 1, #data.itemList do
        if data.itemList[i].status == GOOD_STATE_OUT_SELLING or  data.itemList[i].status  == 0 then -- 0 被人购买
            if self.collecItemList then -- 逛摊中
                for j = 1, #self.collecItemList do
                    if self.collecItemList[j] and self.collecItemList[j].id == data.itemList[i].id then
                        table.remove(self.collecItemList, j)
                        break
                    end
                end
            end


            if self.publicCollecItemList then -- 告示中
                for j = 1, #self.publicCollecItemList do
                    if self.publicCollecItemList[j] and self.publicCollecItemList[j].id == data.itemList[i].id then
                        table.remove(self.publicCollecItemList, j)
                        break
                    end
                end
            end

            -- 摆摊数据（目前用于表情链接中刷新单个商品数据）
            if self.sellDataInfo and self.sellDataInfo.items then
                local items = self.sellDataInfo.items
                for j = 1, #items do
                    if items[j] and items[j].id == data.itemList[i].id then
                        table.remove(items, j)
                        sellInfoIsChange = true
                        break
                    end
                end
            end
        else
            if self.collecItemList then -- 逛摊中
                for j = 1, #self.collecItemList do
                    if self.collecItemList[j] and self.collecItemList[j].id == data.itemList[i].id then
                        if GOOD_STATE_SHOWING == data.itemList[i].status then
                            -- 逛摊中有公示物品表示，重新上架，移除该收藏
                            table.remove(self.collecItemList, j)
                        else
                            self.collecItemList[j].status = data.itemList[i].status
                            self.collecItemList[j].price = data.itemList[i].price
                            self.collecItemList[j].endTime = data.itemList[i].endTime
                            self.collecItemList[j].amount = data.itemList[i].amount
                            self.collecItemList[j].sell_type = data.itemList[i].sell_type
                            self.collecItemList[j].para_str = data.itemList[i].para_str
                            self.collecItemList[j].appointee_name = data.itemList[i].appointee_name
                            if data.itemList[i].buyout_price and data.itemList[i].buyout_price ~= 0 then
                                self.collecItemList[j].buyout_price = data.itemList[i].buyout_price
                            end
                        end

                        break
                    end
                end
            end

            if self.publicCollecItemList then -- 告示中
                for j = 1, #self.publicCollecItemList do
                    if self.publicCollecItemList[j] and self.publicCollecItemList[j].id == data.itemList[i].id then
                        if self.publicCollecItemList[j].startTime ~= data.itemList[i].startTime then
                            -- 上架时间有所改变，移除该收藏
                            table.remove(self.publicCollecItemList, j)
                        else
                            self.publicCollecItemList[j].status = data.itemList[i].status
                            self.publicCollecItemList[j].price = data.itemList[i].price
                            self.publicCollecItemList[j].endTime = data.itemList[i].endTime
                            self.publicCollecItemList[j].amount = data.itemList[i].amount
                            self.publicCollecItemList[j].sell_type = data.itemList[i].sell_type
                            self.publicCollecItemList[j].para_str = data.itemList[i].para_str
                            self.publicCollecItemList[j].appointee_name = data.itemList[i].appointee_name
                            if data.itemList[i].buyout_price and data.itemList[i].buyout_price ~= 0 then
                                self.publicCollecItemList[j].buyout_price = data.itemList[i].buyout_price
                            end
                        end

                        break
                    end
                end
            end
        end
    end

    if sellInfoIsChange then
        DlgMgr:sendMsg("LinkAndExpressionDlg", "MSG_STALL_MINE")
    end

    self:checkPublicMoveToCollect()
end


-- 检查珍宝物品状态
function MarketMgr:MSG_GOLD_STALL_GOODS_STATE(data)
    local sellInfoIsChange = false
    for i = 1, #data.itemList do

        -- 更新选择的
        if self.selectItem and data.itemList[i].id == self.selectItem.id then
            self.selectItem.buyout_price = data.itemList[i].buyout_price
            self.selectItem.appointee_name = data.itemList[i].appointee_name
            self.selectItem.extra = data.itemList[i].para_str

            -- 不能全部更新！！！！
            -- 如果全部更新了，非中标玩家，就会变成支付期，后续不能判断打开时，他是什么状态
            if data.itemList[i].appointee_name == Me:queryBasic("name") then

                self.selectItem.sell_type = data.itemList[i].sell_type
                self.selectItem.endTime = data.itemList[i].endTime
                self.selectItem.startTime = data.itemList[i].startTime
                self.selectItem.status = data.itemList[i].status
            end
        end


        if data.itemList[i].status == GOOD_STATE_OUT_SELLING or  data.itemList[i].status  == 0 then
            if self.collecGoldItemList then -- 逛摊中
                for j = 1, #self.collecGoldItemList do
                    if self.collecGoldItemList[j] and self.collecGoldItemList[j].id == data.itemList[i].id then
                        table.remove(self.collecGoldItemList, j)
                        break
                    end
                end
            end


            if self.publicCollecGoldItemList then -- 告示中
                for j = 1, #self.publicCollecGoldItemList do
                    if self.publicCollecGoldItemList[j] and self.publicCollecGoldItemList[j].id == data.itemList[i].id then
                        table.remove(self.publicCollecGoldItemList, j)
                        break
                    end
                end
            end

            --[[
            -- 摆摊数据（目前用于表情链接中刷新单个商品数据）
            -- 注释掉，因为 我的摆摊界面如果刷新被删除，导致新上架位置计算错误！
            -- 聊天链接中 LinkAndExpressionDlg:getShowItems(allItems) 已会排除过期商品
            if self.goldSellDataInfo and self.goldSellDataInfo.items then
                local items = self.goldSellDataInfo.items
                for j = 1, #items do
                    if items[j] and items[j].id == data.itemList[i].id then
                        table.remove(items, j)
                        sellInfoIsChange = true
                        break
                    end
                end
            end
            --]]
        else
            if self.collecGoldItemList then -- 逛摊中
                for j = 1, #self.collecGoldItemList do
                    if self.collecGoldItemList[j] and self.collecGoldItemList[j].id == data.itemList[i].id then

                        if GOOD_STATE_SHOWING == data.itemList[i].status then
                            -- 逛摊中有公示物品表示，重新上架，移除该收藏
                            table.remove(self.collecGoldItemList, j)
                        else
                            self.collecGoldItemList[j].status = data.itemList[i].status
                            self.collecGoldItemList[j].price = data.itemList[i].price
                            self.collecGoldItemList[j].endTime = data.itemList[i].endTime
                            self.collecGoldItemList[j].sell_type = data.itemList[i].sell_type
                            self.collecGoldItemList[j].para_str = data.itemList[i].para_str
                            self.collecGoldItemList[j].appointee_name = data.itemList[i].appointee_name
                            if data.itemList[i].buyout_price and data.itemList[i].buyout_price ~= 0 then
                                self.collecGoldItemList[j].buyout_price = data.itemList[i].buyout_price
                            end
                        end

                        break
                    end
                end
            end


            if self.publicCollecGoldItemList then -- 告示中
                for j = 1, #self.publicCollecGoldItemList do
                    if self.publicCollecGoldItemList[j] and self.publicCollecGoldItemList[j].id == data.itemList[i].id then
                        if self.publicCollecGoldItemList[j].startTime ~= data.itemList[i].startTime then
                            -- 上架时间有所改变，移除该收藏
                            table.remove(self.publicCollecGoldItemList, j)
                        else
                            self.publicCollecGoldItemList[j].status = data.itemList[i].status
                            self.publicCollecGoldItemList[j].price = data.itemList[i].price
                            self.publicCollecGoldItemList[j].endTime = data.itemList[i].endTime
                            self.publicCollecGoldItemList[j].sell_type = data.itemList[i].sell_type
                            self.publicCollecGoldItemList[j].para_str = data.itemList[i].para_str
                            self.publicCollecGoldItemList[j].appointee_name = data.itemList[i].appointee_name
                            if data.itemList[i].buyout_price and data.itemList[i].buyout_price ~= 0 then
                                self.publicCollecGoldItemList[j].buyout_price = data.itemList[i].buyout_price
                            end
                        end

                        break
                    end
                end
            end
        end
    end

    if sellInfoIsChange then
        DlgMgr:sendMsg("LinkAndExpressionDlg", "MSG_GOLD_STALL_MINE")
    end

    self:gold_checkPublicMoveToCollect()
end

-- 更新搜索中购买物品的状态
function MarketMgr:MSG_STALL_UPDATE_GOODS_INFO(data)
    if data.status == 0 then -- 表示物品已被购买
        if self.searchItemLsit then
            -- 逛摊搜索数据更新
            for i = 1, #self.searchItemLsit do
                if data.id == self.searchItemLsit[i].id then
                    table.remove(self.searchItemLsit, i)
                    table.remove(self.downSearchList, #self.searchItemLsit - i + 1)
                    break
                end
            end
        end

        if self.searchPublicityItemList then
            -- 公示搜索数据更新
            for i = 1, #self.searchPublicityItemList do
                if data.id == self.searchPublicityItemList[i].id then
                    table.remove(self.searchPublicityItemList, i)
                    table.remove(self.downSearchPublicityList, #self.searchPublicityItemList - i + 1)
                    break
                end
            end
        end
	 else
	    if self.searchItemLsit then
	       -- 逛摊搜索数据更新
            for i = 1, #self.searchItemLsit do
                if data.id == self.searchItemLsit[i].id then
                    self.searchItemLsit[i].status = data.status
                    self.searchItemLsit[i].endTime = data.endTime
                    self.searchItemLsit[i].amount = data.amount or 1
                    self.downSearchList[#self.searchItemLsit - i + 1].status = data.status
                    self.downSearchList[#self.searchItemLsit - i + 1].endTime = data.endTime
                    break
                end
            end
        end

        if self.searchPublicityItemList then
            -- 公示搜索数据更新
            for i = 1, #self.searchPublicityItemList do
                if data.id == self.searchPublicityItemList[i].id then
                    self.searchPublicityItemList[i].status = data.status
                    self.searchPublicityItemList[i].endTime = data.endTime
                    self.searchPublicityItemList[i].amount = data.amount or 1
                    self.downSearchPublicityList[#self.searchPublicityItemList - i + 1].status = data.status
                    self.downSearchPublicityList[#self.searchPublicityItemList - i + 1].endTime = data.endTime
                    break
                end
            end
        end
	end
end

-- 更新金元宝搜索中购买物品的状态
function MarketMgr:MSG_GOLD_STALL_UPDATE_GOODS_INFO(data)
    if data.status == 0 then -- 表示物品已被购买
        if self.goldSearchItemList then
            -- 逛摊搜索数据更新
            for i = 1, #self.goldSearchItemList do
                if data.id == self.goldSearchItemList[i].id then
                    table.remove(self.goldSearchItemList, i)
                    table.remove(self.goldDownSearchList, #self.goldSearchItemList - i + 1)
                    break
                end
            end
        end

        if self.goldSearchPublicityItemList then
            -- 公示搜索数据更新
            for i = 1, #self.goldSearchPublicityItemList do
                if data.id == self.goldSearchPublicityItemList[i].id then
                    table.remove(self.goldSearchPublicityItemList, i)
                    table.remove(self.goldDownSearchPublicityList, #self.goldSearchPublicityItemList - i + 1)
                    break
                end
            end
        end
    else
        if self.goldSearchItemList then
            -- 逛摊搜索数据更新
            for i = 1, #self.goldSearchItemList do
                if data.id == self.goldSearchItemList[i].id then
                    self.goldSearchItemList[i].status = data.status
                    self.goldSearchItemList[i].endTime = data.endTime
                    self.goldSearchItemList[i].amount = data.amount or 1
                    self.goldDownSearchList[#self.goldSearchItemList - i + 1].status = data.status
                    self.goldDownSearchList[#self.goldSearchItemList - i + 1].endTime = data.endTime
                    break
                end
            end
        end

        if self.goldSearchPublicityItemList then
            -- 公示搜索数据更新
            for i = 1, #self.goldSearchPublicityItemList do
                if data.id == self.goldSearchPublicityItemList[i].id then
                    self.goldSearchPublicityItemList[i].status = data.status
                    self.goldSearchPublicityItemList[i].endTime = data.endTime
                    self.goldSearchPublicityItemList[i].amount = data.amount or 1
                    self.goldDownSearchPublicityList[#self.goldSearchPublicityItemList - i + 1].status = data.status
                    self.goldDownSearchPublicityList[#self.goldSearchPublicityItemList - i + 1].endTime = data.endTime
                    break
                end
            end
        end
    end
end

-- 获取拍卖物品信息
function MarketMgr:queryAuctionGoodsList()
    gf:CmdToServer("CMD_SYS_AUCTION_GOODS_LIST", {})
end

-- 获取本地收藏的商品的gid
function MarketMgr:getFavoritiesGoodsGid()
    MarketMgr.auctionFavoritiesByGid = {}

    local userDefault = cc.UserDefault:getInstance()
    for i = 1,8 do
        local goodsGid = userDefault:getStringForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsGid" .. i, "")
        if goodsGid ~= "" then
            local endTime = userDefault:getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsTime" .. i, 0)
            if gf:getServerTime() > endTime then
            -- 当前服务器时间大于该收藏商品的有效时间。失效
            else
                MarketMgr.auctionFavoritiesByGid[goodsGid] = endTime
            end
        end
    end
end

-- 取消收藏
function MarketMgr:cancelFavorities(goods, isRemoveNow)
    MarketMgr.auctionFavoritiesByGid[goods.id] = nil
    local userDefault = cc.UserDefault:getInstance()
    local pos = 0
    for i = 1, 8 do
        if MarketMgr.auctionFavoritiesGoods[i] then
            userDefault:setStringForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsGid" .. i, MarketMgr.auctionFavoritiesGoods[i].id)
            userDefault:setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsTime" .. i, MarketMgr.auctionFavoritiesGoods[i].endTime)

            if MarketMgr.auctionFavoritiesGoods[i].id == goods.id then
                --        MarketMgr.auctionFavoritiesGoods[i] = nil
                pos = i
            end
        else
            userDefault:setStringForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsGid" .. i, "")
            userDefault:setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsTime" .. i, 0)
        end
    end

    if isRemoveNow then
        table.remove(MarketMgr.auctionFavoritiesGoods, pos)
        userDefault:setStringForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsGid" .. pos, "")
        userDefault:setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsTime" .. pos, 0)
    end
end

--
function MarketMgr:writeFavoritiesGoodsGid(goods)
    if goods then
        if #MarketMgr.auctionFavoritiesGoods >= 8 then return end
        table.insert(MarketMgr.auctionFavoritiesGoods, goods)
        MarketMgr.auctionFavoritiesByGid[goods.id] = goods.endTime
    end
    local userDefault = cc.UserDefault:getInstance()
    for i = 1, 8 do
        if MarketMgr.auctionFavoritiesGoods[i] then
            userDefault:setStringForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsGid" .. i, MarketMgr.auctionFavoritiesGoods[i].id)
            userDefault:setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "AuctionGoodsTime" .. i, MarketMgr.auctionFavoritiesGoods[i].endTime)
        end
    end
end

function MarketMgr:cleanAuctionData()
    MarketMgr.auctionFavoritiesByGid = {}
    MarketMgr.auctionInfo = {}
    MarketMgr.auctionFavoritiesGoods = {}
    MarketMgr.auctionMyBidedGoods = {}
end


function MarketMgr:MSG_SYS_AUCTION_UPDATE_GOODS(data)
    if MarketMgr.auctionFavoritiesByGid[data.id] then
        data.isFavorities = true
    end
    for i = 1, 8 do
        if MarketMgr.auctionFavoritiesGoods[i] and MarketMgr.auctionFavoritiesGoods[i].id == data.id then
            MarketMgr.auctionFavoritiesGoods[i] = data
        end
    end


    for i = 1, #MarketMgr.auctionInfo do
        if MarketMgr.auctionInfo[i].id == data.id then
            MarketMgr.auctionInfo[i] = data
        end
    end

    if data.isBided == 1 then
        local isAdd = true
        for i = 1, #MarketMgr.auctionMyBidedGoods do
            if MarketMgr.auctionMyBidedGoods[i].id == data.id then
                isAdd = false
                MarketMgr.auctionMyBidedGoods[i] = data
            end
        end

        if isAdd then
            table.insert(MarketMgr.auctionMyBidedGoods, data)
        end
    end
end

-- 更新收藏夹
function MarketMgr:updateFavorities()
    local totalList = MarketMgr.auctionInfo
    MarketMgr.auctionFavoritiesGoods = {}
    for i = 1, #totalList do
        if totalList[i].isFavorities then
            table.insert(MarketMgr.auctionFavoritiesGoods, totalList[i])
        end
    end

    return MarketMgr.auctionFavoritiesGoods
end

function MarketMgr:MSG_SYS_AUCTION_GOODS_LIST(data)
    if self.auctionGoodsReceiveDone then
        self.auctionGoodsReceiveDone = false
        MarketMgr.auctionInfo = {}
        MarketMgr.auctionFavoritiesGoods = {}
        MarketMgr.auctionMyBidedGoods = {}
    end

    self.refreshTime = self.refreshTime or 0

    -- 服务器怕包过大分批发送
    -- data.curPage == 0没有物品
    -- data.curPage == data.totalPage拍卖商品信息发送完全
    -- data.curPage < data.totalPage 拍卖商品信息当前未发送完
    if data.curPage == 0 then
        -- 没有物品
        self.auctionGoodsReceiveDone = true
        self.refreshTime = 0
    else
        for i = 1, data.count do
            -- 收藏夹处理
            if MarketMgr.auctionFavoritiesByGid[data.goods[i].id] then
                -- 如果该商品GID在收藏夹内。
                data.goods[i].isFavorities = true
                MarketMgr.auctionFavoritiesByGid[data.goods[i].id] = data.goods[i].endTime
                table.insert(MarketMgr.auctionFavoritiesGoods, data.goods[i])
            else
                data.goods[i].isFavorities = false
            end

            if data.goods[i].isBided == 1 then
                table.insert(MarketMgr.auctionMyBidedGoods, data.goods[i])
            end

            table.insert(MarketMgr.auctionInfo, data.goods[i])
            if self.refreshTime > data.goods[i].endTime or self.refreshTime == 0 then
                self.refreshTime = data.goods[i].endTime
            end
        end

        -- 如果data.curPage == data.totalPage则信息接送完成
        self.auctionGoodsReceiveDone = (data.curPage == data.totalPage)
    end

    if self.auctionGoodsReceiveDone then
        table.sort(MarketMgr.auctionInfo, function(l, r)
            if l.sortIndex < r.sortIndex then return true end
            if l.sortIndex > r.sortIndex then return false end
            if l.id < r.id then return true end
            if l.id > r.id then return false end
        end)

        table.sort(MarketMgr.auctionFavoritiesGoods, function(l, r)
            if l.sortIndex < r.sortIndex then return true end
            if l.sortIndex > r.sortIndex then return false end
            if l.id < r.id then return true end
            if l.id > r.id then return false end
        end)

        -- 更新收藏夹商品结束时间
        MarketMgr:writeFavoritiesGoodsGid()
    end
end

-- 获取拍卖商品列表信息（排好序）
function MarketMgr:getAuctionGoods()
    return MarketMgr.auctionInfo or {}
end

-- 竞拍拍卖行
function MarketMgr:cmdAuctionBidGoods(gid, bidPrice, curPrice)
    gf:CmdToServer("CMD_SYS_AUCTION_BID_GOODS", {goods_gid = gid, bid_price = bidPrice, price = curPrice})
end

-- 获取摆摊限制等级
function MarketMgr:getOnSellLevel()
    return LEVEL_LIMIT
end

-- 获取珍宝摆摊限制等级
function MarketMgr:getGoldOnSellLevel()
    return GOLD_LEVEL_LIMIT
end

-- 保存集市收藏记录
function MarketMgr:saveMarketCollectData()
    self:savePublicCollect()
    self:saveCollect()
    self:gold_saveCollect()
    self:gold_savePublicCollect()
end

-- 记录上一次选择的一级、二级、三级分类
function MarketMgr:setLastSelectClass(firstClass, secondClass, thirdClass)
    self.lastSelectFirstClass = firstClass
    self.lastSelectSecondClass = secondClass
    self.lastSelectThirdClass = thirdClass
end

-- 获取上一次选择的三级分类（只有处于同一一级分类，且三级列表相同时，才返回上一次选择的三级分类）
function MarketMgr:getLastSelectThirdClass(firstClass, secondClass, thirdClass)
    if self.lastSelectFirstClass and self.lastSelectSecondClass then
        local lastThirdClassData = MarketMgr:getThirdClassData(self.lastSelectFirstClass, self.lastSelectSecondClass)
        local thirdClassData = MarketMgr:getThirdClassData(firstClass, secondClass)

        local haveSameThirdClassData = true
        if #lastThirdClassData ~= #thirdClassData then
            haveSameThirdClassData = false
        else
            for i = 1, #lastThirdClassData do
                if lastThirdClassData[i] ~= thirdClassData[i] then
                    haveSameThirdClassData = false
                end
            end
        end

        if firstClass == self.lastSelectFirstClass and haveSameThirdClassData and self.lastSelectThirdClass then
            return self.lastSelectThirdClass
        end
    end

    return thirdClass
end

-- 获取指定一级、二级分类下的三级分类列表
function MarketMgr:getThirdClassData(firstClass, secondClass)
    local result = {}
    local firstClassData = allSellItems[firstClass]
    if firstClassData then
        for i = 1, #firstClassData do
            if firstClassData[i].name == secondClass and firstClassData[i].list then
                result = firstClassData[i].list
            end
        end
    end

    return result
end

function MarketMgr:setLastSelectLevel(name, level, secondClass)
    if name == CHS[3004159] or  name == CHS[3004162] or name == CHS[3001166] then -- 装备 ,超级黑水晶, 未鉴定装备
        self:setLastEquipLevel(level)
    elseif name == CHS[3000089] and type(level) == "number" then -- 妖石
        self:setLastEquipLevel(level * 10)
    elseif name == CHS[3001150] then -- 低级首饰
        self:setLastJewelryLevel(level)
    elseif name == CHS[3002966] then
        self:setLastJewelryHighLevel(level)
    elseif secondClass and (secondClass == CHS[7000044] or secondClass == CHS[7000045]) then
        -- 经验心得/道武心得
        self:setLastXinDeLevel(level, secondClass)
    end
end

function MarketMgr:getLastSelectLevel(name, secondClass)
    if name == CHS[3004159] or  name == CHS[3004162] or name == CHS[3001166] then -- 装备 ,超级黑水晶,妖石
        return self:getLastEquipLevel()
    elseif name == CHS[3000089] then -- 妖石
        if not self:getLastEquipLevel() then return end
        return math.floor(self:getLastEquipLevel() / 10)
    elseif name == CHS[3001150] then -- 低级首饰
        return self:getLastJewelryLevel()
    elseif name == CHS[3002966] then
        return self:getLastJewelryHighLevel()
    elseif secondClass == CHS[7000044] or secondClass == CHS[7000045] then
        -- 经验心得/道武心得
        return self:getLastXinDeLevel(secondClass)
    end
end

-- 设置集市上次选中武器的等级
function MarketMgr:setLastEquipLevel(level)
    self.lastSelectEquipLevel = level
end

-- 获取集市上次选中武器的等级
function MarketMgr:getLastEquipLevel()
    return self.lastSelectEquipLevel
end

-- 设置集市上次选中首饰等级
function MarketMgr:setLastJewelryLevel(level)
    self.lastSelectJewelryLevel = level
end

-- 获取集市上次选中首饰等级
function MarketMgr:getLastJewelryLevel()
    return self.lastSelectJewelryLevel
end

-- 设置集市上次选中高级首饰等级
function MarketMgr:setLastJewelryHighLevel(level)
    self.lastJewelryHighLevel = level
end

-- 获取集市上次选中高级等级
function MarketMgr:getLastJewelryHighLevel()
    return self.lastJewelryHighLevel
end

function MarketMgr:setLastXinDeLevel(level, name)
    if not self.lastXinDeLevel then
        self.lastXinDeLevel = {}
    end

    self.lastXinDeLevel[name] = level
end

function MarketMgr:getLastXinDeLevel(name)
    if self.lastXinDeLevel then
        return self.lastXinDeLevel[name]
    end
end

-- 集市上一次关闭界面选中状态
-- dlgName 对话框名字
-- firstClass 选中一级标签
-- secondClass 选中二级标签
-- thirdClass 选中三级标签
-- isFromSearch 数据是否是从搜索过来
-- upSort 是否升序排序
function MarketMgr:setMarketLastSelectStateData(data)
    if not self.marketLastSelectData then self.marketLastSelectData = {} end
    self.marketLastSelectData[data.dlgName] = data
end

function MarketMgr:getMarketLastSelectStateData(dlgName)
    if not self.marketLastSelectData then return end

    return self.marketLastSelectData[dlgName]
end

-- 设置交易类型
function MarketMgr:setTradeType(type)
	self.tradeType = type
end

-- 获取交易类型
function MarketMgr:getTradeType()
    return self.tradeType or MarketMgr.TradeType.marketType
end

-- 当前的交易类型是否是珍宝
function MarketMgr:isTreasureTradeType()
    return self:getTradeType() == MarketMgr.TradeType.goldType
end

-- 当前的交易类型是否是珍宝
function MarketMgr:isGoldtype(tradeType)
    return MarketMgr.TradeType.goldType == tradeType
end

-- 获取珍宝交易一级列表
function MarketMgr:getTreasureList()
    local list = gf:deepCopy(TREASURE_ITEM_LIST)
    if not MarketMgr:getIsCanShowCashTag() then
         -- 不显示金钱标签
        for i = #list, 1, -1 do
            if list[i] == CHS[3002143] then
                table.remove(list, i)
            end
        end
    end

    return list
end

-- 是否是休市时间
function MarketMgr:isRestMarketTime()
    local hour = tonumber(gf:getServerDate("%H", gf:getServerTime()))
    if hour >= 8 and hour < 12 then
        gf:ShowSmallTips(CHS[4300009])
        return true
    end

    return false
end

-- 获取摊位费
function MarketMgr:getBoothCost(sellPrice, isUnpublic, tradeType, isMoney)
    local bootCost = sellPrice * SELL_RATE
    local max = MAX_PUBLIC_BOOTH_COST
    local min = MIN_PUBLIC__BOOTH_COST

    if isUnpublic then
        max = MAX_UNPUBLIC_BOOTH_COST
        min = MIN_UNPUBLIC__BOOTH_COST
    end

    local zhanbuDiscount = TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_WFQ_CY_JSBT)
    if self:isGoldtype(tradeType) then
        bootCost = sellPrice * GOLD_SELL_RATE
        max = GOLD_MAX_PUBLIC_BOOTH_COST
        min = GOLD_MIN_PUBLIC__BOOTH_COST

        if isMoney then
            min = GOLD_MIN_MONEY_BOOTH_COST
    end
        zhanbuDiscount = TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_WFQ_CY_ZBBT)
    end

    if bootCost < min then
        bootCost = min
    elseif bootCost > max then
        bootCost = max
    end

	bootCost = math.floor(bootCost)

    -- 集市、珍宝摆摊手续费，最终值还受占卜任务影响
    bootCost = bootCost * zhanbuDiscount

    -- 取整与服务器同步为向上取整
    return math.ceil(bootCost)
end

-- 获取变身卡的三级类别
function MarketMgr:getChangeCardThirdClass(polar)
    return POLAR_TO_NAME[polar] or POLAR_TO_NAME[0]
end

-- 获取等级转等级段用来显示
function MarketMgr:getEquipLevelStr(level)

	if level == CHS[4100650] then
		-- 有可能level == "所有等级"
		return level
	end

    level = tonumber(level)
    if not level then
        return level
    end

    return MARKET_EQUIP_LEVEL_STR[level] or (level ..CHS[3003094])
end

-- 获取三级菜单文字
function MarketMgr:getThirdClassStr(thirdClass, classType)
    if type(thirdClass) == "number" or tonumber(thirdClass) then -- 数字表示等级
        if classType == CHS[3002964] then -- 如果是装备返回等级段
            return self:getEquipLevelStr(thirdClass)
        else
            return thirdClass ..CHS[3003094]
        end
    else
        return thirdClass
    end

    return ""
end

-- 保存排序方式
function MarketMgr:setLastSort(upSort, sortType)
    self.upSort = upSort
    self.sortType = sortType
end

-- 获取排序方式
function MarketMgr:getLastSort()
    if self.upSort == nil then
        self.upSort  = true
    end

    return self.upSort , (self.sortType or "price")
end

-- 设置集市的搜索数据
function MarketMgr:setMarketSearchData(data, tradeType)
    if self:isGoldtype(tradeType) then
        self.goldSearchData = data
    else
        self.marketSearchData = data
    end
end

-- 获取上一次集市搜索数据
function MarketMgr:getMarketSearchData(tradeType)
    if self:isGoldtype(tradeType) then
        return self.goldSearchData
    else
        return self.marketSearchData
    end
end

-- 请求打开抢购界面
function MarketMgr:cmdOpenPanicBuy(goods_gid, tradeType)
    if self:isGoldtype(tradeType) then
        gf:CmdToServer("CMD_GOLD_STALL_RUSH_BUY_OPEN", {goods_gid = goods_gid})
    else
        gf:CmdToServer("CMD_STALL_RUSH_BUY_OPEN", {goods_gid = goods_gid})
    end
end

-- 由于当前集市配置和珍宝同一份，后来黄伟相惊天要求，有些东西珍宝显示，集市不显示！so... 数据要转化下，排除不需要显示的
function MarketMgr:eliminateData(data, tradaType)
    local retDta = {}
    for _, v in pairs(data) do
        if v.sellType then
            if v.sellType == tradaType then
                table.insert(retDta, v)
            end
        else
            table.insert(retDta, v)
        end
    end

    retDta = MarketMgr:checkGongmingStoneShow(retDta)
    return retDta
end

function MarketMgr:getThirdClassList(list, tradeType)
    local res = list

    if not list then
        return list
    end

    if list.sellType and list.sellType ~= tradeType then
        return
    end

    if list.needHideInPublic then
        -- 公测屏蔽元神碎片·餐风、元神碎片·饮露
        res = gf:deepCopy(list)
        for i = #res, 1, -1 do
            if not DistMgr:curIsTestDist() and res.needHideInPublic[res[i]] then
                table.remove(res, i)
            end
        end
    end

    return res
end

-- 根据自身等级获取相关等级段， 心得(经验心得，道武心得)
function MarketMgr:getXindeLVByLevel(level, itemName)
    if not level then level = Me:queryInt("level") end

    local str = ""
    if level < 70 then
        str = CHS[4200207]
    elseif level <= 79 then
        str = CHS[4200208]
    elseif level <= 89 then
        str = CHS[4200209]
    elseif level <= 99 then
        str = CHS[4200210]
    elseif level <= 109 then
        str = CHS[4200211]
    elseif level <= 119 then
        str =  CHS[4100553]
    else
        str =  CHS[4100553]
    end

    -- 经验心得最高100级
    if itemName == CHS[7000044] then
        if level > 99 then
            str = CHS[4200211]
        end
    end

    return str
end

function MarketMgr:getPetShowName(data)
    local name = data.name

    if not data.extra then
        return name
    end

    local info = json.decode(data.extra)
    if not info then
        return name
    end

    if not (info.rank and info.mount_type and info.rebuild_level and info.enchant) then
        return name
    end

    info.name = name
    local petShowName = gf:getPetName(info)
    return petShowName
end

-- 记录二级类别滑动位置
function MarketMgr:setSecondClassScrollPosition(class, positionY)
    self.secondClassScrollPosition = {class = class, positionY = positionY}
end

function MarketMgr:getSecondClassScrollPosition(class)
    if self.secondClassScrollPosition and self.secondClassScrollPosition.class == class then
        return self.secondClassScrollPosition.positionY
    else
        self.secondClassScrollPosition = {}
    end
end

function MarketMgr:MSG_STALL_BUY_RESULT(data)
    if data.tips ~= "" then
        gf:ShowSmallTips(data.tips)
    end
end

function MarketMgr:MSG_GOLD_STALL_BUY_RESULT(data)
    self:MSG_STALL_BUY_RESULT(data)
end

-- 联系卖家
function MarketMgr:connectSeller(type, gid, para, dlgName, itemName)
    gf:CmdToServer("CMD_EXCHANGE_CONTACT_SELLER", {type = type, goods_gid = gid, para = para})
    self.connectSellerItemGid = gid
    self.connectSellerItemdlgName = dlgName
end


function MarketMgr:MSG_EXCHANGE_CONTACT_SELLER(data)
    if self.connectSellerItemGid ~= data.goods_gid and not DlgMgr:getDlgByName(self.connectSellerItemdlgName) then
        -- gid不对，不管
        return
    end

    local name = data.name
    if not FriendMgr:isBlackByGId(data.gid) then
        --  把频道界面设置屏幕外
        local channelDlg = DlgMgr:getDlgByName("ChannelDlg")
        if channelDlg then
            channelDlg:moveToWinOutAtOnce()
        end

        local dlg = FriendMgr:openFriendDlg(true)

        dlg:setChatInfo({name = name, gid = data.gid, icon = data.icon, level = data.level})

        local type = data.type
        local showStr = type .. CHS[7000078] .. data.goods_name

        local para = string.match(data.para, ".")
        local sendInfo = string.format("{\t%s=%s=%s|%s}", showStr, type,  data.goods_gid, para)
        local showInfo = string.format("{\29%s\29}", showStr)

        local chat = FriendMgr:getChatByGid(data.gid)
        if chat then
            chat:addCardInfo(sendInfo, showInfo)
        end
    else
        gf:ShowSmallTips(CHS[5000075])
    end
end

-- 珍宝是否可以出售金钱
function MarketMgr:getIsCanSellCash()
    return self.goldCanSellCashGood
end

-- 珍宝是否显示金钱标签
function MarketMgr:getIsCanShowCashTag()
    return self.goldCanShowCashTag
end

-- 获取开服后珍宝可以出售金钱的天数
function MarketMgr:getSellCashAfterDays()
    return self.sellCashAfterDays
end

-- 获取可交易的金钱商品列表
function MarketMgr:getCanSellCashList()
    return SELL_CASH_LIST
end

-- 请求金钱商品的标准价
function MarketMgr:requestMoneyItemStdPrice(itemName)
    gf:CmdToServer("CMD_GOLD_STALL_CASH_PRICE", {name = tonumber(itemName)})
end

-- 请求金钱商品列表
function MarketMgr:requestMoneyItemList()
    gf:CmdToServer("CMD_GOLD_STALL_CASH_GOODS_LIST", {})
end

-- 请求购买某金钱商品
function MarketMgr:requestBuyMoneyGood(name, price)
    gf:CmdToServer("CMD_GOLD_STALL_BUY_CASH", {name = tonumber(name), expect_price = price})
end

function MarketMgr:MSG_GOLD_STALL_CONFIG(data)
    self.goldStallConfig = data

    self.sellCashAfterDays = data.sell_cash_aft_days
    self.goldCanSellCashGood = data.start_gold_stall_cash == 1
    self.goldCanShowCashTag = data.enable_gold_stall_cash == 1
end

-- 获取金钱商品列表
function MarketMgr:MSG_GOLD_STALL_CASH_GOODS_LIST(data)
    self.cashGoodList = {}

    for i = 1, #SELL_CASH_LIST do
        local info = {}
        local name = tostring(SELL_CASH_LIST[i])
        info.price = data[name]
        info.name = name
        info.isSellMoney = true
        table.insert(self.cashGoodList, info)
    end
end

-- 尝试请求金钱商品列表
function MarketMgr:tryGetCurSellCashList()
    if not self.lastRequestCashListTime then
        self.lastRequestCashListTime = 0
    end

    local curTime = gf:getServerTime()
    -- 1s 内只能请求一次
    if curTime - self.lastRequestCashListTime <= 1 then
        gf:ShowSmallTips(CHS[5420258])
        return false
    else
        self.lastRequestCashListTime = curTime
        self:requestMoneyItemList()
        return true
    end
end

function MarketMgr:checkPetSellCondition(pet, tradeType)
    local sellNum = MarketMgr:getSellPosCount(tradeType)
    local allNum = MarketMgr:getMySellNum(tradeType)

    if not sellNum then
        gf:ShowSmallTips("555"..CHS[3003075])
        return false
    end

    if sellNum >= allNum then
        if Me:getVipType() ~= 3 then
            gf:ShowSmallTips(CHS[3003076])
            return false
        else
            gf:ShowSmallTips(CHS[3003077])
            return false
        end
    end

    local islimited = InventoryMgr:isLimitedItem(pet)
    local iscannotSell = not gf:isExpensive(pet, true) and MarketMgr:isGoldtype(tradeType) -- 珍宝非贵重物品不能摆摊
    local pet_status = pet:queryInt("pet_status")
    local petId = pet:queryBasicInt("id")

    if islimited then
        gf:ShowSmallTips(CHS[6400015])
        return false
    elseif iscannotSell then
        gf:ShowSmallTips(CHS[6000242])
        return false
    elseif pet_status == 1 then
        gf:ShowSmallTips(CHS[3003082])
        return false
    elseif pet_status == 2 then
        gf:ShowSmallTips(CHS[3003083])
        return false
    elseif PetMgr:isRidePet(petId) then
        gf:ShowSmallTips(CHS[2000163])
        return false
    elseif Me:isInCombat() and pet:queryBasicInt('pet_have_called') == 1 then
        -- 战斗中，从集市买的宠物不可以参与战斗，但可以重新上架
        gf:ShowSmallTips(CHS[4000449])
        return false
    elseif PetMgr:isFeedStatus(pet) then
        gf:ShowSmallTips(CHS[5410091])
        return false
    elseif PetMgr:isCFZHStatus(pet) then
        gf:ShowSmallTips(CHS[2500066])
        return
    end

    return true
end

function MarketMgr:checkItemSellCondition(item, tradeType)
    local sellNum = MarketMgr:getSellPosCount(tradeType)
    local allNum = MarketMgr:getMySellNum(tradeType)

    -- if not sellNum then
    --    gf:ShowSmallTips("666"..CHS[3003075])
    --    return false
    --end

    if sellNum >= allNum then
        if Me:getVipType() ~= 3 then
            gf:ShowSmallTips(CHS[3003076])
            return false
        else
            gf:ShowSmallTips(CHS[3003077])
            return false
        end
    end

    local  isLimited = InventoryMgr:isLimitedItem(item)
    if isLimited then
        gf:ShowSmallTips(CHS[3003081])
        return false
    end

    local iscannotSell = not gf:isExpensive(item, false) and MarketMgr:isGoldtype(tradeType) -- 珍宝非贵重物品不能摆摊
    if iscannotSell then
        gf:ShowSmallTips(CHS[6000241])
        return false
    end

    -- 耐久度检测
    if InventoryMgr:isUsedItem(item) then
        gf:ShowSmallTips(CHS[4200365])
        return false
    end

    return true
end

function MarketMgr:checkChangeCardSellCondition(card, tradeType)
    local sellNum = MarketMgr:getSellPosCount(tradeType)
    local allNum = MarketMgr:getMySellNum(tradeType)

    if not sellNum then
        gf:ShowSmallTips("777"..CHS[3003075])
        return false
    end

    if sellNum >= allNum then
        if Me:getVipType() ~= 3 then
            gf:ShowSmallTips(CHS[3003076])
            return false
        else
            gf:ShowSmallTips(CHS[3003077])
            return false
        end
    end

    local cards = StoreMgr:getChangeCardByName(card.name, true)
    if #cards == 0 then
        gf:ShowSmallTips(CHS[4300008])
        return false
    end

    return true
end
--解决珍宝显示问题
function MarketMgr:isShowGoldMarket()
   --if not self.goldStallConfig or self.goldStallConfig.close_time <= 0 then return true end
   -- return gf:getServerTime() < self.goldStallConfig.close_time
   return true
end

function MarketMgr:getCurSellCashList()
    if not self.cashGoodList then
        self:MSG_GOLD_STALL_CASH_GOODS_LIST({})
    end

    return self.cashGoodList or {}
end

-- 获取集市举报物品
function MarketMgr:getMarketTipOffItem()
    local item = DlgMgr:sendMsg("MarketPublicityDlg", "getSelectItemData")
    if not item then
        item = DlgMgr:sendMsg("MarketBuyDlg", "getSelectItemData")
    end
    if not item then
        item = DlgMgr:sendMsg("MarketCollectionDlg", "getSelectItemData")
    end

    return item
end


-- 共鸣石4月26号之前在公测区不可见
function MarketMgr:checkGongmingStoneShow(data)
    if DistMgr:needIgnoreGongming() then
        local list = {}
        for i = 1, #data do
            if data[i].name ~= CHS[7190126] then
                table.insert(list, data[i])
            end
        end

        return list
    else
        return data
    end
end

function MarketMgr:setSellBuyTypeFlag(sell_buy_type, dlg, panel)

    local isVisibleZhiding = (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_BUY)

    -- 指定交易，有的标记叫做  ZhidingImage，有的又叫做 DesignatedIcon
    dlg:setCtrlVisible("ZhidingImage", isVisibleZhiding, panel)
    dlg:setCtrlVisible("DesignatedIcon", isVisibleZhiding, panel)

    -- 拍卖
    local isVisiblePaimai = (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION_BUY)
    dlg:setCtrlVisible("VendueImage", isVisiblePaimai, panel)
    dlg:setCtrlVisible("VendueIcon", isVisiblePaimai, panel)
end


function MarketMgr:openZhenbaoSellDlg(data, tradeInfo, isOper)

    if not isOper and tradeInfo and gf:getServerTime() > tradeInfo.endTime then
        if tradeInfo.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW then
            gf:ShowSmallTips(CHS[4101234]) -- 该商品已不在公示期，无法查看。
            return
        elseif tradeInfo.status == MARKET_STATUS.STALL_GS_AUCTION then
            gf:ShowSmallTips(CHS[4101235]) -- 该商品已不在拍卖期，无法查看。
            return
        end
    end
--]]
        --  成交期
    if tradeInfo and tradeInfo.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
        -- 中标者
        if tradeInfo.appointee_name == Me:queryBasic("name") then
            -- 界面后买打开，因为不能在 parentDlg 界面之前打开
        else
            gf:ShowSmallTips(CHS[4101236])
            return
        end
    end

    local parentDlg
    if data and data.item_type then
        if EquipmentMgr:isJewelry(data) then
            -- 首饰
            parentDlg = DlgMgr:openDlg("MarketGoldJewerlyInfoDlg")
            parentDlg:setJewelryInfo(data)
        elseif data.equip_type == EQUIP_TYPE.ARTIFACT then
            parentDlg = DlgMgr:openDlg("MarketGoldArtifactInfoDlg")
            parentDlg:setArtifactInfo(data)
        else
            parentDlg = DlgMgr:openDlg("MarketGoldEquipmentInfoDlg")
            parentDlg:setEquipmentInfo(data)
        end
    else
        parentDlg = DlgMgr:openDlgEx("MarketGoldPetInfoDlg", data)
        --parentDlg:setPetInfo(data)
    end

    if not parentDlg.childDlg then parentDlg.childDlg = {} end
    -- 普通寄售
    if not tradeInfo then
        local dlg = DlgMgr:openDlg("MarketGoldSellGoodsDlg")
        dlg:setItem(data)

        parentDlg.childDlg[dlg.name] = dlg
        dlg.parentDlg = parentDlg
        return
    end

    -- 处于公示、寄售
    if tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.SHOW or tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.ON_SELL
        or tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.SHOW_VENDUE or tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.ON_SELL_VENDUE then
        local isVisibleCommonResell = (tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_NONE or tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_CONTINUE)
        if isOper then

            local dlg = DlgMgr:openDlg("MarketGoldOperateGoodsDlg")
            dlg:setData(data, tradeInfo)
            parentDlg.childDlg[dlg.name] = dlg
            dlg.parentDlg = parentDlg
        else
            local dlg = DlgMgr:openDlg("MarketGoldViewGoodsDlg")
            dlg:setData(data, tradeInfo)
            parentDlg.childDlg[dlg.name] = dlg
            dlg.parentDlg = parentDlg
        end
        return
    end

    --  成交期
    if tradeInfo.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
        -- 中标者
        if tradeInfo.appointee_name == Me:queryBasic("name") then
            local dlg = DlgMgr:openDlg("MarketGoldPayDlg")
            dlg:setData(data, tradeInfo)
            parentDlg.childDlg[dlg.name] = dlg
            dlg.parentDlg = parentDlg
        else
            gf:ShowSmallTips(CHS[4101246])
            return
        end
    end

    --  过期
    if tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.OUT_SELL then
        local dlg = DlgMgr:openDlg("MarketGoldReSellGoodsDlg")
        dlg:setData(data, tradeInfo)
        parentDlg.childDlg[dlg.name] = dlg
        dlg.parentDlg = parentDlg
    end

end

-- 获取一口价
function MarketMgr:getGoldYkj(price)

    local function getGoldServiceCharge(price)
        -- body
        if price <= 10000 then
            return math.floor( price * 1 )
        elseif price <= 25000 then
            return getGoldServiceCharge(10000) + math.floor( (price - 10000) * 0.7 )
        elseif price <= 250000 then
            return getGoldServiceCharge(25000) + math.floor( (price - 25000) * 0.5 )
        elseif price <= 500000 then
            return getGoldServiceCharge(250000) + math.floor( (price - 250000) * 0.25 )
        elseif price <= 100000000 then
            return getGoldServiceCharge(500000) + math.floor( (price - 500000) * 0.1 )
        end
    end

    return getGoldServiceCharge(price) + price
end

-- 是否竞拍过
function MarketMgr:isVenduedByGoodsGid(gid)
    if not self.myMarketGoldVendueGoodsGids then return false end
    return self.myMarketGoldVendueGoodsGids[gid]
end

function MarketMgr:MSG_GOLD_STALL_AUCTION_BID_GIDS(data)
    self.myMarketGoldVendueGoodsGids = data.gids
end

function MarketMgr:getDepositDingJin(price)
    return math.floor( price * 0.1 )
end


--MessageMgr:regist("MSG_GOLD_STALL_MY_BID_GOODS", MarketMgr)


MessageMgr:regist("MSG_GOLD_STALL_AUCTION_BID_GIDS", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_CONFIG", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_CASH_GOODS_LIST", MarketMgr)

MessageMgr:regist("MSG_EXCHANGE_CONTACT_SELLER", MarketMgr)
MessageMgr:regist("MSG_STALL_MINE", MarketMgr)
MessageMgr:regist("MSG_STALL_ITEM_LIST", MarketMgr)
MessageMgr:regist("MSG_STALL_RECORD", MarketMgr)
MessageMgr:regist("MSG_STALL_SERACH_ITEM_LIST", MarketMgr)
MessageMgr:regist("MSG_MARKET_GOOD_CARD", MarketMgr)
MessageMgr:regist("MSG_MARKET_PET_CARD", MarketMgr)
MessageMgr:regist("MSG_MARKET_SEARCH_RESULT", MarketMgr)
MessageMgr:regist("MSG_MARKET_CHECK_RESULT", MarketMgr)
MessageMgr:regist("MSG_STALL_UPDATE_GOODS_INFO", MarketMgr)
MessageMgr:regist("MSG_SYS_AUCTION_GOODS_LIST", MarketMgr)
MessageMgr:regist("MSG_SYS_AUCTION_UPDATE_GOODS", MarketMgr)
MessageMgr:regist("MSG_STALL_BUY_RESULT", MarketMgr)


-- 珍宝交易相关指令
MessageMgr:regist("MSG_GOLD_STALL_BUY_RESULT", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_GOODS_LIST", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_UPDATE_GOODS_INFO", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_GOODS_STATE", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_MINE", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_RECORD", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_SEARCH_GOODS", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_GOODS_INFO_PET", MarketMgr)
MessageMgr:regist("MSG_GOLD_STALL_GOODS_INFO_ITEM", MarketMgr)

return MarketMgr
