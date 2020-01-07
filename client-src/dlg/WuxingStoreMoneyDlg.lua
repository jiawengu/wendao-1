-- WuxingStoreMoneyDlg.lua
-- Created by haungzz Jan/31/2018
-- 五行竞猜仓库界面

local WuxingStoreMoneyDlg = Singleton("WuxingStoreMoneyDlg", Dialog)

local DLG_TYPE = {
    WXJC = 1, -- 五行竞猜
    SGHZ = 2, -- 商贾货站
}

function WuxingStoreMoneyDlg:init()
    self:bindListener("DrawButton", self.onDrawButton)
    self:bindListener("DepositNumberLabel", self.onTips)
    self:bindListener("CashNumberLabel", self.onDrawButton)

    self.storeCash = 0
    self.tips = CHS[5420278]

    self:updateCash("CashNumberLabel", Me:queryBasicInt("cash"))
    self:updateCash("DepositNumberLabel", self.storeCash)

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_OPEN_STORE_DIALOG")
    self:hookMsg("MSG_TRADING_SPOT_UPDATE_MONEY")
end

function WuxingStoreMoneyDlg:updateCash(label, num)
    num = tonumber(num) or 0
    local storeMoneyStr, storeMoneyColor = gf:getArtFontMoneyDesc(num)
    self:setNumImgForPanel(label, storeMoneyColor, storeMoneyStr, false, LOCATE_POSITION.MID, 23)

    if label == "DepositNumberLabel" then
        self:setImagePlist("CurMoneyImage", ResMgr:getStoreMoneyIcon(num))
    end
end

function WuxingStoreMoneyDlg:onTips(sender, eventType)
    gf:ShowSmallTips(self.tips)
end

function WuxingStoreMoneyDlg:onDrawButton(sender, eventType)
    -- 若当前仓库存款金钱为0，给予弹出提示
    if self.storeCash == 0 then
        gf:ShowSmallTips(CHS[5420276])
        return
    end

    -- 若当前背包携带金钱已达上限20亿，给予弹出提示
    local myCash = Me:queryBasicInt("cash")
    if myCash >= Const.MAX_MONEY_IN_BAG then
        gf:ShowSmallTips(CHS[5420277])
        return
    end

    if self.dlgType == DLG_TYPE.SGHZ then
        TradingSpotMgr:requestGetMoney()
    else
        gf:CmdToServer("CMD_FETCH_STORE_SURPLUS", {})
    end
end

function WuxingStoreMoneyDlg:updateTips()
    if self.dlgType == DLG_TYPE.SGHZ then
        self.tips = CHS[7190481]
        self:setLabelText("TitleLabel_1", CHS[7190480], "BKPanel")
        self:setLabelText("TitleLabel_2", CHS[7190480], "BKPanel")
        self:setLabelText("TipsLabel", CHS[7190481], "TipsPanel")
    end
end

function WuxingStoreMoneyDlg:MSG_UPDATE(data)
    self:updateCash("CashNumberLabel", Me:queryBasicInt("cash"))
end

function WuxingStoreMoneyDlg:MSG_TRADING_SPOT_UPDATE_MONEY(data)
    self:updateCash("DepositNumberLabel", data.bank_money)
end

function WuxingStoreMoneyDlg:MSG_OPEN_STORE_DIALOG(data)
    self.dlgType = data.type
    self:updateTips()

    self.storeCash = tonumber(data.surplus)
    self:updateCash("DepositNumberLabel", self.storeCash)
end

return WuxingStoreMoneyDlg
