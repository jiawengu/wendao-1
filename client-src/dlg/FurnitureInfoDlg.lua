-- FurnitureInfoDlg.lua
-- Created by yangym Jun/28/2017
-- 家具悬浮框
local FurnitureInfoDlg = Singleton("FurnitureInfoDlg", Dialog)
local FurnitureInfo = require ("cfg/FurnitureInfo")

local BTN_FUNC = {
    [CHS[3002410]] = { normalClick = "onSell" },
    [CHS[7000295]] = { normalClick = "onBaitan" },
    [CHS[3002816]] = { normalClick = "onResource"},
}

local menuMore = {}

local FONT_SIZE = 19
local ITEM_MARGIN = 5
local ART_FONT_SIZE = 19
local MONEY_IMAGE = {
    ResMgr.ui.small_reward_cash,
    ResMgr.ui.small_reward_glod,
}

local VOUCHER_IMAGE = ResMgr.ui.small_reward_voucher
local CASH_IMAGE = ResMgr.ui.small_reward_cash



function FurnitureInfoDlg:init()

    self:bindListener("MoreButton", self.onMoreButton)
    self:bindListener("ApplyButton", self.onApplyButton)
    self:bindListener("FurnitureInfoDlg", self.onCloseButton)
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("SourceButton", self.onResource)
    self:bindListener("ResourceButton", self.onResource)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("PuttingButton", self.onPuttingButton)
    self:bindListener("SellButton", self.onSell)
    self:bindListener("PreviewButton", self.onPreviewButton)
    self:bindListener("BuyButton", self.onBuyButton)

    self:getControl("MoreButton"):setLocalZOrder(10)

    self.btn = self:getControl("MoreButton"):clone()
    self.btn:retain()

    self.btnLayer = cc.Layer:create()
    self.btnLayer:setAnchorPoint(0, 0)
    self.btnLayer:retain()

    self.furniture = nil
    self.isMore = nil

    self:hookMsg("MSG_INVENTORY")
end

function FurnitureInfoDlg:resetCtrlShowState()
    -- 重置控件显示状态
    self:setCtrlVisible("SourceButton", false)
    self:setCtrlVisible("MoreButton", false)
    self:setCtrlVisible("ApplyButton", false)
    self:setCtrlVisible("StorePanel", false)
    self:setCtrlVisible("PuttingButtonPanel", false)
    self:setCtrlVisible("HasFurniturePanel", false)
    self:setCtrlVisible("NoFurniturePanel", false)
    self:setCtrlVisible("LeftButton", false)
    self:setCtrlVisible("RightButton", false)
    self:setCtrlVisible("PriceLabelPanel", false)
    self:setCtrlVisible("LimitLabel", false)
    self:setCtrlVisible("PuttingPanel", false)
end

