-- JewelryUpgradeDlg.lua
-- Created by zhengjh Jul/29/2015
-- 首饰合成

local JewelryUpgradeDlg = Singleton("JewelryUpgradeDlg", Dialog)
local classJewelry =
{
    [1] = CHS[3002887],
    [2] = CHS[3002888],
    [3] = CHS[3002889],
}

local CLASS_BALDRIC = 100      -- 玉佩
local CLASS_NECKLACE = 200     -- 项链
local CLASS_WRIST  = 30        -- 手镯

local MAX_ATT_COUNT = Const.JEWELRY_ATTRIB_MAX - 2    -- 当前最高5条，去除基础属性与限制交易

function JewelryUpgradeDlg:init()
    self:bindListener("UpgradeAllButton", self.onUpgradeAllButton)
    self:bindListener("UpgradeButton", self.onUpgradeButton)
    self:bindListViewListener("JewelryListView", self.onSelectJewelryListView)
    self:bindCheckBoxListener("CheckBox", self.onCheckBox)

    self.bigPanel = self:getControl("BigPanel", Const.UIPanel)
    self.bigPanel:retain()
    self.bigPanel:removeFromParent()

    -- 创建顶部提示框
    self.topTagCell = self.bigPanel:clone()
    local panel = self:getControl("JewelryPanel")
    panel:addChild(self.topTagCell, 10, 0)
    self:bindTouchEndEventListener(self.topTagCell, self.onTopTag)
    self:setCtrlVisible("BChosenEffectImage", true, self.topTagCell)
    self:setCtrlVisible("DownArrowImage", false, self.topTagCell)
    self:setCtrlVisible("UpArrowImage", true, self.topTagCell)
    self:bindJewelryListView()

    self.bigSelectImg = self:getControl("BChosenEffectImage", Const.UIPanel, self.bigPanel)
    self.bigSelectImg:retain()
    self.bigSelectImg:removeFromParent()

    self.sPanel = self:getControl("SPanel", Const.UIPanel)
    self.sPanel:retain()
    self.sPanel:removeFromParent()

    self.samllSelectImg = self:getControl("SChosenEffectImage", Const.UIPanel, self.sPanel)
    self.samllSelectImg:retain()
    self.samllSelectImg:removeFromParent()

    self:setCtrlVisible("ItemShapePanel", false, "ItemPanel_1")
    self:setCtrlVisible("ItemShapePanel", false, "ItemPanel")


    self:setCtrlVisible("CostMaterialPanel_2", true, "RightPanel")

    self.isOpen = false
    self.selectJewelry = nil
    self.curUpgradeJewelry = nil
    self:graytBtn()
    self:initData()
    self:setCostPanel(0)
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")

    DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
    DlgMgr:closeThisDlgOnly("EquipmentChildDlg")

    local node = self:getControl("CheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
       self:setCheck("CheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
       self:setCheck("CheckBox", false)
    end
   -- self:onCheckBox(node, 2)

   -- 首饰合成规则的按钮
    self:getControl("NoteButton"):setLocalZOrder(1)
    self:bindListener("NoteButton", self.onNoteButton)
end

function JewelryUpgradeDlg:graytBtn()
    local upgradeAllBtn = self:getControl("UpgradeAllButton")
    gf:grayImageView(upgradeAllBtn)
    upgradeAllBtn:setTouchEnabled(false)

    local upgradeBtn = self:getControl("UpgradeButton")
    gf:grayImageView(upgradeBtn)
    upgradeBtn:setTouchEnabled(false)
end

function JewelryUpgradeDlg:resetBtn()
    local upgradeAllBtn = self:getControl("UpgradeAllButton")
    gf:resetImageView(upgradeAllBtn)
    upgradeAllBtn:setTouchEnabled(true)

    local upgradeBtn = self:getControl("UpgradeButton")
    gf:resetImageView(upgradeBtn)
    upgradeBtn:setTouchEnabled(true)
end

function JewelryUpgradeDlg:initData()
    self.allComposeJewelry = EquipmentMgr:getAllComposeJewelry()
    self:initListView(100)

    -- 界面相关label设置为空字符串
    for i = 1, 8 do
        self:setLabelText("AttachAttribLabel" .. i, "")
    end

    local attribPanel = self:getControl("AttribPanel")
    self:setLabelText("AttribLabel", "", attribPanel)

    local materiaPanel = self:getControl("MateriaPanel", Const.UIPanel, "CostMaterialPanel_2")
    self:setLabelText("AttribPromoteLabel", "", materiaPanel)
end

function JewelryUpgradeDlg:checkCanShowTopTag()
    local cell = self.bigSelectImg:getParent()
    if not cell or not self.isOpen then
        self.topTagCell:setVisible(false)
        return
    end

    local parent = self.topTagCell:getParent()
    local wPos = cell:convertToWorldSpace(cc.p(0, 0))
    local pos = parent:convertToNodeSpace(wPos)
    if pos.y > parent:getContentSize().height - cell:getContentSize().height - 6 then
        self.topTagCell:setVisible(true)

        local str = self:getLabelText("Label", cell)
        self:setLabelText("Label", str, self.topTagCell)
    else
        self.topTagCell:setVisible(false)
    end
end

function JewelryUpgradeDlg:bindJewelryListView()
    local listView =  self:getControl("JewelryListView", Const.UIListView)
    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType
            or ccui.ScrollviewEventType.scrollToTop == eventType
            or ccui.ScrollviewEventType.scrollToBottom == eventType then
            -- 获取控件

            self:checkCanShowTopTag()
        end
    end

    listView:addScrollViewEventListener(onScrollView)
end

function JewelryUpgradeDlg:initListView(tag)
    local listView =  self:getControl("JewelryListView", Const.UIListView)
    listView:removeAllItems()

    local class, secondType = self:getTypes(tag)
    local lastClass, lastSecondeType

    if self.lastSelectTag then
        lastClass, lastSecondeType = self:getTypes(self.lastSelectTag)
    end

    if class ~= lastClass and lastClass then
        self.isOpen = true
    end

    self.lastSelectTag = self.selectTag

    -- 一级菜单
    for i = 1, #classJewelry do
        local bigCell = self.bigPanel:clone()
        bigCell:setTag(CLASS_BALDRIC *i )
        self:createBigCell(classJewelry[i], bigCell)
        listView:addChild(bigCell)

        if class == i then
            self:addBigSelectImg(bigCell)
        end

        if class == i and self.isOpen then
            local itemList = self.allComposeJewelry[classJewelry[i]]
            for j = 1, #itemList do
                local cellS = self.sPanel:clone()
                cellS:setTag(CLASS_BALDRIC *i + j)
                self:createCellS(itemList[j]["level"] ..CHS[3002890], cellS)
                listView:pushBackCustomItem(cellS)
            end
        end

    end

    listView:getParent():requestDoLayout()
    listView:requestRefreshView()
    listView:doLayout()

    if self.isOpen then
        performWithDelay(self.root, function()
            self:checkCanShowTopTag()
        end, 0)
    end

    -- 特判指引运行时，取消滚动（由于直接设置Direction会有布局问题，因此采用修改滑动区域的方式来避免滑动）
    if GuideMgr:isRunning() then
        listView:setInnerContainerSize({width = 0, height = 0})
    end
end

function JewelryUpgradeDlg:getTypes(tag)
    local class = math.floor(tag / CLASS_BALDRIC)
    local secondType = tag % CLASS_BALDRIC
    return class, secondType
end

function JewelryUpgradeDlg:createBigCell(name, cell)
    local label = self:getControl("Label", Const.UILabel, cell)
    label:setString(name)
end

function JewelryUpgradeDlg:createCellS(name, cell)
    local label = self:getControl("Label", Const.UILabel, cell)
    label:setString(name)
end

function JewelryUpgradeDlg:onUpgradeAllButton(sender, eventType)
    self:sendCmd(1)
end

function JewelryUpgradeDlg:onUpgradeButton(sender, eventType)
    self.curUpgradeJewelry = self.selectJewelry
    self:sendCmd(0)
end

function JewelryUpgradeDlg:sendCmd(composeType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[3002892])
        return
    end

    if self.destJewelry and self.destJewelry.level > 70 then
        -- 判断是否处于公示期
        if Me:isInTradingShowState() then
            gf:ShowSmallTips(CHS[4300227])
            return
        end
    end

    if self.destJewelry and self.destJewelry.level > 80 then
        if not self.selectJewelry then
            gf:ShowSmallTips(CHS[4200139])
            return
        end
    end

    if self.composeNum < 1 then
        gf:ShowSmallTips(CHS[3002893])
        return
    end

    local class, secondType = self:getTypes(self.slectJewelTag)
    local jewelry = self.allComposeJewelry[classJewelry[class]][secondType]

    if EquipmentMgr:getJewelryXomposeCost(jewelry.level) > Me:queryBasicInt('cash') then
        gf:askUserWhetherBuyCash(EquipmentMgr:getJewelryXomposeCost(jewelry.level) - Me:queryBasicInt('cash'))
        return
    end

    if self:isCheck("CheckBox") and  self.isHaveLimtedComposeItem and self.isHaveLimtedComposeItem > 0 then
        local days = self.isHaveLimtedComposeItem * 10
        gf:confirm(string.format(CHS[3002894], days) , function()
            local para = string.format("%s_%d_%d", jewelry["name"], 1, composeType)

            if self.selectJewelry and self.selectJewelry.req_level >= 80 then
                gf:CmdToServer("CMD_UPGRADE_EQUIP", {pos = self.selectJewelry.pos, type = Const.UPGRADE_JEWELRY_APPOINT,para = 1})
            else
                gf:CmdToServer("CMD_UPGRADE_EQUIP", {pos = 0,type = Const.UPGRADE_JEWELRY_COMPOSE,para = para})
            end
        end)
    else
        local para = string.format("%s_%d_%d", jewelry["name"], 0, composeType)
        if self.selectJewelry and self.selectJewelry.req_level >= 80 then
            gf:CmdToServer("CMD_UPGRADE_EQUIP", {pos = self.selectJewelry.pos, type = Const.UPGRADE_JEWELRY_APPOINT,para = 0})
        else
            gf:CmdToServer("CMD_UPGRADE_EQUIP", {pos = 0,type = Const.UPGRADE_JEWELRY_COMPOSE,para = para})
        end
    end
end

function JewelryUpgradeDlg:onTopTag(sender, eventType)
    local tag = sender:getTag()

    self:setSelect(self:getControl("JewelryListView"), tag)
end

function JewelryUpgradeDlg:onSelectJewelryListView(sender, eventType)
    GuideMgr:needCallBack("touchBig")
    local tag = self:getListViewSelectedItemTag(sender)
    self:setSelect(sender, tag)
end

function JewelryUpgradeDlg:setSelect(sender, tag)
    local class, secondType = self:getTypes(tag)
    self.selectTag = tag

    if self.selectTag == self.lastSelectTag and secondType ~= 0 then
        return
    end

    local item = sender:getChildByTag(tag)

    if secondType ~= 0 then       -- 二级菜单
        -- 刷新选中的配方
        self.lastSelectTag = self.selectTag
        self.selectJewelry = nil
        self:refreshPanel(tag)

        self:addSmallSelcelImage(item)
        return
    elseif class ~= 0 then -- 一级菜单
        --self:addBigSelectImg(item)
        self.isOpen = not self.isOpen
    end

    performWithDelay(sender, function() self:initListView(tag) end, 0)
end

function JewelryUpgradeDlg:setJewelry(jewelry)
    self:setCtrlVisible("ItemShapePanel", true, "ItemPanel_1")
    self:setCtrlVisible("ItemShapePanel", true, "ItemPanel")

    local bigType = 0
    local smallType = 0
    local jewelryList = {}
    if jewelry.equip_type == EQUIP_TYPE.NECKLACE then
        bigType = 2
        jewelryList = self.allComposeJewelry[CHS[3002888]]
    elseif jewelry.equip_type == EQUIP_TYPE.BALDRIC then
        bigType = 1
        jewelryList = self.allComposeJewelry[CHS[3002887]]
    elseif jewelry.equip_type == EQUIP_TYPE.WRIST then
        bigType = 3
        jewelryList = self.allComposeJewelry[CHS[3002889]]
    else
        return
    end
    for i = 1 ,#jewelryList do
        if jewelryList[i].name == jewelry.name then
            smallType = i
        end
    end
    if smallType < #jewelryList then
        smallType = smallType + 1
    end
    if bigType == 0 then return end
    self.isOpen = true
    local tag = bigType * 100 + smallType
    performWithDelay(self.root, function()
        self:initListView(tag)
        local listView =  self:getControl("JewelryListView", Const.UIListView)
        local item = listView:getChildByTag(tag)

        if smallType ~= 0 then       -- 二级菜单
            -- 刷新选中的配方

            self.lastSelectTag = self.tag
            self:refreshPanel(tag)

            self:addSmallSelcelImage(item)

            if jewelry.req_level >= 80 and jewelry.req_level < 100 then
                self:setSelectJewelry(jewelry)
            end
            return
        elseif class ~= 0 then -- 一级菜单
            --self:addBigSelectImg(item)
            self.isOpen = not self.isOpen
        end
    end, 0)
end

-- 刷新整个界面，调用该方法前需先清空选中的首饰 self.selectJewelry = nil
function JewelryUpgradeDlg:refreshPanel(tag)
    if not self.slectJewelTag then
        self:resetBtn()
    end

    self:setCtrlVisible("ItemShapePanel", true, "ItemPanel_1")
    self:setCtrlVisible("ItemShapePanel", true, "ItemPanel")
    self:setCtrlVisible("ItemShapePanel", true, "UpgradeItemPanel")
    self.slectJewelTag = tag -- 面板上数据所选的配方标志
    local class, secondType = self:getTypes(tag)
    local jewelry = self.allComposeJewelry[classJewelry[class]][secondType]
    local composePanel2 = self:getControl("CostMaterialPanel_2")
    local needItems = jewelry["needItems"]

    self.destJewelry = jewelry
    local composePanel = composePanel2
    self:setCtrlVisible("UpgradeAllButton", jewelry.level < 80)


    local materiaPanel = self:getControl("MateriaPanel", Const.UIPanel, composePanel)

    local haveMinItemNum = -1  -- 可合成的个数
    self.isHaveLimtedComposeItem = 0 -- 合成材料中是否有限制交易道具

    self:setLabelText("ItemNameLabel_1", "", materiaPanel)
    self:setLabelText("ItemNameLabel_2", "", materiaPanel)

    -- 合成材料
    for i = 1, #needItems do
        local itemPanel = self:getControl(string.format("ItemPanel_%d", i), nil , materiaPanel)
        local needComposeItem = {}
        local haveItemNum = InventoryMgr:getAmountByNameIsForeverBindBag(needItems[i]["name"], self:isCheck("CheckBox"))
        local haveItemNumUnint = math.floor(haveItemNum / needItems[i]["count"])
        if needItems[i].level and needItems[i].level >= 80 then
            -- 80以上级别首饰，需要指定，所以材料判断设置为满足个数
            haveItemNumUnint = 1
        end

        local itemShapePanel = self:getControl("ItemShapePanel", nil, itemPanel)
        if haveItemNumUnint < haveMinItemNum or haveMinItemNum == -1 then
            haveMinItemNum = haveItemNumUnint
        end

        needComposeItem["name"] = needItems[i]["name"]
        if haveItemNum > 999 then
            needComposeItem["count"] = string.format("*/%d",  needItems[i]["count"])
        else
            needComposeItem["count"] = string.format("%d/%d", haveItemNum, needItems[i]["count"])
        end
        needComposeItem["level"] = needItems[i]["level"]
        needComposeItem["isNeedSelect"] = needItems[i]["isNeedSelect"]

        -- 材料名字
        self:setLabelText("ItemNameLabel_" .. i, needComposeItem["name"], materiaPanel)


        if haveItemNumUnint < 1 then
            self:createItemPanel(needComposeItem, itemPanel, COLOR3.RED)
        else
            self:createItemPanel(needComposeItem, itemPanel, COLOR3.TEXT_DEFAULT)
        end

        local limitItemNum = 0
        if InventoryMgr:getAmountByNameForeverBind(needItems[i]["name"], true) > 0
            and self:isCheck("CheckBox")
            and (not needItems[i].level or needItems[i].level < 80) then
            -- 合成80级以上的首饰的首饰材料不计入增加限制交易天数的计算
            if InventoryMgr:getAmountByNameForeverBind(needItems[i]["name"], true) >  needItems[i]["count"] then
                limitItemNum =  needItems[i]["count"]
            else
                limitItemNum = InventoryMgr:getAmountByNameForeverBind(needItems[i]["name"], true)
            end

            self.isHaveLimtedComposeItem = self.isHaveLimtedComposeItem + limitItemNum
        end

        itemShapePanel.needItems = needItems[i]
        -- 道具弹出悬浮框
        if needItems[i]["isItem"] == true then
            self:bindTouchEndEventListener(itemShapePanel, self.showItemInfo, needComposeItem["name"])
        else
            -- 首饰
            self:bindTouchEndEventListener(itemShapePanel, self.showEquipmentInfo, needComposeItem["name"])
            if needItems[i].level and needItems[i].level >= 80 and not self.selectJewelry then
                -- 有选中首饰时，不清除选中首饰
                local addImage = self:getControl("AddImage", nil, itemPanel)
                addImage.needItems = needItems[i]
                self:bindTouchEndEventListener(addImage, self.showEquipmentInfo, needComposeItem["name"])
                self:setCtrlVisible("ItemShapePanel", false, itemPanel)
                self:setCtrlVisible("NoneImage", true, itemPanel)
            else
                -- 由于前面调了 self:createItemPanel 重设了选中首饰的图标，故需再重设一次选中首饰
                if self.selectJewelry then
                    self:setSelectJewelry(self.selectJewelry)
                end

                self:setCtrlVisible("ItemShapePanel", true, itemPanel)
                self:setCtrlVisible("NoneImage", false, itemPanel)
            end
        end
    end

    local itemPanel = self:getControl(string.format("ItemPanel_%d", 2), nil , materiaPanel)
    local touchPanel = self:getControl("ItemShapePanel", nil, itemPanel)
    if #needItems == 2 then
        self:setCtrlVisible("NoneImage", false, itemPanel)
        touchPanel:setTouchEnabled(true)
    else
        self:setCtrlVisible("NoneImage", true, itemPanel)
        touchPanel:setTouchEnabled(false)
    end

    -- 合成后的装备
    local composedEquip = {}
    composedEquip["name"] = jewelry["name"]
    composedEquip["count"] = haveMinItemNum
    composedEquip["level"] = jewelry["level"]
    if jewelry["level"] >= 90 then composedEquip["count"] = "" end
    local destPanel = self:getControl("UpgradeItemPanel", Const.UIPanel, composePanel)
    self:createItemPanel(composedEquip, destPanel)
    self:setLabelText("AttribLabel", jewelry["attrib"], destPanel)

    local attribPanel = self:getControl("AttribPanel")
    self:setLabelText("AttribLabel", jewelry["needItems"][1]["attrib"], attribPanel)

    local upGrade = tonumber(string.match(jewelry["attrib"], "(%d+)")) - tonumber(string.match(jewelry["needItems"][1]["attrib"], "(%d+)"))
    self:setLabelText("AttribPromoteLabel", upGrade .. "↑", materiaPanel)

    -- 刷新界面的时候，有选择的装备,刷新装备蓝属性
    if jewelry.level >= 80 then
        self:setBlueAtt(self.selectJewelry or jewelry)
    else
        self:setBlueAtt(nil)
    end

    -- 合成花费
    self:setCostPanel(jewelry.level)
    self:updateLayout("CostCashPanel")
    self:updateLayout("RightPanel")
    self:updateLayout("CostMaterialPanel_1")
    self.composeNum = haveMinItemNum
end

function JewelryUpgradeDlg:showItemInfo(sender, eventType, name)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(name, rect)
end

function JewelryUpgradeDlg:setBlueAtt(jewelry)
    local leftPanel = self:getControl("LeftPanel", Const.UIPanel, "CostMaterialPanel_2")
    local rightPanel = self:getControl("RightPanel", Const.UIPanel, "CostMaterialPanel_2")
    if not jewelry then
        for i = 1, MAX_ATT_COUNT do
            self:setLabelText("AttachAttribLabel" .. i, "", leftPanel)
            self:setLabelText("AttachAttribLabel" .. i, "", rightPanel)
        end
        return
    end

    local blueAtt = {}
    if jewelry.level >= 80 then
        -- 80是虚构的首饰
        blueAtt = {}
    else
        blueAtt = EquipmentMgr:getJewelryBule(jewelry)
    end

    for i = 1, MAX_ATT_COUNT do
        if blueAtt[i] then
            self:setLabelText("AttachAttribLabel" .. i, blueAtt[i], leftPanel)
            self:setLabelText("AttachAttribLabel" .. i, blueAtt[i], rightPanel)
        else
            self:setLabelText("AttachAttribLabel" .. i, "", leftPanel)
            if i == #blueAtt + 1 then
                self:setLabelText("AttachAttribLabel" .. i, CHS[4100263], rightPanel)
            else
                self:setLabelText("AttachAttribLabel" .. i, "", rightPanel)
            end
        end
    end
end

function JewelryUpgradeDlg:setSelectJewelry(jewelry)
    self.selectJewelry = jewelry

    local itemPanel = self:getControl(string.format("ItemPanel_%d", 1), nil , "CostMaterialPanel_2")
    self:createItemPanel({name = jewelry.name, level = jewelry.req_level, isLimit = InventoryMgr:isLimitedItem(jewelry)}, itemPanel, COLOR3.TEXT_DEFAULT)

    self:setBlueAtt(jewelry)

    self:setCtrlVisible("ItemShapePanel", true, itemPanel)
    self:setCtrlVisible("NoneImage", false, itemPanel)
end


function JewelryUpgradeDlg:showEquipmentInfo(sender, eventType, name)
    if self.destJewelry.level > 80 and not sender.needItems.isRes then
        local count = InventoryMgr:getAmountByNameIsForeverBindBag(name, self:isCheck("CheckBox"))
        if count <= 0 then
            gf:ShowSmallTips(string.format(CHS[4100264], self.destJewelry.level - 10, name))
            return
        end

        local dlg = DlgMgr:openDlg("SubmitJewelryDlg")
        dlg:setDataByName(name)
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    local item = gf:deepCopy(InventoryMgr:getItemInfoByName(name))
    local dlg = DlgMgr:openDlg("JewelryInfoDlg")
    local pos = item.pos or 6
    local item = dlg:getInitJewelry(pos, name)
    item.pos = nil
    dlg:setJewelryInfo(item, pos, true)
    dlg:setFloatingFramePos(rect)
end

function JewelryUpgradeDlg:setCostPanel(level)
    local costCash = EquipmentMgr:getJewelryXomposeCost(level)
    local moneyStr, fontColor = gf:getArtFontMoneyDesc(costCash)
    self:setNumImgForPanel("CostCashPanel", fontColor, moneyStr, false, LOCATE_POSITION.CENTER, 23)
    local meMoneyStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnCashPanel", meFontColor, meMoneyStr, false, LOCATE_POSITION.CENTER, 23)
end

function JewelryUpgradeDlg:createItemPanel(item, panel, color)
    local itemImage = self:getControl("ItemImage", Const.UIImage, panel)
    local icon = InventoryMgr:getIconByName(item["name"])

    if item.isNeedSelect and not self.selectJewelry then
     --   itemImage:loadTexture(ResMgr.ui.add_symbol, ccui.TextureResType.plistType)
        self:setLabelText("ItemNameLabel", CHS[4100265], panel)
        self:setCtrlVisible("AddImage", true, panel)
        itemImage:loadTexture(ResMgr:getItemIconPath(icon))
    else
        itemImage:loadTexture(ResMgr:getItemIconPath(icon))
        self:setItemImageSize("ItemImage", panel)
        self:setLabelText("ItemNameLabel", item["name"], panel)
        self:setCtrlVisible("AddImage", false, panel)
    end
    itemImage:setVisible(true)


    self:setNumImgForPanel("ItemLevelPanel", ART_FONT_COLOR.NORMAL_TEXT,item["level"], false, LOCATE_POSITION.LEFT_TOP, 23, panel)

    if color and color == COLOR3.RED then
        self:setNumImgForPanel("ItemNumPanel", ART_FONT_COLOR.RED,item["count"], false, LOCATE_POSITION.RIGHT_BOTTOM, 23, panel)
    else
        self:setNumImgForPanel("ItemNumPanel", ART_FONT_COLOR.NORMAL_TEXT,item["count"], false, LOCATE_POSITION.RIGHT_BOTTOM, 23, panel)
    end

--[[
    local itemNumLabel = self:getControl("ItemNumLabel", Const.UILabel, panel)
    itemNumLabel:setColor(color or COLOR3.TEXT_DEFAULT)
    if item.isNeedSelect then
        itemNumLabel:setString("")
    else
        itemNumLabel:setString(item["count"])
    end
    --]]


    if item["isLimit"]  then
        InventoryMgr:addLogoBinding(itemImage)
    else
        InventoryMgr:removeLogoBinding(itemImage)
    end

end

function JewelryUpgradeDlg:addSmallSelcelImage(sender)
    self.samllSelectImg:removeFromParent()
    sender:addChild(self.samllSelectImg)
end

function JewelryUpgradeDlg:addBigSelectImg(sender)
    self.bigSelectImg:removeFromParent()
    sender:addChild(self.bigSelectImg)

    if self.isOpen then
        self:setCtrlVisible("DownArrowImage", false, sender)
        self:setCtrlVisible("UpArrowImage", true, sender)
        self.bigSelectImg:setVisible(true)
    else
        self:setCtrlVisible("DownArrowImage", true, sender)
        self:setCtrlVisible("UpArrowImage", false, sender)
        self.bigSelectImg:setVisible(false)
    end
end

function JewelryUpgradeDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        --gf:ShowSmallTips("将优先使用限制交易道具合成。")
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    if self.slectJewelTag then
        JewelryUpgradeDlg:refreshPanel(self.slectJewelTag)
    end
end

function JewelryUpgradeDlg:onNoteButton(sender, eventType)
    local data = {one = CHS[4200605], isScrollToDef = true}
    DlgMgr:openDlgEx("JewerlyRuleNewDlg", data)
end

function JewelryUpgradeDlg:cleanup()
    self:releaseCloneCtrl("bigPanel")
    self:releaseCloneCtrl("sPanel")
    self:releaseCloneCtrl("bigSelectImg")
    self:releaseCloneCtrl("samllSelectImg")
    self.lastSelectTag = nil
    self.selectTag = nil
    self.slectJewelTag = nil
end

function JewelryUpgradeDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_UPGRADE_JEWELRY_OK == data.notify and self.slectJewelTag then
        local id = tonumber(data.para)

		local newJewelry = InventoryMgr:getItemById(id)
		if newJewelry and newJewelry.req_level >= 80 then
			DlgMgr:openDlgEx("JewelryShowDlg", {newJewelry, self.curUpgradeJewelry or self.selectJewelry})
		end

        self.selectJewelry = nil
        self:refreshPanel(self.slectJewelTag)
    end
end

function JewelryUpgradeDlg:MSG_UPDATE()
    if self.slectJewelTag and self.destJewelry then
        self:setCostPanel(self.destJewelry.level)
    end
end

function JewelryUpgradeDlg:MSG_INVENTORY(data)
    if self.slectJewelTag then
        JewelryUpgradeDlg:refreshPanel(self.slectJewelTag)
    end
end

function JewelryUpgradeDlg:getSelectItemBox(clickItem)
    if clickItem == "CheckBox" then
        if self:isCheck("CheckBox") then
            return
        else
            return self:getBoundingBoxInWorldSpace(self:getControl("CheckBox"))
        end
    end

    local listView =  self:getControl("JewelryListView", Const.UIListView)
    local panel = listView:getChildByTag(tonumber(clickItem))

    return self:getBoundingBoxInWorldSpace(panel)
end

function JewelryUpgradeDlg:youMustGiveMeOneNotify(param)
    if "limitEquip" == param then
        if self:isCheck("CheckBox") and self.isHaveLimtedComposeItem and self.isHaveLimtedComposeItem > 0 then
            GuideMgr:youCanDoIt(self.name, param)
        else
            GuideMgr:youCanDoIt(self.name, "")
        end
    else
        GuideMgr:youCanDoIt(self.name, param)
    end
end

return JewelryUpgradeDlg
