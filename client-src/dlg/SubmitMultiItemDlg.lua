-- SubmitMultiItemDlg.lua
-- Created by zhengjh Sep/27/2016
-- 提交多个道具

local SubmitMultiItemDlg = Singleton("SubmitMultiItemDlg", Dialog)
local COLUNM = 4
local SPACE = 1

local SUBMIT_NOT_CLOSE_DLG_ITEM = {
    [CHS[7190291]] = CHS[7100374], -- 小童魂魄的证词，对应提示
}

-- 需要修改标题与提交按钮描述
local TITLE_SUBMIT_DES = {
    {item = {CHS[7190288], CHS[7190289], CHS[7190290], CHS[7190291], CHS[7190292], CHS[7190293], CHS[7190296],
        CHS[7190297], CHS[7190298], CHS[7190299], CHS[7190300]}, title = CHS[7100361], confirm = CHS[7100362]},
}

function SubmitMultiItemDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)

    self.itemCell = self:retainCtrl("ItemListPanel")
    self.itemSelectImg = self:retainCtrl("SeleteImage", self.itemCell)

    self.selectItems = {}
    self.caiyapData = nil

    self.descPanel = self:retainCtrl("DescPanel")
    self.limitTradeLabel = self:retainCtrl("LimitTradeLabel")
    self.limitTimePanel = self:retainCtrl("LimitTimePanel")

end


--
function SubmitMultiItemDlg:setDataForWaWaFuY(data)
    self.type = "wawa_caiyao"
    self.limitNum = 1
    self.caiyapData = data
    local caiyaoList = InventoryMgr:getItemByClass(ITEM_CLASS.CAIYAO)
    self:initList(caiyaoList)

    self:setLabelText("Label_1", CHS[4101462], "TitlePanel")
    self:setLabelText("Label_2", CHS[4101462], "TitlePanel")

    self:setLabelText("Label_1", CHS[4101489], "SubmitButton")
    self:setLabelText("Label_2", CHS[4101489], "SubmitButton")
end

-- 多选并未支持
function SubmitMultiItemDlg:setData(list, limit, type)
    self.type = type
    self.limitNum = limit
    self:initList(list)
    self:refreshTitleAndConfirm(list)
end

-- 有些道具不是提交，需要刷新修改标题与按钮
function SubmitMultiItemDlg:refreshTitleAndConfirm(data)
    for i = 1, #data do
        local item = data[i]
        for j = 1, #TITLE_SUBMIT_DES do
            local list = TITLE_SUBMIT_DES[j].item
            for k = 1, #list do
                if list[k] == item.name then
                    self:setLabelText("Label_1", CHS[7100361], "TitlePanel")
                    self:setLabelText("Label_2", CHS[7100361], "TitlePanel")
                    self:setLabelText("Label_1", CHS[7100362], "SubmitButton")
                    self:setLabelText("Label_2", CHS[7100362], "SubmitButton")
                    return
                end
            end
        end
    end
end

function SubmitMultiItemDlg:initList(data)
    local scroview = self:getControl("ScrollView")
    scroview:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local count = #data
    local cellColne = self.itemCell:clone()
    local line = math.floor(count / COLUNM)
    local left =  count % COLUNM

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + SPACE)

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUNM
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * COLUNM
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (cellColne:getContentSize().width + SPACE)
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height + SPACE)
            cell:setPosition(x, y)
            self:setCellData(cell, data[tag], tag == count)
            contentLayer:addChild(cell)

            if tag == 1 then
                self:setSelectInfo(cell, data[tag])
            end
        end
    end

    contentLayer:setContentSize(scroview:getContentSize().width, totalHeight)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end
end

function SubmitMultiItemDlg:setCellData(cell, item, isAddItem)
    self:setCtrlVisible("GetImage", false, cell)
    -- 设置图标
    local iconPath = ResMgr:getItemIconPath(item.icon)
    self:setImage("ItemImage", iconPath, cell)
    self:setItemImageSize("ItemImage", cell)

    -- 等级
    if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level and item.req_level > 0 then
        self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false, LOCATE_POSITION.LEFT_TOP, 19)
    elseif item.level and item.level > 0 then
        self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 限时/限制交易道具
    local img = self:getControl("ItemImage", nil, cell)
    if InventoryMgr:isTimeLimitedItem(item) then
        InventoryMgr:addLogoTimeLimit(img)
    elseif InventoryMgr:isLimitedItem(item) then
        InventoryMgr:addLogoBinding(img)
    end

    -- 融合标识
    if item and InventoryMgr:isFuseItem(item.name) then
        InventoryMgr:addLogoFuse(img)
    end

    -- 未鉴定
    if item and item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(img)
    end

    local function touch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:setSelectInfo(sender, item)
        end
    end

    cell:addTouchEventListener(touch)
