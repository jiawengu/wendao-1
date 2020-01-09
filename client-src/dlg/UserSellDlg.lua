-- UserSellDlg.lua
-- Created by songcw Oct/19/2016
-- 聚宝斋界面

local UserSellDlg = Singleton("UserSellDlg", Dialog)
local DataObject = require("core/DataObject")
local RadioGroup = require("ctrl/RadioGroup")

local PRICE_MIN = 50            -- 最低价格

local CHECKBOX = {
    "CommonSellButton",
    "DesignatedSellButton",
}

local DISPLAY_MAP = {
    ["CommonSellButton"] = {"CommonSellPanel", "ModifyPriceTimeLabel"},
    ["DesignatedSellButton"] = {"DesignatedSellPanel", "NoteButton"},
}


local SELL_STATE = {
    TO_SELL         = 1,        -- 寄售
    PUBLICING       = 10,        -- 公示期
    SELLING         = 20,        -- 寄售期
    TIME_OUT        = 70,        -- 订单过期
    CANCEL          = 60,
    PAYMENT         = 40,
    FORCE_CLOSED    = 110, -- 强制下架
}

function UserSellDlg:init()
    self:bindListener("SellButton", self.onSellButton)
    self:bindListener("ResellButton", self.onResellButton)
    self:bindListener("TakeBackButton", self.onTakeBackButton)
    self:bindListener("ModifyPriceButton", self.onModifyPriceButton)
    self:bindListener("DesignatedButton", self.onDesignatedButton)
    self:bindListener("ValuePanel", self.onDesignatedButton, "DesignatedNamePanel")
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("NoteButton", self.onNoteButton1, "DesignatedSellPanel")

    self:bindListViewListener("ListView", self.onSelectListView)

    self:setCtrlEnabled("ModifyPriceButton", false)

    self:bindListener("DownTipsPanel", self.onDownTipsPanel)

    self.gid = nil
    self.isByMe = nil  -- 是否Me身上取的数据，用于取技能
    self.price = nil
    self.initPrice = nil
    self.priceDesignated = nil
    self.data = nil
    self.inputNum = nil
    self.designatedChar = nil
    TradingMgr:setCheckBindFlag(false)
    -- CharBasicInfoPanel长度可变，记住原始值
    self.basicPanelSize = self.basicPanelSize or self:getControl("CharInfoPanel"):getContentSize()

    self.scrollview = self:getControl("ScrollView")

    self:bindSellNumInput()

    self:addMagicAndSee("DownTipsPanel", ResMgr:getMagicDownIcon())

    self.group = RadioGroup.new()
    self.group:setItemsByButton(self, CHECKBOX, self.onCheckBox)

    self:hookMsg("MSG_TRADING_ROLE")
    self:hookMsg("MSG_EXISTED_CHAR_LIST")
    self:hookMsg("MSG_FUZZY_IDENTITY")

--    if DistMgr:curIsTestDist() then
    if false then -- WDSY-16521
        self:setLabelText("PublicLabel_2", CHS[4300153])
        self:setLabelText("SaleLabel_2", CHS[4300145])
    else
        self:setLabelText("PublicLabel_2", string.format(CHS[4200520], 5))
        self:setLabelText("SaleLabel_2", CHS[4300154])
    end

    -- 默认设置为寄售
    self:setButtonDisplay(SELL_STATE.TO_SELL)
    -- 角色界面上架、寄售没有区分，所以....
    local myUserData = TradingMgr:getTradingUserData()

    -- 如果有数据，是指定交易，过期，价格都为一口价
    if myUserData and next(myUserData) and myUserData[1].state == TRADING_STATE.TIMEOUT then
        if myUserData[1].sell_buy_type == TRADE_SBT.APPOINT_SELL then
            myUserData[1].price = myUserData[1].butout_price
        end
    end


    -- 如果是我的角色，并且界面在寄售界面，我的货架中，则显示修改
    if myUserData and next(myUserData) and myUserData[1].state ~= TRADING_STATE.TIMEOUT then
        self:setButtonDisplay(myUserData[1].state, myUserData[1].price, myUserData[1].end_time)
        self:refreshDesignatedCost(myUserData[1].price, myUserData[1].butout_price)
        if myUserData[1].sell_buy_type == TRADE_SBT.APPOINT_SELL then
            self:onCheckBox(self:getControl(CHECKBOX[2]), nil, true)
            self:setLabelText("DefaultLabel", myUserData[1].appointee_name)
        else
            self:onCheckBox(self:getControl(CHECKBOX[1]), nil, true)
        end
        self:setImageIsAppoint(myUserData[1].sell_buy_type == TRADE_SBT.APPOINT_SELL)
    else
        self:onCheckBox(self:getControl(CHECKBOX[1]), nil, true)
    end


    -- 设置数据
    self:setData(TradingMgr:getMyGoodsData())
end

function UserSellDlg:cleanup()
    self.curTradeType = nil
end

-- 设置check选中，起始这个是用button模拟的check
function UserSellDlg:setImageIsAppoint(isAppoint)
    self:setCtrlVisible("CommonSellImage", not isAppoint)
    self:setCtrlVisible("DesignatedSellImage", isAppoint)
end

function UserSellDlg:onCheckBox(sender, eventType, isInit)
    -- 如果已经在寄售期
    -- 当前为指定交易，则不可以点击正常交易。反之
    local myUserData = TradingMgr:getTradingUserData()

    -- 过期特殊处理
    if myUserData and next(myUserData) and (myUserData[1].state == TRADING_STATE.TIMEOUT or myUserData[1].state == TRADING_STATE.CANCEL) and not isInit then
        self:setImageIsAppoint(false)
        gf:ShowSmallTips(CHS[2100238])
        return
    end

    self:setDisplayByCtrlName(sender:getName())


    if self.state ~= SELL_STATE.TO_SELL and myUserData and next(myUserData) then

        if sender:getName() == "CommonSellButton" and myUserData[1].sell_buy_type == TRADE_SBT.APPOINT_SELL then
            self:setDisplayByCtrlName("DesignatedSellButton")
            self:setImageIsAppoint(true)
            if not isInit then
                gf:ShowSmallTips(CHS[2100238])
            end
        elseif sender:getName() == "DesignatedSellButton" and myUserData[1].sell_buy_type ~= TRADE_SBT.APPOINT_SELL then
            self:setDisplayByCtrlName("CommonSellButton")
            self:setImageIsAppoint(false)
            if not isInit then
                gf:ShowSmallTips(CHS[2100238])
            end
        end
    end
