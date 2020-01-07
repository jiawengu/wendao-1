-- ChooseItemDlg.lua
-- Created by song Aug/11/2016
-- 赠送选择道具界面

local ChooseItemDlg = Singleton("ChooseItemDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local GridPanel = require('ctrl/GridPanel')

local CAN_NOT_GIVE_ITEM_LIST = require(ResMgr:getCfgPath("CanNotGiveItem.lua"))

local checkBoxs = {"ItemTagCheckBox", "PetTagCheckBox", "ChangeCardDlgCheckBox"}

-- checkBox对应的显示Panel
local ItemsPanel = {
    ["ItemTagCheckBox"] = "BagItemListPanel",
    ["PetTagCheckBox"] = "PetListPanel",
    ["ChangeCardDlgCheckBox"] = "ChangeCardListPanel",
}

-- checkBox对应的数据是否已经读取过，读取过就不重复读取
ChooseItemDlg.isLoad = {
    ["ItemTagCheckBox"] = false,
    ["PetTagCheckBox"] = false,
    ["ChangeCardDlgCheckBox"] = false,
}

local BAG_COW   = 4                     -- 背包界面列
local MAGIN     = 8

local TIANSHENG_SKILL_CUT_HEIGHT = 32   -- 天生技能如果只有一个，裁减掉的大小

local BASE_ATTRIBUTE_LABEL_HEIGHT = 27   -- 点击装备时右侧界面中每条属性描述的高度

-- 赠送界面首饰最多属性数量
local JEWELRY_MAX_ATTRIB = 8

function ChooseItemDlg:init()
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    -- 控件显示初始化
    self:setCtrlVisibleInit()
    self.selectPet = nil
    self.selectCard = nil
    self.selectItem = nil
    self.isLoad = {}
    self.tianshengPanelSize = self:getCtrlContentSize("SkillPanel", "PetPanel")
    self.petPanelSize = self:getCtrlContentSize("MainPanel", "PetPanel")

    -- 克隆项初始化
    self:clonePanel()

    -- 右侧滚动控件初始化
    self:setScrollViewInit()

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, checkBoxs, self.onCheckBox)
    self.radioGroup:selectRadio(1, true)
    self:onCheckBox(self:getControl(checkBoxs[1]))

    self:hookMsg("MSG_COMPLETE_GIVING")
end

-- 控件显示初始化
function ChooseItemDlg:setCtrlVisibleInit()
    local panel = self:getControl("BagItemPanel")
    for checkBox, ctrlName in pairs(ItemsPanel) do
        self:setCtrlVisible(ctrlName, false, panel)
    end

    self:setCtrlVisible("ConfirmButton", true)
    self:setDisplayInfoVisibleFlase()
end

function ChooseItemDlg:setDisplayInfoVisibleFlase()
    local AttriPanel = self:getControl("AttributePanel")
    self:setCtrlVisible("JewelryPanel", false, AttriPanel)
    self:setCtrlVisible("EquipPanel", false, AttriPanel)
    self:setCtrlVisible("ItemPanel", false, AttriPanel)
    self:setCtrlVisible("PetPanel", false, AttriPanel)
    self:setCtrlVisible("ChangeCardPanel", false, AttriPanel)
    self:setCtrlVisible("ArtifactPanel", false, AttriPanel)
    self:setCtrlVisible("FashionDressPanel", false, AttriPanel)
end

-- 右侧滚动控件初始化
function ChooseItemDlg:setScrollViewInit()
    local attPanel = self:getControl("AttributePanel")

    local petPanel = self:getControl("PetPanel", nil, attPanel)
    local petScrollCtrl = self:getControl("PetScrollView", nil, petPanel)
    local petInnerSize = self:getControl("MainPanel", nil, petPanel):getContentSize()
    petScrollCtrl:setInnerContainerSize(petInnerSize)
end

-- 克隆项初始化
function ChooseItemDlg:clonePanel()
    self.unitPetPanel = self:getControl("PetCellPanel", Const.UIPanel)
    self.unitPetPanel:retain()
    self.unitPetPanel:removeFromParent()

    self.unitPetSelectImage = self:getControl("ChosenEffectImage", Const.UIImage, self.unitPetPanel)
    self.unitPetSelectImage:retain()
    self.unitPetSelectImage:removeFromParent()

    self.unitCardPanel = self:getControl("CardCellPanel", Const.UIPanel)
    self.unitCardPanel:retain()
    self.unitCardPanel:removeFromParent()

    self.unitCardSelectImage = self:getControl("ChosenEffectImage", Const.UIImage, self.unitCardPanel)
    self.unitCardSelectImage:retain()
    self.unitCardSelectImage:removeFromParent()

    self.unitItemPanel = self:getControl("ItemPanel")
    self.unitItemPanel:retain()
    self.unitItemPanel:removeFromParentAndCleanup()

    self.unitItemSelectImage = self:getControl("ChosenEffectImage", Const.UIImage, self.unitItemPanel)
    self.unitItemSelectImage:retain()
    self.unitItemSelectImage:removeFromParentAndCleanup()
end

function ChooseItemDlg:cleanup()
    self:releaseCloneCtrl("unitPetPanel")
    self:releaseCloneCtrl("unitPetSelectImage")

    self:releaseCloneCtrl("unitCardPanel")
    self:releaseCloneCtrl("unitCardSelectImage")

    self:releaseCloneCtrl("unitItemPanel")
    self:releaseCloneCtrl("unitItemSelectImage")
end

