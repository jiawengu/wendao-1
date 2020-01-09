-- GetTaoTrusteeshipSupplyTimeDlg.lua
-- Created by songcw Oct/13/2016
-- 购买在线托管时间

local GetTaoTrusteeshipSupplyTimeDlg = Singleton("GetTaoTrusteeshipSupplyTimeDlg", Dialog)

function GetTaoTrusteeshipSupplyTimeDlg:init()
    self:bindListener("SupplyButton", self.onSupplyButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("MaxButton", self.onMaxButton)

    -- 输入面板
    self:bindNumInput("InputTimePanel")
    self.buyTime = 0
    local data = GetTaoMgr:getTrusteeshipData()
    self:setLabelText("TimeValueLabel", data.ti, "TimePanel")
    self:setStartTime(0)

    self:hookMsg("MSG_UPDATE")
end

function GetTaoTrusteeshipSupplyTimeDlg:cleanup()
    self.topLayerForFloat = nil
end

function GetTaoTrusteeshipSupplyTimeDlg:comfireNumber()
    local data = GetTaoMgr:getTrusteeshipData()
    local maxTi = GetTaoMgr:getLevelTrusteeshipTimeByVip(Me:getVipType())
    if self.buyTime + data.ti < 10 then
        gf:ShowSmallTips(CHS[4200190])

        self.buyTime = 10 - data.ti
        self:setStartTimeAndCost(10 - data.ti)
    end
end

function GetTaoTrusteeshipSupplyTimeDlg:insertNumber(num)
    local data = GetTaoMgr:getTrusteeshipData()
    local retValue = num
    local maxTi = GetTaoMgr:getLevelTrusteeshipTimeByVip(Me:getVipType())
    if retValue + data.ti > maxTi then

        if maxTi - data.ti <= 0 then
            ChatMgr:sendMiscMsg(CHS[4300169])
            gf:ShowSmallTips(CHS[4300169])

            DlgMgr:closeDlg("SmallNumInputDlg")
            self:onCloseButton()
            return
        end

        retValue = maxTi - data.ti

        if GetTaoMgr:isNightTrusteeship() then
            -- 夜间
            if Me:getVipType() ~= 3 then
                gf:ShowSmallTips(string.format(CHS[4200537], maxTi))   -- 当前最多只可夜间托管#R%d分钟#n，提升位列仙班等级可托管更长时间。
            else
                gf:ShowSmallTips(string.format(CHS[4200538], maxTi)) -- 最多只可夜间托管#R%d分钟#n。
            end
        else
            if Me:getVipType() ~= 3 then
                gf:ShowSmallTips(string.format(CHS[4100392], maxTi))
            else
                gf:ShowSmallTips(string.format(CHS[4100393], maxTi))
            end
        end
    end

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(retValue)
    end
    self.buyTime = retValue
    self:setStartTimeAndCost(retValue)
end

-- 设置输入时间和消耗金钱
function GetTaoTrusteeshipSupplyTimeDlg:setStartTimeAndCost(retValue)
    local data = GetTaoMgr:getTrusteeshipData()
    if retValue + data.ti < 10 then
        self:setLabelText("InfoLabel", retValue, "InputTimePanel", COLOR3.RED)
    else
        self:setLabelText("InfoLabel", retValue, "InputTimePanel", COLOR3.TEXT_DEFAULT)
    end

    self:setStartTime(retValue)
end

function GetTaoTrusteeshipSupplyTimeDlg:setStartTime(retValue)
    local costText, costfontColor = gf:getArtFontMoneyDesc(retValue * 5000)
    self:setNumImgForPanel("CostMoneyPanel", costfontColor, costText, false, LOCATE_POSITION.MID, 21)

    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 21)
end


function GetTaoTrusteeshipSupplyTimeDlg:onSupplyButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.buyTime <= 0 then
        gf:ShowSmallTips(CHS[4100396])
        return
    end

    local data = GetTaoMgr:getTrusteeshipData()
    if self.buyTime + data.ti < 10 then
        gf:ShowSmallTips(CHS[4100397])
        return
    end


    local nomarMaxTi = GetTaoMgr:getLevelTrusteeshipTimeByType(1, Me:getVipType())

    local function goonFun( )
        -- body
        if not GetTaoMgr:isNightTrusteeship() and (self.buyTime + data.ti) > nomarMaxTi then
            gf:ShowSmallTips(CHS[4200545])   -- 当前不处于夜间托管时间（22:00-02:00），请重新进行操作。
            ChatMgr:sendMiscMsg(CHS[4200545])
            self:onCloseButton()
            return
        end

        local cash = self.buyTime * 5000
        if cash > Me:queryBasicInt("cash") then
            gf:askUserWhetherBuyCash(cash)
            return
        end

        GetTaoMgr:buyTrusteeshipTime(self.buyTime)
        self:onCloseButton()
    end

    if GetTaoMgr:isNightTrusteeship() and (self.buyTime + data.ti) > nomarMaxTi then

        local tips = string.format( CHS[4200540], nomarMaxTi) -- #R夜间托管#n持续更长时间，但开启后无法主动#R暂停#n、无论是否下线都会开始#R消耗#n托管时间直到托管时间低于#R%d分钟#n，是否确认开启？\n（建议道友开启夜间托管后可立刻下线开始托管）

        gf:confirm(tips, function ( ... )
            -- body
            goonFun()
        end)
        return
    end

    goonFun()
end

function GetTaoTrusteeshipSupplyTimeDlg:onAddButton(sender, eventType)
    gf:showBuyCash()
end

function GetTaoTrusteeshipSupplyTimeDlg:onMaxButton(sender, eventType)
    local data = GetTaoMgr:getTrusteeshipData()
    local maxTi = GetTaoMgr:getLevelTrusteeshipTimeByVip(Me:getVipType())
    local buyTime = maxTi - data.ti
    if buyTime <= 0 then
        gf:ShowSmallTips(CHS[4300169])
        ChatMgr:sendMiscMsg(CHS[4300169])

        self:close()
        return
    end

    self.buyTime = buyTime
    self:setStartTimeAndCost(buyTime)
end

function GetTaoTrusteeshipSupplyTimeDlg:MSG_UPDATE()
    self:setStartTime(self.buyTime)
end

return GetTaoTrusteeshipSupplyTimeDlg