end

function UserSellDlg:setDisplayByCtrlName(ctrlName)
    for _, panelName in pairs(DISPLAY_MAP) do
        for i, pName in pairs(panelName) do
            self:setCtrlVisible(pName, false)
        end
    end
    --

    for i, pName in pairs(DISPLAY_MAP[ctrlName]) do
        self:setCtrlVisible(pName, true)
    end
end

function UserSellDlg:onDownTipsPanel(sender, eventType)
    local listInnerContent = self.scrollview:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local listViewSize = self.scrollview:getContentSize()

    -- 计算滚动的百分比
    local totalHeight = innerSize.height - listViewSize.height
    local innerPosY = listInnerContent:getPositionY()
    if innerPosY < -230 then
        listInnerContent:setPositionY(innerPosY + 230)
    else
        self:removeMagicAndNoSee("DownTipsPanel", ResMgr:getMagicDownIcon())
        listInnerContent:setPositionY(0)
    end
end


function UserSellDlg:onUpdate()
    if self.moveDown then
        local listInnerContent = self.scrollview:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = self.scrollview:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height
        local innerPosY = listInnerContent:getPositionY()
        if innerPosY < 0 then
            listInnerContent:setPositionY(innerPosY + 2)
        else
            self.moveDown = false
            self:removeMagicAndNoSee("DownTipsPanel", ResMgr:getMagicDownIcon())
            listInnerContent:setPositionY(0)
        end
    end
end

function UserSellDlg:initDownTipsPanel()
    local downPanel = self:getControl("DownTipsPanel")

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.moveDown = true
        elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
            self.moveDown = false
        end
    end

    downPanel:addTouchEventListener(listener)
end

function UserSellDlg:getDataByMe()
    local data = {}
    data.name = Me:getName()
    data.icon = Me:getDlgIcon()
    data.weaponIcon = Me:getDlgWeaponIcon()

    data.icon = Me:queryBasicInt("org_icon")
    data.level = Me:getLevel()
    data.name = Me:queryBasic("name")
    data.tao = Me:queryBasicInt("tao")
    data.title = CharMgr:getChengweiShowName(Me:queryBasic("title"))
    data.party_name = Me:queryBasic("party")
    data.party_contrib = Me:queryBasic("party/contrib")
    data.nice = Me:queryInt("nice")
    data.voucher = Me:queryInt("voucher")
    data.silver_coin = Me:queryBasicInt("silver_coin")
    data.cash = Me:queryBasicInt("cash")
    data.max_life = Me:queryInt("max_life")
    data.max_mana = Me:queryInt("max_mana")
    data.phy_power = Me:queryInt("phy_power")
    data.mag_power = Me:queryInt("mag_power")
    data.speed = Me:queryInt("speed")
    data.def = Me:queryInt("def")
    data.con = Me:queryInt("con")
    data.wiz = Me:queryInt("wiz")
    data.str = Me:queryInt("str")
    data.dex = Me:queryInt("dex")
    data.attrib_point = Me:queryInt("attrib_point")

    data.metal = Me:queryInt("metal")
    data.wood = Me:queryInt("wood")
    data.fire = Me:queryInt("fire")
    data.earth = Me:queryInt("earth")
    data.water = Me:queryInt("water")
    data.polar_point = Me:queryInt("polar_point")

    data.resist_metal = Me:queryInt("resist_metal")
    data.resist_wood = Me:queryInt("resist_wood")
    data.resist_water = Me:queryInt("resist_water")
    data.resist_fire = Me:queryInt("resist_fire")
    data.resist_earth = Me:queryInt("resist_earth")

    data.ignore_resist_metal = Me:queryInt("ignore_resist_metal")
    data.ignore_resist_wood = Me:queryInt("ignore_resist_wood")
    data.ignore_resist_water = Me:queryInt("ignore_resist_water")
    data.ignore_resist_fire = Me:queryInt("ignore_resist_fire")
    data.ignore_resist_earth = Me:queryInt("ignore_resist_earth")

    data.resist_forgotten = Me:queryInt("resist_forgotten")
    data.resist_poison = Me:queryInt("resist_poison")
    data.resist_frozen = Me:queryInt("resist_frozen")
    data.resist_sleep = Me:queryInt("resist_sleep")
    data.resist_confusion = Me:queryInt("resist_confusion")

    data.ignore_resist_forgotten = Me:queryInt("ignore_resist_forgotten")
    data.ignore_resist_poison = Me:queryInt("ignore_resist_poison")
    data.ignore_resist_frozen = Me:queryInt("ignore_resist_frozen")
    data.ignore_resist_sleep = Me:queryInt("ignore_resist_sleep")
    data.ignore_resist_confusion = Me:queryInt("ignore_resist_confusion")

    data.pot = Me:queryInt("pot")
    data.polar = Me:queryInt("polar")

    return data
end

function UserSellDlg:setDataByMe()
    self.isByMe = true
    local data = self:getDataByMe()
    self:setData(data)
end

function UserSellDlg:setData(data)
    if not data then return end
    self.data = data
    self:setLeftInfo(data)

    self:setRightAttInfo(data)
end