-- isFromPutting: 在家具摆放界面中显示
-- isFromPutting.furnitures：家具列表和背包中的所有此类家具
-- isFromPutting.index 当前要显示的那一个家具的序号
-- isNeedHidePrice: 家具名片是否需要隐藏价格
function FurnitureInfoDlg:setBasicInfo(furniture, isCard, isFromPutting, isNeedHidePrice)
    -- 保存当前家具数据
    self.furniture = furniture
    self.isCard = isCard
    self.isFromPutting = isFromPutting

    -- 重置各控件显示状态
    self:resetCtrlShowState()

    local name = furniture.name
    local type = HomeMgr:getFurnitureType(name)
    local purchaseType = HomeMgr:getPurchaseType(name)
    local purchaseCost = HomeMgr:getPurchaseCost(name)
    local level = HomeMgr:getFurnitureLevel(name)
    local maxDur = HomeMgr:getMaxDur(name)
    local dur = furniture.durability or maxDur
    local comfort = HomeMgr:getFurnitureComfort(name)
    local price = HomeMgr:getFurnitureSellPrice(name)
    local capacity = HomeMgr:getFurnitureCapacity(name)

    -- 家具图标
    self:setImage("ItemImage", ResMgr:getItemIconPath(HomeMgr:getFurnitureIcon(name)))
    self:setItemImageSize("ItemImage")

    -- 图标左下角限制交易/限时标记
    if furniture and InventoryMgr:isLimitedItem(furniture) then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage"))
    else
        InventoryMgr:removeLogoBinding(self:getControl("ItemImage"))
    end

    -- 家具名称
    self:setLabelText("NameLabel1", name)

    -- 家具等级
    local levelStr = string.format(CHS[7002359], gf:getChineseNum(level))
    self:setLabelText("NameLabel2", levelStr)

    -- 家具类型
    local typeStr = string.format(CHS[7002361], string.gsub(type, "-", CHS[7002362]))
    self:setLabelText("NameLabel3", typeStr)

    -- 舒适度
    local comfortLabel = string.format(CHS[7002363], comfort)
    self:setLabelText("ComfortLabel", comfortLabel)

    -- 耐久度
    if maxDur then
        local durStr = string.format(CHS[7002360], dur, maxDur)
        self:setLabelText("ComfortLabel_0", durStr)
    else
        self:setLabelText("ComfortLabel_0", CHS[7002367])
    end

    -- 宠物的特别
    if capacity then
        if not furniture.food_num then
            local durStr = string.format(CHS[4200411], capacity, capacity)
            self:setLabelText("ComfortLabel_0", durStr)
        else
            local durStr = string.format(CHS[4200411], furniture.food_num, furniture.max_food_num)
            self:setLabelText("ComfortLabel_0", durStr)
        end
    end

    -- 基本描述
    local descPanel1 = self:getControl("DescPanel")
    local descPanel2 = self:getControl("SpecialPanel")
    local descPanel1Height = descPanel1:getContentSize().height
    local descPanel2Height = descPanel2:getContentSize().height

    local desc1 = HomeMgr:getFurnitureDesc(name)
    local height1 = self:setDescript(desc1, descPanel1, COLOR3.LIGHT_WHITE)
    descPanel1:setContentSize(descPanel1:getContentSize().width, height1)

    -- 特殊功能
    local specialFunc = HomeMgr:getFurnitureSpecialDesc(name)
    local height2 = - 2 * ITEM_MARGIN
    if specialFunc then
        local desc2 = string.format(CHS[7002365], specialFunc)
        height2 = self:setDescript(desc2, descPanel2, COLOR3.LIGHT_WHITE)
        self:setCtrlVisible("SeparateImage_2", true)
    else
        self:setCtrlVisible("SeparateImage_2", false)
    end

    descPanel2:setContentSize(descPanel2:getContentSize().width, height2)

    local limitLabelOffset = 0
    if isFromPutting then
        -- 在居所摆放界面中所显示的名片（会显示购买价格和出售价格）
        self:setCtrlVisible("PuttingPanel", true)

        -- 购买区域之图标
        local buyImage = self:getControl("BuyImage", nil, "BuyPanel")
        self:setImagePlist("BuyImage", MONEY_IMAGE[purchaseType], "BuyPanel")

        -- 购买区域之价格
        local cost = purchaseCost
        if purchaseType == 1 then
            cost = cost * 10000
        end

        self:setCtrlVisible("NotPanel", false, "BuyPanel")
        self:setCtrlVisible("Panel_58", false, "BuyPanel")
        if cost == 0 then
            self:setColorText(CHS[7003094], "NotPanel", "BuyPanel", nil, nil, nil, ART_FONT_SIZE, true)
            self:setCtrlVisible("NotPanel", true, "BuyPanel")
            buyImage:setVisible(false)
        else
            buyImage:setVisible(true)

            self:setCtrlVisible("Panel_58", true, "BuyPanel")
            local costStr, costColor = gf:getArtFontMoneyDesc(cost)
            self:setNumImgForPanel("Panel_58",
                costColor, costStr, false, LOCATE_POSITION.MID, ART_FONT_SIZE, "BuyPanel")
        end

        -- 出售区域之图标
        local buyImage = self:getControl("BuyImage", nil, "SalePanel")

        if HomeMgr:isFunitureCanGetCashBySell(furniture) then
            self:setImagePlist("BuyImage", CASH_IMAGE, "SalePanel")
        else
            self:setImagePlist("BuyImage", VOUCHER_IMAGE, "SalePanel")
        end

        self:setCtrlVisible("NotPanel", false, "SalePanel")
        self:setCtrlVisible("Panel_58", false, "SalePanel")
        -- 出售区域之价格
        if price == 0 then
            self:setColorText(CHS[7003095], "NotPanel", "SalePanel", nil, nil, nil, ART_FONT_SIZE, true)
            buyImage:setVisible(false)
            self:setCtrlVisible("NotPanel", true, "SalePanel")
        else
            buyImage:setVisible(true)

            self:setCtrlVisible("Panel_58", true, "SalePanel")
            local sellStr, sellColor = gf:getArtFontMoneyDesc(price)
            self:setNumImgForPanel("Panel_58",
                sellColor, sellStr, false, LOCATE_POSITION.MID, ART_FONT_SIZE, "SalePanel")
        end
    else
        if isNeedHidePrice == true then
            self:setCtrlVisible("PriceLabelPanel", false)
            self:setCtrlVisible("LimitLabel", false)
            local hideHeight = self:getControl("PriceLabelPanel"):getContentSize().height + self:getControl("LimitLabel"):getContentSize().height + 3 * ITEM_MARGIN
            limitLabelOffset = - hideHeight
        else
            -- 普通情况下显示的名片
            self:setCtrlVisible("PriceLabelPanel", true)
            self:setCtrlVisible("LimitLabel", true)

            -- 出售价格
            local priceStr
            if price > 0 then
                priceStr = string.format(CHS[7002364], gf:getMoneyDesc(price))
            else
                priceStr = CHS[7002366]
            end

            self:setDescript(priceStr, self:getControl("PriceLabelPanel"), COLOR3.BLUE, true)

            -- 限制交易时间
            if InventoryMgr:isLimitedItem(furniture) then
                local str, day = gf:converToLimitedTimeDay(furniture.gift)
                self:setLabelText("LimitLabel", str)
                limitLabelOffset = 0
            else
                limitLabelOffset = - FONT_SIZE
            end
        end
    end

    -- 总高度自适应
    local offset = height1 - descPanel1Height + height2 - descPanel2Height + limitLabelOffset
    local mainPanel = self:getControl("FurnitureInfoDlg")
    mainPanel:setContentSize(mainPanel:getContentSize().width, mainPanel:getContentSize().height + offset)
    self:updateLayout("FurnitureInfoDlg")

    if isCard then  -- 名片信息仅显示来源
        self:setCtrlVisible("SourceButton", true)
    elseif isFromPutting then  -- 家具摆放界面的道具名片
        self:setCtrlVisible("PuttingButtonPanel", true)
    else
        self:setCtrlVisible("MoreButton", true)
        self:setCtrlVisible("ApplyButton", true)
    end

    if isFromPutting then
        local furnitures = self.isFromPutting.furnitures
        local index = self.isFromPutting.index
        -- 家具摆放界面显示的两种情况
        if furnitures and #furnitures > 0 then
            self:setCtrlVisible("HasFurniturePanel", true)
            self:setCtrlVisible("LeftButton", (index > 1))
            self:setCtrlVisible("RightButton", (index < #furnitures))
        else
            self:setCtrlVisible("NoFurniturePanel", true)
        end
    end

    menuMore = self:setMenuMore(isCard)
end

function FurnitureInfoDlg:onMoreButton(sender, eventType)
    if not self.isMore then
        self.isMore = true
        local btnSize = self.btn:getContentSize()
        for i,v in pairs(menuMore) do
            local btn = self.btn:clone()
            btn:setTitleText(tostring(v))
            btn:setPosition(0 + btnSize.width / 2, btnSize.height * i + btnSize.height / 2)
            btn:setVisible(true)
            self.btnLayer:addChild(btn)

            self:bindTouchEndEventListener(btn, function(self, sender, eventType)
                local title = sender:getTitleText()
                if BTN_FUNC[title].normalClick and "function" == type(self[BTN_FUNC[title].normalClick]) then
                    self[BTN_FUNC[title].normalClick](self, sender, eventType)
                end
            end)
        end
        self.btnLayer:setPosition(0, 0)
        self.btnLayer:removeFromParent()
        sender:addChild(self.btnLayer)
    else
        self.isMore = false
        self.btnLayer:removeFromParent()
    end
end

-- 使用
function FurnitureInfoDlg:onApplyButton(sender, eventType)
    -- 判断物品是否已经超时
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    if HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        -- 当前家具只能在自己居所中使用
        gf:ShowSmallTips(CHS[7003093])
        return
    end

    if not self.furniture or not self.furniture.name then
        return
    end

    local mainType = HomeMgr:getFurnitureMainTypeByName(self.furniture.name)
    local mapName = MapMgr:getCurrentMapName()
    if not string.match(mapName, mainType) then
        -- 当前家具只能在XXX处摆放
        gf:ShowSmallTips(string.format(CHS[7002381], mainType))
        return
    end

    gf:CmdToServer('CMD_HOUSE_TRY_MANAGE', {dlg_para = HomeMgr:getFurnitureType(self.furniture.name) .. ":" .. self.furniture.name})
    self:onCloseButton()
end

-- 存入/取出
function FurnitureInfoDlg:onDepositButton(sender, eventType)
    local str = self:getLabelText("Label_16", sender)
    if str == CHS[4300070] then
        StoreMgr:cmdBagToStore(self.furniture.pos)
    else
        StoreMgr:cmdStoreToBag(self.furniture.pos)
    end
    self:onCloseButton()
end

-- 来源
function FurnitureInfoDlg:onResource(sender, eventType)
    if not self.furniture then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    if #InventoryMgr:getRescourse(self.furniture.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(self:getControl("FurnitureInfoDlg"))
    InventoryMgr:openItemRescourse(self.furniture.name, rect)
end

-- 出售
function FurnitureInfoDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end

    local name = self.furniture.name
    local pos = self.furniture.pos
    local price = HomeMgr:getFurnitureSellPrice(name)
    local priceStr = gf:getMoneyDesc(price)
    local isForeverLimit = InventoryMgr:isLimitedItemForever(self.furniture)
    local isBagFurniture = InventoryMgr:isBagItemByPos(pos)
    local tip
    if isForeverLimit or (not isBagFurniture) then
        tip = string.format(CHS[7003092], priceStr, name)
    else
        tip = string.format(CHS[7003091], priceStr, name)
    end

    if price <= 0 then
        gf:ShowSmallTips(CHS[7002382])
        return
    end

    gf:confirm(tip, function()
        gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, pos, 1)
        self:onCloseButton()
    end)
end

-- 摆摊
function FurnitureInfoDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 判断是否可以摆摊
    if InventoryMgr:isLimitedItem(self.furniture) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002435], MarketMgr:getOnSellLevel()))
        return
    end


    local furniture = {name = self.furniture.name, bagPos = self.furniture.pos, icon = self.furniture.icon, amount = self.furniture.amount, level = self.furniture.level, detail = self.furniture}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(furniture.detail.pos)
    MarketMgr:openSellItemDlg(furniture.detail, 3)
    self:onCloseButton()
