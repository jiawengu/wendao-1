-- HomeChooseItemDlg.lua
-- Created by 
-- 

local HomeChooseItemDlg = Singleton("HomeChooseItemDlg", Dialog)

-- 鱼类直接排好序
local FISH_INFO = {
    CHS[5400185], CHS[5400186], CHS[5400187], CHS[5400188], CHS[5400189], CHS[5400190],
    CHS[5400191], CHS[5400196], CHS[5400192], CHS[5400193], CHS[5400194], CHS[5400195]
}

-- 种植分多类，需重新排序   type 1(蔬果)  2（药材）  3树木
local PLANT_INFO = {
    {name = CHS[4100739], level = 1, type = 1},    -- 大白菜
    {name = CHS[4100740], level = 1, type = 1},
    {name = CHS[4100741], level = 2, type = 1},
    {name = CHS[4100742], level = 2, type = 1},
    {name = CHS[4100743], level = 3, type = 1},
    {name = CHS[4100744], level = 3, type = 1},
    {name = CHS[4100745], level = 4, type = 1},
    {name = CHS[4100746], level = 4, type = 1},
    {name = CHS[4100747], level = 5, type = 1},
    {name = CHS[4100748], level = 5, type = 1},
    {name = CHS[4100749], level = 4, type = 2},
    {name = CHS[4100750], level = 5, type = 2},
    {name = CHS[4100751], level = 2, type = 3},
    {name = CHS[4100752], level = 3, type = 3},
    {name = CHS[4100753], level = 4, type = 3},
    {name = CHS[4100754], level = 5, type = 3},
}

local NEED_MATERIAL     = 1     -- 所需材料
local CHOOSE_GIFT       = 2     -- 选择谢礼

local BAG_COW   = 4                     -- 背包界面列
local MAGIN     = 8

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2
local shopLimit = 10

function HomeChooseItemDlg:init()

    self:blindPress("PlusButton")
    self:blindPress("MinusButton")
    
    -- 绑定数字键盘
    self:bindNumInput("NumPanel", nil, function ()
        if not self.selectItem then return true end
    end)
    
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("GiveButton", self.onGiveButton)
    
    table.sort(PLANT_INFO, function(l, r)
        if l.level < r.level then return true end
        if l.level > r.level then return false end
        if l.type < r.type then return true end
        if l.type > r.type then return false end
    end)

    self.dlgType = nil
    self.selectItem = nil
    self.objIndex = nil

    self.unitItemPanel = self:retainCtrl("ItemPanel")
    self.unitItemSelectImage = self:retainCtrl("ChosenEffectImage", self.unitItemPanel)
end

-- 数字键盘插入数字
function HomeChooseItemDlg:insertNumber(num)
    self.selectNum = num
    if self.selectNum <= 0 then
        self.selectNum = 0
    end
    
    if self.dlgType == CHOOSE_GIFT then
        if self.selectNum > math.min(10, InventoryMgr:getAmountByName(self.selectItem.name)) then
            if math.min(10, InventoryMgr:getAmountByName(self.selectItem.name)) == 10 then
                gf:ShowSmallTips(CHS[4100755])  
            else
                gf:ShowSmallTips(CHS[4100756])
            end

            self.selectNum = math.min(10, InventoryMgr:getAmountByName(self.selectItem.name))      
        end
    end

    if self.dlgType == NEED_MATERIAL then 
        if self.selectNum > 10 then
            gf:ShowSmallTips(CHS[4100757])   
            self.selectNum = 10 
            count = self.selectNum
        end
    end
    self:updateCount()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.selectNum)
    end
end

