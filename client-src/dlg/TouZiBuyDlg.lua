-- TouZiBuyDlg.lua
-- Created by lixh Aug/30/2017
-- 中秋博饼筛子购买界面

local TouZiBuyDlg = Singleton("TouZiBuyDlg", Dialog)

function TouZiBuyDlg:init()
    self:bindListener("ConfirmButton", self.onBuyButton)
    
    -- 注册事件
    -- self:hookMsg("MSG_AUTUMN_2017_BUY")
end

function TouZiBuyDlg:onBuyButton(sender, eventType)
    if not InventoryMgr:getFirstEmptyPos() then
        -- 你的包裹已满，无法购买。
        gf:ShowSmallTips(CHS[7120001])
        return
    end
    
    if self.haveBuyCount and self.maxCount and self.haveBuyCount >= self.maxCount then
        -- 每日只可购买3次骰子。
        gf:ShowSmallTips(CHS[7120002])
        return
    end
    
    if Me:getTotalCoin() < self.price then
        -- 你的元宝数量不足，是否前往充值？
        gf:askUserWhetherBuyCoin()
        return
    end 
    
    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton") then
        return
    end
    
    if Me:queryBasicInt('silver_coin') <= 0 then
        -- 只消耗金元宝
        gf:confirm(string.format(CHS[7120003], self.price), function ()
            self:sendBuyMsg()
        end)
    else
        --只消耗银元宝或混合消耗
        if Me:getSilverCoin() >= self.price then
            gf:confirm(string.format(CHS[7120004], self.price), function ()
                self:sendBuyMsg()
            end)
        else
            gf:confirm(string.format(CHS[7120005], self.price, self.price - Me:getSilverCoin()), function ()
                self:sendBuyMsg()
            end)
        end
    end
end

function TouZiBuyDlg:sendBuyMsg()
    gf:CmdToServer("CMD_AUTUMN_2017_BUY", {flag = 1})
end

function TouZiBuyDlg:refreshPanel(haveBuyCount, maxCount, price)
    self.haveBuyCount = haveBuyCount
    self.maxCount = maxCount
    self.price = price
    self:setLabelText("TimeLabel", string.format(CHS[7120000], haveBuyCount, maxCount))
    
    if haveBuyCount >= maxCount then
        -- 当前购买次数已达上限
        self:setCtrlEnabled("ConfirmButton", false)
        self:setCtrlVisible("PayPanel", false)
        self:setCtrlVisible("AcerImage", false)
        self:setCtrlVisible("MaxLabel1", true)
        self:setCtrlVisible("MaxLabel2", true)
    else
        self:setNumImgForPanel("PayPanel", ART_FONT_COLOR.DEFAULT, price, false, LOCATE_POSITION.CENTER, 23)
        self:setCtrlEnabled("ConfirmButton", true)
        self:setCtrlVisible("PayPanel", true)
        self:setCtrlVisible("AcerImage", true)
        self:setCtrlVisible("MaxLabel1", false)
        self:setCtrlVisible("MaxLabel2", false)
    end
end

function TouZiBuyDlg:MSG_AUTUMN_2017_BUY(data)
    self:refreshPanel(data.count, data.max_count, data.price)
end

return TouZiBuyDlg