-- 设置左侧信息
function UserSellDlg:setLeftInfo(data)

    self:setLabelText("NameLabel_3", data.name)

    local objcet = DataObject.new()
    objcet:absorbBasicFields(data)

    self:setPortrait("CharPanel", self:getIcon(objcet), data.weapon_icon, nil, nil, nil, nil, cc.p(0, -60), data.icon)

    -- 仙魔光效
    if data["upgrade_type"] then
        self:addUpgradeMagicToCtrl("CharPanel", data["upgrade_type"], nil, true)
    end
end

function UserSellDlg:getIcon(ob)
    local icon
    repeat

        if ob:queryBasicInt("suit_icon") ~= 0 then
            icon = ob:queryBasicInt("suit_icon")
            break
        end

        icon = ob:queryBasicInt('icon')
    until true

    if not gf:isCharExist(icon) then
        icon = 6004
    end

    return icon
end

-- 设置右侧属性信息
function UserSellDlg:setRightAttInfo(data)
    -- 基础信息
    self:setBasicInfo(data)

    -- 属性值
    self:setAttribValue(data)

    -- 属性加点
    self:setAttribPoint(data)

    -- 相性
    self:setPolarPoint(data)

    -- 抗性
    self:setResistPoint(data)

    -- 抗障碍
    self:setResistObstacles(data)

    -- 设置技能
    self:setSkills(data)

    -- 潜能
    self:setLabelText("PotLabel_3", data.pot)
    --
    -- 称谓
    local  titles =  TradingMgr:getTitleByLenSort(data.appellation)
    local titleNameCtl = self:getControl("TitleLabel_1")
    local posY = titleNameCtl:getPositionY()
    local parentPanel = titleNameCtl:getParent()
    for i, titleInfo in pairs(titles) do
        local label = self:getControl("TitleNameLabel_1"):clone()
        label:setString(CharMgr:getChengweiShowName(titleInfo.title))
        label:setPositionY(posY - i * 23)
        parentPanel:addChild(label)
    end
    parentPanel:requestDoLayout()

    local mainPanel = self:getControl("CharInfoPanel")

    mainPanel:setContentSize(self.basicPanelSize.width, self.basicPanelSize.height + 23 * #titles + 5 )
    mainPanel:requestDoLayout()
    --]]

    -- 今日剩余次数
    local data2 = TradingMgr:getTradingUserData()
    if data2 and next(data2) then
        self:setLabelText("ModifyPriceTimeLabel", string.format(CHS[4100406], data2[1].change_price_count))
    else
        self:setLabelText("ModifyPriceTimeLabel", "")
    end

    self:updateLayout("CharInfoPanel")

    local scrollview = self:getControl("ScrollView")
    local infoPanel = self:getControl("CharInfoPanel")
    infoPanel:requestDoLayout()
    infoPanel:removeFromParent()
    scrollview:removeAllChildren()
    scrollview:addChild(infoPanel)
    scrollview:setInnerContainerSize(infoPanel:getContentSize())
    scrollview:requestDoLayout()

    self:setLeftInfo(data)

    infoPanel:setPositionY(0)

    scrollview:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
end

-- 设置剩余次数
function UserSellDlg:setLeftTime(leftTime)
    if leftTime then
        self:setLabelText("ModifyPriceTimeLabel", string.format(CHS[4100406], leftTime))
    else
        self:setLabelText("ModifyPriceTimeLabel", "")
    end
end

-- 是否是指定交易
function UserSellDlg:isAppointTrading()
    local myUserData = TradingMgr:getTradingUserData()
    -- 如果是我的角色，并且界面在寄售界面，我的货架中，则显示修改
    if myUserData and next(myUserData) then
        if myUserData[1].sell_buy_type == TRADE_SBT.APPOINT_SELL then
            return true
        end
    end

    return false
end

-- 设置数字键盘输入
function UserSellDlg:bindSellNumInput()
    local moneyPanel = self:getControl('ValuePanel', nil, "PricePanel")
    local function openNumIuputDlg()
        if self:isAppointTrading() then
            gf:ShowSmallTips(CHS[4100972])
            return
        end

        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("normal")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNum = 0
     --   self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)

    local designPanel = self:getControl('PricePanel', nil, "DesignatedSellPanel")
    local moneyPanel = self:getControl('ValuePanel', nil, designPanel)
    local function openNumIuputDlg()
        if self:isAppointTrading() then
            gf:ShowSmallTips(CHS[4100972])
            return
        end
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("designated")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNumDesignated = 0
        --   self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end

-- 数字键盘删除数字
function UserSellDlg:deleteNumber(key)
    if key == "normal" then
        self.inputNum = math.floor(self.inputNum / 10)
        self:refreshCost(self.inputNum )
    else
        self.inputNumDesignated = math.floor(self.inputNumDesignated / 10)
        self:refreshDesignatedCost(self.inputNumDesignated)
    end
end

-- 数字键盘清空
function UserSellDlg:deleteAllNumber(key)
    if key == "normal" then
        self.inputNum = 0
        self:refreshCost(self.inputNum)
    else
        self.inputNumDesignated = 0
        self:refreshDesignatedCost(self.inputNumDesignated)
    end
end

-- 数字键盘插入数字
function UserSellDlg:insertNumber(num, key)

    if key == "normal" then
        if num == "00" then
            self.inputNum = self.inputNum * 100
        elseif num == "0000" then
            self.inputNum = self.inputNum * 10000
        else
            self.inputNum = self.inputNum * 10 + num
        end

        if self.inputNum >= TradingMgr:getMaxPrice() then
            self.inputNum = TradingMgr:getMaxPrice()
            gf:ShowSmallTips(CHS[3003069])
        end

        self:refreshCost(self.inputNum)
    else
        if num == "00" then
            self.inputNumDesignated = self.inputNumDesignated * 100
        elseif num == "0000" then
            self.inputNumDesignated = self.inputNumDesignated * 10000
        else
            self.inputNumDesignated = self.inputNumDesignated * 10 + num
        end

        if self.inputNumDesignated >= TradingMgr:getMaxPrice() then
            self.inputNumDesignated = TradingMgr:getMaxPrice()
            gf:ShowSmallTips(CHS[3003069])
        end

        self:refreshDesignatedCost(self.inputNumDesignated)
    end
