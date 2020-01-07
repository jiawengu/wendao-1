-- MarketCollectionDlg.lua
-- Created by songcw
-- 集市收藏界面

local MarketCollectionDlg = require('dlg/MarketCollectionDlg')
local MarketGoldCollectionDlg = Singleton("MarketGoldCollectionDlg", MarketCollectionDlg)

function MarketGoldCollectionDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketCollectionDlg")
end

-- 设置所有hook消息
function MarketGoldCollectionDlg:setAllHookMsgs()
    self:hookMsg("MSG_GOLD_STALL_GOODS_STATE")
    self:hookMsg("MSG_SAFE_LOCK_INFO")
    self:hookMsg("MSG_UPDATE")

    self:hookMsg("MSG_GOLD_STALL_RUSH_BUY_OPEN")
end

function MarketGoldCollectionDlg:openSearchDlg()
    DlgMgr:openDlg("MarketGoldSearchDlg")
end

-- 搜藏物品状态
function MarketGoldCollectionDlg:MSG_GOLD_STALL_GOODS_STATE()
    self:MSG_MARKET_CHECK_RESULT()
end

function MarketGoldCollectionDlg:cleanClassData()
  --  MarketMgr:MSG_GOLD_STALL_GOODS_LIST({})
end

function MarketGoldCollectionDlg:setTradeTypeUI()

    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", true, self.itemCellCtrl)
    self:setCtrlVisible("CoinImage", false, self.itemCellCtrl)

    -- 设置玩家身上的金元宝
    local moneyPanel = self:getControl("MoneyPanel")
    self:setCtrlVisible("GoldImage", true, moneyPanel)
    self:setCtrlVisible("MoneyImage", false, moneyPanel)

    -- 珍宝标题
    self:setLabelText("TitleLabel_1", CHS[6000243])
    self:setLabelText("TitleLabel_2", CHS[6000243])

    self:setCtrlVisible("ViewButton", true)
    self:bindListener("ViewButton", self.onViewButton)
end

function MarketGoldCollectionDlg:onViewButton(sender, eventType)

    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4010213])
        return
    end

    if self.selectItemData.petShowName then
        MarketMgr:requireMarketGoodCard(self.selectItemData.id.."|"..self.selectItemData.endTime,
            MARKET_CARD_TYPE.VIEW_OTHERS, self.selectItemData, true, true, self:tradeType())
    else
        MarketMgr:requireMarketGoodCard(self.selectItemData.id.."|"..self.selectItemData.endTime,
            MARKET_CARD_TYPE.VIEW_OTHERS, self.selectItemData, nil, true, self:tradeType())
    end


end

function MarketGoldCollectionDlg:onMoneyPanel()
    DlgMgr:openDlg("OnlineRechargeDlg")
end


-- 设置金钱
function MarketGoldCollectionDlg:setCashView()

    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23)
end

function MarketGoldCollectionDlg:tradeType()
    return MarketMgr.TradeType.goldType
end

function MarketGoldCollectionDlg:MSG_GOLD_STALL_RUSH_BUY_OPEN(data)
    self:MSG_STALL_RUSH_BUY_OPEN(data)
end

return MarketGoldCollectionDlg
