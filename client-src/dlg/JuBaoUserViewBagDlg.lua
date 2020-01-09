-- JuBaoUserViewBagDlg.lua
-- Created by songcw Dec/16/2016
-- 聚宝斋背包、仓库、卡套信息界面

local JuBaoUserViewBagDlg = Singleton("JuBaoUserViewBagDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local DISPLAY_CHECKBOX = {
    "BagButton",          -- 背包
    "StorageButton",      -- 仓库
    "HomeButton",         -- 居所
    "FurnitureButton",    -- 家具
    "CardButton",         -- 卡套
}

-- 背包、仓库、卡套checkBox 对应显示的panel
local CHECKBOX_PANEL = {
    ["BagButton"]     = "BagPanel",
    ["StorageButton"] = "StoragePanel",
    ["CardButton"]    = "CardPanel",
    ["HomeButton"]    = "HomePanel",
    ["FurnitureButton"] = "FurniturePanel",
}

local LINE_ITEMS_COUNT = 9              -- 每行个数
local MAGIN = 8
local FONT_HEIGHT = 25

function JuBaoUserViewBagDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("BuyButton", self.onBuyButton, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton, "DesignatedSellPanel")
    
    -- 初始化将要clone的控件
    self:initRetainPanels()
    
    -- 设置变身卡的inner
    
    self.unitItemPanelSize = self.unitItemPanelSize or self.unitItemPanel:getContentSize()
    self.cardInnerSize = self.cardInnerSize or self:getControl("CardScrollView"):getContentSize()
    self.scrollViewSize = self.scrollViewSize or self:getControl("BagScrollView"):getContentSize()
    
    -- 单选框初始化
    self:initCheckBox()
    
    self.goods_gid = DlgMgr:sendMsg("JuBaoUserViewTabDlg", "getGid")

    -- 从管理器中取数据设置
    self:setDataFormMgr()
    
    -- 价格信息
    TradingMgr:setPriceInfo(self)
    
    self:hookMsg("MSG_TRADING_SNAPSHOT")
end

function JuBaoUserViewBagDlg:initCardScrollView()
    local layer = self:getControl("InfoPanel", nil, "CardPanel")
    layer:removeFromParent()
    local scrollView = self:getControl("CardScrollView")
    scrollView:setDirection(ccui.ScrollViewDir.vertical)
    scrollView:addChild(layer)
    scrollView:setInnerContainerSize(layer:getContentSize())
end

function JuBaoUserViewBagDlg:initRetainPanels()
    -- 背包、仓库物品单元Unit
    self.unitItemPanel = self:toCloneCtrl("UnitItemPanel")

    -- 背包、仓库物品单元Unit 选中效果
    self.unitItemSelectImage = self:toCloneCtrl("ChosenEffectImage", self.unitItemPanel)

    -- 变身卡
    self.unitCardPanel = self:toCloneCtrl("CardInfoPanel")

    -- 变身卡 选中效果
    self.unitCardSelectImage = self:toCloneCtrl("ChosenImage", self.unitCardPanel)
end

function JuBaoUserViewBagDlg:cleanup()
    self:releaseCloneCtrl("unitItemPanel")
    self:releaseCloneCtrl("unitItemSelectImage")
    
    self:releaseCloneCtrl("unitCardPanel")
    self:releaseCloneCtrl("unitCardSelectImage")
end

-- 设置数据
function JuBaoUserViewBagDlg:setDataFormMgr()
    -- 没有设置商品gid，异常情况
    if not self.goods_gid then return end

    local bagData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_BAG)
    if bagData then
        self:setBagData(bagData, self.goods_gid)
    else
        TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_BAG)            
    end        

    local storeData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_STORE)
    if storeData then
        self:setStoreData(storeData, self.goods_gid)
    else
        TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_STORE)            
    end

    local cardData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CARD_STORE)
    if cardData then
        self:setCardData(cardData, self.goods_gid)
    else
        TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CARD_STORE)            
    end
    
    local homeData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_HOME_STORE)
    if homeData then
        self:setHomeData(homeData, self.goods_gid)
    else
        TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_HOME_STORE)            
    end
    
    -- 家具
    local furnData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FURNITURE_STORE)
    if furnData then
        self:setfurnData(furnData, self.goods_gid)
    else
        TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FURNITURE_STORE)            
    end
end

