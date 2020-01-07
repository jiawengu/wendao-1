-- GetTaoTrusteeshipDlg.lua
-- Created by songcw Oct/12/2016
-- 刷道托管界面

local GetTaoTrusteeshipDlg = Singleton("GetTaoTrusteeshipDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local GETTAO_CHECKBOS = {
    "XiangyCheckBox",
    "FumCheckBox",
    "FeixCheckBox"
}

local SET_CHECKBOS = {
    "YesCheckBox",
    "NoCheckBox",
}

function GetTaoTrusteeshipDlg:init()
    self:bindListener("AddCashButton", self.onAddCashButton)
    self:bindListener("AddBackupButton", self.onAddBackupButton)
    self:bindListener("MedicineButton", self.onMedicineButton)
    self:bindListener("SupermarketButton", self.onSupermarketButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("PauseButton", self.onPauseButton)
    self:bindListener("ContinueButton", self.onContinueButton)
    self:bindListener("SupplyTimeButton", self.onSupplyTimeButton)
    self:bindListener("TrustingTimePanel", self.onSupplyTimeButton, "PausePanel")
    self:bindListener("TrustingTimePanel", self.onSupplyTimeButton, "OnPanel")
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ResultButton", self.onResultButton)

    GetTaoMgr:addOrRemoveRedDot()

    -- 单选框初始化
    self:initRadio()

    -- 设置储备信息
    self:setBackupInfo()

    -- 打开数字键盘
    self.buyTruTi = 0

    -- 输入面板
    self:bindNumInput("InputTimePanel")

    -- 增加储备悬浮
    self:bindFloatPanel("AddReservePanel")


    self:setTrusteeshipDisplay()

    -- 请求数据
    GetTaoMgr:questTrusteeshData()

    self:hookMsg("MSG_REFRESH_SHUAD_TRUSTEESHIP")
    self:hookMsg("MSG_UPDATE")
end

function GetTaoTrusteeshipDlg:setTrusteeshipDisplay()
    local data = GetTaoMgr:getTrusteeshipData()
    if not data or not next(data) then return end

    local state = data.state

    self:setCtrlVisible("StartPanel", false)
    self:setCtrlVisible("OnPanel", false)
    self:setCtrlVisible("PausePanel", false)
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("PauseButton", false)
    self:setCtrlVisible("ContinueButton", false)
    self:setCtrlVisible("SupplyTimeButton", false)

    if state == TRUSTEESHIP_STATE.OFF then
        self:setCtrlVisible("StartPanel", true)
        self:setCtrlVisible("StartButton", true)

        self:setStartCash(self.buyTruTi)
    elseif state == TRUSTEESHIP_STATE.PAUSE then
        self:setCtrlVisible("PausePanel", true)
        self:setCtrlVisible("ContinueButton", true)
        self:setCtrlVisible("SupplyTimeButton", true)

        self:setLabelText("TimeValueLabel", data.ti, "PausePanel")
    else
        self:setCtrlVisible("OnPanel", true)
        self:setCtrlVisible("PauseButton", true)
        self:setCtrlVisible("SupplyTimeButton", true)

        self:setLabelText("TimeValueLabel", data.ti, "OnPanel")

        if data.ti > GetTaoMgr:getLevelTrusteeshipTimeByType(1, Me:getVipType()) then
            self:setLabelText("OnLabel", CHS[4200535], "OnPanel")   -- 夜间托管开启中...
        else
            self:setLabelText("OnLabel", CHS[4200536], "OnPanel") -- 托管开启中...
        end
    end

    if data.task_name == CHS[3002654] then
        self:setCheck("XiangyCheckBox", true)
        self:setCheck("FumCheckBox", false)
        self:setCheck("FeixCheckBox", false)
        self.lastSelect = "XiangyCheckBox"
    elseif data.task_name == CHS[3002655] then
        self:setCheck("XiangyCheckBox", false)
        self:setCheck("FumCheckBox", true)
        self:setCheck("FeixCheckBox", false)
        self.lastSelect = "FumCheckBox"
    else
        self:setCheck("XiangyCheckBox", false)
        self:setCheck("FumCheckBox", false)
        self:setCheck("FeixCheckBox", true)
        self.lastSelect = "FeixCheckBox"
    end

    -- 智能托管
    if data.is_smart == 1 then
        self.getTaoSetGroup:setSetlctByName("YesCheckBox", true)
    else
        self.getTaoSetGroup:setSetlctByName("NoCheckBox", true)
    end
end

function GetTaoTrusteeshipDlg:comfireNumber()
    if self.buyTruTi < 10 then
        gf:ShowSmallTips(CHS[4200189])
        self:setStartTimeAndCost(10)
    end
end

function GetTaoTrusteeshipDlg:insertNumber(num)
    local retValue = num
    if retValue > GetTaoMgr:getLevelTrusteeshipTimeByVip(Me:getVipType()) then
        retValue = GetTaoMgr:getLevelTrusteeshipTimeByVip(Me:getVipType())


        if GetTaoMgr:isNightTrusteeship() then
            -- 夜间
            if Me:getVipType() ~= 3 then
                gf:ShowSmallTips(string.format(CHS[4200530], retValue))   -- 当前最多只可夜间托管#R%d分钟#n，提升位列仙班等级可托管更长时间。
            else
                gf:ShowSmallTips(string.format(CHS[4200531], retValue))  -- 最多只可夜间托管#R%d分钟#n。
            end
        else
            if Me:getVipType() ~= 3 then
                gf:ShowSmallTips(string.format(CHS[4100392], retValue))
            else
                gf:ShowSmallTips(string.format(CHS[4100393], retValue))
            end
        end
    end

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(retValue)
    end
    self:setStartTimeAndCost(retValue)
end

-- 设置输入时间和消耗金钱
function GetTaoTrusteeshipDlg:setStartTimeAndCost(retValue)
    self.buyTruTi = retValue

    if retValue < 10 then
        self:setLabelText("InfoLabel", retValue, "InputTimePanel", COLOR3.RED)
    else
        self:setLabelText("InfoLabel", retValue, "InputTimePanel", COLOR3.TEXT_DEFAULT)
    end

    local costText, costfontColor = gf:getArtFontMoneyDesc(retValue * 5000)
    self:setNumImgForPanel("CostMoneyPanel", costfontColor, costText, false, LOCATE_POSITION.MID, 21)

    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 21)
