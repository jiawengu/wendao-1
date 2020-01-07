-- ChildStoreMoneyDlg.lua
-- Created by songcw Mar/02/2019
-- 娃娃生产结果界面

local ChildStoreMoneyDlg = Singleton("ChildStoreMoneyDlg", Dialog)

local MAX_LIMIT = 200000000

function ChildStoreMoneyDlg:init(data)
    self:bindListener("DrawButton", self.onDrawButton)
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("MoneyImage", self.onCashButton, "UserCashPanel")

    self:bindNumInput("AddPanel")

    self.data = data
    self.buyNum = nil

    self:setLabelText("Label", data.name, "NamePanel")

    self:setBasicInfo()
    self:updateAddCash()

    self:bindFloatingEvent("RulePanel")

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_CHILD_INFO")
end

-- 数字键盘插入数字
function ChildStoreMoneyDlg:insertNumber(num)
    if num <= 0 then num = 1 end

    self.buyNum = num

    local tips = ""

    local childCash = math.min(self.data.money, MAX_LIMIT)

    if self.buyNum + childCash > MAX_LIMIT  then
        self.buyNum = MAX_LIMIT - childCash
        tips = CHS[4010425]
    end

    if self.buyNum > Me:queryBasicInt("cash") then
        self.buyNum = Me:queryBasicInt("cash")
        tips = CHS[4010424]
    end

    if tips ~= "" then
        gf:ShowSmallTips(tips)
    end

    DlgMgr:sendMsg('SmallNumInputDlg', 'setInputValue', self.buyNum)

    self:updateAddCash()
end

function ChildStoreMoneyDlg:updateAddCash()

    if self.buyNum then
        local storeMoney = self.buyNum
        local storeMoneyStr, storeMoneyColor = gf:getArtFontMoneyDesc(storeMoney)
        self:setNumImgForPanel("DepositNumberLabel", storeMoneyColor, storeMoneyStr, false, LOCATE_POSITION.MID, 23, "AddPanel")
        self:setCtrlVisible("DefaultLabel", false, "AddPanel")
    end

end

function ChildStoreMoneyDlg:setBasicInfo()
    local money = Me:queryBasicInt("cash")
    local moneyStr, moneyColor = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("CashNumberLabel", moneyColor, moneyStr, false, LOCATE_POSITION.MID, 23, "UserCashPanel")

    local storeMoney = self.data.money
    local storeMoneyStr, storeMoneyColor = gf:getArtFontMoneyDesc(storeMoney)
    self:setNumImgForPanel("DepositNumberLabel", storeMoneyColor, storeMoneyStr, false, LOCATE_POSITION.MID, 23, "DepositPanel")

--    self:setImagePlist("MoneyImage", ResMgr:getStoreMoneyIcon(storeMoney), "UserCashPanel")
end

function ChildStoreMoneyDlg:onDrawButton(sender, eventType)
end

function ChildStoreMoneyDlg:onSaveButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.buyNum or self.buyNum == 0 then
        gf:ShowSmallTips(CHS[4010426])-- 请输入要存入的金钱数量。
        return
    end
    gf:CmdToServer("CMD_CHILD_PUT_MONEY", {child_id = self.data.id, child_name = self.data.name, money = self.buyNum})
    self:onCloseButton()
end

function ChildStoreMoneyDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function ChildStoreMoneyDlg:onCashButton(sender, eventType)
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

function ChildStoreMoneyDlg:MSG_UPDATE()
    self:setBasicInfo()
end

function ChildStoreMoneyDlg:MSG_CHILD_INFO(data)
    for i = 1, data.count do
        local ret = data.childInfo[i]
        if ret.id == self.data.id then
            self.data = ret
            self:setBasicInfo()
            self:updateAddCash()
        end
    end

end



return ChildStoreMoneyDlg
