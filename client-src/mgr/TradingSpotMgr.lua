-- TradingSpotMgr.lua
-- Created by lixh Des/26/2018
-- 商贾货站管理器

TradingSpotMgr = Singleton()

local ItemInfo = require (ResMgr:getCfgPath("TradingSpotItemCfg.lua"))

-- 货站商品数据
TradingSpotMgr.allGoodsData = {}

-- 盈亏数据
TradingSpotMgr.profitData = {}

-- 交易状态
local TRADING_STATUS = {
    OPEN = 1,   -- 开盘
    HALT = 2,   -- 停盘
    CLOSE = 3,  -- 收盘
}

-- 商品数据列表
local GOODS_LIST_TYPE = {
    ALL_ITEM = 1,   -- 所以货品
    MY_ITEM = 2,    -- 我的货品
    COLLECTION = 3, -- 收藏
}

-- 盈亏数据类型
local PROFIT_LIST_TYPE = {
    LAST = 1,       -- 上期
    HISTORY = 2,    -- 历史
}

-- 货品详情数据类型
local DETAILS_LIST_TYPE = {
    LINE = 1,       -- 折线图
    RANGE = 2,      -- 历史涨跌
    RECORD = 3,     -- 盈亏记录
}

-- 货站限制等级
local SPOT_OPEN_LEVEL = 75

-- 手续费百分比
local POUNDAGE_VALUE = 0

-- 获取手续费百分比配置
function TradingSpotMgr:getPoundageCfg()
    return POUNDAGE_VALUE
end

-- 玩家等级满足货站条件
function TradingSpotMgr:isMeLevelMeetCondition()
    if Me:getLevel() >= SPOT_OPEN_LEVEL then
        return true
    end

    return false
end

-- 获取货品交易类型配置
function TradingSpotMgr:getTradingStatusCfg()
    return TRADING_STATUS
end

-- 获取货品数据列表类型配置
function TradingSpotMgr:getGoodsListTypeCfg()
    return GOODS_LIST_TYPE
end

-- 获取盈亏数据列表类型配置
function TradingSpotMgr:getProfitListTypeCfg()
    return PROFIT_LIST_TYPE
end

-- 获取货品详情列表类型配置
function TradingSpotMgr:getDetailListTypeCfg()
    return DETAILS_LIST_TYPE
end

-- 是否处于休市时间
function TradingSpotMgr:isInRestTime()
    local time = gf:getServerTime()
    if self.openTradingTime and self.closeTradingTime
        and time >= self.openTradingTime
        and time <= self.closeTradingTime then
        return false
    end

    return true
end

-- 获取当天收市时间
function TradingSpotMgr:getTradingCloseTime()
    return self.closeTradingTime
end

-- 获取涨幅的描述
function TradingSpotMgr:getPriceUpTextInfo(upValue)
    if upValue > 0 then
        return string.format("+%.2f%%", upValue / 100), COLOR3.RED
    elseif upValue < 0 then
        return string.format("%.2f%%", upValue / 100), COLOR3.GREEN
    else
        return string.format("%.2f%%", upValue / 100), COLOR3.TEXT_DEFAULT
    end
end

-- 获取盈亏的描述
function TradingSpotMgr:getProfitTextInfo(profit)
    local moneyDes, _ = gf:getMoneyDesc(math.floor(profit), true)
    if profit > 0 then
        return string.format("+%s", moneyDes), COLOR3.RED
    elseif profit < 0 then
        return string.format("%s", moneyDes), COLOR3.GREEN
    else
        return moneyDes, COLOR3.TEXT_DEFAULT
    end
end

-- 计算商品列表总价
function TradingSpotMgr:getAllGoodsPrice(list)
    local allPrice = 0
    for i = 1, #list do
        allPrice = allPrice + list[i].all_price
    end

    return allPrice
end

-- 计算商品列表手续费
function TradingSpotMgr:getAllGoodsPoundage(list)
    local allPoundage = 0
    for i = 1, #list do
        allPoundage = allPoundage + math.floor(list[i].price * list[i].volume / 100) * self:getPoundageCfg()
    end

    return allPoundage
end

-- 获取期数移除符号"."的数值
function TradingSpotMgr:getTradingNoNum(tradingNo)
    local desArray = string.split(tradingNo, ".")
    if #desArray ~= 2 then return end

    return tonumber(desArray[1] .. desArray[2])
end