function HomeChooseItemDlg:blindPress(name)
    local widget = self:getControl(name)

    local function updataCount()
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "PlusButton" then
                self:onPlusButton()
            elseif self.clickBtn == "MinusButton" then
                self:onMinusButton()
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , updataCount, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function HomeChooseItemDlg:setData(dlgType, objIndex)
    self.dlgType = dlgType
    self.objIndex = objIndex
    
    self:setCtrlVisible("ConfirmButton", dlgType == NEED_MATERIAL)
    self:setCtrlVisible("GiveButton", dlgType ~= NEED_MATERIAL)
    if dlgType == NEED_MATERIAL then
        self:setLabelText("TitleLabel", CHS[4100758])     -- 标题
        
        self:setLabelText("TextLabel1", CHS[4100759])     
    elseif dlgType == CHOOSE_GIFT then
        self:setLabelText("TitleLabel", CHS[4100760])     -- 标题
        
        self:setLabelText("TextLabel1", CHS[4100761])     
    end

    local  items = self:getMeetItems(dlgType)
    local listCtrl = self:getControl("BagItemsScrollView")
    listCtrl:removeAllChildren()
    listCtrl:setTouchEnabled(true)
    local count = #items

    self:setCtrlVisible("NoticePanel", (count == 0), "BagItemListPanel")

    local row = math.ceil(count / BAG_COW)
    local contentSize = self.unitItemPanel:getContentSize()
    local innerContainner = listCtrl:getInnerContainer()
    local listContentSize = listCtrl:getContentSize()
    local innerContentSize = {width = math.max(BAG_COW * contentSize.width, listContentSize.width), height = math.max(row * (MAGIN + contentSize.height), listContentSize.height)}
    local offY = math.max(listContentSize.height - row * (MAGIN + contentSize.height), 0)
    listCtrl:setInnerContainerSize(innerContentSize)
    for i = 1, #items do
        local item = self.unitItemPanel:clone()
        local newY = math.floor((i - 1) / BAG_COW)
        local newY = row - newY - 1
        local newX = (i - 1) % BAG_COW
        item:setPosition(MAGIN + newX * (contentSize.width + MAGIN), offY + MAGIN + newY * (contentSize.height + MAGIN))
        listCtrl:addChild(item)

        local imageCtrl = self:getControl("IconImage", nil, item)

        item.item = items[i]
        self:bindTouchEndEventListener(item, function(self, sender, eventType)
            self:onSelectItem(item)
        end)

        local iconPanel = self:getControl("IconImagePanel", Const.UIPanel, item)
        if nil == items[i].amount then
            self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_BOTTOM)
        else
            self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, items[i].amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        end

        if nil == items[i].level then
            self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
        else
            self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, items[i].level, false, LOCATE_POSITION.LEFT_TOP, 21)
        end
    
        self:setImage("IconImage", ResMgr:getIconPathByName(items[i].name), item)
        self:setItemImageSize("IconImage", item)  

        if not self.selectItem then
            self:onSelectItem(item)
        end
    end
end

-- 点击某个
function HomeChooseItemDlg:onSelectItem(sender, eventType)
    self.selectItem = sender.item

    -- 增加光效
    self.unitItemSelectImage:removeFromParent()
    sender:addChild(self.unitItemSelectImage)

    self:setItemInfo(self.selectItem)
end

function HomeChooseItemDlg:setItemInfo(item)
    local attPanel = self:getControl("AttributePanel")
    local itemPanel = self:getControl("ItemPanel", nil, attPanel)
    local itemMainPanel = self:getControl("MainPanel", nil, itemPanel)

    -- icon
    self:setImage("ItemImage", ResMgr:getIconPathByName(item.name), itemMainPanel)
    self:setItemImageSize("ItemImage", itemMainPanel)

    -- 名称
    self:setLabelText("NameLabel", item.name, itemMainPanel)

    -- level
    local levelPanel = self:getControl("JeweleyLevelPanel", nil, itemMainPanel)
    if item.level then
        self:removeNumImgForPanel(levelPanel, LOCATE_POSITION.LEFT_TOP)
    else
        self:setNumImgForPanel(levelPanel, ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 拥有
    self:setLabelText("NumLabel", string.format(CHS[4100762], InventoryMgr:getAmountByName(item.name)), itemMainPanel)

    -- 描述
    local descriptStr = InventoryMgr:getDescript(item.name)
    self:setDescriptAutoSize(descriptStr, "DescPanel", COLOR3.TEXT_DEFAULT, itemMainPanel)  

    self.selectNum = 1
    self:updateCount()

    itemMainPanel:requestDoLayout()
end

function HomeChooseItemDlg:updateCount()
    self:setLabelText("NumLabel", self.selectNum, "NumPanel")
end

function HomeChooseItemDlg:setDescriptAutoSize(descript, ctrlName, defaultColor, root, notDoLayout)
    local panel = self:getControl(ctrlName, nil, root)
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b) end
    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((panel:getContentSize().width - textW) * 0.5,textH)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    panel:setContentSize(panel:getContentSize().width, textH)
    if not notDoLayout then
        panel:requestDoLayout()
    end
