-- PracticeBuyDoubleDlg.lua
-- Created by zjh Jul/8/2015
-- 双倍点数购买

local PracticeBuyDoubleDlg = Singleton("PracticeBuyDoubleDlg", Dialog)
local SINGLEPRICE = 108 -- 双倍点数的价格
local ONE_BUY_POINT = 200 -- 点击一次购买的点数

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2

function PracticeBuyDoubleDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")
    
        -- 打开数字键盘
    self:bindNumInput("TouchPanel", "NumPanel")
    
    self:bindListener("CancelButton", self.onCancelButton)
    self:initData()

    self.needCheck = true
    if next(OnlineMallMgr:getOnlineMallList()) then
        self:MSG_ONLINE_MALL_LIST()
    elseif not OnlineMallMgr:hasRequestOnlineData() then
        OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")
    end

    self:hookMsg("MSG_ONLINE_MALL_LIST")
end

-- 数字键盘插入数字
function PracticeBuyDoubleDlg:insertNumber(num)
    if num <= 0 then num = 1 end

    self.count = num      
    
    local limit = math.max(1, math.floor(( PracticeMgr:getDoublePointLimit() - GetTaoMgr:getAllDoublePoint()) / 200))
    if self.count > limit then
        self.count = limit
        gf:ShowSmallTips(CHS[4100944])
    end
    
    DlgMgr:sendMsg('SmallNumInputDlg', 'setInputValue', self.count)
    
    self:setShopInfo()
end

function PracticeBuyDoubleDlg:blindPress(name)
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

function PracticeBuyDoubleDlg:onReduceButton(sender, eventType)
    if self.count > 1 then
        self.count = self.count - 1
   
    end
    self:setShopInfo()
end

function PracticeBuyDoubleDlg:onAddButton(sender, eventType)
    if self.count < self:getBuyMaxTimes() then
        if tonumber(Me:queryBasic("double_points")) > PracticeMgr:getDoublePointLimit() - ONE_BUY_POINT * (self.count + 1) then
            gf:ShowSmallTips(CHS[3003493])
        else
            self.count = self.count + 1     
        end
    end
    self:setShopInfo()
end

function PracticeBuyDoubleDlg:onBuyButton(sender, eventType)
    local totalMoney = Me:getTotalCoin()
    
    if totalMoney < self.count * SINGLEPRICE then 
        gf:askUserWhetherBuyCoin()
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_DOUBLE_POINTS, self.count)  
    end
    
    DlgMgr:closeDlg(self.name)
end

function PracticeBuyDoubleDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function PracticeBuyDoubleDlg:initData()
    local numberLabel = self:getControl("NumberLabel")
    self.count = 1
    self:setShopInfo()
end


function PracticeBuyDoubleDlg:setShopInfo()
    
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

function PracticeBuyDoubleDlg:getBuyMaxTimes()
    return PracticeMgr:getDoublePointLimit() / ONE_BUY_POINT
end

function PracticeBuyDoubleDlg:MSG_ONLINE_MALL_LIST()
    if not self.needCheck then
        return
    end

    OnlineMallMgr:checkHasDiscountCanBuy(CHS[3001147])

    self.needCheck = false
end

return PracticeBuyDoubleDlg