-- 获取期数描述
function TradingSpotMgr:getTradingNoDes(tradingNo)
    local desArray = string.split(tradingNo, ".")
    if #desArray ~= 2 then return end

    local timeStr = desArray[1]
    return string.format(CHS[7190464], string.sub(timeStr, 1, 4), string.sub(timeStr, 5, 6), string.sub(timeStr, 7, 8), desArray[2])
end

-- 打开货站界面，并选中指定货品，然后打开对应详情界面
function TradingSpotMgr:openTradingSpotAndSelectItem(goodsId)
    local dlg = DlgMgr:getDlgByName("TradingSpotItemDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("TradingSpotItemDlg")
    end

    dlg.selectedGoodsId = goodsId
    dlg.needOpenGoodsDetail = true
end

-- 打开货站界面，并选中指定页签
function TradingSpotMgr:openTradingSpotByType(type)
    local dlg = DlgMgr:getDlgByName("TradingSpotItemDlg")
    if not dlg then
        dlg = DlgMgr:openDlgEx("TradingSpotItemDlg", GOODS_LIST_TYPE.MY_ITEM)
    else
        dlg:selectRadio(GOODS_LIST_TYPE.MY_ITEM)
    end
end

-- 判断是否可以打开货站
function TradingSpotMgr:checkCanOepnTradingSpot(notEnableCb)
    if not TradingSpotMgr:isTradingSpotEnable() then
        if notEnableCb and 'function' == type(notEnableCb) then
            gf:showTipAndMisMsg(CHS[7190461])
            notEnableCb()
        else
            gf:ShowSmallTips(CHS[7190461])
        end

        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190462])
        return
    end

    if not TradingSpotMgr:isMeLevelMeetCondition() then
        gf:ShowSmallTips(CHS[7190478])
        return
    end

    if Me:isAntiAdditionSwith5() or Me:getAdultStatus() == 2 then
        -- 未实名或未成年用户
        gf:ShowSmallTips(CHS[7190479])
        return
    end

    return true
end

-- 检查结算点(收盘)时间
function TradingSpotMgr:checkCloseTradingTime()
    local curTime = gf:getServerTime()
    if self.closeTradingTime and self.closeTradingTime > curTime and self.closeTradingTime - curTime < 300 then
        return true
    end

    return false
end

-- 请求货品详情数据
function TradingSpotMgr:requestOpenGoodsDetailDlg(goodsId, type)
    gf:CmdToServer("CMD_TRADING_SPOT_GOODS_DETAIL", {id = goodsId, type = type})
end

-- 请求买入货品
function TradingSpotMgr:requestBuyGoods(goodsId, num, price)
    gf:CmdToServer("CMD_TRADING_SPOT_BUY_GOODS", {id = goodsId, num = num, price = price})
end

-- 请求一键跟买货品
function TradingSpotMgr:requestBuyGoodsByPlan(tradingNo, plan, allPrice, charGid, charName)
    gf:CmdToServer("CMD_TRADING_SPOT_BID_ONE_PLAN", {trading_no = tradingNo, plan = plan, total_price = allPrice,
        char_gid = charGid, char_name = charName})
end

-- 货品详情折线图数据
function TradingSpotMgr:MSG_TRADING_SPOT_GOODS_LINE(data)
    -- WDSY-35971 ,查找一下是否有停盘的情况
    local haltIndex = 0
    for i = data.count, 1, -1 do
        if data.list[i].status == TRADING_STATUS.HALT then
            haltIndex = i
        end
    end

    if haltIndex > 0 then
        -- WDSY-35971 ,停盘时需要过滤停盘之前的数据
        local filtGoodsList = {}
        for i = haltIndex, data.count do
            filtGoodsList[i - haltIndex + 1] = data.list[i]
        end

        data.count = #filtGoodsList
        data.list = filtGoodsList
    end

    data.list_type = DETAILS_LIST_TYPE.LINE

    -- 历史涨跌数据预处理
    data.rangeList = {}
    for i = 1, data.count do
        local percentY
        local range = data.list[i].range
        if data.list[i].status == TRADING_STATUS.HALT then
            range = 0
            percentY = 100
        else
            percentY = data.list[i].close_price / data.init_price * 100
        end

        table.insert(data.rangeList, {percent = percentY, range = range, status = data.list[i].status})
    end

    if self.needOpenCardDlg then
        local dlg = DlgMgr:getDlgByName("TradingSpotShareItemDlg")
        if not dlg then
            dlg = DlgMgr:openDlgEx("TradingSpotShareItemDlg", self:getCharCardData())
        end

        self.needOpenCardDlg = nil
    end

    DlgMgr:sendMsg("TradingSpotItemInfoDlg", "setData", data)
    DlgMgr:sendMsg("TradingSpotShareItemDlg", "setData", data)