end

function GetTaoTrusteeshipDlg:setStartCash(retValue)
    local costText, costfontColor = gf:getArtFontMoneyDesc(retValue * 5000)
    self:setNumImgForPanel("CostMoneyPanel", costfontColor, costText, false, LOCATE_POSITION.MID, 21)

    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 21)
end

function GetTaoTrusteeshipDlg:cleanup()
    self.topLayerForFloat = nil
end

-- 点击勾选框
function GetTaoTrusteeshipDlg:onCheckBox(sender, eventType)
    if sender:getName() == "FumCheckBox" and Me:queryBasicInt("level") < 80 then
        self:setCheck("XiangyCheckBox", true)
        self:setCheck("FumCheckBox", false)
        gf:ShowSmallTips(CHS[4100394])
        return
    end

    if sender:getName() == "FeixCheckBox" and Me:queryBasicInt("level") < 120 then
        self:setCheck(self.lastSelect, true)
        self:setCheck("FeixCheckBox", false)
        gf:ShowSmallTips(CHS[4000447])
        return
    end

    local task = CHS[5000160]
    if sender:getName() == "FumCheckBox" then
        task = CHS[5000161]
    elseif sender:getName() == "FeixCheckBox" then
        task = CHS[4000444]
    end

    self.lastSelect = sender:getName()
    GetTaoMgr:setTrusteeshipTask(task)
end

-- 点击刷道设置勾选框
function GetTaoTrusteeshipDlg:onSetCheckBox(sender, eventType)
    local name = sender:getName()

    if name == "YesCheckBox" then
        -- 开启刷道智能托管
        GetTaoMgr:setSmartState(1)
    else
        -- 关闭智能托管
        GetTaoMgr:setSmartState(0)
    end
end

-- 单选框初始化
function GetTaoTrusteeshipDlg:initRadio()
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, GETTAO_CHECKBOS, self.onCheckBox)

    self.getTaoSetGroup = RadioGroup.new()
    self.getTaoSetGroup:setItems(self, SET_CHECKBOS, self.onSetCheckBox)
end

