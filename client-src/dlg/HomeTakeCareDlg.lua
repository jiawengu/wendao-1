-- HomeTakeCareDlg.lua
-- Created by yangym Jun/19/2017
-- 居所打理界面

local HomeTakeCareDlg = Singleton("HomeTakeCareDlg", Dialog)

local CHECKBOX_PANEL = {
    ["HomePanelCheckBox"] = "HomePanel",
    ["RepairPanelCheckBox"] = "RepairPanel",
}

local FURNITURE_TYPE = {
    CHS[4100075], -- 全部
    CHS[7002320], -- 房屋-床柜
    CHS[7002321], -- 房屋-功能
    CHS[2000294], -- 前庭-功能
}

local DIFF_HOME_ICON = {
    ResMgr.ui.house_xiaoshe,
    ResMgr.ui.house_yazhu,  
    ResMgr.ui.house_haozhai,
}

local MIN_CLEAN = 20

local RadioGroup = require("ctrl/RadioGroup")

function HomeTakeCareDlg:init()
    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("CleanButton", self.onCleanButton)
    self:bindListener("RepairButton", self.onRepairButton)

    self.bigPanel = self:getControl("BigPanel")
    self.bigPanel:retain()
    self.bigPanel:removeFromParent()

    self.itemPanel = self:getControl("ItemPanel")
    self.itemPanel:retain()
    self.itemPanel:removeFromParent()

    self:setCtrlVisible("HomePanel", false)
    self:setCtrlVisible("RepairPanel", false)

    -- 复选框初始化
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"HomePanelCheckBox", "RepairPanelCheckBox"}, self.onCheckBox)
    self.radioGroup:selectRadio(1) -- 默认选择第一项

    self:hookMsg("MSG_HOUSE_DATA")
    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_HOUSE_FUNCTION_FURNITURE_LIST")

    -- 初始化金钱显示
    local costCash, costColor = gf:getArtFontMoneyDesc(0)
    self:setNumImgForPanel("NeedCashPanel", costColor, costCash, false, LOCATE_POSITION.MID, 21, "NeedPanel")

    local money = Me:queryInt("cash")
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("HaveCashPanel", color, cash, false, LOCATE_POSITION.MID, 21, "HavePanel")

    HomeMgr:requestData()
    HomeMgr:requestSpecialFurnitures()
    self:setHomeInfo()
end

function HomeTakeCareDlg:onCheckBox(sender, eventType)
    local ctrlName = sender:getName()
    for k, v in pairs(CHECKBOX_PANEL) do
        local isChosen = (k == ctrlName)
        local panel = self:getControl(k)
        self:setCtrlVisible(v, isChosen)

        -- 标签页
        self:setCtrlVisible("ChosenLabel_1", isChosen, panel)
        self:setCtrlVisible("ChosenLabel_2", isChosen, panel)
        self:setCtrlVisible("UnChosenLabel_1", not isChosen, panel)
        self:setCtrlVisible("UnChosenLabel_2", not isChosen, panel)

        -- 标题
        self:setCtrlVisible("Label_1", ctrlName == "HomePanelCheckBox")
        self:setCtrlVisible("Label_2", ctrlName == "RepairPanelCheckBox")
    end
end

function HomeTakeCareDlg:setHomeInfo()
    local data = {
         type = HomeMgr:getHomeType(),
         nowClean = HomeMgr:getClean(),
         maxClean = HomeMgr:getMaxClean(),
         nowComfort = HomeMgr:getComfort(),
         maxComfort = HomeMgr:getMaxComfort(),
         cleanCostTime = HomeMgr:getCleanCostTime()
    }

    self.data = data

    -- 居所类型
    self:setLabelText("HomeTypeLabel", HomeMgr:getMyHomePrefix() .. HomeMgr:getHomeTypeCHS(data.type))

    -- 显示图片
    self:setImage("HomeTyoeImage", DIFF_HOME_ICON[data.type])

    -- 舒适度
    self:setComfortProgress(data)

    -- 清洁度
    self:setCleanProgress(data)

    -- 清洁度说明
    self:setCleanDesc(data)
end

-- 清洁度说明
function HomeTakeCareDlg:setCleanDesc(data)
    local str
    if 30 == data.cleanCostTime then
        str = tostring(data.cleanCostTime)
    else
        str = string.format("#B%d#n", data.cleanCostTime)
    end

    self:setColorText(string.format(CHS[2000424], str), "CleanTextPanel", "HomePanel", nil, 1, cc.c3b(0xA6, 0x63, 0x29), 15)
end