-- 点击checkBox事件。 背包、宠物、卡套
function ChooseItemDlg:onCheckBox(sender, eventType)
    -- 将其他道具类型显示为不可见
    self:setCtrlVisibleInit()

    -- 如果该类型未加载数据则加载数据
    local checkName = sender:getName()
    if not self.isLoad[checkName] then self:loadData(checkName) end

    -- 当前选择的checkBox对应的数据显示为可见
    local ctrlName = ItemsPanel[checkName]
    local panel = self:getControl("BagItemPanel")
    self:setCtrlVisible(ctrlName, true, panel)

    if checkName == "ItemTagCheckBox" then
        if self.selectItem then
            self:setCtrlEnabled("ConfirmButton", true)
            self:setBagInfo(self.selectItem)
        else
            self:setCtrlEnabled("ConfirmButton", false)
        end
    elseif checkName == "PetTagCheckBox" then
        if self.selectPet then
            self:setCtrlVisible("PetPanel", true, "AttributePanel")
            self:setCtrlEnabled("ConfirmButton", true)
        else
            self:setCtrlEnabled("ConfirmButton", false)
        end
    elseif checkName == "ChangeCardDlgCheckBox" then
        if self.selectCard then
            self:setCtrlVisible("ChangeCardPanel", true, "AttributePanel")
            self:setCtrlEnabled("ConfirmButton", true)
        else
            self:setCtrlEnabled("ConfirmButton", false)
        end
    end
end

function ChooseItemDlg:loadData(checkBoxName)
    if checkBoxName == "ItemTagCheckBox" then
        self:setBagData()
    elseif checkBoxName == "PetTagCheckBox" then
        self:setPetData()
    elseif checkBoxName == "ChangeCardDlgCheckBox" then
        self:setCardData()
    end
    self.isLoad[checkBoxName] = true
end

function ChooseItemDlg:getMeetConditionItems()
    local items = MarketMgr:getBagCanSell(MarketMgr.TradeType.marketType)



    local dest = {}
    for i = 1, #items do

        local isCanAdd = true

        if InventoryMgr:isLimitedItemForever(items[i]) then
            isCanAdd = false
        end

        if items[i].item_type == ITEM_TYPE.TOY then
            isCanAdd = false
        end

        if isCanAdd then
            table.insert(dest, items[i])
        end
    end

    return dest
end

