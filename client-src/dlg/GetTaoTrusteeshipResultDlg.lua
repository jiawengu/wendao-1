-- GetTaoTrusteeshipResultDlg.lua
-- Created by songcw Nov/23/2016
-- 刷道托管结算界面

local GetTaoTrusteeshipResultDlg = Singleton("GetTaoTrusteeshipResultDlg", Dialog)

function GetTaoTrusteeshipResultDlg:init()
end

function GetTaoTrusteeshipResultDlg:setData(data)
    -- 场次
    local countStr = gf:getMoneyDesc(data.count, true)
    self:setLabelText("NumLabel", countStr .. CHS[4300155], "StatisticsPanel1")
    
    -- 道行
    self:setLabelText("NumLabel", "+" .. gf:getTaoStr(data.tao, data.tao_ex), "StatisticsPanel6")
    
    -- 武学
    local martialStr = gf:getMoneyDesc(data.martial, true)
    self:setLabelText("NumLabel", "+" .. martialStr, "StatisticsPanel2")  
    
    -- 潜能
    local potStr = gf:getMoneyDesc(data.pot, true)
    self:setLabelText("NumLabel", "+" .. potStr, "StatisticsPanel3") 
    
    -- 金钱 or 代金券
    if data.cash > 0 and data.voucher > 0 then
        local cashStr = gf:getMoneyDesc(data.voucher + data.cash, true)
        self:setLabelText("NumLabel", "+" .. cashStr, "StatisticsPanel8") 
        self:setLabelText("NameLabel", CHS[4300167], "StatisticsPanel8") 
        self:setCtrlVisible("StatisticsPanel4", false)
        self:setCtrlVisible("StatisticsPanel8", true)
    elseif data.cash > 0 then
        local cashStr = gf:getMoneyDesc(data.cash, true)
        self:setLabelText("NumLabel", "+" .. cashStr, "StatisticsPanel4") 
        self:setCtrlVisible("StatisticsPanel4", true)
        self:setCtrlVisible("StatisticsPanel8", false)
    else
        local cashStr = gf:getMoneyDesc(data.voucher, true)
        self:setLabelText("NumLabel", "+" .. cashStr, "StatisticsPanel8") 
        self:setCtrlVisible("StatisticsPanel4", false)
        self:setCtrlVisible("StatisticsPanel8", true)
    end
    
    -- 积分
    local scoreStr = gf:getMoneyDesc(data.score, true)
    self:setLabelText("NumLabel", "+" .. scoreStr, "StatisticsPanel5") 

    -- 托管时间
    local timeStr = math.ceil(data.tru_time / 60)
    self:setLabelText("NumLabel", timeStr .. CHS[3002943], "StatisticsPanel7") 
end

return GetTaoTrusteeshipResultDlg
