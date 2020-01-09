-- LineUpChangeChannelDiscountDlg.lua
-- Created by lixh2 Mar/11/2019
-- 排队优惠信息界面

local LineUpChangeChannelDiscountDlg = Singleton("LineUpChangeChannelDiscountDlg", Dialog)

function LineUpChangeChannelDiscountDlg:init()
    self.bkImage = self:getControl("BackImage")
    self.rulePanel = self:getControl("RulePanel")
    self.discountPanel = self:getControl("Panel_1")
    self.vipPanel = self:getControl("Panel_2")

    self.rootSize = self.root:getContentSize()
    self.bkImageSize = self.bkImage:getContentSize()
    self.rulePanelSize = self.rulePanel:getContentSize()
    self.discountPanelSize = self.discountPanel:getContentSize()
    self.vipPanelSize = self.vipPanel:getContentSize()
end

function LineUpChangeChannelDiscountDlg:setInfo(data)
    local function setTimeStr(panel, startTime, endTime)
        local startTimeStr = gf:getServerDate(CHS[7150112], startTime)
        local endTimeStr = gf:getServerDate(CHS[7150112], endTime)
        local timeStr = string.format(CHS[7150123], startTimeStr, endTimeStr)
        self:setLabelText("Label4", timeStr, panel)
    end

    local curTime = gf:getServerTime()

    local isDiscountOpen = false
    if curTime > data.discount_start_time and curTime < data.discount_end_time then
        isDiscountOpen = true
    end

    local isVipOpen = false
    if curTime > data.vip_start_time and curTime < data.vip_end_time then
        isVipOpen = true
    end

    local minusHeight = 0

    if isDiscountOpen and isVipOpen then
        setTimeStr(self.discountPanel, data.discount_start_time, data.discount_end_time)
        setTimeStr(self.vipPanel, data.vip_start_time, data.vip_end_time)
    elseif isDiscountOpen then
        setTimeStr(self.discountPanel, data.discount_start_time, data.discount_end_time)
        
        self.vipPanel:setContentSize(self.vipPanelSize.width, 0)
        self.vipPanel:setVisible(false)

        minusHeight = self.vipPanelSize.height
    elseif isVipOpen then
        setTimeStr(self.vipPanel, data.vip_start_time, data.vip_end_time)

        self.discountPanel:setContentSize(self.discountPanelSize.width, 0)
        self.discountPanel:setVisible(false)

        minusHeight = self.discountPanelSize.height
    else
        self:setCtrlVisible("RulePanel", false)
        self:setCtrlVisible("NoticePanel", true)
    end

    if minusHeight > 0 then
        self.root:setContentSize(cc.size(self.rootSize.width, self.rootSize.height - minusHeight))
        self.rulePanel:setContentSize(cc.size(self.rulePanelSize.width, self.rulePanelSize.height - minusHeight))
        self.bkImage:setContentSize(cc.size(self.bkImageSize.width, self.bkImageSize.height - minusHeight))
    end
end

return LineUpChangeChannelDiscountDlg
