-- MarketSellDlg.lua
-- Created by liuhb Apr/22/2015
-- 摆摊界面

local MarketSellDlg = Singleton("MarketSellDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local RewardContainer = require("ctrl/RewardContainer")

local sellCow = MarketMgr.sellCow                   -- 摆摊界面列
local bagCow = 4                     -- 背包界面列
local magin = 1
local sellAccount = MarketMgr:getMySellNum()
local sellItemCtrlList = {}

local CONST_DATA =
{
    Colunm = 2,
}

local cardAmount

function MarketSellDlg:init()
    self:bindListener("DealRecordButton", self.onDealRecordButton)
    self:bindListener("GetMoneyButton", self.onGetMoneyButton)
    self:bindListener("MarketBuyButton", self.onMarketBuyButton)
    self:bindListener("BuyCoinButton", self.onBuyCoinButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("MoneyPanel", self.onBuyCoinButton)

    -- 初始化界面
    self:initView()

    -- 更新数据
    self:updateViewData()

    -- 设置所有hook消息
    self:setAllHookMsgs()

    -- 请求，我的摆摊界面
    MarketMgr:requestRefreshMySell(self:tradeType())

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"ItemTagCheckBox", "PetTagCheckBox", "ChangeCardDlgCheckBox", "MoneyTagCheckBox"}, self.onTagCheckBox)
    self.radioGroup:selectRadio(1)
    self:onItemTagCheckBox()

    if not MarketMgr:getIsCanShowCashTag() then
        self:setCtrlVisible("MoneyTagCheckBox", false)
    end
end

-- 设置所有hook消息
function MarketSellDlg:setAllHookMsgs()
    self:hookMsg("MSG_STALL_MINE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INSIDER_INFO")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_SET_OWNER")
    self:hookMsg("MSG_STORE")
end

function MarketSellDlg:setAllItemPanelVisible()
    self:setCtrlVisible("PetListPanel", false)
    self:setCtrlVisible("BagItemListPanel", false)
    self:setCtrlVisible("ChangeCardListPanel", false)
    self:setCtrlVisible("MoneyListPanel", false)
end

function MarketSellDlg:onTagCheckBox(sender, evetType)
    local name = sender:getName()
    if name == "ItemTagCheckBox" then
        self:onItemTagCheckBox()
    elseif name == "PetTagCheckBox" then
        self:onPetTagCheckBox()
    elseif name == "ChangeCardDlgCheckBox" then
        self:onChangeCardDlgCheckBox()
    elseif name == "MoneyTagCheckBox" then
        self:onMoneyTagCheckBox()
    end
end

function MarketSellDlg:onItemTagCheckBox()
    self:setAllItemPanelVisible()
    self:setCtrlVisible("BagItemListPanel", true)
    self:checkItemEmptyPanel()
end


function MarketSellDlg:onPetTagCheckBox()
    self:setAllItemPanelVisible()
    self:setCtrlVisible("PetListPanel", true)
    self:checkPetEmptyPanel()
end

function MarketSellDlg:onMoneyTagCheckBox()
    self:setAllItemPanelVisible()
    self:setCtrlVisible("MoneyListPanel", true)
    self:updateMoneyListData()
end

function MarketSellDlg:onChangeCardDlgCheckBox()
    if self.radioGroup:getSelectedRadioName() ~= "ChangeCardDlgCheckBox" then
        self.radioGroup:setSetlctByName("ChangeCardDlgCheckBox")
    end
    self:setAllItemPanelVisible()
    self:setCtrlVisible("ChangeCardListPanel", true)
    self:checkChangeCardEmptyPanel()
end

function MarketSellDlg:checkChangeCardEmptyPanel()
    local items = StoreMgr:getChangeCard()
    local cardPanel = self:getControl("ChangeCardListPanel")
    if #items == 0 then
        self:setCtrlVisible("NoticePanel", true, cardPanel)
    else
        self:setCtrlVisible("NoticePanel", false, cardPanel)
    end
end

function MarketSellDlg:checkItemEmptyPanel()
    local bagItemPanel = self:getControl("BagItemListPanel")
    if self.itemList == nil or table.maxn(self.itemList) == 0 then
        self:setCtrlVisible("NoticePanel", true, bagItemPanel)
    else
        self:setCtrlVisible("NoticePanel", false, bagItemPanel)
    end
end

function MarketSellDlg:checkPetEmptyPanel()
    local petPanel = self:getControl("PetListPanel")
    if self.petList == nil or table.maxn(self.petList) == 0 then
        self:setCtrlVisible("NoticePanel", true, petPanel)
    else
        self:setCtrlVisible("NoticePanel", false, petPanel)
    end