function HomeTakeCareDlg:setComfortProgress(data)
    local nowComfort = data.nowComfort
    local maxComfort = data.maxComfort
    local comfortStr = nowComfort  .. "/" .. maxComfort
    self:setLabelText("ProgressLabel_1", comfortStr, "ComfortProgressPanel")
    self:setLabelText("ProgressLabel_2", comfortStr, "ComfortProgressPanel")

    local comfortProgress = self:getControl("ProgressBar", nil, "ComfortProgressPanel")
    comfortProgress:setPercent(nowComfort / maxComfort * 100)
end

function HomeTakeCareDlg:setCleanProgress(data)
    local cleanProgress = self:getControl("ProgressBar", nil, "CleanProgressPanel")
    local nowClean = data.nowClean
    local maxClean = data.maxClean
    local cleanStr = nowClean  .. "/" .. maxClean
    self:setLabelText("ProgressLabel_1", cleanStr, "CleanProgressPanel")
    self:setLabelText("ProgressLabel_2", cleanStr, "CleanProgressPanel")

    if nowClean < MIN_CLEAN then
        -- 清洁度<20，进度条显示为红色
        cleanProgress:loadTexture(PROGRESS_BAR.RED)
    else
        cleanProgress:loadTexture(PROGRESS_BAR.GREEN)
    end

    cleanProgress:setPercent(nowClean / maxClean * 100)
end