-- 道具点击增加光效
function JuBaoUserViewBagDlg:addItemSelectImage(sender)
    self.unitItemSelectImage:removeFromParent()
    sender:addChild(self.unitItemSelectImage)
end


-- 变身卡点击增加光效
function JuBaoUserViewBagDlg:addCardSelectImage(sender)
    self.unitCardSelectImage:removeFromParent()
    sender:addChild(self.unitCardSelectImage)
end

function JuBaoUserViewBagDlg:showCardInfo(info)
    local cardName = info.name
    local cardInfo = InventoryMgr:getCardInfoByName(cardName)    
    local cardInfoPanel = self:getControl("CardAttribInfoPanel")
    
    -- 名字、等级，icon、相性
    self:setLabelText("CardNameLabel", cardName, cardInfoPanel)
    self:setLabelText("LevelLabel", CHS[4100085] .. cardInfo.card_level, cardInfoPanel)
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(cardName)), cardInfoPanel)
    self:setItemImageSize("ItemImage", cardInfoPanel)
    self:setImagePlist("PolarImage", ResMgr:getPolarImagePath(gf:getPolar(cardInfo.polar)), cardInfoPanel)
    
    -- 描述
    local desStr = InventoryMgr:getDescript(cardName)
    self:setLabelText("DescLabel", desStr, cardInfoPanel)

    -- 变身卡属性
    local totalInfo = InventoryMgr:getChangeCardEff(cardName)
    
    -- 持续时间
    local keepTime = {str = string.format(CHS[4100086], InventoryMgr:getCardChangeTime(cardInfo.card_type)), color = COLOR3.EQUIP_NORMAL}
    table.insert(totalInfo, keepTime)
    
    -- 设置属性
    local hasCount = 0
    for i = 1, 12 do
        local attInfo = totalInfo[i]
        if attInfo then
            self:setLabelText("BaseAttributeLabel" .. i, attInfo.str, nil, attInfo.color)
            hasCount = i
        else
            self:setLabelText("BaseAttributeLabel" .. i, "")
        end
    end

    -- 设置scroll滚动区域， 7个刚刚好，大于7个可滚动,字体高度 FONT_HEIGHT 25
    local addHeight = math.max(hasCount - 7, 0) * FONT_HEIGHT
    local scrollView = self:getControl("CardScrollView")

    local innerLayer = self:getControl("CardAttribInfoPanel")    
    local size = {width = self.cardInnerSize.width, height = self.cardInnerSize.height + addHeight}
    innerLayer:setContentSize(size)
    innerLayer:requestDoLayout()
    
    scrollView:setInnerContainerSize(size)
    scrollView:getInnerContainer():setPositionY(self.cardInnerSize.height - size.height)
    

    scrollView:requestDoLayout()
end

function JuBaoUserViewBagDlg:onChosenCard(sender)
    -- 点击光效
    self:addCardSelectImage(sender)
    
    self:showCardInfo(sender.cardInfo)
end

-- 设置卡套
function JuBaoUserViewBagDlg:setCardData(data, gid)
    if gid ~= self.goods_gid then return end
    local listView = self:resetListView("ListView")

    local cardList = StoreMgr:getCardsInCardBagDisplayAmount(data)
    local count = #cardList
    for i = 1, count do
        local panel = self.unitCardPanel:clone()        
        -- icon
        self:setImage("GoodsImage",InventoryMgr:getIconFileByName(cardList[i].name), panel)
        self:setItemImageSize("GoodsImage", panel)
        -- 名称
        self:setLabelText("NameLabel", cardList[i].name, panel)
        -- 数量
        self:setLabelText("TypeLabel", CHS[4100091] .. cardList[i].count, panel)
        -- 相性
        self:setImagePlist("PolarImage", ResMgr:getPolarImagePath(gf:getPolar(cardList[i].polar)), panel)
        
        panel.cardInfo = cardList[i]
        
        self:bindTouchEndEventListener(panel, function ()
            self:onChosenCard(panel)
        end)
        
        listView:pushBackCustomItem(panel)
    end
    
    self:setCtrlVisible("NoticePanel", count == 0, "CardPanel")
    listView:setVisible(count ~= 0)
    
    listView:requestRefreshView()
    
    -- 设置默认选择
    local item = listView:getItem(0)
    if item then
        self:onChosenCard(item)
    end
end

