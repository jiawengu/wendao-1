-- BatteryAndWifiMgr.lua
-- created by songcw Oct/26/2016
-- 交易平台管理器

TradingMgr = Singleton()

-- 角色
TradingMgr.tradingData = nil

-- 商品
TradingMgr.tradingGoodsData = nil

local json = require("json")
local CHAR_TRADING = require('cfg/TradingMapChar')
local PET_TRADING = require('cfg/TradingMapPet')
local ITEM_TRADING = require('cfg/TradingMapItem')
local GUARD_TRADING = require('cfg/TradingMapGuard')
local CHILD_TRADING = require('cfg/TradingMapChild')

local DataObject = require("core/DataObject")
TradingMgr.LIST_TYPE = {
    SALE_LIST = 1,          --  售出
    SHOW_LIST = 2,          -- 公示
    AUCTION_SHOW_LIST = 4,  -- 拍卖公示
    AUCTION_LIST = 5,  -- 拍卖寄售
}

TradingMgr.URL_ACTION = {
    BUY         = 1,    -- 购买
    CANCEL   = 2,    -- 取回
}

TradingMgr.LIST_TYPE_NAME = {
    [1] = CHS[5410124],          -- 寄售列表
    [2] = CHS[5410125],          -- 公示列表
    [4] = CHS[5410125],           -- 公示列表
    [5] = CHS[4101096],           -- 拍卖列表
}

TradingMgr.GOODS_TYPE = {
    SALE_TYPE_USER_METAL        = 101,  -- 金角色
    SALE_TYPE_USER_WOOD         = 102,  -- 木角色
    SALE_TYPE_USER_WATER        = 103,  -- 水角色
    SALE_TYPE_USER_FIRE         = 104,  -- 火角色
    SALE_TYPE_USER_EARTH        = 105,  -- 土角色

    SALE_TYPE_CASH_GOODS        = 201,  -- 金钱

    SALE_TYPE_PET_NORMAL        = 301,  -- 普通宠物
    SALE_TYPE_PET_ELITE         = 302,  -- 变异宠物
    SALE_TYPE_PET_OTHER         = 303,  -- 其他特殊宠物
    SALE_TYPE_PET_JINGGUAI      = 304,  -- 精怪
    SALE_TYPE_PET_YULING        = 305,  -- 御灵
    SALE_TYPE_PET_JINIAN       = 306,  -- 纪念
    SALE_TYPE_PET_EPIC         = 307,  -- 神兽

    SALE_TYPE_WEAPON_GUN        = 401,  -- 枪
    SALE_TYPE_WEAPON_CLAW       = 402,  -- 爪
    SALE_TYPE_WEAPON_SWORD      = 403,  -- 剑
    SALE_TYPE_WEAPON_FAN        = 404,  -- 扇
    SALE_TYPE_WEAPON_HAMMER     = 405,  -- 锤

    SALE_TYPE_HELMET_MALE       = 501,  -- 男帽
    SALE_TYPE_HELMET_FEMALE     = 502,  -- 女帽
    SALE_TYPE_ARMOR_MALE        = 503,  -- 男衣
    SALE_TYPE_ARMOR_FEMALE      = 504,  -- 女衣
    SALE_TYPE_BOOT              = 505,  -- 鞋子

    SALE_TYPE_JEWELRY_BALDRIC   = 601,  -- 玉佩
    SALE_TYPE_JEWELRY_NECKLACE  = 602,  -- 项链
    SALE_TYPE_JEWELRY_WRIST     = 603,  -- 手镯

    SALE_TYPE_ARTIFACT_HUNYJD   = 701,  -- 混元金斗
    SALE_TYPE_ARTIFACT_FANTY    = 702,  -- 番天印
    SALE_TYPE_ARTIFACT_DINGHZ   = 703,  -- 定海珠
    SALE_TYPE_ARTIFACT_JINJJ    = 704,  -- 金蛟剪
    SALE_TYPE_ARTIFACT_YINYJ    = 705,  -- 阴阳镜
    SALE_TYPE_ARTIFACT_XIEJJH   = 706,  -- 卸甲金葫
    SALE_TYPE_ARTIFACT_JIULSHZ  = 707,  -- 九龙神火罩
}

local COST_CASH_EXPENSIVE = 500000        -- 手续费，游戏币
local COST_CASH_NORMAL= 2000000           -- 手续费，游戏币

local PRICE_MAX = 500000        -- 最高
local PRICE_PET_MAX = 200000        -- 最高

-- 收藏、取消收藏两次操作时间间隔
local TIME_MAGIN_FOR_COLLECT = 3000

-- 寄售物品数据
local jubao_sell_data = {}

-- 公示物品数据
local jubao_public_data = {}

-- 聚宝斋拍卖数据
local jubao_vendue_data = {}

-- 收藏列表，哈希表，gid为key
local favorite_data = {}

-- 快照信息,以商品gid为key
local mGoodsInfo = {}

-- 我出售信息，目前包含自己角色的快照
local mMySellGoods = nil

local FAVORITE_COUNT = 20

TradingMgr.BUY_URL = "http://www.boyuemobile.com"
TradingMgr.AUTO_LOGIN_URL = "%s/purchase/order.do"
TradingMgr.AUTO_MANAGE_URL = "%s/personal/orderManage.do"

TradingMgr.autoLoginInfo = {}
-- 获取手续费
function TradingMgr:getCostCash(item)
    if not item then
        return COST_CASH_EXPENSIVE
    end

    --  如果是物品
    if item.item_type then
        if gf:isExpensive(item) then
            return COST_CASH_EXPENSIVE
        else
            return COST_CASH_NORMAL
        end
    end

    -- 如果是宠物
    if gf:isExpensive(item, true) then
        return COST_CASH_EXPENSIVE
    else
        return COST_CASH_NORMAL
    end
end

function TradingMgr:getMaxPrice()
    return PRICE_MAX
end

function TradingMgr:getRealIncomeForVendue(price)
    local st = price * 0.06 + 5
    return math.max(0, price - st)
end

-- 获取定金
function TradingMgr:getDeposit(price)
    return math.floor(price * 0.1)
end

-- 实际收入
function TradingMgr:getRealIncome(price, isHero, isMoney)
    if isHero then
        local st = math.max(price * 0.04, 50)
        return math.max(0, price - st)
    elseif isMoney then
        if price < 50 then
            return math.max(price * 0.9, 0)
        elseif price >= 50 and price <= 100 then
            return math.max(price * 0.91, 0)
        else
            return math.max(price * 0.96 - 5, 0)
        end
    else
        if price <= 100 then
            return math.max(price - 5, 0)
        else
            return math.max(price - (price * 0.04 + 5), 0)
        end
    end
end

function TradingMgr:clearData()
    TradingMgr.tradingData = nil
    TradingMgr.tradingGoodsData = nil
    mMySellGoods = nil
    TradingMgr:cleanAutoLoginInfo()
    -- 聚宝斋寄售,公示列表数据需要在登录,退出游戏时清除,换线不清除  WDSY-26392
    if not DistMgr:getIsSwichServer() then
        jubao_sell_data = {}
        jubao_public_data = {}
        jubao_vendue_data = {}
    end
end

--
local YKJ_MAP = {
    {0,         200,        100},
    {200,       500,        70 },
    {500,       5000,       50},
    {5000,      500000,     25},
}
--]]

-- 获取一口价
function TradingMgr:getYKJ(price, isPet)
    local ret = price
    for _, arr in pairs(YKJ_MAP) do
        if price <= arr[2] then
            ret = ret + math.ceil(1.0 * arr[3] / 100 * (price - arr[1]))
            if isPet then
                return math.min(ret, PRICE_PET_MAX) + math.ceil(price * 2.5 / 100)
            else
                return math.min(ret, PRICE_MAX) + math.ceil(price * 2.5 / 100)
            end
        end

        ret = ret + math.ceil(1.0 * arr[3] / 100 * (arr[2] - arr[1]))
    end

    ret = ret + math.ceil(price * 2.5 / 100)

    if isPet then
        return math.min(ret, PRICE_PET_MAX)
    else
        return math.min(ret, PRICE_MAX)
    end
end

-- 在游戏中出售角色
function TradingMgr:tradingSellRole(price, appointee, income)
    -- 价格判断
    if not price then
        gf:ShowSmallTips(CHS[4300260])
        return
    end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        SafeLockMgr:addModuleContinueCb("TradingMgr", "tradingSellRole", price, appointee, income)
        return
    end

    if Me:queryInt("cash") < TradingMgr:getCostCash() then
        gf:askUserWhetherBuyCash()
        return
    end

    TradingMgr:trySellOrResellGoods("CMD_TRADING_SELL_ROLE", {price = price, appointee = appointee or "", income = tostring(income)})
end

function TradingMgr:getCheckBindFlag()
    return self.isChecking
end

function TradingMgr:setCheckBindFlag(isChecking)
    self.isChecking = isChecking
end

-- 获取数据，根据传入类型
function TradingMgr:getDataByClass(list_type, goods_type)

    if not goods_type then return end

    if not self.tradingSearchDataRecTime then self.tradingSearchDataRecTime = {} end
    if goods_type == CHS[7000306] and gfGetTickCount() - (self.tradingSearchDataRecTime[list_type] or 0) >= 15 * 60 * 1000 then
        if list_type == TradingMgr.LIST_TYPE.SALE_LIST then
            jubao_sell_data[goods_type] = {}
        elseif list_type == TradingMgr.LIST_TYPE.SHOW_LIST then
            jubao_public_data[goods_type] = {}
        else
            if not jubao_vendue_data[list_type] then jubao_vendue_data[list_type] = {} end
            jubao_vendue_data[list_type][goods_type] = {}
        end
    end


    if list_type == TradingMgr.LIST_TYPE.SALE_LIST or list_type == TradingMgr.LIST_TYPE.SALE_LIST then
        return jubao_sell_data[goods_type]
    elseif list_type == TradingMgr.LIST_TYPE.SHOW_LIST then
        return jubao_public_data[goods_type]
    else
        -- 拍卖
        if jubao_vendue_data[list_type] then
            return jubao_vendue_data[list_type][goods_type]
        end
    end

    return
end

-- 请求聚宝斋收藏列表
function TradingMgr:queryTradingCollectList(list_type)
    gf:CmdToServer("CMD_TRADING_FAVORITE_LIST", {list_type = list_type})


end

-- 请求聚宝斋商品列表
function TradingMgr:queryTradingGoodsList(list_type, goods_type)

    local data = TradingMgr:getDataByClass(list_type, goods_type)

    local key = 0
    if data then key = data.key end


    -- list_type ： 1寄售    2公示   4拍卖公示 5拍卖
    gf:CmdToServer("CMD_TRADING_GOODS_LIST", {list_type = list_type, goods_type = goods_type, key = key or 0})
end

-- 请求改变商品的收藏
function TradingMgr:modifyCollectGoods(gid, isFavorite, auto_favorite)
    auto_favorite = auto_favorite or 0

    -- 是否已收藏
    if isFavorite == 1 and favorite_data[gid] then
        return
    end

    gf:CmdToServer("CMD_TRADING_CHANGE_FAVORITE", {gid = gid, is_favorite = isFavorite, auto_favorite = auto_favorite})
    return true
end

-- 客户端在选角界面请求取回角色
function TradingMgr:tradingCanceRole(gid)
    gf:CmdToServer("CMD_TRADING_CANCEL_ROLE", {gid = gid})
end

