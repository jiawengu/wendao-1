-- ArtifactBuyDlg.lua
-- Created by 
-- 

local ArtifactBuyDlg = Singleton("ArtifactBuyDlg", Dialog)

local SINGLEPRICE = 418 -- 双倍点数的价格
local ONE_BUY_POINT = 200 -- 点击一次购买的点数

function ArtifactBuyDlg:init(data)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
    
    self.furnitureId = data.furnitureId
    self.furnitureX, self.furnitureY = data.pX, data.pY
    
    self.data = nil
    self.id = nil
end

function ArtifactBuyDlg:setData(data, id)
    self.data = data
    self.id = id
    self:initData()
end


function ArtifactBuyDlg:initData()
    local numberLabel = self:getControl("NumLabel")
    self.count = 1
    self:setCtrlEnabled("ReduceButton", false)
    self:setShopInfo()
end

function ArtifactBuyDlg:setShopInfo()
    -- 购买数量
    local numberLabel = self:getControl("NumLabel")
    numberLabel:setString(self.count)
    
    
    local numberLabel2 = self:getControl("NumLabel2")
    numberLabel2:setString(self.count)
    
    self:setLabelText("NumLabel", self.count)
    self:setLabelText("NumLabel2", self.count)

    -- 总价
    local totalParice = self.count * SINGLEPRICE
    local buyBtn = self:getControl("BuyButton")
    self:setLabelText("Label1", totalParice, buyBtn)
    self:setLabelText("Label2", totalParice, buyBtn)
    self:updateLayout("PricePanel")
end

function ArtifactBuyDlg:onReduceButton(sender, eventType)
    if not self.data then return end
    if self.count - 1 <= 0 then
        self:setCtrlEnabled("ReduceButton", false)
        return
    else
        self:setCtrlEnabled("ReduceButton", true)
    end

    self.count = self.count - 1
    self:setShopInfo()
end

function ArtifactBuyDlg:onAddButton(sender, eventType)
    if not self.data then return end
    if self.data.nimbus + (self.count + 1) * ONE_BUY_POINT > self.data.max_nimbus then
        gf:ShowSmallTips(CHS[4100674]) -- 购买后灵气值将超出上限，无法购买。
        return
    end
    
    self:setCtrlEnabled("ReduceButton", true)
    self.count = self.count + 1
    self:setShopInfo()
end

function ArtifactBuyDlg:onBuyButton(sender, eventType)
    local furn = HomeMgr:getFurnitureById(self.furnitureId)
    -- 目标家具已消失
    if not furn then
        gf:ShowSmallTips(CHS[5410041])
        ChatMgr:sendMiscMsg(CHS[5410041])
        self:onCloseButton()
        return
    end

    -- 对应家具位置已发生改变
    if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
        gf:ShowSmallTips(CHS[4200418])
        ChatMgr:sendMiscMsg(CHS[4200418])
        self:onCloseButton()
        return
    end
    
    local totalMoney = Me:getTotalCoin()

    if totalMoney < self.count * SINGLEPRICE then 
        gf:askUserWhetherBuyCoin()
        return
    end
    
    HomeMgr:cmdHouseUseFurniture(self.data.furniture_pos, "artifact_practice", "add_nimbus_by_coin", self.count)
    self:onCloseButton()
end

return ArtifactBuyDlg
