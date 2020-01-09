-- EquipmentIdentifyDlg.lua
-- Created by zhengjh Feb/20/2016
-- 装备鉴定

local EquipmentIdentifyDlg = Singleton("EquipmentIdentifyDlg", Dialog)
local EquipmentAtt = require(ResMgr:getCfgPath("EquipmentAttribute.lua"))
local RadioGroup = require("ctrl/RadioGroup")

local CONST_DATA =
{
    Colunm = 3,
}

-- 装备、宝石
local IDENTIFY_CHECKBOX = {
    "AttributeCheckBox",         -- 装备
    "GemCheckBox",               -- 宝石
}

local IDENTIFY_DISPLAY_PANEL = {
    AttributeCheckBox = "EquipmentIdentifyPanel",         -- 装备鉴定
    GemCheckBox = "GemPanel",                             -- 宝石鉴定
}

function EquipmentIdentifyDlg:init()
    self:bindListener("InfoButton", self.onInfoButton, "EquipmentIdentifyPanel")
    self:bindListener("InfoButton", self.onInfoGemButton, "GemPanel")
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("IdentifyButton1", self.onIdentifyButton1)
    self:bindListener("IdentifyButton2", self.onIdentifyButton2)
    self:bindListener("GemAppraisalButton_0", self.onIdentifyGem)

    self:bindCheckBoxListener("CheckBox", self.onAutoIdentifyCheckBox, "AutoIdentifyPanel")

    self.itemCell = self:getControl("ItemCellPanel")
    self.itemCell:retain()
    self.itemCell:removeFromParentAndCleanup()

    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.itemCell)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GENERAL_NOTIFY")

    -- 初值化天鉴神兵
    self:setIdentifyProgress()

    --  初值化数据
    self:initData(1)

    self:setCtrlVisible("EquipmentIdentifyPanel", false)
    self:setCtrlVisible("GemPanel", false)

    -- 初始化预下方可能产出的宝石
    self:setPreOutputGemByLevel()

    -- 初始化中级产出宝石
    self:setOutputGem()

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, IDENTIFY_CHECKBOX, self.onIdentifyType)
    self.radioGroup:setSetlctByName(IDENTIFY_CHECKBOX[1])
    self.identifyType = IDENTIFY_CHECKBOX[1]
    self:onIdentifyType(self:getControl(IDENTIFY_CHECKBOX[1]))
end

function EquipmentIdentifyDlg:onIdentifyType(sender, eventType)

    self:setCtrlVisible("EquipmentIdentifyPanel", false)
    self:setCtrlVisible("GemPanel", false)

    local panelName = sender:getName()

    self.identifyType = panelName
    local panel = self:getControl(IDENTIFY_DISPLAY_PANEL[panelName])
    if panel then panel:setVisible(true) end

    local selectId = 1

    local isResetForGem = false         -- 如果是宝石，70级以下的要排除
    if panelName == "GemCheckBox" and self.selcetItem and self.selcetItem.req_level < 70 then
        isResetForGem = true
    end

    if self.selcetItem and self.selcetItem.item_unique and not isResetForGem then
        selectId = self.selcetItem.item_unique
    end

    if isResetForGem then
        self.selcetItem = nil
    end

    self:initData(selectId)

    --gf:ShowSmallTips(sender:getName())
    self:stopAutoIdentify()
end

function EquipmentIdentifyDlg:onDlgOpened(param)
    if param[1] == CHS[4100438] then
        self.radioGroup:setSetlctByName(IDENTIFY_CHECKBOX[2])
        self:onIdentifyType(self:getControl(IDENTIFY_CHECKBOX[2]))
    end
end



function EquipmentIdentifyDlg:initData(selectId, panelName)
    if self.identifyType == "AttributeCheckBox" then
        self:initListPanel(InventoryMgr:getAllBagUnidentifiedEquip(), self.itemCell, selectId)
    elseif self.identifyType == "GemCheckBox" then
        self:initListPanel(EquipmentMgr:getUnidentifiedEquipForIdentifyGem(), self.itemCell, selectId)
    end
end