-- 客户端在选角界面请求修改角色价格
function TradingMgr:tradingChangePriceRole(gid, price)
    gf:CmdToServer("CMD_TRADING_CHANGE_PRICE_ROLE", {gid = gid, price = price})
end

-- 客户端在选角界面请求继续寄售角色
function TradingMgr:tradingSellRoleAgain(gid, price, income)
    gf:CmdToServer("CMD_TRADING_SELL_ROLE_AGAIN", {gid = gid, price = price, income = tostring(income)})
end

-- 客户端请求商品的快照信息
function TradingMgr:tradingSnapshot(goods_gid, snapshot_type, isSync, isShowCard)

    gf:CmdToServer("CMD_TRADING_SNAPSHOT", {goods_gid = goods_gid, snapshot_type = snapshot_type, isSync = isSync or 0, isShowCard = isShowCard or 0})
end

-- 客户端请求自身商品快照信息
function TradingMgr:tradingSnapshotMe()
    gf:CmdToServer("CMD_TRADING_SNAPSHOT_ME", {})
end

-- 聚宝斋上架商品，重新上架商品，需要刷新实名认证的消息
function TradingMgr:trySellOrResellGoods(cmd, para)

    if (Me.bindData and Me.bindData.isBindName) or gf:isWindows() then
        -- 已经实名认证
        gf:CmdToServer(cmd, para)
    else
        -- 未实名认证,应服务器要求，再次请求刷新数据，据说可能在平台认证原因
        if not self.isChecking then
            gf:CmdToServer('CMD_REQUEST_FUZZY_IDENTITY', {force_request = 1})
            TradingMgr:setCheckBindFlag(true)

            performWithDelay(gf:getUILayer(), function ()
                DlgMgr:sendMsg("UserSellDlg","queryBindNotAnswer")
                DlgMgr:sendMsg("JuBaoPetSellDlg","queryBindNotAnswer")
                DlgMgr:sendMsg("JuBaoPetOperateDlg","queryBindNotAnswer")
                DlgMgr:sendMsg("JuBaoCashSellDlg","queryBindNotAnswer")
                DlgMgr:sendMsg("JuBaoCashOperateDlg","queryBindNotAnswer")
                DlgMgr:sendMsg("JuBaoEquipSellDlg","queryBindNotAnswer")
                DlgMgr:sendMsg("JuBaoEquipOperateDlg","queryBindNotAnswer")
            end, 5)
        else
            local dlg = gf:confirm(CHS[4200217], function ()
                local dlg2 = DlgMgr:openDlg("SystemAccManageDlg")
                dlg2:onSwitchPanel(dlg2:getControl("AuthenticateRealNameCheckBox"))
                dlg2.radioGroup:selectRadio(2)
            end)
            dlg:setConfirmText(CHS[4200218])
            dlg:setCancleText(CHS[4200219])
        end
    end
end

-- 2017 ============
-- 上架商品
function TradingMgr:cmdSellGoods(price, type, para, appointee, item, sell_type)
    if not appointee then appointee = "" end


    -- 价格判断
    if not price then
        if sell_type == TRADE_SBT.AUCTION then
            gf:ShowSmallTips(CHS[4101101])
        else
            gf:ShowSmallTips(CHS[4300260])
        end
        return
    end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        SafeLockMgr:addModuleContinueCb("TradingMgr", "cmdSellGoods", price, type, para, appointee, item, sell_type)
        return
    end

    -- 金钱寄售摊位费为0
    if type ~= JUBAO_SELL_TYPE.SALE_TYPE_CASH and Me:queryInt("cash") < TradingMgr:getCostCash(item) then
        gf:askUserWhetherBuyCash()
        return
    end

    sell_type = sell_type or TRADE_SBT.NONE
    local income = 0
    if sell_type ~= TRADE_SBT.AUCTION then
        if type == JUBAO_SELL_TYPE.SALE_TYPE_CASH then
            income = TradingMgr:getRealIncome(price, false, true)
        elseif type == JUBAO_SELL_TYPE.SALE_TYPE_ROLE then
            income = TradingMgr:getRealIncome(price, true)
        else
            income = TradingMgr:getRealIncome(price)
        end
    else
        income = TradingMgr:getRealIncomeForVendue(price)
    end

    TradingMgr:trySellOrResellGoods("CMD_TRADING_SELL_GOODS", {price = price, type = type, para = para, appointee = appointee, sell_type = sell_type, income = tostring(income)})
end

-- 聚宝斋重新上架商品
function TradingMgr:cmdSellGoodsAgain(goods_gid, price, sell_type, type)
    sell_type = sell_type or TRADE_SBT.NONE


    local income = 0
    if sell_type ~= TRADE_SBT.AUCTION then
        if type == JUBAO_SELL_TYPE.SALE_TYPE_CASH then
            income = TradingMgr:getRealIncome(price, false, true)
        elseif type == JUBAO_SELL_TYPE.SALE_TYPE_ROLE then
            income = TradingMgr:getRealIncome(price, true)
        else
            income = TradingMgr:getRealIncome(price)
        end
    else
        income = TradingMgr:getRealIncomeForVendue(price)
    end



    TradingMgr:trySellOrResellGoods("CMD_TRADING_SELL_GOODS_AGAIN", {goods_gid = goods_gid, price = price, sell_type = sell_type, income = tostring(income)})
end

-- 聚宝斋修改商品价格
function TradingMgr:cmdChangePriceGoods(goods_gid, price)
    gf:CmdToServer("CMD_TRADING_CHANGE_PRICE_GOODS", {goods_gid = goods_gid, price = price})
end

-- 聚宝斋取消售上架商品
function TradingMgr:cmdCancelGoods(goods_gid)
    gf:CmdToServer("CMD_TRADING_CANCEL_GOODS", {goods_gid = goods_gid})
end

function TradingMgr:changePriceCondition(changePrice, goodsData, minPrice)
    local initPrice = goodsData.init_price * 0.8
    local curPrice = goodsData.price * 0.8

    initPrice = math.ceil( initPrice )    -- WDSY-36842
    curPrice = math.ceil( curPrice )    -- WDSY-36842

    local maxPrice = math.max(initPrice, curPrice, minPrice)

    local tips
    if maxPrice == initPrice then
        tips = CHS[4200567]
    elseif maxPrice == curPrice then
        tips = CHS[4200568]
    else
        tips = string.format( CHS[4200569], minPrice)
    end

    if changePrice < maxPrice then
        return false, maxPrice, tips
    end

    return true
end

-- 2017 ============

function TradingMgr:getTradingState(state)
    if not state then return "" end
    if state == TRADING_STATE.SHOW then
        return CHS[4100407], ResMgr.ui.tradingFlag_public
    elseif state == TRADING_STATE.SALE then
        return CHS[4100408], ResMgr.ui.tradingFlag_sell
    elseif state == TRADING_STATE.PAUSE then
        return CHS[4100409]
    elseif state == TRADING_STATE.PAYMENT or state == TRADING_STATE.AUCTION_PAYMENT then
        return CHS[4200196], ResMgr.ui.tradingFlag_sell
    elseif state == TRADING_STATE.CLOSED then
        return CHS[4100411]
    elseif state == TRADING_STATE.CANCEL then
        return CHS[4100413], ResMgr.ui.tradingFlag_timeOut
    elseif state == TRADING_STATE.TIMEOUT then
        return CHS[4100413], ResMgr.ui.tradingFlag_timeOut
    elseif state == TRADING_STATE.FETCHED then
        return CHS[4100414]
    elseif state == TRADING_STATE.FROZEN then
        return CHS[4100415], ResMgr.ui.tradingFlag_timeOut
    elseif state == TRADING_STATE.GOT then
        return CHS[4100416]
    elseif state == TRADING_STATE.FORCE_CLOSED then
        return CHS[4100417], ResMgr.ui.tradingFlag_timeOut
    elseif state == TRADING_STATE.ERROR then
        return CHS[4100418]
    elseif state == TRADING_STATE.AUCTION_SHOW then
        return CHS[4100407], ResMgr.ui.tradingFlag_public
    elseif state == TRADING_STATE.AUCTION then
        return CHS[4200528], ResMgr.ui.tradingFlag_sell
    end

    return ""
end

-- 用于登录时更换区组界面中，显示公示期、寄售期和已过期等图片
function TradingMgr:getTradingStateImagePathForChangeDist(state)
    if not state then return end
    if state == TRADING_STATE.SHOW then
        return ResMgr.ui.login_change_dist_public
    elseif state == TRADING_STATE.SALE then
        return ResMgr.ui.login_change_dist_sell
    elseif state == TRADING_STATE.PAUSE then

    elseif state == TRADING_STATE.PAYMENT then
        return ResMgr.ui.login_change_dist_sell
    elseif state == TRADING_STATE.CLOSED then

    elseif state == TRADING_STATE.CANCEL then
        return ResMgr.ui.login_change_dist_timeout
    elseif state == TRADING_STATE.TIMEOUT then
        return ResMgr.ui.login_change_dist_timeout
    elseif state == TRADING_STATE.FETCHED then

    elseif state == TRADING_STATE.FROZEN then
        return ResMgr.ui.login_change_dist_timeout
    elseif state == TRADING_STATE.GOT then

    elseif state == TRADING_STATE.FORCE_CLOSED then
        return ResMgr.ui.login_change_dist_timeout
    elseif state == TRADING_STATE.ERROR then

    end
end

function TradingMgr:getTradingUserData()
    return TradingMgr.tradingData
end

function TradingMgr:getTradingData()
    if not TradingMgr.tradingData or not next(TradingMgr.tradingData) then
        return TradingMgr.tradingGoodsData
    end

    return TradingMgr.tradingData
end

function TradingMgr:getTradingDataByGid(gid)
    if TradingMgr.tradingGoodsData then
        for i = 1, TradingMgr.tradingGoodsData.count do
            if TradingMgr.tradingGoodsData[i].goods_gid == gid then
                return TradingMgr.tradingGoodsData[i]
            end
        end
    end
end

-- 根据服务器索引转化成属性字段
function TradingMgr:changeIndexToFieldByChar(data)
    local ret = {}
    for index, value in pairs(data) do
        if CHAR_TRADING[index] then
            if type(value) == "table" then
                if value[1] then
                    ret[CHAR_TRADING[index]] = {}
                    for i = 1, #value do
                        table.insert(ret[CHAR_TRADING[index]], value[i])
                    end
                else
                    ret[CHAR_TRADING[index]] = TradingMgr:changeIndexToFieldByChar(value)
                end
            else
                ret[CHAR_TRADING[index]] = value
            end
        else
            Log:D("=========有编号没有定义==========:" .. index)
        end
    end

    return ret
end

-- 根据服务器索引转化成属性字段 宠物
function TradingMgr:changeIndexToFieldByPet(data)
    local ret = {}
    for index, value in pairs(data) do

        if PET_TRADING[index] then
            if type(value) == "table" then
                if value[1] then
                    ret[PET_TRADING[index]] = {}
                    for i = 1, #value do
                        table.insert(ret[PET_TRADING[index]], value[i])
                    end
                else
                    ret[PET_TRADING[index]] = TradingMgr:changeIndexToFieldByPet(value)
                end
            else
                ret[PET_TRADING[index]] = value
            end

            if index == 233 then
                ret[PET_TRADING[index]] = string.gsub(ret[PET_TRADING[index]], CHS[6000310], CHS[5440001])
                ret[PET_TRADING[index]] = string.gsub(ret[PET_TRADING[index]], CHS[6000324], CHS[5440002])
            end
        else
            Log:D("=========有编号没有定义==========:" .. index)
        end
    end

    return ret
end

