-- PetHorseBuyFenglingDlg.lua
-- Created by zhengjh Sep/29/2016
-- 购买风灵丸

local PetHorseBuyFenglingDlg = Singleton("PetHorseBuyFenglingDlg", Dialog)
local PRICE = 1766

function PetHorseBuyFenglingDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)

    self:bindListener("GoldCheckBox", self.onGoldCheckBox)
    self:setCheck("GoldCheckBox", InventoryMgr.isUseGoldBuyFenglingwan)
    self:refreshCoinIcon()

    -- 设置价格
    local price = gf:getMoneyDesc(PRICE, true)
    self:setLabelText("Label1", price, "BuyButton")
    self:setLabelText("Label2", price, "BuyButton")
    self:setLabelText("Label1", price, "InfoPanel")
end

function PetHorseBuyFenglingDlg:setPetNo(no)
    self.petNo = no
end

function PetHorseBuyFenglingDlg:onGoldCheckBox(sender, envetType)
    if sender:getSelectedState() == true then
        InventoryMgr.isUseGoldBuyFenglingwan = true
        gf:ShowSmallTips(CHS[6000527])
    else
        InventoryMgr.isUseGoldBuyFenglingwan = false
        gf:ShowSmallTips(CHS[6000526])
    end
    self:refreshCoinIcon()
end

function PetHorseBuyFenglingDlg:refreshCoinIcon()
    self:setCtrlVisible("GoldImage", InventoryMgr.isUseGoldBuyFenglingwan, "BuyButton")
    self:setCtrlVisible("SilverImage", not InventoryMgr.isUseGoldBuyFenglingwan, "BuyButton")

    self:setCtrlVisible("GoldImage", InventoryMgr.isUseGoldBuyFenglingwan, "InfoPanel")
    self:setCtrlVisible("SilverImage", not InventoryMgr.isUseGoldBuyFenglingwan, "InfoPanel")
end

function PetHorseBuyFenglingDlg:onBuyButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return false
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        return false
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton", sender, eventType) then
        return
    end


    if self:isCheck("GoldCheckBox") and Me:queryBasicInt("gold_coin") < PRICE then
        gf:askUserWhetherBuyCoin("gold_coin")
        return
    end

    if not self:isCheck("GoldCheckBox") and Me:getTotalCoin() < PRICE then
        gf:askUserWhetherBuyCoin()
        return
    end


    local data = {}
    data.no = self.petNo

    local tip = ""
    local silverCoin = Me:queryInt("silver_coin")
    if self:isCheck("GoldCheckBox") then
        tip = string.format(CHS[6000528], PRICE)
        data.type = "gold_coin"
    else
        if silverCoin == 0 then
            tip = string.format(CHS[6000529], PRICE)
        else
            if silverCoin >= PRICE then
                tip = string.format(CHS[6000531], PRICE)
            else
                local costGodld = PRICE - silverCoin
                tip = string.format(CHS[6000530], silverCoin, costGodld)
            end
        end

        data.type = ""
   end

    gf:confirm(tip, function ()
        gf:CmdToServer("CMD_ADD_FENGLINGWAN", data)
    end)
end

return PetHorseBuyFenglingDlg
