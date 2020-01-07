-- MarketGoldBidDlg.lua
-- Created by songcw
--

local MarketGoldBidDlg = Singleton("MarketGoldBidDlg", Dialog)

local MARGIN_COST   = 2000    -- 保证金

local PRICE_MAX     =   20000000    -- 最高价
local PRICE_MIN     =   2000        -- 最低价


function MarketGoldBidDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self.price = nil

    -- 设置保证金
    self:setMargin()

    -- 最低竞价
    self:refreshCost()

    -- 绑定输入框
    self:bindSellNumInput()

    self:hookMsg("MSG_GOLD_STALL_BUY_RESULT")
end

-- 绑定输入框
function MarketGoldBidDlg:bindSellNumInput()
    -- 普通交易
    local moneyPanel = self:getControl('ValuePanel', nil, "MyPricePanel")
    local function openNumIuputDlg()
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("normal")

        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)
        self.inputNum = 0
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end


-- 数字键盘删除数字
function MarketGoldBidDlg:deleteNumber(key)
    if key == "normal" then
        self.inputNum = math.floor(self.inputNum / 10)
        self:refreshCost(self.inputNum )
    end
end

-- 数字键盘清空
function MarketGoldBidDlg:deleteAllNumber(key)
    if key == "normal" then
        self.inputNum = 0
        self:refreshCost(self.inputNum)
    end
end

-- 数字键盘插入数字
function MarketGoldBidDlg:insertNumber(num, key)

    local function setNum(num, inputNum)
        if num == "00" then
            inputNum = inputNum * 100
        elseif num == "0000" then
            inputNum = inputNum * 10000
        else
            inputNum = inputNum * 10 + num
        end

        if inputNum >= PRICE_MAX then
            inputNum = PRICE_MAX
            gf:ShowSmallTips(CHS[3003069])
        end

        return inputNum
    end

    if key == "normal" then
        self.inputNum = setNum(num, self.inputNum)
        self:refreshCost(self.inputNum)
    end
end

-- 设置、刷新价格相关
function MarketGoldBidDlg:refreshCost(price, panelName)

    self.price = price

    -- 出售价格
    local sellPricePanel = self:getControl("MyPricePanel")
    if not price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, sellPricePanel)
        self:setCtrlVisible("DefaultLabel", true, sellPricePanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(price)
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, sellPricePanel)
        self:setCtrlVisible("DefaultLabel", false, sellPricePanel)
    end
end

-- 获取最低竞价
function MarketGoldBidDlg:getMinBuyPrice(data)

    -- 竞拍次数
    local paraExtra = data.extra or data.para_str
    local extraInfo = json.decode(paraExtra)
    if extraInfo.auction_count == 0 then
        return data.buyout_price
    end

    local curPrice = data.buyout_price

    local addPrice = 0
    if curPrice < 50000 then
        addPrice = 1000
    elseif curPrice < 200000 then
        addPrice = 2000
    elseif curPrice < 500000 then
        addPrice = 5000
    elseif curPrice < 20000000 then
        addPrice = 10000
    end

    return addPrice + curPrice
end

-- 设置界面
function MarketGoldBidDlg:setData(item, data)
    self.item = item
    self.tradeInfo = data
    self.curPage, self.sortType = DlgMgr:sendMsg("MarketGoldVendueDlg", "getPosInfo")
    self:setItemName(item)

    -- 当前价格
    local panel = self:getControl("NowPricePanel", nil, "PricePanel")
    local cashText, fonColor = gf:getArtFontMoneyDesc(data.buyout_price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, panel)

    -- 最低竞价
    local minPrice = self:getMinBuyPrice(data)
    local cashText, fonColor = gf:getArtFontMoneyDesc(minPrice)
    self:refreshCost(minPrice)

    self:setLabelText("NoteLabel", string.format(CHS[4101215], cashText)) -- 最低竞价：%s

    if MarketMgr:isVenduedByGoodsGid(data.id) then
        self:setCtrlVisible("Text1Panel", false)
        self:setCtrlVisible("Text2Panel", true)
    else
        self:setCtrlVisible("Text1Panel", true)
        self:setCtrlVisible("Text2Panel", false)
    end