end

-- 货品详情历史涨跌数据
function TradingSpotMgr:MSG_TRADING_SPOT_GOODS_RANGE(data)
    data.list_type = DETAILS_LIST_TYPE.RANGE

    -- 增加 trading_num 字段用于比较大小
    for i = 1, data.count do
        data.list[i].trading_num = self:getTradingNoNum(data.list[i].trading_no)
    end

    -- 刷新列表排序，期数从大到小
    table.sort(data.list, function(l, r)
        if l.trading_num < r.trading_num then return false end
        if l.trading_num > r.trading_num then return true end
    end)

    DlgMgr:sendMsg("TradingSpotItemInfoDlg", "setData", data)
    DlgMgr:sendMsg("TradingSpotShareItemDlg", "setData", data)
end

-- 货品详情盈亏记录
function TradingSpotMgr:MSG_TRADING_SPOT_GOODS_RECORD(data)
    data.list_type = DETAILS_LIST_TYPE.RECORD

    -- 增加 trading_num 字段用于比较大小
    for i = 1, data.count do
        data.list[i].trading_num = self:getTradingNoNum(data.list[i].trading_no)
    end

    -- 刷新列表排序，期数从大到小
    table.sort(data.list, function(l, r)
        if l.trading_num < r.trading_num then return false end
        if l.trading_num > r.trading_num then return true end
    end)

    DlgMgr:sendMsg("TradingSpotItemInfoDlg", "setData", data)
end

-- 请求收藏货品
function TradingSpotMgr:requestCollectGoods(goodsId, flag)
    gf:CmdToServer("CMD_TRADING_SPOT_COLLECT", {id = goodsId, flag = flag and 1 or 0})
end

-- 收藏/取消收藏货品结果
function TradingSpotMgr:MSG_TRADING_SPOT_COLLECT(data)
    for i = 1, #self.allGoodsData do
        if self.allGoodsData[i].goods_id == data.goods_id then
            self.allGoodsData[i].is_collected = data.is_collected

            DlgMgr:sendMsg("TradingSpotItemDlg", "refreshItemInfo", self.allGoodsData[i])
            DlgMgr:sendMsg("TradingSpotItemInfoDlg", "refreshCollectInfo")
            return
        end
    end
end

-- 获取商品配置
function TradingSpotMgr:getItemInfo(id)
    local itemCfg = ItemInfo[id]
    if itemCfg then
        return itemCfg.name, InventoryMgr:getItemInfoByName(itemCfg.name)
    end
end

-- 获取主营人配置
function TradingSpotMgr:getGoodsOwner(id)
    local itemCfg = ItemInfo[id]
    if itemCfg then
        return itemCfg.npc
    end
end

-- 获取指定货品的数据
function TradingSpotMgr:getGoodsInfoById(id)
    if self.allGoodsData then
        for i = 1, #self.allGoodsData do
            if self.allGoodsData[i].goods_id == id then
                return self.allGoodsData[i]
            end
        end
    end
end

-- 获取指定货品的数据
function TradingSpotMgr:getGoodsListByType(type)
    local ret = {}
    if type == GOODS_LIST_TYPE.MY_ITEM then
        -- 我的持有
        for i = 1, #self.allGoodsData do
            if self.allGoodsData[i].volume > 0 then
                table.insert(ret, self.allGoodsData[i])
            end
        end
    elseif type == GOODS_LIST_TYPE.COLLECTION then
        -- 我的收藏
        for i = 1, #self.allGoodsData do
            if self.allGoodsData[i].is_collected then
                table.insert(ret, self.allGoodsData[i])
            end
        end
    else
        -- 所有物品
        ret = gf:deepCopy(self.allGoodsData)
    end

    return ret
end

-- 获取名片数据
function TradingSpotMgr:getCharCardData()
    return self.charCardData
end

-- 请求货站主界面数据
function TradingSpotMgr:requestMainSpotData(type)
    gf:CmdToServer("CMD_TRADING_SPOT_DATA", {type = type})
end