function ChooseItemDlg:setBagData()
    local items = self:getMeetConditionItems()

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
        item:setTag(items[i].pos)
        local imageCtrl = self:getControl("IconImage", nil, item)

        -- 限制交易道具置灰
        if InventoryMgr:isLimitedItem(items[i]) then
            gf:grayImageView(imageCtrl)
            InventoryMgr:addLogoBinding(self:getControl("IconImage", nil, item))
        end

        if gf:isExpensive(items[i]) or 1 == CAN_NOT_GIVE_ITEM_LIST[items[i].name] then
            gf:grayImageView(imageCtrl)
        end

        if items[i].item_type == ITEM_TYPE.EQUIPMENT and items[i].req_level and items[i].req_level > 0 then
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, items[i].req_level, false, LOCATE_POSITION.LEFT_TOP, 21, item)
        end

        item.item = items[i]
        self:bindTouchEndEventListener(item, function(self, sender, eventType)
            self:onSelectItem(item)
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
        self:setItemImageSize("IconImage", item)

        if items[i].item_type == ITEM_TYPE.EQUIPMENT and items[i].unidentified == 1 then
            InventoryMgr:addLogoUnidentified(imageCtrl)
        end

        -- 法宝相性
        if items[i].item_type == ITEM_TYPE.ARTIFACT and items[i].item_polar then
            InventoryMgr:addArtifactPolarImage(imageCtrl, items[i].item_polar)
        end
    end
end

function ChooseItemDlg:onSelectItem(sender, eventType)

    if InventoryMgr:isLimitedItem(sender.item) or gf:isExpensive(sender.item) or CAN_NOT_GIVE_ITEM_LIST[sender.item.name] == 1 then
        gf:ShowSmallTips(CHS[4100300])
        return
    end

    self.selectItem = sender.item
    self:addSelectImage(sender, "item")
    self:setBagInfo(self.selectItem)
    self:setCtrlEnabled("ConfirmButton", true)
end

-- 点击道具
function ChooseItemDlg:setBagInfo(item)
    self:setDisplayInfoVisibleFlase()
    local AttriPanel = self:getControl("AttributePanel")
    if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 0 then
        if EquipmentMgr:isJewelry(item) then
            self:setJewelryInfo(item)
            self:setCtrlVisible("JewelryPanel", true, AttriPanel)
        elseif item.fasion_type == FASION_TYPE.FASION then
            self:setCtrlVisible("FashionDressPanel", true, AttriPanel)
            self:setFashionInfo(item)
        else
            self:setEquipInfo(item)
            self:setCtrlVisible("EquipPanel", true, AttriPanel)
        end
    elseif item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        self:setCardInfo(item)
        self:setCtrlVisible("ChangeCardPanel", true, "AttributePanel")
    elseif item.item_type == ITEM_TYPE.ARTIFACT then
        self:setArtifactInfo(item)
        self:setCtrlVisible("ArtifactPanel", true, AttriPanel)
    elseif item.item_type == ITEM_TYPE.CUSTOM and item.fasion_type == FASION_TYPE.FASION then
        self:setCtrlVisible("FashionDressPanel", true, AttriPanel)
        self:setFashionInfo(item)
    else
        self:setItemInfo(item)
        self:setCtrlVisible("ItemPanel", true, AttriPanel)
    end
end

function ChooseItemDlg:setItemInfo(item)
    local attPanel = self:getControl("AttributePanel")
    local itemPanel = self:getControl("ItemPanel", nil, attPanel)
    local itemMainPanel = self:getControl("MainPanel", nil, itemPanel)

    if InventoryMgr:getIsGuard(item.name) then
        -- 有可能是守护类型道具
        local icon = InventoryMgr:getIconByName(item.name)
        self:setImage("ItemImage", ResMgr:getSmallPortrait(item.icon), itemMainPanel)
        self:setItemImageSize("ItemImage", itemMainPanel)
    else
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(item.name)), itemMainPanel)
        self:setItemImageSize("ItemImage", itemMainPanel)
    end
    if item and InventoryMgr:isLimitedItem(item) then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage"), itemMainPanel)
    end

    local color = InventoryMgr:getItemColor(item)
    self:setLabelText("NameLabel", item.name, itemMainPanel, color)

    if item.level and item.level ~= 0 then
        self:setLabelText("LevelLabel", string.format(CHS[3003748], item.level), itemMainPanel)
    else
        self:setLabelText("LevelLabel", "", itemMainPanel)
    end

    self:setLabelText("NumLabel", CHS[4100301] .. item.amount, itemMainPanel)

    -- 描述
    local descriptStr = InventoryMgr:getDescriptByItem(item)
    if item["expired_time"] and item["expired_time"] ~= 0 then
        descriptStr = descriptStr .. gf:getServerDate(CHS[4300028], item["expired_time"])
    end

    self:setDescriptAutoSize(descriptStr, "DescPanel", COLOR3.WHITE, itemMainPanel)


    local attTab = {}

    -- 带属性黑水晶
    if gf:findStrByByte(item.name, CHS[3002823]) then
        local color = InventoryMgr:getItemColor(item)
        self:setLabelText("NameLabel", string.match(item.name, CHS[3002936]), itemMainPanel, color)
        local funStr1 = CHS[3002824] .. EquipmentMgr:getEquipChs(item.upgrade_type)
        if funStr1 ~= "" then table.insert(attTab, {str = funStr1}) end

        local funStr2 = ""
        for i,field in pairs(EquipmentMgr:getAllAttField()) do
            local str = field .. "_2"
            local bai = ""
            if EquipmentMgr:getAttribsTabByName(CHS[3002825])[field] then bai = "%" end
            local equip = {req_level = item.level, equip_type = item.upgrade_type}
            local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if item.extra[str] then
                funStr2 = funStr2 .. EquipmentMgr:getAttribChsOrEng(field) .. " " .. item.extra[str] .. bai .. "/" .. maxValue .. bai
            end
        end

        if funStr2 ~= "" then table.insert(attTab, {str = funStr2}) end
    end

    local funStr  = InventoryMgr:getFuncStr(item)
    if funStr ~= "" then table.insert(attTab, {str = funStr}) end

    local limitTab = InventoryMgr:getLimitAtt(item, self:getControl("LimitTradeLabel"))
    if next(limitTab) then
        table.insert(attTab, {str = limitTab[1].str, color = limitTab[1].color})
    end

    for i = 1, 4 do
        if attTab[i] then
            self:setDescriptAutoSize(attTab[i].str, "DescPanel" .. i, attTab[i].color or COLOR3.WHITE, itemMainPanel)
        else
            self:getControl("DescPanel" .. i, nil, itemMainPanel):removeAllChildren()
        end
    end

    itemMainPanel:requestDoLayout()
end

function ChooseItemDlg:setDescriptAutoSize(descript, ctrlName, defaultColor, root, notDoLayout)
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

