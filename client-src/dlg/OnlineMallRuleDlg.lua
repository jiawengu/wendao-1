-- OnlineMallRuleDlg.lua
-- Created by sujl, Nov/12/2016
-- 在线商城规则说明界面

local OnlineMallRuleDlg = Singleton("OnlineMallRuleDlg", Dialog)

function OnlineMallRuleDlg:init()
    self:bindListener("BackImage", self.onCloseButton, "SilverRulePanel")
    self:bindListener("BackImage", self.onCloseButton, "GoldRulePanel")
    self:bindListener("BackImage", self.onCloseButton, "NormalRulePanel")

    local hasDiscountCoupon = InventoryMgr:hasDiscountCoupon()
    local isTestDist = DistMgr:curIsTestDist()
    if isTestDist then
        self.curPanel = self:getControl("SilverRulePanel")
        self:setCtrlVisible("SilverRulePanel", true)
        self:setCtrlVisible("GoldRulePanel", false)
        self:setCtrlVisible("NormalRulePanel", false)
    else
        self.curPanel = self:getControl("GoldRulePanel")
        self:setCtrlVisible("SilverRulePanel", false)
        self:setCtrlVisible("GoldRulePanel", true)
        self:setCtrlVisible("NormalRulePanel", false)
    end

    if hasDiscountCoupon then
        self:showOwn()
    else
        local activityTime = ActivityMgr:getActivityStartTimeByMainType("discount_coupon")
        local curTime = gf:getServerTime()
        --activityTime = { startTime = curTime - 1000, endTime = curTime + 3600 * 10 }
        if activityTime and activityTime["startTime"] and activityTime["endTime"]
            and activityTime["startTime"] <= curTime
            and activityTime["endTime"] >= curTime then
            self:showNone(activityTime)
        else
            self:showUnOpen()
        end
    end
end

function OnlineMallRuleDlg:showUnOpen()
    self:setCtrlVisible("SilverRulePanel", false)
    self:setCtrlVisible("GoldRulePanel", false)
    self:setCtrlVisible("NormalRulePanel", true)
end

function OnlineMallRuleDlg:showOwn()
    self:setCtrlVisible("Label1_1", false, self.curPanel)
    self:setCtrlVisible("Label1", true, self.curPanel)
    self:setCtrlVisible("Label2", true, self.curPanel)
    self:setCtrlVisible("Label3", true, self.curPanel)
    self:setCtrlVisible("OwnPanel", true, self.curPanel)
    self:setCtrlVisible("NonePanel", false, self.curPanel)

    local discountCoupon1 = InventoryMgr:getDiscountCoupon(CHS[2000188])
    self:setLabelText("CouponNumLable_1", string.format(CHS[2000197], discountCoupon1 and discountCoupon1[CHS[2000188]] or 0), self.curPanel)

    local discountCoupon5 = InventoryMgr:getDiscountCoupon(CHS[2000189])
    self:setLabelText("CouponNumLable_2", string.format(CHS[2000197], discountCoupon5 and discountCoupon5[CHS[2000189]] or 0), self.curPanel)

    local discountCoupon9 = InventoryMgr:getDiscountCoupon(CHS[2000190])
    self:setLabelText("CouponNumLable_3", string.format(CHS[2000197], discountCoupon9 and discountCoupon9[CHS[2000190]] or 0), self.curPanel)
end

function OnlineMallRuleDlg:showNone(activityTime)
    self:setCtrlVisible("Label1_1", false, self.curPanel)
    self:setCtrlVisible("Label1", true, self.curPanel)
    self:setCtrlVisible("Label2", true, self.curPanel)
    self:setCtrlVisible("Label3", true, self.curPanel)
    self:setCtrlVisible("OwnPanel", false, self.curPanel)
    self:setCtrlVisible("NonePanel", true, self.curPanel)

    if not activityTime then return end
    local endTime = activityTime["endTime"]
    self:setLabelText("Label_6", string.format(CHS[2000196],
        gf:getServerDate("%m", endTime),
        gf:getServerDate("%d", endTime),
        gf:getServerDate("%H", endTime),
        gf:getServerDate("%M", endTime)),
        self:getControl("NonePanel", Const.UIPanel, self.curPanel))
end

function OnlineMallRuleDlg:cleanup()
end

return OnlineMallRuleDlg