-- 货站主界面数据
function TradingSpotMgr:MSG_TRADING_SPOT_DATA(data)
    self.openTradingTime = data.open_time
    self.closeTradingTime = data.close_time
    self.allGoodsData = data.list

    table.sort(self.allGoodsData, function(l, r)
        if l.all_price < r.all_price then return false end
        if l.all_price > r.all_price then return true end
        if l.volume < r.volume then return false end
        if l.volume > r.volume then return true end
        if l.goods_id < r.goods_id then return true end
        if l.goods_id > r.goods_id then return false end
    end)

    if data.needOpenDlg == 1 or self.needOpenTradingSpot then
        DlgMgr:openDlg("TradingSpotItemDlg")
        self.needOpenTradingSpot = nil
    end

    DlgMgr:sendMsg("TradingSpotItemDlg", "refreshDlgData")
    DlgMgr:sendMsg("TradingSpotItemInfoDlg", "refreshGoodsInfo")
    DlgMgr:sendMsg("TradingSpotSharePlanDlg", "refreshRestTimeDes")
    DlgMgr:sendMsg("TradingSpotItemInfoDlg", "updateTurnButtonShow")
end

-- 请求盈亏界面数据
function TradingSpotMgr:requestProfitData(type)
    gf:CmdToServer("CMD_TRADING_SPOT_PROFIT", {type = type})
end

-- 盈亏界面数据
function TradingSpotMgr:MSG_TRADING_SPOT_PROFIT(data)
    -- 增加 trading_num 字段用于比较大小
    for i = 1, data.count do
        data.list[i].trading_num = self:getTradingNoNum(data.list[i].trading_no)
    end

    self.profitData[data.list_type] = data.list

    -- 刷新列表排序，期数从大到小，盈亏从大到小，总额从大到小，id从小到大
    table.sort(self.profitData[data.list_type], function(l, r)
        if l.trading_num < r.trading_num then return false end
        if l.trading_num > r.trading_num then return true end
        if l.profit < r.profit then return false end
        if l.profit > r.profit then return true end
        if l.all_price < r.all_price then return false end
        if l.all_price > r.all_price then return true end
        if l.goods_id < r.goods_id then return true end
        if l.goods_id > r.goods_id then return false end
    end)

    DlgMgr:sendMsg("TradingSpotProfitDlg", "setData", data)
end

-- 请求提款
function TradingSpotMgr:requestGetMoney()
    gf:CmdToServer("CMD_TRADING_SPOT_GET_MONEY", {})
end

-- 请求打开十大巨商界面
function TradingSpotMgr:requestRankingData()
    gf:CmdToServer("CMD_TRADING_SPOT_RANK_LIST", {})
end