end

function MarketSellDlg:cleanup()
    self:releaseCloneCtrl("sellItemCtrl")
    self:releaseCloneCtrl("itemSelectImg")
    self:releaseCloneCtrl("sellLockItemCtrl")
    self:releaseCloneCtrl("bagItemCtrl")
    self:releaseCloneCtrl("bagItemSelectCtrl")
    self:releaseCloneCtrl("petItemCtrl")
    self:releaseCloneCtrl("petItemSelectCtrl")
    self:releaseCloneCtrl("cardItemSelectCtrl")
    self:releaseCloneCtrl("cardItemCtrl")

    sellItemCtrlList = {}
    self.radioGroup = nil
    self.selectCardName = nil
    cardAmount = 0
end

-- 初始化界面控件
function MarketSellDlg:initView()
    -- 初始化左侧列表
    self:initLeftView()

    -- 初始化右侧显示列表
    self:initRightView()

    -- 初始化整个界面数据
    self:initWholeView()

    -- 初始化道具数据
    self:initItemList()

    -- 初始化宠物数据
    self:initPetList()

    -- 隐藏审核提示
    self:setCtrlVisible("InfoPanel", false, "ItemPanel")
end

-- 初始化左侧列表
function MarketSellDlg:initLeftView()
    self.sellItemCtrl = self:getControl("ItemCellPanel")
    self.sellItemCtrl:retain()
    self.sellItemCtrl:removeFromParentAndCleanup()

    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.sellItemCtrl)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()

    self.sellLockItemCtrl = self:getControl("LockPanel")
    self.sellLockItemCtrl:retain()
    self.sellLockItemCtrl:removeFromParentAndCleanup()
end

-- 初始化右侧显示列表
function MarketSellDlg:initRightView()
    -- 背包单元格
    self.bagItemCtrl = self:getControl("ItemCellPanel")
    self.bagItemCtrl:retain()
    self.bagItemCtrl:removeFromParentAndCleanup()

    self.bagItemSelectCtrl = self:getControl("ChosenEffectImage", Const.UIImage, self.bagItemCtrl)
    self.bagItemSelectCtrl:retain()
    self.bagItemSelectCtrl:removeFromParentAndCleanup()

    -- 宠物单元格
    self.petItemCtrl = self:getControl("PetCellPanel")
    self.petItemCtrl:retain()
    self.petItemCtrl:removeFromParentAndCleanup()

    self.petItemSelectCtrl = self:getControl("ChosenEffectImage", Const.UIImage, self.petItemCtrl)
    self.petItemSelectCtrl:retain()
    self.petItemSelectCtrl:removeFromParentAndCleanup()

    -- 变身卡
    self.cardItemCtrl = self:getControl("CardCellPanel")
    self.cardItemCtrl:retain()
    self.cardItemCtrl:removeFromParentAndCleanup()

    self.cardItemSelectCtrl = self:getControl("ChosenEffectImage", Const.UIImage, self.cardItemCtrl)
    self.cardItemSelectCtrl:retain()
    self.cardItemSelectCtrl:removeFromParentAndCleanup()

    -- 金钱
    self.moneyItemPanel = self:retainCtrl("MoneyPanel", "MoneyListPanel")
    self.moneyItemSelectCtrl = self:retainCtrl("ChosenEffectImage", self.moneyItemPanel)
end