-- 根据服务器索引转化成属性字段 守护
function TradingMgr:changeIndexToFieldByGuard(data)
    local ret = {}
    for index, value in pairs(data) do
        if GUARD_TRADING[index] then
            if type(value) == "table" then
                if value[1] then
                    ret[GUARD_TRADING[index]] = {}
                    for i = 1, #value do
                        table.insert(ret[GUARD_TRADING[index]], value[i])
                    end
                else
                    ret[GUARD_TRADING[index]] = TradingMgr:changeIndexToFieldByGuard(value)
                end
            else
                ret[GUARD_TRADING[index]] = value
            end
        else
            Log:D("=========有编号没有定义==========:" .. index)
        end
    end

    return ret
end

-- 根据服务器索引转化成属性字段 守护
function TradingMgr:changeIndexToFieldByChild(data)
    local ret = {}
    for index, value in pairs(data) do
        if CHILD_TRADING[index] then
            if type(value) == "table" then
                if value[1] then
                    ret[CHILD_TRADING[index]] = {}
                    for i = 1, #value do
                        table.insert(ret[CHILD_TRADING[index]], value[i])
                    end
                else
                    ret[CHILD_TRADING[index]] = TradingMgr:changeIndexToFieldByChild(value)
                end
            else
                ret[CHILD_TRADING[index]] = value
            end
        else
            Log:D("=========有编号没有定义==========:" .. index)
        end
    end

    return ret
end

-- 根据服务器索引转化成属性字段 装备
function TradingMgr:changeIndexToFieldByEquip(data)
    local ret = {}
    for index, value in pairs(data) do
        if ITEM_TRADING[index] then
            if type(value) == "table" then
                if value[1] then
                    ret[ITEM_TRADING[index]] = {}
                    for i = 1, #value do
                        table.insert(ret[ITEM_TRADING[index]], value[i])
                    end
                else
                    ret[ITEM_TRADING[index]] = TradingMgr:changeIndexToFieldByEquip(value)
                end
            else
                ret[ITEM_TRADING[index]] = value
            end
        else
            Log:D("=========有编号没有定义==========:" .. index)
        end
    end

    return ret
end

function TradingMgr:getLeftTime(leftTime, tradState)
    if tradState then
        if tradState == TRADING_STATE.TIMEOUT then
            return CHS[7000092]
        end
    end

    -- 如果截止时间到了，平台没有通知状态，则显示小于1分钟，吕寅口谕
    if tradState == TRADING_STATE.AUCTION and leftTime <= 0 then
        return CHS[4300224]
    end

    if leftTime <= 0 then return "" end

    -- 根据时间
    local day = math.floor(leftTime / (60 * 60 *24))
    local h = math.floor((leftTime % (60 * 60 *24)) / (60 * 60))

    local timeStr = ""
    if day > 0 then
        -- 防止误差，时间减去几分钟
        local retDay = math.ceil((leftTime - 60) / (60 * 60 * 24))
        timeStr = string.format(CHS[2000139], retDay)
        return timeStr
    end
    if h > 0 then
        timeStr = timeStr .. string.format(CHS[4100093], h)
    else
        if day <= 0 then
            --timeStr = timeStr .. string.format(CHS[4200192], 1)
            -- 小时数小于 0 ，天数小于0，那
            if leftTime < 60 then
                timeStr = CHS[4300224]
            else
                timeStr = string.format(CHS[4300223], math.floor(leftTime / 60))
            end
        end
    end

    return timeStr
end

-- 聚宝斋角色信息       与商品互斥，只有一个
function TradingMgr:MSG_TRADING_ROLE(data)
    TradingMgr.tradingData = {}
    if data.state == 0 then
    else
        if not string.isNilOrEmpty(data.jstr) then
            data.jdata = json.decode(data.jstr)
        end
        TradingMgr.tradingData[1] = data
        TradingMgr.tradingData.count = 1
    end
end

-- 聚宝斋商品信息
function TradingMgr:MSG_TRADING_GOODS_MINE(data)
    if data.count == 0 then
        TradingMgr.tradingGoodsData = nil
    else

        for i = data.count , 1, -1 do
            if data[i] and data[i].para then
                local info = json.decode(data[i].para)
                if not info.sale_time then info.sale_time = 0 end
                for field, value in pairs(info) do
                    data[i][field] = value
                end
            end
        end

        TradingMgr.tradingGoodsData = data

        table.sort(TradingMgr.tradingGoodsData, function(l, r)
            if l.sale_time > r.sale_time then return true end
            if l.sale_time < r.sale_time then return false end
        end)
    end
end

function TradingMgr:MSG_TRADING_GOODS_MINE_REMOVE(data)
    if not TradingMgr.tradingGoodsData or not TradingMgr.tradingGoodsData.count then return end

    local retData = {}
    retData.count = 0
    for i = 1, TradingMgr.tradingGoodsData.count do
        if TradingMgr.tradingGoodsData[i].goods_gid ~= data.goods_gid then
            retData.count = retData.count + 1
            retData[retData.count] = TradingMgr.tradingGoodsData[i]
        end
    end

    if retData.count == 0 then
        TradingMgr.tradingGoodsData = nil
    else
        TradingMgr.tradingGoodsData = retData
    end
end

-- 聚宝斋商品信息
function TradingMgr:MSG_TRADING_GOODS_MINE_UPDATE(data)
    if not TradingMgr.tradingGoodsData then TradingMgr.tradingGoodsData = {} end

    TradingMgr.tradingGoodsData.count = TradingMgr.tradingGoodsData.count or 0

    if data.para then
        local info = json.decode(data.para)
        if not info.sale_time then info.sale_time = 0 end

        for field, value in pairs(info) do
            data[field] = value
        end
    end

    local isAdd = true
    for i = 1, TradingMgr.tradingGoodsData.count do
        if TradingMgr.tradingGoodsData[i].goods_gid == data.goods_gid then
            isAdd = false
            TradingMgr.tradingGoodsData[i] = data
        end
    end

    if isAdd then
        table.insert(TradingMgr.tradingGoodsData, data)
        TradingMgr.tradingGoodsData.count = TradingMgr.tradingGoodsData.count + 1
    end

        table.sort(TradingMgr.tradingGoodsData, function(l, r)
            if l.sale_time > r.sale_time then return true end
            if l.sale_time < r.sale_time then return false end
        end)

end

function TradingMgr:parsingForChar(jsonData, data)
    local tra_data = nil
    if jsonData then tra_data = TradingMgr:changeIndexToFieldByChar(jsonData) end
    if tra_data then    -- 数据正常
        if GameMgr:getGameState() == GAME_RUNTIME_STATE.MAIN_GAME then
            -- 游戏中

            local myUserData = TradingMgr:getTradingUserData()
            -- 如果是我的角色，并且界面在寄售界面，我的货架中，则显示修改
            if myUserData and next(myUserData) and myUserData[1].goods_gid == data.goods_gid then
                TradingMgr:setMyGoodsData(tra_data)

                local dlg = DlgMgr:getDlgByName("JuBaoZhaiStorageDlg")
                if dlg then
                    local dlg2 = DlgMgr:openDlg("UserSellDlg")
                    dlg2:setButtonDisplay(TRADING_STATE.SHOW, TradingMgr:getTradingData()[1].price)
                    return
                end

            end

            local dlg = DlgMgr:getDlgByName("JuBaoUserViewSelfDlg")
            if dlg then
                dlg:setUserData(tra_data, data.goods_gid)
            else
                local tempData = TradingMgr:getTradGoodsData(data.goods_gid, "info")
                if tempData then
                        -- 有可能出现没有数据情况具体见任务 WDSY-26218  by songcw
                    dlg = DlgMgr:openDlg("JuBaoUserViewSelfDlg")
                    dlg:setGid(data.goods_gid)
                    TradingMgr:setPriceInfo(dlg)
                    dlg:setUserData(tra_data, data.goods_gid)
                    TradingMgr:tradingSnapshot(data.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EQUIP)
                end
            end

            mGoodsInfo[data.goods_gid][data.snapshot_type] = tra_data
        else
            -- 其他状态，比如登入
            local loginData = Client.loginCharList
            for i = 1, loginData.count do
            if data.goods_gid == loginData[i].trading_goods_gid then
                    TradingMgr.tradingData = {}
                    local dataTemp = {}
                    dataTemp.change_price_count = loginData[i].trading_cg_price_ct
                    dataTemp.end_time = loginData[i].trading_left_time
                    dataTemp.goods_gid = loginData[i].trading_goods_gid
                    dataTemp.price = loginData[i].trading_price
                    dataTemp.state = loginData[i].trading_state
                    dataTemp.butout_price = loginData[i].trading_buyout_price or 0
                    dataTemp.sell_buy_type = loginData[i].trading_sell_buy_type or 0
                    dataTemp.appointee_name = loginData[i].trading_appointee_name or ""
                    dataTemp.init_price = loginData[i].trading_org_price or ""

                    -- 如果有数据，是指定交易，过期，价格都为一口价
                if dataTemp and next(dataTemp) and (dataTemp.state == TRADING_STATE.TIMEOUT or dataTemp.state == TRADING_STATE.CANCEL) then
                        if dataTemp.sell_buy_type == TRADE_SBT.APPOINT_SELL then
                            dataTemp.price = dataTemp.butout_price
                            dataTemp.sell_buy_type = TRADE_SBT.NONE
                        end
                    end

                    TradingMgr.tradingData[1] = dataTemp
                    TradingMgr.tradingData.count = 1

                    TradingMgr:setMyGoodsData(tra_data)

                    local dlg = DlgMgr:openDlg("UserSellDlg", nil, nil, true)
                    dlg:setData(tra_data)
                    dlg:setButtonDisplay(loginData[i].trading_state, dataTemp.price, loginData[i].trading_left_time)
                    dlg:setGid(loginData[i].gid)
                    dlg:setGoodsId(loginData[i].trading_goods_gid)
                    dlg:setLeftTime(dataTemp.change_price_count)
                end
            end
        end
    end
end

function TradingMgr:parsingForPet(jsonData)

end


