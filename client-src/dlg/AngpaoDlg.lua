-- AngpaoDlg.lua
-- Created by zhengjh Jun/20/2016
-- 婚礼红包

local AngpaoDlg = Singleton("AngpaoDlg", Dialog)
local timesEveryMinute = 4 -- 每分钟红包发放次数
local minPrice = 10000 -- 每个红包最小价格
local maxPrice = 10000000 -- 每个红包最大价格
local maxTotalMoney = 2000000000

function AngpaoDlg:init()
    self:bindListener("TimeAddButton", self.onTimeAddButton)
    self:bindListener("TimeReduceButton", self.onTimeReduceButton)
    self:bindListener("NumAddButton", self.onNumAddButton)
    self:bindListener("NumReduceButton", self.onNumReduceButton)
    self:bindListener("MoneyAddButton", self.onMoneyAddButton)
    self:bindListener("MoneyReduceButton", self.onMoneyReduceButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)

    local moneyPanel = self:getControl("MoneyPanel")
    -- 打开数字键盘
    self:bindNumInput("BackImage", moneyPanel, nil)


    self.sendTotalTime = 1 -- 发放红包时间
    self.count = 1 -- 每次发几个
    self.price = 10000 -- 每个红包多少钱
    self.personNum = 1 -- 撒钱丫鬟个数
end

function AngpaoDlg:setInfo(personNum)
    self.personNum = personNum
    self:refreshInfo()
    self:refreshGrantPanel()
    self:refreshNumPanel()
    self:refreshMoneyPanel()
end

function AngpaoDlg:onTimeAddButton(sender, eventType)
    self.sendTotalTime = self.sendTotalTime + 1
    if self:getTotalNum() > maxTotalMoney then
        gf:ShowSmallTips(string.format(CHS[6400055], gf:getMoneyDesc(maxTotalMoney)))
        self.sendTotalTime = self.sendTotalTime - 1
        return
    end

    self:refreshGrantPanel()
end

function AngpaoDlg:onTimeReduceButton(sender, eventType)
    self.sendTotalTime = self.sendTotalTime - 1
    self:refreshGrantPanel()
end

function AngpaoDlg:refreshGrantPanel()
    if not self.sendTotalTime then return end
    if self.sendTotalTime <= 1 then
        self:setCtrlEnabled("TimeReduceButton", false)
    else
        self:setCtrlEnabled("TimeReduceButton", true)
    end

    if self.sendTotalTime >= 4 then
        self:setCtrlEnabled("TimeAddButton", false)
    else
        self:setCtrlEnabled("TimeAddButton", true)
    end

    self:refreshInfo()
end


function AngpaoDlg:onNumAddButton(sender, eventType)
    self.count = self.count + 1
    if self:getTotalNum() > maxTotalMoney then
        gf:ShowSmallTips(string.format(CHS[6400055], gf:getMoneyDesc(maxTotalMoney)))

        self.count = self.count - 1
        return
    end
    self:refreshNumPanel()
end

function AngpaoDlg:onNumReduceButton(sender, eventType)
    self.count = self.count - 1
    self:refreshNumPanel()
end

function AngpaoDlg:refreshNumPanel()
    if not self.count then return end
    if self.count <= 1 then
        self:setCtrlEnabled("NumReduceButton", false)
    else
        self:setCtrlEnabled("NumReduceButton", true)
    end

    if self.count >= 6 then
        self:setCtrlEnabled("NumAddButton", false)
    else
        self:setCtrlEnabled("NumAddButton", true)
    end

    self:refreshInfo()
end

function AngpaoDlg:onMoneyAddButton(sender, eventType)
    self.price = self.price + minPrice
    if self:getTotalNum() > maxTotalMoney then
        gf:ShowSmallTips(string.format(CHS[6400055], gf:getMoneyDesc(maxTotalMoney)))
        self.price = self.price - minPrice
        return
    end

    self:refreshMoneyPanel()
end