-- 初始化整体界面
function MarketSellDlg:initWholeView()
    self:setLabelText("MyBoothLabel", string.format(CHS[5000123], 0, 16))

    -- 设置角色身上的金钱
    self:updateCashView()

    -- 设置摆摊的金钱
    local cashText, fontColor = gf:getArtFontMoneyDesc(MarketMgr:getMySellCashData() or 0)
    self:setNumImgForPanel("MeMarketCoinPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)

    -- 设置珍宝和集市的ui区别
    self:setTradeTypeUI()
end

function MarketSellDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", false, self.sellItemCtrl)
    self:setCtrlVisible("CoinImage", true, self.sellItemCtrl)

    -- 设置玩家身上的金元宝
    local moneyPanel = self:getControl("MoenyPanel")
    self:setCtrlVisible("GoldImage", false, moneyPanel)
    self:setCtrlVisible("MoneyImage", true, moneyPanel)

    -- 收入金元宝
    local earningPanel = self:getControl("MarketMoneyPanel")
    self:setCtrlVisible("GoldImage", false, earningPanel)
    self:setCtrlVisible("MoneyImage", true, earningPanel)

    -- 不等价交易提示
    self:setLabelText("InfoLabel", CHS[7001021], "InfoPanel2")

    -- 集市不显示金钱
    self:setCtrlVisible("MoneyTagCheckBox", false)
end

-- 更新界面数据
function MarketSellDlg:updateViewData()
    -- 更新左侧列表数据
    --self:updateLeftViewData()

    -- 更新右侧具体物品数据
    self:updateItemData()
    self:updatePetListData()
    self:updateCardListData()
    self:updateMoneyListData()

    -- 更新整体界面数据
   -- self:updateWholeViewData()
end



function MarketSellDlg:initSallList()
    local data = MarketMgr:getSellItemList(self:tradeType())
    local listPanel = self:getControl("ItemListPanel")
    listPanel:removeAllChildren()

    local itemPanel = self:getControl("ItemPanel")
    if #data == 0 then
        self:setCtrlVisible("NoticePanel", true, itemPanel)
    else
        self:setCtrlVisible("NoticePanel", false, itemPanel)
    end

    -- 交易记录
    if MarketMgr:getDealNum(self:tradeType()) == 0 then
        self:setCtrlVisible("InfoPanel", false, itemPanel)
    else
        self:setCtrlVisible("InfoPanel", true, itemPanel)
    end


    local num = #data
    local needAddLock = false
    if self:getMaxSellItemNum() == num and Me:getVipType() ~= 3 then
        num = num + 1 -- 多一个锁定位置
        needAddLock = true
    end

    local contentLayer = ccui.Layout:create()
    contentLayer:setName("contentLayer")
    local line = math.floor(num/ CONST_DATA.Colunm)
    local left = num % CONST_DATA.Colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * self.sellItemCtrl:getContentSize().height

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = CONST_DATA.Colunm
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * CONST_DATA.Colunm
            local cell
            if needAddLock and  tag == num then
                cell = self.sellLockItemCtrl:clone()
                self:bindTouchEndEventListener(cell, function(self, sender, eventType)
                    gf:confirm(CHS[5000131], function()
                        DlgMgr:openDlg("OnlineMallVIPDlg")
                    end, nil, nil, nil, nil, true)
                end)
            else
                cell = self.sellItemCtrl:clone()
                self:setItemData(cell, data[tag])
            end
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * self.sellItemCtrl:getContentSize().width
            local y = totalHeight - (i - 1) * self.sellItemCtrl:getContentSize().height
            cell:setPosition(x, y)
            cell:setTag(tag)
            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(listPanel:getContentSize().width, totalHeight)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(listPanel:getContentSize())
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)
    scroview:setBounceEnabled(true)

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end

    listPanel:addChild(scroview)
end

