-- JuBaoUserViewSelfDlg.lua
-- Created by songcw Dec/12/2016
-- 聚宝斋角色展示界面

local JuBaoUserViewSelfDlg = Singleton("JuBaoUserViewSelfDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local FashionEffect = DressMgr:getFashionEffect()
local CustomItem = require("cfg/CustomItem")
local LightEffects = require("cfg/LightEffect")
local FollowPet = DressMgr:getFollowPet()

local CHECK_BOXS = {
    "AttribCheckBox",
    "BasicCheckBox",
}


local FASHION_CHECKBOX = {
    "FashionDressButton",
    "EffectButton",
    "PetButton",
    "CustomDressButton",
}

local CUSTOM_ITEMS_CHECK = {
    "BackDecorationCheckBox", "HairCheckBox", "BodyCheckBox", "TrousersCheckBox", "WeaponCheckBox"
}


local FASHION_CHECK_BOXS_DISPLAY = {
    FashionDressButton = {"EffectAndFashionItemPanel", "EffectAndFashionPanel", "SexPanel"},
    EffectButton = {"EffectAndFashionItemPanel", "EffectAndFashionPanel"},
    PetButton = {"EffectAndFashionItemPanel", "EffectAndFashionPanel"},
    CustomDressButton = {"CustomPanel", "CustomItemPanel", "SexPanel"},
}

local CHECK_BOXS_DISPLAY = {
    AttribCheckBox = "CharAttribListView",
    BasicCheckBox = "CharBasicListView",
}

-- 自定义时装显示panel 对应的部位
local CUSTOM_PANEL_POS = {
    HairPanel = 33,
    BodyPanel = 34,
    TrousersPanel = 35,
    WeaponPanel = 36,
    BackDecorationPanel = 38,
}

local POS_PANEL = {
    [1] = "WeaponPanel",    -- 武器
    [2] = "HelmetPanel",    -- 头盔
    [3] = "ArmorPanel",     -- 衣服
    [4] = "NecklacePanel",  -- 项链
    [5] = "BaldricPanel",   -- 玉佩
    [6] = "WristPanel_1",   -- 左手镯
    [7] = "WristPanel_2",   --
    [8] = "FlyArtifactPanel",
    [9] = "ArtifactPanel",  --

    [10] = "BootPanel",

    [11] = "WeaponPanel",
    [12] = "HelmetPanel",
    [13] = "ArmorPanel",
    [14] = "BootPanel",
    [15] = "BaldricPanel",
    [16] = "NecklacePanel",
    [17] = "WristPanel_1",
    [18] = "WristPanel_2",
    [19] = "ArtifactPanel",

    [31] = "WeddingArmorPanel",
    [32] = "WeddingBaldricPanel",

}

local FOLLOW_SPRITE_OFFPOS = {
    [1] = cc.p(-40, -60),
    [3] = cc.p(40, -60),
    [5] = cc.p(-40, -60),
    [7] = cc.p(40, -60),
}

function JuBaoUserViewSelfDlg:init()
    self:bindListener("SuitButton_1", self.onSuitButton_1)
    self:bindListener("SuitButton_2", self.onSuitButton_2)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("BuyButton", self.onBuyButton, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton, "DesignatedSellPanel")
    self:bindListener("WeddingButton", self.onWeddingButton)
    self:bindListener("SuitButton", self.onSuitButton)

    self:initCtrlVisible()

    -- 列表控件
    self.choseImage = self:retainCtrl("ChoseImage", nil, "CustomItemPanel")
    self.showPanel = self:retainCtrl("ShowPanel_1", nil, self:getControl("ShowListView", nil, "CustomItemPanel"))

    --self.fashionType = "FashionDressButton"
    self.fashionType = nil

    self.fashionGroup = RadioGroup.new()
    self.fashionGroup:setItemsByButton(self, FASHION_CHECKBOX, self.onFashionCheckBox)

    self.customGroup = RadioGroup.new()
    self.customGroup:setItems(self, CUSTOM_ITEMS_CHECK, self.onCustomCheckBox)

    self.curSuit = 1
    self.equipData = nil
    self.isLoadTitle = false

    -- CharBasicInfoPanel长度可变，记住原始值
    self.basicPanelSize = self.basicPanelSize or self:getControl("CharBasicInfoPanel"):getContentSize()

    self.goods_gid = DlgMgr:sendMsg("JuBaoUserViewTabDlg", "getGid")

    self.data = nil

    -- 从管理器中取数据设置
    self:setDataFormMgr()

    -- 价格信息
    TradingMgr:setPriceInfo(self)


    self:initListView()

    self:hookMsg("MSG_TRADING_SNAPSHOT")
end

function JuBaoUserViewSelfDlg:onCustomCheckBox(sender, index)
    self.checkPart = index
    self:refreshCustomListView()
end

function JuBaoUserViewSelfDlg:getCusomData(fashionType)
    if not self.goods_gid then return {} end

    -- 获取数据
    local data = {}
    if fashionType == "FashionDressButton" then
        data = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FASION)
    elseif fashionType == "CustomDressButton" then
        data = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CUSTOM)
    elseif fashionType == "EffectButton" then
        data = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EFFECT)
    elseif fashionType == "PetButton" then
        data = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FOLLOW_PET)
    end
    if not data then data = {} end

    local gender = self.isFemale and 2 or 1

    -- 存储格式转换下，并且如果自定义，区分 部分（头、衣服...）
    local ret = {}
    for _, info in pairs(data) do
        local itemInfo = InventoryMgr:getItemInfoByName(info.name)
        if fashionType == "CustomDressButton" then
            if self.checkPart == itemInfo.part and gender == itemInfo.gender then
                table.insert(ret, info)
            end
        elseif fashionType == "EffectButton" then
            table.insert(ret, info)
        elseif fashionType == "PetButton" then
            table.insert(ret, info)
        else
            if gender == itemInfo.gender then
                table.insert(ret, info)
            end
        end
    end

    -- 身上的也要加进去
    local equipData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EQUIP)
    if fashionType == "CustomDressButton" then
        local equipPos = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
        for i = 1, #equipPos do
            local equip = equipData[equipPos[i]]
            if equip and InventoryMgr:getItemInfoByName(equip.name).gender == gender and self.checkPart == InventoryMgr:getItemInfoByName(equip.name).part then
                equip.pos = equipPos[i]
                table.insert(ret, equip)
            end
        end
    elseif fashionType == "FashionDressButton" then
        local equip = equipData[31]
        if equip and InventoryMgr:getItemInfoByName(equip.name).gender == gender then
            equip.pos = 31
            table.insert(ret, equip)
        end
    elseif fashionType == "EffectButton" then
        local equip = equipData[32]
        if equip then
            equip.pos = 32
            table.insert(ret, equip)
        end
    elseif fashionType == "PetButton" then
        local equip = equipData[EQUIP.EQUIP_FOLLOW_PET]
        if equip then
            equip.pos = EQUIP.EQUIP_FOLLOW_PET
            table.insert(ret, equip)
        end
    end

    table.sort(ret, function(l, r)
        return l.icon < r.icon
    end)

    return ret
