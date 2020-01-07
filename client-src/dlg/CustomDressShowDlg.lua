-- CustomDressShowDlg.lua
-- Created by sujl, Jun/25/2018
-- 自定义换装预览界面

local CustomDressShowDlg = Singleton("CustomDressShowDlg", Dialog)

local CustomItem = require("cfg/CustomItem")

local FASHION_ITEM_CHS = {
    [EQUIP.FASION_HAIR]  = CHS[7150124], -- 发型
    [EQUIP.FASION_UPPER] = CHS[7150125], -- 上身
    [EQUIP.FASION_LOWER] = CHS[7150126], -- 下身
    [EQUIP.FASION_ARMS]  = CHS[7150127], -- 武器
}

-- 预览部件数量
local PREVIEW_ITEM_COUNT = 5

function CustomDressShowDlg:init(param)
    self:bindListener("TurnRightButton", self.onTurnRightButton)
    self:bindListener("TurnLeftButton", self.onTurnLeftButton)
    self:bindListener("UseButton", self.onUseButton)

    self.listView = self:getControl("ListView")

    self.icon = param.icon
    self.data = param.data
    self.gender = param.gender
    self.price = { 0, 0, 0, 0, 0 }
    self.partIndex = {}
    self.dir = 5
    self.cost = 0
    self.curSels = gf:deepCopy(self.data)
    self:refreshList(self.data)
    self:refreshPortrait()
    self:refreshCost()
end

-- 刷新列表
function CustomDressShowDlg:refreshList(datas)
    local name
    local itemPanel = self.listView:getItems()

    for i = 2, PREVIEW_ITEM_COUNT do
        self:setItemInfo(i, itemPanel[i - 1], datas[i])
        self:bindCheckBoxListener("ChoseCheckBox", self.onCheckBox, itemPanel[i - 1])
    end

    -- 特殊处理背饰，策划要求显示在最后面
    self:setItemInfo(1, itemPanel[PREVIEW_ITEM_COUNT], datas[1])
    self:bindCheckBoxListener("ChoseCheckBox", self.onCheckBox, itemPanel[PREVIEW_ITEM_COUNT])
end

function CustomDressShowDlg:showPricePanel(panel, show, showSel)
    showSel = showSel or show
    self:setCtrlVisible("UseLabel", true, panel)
    self:setCtrlVisible("PriceBKImage", show, panel)
    self:setCtrlVisible("PriceImage", show, panel)
    self:setCtrlVisible("PricePanel", show, panel)
    self:setCtrlVisible("ChoseCheckBox", showSel, panel)
end

function CustomDressShowDlg:getDressItem(itemName)
    local mallItems = InventoryMgr.dressData.malls
    local mallItem
    for i = 1, #mallItems do
        mallItem = mallItems[i]
        if mallItem.name == itemName then
            return { name = mallItem.name, coin = mallItem.goods_price }
        end
    end
end