function EquipmentIdentifyDlg:stopAutoIdentify()
    self:setCtrlVisible("CostPanel", true)
    self:setCtrlVisible("AutoCostPanel", false)
    self.isAutoIdentify = false
    self:setCheck("CheckBox", false, "AutoIdentifyPanel")

    if self.autoIdentifyFlag then
        self.root:stopAction(self.autoIdentifyFlag)
        self.autoIdentifyFlag = nil
    end

end

function EquipmentIdentifyDlg:initListPanel(data, cellColne, selectId)
    local scroview = self:getControl("BagItemsScrollView")
    scroview:removeAllChildren()

    if not data or #data == 0 then
        self:setCtrlVisible("NoticePanel", true)
        self:stopAutoIdentify()
        return
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    local contentLayer = ccui.Layout:create()
    local line = math.floor(#data / CONST_DATA.Colunm)
    local left = #data % CONST_DATA.Colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * cellColne:getContentSize().height

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = CONST_DATA.Colunm
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * CONST_DATA.Colunm
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * cellColne:getContentSize().width
            local y = totalHeight - (i - 1) * cellColne:getContentSize().height
            cell:setPosition(x, y)
            cell:setTag(tag)
            self:initCellData(cell , data[tag])
            contentLayer:addChild(cell)

            -- 选中装备
            if selectId and (selectId == tag or selectId == data[tag].item_unique) then
                self:addItemSelcelImage(cell)
                self:initSelectItemInfo(data[tag])
                self.selcetItem = data[tag]
                self.selcetItem.selectPanel = cell
            end
        end
    end

    contentLayer:setContentSize(scroview:getContentSize().width, totalHeight)
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)
    scroview:setClippingEnabled(true)
    scroview:setBounceEnabled(true)

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end
end

function EquipmentIdentifyDlg:initCellData(cell, data)
    local imgPath = ResMgr:getItemIconPath(data.icon)
    self:setImage("IconImage", imgPath, cell)
    self:setItemImageSize("IconImage", cell)

    local iamge = self:getControl("IconImage", nil, cell)
    iamge:removeAllChildren()
    if InventoryMgr:isTimeLimitedItem(data) then
        InventoryMgr:addLogoTimeLimit(iamge)
    elseif InventoryMgr:isLimitedItem(data) then
        InventoryMgr:addLogoBinding(iamge)
    end

    if data and data.item_type == ITEM_TYPE.EQUIPMENT and data.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(iamge)

        if data.req_level then
            self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false,
                LOCATE_POSITION.LEFT_TOP, 21)
        end

        if data.amount and data.amount > 0 then
            self:setNumImgForPanel("IconImagePanel", ART_FONT_COLOR.NORMAL_TEXT, data.amount, false,
                LOCATE_POSITION.RIGHT_BOTTOM, 21, cell)
        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then

            if self.isAutoIdentify then return end


            self:addItemSelcelImage(cell)
            self.selcetItem = data
            self.selcetItem.selectPanel = cell
            self:initSelectItemInfo(data)
        end
    end

    cell:addTouchEventListener(listener)
end


function EquipmentIdentifyDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    local panel = self:getControl("IconImagePanel", nil, item)
    panel:addChild(self.itemSelectImg)
end