end

-- 刷新道具列表
function JuBaoUserViewSelfDlg:refreshCustomListView()


    if self.fashionType == "FashionDressButton" then
        self:initFasionListView("ShowListView", self:getCusomData(self.fashionType), "EffectAndFashionItemPanel", 6)

    elseif self.fashionType == "CustomDressButton" then
        self:initFasionListView("ShowListView", self:getCusomData(self.fashionType), "CustomItemPanel", 6)


    elseif self.fashionType == "EffectButton" then
        self:initFasionListView("ShowListView", self:getCusomData(self.fashionType), "EffectAndFashionItemPanel", 6)

    elseif self.fashionType == "PetButton" then
        self:initFasionListView("ShowListView", self:getCusomData(self.fashionType), "EffectAndFashionItemPanel", 6)

    end
end

-- 初始化列表数据
function JuBaoUserViewSelfDlg:initFasionListView(name, data, root, margin)
    local list = self:resetListView(name, margin, nil, root)
    local line = math.max(5, math.floor(#data / 5 + 0.5))

    local panel
    for i = 1, line do
        panel = self.showPanel:clone()
        self:setPanelData(panel, data, (i - 1) * 5 + 1)
        list:pushBackCustomItem(panel)
    end
end

-- 设置道具列表单行道具数据
function JuBaoUserViewSelfDlg:setPanelData(panel, data, start)
    local item
    for i = 1, 5 do
        item = self:getControl("ItemPanel_" .. tostring(i), nil, panel)
        self:setItemData(item, data[start + i - 1])
    end
end

-- 设置道具列表道具数据
function JuBaoUserViewSelfDlg:setItemData(item, data)
    self:setCtrlVisible("ItemImage", nil ~= data, item)
    self:setCtrlVisible("NoImage", nil ~= data and (not data.amount or data.amount <= 0), item)


    if data then
        -- 存在道具数据
        self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), item)
        gf:setItemImageSize(self:getControl("ItemImage", nil, item))
        item:setName(data.name)
        item.data = data

        self:setImagePlist("BKImage", ResMgr.ui.bag_item_bg_img, item)
        self:setCtrlVisible("OwnImage", data.pos and data.pos >= EQUIP.FASION_START and data.pos <= EQUIP.FASIONG_END, item)

                -- 图标左下角限制交易/限时标记
        local image = self:getControl("ItemImage", nil, item)
        if InventoryMgr:isTimeLimitedItem(data) then
            InventoryMgr:addLogoTimeLimit(image)
        elseif InventoryMgr:isLimitedItem(data) then
            InventoryMgr:addLogoBinding(image)
        end
    else
        self:setImagePlist("BKImage", ResMgr.ui.bag_no_item_bg_img, item)
        self:setCtrlVisible("OwnImage", false, item)
    end




    -- 绑定事件
    self:bindTouchEndEventListener(item, self.onClickItemPanel)
end


-- 选中道具
function JuBaoUserViewSelfDlg:onClickItemPanel(sender)
    if self.choseImage:getParent() == sender then
        -- 取消选择
        self.choseImage:removeFromParent()

    else
        -- 选中新道具(可能是空格)
        self.choseImage:removeFromParent()
        sender:addChild(self.choseImage)
    end
    if not sender.data then return end



    local rect = self:getBoundingBoxInWorldSpace(sender)

    InventoryMgr:showFashioEquip(sender.data, rect, true)
    --[[
    if sender.data.item_type == ITEM_TYPE.EFFECT then
        InventoryMgr:showFashioEquip(sender.data, rect, true)
    else
        local dlg = DlgMgr:openDlg("ItemInfoDlg")
        dlg:setInfoFormCustom(sender.data, true)
        dlg:setFloatingFramePos(rect)
    end
--]]

end

function JuBaoUserViewSelfDlg:onFashionCheckBox(sender, eventType)
    for checkBoxName, panelNameTab in pairs(FASHION_CHECK_BOXS_DISPLAY) do
        for _, pName in pairs(panelNameTab) do
            self:setCtrlVisible(pName, false)
        end
    end

    for _, pName in pairs(FASHION_CHECK_BOXS_DISPLAY[sender:getName()]) do
        self:setCtrlVisible(pName, true)
    end

    self.fashionType = sender:getName()

    -- 选择自定义，默认选择头部
    if sender:getName() == "CustomDressButton" then
        self.customGroup:selectRadio(2, true)
        self:onCustomCheckBox(self:getControl("HairCheckBox"), 2)
    else
        self:refreshCustomListView()
    end

    -- 设置时装、特效 道具
    local panel = self:getControl("ItemPanel", nil, "EffectAndFashionPanel")
    if sender:getName() == "FashionDressButton" then
        if self.equipData and self.equipData[31] then
            self:setUnitEquip(self.equipData[31], panel)
        else
            self:setUnitEquip(nil, panel)
        end
    elseif sender:getName() == "EffectButton" then
        if self.equipData and self.equipData[32] then
            self:setUnitEquip(self.equipData[32], panel)
        else
            self:setUnitEquip(self.equipData[32], panel)
        end
    elseif sender:getName() == "PetButton" then
        if self.equipData and self.equipData[EQUIP.EQUIP_FOLLOW_PET] then
            self:setUnitEquip(self.equipData[EQUIP.EQUIP_FOLLOW_PET], panel)
        else
            self:setUnitEquip(self.equipData[EQUIP.EQUIP_FOLLOW_PET], panel)
        end
    end

    local userPanel = self:getControl("UserPanel_2")

    -- 设置形象
    if sender:getName() == "FashionDressButton" then    -- 时装
        if self:isUnValiedGender() then
            local gender = self.isFemale and 2 or 1
            local icon = gf:getIconByGenderAndPolar(gender, self.data.polar)
            self:setPortrait("UserPanel_2", icon)
        elseif self.equipData and self.equipData[31] then
            self:setPortrait("UserPanel_2", InventoryMgr:getFashionShapeIcon(self.equipData[31].name))
        else
            self:setShape("UserPanel_2")
        end
    end

    if sender:getName() == "EffectButton" then          -- 特效

        self:setShape("UserPanel_2")

        if not userPanel.effect and self.equipData and self.equipData[32] then

            local mIcon = FashionEffect[self.equipData[32].name] and FashionEffect[self.equipData[32].name].fasion_effect

            local charAction = userPanel:getChildByTag(Dialog.TAG_PORTRAIT)
            local magic = LightEffects[mIcon]
            local size = userPanel:getContentSize()
            local pos = cc.p(charAction:getPosition())
            if 2 == magic.pos then
                local x, y = charAction:getWaistOffset()
                pos = cc.p(pos.x + x, pos.y + y)
            elseif 3 == magic.pos then
                local x, y = charAction:getHeadOffset()
                pos = cc.p(pos.x + x, pos.y + y)
            else
                pos = cc.p(pos.x, pos.y)
            end

            self:addMagicToCtrl("UserPanel_2", magic.icon, nil, pos, 5, magic.extraPara)
            userPanel.effect = magic.icon
        end
    else
        self:removeLoopMagicFromCtrl("UserPanel_2", userPanel.effect)
        userPanel.effect = nil
    end

    if sender:getName() == "CustomDressButton" then     -- 自定义
        self:setCustonShape()
    end

    if sender:getName() == "PetButton" then             -- 跟宠
        self:setShape("UserPanel_2")
        local petIcon
        if self.equipData and self.equipData[EQUIP.EQUIP_FOLLOW_PET] then
            local followPet = FollowPet[self.equipData[EQUIP.EQUIP_FOLLOW_PET].name]
            petIcon = followPet and followPet.effect_icon
        else
            petIcon = 0
        end

        self:setPortrait("UserPanel_2", petIcon, 0, nil, nil, nil, nil, FOLLOW_SPRITE_OFFPOS[5], nil, nil, 5, Dialog.TAG_PORTRAIT1)
    else
        self:setPortrait("UserPanel_2", 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, Dialog.TAG_PORTRAIT1)
    end

    self:setFashionEquip()