function HomeTakeCareDlg:setRepairPanel()
    -- 获取家具类别
    self.furnitureType = {}
    for i = 1, #FURNITURE_TYPE do
        if self:hasFurnitureByType(FURNITURE_TYPE[i]) then
            table.insert(self.furnitureType, FURNITURE_TYPE[i])
        end
    end

    local categoryListView = self:resetListView("CategoryListView", 5)
    categoryListView:setVisible(true)
    for i = 1, #self.furnitureType do
        local panel = self.bigPanel:clone()
        panel:setVisible(true)
        self:setLabelText("Label", self.furnitureType[i], panel)

        local function func(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onCategoryListSelect(sender)
            end
        end

        panel:addTouchEventListener(func)
        categoryListView:pushBackCustomItem(panel)

        -- 默认选中第一项
        if i == 1 then
            self:onCategoryListSelect(panel)
        end
    end
end

function HomeTakeCareDlg:onCategoryListSelect(sender)
    local label = self:getControl("Label", nil, sender)
    local type = label:getString()
    local listView = self:getControl("CategoryListView")
    for k, v in pairs(listView:getChildren()) do
        self:setCtrlVisible("BChosenEffectImage", sender == v, v)
    end

    self:initItemList(type)
end

function HomeTakeCareDlg:initItemList(type)
    self.type = type
    self.furnitures = self:getSpecialFurnitureByType(type)

    local itemListView = self:resetListView("ItemListView", 5)
    itemListView:setVisible(true)
    itemListView:removeAllChildren()

    -- 如果没有家具，显示莲花姑娘
    self:setCtrlVisible("NoticePanel", #self.furnitures <= 0, "ItemInfoPanel")
    self:setCtrlVisible("ItemListView", #self.furnitures > 0, "ItemInfoPanel")

    for i = 1, #self.furnitures do
        local panel = self.itemPanel:clone()
        panel:setVisible(true)
        panel:setTag(i)
        local item = self.furnitures[i]
        local name = item.name or item:queryBasic("name")

        -- 图标
        local icon = HomeMgr:getFurnitureIcon(name)
        self:setImage("IconImage", ResMgr:getItemIconPath(icon), panel)
        local iconPanel = self:getControl("IconPanel", nil, panel)
        local function iconTouch(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local rect = self:getBoundingBoxInWorldSpace(iconPanel)
                InventoryMgr:showFurniture({
                    name = name,
                    durability = item["durability"]
                }, rect, true)
            end
        end

        iconPanel:addTouchEventListener(iconTouch)

        -- 名称
        self:setLabelText("NameLabel", name, panel)

        -- 耐久
        local nowDur, maxDur = self:getDurInfo(item)
        local id = item.id or item:queryBasicInt("id")
        if HomeMgr:isUsingById(id) then
            self:setLabelText("DurableLabel", CHS[4200419], panel, COLOR3.RED)
            self:setLabelText("DurableNumLabel_1", "", panel)
            self:setLabelText("DurableNumLabel_2", "", panel)
        else
            self:setLabelText("DurableLabel", CHS[4200422], panel,  COLOR3.TEXT_DEFAULT)
            if nowDur <= 0 then
                self:setLabelText("DurableNumLabel_1", nowDur, panel, COLOR3.RED)
            else
                self:setLabelText("DurableNumLabel_1", nowDur, panel, COLOR3.TEXT_DEFAULT)
            end

            self:setLabelText("DurableNumLabel_2", "/" .. maxDur, panel)
        end

        -- 置灰图标
        local iconImage = self:getControl("IconImage", nil, panel)
        if nowDur <= 0 then
            gf:grayImageView(iconImage)
        else
            gf:resetImageView(iconImage)
        end

        local function func(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onItemSelect(sender)
            end
        end

        panel:addTouchEventListener(func)
        itemListView:pushBackCustomItem(panel)

        if i == 1 then
            -- 默认选中第一项
            self:onItemSelect(panel)
        end
    end
end

function HomeTakeCareDlg:onItemSelect(sender)
    if not self.furnitures then
        return
    end

    local tag = sender:getTag()
    local item = self.furnitures[tag]

    if not item then
        return
    end

    -- 选中效果
    local listView = self:getControl("ItemListView")
    for k, v in pairs(listView:getChildren()) do
        self:setCtrlVisible("ChosenEffectImage", sender == v, v)
    end

    local id = item.id or item:queryBasicInt("id")
    if HomeMgr:isUsingById(id) then
        self:setCtrlEnabled("RepairButton", false)
    else
        self:setCtrlEnabled("RepairButton", true)
    end
    -- 设置右侧详细信息
    self:setItemInfo(item)
    self.item = item
end

function HomeTakeCareDlg:setItemInfo(item)
    local mainPanel = self:getControl("InfoPanel")
    local name = item.name or item:queryBasic("name")

    -- 名称
    self:setLabelText("NameLabel", name, mainPanel)

    -- 描述
    local desStr = HomeMgr:getFurnitureDesc(name)
    self:setDescript(desStr)

    -- 恢复耐久所需消耗
    local costMoney = self:getCostMoney(item)
    local costCash, costColor = gf:getArtFontMoneyDesc(costMoney)
    self:setNumImgForPanel("NeedCashPanel", costColor, costCash, false, LOCATE_POSITION.MID, 21, "NeedPanel")
    self.costMoney = costMoney
    local id = item.id or item:queryBasicInt("id")
    if HomeMgr:isUsingById(id) then
        local costCash2, costColor2 = gf:getArtFontMoneyDesc(0)
        self:setNumImgForPanel("NeedCashPanel", costColor2, costCash2, false, LOCATE_POSITION.MID, 21, "NeedPanel")
    end

    -- 拥有金钱
    local money = Me:queryInt("cash")
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("HaveCashPanel", color, cash, false, LOCATE_POSITION.MID, 21, "HavePanel")
end

-- 设置物品描绘信息
function HomeTakeCareDlg:setDescript(descript)
    local panel = self:getControl("FunPanel")
    panel:removeAllChildren()

    local box = panel:getBoundingBox()

    local container = ccui.Layout:create()
    container:setPosition(0,0)
    local scrollview = ccui.ScrollView:create()
    scrollview:setContentSize(panel:getContentSize())
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:addChild(container)
    panel:addChild(scrollview)

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(17)
    textCtrl:setContentSize(box.width, 0)
    textCtrl:setString(descript)
    textCtrl:updateNow()

    textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0,textH)
    container:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    container:setContentSize(textW, textH)
    scrollview:setInnerContainerSize(container:getContentSize())
    if textH < panel:getContentSize().height then
        container:setPositionY(panel:getContentSize().height - textH)
    end

end

--  是否有该类型的特殊家具（全部，房屋-床柜，房屋-功能）
function HomeTakeCareDlg:hasFurnitureByType(type)
    if type == CHS[4100075] then
        return true
    else
        return (#self:getSpecialFurnitureByType(type) > 0)
    end
end

-- 获取该类型的所有家具，根据一定规则排序（全部，房屋-床柜，房屋-功能）
function HomeTakeCareDlg:getSpecialFurnitureByType(type)
    return HomeMgr:getAllSpecialFurnitureByType(type)
end

-- 获得耐久度信息（当前耐久度，最大耐久度）
function HomeTakeCareDlg:getDurInfo(item)
    local dur = item.durability or item:queryBasicInt("durability")
    local maxDur = HomeMgr:getMaxDur(item.name or item:queryBasic("name"))
    return dur, maxDur
end

-- 获取恢复耐久所消耗的金钱
function HomeTakeCareDlg:getCostMoney(item)
    local nowDur, maxDur = self:getDurInfo(item)
    return HomeMgr:getFixCost(nowDur, maxDur)
end

function HomeTakeCareDlg:onCleanButton()
    if not self.data then
        return
    end

    local data = self.data
    if data.nowClean == data.maxClean then
        -- 当前清洁度已满，无需清洁了。
        gf:ShowSmallTips(CHS[7002347])
        return
    end

    DlgMgr:openDlg("HomeCleanDlg")

end

function HomeTakeCareDlg:onRepairButton()
    local item = self.item
    if not item then
        return
    end

    local furniture_pos = item.id or item:queryBasicInt("id")

    -- 这件家具的耐久度已达上限，无需进行修理。
    local dur, maxDur =self:getDurInfo(item)
    if dur >= maxDur then
        gf:ShowSmallTips(CHS[7002350])
        return
    end

    if self.costMoney then
        local name = item.name or item:queryBasic("name")
        local moneyStr = gf:getMoneyDesc(self.costMoney)
        local tip = string.format(CHS[7002351], moneyStr, name)
        gf:confirm(tip, function()
            if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                gf:ShowSmallTips(CHS[5410117])
                return
            end

            gf:CmdToServer("CMD_HOUSE_REPAIR_FURNITURE", {furniture_pos = furniture_pos, cost = self.costMoney})
        end)
    end

end

function HomeTakeCareDlg:MSG_HOUSE_FUNCTION_FURNITURE_LIST()
    self:setRepairPanel()

    if self.dlgOPenedList then
        local listView = self:getControl("ItemListView")
        listView:doLayout()
        self:onDlgOpened(self.dlgOPenedList)
        self.dlgOPenedList = nil
    end
end

function HomeTakeCareDlg:MSG_UPDATE()
    local money = Me:queryInt("cash")
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("HaveCashPanel", color, cash, false, LOCATE_POSITION.MID, 21, "HavePanel")
end

function HomeTakeCareDlg:MSG_HOUSE_DATA()
    self:setHomeInfo()
end

function HomeTakeCareDlg:MSG_HOUSE_FURNITURE_OPER(data)
    if not (data.action == "repair" or data.action == "update") then
        return
    end

    -- 重新刷一遍列表
    if not self.type then
        return
    end

    self:initItemList(self.type)
    local lastSelectTag
    for i = 1, #self.furnitures do
        local item = self.furnitures[i]
        if (item.id or item:queryBasicInt("id")) == data.furniture_pos then
            lastSelectTag = i
        end
    end

    -- 默认选中上一次选中项
    local listView = self:getControl("ItemListView")
    local items = listView:getChildren()
    for k, v in pairs(items) do
        if v:getTag() == lastSelectTag then
            self:onItemSelect(v)
            return
        end
    end
end

function HomeTakeCareDlg:onDlgOpened(list)
    if list[1] == CHS[5400112] then
        -- 耐久
        if not self.furnitures then
            -- 家具列表还未创建，先缓存，等创建后再重新调用
            self.dlgOPenedList = list
            return
        end

        self.radioGroup:setSetlctByName("RepairPanelCheckBox")

        local id = tonumber(list[2])
        if id then
            local listView = self:getControl("ItemListView")
            local index = 0
            for i, v in pairs(self.furnitures) do
                if v.id == id then
                    index = i
                    break
                end
            end

            if index > 0 then
                self:scrollToOneFurniture(listView, index)
            end
        end
    else
        -- 居所
        self.radioGroup:setSetlctByName("HomePanelCheckBox")
    end
end

-- 滑到某个家具，如果滑动距离足够活动会在最顶部
function HomeTakeCareDlg:scrollToOneFurniture(listView, tag)
    -- local contentLayer = scrollview:getChildByTag(SCROLLVIEW_CHILD_TAG)
    local cell = listView:getChildByTag(tag)

    if not cell then
        return
    end

    self:onItemSelect(cell)

    local scrollSize = listView:getContentSize()
    local scrollInnerSize = listView:getInnerContainerSize()
    local canScrollHeight = scrollInnerSize.height - scrollSize.height
    local line = tag - 1

    local scrollTime = 0.05 * line
    if canScrollHeight > 0 then
        local scrollHeight = line * (cell:getContentSize().height + 5)
        if scrollHeight > canScrollHeight then
            scrollHeight = canScrollHeight
        end

        local percent = scrollHeight / canScrollHeight * 100
        listView:scrollToPercentVertical(percent, scrollTime, false)
    end
end

function HomeTakeCareDlg:cleanup()
    self:releaseCloneCtrl("bigPanel")
    self:releaseCloneCtrl("itemPanel")
    self.furnitureType = {}
    self.item = nil
    self.furnitures = nil

    -- 关闭该界面时，同时关闭对应子界面
    DlgMgr:closeDlg("HomeCleanDlg")
end

return HomeTakeCareDlg