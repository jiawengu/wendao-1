-- MarketPanicBuyDlg.lua
-- Created by songcw Jan/11/2017
-- 集市抢购界面

local MarketPanicBuyDlg = Singleton("MarketPanicBuyDlg", Dialog)

function MarketPanicBuyDlg:init()
    self:bindListener("TryBuyButton", self.onTryBuyButton, self.onBuyCanceled)
    self:bindListener("IconPanel", self.onIconPanel)

    self.tradeType = nil
    self.data = nil
    self.lock = nil

    DlgMgr:closeDlg("MarketGoldEquipmentInfoDlg")
    DlgMgr:closeDlg("MarketGoldPetInfoDlg")
    DlgMgr:closeDlg("MarketGoldArtifactInfoDlg")
    DlgMgr:closeDlg("MarketGoldJewerlyInfoDlg")

    self:hookMsg("MSG_STALL_BUY_RESULT")
    self:hookMsg("MSG_GOLD_STALL_BUY_RESULT")
    self:hookMsg("MSG_UPDATE")
end

-- WDSY-31474 原因重写接口，主要是为了调出  ccui.TouchEventType.canceled 事件回调
function MarketPanicBuyDlg:bindListener(ctrlName, func, cancelFun)
    local ctrl = self:getControl(ctrlName)
        -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            -- 记录点击时是否打开WaitDlg
            self.beganWaitDlgIsNotOpen = not DlgMgr:isDlgOpened("WaitDlg")
        elseif eventType == ccui.TouchEventType.ended then
            -- 控件长按过程中断线，则不进行后续事件处理
            if self.beganWaitDlgIsNotOpen and DlgMgr:isDlgOpened("WaitDlg") then
                return
            end

            self:touchEndEventFunc(sender, eventType, ctrl, func, data)
        elseif eventType == ccui.TouchEventType.canceled then
                        -- 控件长按过程中断线，则不进行后续事件处理
            if self.beganWaitDlgIsNotOpen and DlgMgr:isDlgOpened("WaitDlg") then
                return
            end

            if cancelFun then
                cancelFun(self)
            end
        end
    end

    ctrl:addTouchEventListener(listener)
end

function MarketPanicBuyDlg:setData(data, tradeType)
    self.tradeType = tradeType
    self.data = data

    self:setTips(data)

    -- icon
    local imgPath
    if PetMgr:getPetIcon(data.name) then
        imgPath =   ResMgr:getSmallPortrait(PetMgr:getPetIcon(data.name))
        data.name = PetMgr:getShowNameByRawName(data.name)
        local petShowName = MarketMgr:getPetShowName(data)
        data.petShowName = petShowName
    else
        local icon = InventoryMgr:getIconByName(data.name)
        imgPath = ResMgr:getItemIconPath(icon)
    end
    self:setImage("IconImage", imgPath)
    self:setItemImageSize("IconImage")

    -- 等级
    if  data.level > 0 then
        self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    if  data.req_level > 0 then
        self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(self:getControl("IconImage"), data.item_polar)
    end

    -- 带属性超级黑水晶
    if string.match(data.name, CHS[3003008]) then
        local name = string.gsub(data.name, CHS[3003009], "")
        local list = gf:split(name, "|")
        self:setLabelText("NameLabel", list[1])
        local field = EquipmentMgr:getAttribChsOrEng(list[1])
        local value = 0
        local maxValue = 0
        local bai = ""
        if list[2] then
            value =  tonumber(list[2])
            local equip = {req_level = data.level, equip_type = list[3]}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3003010])[field] then
                bai = "%"
            end
        end

        self:setLabelText("NameLabel2", value .. bai .. "/" .. maxValue .. bai)

        self:setCtrlVisible("NameLabel", true)
        self:setCtrlVisible("NameLabel2", true)
        self:setCtrlVisible("OneNameLabel", false)
    else
        -- 名字
        self:setLabelText("OneNameLabel", data.petShowName or data.name)
        self:setCtrlVisible("NameLabel", false)
        self:setCtrlVisible("NameLabel2", false)
        self:setCtrlVisible("OneNameLabel", true)
    end

    -- 金钱
    local str, color = gf:getMoneyDesc(data.price, true)
    self:setLabelText("CoinLabel", str, nil, color)
    self:setLabelText("CoinLabel2", str)

    self:setCashView()
end

-- 设置金钱
function MarketPanicBuyDlg:setCashView()
    self:setCtrlVisible("CoinImage", false)
    self:setCtrlVisible("GoldImage", false)

    self:setCtrlVisible("MoneyImage", false)
    self:setCtrlVisible("MyGoldImage", false)
    if MarketMgr:isGoldtype(self.tradeType) then
        self:setCtrlVisible("GoldImage", true)
        self:setCtrlVisible("MyGoldImage", true)
        local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
        self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23)
    else
        self:setCtrlVisible("CoinImage", true)
        self:setCtrlVisible("MoneyImage", true)
        local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
    end
end

function MarketPanicBuyDlg:onIconPanel(sender, eventType)
    if not self.data then return end
    if self.lock then return end
    local data = self.data

    local isPet = false
    if PetMgr:getPetIcon(data.name) then isPet = true end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime,
        MARKET_CARD_TYPE.FLOAT_DLG, rect, isPet, true, self.tradeType)
end


function MarketPanicBuyDlg:onBuyCanceled(sender, eventType)
    if self.lock then
        self:setCtrlEnabled("TryBuyButton", false)
    end
end