end

function JuBaoUserViewSelfDlg:getPartString(parts)
    if not parts then return "" end
    return gf:makePartString(parts[1] and parts[1].partIndex or 0, parts[2] and parts[2].partIndex or 0,
        parts[3] and parts[3].partIndex or 0, parts[4] and parts[4].partIndex or 0, parts[5] and parts[5].partIndex or 0)
end

function JuBaoUserViewSelfDlg:getPartColorString(parts)
    if not parts then return "" end
    return gf:makePartColorString(0, parts[1] and parts[1].colorIndex or 0, parts[2] and parts[2].colorIndex or 0,
        parts[3] and parts[3].colorIndex or 0, parts[4] and parts[4].colorIndex or 0,
        parts[5] and parts[5].colorIndex or 0)
end

function JuBaoUserViewSelfDlg:isUnValiedGender()
    local gender = self.isFemale and 2 or 1
    if self.data.gender ~= gender then
        return true
    end

    return false
end

-- 设置自定义形象
function JuBaoUserViewSelfDlg:setCustonShape()
    local parts = {}
    local icon = 0

    local equipPos = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
    for i = 1, #equipPos do
        if self.equipData[equipPos[i]] then
            local nitem = {}
            local itemInfo = InventoryMgr:getItemInfoByName(self.equipData[equipPos[i]].name)
            local custItem = CustomItem[self.equipData[equipPos[i]].name]
            nitem.part = itemInfo.part
            nitem.gender = itemInfo.gender
            nitem.partIndex = custItem.fasion_part
            nitem.colorIndex = custItem.fasion_dye
            parts[itemInfo.part] = nitem
            icon = custItem.fasion_role
        end
    end

    local partString = self:getPartString(parts)
    local partColorString = self:getPartColorString(parts)

    icon = self.isFemale and 60001 or 61001

    if self:isUnValiedGender() then
        partString = ""
        partColorString = ""
    end

    local argList = {
        panelName = "UserPanel_2",
        icon = icon,
        weapon = 0,
        root = nil,
        action = nil,
        clickCb = nil,
        offPos = nil,
        orgIcon = nil,
        syncLoad = nil,
        dir = 5,
        pTag = nil,
        extend = nil,
        partIndex = partString,
        partColorIndex = partColorString,
    }

    local charAction = self:setPortraitByArgList(argList)
end

function JuBaoUserViewSelfDlg:initCtrlVisible()
    self:setCtrlVisible("EquipmentPanel", true)
    self:setCtrlVisible("SuitButton_1", true)
    self:setCtrlVisible("SuitButton_2", false)
    self:setCtrlVisible("WeddingButton", true)
    self:setCtrlVisible("WeddingItemPanel", false)
    self:setCtrlVisible("SuitButton", false)
    self:setCtrlVisible("CommonPanel", false)

    for checkBoxName, panelNameTab in pairs(FASHION_CHECK_BOXS_DISPLAY) do
        for _, pName in pairs(panelNameTab) do
            self:setCtrlVisible(pName, false)
        end
    end

    self:setCtrlVisible("AttribPanel", true)

    self:setCtrlVisible("UserPanel_1", true)
    self:setCtrlVisible("UserPanel_2", false)
end

-- 设置数据
function JuBaoUserViewSelfDlg:setDataFormMgr()
    -- 设置数据
    if self.goods_gid then
        local userData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
        if userData then
            self:setUserData(userData, self.goods_gid)
        else
            TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
        end

        local equipData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EQUIP)
        if equipData then
            self:setEquipData(equipData, self.goods_gid)
        else
            TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EQUIP)
        end
    end
end

-- 初始化右侧listView信息
function JuBaoUserViewSelfDlg:initListView()
    for checkBox, displayPanel in pairs(CHECK_BOXS_DISPLAY) do
        self:setCtrlVisible(displayPanel, false)
    end
    local attPanel = self:getControl("CharAttribInfoPanel")
    attPanel:setVisible(true)
    attPanel:removeFromParent()
    self:getControl("CharAttribListView"):pushBackCustomItem(attPanel)

    local basicPanel = self:getControl("CharBasicInfoPanel")
    basicPanel:setVisible(true)
    basicPanel:removeFromParent()
    self:getControl("CharBasicListView"):pushBackCustomItem(basicPanel)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECK_BOXS, self.onCheckBox)
    self.radioGroup:setSetlctByName(CHECK_BOXS[1])


end