end

-- 更新向下提示
function UserSellDlg:updateDownArrow(sender, eventType)
    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local listViewCtrl = sender

        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height

        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)

        if persent < 90 then
            self:addMagicAndSee("DownTipsPanel", ResMgr:getMagicDownIcon())
        else
            self:removeMagicAndNoSee("DownTipsPanel", ResMgr:getMagicDownIcon())
        end
    end
end

function UserSellDlg:addMagicAndSee(panelName, icon)
    local ctrl = self:getControl(panelName)
    self:addMagic(ctrl, icon)
    ctrl:setVisible(true)
end

function UserSellDlg:removeMagicAndNoSee(panelName, icon)
    local ctrl = self:getControl(panelName)
    self:removeMagic(ctrl, icon)
    ctrl:setVisible(false)
end

-- 设置基础信息
function UserSellDlg:setBasicInfo(data)
    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(data.icon))
    self:setItemImageSize("GuardImage")

    -- 元婴血婴
    if data.upgrade_level and data.upgrade_level ~= 0 then
        self:setLabelText("BabyLabel_1", gf:getChildName(data.upgrade_type), "InfoPanel_22")
        self:setLabelText("BabyLabel_3", data.upgrade_level, "InfoPanel_22")
    else
        self:setLabelText("BabyLabel_1", CHS[4100560], "InfoPanel_22")
        self:setLabelText("BabyLabel_3", CHS[5000059], "InfoPanel_22")
    end

    -- 仙魔类型
    if data.upgrade_type == CHILD_TYPE.UPGRADE_IMMORTAL then
        self:setLabelText("UpgradeLabel_3", CHS[7190115], "InfoPanel_22")
    elseif data.upgrade_type == CHILD_TYPE.UPGRADE_MAGIC then
        self:setLabelText("UpgradeLabel_3", CHS[7190114], "InfoPanel_22")
    else
        self:setLabelText("UpgradeLabel_3", CHS[7002286], "InfoPanel_22")
    end

    -- 等级
  --  self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    self:setLabelText("UserLabel_3", data.level, "InfoPanel_22")

    -- 名字
  --  self:setLabelText("NameLabel", gf:getRealName(data.name))
    -- tao
    self:setLabelText("TaoLabel_3", gf:getTaoStr(data.tao, 0))
    -- 称谓
    self:setLabelText("TitleLabel_3", data.title)
    -- 帮派
    self:setLabelText("PartyLabel_3", data.party_name)
    -- 帮贡
    self:setLabelText("ContribLabel_3", data.party_contrib)
    -- 好心值
    self:setLabelText("NiceLabel_3", data.nice)
    -- PK值
    if data.total_pk then
        self:setLabelText("PKLabel_3", data.total_pk)
    end

    -- 灵尘
    self:setLabelText("LingChenLabel_3", data.lingchen_point or 0)

    -- 代金券
    local voucherStr = gf:getMoneyDesc(data.voucher, true)
    self:setLabelText("VoucherLabel_3", voucherStr)
    -- 问道币
    local cashStr = gf:getMoneyDesc(data.cash, true)
    self:setLabelText("CashLabel_3", cashStr)
    -- 银元宝
    local silver_coinStr = gf:getMoneyDesc(data.silver_coin, true)
    self:setLabelText("SliverCoinLabel_3", silver_coinStr)
    -- 钱庄
    local balanceStr = gf:getMoneyDesc(data.balance, true)
    self:setLabelText("StoreCashLabel_3", balanceStr)

    -- 免费改名次数
    local tempHeight = 0
    if not data.free_rename then
        local panel = self:setCtrlVisible("InfoPanel_21", false)
        panel:setContentSize(panel:getContentSize().width, 1)
        tempHeight = panel:getContentSize().height
    else
        self:setLabelText("RenameLabel_3", string.format(CHS[4300252], data.free_rename))
    end

    -- 内丹境界
    self:setLabelText("InnerLabel_3", CHS[7100146], "InfoPanel_22")
    if InnerAlchemyMgr:isInnerAlchemyOpen(data.upgrade_level, data.upgrade_type) then
        local innerState = data.neidan_state
        local innerStage = data.neidan_stage
        if innerState and innerState > 0 and innerStage and innerStage > 0 then
            self:setLabelText("InnerLabel_3", string.format(CHS[7100134], InnerAlchemyMgr:getAlchemyState(innerState),
                InnerAlchemyMgr:getAlchemyStage(innerStage)), "InfoPanel_22")
        end
    end

    -- 会员
    self:setLabelText("ServiceLabel_3", gf:getVipStr(data.insider_level, data.insider_time))

    -- 声望
    self:setLabelText("ReputationLabel_3", data.reputation)

    -- 经验锁
    self:setLabelText("ExplockLabel_3", data.is_lock_exp == 1 and CHS[4300460] or CHS[4300461])

    -- 双倍
    self:setLabelText("DoublePointLabel_3", data.double_points)

    -- 急急如律令
    self:setLabelText("JijrllLabel_3", data.jiji_points)

    -- 宠风散
    self:setLabelText("ChongfsLabel_3", data.chongfs_points)

    -- 首饰精华
    self:setLabelText("JinghuaLabel_3", data.jewelry_essence or 0)

    -- 离线时间
    self:setLabelText("OffLineTimeLabel_3", string.format(CHS[3002679], math.floor(data.shuad_offline_time / 60)))

    -- 紫气鸿蒙
    self:setLabelText("ZiqhmLabel_3", data.ziqhm_points)

    -- 神木鼎
    self:setLabelText("ShenmdLabel_3", data.shenmu_points)

    -- 如意刷道令
    self:setLabelText("RuysdlLabel_3", data.ruyi_point or 0)

    -- 气血储备
    self:setLabelText("LifeStoreLabel_3", data.extra_life)

    -- 法力储备
    self:setLabelText("ManaStoreLabel_3", data.extra_mana)

    -- 忠诚储备
    self:setLabelText("LoyaltyStoreLabel_3", data.backup_loyalty)

    -- 卡套空间
    self:setLabelText("CardBagLabel_3", data.card_store_size)

    -- 仙道
    self:setLabelText("XianLabel_3", data.upgrade_immortal or 0)
    -- 魔道
    self:setLabelText("MoLabel_3", data.upgrade_magic or 0)
    -- 未分配
    self:setLabelText("UnAssignLabel_3", data.upgrade_total or 0, "InfoPanel_23")


    -- 部分属性受到坐骑属性加成，若没有，需要设置panel的size，隐藏提示
    local mainPanel = self:getControl("CharInfoPanel")
    local panel1 = self:getControl("InfoPanel_2")
    self.initInfoPanelSize1 = self.initInfoPanelSize1 or panel1:getContentSize()

    local panel2 = self:getControl("InfoPanel_3")
    self.initInfoPanelSize2 = self.initInfoPanelSize2 or panel2:getContentSize()
    local panel3 = self:getControl("InfoPanel_23")
    self.initInfoPanelSize3 = self.initInfoPanelSize3 or panel3:getContentSize()

    self.innerSize = self.innerSize or mainPanel:getContentSize()

    self:setCtrlVisible("NotePanel", data.mount_flw_valid == 1, panel1)
    self:setCtrlVisible("NotePanel", data.mount_flw_valid == 1, panel2)
    self:setCtrlVisible("NotePanel", data.mount_flw_valid == 1, panel3)
    if data.mount_flw_valid == 1 then
        panel1:setContentSize(self.initInfoPanelSize1)
        panel2:setContentSize(self.initInfoPanelSize2)
        panel3:setContentSize(self.initInfoPanelSize3)
        mainPanel:setContentSize(self.innerSize.width, self.innerSize.height - tempHeight)
    else
        panel1:setContentSize(self.initInfoPanelSize1.width, self.initInfoPanelSize1.height - 25)
        panel2:setContentSize(self.initInfoPanelSize2.width, self.initInfoPanelSize2.height - 25)
        panel3:setContentSize(self.initInfoPanelSize3.width, self.initInfoPanelSize3.height - 25)
        mainPanel:setContentSize(self.innerSize.width, self.innerSize.height - 50 - tempHeight)
    end

    local pkCutHeight = 0
    self.initPanel8Size = self.initPanel8Size or self:getCtrlContentSize("InfoPanel_8")
    if not data.total_pk then
        pkCutHeight = 23
        self:setCtrlContentSize("InfoPanel_8", self.initPanel8Size.width, self.initPanel8Size.height - pkCutHeight)
        for i = 1, 3 do
            self:setCtrlVisible("PKLabel_" .. i, false)
        end

        self:setCtrlContentSize("PKLabel_1", nil, 0)
    else
        self:setCtrlContentSize("PKLabel_1", nil, 23)
    end

    local curSize = mainPanel:getContentSize()
    mainPanel:setContentSize(curSize.width, curSize.height - pkCutHeight)

    mainPanel:requestDoLayout()