-- 设置道具信息
function CustomDressShowDlg:setItemInfo(index, panel, itemName)
    if not itemName then
        self:setLabelText("ItemLabel", CHS[5430016], panel)
        self:setLabelText("UseLabel", CHS[5430017], panel, COLOR3.RED)
        self:showPricePanel(panel, false, false)
        return
    end

    self:setLabelText("UseLabel", "", panel, COLOR3.TEXT_DEFAULT)
    self:setLabelText("ItemLabel", itemName, panel)
    local path = ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName))
    self:setImage("ItemImage", path, panel)
    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))

    local info = InventoryMgr:getItemInfoByName(itemName)
    if info.part then
        self.partIndex[info.part] = index
    end

    if self:hasEquip(itemName) then
        self:showPricePanel(panel, false)
        self:setLabelText("UseLabel", CHS[2200133], panel)
    elseif self:hasItem(itemName) then
        self:showPricePanel(panel, false, true)
        self:setCheck("ChoseCheckBox", true, panel)
        self:setLabelText("UseLabel", CHS[2200134], panel)
    else
        self:setCheck("ChoseCheckBox", true, panel)

        -- 自定义部件
        local data = self:getDressItem(itemName)
        local canBuy = data and data.coin and data.coin > 0
        if canBuy then
            self:showPricePanel(panel, true)
            self:setLabelText("UseLabel", CHS[2200136], panel)
            if DistMgr:curIsTestDist() then
                self:setImagePlist("PriceImage", ResMgr.ui.small_reward_silver, panel)
            else
                self:setImagePlist("PriceImage", ResMgr.ui.small_reward_glod, panel)
            end
            local goldText = gf:getArtFontMoneyDesc(data.coin)
            self:setNumImgForPanel("PricePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 17, panel)
            self.price[index] = data.coin
        else
            self:setLabelText("UseLabel", info.custom_tips, panel)
            self:showPricePanel(panel, false)
            self.price[index] = -1
        end
    end
end

-- 已穿戴
function CustomDressShowDlg:hasEquip(itemName)
    local v = InventoryMgr:getFashionValue(true)
    for i = 1, #v do
        if v[i].name == itemName then
            return true
        end
    end

    v = InventoryMgr:getCustomValue()
    for i = 1, #v do
        if v[i].name == itemName then
            return true
        end
    end
end

-- 已拥有
function CustomDressShowDlg:hasItem(itemName)
    return StoreMgr:getFashionItemByName(itemName) or StoreMgr:getCustomItemByName(itemName) or self:hasEquip(itemName)
end

function CustomDressShowDlg:refreshPortrait()
    if not self.icon then
        return
    end

    local partString, partColorString

    -- 部件
    local parts = {}
    local itemName, nitem, itemInfo, custItem

    for i = 1, PREVIEW_ITEM_COUNT do
        itemName = self.curSels[self.partIndex[i]]
        if string.isNilOrEmpty(itemName) and self.gender == Me:queryBasicInt("gender") then
            local p = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
            local item = InventoryMgr:getItemByPos(p[i])
            itemName = item and item.name
        end

        if not string.isNilOrEmpty(itemName) then
            nitem = {}
            itemInfo = InventoryMgr:getItemInfoByName(itemName)
            custItem = CustomItem[itemName]
            nitem.part = itemInfo.part
            nitem.partIndex = custItem.fasion_part
            nitem.colorIndex = custItem.fasion_dye
            parts[itemInfo.part] = nitem
        else
            parts[i] = nil
        end
    end

    partString = gf:makePartString(parts[1] and parts[1].partIndex or 0, parts[2] and parts[2].partIndex or 0,
        parts[3] and parts[3].partIndex or 0, parts[4] and parts[4].partIndex or 0, parts[5] and parts[5].partIndex or 0)
    partColorString = gf:makePartColorString(0, parts[1] and parts[1].colorIndex or 0, parts[2] and parts[2].colorIndex or 0,
        parts[3] and parts[3].colorIndex or 0, parts[4] and parts[4].colorIndex or 0, parts[5] and parts[5].colorIndex or 0)

    local argList = {
        panelName = "UserPanel",
        icon = self.icon,
        weapon = 0,
        root = panel,
        action = nil,
        clickCb = nil,
        offPos = nil,
        orgIcon = Me:queryBasicInt("icon"),
        syncLoad = nil,
        dir = self.dir,
        pTag = nil,
        extend = nil,
        partIndex = partString,
        partColorIndex = partColorString,
    }

    local charAction = self:setPortraitByArgList(argList)
    self:displayPlayActions("UserPanel", nil, -36)
end

function CustomDressShowDlg:refreshCost()
    local cost = 0
    local itemName
    for key, v in pairs(self.curSels) do
        if not string.isNilOrEmpty(v) then
            cost = cost + (self.price[key] > 0 and self.price[key] or 0)
        end
    end

    if DistMgr:curIsTestDist() then
        self:setImagePlist("GoldImage", ResMgr.ui.small_reward_silver, "CostPanel")
    else
        self:setImagePlist("GoldImage", ResMgr.ui.small_reward_glod, "CostPanel")
    end

    local goldText = gf:getArtFontMoneyDesc(cost)
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 19, "CostPanel")

    if cost > 0 then
        self:setLabelText("Label_1", CHS[2200137], "UseButton")
        self:setLabelText("Label_2", CHS[2200137], "UseButton")
    else
        self:setLabelText("Label_1", CHS[2200138], "UseButton")
        self:setLabelText("Label_2", CHS[2200138], "UseButton")
    end
    self.cost = cost
