-- AddOfflineTimeDlg.lua
-- Created by songcw Mar/19/2015
-- 购买离线时间界面

local AddOfflineTimeDlg = Singleton("AddOfflineTimeDlg", Dialog)

AddOfflineTimeDlg.maxTime = 90000   -- 秒

AddOfflineTimeDlg.data = nil

function AddOfflineTimeDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("BuyFiveButton", self.onBuyFiveButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:hookMsg("MSG_SHUADAO_REFRESH_BUY_TIME")
end

function AddOfflineTimeDlg:setInfo(data)
    if nil == data then return end
    self.data = data
    self:setLabelText("MoneyLabel", GetTaoMgr:getBuyOne())

    local min = math.floor(GetTaoMgr:getAllOfflineTime() / 60)
    local sec = GetTaoMgr:getAllOfflineTime() % 60

    self:setLabelText("OwnTimeLabel2", string.format(CHS[4000294], min, sec))

    local maxTime = self:getMaxBuyTime()
    self:setLabelText("BuyNumberLabel2", string.format("%d/%d", GetTaoMgr:getBuyTime(), maxTime))

    self:updateLayout("BackgroundPanel")
end

function AddOfflineTimeDlg:getMaxBuyTime()
    local vipType = Me:getVipType()
    if vipType == 0 then
        return 4
    elseif vipType == 1 then
        return 8
    elseif vipType == 2 then
        return 10
    elseif vipType == 3 then
        return 12
    end

    return 0
end

function AddOfflineTimeDlg:onBuyButton(sender, eventType)
    -- 没有数据就别让玩家点了，不然扣钱了算谁的...
    if nil == self.data then return end

    if self:getMaxBuyTime() == GetTaoMgr:getBuyTime() then
        if Me.vipType ~= 3 then
            gf:ShowSmallTips(CHS[3002242])
        else
            gf:ShowSmallTips(CHS[3002243])
        end

        return
    end

    if GetTaoMgr:getAllOfflineTime() + 60 * 60 > self.maxTime then
        gf:ShowSmallTips(string.format(CHS[3002244], math.floor(self.maxTime / 60)))
        return
    end

    local coin = Me:getTotalCoin()
    if coin < GetTaoMgr:getBuyOne() then
        gf:askUserWhetherBuyCoin()
        return
    end

    -- 安全锁判断    没有验证别让玩家点了，不然被盗了算谁的...
    if self:checkSafeLockRelease("onBuyButton") then
        return
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_BUY_OFFLINE_TIME, 1)
end

function AddOfflineTimeDlg:onBuyFiveButton(sender, eventType)
    if self:getMaxBuyTime() - GetTaoMgr:getBuyTime() < 5 then
        gf:ShowSmallTips(CHS[3002245])
        return
    end

    if GetTaoMgr:getAllOfflineTime() + 60 * 60 * 5 > self.maxTime then
        gf:ShowSmallTips(string.format(CHS[3002246], math.floor(self.maxTime / 60)))
        return
    end

    gf:confirm(string.format(CHS[3002247], GetTaoMgr:getBuyFive()), function()
        local coin = Me:getTotalCoin()
        if coin < GetTaoMgr:getBuyFive() then
            gf:askUserWhetherBuyCoin()
            return
        end
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_BUY_OFFLINE_TIME, 5)
    end)
end

function AddOfflineTimeDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function AddOfflineTimeDlg:MSG_SHUADAO_REFRESH_BUY_TIME(data)
    -- 设置上一次离线任务
    self:setInfo(data)
end

return AddOfflineTimeDlg
