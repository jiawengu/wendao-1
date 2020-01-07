-- GetTaoBuyDlg.lua
-- Created by liuhb Jan/27/2016
-- 购买急急如律令界面

local GetTaoBuyDlg = Singleton("GetTaoBuyDlg", Dialog)

local UNIT_PRICE_JIJI = 328
local MAX_BUY_TIME = 10
local MAX_JIJI = GetTaoMgr:getMaxJiJiPoint()
local PER_POINT = 200
local MAX_ZQHM = GetTaoMgr:getMaxZiQiHongMengPoint()
local MAX_CFS = GetTaoMgr:getMaxChongFengSanPoint()
local EFF_POINT = 200   -- 购买一次的有效点数

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2

function GetTaoBuyDlg:init()
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")

    -- 打开数字键盘
    self:bindNumInput("TouchPanel", "NumPanel")

    self:bindListener("BuyButton", self.onBuyButton)

    self.buyNum = 1

    self:hookMsg("MSG_ONLINE_MALL_LIST")
end

-- 数字键盘插入数字
function GetTaoBuyDlg:insertNumber(num)
    if num <= 0 then num = 1 end

    self.buyNum = num  

    local limit = math.max(1, math.floor(( self.maxPoint - self:getTotalPoint()) / self.perPoint))
    if self.buyNum > limit then
        self.buyNum = limit
        gf:ShowSmallTips(CHS[4100944])
    end

    DlgMgr:sendMsg('SmallNumInputDlg', 'setInputValue', self.buyNum)

    self:updateViewData()
end

function GetTaoBuyDlg:blindPress(name)
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

function GetTaoBuyDlg:setInfoByType(type)
    if type == "jiji" then
        self.unitPrice = 328
        self.maxBuyTimes = MAX_JIJI / EFF_POINT
        self.maxPoint = MAX_JIJI
        self.perPoint = 200
        self:setCtrlVisible("ChongfsInfoPanel", false)
        self:setCtrlVisible("InfoPanel", true)
        self:setCtrlVisible("ZiQiHongMengInfoPanel", false)
    elseif type == "chongfengsan" then
        self.unitPrice = 216
        self.maxBuyTimes = MAX_CFS / EFF_POINT
        self.maxPoint = MAX_CFS
        self.perPoint = 200
        self:setCtrlVisible("ChongfsInfoPanel", true)
        self:setCtrlVisible("InfoPanel", false)
        self:setCtrlVisible("ZiQiHongMengInfoPanel", false)
    elseif type == "ziqihongmeng" then
        -- 紫气鸿蒙
        self.unitPrice = 418
        self.maxBuyTimes = MAX_ZQHM / EFF_POINT
        self.maxPoint = MAX_ZQHM
        self.perPoint = 200
        self:setCtrlVisible("ChongfsInfoPanel", false)
        self:setCtrlVisible("InfoPanel", false)
        self:setCtrlVisible("ZiQiHongMengInfoPanel", true)
    end
    
    self.type = type
    self:updateViewData()

    self.needCheck = true
    if next(OnlineMallMgr:getOnlineMallList()) then
        self:MSG_ONLINE_MALL_LIST()
    elseif not OnlineMallMgr:hasRequestOnlineData() then
        OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")
    end
end

-- 更新界面数据
function GetTaoBuyDlg:updateViewData()
    self:setLabelText("NumLabel", self.buyNum, self:getControl("NumPanel"))
    self:setLabelText("Label1", self.buyNum * self.unitPrice, self:getControl("BuyButton"))

    self:setCtrlEnabled("ReduceButton", true)
    self:setCtrlEnabled("AddButton", true)
    if self.buyNum <= 1 then
        self:setCtrlEnabled("ReduceButton", false)
    end

    if self.buyNum >= self.maxBuyTimes then
        self:setCtrlEnabled("AddButton", false)
    end
end

-- 减按钮
function GetTaoBuyDlg:onReduceButton(sender, eventType)    
    self.buyNum = self.buyNum - 1
    if self.buyNum < 1 then self.buyNum = 1 end
    self:updateViewData()
end

-- 加按钮
function GetTaoBuyDlg:onAddButton(sender, eventType)
    if self.buyNum >= self.maxBuyTimes then
        self:setCtrlEnabled("AddButton", false)
        return
    end

    if self:getTotalPoint() + (self.buyNum + 1) * self.perPoint > self.maxPoint then
        gf:ShowSmallTips(self.tips or "")
        return
    end

    self.buyNum = self.buyNum + 1
    self:updateViewData()
end

function GetTaoBuyDlg:getTotalPoint()
    if self.type == "jiji" then
        self.tips = CHS[3002653]
        return GetTaoMgr:getAllJijiPoint()
    elseif self.type == "chongfengsan" then
        self.tips = CHS[6200029]
        return GetTaoMgr:getPetFengSanPoint()
    elseif self.type == "ziqihongmeng" then
        -- 紫气鸿蒙
        self.tips = CHS[7000287]
        return GetTaoMgr:getAllZiQiHongMengPoint()
    end
end

function GetTaoBuyDlg:onBuyButton(sender, eventType)
    local totalMoney = Me:getTotalCoin()
    
    if totalMoney < self.buyNum * self.unitPrice then 
        gf:askUserWhetherBuyCoin()
    else
        self:sendBuyCmd()
    end
    
    self:onCloseButton()
end

function GetTaoBuyDlg:sendBuyCmd()
    if self.type == "jiji" then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_JIJI, self.buyNum)
    elseif self.type == "chongfengsan" then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_CHONGFENGSAN, 2, self.buyNum)
    elseif self.type == "ziqihongmeng" then
        -- 紫气鸿蒙
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_ZIQIHONGMENG, 2, self.buyNum)
    end
end

function GetTaoBuyDlg:MSG_ONLINE_MALL_LIST()
    if not self.needCheck then
        return
    end

    if self.type == "jiji" then
        OnlineMallMgr:checkHasDiscountCanBuy(CHS[3001146])
    elseif self.type == "chongfengsan" then
        OnlineMallMgr:checkHasDiscountCanBuy(CHS[6200026])
    elseif self.type == "ziqihongmeng" then
        OnlineMallMgr:checkHasDiscountCanBuy(CHS[5420247])
    end

    self.needCheck = false
end

return GetTaoBuyDlg