-- 设置装备鉴定
function EquipmentIdentifyDlg:setIdentifyEquip(item, isIdentify)
    local imgPath = ResMgr:getItemIconPath(item.icon)
    self:setImage("EquipmentImage", imgPath)
    self:setItemImageSize("EquipmentImage")

    local iamge = self:getControl("EquipmentImage")
    iamge:removeAllChildren()

    if item and item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(iamge)
    end

    --  未鉴定装备悬浮框
    local equipPanel = self:getControl("EquipmentImagePanel")
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local rect = self:getBoundingBoxInWorldSpace(sender)

            local equipType = item["equip_type"]

            if equipType then
                if (equipType >= 1 and equipType <= 3) or equipType == EQUIP.BOOT then      --  装备
                    if item.unidentified == 1 then
                        -- 未鉴定状态
                        InventoryMgr:showBasicMessageByItem(item, rect)
                else
                    InventoryMgr:showEquipByEquipment(item, rect, true)
                end
                end
            end
        end
    end
    equipPanel:addTouchEventListener(listener)
    self:setCtrlVisible("NoneEquipImage", false)

    -- 名字
    self:setLabelText("EquipmentNameLabel", item.name)

    -- 属性面板
    local panel = self:getControl("AttributePanel")
    if isIdentify then
        self:setIndentifyInfo(item)
        panel:setVisible(true)
        self:setCtrlVisible("NoticeLabel", false)
    else
        panel:setVisible(false)
        self:setLabelText("NoticeLabel", CHS[3002436])
        self:setCtrlVisible("NoticeLabel", true)
    end

    -- 显示金钱
    local cash = EquipmentMgr:getIndentifyCost(item, 1)
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(cash))
    self:setNumImgForPanel("CashPanel1", fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 23)

    local cash2 = EquipmentMgr:getIndentifyCost(item, 2)
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(cash2))
    self:setNumImgForPanel("CashPanel2", fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 23)

    self:updateLayout("OnePanel")
end

function EquipmentIdentifyDlg:resetItemIcon()
    self:setImagePlist("EquipmentImage", ResMgr.ui.touming)
    self:setItemImageSize("EquipmentImage")
    self:setLabelText("EquipmentNameLabel", "")
    local iamge = self:getControl("EquipmentImage")
    iamge:removeAllChildren()

    local panel = self:getControl("EquipmentIconPanel")
    local ctrl = self:getControl("IconImage", nil, panel)
    gf:resetImageView(ctrl)
    panel.item = nil
    self:setImagePlist("IconImage", ResMgr.ui.touming, panel)
    self:setItemImageSize("IconImage", panel)
    self:setLabelText("EquipmentNameLabel", "", "SizePanel", COLOR3.TEXT_DEFAULT)
    InventoryMgr:removeLogoUnidentified(ctrl)
end

-- 宝石鉴定
function EquipmentIdentifyDlg:setGemIdentify(item)
    -- 未鉴定装备图标
    local imgPath = ResMgr:getItemIconPath(item.icon)
    local panel = self:getControl("EquipmentIconPanel")
    local ctrl = self:getControl("IconImage", nil, panel)
    gf:resetImageView(ctrl)
    panel.item = item
    self:setImage("IconImage", imgPath, panel)
    self:setItemImageSize("IconImage", panel)

    self:bindTouchEndEventListener(panel, function ()
        if panel.item then
            local rect = self:getBoundingBoxInWorldSpace(panel)
            InventoryMgr:showBasicMessageByItem(panel.item, rect)
        end
    end)

    -- 未鉴定标记
    if item and item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(ctrl)
    end

    -- 未鉴定装备名称
    self:setLabelText("EquipmentNameLabel", item.name, "SizePanel", COLOR3.TEXT_DEFAULT)
    self:updateLayout("SizePanel")

    -- 可能鉴定出的宝石
    self:setPreOutputGemByLevel(item.req_level)

    -- 鉴定产出宝石icon
    self:setOutputGem()

    -- 鉴定消耗金钱
    local cash = EquipmentMgr:getIdentifyCostByLevel(item.req_level)
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(cash))
    self:setNumImgForPanel("GemCashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
end

function EquipmentIdentifyDlg:setPreOutputGemByLevel(req_level)
    local retGem = EquipmentMgr:getIdentifyGemByLevel(req_level)
    for i = 1, 2 do
        local panel = self:getControl("GemIconPanel_" .. i)
        local image = self:getControl("IconImage", nil, panel)
        panel.gemName = retGem[i]
        if retGem[i] then
            local gemPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(retGem[i]))
            image:loadTexture(gemPath)
            gf:setItemImageSize(image)
            gf:grayImageView(image)

            self:setCtrlVisible("IconImage", true, panel)
            self:setCtrlVisible("BNoneImage", false, panel)
        else
            gf:resetImageView(image)

            self:setCtrlVisible("IconImage", false, panel)
            self:setCtrlVisible("BNoneImage", true, panel)
        end

        self:bindTouchEndEventListener(panel, function ()
            if panel.gemName then
                local rect = self:getBoundingBoxInWorldSpace(panel)
                InventoryMgr:showBasicMessageDlg(panel.gemName, rect)
            end
        end)
    end
