-- OnlineMallMgr.lua
-- created by zhengjh Mar/27/2014
-- 在线商城管理器

OnlineMallMgr = Singleton()

local VipInfo = require("cfg/VipInfo")
local VipRight = require("cfg/VipRight")

local VIP_INFO =
{
    [1] = CHS[6000202], --"位列仙班·月卡",
    [2] = CHS[6000203], --"位列仙班·季卡",
    [3] = CHS[6000204], --"位列仙班·年卡",
}

local ONLINEMALL_ITEM_WEIGHT = {
    -- 商城道具排序规则（目前用于推荐商品）
    ["E"] = 0,
    ["L"] = 1,
    ["X"] = 2,
    ["R"] = 3,
}

local onlineMallList = {}
local isRequestOnlineData = false

-- 是否使用金元宝购买
OnlineMallMgr.isUseGold = false

-- name 玩家名字
function OnlineMallMgr:openOnlineMall(dlgName, para, items, openFrom)
    -- 连续快速打开两次，第二次打开商城界面
    if not self.lasetTime or gfGetTickCount() - self.lasetTime > 1 * 1000 then
        self.openDlgName = dlgName
        isRequestOnlineData = true
        local data = {}
        data["name"] = Me:queryBasic("name")
        data["para"] = para
        gf:CmdToServer("CMD_OPEN_ONLINE_MALL", data)

        self:setOpenItem(items, openFrom)
    end

    self.lasetTime = gfGetTickCount()
end

function OnlineMallMgr:hasRequestOnlineData()
    return next(onlineMallList) or isRequestOnlineData
end

function OnlineMallMgr:clearData(isLoginOrSwithLine)
    self.mallCashInfo = nil
    onlineMallList = {}
    isRequestOnlineData = false
    
    if not isLoginOrSwithLine then
        self.lasetTime = nil
    end
end

-- 设置默认打开物品

-- items 为 key,为名称 value为参数值
-- 该接口目前用于，商城选中道具，vip界面选中vip等级
function OnlineMallMgr:setOpenItem(items, from)
    self.items = items

    -- 来源
    self.openFrom = from
end

-- 物品列表
function OnlineMallMgr:MSG_ONLINE_MALL_LIST(data)
    if not data then return end

    if data.type == 1 then -- 刷新单个
        local item = data[1]
        for i = 1,#onlineMallList do
            if item["barcode"] == onlineMallList[i]["barcode"] then
                onlineMallList[i] = item
                break
            end
        end

        DlgMgr:sendMsg("OnlineMallDlg","refreshItemData", item["barcode"])
    elseif data.type == 0 then -- 刷新所有列表
        onlineMallList = {}

        for i = 1 ,data["count"] do
            table.insert(onlineMallList, data[i])
        end

        -- 根据show_pos排序
        self:sortItems()

        -- 由换装系统发起的请求，无需后续处理了
        if data.para == "dressRequest" then return end

        if data.para == "notOpenDlg" then return end

        if self.openDlgName ~= nil then
            local dlg = DlgMgr:openDlg(self.openDlgName)
            self.openDlgName = nil

            local selectGoods = nil
            for i = 1, #onlineMallList do
                local goods = onlineMallList[i]

                -- 位列仙班是否满足
                local isMeetVip = true
                if goods.must_vip == 1 and Me:getVipType() <= 0 then
                    isMeetVip = false
                end

                if self.items and self.items[goods.name] then
                    if self.openFrom then
                        -- 标记一下购买参数，用于购买成功或失败时通知服务端
                        self.bugGoodsPara = {
                            from = self.openFrom,
                            barcode = goods.barcode
                        }
                    end

                    if goods["sale_quota"] > 0 and goods.discount ~= 100 and isMeetVip then
                        -- 便捷购买的物品，有打折，则点击购买需要弹出商城界面
                        DlgMgr:sendMsg(dlg.name, "setNeedGotoOnline", true)
                    end
                end
            end

            DlgMgr:sendMsg(dlg.name, "initData")
            DlgMgr:sendMsg(dlg.name, "onDlgOpened", self.items)
            DlgMgr:sendMsg(dlg.name, "setOpenFrom", self.openFrom)

            DlgMgr:sendMsg("OnlineMallVIPDlg","selectVipType", self.items or {vip = 1})

            self.items = nil
            self.openFrom = nil
            return
        end
        local last = DlgMgr:getLastDlgByTabDlg('OnlineMallTabDlg') or 'OnlineMallDlg'
        DlgMgr:openDlg(last)

        DlgMgr:sendMsg("OnlineMallDlg","initData")
        DlgMgr:sendMsg("OnlineMallDlg","onDlgOpened", self.items)

        self.items = nil
        self.openFrom = nil
    end
end

