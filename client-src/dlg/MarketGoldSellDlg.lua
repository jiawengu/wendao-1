-- MarketSellDlg.lua
-- Created by zhengjh Apr/20/2016
-- 珍宝摆摊界面

local MarketSellDlg = require('dlg/MarketSellDlg')
local MarketGoldSellDlg = Singleton("MarketGoldSellDlg", MarketSellDlg)

function MarketGoldSellDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketSellDlg")
end

function MarketGoldSellDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", true, self.sellItemCtrl)
    self:setCtrlVisible("CoinImage", false, self.sellItemCtrl)

    -- 设置玩家身上的金元宝
    local moneyPanel = self:getControl("MoenyPanel")
    self:setCtrlVisible("GoldImage", true, moneyPanel)
    self:setCtrlVisible("MoneyImage", false, moneyPanel)

    -- 收入金元宝
    local earningPanel = self:getControl("MarketMoneyPanel")
    self:setCtrlVisible("GoldImage", true, earningPanel)
    self:setCtrlVisible("MoneyImage", false, earningPanel)

    -- 珍宝标题
    self:setLabelText("TitleLabel_1", CHS[6000243])
    self:setLabelText("TitleLabel_2", CHS[6000243])

    -- 珍宝不显示卡套标签页
    self:setCtrlVisible("ChangeCardDlgCheckBox", false)

    -- 不等价交易提示
    self:setLabelText("InfoLabel", CHS[7001022], "InfoPanel2")
end

-- 设置所有hook消息
function MarketGoldSellDlg:setAllHookMsgs()
    self:hookMsg("MSG_GOLD_STALL_MINE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INSIDER_INFO")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_SET_OWNER")

    self:hookMsg("MSG_GOLD_STALL_GOODS_STATE")
end

function MarketGoldSellDlg:onBuyCoinButton()
    DlgMgr:openDlg("OnlineRechargeDlg")
end

-- 设置金钱
function MarketGoldSellDlg:updateCashView()
    -- 设置角色身上的金钱
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    local panel = self:getControl("MoneyPanel")
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, panel)
end

function MarketGoldSellDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("TreasureRuleDlg")
    dlg:setRuleType("boothRule")
end

function MarketGoldSellDlg:onDealRecordButton(sender, eventType)
    DlgMgr:openDlg("MarketGoldRecordDlg")
end

function MarketGoldSellDlg:MSG_GOLD_STALL_MINE()
    self:MSG_STALL_MINE()
end

function MarketGoldSellDlg:MSG_GOLD_STALL_GOODS_STATE(data)
    -- 处理拍卖，物品竞拍价格变化时，属性当前是商品价格
    local listPanel = self:getControl("ItemListPanel")
    local items = listPanel:getChildren()
    if items and items[1] then
        local scoreView = items[1]
        local contentLayer = scoreView:getChildByName("contentLayer")
        if not contentLayer then return end

        for i = 1, data.count do
            if contentLayer:getChildByName(data.itemList[i].id) then
                local cell = contentLayer:getChildByName(data.itemList[i].id)
                -- 只刷新价格！
                -- 只处理拍卖的价格
                local price = data.itemList[i].price
                local sell_buy_type = data.itemList[i].sell_type
                if (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION_BUY) then
                    -- 拍卖显示当前价格
                    price = data.itemList[i].buyout_price
                elseif (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_BUY) and data.appointee_name ~= Me:queryBasic("name") then
                    -- 指定交易，指定对象不是我，显示一口价
                    price = data.itemList[i].buyout_price
                end

                -- 过期了设置回原价
                if data.itemList[i].status == 3 then
                    price = data.itemList[i].price
                    self:setCtrlVisible("TimeoutImage", true, cell)

                    -- 管理器中不能直接刷新，因为在其他界面需要之前状态
                    MarketMgr:setSelectItemByField("status", data.itemList[i].status)
                end

                local str, color = gf:getMoneyDesc(price, true)
                local coinLabel = self:getControl("CoinLabel", nil, cell)
                coinLabel:setColor(color)
                coinLabel:setString(str)
                self:setLabelText("CoinLabel2", str, cell)
            end
        end
    end
end

function MarketGoldSellDlg:tradeType()
    return MarketMgr.TradeType.goldType
end

return MarketGoldSellDlg
