-- MarketPublicityDlg.lua
-- Created by zhengjh Aug/23/2015
-- 珍宝公示

local MarketPublicityDlg = require('dlg/MarketPublicityDlg')
local MarketGlodPublicityDlg = Singleton("MarketGlodPublicityDlg", MarketPublicityDlg)

function MarketGlodPublicityDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketPublicityDlg")
end

function MarketGlodPublicityDlg:cleanClassData()
    MarketMgr:MSG_GOLD_STALL_GOODS_LIST({sell_stage = 1})
end

function MarketGlodPublicityDlg:defaultCol()
    local gid = string.match(FriendMgr.requestInfo.gid, CHS[4010212])
    if FriendMgr.requestInfo and gid then
        self:onCollectionButton()
    end
end

function MarketGlodPublicityDlg:setTradeTypeUI()
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

    -- 通过名片打开时，可能没有设置
    MarketMgr:setTradeType(MarketMgr.TradeType.goldType)

    self:setCtrlVisible("ViewButton", true)
    self:bindListener("ViewButton", self.onViewButton)
    self:setCtrlVisible("UnlockButton", false)
    self:setCtrlVisible("PanicBuyButton", false)
end

-- 设置所有hook消息
function MarketGlodPublicityDlg:setAllHookMsgs()
    self:hookMsg("MSG_GOLD_STALL_GOODS_LIST")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GOLD_STALL_UPDATE_GOODS_INFO")
    self:hookMsg("MSG_GOLD_STALL_GOODS_STATE")

    self:hookMsg("MSG_GOLD_STALL_RUSH_BUY_OPEN")
end


-- 设置金钱
function MarketGlodPublicityDlg:setCashView()
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)
end


function MarketGlodPublicityDlg:onMoneyPanel()
    DlgMgr:openDlg("OnlineRechargeDlg")
end

-- 获取一级菜单的列表
function MarketGlodPublicityDlg:getFirstItemList()
    local list = gf:deepCopy(MarketMgr:getTreasureList())
    for i = #list, 1, -1 do
        if list[i] == CHS[3002143] then
            -- 公示不显示金钱标签
            table.remove(list, i)
        end
    end

    return list
end

function MarketGlodPublicityDlg:openSearchDlg()
    DlgMgr:openDlg("MarketGoldSearchDlg")
end


function MarketGlodPublicityDlg:onViewButton(sender, eventType)

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


-- 某一类物品逛摊数据
function MarketGlodPublicityDlg:MSG_GOLD_STALL_GOODS_LIST(data)
    self:MSG_STALL_ITEM_LIST(data)
end

-- 刷新某个物品状态
function MarketGlodPublicityDlg:MSG_GOLD_STALL_UPDATE_GOODS_INFO()
    self:MSG_STALL_UPDATE_GOODS_INFO()
end

-- 收藏某个，返回的数据
function MarketGlodPublicityDlg:MSG_GOLD_STALL_GOODS_STATE(data)
    self:MSG_MARKET_CHECK_RESULT(data)
end

function MarketGlodPublicityDlg:tradeType()
    return MarketMgr.TradeType.goldType
end
function MarketGlodPublicityDlg:MSG_GOLD_STALL_RUSH_BUY_OPEN(data)
    self:MSG_STALL_RUSH_BUY_OPEN(data)
end

return MarketGlodPublicityDlg
