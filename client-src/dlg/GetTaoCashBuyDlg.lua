-- GetTaoCashBuyDlg.lua
-- Created by songcw June/19/2017
-- 购买如意刷道令界面

local GetTaoCashBuyDlg = Singleton("GetTaoCashBuyDlg", Dialog)

local MAX_POINT = 4000
local PRICE     = 2000000

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2
local MAX_BUY_TIME = 20

function GetTaoCashBuyDlg:init()
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")

    self:bindCheckBoxListener("CheckBox", self.onCheckBox)

    -- 打开数字键盘
    self:bindNumInput("TouchPanel", "NumPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self.buyNum = 1

    self:setCheck("CheckBox", GetTaoMgr:getRuYiZHLAMTState())

    -- 若角色PK值大于0，给出提示
    local pk = Me:queryBasicInt("total_pk")
    if pk > 0 then
        gf:ShowSmallTips(CHS[5410106])
        ChatMgr:sendMiscMsg(CHS[5410106])
    end

    -- pk值影响购买价格
    local pkCostCoef = 1 + pk * 0.05
    if pkCostCoef > 2 then
        pkCostCoef = 2
    end

    self.price = PRICE * pkCostCoef
    self:updateViewData()
end

-- 数字键盘插入数字
function GetTaoCashBuyDlg:insertNumber(num)
    if num <= 0 then num = 1 end

    self.buyNum = num

    local limit = math.max(1, math.floor(( MAX_POINT - GetTaoMgr:getRuYiZHLPoint()) / 200))
    if self.buyNum > limit then
        self.buyNum = limit
        gf:ShowSmallTips(CHS[4100944])
    end

    DlgMgr:sendMsg('SmallNumInputDlg', 'setInputValue', self.buyNum)

    self:updateViewData()
end

function GetTaoCashBuyDlg:blindPress(name)
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

-- 更新界面数据
function GetTaoCashBuyDlg:updateViewData()
    self:setLabelText("NumLabel", self.buyNum, self:getControl("NumPanel"))
    self:setLabelText("Label2", string.format(CHS[5000108], self.buyNum * 200), self:getControl("InfoPanel"))
    local num, numColor = gf:getArtFontMoneyDesc(self.buyNum * self.price)
    self:setNumImgForPanel("PayPanel", numColor, num, false, LOCATE_POSITION.LEFT_BOTTOM, 21)

    self:setCtrlEnabled("ReduceButton", true)
    self:setCtrlEnabled("AddButton", true)
    if self.buyNum <= 1 then
        self:setCtrlEnabled("ReduceButton", false)
    end

    if self.buyNum >= MAX_BUY_TIME then
        self:setCtrlEnabled("AddButton", false)
    end
end

function GetTaoCashBuyDlg:onReduceButton(sender, eventType)
    self.buyNum = self.buyNum - 1
    if self.buyNum < 1 then self.buyNum = 1 end
    self:updateViewData()
end

function GetTaoCashBuyDlg:onAddButton(sender, eventType)

    if self.buyNum >= MAX_BUY_TIME then
        self:updateViewData()
        return
    end

    if GetTaoMgr:getRuYiZHLPoint() + (self.buyNum + 1) * 200 > MAX_POINT then
        gf:ShowSmallTips(CHS[4200390])
        return
    end

    self.buyNum = self.buyNum + 1
    self:updateViewData()
end

function GetTaoCashBuyDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() then
        gf:CmdToServer("CMD_SET_SHUADAO_RUYI_AMT_STATE", {state = 1})
    else
        gf:CmdToServer("CMD_SET_SHUADAO_RUYI_AMT_STATE", {state = 0})
    end
end


function GetTaoCashBuyDlg:onConfirmButton(sender, eventType)
    if GetTaoMgr:getRuYiZHLPoint() + self.buyNum * 200 > MAX_POINT then
        gf:ShowSmallTips(CHS[4200390])
        return
    end


    if not gf:checkEnough("cash", self.buyNum * self.price) then
        return
    end

    gf:CmdToServer("CMD_BUY_SHUADAO_RUYI_POINT", {num = self.buyNum})
    self:onCloseButton()
end

return GetTaoCashBuyDlg