function MarketSellDlg:setItemData(cell, data)
    local imgPath
    local resType = ccui.TextureResType.localType
    local isPet = false
    local isMoneyGood = data.stall_item_type == TRANSFER_ITEM_TYPE.CASH
    if PetMgr:getPetIcon(data.name) then
        imgPath =   ResMgr:getSmallPortrait(PetMgr:getPetIcon(data.name))
        data.name = PetMgr:getShowNameByRawName(data.name)
        local petShowName = MarketMgr:getPetShowName(data)
        data.petShowName = petShowName
        isPet = true
    elseif isMoneyGood then
        imgPath = ResMgr.ui.big_cash
        resType = ccui.TextureResType.plistType
    else
        local icon = InventoryMgr:getIconByName(data.name)
        imgPath = ResMgr:getItemIconPath(icon)
    end

    cell:setName(data.id)

    local goodsImage = self:getControl("IconImage", Const.UIImage, cell)
    goodsImage:loadTexture(imgPath, resType)
    self:setItemImageSize("IconImage", cell)

    local iconPanel = self:getControl("IconPanel", nil, cell)
    if  data.level ~= 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end


    -- 设置数量
    if data.amount and data.amount > 1 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    end

    if data.req_level and data.req_level > 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 法宝相性
    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(goodsImage, data.item_polar)
    end

    -- 带属性超级黑水晶
    if string.match(data.name, CHS[3003078]) then
        local name = string.gsub(data.name,CHS[3003079],"")
        local list = gf:split(name, "|")
        self:setLabelText("NameLabel", list[1], cell)
        local field = EquipmentMgr:getAttribChsOrEng(list[1])
        local str = field .. "_" .. Const.FIELDS_EXTRA1
        local value = 0
        local maxValue = 0
        local bai = ""
        if list[2] then
            value =  tonumber(list[2])
            local equip = {req_level = data.level, equip_type = list[3]}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3003080])[field] then bai = "%" end
        end

        self:setLabelText("NameLabel2", value .. bai .. "/" .. maxValue .. bai, cell)

        self:setCtrlVisible("NameLabel", true, cell)
        self:setCtrlVisible("NameLabel2", true, cell)
        self:setCtrlVisible("OneNameLabel", false, cell)
    elseif isMoneyGood then
        local sellMoney = tonumber(data.name)
        local cashText, fontColor = gf:getArtFontMoneyDesc(sellMoney)
        self:setNumImgForPanel("MoneyNamePanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, cell)
        self:setCtrlVisible("NameLabel", false, cell)
        self:setCtrlVisible("NameLabel2", false, cell)
    else
        -- 名字
        self:setLabelText("OneNameLabel", data.petShowName or data.name, cell)
        self:setCtrlVisible("NameLabel", false, cell)
        self:setCtrlVisible("NameLabel2", false, cell)
    end

    -- 金钱
    local price = data.price

    local sell_buy_type = data.sell_type
    if (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_BUY) and data.appointee_name ~= Me:queryBasic("name") then
        -- 指定交易，指定对象不是我，显示一口价
         price = data.buyout_price
    elseif (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION_BUY) then
        -- 拍卖显示当前价格
        price = data.buyout_price
    end


    if data.status == 3 then
        -- 过期
        price = data.price
    end


    local str, color = gf:getMoneyDesc(price, true)
    local coinLabel = self:getControl("CoinLabel", nil, cell)
    coinLabel:setColor(color)
    coinLabel:setString(str)
    self:setLabelText("CoinLabel2", str, cell)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addItemSelcelImage(cell)
            if isMoneyGood then
                local dlg = DlgMgr:openDlg("MarketSellMoneyDlg")
                dlg:setTradeType(self:tradeType())
                dlg:setSellMoney(data, MarketMgr:statusToDlgType(data.status), data.id)
            else
                if MarketMgr.isGoldtype(self:tradeType()) then
                    MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime, MARKET_CARD_TYPE.ME_ACTION,
                        data, isPet, false, self:tradeType())
                else
                    MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime, MARKET_CARD_TYPE.ME_ACTION,
                        data, isPet, false, self:tradeType())
                end
            end
        end
    end

    cell:addTouchEventListener(listener)

    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addItemSelcelImage(cell)
            local rect = self:getBoundingBoxInWorldSpace(iconPanel)
            if isMoneyGood then
                sender.reward = {CHS[3002143], CHS[3002143]}
                RewardContainer:imagePanelTouch(sender, eventType)
            else
                MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime, MARKET_CARD_TYPE.FLOAT_DLG,
                    rect, isPet, false, self:tradeType())
            end
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    self:setCtrlVisible("TimeoutImage", false, cell)
    self:setCtrlVisible("PublictyImage", false, cell)
    self:setCtrlVisible("TimeLabel", false, cell)
    self:setCtrlVisible("BackImage", false, cell)

    -- 超时
    if data.status == 3 then
        self:setCtrlVisible("TimeoutImage", true, cell)
    -- 公示中
    elseif data.status == 1 or data.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW then
        self:setCtrlVisible("TimeLabel", true, cell)
        local leftTime = data.endTime - gf:getServerTime()
        local timeStr = MarketMgr:getTimeStr(leftTime, self:tradeType())    -- self:tradeType() == 1为集市，集市显示类型为1
        self:setLabelText("TimeLabel", timeStr, cell)
        self:setCtrlVisible("BackImage", true, cell)
    elseif data.status == 4 then
        self:setCtrlVisible("TipImage", true, cell)
    end

    MarketMgr:setSellBuyTypeFlag(data.sell_type, self, cell)

    -- 未鉴定
    if  data.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(goodsImage)
    end
end

-- 商品列表选中效果
function MarketSellDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)
end

-- 道具选中效果
function MarketSellDlg:addBagItemSelectImage(item)
    self.bagItemSelectCtrl:removeFromParent()
    item:addChild(self.bagItemSelectCtrl)
end

-- 宠物选中效果
function MarketSellDlg:addPetItemSelectImage(item)
    self.petItemSelectCtrl:removeFromParent()
    item:addChild(self.petItemSelectCtrl)
end

-- 变身卡选中效果
function MarketSellDlg:addPetItemSelectImage(item)
    self.cardItemSelectCtrl:removeFromParent()
    item:addChild(self.cardItemSelectCtrl)
end

-- 金钱选中效果
function MarketSellDlg:addMoneyItemSelectImage(item)
    self.moneyItemSelectCtrl:removeFromParent()
    item:addChild(self.moneyItemSelectCtrl)
end

-- 玩家所能卖的摊位
function MarketSellDlg:getMaxSellItemNum()
    local type = Me:getVipType()
    local num = 0
    if type == 0 then
        num = 4
    elseif type == 1 then
        num = 8
    elseif type == 2 then
        num = 12
    elseif type == 3 then
        num = 16
    end

    return num