end

-- 设置属性值
function UserSellDlg:setAttribValue(data)
    -- 气血
    self:setLabelText("LifeLabel_3", data.max_life)
    -- 物伤
    self:setLabelText("PhyPowerLabel_3", data.phy_power)
    -- 法力
    self:setLabelText("ManaLabel_3", data.max_mana)
    -- 法伤
    self:setLabelText("MagPowerLabel_3", data.mag_power)
    -- 速度
    self:setLabelText("SpeedLabel_3", data.speed)
    -- 防御
    self:setLabelText("DefLabel_3", data.def)
end

-- 设置属性加点
function UserSellDlg:setAttribPoint(data)
    -- 体质
    self:setLabelText("ConLabel_3", data.con)
    -- 灵力
    self:setLabelText("WizLabel_3", data.wiz)
    -- 力量
    self:setLabelText("StrLabel_3", data.str)
    -- 敏捷
    self:setLabelText("DexLabel_3", data.dex)
    -- 未分配
    self:setLabelText("UnAssignLabel_3", data.attrib_point, "InfoPanel_3")
end

-- 设置相性加点
function UserSellDlg:setPolarPoint(data)
    -- 金
    self:setLabelText("MetalLabel_3", data.metal)
    -- 木
    self:setLabelText("WoodLabel_3", data.wood)
    -- 水
    self:setLabelText("WaterLabel_3", data.water)
    -- 火
    self:setLabelText("FireLabel_3", data.fire)
    -- 土
    self:setLabelText("EarthLabel_3", data.earth)
    -- 未分配
    self:setLabelText("UnAssignLabel_3", data.polar_point, "InfoPanel_4")
end

-- 设置抗性加点
function UserSellDlg:setResistPoint(data)
    -- 抗金
    self:setLabelText("ResitMetalLabel_3", data.resist_metal .. "%")
    -- 抗木
    self:setLabelText("ResitWoodLabel_3", data.resist_wood .. "%")
    -- 抗水
    self:setLabelText("ResitWaterLabel_3", data.resist_water .. "%")
    -- 抗火
    self:setLabelText("ResitFireLabel_3", data.resist_fire .. "%")
    -- 抗土
    self:setLabelText("ResitEarthLabel_3", data.resist_earth .. "%")

    -- 忽视抗金
    self:setLabelText("IgnoreResitMetalLabel_3", data.ignore_resist_metal .. "%")
    -- 忽视抗木
    self:setLabelText("IgnoreResitWoodLabel_3", data.ignore_resist_wood .. "%")
    -- 忽视抗水
    self:setLabelText("IgnoreResitWaterLabel_3", data.ignore_resist_water .. "%")
    -- 忽视抗火
    self:setLabelText("IgnoreResitFireLabel_3", data.ignore_resist_fire .. "%")
    -- 忽视抗土
    self:setLabelText("IgnoreResitEarthLabel_3", data.ignore_resist_earth .. "%")