end

-- 仓库显示存入/取出格式
function FurnitureInfoDlg:setStoreDisplayType()
    if not self.furniture then
        return
    end

    if self.furniture.pos < 200 then
        self:setLabelText("Label_16", CHS[4300070], "DepositButton")
    else
        self:setLabelText("Label_16", CHS[4300071], "DepositButton")
    end

    self:setCtrlVisible("StorePanel", true)
    self:setCtrlVisible("ApplyButton", false)
    self:setCtrlVisible("MoreButton", false)
    self:setCtrlVisible("SourceButton", false)
    self:setCtrlVisible("PuttingButtonPanel", false)
end

function FurnitureInfoDlg:setMenuMore(isCard)
    local menuTab = {}
    if not isCard then
        table.insert(menuTab, CHS[3002410])
        if not InventoryMgr:isLimitedItem(self.furniture) and MarketMgr:isItemCanSell(self.furniture) then
            table.insert(menuTab, CHS[7000295])
        end

        table.insert(menuTab, CHS[3002816])
    end

    return menuTab
end

function FurnitureInfoDlg:setDescript(descript, panel, defaultColor, horInMid)
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then
        textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b)
    end
    textCtrl:setFontSize(FONT_SIZE)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居左显示
    local textW, textH = textCtrl:getRealSize()
    if horInMid then
        textCtrl:setPosition((panel:getContentSize().width - textW) * 0.5, textH)
    else
        textCtrl:setPosition(0, textH)
    end

    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    return textH
