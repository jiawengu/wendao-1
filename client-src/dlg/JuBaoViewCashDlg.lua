-- JuBaoViewCashDlg.lua
-- Created by lixh2 Sep/27/2017
-- 聚宝斋金钱预览界面

local JuBaoViewCashDlg = Singleton("JuBaoViewCashDlg", Dialog)

function JuBaoViewCashDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
end

function JuBaoViewCashDlg:setData(data)
    self.goodsData = data
    self.goods_gid = data.goods_gid
    
    local cashText
    local fontColor
    
    -- 出售金钱
    local sellCount = tonumber(self.goodsData.goods_name)
    cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(sellCount))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "SellCashPanel")
    
    -- 出售价格
    local sellPrice = tonumber(self.goodsData.price)
    cashText = gf:getArtFontMoneyDesc(tonumber(sellPrice))
    self:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, "PricePanel") 
    self:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23, "PricePanel")
    
    -- 单价
    cashText, fontColor = gf:getArtFontMoneyDesc(math.floor(sellCount / sellPrice))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "PerValuePanel")
    
    -- 剩余时间 
    if tonumber(self.goodsData.state) == TRADING_STATE.SHOW then
        self:setLabelText("LeftLabel", CHS[4300194], "LeftTimePanel")
    elseif tonumber(self.goodsData.state) == TRADING_STATE.SALE then
        self:setLabelText("LeftLabel", CHS[4300195], "LeftTimePanel")
    end
    
    self:setLabelText("LeftLabel_2", TradingMgr:getLeftTime(self.goodsData.end_time - gf:getServerTime()), "LeftTimePanel")
end

function JuBaoViewCashDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end
    TradingMgr:tryBuyItem(self.goods_gid, self.name)
end

function JuBaoViewCashDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

return JuBaoViewCashDlg