end

-- 设置选中的背包物品
function MarketSellDlg:setSelectItem(pos)
    local listCtrl = self:getControl("BagItemsScrollView")
    local item  = listCtrl:getChildByName(tostring(pos))
    if item then
        local iconPanel = self:getControl("IconImagePanel", nil, item)
        self:addBagItemSelectImage(iconPanel)
    end
end

-- 初始化道具数据
function MarketSellDlg:initItemList()
    local items = MarketMgr:getBagCanSell(self:tradeType())
    self.itemList = {}
    local index = 1
    for i = 1, #items do
        local isLimited = InventoryMgr:isLimitedItem(items[i])  -- 限制交易物品不能摆摊
        local iscannotSell = not gf:isExpensive(items[i], false) and MarketMgr:isGoldtype(self:tradeType()) -- 珍宝非贵重物品不能摆摊

        -- 不是限制交易类型的、满足出售条件、且耐久度为满的才可以出售
        if not (isLimited or iscannotSell or InventoryMgr:isUsedItem(items[i])) then
            self.itemList[index] = items[i]
            index = index + 1
        end
    end
end

-- 初值道具物品
function MarketSellDlg:updateItemData()
    local items = self.itemList
    self:checkItemEmptyPanel()
    local listCtrl = self:getControl("BagItemsScrollView")
    listCtrl:removeAllChildren()
    listCtrl:setTouchEnabled(true)
    local count = #items
    local row = math.ceil(count / bagCow)
    local contentSize = self.bagItemCtrl:getContentSize()
    local innerContainner = listCtrl:getInnerContainer()
    local listContentSize = listCtrl:getContentSize()
    local innerContentSize = {width = math.max(bagCow * contentSize.width, listContentSize.width), height = math.max(row * (magin + contentSize.height), listContentSize.height)}
    local offY = math.max(listContentSize.height - row * (magin + contentSize.height), 0)
    listCtrl:setInnerContainerSize(innerContentSize)
    for i = 1, #items do
        local item = self.bagItemCtrl:clone()
        local newY = math.floor((i - 1) / bagCow)
        local newY = row - newY - 1
        local newX = (i - 1) % bagCow
        item:setPosition(magin + newX * (contentSize.width + magin), offY + magin + newY * (contentSize.height + magin))
        listCtrl:addChild(item)

        self:bindTouchEndEventListener(item, function(self, sender, eventType)
            if not MarketMgr:checkItemSellCondition(items[i], self:tradeType()) then return end

            if MarketMgr:isGoldtype(self:tradeType()) then
                if items[i].item_type == ITEM_TYPE.EQUIPMENT or items[i].item_type == ITEM_TYPE.ARTIFACT then
                    --local dlg = DlgMgr:openDlg("MarketGoldItemInfoDlg")
                    --dlg:setData(items[i])

                    MarketMgr:openZhenbaoSellDlg(items[i])
                end
            else
                if items[i].item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(items[i].equip_type) and  items[i].unidentified == 0 then
                    local dlg = DlgMgr:openDlg("MarketSellEquipmentDlg")
                    dlg:setTradeType(self:tradeType())
                    dlg:setEquipInfo(items[i], 3)
                else
                    MarketMgr:openSellItemDlg(items[i], 3, self:tradeType())
                end
            end

            local iconPanel = self:getControl("IconImagePanel", nil, item)
            self:addBagItemSelectImage(iconPanel)

        end)

        local iconPanel = self:getControl("IconImagePanel", Const.UIPanel, item)
        if nil == items[i].amount or 1 >= items[i].amount then
            self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_BOTTOM)
        else
            self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, items[i].amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        end

        if nil == items[i].level or 0 == items[i].level then
            self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
        else
            self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, items[i].level, false, LOCATE_POSITION.LEFT_TOP, 21)
        end

        local iconPath = ResMgr:getItemIconPath(items[i].icon)
        self:setImage("IconImage", iconPath, item)
        self:setItemImageSize("IconImage")

        if items[i].item_type == ITEM_TYPE.EQUIPMENT and items[i].unidentified == 1 then
            InventoryMgr:addLogoUnidentified(self:getControl("IconImage", nil, item))
        end

        if items[i].item_type == ITEM_TYPE.EQUIPMENT and items[i].req_level and items[i].req_level > 0 then
            self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, items[i].req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
        end

        -- 法宝相性
        if items[i].item_type ==ITEM_TYPE.ARTIFACT and items[i].item_polar then
            InventoryMgr:addArtifactPolarImage(self:getControl("IconImage", nil, item), items[i].item_polar)
        else
            InventoryMgr:removeArtifactPolarImage(self:getControl("IconImage", nil, item))
        end

        item:setName(tostring(items[i].pos))
    end