end

-- 设置保证金
function MarketGoldBidDlg:setMargin()
    local cashText, fonColor = gf:getArtFontMoneyDesc(MARGIN_COST)
    local panel = self:getControl("DepositPanel")
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, panel)
end

-- 设置物品名称
function MarketGoldBidDlg:setItemName(item)
    local name = ""
    local level = 0
    if item and item.item_type then
        -- 物品
        name = item.name
        if item.item_type == ITEM_TYPE.EQUIPMENT then
            level = item.req_level
        else
            -- 法宝
            level = item.level
        end
    else
        -- 宠物
        name = item:queryBasic("name")
        level = item:queryBasicInt("level")
    end

    local nameStr = string.format(CHS[4101216], name, level) -- 您当前将竞价：%s %d级
    self:setLabelText("NoticeLabel", nameStr)
end

function MarketGoldBidDlg:getPageStr()
    if not self.curPage then  return end

    local page_str = ""

    if self.curPage < 1 then
        self.curPage = 1
    end

    if self.upSort then
        page_str = string.format("%d;%d;%d;%s", self.curPage, MarketMgr.TRADE_GOLD_STATE.ON_SELL_VENDUE, 1, self.sortType or "price")
    else
        page_str = string.format("%d;%d;%d;%s", self.curPage, MarketMgr.TRADE_GOLD_STATE.ON_SELL_VENDUE, 2, self.sortType or "price")
    end

    return page_str
end

function MarketGoldBidDlg:onConfirmButton(sender, eventType)

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.price then
        gf:ShowSmallTips(CHS[4101217])    -- 请输入竞价。
        return
    end

    local minPrice = self:getMinBuyPrice(self.tradeInfo)
    if self.price < minPrice then
        gf:ShowSmallTips(string.format(CHS[4101218], minPrice))  -- 竞拍当前商品最少需要加价%d元宝。
        self:refreshCost(minPrice)
        return
    end

    if self.tradeInfo and self.tradeInfo.is_my_goods == 1 then
        gf:ShowSmallTips(CHS[4101243])  -- 道友，这是你自己出售的商品哦。
        return
    end

    if self.tradeInfo and self.tradeInfo.appointee_name == Me:queryBasic("name") then
        gf:ShowSmallTips(CHS[4101245])  -- 你当前是最高竞价者，无法竞拍。
        return
    end


    if not MarketMgr:isVenduedByGoodsGid(self.tradeInfo.id) then
        if Me:getGoldCoin() > self.price and Me:getGoldCoin() < self.price + MARGIN_COST then
            -- 金元宝不足
            gf:ShowSmallTips(CHS[4101244])  -- 当前拥有元宝不足以支付保证金。
            return
        end
    end

    local path_str = DlgMgr:sendMsg("MarketGoldVendueDlg", "getKeyStr")
    local type = MarketMgr.STALL_BUY_COMMON
    if path_str == CHS[4101220] then        -- 我的竞拍__
        type = MarketMgr.STALL_BUY_AUCTION
        path_str = ""
        page_str = ""
    end

    if DlgMgr:getDlgByName("MarketGoldCollectionDlg") then
        type = MarketMgr.STALL_BUY_COLLECT
        path_str = ""
        page_str = ""
    end


    local data = {goods_id = self.tradeInfo.id, path_str = path_str, page_str = self:getPageStr(), old_price = self.tradeInfo.buyout_price, new_price = self.price, type = type}

    gf:CmdToServer("CMD_GOLD_STALL_BID_GOODS", data)
end

function MarketGoldBidDlg:MSG_GOLD_STALL_BUY_RESULT()
    self:onCloseButton()
end


return MarketGoldBidDlg