-- 点击单选框
function JuBaoUserViewSelfDlg:onCheckBox(sender, eventType)
    for checkBox, displayPanel in pairs(CHECK_BOXS_DISPLAY) do
        self:setCtrlVisible(displayPanel, false)

        self:setCtrlVisible("ChosenPanel", false, checkBox)
        self:setCtrlVisible("UnChosenPanel", true, checkBox)
    end

    self:setCtrlVisible("ChosenPanel", true, sender)
    self:setCtrlVisible("UnChosenPanel", false, sender)
    self:setCtrlVisible(CHECK_BOXS_DISPLAY[sender:getName()], true)
end

function JuBaoUserViewSelfDlg:setGid(gid)
    self.goods_gid = gid

    DlgMgr:sendMsg("JuBaoUserViewTabDlg", "setGid", gid)
end

function JuBaoUserViewSelfDlg:setShape(panelName)
    -- 设置形象
    local data = self.data
    local off = nil
    if panelName == "UserPanel_1" then
        off = {}
        off.x = 0
        off.y = -5
    end

    if self.curSuit == 1 then
        if data.suit_icon ~= 0 then
            self:setPortrait(panelName, data.suit_icon, data.weapon_icon, nil, nil, nil, nil, off, data["icon"])
        else
            self:setPortrait(panelName, data.icon, data.weapon_icon, nil, nil, nil, nil, off, data["icon"])
        end
    else
        if data.back_suit_icon and data.back_suit_icon ~= 0 then
            -- WDSY-29959未处理聚宝斋已上架角色旧数据，导致back_suit_icon,back_weapon_icon字段有可能为空
            -- back_suit_icon为空时显示原始icon，back_weapon_icon为空不显示武器
            self:setPortrait(panelName, data.back_suit_icon, data.back_weapon_icon, nil, nil, nil, nil, off, data["icon"])
        else
            self:setPortrait(panelName, data.icon, data.back_weapon_icon, nil, nil, nil, nil, off, data["icon"])
        end
    end
end

function JuBaoUserViewSelfDlg:setUserData(data, gid)
    if gid ~= self.goods_gid then return end

    self.data = data
    self:setShape("UserPanel_1")

    -- 请求 时装、特效、自定义
    TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FASION)

    TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CUSTOM)

    TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EFFECT)

    TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FOLLOW_PET)

    TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CHILD)

    self.isFemale = data.gender == 2 and true or false
    self:createSwichButton(self:getControl("SexPanel"), self.isFemale, function(dlg, isOn)
        self.isFemale = isOn

        self:onFashionCheckBox(self:getControl(self.fashionType))
    end)

    -- 仙魔光效
    if data["upgrade_type"] then
        self:addUpgradeMagicToCtrl("UserPanel", data["upgrade_type"], nil, true)
    end

    -- 名字
    self:setLabelText("NameLabel_2", gf:getRealName(data.name))
    self:setLabelText("NameLabel_1", gf:getRealName(data.name))

    self:setUserAttribInfo(data)

    self:setUserBasicInfo(data)
end

function JuBaoUserViewSelfDlg:onClickEquipPanel(sender, eventType)

    if not sender.data then return end
    local equip = sender.data

    local rect = self:getBoundingBoxInWorldSpace(sender)

    if equip.item_type == ITEM_TYPE.ARTIFACT then  -- 法宝
        InventoryMgr:showArtifactByArtifact(equip, rect, true)
    else
        if EquipmentMgr:isJewelry(equip) then
            InventoryMgr:showJewelryByJewelry(equip, rect, true)
        else
            if InventoryMgr:isEquipFloat(equip) then
                InventoryMgr:showEquipByEquipment(equip, rect, true)
            else
                local dlg = DlgMgr:openDlg("EquipmentInfoCampareDlg")
                dlg:setFloatingCompareInfo(equip)
            end
        end
    end

end