function TradingMgr:MSG_TRADING_SNAPSHOT(data)

    if data.isShowCard == 1 then return end

    if not mGoodsInfo[data.goods_gid] then  mGoodsInfo[data.goods_gid] = {} end

    -- WDSY-20443  未飞升宠物，服务器下发数据转json错误，这里做一个容错处理
    if string.match(data.content, ",305:U,") then
        data.content = string.gsub(data.content, ",305:U,", ",305:0,")
    end

    local jsonData
    if pcall(function()
        jsonData = json.decode(data.content)
        end) then
    else
        return
    end

    if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT then
        local goodsType = math.floor(data.goods_type / 100)
        if goodsType == JUBAO_SELL_TYPE.SALE_TYPE_PET then
            local petTab = TradingMgr:changeIndexToFieldByPet(jsonData)
            petTab.raw_name = petTab.name
            petTab["mount_attrib/end_time"] = petTab["mount_flw_time"]
            petTab["mount_attrib/move_speed"] = petTab["mount_move_speed"]
            local pet = DataObject.new()
            pet:absorbBasicFields(petTab)

            mGoodsInfo[data.goods_gid][data.snapshot_type] = pet

            if TradingMgr:getTradingDataByGid(data.goods_gid) then
                if DlgMgr:getDlgByName("JuBaoZhaiStorageDlg") then
                    -- 我的寄售，弹出操作界面
                    local dlg2 = DlgMgr:openDlg("JuBaoPetOperateDlg")
                    local priceInfo = TradingMgr:getTradingDataByGid(data.goods_gid)
                    dlg2:setPet(pet, priceInfo)

                else
                    -- 公示，寄售，查看信息
                    local dlg2 = DlgMgr:openDlg("JuBaoViewPetDlg")
                    dlg2:setPet(pet, data)
                end
            else
                -- 不是自己的商品
                local dlg = DlgMgr:openDlg("JuBaoViewPetDlg")
                dlg:setPet(pet, data)
            end
        elseif goodsType == JUBAO_SELL_TYPE.SALE_TYPE_ROLE then
            TradingMgr:parsingForChar(jsonData, data)
        elseif goodsType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON
            or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then
            local equipTemp = TradingMgr:changeIndexToFieldByEquip(jsonData)
            local equip = TradingMgr:getEquipByData(equipTemp)
            local priceInfo = TradingMgr:getTradingDataByGid(data.goods_gid)
            if priceInfo then
                -- 如果是我的商品
                local dlg = DlgMgr:getDlgByName("JuBaoZhaiStorageDlg")
                if dlg then
                    -- 如果是我的货架（不在对话框内监听，是因为可能从聊天中打开！）
                    local dlg2 = DlgMgr:openDlg("JuBaoEquipOperateDlg")
                    dlg2:setDlgData(equip, priceInfo)
                else

                    -- 要区分两个界面，一个为指定交易的
                    -- 我也很无奈，其他的都是一个界面，就装备要区分
                    -- 做了聚宝-拍卖，更尴尬了。拍卖公示显示JuBaoViewEquipDlg，寄售显示JuBaoViewDesignatedEquipDlg界面！！！！！我能怎么办？我也很无奈
                    if priceInfo.sell_buy_type == TRADE_SBT.AUCTION then
                        if priceInfo.state == TRADING_STATE.AUCTION_SHOW then
                            local dlg2 = DlgMgr:openDlg("JuBaoViewEquipDlg")
                            dlg2:setDlgData(equip, data, priceInfo, priceInfo)
						-- 测试说，当前 AUCTION_PAYMENT 状态的时候也打开界面，据说下个版本要改成不打开！！！！
                        elseif priceInfo.state == TRADING_STATE.AUCTION or priceInfo.state == TRADING_STATE.AUCTION_PAYMENT then
                            local dlg2 = DlgMgr:openDlg("JuBaoViewDesignatedEquipDlg")
                            dlg2:setDlgData(equip, data, priceInfo)
                        end
                    else
                        if priceInfo.appointee_name ~= "" then
                            local dlg2 = DlgMgr:openDlg("JuBaoViewDesignatedEquipDlg")
                            dlg2:setDlgData(equip, data, priceInfo)
                        else
                            local dlg2 = DlgMgr:openDlg("JuBaoViewEquipDlg")
                            dlg2:setDlgData(equip, data, priceInfo)
                        end
                    end
                end
            else
                -- 要区分两个界面，一个为指定交易的
                -- 我也很无奈，其他的都是一个界面，就装备要区分
                local tempInfo = TradingMgr:getTradGoodsData(data.goods_gid, "info")
                if not tempInfo then return end
                local priceInfo = tempInfo
                if priceInfo.sell_buy_type == TRADE_SBT.AUCTION then
                    if priceInfo.state == TRADING_STATE.AUCTION_SHOW then
                        local dlg2 = DlgMgr:openDlg("JuBaoViewEquipDlg")
                        dlg2:setDlgData(equip, data, priceInfo)
                    elseif priceInfo.state == TRADING_STATE.AUCTION then
                        local dlg2 = DlgMgr:openDlg("JuBaoViewDesignatedEquipDlg")
                        dlg2:setDlgData(equip, data, priceInfo)
                    end
                else
                    if tempInfo.appointee_name ~= "" then
                        local dlg2 = DlgMgr:openDlg("JuBaoViewDesignatedEquipDlg")
                        dlg2:setDlgData(equip, data, tempInfo)
                    else
                        local dlg2 = DlgMgr:openDlg("JuBaoViewEquipDlg")
                        dlg2:setDlgData(equip, data, tempInfo)
                    end
                end
            end
        elseif goodsType == JUBAO_SELL_TYPE.SALE_TYPE_CASH then
            local goodsInfo = TradingMgr:getTradGoodsData(data.goods_gid)
            local dlg = DlgMgr:openDlg("JuBaoViewCashDlg")
            dlg:setData(goodsInfo.info)
        end
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_EQUIP then
        local equipTra
        if pcall(function()
            equipTra = json.decode(data.content)
        end) then
        end

        local equipData = {}
        if equipTra then
            for pos, equipStr in pairs(equipTra) do
                local equip = TradingMgr:changeIndexToFieldByEquip(equipStr)

                -- 1-40 位置中，服务器没有下发 fasion_type，客户端要兼容下
                -- 1-40 位置中，服务器没有下发 fasion_type，客户端要兼容下
                if equip.item_type == ITEM_TYPE.CUSTOM or equip.item_type == ITEM_TYPE.EFFECT or equip.item_type == ITEM_TYPE.FOLLOW_ELF then
                    equip.fasion_type = FASION_TYPE.FASION
                end

                -- 除时装内限时的要排除
                if InventoryMgr:isTimeLimitedItem(equip) and equip.fasion_type ~= FASION_TYPE.FASION then
                else
                    equipData[pos] = TradingMgr:getEquipByData(equip)
                    equipData[pos].pos = nil
                end
            end
        end

        mGoodsInfo[data.goods_gid][data.snapshot_type] = equipData
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_BAG                       -- 背包
      or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_HOME_STORE                     -- 居所
      or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_STORE                     -- 仓库
      or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_CARD_STORE
      or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_FURNITURE_STORE then           -- 变身卡卡套
        local equipTra
        if pcall(function()
            equipTra = json.decode(data.content)
        end) then
        end

        local equipData = {}
        if equipTra then
            for pos, equipStr in pairs(equipTra) do
				local equip = TradingMgr:changeIndexToFieldByEquip(equipStr)
                if InventoryMgr:isTimeLimitedItem(equip) and equip.fasion_type ~= FASION_TYPE.FASION then
                else
                    if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_FURNITURE_STORE then
                        -- 家具
                        local furnInfo = HomeMgr:getFurnitureInfo(equip.name)
                        if furnInfo.furniture_type ~= CHS[5400136] then
                            -- 种植物不显示
                            local place = string.match(furnInfo.furniture_type, "(.+)-.+")
                            equip.place = place
                            table.insert(equipData, TradingMgr:getEquipByData(equip))
                        end
                    else
                        table.insert(equipData, TradingMgr:getEquipByData(equip))
                    end
                end
            end
        end

        if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_FURNITURE_STORE then
            -- 家具
            table.sort(equipData, function(l, r)
                local lOrder = HomeMgr:getFurnOrderByPlace(l.place)
                local rOrder = HomeMgr:getFurnOrderByPlace(r.place)
                if lOrder < rOrder then return true end
                if lOrder > rOrder then return false end
                if l.icon < r.icon then return true end
                if l.icon > r.icon then return false end
            end)
        else
            table.sort(equipData, function(l, r)
                if l.pos < r.pos then return true end
                if l.pos > r.pos then return false end
            end)
        end

        mGoodsInfo[data.goods_gid][data.snapshot_type] = equipData
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_PET_BAG or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_PET_STORE or data.snapshot_type == TRAD_SNAPSHOT.TRAD_SNAPSHOT_HOUSE_PET_STORE then
        local petData = {}
        for pos, equipStr in pairs(jsonData) do
            local pet = TradingMgr:changeIndexToFieldByPet(equipStr)
            if not InventoryMgr:isTimeLimitedItem(pet) then
                pet.raw_name = pet.name
                pet["mount_attrib/end_time"] = pet["mount_flw_time"]
                pet["mount_attrib/move_speed"] = pet["mount_move_speed"]
                table.insert(petData, pet)
            end
        end

        table.sort(petData, function(l, r)
            if l.intimacy > r.intimacy then return true end
            if l.intimacy < r.intimacy then return false end
        end)

        mGoodsInfo[data.goods_gid][data.snapshot_type] = petData
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_GUARD then
        local preData
        if pcall(function()
            preData = json.decode(data.content)
        end) then
        end
        local guardData = {}
        if preData then
            for pos, item in pairs(preData) do
                local guard = TradingMgr:changeIndexToFieldByGuard(item)
                table.insert(guardData, guard)
            end
        end

        table.sort(guardData, function(l, r)
            if l.rank > r.rank then return true end
            if l.rank < r.rank then return false end
            if l.polar < r.polar then return true end
            if l.polar > r.polar then return false end
        end)

        mGoodsInfo[data.goods_gid][data.snapshot_type] = guardData
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_CHILD then
        local preData
        if pcall(function()
            preData = json.decode(data.content)
        end) then
        end
        local childData = {}
        if preData then
            for pos, item in pairs(preData) do
                local child = TradingMgr:changeIndexToFieldByChild(item)
                table.insert(childData, child)
            end
        end

        table.sort(childData, function(l, r)
            if l.intimacy > r.intimacy then return true end
            if l.intimacy < r.intimacy then return false end
        end)

        mGoodsInfo[data.goods_gid][data.snapshot_type] = childData
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_FASION
        or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_CUSTOM
        or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_EFFECT
        or data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_FOLLOW_PET then
        local equipTra
        if pcall(function()
            equipTra = json.decode(data.content)
        end) then
        end

        local equipData = {}
        if equipTra then
            for pos, equipStr in pairs(equipTra) do
                local equip = TradingMgr:changeIndexToFieldByEquip(equipStr)

                -- 1-40 位置中，服务器没有下发 fasion_type，客户端要兼容下
                if equip.item_type == ITEM_TYPE.CUSTOM or equip.item_type == ITEM_TYPE.EFFECT or equip.item_type == ITEM_TYPE.FOLLOW_ELF then
                    equip.fasion_type = FASION_TYPE.FASION
                end

                -- 除时装内限时的要排除
                if InventoryMgr:isTimeLimitedItem(equip) and equip.fasion_type ~= FASION_TYPE.FASION then
                else
                    equipData[pos] = TradingMgr:getEquipByData(equip)

                end
            end
        end

        mGoodsInfo[data.goods_gid][data.snapshot_type] = equipData

    end
end

function TradingMgr:getTradGoodsData(gid, snapshot_type)
    if mGoodsInfo[gid] and not snapshot_type then
        return mGoodsInfo[gid]
    end

    if mGoodsInfo[gid] and mGoodsInfo[gid][snapshot_type] then
        return mGoodsInfo[gid][snapshot_type]
    end
end

function TradingMgr:setTradGoodsData(data)
    if not mGoodsInfo[data.goods_gid] then mGoodsInfo[data.goods_gid] = {} end

    mGoodsInfo[data.goods_gid]["info"] = data
end

function TradingMgr:cleanDataByGid(goods_gid)
    mGoodsInfo[goods_gid] = {}
end

function TradingMgr:MSG_TRADING_SNAPSHOT_ME(data)

end

-- 获取排序后的称谓
function TradingMgr:getTitleByLenSort(appellation)
    if not appellation then return {} end

    local retTitles = {}
    for _, title in pairs(appellation) do
        local data = {title = title, len = gf:getTextLength(title)}
        table.insert(retTitles, data)
    end

    table.sort(retTitles, function(l, r)
        if l.len < r.len then return true end
        if l.len > r.len then return false end
        return false
    end)

    return retTitles
end

-- 获取当前他人金钱订单信息
function TradingMgr:getOtherCashData()
    return self.otherCashData
end

