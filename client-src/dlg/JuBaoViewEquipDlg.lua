-- JuBaoViewEquipDlg.lua
-- Created by songcw Feb/22/2017
-- 聚宝斋，查看装备

local JuBaoViewEquipDlg = Singleton("JuBaoViewEquipDlg", Dialog)

function JuBaoViewEquipDlg:init()
    self:bindListener("BuyButton", self.onBuyButton, "CommonSellPanel")

    self:bindListener("VendueButton", self.onBuyButton, "VendueSellPanel")
    self:bindListener("VendueButton", self.onBuyButton, "VenduePublicPanel")

    self:bindListener("NoteButton", self.onNoteVendueButton, "VendueSellPanel")
    self:bindListener("NoteButton", self.onNoteVendueButton, "VenduePublicPanel")
    self.goods_gid = nil
end

function JuBaoViewEquipDlg:setDlgData(equip, tradingData, priceData)
    self.goods_gid = tradingData.goods_gid

    if priceData and priceData.para then
        -- 需要将竞拍次数从json格式中转出来
        local info = json.decode(priceData.para)
        priceData.auction_count = info.auction_count
    end

    TradingMgr:setPriceInfo(self, priceData)

    self:setCtrlVisible("CommonSellPanel", TradingMgr:isDisplayNormal(priceData.sell_buy_type))
    self:setCtrlVisible("VenduePublicPanel", priceData.sell_buy_type == TRADE_SBT.AUCTION)

    self:setEquipInfo(equip)
end

function JuBaoViewEquipDlg:setEquipInfo(equip)
    self:setCtrlVisible("ArtifactInfoPanel", false)
    self:setCtrlVisible("EquipmentInfoPanel", false)
    self:setCtrlVisible("JewelryInfoPanel", false)

    if equip.item_type == ITEM_TYPE.EQUIPMENT then
        if EquipmentMgr:isJewelry(equip) then
            -- 首饰
            self:setCtrlVisible("JewelryInfoPanel", true)
            EquipmentMgr:setJewelryForJubao(self, equip)
        else
            -- 装备
            self:setCtrlVisible("EquipmentInfoPanel", true)
            EquipmentMgr:setEquipForJubao(self, equip)
        end
    elseif equip.item_type == ITEM_TYPE.ARTIFACT then
        -- 法宝
        self:setCtrlVisible("ArtifactInfoPanel", true)
        EquipmentMgr:setArtifactForJubao(self, equip)
    end
end

function JuBaoViewEquipDlg:onNoteVendueButton(sender, eventType)
    TradingMgr:showVendueTipsInfo(sender)
end


function JuBaoViewEquipDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end
    TradingMgr:tryBuyItem(self.goods_gid, self.name)
    --[[
    local data = TradingMgr:getTradGoodsData(self.goods_gid, "info")
    if data.state == TRADING_STATE.SHOW then
        local tips = CHS[4000400] .. "\n" .. CHS[4101052]
        gf:confirmEx(tips, CHS[4101053], function ()
            TradingMgr:modifyCollectGoods(self.goods_gid, 1)
            TradingMgr:askAutoLoginToken(self.name, self.goods_gid)
        end, CHS[4101054])
        return
    end

    gf:confirm(CHS[4200205],function ()
        TradingMgr:askAutoLoginToken(self.name, self.goods_gid)
    end)
    --]]
end

function JuBaoViewEquipDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

return JuBaoViewEquipDlg