end

function FurnitureInfoDlg:cleanup()
    self.furniture = nil

    if self.btnLayer then
        self.btnLayer:release()
        self.btnLayer = nil
    end

    if self.btn then
        self.btn:release()
        self.btn = nil
    end
end

function FurnitureInfoDlg:onLeftButton()
    if not self.furniture then
        return
    end

    if not self.isFromPutting then
        return
    end

    local furnitures = self.isFromPutting.furnitures
    local index = self.isFromPutting.index
    local targetIndex = index - 1
    self:setBasicInfo(furnitures[targetIndex], false, {furnitures = furnitures, index = targetIndex})
end

function FurnitureInfoDlg:onRightButton()
    if not self.furniture then
        return
    end

    if not self.isFromPutting then
        return
    end

    local furnitures = self.isFromPutting.furnitures
    local index = self.isFromPutting.index
    local targetIndex = index + 1
    self:setBasicInfo(furnitures[targetIndex], false, {furnitures = furnitures, index = targetIndex})
end

-- 摆设
function FurnitureInfoDlg:onPuttingButton()
    if not self.furniture or not self.furniture.pos then
        return
    end

    DlgMgr:sendMsg("HomePuttingDlg", "doPutting", self.furniture.pos)
    self:onCloseButton()
end

-- 购买
function FurnitureInfoDlg:onBuyButton()
    if not self.furniture or not self.furniture.name then
        return
    end
    local LuBanFur = HomeMgr:getLuBanFur()
    local name = self.furniture.name
    local cost = HomeMgr:getPurchaseCost(name)
    if cost <= 0 then
        if not LuBanFur[name] then
            gf:ShowSmallTips(CHS[7100035])
        else
            gf:ShowSmallTips(CHS[4200450])
        end
        return
    end

    local info = FurnitureInfo[name]
    local limit = HomeMgr:getLimitByType(info.furniture_type)
    local amount = 0
    for k, v in pairs(FurnitureInfo) do
        if v.furniture_type == info.furniture_type then
            local items = StoreMgr:getFurnitureByName(k, true)
            for i = 1, #items do
                amount = amount + items[i].amount
            end
        end
    end
    if limit > 0 and amount >= limit then
        gf:ShowSmallTips(CHS[2000334])
        return
    end

    DlgMgr:sendMsg("HomePuttingDlg", "doBuy", self.furniture.name)
    self:onCloseButton()
end

-- 预览
function FurnitureInfoDlg:onPreviewButton()
    if not self.furniture or not self.furniture.name then
        return
    end

    DlgMgr:sendMsg("HomePuttingDlg", "doPreview", self.furniture.name)
    self:onCloseButton()
end

function FurnitureInfoDlg:MSG_INVENTORY(data)
    for i = 1, data.count do
        if not self.furniture or data[i].pos == self.furniture.pos then
            self:onCloseButton()
            return
        end
    end
end

return FurnitureInfoDlg
