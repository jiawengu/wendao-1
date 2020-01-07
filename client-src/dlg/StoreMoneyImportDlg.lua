-- StoreMoneyImportDlg.lua
-- Created by yangym Oct/31/2016
-- 取钱/存钱界面

local StoreMoneyImportDlg = Singleton("StoreMoneyImportDlg", Dialog)

local MAX_STORE = 2000000000
local MAX_CASH = 2000000000

function StoreMoneyImportDlg:init()
    -- 绑定点击购买金钱的事件
    local cashPanelSaving = self:getControl("CashPanel", nil, "SaveInfoPanel")
    local cashPanelDrawing = self:getControl("CashPanel", nil, "DrawInfoPanel")
    
    self:bindListener("MoneyImage", self.onCashButton, cashPanelSaving)
    -- self:bindListener("CashNumberLabel", self.onCashButton, cashPanelSaving)
    
    self:bindListener("MoneyImage", self.onCashButton, cashPanelDrawing)
    -- self:bindListener("CashNumberLabel", self.onCashButton, cashPanelDrawing)
    
    -- 绑定数字键盘点击事件
    self:bindListener("1Button", self.onButton)
    self:bindListener("2Button", self.onButton)
    self:bindListener("3Button", self.onButton)
    self:bindListener("4Button", self.onButton)
    self:bindListener("5Button", self.onButton)
    self:bindListener("6Button", self.onButton)
    self:bindListener("7Button", self.onButton)
    self:bindListener("8Button", self.onButton)
    self:bindListener("9Button", self.onButton)
    self:bindListener("DeleteButton", self.onDeleteButton)
    self:bindListener("ComfireButton", self.onConfirmButton)
    self:bindListener("0Button", self.onButton)
    self:bindListener("00Button", self.onButton)
    self:bindListener("0000Button", self.onButton)
    self:bindListener("AllButton", self.onAllButton)
    self:bindListener("AllDeleteButton", self.onAllDeleteButton)
    self.inputValue = 0
    
    self.isSaving = true
    self:getControl("SaveInfoPanel"):setVisible(true)
    self:getControl("DrawInfoPanel"):setVisible(false)
    
    self:setBasicInfo()
    self:updateMoneyNum()
    
    self:hookMsg("MSG_UPDATE")
end

function StoreMoneyImportDlg:setInterfaceDraw()
    -- 界面变为取款界面
    self:setLabelText("TitleLabel_1", CHS[7000104], "TitleImage")
    self:setLabelText("TitleLabel_2", CHS[7000104], "TitleImage")

    self:getControl("SaveInfoPanel"):setVisible(false)
    self:getControl("DrawInfoPanel"):setVisible(true)
    

    self.isSaving = false
    
    self:setBasicInfo()
    self:updateMoneyNum()
end

function StoreMoneyImportDlg:setBasicInfo()
    -- 设置基本信息，包括
    local panelName
    if self.isSaving then
        panelName = "SaveInfoPanel"
    else
        panelName = "DrawInfoPanel"
    end
    
    local cashPanel = self:getControl("CashPanel", nil, panelName)
    local depositPanel = self:getControl("DepositPanel", nil, panelName)
    
    local money = Me:queryBasicInt("cash")
    local moneyStr, moneyColor = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("CashNumberLabel", moneyColor, moneyStr, false, LOCATE_POSITION.MID, 23, cashPanel)
    self.cashTextNum = money

    local storeMoney = StoreMgr:getStoreMoney()
    local storeMoneyStr, storeMoneyColor = gf:getArtFontMoneyDesc(storeMoney)
    self:setNumImgForPanel("DepositNumberLabel", storeMoneyColor, storeMoneyStr, false, LOCATE_POSITION.MID, 23, depositPanel)
    self.storeMoneyTextNum = storeMoney
end

function StoreMoneyImportDlg:updateMoneyNum()
    -- 更新输入框
    local labelName
    if self.isSaving then
        labelName = "SaveNumberLabel"
    else
        labelName = "DrawNumberLabel"
    end

    self.inputValue = math.max(self.inputValue, 0)
    local moneyStr, moneyColor = gf:getArtFontMoneyDesc(self.inputValue)
    self:setNumImgForPanel(labelName, moneyColor, moneyStr, false, LOCATE_POSITION.MID, 23)
end