end



-- 刷新变身卡列表
function MarketSellDlg:updateCardListData()
    local listView = self:getControl("CardListView")
    local positionY = listView:getInnerContainer():getPositionY()

    local list, size = self:resetListView("CardListView", 0)
    local storeCard = StoreMgr:getCardsInCardBagDisplayAmount()
    self:setCtrlVisible("NoticePanel", false, "ChangeCardListPanel")

    local cardNewAmount = 0
    for i, v in pairs(storeCard) do
        -- 增加项
        local panel = self:createCardItem(v)
        list:pushBackCustomItem(panel)
        cardNewAmount = cardNewAmount + 1
        if self.selectCardName and self.selectCardName == v.name then
            self:selectCardPanel(panel, nil, true)
        end
    end
    -- 如果卡片种类没有变化（只有数量有变化），则需要保持在原来的位置
    if cardAmount == cardNewAmount then
        list:doLayout()
        list:getInnerContainer():setPositionY(positionY)
    end
    cardAmount = cardNewAmount
end

-- 刷新金钱列表
function MarketSellDlg:updateMoneyListData()
    local moneyListPanel = self:getControl("MoneyListPanel")
    local myCash = Me:queryBasicInt("cash")
    local cashText, fontColor = gf:getArtFontMoneyDesc(myCash)
    local panel = self:getControl("OwnMoneyPanel", nil, moneyListPanel)
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, panel)

    if not MarketMgr:getIsCanSellCash() then
        self:setCtrlVisible("NoticePanel", true, moneyListPanel)
        self:setCtrlVisible("MoneyListView", false, moneyListPanel)
        self:setCtrlVisible("InfoLabel", false, moneyListPanel)

        local panel = self:getControl("NoticePanel", nil, moneyListPanel)
        self:setLabelText("InfoLabel1", string.format(CHS[4300347], MarketMgr:getSellCashAfterDays()), panel)
        return
    else
        self:setCtrlVisible("NoticePanel", false, moneyListPanel)
        self:setCtrlVisible("MoneyListView", true, moneyListPanel)
        self:setCtrlVisible("InfoLabel", true, moneyListPanel)
    end

    local list, size = self:resetListView("MoneyListView", 5, nil, moneyListPanel)
    local cashList = MarketMgr:getCanSellCashList()
    for i = 1, #cashList do
        -- 增加项
        list:pushBackCustomItem(self:createMoneyItem(cashList[i], myCash))
    end
end