-- 获取金钱出手标准价
function TradingMgr:getCashStandardPrice()
    return self.cashStandardPrice or 0
end

-- 获取开服后聚宝斋是否可以出售金钱
function TradingMgr:getIsCanSellCash()
    return self.isCanSellCash == 1
end

-- 获取开服后聚宝斋可以出售金钱的天数
function TradingMgr:getSellCashAfterDays()
    return self.sellCashAfterDays
end

-- 获取聚宝斋是否开启
function TradingMgr:getTradingEnable()
    return self.tradingEnable
end

-- 服务器告知客户端聚宝斋是否开启
function TradingMgr:MSG_TRADING_ENABLE(data)
    self.tradingEnable = (data.enable == 1)
    self.sellCashAfterDays = data.sellCashAfterDays
    self.isCanSellCash = data.isSellCash
    self.cashRecommendPrice = data.recommendPrice or 0

    TradingMgr.BUY_URL = data.url
end

-- 通知客户端出售金钱的信息,公示物品
function TradingMgr:MSG_TRADING_SELL_CASH(data)
    self.cashStandardPrice = data.standardPrice

    local showData = {}
    for i = 1, data.count do
        local info = json.decode(data.goods[i].para)
        if not info.sale_time then info.sale_time = 0 end
        for field, value in pairs(info) do
            data.goods[i][field] = value
        end

        data.goods[i].cash = tonumber(data.goods[i].goods_name)
        data.goods[i].unit_price = math.floor(data.goods[i].cash / data.goods[i].price)
        data.goods[i].insider_level = info.insider_level or 0
        table.insert(showData, data.goods[i])
    end

    self.otherCashData = showData
end

-- 服务器通知客户端商品数据
function TradingMgr:MSG_TRADING_GOODS_LIST(data)
    if data.list_type == TradingMgr.LIST_TYPE.SALE_LIST then
        if data.is_begin == 1 then  --  等于1的情况，为第一页，清空原有数据
            jubao_sell_data[data.goods_type] = {}
        end

        for i = 1, data.count do
            local info = json.decode(data.goods[i].para)
            if not info.sale_time then info.sale_time = 0 end
            for field, value in pairs(info) do
                data.goods[i][field] = value
            end


			data.goods[i].isDecode = true

            if data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
                data.goods[i].cash = math.floor(tonumber(data.goods[i].goods_name))
                data.goods[i].unit_price = math.floor(tonumber(data.goods[i].goods_name) / tonumber(data.goods[i].price))
            end

            data.goods[i].insider_level = info.insider_level or 0
            table.insert(jubao_sell_data[data.goods_type], data.goods[i])
        end
    elseif data.list_type == TradingMgr.LIST_TYPE.SHOW_LIST then
        if data.is_begin == 1 then  --  等于1的情况，为第一页，清空原有数据
            jubao_public_data[data.goods_type] = {}
        end

        for i = 1, data.count do
            local info = json.decode(data.goods[i].para)
            for field, value in pairs(info) do
                data.goods[i][field] = value
            end

			data.goods[i].isDecode = true

            if data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
                data.goods[i].cash = math.floor(tonumber(data.goods[i].goods_name))
                data.goods[i].unit_price = math.floor(tonumber(data.goods[i].goods_name) / tonumber(data.goods[i].price))
            end

            data.goods[i].insider_level = info.insider_level or 0
            table.insert(jubao_public_data[data.goods_type], data.goods[i])
        end
    else
        if not jubao_vendue_data[data.list_type] then jubao_vendue_data[data.list_type] = {} end
        if data.is_begin == 1 then  --  等于1的情况，为第一页，清空原有数据
            jubao_vendue_data[data.list_type][data.goods_type] = {}
        end

        for i = 1, data.count do
            local info = json.decode(data.goods[i].para)
            for field, value in pairs(info) do
                data.goods[i][field] = value
            end

			data.goods[i].isDecode = true

            if data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
                data.goods[i].cash = math.floor(tonumber(data.goods[i].goods_name))
                data.goods[i].unit_price = math.floor(tonumber(data.goods[i].goods_name) / tonumber(data.goods[i].price))
            end

            data.goods[i].insider_level = info.insider_level or 0
            table.insert(jubao_vendue_data[data.list_type][data.goods_type], data.goods[i])
        end
    end

    --if data.goods[i].good

    if data.is_end == 1 then
        if data.select_gid ~= "" and data.goods and data.goods[1] then
            local dlg
            if data.goods[1].sell_buy_type == TRADE_SBT.AUCTION then
                dlg = DlgMgr:openDlg("JuBaoZhaiVendueDlg")
            else
                dlg = DlgMgr:openDlg("JuBaoZhaiSellDlg")
            end

            DlgMgr:reorderDlgByName(dlg.name)
            DlgMgr:reorderDlgByName("JuBaoZhaiTabDlg")

            local list = {}
            list[1] = TradingMgr.LIST_TYPE_NAME[data.list_type]
            list[2] = math.floor(data.goods_type / 100)
            list[3] = data.goods_type % 100
            list[4] = data.select_gid
            dlg:onDlgOpened(list)
            dlg:MSG_TRADING_GOODS_LIST(data)
        else
            DlgMgr:sendMsg("JuBaoZhaiSellDlg", "MSG_TRADING_GOODS_LIST", data)
            DlgMgr:sendMsg("JuBaoZhaiVendueDlg", "MSG_TRADING_GOODS_LIST", data)
        end
    end
end

-- 获取排序方式
function TradingMgr:getSortFun(type, menuType)
    local retTab = {}

    -- 价格升序
    local function sortPriceUp(list)
        table.sort(list, function(l, r)

            local retPriceL = l.price
            if l.sell_buy_type == 1 then
                retPriceL = l.butout_price
            end

            local retPriceR = r.price
            if r.sell_buy_type == 1 then
                retPriceR = r.butout_price
            end


            if retPriceL < retPriceR then return true end
            if retPriceL > retPriceR then return false end
            if (l.tao or 0) > (r.tao or 0) then return true end
            if (l.tao or 0) < (r.tao or 0) then return false end
            if l.end_time < r.end_time then return true end
            if l.end_time > r.end_time then return false end
            return false
        end)
    end

    -- 价格降序
    local function sortPriceDown(list)
        table.sort(list, function(l, r)
            local retPriceL = l.price
            if l.sell_buy_type == 1 then
                retPriceL = l.butout_price
            end

            local retPriceR = r.price
            if r.sell_buy_type == 1 then
                retPriceR = r.butout_price
            end

            if retPriceL > retPriceR then return true end
            if retPriceL < retPriceR then return false end
            if (l.tao or 0) > (r.tao or 0) then return true end
            if (l.tao or 0) < (r.tao or 0) then return false end
            if l.end_time < r.end_time then return true end
            if l.end_time > r.end_time then return false end
            return false
        end)
    end

    -- 剩余时间升序
    local function sortTimeUp(list)
        table.sort(list, function(l, r)
            if l.end_time < r.end_time then return true end
            if l.end_time > r.end_time then return false end
            return false
        end)
    end

    -- 剩余时间降序
    local function sortTimeDown(list)
        table.sort(list, function(l, r)
            if l.end_time > r.end_time then return true end
            if l.end_time < r.end_time then return false end
            return false
        end)
    end

    -- 主条件等级升序  道行升序
    local function sortLevelUpTao(list)
        table.sort(list, function(l, r)
            if l.level < r.level then return true end
            if l.level > r.level then return false end
            if l.tao > r.tao then return true end
            if l.tao < r.tao then return false end
            return false
        end)
    end

    -- 主条件等级降序 道行升序
    local function sortLevelDownTao(list)
        table.sort(list, function(l, r)
            if l.level > r.level then return true end
            if l.level < r.level then return false end
            if l.tao > r.tao then return true end
            if l.tao < r.tao then return false end
            return false
        end)
    end

    -- 武学升序
    local function sortMartialUp(list)
        table.sort(list, function(l, r)
            if l.martial < r.martial then return true end
            if l.martial > r.martial then return false end
            return false
        end)
    end

    -- 武学降序
    local function sortMartialDown(list)
        table.sort(list, function(l, r)
            if l.martial > r.martial then return true end
            if l.martial < r.martial then return false end
            return false
        end)
    end

    -- 阶位升序
    local function sortCapacityUp(list)
        table.sort(list, function(l, r)
            if l.capacity_level < r.capacity_level then return true end
            if l.capacity_level > r.capacity_level then return false end
            if l.default_capacity_level > r.default_capacity_level then return true end
            if l.default_capacity_level < r.default_capacity_level then return false end
            return false
        end)
    end

    -- 阶位降序
    local function sortCapacityDown(list)
        table.sort(list, function(l, r)
            if l.capacity_level > r.capacity_level then return true end
            if l.capacity_level < r.capacity_level then return false end
            if l.default_capacity_level > r.default_capacity_level then return true end
            if l.default_capacity_level < r.default_capacity_level then return false end
            return false
        end)
    end

	-- 改造降序   完美度
    local function sortEquipLevelDown(list)
        table.sort(list, function(l, r)
            if l.level > r.level then return true end
            if l.level < r.level then return false end
            if l.rebuild_level > r.rebuild_level then return true end
            if l.rebuild_level < r.rebuild_level then return false end
            if l.perfect_percent > r.perfect_percent then return true end
            if l.perfect_percent < r.perfect_percent then return false end
            return false
        end)
    end

    -- 改造升序   完美度
    local function sortEquipLevelUp(list)
        table.sort(list, function(l, r)
            if l.level < r.level then return true end
            if l.level > r.level then return false end
            if l.rebuild_level > r.rebuild_level then return true end
            if l.rebuild_level < r.rebuild_level then return false end
            if l.perfect_percent > r.perfect_percent then return true end
            if l.perfect_percent < r.perfect_percent then return false end
            return false
        end)
    end

    -- 法宝升序
    local function sortArtifactLevelUp(list)
        table.sort(list, function(l, r)
            if l.level < r.level then return true end
            if l.level > r.level then return false end
            if (l.artifact_skill_order or 100) < (r.artifact_skill_order or 100) then return true end
            if (l.artifact_skill_order or 100) > (r.artifact_skill_order or 100) then return false end
            return false
        end)
    end

    -- 法宝降序
    local function sortArtifactLevelDown(list)
        table.sort(list, function(l, r)
            if l.level > r.level then return true end
            if l.level < r.level then return false end
            if (l.artifact_skill_order or 100) < (r.artifact_skill_order or 100) then return true end
            if (l.artifact_skill_order or 100) > (r.artifact_skill_order or 100) then return false end
            return false
        end)
    end

     -- 首饰   升序
    local function sortJewelryLevelUp(list)
        table.sort(list, function(l, r)
            if l.level < r.level then return true end
            if l.level > r.level then return false end
            return false
        end)
    end

    -- 首饰 降序
    local function sortJewelryLevelDown(list)
        table.sort(list, function(l, r)
            if l.level > r.level then return true end
            if l.level < r.level then return false end
            return false
        end)
    end

    -- 金钱单价升序  数量升序
    local function sortMoneyUp(list)
        table.sort(list, function(l, r)
            if l.unit_price < r.unit_price then return true end
            if l.unit_price > r.unit_price then return false end
            if l.cash > r.cash then return true end
            if l.cash < r.cash then return false end
            return false
        end)
    end

    -- 金钱单价降序  数量升序
    local function sortMoneyDown(list)
        table.sort(list, function(l, r)
            if l.unit_price > r.unit_price then return true end
            if l.unit_price < r.unit_price then return false end
            if l.cash > r.cash then return true end
            if l.cash < r.cash then return false end
            return false
        end)
    end

    -- 是否坐骑
    local function isRidePet(pet)
        return pet.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_YULING
            or pet.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINGGUAI
    end

    -- 宠物升序
    local function sortPetUp(list)
        table.sort(list, function(l, r)
            if not isRidePet(l) and isRidePet(r) then return true end
            if isRidePet(l) and not isRidePet(r) then return false end

            if not isRidePet(l) and not isRidePet(r) then
                if l.martial < r.martial then return true end
                if l.martial > r.martial then return false end
            elseif isRidePet(l) and isRidePet(r) then
                if l.capacity_level < r.capacity_level then return true end
                if l.capacity_level > r.capacity_level then return false end
                if l.default_capacity_level > r.default_capacity_level then return true end
                if l.default_capacity_level < r.default_capacity_level then return false end
            end

            return false
        end)
    end

    -- 宠物降序
    local function sortPetDown(list)
        table.sort(list, function(l, r)
            if not isRidePet(l) and isRidePet(r) then return true end
            if isRidePet(l) and not isRidePet(r) then return false end

            if not isRidePet(l) and not isRidePet(r) then
                if l.martial > r.martial then return true end
                if l.martial < r.martial then return false end
            elseif isRidePet(l) and isRidePet(r) then
                if l.capacity_level > r.capacity_level then return true end
                if l.capacity_level < r.capacity_level then return false end
                if l.default_capacity_level > r.default_capacity_level then return true end
                if l.default_capacity_level < r.default_capacity_level then return false end
            end

            return false
        end)
    end

    if type == 1 then                   -- 价格升序
        return sortPriceUp
    elseif type == 2 then               -- 价格降序
        return sortPriceDown
    elseif type == 3 then               -- 信息升序
        -- 金钱 按照单价升序，数量降序
        if menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
            return sortMoneyUp
        end

        -- 角色 按照等级升序，道行降序
        if menuType >= TradingMgr.GOODS_TYPE.SALE_TYPE_USER_METAL and menuType <= TradingMgr.GOODS_TYPE.SALE_TYPE_USER_EARTH then
            return sortLevelUpTao
        end

        -- 普通 变异 其他按武学
        if menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_NORMAL
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_ELITE
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINIAN
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_OTHER
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_EPIC then
            return sortMartialUp
        end

        -- 精怪、御灵按阶位
        if menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_YULING
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINGGUAI then
            return sortCapacityUp
        end

        if menuType == JUBAO_SELL_TYPE.SALE_TYPE_PET then
            return sortPetUp
        end

        local bigType = math.floor(menuType / 100)
        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON or bigType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR or menuType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON or menuType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR then
            return sortEquipLevelUp
        end

        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT or menuType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then
            -- 若为法宝，按照等级，法宝技能排序
            return sortArtifactLevelUp
        end

        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY or menuType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY then
            -- 若为首饰，按等级
            return sortJewelryLevelUp
        end

    elseif type == 4 then               -- 信息降序
        -- 金钱 按照单价降序，数量降序
        if menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
            return sortMoneyDown
        end

        -- 角色 按照等级降序，道行降序
        if menuType >= TradingMgr.GOODS_TYPE.SALE_TYPE_USER_METAL and menuType <= TradingMgr.GOODS_TYPE.SALE_TYPE_USER_EARTH then
            return sortLevelDownTao
        end

        -- 普通 变异 其他按武学
        if menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_NORMAL
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_ELITE
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINIAN
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_OTHER
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_EPIC then
            return sortMartialDown
        end

        -- 精怪、御灵按阶位
        if menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_YULING
            or menuType == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINGGUAI then
            return sortCapacityDown
        end

        if menuType == JUBAO_SELL_TYPE.SALE_TYPE_PET then
            return sortPetDown
        end

        local bigType = math.floor(menuType / 100)
        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON or bigType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR or menuType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON or menuType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR then
            return sortEquipLevelDown
        end

        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT or menuType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then
            -- 若为法宝，按照等级，法宝技能排序
            return sortArtifactLevelDown
        end

        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY or menuType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY then
            -- 若为首饰，按等级
            return sortJewelryLevelDown
        end

    elseif type == 5 then               -- 时间升序
        return sortTimeUp
    elseif type == 6 then               -- 时间降序
        return sortTimeDown
    end
