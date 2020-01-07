-- StoreMoneyDlg.lua
-- Created by yangym Oct/31/2016
-- 钱庄界面

local StoreMoneyDlg = Singleton("StoreMoneyDlg", Dialog)

local MAX_STORE = 2000000000
local MAX_CASH = 2000000000

function StoreMoneyDlg:init()
    self:bindListener("MoneyImage", self.onDepositButton, "DepositPanel")
    self:bindListener("MoneyImage", self.onCashButton, "CashPanel")
    self:bindListener("DrawButton", self.onDrawButton, "ButtonPanel")
    self:bindListener("SaveButton", self.onSaveButton, "ButtonPanel")
    self:bindListener("CashNumberLabel", self.onDrawButton, "CashPanel")
    self:bindListener("DepositNumberLabel", self.onSaveButton, "DepositPanel")
    
    self:setBasicInfo()
    
    self:hookMsg("MSG_UPDATE")
end

function StoreMoneyDlg:setBasicInfo()
    local money = Me:queryBasicInt("cash")
    local moneyStr, moneyColor = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("CashNumberLabel", moneyColor, moneyStr, false, LOCATE_POSITION.MID, 23)
    
    local storeMoney = StoreMgr:getStoreMoney()
    local storeMoneyStr, storeMoneyColor = gf:getArtFontMoneyDesc(storeMoney)
    self:setNumImgForPanel("DepositNumberLabel", storeMoneyColor, storeMoneyStr, false, LOCATE_POSITION.MID, 23)

    self:setImagePlist("MoneyImage", ResMgr:getStoreMoneyIcon(storeMoney), "MainPanel")
end

function StoreMoneyDlg:onCashButton(sender, eventType)
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

function StoreMoneyDlg:onSaveButton(sender, eventType)
    local money = Me:queryBasicInt("cash")
    local storeMoney = StoreMgr:getStoreMoney()
    
    if money == 0 then
        gf:ShowSmallTips(CHS[7000112])
        return
    end
    
    if storeMoney >= MAX_STORE then
        gf:ShowSmallTips(CHS[7000113])
        return
    end
    
    DlgMgr:openDlg("StoreMoneyImportDlg")
end

function StoreMoneyDlg:onDrawButton(sender, eventType)
    local money = Me:queryBasicInt("cash")
    local storeMoney = StoreMgr:getStoreMoney()
    
    if storeMoney == 0 then
        gf:ShowSmallTips(CHS[7000114])
        return
    end
    
    if money >= MAX_CASH then
        gf:ShowSmallTips(CHS[7000115])
        return
    end
    
    local dlg = DlgMgr:openDlg("StoreMoneyImportDlg")
    dlg:setInterfaceDraw()
end

function StoreMoneyDlg:MSG_UPDATE()
    self:setBasicInfo()
end
return StoreMoneyDlg