-- JewelryRefineDlg.lua
-- Created by huangzz Dec/17/2016
-- 首饰重铸界面

local JewelryRefineDlg = Singleton("JewelryRefineDlg", Dialog)

local CLASS_JEWELRY =
{
    [1] = CHS[3002887],
    [2] = CHS[3002888],
    [3] = CHS[3002889],
}

-- 不同的等级可附加的属性数量
local LEVEL_ATTACH_COUNT =
{
    [80] = 1,
    [90] = 2,
    [100] = 3,
}

local CLASS_BALDRIC = 100      -- 玉佩
local CLASS_NECKLACE = 200     -- 项链
local CLASS_WRIST  = 300       -- 手镯

function JewelryRefineDlg:init()
    self:bindListener("RefineButton", self.onRefineButton)
    self:bindListViewListener("JewelryListView", self.onSelectJewelryListView)
    
    self:blindLongPress("ItemImage", self.onShowJewelryInfo, self.onAddJewelry,"ItemPanel_1")
    self:blindLongPress("ItemImage", self.onShowJewelryInfo, self.onAddJewelry,"ItemPanel_2")
    self:blindLongPress("ItemImage", self.onShowJewelryInfo, self.onAddJewelry,"ItemPanel_3")
    self:blindLongPress("ItemImage", self.onShowJewelryInfo, nil, "ItemPanel")
    
    self:blindLongPress("AddImage", nil, self.onAddJewelry,"ItemPanel_1")
    self:blindLongPress("AddImage", nil, self.onAddJewelry,"ItemPanel_2")
    self:blindLongPress("AddImage", nil, self.onAddJewelry,"ItemPanel_3")
    
    self:setCtrlEnabled("RefineButton", false)
    
    self.bigPanel = self:getControl("BigPanel", Const.UIPanel)
    self.bigPanel:retain()
    self.bigPanel:removeFromParent()
    
    self.bigSelectImg = self:getControl("BChosenEffectImage", Const.UIPanel, self.bigPanel)
    self.bigSelectImg:retain()
    self.bigSelectImg:removeFromParent()

    self.sPanel = self:getControl("SPanel", Const.UIPanel)
    self.sPanel:retain()
    self.sPanel:removeFromParent()
    
    self.smallSelectImg = self:getControl("SChosenEffectImage", Const.UIPanel, self.sPanel)
    self.smallSelectImg:retain()
    self.smallSelectImg:removeFromParent()

    self:initData()
    
    -- 首饰重铸规则的按钮
    self:getControl("NoteButton"):setLocalZOrder(1)
    self:bindListener("NoteButton", self.onNoteButton)
    
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_UPDATE")
end

function JewelryRefineDlg:initData()
    self.checkedJewelrys = {}
    self.checkedCount = 0
    self.limtedJewelryNum = 0
    self.allRefineJewelry = EquipmentMgr:getAllRefineJewelry()
    
    self:setCtrlVisible("AddImage", false, "ItemPanel_1")
    self:setCtrlVisible("AddImage", false, "ItemPanel_2")
    self:setCtrlVisible("AddImage", false, "ItemPanel_3")
    
    self:setLabelText("ItemNameLabel", "", "ItemPanel")
    self:setLabelText("AttribLabel", "")
    
    self:initListView(100)
    self:setCostPanel(0)
    self:setBlueAtt(nil)
end

function JewelryRefineDlg:initListView(tag)
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
    for i = 1, #CLASS_JEWELRY do
        local bigCell = self.bigPanel:clone()
        bigCell:setTag(CLASS_BALDRIC *i )
        self:setLabelText("Label", CLASS_JEWELRY[i], bigCell)
        listView:addChild(bigCell)

        if class == i then
            self:showBigSelectImg(bigCell)
        end
        
        -- 二级菜单
        if class == i and self.isOpen then
            local itemList = self.allRefineJewelry[CLASS_JEWELRY[i]]
            for j = 1, #itemList do
                local cellS = self.sPanel:clone()
                cellS:setTag(CLASS_BALDRIC *i + j)
                self:setLabelText("Label", itemList[j]["level"] ..CHS[3002890], cellS)
                listView:pushBackCustomItem(cellS)
            end
        end
    end

    listView:getParent():requestDoLayout()
    listView:requestRefreshView()
    listView:doLayout()
    
end

function JewelryRefineDlg:getTypes(tag)
    local class = math.floor(tag / CLASS_BALDRIC)
    local secondType = tag % CLASS_BALDRIC
    return class, secondType
end

function JewelryRefineDlg:showSmallSelcelImage(sender)
    self.smallSelectImg:removeFromParent()
    sender:addChild(self.smallSelectImg)
end

function JewelryRefineDlg:showBigSelectImg(sender)
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