end


function TradingMgr:getFavoriteInfo()
    return favorite_data
end

-- 收藏列表的gid
function TradingMgr:MSG_TRADING_FAVORITE_GIDS(data)
    favorite_data = {}
    for i = 1, data.count do
        favorite_data[data[i]] = 1
    end

    favorite_data.count = data.count
end

-- 获取人物技能
function TradingMgr:getUserSkillByData(data, panelNameMap)
    local hasSkills = {}
    -- 从data中取
    if data["skills"] then
        -- 力破千钧
        if data.skills.skill_J and data.skills.skill_J.skill_J_1 and data.skills.skill_J.skill_J_1.level > 0 then
            hasSkills[panelNameMap[1]] = {}
            table.insert(hasSkills[panelNameMap[1]], data.skills.skill_J.skill_J_1)
        end

        --B
        if data.skills.skill_B then
            local skillTable = {}
            for i = 1, 5 do
                if data.skills.skill_B["skill_B_" .. i] and data.skills.skill_B["skill_B_" .. i].level > 0 then
                    table.insert(skillTable, data.skills.skill_B["skill_B_" .. i])
                end
            end
            hasSkills[panelNameMap[2]] = skillTable
        end

        -- c
        if data.skills.skill_C then
            local skillTable = {}
            for i = 1, 5 do
                if data.skills.skill_C["skill_C_" .. i] and data.skills.skill_C["skill_C_" .. i].level > 0 then
                    table.insert(skillTable, data.skills.skill_C["skill_C_" .. i])
                end
            end
            hasSkills[panelNameMap[3]] = skillTable
        end

        -- D
        if data.skills.skill_D then
            local skillTable = {}
            for i = 1, 5 do
                if data.skills.skill_D["skill_D_" .. i] and data.skills.skill_D["skill_D_" .. i].level > 0 then
                    table.insert(skillTable, data.skills.skill_D["skill_D_" .. i])
                end
            end
            hasSkills[panelNameMap[4]] = skillTable
        end

        -- F
        if data.skills.skill_F then
            local skillTable = {}
            for i = 1, 5 do
                if data.skills.skill_F["skill_F_" .. i] and data.skills.skill_F["skill_F_" .. i].level > 0 then
                    table.insert(skillTable, data.skills.skill_F["skill_F_" .. i])
                end
            end
            hasSkills[panelNameMap[5]] = skillTable
        end
    end

    -- 应该有的
    local skillInfo = {}
    -- 力破千钧
    local phySkill = SkillMgr:getSkillsByClass(SKILL.CLASS_PHY, SKILL.SUBCLASS_J)
    if phySkill then
        skillInfo[panelNameMap[1]] = phySkill             -- InfoPanel_8 对应的为力破技能！！
    end

    -- B
    local bSkill = SkillMgr:getSkillsByPolarAndSubclass(data.polar, SKILL.SUBCLASS_B)
    if bSkill and next(bSkill) then
        skillInfo[panelNameMap[2]] = bSkill
    end

    -- C
    local cSkill = SkillMgr:getSkillsByPolarAndSubclass(data.polar, SKILL.SUBCLASS_C)
    if cSkill and next(cSkill) then
        skillInfo[panelNameMap[3]] = cSkill
    end

    -- D
    local dSkill = SkillMgr:getSkillsByPolarAndSubclass(data.polar, SKILL.SUBCLASS_D)
    if dSkill and next(dSkill) then
        skillInfo[panelNameMap[4]] = dSkill
    end

    local fSkill = SkillMgr:getSkillsByClass(SKILL.CLASS_PUBLIC, SKILL.SUBCLASS_F)
    if fSkill and next(fSkill) then
        skillInfo[panelNameMap[5]] = fSkill
    end

    return skillInfo, hasSkills
end


-- 由于服务器下发的和原本的装备格式不一样，做一个转换
function TradingMgr:getEquipByData(data)
    local equip = gf:deepCopy(data)

    equip.extra = {}

    -- 粉属性
    if data.prop2 then
        for field, info in pairs(data.prop2) do
            local pinkStr = string.format("%s_%d", field, Const.FIELDS_EXTRA2)
            equip.extra[pinkStr] = info.val

            local pinkComplete = string.format("%s_%d", field, Const.PINK_COMPLETION)
            equip.extra[pinkComplete] = info["degree_32"]

            -- 首饰属性顺序 首饰重复属性 JEWELRY_BLUE_ATTRIB_EX == 3，与粉属性重复，所以在这里加
            local orderKey = string.format("%s_%d", field, Const.JEWELRY_BLUE_ORDER_EX)
            equip.extra[orderKey] = info["order"] or 1
        end
    end

    -- 黄属性
    if data.prop3 then
        for field, info in pairs(data.prop3) do
            local yellowStr = string.format("%s_%d", field, Const.FIELDS_PROP3)
            equip.extra[yellowStr] = info.val

            local goldComplete = string.format("%s_%d", field, Const.GOLD_COMPLETION)
            equip.extra[goldComplete] = info["degree_32"]

        end
    end

    -- 蓝属性
    if data.prop then
        for field, info in pairs(data.prop) do
            local blueStr = string.format("%s_%d", field, Const.FIELDS_EXTRA1)
            equip.extra[blueStr] = info.val

            local blueComplete = string.format("%s_%d", field, Const.BLUE_COMPLETION)
            equip.extra[blueComplete] = info["degree_32"]

            -- 首饰属性顺序
            local orderKey = string.format("%s_%d", field, Const.JEWELRY_BLUE_ORDER)
            equip.extra[orderKey] = info["order"] or 1
        end
    end

    -- 绿属性
    if data.prop4 then
        for field, info in pairs(data.prop4) do
            local greenStr = string.format("%s_%d", field, Const.FIELDS_PROP4)
            equip.extra[greenStr] = info.val
        end
    end

    -- 套装
    if data.prop_suit then
        for field, info in pairs(data.prop_suit) do
            local greenDarkStr = string.format("%s_%d", field, Const.FIELDS_SUIT)
            equip.extra[greenDarkStr] = info.val
        end
    end

    -- 基础属性
    if data.basic_prop then
        for field, info in pairs(data.basic_prop) do
            if field == "power" or field == "phy_power" then
                local basicStr = string.format("%s_%d", "phy_power", Const.FIELDS_NORMAL)
                equip.extra[basicStr] = info.val

                if info.is_extra == 1 then
                    equip.extra["phy_power_isTotal"] = 1
                end
            else
                local basicStr = string.format("%s_%d", field, Const.FIELDS_NORMAL)
                equip.extra[basicStr] = info.val

                if info.is_extra == 1 then
                    equip.extra[field .. "_isTotal"] = 1
                end
            end


        end
    end

    -- 改造
    if data.prop_rebuild then
        for field, info in pairs(data.prop_rebuild) do

            if field == "power" or field == "phy_power" then
                local rebuildStr = string.format("%s_%d", "phy_power", Const.FIELDS_REBUILD)
                equip.extra[rebuildStr] = info.val
            else
                local basicStr = string.format("%s_%d", field, Const.FIELDS_REBUILD)
                equip.extra[basicStr] = info.val
            end
        end
    end

    equip.unidentified = equip.unidentified or 0

	-- 法宝类型
    if data.equip_type == EQUIP_TYPE.ARTIFACT then
        -- 法宝相性
        equip.item_polar = data.artifact_polar

        -- 法宝亲密
        equip.intimacy = data.artifact_intimacy

        -- 法宝灵气
        equip.nimbus = data.artifact_nimbus

        -- 法宝道法
        equip.exp = data.artifact_exp

        -- 法宝道法升级所需值
        equip.exp_to_next_level = data.artifact_exp_next

        -- 法宝特殊技能名称
        equip.extra_skill = data.artifact_extra_skill

        -- 法宝特殊技能等级
        equip.extra_skill_level = data.artifact_extra_skill_level
    end

    -- 婚服相关
    equip.alias = data.alias or ""

    return equip
