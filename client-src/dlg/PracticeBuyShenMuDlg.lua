-- PracticeBuyShenMuDlg.lua
-- Created by zhengjh Apr/26/2016
-- 购买神木鼎

local PracticeBuyShenMuDlg = Singleton("PracticeBuyShenMuDlg", Dialog)
local SINGLEPRICE = 328 -- 神木点数的价格
local ONE_BUY_POINT = 1000 -- 点击一次购买的点数

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2

function PracticeBuyShenMuDlg:init()
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")
    self:bindListener("BuyButton", self.onBuyButton)
    
    -- 打开数字键盘
    self:bindNumInput("TouchPanel", "NumPanel")
    
    self:initData()
    self:initUI()

    self.needCheck = true
    if next(OnlineMallMgr:getOnlineMallList()) then
        self:MSG_ONLINE_MALL_LIST()
    elseif not OnlineMallMgr:hasRequestOnlineData() then
        OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")
    end

    self:hookMsg("MSG_ONLINE_MALL_LIST")
end

-- 数字键盘插入数字
function PracticeBuyShenMuDlg:insertNumber(num)
    if num <= 0 then num = 1 end

    self.count = num      

    local limit = math.max(1, math.floor(( PracticeMgr:getShenmuPointLimit() - Me:queryBasicInt("shenmu_points")) / ONE_BUY_POINT))
    if self.count > limit then
        self.count = limit
        gf:ShowSmallTips(CHS[4100944])
    end

    DlgMgr:sendMsg('SmallNumInputDlg', 'setInputValue', self.count)

    self:setShopInfo()
end

function PracticeBuyShenMuDlg:blindPress(name)
    local widget = self:getControl(name,nil,self.root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end
    -- longClick为长按的标志位
    local function updataCount(longClick)
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "AddButton" then
                self:onAddButton(longClick)
            elseif self.clickBtn == "ReduceButton" then
                self:onReduceButton(longClick)
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , function() updataCount(true) end, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else            
            updataCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end


function PracticeBuyShenMuDlg:initUI()
    local isTestDist = DistMgr:curIsTestDist()
    local infoPanel = self:getControl("InfoPanel")
    self:setCtrlVisible("GoldImage", not isTestDist, infoPanel)
    self:setCtrlVisible("SilverImage", isTestDist, infoPanel)
    local butBtn = self:getControl("BuyButton")
    self:setCtrlVisible("GoldImage", not isTestDist, butBtn)
    self:setCtrlVisible("SilverImage", isTestDist, butBtn)
    self:setCtrlVisible("InfoLabel", isTestDist)
end

function PracticeBuyShenMuDlg:onReduceButton(sender, eventType)
    if self.count > 1 then
        self.count = self.count - 1 
    end
    self:setShopInfo()
end

function PracticeBuyShenMuDlg:onAddButton(sender, eventType)
    if self.count < self:getBuyMaxTimes() then
        if Me:queryBasicInt("shenmu_points") > PracticeMgr:getShenmuPointLimit() - ONE_BUY_POINT * (self.count + 1) then
            gf:ShowSmallTips(CHS[6000253])
        else
            self.count = self.count + 1
        end
    end
    
    self:setShopInfo()
end

function PracticeBuyShenMuDlg:onBuyButton(sender, eventType)
    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton", sender, eventType) then
        return
    end

    local totalMoney
    if DistMgr:curIsTestDist() then
        totalMoney = Me:getTotalCoin()
    else
        totalMoney = tonumber(Me:queryBasic("gold_coin"))
    end

    if totalMoney < self.count * SINGLEPRICE then
        gf:askUserWhetherBuyCoin()
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_SHENMU_POINTS, self.count)
    end

    DlgMgr:closeDlg(self.name)
end

function PracticeBuyShenMuDlg:initData()
    local numberLabel = self:getControl("NumberLabel")
    self.count = 1
    self:setShopInfo()
end


function PracticeBuyShenMuDlg:setShopInfo()
    local reduceButton = self:getControl("ReduceButton")
    local addButton = self:getControl("AddButton")

    if self.count <= 1 then
        gf:grayImageView(reduceButton)
        reduceButton:setEnabled(false)
    else
        gf:resetImageView(reduceButton)
        reduceButton:setEnabled(true)
    end

    if self.count >= self:getBuyMaxTimes() then
        gf:grayImageView(addButton)
        addButton:setEnabled(false)
    else
        gf:resetImageView(addButton)
        addButton:setEnabled(true)
    end

    -- 购买数量
    local numberLabel = self:getControl("NumLabel")
    numberLabel:setString(self.count)
    local numberLabel2 = self:getControl("NumLabel2")
    numberLabel2:setString(self.count)

    -- 总价
    local totalParice = self.count * SINGLEPRICE
    local buyBtn = self:getControl("BuyButton")
    self:setLabelText("Label1", totalParice, buyBtn)
    self:setLabelText("Label2", totalParice, buyBtn)
    self:updateLayout("PricePanel")
end

function PracticeBuyShenMuDlg:getBuyMaxTimes()
    return PracticeMgr:getShenmuPointLimit() / ONE_BUY_POINT
end

function PracticeBuyShenMuDlg:MSG_ONLINE_MALL_LIST()
    if not self.needCheck then
        return
    end

    OnlineMallMgr:checkHasDiscountCanBuy(CHS[6000252])

    self.needCheck = false
end

return PracticeBuyShenMuDlg