function AngpaoDlg:onMoneyReduceButton(sender, eventType)
    self.price = self.price - minPrice
    self:refreshMoneyPanel()
end

function AngpaoDlg:refreshMoneyPanel()
    if not self.price then return end
    if self.price <= minPrice then
        self:setCtrlEnabled("MoneyReduceButton", false)
    else
        self:setCtrlEnabled("MoneyReduceButton", true)
    end

    if self.price >= maxPrice then
        self:setCtrlEnabled("MoneyAddButton", false)
        self.price = maxPrice
    else
        self:setCtrlEnabled("MoneyAddButton", true)
    end

    self:refreshInfo()
end

-- 数字键盘插入数字
function AngpaoDlg:insertNumber(num)
    if not self.price then return end

    if num <= 0 then  num = 1 end
    local lastPrice = self.price
    self.price = num * minPrice
    if num > maxPrice / minPrice then
        gf:ShowSmallTips(string.format(CHS[6400077], gf:getMoneyDesc(maxPrice)))
        -- 更新键盘数据
        DlgMgr:sendMsg("SmallNumInputDlg", "setInputValue", lastPrice / minPrice)
        self.price = lastPrice
    elseif self:getTotalNum() > maxTotalMoney then
        gf:ShowSmallTips(string.format(CHS[6400055], gf:getMoneyDesc(maxTotalMoney)))

        -- 更新键盘数据
        DlgMgr:sendMsg("SmallNumInputDlg", "setInputValue", lastPrice / minPrice)
        self.price = lastPrice
    end

    self:refreshMoneyPanel()
end

function AngpaoDlg:onConfrimButton(sender, eventType)
    if self:getTotalNum() > maxTotalMoney then
        gf:ShowSmallTips(string.format(CHS[6400055], gf:getMoneyDesc(maxTotalMoney)))
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onConfrimButton") then
        return
    end

    if self:getTotalNum() > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    gf:confirm(string.format(CHS[6400056], self:getTotalNum()), function ()
        local data = {}
        data.each_time_num = self.count
        data.cash = self.price
        data.last_time = self.sendTotalTime
        MarryMgr:setRedPacket(data)
        DlgMgr:closeDlg(self.name)
    end)
end

-- 刷新界面数据
function AngpaoDlg:refreshInfo()
    -- 发放红包持续时间
    local grantPanel = self:getControl("GrantPanel")
    self:setLabelText("ConValueLabel", self.sendTotalTime, grantPanel)

    -- 每次几个红包
    local numPanel = self:getControl("NumPanel")
    self:setLabelText("ConValueLabel", self.count, numPanel)

    -- 丫鬟数量
    self:setLabelText("NoteLabel_4", string.format(CHS[6400057], self.personNum))

    -- 总共发放红包个数
    local totalNum = self.sendTotalTime * timesEveryMinute * self.count * self.personNum
    self:setLabelText("NoteLabel_10", string.format(CHS[6400058], totalNum))

    -- 每个红包多少钱
    local moneyPanel = self:getControl("MoneyPanel")
    self:setLabelText("ConValueLabel", self.price, moneyPanel)

    -- 每个红包最小金额
    local moenyStr, color = gf:getMoneyDesc(minPrice, true)
    self:setLabelText("NoteLabel_6", moenyStr, nil, color)

    -- 身上的金钱
    local moenyStr, color = gf:getMoneyDesc(Me:queryBasicInt("cash"), true)
    self:setLabelText("NoteLabel_8", moenyStr, nil, color)

    -- 总金额
    local totalMoey = totalNum * self.price
    local moenyStr, color = gf:getMoneyDesc(totalMoey, true)
    self:setLabelText("TotalMoneyLabel", moenyStr, nil, color)

    self:updateLayout("MainBodyPanel")
end

-- 获取总的金额
function AngpaoDlg:getTotalNum()
    return self.sendTotalTime * timesEveryMinute * self.count * self.personNum * self.price
end

function AngpaoDlg:onDlgOpened(list)
    self:setInfo(list[1])
end

return AngpaoDlg