-- 设置仓库
function JuBaoUserViewBagDlg:setHomeData(data, gid)
    if gid ~= self.goods_gid then return end
    local scrollView = self:getControl("StoreScrollView", nil, "HomePanel")
    scrollView:removeAllChildren()
    self:setItems(data, scrollView)    
    
    if not next(data) then
        local userData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
        if userData and not string.isNilOrEmpty(userData.house_id) then
            self:setLabelText("InfoLabel1", CHS[5400228], "HomePanel")
        else
            self:setLabelText("InfoLabel1", CHS[5400218], "HomePanel")
        end
        
        self:setCtrlVisible("NoticePanel", true, "HomePanel")
    else
        self:setCtrlVisible("NoticePanel", false, "HomePanel")
    end
end


-- 设置仓库
function JuBaoUserViewBagDlg:setStoreData(data, gid)
    if gid ~= self.goods_gid then return end
    local scrollView = self:getControl("StoreScrollView", nil, "StoragePanel")
    scrollView:removeAllChildren()
    self:setItems(data, scrollView)
    self:setCtrlVisible("NoticePanel", not next(data), "StoragePanel")
end

-- 设置背包
function JuBaoUserViewBagDlg:setBagData(data, gid)
    if gid ~= self.goods_gid then return end
    local scrollView = self:getControl("BagScrollView")
    scrollView:removeAllChildren()
    self:setItems(data, scrollView)
    self:setCtrlVisible("NoticePanel", not next(data), "BagPanel")
end

-- 设置家具
function JuBaoUserViewBagDlg:setfurnData(data, gid)
    if gid ~= self.goods_gid then return end
    local scrollView = self:getControl("StoreScrollView", nil, "FurniturePanel")
    scrollView:removeAllChildren()
    self:setItems(data, scrollView)
    self:setCtrlVisible("NoticePanel", not next(data), "FurniturePanel")
    self:setCtrlVisible("NoticePanel_2", false, "FurniturePanel")
    local ctrl = self:getControl("NoticePanel_1", nil, "FurniturePanel")
    ctrl:setVisible(false)
    if not next(data) then
        local userData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
        if userData and userData["snapshot_furniture_store_count"] and userData["snapshot_furniture_store_count"] > 0 then
            -- 有家具但未请求到的提示
            self:setCtrlVisible("NoticePanel_2", true, "FurniturePanel")
        elseif userData and not string.isNilOrEmpty(userData.house_id) then
            -- 无家具提示
            self:setLabelText("InfoLabel1", CHS[5400271], ctrl)
            ctrl:setVisible(true)
        else
            -- 无居所提示
            self:setLabelText("InfoLabel1", CHS[5400218], ctrl)
            ctrl:setVisible(true)
        end
    end
end

-- 根据索引获取position
function JuBaoUserViewBagDlg:getPositionByIndex(index, size)
    local xNum = index % LINE_ITEMS_COUNT 
    if xNum == 0 then xNum = LINE_ITEMS_COUNT end
    
    local yNum = math.floor((index - 1) / LINE_ITEMS_COUNT) + 1

    return MAGIN + (xNum - 1) * (self.unitItemPanelSize.width + MAGIN), (size.height - self.unitItemPanelSize.height) - MAGIN - (yNum - 1) * (self.unitItemPanelSize.height + MAGIN)
   -- return 0, 
end

-- 设置道具
function JuBaoUserViewBagDlg:setItems(data, scrollView)    
    local contentLayer = ccui.Layout:create()
    local sum = 0
    for pos, itemInfo in pairs(data) do
        sum = sum + 1
    end  
    
    local yNum = math.floor((sum - 1) / LINE_ITEMS_COUNT) + 1
    
    local width = self.scrollViewSize.width
    local height = math.max(self.scrollViewSize.height, yNum * self.unitItemPanel:getContentSize().height + (yNum + 1) * MAGIN)
    
    local size = {width = width, height = height}
    contentLayer:setContentSize(size)
    
    local index = 0
    for pos, itemInfo in pairs(data) do
        index = index + 1
        local cell = self.unitItemPanel:clone()
        self:setUnitItems(itemInfo, cell, index, contentLayer:getContentSize())
        contentLayer:addChild(cell)
    end        
    
    scrollView:setDirection(ccui.ScrollViewDir.vertical)
    scrollView:addChild(contentLayer)
    scrollView:setInnerContainerSize(contentLayer:getContentSize())
end

