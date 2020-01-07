-- JungongShopDlg.lua
-- Created by sujl, Apr/15/2017
-- 军功商店

local SpecialBuyDlg = require("dlg/SpecialBuyDlg")
local JungongShopDlg = Singleton("JungongShopDlg", SpecialBuyDlg)
local shopLimit = 100

function JungongShopDlg:initData()
    self:setHavePanel()

    self.shopLimit = shopLimit

    self:hookMsg("MSG_YISHI_EXCHANGE_RESULT", JungongShopDlg)
end

function JungongShopDlg:getCfgFileName()
    return ResMgr:getDlgCfg("InvadeBuyDlg")
end

function JungongShopDlg:refreshTotalValuePanel(totalValue)

    local costStr = gf:getMoneyDesc(totalValue, true)

    local pricePanel = self:getControl("TotalValuePanel")
    if totalValue > YiShiMgr:getMerit() then
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.RED)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    else
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.WHITE)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    end
end

function JungongShopDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
        self.clickNum = self.clickNum  + 1  -- 点击次数，不包括长按
    elseif self.clickNum < 4 then
        self.clickNum = 0
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end

end

function JungongShopDlg:doBuy(num)
    local totalCost = self.goods[self.pickGoods].price * num
    local name = self.goods[self.pickGoods].name
    if YiShiMgr:getMerit() < totalCost then
        -- 军功不足，购买失败
        gf:ShowSmallTips(CHS[2000225])
        return
    end


    local showMessage = string.format(CHS[2000226], totalCost, num, InventoryMgr:getUnit(name), name)

    gf:confirm(showMessage, function()
        -- 发送购买指令
        gf:CmdToServer("CMD_YISHI_EXCHANGE", {
            name = name,
            amount = num,
        })
    end)
end

-- 设置拥有的军功
function JungongShopDlg:setHavePanel()
    local ownPanel = self:getControl("HavePanel")

    local haveText = gf:getArtFontMoneyDesc(YiShiMgr:getMerit())
    self:setNumImgForPanel("HaveTextPanel", ART_FONT_COLOR.DEFAULT, haveText, haveText, LOCATE_POSITION.MID, 23, ownPanel)
end

function JungongShopDlg:MSG_YISHI_EXCHANGE_RESULT(data)
    -- 设置拥有的军功
    self:setHavePanel()
end

return JungongShopDlg