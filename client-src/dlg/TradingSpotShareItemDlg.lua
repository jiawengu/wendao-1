-- TradingSpotShareItemDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站货品名片界面

local TradingSpotItemInfoBasicDlg = require('dlg/TradingSpotItemInfoBasicDlg')
local TradingSpotShareItemDlg = Singleton("TradingSpotShareItemDlg", TradingSpotItemInfoBasicDlg)

-- 界面数据类型
local DLG_DATA_TYPE = TradingSpotMgr:getDetailListTypeCfg()

function TradingSpotShareItemDlg:init(data)
    self.goodsInfo = data

    TradingSpotItemInfoBasicDlg.init(self, self.root)

    self.dlgType = nil
    self.radioGroup:setItems(self, { "RecentFloatCheckBox", "HistoryFloatCheckBox", "ProfitRecordCheckBox" }, self.onTypeCheckBox)
    self.radioGroup:selectRadio(DLG_DATA_TYPE.LINE)

    self:bindListener("BuyButton", self.onBuyButton)
end

function TradingSpotShareItemDlg:setData(data)
    TradingSpotItemInfoBasicDlg.setData(self, data)
    self:refreshCharInfo()
end

function TradingSpotShareItemDlg:refreshCharInfo()
    self.goodsInfo = TradingSpotMgr:getCharCardData()
    if not self.goodsInfo then return end

    local panel = self:getControl("UpPanel")
    local itemName, _ = TradingSpotMgr:getItemInfo(self.goodsInfo.goods_id)
    self:setLabelText("ItemLabel", string.format(CHS[7190476], itemName), panel)
    self:setLabelText("NameLabel", string.format(CHS[7190477], self.goodsInfo.char_name), panel)
end

-- 获取当前列表下一个商品的goods_id
function TradingSpotShareItemDlg:getNextGoodsId(goodsId, isLeft)
    return DlgMgr:sendMsg("TradingSpotSharePlanDlg", "getNextGoodsId", goodsId, isLeft)
end

function TradingSpotShareItemDlg:cleanup()
    self.dlgType = nil
    self.goodsInfo = nil
    self.startNum = nil
    self.goodsListInfo = nil

    if self.pen then
        self.pen:clear()
        self.pen:removeFromParent()
        self.pen = nil
    end
end

function TradingSpotShareItemDlg:onBuyButton(sender, eventType)
    if TradingSpotMgr:checkCanOepnTradingSpot() then
        TradingSpotMgr:openTradingSpotAndSelectItem(self.goodsInfo.goods_id)
        DlgMgr:closeDlg(self.name)
    end
end

return TradingSpotShareItemDlg