-- 设置单个装备
function JuBaoUserViewSelfDlg:setUnitEquip(data, panel, imageToNotItem)
    if not data then
        if imageToNotItem then
            self:setImage("Image", imageToNotItem, self:getControl("Image", nil, panel))
        end
        self:setCtrlVisible("EquipedPanel", false, panel)
        return
    end

    self:setCtrlVisible("EquipedPanel", true, panel)
    -- icon
    self:setImage("IconImage", ResMgr:getItemIconPath(data["icon"]), panel)
    self:setItemImageSize("IconImage", panel)

    -- 法宝相性
    local image = self:getControl("IconImage", nil, panel)
    InventoryMgr:removeArtifactPolarImage(image)
    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(image, data.item_polar)

        if data.nimbus == 0 then
            gf:addRedEffect(image)
        else
            gf:removeRedEffect(image)
        end
    end

    -- 等级
    if data.req_level and data.req_level > 0 then
        self:setNumImgForPanel("EquipedPanel", ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    end

    if data.level and data.level > 0 then
        -- 法宝字段level等级
        self:setNumImgForPanel("EquipedPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    end

    --[[ 限制交易
    if InventoryMgr:isLimitedItem(data) then
        InventoryMgr:addLogoBinding(image)
    end
--]]

    InventoryMgr:removeLogoTimeLimit(image)
    InventoryMgr:removeLogoBinding(image)
        -- 图标左下角限制交易/限时标记
    if InventoryMgr:isTimeLimitedItem(data) then
        InventoryMgr:addLogoTimeLimit(image)
    elseif InventoryMgr:isLimitedItem(data) then
        InventoryMgr:addLogoBinding(image)
    end


    --
    local magicPath = InventoryMgr:getEquipEffect(data)
    local lastMagic = image:getChildByName("magic")

    if lastMagic then
        lastMagic:removeFromParent()
    end

    if magicPath then
        local magic = ccui.ImageView:create(magicPath, ccui.TextureResType.plistType)
        --local magic = gf:createLoopMagic(magicPath)
        image:addChild(magic)
        local size = image:getContentSize()
        magic:setPosition(size.width / 2, size.height / 2)
        magic:setName("magic")
    end
end

function JuBaoUserViewSelfDlg:setEquipData(data, gid)
    if gid ~= self.goods_gid then return end

    self.equipData = data

    for i = 1, 10 do
        self:bindListener(POS_PANEL[i], self.onClickEquipPanel)
    end

    if self.curSuit == 1 then
        for i = 1, 10 do
            local panel = self:getControl(POS_PANEL[i])
            if data[i] then
                panel.data = data[i]
                self:setUnitEquip(data[i], panel)
            else
                panel.data = nil
                self:setCtrlVisible("EquipedPanel", false, panel)
            end
        end
    else
        for i = 11, 19 do
            local panel = self:getControl(POS_PANEL[i])
            if data[i] then
                panel.data = data[i]
                self:setCtrlVisible("EquipedPanel", true, panel)
                self:setUnitEquip(data[i], panel)
            else
                panel.data = nil
                self:setCtrlVisible("EquipedPanel", false, panel)
            end
        end
    end

    --[[ 婚服
    for i = 31, 32 do
        if data[i] then
            self:setUnitEquip(data[i], POS_PANEL[i])
            local panel = self:getControl(POS_PANEL[i])
            panel.data = data[i]
            self:bindListener(POS_PANEL[i], self.onWeddingPanel)
        end
    end
    --]]

    -- 自定义
    self:setFashionEquip()
end


function JuBaoUserViewSelfDlg:setFashionEquip()
    local data = self.equipData


    -- 设置时装、特效 道具
    local panel = self:getControl("ItemPanel", nil, "EffectAndFashionPanel")
    if self.fashionType == "FashionDressButton" then
        if data and data[31] then
            self:setUnitEquip(data[31], panel)
            panel.data = data[31]
            self:bindTouchEndEventListener(panel, self.onWeddingPanel)
        else
            self:setUnitEquip(nil, panel, ResMgr.ui.equip_fashion_img)
            panel.data = nil
        end
    elseif self.fashionType == "EffectButton" then
        if data and data[32] then
            self:setUnitEquip(data[32], panel)
            panel.data = data[32]
            self:bindTouchEndEventListener(panel, self.onWeddingPanel)
        else
            self:setUnitEquip(data[32], panel, ResMgr.ui.equip_yupei_img)
            panel.data = nil
        end
    elseif self.fashionType == "PetButton" then
        if data and data[EQUIP.EQUIP_FOLLOW_PET] then
            self:setUnitEquip(data[EQUIP.EQUIP_FOLLOW_PET], panel)
            panel.data = data[EQUIP.EQUIP_FOLLOW_PET]
            self:bindTouchEndEventListener(panel, self.onWeddingPanel)
        else
            self:setUnitEquip(data[EQUIP.EQUIP_FOLLOW_PET], panel, ResMgr.ui.equip_pet_img)
            panel.data = nil
        end
    end

    -- 时装
    local customPanel = self:getControl("CustomPanel")
    for panelName, pos in pairs(CUSTOM_PANEL_POS) do
        local panel = self:getControl(panelName, nil, customPanel)
        if data[pos] then
            self:setUnitEquip(data[pos], panel)
            panel.data = data[pos]
            self:bindTouchEndEventListener(panel, self.onWeddingPanel)
        else
            self:setUnitEquip(data[pos], panel)
            panel.data = nil
        end
    end

    if self:isUnValiedGender() then

        if self.fashionType == "EffectButton" then
        elseif self.fashionType == "PetButton" then
        else
            self:setCtrlVisible("EffectAndFashionPanel", false)
        end
        self:setCtrlVisible("CustomPanel", false)
    end
end

function JuBaoUserViewSelfDlg:onWeddingPanel(sender, eventType)
    if not sender.data then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showFashioEquip(sender.data, rect, true)
end

function JuBaoUserViewSelfDlg:setUnitPanel(data)
end

-- 角色属性
function JuBaoUserViewSelfDlg:setUserAttribInfo(data)
    local mainPanel = self:getControl("CharAttribInfoPanel")

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(data.icon))
    self:setItemImageSize("GuardImage")

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, mainPanel)

    -- 姓名
    self:setLabelText("NameLabel", gf:getRealName(data.name), mainPanel)

    -- 道行
    self:setLabelText("TaoLabel", string.format(CHS[4100404], gf:getTaoStr(data.tao, 0)))

    -- 内丹境界
    self:setLabelText("InnerLabel", CHS[7100156], mainPanel)
    if InnerAlchemyMgr:isInnerAlchemyOpen(data.upgrade_level, data.upgrade_type) then
        local innerState = data.neidan_state
        local innerStage = data.neidan_stage
        if innerState and innerState > 0 and innerStage and innerStage > 0 then
            self:setLabelText("InnerLabel", string.format(CHS[7100147], InnerAlchemyMgr:getAlchemyState(innerState),
                InnerAlchemyMgr:getAlchemyStage(innerStage)), mainPanel)
        end
    end

    -- 元婴
    if data.upgrade_level and data.upgrade_level ~= 0 then
        self:setLabelText("BabyLabel_1", gf:getChildName(data.upgrade_type), "InfoPanel_12")
        self:setLabelText("BabyLabel_3", data.upgrade_level, "InfoPanel_12")
    else
        self:setLabelText("BabyLabel_1", CHS[4100560], "InfoPanel_12")
        self:setLabelText("BabyLabel_3", CHS[5000059], "InfoPanel_12")
    end

    -- 仙魔类型
    if data.upgrade_type == CHILD_TYPE.UPGRADE_IMMORTAL then
        self:setLabelText("UpgradeLabel_3", CHS[7190115], "InfoPanel_12")
    elseif data.upgrade_type == CHILD_TYPE.UPGRADE_MAGIC then
        self:setLabelText("UpgradeLabel_3", CHS[7190114], "InfoPanel_12")
    else
        self:setLabelText("UpgradeLabel_3", CHS[7002286], "InfoPanel_12")
    end


    -- 气血
    self:setLabelText("LifeLabel_3", data.max_life)
    -- 物伤
    self:setLabelText("PhyPowerLabel_3", data.phy_power)
    -- 法力
    self:setLabelText("ManaLabel_3", data.max_mana)
    -- 法伤
    self:setLabelText("MagPowerLabel_3", data.mag_power)
    -- 速度
    self:setLabelText("SpeedLabel_3", data.speed)
    -- 防御
    self:setLabelText("DefLabel_3", data.def)

    -- 体质
    self:setLabelText("ConLabel_3", data.con)
    -- 灵力
    self:setLabelText("WizLabel_3", data.wiz)
    -- 力量
    self:setLabelText("StrLabel_3", data.str)
    -- 敏捷
    self:setLabelText("DexLabel_3", data.dex)
    -- 未分配
    self:setLabelText("UnAssignLabel_3", data.attrib_point, "InfoPanel_2")

    -- 金
    self:setLabelText("MetalLabel_3", data.metal)
    -- 木
    self:setLabelText("WoodLabel_3", data.wood)
    -- 水
    self:setLabelText("WaterLabel_3", data.water)
    -- 火
    self:setLabelText("FireLabel_3", data.fire)
    -- 土
    self:setLabelText("EarthLabel_3", data.earth)
    -- 未分配
    self:setLabelText("UnAssignLabel_3", data.polar_point, "InfoPanel_3")

    -- 抗金
    self:setLabelText("ResitMetalLabel_3", data.resist_metal .. "%")
    -- 抗木
    self:setLabelText("ResitWoodLabel_3", data.resist_wood .. "%")
    -- 抗水
    self:setLabelText("ResitWaterLabel_3", data.resist_water .. "%")
    -- 抗火
    self:setLabelText("ResitFireLabel_3", data.resist_fire .. "%")
    -- 抗土
    self:setLabelText("ResitEarthLabel_3", data.resist_earth .. "%")

    -- 忽视抗金
    self:setLabelText("IgnoreResitMetalLabel_3", data.ignore_resist_metal .. "%")
    -- 忽视抗木
    self:setLabelText("IgnoreResitWoodLabel_3", data.ignore_resist_wood .. "%")
    -- 忽视抗水
    self:setLabelText("IgnoreResitWaterLabel_3", data.ignore_resist_water .. "%")
    -- 忽视抗火
    self:setLabelText("IgnoreResitFireLabel_3", data.ignore_resist_fire .. "%")
    -- 忽视抗土
    self:setLabelText("IgnoreResitEarthLabel_3", data.ignore_resist_earth .. "%")
    -- 抗遗忘
    self:setLabelText("ResitForgottenLabel_3", data.resist_forgotten .. "%")
    -- 抗中毒
    self:setLabelText("ResitPoisonLabel_3", data.resist_poison .. "%")
    -- 抗冰冻
    self:setLabelText("ResitFrozenLabel_3", data.resist_frozen .. "%")
    -- 抗昏睡
    self:setLabelText("ResitSleepLabel_3", data.resist_sleep .. "%")
    -- 抗混乱
    self:setLabelText("ResitConfusionLabel_3", data.resist_confusion .. "%")

    -- 忽视抗金
    self:setLabelText("IgnoreResitForgottenLabel_3", data.ignore_resist_forgotten .. "%")
    -- 忽视抗木
    self:setLabelText("IgnoreResitPoisonLabel_3", data.ignore_resist_poison .. "%")
    -- 忽视抗水
    self:setLabelText("IgnoreResitFrozenLabel_3", data.ignore_resist_frozen .. "%")
    -- 忽视抗火
    self:setLabelText("IgnoreResitSleepLabel_3", data.ignore_resist_sleep .. "%")
    -- 忽视抗土
    self:setLabelText("IgnoreResitConfusionLabel_3", data.ignore_resist_confusion .. "%")

    -- 潜能
    self:setLabelText("PotLabel_3", data.pot)

    -- 仙道
    self:setLabelText("XianLabel_3", data.upgrade_immortal or 0)
    -- 魔道
    self:setLabelText("MoLabel_3", data.upgrade_magic or 0)
    -- 未分配
    self:setLabelText("UnAssignLabel_3", data.upgrade_total or 0, "InfoPanel_13")

    -- 设置技能
    self:setSkills(data)

    -- 部分属性受到坐骑属性加成，若没有，需要设置panel的size，隐藏提示
    local panel1 = self:getControl("InfoPanel_1")
    self.initInfoPanelSize1 = self.initInfoPanelSize1 or panel1:getContentSize()

    local panel2 = self:getControl("InfoPanel_2")
    self.initInfoPanelSize2 = self.initInfoPanelSize2 or panel2:getContentSize()

    local panel3 = self:getControl("InfoPanel_13")
    self.initInfoPanelSize3 = self.initInfoPanelSize3 or panel3:getContentSize()

    self.innerSize = self.innerSize or mainPanel:getContentSize()

    self:setCtrlVisible("NotePanel", data.mount_flw_valid == 1, panel1)
    self:setCtrlVisible("NotePanel", data.mount_flw_valid == 1, panel2)
    self:setCtrlVisible("NotePanel", data.mount_flw_valid == 1, panel3)
    if data.mount_flw_valid == 1 then
        panel1:setContentSize(self.initInfoPanelSize1)
        panel2:setContentSize(self.initInfoPanelSize2)
        panel3:setContentSize(self.initInfoPanelSize3)
        mainPanel:setContentSize(self.innerSize)
    else
        panel1:setContentSize(self.initInfoPanelSize1.width, self.initInfoPanelSize1.height - 25)
        panel2:setContentSize(self.initInfoPanelSize2.width, self.initInfoPanelSize2.height - 25)
        panel3:setContentSize(self.initInfoPanelSize3.width, self.initInfoPanelSize3.height - 25)
        mainPanel:setContentSize(self.innerSize.width, self.innerSize.height - 50)
    end

    mainPanel:requestDoLayout()
