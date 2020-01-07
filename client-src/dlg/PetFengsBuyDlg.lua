-- PetFengsBuyDlg.lua
-- Created by zhengjh Apr/26/2016
-- 购买宠风散/紫气鸿蒙

local PRICE = 2160000
local ZQHM_PRICE = 4180000

local PetFengsBuyDlg = Singleton("PetFengsBuyDlg", Dialog)

function PetFengsBuyDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
end

function PetFengsBuyDlg:setType(type)
    if type == "zqhm" then
        -- 购买紫气鸿蒙
        self.type = "zqhm"
        self:setLabelText("TitleLabel_1", CHS[7001008])
        self:setLabelText("TitleLabel_2", CHS[7001008])
        self:setLabelText("BuyLabel", CHS[7001009])
        local cashText, fontColor = gf:getArtFontMoneyDesc(ZQHM_PRICE)
        self:setNumImgForPanel("PayPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
        local str = string.format(CHS[6200032], GetTaoMgr:getCashHaveBuyZiQiHongMengTimes(), GetTaoMgr:GetMaxCanBuyZiQiHongMengTimes())
        self:setLabelText("TimeLabel", str)
    elseif type == "chongfs" then
        -- 购买宠风散
        self.type = "chongfs"
        local cashText, fontColor = gf:getArtFontMoneyDesc(PRICE)
        self:setNumImgForPanel("PayPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
        local str = string.format(CHS[6200032], GetTaoMgr:getCashHaveBuyChongFengSanTimes(), GetTaoMgr:GetMaxCanBuyTimes())
        self:setLabelText("TimeLabel", str)
    end
end

function PetFengsBuyDlg:onConfirmButton(sender, eventType)
    if self.type == "chongfs" then
        -- 购买宠风散
        if Me:getLevel() < GetTaoMgr.USE_CHONGFENGSAN_MIN_LEVEL then
            -- 未达到等级要求无法操作
            gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_CHONGFENGSAN_MIN_LEVEL))
            return
        end

        if GetTaoMgr:getPetFengSanPoint() > GetTaoMgr:getMaxChongFengSanPoint() - 200 then
            gf:ShowSmallTips(CHS[6200029])
            return
        end

        local voucher = Me:query("voucher")
        local cash = Me:query("cash")

        if voucher + cash < PRICE then
            gf:askUserWhetherBuyCash()
            return
        end

        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_CHONGFENGSAN, 1, 1)

        if GetTaoMgr:getCashHaveBuyChongFengSanTimes() + 1 >= GetTaoMgr:GetMaxCanBuyTimes() then
            DlgMgr:closeDlg(self.name)
        else
            local str = string.format(CHS[6200032], GetTaoMgr:getCashHaveBuyChongFengSanTimes() + 1, GetTaoMgr:GetMaxCanBuyTimes())
            self:setLabelText("TimeLabel", str)
        end
    elseif self.type == "zqhm" then
        -- 购买紫气鸿蒙
        if GetTaoMgr:getAllZiQiHongMengPoint() > GetTaoMgr:getMaxZiQiHongMengPoint() - 200 then
            gf:ShowSmallTips(CHS[7000287])
            return
        end

        local voucher = Me:query("voucher")
        local cash = Me:query("cash")

        if voucher + cash < ZQHM_PRICE then
            gf:askUserWhetherBuyCash()
            return
        end

        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_ZIQIHONGMENG, 1, 1)

        if GetTaoMgr:getCashHaveBuyZiQiHongMengTimes() + 1 >= GetTaoMgr:GetMaxCanBuyZiQiHongMengTimes() then
            DlgMgr:closeDlg(self.name)
        else
            local str = string.format(CHS[6200032], GetTaoMgr:getCashHaveBuyZiQiHongMengTimes() + 1, GetTaoMgr:GetMaxCanBuyZiQiHongMengTimes())
            self:setLabelText("TimeLabel", str)
        end
    end
end

return PetFengsBuyDlg