function MarketPanicBuyDlg:onTryBuyButton(sender, eventType)

    if self.lock then
        self:setCtrlEnabled("TryBuyButton", false)
    end

    if not self.data then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local level = Me:getLevel()
    if level < 50 then
        gf:ShowSmallTips(string.format(CHS[3002990], 50))
        return
    end

    if self.data.is_my_goods == 1 then
        gf:ShowSmallTips(CHS[3002991])
        return
    end

    local item =  self.data
    local function buyItem(amount)
        MarketMgr:BuyItem(item.id, "", "", item.price, MarketMgr.STALL_BUY_RUSH, self.tradeType, amount or 1)
    end

    local name = item.name
    if string.match(item.name, CHS[3002980]) then
        local list = gf:split(item.name, "|")
        name = list[1]
    end

    if MarketMgr:isGoldtype(self.tradeType) then
        buyItem()
    else
        if MarketMgr:isCanDoubleSellAndBuy(name) then -- 可批量购买
            local dlg = DlgMgr:openDlg("MarketBatchSellItemDlg")
            dlg:setTradeType(self.tradeType)
            item.icon = InventoryMgr:getIconByName(item.name)
            dlg:setItemInfo(item, 5, item.id)
            dlg:setBuyInfo(item.amount, buyItem)
        else
            buyItem()
        end
    end
end

function MarketPanicBuyDlg:creatMagic(isGet)
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.market_qianggou.name)
    local titlePanel = self:getControl("MagicPanel")
    titlePanel:addChild(magic)
    local size = titlePanel:getContentSize()
    local pos = cc.p(size.width / 2, -140)
    magic:setPosition(pos)
    magic:setAnchorPoint(0.5, 0.5)
    if isGet then
        magic:getAnimation():play("Top02")
    else
        magic:getAnimation():play("Top01")
    end
end

function MarketPanicBuyDlg:setTips(data, buyData)
    self:setLabelText("LeftTimeLabel", "")
    self:setCtrlVisible("TimeOutPanel", false)
    self:setCtrlVisible("FailurePanel", false)
    self:setCtrlVisible("SuccessPanel", false)
    self:setCtrlVisible("ReadyPanel", false)
    local labelCtrl = self:getControl("LeftTimeLabel")


    if buyData then
        self.root:stopAllActions()

        if buyData.result == 1 then
            self:setCtrlVisible("SuccessPanel", true)
            self:setCtrlEnabled("TryBuyButton", false)

            self:creatMagic(true)
        elseif buyData.result == 3 then
            self:setCtrlVisible("FailurePanel", true)
            self:setCtrlEnabled("TryBuyButton", false)
            self:setCtrlEnabled("IconImage", false)
            self:setCtrlEnabled("BigBackImage", false)
            self:setCtrlEnabled("CoinImage", false)
            self:setCtrlEnabled("GoldImage", false)
            self:setCtrlEnabled("IconBKImage", false)

            local ctrl = self:getControl("CoinLabel")
            local ctrl2 = self:getControl("CoinLabel2")
            local ctrl3 = self:getControl("OneNameLabel")

            ctrl3:setColor(COLOR3.GRAY)
            ctrl2:setColor(COLOR3.GRAY)
            ctrl:setColor(COLOR3.GRAY)

            self:creatMagic(false)
        end

        self:setLabelText("TextLabel", CHS[4300200], "TryBuyButton")
        self:setLabelText("TextLabel_1", CHS[4300200], "TryBuyButton")
        return
    end

    if data.status == 1 then
        -- 公示中
        self.root:stopAllActions()
        local function setTime()
            local leftTime = data.endTime - gf:getServerTime()
            local timeStr = MarketMgr:getTimeStr(leftTime)
            self:setLabelText("LeftTimeLabel", timeStr)

            if leftTime <= 0 then
                self.root:stopAllActions()
                self:setTips({status = 10})
            end
        end

        setTime()
        schedule(self.root, setTime, 1)
    elseif data.status == 2 then
        -- 摆摊中
        self.root:stopAllActions()
        self:setLabelText("LeftTimeLabel", "")
        self:setCtrlVisible("TimeOutPanel", true)
    elseif data.status == 10 then
        -- 客户端存在的状态，倒计时结束
        self.root:stopAllActions()
        self:setLabelText("LeftTimeLabel", "")
        self:setCtrlVisible("ReadyPanel", true)
    end
end

function MarketPanicBuyDlg:MSG_GOLD_STALL_BUY_RESULT(data)
    self:MSG_STALL_BUY_RESULT(data)
end

function MarketPanicBuyDlg:MSG_STALL_BUY_RESULT(data)
    if not self.data then return end
    if self.data.id ~= data.goods_gid then return end
    if data.result == 1 or data.result == 3 then
        -- 卖出去了
        if not self.lock then
            self:setTips(nil, data)
            self.lock = true
            if MarketMgr:isGoldtype(self.tradeType) then
                DlgMgr:sendMsg("MarketGlodPublicityDlg", "requireItemList")
                DlgMgr:sendMsg("MarketGoldCollectionDlg", "onRefreshButton")

                local tempData = {status = 0, id = data.goods_gid}
                MarketMgr:MSG_GOLD_STALL_UPDATE_GOODS_INFO(tempData)
                DlgMgr:sendMsg("MarketGlodPublicityDlg", "refreshFormSeachItemList")
            else
                DlgMgr:sendMsg("MarketPublicityDlg", "requireItemList")
                DlgMgr:sendMsg("MarketCollectionDlg", "onRefreshButton")

                local tempData = {status = 0, id = data.goods_gid}
                MarketMgr:MSG_STALL_UPDATE_GOODS_INFO(tempData)
                DlgMgr:sendMsg("MarketPublicityDlg", "refreshFormSeachItemList")

            end
        end
    elseif data.result == 2 then
        self:setTips({status = 2})
    end
end

function MarketPanicBuyDlg:MSG_UPDATE()
    self:setCashView()
end

function MarketPanicBuyDlg:cleanup()
    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.market_qianggou.name)
end


return MarketPanicBuyDlg