end

function SubmitMultiItemDlg:setSelectInfo(sender, item)
    self:seleceltItem(sender, item)
    self:initSecectItemInfo(item)
    self:addItemSelcelImage(sender)
end

function SubmitMultiItemDlg:seleceltItemForCaiYap(cell, item)
    if item and self.selectItems[item.item_unique] then -- 如果已经存在则取消
        self.selectItems[item.item_unique] = nil
        self:setCtrlVisible("GetImage", false, cell)
    else
        if self.limitNum == 1 then
            for key, v in pairs(self.selectItems) do
                self.selectItems[key] = nil
                self:setCtrlVisible("GetImage", false, v.cell)
            end
        else
            if self:getItemsCount(self.selectItems)>= self.limitNum then
                gf:ShowSmallTips(string.format(CHS[6000518], self.limitNum))
                return
            end
        end

        self.selectItems[item.item_unique] = {item = item, cell = cell}
        self:setCtrlVisible("GetImage", true, cell)
    end
end

function SubmitMultiItemDlg:seleceltItem(cell, item)
    if item and self.selectItems[item.item_unique] then -- 如果已经存在则取消
        self.selectItems[item.item_unique] = nil
        self:setCtrlVisible("GetImage", false, cell)
    else
        if self.limitNum == 1 then
            for key, v in pairs(self.selectItems) do
                self.selectItems[key] = nil
                self:setCtrlVisible("GetImage", false, v.cell)
            end
        else
            if self:getItemsCount(self.selectItems)>= self.limitNum then
                gf:ShowSmallTips(string.format(CHS[6000518], self.limitNum))
                return
            end
        end

        self.selectItems[item.item_unique] = {item = item, cell = cell}
        self:setCtrlVisible("GetImage", true, cell)
    end
end

function SubmitMultiItemDlg:addItemSelcelImage(cell)
    self.itemSelectImg:removeFromParent()
    cell:addChild(self.itemSelectImg)
end