function JewelryRefineDlg:refreshPanel(tag)
    if not self.selectJewelry then
        self:setCtrlEnabled("RefineButton", true)
    end
    
    self.checkedJewelrys = {}
    self.checkedCount = 0
    self.limtedJewelryNum = 0
    
    local itemImage = self:getControl("ItemImage", nil, "ItemPanel")
    InventoryMgr:removeLogoBinding(itemImage)
    
    -- 保存当前要重铸的首饰的标签
    local class, secondType = self:getTypes(tag)
    local jewelry = self.allRefineJewelry[CLASS_JEWELRY[class]][secondType]
    self.selectJewelry = jewelry
    
    self.bagJewelrys = InventoryMgr:getItemByName(jewelry.name, false, true)

    self:createItemPanel(nil, "ItemPanel_1")
    self:createItemPanel(nil, "ItemPanel_2")
    self:createItemPanel(nil, "ItemPanel_3")

    -- 重铸后的装备
    local icon = InventoryMgr:getIconByName(jewelry["name"])
    self:setCtrlVisible("ItemShapePanel", true, "ItemPanel")
    self:setCtrlVisible("NoneImage", false, "ItemPanel")
    
    self:setImage("ItemImage", ResMgr:getItemIconPath(icon), "ItemPanel")
    self:setItemImageSize("ItemImage", "ItemPanel")
    self:setLabelText("ItemNameLabel", jewelry["name"], "ItemPanel")
    self:setLabelText("LevelLabel", jewelry["level"]..CHS[3002890], "ItemPanel")
    self:setLabelText("AttribLabel", jewelry["attrib"])
    
    self:setBlueAtt(jewelry)

    -- 合成花费
    self:setCostPanel(jewelry.level)
end

-- item = nil 时，显示‘+’图片，否则显示对应的首饰  
function JewelryRefineDlg:createItemPanel(item, panel)
    self:setCtrlVisible("AddImage", true, panel)
    local itemImage = self:getControl("ItemImage", nil, panel)
    
    if item then
        local icon = InventoryMgr:getIconByName(item["name"])
        
        self:setImage("ItemImage", ResMgr:getItemIconPath(icon), panel)
        self:setItemImageSize("ItemImage", panel)
        self:setLabelText("ItemNameLabel", item["name"], panel)
        

        if item["level"]  then
            self:setLabelText("LevelLabel", item["level"]..CHS[3002890], panel)
        else
            self:setLabelText("LevelLabel", "", panel)
        end
        
        if InventoryMgr:isLimitedItem(item)  then             
            InventoryMgr:addLogoBinding(itemImage)
        else
            InventoryMgr:removeLogoBinding(itemImage)
        end
        
        self:setCtrlVisible("NoneImage", false, panel)
        self:setCtrlVisible("ItemShapePanel", true, panel)
    else
        self:setImagePlist("AddImage", ResMgr.ui.add_symbol, panel)
        self:setLabelText("ItemNameLabel", CHS[5400016], panel)
        
        self:setCtrlVisible("ItemShapePanel", false, panel)
        
        self:setCtrlVisible("NoneImage", true, panel)
        self:setCtrlVisible("ItemShapePanel", false, panel)
    end
end

function JewelryRefineDlg:setCostPanel(level)
    local costCash = EquipmentMgr:getJewelryUpgradeCost(level)
    local moneyStr, fontColor = gf:getArtFontMoneyDesc(costCash)
    self:setNumImgForPanel("CostCashPanel", fontColor, moneyStr, false, LOCATE_POSITION.CENTER, 23)
    local meMoneyStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnCashPanel", meFontColor, meMoneyStr, false, LOCATE_POSITION.CENTER, 23)
end

function JewelryRefineDlg:showItemInfo(sender, eventType, name)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(name, rect)
end

-- 显示附加属性
function JewelryRefineDlg:setBlueAtt(jewelry)
    local rightPanel = self:getControl("RightPanel", Const.UIPanel, "CostMaterialPanel")
    
    for i = 1, 3 do
        self:setLabelText("AttachAttribLabel" .. i, "", rightPanel)
    end
    
    if not jewelry then
        return
    end
    
    if not jewelry.extra then
        for i = 1, LEVEL_ATTACH_COUNT[jewelry.level] do
            self:setLabelText("AttachAttribLabel" .. i, CHS[5400015], rightPanel)
        end
        
        return
    end

    local blueAtt = EquipmentMgr:getJewelryBule(jewelry)

    for i = 1, #blueAtt do
        if blueAtt[i] then
            self:setLabelText("AttachAttribLabel" .. i, blueAtt[i], rightPanel)
        end
    end
end