-- 设置单个物品
function JuBaoUserViewBagDlg:setUnitItems(data, cell, index, size)

    cell:setPosition(self:getPositionByIndex(index, size))
    
    -- 图标
    self:setImage("IconImage", InventoryMgr:getIconPathByItem(data), cell)
    self:setItemImageSize("IconImage", cell)
    
    local panel = self:getControl("IconImagePanel", nil, cell)
    local imageCtrl = self:getControl("IconImage", nil, cell)
    
    if data.item_polar then                    
        InventoryMgr:addArtifactPolarImage(imageCtrl, data.item_polar)
    end  
    
    -- 需求等级
    if data.req_level and data.req_level > 0 and data.item_type == ITEM_TYPE.EQUIPMENT then
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.req_level,
            false, LOCATE_POSITION.LEFT_TOP, 21, cell)  
    end
    
    -- 等级
    if data.level and data.level > 0 then
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level,
            false, LOCATE_POSITION.LEFT_TOP, 21, cell)  
    end  
    
    -- 限时
    if data and InventoryMgr:isTimeLimitedItem(data) then
        InventoryMgr:addLogoTimeLimit(imageCtrl)
    end

    -- 融合标识
    if data and InventoryMgr:isFuseItem(data.name) then
        InventoryMgr:addLogoFuse(imageCtrl)
    end
    
    -- 限制交易
    if data and InventoryMgr:isLimitedItem(data) then
        InventoryMgr:addLogoBinding(imageCtrl)
    end

    -- 未鉴定装备处理
    if InventoryMgr:isUnidentifiedByItem(data) then
        InventoryMgr:addLogoUnidentified(imageCtrl)
    end
    
    -- 变身卡相性
    if data and data.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        InventoryMgr:addPolarChangeCard(imageCtrl, data.name)
    end
    
    -- 数量
    if data.amount and data.amount > 1 then
        self:setNumImgForPanel(imageCtrl, ART_FONT_COLOR.NORMAL_TEXT, data.amount,
            false, LOCATE_POSITION.RIGHT_BOTTOM, 21, cell) 
    end
    
    cell.data = data
    
    -- 事件监听
    self:bindTouchEndEventListener(cell, self.onClickItems)
end

-- 点击某个商品
function JuBaoUserViewBagDlg:onClickItems(sender, eventType)
    if not sender.data then return end
    
    self:addItemSelectImage(sender)
    
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showOnlyFloatCardDlg(sender.data, rect)
end

-- 单选框初始化
function JuBaoUserViewBagDlg:initCheckBox()
    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItemsByButton(self, DISPLAY_CHECKBOX, self.onCheckBox)    
    self:onCheckBox(self:getControl(DISPLAY_CHECKBOX[1]))
end

-- 背包、仓库、卡套 checkBox点击事件
function JuBaoUserViewBagDlg:onCheckBox(sender, eventType)
    for _, panelName in pairs(CHECKBOX_PANEL) do
        self:setCtrlVisible(panelName, false)
    end
    
    self:setCtrlVisible(CHECKBOX_PANEL[sender:getName()], true)
end

function JuBaoUserViewBagDlg:onNoteButton(sender, eventType)    
    gf:showTipInfo(CHS[4100945], sender)
end


function JuBaoUserViewBagDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end
    TradingMgr:tryBuyItem(self.goods_gid, self.name)
end

function JuBaoUserViewBagDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

-- 收到数据
function JuBaoUserViewBagDlg:MSG_TRADING_SNAPSHOT(data)
    if not self.goods_gid or data.goods_gid ~= self.goods_gid then return end
    if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_BAG then
        local bagData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_BAG)
        if bagData then
            self:setBagData(bagData, self.goods_gid)        
        end   
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_STORE then
        local storeData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_STORE)
        if storeData then
            self:setStoreData(storeData, self.goods_gid)  
        end
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_CARD_STORE then
        local cardData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CARD_STORE)
        if cardData then
            self:setCardData(cardData, self.goods_gid)        
        end
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_HOME_STORE then
        local cardData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_HOME_STORE)
        if cardData then
            self:setHomeData(cardData, self.goods_gid)        
        end
    elseif data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_FURNITURE_STORE then
        local furnData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FURNITURE_STORE)
        if furnData then
            self:setfurnData(furnData, self.goods_gid)       
        end
    end
end

return JuBaoUserViewBagDlg