-- 创建金钱列表条目
function MarketSellDlg:createMoneyItem(sellMoney, myCash)
    local panel = self.moneyItemPanel:clone()
    local ownNum = math.floor(myCash / sellMoney)

    self:setImagePlist("GuardImage", ResMgr.ui.big_cash, panel)
    self:setItemImageSize("GuardImage", panel)
    self:setLabelText("OwnNumLabel", string.format(CHS[4100762], ownNum), panel)

    local cashText, fontColor = gf:getArtFontMoneyDesc(sellMoney)
    self:setNumImgForPanel("MoneyNumPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, panel)

    if ownNum == 0 then
        local img = self.moneyItemSelectCtrl:clone()
        panel:addChild(img)
        gf:grayImageView(img)
        gf:grayImageView(self:getControl("GuardImage", nil, panel))
        gf:grayImageView(self:getControl("GridImage", nil, panel))

        self:bindTouchEndEventListener(panel, function()
            gf:ShowSmallTips(CHS[5420253])
        end)
    else
        panel.sellMoney = sellMoney
        self:bindTouchEndEventListener(panel, self.onSelectMoneyPanel)
    end

    return panel
end

function MarketSellDlg:onSelectMoneyPanel(sender)
    local myCash = Me:queryBasicInt("cash")
    local sellCash = sender.sellMoney
    local sellNum = MarketMgr:getSellPosCount(self:tradeType())
    local allNum = MarketMgr:getMySellNum(self:tradeType())

    if not sellNum then
        gf:ShowSmallTips("444"..CHS[3003075])
        return
    end

    if sellNum >= allNum then
        if Me:getVipType() ~= 3 then
            gf:ShowSmallTips(CHS[3003076])
            return
        else
            gf:ShowSmallTips(CHS[3003077])
            return
        end
    end

    if myCash < sellCash then
        gf:ShowSmallTips(CHS[5420253])
        self:updateMoneyListData()
        return
    end

    local dlg = DlgMgr:openDlg("MarketSellMoneyDlg")
    dlg:setTradeType(self:tradeType())
    dlg:setSellMoney({name = tostring(sellCash)}, 3)

    self:addMoneyItemSelectImage(sender)
end

-- 刷新宠物列表
function MarketSellDlg:updatePetListData()
    local list, size = self:resetListView("PetListView", 0)
    list:setItemsMargin(6)
    self.petListSize = size

    self:checkPetEmptyPanel()


    for i, v in pairs(self.petList) do
        -- 增加项
        list:pushBackCustomItem(self:createPetItem(v))
    end
end

function MarketSellDlg:initPetList()
    local pets = PetMgr.pets
    self.petList = {}
    for k, v in pairs(pets) do
     --   local islimited = PetMgr:isLimitedPet(v) -- 限制交易物品不能摆摊
     --   local iscannotSell = not gf:isExpensive(v, true) and MarketMgr:isGoldtype(self:tradeType()) -- 珍宝非贵重物品不能摆摊

        local rank = v:queryInt("rank")
        if rank == Const.PET_RANK_BABY or rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
            table.insert(self.petList,v)
        end
    end

    table.sort(self.petList, function(l,r) return PetMgr:comparePet(l,r) end)
end

function MarketSellDlg:createCardItem(cardInfo)
    local panel = self.cardItemCtrl:clone()
    local cardInfoCfg = InventoryMgr:getCardInfoByName(cardInfo.name)
    local icon = InventoryMgr:getIconByName(cardInfo.name)
    self:setImage("GuardImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("GuardImage", panel)
    self:setLabelText("NameLabel", cardInfo.name, panel)
    self:setLabelText("LevelLabel", CHS[4100091] .. cardInfo.count, panel)
    panel.cardInfo = cardInfo
    self:bindTouchEndEventListener(panel, self.selectCardPanel)


    local cards = StoreMgr:getChangeCardByName(cardInfo.name, true)
    if #cards == 0 then
        gf:grayImageView(self:getControl("GuardImage", nil, panel))
        gf:grayImageView(self:getControl("BKImage", nil, panel))
        self:getControl("NameLabel", nil, panel):setColor(COLOR3.GRAY)
        self:getControl("LevelLabel", nil, panel):setColor(COLOR3.GRAY)
    end

    return panel
end

-- isDef表示是否默认选择
function MarketSellDlg:selectCardPanel(sender, eventType, isDef)
    if not sender.cardInfo then return end

    if not MarketMgr:checkChangeCardSellCondition(sender.cardInfo, self:tradeType()) then return end

    local cards = StoreMgr:getChangeCardByName(sender.cardInfo.name, true)
    if #cards == 0 and not isDef then
        gf:ShowSmallTips(CHS[4300008])
        return
    end

    if #cards == 0 and isDef then
        -- 如果是默认选择，并且可交易数为0，则不选择
        self.selectCardName = nil
    else
        self:addPetItemSelectImage(sender)
        self.selectCardName = sender.cardInfo.name
    end
    if not isDef then
        MarketMgr:openSellItemDlg(cards[1], 3, self:tradeType())
    end
end

function MarketSellDlg:selectCardPanelByName(cardName)
    local list = self:getControl("CardListView")
    local items = list:getItems()
    local ind
    for i = 1, #items do
        local panel = items[i]
        if panel.cardInfo and panel.cardInfo.name == cardName then
            self:selectCardPanel(panel)
            ind = i
        end
    end

    if ind then
        performWithDelay(list, function ()
            self:setListInnerPosByIndex("CardListView", ind)
        end, 0)
    end

end


function MarketSellDlg:createPetItem(pet)
    local pet_status = pet:queryInt("pet_status")
    local petPanel = self.petItemCtrl:clone()
    local petId = pet:queryBasicInt("id")
    petPanel:setTag(petId)

    local petImage = self:getControl("GuardImage", Const.UIImage, petPanel)
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:loadTexture(path)
    self:setItemImageSize("GuardImage", petPanel)

    local iscannotSell = not gf:isExpensive(pet, true) and MarketMgr:isGoldtype(self:tradeType()) -- 珍宝非贵重物品不能摆摊
    if PetMgr:isLimitedPet(pet) or iscannotSell then
        gf:grayImageView(petImage)
        gf:grayImageView(self:getControl("BKImage", nil, petPanel))
        self:getControl("NameLabel", nil, petPanel):setColor(COLOR3.GRAY)
        self:getControl("LevelLabel", nil, petPanel):setColor(COLOR3.GRAY)
        self:getControl("PolarValueLabel", nil, petPanel):setColor(COLOR3.GRAY)
    end

	local petNameLabel = self:getControl("NameLabel", Const.UILabel, petPanel)
    petNameLabel:setString(gf:getPetName(pet.basic))

    local petLevelValueLabel = self:getControl("LevelLabel", Const.UILabel, petPanel)
    petLevelValueLabel:setString("LV."..pet:queryBasic("level"))

    -- 设置宠物相性
    local polarName = gf:getPolar(pet:queryBasicInt("polar"))
    local polarValueLabel = self:getControl("PolarValueLabel", Const.UILabel, petPanel)
    polarValueLabel:setText(polarName)

    local statusImg = self:getControl("StatusImage", Const.UIImage, petPanel)
    statusImg:setVisible(false)

    if pet_status == 1 then
        -- 参战
        statusImg:setVisible(true)
        petNameLabel:setColor(COLOR3.GREEN)
        petLevelValueLabel:setColor(COLOR3.GREEN)
        polarValueLabel:setColor(COLOR3.GREEN)
        statusImg:loadTexture(ResMgr.ui.canzhan_flag)

    elseif pet_status == 2 then
        -- 掠阵
        petNameLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        polarValueLabel:setColor(COLOR3.YELLOW)
        statusImg:loadTexture(ResMgr.ui.luezhen_flag)
        statusImg:setVisible(true)
    elseif PetMgr:isRidePet(pet:getId()) then
        -- 骑乘
        statusImg:loadTexture(ResMgr.ui.ride_flag)
        statusImg:setVisible(true)
    end

    local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not MarketMgr:checkPetSellCondition(pet, self:tradeType()) then return end

            if PetMgr:isLimitedPet(pet) then
                gf:ShowSmallTips(CHS[6400015])
                return
            end

            if MarketMgr:isGoldtype(self:tradeType()) then
              --  local dlg = DlgMgr:openDlg("MarketGoldItemInfoDlg")
              --  dlg:setData(pet)

                MarketMgr:openZhenbaoSellDlg(pet)
            else
                local dlg = DlgMgr:openDlg("MarketSellPetDlg")
                dlg:setTradeType(self:tradeType())
                dlg:setPetInfo(pet, 3, 0, true)
            end

            self:addPetItemSelectImage(petPanel)
            self.selectId = pet:getId()
        end
    end

    petPanel:addTouchEventListener(selectPet)

    return petPanel
end

-- 更新整体界面数据
function MarketSellDlg:updateWholeViewData()
    self:updateCashView()

    -- 设置左上角的摊位信息
    local sellItemInfo = MarketMgr:getMySellItemListInfo(self:tradeType())
    local sellNum = sellItemInfo["stallNum"]
    local allNum = sellItemInfo["stallTotalNum"]

    self:setLabelText("MyBoothLabel", string.format(CHS[5000132], sellNum, allNum))

    -- 设置右下角摆摊帐户
    local cashText, fontColor = gf:getArtFontMoneyDesc(sellItemInfo["sellCash"] or 0)
    local panel = self:getControl("MarketMoneyPanel")
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, panel)
end

-- 设置金钱
function MarketSellDlg:updateCashView()
    -- 设置角色身上的金钱
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    local panel = self:getControl("MoneyPanel")
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, panel)
end