function ChooseItemDlg:setJewelryInfo(equip)
    local attPanel = self:getControl("AttributePanel")
    local equipPanel = self:getControl("JewelryPanel", nil, attPanel)
    local equipMainPanel = self:getControl("MainPanel", nil, equipPanel)

    self:setImage("ItemImage", InventoryMgr:getIconFileByName(equip.name), equipMainPanel)
    self:setItemImageSize("ItemImage", equipMainPanel)
    self:setNumImgForPanel("JewelryShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, equipMainPanel)

    -- 名称
    local color = InventoryMgr:getItemColor(equip)
    self:setLabelText("NameLabel", equip.name, equipMainPanel, color)
    -- 描述
    self:setLabelText("DescLabel", InventoryMgr:getDescript(equip.name), equipMainPanel)
    -- 等级
    self:setLabelText("LevelValueLabel", equip.req_level, equipMainPanel)


    -- 部位和强化等级
    --- 如果没有强化的，原强化label需要显示部位
    local developStr, devLevel, devCom = EquipmentMgr:getJewelryDevelopInfo(equip)
    if devLevel == 0 and devCom == 0 then
                    -- 部位
        if equip.equip_type == EQUIP.BALDRIC then
            self:setLabelText("DevelopLevelLabel", CHS[3002877], equipMainPanel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.NECKLACE then
            self:setLabelText("DevelopLevelLabel", CHS[3002878], equipMainPanel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.LEFT_WRIST then
            self:setLabelText("DevelopLevelLabel", CHS[3002879], equipMainPanel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.RIGHT_WRIST then
            self:setLabelText("DevelopLevelLabel", CHS[3002879], equipMainPanel, COLOR3.LIGHT_WHITE)
        end

        self:setLabelText("CommondLabel", "", equipMainPanel, COLOR3.LIGHT_WHITE)
    else
        -- 强化
        self:setLabelText("DevelopLevelLabel", developStr, equipMainPanel, COLOR3.BLUE)

        -- 部位
        if equip.equip_type == EQUIP.BALDRIC then
            self:setLabelText("CommondLabel", CHS[3002877], equipMainPanel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.NECKLACE then
            self:setLabelText("CommondLabel", CHS[3002878], equipMainPanel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.LEFT_WRIST then
            self:setLabelText("CommondLabel", CHS[3002879], equipMainPanel, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.RIGHT_WRIST then
            self:setLabelText("CommondLabel", CHS[3002879], equipMainPanel, COLOR3.LIGHT_WHITE)
        end
    end



    local attr = EquipmentMgr:getJewelryAttrib(equip)

    -- 转换次数
    if equip.transform_num and equip.transform_num > 0 then
        table.insert(attr, {str = string.format(CHS[4010062], equip.transform_num), color = COLOR3.LIGHT_WHITE})
    end

    -- 冷却时间
    if EquipmentMgr:isCoolTimed(equip) then
        table.insert(attr, {str = string.format(CHS[4010063], EquipmentMgr:getCoolTimedByDay(equip)), color = COLOR3.LIGHT_WHITE})
    end

    local jewelryAttPanel = self:getControl("DescPanel", nil, equipMainPanel)
    local lackHeight = 0
    for i = 1, JEWELRY_MAX_ATTRIB do
        if attr[i] then

            local attPanel = self:getControl("AttribPanel" .. i, nil, jewelryAttPanel)
            if attPanel then
                self:setColorText(attr[i].str, attPanel, attr[i].color)
                self:setLabelText("AttribLabel" .. i, "", jewelryAttPanel, attr[i].color)
            else
                self:setLabelText("AttribLabel" .. i, attr[i].str, jewelryAttPanel, attr[i].color)
            end


        else
            self:setLabelText("AttribLabel" .. i, "", jewelryAttPanel)
            lackHeight = lackHeight + BASE_ATTRIBUTE_LABEL_HEIGHT
        end
    end
    jewelryAttPanel:requestDoLayout()

    local equipScrollCtrl = self:getControl("JewelryScrollView", nil, equipPanel)
    local equipInnerSize = self:getControl("MainPanel", nil, equipPanel):getContentSize()
    equipInnerSize.height = equipInnerSize.height - lackHeight
    equipScrollCtrl:setInnerContainerSize(equipInnerSize)
end

function ChooseItemDlg:setArtifactInfo(artifact)
    local attPanel = self:getControl("AttributePanel")
    local artifactPanel = self:getControl("ArtifactPanel", nil, attPanel)
    local artifactMainPanel = self:getControl("MainPanel", nil, artifactPanel)

    self:setImage("ItemImage", InventoryMgr:getIconFileByName(artifact.name), artifactMainPanel)
    self:setItemImageSize("ItemImage", artifactMainPanel)
    self:setNumImgForPanel("ArtifactShapePanel", ART_FONT_COLOR.NORMAL_TEXT, artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, artifactMainPanel)

    self:setLabelText("NameLabel", artifact.name,artifactMainPanel, COLOR3.YELLOW)  --法宝名称
    self:setLabelText("CommondLabel", CHS[7000145], artifactMainPanel, COLOR3.TEXT_DEFAULT)  -- 类型： 法宝

    -- 法宝相性
    if artifact.item_polar then
        InventoryMgr:addArtifactPolarImage(self:getControl("ItemImage", nil, artifactMainPanel), artifact.item_polar)
    end

    local expStr = string.format(CHS[7000185], artifact.exp, artifact.exp_to_next_level) -- 道法
    local nimbusStr = string.format(CHS[7000186], artifact.nimbus, Formula:getArtifactMaxNimbus(artifact.level)) -- 灵气
    local intimacyStr = string.format(CHS[7000187], artifact.intimacy) -- 亲密度
    local polarStr = string.format(CHS[7000188], gf:getPolar(artifact.item_polar),
        EquipmentMgr:getPolarAttribByArtifact(artifact)) -- 相性
    local skillStr = string.format(CHS[7000189], EquipmentMgr:getArtifactSkillDesc(artifact.name))  -- 法宝技能

    -- 法宝特殊技能
    local extraSkillStr
    if artifact.extra_skill and artifact.extra_skill ~= "" then
        -- 有特殊技能
        local extraSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
        local extraSkillLevel = artifact.extra_skill_level
        local extraSkillDesc = SkillMgr:getSkillDesc(extraSkillName).desc
        extraSkillStr = string.format(CHS[7000311], extraSkillName, extraSkillLevel)
            .. CHS[7000078] .. extraSkillDesc
    else
        -- 无特殊技能
        extraSkillStr = string.format(CHS[7000151], CHS[7000153]) .. CHS[7000078]
            .. CHS[3001385].. "\n" .. CHS[7000310]
    end

    self:setDescriptAutoSize(expStr, "BaseAttribPanel1", COLOR3.TEXT_DEFAULT, artifactMainPanel, true)
    self:setDescriptAutoSize(nimbusStr, "BaseAttribPanel2", COLOR3.TEXT_DEFAULT, artifactMainPanel, true)
    self:setDescriptAutoSize(intimacyStr, "BaseAttribPanel3", COLOR3.TEXT_DEFAULT, artifactMainPanel, true)
    self:setDescriptAutoSize(polarStr, "BaseAttribPanel4", COLOR3.TEXT_DEFAULT, artifactMainPanel, true)
    self:setDescriptAutoSize(skillStr, "BaseAttribPanel5", COLOR3.TEXT_DEFAULT, artifactMainPanel, true)
    self:setDescriptAutoSize(extraSkillStr, "BaseAttribPanel6", COLOR3.TEXT_DEFAULT, artifactMainPanel, true)

    self:getControl("DescPanel", nil, artifactMainPanel):requestDoLayout()

    local scollCtrl = self:getControl("ArtifactScrollView", nil, artifactPanel)
    local container = self:getControl("MainPanel", nil, artifactPanel)
    scollCtrl:setInnerContainerSize(container:getContentSize())
end

function ChooseItemDlg:setFashionInfo(equip)
    local attPanel = self:getControl("AttributePanel")
    local equipPanel = self:getControl("FashionDressPanel", nil, attPanel)
    local equipMainPanel = self:getControl("MainPanel", nil, equipPanel)

    self:setImage("ItemImage", InventoryMgr:getIconFileByName(equip.name), equipMainPanel)
    self:setItemImageSize("ItemImage", equipMainPanel)

    -- 名称
    if equip.alias and equip.alias ~= "" then
        self:setLabelText("NameLabel", equip.alias, equipMainPanel)
    else
        self:setLabelText("NameLabel", equip.name, equipMainPanel)
    end

    self:setLabelText("GenderLabel", gf:getGenderChs(equip.gender), equipMainPanel)

    local descriptStr = InventoryMgr:getDescriptByItem(equip)
    self:setDescriptAutoSize(descriptStr, "DescPanel", COLOR3.WHITE, equipMainPanel)
end

function ChooseItemDlg:setEquipInfo(equip)
    local attPanel = self:getControl("AttributePanel")
    local equipPanel = self:getControl("EquipPanel", nil, attPanel)
    local equipMainPanel = self:getControl("MainPanel", nil, equipPanel)

    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name), equipMainPanel)
    self:setItemImageSize("EquipmentImage", equipMainPanel)
    self:setNumImgForPanel("EquipShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, equipMainPanel)

    local color = InventoryMgr:getItemColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, equipMainPanel, color)

    local mainInfo = EquipmentMgr:getMainInfoMap(equip)
    local count = #mainInfo
    for i = 1,2 do
        if i > count then
            self:setCtrlVisible("MainLabel" .. i, false, equipMainPanel)
        else
            self:setLabelText("MainLabel" .. i, mainInfo[i].str, equipMainPanel, mainInfo[i].color)
        end
    end

    EquipmentMgr:setEvolveStar(self, equip)

    local attrib = EquipmentMgr:getAttInfoForGive(equip)
    local lackHeight = 0
    for i = 1, 14 do
        local att = attrib[i]
        local desPanel = self:getControl("BaseAttributePanel" .. i)

        if att then
            if desPanel then
                self:setCtrlVisible("BaseAttributePanel" .. i, true)
                self:setColorText(att.str, desPanel, att.color)
                self:setLabelText("BaseAttributeLabel" .. i, "")
            else
                self:setCtrlVisible("BaseAttributePanel" .. i, false)
                self:setLabelText("BaseAttributeLabel" .. i, attrib[i].str, nil, attrib[i].color)
            end
        else
            lackHeight = lackHeight + BASE_ATTRIBUTE_LABEL_HEIGHT
            self:setCtrlVisible("BaseAttributePanel" .. i, false)
            self:setLabelText("BaseAttributeLabel" .. i, "")
        end
        attPanel:requestDoLayout()
    end
    equipMainPanel:requestDoLayout()

    local equipPanel = self:getControl("EquipPanel", nil, attPanel)
    local equipScrollCtrl = self:getControl("EquipScrollView", nil, equipPanel)
    local equipInnerSize = self:getControl("MainPanel", nil, equipPanel):getContentSize()
    equipInnerSize.height = equipInnerSize.height - lackHeight
    equipScrollCtrl:setInnerContainerSize(equipInnerSize)
end

function ChooseItemDlg:setPetData()
    local pets = PetMgr:getOrderPets()
    self:setCtrlVisible("NoticePanel", (#pets == 0), "PetListPanel")
    if #pets == 0 then return end
    local list = self:resetListView("PetListView")
    local isSelect = false
    for _, pet in pairs(pets) do
        local panel = self.unitPetPanel:clone()
        self:setPetUnitPanel(pet, panel)
        list:pushBackCustomItem(panel)
    end
end

function ChooseItemDlg:setCardData()
    local list, size = self:resetListView("CardListView")
    local storeCard = StoreMgr:getCardsInCardBagDisplayAmount()
    self:setCtrlVisible("NoticePanel", (#storeCard == 0), "ChangeCardListPanel")

    for i, v in pairs(storeCard) do
        -- 增加项
        local panel = self.unitCardPanel:clone()
        self:setCardUnitPanel(v, panel)
        list:pushBackCustomItem(panel)
    end
end

function ChooseItemDlg:setCardUnitPanel(cardInfo, panel)
    panel:setName(cardInfo.name)
    local cardInfoCfg = InventoryMgr:getCardInfoByName(cardInfo.name)
    local icon = InventoryMgr:getIconByName(cardInfo.name)
    self:setImage("GuardImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("GuardImage", panel)
    self:setLabelText("NameLabel", cardInfo.name, panel)
    self:setLabelText("LevelLabel", CHS[4100091] .. cardInfo.count, panel)

    local canGiveCard = StoreMgr:getChangeCardByName(cardInfo.name, true)
    self:setCtrlEnabled("GuardImage", not (#canGiveCard == 0), panel)

    panel.cardInfo = cardInfo
    self:bindTouchEndEventListener(panel, self.onSelectCard)
end

function ChooseItemDlg:onSelectCard(sender, eventType)
    local cards = StoreMgr:getChangeCardByName(sender.cardInfo.name, true)
    if #cards == 0 then
        gf:ShowSmallTips(CHS[4100300])
        return
    end

    self.selectCard = sender.cardInfo
    self:addSelectImage(sender, "card")
    self:setCardInfo(self.selectCard)

    self:setCtrlVisible("ChangeCardPanel", true, "AttributePanel")
    self:setCtrlEnabled("ConfirmButton", true)
end

function ChooseItemDlg:setCardInfo(cardInfo)
    local attPanel = self:getControl("AttributePanel")
    local cardPanel = self:getControl("ChangeCardPanel", nil, attPanel)
    local cardMainPanel = self:getControl("MainPanel", nil, cardPanel)

    local cardCfg = InventoryMgr:getCardInfoByName(cardInfo.name)
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(cardInfo.name)), cardMainPanel)
    self:setItemImageSize("ItemImage", cardMainPanel)
    self:setLabelText("NameLabel", cardInfo.name, cardMainPanel)
    self:setLabelText("LevelLabel", CHS[4100085] .. cardCfg.card_level, cardMainPanel)
    self:setLabelText("NumLabel", CHS[4100091] .. (cardInfo.count or cardInfo.amount), cardMainPanel)

    local info = InventoryMgr:getChangeCardEff(cardInfo.name)
    local panel = self:getControl("ChangeCardDescriptionPanel", nil, cardMainPanel)
    for i = 1, 10 do
        if info[i] then
            self:setLabelText("BaseAttributeLabel" .. i, info[i].str, panel, info[i].color)
        else
            self:setLabelText("BaseAttributeLabel" .. i, "", panel)
        end
    end
end

function ChooseItemDlg:setPetUnitPanel(pet, panel)
    panel.pet = pet
    panel:setTag(pet:queryBasicInt("no"))
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), panel)
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), panel)
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("GuardImage", panel)

    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    self:setImagePlist("Image", ResMgr:getPolarImagePath(polar), panel)

    -- 参战、掠阵
    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        self:setImage("StatusImage", ResMgr.ui.canzhan_flag_new, panel)
    elseif pet_status == 2 then
        -- 掠阵
        self:setImage("StatusImage", ResMgr.ui.luezhen_flag_new, panel)
    elseif PetMgr:isRidePet(pet:getId()) then
        -- 骑乘
        self:setImage("StatusImage", ResMgr.ui.ride_flag_new, panel)
    else
        -- 透明图片
        self:setImagePlist("StatusImage", ResMgr.ui.touming, panel)
    end

    -- 如果不可赠送，置灰
    if PetMgr:isLimitedPet(pet) or gf:isExpensive(pet, true) then
        self:setCtrlEnabled("GuardImage", false, panel)
    else
        self:setCtrlEnabled("GuardImage", true, panel)
    end

    self:bindTouchEndEventListener(panel, function ()
        self:onSelectPet(panel)
    end)
end

function ChooseItemDlg:onSelectPet(sender, eventType)
    if gf:isExpensive(sender.pet, true) or PetMgr:isLimitedPet(sender.pet) then
        gf:ShowSmallTips(CHS[4100300])
        return
    end

    if sender.pet:queryInt("pet_status") == 1 then
        gf:ShowSmallTips(CHS[4100302])
        return
    elseif sender.pet:queryInt("pet_status") == 2 then
        gf:ShowSmallTips(CHS[4100303])
        return
    elseif PetMgr:isRidePet(sender.pet:getId()) then
        gf:ShowSmallTips(CHS[6000547])
        return
    elseif PetMgr:isFeedStatus(sender.pet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    elseif PetMgr:isCFZHStatus(sender.pet) then
        gf:ShowSmallTips(CHS[2500066])
        return
    end
    self.selectPet = sender.pet
    self:addSelectImage(sender, "pet")
    self:setPetInfo(self.selectPet)

    self:setCtrlVisible("PetPanel", true, "AttributePanel")
    self:setCtrlEnabled("ConfirmButton", true)
end

function ChooseItemDlg:addSelectImage(sender, selectTeg)
    if selectTeg == "pet" then
        self.unitPetSelectImage:removeFromParent()
        sender:addChild(self.unitPetSelectImage)
    elseif selectTeg == "card" then
        self.unitCardSelectImage:removeFromParent()
        sender:addChild(self.unitCardSelectImage)
    elseif selectTeg == "item" then
        self.unitItemSelectImage:removeFromParent()
        sender:addChild(self.unitItemSelectImage)
    end
end

-- 右侧宠物信息
function ChooseItemDlg:setPetInfo(pet)
    local attPanel = self:getControl("AttributePanel")
    local petPanel = self:getControl("PetPanel", nil, attPanel)
    local petMainPanel = self:getControl("MainPanel", nil, petPanel)

    -- 头像、名字、等级
    self:setImage("ItemImage", ResMgr:getSmallPortrait(pet:queryBasicInt("icon")), petMainPanel)
    self:setItemImageSize("ItemImage", petMainPanel)
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), petMainPanel)
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), petMainPanel)

    -- 基本属性
    self:setLabelText("LifeValueLabel", pet:queryInt("max_life"), petMainPanel)
    self:setLabelText("ManaValueLabel", pet:queryInt("max_mana"), petMainPanel)
    self:setLabelText("PhyValueLabel", pet:queryInt("phy_power"), petMainPanel)
    self:setLabelText("MagPowerValueLabel", pet:queryInt("mag_power"), petMainPanel)
    self:setLabelText("DefenceValueLabel", pet:queryInt("def"), petMainPanel)
    self:setLabelText("SpeedValueLabel", pet:queryInt("speed"), petMainPanel)
    self:setLabelText("MartialValueLabel", pet:queryInt("martial"), petMainPanel)
    self:setLabelText("CatchLevelValueLabel", pet:queryInt("req_level"), petMainPanel)

    --精怪、御灵显示阶位
    local mount_type = pet:queryInt("mount_type")
    if mount_type == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI or mount_type == MOUNT_TYPE.MOUNT_TYPE_YULING then
        self:setLabelText("HierarchyValueLabel", PetMgr:getMountRankStr(pet), petMainPanel)
        self:setCtrlVisible("HierarchyLabel", true, petMainPanel)
        self:setCtrlVisible("HierarchyValueLabel", true, petMainPanel)
    else
        self:setCtrlVisible("HierarchyLabel", false, petMainPanel)
        self:setCtrlVisible("HierarchyValueLabel", false, petMainPanel)
    end

    -- 基本成长
    local lifeShape = pet:queryInt("pet_life_shape")
    local manaShape = pet:queryInt("pet_mana_shape")
    local speedShape = pet:queryInt("pet_speed_shape")
    local phyShape = pet:queryInt("pet_phy_shape")
    local magShape = pet:queryInt("pet_mag_shape")


    local basicLife = PetMgr:getPetBasicShape(pet, "life_effect")
    if lifeShape ~= basicLife then
        self:setLabelText("LifeEffectValueLabel", string.format("%d(%d + %d)", lifeShape, basicLife, lifeShape - basicLife), petMainPanel)
    else
        self:setLabelText("LifeEffectValueLabel", basicLife, petMainPanel)
    end
    self:updateLayout("LifeEffectPanel", petMainPanel)

    local basicMana = PetMgr:getPetBasicShape(pet, "mana_effect")
    if manaShape ~= basicMana then
        self:setLabelText("ManaEffectValueLabel", string.format("%d(%d + %d)", manaShape, basicMana, manaShape - basicMana), petMainPanel)
    else
        self:setLabelText("ManaEffectValueLabel", basicMana, petMainPanel)
    end
    self:updateLayout("ManaEffectPanel", petMainPanel)

    local basicPhy = PetMgr:getPetBasicShape(pet, "phy_effect")
    if phyShape ~= basicPhy then
        self:setLabelText("PhyEffectValueLabel", string.format("%d(%d + %d)", phyShape, basicPhy, phyShape - basicPhy), petMainPanel)
    else
        self:setLabelText("PhyEffectValueLabel", phyShape, petMainPanel)
    end
    self:updateLayout("PhyEffectPanel", petMainPanel)

    local basicMag = PetMgr:getPetBasicShape(pet, "mag_effect")
    if magShape ~= basicMag then
        self:setLabelText("MagEffectValueLabel", string.format("%d(%d + %d)", magShape, basicMag, magShape - basicMag), petMainPanel)
    else
        self:setLabelText("MagEffectValueLabel", basicMag, petMainPanel)
    end
    self:updateLayout("MagEffectPanel", petMainPanel)

    local basicSpeed = PetMgr:getPetBasicShape(pet, "speed_effect")
    if speedShape ~= basicSpeed then
        self:setLabelText("SpeedEffectValueLabel", string.format("%d(%d + %d)", speedShape, basicSpeed, speedShape - basicSpeed), petMainPanel)
    else
        self:setLabelText("SpeedEffectValueLabel", basicSpeed, petMainPanel)
    end
    self:updateLayout("SpeedEffectPanel", petMainPanel)

    local totalAll = lifeShape + manaShape + speedShape + phyShape + magShape
    local totalBasic = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    if totalAll ~= totalBasic then
        self:setLabelText("TotalEffectValueLabel", string.format("%d(%d + %d)", totalAll, totalBasic, totalAll - totalBasic), petMainPanel)
    else
        self:setLabelText("TotalEffectValueLabel", totalAll, petMainPanel)
    end
    self:updateLayout("TotalEffectPanel", petMainPanel)

    -- 强化
    local phyStrongTime = pet:queryInt("phy_rebuild_level")
    local magStrongTime = pet:queryInt("mag_rebuild_level")
    local phyStrongRate = pet:queryInt("phy_rebuild_rate")
    local magStrongRate = pet:queryInt("mag_rebuild_rate")
    if phyStrongRate == 0 then
        self:setLabelText("ValueLabel", phyStrongTime .. CHS[3003367], "PhyStrengthPanel")
    else
        self:setLabelText("ValueLabel", phyStrongTime .. CHS[3003368] .. phyStrongRate / 100 .. "%)", "PhyStrengthPanel")
    end
    self:updateLayout("PhyStrengthPanel", petMainPanel)

    if magStrongRate == 0 then
        self:setLabelText("ValueLabel", magStrongTime .. CHS[3003367], "MagStrengthPanel")
    else
        self:setLabelText("ValueLabel", magStrongTime .. CHS[3003368] .. magStrongRate / 100 .. "%)", "MagStrengthPanel")
    end
    self:updateLayout("MagStrengthPanel", petMainPanel)

    -- 羽化
    local total = Formula:getPetYuhuaMaxNimbus(pet)
    if PetMgr:isYuhuaCompleted(pet) then
        self:setLabelText("ValueLabel", string.format(CHS[4100987]), "YuHuaPanel")
    else
        local now = pet:queryBasicInt("eclosion_nimbus")
        self:setLabelText("ValueLabel", string.format("%s %d/%d(%0.2f%%)", PetMgr:getYuhuaStageChs(pet), now, total, PetMgr:getYuhuaPercent(pet)), "YuHuaPanel")
    end

    -- 点化
    local now = pet:queryBasicInt("enchant_nimbus")
    local total = Formula:getPetDianhuaMaxNimbus(pet)
    local pers = math.floor(now / total * 100 * 100) * 0.01
    if pet:queryBasicInt("enchant") == 2 then
        self:setLabelText("ValueLabel", string.format(CHS[4100987]), "DianHuaPanel")
    else
        self:setLabelText("ValueLabel", string.format("%d/%d (%0.2f", now, total, pers) .. "%)", "DianHuaPanel")
    end
    self:updateLayout("DianHuaPanel", petMainPanel)

    -- 天生技能
    local skill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId())
    for i = 1, 3 do
        if skill[i] then
            self:setLabelText("Label" .. i, string.format(CHS[4300284], skill[i].name, skill[i].level), "SkillPanel")
        elseif i == 1 then
            self:setLabelText("Label" .. i, CHS[5000059], "SkillPanel")
        else
            self:setLabelText("Label" .. i, "", "SkillPanel")
        end
    end

    if #skill < 3 then
        self:setCtrlContentSize("SkillPanel", nil, self.tianshengPanelSize.height - TIANSHENG_SKILL_CUT_HEIGHT)
        self:setCtrlContentSize("MainPanel", nil, self.petPanelSize.height - TIANSHENG_SKILL_CUT_HEIGHT, petMainPanel)

    else
        self:setCtrlContentSize("SkillPanel", nil, self.tianshengPanelSize.height)
        self:setCtrlContentSize("MainPanel", nil, self.petPanelSize.height, petMainPanel)
    end
    self:updateLayout("SkillPanel", petMainPanel)


    -- 幻化
    local attMap = {"life", "mana", "speed", "phy", "mag"}
    local times = 0
    for _, att in pairs(attMap) do
        local fieldTimes = string.format("morph_%s_times", att)

        times = times + pet:queryBasicInt(fieldTimes)
    end
    self:setLabelText("ValueLabel", string.format("%d/%d", times, 15), "HuanHuaPanel")

    -- 飞升
    local flyTips = PetMgr:isFlyPet(pet) and CHS[7002287] or CHS[7002286]
    self:setLabelText("ValueLabel", flyTips, "FeiShengPanel")

    -- 进化
    local soul = pet:queryBasic("evolve")
    if soul == "" then soul = CHS[5000059] end
    self:setLabelText("ValueLabel", soul, "JinHuaPanel")

    -- 顿悟
    local dunwuSkills = SkillMgr:getPetDunWuSkillsByPet(pet)
    if dunwuSkills and next(dunwuSkills) then
        for i = 1, 2 do
            if dunwuSkills[i] then

                self:setLabelText("Label" .. i, string.format(CHS[4300284], dunwuSkills[i].name, dunwuSkills[i].level), "DunWuSkillPanel")
            else
                self:setLabelText("Label" .. i, "", "DunWuSkillPanel")
            end
        end
    else
        self:setLabelText("Label1", CHS[5000059], "DunWuSkillPanel")
        self:setLabelText("Label2", "", "DunWuSkillPanel")
    end

    petMainPanel:requestDoLayout()

    self:setScrollViewInit()
end

function ChooseItemDlg:setColorText(str, panel, defColor)
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width, 0)
    if defColor then
        textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    else
        textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    end
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size.width - textW) * 0.5, textH)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    panel:setContentSize(size.width, textH)
    return textH