end

-- 该接口用于，传入寄售类型，返回是否显示普通交易类型
-- 当前用于，TRADE_SBT.APPOINT_CONTINUE 和 TRADE_SBT.NONE 需要显示普通交易类型
function TradingMgr:isDisplayNormal(sell_buy_type)
    if sell_buy_type == TRADE_SBT.APPOINT_CONTINUE or sell_buy_type == TRADE_SBT.NONE then
        return true
    else
        return false
    end
end

-- 价格信息
function TradingMgr:setPriceInfo(dlg, data)
    local function setInfo(data)
        local cashText = gf:getArtFontMoneyDesc(tonumber(data.price))
        dlg:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23)
        dlg:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23)

        -- 剩余时间
        dlg:setLabelText("LeftLabel_2", TradingMgr:getLeftTime(data.end_time - gf:getServerTime()))
        -- 指定交易时间
        dlg:setLabelText("LeftLabel_2", TradingMgr:getLeftTime(data.end_time - gf:getServerTime()), "DesignatedSellPanel")


        if tonumber(data.state) == TRADING_STATE.SHOW  then
            dlg:setLabelText("LeftLabel", CHS[4300194])
            dlg:setLabelText("LeftLabel", CHS[4300194], "DesignatedSellPanel")
        elseif tonumber(data.state) == TRADING_STATE.SALE then
            dlg:setLabelText("LeftLabel", CHS[4300195])
            dlg:setLabelText("LeftLabel", CHS[4300195], "DesignatedSellPanel")
        end

        dlg:setCtrlVisible("DesignatedSellPanel", data.sell_buy_type == TRADE_SBT.APPOINT_SELL)
        dlg:setCtrlVisible("CommonSellPanel", TradingMgr:isDisplayNormal(data.sell_buy_type))

        dlg:setCtrlVisible("VendueSellPanel", false)
        dlg:setCtrlVisible("VenduePublicPanel", false)

        if data.sell_buy_type == TRADE_SBT.APPOINT_SELL then
            -- 指定交易玩家
            dlg:setLabelText("ValueLabel", data.appointee_name, "DesignatedUserPanel")

            -- 指定交易价格
            dlg:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, data.price, false, LOCATE_POSITION.MID, 23, "DesignatedSellPanel")
            dlg:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, "DesignatedSellPanel")

            -- 一口价
            dlg:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, data.butout_price, false, LOCATE_POSITION.MID, 23, "FixedPricePanel")
            dlg:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, "FixedPricePanel")
        elseif data.sell_buy_type == TRADE_SBT.AUCTION then
            if data.state == TRADING_STATE.AUCTION_SHOW then
                if dlg.name == "JuBaoEquipOperateDlg" or dlg.name == "JuBaoPetOperateDlg" then
                    local panel2 = dlg:getControl("LeftTimePanel", nil, "VenduePanel")
                    dlg:setLabelText("PublicLabel_1", CHS[4300490], panel2) -- 拍卖寄售期，
                    dlg:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(data.end_time - gf:getServerTime()), panel2)

                    dlg:setLabelText("SaleLabel_1", CHS[4300491], panel2) -- 拍卖寄售期，
                    dlg:setLabelText("SaleLabel_2", string.format(CHS[4200520], 3), panel2)
                else
                    dlg:setCtrlVisible("VenduePublicPanel", true)
                    dlg:setLabelText("LeftLabel", CHS[4300194], "VenduePublicPanel")
                    dlg:setLabelText("LeftLabel_2", TradingMgr:getLeftTime(data.end_time - gf:getServerTime()), "VenduePublicPanel")
                end


                local panel = dlg:getControl("VenduePublicPanel")


                dlg:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23, panel)
                dlg:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, panel)

            else
                dlg:setCtrlVisible("VendueSellPanel", true)
                local vendueSellePanel = dlg:getControl("VendueSellPanel")
                if not vendueSellePanel then vendueSellePanel = dlg:getControl("VenduePublicPanel") end

                -- 剩余时间

                if dlg.name == "JuBaoEquipOperateDlg" or dlg.name == "JuBaoPetOperateDlg" then
                    local panel2 = dlg:getControl("LeftTimePanel", nil, "VenduePanel")
                    dlg:setLabelText("PublicLabel_1", CHS[4300490], panel2) -- 拍卖寄售期，
                    dlg:setLabelText("PublicLabel_2", string.format(CHS[4200520], 0), panel2)

                    dlg:setLabelText("SaleLabel_1", CHS[4300491], panel2) -- 拍卖寄售期，
                    dlg:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(data.end_time - gf:getServerTime()), panel2)
                else
                    local panel2 = dlg:getControl("VendueTimesPanel", nil, vendueSellePanel)
                    dlg:setLabelText("LeftLabel", CHS[4101102], panel2) -- 拍卖寄售期，
                    dlg:setLabelText("LeftLabel_2", TradingMgr:getLeftTime(data.end_time - gf:getServerTime()), panel2)
                end



                -- 竞拍次数
                local panel1 = dlg:getControl("LeftTimePanel", nil, vendueSellePanel)
                dlg:setLabelText("LeftLabel_2", string.format(CHS[4200522], data.auction_count), panel1)
                dlg:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, data.auction_count, false, LOCATE_POSITION.MID, 23, panel1)

                -- 底价
                local panel1 = dlg:getControl("UpsetPricePanel", nil, vendueSellePanel)
                local cashText = gf:getArtFontMoneyDesc(tonumber(data.price))
                dlg:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23, panel1)
                dlg:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, panel1)

                -- 当前价格
                local panel1 = dlg:getControl("CurrentPricePanel", nil, vendueSellePanel)
                local cashText = gf:getArtFontMoneyDesc(tonumber(data.butout_price))
                dlg:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23, panel1)
                dlg:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, panel1)


            end
        end


    end

    if not data then
        if not dlg.goods_gid then return end
        data = TradingMgr:getTradGoodsData(dlg.goods_gid, "info")
    end

    if data then
        if data.para then
            -- 需要将竞拍次数从json格式中转出来
            local info = json.decode(data.para)
            data.auction_count = info.auction_count
        end
        setInfo(data)
    end
end

function TradingMgr:setMyGoodsData(tra_data)
    mMySellGoods = tra_data
end

function TradingMgr:getMyGoodsData()
	return mMySellGoods
end

function TradingMgr:MSG_TRADING_GOODS_UPDATE(data)
    TradingMgr:setTradGoodsData(data)
end

-- 请求聚宝交易记录
function TradingMgr:queryJuBaoRecord()
    gf:CmdToServer("CMD_TRADING_RECORD", {})
end

-- 获取交易记录 para == "buy" OR "sale"
function TradingMgr:getTradeRecord(para)
    if not self.jubaoRrcord then return end
    if para == "buy" then
        return self.jubaoRrcord.buyInfo
    elseif para == "sale" then
        return self.jubaoRrcord.sellInfo
    end
end

function TradingMgr:getEquipSaleType(equip)
    if equip.equip_type == EQUIP_TYPE.WEAPON then
        return JUBAO_SELL_TYPE.SALE_TYPE_WEAPON
    elseif equip.equip_type == EQUIP_TYPE.HELMET or equip.equip_type == EQUIP_TYPE.ARMOR or equip.equip_type == EQUIP_TYPE.BOOT then
        return JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR
    elseif equip.equip_type == EQUIP_TYPE.WRIST or equip.equip_type == EQUIP_TYPE.BALDRIC or equip.equip_type == EQUIP_TYPE.NECKLACE then
        return JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY
    elseif equip.equip_type == EQUIP_TYPE.ARTIFACT then
        return JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT
    end
end

function TradingMgr:MSG_TRADING_RECORD(data)
    self.jubaoRrcord = data
end

function TradingMgr:setEagleEyeSearchData(data)
    self.EagleEyeSearchData = data
end

function TradingMgr:getEagleEyeSearchData()
    return self.EagleEyeSearchData --搜索条件
end

function TradingMgr:getSearchGoodsType(list_type)
    if self.searchGoodsType and self.searchGoodsType[list_type] then
        return self.searchGoodsType[list_type]
    end
end

function TradingMgr:MSG_TRADING_SEARCH_GOODS(data)
    if data.is_begin == 1 then
        if data.list_type == TradingMgr.LIST_TYPE.SALE_LIST then
            jubao_sell_data[CHS[7000306]] = {}
        elseif data.list_type == TradingMgr.LIST_TYPE.SHOW_LIST then
            jubao_public_data[CHS[7000306]] = {}
        else
            if not jubao_vendue_data[data.list_type] then jubao_vendue_data[data.list_type] = {}   end
            jubao_vendue_data[data.list_type][CHS[7000306]] = {}
        end
    end

    for i = 1, data.count do
        local info = json.decode(data[i].para)
        for field, value in pairs(info) do
            data[i][field] = value
        end

        if data.list_type == TradingMgr.LIST_TYPE.SALE_LIST then
            table.insert(jubao_sell_data[CHS[7000306]], data[i])
        elseif data.list_type == TradingMgr.LIST_TYPE.SHOW_LIST then
            table.insert(jubao_public_data[CHS[7000306]], data[i])
        else
            table.insert(jubao_vendue_data[data.list_type][CHS[7000306]], data[i])
        end
    end

    if data.is_end == 1 then
        if not self.tradingSearchDataRecTime then self.tradingSearchDataRecTime = {} end
        self.tradingSearchDataRecTime[data.list_type] = gfGetTickCount()
        -- 刷新需要在设置完成时间后刷
        DlgMgr:sendMsg("JuBaoZhaiSellDlg", "MSG_TRADING_SEARCH_GOODS", data)
        DlgMgr:sendMsg("JuBaoZhaiVendueDlg", "MSG_TRADING_SEARCH_GOODS", data)
        DlgMgr:closeDlg("JuBaoZhaiSearchDlg")

        if not self.searchGoodsType then self.searchGoodsType = {} end
        self.searchGoodsType[data.list_type] = data.goods_type
    end
end

-- 订单自动登录，请求token
function TradingMgr:askAutoLoginToken(dlgName, goodsId, needCheckBind, meGid, isTakeBack)
    if needCheckBind and Me:getAdultStatus() == 2 then
        -- 角色尚未完成实名认证
        local dlg = gf:confirm(CHS[7190176], function()
            -- 前往认证
            local dlg2 = DlgMgr:openDlg("SystemAccManageDlg")
            dlg2:onSwitchPanel(dlg2:getControl("AuthenticateRealNameCheckBox"))
            dlg2.radioGroup:selectRadio(2)
        end, function()
            -- 匿名浏览
            self.autoLoginInfo.dlgName = dlgName
            self.autoLoginInfo.goodsId = goodsId
            self.autoLoginInfo.isTakeBack = isTakeBack
            local gid = Me:queryBasic('gid')
            if string.isNilOrEmpty(gid) then gid = meGid or goodsId end
            self.autoLoginInfo.gid = gid
            gf:CmdToServer("CMD_TRADING_AUTO_LOGIN_TOKEN", {gid = gid})
        end)
        dlg:setConfirmText(CHS[7190177])
        dlg:setCancleText(CHS[7190178])
    else
        self.autoLoginInfo.dlgName = dlgName
        self.autoLoginInfo.goodsId = goodsId
        self.autoLoginInfo.isTakeBack = isTakeBack
        local gid = Me:queryBasic('gid')
        if string.isNilOrEmpty(gid) then gid = meGid or goodsId end
        self.autoLoginInfo.gid = gid
        gf:CmdToServer("CMD_TRADING_AUTO_LOGIN_TOKEN", {gid = gid})
    end