function GetTaoTrusteeshipDlg:bindFloatPanel(name)
    if not self.topLayerForFloat then
        self.topLayerForFloat = cc.Layer:create()
        self.topLayerForFloat:setLocalZOrder(100)
        self.topLayerForFloat:setTouchEnabled(false)
        self.root:addChild(self.topLayerForFloat)
    end

    gf:bindTouchListener(self.topLayerForFloat, function(touch, event)
        -- 记住当前点击的位置
        local curTouchPos = touch:getLocation()
        if event:getEventCode() == cc.EventCode.BEGAN then
            local panel = self:getControl(name)
            if not panel then return end
            local rect = self:getBoundingBoxInWorldSpace(panel)

            if cc.rectContainsPoint(rect, curTouchPos) then

            else
                panel:setVisible(false)
            end
        end

        -- 需要往后传递
        return true
    end, {
        cc.Handler.EVENT_TOUCH_BEGAN,
    }, true)
end

-- 设置储备信息
function GetTaoTrusteeshipDlg:setBackupInfo()
    local parentPanel = self:getControl("StorePanel")
    local panel = self:getControl("StorePanel", nil, parentPanel)
    self:setLabelText("LoyaltyStoreValueLabel", Me:query("backup_loyalty"), panel)
    self:setLabelText("LifeStoreValueLabel", Me:query("extra_life"), panel)
    self:setLabelText("ManaStoreValueLabel", Me:query("extra_mana"), panel)
    panel:requestDoLayout()

    -- 增加储备信息
    self:setAddBackupPanel()
end

function GetTaoTrusteeshipDlg:setAddBackupPanel()
    local function generalConditions(level)
        -- 处于禁闭状态
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        if Me:queryInt("level") < level then
            gf:ShowSmallTips(string.format(CHS[3002380], level))
            return
        end

        return true
    end

    local panel = self:getControl("AddReservePanel")
    local lifePanel = self:getControl("LifePanel", nil, panel)
    self:setImage("GuardImage", ResMgr:getIconPathByName(CHS[3002595]), lifePanel)
    self:setItemImageSize("GuardImage", lifePanel)
    self:bindListener("AddButton", function(dlg, sender, eventType)
        self:setCtrlVisible("AddReservePanel", true)
        if not generalConditions(10) then return end

        if Me:queryInt("extra_life") + 300000 > Const.MAX_LIFE_STORE then
            gf:ShowSmallTips(CHS[3003770])
            return
        end

        local cost = 120000  * (1 + Me:queryBasicInt("total_pk") * 0.05)
        local money = gf:getMoneyDesc(cost)
        gf:confirm(string.format(CHS[3003772], money), function()
            if not gf:checkHasEnoughMoney(cost) then
                gf:askUserWhetherBuyCash(cost)
                return
            end

            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FAST_ADD_EXTRA, 1)
        end)

    end, lifePanel)

    local manaPanel = self:getControl("ManaPanel", nil, panel)
    self:setImage("GuardImage", ResMgr:getIconPathByName(CHS[3002598]), manaPanel)
    self:setItemImageSize("GuardImage", manaPanel)
    self:bindListener("AddButton", function(dlg, sender, eventType)
        self:setCtrlVisible("AddReservePanel", true)
        if not generalConditions(10) then return end

        if Me:queryInt("extra_mana") + 300000 > Const.MAX_MANA_STORE then
            gf:ShowSmallTips(CHS[3003773])
            return
        end

        local cost = 360000  * (1 + Me:queryBasicInt("total_pk") * 0.05)
        local money = gf:getMoneyDesc(cost)
        gf:confirm(string.format(CHS[3003774], money), function()
            if not gf:checkHasEnoughMoney(cost) then
                gf:askUserWhetherBuyCash(cost)
                return
            end

            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FAST_ADD_EXTRA, 2)
        end)
    end, manaPanel)

    local loyaltyPanel = self:getControl("LoyaltyPanel", nil, panel)
    self:setImage("GuardImage", ResMgr:getIconPathByName(CHS[3002601]), loyaltyPanel)
    self:setItemImageSize("GuardImage", loyaltyPanel)
    self:bindListener("AddButton", function(dlg, sender, eventType)
        self:setCtrlVisible("AddReservePanel", true)
        if not generalConditions(20) then return end

        if Me:queryInt("backup_loyalty") + 300 > 3000000 then
            gf:ShowSmallTips(CHS[3003776])
            return
        end

        local money = gf:getMoneyDesc(1800000 * (1 + Me:queryBasicInt("total_pk") * 0.05))
        gf:confirm(string.format(CHS[3003777], money), function()
            if not gf:checkHasEnoughMoney(1800000) then
                gf:askUserWhetherBuyCash(1800000)
                return
            end

            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FAST_ADD_EXTRA, 3)
        end)
    end, loyaltyPanel)
end

function GetTaoTrusteeshipDlg:onAddCashButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    gf:showBuyCash()
end