end

-- 基础信息
function JuBaoUserViewSelfDlg:setUserBasicInfo(data)

    local mainPanel = self:getControl("CharBasicInfoPanel")
    -- 会员
    self:setLabelText("ServiceLabel_3", gf:getVipStr(data.insider_level, data.insider_time), mainPanel)

    -- 帮派
    self:setLabelText("PartyLabel_3", data.party_name, mainPanel)
    -- 帮贡
    self:setLabelText("ContribLabel_3", data.party_contrib, mainPanel)

    -- 好心值
    self:setLabelText("NiceLabel_3", data.nice, mainPanel)

    -- PK值
    if data.total_pk then
        self:setLabelText("PKLabel_3", data.total_pk)
    end

    -- 灵尘
    self:setLabelText("LingChenLabel_3", data.lingchen_point or 0)

    -- 声望
    self:setLabelText("ReputationLabel_3", data.reputation, mainPanel)

    -- 经验锁
    self:setLabelText("ExplockLabel_3", data.is_lock_exp == 1 and CHS[4300460] or CHS[4300461], mainPanel)

    -- 双倍
    self:setLabelText("DoublePointLabel_3", data.double_points, mainPanel)

    -- 急急如律令
    self:setLabelText("JijrllLabel_3", data.jiji_points, mainPanel)

    -- 宠风散
    self:setLabelText("ChongfsLabel_3", data.chongfs_points, mainPanel)

    -- 紫气鸿蒙
    self:setLabelText("ZiqhmLabel_3", data.ziqhm_points, mainPanel)

    -- 首饰精华
    self:setLabelText("JinghuaLabel_3", data.jewelry_essence or 0, mainPanel)

    -- 离线时间
    self:setLabelText("OffLineTimeLabel_3", string.format(CHS[3002679], math.floor(data.shuad_offline_time / 60)), mainPanel)

    -- 神木鼎
    self:setLabelText("ShenmdLabel_3", data.shenmu_points, mainPanel)

    -- 如意刷道令
    self:setLabelText("RuysdlLabel_3", data.ruyi_point or 0)

    -- 气血储备
    self:setLabelText("LifeStoreLabel_3", data.extra_life, mainPanel)

    -- 法力储备
    self:setLabelText("ManaStoreLabel_3", data.extra_mana, mainPanel)

    -- 忠诚储备
    self:setLabelText("LoyaltyStoreLabel_3", data.backup_loyalty, mainPanel)

    -- 卡套空间
    self:setLabelText("CardBagLabel_3", data.card_store_size, mainPanel)

    -- 银元宝
    local silver_coinStr = gf:getMoneyDesc(data.silver_coin, true)
    self:setLabelText("SliverCoinLabel_3", silver_coinStr, mainPanel)

    -- 钱庄
    local balanceStr = gf:getMoneyDesc(data.balance, true)
    self:setLabelText("StoreCashLabel_3", balanceStr, mainPanel)

    -- 游戏币
    local cashStr = gf:getMoneyDesc(data.cash, true)
    self:setLabelText("CashLabel_3", cashStr, mainPanel)

    -- 代金券
    local voucherStr = gf:getMoneyDesc(data.voucher, true)
    self:setLabelText("VoucherLabel_3", voucherStr, mainPanel)

    -- 免费改名次数
    local tempHeight = 0
    if not data.free_rename then
        local panel = self:setCtrlVisible("InfoPanel_15", false)
        panel:setContentSize(panel:getContentSize().width, 1)
        tempHeight = panel:getContentSize().height
    else
    self:setLabelText("RenameLabel_3", string.format(CHS[4300252], data.free_rename))
    end

    -- 称谓

    local  titles =  TradingMgr:getTitleByLenSort(data.appellation)
    if not self.isLoadTitle then
        local titleNameCtl = self:getControl("TitleLabel_1")
        local posY = titleNameCtl:getPositionY()
        local parentPanel = titleNameCtl:getParent()
        for i, titleInfo in pairs(titles) do
            local label = self:getControl("TitleNameLabel_1"):clone()
            label:setString(CharMgr:getChengweiShowName(titleInfo.title))
            label:setPositionY(posY - i * 23)
            parentPanel:addChild(label)
        end
        parentPanel:requestDoLayout()
        self.isLoadTitle = true
    end

    -- PK值
    local pkCutHeight = 0
    self.initPanel8Size = self.initPanel8Size or self:getCtrlContentSize("InfoPanel_8",  mainPanel)
    if not data.total_pk then
        pkCutHeight = 23
        self:setCtrlContentSize("InfoPanel_8", self.initPanel8Size.width, self.initPanel8Size.height - pkCutHeight, mainPanel)
        for i = 1, 3 do
            self:setCtrlVisible("PKLabel_" .. i, false, mainPanel)
        end

        self:setCtrlContentSize("PKLabel_1", nil, 0, mainPanel)
    else
        self:setCtrlContentSize("PKLabel_1", nil, 23, mainPanel)
    end

    mainPanel:setContentSize(self.basicPanelSize.width, self.basicPanelSize.height + 23 * #titles + 5 - tempHeight - pkCutHeight)
    mainPanel:requestDoLayout()
end


function JuBaoUserViewSelfDlg:setSkills(data)
    -- 技能对应的panel表
    local skillPanelName = {"InfoPanel_6", "InfoPanel_7", "InfoPanel_8", "InfoPanel_9", "InfoPanel_10"}

    local skillInfo, hasSkills = TradingMgr:getUserSkillByData(data, skillPanelName)

    local map = {
        [6] = "",
        [7] = "B",
        [8] = "C",
        [9] = "D",
        [10] = "Passive",
    }

    for i = 6, 10 do
        local panelName = "InfoPanel_" .. i
        self:setSkillsPanel(panelName, skillInfo[panelName], hasSkills[panelName], map[i])
        self:updateLayout(panelName)
    end
end

function JuBaoUserViewSelfDlg:setSkillsPanel(panelName, skillInfo, hasSkill, skillType)
    local function getSkillByNameFromTab(skillName, skillTab)
        if not skillTab or not next(skillTab) then return false end
        for _, skill in pairs(skillTab) do
            if skillName == skill.name then
                return skill
            end
        end
    end

    local parentPanel = self:getControl(panelName)
    for i = 1, 5 do
        if skillInfo[i] then
            local panel = self:getControl(skillType .. "SkillPanel_" .. i, nil, parentPanel)
            if panel then
                panel.skillName = skillInfo[i].name
                self:setImage("SkillImage", SkillMgr:getSkillIconPath(skillInfo[i].no), panel)
                self:setItemImageSize("SkillImage", panel)
                self:setLabelText(skillType .. "SkillNameLabel_" .. i, skillInfo[i].name)

                local retSkill = getSkillByNameFromTab(skillInfo[i].name, hasSkill)
                if not retSkill then
                    gf:grayImageView(self:getControl("SkillImage", Const.UIImage, panel))
                    self:setLabelText(skillType .. "SkillLevelLabel_" .. i, 0)
                else
                    self:setLabelText(skillType .. "SkillLevelLabel_" .. i, retSkill.level)
                end

                self:bindTouchEndEventListener(panel, function(obj, sender, type)
                    if panel.skillName then
                        local rect = self:getBoundingBoxInWorldSpace(panel)
                        local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
                        dlg:setSKillByName(panel.skillName , rect)
            end
                end)
        end
    end
    end
end

function JuBaoUserViewSelfDlg:onSuitButton_1(sender, eventType)
    if not self.equipData then return end
    gf:ShowSmallTips(CHS[4300199])
    self.curSuit = 2
    self:setEquipData(self.equipData, self.goods_gid)
    sender:setVisible(false)
    self:setCtrlVisible("SuitButton_2", true)

    self:setShape("UserPanel_1")

    if self.fashionType == "EffectButton" or self.fashionType == "PetButton" then          -- 特效和跟宠
        self:setShape("UserPanel_2")
    end
end

function JuBaoUserViewSelfDlg:onSuitButton_2(sender, eventType)
    if not self.equipData then return end
    self.curSuit = 1
    self:setEquipData(self.equipData, self.goods_gid)
    sender:setVisible(false)
    self:setCtrlVisible("SuitButton_1", true)

    self:setShape("UserPanel_1")
    --self:setShape("UserPanel_2")
    if self.fashionType == "EffectButton" or self.fashionType == "PetButton" then          -- 特效和跟宠
        self:setShape("UserPanel_2")
    end
end

function JuBaoUserViewSelfDlg:onNoteButton(sender, eventType)
    gf:showTipInfo(CHS[4100945], sender)
end

function JuBaoUserViewSelfDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end
    TradingMgr:tryBuyItem(self.goods_gid, self.name)
end

function JuBaoUserViewSelfDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

function JuBaoUserViewSelfDlg:onWeddingButton(sender, eventType)

    local data1 = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EQUIP)
    local data2 = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_FASION)
    local data3 = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CUSTOM)
    local data4 = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EFFECT)

    if not data1 or not data2 or not data3 or not data4 then
        return
    end

    self:setCtrlVisible("EquipmentPanel", false)
    self:setCtrlVisible("SuitButton", true)
    self:setCtrlVisible("WeddingButton", false)

    self:setCtrlVisible("NamePanel", false)

    self:setCtrlVisible("CommonPanel", true)

    self:setCtrlVisible("AttribPanel", false)

    self:setCtrlVisible("UserPanel_1", false)
    self:setCtrlVisible("UserPanel_2", true)


    local data = self.equipData
    local hasCustom = false

    local equipPos = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
    for i = 1, #equipPos do
        if data and data[equipPos[i]] then
            hasCustom = true
        end
    end

    if not self.fashionType then
        if hasCustom then
            -- 策划要求，如果有自定义，默认选择自定义
            self:onFashionCheckBox(self:getControl("CustomDressButton"))
            self.fashionGroup:setSetlctButtonByName("CustomDressButton")
        else
            self:onFashionCheckBox(self:getControl("FashionDressButton"))
            self.fashionGroup:setSetlctButtonByName("FashionDressButton")
        end
    end


    -- 需要根据性别显示的
    local meetGender = {
        EffectAndFashionPanel = 1,
        CustomPanel = 1,
    }

    for _, pName in pairs(FASHION_CHECK_BOXS_DISPLAY[self.fashionType]) do


        if self.fashionType ~= "EffectButton" or self.fashionType ~= "PetButton" then
            if meetGender[pName] then
                if self:isUnValiedGender() then
                    self:setCtrlVisible(pName, false)
                else
                    self:setCtrlVisible(pName, true)
                end
            else
                self:setCtrlVisible(pName, true)
            end
        else
            self:setCtrlVisible(pName, true)
        end

    end