end

    -- 鉴定产出宝石icon
function EquipmentIdentifyDlg:setOutputGem(name)
    local panel = self:getControl("ResultIconPanel")
    local image = self:getControl("IconImage", nil, panel)
    panel.gemName = name
    if not name then
        self:setCtrlVisible("IconImage", false, panel)
        self:setCtrlVisible("BNoneImage", true, panel)
    else
        local gemPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(name))
        image:loadTexture(gemPath)
        gf:setItemImageSize(image)
        self:setCtrlVisible("IconImage", true, panel)
        self:setCtrlVisible("BNoneImage", false, panel)
    end

    self:bindTouchEndEventListener(panel, function ()
        if panel.gemName then
            local rect = self:getBoundingBoxInWorldSpace(panel)
            InventoryMgr:showBasicMessageDlg(panel.gemName, rect)
        end
    end)
end

function EquipmentIdentifyDlg:initSelectItemInfo(item, isIdentify)
    if item == nil then return end

    if self.identifyType == "AttributeCheckBox" then
        self:setIdentifyEquip(item, isIdentify)
    elseif self.identifyType == "GemCheckBox" then
        self:setGemIdentify(item)
    end
end

function EquipmentIdentifyDlg:setIdentifyProgress(isNeedTips)
    -- 天鉴神兵
    local value = Me:queryBasicInt("equip_identify")
    local prencet = value / 100
    self:setProgressBar("ProgressBar", prencet, 100)
    self:setLabelText("ComLabel", prencet .. "%")
    self:setLabelText("ComLabel_1", prencet .. "%")

    if isNeedTips and value == 10000 and self.isAutoIdentify then
        gf:ShowSmallTips(CHS[4200577])
        ChatMgr:sendMiscMsg(CHS[4200577])

        self:stopAutoIdentify()
    end
end

-- 鉴定属性面板
function EquipmentIdentifyDlg:setIndentifyInfo(equip)
    -- 获取装备名称颜色         各个颜色属性
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)
    local blueAttTab = self:getColorAtt(blueTab, "blue", equip)
    local pinkAttTab = self:getColorAtt(pinkTab, "pink", equip)
    local yellowAttTab = self:getColorAtt(yellowTab, "yellow", equip)
    local allAttribTab = {}

    for _,v in pairs(blueAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(pinkAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(yellowAttTab) do
        table.insert(allAttribTab, v)
    end

    local count = #allAttribTab

    for i = 1,5 do
        local desPanel = self:getControl("AttributePanel" .. i)
        if not desPanel then return end

        if i <= count then
            self:setCtrlVisible("AttributePanel" .. i, true)
            self:setDescript(allAttribTab[i].str, desPanel, allAttribTab[i].color)
        else
            desPanel:removeAllChildren()
        end
    end
end

function EquipmentIdentifyDlg:setDescript(descript, panel, color)
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:updateNow()
    --
    textCtrl:setDefaultColor(color.r, color.g, color.b)
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size.width - textW) * 0.5, size.height - (size.height - 19) * 0.5)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end

-- 获取装备鉴定属性
function EquipmentIdentifyDlg:getColorAtt(attTab, colorStr, equip)
    local destTab = {}
    local color
    local maxValue
    local colorType = 0         -- 蓝、粉、金   需要显示强化完成度
    if colorStr == "blue" then
        color = COLOR3.EQUIP_BLUE
        colorType = 1
    elseif colorStr == "pink" then
        color = COLOR3.EQUIP_PINK
        colorType = 2
    elseif colorStr == "yellow" then
        color = COLOR3.YELLOW
        colorType = 3
    end
    --]]
    for i, att in pairs(attTab) do
        local bai = ""
        if EquipmentAtt[CHS[3002437]][att.field] then bai = "%" end

        if EquipmentAtt[att.field] ~= nil then
            local str = EquipmentAtt[att.field] .. " " .. att.value .. bai
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""

            local completion = EquipmentMgr:getAttribCompletion(equip, att.field, colorType)
            if colorType ~= 0 and completion and completion ~= 0 then
                str = str .. "/" .. maxValue .. bai .. " #R(+" .. completion * 0.01 .. "%)#n"
                table.insert(destTab, {str = str, color = color, basic = 1})
            else
                str = str .. "/" .. maxValue .. bai
                table.insert(destTab, {str = str, color = color})
            end
        end
    end

    return destTab