-- 十大巨商数据，打开对应界面
function TradingSpotMgr:MSG_TRADING_SPOT_RANK_LIST(data)
    -- 盈利，等级
    table.sort(data.list, function(l, r)
        if l.sum_profit > r.sum_profit then return true end
        if l.sum_profit < r.sum_profit then return false end
        if l.level > r.level then return true end
        if l.level < r.level then return false end
    end)

    local dlg = DlgMgr:getDlgByName("TradingSpotRankDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("TradingSpotRankDlg")
    end

    dlg:setData(data)
end

-- 货站是否开启
function TradingSpotMgr:isTradingSpotEnable()
    return self.isOpen
end

-- 货站是否开放，到达开服天数
function TradingSpotMgr:isTradingSpotOpen()
    if not self.openTime then
        return false
    end

    local curTime = gf:getServerTime()
    if curTime < self.openTime then
        local leftTime = self.openTime - curTime
        local leftDays = math.floor(leftTime / (24 * 3600))
        gf:ShowSmallTips(string.format(CHS[7190497], leftDays))
        return false
    else
        return true
    end
end

-- 货站是否开启数据
function TradingSpotMgr:MSG_SPOT_ENABLE(data)
    self.isOpen = data.flag
    self.openTime = data.open_time
end

-- 货站名片
function TradingSpotMgr:MSG_TRADING_SPOT_GOODS_CARD(data)
    data.list_type = DETAILS_LIST_TYPE.RECORD

    -- 增加 trading_num 字段用于比较大小
    for i = 1, data.count do
        data.list[i].trading_num = self:getTradingNoNum(data.list[i].trading_no)
    end

    -- 刷新列表排序，期数从大到小
    table.sort(data.list, function(l, r)
        if l.trading_num < r.trading_num then return false end
        if l.trading_num > r.trading_num then return true end
    end)

    self.needOpenCardDlg = true
    TradingSpotMgr:requestOpenGoodsDetailDlg(data.goods_id, DETAILS_LIST_TYPE.LINE)

    self.charCardData = data
end

-- 货站买入方案
function TradingSpotMgr:MSG_TRADING_SPOT_CHAR_BID_INFO_CARD(data)
    -- 打开买入方案时，有可能没有货站主界面的数据，所以服务器也发了开市、收市时间，在此也更新一下数据
    self.openTradingTime = data.open_time
    self.closeTradingTime = data.close_time

    local dlg = DlgMgr:getDlgByName("TradingSpotSharePlanDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("TradingSpotSharePlanDlg")
    end

    dlg:setData(data)
end

-- 货站余额
function TradingSpotMgr:MSG_TRADING_SPOT_UPDATE_MONEY(data)
    self.bankMoney = data.bank_money
end

function TradingSpotMgr:clearData()
    self.isOpen = nil
    self.bankMoney = nil
    self.openTradingTime = nil
    self.closeTradingTime = nil
    self.allGoodsData = {}
    self.profitData = {}
    self.needOpenCardDlg = nil
end

-- 发表状态
function TradingSpotMgr:publishStatus(catalog, text)
    gf:CmdToServer('CMD_BBS_PUBLISH_ONE_STATUS', { catalog = catalog, text = text})
end

function TradingSpotMgr:queryBBSList(catalog, last_sid)
    if not catalog then return end
    last_sid = last_sid or ""
    gf:CmdToServer('CMD_BBS_REQUEST_STATUS_LIST', { last_sid = last_sid , catalog = catalog})
end


-- 删除状态
function TradingSpotMgr:deleteBBSStatus(sid)
    gf:CmdToServer('CMD_BBS_DELETE_ONE_STATUS', { sid = sid })
end

-- 请求某条状态的所有点赞玩家
function TradingSpotMgr:queryBBSStatusLikeList(sid, distName)
    distName = distName or GameMgr:getDistName()
    gf:CmdToServer('CMD_BBS_REQUEST_LIKE_LIST', { sid = sid, user_dist = distName})
end

-- 评论
function TradingSpotMgr:publishBBSComment(uid, sid, reply_cid, reply_gid, reply_dist, text, is_expand, status_dist)
    reply_cid = reply_cid or 0
    reply_gid = reply_gid or ""
    reply_dist = reply_dist or ""
    is_expand = is_expand or 0

    gf:CmdToServer('CMD_BBS_PUBLISH_ONE_COMMENT', { uid = uid, sid = sid,
        reply_cid = reply_cid, reply_gid = reply_gid, reply_dist = reply_dist,
        text = text, is_expand = is_expand, status_dist = status_dist})
end

-- 请求所有评论数据
function TradingSpotMgr:queryBBSAllComment(sid, user_dist)
    gf:CmdToServer('CMD_BBS_ALL_COMMENT_LIST', { sid = sid, user_dist = user_dist })
end


-- 点赞
function TradingSpotMgr:likeBBSStatusById(sid, distName, uid)
    gf:CmdToServer('CMD_BBS_LIKE_ONE_STATUS', { sid = sid, user_dist = distName, uid = uid})
end

-- 删除评论     isExpand:是否展开评论，评论是否展开，表现形式不一致
function TradingSpotMgr:deleteBBSComment(sid, cid, isExpand, user_dist)
    gf:CmdToServer('CMD_BBS_DELETE_ONE_COMMENT', { sid = sid, cid = cid, isExpand = isExpand , user_dist = user_dist})
end

-- 举报某个动态
function TradingSpotMgr:reportBBSStatus(uid, sid, user_dist)
    gf:CmdToServer('CMD_BBS_REPORT_ONE_STATUS', { uid = uid, sid = sid, user_dist = user_dist})
end

MessageMgr:regist("MSG_SPOT_ENABLE", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_GOODS_LINE", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_GOODS_RANGE", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_GOODS_RECORD", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_PROFIT", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_COLLECT", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_DATA", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_GOODS_CARD", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_UPDATE_MONEY", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_RANK_LIST", TradingSpotMgr)
MessageMgr:regist("MSG_TRADING_SPOT_CHAR_BID_INFO_CARD", TradingSpotMgr)