function SubmitMultiItemDlg:initSecectItemInfo(item)
    self:setLabelText("NameLabel", item.name, nil, COLOR3.TEXT_DEFAULT)

    local iconPath = ResMgr:getItemIconPath(item.icon)
    self:setImage("ItemImage", iconPath, "ItemInfoPanel")
    self:setItemImageSize("ItemImage", "ItemInfoPanel")

    -- 限时/限制交易道具
    local img = self:getControl("ItemImage", nil, "ItemInfoPanel")
    if InventoryMgr:isTimeLimitedItem(item) then
        InventoryMgr:addLogoTimeLimit(img)
        InventoryMgr:removeLogoBinding(img)
    elseif InventoryMgr:isLimitedItem(item) then
        InventoryMgr:addLogoBinding(img)
        InventoryMgr:removeLogoTimeLimit(img)
    else
        InventoryMgr:removeLogoBinding(img)
        InventoryMgr:removeLogoTimeLimit(img)
    end

    -- 融合标识
    if item and InventoryMgr:isFuseItem(item.name) then
        InventoryMgr:addLogoFuse(img)
    else
        InventoryMgr:removeLogoFuse(img)
    end

    -- 等级
    if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level and item.req_level > 0 then
        -- 装备的话，显示req_level
        self:setLabelText("ParaLabel", CHS[3002819] .. item.req_level)
    elseif self.type == "wawa_caiyao" then
        self:setLabelText("ParaLabel", CHS[4101367] .. self:getFunValue(item), nil, COLOR3.GREEN)
    elseif item.level and item.level > 0 then
        self:setLabelText("ParaLabel", CHS[3002819] .. item.level)
    else
        self:setLabelText("ParaLabel", "")
    end

    local listView = self:getControl("ListView")
    listView:removeAllItems()

    -- 描述
    local descriptStr = ""
    if not item["isShowDesc"] then
        if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
            descriptStr = InventoryMgr:getDescript(CHS[3002820])
        elseif InventoryMgr:isUpgrade(item.name)  and item.level then       -- 粉才描述
            if item.level == 3 then
                descriptStr = CHS[3002821]
        elseif item.level > 3 then
            descriptStr = string.format(CHS[3002822], item.level *10, item.level *10 + 9)
        end
        else
            if item.desc and item.desc ~= "" then
                descriptStr = item.desc
            elseif item.real_desc and item.real_desc ~= "" then
                -- 部分物品描述，使用动态字段，需要服务器告知
                descriptStr = item.real_desc
            else
                descriptStr = InventoryMgr:getDescript(item.name)
            end
        end

        if item["expired_time"] and item["expired_time"] ~= 0 then
            descriptStr = descriptStr .. gf:getServerDate(CHS[4300028], item["expired_time"])
        end
    end

    -- self:setLabelText("DescLabel", descriptStr, nil, COLOR3.TEXT_DEFAULT)
    listView:pushBackCustomItem(self.descPanel)
    self:setColorText(descriptStr, self.descPanel, nil, nil, nil, COLOR3.TEXT_DEFAULT, 19)

    local limitTab = InventoryMgr:getLimitAtt(item)
    if next(limitTab) then
        listView:pushBackCustomItem(self.limitTradeLabel)
        self:setLabelText("LimitTradeLabel", limitTab[1].str)

        if InventoryMgr:isTimeLimitedItem(item) then
            listView:pushBackCustomItem(self.limitTimePanel)
            local timeLimitStr = string.format(CHS[7000077], gf:getServerDate(CHS[4200022], item.deadline))
            self:setColorText(timeLimitStr, self.limitTimePanel, nil, nil, nil, COLOR3.TEXT_DEFAULT, 19, true)
        end
    end
end

function SubmitMultiItemDlg:getFunValue(item)
    local name = item.name
    if string.match(name, CHS[4101368]) or string.match(name, CHS[4101369]) then
        return 3
    elseif string.match(name, CHS[4101370]) then
        return 5
    elseif string.match(name, CHS[4101371]) then
        return 8
    end
end

function SubmitMultiItemDlg:getItemsCount(items)
    local count = 0
    for k, v in pairs(items)do
        count = count + 1
    end

    return count
end

-- 检查是否有道具提交时不需要关界面
function SubmitMultiItemDlg:checkNotCloseDlg()
    for k, v in pairs(self.selectItems) do
        if v["item"] and SUBMIT_NOT_CLOSE_DLG_ITEM[v["item"].name] then
            return SUBMIT_NOT_CLOSE_DLG_ITEM[v["item"].name]
        end
    end

    return false
end

function SubmitMultiItemDlg:onSubmitButtonForCaiyao(sender, eventType)


    for k, v in pairs(self.selectItems) do
        if v["item"] then
            self.caiyapData.fy_para = v["item"].item_unique
        end
    end

    gf:CmdToServer("CMD_CHILD_RAISE", self.caiyapData)
    self:onCloseButton()
end

function SubmitMultiItemDlg:onSubmitButton(sender, eventType)
    if not next(self.selectItems) then
        gf:ShowSmallTips(CHS[5400601])
        return
    end

    if self.type == "wawa_caiyao" then
        self:onSubmitButtonForCaiyao()
        return
    end

    local size = 0
    local list = {}

    for k, v in pairs(self.selectItems) do
        size = size + 1
        if self.type == "mxza" then
            list[size] = v.item
        else
            list[size] = k
        end
    end

    local data = {}
    data.petNum = 0
    data.itemNum = size
    data.itemList = list

    local tips = self:checkNotCloseDlg()
    if tips then
        gf:ShowSmallTips(tips)
        return
    end

    if self.type and self.type == "mxza" and data.itemList[1] then
        -- 探案迷仙镇案需要特殊处理
        gf:CmdToServer("CMD_MXZA_SUBMIT_EXHIBIT", {name = data.itemList[1].name, state = data.itemList[1].state})
    else
        gf:CmdToServer("CMD_SUBMIT_MULTI_ITEM",data)
    end

    DlgMgr:closeDlg(self.name)
end

return SubmitMultiItemDlg
