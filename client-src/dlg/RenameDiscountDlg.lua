-- RenameDiscountDlg.lua
-- created by songcw May/27/2017
-- 5折改名卡

local RenameDiscountDlg = Singleton("RenameDiscountDlg", Dialog)

function RenameDiscountDlg:init()
    self:bindListener("FrameImage", self.onFrameImage, "BonusPanel")
    self:bindListener("GetButton", self.onGetButton)
    
    GiftMgr:requestRenameDiscountInfo()
    
    self:setImage("BonusImage", ResMgr:getIconPathByName(CHS[2000095]))
    InventoryMgr:addLogoBinding(self:getControl("BonusImage"))
    
    self:setImage("ShansImage", ResMgr:getBigPortrait(6236))
    
    self:hookMsg("MSG_RENAME_DISCOUNT")
    
    if self.data then
        self:MSG_RENAME_DISCOUNT(self.data)
    end
end

function RenameDiscountDlg:onFrameImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[2000095], rect, true)
end

function RenameDiscountDlg:onGetButton(sender, eventType)
    GiftMgr:buyRenameDiscount()
end

function RenameDiscountDlg:MSG_RENAME_DISCOUNT(data)
    self.data = self.data

    -- 截止时间
    self:setLabelText("TimeLabel", gf:getServerDate(CHS[4300158], data.time_out))
    
    -- 原价
    self:setNumImgForPanel("PricePanel", ART_FONT_COLOR.NORMAL_TEXT, data.org_price, false, LOCATE_POSITION.MID, 21, "OldPricePanel")

    -- 现价
    self:setNumImgForPanel("PricePanel", ART_FONT_COLOR.NORMAL_TEXT, data.price, false, LOCATE_POSITION.MID, 21, "NewPricePanel")
    
    -- 现价
    self:setNumImgForPanel("PricePanel", ART_FONT_COLOR.NORMAL_TEXT, data.price, false, LOCATE_POSITION.MID, 21, "GetButton")
    
    -- 购买次数
    local buyCount = 1 - data.buy_count
    self:setLabelText("BonusLabel_2", buyCount)
    
    -- 按钮状态
    if buyCount >= 1 then
        self:setCtrlEnabled("GetButton", false)
        self:setLabelText("NumLabel_2", CHS[4300253], "GetButton")
        self:setLabelText("NumLabel_1", CHS[4300253], "GetButton")
    end
end

return RenameDiscountDlg