function MarketSellDlg:onDealRecordButton(sender, eventType)
    DlgMgr:openDlg("MarketRecordDlg")
end

function MarketSellDlg:onGetMoneyButton(sender, eventType)
    MarketMgr:getMySellCash(self:tradeType())
end

function MarketSellDlg:onMarketBuyButton(sender, enventType)
    DlgMgr:openDlg("MarketBuyDlg")

    DlgMgr:closeDlg(self.name)
end

function MarketSellDlg:onBuyCoinButton(sender, eventType)
    gf:showBuyCash()
end


function MarketSellDlg:MSG_STALL_MINE(data)
    --self:updateLeftViewData()
    self:initSallList()
    self:updateWholeViewData()
end

function MarketSellDlg:MSG_STORE(data)
    self:updateCardListData()
end


function MarketSellDlg:MSG_INVENTORY(data)
    self:initItemList()
    self:updateItemData()
end

function MarketSellDlg:MSG_UPDATE(data)
    self:updateCashView()
    self:updateMoneyListData()
end

function MarketSellDlg:MSG_INSIDER_INFO(data)
    MarketMgr:requestRefreshMySell(self:tradeType())
end

function MarketSellDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    dlg:setRuleType("boothRule")
end

function MarketSellDlg:MSG_UPDATE_PETS()
    self:initPetList()
    self:updatePetListData()
end

function MarketSellDlg:MSG_SET_OWNER()
    self:initPetList()
    self:updatePetListData()
end

function MarketSellDlg:tradeType()
    return MarketMgr.TradeType.marketType
end

return MarketSellDlg