end

-- 获取满足的
function HomeChooseItemDlg:getMeetItems(dlgType)
    local ret = {}
    if dlgType == NEED_MATERIAL then
        -- 所需，显示全部
        -- 鱼类
        for _, name in pairs(FISH_INFO) do
            local data = {name = name, level = _, amount = InventoryMgr:getAmountByName(name)}
            table.insert(ret, data)
        end

        -- 种植
        for _, plant in pairs(PLANT_INFO) do
            local data = {name = plant.name, level = plant.level, amount = InventoryMgr:getAmountByName(plant.name)}
            table.insert(ret, data)
        end
    else
        -- 选择谢礼，已有
        -- 鱼类
        for _, name in pairs(FISH_INFO) do
            local amount = InventoryMgr:getUnlimtedAmountByName(name)
            if amount > 0 then
                local data = {name = name, level = _, amount = amount}
                table.insert(ret, data)
            end
        end

        -- 种植
        for _, plant in pairs(PLANT_INFO) do
            local amount = InventoryMgr:getUnlimtedAmountByName(plant.name)
            if amount > 0 then
                local data = {name = plant.name, level = plant.level, amount = amount}
                table.insert(ret, data)
            end
        end
    end

    return ret
end

function HomeChooseItemDlg:onMinusButton(sender, eventType)
    if not self.selectItem then return end
    self.selectNum = self.selectNum - 1
    if self.selectNum < 1 then
        self.selectNum = 1     

        if self.dlgType == NEED_MATERIAL then
            gf:ShowSmallTips(CHS[4100763])          -- "单项求助最小数量为#R1#n。",
        elseif self.dlgType == CHOOSE_GIFT then
            gf:ShowSmallTips(CHS[4100764])  -- 谢礼单项最小数量为#R1#n。
        end
    end   
    
    self:updateCount()
end

function HomeChooseItemDlg:onPlusButton(sender, eventType)
    if not self.selectItem then return end
    self.selectNum = self.selectNum + 1
    
    if self.dlgType == CHOOSE_GIFT then
        if self.selectNum > math.min(10, InventoryMgr:getAmountByName(self.selectItem.name)) then
            if self.selectNum > 10 then
                gf:ShowSmallTips(CHS[4100755])  
            else
                gf:ShowSmallTips(CHS[4100756])
            end
            
            self.selectNum = math.min(10, InventoryMgr:getAmountByName(self.selectItem.name))
        end
    end
    
    if self.dlgType == NEED_MATERIAL then 
        if self.selectNum > 10 then
            gf:ShowSmallTips(CHS[4100757])   
            self.selectNum = 10 
        end
    end
    
    self:updateCount()
end

function HomeChooseItemDlg:onConfirmButton(sender, eventType) 
    if not self.selectItem then return end
    
    if self.selectNum < 1 then
        gf:ShowSmallTips(CHS[4100763])
        return 
    end
    
    HomeMgr:submitNeedMaterial(self.objIndex, self.selectItem.name, self.selectNum)
    self:onCloseButton()
end

function HomeChooseItemDlg:onGiveButton(sender, eventType)    
    if not self.selectItem then return end
    
    if self.selectNum < 1 then
        gf:ShowSmallTips(CHS[4100764])
        return 
    end

    
    local item = InventoryMgr:getFirstNotBindItemByName(self.selectItem.name)
    HomeMgr:submitGift(self.objIndex, item.pos, self.selectNum)
    self:onCloseButton()
end

return HomeChooseItemDlg