end

function CustomDressShowDlg:onCheckBox(sender)
    local ctlName = sender:getParent():getName()
    local index = tonumber(string.match(ctlName, "PartPanel_(%d)"))
    index = index % 5 + 1

    local checked = sender:getSelectedState()
    if index then
        if checked then
            self.curSels[index] = self.data[index]
        else
            self.curSels[index] = ""
        end
    end

    self:refreshPortrait()
    self:refreshCost()
end

-- 形象右转
function CustomDressShowDlg:onTurnRightButton()
    self.dir = self.dir - 2
    if self.dir < 0 then
        self.dir = 7
    end

    self:refreshPortrait()
end

-- 形象左转
function CustomDressShowDlg:onTurnLeftButton()
    self.dir = self.dir + 2
    if self.dir > 7 then
        self.dir = 1
    end

    self:refreshPortrait()
end

function CustomDressShowDlg:onUseButton()
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003663])
        return
    end

    local genderMatch = self.gender == Me:queryBasicInt("gender")
    if not genderMatch then
        if self.icon then
            gf:ShowSmallTips(CHS[2200142])
        else
            gf:ShowSmallTips(CHS[2200143])
        end
        return
    end

    local items = {}
    local partCou = 0
    for key, v in pairs(self.curSels) do
        if not self:hasItem(v) and not string.isNilOrEmpty(v) then
            -- 跨服区组中不可购买时装
            if not DistMgr:checkCrossDist() then return end

            if -1 == self.price[key] then
                table.insert(items, string.format("#R%s#n", v))
            end
        end
    end

    if #items > 0 then
        gf:ShowSmallTips(string.format(CHS[2200140], table.concat(items, CHS[2200141])))
        return
    end

    -- 当前预览的自定义外观部件不足4件，无法进行穿戴。
    if self.icon then
        -- 部件
        local loseItem = {}
        local p = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
        for i = 2, #p do
            local item = InventoryMgr:getItemByPos(p[i])
            if string.isNilOrEmpty(self.curSels[i]) and (not item or item.name ~= self.curSels[i]) then
                table.insert(loseItem, string.format("#R%s#n", FASHION_ITEM_CHS[p[i]]))
            end
        end

        if #loseItem > 0 then
            gf:ShowSmallTips(string.format(CHS[5430020], table.concat(loseItem, "、")))
            return
        end
    end

    items = {}
    for key, v in pairs(self.curSels) do
        if not string.isNilOrEmpty(v) then
            table.insert(items, v)
        end
    end

    if #items == 1 then
        -- 可能是时装
        local dressItem = InventoryMgr:getItemByPos(EQUIP.FASION_DRESS)
        if dressItem and dressItem.name == items[1] then
            self:onCloseButton()
            return
        end
    end

    local dresses = InventoryMgr:getCustomValue()
    local function isAllDressed()
        if not dresses or #dresses <= 0 then return end
        for i = 1, #items do
            local isDress = false
            for j = 1, #dresses do
                if dresses[j].name == items[i] then
                    isDress = true
                end
            end
            if not isDress then
                return false
            end
        end
        return true
    end
    if #items <= 0 or isAllDressed() then
        self:onCloseButton()
        return
    end

    DlgMgr:sendMsg("CustomDressDlg", "beginBatchUpdate")    -- 通知自定义界面穿戴批量更新
    gf:CmdToServer('CMD_FASION_CUSTOM_EQUIP_EX', { is_buy = self.cost > 0 and 1 or 0, item_names = table.concat(items, "|")  })

end

return CustomDressShowDlg