-- 排序商品列表
function OnlineMallMgr:sortItems()
    local function sortfunc(r, l)
        if self:getSortWight(r["sale_quota"]) > self:getSortWight(l["sale_quota"]) then return true end
        if self:getSortWight(r["sale_quota"]) < self:getSortWight(l["sale_quota"]) then return false end

        return r["show_pos"] < l["show_pos"]
    end

    table.sort(onlineMallList, sortfunc)
end

function OnlineMallMgr:getSortWight(quota)
    local wight = 1

    if quota ~= -1 then -- 限购
        wight = 2
    end

    return wight
end

-- 获取商品列表
function OnlineMallMgr:getOnlineMallList()
    return onlineMallList
end

-- 根据道具名获取道具信息用于来源
function OnlineMallMgr:getMallItemForRes(itemName)
    local item
    for i = 1, #onlineMallList do
        if onlineMallList[i].name == itemName then
            if 3 == onlineMallList[i].recommend or 1 == onlineMallList[i].type then
                return onlineMallList[i]
            else
                item = onlineMallList[i]
            end
        end
    end

    return item
end

-- 获取推荐商品
function OnlineMallMgr:getRecommandMallList()
    local mallList = {}

    local limitList = {}
    for _, item in ipairs(self:getOnlineMallList()) do
        if item.type == 1 then
            limitList[item.name] = item.name
        end
    end

    for _, item in ipairs(self:getOnlineMallList()) do
        if item.type == 1 or (item.recommend == 3 and
                              (not limitList[item.name]) and
                              (not ActivityMgr:isInLimitPurchase())) then
            table.insert(mallList, item)
        end
    end

    table.sort(mallList, function(l, r)
        if 1 == l.type and 1 ~= r.type then return true end
        if 1 ~= l.type and 1 == r.type then return false end

        local lItemType = string.sub(l.barcode, 1, 1)
        local rItemType = string.sub(r.barcode, 1, 1)
        if ONLINEMALL_ITEM_WEIGHT[lItemType] < ONLINEMALL_ITEM_WEIGHT[rItemType] then return true end
        if ONLINEMALL_ITEM_WEIGHT[lItemType] > ONLINEMALL_ITEM_WEIGHT[rItemType] then return false end

        if l.rpos < r.rpos then return true end
        if l.rpos > r.rpos then return false end
    end)

    return mallList
end

-- 获取提升道具商品
function OnlineMallMgr:getPromoteMallList()
    local mallList = {}

    for _, item in ipairs(self:getOnlineMallList()) do
        if item.type == 2 then
            table.insert(mallList, item)
        end
    end

    table.sort(mallList, function(l, r)
        if l.type < r.type then return true end
        if l.type > r.type then return false end

        if l.show_pos < r.show_pos then return true end
        if l.show_pos > r.show_pos then return false end
    end)

    return mallList
end

-- 获取练功道具
function OnlineMallMgr:getPracticeMallList()
    local mallList = {}

    for _, item in ipairs(self:getOnlineMallList()) do
        if item.type == 3 then
            table.insert(mallList, item)
        end
    end

    table.sort(mallList, function(l, r)
        if l.type < r.type then return true end
        if l.type > r.type then return false end

        if l.show_pos < r.show_pos then return true end
        if l.show_pos > r.show_pos then return false end
    end)

    return mallList
end

-- 获取其他道具
function OnlineMallMgr:getOtherMallList()
    local mallList = {}

    for _, item in ipairs(self:getOnlineMallList()) do
        if item.type == 4 then
            table.insert(mallList, item)
        end
    end

    table.sort(mallList, function(l, r)
        if l.type < r.type then return true end
        if l.type > r.type then return false end

        if l.show_pos < r.show_pos then return true end
        if l.show_pos > r.show_pos then return false end
    end)

    return mallList
end

-- 购买道具
function OnlineMallMgr:buyGoods(data)

    gf:CmdToServer("CMD_BUY_FROM_ONLINE_MALL", data)

    if self.bugGoodsPara and self.bugGoodsPara.barcode == data.barcode then
        self.bugGoodsPara.isRequest = true
    end
end

-- 使用优惠券购买道具
function OnlineMallMgr:buyGoodsWithCoupon(data)
    gf:CmdToServer("CMD_COUPON_BUY_FROM_MALL", data)
end

-- vip信息
function OnlineMallMgr:getVipInfo()
    return VipInfo
end

-- vip特权信息
function OnlineMallMgr:getVipInfoRight()
    return VipRight
end

-- 领取tvip提示
function OnlineMallMgr:getVipTips(getVipName)
    local myVip = Me:getVipType()
    local vipName = VIP_INFO[myVip]

    if not vipName then  return end -- 没有vip

    -- 不要转换提示
    local toDays = self:getVipChangeDays(vipName, getVipName)
    if not toDays then return end

    if GameMgr.isIOSReview then
        local tips = CHS[3004172] .. getVipName .. "?"
        tips = gf:replaceVipStr(tips)
        return tips
    end

    local tips = string.format(CHS[3004173], getVipName, vipName, toDays, getVipName)
    return tips