end

-- 设置抗障碍
function UserSellDlg:setResistObstacles(data)
    -- 抗遗忘
    self:setLabelText("ResitForgottenLabel_3", data.resist_forgotten .. "%")
    -- 抗中毒
    self:setLabelText("ResitPoisonLabel_3", data.resist_poison .. "%")
    -- 抗冰冻
    self:setLabelText("ResitFrozenLabel_3", data.resist_frozen .. "%")
    -- 抗昏睡
    self:setLabelText("ResitSleepLabel_3", data.resist_sleep .. "%")
    -- 抗混乱
    self:setLabelText("ResitConfusionLabel_3", data.resist_confusion .. "%")

    -- 忽视抗金
    self:setLabelText("IgnoreResitForgottenLabel_3", data.ignore_resist_forgotten .. "%")
    -- 忽视抗木
    self:setLabelText("IgnoreResitPoisonLabel_3", data.ignore_resist_poison .. "%")
    -- 忽视抗水
    self:setLabelText("IgnoreResitFrozenLabel_3", data.ignore_resist_frozen .. "%")
    -- 忽视抗火
    self:setLabelText("IgnoreResitSleepLabel_3", data.ignore_resist_sleep .. "%")
    -- 忽视抗土
    self:setLabelText("IgnoreResitConfusionLabel_3", data.ignore_resist_confusion .. "%")
end

function UserSellDlg:setSkills(data)
    -- 技能对应的panel表
    local skillPanelName = {"InfoPanel_15", "InfoPanel_16", "InfoPanel_17", "InfoPanel_18", "InfoPanel_19"}

    local skillInfo, hasSkills = TradingMgr:getUserSkillByData(data, skillPanelName)
    local map = {
        [15] = "",
        [16] = "B",
        [17] = "C",
        [18] = "D",
        [19] = "Passive",
    }

    for i = 15, 19 do
        local panelName = "InfoPanel_" .. i
        self:setSkillsPanel(panelName, skillInfo[panelName], hasSkills[panelName], map[i])
        self:updateLayout(panelName)
    end
end

function UserSellDlg:setSkillsPanel(panelName, skillInfo, hasSkill, skillType)

    local function getSkillByNameFromTab(skillName, skillTab)
        if not skillTab or not next(skillTab) then return false end
        for _, skill in pairs(skillTab) do
           if skillName == skill.name then
                return skill
           end
        end
    end

    local parentPanel = self:getControl(panelName)
    for i = 1, 5 do
        if skillInfo[i] then
            local panel = self:getControl(skillType .. "SkillPanel_" .. i, nil, parentPanel)
            if panel then
                panel.skillName = skillInfo[i].name
                self:setImage("SkillImage", SkillMgr:getSkillIconPath(skillInfo[i].no), panel)
                self:setItemImageSize("SkillImage", panel)
                self:setLabelText(skillType .. "SkillNameLabel_" .. i, skillInfo[i].name)

                local retSkill = getSkillByNameFromTab(skillInfo[i].name, hasSkill)
                if not retSkill then
                    gf:grayImageView(self:getControl("SkillImage", Const.UIImage, panel))
                    self:setLabelText(skillType .. "SkillLevelLabel_" .. i, 0)
                else
                    self:setLabelText(skillType .. "SkillLevelLabel_" .. i, retSkill.level)
                end

                self:bindTouchEndEventListener(panel, function(obj, sender, type)
                    if panel.skillName then
                        local rect = self:getBoundingBoxInWorldSpace(panel)
                        local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
                        dlg:setSKillByName(panel.skillName , rect)
                    end
                end)
            end
        end
    end
end

-- 获取技能信息
function UserSellDlg:getSkills(data)

    -- 身上有的
    local hasSkills = {}
    if self.isByMe then
        -- 从me身上取
        -- 力破千钧
        local phySkill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_J)
        if phySkill then
            hasSkills["InfoPanel_8"] = phySkill             -- InfoPanel_8 对应的为力破技能！！
        end

        -- B
        local bSkill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_B)
        if bSkill and next(bSkill) then
            hasSkills["InfoPanel_9"] = bSkill
        end

        -- C
        local cSkill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_C)
        if cSkill and next(cSkill) then
            hasSkills["InfoPanel_10"] = cSkill
        end

        -- D
        local dSkill = SkillMgr:getSkillNoAndLadder(Me:getId(), SKILL.SUBCLASS_D)
        if dSkill and next(dSkill) then
            hasSkills["InfoPanel_11"] = dSkill
        end
    else
        -- 从data中取
        if data["skills"] then
            -- 力破千钧
            if data.skills.skill_J and data.skills.skill_J.skill_J_1 then
                hasSkills["InfoPanel_8"] = {}
                table.insert(hasSkills["InfoPanel_8"], data.skills.skill_J.skill_J_1)
            end

            --B
            if data.skills.skill_B then
                local skillTable = {}
                for i = 1, 5 do
                    if data.skills.skill_B["skill_B_" .. i] and data.skills.skill_B["skill_B_" .. i].level > 0 then
                        table.insert(skillTable, data.skills.skill_B["skill_B_" .. i])
                    end
                end
                hasSkills["InfoPanel_9"] = skillTable
            end

            -- c
            if data.skills.skill_C then
                local skillTable = {}
                for i = 1, 5 do
                    if data.skills.skill_C["skill_C_" .. i] and data.skills.skill_C["skill_C_" .. i].level > 0 then
                        table.insert(skillTable, data.skills.skill_C["skill_C_" .. i])
                    end
                end
                hasSkills["InfoPanel_10"] = skillTable
            end

            -- D
            if data.skills.skill_D then
                local skillTable = {}
                for i = 1, 5 do
                    if data.skills.skill_D["skill_D_" .. i] and data.skills.skill_D["skill_D_" .. i].level > 0 then
                        table.insert(skillTable, data.skills.skill_D["skill_D_" .. i])
                    end
                end
                hasSkills["InfoPanel_11"] = skillTable
            end
        end
    end

    -- 应该有的
    local skillInfo = {}
    -- 力破千钧
    local phySkill = SkillMgr:getSkillsByClass(SKILL.CLASS_PHY, SKILL.SUBCLASS_J)
    if phySkill then
        skillInfo["InfoPanel_8"] = phySkill             -- InfoPanel_8 对应的为力破技能！！
    end

    -- B
    local bSkill = SkillMgr:getSkillsByPolarAndSubclass(data.polar, SKILL.SUBCLASS_B)
    if bSkill and next(bSkill) then
        skillInfo["InfoPanel_9"] = bSkill
    end

    -- C
    local cSkill = SkillMgr:getSkillsByPolarAndSubclass(data.polar, SKILL.SUBCLASS_C)
    if cSkill and next(cSkill) then
        skillInfo["InfoPanel_10"] = cSkill
    end

    -- D
    local dSkill = SkillMgr:getSkillsByPolarAndSubclass(data.polar, SKILL.SUBCLASS_D)
    if dSkill and next(dSkill) then
        skillInfo["InfoPanel_11"] = dSkill
    end

    return skillInfo, hasSkills