end

function EquipmentIdentifyDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("EquipmentRuleDlg")
    dlg:showType("EquipmentIdentifyDlg")
end

function EquipmentIdentifyDlg:onInfoGemButton(sender, eventType)
    local dlg = DlgMgr:openDlg("EquipmentRuleDlg")
    dlg:showType("GemIdentifyRuleDlg")
end



function EquipmentIdentifyDlg:onStopButton(sender, eventType)
    self:stopAutoIdentify()
end

function EquipmentIdentifyDlg:onAutoIdentifyCheckBox(sender, eventType)

end


function EquipmentIdentifyDlg:onIdentifyGem(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 物品判断
    if not self.selcetItem then
        gf:ShowSmallTips(CHS[3002439])
        return
    end

    local item = InventoryMgr:getItemByPos(self.selcetItem.pos)
    if not item or item.name ~= self.selcetItem.name then
        gf:ShowSmallTips(CHS[4101001])
        self:resetItemIcon()
        self:initData(1)
        self.selcetItem = nil
        return
    end

    -- 金钱判断
    local cost = EquipmentMgr:getIdentifyCostByLevel(self.selcetItem.req_level)
    if Me:queryBasicInt("cash") < cost then
        gf:askUserWhetherBuyCash()
    else

        -- 背包判断
        local emptyCount = InventoryMgr:getEmptyPosCount()
        if emptyCount == 0 then
            gf:ShowSmallTips(CHS[4200220])
            return
        end

        -- 发送鉴定指令
        local moenyStr, color = gf:getMoneyDesc(cost, false)
        gf:confirm(string.format(CHS[4100434], moenyStr, self.selcetItem.name), function ()
            -- 可能存在消息延时，导致self.selcetItem被清为nil
            if self.selcetItem then
                EquipmentMgr:identyfyGem(self.selcetItem.pos)
            end
        end)
    end
end

function EquipmentIdentifyDlg:onIdentifyButton1(sender, eventType)
    if not self:indetifyEquipment(1) then
        self:stopAutoIdentify()
    end
end

function EquipmentIdentifyDlg:onIdentifyButton2(sender, eventType)
    if not self:indetifyEquipment(2) then
        self:stopAutoIdentify()
    end
end

function EquipmentIdentifyDlg:indetifyEquipment(type)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.selcetItem then
        gf:ShowSmallTips(CHS[3002439])
        return
    end

    local item = InventoryMgr:getItemByPos(self.selcetItem.pos)
    if not item or item.name ~= self.selcetItem.name then
        gf:ShowSmallTips(CHS[4101001])
        self:resetItemIcon()
        self:initData(1)
        self.selcetItem = nil
        return
    end

    local cost = EquipmentMgr:getIndentifyCost(self.selcetItem, type)
    if Me:queryBasicInt("cash") < cost then
        gf:askUserWhetherBuyCash()
        return
    else

                -- 安全锁判断
        if self:checkSafeLockRelease("indetifyEquipment", type) then
            return
        end

        -- 如果自动鉴定的checkBox开启
        self:setCtrlVisible("CostPanel", not self:isCheck("CheckBox", "AutoIdentifyPanel"))
        self:setCtrlVisible("AutoCostPanel", self:isCheck("CheckBox", "AutoIdentifyPanel"))

        if self:isCheck("CheckBox", "AutoIdentifyPanel") then
            self.isAutoIdentify = type

            if type == 1 then
                self:setLabelText("NormalIdentifyLabel", CHS[4200579])
            elseif type == 2 then
                self:setLabelText("NormalIdentifyLabel", CHS[4200580])
            end
        end

        -- 若玩家当前包裹空间不足1格，则予以如下弹出提示：
        if InventoryMgr:getEmptyPosCount() == 0 then
            gf:ShowSmallTips(string.format( CHS[4200581], 1 ))
            return
        end

        -- 发送鉴定指令
        local pos = self.selcetItem.pos
        local para = self.isAutoIdentify and "1" or "0"
        if type == 1 then -- 普通鉴定
            EquipmentMgr:identifyEquip(pos, para)
        else
            EquipmentMgr:delicateIdentifyEquip(pos, para)
        end

        return true
    end
end

function EquipmentIdentifyDlg:MSG_UPDATE(data)
    if not data.equip_identify then return end
    self:setIdentifyProgress(true)
end

function EquipmentIdentifyDlg:MSG_GENERAL_NOTIFY(data)

    local function identifyDown(rightNow)
        -- body
        if self.selcetItem then
            local panel = self.selcetItem.selectPanel
            self.selcetItem = InventoryMgr:getItemByPos(self.selcetItem.pos)
            self:initCellData(panel, self.selcetItem)
            self.selcetItem.selectPanel = panel

            if self.isAutoIdentify then

                if rightNow then
                    --self:stopAutoIdentify()
                    if self.identifyType == "AttributeCheckBox" then
                        if not self:indetifyEquipment(self.isAutoIdentify) then
                            self:stopAutoIdentify()
                        end
                    end
                else
                    self.autoIdentifyFlag = performWithDelay(self.root, function ( )
                        if self.identifyType == "AttributeCheckBox" then
                            if not self:indetifyEquipment(self.isAutoIdentify) then
                                self:stopAutoIdentify()
                            end
                        end
                    end, 2)
                end
            end
        end
    end

    if NOTIFY.NOTIFY_BAOZANG_READY_SEARCH == data.notify then
        -- 收到藏宝图消息，停止鉴定
        self:stopAutoIdentify()
    elseif NOTIFY.NOTIFY_EQUIP_IDENTIFY == data.notify then
        local list = gf:split(data.para, "|")
        local item = InventoryMgr:getItemById(tonumber(list[1]))
        if self.selcetItem and self.selcetItem.amount > 1 then
            identifyDown()
        else
            if self.isAutoIdentify then
                local tempSelectItem = gf:deepCopy(self.selcetItem)
                local tag = self.selcetItem.selectPanel:getTag()
                self.selcetItem = nil


                if #InventoryMgr:getAllBagUnidentifiedEquip() < tag then
                    tag = 1
                end

                self:initData(tag)

                if tempSelectItem and self.selcetItem then
                    if self.selcetItem.req_level == tempSelectItem.req_level then
                        identifyDown()
                    else
                        local tips = string.format( CHS[4200578], self.selcetItem.req_level, tempSelectItem.req_level)
                        gf:confirm(tips, function ()
                            -- body
                            identifyDown(true)
                        end, function ()
                            -- body
                            self:stopAutoIdentify()
                        end, nil, nil, nil, true, nil, "EquipmentIdentifyDlg")
                    end
                else
                    self:stopAutoIdentify()
                    self:initData()
                    self.selcetItem = nil
                end
            else
                self:initData()
                self.selcetItem = nil
            end
        end

        self:initSelectItemInfo(item, true)
    elseif NOTIFY.NOTIFY_EQUIP_IDENTIFY_GEM == data.notify then
        if self.selcetItem and self.selcetItem.amount > 1 then
            local panel = self.selcetItem.selectPanel
            self.selcetItem = InventoryMgr:getItemByPos(self.selcetItem.pos)
            self:initCellData(panel, self.selcetItem)
            self.selcetItem.selectPanel = panel
        else
            self:initData()
            self.selcetItem = nil
        end

        self:setOutputGem(data.para)
        local panel = self:getControl("EquipmentIconPanel")
        panel.item = nil
        local ctrl = self:getControl("IconImage", nil, panel)
        gf:grayImageView(ctrl)
    end
end

function EquipmentIdentifyDlg:cleanup()
    self.selcetItem = nil
    self.isAutoIdentify = false
    self:releaseCloneCtrl("itemCell")
    self:releaseCloneCtrl("itemSelectImg")
end

return EquipmentIdentifyDlg