end

function OnlineMallMgr:getVipChangeDays(fromVipName, toVipName)
    local leftDays =  Me:getVipFloatDays()
    local toDays = nil
    if CHS[3004174] == fromVipName then
        if toVipName == CHS[3004175] then
            -- 季卡
            toDays = math.floor(leftDays / 1.2)
        elseif toVipName == CHS[3004176] then
            toDays = math.floor(leftDays / 1.5)
        end
    elseif CHS[3004175] == fromVipName then
        if toVipName == CHS[3004176] then
            toDays = math.floor(leftDays / 1.25)
        end
    end

    if toDays and toDays < 1 then
        toDays = 1
    end

    return toDays
end


-- 购买会员
function OnlineMallMgr:buyVip(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_INSIDER , type)
end

-- 领取元宝
function OnlineMallMgr:getMoney(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_DRAW_INSIDER_COIN, type)
end

-- 购买元宝
function OnlineMallMgr:buyGoldCoin(index)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_RECHARGE_COIN, index)
end

-- 打开充值界面
function OnlineMallMgr:openRechargeDlg()
    local tabDlg = DlgMgr:getDlgByName("OnlineMallTabDlg")

    if tabDlg then
        tabDlg.group:setSetlctByName("RechargeCheckBox")
    else
        DlgMgr:openDlg("OnlineRechargeDlg")
        --DlgMgr.dlgs["MarketTabDlg"].group:setSetlctByName("MarketPublicityDlgCheckBox")
    end
end

-- 获取购买游戏币信息
function OnlineMallMgr:getMallCashInfo()
    return self.mallCashInfo
end

-- 购买金钱信息
function OnlineMallMgr:MSG_ONLINE_MALL_CASH_LIST(data)
    self.mallCashInfo = self.mallCashInfo or {}
    self.mallCashInfo = data
    table.sort(self.mallCashInfo, function(l, r)
        if l.toMoney < r.toMoney then return true end
        if l.toMoney > r.toMoney then return false end
    end)
end

function OnlineMallMgr:MSG_INSIDER_DISCOUNT_INFO(data)
    self.vipDiscount = data
end

-- 通知服务端购买商品成功或失败(目前只处理了快捷购买框)
function OnlineMallMgr:cmdBuyItemResult(from , result)
    if self.bugGoodsPara and self.bugGoodsPara.from == from and not self.bugGoodsPara.isRequest then
        -- 如果已经在请求购买了，需等收到 MSG_BUY_FROM_MALL_RESULT 才可通知结果
        gf:CmdToServer("CMD_BUY_CHAR_ITEM_CB", {from = from or "", result = result or 0})
        self.bugGoodsPara = nil
    end
end

function OnlineMallMgr:checkHasDiscountCanBuy(itemName)
    local disItem = nil
    for _, item in ipairs(self:getOnlineMallList()) do
        if item["name"] == itemName and item["discount"] < 100 and item["discount"] > 0 then
            disItem = item
        end
    end

    if not disItem then
        -- 无折扣道具
        return
    end

    if disItem["sale_quota"] == 0 then
        -- 售罄
        return
    end

    if disItem["discountTime"] - gf:getServerTime() <= 0 then
        -- 过期
        return
    end

    if not Me:isVip() and disItem["must_vip"] == 1 then
        -- 无折扣道具、售罄、过期、仅 vip 可购买
        return
    end

    gf:confirm(string.format(CHS[5410273], itemName), function()
        OnlineMallMgr:openOnlineMall("OnlineMallDlg", nil, {[itemName] = 1})
    end)
end

function OnlineMallMgr:MSG_BUY_FROM_MALL_RESULT(data)
    if not self.bugGoodsPara or self.bugGoodsPara.barcode ~= data.barcode then
        return
    end

    self.bugGoodsPara.isRequest = false
    self:cmdBuyItemResult(self.bugGoodsPara.from, data.result)
end

function OnlineMallMgr:MSG_AAA_CHARGE_DATA_LIST(data)
    local dlg = DlgMgr:openDlg("OnlineRechargeGiftDlg")
    dlg:setData(data)
end

MessageMgr:regist("MSG_AAA_CHARGE_DATA_LIST", OnlineMallMgr)
MessageMgr:regist("MSG_ONLINE_MALL_LIST", OnlineMallMgr)
MessageMgr:regist("MSG_ONLINE_MALL_CASH_LIST", OnlineMallMgr)
MessageMgr:regist("MSG_INSIDER_DISCOUNT_INFO", OnlineMallMgr)
MessageMgr:regist("MSG_BUY_FROM_MALL_RESULT", OnlineMallMgr)

return OnlineMallMgr
