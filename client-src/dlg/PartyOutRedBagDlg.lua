-- PartyOutRedBagDlg.lua
-- Created by zhengjh Aug/26/2016
-- 帮派发送红包界面

local PartyOutRedBagDlg = Singleton("PartyOutRedBagDlg", Dialog)
local MAX_RED_BAG_MONEY = 30000

function PartyOutRedBagDlg:init()
    self:bindPressForIntervalCallback('ConAddButton', 0.1, self.onConAddButton, 'times')
    self:bindPressForIntervalCallback('ConReduceButton', 0.1, self.onConReduceButton, 'times')

    self:bindPressForIntervalCallback('NumAddButton', 0.1, self.onNumAddButton, 'numTimes')
    self:bindPressForIntervalCallback('NumReduceButton', 0.1, self.onNumReduceButton, 'numTimes')

    self:bindPressForIntervalCallback('NumAddButton', 0.1, self.onActMoneyAddButton, 'ActiveMoneyNumTimes', "TotalConPanel")
    self:bindPressForIntervalCallback('NumReduceButton', 0.1, self.onActMoneyReduceButton, 'ActiveMoneyNumTimes', "TotalConPanel")

    self:bindPressForIntervalCallback('NumAddButton', 0.1, self.onActRedBagNumAddButton, 'ActiveMoneyNumTimes', "RedBagNumPanel")
    self:bindPressForIntervalCallback('NumReduceButton', 0.1, self.onActRedBagNumReduceButton, 'ActiveMoneyNumTimes', "RedBagNumPanel")

    self:bindFloatPanelListener("SelectRedBagTypePanel")
    self:bindFloatPanelListener("SelectAvtivePanel")

    self:bindListener("ConfirmButton", self.onConfirmButton)

    self:bindListener("ExpandButton", self.onExpandButton)

    self:bindListener("PartyAllButton", self.onPartyAllPanel)
    self:bindListener("PartyActiveButton", self.onPartyActivePanel)

    self:onPartyAllPanel()

    local partyActivePanel = self:getControl("PartyActivePanel")
    local activePanel = self:getControl("ActivePanel")
    self:bindListener("ExpandButton", self.onActiveExpandButton, activePanel)
    self:bindListener("RespondPanel", self.onActiveExpandButton, activePanel)

    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("DelAllButton", self.onDelAllButton, "ActiveMessageInputPanel")
    self:bindListener("OutRedBagButton", self.onOutRedBagButton)
    self:bindListener("NoteButton", self.onNoteButton)

    self.unitActivePanel = self:retainCtrl("UnitNumPanel")

    self:bindEditFieldForSafe("MessageInputPanel", 20, "DelAllButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, true)
    self:bindEditFieldForSafe("ActiveMessageInputPanel", 20, "DelAllButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, true)

    self:initBindNumInput()

    self.money = 0
    self.actMoney = 0
    self.num = 0
    self.actNum = 0
    self.curActiveInfo = nil

    -- 请求数据
    PartyMgr:requestRedBgaInfo()

    self:setUiInfo()
    self:hookMsg("MSG_PT_RB_SEND_INFO")
end

function PartyOutRedBagDlg:initBindNumInput()

    -- 绑定数字键盘
    self:bindNumInput("RespondPanel", "MoneyConPanel", nil, "money")
    self:bindNumInput("RespondPanel", "NumConPanel", function ()
        if self.money == 0 then
            gf:ShowSmallTips(CHS[6000449])
            return true
        end
    end, "number")

        -- 绑定数字键盘
    self:bindNumInput("RespondPanel", "TotalConPanel", function ( )
        -- body
        if not self.curActiveInfo then
            gf:ShowSmallTips(CHS[4200582])
            return true
        end
    end, "active_money")
    self:bindNumInput("RespondPanel", "RedBagNumPanel", function ()
        if not self.curActiveInfo then
            gf:ShowSmallTips(CHS[4200582])
            return true
        end

        if self.actMoney == 0 then
            gf:ShowSmallTips(CHS[6000449])
            return true
        end
    end, "active_number")
end

function PartyOutRedBagDlg:setUiInfo()
    local info = PartyMgr:getPartyRedBagInfo()
    self:setLabelText("HaveMoneyLabel", Me:queryInt("gold_coin"))
    self:setLabelText("PartyMemberNumLable", info.memberCount or 0)
    self:setLabelText("SurplusTimeLabel", info.leftTimes or 0)

    self:setLabelText("OwnCoinLabel", string.format( CHS[4200583], Me:queryInt("gold_coin")), "PartyActivePanel")
end

-- 数字键盘插入数字
function PartyOutRedBagDlg:insertNumber(num, key)
    if key == "money" or key == "active_money" then
        self:updateMoneyPanel(num, key)
    elseif key == "number" or key == "active_number" then
        self:updateNumPanel(num, key)
    end
end

function PartyOutRedBagDlg:updateNumPanel(num, key)

    local maxNum = self:getMaxNum()
    if key == "active_number" then
        maxNum = self:getMaxNum(self.actMoney)
    end

    local minNum = 0

    if num > maxNum then
        num = maxNum
        gf:ShowSmallTips(string.format(CHS[6000450], num))
    elseif num < minNum then
        num = minNum
        gf:ShowSmallTips(string.format(CHS[6000451], num))
    end

    if key == "active_number" then
        self.actNum = num
        self:setNumLabel(self.actNum, "RedBagNumPanel")
    else
        self.num = num
        self:setNumLabel(self.num)
    end

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(num)
    end
end

function PartyOutRedBagDlg:updateMoneyPanel(num, key)
    local money = num

    if num > MAX_RED_BAG_MONEY then
        money = MAX_RED_BAG_MONEY
        gf:ShowSmallTips(string.format(CHS[6000447], money))
    elseif num < 0 then
        money = 0
        gf:ShowSmallTips(string.format(CHS[6000448], money))
    end

    if key == "money" then
        self.money = money
        self:setMoneyLabel(self.money)
    else
        self.actMoney = money
        self:setActMoneyLabel(self.actMoney)
    end

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(money)
    end
end

function PartyOutRedBagDlg:setActMoneyLabel(money)

    local moneyConPanel = self:getControl("TotalConPanel")
    self:setLabelText("NumLabel", money, moneyConPanel)
    self:setCtrlVisible("NumLabel", true, moneyConPanel)
    self:setCtrlVisible("MoneyImage", true, moneyConPanel)
    self:setCtrlVisible("DefaultLabel", false, moneyConPanel)

    if money >= MAX_RED_BAG_MONEY then
        self:setCtrlEnabled("NumAddButton", false, "TotalConPanel")
    else
        self:setCtrlEnabled("NumAddButton", true, "TotalConPanel")
    end


    if money <= 0 then
        self:setCtrlEnabled("NumReduceButton", false, "TotalConPanel")
    else
        self:setCtrlEnabled("NumReduceButton", true, "TotalConPanel")
    end

    -- 设置红包个数范围
    self:setActNumRange()
    self:refreshNumPanelButtonState(self.actNum, "RedBagNumPanel")
end

function PartyOutRedBagDlg:setMoneyLabel(money)

    local moneyConPanel = self:getControl("MoneyConPanel")
    self:setLabelText("BonusNumLabel", money, moneyConPanel)
    self:setCtrlVisible("BonusNumLabel", true, moneyConPanel)
    self:setCtrlVisible("MoneyImage", true, moneyConPanel)
    self:setCtrlVisible("DefaultLabel", false, moneyConPanel)

    if money >= MAX_RED_BAG_MONEY then
        self:setCtrlEnabled("ConAddButton", false)
    else
        self:setCtrlEnabled("ConAddButton", true)
    end

    if money <= 0 then
        self:setCtrlEnabled("ConReduceButton", false)
    else
        self:setCtrlEnabled("ConReduceButton", true)
    end

    -- 设置红包个数范围
    self:setNumRange()
    self:refreshNumPanelButtonState(self.num)
end

function PartyOutRedBagDlg:getMaxNum(money)
    if not money then money = self.money end

    return math.min(100, math.floor(money / 300 * 3))
end

function PartyOutRedBagDlg:getMinNum(money)
    if not money then money = self.money end
    return math.max(math.floor(money /600), 10)
end

function PartyOutRedBagDlg:setNumLabel(num, panelName)
    panelName = panelName or "NumConPanel"
    local numConPanel = self:getControl(panelName)
    self:setLabelText("NumLabel", num, numConPanel)
    self:setCtrlVisible("NumLabel", true, numConPanel)
    self:setCtrlVisible("DefaultLabel", false, numConPanel)

    self:refreshNumPanelButtonState(num, panelName)

    -- 设置红包个数范围
    if panelName ~= "NumConPanel" then
        self:setActNumRange()
    else
        self:setNumRange()
    end
end

-- 刷新红包个数的面板加号和减号置灰状态
function PartyOutRedBagDlg:refreshNumPanelButtonState(num, panelName)
    if not num then return end
    local maxNum = self:getMaxNum()
    local minNum = 0

    if panelName == "NumConPanel" then

        if num >= maxNum then
            self:setCtrlEnabled("NumAddButton", false)
        else
            self:setCtrlEnabled("NumAddButton", true)
        end

        if num <= minNum then
            self:setCtrlEnabled("NumReduceButton", false)
        else
            self:setCtrlEnabled("NumReduceButton", true)
        end

    else
        maxNum = self:getMaxNum(self.actMoney)

        if num >= maxNum then
            self:setCtrlEnabled("NumAddButton", false, "RedBagNumPanel")
        else
            self:setCtrlEnabled("NumAddButton", true, "RedBagNumPanel")
        end

        if num <= minNum then
            self:setCtrlEnabled("NumReduceButton", false, "RedBagNumPanel")
        else
            self:setCtrlEnabled("NumReduceButton", true, "RedBagNumPanel")
        end
    end
end

function PartyOutRedBagDlg:onConAddButton(sender, eventType)
    self.money = self.money + 1000
    if self.money  > MAX_RED_BAG_MONEY then
        self.money = MAX_RED_BAG_MONEY
        gf:ShowSmallTips(string.format(CHS[6000447], self.money))
    end

    self:setMoneyLabel(self.money)
end

function PartyOutRedBagDlg:onConReduceButton(sender, eventType)
    self.money = self.money - 1000
    if self.money < 0 then
        self.money = 0
        gf:ShowSmallTips(string.format(CHS[6000448], self.money))
    end

    self:setMoneyLabel(self.money)
end

function PartyOutRedBagDlg:onActMoneyAddButton(sender, eventType)
    if not self.curActiveInfo then
        gf:ShowSmallTips(CHS[4200582])
        return true
    end

    self.actMoney = self.actMoney + 1000
    if self.actMoney  > MAX_RED_BAG_MONEY then
        self.actMoney = MAX_RED_BAG_MONEY
        gf:ShowSmallTips(string.format(CHS[6000447], self.actMoney))
    end

    self:setActMoneyLabel(self.actMoney)
end

function PartyOutRedBagDlg:onActMoneyReduceButton(sender, eventType)
    if not self.curActiveInfo then
        gf:ShowSmallTips(CHS[4200582])
        return true
    end

    self.actMoney = self.actMoney - 1000
    if self.actMoney < 0 then
        self.actMoney = 0
        gf:ShowSmallTips(string.format(CHS[6000448], self.actMoney))
    end

    self:setActMoneyLabel(self.actMoney)
end

function PartyOutRedBagDlg:onActRedBagNumAddButton(sender, eventType)
    if not self.curActiveInfo then
        gf:ShowSmallTips(CHS[4200582])
        return true
    end

    if self.actMoney == 0 then
        gf:ShowSmallTips(CHS[6000449])
        return true
    end

    self.actNum = self.actNum + 1

    local maxNum = self:getMaxNum(self.actMoney)
    local minNum = 0

    if  self.actNum > maxNum then
        self.actNum = maxNum
        gf:ShowSmallTips(string.format(CHS[6000450], self.actNum))
    elseif  self.actNum < minNum then
        self.actNum = minNum
        gf:ShowSmallTips(string.format(CHS[6000451], self.actNum))
    end

    self:setNumLabel(self.actNum, "RedBagNumPanel")
end

function PartyOutRedBagDlg:onActRedBagNumReduceButton(sender, eventType)

    if not self.curActiveInfo then
        gf:ShowSmallTips(CHS[4200582])
        return true
    end

    if self.actMoney == 0 then
        gf:ShowSmallTips(CHS[6000449])
        return true
    end

    self.actNum = self.actNum - 1
    local maxNum = self:getMaxNum(self.actMoney)
    local minNum = 0

    if self.actNum > maxNum then
        self.actNum = maxNum
        gf:ShowSmallTips(string.format(CHS[6000450], self.actNum))
    elseif self.actNum < minNum then
        self.actNum = minNum
        gf:ShowSmallTips(string.format(CHS[6000451], self.actNum))
    end

    self:setNumLabel(self.actNum, "RedBagNumPanel")
end

function PartyOutRedBagDlg:onNumAddButton(sender, eventType)
    if self.money == 0 then
        gf:ShowSmallTips(CHS[6000449])
        return true
    end

    self.num = self.num + 1

    local maxNum = self:getMaxNum()
    local minNum = 0

    if  self.num > maxNum then
        self.num = maxNum
        gf:ShowSmallTips(string.format(CHS[6000450], self.num))
    elseif  self.num < minNum then
        self.num = minNum
        gf:ShowSmallTips(string.format(CHS[6000451], self.num))
    end

    self:setNumLabel(self.num)
end

function PartyOutRedBagDlg:onNumReduceButton(sender, eventType)
    if self.money == 0 then
        gf:ShowSmallTips(CHS[6000449])
        return true
    end

    self.num = self.num - 1
    local maxNum = self:getMaxNum()
    local minNum = 0

    if self.num > maxNum then
        self.num = maxNum
        gf:ShowSmallTips(string.format(CHS[6000450], self.num))
    elseif self.num < minNum then
        self.num = minNum
        gf:ShowSmallTips(string.format(CHS[6000451], self.num))
    end

    self:setNumLabel(self.num)
end

function PartyOutRedBagDlg:setActNumRange()
    if self.actMoney < 1000 then
        self:setLabelText("PartyRedBagNumLabel", 0, "PartyActivePanel")
    else
        self:setLabelText("PartyRedBagNumLabel", string.format(CHS[6000452], self:getMinNum(self.actMoney), self:getMaxNum(self.actMoney)), "PartyActivePanel")
    end

    local numConPanel = self:getControl("RedBagNumPanel")
    local label = self:getControl("NumLabel", nil, numConPanel)

    if self.actNum and (self.actNum > self:getMaxNum(self.actMoney) or self.actNum < self:getMinNum(self.actMoney)) then
        label:setColor(COLOR3.RED)
    else

        label:setColor(COLOR3.TEXT_DEFAULT)
    end

    self:updateLayout("MainPanel")
end


function PartyOutRedBagDlg:setNumRange()
    if self.money < 1000 then
        self:setLabelText("PartyRedBagNumLabel", 0)
    else
        self:setLabelText("PartyRedBagNumLabel", string.format(CHS[6000452], self:getMinNum(), self:getMaxNum()))
    end

    local numConPanel = self:getControl("NumConPanel")
    local label = self:getControl("NumLabel", nil, numConPanel)

    if self.num and (self.num > self:getMaxNum() or self.num < self:getMinNum()) then
        label:setColor(COLOR3.RED)
    else
        label:setColor(COLOR3.TEXT_DEFAULT)
    end

    self:updateLayout("MainPanel")
end

function PartyOutRedBagDlg:onPartyAllPanel(sender, eventType)
    self:setLabelText("RedBagTypeLabel", CHS[4200570])

    self:setCtrlVisible("PartyAllPanel", true)
    self:setCtrlVisible("PartyActivePanel", false)
    self:setCtrlVisible("SelectRedBagTypePanel", false)

    self.redBagType = CHS[4200570]
end

function PartyOutRedBagDlg:onPartyActivePanel(sender, eventType)
    self:setLabelText("RedBagTypeLabel", CHS[4200571])

    self:setCtrlVisible("PartyAllPanel", false)
    self:setCtrlVisible("PartyActivePanel", true)
    self:setCtrlVisible("SelectRedBagTypePanel", false)

    self.redBagType = CHS[4200571]
end


function PartyOutRedBagDlg:onConfirmButton(sender, eventType)
--    self:setLabelText("ActiveLabel", )

    if not self.curActive then return end

    local info = PartyMgr:getPartyRedBagInfo()
    local uInfo = info.activiesInfo[self.curActive]

    if not uInfo then return end

    if uInfo.participation < 10 then
        gf:ShowSmallTips(CHS[4200572])
        return
    end

    self.curActiveInfo = uInfo
    self:setLabelText("ActiveLabel", uInfo.name)
    self:setLabelText("ActiveMemberNumLabel", string.format( CHS[4200576], uInfo.participation))
    self:setLabelText("DefaultLabel", "", "ActivePanel")

    self:setCtrlVisible("SelectAvtivePanel", false)

    local panel = self:getControl("ActiveMessageInputPanel")
    local str = string.format(CHS[4200584],  self.curActiveInfo.name)
    self:setLabelText("DefaultLabel", str, panel)

    self:changeActive()
end


function PartyOutRedBagDlg:onExpandButton(sender, eventType)
    local info = PartyMgr:getPartyRedBagInfo()
    if not next(info) then return end

    self:setCtrlVisible("SelectRedBagTypePanel", true)
end

function PartyOutRedBagDlg:onDelAllButton(sender, eventType)
    local panel = sender:getParent()
    self:setInputText("TextField", "", panel)
    self:getControl("DelAllButton", nil, panel):setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, panel)
end

function PartyOutRedBagDlg:onOutRedBagButton(sender, eventType)

    local function isMeetMoneyAndNum( money, num)
        if money == 0 then
            gf:ShowSmallTips(CHS[6000459])
            return
        end

        if money < 1000 then
            gf:ShowSmallTips(CHS[6000476])
            return
        end

        if num == 0 then
            gf:ShowSmallTips(CHS[6000460])
            return
        end

        return true
    end

    local data = {}

    if self.redBagType == CHS[4200571] then
        if not self.curActiveInfo then
            gf:ShowSmallTips(CHS[4200573])
            return
        end

        if not isMeetMoneyAndNum(self.actMoney, self.actNum) then return end

        local panel = self:getControl("ActiveMessageInputPanel")
        local inputText = Dialog.getInputText(self, "TextField", panel)
        if not inputText or string.len(inputText) == 0 then
            inputText = string.format(CHS[4200584],  self.curActiveInfo.name)
        end

        data.money = self.actMoney or ""
        data.num = self.actNum or ""
        data.msg = inputText or ""

        data.actName = self.curActiveInfo.name or ""
        data.actId = self.curActiveInfo.activeId
    else
        if not isMeetMoneyAndNum(self.money, self.num) then return end

        local panel = self:getControl("MessageInputPanel")
        local inputText = Dialog.getInputText(self, "TextField", panel)
        if not inputText or string.len(inputText) == 0 then
            inputText = CHS[6000453]
        end

        data.money = self.money or ""
        data.num = self.num or ""
        data.msg = inputText or ""
        data.actName = ""
        data.actId = ""
    end

    local num = data.num
    local min = self:getMinNum(data.money)
    local max = self:getMaxNum(data.money)

    if self:checkSafeLockRelease("onOutRedBagButton", sender, eventType) then
        return
    end

    local function sendMsg()
        local _, haveBad = gf:filtText(inputText)
        if haveBad then
            return
        end

        if num < min or num > max then
            gf:ShowSmallTips(CHS[6000457])
            return
        end


        if Me:queryBasicInt("gold_coin") < (data.money or 0) then
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        end

        if Me:queryInt("level") < 50 then
            gf:ShowSmallTips(string.format(CHS[6000456], 50))
            return
        end

        local info = PartyMgr:getPartyRedBagInfo()
        if info and (not info.leftTimes or info.leftTimes <= 0) then
            gf:ShowSmallTips(CHS[6000455])
            return
        end

        if info and info.memberCount < PartyMgr:getLastRedBagNum() then
            gf:ShowSmallTips(string.format(CHS[6000454], PartyMgr:getLastRedBagNum()))
            return
        end

        PartyMgr:sendRedBag(data)
        DlgMgr:closeDlg(self.name)
    end


    gf:confirm(string.format(CHS[6000458], data.money), function ()
        sendMsg()
    end)
end

function PartyOutRedBagDlg:onNoteButton(sender, eventType)
    DlgMgr:openDlg("OutPartyRedBagRuleDlg")
end

function PartyOutRedBagDlg:MSG_PT_RB_SEND_INFO()
    self:setUiInfo()

    self:initActiveList()

    self:updateCurActiveIndex(1)
end

function PartyOutRedBagDlg:setUnitActive(data, panel)
    if not data then
        data = {}
        data.name = ""
        data.participation = ""
    end

    self:setLabelText("ActiveLabel", data.name, panel)

    if data.activeId and data.activeId == "" then
        self:setLabelText("NumberLabel", CHS[4200574], panel)
    else
        local str = data.participation == "" and "" or (data.participation .. CHS[4200575])
        self:setLabelText("NumberLabel", str, panel)
    end
end

-- 换活动
function PartyOutRedBagDlg:changeActive()
    local actMoneyPanel = self:getControl("TotalConPanel")
    self:setCtrlVisible("DefaultLabel", true, actMoneyPanel)
    self:setCtrlVisible("MoneyImage", false, actMoneyPanel)
    self:setLabelText("NumLabel", "", actMoneyPanel)
    self.actMoney = 0

    local actNumPanel = self:getControl("RedBagNumPanel")
    self:setCtrlVisible("DefaultLabel", true, actNumPanel)
    self:setLabelText("NumLabel", "", actNumPanel)
    self.actNum = 0
    self:setActNumRange()

    self:setCtrlEnabled("NumAddButton", true, "RedBagNumPanel")
    self:setCtrlEnabled("NumReduceButton", true, "RedBagNumPanel")
end

function PartyOutRedBagDlg:updateCurActiveIndex(num)
    self.curActive = num
end

function PartyOutRedBagDlg:onActiveExpandButton(sender)
    self:setCtrlVisible("SelectAvtivePanel", true)

    local list = self:getControl("ActiveListView")
    list:getInnerContainer():setPositionY(list:getContentSize().height - list:getInnerContainer():getContentSize().height)
    self:updateCurActiveIndex(1)
end


function PartyOutRedBagDlg:initActiveList()

    local info = PartyMgr:getPartyRedBagInfo()
    local list = self:resetListView("ActiveListView")

    -- 前后各加2个空位
    for i = 1, info.activiesCount + 4 do
        local panel = self.unitActivePanel:clone()
        panel:setTag(i)
        panel:setVisible(true)
        if i <= 2 or i >= info.activiesCount + 3 then
            self:setUnitActive(nil, panel)
        else
            self:setUnitActive(info.activiesInfo[i - 2], panel)
        end

        list:pushBackCustomItem(panel)
    end

    local function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            self.isScrolling = true

            local delay = cc.DelayTime:create(0.15)
            local func = cc.CallFunc:create(function()
                local _, offY = sender:getInnerContainer():getPosition()
                local befPercent = offY / (list:getInnerContainer():getContentSize().height - list:getContentSize().height) * 100 + 100
                local labelSize = self.unitActivePanel:getContentSize()
                local absOff = math.abs(offY)
                local num = (info.activiesCount + 2) - math.floor(absOff / labelSize.height)
                if absOff % labelSize.height > labelSize.height * 0.5 then num = num - 1 end
                local percent = ((num - 3) * labelSize.height)/ (list:getInnerContainer():getContentSize().height - list:getContentSize().height) * 100
                if ( 0.001 <= math.abs( befPercent - percent ) or num ~= (self.curActive + 2)) and num > 2 and offY < 0 then
                    sender:scrollToPercentVertical(percent, 0.5, false)
                    performWithDelay(sender, function ()
                        self.isScrolling = false
                    end,0.5)
                    self:updateCurActiveIndex(num - 2)
                elseif offY > 0 then
                    self:updateCurActiveIndex(4)
                elseif num <= 2 then
                    self:updateCurActiveIndex(1)
                end
            end)
            sender:stopAllActions()
            sender:runAction(cc.Sequence:create(delay, func))
        end
    end
    list:addScrollViewEventListener(scrollListener)

    performWithDelay(self.root,function ()
        list:getInnerContainer():setPositionY(0)
    end, 0)
end

return PartyOutRedBagDlg