end

function UserSellDlg:refreshDesignatedCost(price, ykjPrice)
    local mainPanel = self:getControl("DesignatedSellPanel")
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash())
    if self.state ~= SELL_STATE.TO_SELL then
        cashText2,fonColor2 = gf:getArtFontMoneyDesc(0)
    end

    local taxPanel = self:getControl("TaxPanel", nil, mainPanel)
    local costPanel = self:getControl("ValuePanel", nil, taxPanel)
    self:setNumImgForPanel(costPanel, fonColor2, cashText2, false, LOCATE_POSITION.MID, 19)

    self.priceDesignated = price
    if not price then return end
    -- 一口价
    local cashText = gf:getArtFontMoneyDesc(ykjPrice or TradingMgr:getYKJ(price))
    local panelP = self:getControl("FixedPricePanel", nil, mainPanel)
    local pricePanel = self:getControl("ValuePanel", nil, panelP)
    self:setNumImgForPanel(pricePanel, ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21)


    -- 实际获得   一口价
    local income = TradingMgr:getRealIncome(TradingMgr:getYKJ(price), true)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    local panelP = self:getControl("IncomePanel_2", nil, mainPanel)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, panelP)
    self:setCtrlVisible("NoteImage", income <= 0, panelP)


   --
    -- 实际获得   指定
    local income = TradingMgr:getRealIncome(price, true)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    local panelP = self:getControl("IncomePanel_1", nil, mainPanel)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, panelP)
    self:setCtrlVisible("NoteImage", income <= 0, panelP)

    -- 买方定金
    local income = TradingMgr:getDeposit(price)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    local panelP = self:getControl("BuyerDepositPanel", nil, mainPanel)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 21, panelP)

    -- 价格
    local cashText = gf:getArtFontMoneyDesc(price)
    local panelP = self:getControl("PricePanel", nil, mainPanel)
    local pricePanel = self:getControl("ValuePanel", nil, panelP)
    self:setNumImgForPanel(pricePanel, ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21)
end

-- 设置、刷新价格相关
function UserSellDlg:refreshCost(price)
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash())
    if self.state ~= SELL_STATE.TO_SELL then
        cashText2,fonColor2 = gf:getArtFontMoneyDesc(0)
    end

    local costPanel = self:getControl("ValuePanel", nil, "TaxPanel")
    self:setNumImgForPanel("ValuePanel", fonColor2, cashText2, false, LOCATE_POSITION.MID, 19, costPanel)

    self.price = price
    if not price then return end

    -- 设置寄售价格
    if self.initPrice ~= price then self:setCtrlEnabled("ModifyPriceButton", true) end

    local cashText = gf:getArtFontMoneyDesc(price)
    local pricePanel = self:getControl("ValuePanel", nil, "PricePanel")
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21, pricePanel)

    -- 实际获得
    local income = TradingMgr:getRealIncome(price, true)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)

    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, "IncomePanel")
    self:setCtrlVisible("NoteImage", income <= 0, "IncomePanel")
end