end

function JuBaoUserViewSelfDlg:onSuitButton(sender, eventType)
    self:setCtrlVisible("EquipmentPanel", true)
    self:setCtrlVisible("WeddingItemPanel", false)
    self:setCtrlVisible("SuitButton", false)
    self:setCtrlVisible("WeddingButton", true)
    self:setCtrlVisible("NamePanel", true)
    self:setCtrlVisible("CommonPanel", false)

    self:setCtrlVisible("UserPanel_1", true)
    self:setCtrlVisible("UserPanel_2", false)

    self:setCtrlVisible("AttribPanel", true)
    for checkBoxName, panelNameTab in pairs(FASHION_CHECK_BOXS_DISPLAY) do
        for _, pName in pairs(panelNameTab) do
            self:setCtrlVisible(pName, false)
        end
    end

    self:setShape("UserPanel_1")
end


-- 创建切换按钮
function JuBaoUserViewSelfDlg:createSwichButton(statePanel, isOn, func, key)
    -- 创建滑动开关
    local actionTime = 0.2
    local bkImage1 = self:getControl("ManImage", nil, statePanel)
    local bkImage2 = self:getControl("WomanImage", nil, statePanel)
    local image = self:getControl("ChoseButton", nil, statePanel)
    local psize = statePanel:getContentSize()
    local iSize = image:getContentSize()
    local px1 = iSize.width / 2
    local px2 = psize.width - px1
    local isAtionEnd = true
    image:setTouchEnabled(false)

    statePanel.isOn = isOn
    if isOn then
        image:setPositionX(px2)
    else
        image:setPositionX(px1)
    end

    local function switchColor(isOn)
        if isOn then
            bkImage1:setColor(cc.c3b(51, 51, 51))
            bkImage1:setOpacity(33)
            bkImage2:setColor(cc.c3b(255, 255, 255))
            bkImage2:setOpacity(255)
        else
            bkImage1:setColor(cc.c3b(255, 255, 255))
            bkImage1:setOpacity(255)
            bkImage2:setColor(cc.c3b(51, 51, 51))
            bkImage2:setOpacity(33)
        end
    end

    local function swichButtonAction(self, sender, eventType, data, noCallBack)
        local action
        if isAtionEnd then
            if statePanel.isOn then
                local moveto = cc.MoveTo:create(actionTime, cc.p(px1, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local delayFunc  = cc.CallFunc:create(function ()
                        switchColor(statePanel.isOn)
                        isAtionEnd = true
                        if not noCallBack then
                            func(self, statePanel.isOn, key)
                        end
                    end)

                    local sq = cc.Sequence:create(delayFunc)

                    bkImage2:runAction(sq)
                end)

                action = cc.Sequence:create(moveto, fuc)
                image:runAction(action)

                statePanel.isOn = not statePanel.isOn
            else
                local moveto = cc.MoveTo:create(actionTime, cc.p(px2, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local delayFunc  = cc.CallFunc:create(function ()
                        switchColor(statePanel.isOn)
                        isAtionEnd= true
                        if not noCallBack then
                            func(self, statePanel.isOn, key)
                        end
                    end)

                    local sq = cc.Sequence:create(delayFunc)
                    bkImage1:runAction(sq)
                end)

                action = cc.Sequence:create(moveto, fuc)
                image:runAction(action)
                statePanel.isOn = not statePanel.isOn
            end

        end
    end

    self:bindTouchEndEventListener(statePanel, swichButtonAction)
    local function onNodeEvent(event)
        if "cleanup" == event then
            if not isAtionEnd and func then
                func(self, statePanel.isOn, key)
            end
        end
    end

    statePanel:registerScriptHandler(onNodeEvent)

    statePanel.touchAction = swichButtonAction

    -- 外部强行停止ACTION时，保证isAtionEnd不会因此而无法重置
    image.resetActionEndFlag = function()
        isAtionEnd = true
    end

    switchColor(statePanel.isOn)
end

function JuBaoUserViewSelfDlg:MSG_TRADING_SNAPSHOT(data)
    if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_EQUIP and data.goods_gid == self.goods_gid and self.goods_gid then
        local equipData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_EQUIP)
        if equipData then
            self:setEquipData(equipData, self.goods_gid)
        end
    end
end

return JuBaoUserViewSelfDlg