end

function ChooseItemDlg:onDepositButton(sender, eventType)
end

function ChooseItemDlg:setInitSelect(item, itemType)
    self.radioGroup:selectRadio(itemType, true)
    self:onCheckBox(self:getControl(checkBoxs[itemType]))
    if itemType == 1 then
        performWithDelay(self.root, function ()
            local listCtrl = self:getControl("BagItemsScrollView")
            local panel = listCtrl:getChildByTag(item.pos)
            self:onSelectItem(panel)
        end, 0)
    elseif itemType == 2 then
        performWithDelay(self.root, function ()
            local listCtrl = self:getControl("PetListView")
            local panel = listCtrl:getChildByTag(item:queryBasicInt("no"))
            self:onSelectPet(panel)
        end, 0)
    elseif itemType == 3 then
        performWithDelay(self.root, function ()
            local listCtrl = self:getControl("CardListView")
            local panel = listCtrl:getChildByName(item.name)
            self:onSelectCard(panel)
        end, 0)
    end
end

function ChooseItemDlg:onConfirmButton(sender, eventType)
    local type = 0
    local select
    if self.radioGroup:getSelectedRadioIndex() == 1 then
        type = 1
        select = self.selectItem
    elseif self.radioGroup:getSelectedRadioIndex() == 2 then
        type = 2
        select = self.selectPet
    elseif self.radioGroup:getSelectedRadioIndex() == 3 then
        type = 3
        select = StoreMgr:getFirstNotBindItemByName(self.selectCard.name)
    end

    if select then
        DlgMgr:sendMsg("GiveDlg", "setItemInfo", select, 1, type)
    end

    self:onCloseButton()
end

function ChooseItemDlg:MSG_COMPLETE_GIVING(data)
    self:onCloseButton()
end

return ChooseItemDlg