function UserSellDlg:setButtonDisplay(state, price, sale_left_time)
    self.state = state
    self.initPrice = price
    self:refreshCost(self.initPrice)
    self:refreshDesignatedCost()

    self:setCtrlVisible("SellButton", false)
    self:setCtrlVisible("ResellButton", false)
    self:setCtrlVisible("TakeBackButton", false)
    self:setCtrlVisible("ModifyPriceButton", false)
    local data = TradingMgr:getTradingData()

    -- 如果已经寄售，置灰
    if state > SELL_STATE.TO_SELL then
        self:setCtrlEnabled("DesignatedButton", false)
        self:setCtrlEnabled("ValuePanel", false, "DesignatedNamePanel")
    end

    self:setCtrlVisible("ForbidEditImage", state > SELL_STATE.TO_SELL, "DesignatedSellPanel")
    self:setCtrlVisible("EditImage", state == SELL_STATE.TO_SELL, "DesignatedSellPanel")

    if state == SELL_STATE.TO_SELL then
        self:setCtrlVisible("SellButton", true)
    elseif state == SELL_STATE.PUBLICING then
        self:setCtrlVisible("ModifyPriceButton", true)
        self:setCtrlVisible("TakeBackButton", true)
        self:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(data[1].end_time - gf:getServerTime()))
        self:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(data[1].end_time - gf:getServerTime()), "DesignatedSellPanel")
    elseif state == SELL_STATE.SELLING or state == SELL_STATE.PAYMENT then
        self:setCtrlVisible("ModifyPriceButton", true)
        self:setCtrlVisible("TakeBackButton", true)
        self:setLabelText("PublicLabel_2", CHS[4300146])
        self:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(sale_left_time))

        self:setLabelText("PublicLabel_2", CHS[4300146], "DesignatedSellPanel")
        self:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(sale_left_time), "DesignatedSellPanel")
    elseif state == SELL_STATE.TIME_OUT or state == SELL_STATE.CANCEL or state == SELL_STATE.FORCE_CLOSED then
        self:setCtrlVisible("TakeBackButton", true)
        self:setCtrlVisible("ResellButton", true)
        if state == SELL_STATE.TIME_OUT then
            self:setLabelText("PublicLabel_2", CHS[4300146])
            self:setLabelText("PublicLabel_2", CHS[4300146], "DesignatedSellPanel")
        else
            --    if DistMgr:curIsTestDist() then
            if false then -- WDSY-16521
                self:setLabelText("PublicLabel_2", CHS[4300153])
                self:setLabelText("PublicLabel_2", CHS[4300153], "DesignatedSellPanel")
            else
                self:setLabelText("PublicLabel_2", string.format(CHS[4200520], 5), "DesignatedSellPanel")
                self:setLabelText("PublicLabel_2", string.format(CHS[4200520], 5))
            end
        end
    end

    self:updateLayout("LeftTimePanel")
end

function UserSellDlg:setGid(gid)
    self.gid = gid
end

function UserSellDlg:setGoodsId(gid)
    self.goodsId = gid
end

function UserSellDlg:onSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    gf:confirm(CHS[4100401], function ()
        if self:getCtrlVisible("DesignatedSellPanel") then
            -- 指定交易
            if not self.designatedChar then
                gf:ShowSmallTips(CHS[4100973])
                return
            end

            self.curTradeType = CHECKBOX[2] -- 记录本次操作类型
            if self.priceDesignated then            
                local income = TradingMgr:getRealIncome(self.priceDesignated, true)
                TradingMgr:tradingSellRole(self.priceDesignated, self.designatedChar.gid, income)
            else
                TradingMgr:tradingSellRole(self.priceDesignated, self.designatedChar.gid)
            end
        else
            self.curTradeType = CHECKBOX[1] -- 记录本次操作类型
            if self.price then            
                local income = TradingMgr:getRealIncome(self.price, true)
                TradingMgr:tradingSellRole(self.price, nil, income)
            else
                TradingMgr:tradingSellRole(self.price)
            end
        end
    end)
end


function UserSellDlg:onResellButton(sender, eventType)
    local gid = self.gid or Me:queryBasic("gid")
    local income = TradingMgr:getRealIncome(self.price, true)
    TradingMgr:tradingSellRoleAgain(gid, self.price, income)
end

function UserSellDlg:onTakeBackButton(sender, eventType)
    if self.state == SELL_STATE.SELLING or self.state == SELL_STATE.PAYMENT then
        local dlg = gf:confirm(CHS[4300147], function ()
            TradingMgr:askAutoLoginToken(self.name, self.goodsId, nil, self.gid or Me:queryBasic("gid"), true)
        end)
        dlg:setConfirmText(CHS[4300148])
        dlg:setCancleText(CHS[4300149])
        return
    end

    local gid = self.gid or Me:queryBasic("gid")
    TradingMgr:tradingCanceRole(gid)
end

function UserSellDlg:onModifyPriceButton(sender, eventType)

    local myUserData = TradingMgr:getTradingUserData()

    local isOk, price, tips = TradingMgr:changePriceCondition(self.price, myUserData[1], PRICE_MIN)
    if isOk then
        local gid = self.gid or Me:queryBasic("gid")
        TradingMgr:tradingChangePriceRole(gid, self.price)
    else
        self:refreshCost(price, self.goodsData)
        gf:ShowSmallTips(tips)
    end
end


function UserSellDlg:onNoteButton(sender, eventType)
    local str = CHS[4200475]
    gf:showTipInfo(str, sender)
end

function UserSellDlg:onNoteButton1(sender, eventType)
    local str = CHS[2100213]
    gf:showTipInfo(str, sender)
end

function UserSellDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

function UserSellDlg:onDesignatedButton(sender, eventType)
    DlgMgr:openDlg("DesignatedUserDlg")
end

function UserSellDlg:setDesignatedChar(char)
    self:setLabelText("DefaultLabel", char.name)
    self.designatedChar = char
end

function UserSellDlg:MSG_EXISTED_CHAR_LIST(data)
    self:onCloseButton()
end

function UserSellDlg:MSG_TRADING_ROLE(data)
    if data.state == 0 then
        self.inputNum = nil
    end
    self:onCloseButton()
end

function UserSellDlg:queryBindNotAnswer()
    if not TradingMgr:getCheckBindFlag() then return end
    gf:ShowSmallTips(CHS[4300198])
    TradingMgr:setCheckBindFlag(false)
end

function UserSellDlg:MSG_FUZZY_IDENTITY(data)
    if TradingMgr:getCheckBindFlag() then
        if CHECKBOX[1] == self.curTradeType then
            local income = TradingMgr:getRealIncome(self.price, true)
            TradingMgr:tradingSellRole(self.price, nil, income)
        elseif CHECKBOX[2] == self.curTradeType then
            local income = TradingMgr:getRealIncome(self.priceDesignated, true)
            TradingMgr:tradingSellRole(self.priceDesignated, self.designatedChar.gid, income)
        end

        TradingMgr:setCheckBindFlag(false)
    end
end

return UserSellDlg