end

-- 检查应用是否存在
function TradingMgr:checkAppInstall()
    local ctx = AndroidUtil:callStatic("org/cocos2dx/lua/AppActivity", "getContext", "()Landroid/content/Context;", {})
    if not ctx then return end
    local packageManager = AndroidUtil:callInst("android/content/Context", "getPackageManager", ctx, "()Landroid/content/pm/PackageManager;", {})
    if not packageManager then return end
    local pinfo = AndroidUtil:callInst("android/content/pm/PackageManager", "getPackageInfo", packageManager, "(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;", { "com.leiting.jbz", 0 })
    if pinfo then
        local versionName = AndroidUtil:callStatic("com/gbits/ClassUtils", "getStringField", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;", {"android.content.pm.PackageInfo", "versionName", pinfo})
        if versionName then
            return versionName >= "1.0.4"
        end
    end
end

-- 应用跳转
function TradingMgr:gotoIntent(goodsId, token, currDate, sign)
    local intent = AndroidUtil:newInstance("android.content.Intent", {}, {})
    if not intent then return end
    local ret
    ret = AndroidUtil:callInst("android/content/Intent", "putExtra", intent, "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;", {"gameBillId", goodsId})
    if not ret then return end
    ret = AndroidUtil:callInst("android/content/Intent", "putExtra", intent, "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;", {"token", token})
    if not ret then return end
    ret = AndroidUtil:callInst("android/content/Intent", "putExtra", intent, "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;", {"currDate", currDate})
    if not ret then return end
    ret = AndroidUtil:callInst("android/content/Intent", "putExtra", intent, "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;", {"sign", sign})
    if not ret then return end
    ret = AndroidUtil:callInst("android/content/Intent", "setClassName", intent, "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;", {"com.leiting.jbz", "com.leiting.jbz.activity.LaunchActivity"})
    if not ret then return end
    ret = AndroidUtil:callStatic("org/cocos2dx/lua/AppActivity", "getContext", "()Landroid/content/Context;", {})
    if not ret then return end
    AndroidUtil:callInst("org/cocos2dx/lua/AppActivity", "startActivity", ret, "(Landroid/content/Intent;)V", { intent })
end

-- 订单自动登录
function TradingMgr:goodsAutoLogin(goodsId, token, gid)
    gid = gid or Me:queryBasic("gid")
    local account = Client:getAccount()
    local date = gf:getServerDate(CHS[7190180], gf:getServerTime())
    local sign = gfGetMd5(account .. "%" .. date .. "%" .. goodsId .. "%" .. gid .. "%" .. "#leiting_wd#")
    local url = string.format(TradingMgr.AUTO_LOGIN_URL, TradingMgr.BUY_URL)
    local urlWithPara = url .. string.format(CHS[7190179], goodsId, token, date, sign)
    if gf:isAndroid() and self:checkAppInstall() then
        self:gotoIntent(goodsId, token, date, sign)
    else
        DeviceMgr:openUrl(urlWithPara)
    end
end

-- 订单自动登录管理
function TradingMgr:goodsAutoManage(goodsId, token, gid)
    gid = gid or Me:queryBasic("gid")
    local account = Client:getAccount()
    local date = gf:getServerDate(CHS[7190180], gf:getServerTime())
    if gf:isAndroid() and self:checkAppInstall() then
        goodsId = string.format("%s_orderManage", goodsId)
    end
    local sign = gfGetMd5(account .. "%" .. date .. "%" .. goodsId .. "%" .. gid .. "%" .. "#leiting_wd#")
    local url = string.format(TradingMgr.AUTO_MANAGE_URL, TradingMgr.BUY_URL)
    local urlWithPara = url .. string.format(CHS[7190179], goodsId, token, date, sign)
    if gf:isAndroid() and self:checkAppInstall() then
        self:gotoIntent(goodsId, token, date, sign)
    else
        DeviceMgr:openUrl(urlWithPara)
    end
end

-- 清除订单自动登录信息
function TradingMgr:cleanAutoLoginInfo()
    self.autoLoginInfo = {}
end

-- 订单自动登录token回来了
function TradingMgr:MSG_TRADING_AUTO_LOGIN_TOKEN(data)
    local dlg = DlgMgr:getDlgByName(self.autoLoginInfo.dlgName)
    if dlg then
        if self.autoLoginInfo.isTakeBack then
            TradingMgr:goodsAutoManage(self.autoLoginInfo.goodsId, data.token, self.autoLoginInfo.gid)
        else
            TradingMgr:goodsAutoLogin(self.autoLoginInfo.goodsId, data.token, self.autoLoginInfo.gid)
        end
    end
end

function TradingMgr:setSellBuyTypeFlag(sell_buy_type, dlg, panel)
    dlg:setCtrlVisible("StateBKImage", false, panel)
    dlg:setCtrlVisible("SellStateValueLabel_1", true, panel)
    dlg:setCtrlVisible("SellStateValueLabel_2", true, panel)

    if sell_buy_type == TRADE_SBT.APPOINT_SELL then
        dlg:setCtrlVisible("StateBKImage", true, panel)
        dlg:setLabelText("SellStateValueLabel_1", CHS[4010052], panel)
        dlg:setLabelText("SellStateValueLabel_2", CHS[4010052], panel)
    elseif sell_buy_type == TRADE_SBT.AUCTION then
        dlg:setCtrlVisible("StateBKImage", true, panel)
        dlg:setLabelText("SellStateValueLabel_1", CHS[4010053], panel)
        dlg:setLabelText("SellStateValueLabel_2", CHS[4010053], panel)
    else
        dlg:setLabelText("SellStateValueLabel_1", "", panel)
        dlg:setLabelText("SellStateValueLabel_2", "", panel)
    end
end

-- 设置竞拍flag
function TradingMgr:setAuctionFlag(data, dlg, panel)
    local gids = TradingMgr:getAuctionGid()
    if gids[data.goods_gid] then
        -- 竞拍的商品
        dlg:setCtrlVisible("VendueFailImage", data.appointee_gid ~= Me:queryBasic("gid"), panel)
        dlg:setCtrlVisible("VendueSuccessImage", data.appointee_gid == Me:queryBasic("gid"), panel)
    else
        dlg:setCtrlVisible("VendueFailImage", false, panel)
        dlg:setCtrlVisible("VendueSuccessImage", false, panel)
    end
end

function TradingMgr:getAuctionGid()
    if not self.auction_gids then
        self.auction_gids = {}
    end

    return self.auction_gids[Me:getShowId()] or {}
end

function TradingMgr:MSG_TRADING_AUCTION_BID_GIDS(data)
    if not self.auction_gids then
        self.auction_gids = {}
    end

    self.auction_gids[Me:getShowId()] = {}
    for i = 1, data.count do
         self.auction_gids[Me:getShowId()][data[i]] = 1
    end
end

function TradingMgr:MSG_TRADING_AUCTION_BID_LIST(data)

    -- 该商品肯定是拍卖-寄售中的
    if not jubao_vendue_data[TradingMgr.LIST_TYPE.AUCTION_LIST] then jubao_vendue_data[TradingMgr.LIST_TYPE.AUCTION_LIST] = {} end
    jubao_vendue_data[TradingMgr.LIST_TYPE.AUCTION_LIST][CHS[4010051]] = {}

    -- 容错拍卖收藏列表
    if not self.auction_gids then
        self.auction_gids = {}
    end
    self.auction_gids[Me:getShowId()] = {}

    for i = 1, data.count do

        local info = json.decode(data[i].para)
        for field, value in pairs(info) do
            data[i][field] = value
        end

		data[i].isDecode = true

        -- 保存数据
        table.insert(jubao_vendue_data[TradingMgr.LIST_TYPE.AUCTION_LIST][CHS[4010051]], data[i])

        -- 更新收藏gid
        self.auction_gids[Me:getShowId()][data[i].goods_gid] = 1
    end

end

function TradingMgr:setAutoLoginInfo(gid, dlgName)
    self.autoLoginInfo.dlgName = dlgName
    self.autoLoginInfo.goodsId = gid
end

function TradingMgr:tryBuyItem(gid, dlgName)
    TradingMgr:setAutoLoginInfo(gid, dlgName)
    gf:CmdToServer("CMD_TRADING_BUY_GOODS", {goods_gid = gid})
end

function TradingMgr:MSG_TRADING_OPEN_URL(data)
    if not self.autoLoginInfo.dlgName then return end
            -- 弹出确认框
    gf:confirmEx(
        data.text,
        data.str_confirm,
        function()
            TradingMgr:askAutoLoginToken(self.autoLoginInfo.dlgName, data.goods_gid, nil, nil, data.action == TradingMgr.URL_ACTION.CANCEL)
            if data.auto_favorite == 1 then
                TradingMgr:modifyCollectGoods(data.goods_gid, 1, data.auto_favorite)
            end
        end,
        data.str_cancel
        )
end

function TradingMgr:showVendueTipsInfo(sender)
    local str1 = CHS[4010054]
    local str2 = CHS[4010055]
    local str3 = CHS[4010056]
    local str4 = CHS[4010057]
    local str5 = CHS[4010058]
    local str6 = CHS[4010059]
    local str7 = CHS[4010060]
    local str8 = CHS[4010061]
    local str = str1 .. str2 .. str3 .. str4 .. str5 .. str6 .. str7 .. str8
    gf:showTipInfo(str, sender)
end

MessageMgr:regist("MSG_TRADING_OPEN_URL", TradingMgr)
MessageMgr:regist("MSG_TRADING_AUCTION_BID_LIST", TradingMgr)
MessageMgr:regist("MSG_TRADING_AUCTION_BID_GIDS", TradingMgr)
MessageMgr:regist("MSG_TRADING_SEARCH_GOODS", TradingMgr)

MessageMgr:regist("MSG_TRADING_RECORD", TradingMgr)
MessageMgr:regist("MSG_TRADING_GOODS_UPDATE", TradingMgr)
MessageMgr:regist("MSG_TRADING_FAVORITE_GIDS", TradingMgr)
MessageMgr:regist("MSG_TRADING_GOODS_LIST", TradingMgr)
MessageMgr:regist("MSG_TRADING_ENABLE", TradingMgr)
MessageMgr:regist("MSG_TRADING_SNAPSHOT_ME", TradingMgr)
MessageMgr:regist("MSG_TRADING_SNAPSHOT", TradingMgr)
MessageMgr:regist("MSG_TRADING_ROLE", TradingMgr)
MessageMgr:regist("MSG_TRADING_GOODS_MINE_UPDATE", TradingMgr)
MessageMgr:regist("MSG_TRADING_GOODS_MINE", TradingMgr)
MessageMgr:regist("MSG_TRADING_GOODS_MINE_REMOVE", TradingMgr)
MessageMgr:regist("MSG_TRADING_SELL_CASH", TradingMgr)
MessageMgr:regist("MSG_TRADING_AUTO_LOGIN_TOKEN", TradingMgr)