function StoreMoneyImportDlg:onButton(sender, eventType)
    -- 输入框输入数字
    local insertNumber = sender:getTag()
    local money = Me:queryBasicInt("cash")
    local storeMoney = StoreMgr:getStoreMoney()
    if self.isSaving then  --存钱
        if self.inputValue == math.max(money, 0) then
            gf:ShowSmallTips(string.format(CHS[7000106], gf:getMoneyDesc(money)))
            return
        end
        
        if self.inputValue + storeMoney == MAX_STORE then
            if storeMoney == MAX_STORE then
                gf:ShowSmallTips(CHS[7000117])
                return
            end
            
            gf:ShowSmallTips(string.format(CHS[7000107], gf:getMoneyDesc(self.inputValue)))
            return
        end
        
        if insertNumber == 10 then  -- 00按钮
            self.inputValue = self.inputValue * 100
        elseif insertNumber == 11 then  -- 0000按钮
            self.inputValue = self.inputValue * 10000
        else
            self.inputValue = self.inputValue * 10 + insertNumber
        end
        
        -- 要存的钱超过背包携带
        self.inputValue = math.max(self.inputValue, 0)
        self.inputValue = math.min(self.inputValue, money)
        -- 如果存入，会超过钱庄的最大存钱限度
        self.inputValue = math.min(self.inputValue, MAX_STORE - storeMoney)
        
    else  -- 取钱
        if self.inputValue >= storeMoney then
            local str = gf:getMoneyDesc(storeMoney)
            gf:ShowSmallTips(string.format(CHS[7000108], gf:getMoneyDesc(storeMoney)))
            return
        end
        
        if self.inputValue + money == MAX_CASH then
            if money == MAX_CASH then
                gf:ShowSmallTips(CHS[7000118])
                return
            end
            
            gf:ShowSmallTips(string.format(CHS[7000109], gf:getMoneyDesc(self.inputValue)))
            return
        end
        
        if insertNumber == 10 then  -- 00按钮
            self.inputValue = self.inputValue * 100
        elseif insertNumber == 11 then  -- 0000按钮
            self.inputValue = self.inputValue * 10000
        else
            self.inputValue = self.inputValue * 10 + insertNumber
        end
        
        -- 要取的钱超过金库中存储金钱
        if self.inputValue > storeMoney then
            self.inputValue = storeMoney
        end
        
        -- 如果取出，会超过背包的最大携带限度
        if self.inputValue + money > MAX_CASH then
            self.inputValue = MAX_CASH - money
        end
    end
    
    self:updateMoneyNum()
end

function StoreMoneyImportDlg:onDeleteButton(sender, eventType)
    -- 退格操作
    if self.inputValue == 0 then
         return
    end
    
    self.inputValue = math.floor(self.inputValue / 10)
    self:updateMoneyNum()
end

function StoreMoneyImportDlg:onConfirmButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    
    if self.inputValue == 0 then
        gf:ShowSmallTips(CHS[7000204])
        return
    end
    
    local money = Me:queryBasicInt("cash")
    local storeMoney = StoreMgr:getStoreMoney()   
    
    if self.isSaving then
        
        -- 向服务器发送存款消息
        -- id参数本身用于服务器判断NPC是否在附近，现在暂不使用，故设为0
        gf:CmdToServer("CMD_DEPOSIT", {id = 0, money = self.inputValue})
    else
        
        -- 向服务器发送取款消息
        gf:CmdToServer("CMD_WITHDRAW", {id = 0, money = self.inputValue})
        
    end
end

function StoreMoneyImportDlg:onAllDeleteButton()
    self.inputValue = 0
    self:updateMoneyNum()
end

function StoreMoneyImportDlg:onAllButton()
    local cash = Me:queryBasicInt("cash")
    local storeMoney = StoreMgr:getStoreMoney()
    if self.isSaving then  --存钱
        
        if cash <= 0 then
            gf:ShowSmallTips(string.format(CHS[7000106], gf:getMoneyDesc(cash)))
            return
        end
        
        if storeMoney == MAX_STORE then
            gf:ShowSmallTips(CHS[7000201])
            return
        end
            
        self.inputValue = math.min(cash, MAX_STORE - storeMoney) 
        self.inputValue = math.max(self.inputValue, 0) 
    else
        if storeMoney <= 0 then
            gf:ShowSmallTips(string.format(CHS[7000108], gf:getMoneyDesc(storeMoney)))
            return
        end
        
        if cash == MAX_CASH then
            gf:ShowSmallTips(CHS[7000203])
            return
        end
        
        self.inputValue = math.min(storeMoney, MAX_CASH - cash)
    end
    
    self:updateMoneyNum()
end

function StoreMoneyImportDlg:onCashButton()
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

function StoreMoneyImportDlg:MSG_UPDATE(data)
    local storeMoney = StoreMgr:getStoreMoney()
    local money = Me:queryBasicInt("cash")
    if self.cashTextNum and self.cashTextNum ~= money
        or self.storeMoneyTextNum and self.storeMoneyTextNum ~= storeMoney then
        -- 存款或当前金钱与界面上的值不一致时才刷新
        self.inputValue = 0
        self:setBasicInfo()
        self:updateMoneyNum()
    end
end

return StoreMoneyImportDlg