-- 重铸
function JewelryRefineDlg:onRefineButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[5400009])
        return
    end

    if self.checkedCount < 3 then
        gf:ShowSmallTips(string.format(CHS[5400010], InventoryMgr:getUnit(self.selectJewelry.name), self.selectJewelry.name))
        return
    end
    
    local costMoney = EquipmentMgr:getJewelryUpgradeCost(self.selectJewelry.level)
    local para = self.selectJewelry.name .. ":"
    
    local cou = 1
    for _, v in pairs(self.checkedJewelrys) do
        para = para .. v.pos
        if cou < 3 then
            para = para .. "|"
        end
        
        cou = cou + 1
    end
    
    if self.limtedJewelryNum > 0 then
        local days = self.limtedJewelryNum * 10
        gf:confirm(string.format(CHS[5400012], days) , function()
            if gf:checkEnough("cash", costMoney) then
                gf:CmdToServer("CMD_UPGRADE_EQUIP", {pos = 0, type = Const.EQUIP_RECAST_HIGHER_JEWELRY, para = para})
            end
        end)
    else
        if gf:checkEnough("cash", costMoney) then
            gf:CmdToServer("CMD_UPGRADE_EQUIP", {pos = 0, type = Const.EQUIP_RECAST_HIGHER_JEWELRY, para = para})
        end
    end
    
end

function JewelryRefineDlg:onNoteButton(sender, eventType)
    DlgMgr:openDlg("JewelryRefineRuleDlg")
end

function JewelryRefineDlg:onSelectJewelryListView(sender, eventType)
    local tag = self:getListViewSelectedItemTag(sender)
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
        self:showSmallSelcelImage(item)
        return
    elseif class ~= 0 then         -- 一级菜单
        self.isOpen = not self.isOpen
    end

    performWithDelay(sender, function() self:initListView(tag) end, 0)
end

function JewelryRefineDlg:onAddJewelry(sender, eventType)
    if #self.bagJewelrys < 3 then
        gf:ShowSmallTips(CHS[5400008])
        return
    end
    
    local dlg = DlgMgr:openDlg('SubmitRefineJewelryDlg')
    if not self.checkedJewelrys["ItemPanel_1"] then
        dlg:setData(self.bagJewelrys, {})
    else
        dlg:setData(self.bagJewelrys, self.checkedJewelrys)
    end
end

-- 显示首饰信息
function JewelryRefineDlg:onShowJewelryInfo(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local parent = sender:getParent():getParent()

    if not self.checkedJewelrys[parent:getName()] then 
        return
    end
    
    InventoryMgr:showJewelryFloatDlg(self.checkedJewelrys[parent:getName()], rect, true)
end

-- 显示从提交框获取三个的首饰
function JewelryRefineDlg:showRefineJewelry(jewelrys)
    self.checkedJewelrys = {}
    self.checkedCount = 0
    self.limtedJewelryNum = 0
    for _, v in pairs(jewelrys) do
        self.checkedCount = self.checkedCount + 1
        
        local ctrlName =  "ItemPanel_" .. self.checkedCount
        self.checkedJewelrys[ctrlName] = v 
        
        self:createItemPanel(v, ctrlName)
        
        if InventoryMgr:isLimitedItemForever(v) then
            self.limtedJewelryNum = self.limtedJewelryNum + 1
        end
    end
    
    self:setBlueAtt(self.selectJewelry)
    
    local itemImage = self:getControl("ItemImage", nil, "ItemPanel")
    InventoryMgr:removeLogoBinding(itemImage)
end

function JewelryRefineDlg:MSG_GENERAL_NOTIFY(data)
    if data.notify == NOTIFY.NOTIFY_HIGHER_JEWELRY_RECAST_OK then
        local jewelry = InventoryMgr:getItemById(tonumber(data.para))
        self:setBlueAtt(jewelry)
        
        self:createItemPanel(nil, "ItemPanel_1")
        self:createItemPanel(nil, "ItemPanel_2")
        self:createItemPanel(nil, "ItemPanel_3")
        
        self.checkedJewelrys = {}
        self.checkedCount = 0
        self.limtedJewelryNum = 0
        
        self.checkedJewelrys["ItemPanel"] = jewelry
        
        local itemImage = self:getControl("ItemImage", nil, "ItemPanel")
        if InventoryMgr:isLimitedItem(jewelry)  then             
            InventoryMgr:addLogoBinding(itemImage)
        else
            InventoryMgr:removeLogoBinding(itemImage)
        end
        
        self.bagJewelrys = InventoryMgr:getItemByName(self.selectJewelry.name, false, true)
    end
end

function JewelryRefineDlg:MSG_UPDATE()
    if self.selectJewelry then
        self:setCostPanel(self.selectJewelry.level)
    end
end

function JewelryRefineDlg:cleanup()
    self:releaseCloneCtrl("bigPanel")
    self:releaseCloneCtrl("sPanel")
    self:releaseCloneCtrl("bigSelectImg")
    self:releaseCloneCtrl("smallSelectImg")
    
    self.lastSelectTag = nil
    self.selectTag = nil
    self.selectJewelry = nil
    self.isOpen = false
end

return JewelryRefineDlg