function GetTaoTrusteeshipDlg:onAddBackupButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local addBackupPanel = self:getControl("AddReservePanel")
    local isVisible = addBackupPanel:isVisible()
    addBackupPanel:setVisible(not isVisible)

    if not addBackupPanel:isVisible() then return end

    -- 若角色PK值大于0，给出提示
    if Me:queryBasicInt("total_pk") > 0 then
        gf:ShowSmallTips(CHS[7000062])
    end
end

function GetTaoTrusteeshipDlg:onMedicineButton()
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300029]))
    self:onCloseButton()
end

function GetTaoTrusteeshipDlg:onSupermarketButton()
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300030]))
    self:onCloseButton()
end

function GetTaoTrusteeshipDlg:onStartButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 有老君发怒时
    if TaskMgr:isExistTaskByName(CHS[6000562]) then
        gf:ShowSmallTips(CHS[4300193])
        return
    end

    if self.buyTruTi < 10 then
        gf:ShowSmallTips(CHS[4100395])
        return
    end

    local nomarMaxTi = GetTaoMgr:getLevelTrusteeshipTimeByType(1, Me:getVipType())

    local function goonFun( )
        -- body
        if not GetTaoMgr:isNightTrusteeship() and self.buyTruTi > nomarMaxTi then
            gf:ShowSmallTips(CHS[4200532])   -- 当前不处于夜间托管时间（22:00-02:00），请重新进行操作。
            ChatMgr:sendMiscMsg(CHS[4200539])
            self:setStartTimeAndCost(nomarMaxTi)
            return
        end

        local cash = self.buyTruTi * 5000
        if cash > Me:queryBasicInt("cash") then
            gf:askUserWhetherBuyCash(cash)
            return
        end

        GetTaoMgr:openTrusteeship(self.buyTruTi)
    end

    if GetTaoMgr:isNightTrusteeship() and self.buyTruTi > nomarMaxTi then

        local tips = string.format(CHS[4200533], nomarMaxTi) -- #R夜间托管#n持续更长时间，但开启后无法主动#R暂停#n、无论是否下线都会开始#R消耗#n托管时间直到托管时间低于#R%d分钟#n，是否确认开启？\n（建议道友开启夜间托管后可立刻下线开始托管）

        gf:confirm(tips, function ( ... )
            -- body
            goonFun()
        end)
        return
    end

    goonFun()
end

function GetTaoTrusteeshipDlg:onPauseButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local normalTruTime = GetTaoMgr:getLevelTrusteeshipTimeByType(1, Me:getVipType())
    if GetTaoMgr:getTrusteeshipData().ti > normalTruTime then

        local tip = string.format(CHS[4200534], normalTruTime)
        gf:confirm(tip, function ()
            GetTaoMgr:setTrusteeshState(2)
        end)
        return
    end

    GetTaoMgr:setTrusteeshState(2)
end

function GetTaoTrusteeshipDlg:onContinueButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 有老君发怒时
    if TaskMgr:isExistTaskByName(CHS[6000562]) then
        gf:ShowSmallTips(CHS[4300193])
        return
    end

    GetTaoMgr:setTrusteeshState(1)
end

function GetTaoTrusteeshipDlg:onSupplyTimeButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local data = GetTaoMgr:getTrusteeshipData()
    if data.ti >= GetTaoMgr:getLevelTrusteeshipTimeByVip(Me:getVipType()) then
        gf:ShowSmallTips(CHS[4300168])
        return
    end

    -- 有老君发怒时
    if TaskMgr:isExistTaskByName(CHS[6000562]) then
        gf:ShowSmallTips(CHS[4300193])
        return
    end

    DlgMgr:openDlg("GetTaoTrusteeshipSupplyTimeDlg")
end

function GetTaoTrusteeshipDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("GetTaoTrusteeshipRuleDlg")
end

function GetTaoTrusteeshipDlg:onResultButton(sender, eventType)
    GetTaoMgr:queryTrusteeshipInfo()
end

function GetTaoTrusteeshipDlg:MSG_REFRESH_SHUAD_TRUSTEESHIP(data)
    -- 根据状态设置界面
    self:setTrusteeshipDisplay(data)
end

function GetTaoTrusteeshipDlg:MSG_UPDATE(data)
    -- 设置储备信息
    self:setBackupInfo()
    self:setStartCash(self.buyTruTi)
end

return GetTaoTrusteeshipDlg
