-- CustomDressDlg.lua
-- Created by sujl, May/30/2018
-- 自定义换装界面

local CustomDressDlg = Singleton("CustomDressDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local GridPanel = require('ctrl/GridPanel')
local CustomItem = require("cfg/CustomItem")
local FashionEffect = DressMgr:getFashionEffect()
local FollowPet = DressMgr:getFollowPet()

-- 展示按钮状态
local SHOW_BTN_STATE = {
    UNWEAR      = 1,    -- 未穿戴
    SHOW        = 2,    -- 展示中
    HIDE        = 3,    -- 隐藏中
    UNABLE      = 4,    -- 不可用
}

local EQUIP_ROW_SPACE = 15
local GRID_W = 74
local GRID_H = 74

local FOLLOW_SPRITE_OFFPOS = {
    [1] = cc.p(-40, -60),
    [3] = cc.p(40, -60),
    [5] = cc.p(-40, -60),
    [7] = cc.p(40, -60),
}

local COUPLR_EFFECT = {
    ["鸾凤宝玉"] = true,
    ["多彩泡泡"] = true,
    ["翩翩起舞"] = true,
    ["浪漫玫瑰"] = true,
}

-- 预览部件数量
local PREVIEW_ITEM_COUNT = 5

function CustomDressDlg:init()
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("SaveButton", self.onSaveButton)

    -- 绑定类型选择
    self:bindTypeCheck("FashionItemPanel", self.onFashionTypeCheck)
    self:bindTypeCheck("EffectItemPanel", self.onEffectTypeCheck)
    self:bindTypeCheck("CustomItemPanel", self.onCustomTypeCheck)
    self:bindTypeCheck("PetItemPanel", self.onPetTypeCheck )

    -- 隐藏选择菜单
    self:showChoseMenuPanel("FashionItemPanel", false)
    self:showChoseMenuPanel("EffectItemPanel", false)
    self:showChoseMenuPanel("CustomItemPanel", false)
    self:showChoseMenuPanel("PetItemPanel", false)

    -- 列表控件
    self.choseImage = self:retainCtrl("ChoseImage", nil, "CustomItemPanel")
    self.showPanel = self:retainCtrl("ShowPanel_1", nil, self:getControl("ShowListView", nil, "CustomItemPanel"))

    -- 初始化面板数据
    self.dir = 5
    self.isFemale = 2 == Me:queryBasicInt("gender")
    self.icon = gf:getIconByGenderAndPolar(Me:queryBasicInt("gender"), Me:queryBasicInt("polar"))
    self.orgIcon = Me:queryBasicInt("icon")
    self:initFashionPanels()
    self:initCustomPanels()
    self:initEffectPanels()
    self:initPetPanels()
    self:initCommonPanel()

    self:setCtrlVisible("CheckButton", false)

    self.typeRaido = RadioGroup.new()
    self.typeRaido:setItems(self, { "DressDlgCheckBox", "EffectDlgCheckBox", "PetDlgCheckBox", "RuleDlgCheckBox" }, function(dlg, sender, index)
        self:setCtrlVisible("BackDecorationPanel", false)

        if 1 == index then
            -- 默认选择时装
            local dressLabel = InventoryMgr:getDressLabel()
            if -1 == dressLabel or 0 == dressLabel then
                self:onFashionDressButton()
            elseif 1 == dressLabel then
                self:onCustomDressButton()
            end

            self:showEffectDressPanel(false)
            self:showPetDressPanel(false)
            self:refreshListView()
            self.lastShowPanel = nil
        elseif 2 == index then
            self:showFashionDressPanel(false)
            self:showCustomDressPanel(false)
            self:showPetDressPanel(false)
            self:showEffectDressPanel(true)

            --StoreMgr:cmdStoreMagicItems()
            self:beginBatchUpdate()
            gf:CmdToServer("CMD_FASION_EFFECT_VIEW")

            self.checkState = nil
            self:refreshListPanelText()
            if self.curShowPanel == "FashionPanel" or self.curShowPanel == "CustomPanel" then
            self.lastShowPanel = self.curShowPanel
            end
            self.curShowPanel = "EffectPanel"

            self:refreshCommonPanel()
            self:refreshListView({})
        elseif 3 == index then
            self:showFashionDressPanel(false)
            self:showCustomDressPanel(false)
            self:showEffectDressPanel(false)
            self:showPetDressPanel(true)

            self:beginBatchUpdate()
            gf:CmdToServer("CMD_FOLLOW_PET_VIEW")

            self.checkState = nil
            self:refreshListPanelText()
            if self.curShowPanel == "FashionPanel" or self.curShowPanel == "CustomPanel" then
            self.lastShowPanel = self.curShowPanel
            end
            self.curShowPanel = "PetPanel"

            self:refreshCommonPanel()
            self:refreshListView({})
        end

        self:setCtrlVisible("RulePanel", 4 == index)
        self:setCtrlVisible("MainPanel", 4 ~= index)

        self:refreshCommonButton()
    end, "SwitchPanel")

    self.typeRaido:selectRadio(1)

    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_FASION_FAVORITE_LIST")
    self:hookMsg("MSG_FASION_CUSTOM_LIST")
    self:hookMsg("MSG_FASION_EFFECT_LIST")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_APPEARANCE")
    self:hookMsg("MSG_FASION_FAVORITE_APPLY")
    self:hookMsg("MSG_FASION_CUSTOM_END")
    self:hookMsg("MSG_FASION_CUSTOM_BEGIN")
    self:hookMsg("MSG_FOLLOW_PET_VIEW")

    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function CustomDressDlg:cleanup()
    self.curShowPanel = nil
    self.icon = nil
    self.parts = nil
    self.isFemale = nil
    self.checkPart = nil
    self.hideEffect = nil
    self.lastShowPanel = nil
    self.selFashionItem = nil
    self.selMagicItem = nil
    self.selPetItem = nil
    self.partString = nil
    self.partColorString = nil
    self.showTips = nil
    self.dirtyListView = nil
    self.dirtyIcon = nil
    self.dirtyCommonPanel = nil
    self.dirtyEffectButton = nil
    self.batchUpdate = nil
    self.magic = nil
    self.followPet = nil

    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function CustomDressDlg:onOpenDlgRequestData(sender, eventType)
    if self.curShowPanel == "EffectPanel" then
        gf:CmdToServer("CMD_FASION_CUSTOM_SWITCH", {fasion_label = self.lastShowPanel == "FashionPanel" and 0 or 1})
    else
        gf:CmdToServer("CMD_FASION_CUSTOM_SWITCH", {fasion_label = (self.curShowPanel == "FashionPanel" and 0 or 1)})
    end

    self:beginBatchUpdate()
end

-- 初始化通用面板
function CustomDressDlg:initCommonPanel()
    local panel = "CommonPanel"
    self:bindListener("TurnRightButton", self.onTurnRightButton, panel)
    self:bindListener("TurnLeftButton", self.onTurnLeftButton, panel)
    self:bindListener("FashionDressButton", self.onFashionDressButton, panel)
    self:bindListener("CustomDressButton", self.onCustomDressButton, panel)
    self:bindListener("EffectOpenButton", self.onEffectOpenButton, panel)
    self:bindListener("EffectCloseButton", self.onEffectCloseButton, panel)
    self:bindListener("ShowOpenButton", self.onShowOpenButton, panel)
    self:bindListener("ShowCloseButton", self.onShowCloseButton, panel)
    self:bindListener("ResetButton", self.onResetButton, panel)

    local dressLabel = InventoryMgr:getDressLabel()
    self:setCtrlVisible("DownPanel", -1 == dressLabel, panel)

    -- 默认开启
    self:refreshEffectButton()

    self:createSwichButton(self:getControl("SexPanel", nil, panel), self.isFemale, function(dlg, isOn)
        self.isFemale = isOn
        self.selFashionItem = nil
        self.selMagicItem = nil
        self.selPetItem = nil
        self.parts = nil
        self:resetIcon()
        self:refreshCommonPanel()

        -- 重置道具的过滤条件
        self.checkState = nil
        self:refreshListPanelText()

        -- 刷新右侧道具列表
        self:refreshListView()

        local gender = self.isFemale and 2 or 1
        if gender ~= Me:queryBasicInt("gender") then
            gf:ShowSmallTips(CHS[2100174])
        end
    end)
end

-- 刷新通用面板数据
function CustomDressDlg:refreshCommonPanel()
    local panel = "CommonPanel"
    self:switchButton(self:getControl("SexPanel", nil, panel), self.isFemale)

    local userPanel = self:getControl("UserPanel", nil, panel)
    if userPanel.icon ~= self.icon then
        self.dir = 5
    end

    local argList = {
        panelName = "UserPanel",
        icon = self.icon,
        weapon = 0,
        root = panel,
        action = nil,
        clickCb = nil,
        offPos = nil,
        orgIcon = self.orgIcon,
        syncLoad = nil,
        dir = self.dir,
        pTag = nil,
        extend = nil,
        partIndex = self.partString,
        partColorIndex = self.partColorString,
    }

    local charAction = self:setPortraitByArgList(argList)

    userPanel.icon = self.icon

    if userPanel.effect then
        self:removeLoopMagicFromCtrl("UserPanel", userPanel.effect, panel)
    end

    local isFollowEffect
    if self.magic then
        local lightEffects = require("cfg/LightEffect")
        local magic = lightEffects[self.magic]
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
        self:addMagicToCtrl("UserPanel", magic.icon, panel, pos, self.dir)
        userPanel.effect = magic.icon
        isFollowEffect = magic.follow_dis and magic.follow_dis > 0 or false
    else
        userPanel.effect = nil
    end

    local argList = {
        panelName = "UserPanel",
        icon = self.followPet,
        weapon = 0,
        root = panel,
        action = nil,
        clickCb = nil,
        offPos = FOLLOW_SPRITE_OFFPOS[self.dir],
        orgIcon = nil,
        syncLoad = nil,
        dir = self.dir,
        pTag = Dialog.TAG_PORTRAIT1,
        extend = nil,
        -- partIndex = self.partString,
        -- partColorIndex = self.partColorString,
    }

    self:setPortraitByArgList(argList)

    if self.followPet and self.followPet ~= 0 then
        local acts = gf:getAllActionByIcon(self.followPet, {[Const.SA_STAND] = true, [Const.SA_DIE] = true})
        self:displayPlayActions("UserPanel", nil, FOLLOW_SPRITE_OFFPOS[self.dir], Dialog.TAG_PORTRAIT1, acts)
    end

    userPanel.followPet = self.followPet

    self:refreshPanelTips()
    self:refreshShowButton()

    local panel = self:getControl("UserPanel")
    local actKey = "act" .. tostring(Dialog.TAG_PORTRAIT)
    if panel[actKey] then
        panel:stopAction(panel[actKey])
        panel[actKey] = nil
    end
    if isFollowEffect then
        charAction:setAction(Const.SA_STAND)
        charAction:playAction(nil, Const.SA_WALK, 0)
    else
        self:displayPlayActions("UserPanel", nil, -36)
    end
end

function CustomDressDlg:refreshCommonButton()
    if self.curShowPanel == "PetPanel" then
        self:setCtrlVisible("EffectOpenButton", false, "CommonPanel")
        self:setCtrlVisible("EffectCloseButton", false, "CommonPanel")
        self:setCtrlVisible("ShowOpenButton", false, "CommonPanel")
        self:setCtrlVisible("ShowCloseButton", false, "CommonPanel")
        self:setCtrlVisible("SaveButton", false)
    else
        self:setCtrlVisible("EffectOpenButton", self.hideEffect ~= true, "CommonPanel")
        self:setCtrlVisible("EffectCloseButton", self.hideEffect == true, "CommonPanel")
        self:setCtrlVisible("ShowOpenButton", Me:isShowDress(), "CommonPanel")
        self:setCtrlVisible("ShowCloseButton", not Me:isShowDress(), "CommonPanel")
        self:setCtrlVisible("SaveButton", true)
    end
end

function CustomDressDlg:getPartString(parts)
    if not parts then return "" end
    return gf:makePartString(
        parts[1] and parts[1].partIndex or 0,
        parts[2] and parts[2].partIndex or 0,
        parts[3] and parts[3].partIndex or 0,
        parts[4] and parts[4].partIndex or 0,
        parts[5] and parts[5].partIndex or 0
    )
end

function CustomDressDlg:getPartColorString(parts)
    if not parts then return "" end
    return gf:makePartColorString(0, parts[1] and parts[1].colorIndex or 0, parts[2] and parts[2].colorIndex or 0,
        parts[3] and parts[3].colorIndex or 0, parts[4] and parts[4].colorIndex or 0,
        parts[5] and parts[5].colorIndex or 0)
end

-- 刷新特效开关
function CustomDressDlg:refreshEffectButton()
    -- 特效开关状态
    if Me:isShowEffect() and InventoryMgr:getItemByPos(EQUIP.FASION_BALDRIC) then
        self:onEffectCloseButton()
    else
        self:onEffectOpenButton()
    end
end

-- 刷新展示按钮
function CustomDressDlg:refreshShowButton()
    local isShow = Me:isShowDress()
    local gender = self.isFemale and 2 or 1
    local genderMatch = gender == Me:queryBasicInt("gender")
    isShow = isShow and genderMatch
    self.showTips = nil
    if not genderMatch then
        self.showTips = CHS[2200130]
    end

    local showPanel
    if 'EffectPanel' == self.curShowPanel or 'PetPanel' == self.curShowPanel then
        showPanel = self.lastShowPanel
    else
        showPanel = self.curShowPanel
    end
    local isEquip = ('FashionPanel' == showPanel and #(InventoryMgr:getFashionValue(true)) > 0) or ('CustomPanel' == showPanel and InventoryMgr:isCustomValueFull())
    isShow = isShow and isEquip
    if not isEquip then
        if 'FashionPanel' == showPanel then
            self.showTips = CHS[2200131]
        elseif 'CustomPanel' == showPanel then
            self.showTips = CHS[2200132]
        end
    end

    if isShow then
        self:onShowCloseButton()
    else
        self:onShowOpenButton()
    end
end

function CustomDressDlg:refreshListPanelText()
    if not self.checkState then
        self:setLabelText("Label1", CHS[2100180], self:getControl("TypeCheckBox", nil, "CustomItemPanel"))  -- 所有部件
        self:setLabelText("Label1", CHS[2100181], self:getControl("TypeCheckBox", nil, "FashionItemPanel")) -- 所有时装
        self:setLabelText("Label1", CHS[2100182], self:getControl("TypeCheckBox", nil, "EffectItemPanel"))  -- 所有特效
        self:setLabelText("Label1", CHS[2500073], self:getControl("TypeCheckBox", nil, "PetItemPanel"))       -- 所有跟宠
    elseif 1 == self.checkState then
        self:setLabelText("Label1", CHS[2100183], self:getControl("TypeCheckBox", nil, "CustomItemPanel"))
        self:setLabelText("Label1", CHS[2100183], self:getControl("TypeCheckBox", nil, "FashionItemPanel"))
        self:setLabelText("Label1", CHS[2100183], self:getControl("TypeCheckBox", nil, "EffectItemPanel"))
        self:setLabelText("Label1", CHS[2100183], self:getControl("TypeCheckBox", nil, "PetItemPanel"))
    elseif 2 == self.checkState then
        self:setLabelText("Label1", CHS[2100184], self:getControl("TypeCheckBox", nil, "CustomItemPanel"))
        self:setLabelText("Label1", CHS[2100184], self:getControl("TypeCheckBox", nil, "FashionItemPanel"))
        self:setLabelText("Label1", CHS[2100184], self:getControl("TypeCheckBox", nil, "EffectItemPanel"))
        self:setLabelText("Label1", CHS[2100184], self:getControl("TypeCheckBox", nil, "PetItemPanel"))
    end
end

-- 刷新面板提示
function CustomDressDlg:refreshPanelTips()
    local gender = self.isFemale and 2 or 1
    local genderMatch = gender == Me:queryBasicInt("gender")
    self:setLabelText("TipsLabel", genderMatch and CHS[2100185] or CHS[2100186], self:getControl("TitlePanel", nil, "FashionPanel"))
    self:setLabelText("TipsLabel", genderMatch and CHS[2100187] or CHS[2100186], self:getControl("TitlePanel", nil, "CustomPanel"))
    self:setCtrlVisible("ItemPanel", genderMatch, self:getControl("ItemPanel", nil, "FashionPanel"))
    self:setCtrlVisible("BackImage_2", genderMatch, "FashionPanel")
    self:setCtrlVisible("BackImage_3", genderMatch, "FashionPanel")
    self:setCtrlVisible("BackDecorationPanel", genderMatch and self:getControl("CustomPanel"):isVisible())
    self:setCtrlVisible("HairPanel", genderMatch, self:getControl("ItemPanel", nil, "CustomPanel"))
    self:setCtrlVisible("BodyPanel", genderMatch, self:getControl("ItemPanel", nil, "CustomPanel"))
    self:setCtrlVisible("TrousersPanel", genderMatch, self:getControl("ItemPanel", nil, "CustomPanel"))
    self:setCtrlVisible("WeaponPanel", genderMatch, self:getControl("ItemPanel", nil, "CustomPanel"))
end

-- 初始化时装面板
function CustomDressDlg:initFashionPanels()
    local panel = "FashionPanel"

    local fashionEquip = InventoryMgr:getFashionData()
    self:showEquipInfo('ItemPanel', panel, fashionEquip)

    local listPanel = self:getControl("ListPanel", nil, "FashionItemPanel")
    local choseMenuPanel = self:getControl("ChoseMenuPanel", nil, listPanel)
    self:setCtrlTouchEnabled("OwnImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("NoImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("AllImage", true, choseMenuPanel)
    self:bindListener("AllImage", function(dlg, sender, eventType)
        self:setTypeCheck("FashionItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "FashionItemPanel")
        self.checkState = nil
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("OwnImage", function(dlg, sender, eventType)
        self:setTypeCheck("FashionItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "FashionItemPanel")
        self.checkState = 1
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("NoImage", function(dlg, sender, eventType)
        self:setTypeCheck("FashionItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "FashionItemPanel")
        self.checkState = 2
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)

    self:updateLayout(panel)
end

-- 初始化自定义面板
function CustomDressDlg:initCustomPanels()
    local panel = "CustomPanel"

    local customEquip = InventoryMgr:getCustomData()
    self:showEquipInfo('BackDecorationPanel', nil, customEquip, 1)
    self:showEquipInfo('HairPanel', panel, customEquip, 2)
    self:showEquipInfo('BodyPanel', panel, customEquip, 3)
    self:showEquipInfo('TrousersPanel', panel, customEquip, 4)
    self:showEquipInfo('WeaponPanel', panel, customEquip, 5)

    local group = RadioGroup.new()
    group:setItems(self, {"BackDecorationCheckBox", "HairCheckBox", "BodyCheckBox", "TrousersCheckBox", "WeaponCheckBox"}, function(dlg, sender, index)
        self.checkPart = index
        self:refreshListView()
    end, self:getControl("ChosePanel", nil, panel))
    self.partGroup = group

    local listPanel = self:getControl("ListPanel", nil, "CustomItemPanel")
    local choseMenuPanel = self:getControl("ChoseMenuPanel", nil, listPanel)
    self:setCtrlTouchEnabled("OwnImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("NoImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("AllImage", true, choseMenuPanel)
    self:bindListener("AllImage", function(dlg, sender, eventType)
        self:setTypeCheck("CustomItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "CustomItemPanel")
        self.checkState = nil
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("OwnImage", function(dlg, sender, eventType)
        self:setTypeCheck("CustomItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "CustomItemPanel")
        self.checkState = 1
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("NoImage", function(dlg, sender, eventType)
        self:setTypeCheck("CustomItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "CustomItemPanel")
        self.checkState = 2
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
end

-- 初始化特效面板
function CustomDressDlg:initEffectPanels()
    local panel = "EffectPanel"

    local fashionEquip = InventoryMgr:getFashionData()
    self:showEquipInfo('ItemPanel', panel, fashionEquip, 2)

    local listPanel = self:getControl("ListPanel", nil, "EffectItemPanel")
    local choseMenuPanel = self:getControl("ChoseMenuPanel", nil, listPanel)
    self:setCtrlTouchEnabled("OwnImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("NoImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("AllImage", true, choseMenuPanel)
    self:bindListener("AllImage", function(dlg, sender, eventType)
        self:setTypeCheck("EffectItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "EffectItemPanel")
        self.checkState = nil
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("OwnImage", function(dlg, sender, eventType)
        self:setTypeCheck("EffectItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "EffectItemPanel")
        self.checkState = 1
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("NoImage", function(dlg, sender, eventType)
        self:setTypeCheck("EffectItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "EffectItemPanel")
        self.checkState = 2
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)

    self:updateLayout(panel)
end

function CustomDressDlg:initPetPanels ()
    local panel = "PetPanel"

    local petItemEquip = InventoryMgr:getFollowPetData()
    self:showEquipInfo('ItemPanel', panel, petItemEquip , 1)

    local listPanel = self:getControl("ListPanel", nil, "PetItemPanel")
    local choseMenuPanel = self:getControl("ChoseMenuPanel", nil, listPanel)
    self:setCtrlTouchEnabled("OwnImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("NoImage", true, choseMenuPanel)
    self:setCtrlTouchEnabled("AllImage", true, choseMenuPanel)
    self:bindListener("AllImage", function(dlg, sender, eventType)
        self:setTypeCheck("PetItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "PetItemPanel")
        self.checkState = nil
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("OwnImage", function(dlg, sender, eventType)
        self:setTypeCheck("PetItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "PetItemPanel")
        self.checkState = 1
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)
    self:bindListener("NoImage", function(dlg, sender, eventType)
        self:setTypeCheck("PetItemPanel", false)
        self:setCtrlVisible("ChoseMenuPanel", false, "PetItemPanel")
        self.checkState = 2
        self:refreshListPanelText()
        self:refreshListView()
    end, choseMenuPanel)

    self:updateLayout(panel)
end

-- 创建切换按钮
function CustomDressDlg:createSwichButton(statePanel, isOn, func, key)
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

-- 切换性别按钮状态
function CustomDressDlg:switchButton(statePanel, isOn)
    self.isFemale = isOn
    if statePanel.isOn == isOn then return end

    statePanel.isOn = isOn
    local bkImage1 = self:getControl("ManImage", nil, statePanel)
    local bkImage2 = self:getControl("WomanImage", nil, statePanel)
    local image = self:getControl("ChoseButton", nil, statePanel)
    local psize = statePanel:getContentSize()
    local iSize = image:getContentSize()
    local px1 = iSize.width / 2
    local px2 = psize.width - px1

    if isOn then
        bkImage1:setColor(cc.c3b(51, 51, 51))
        bkImage1:setOpacity(33)
        bkImage2:setColor(cc.c3b(255, 255, 255))
        bkImage2:setOpacity(255)
        image:setPositionX(px2)
    else
        bkImage1:setColor(cc.c3b(255, 255, 255))
        bkImage1:setOpacity(255)
        bkImage2:setColor(cc.c3b(51, 51, 51))
        bkImage2:setOpacity(33)
        image:setPositionX(px1)
    end
end

-- 显示装备相关信息
function CustomDressDlg:showEquipInfo(panelName, root, data, index, callback)
    index = index or 1
    local panel = self:getControl(panelName, Const.UIPanel, root)
    local size = panel:getContentSize()
    panel:removeAllChildren()

    local colunm = 1
    local rowNum = 1
    local rowSpace = EQUIP_ROW_SPACE
    local colunmSpace = size.width - colunm * GRID_H

    local grids = panel:getChildByName("Grid")

    if not grids then
        grids = GridPanel.new(
            size.width, size.height,
            rowNum, colunm,
            GRID_W, GRID_H,
            rowSpace, colunmSpace)
        grids:setName("Grid")
    end

    grids:setData(data, index, function(idx, sender)
        if 'function' == type(callback) then
            callback(idx, sender)
        end

        -- 弹出道具悬浮框
        local item = InventoryMgr:getItemByPos(sender.data.pos)
        if not item then return end
        local rect = self:getBoundingBoxInWorldSpace(sender)
            local dlg = DlgMgr:openDlg("FashionDressInfoDlg")
            dlg:setEquipInfoFormCustom(item)
            dlg:setFloatingFramePos(rect)
    end)
    grids:setSelectAbled(false)

    panel:addChild(grids)
end

-- 设置使用按钮文本及状态
function CustomDressDlg:setUseButton(name, abled)
    self:setLabelText("Label_1", name, "UseButton")
    self:setLabelText("Label_2", name, "UseButton")
    self:setCtrlEnabled("UseButton", abled)
end

-- 刷新道具信息，主要指右侧选中按钮后的效果
function CustomDressDlg:refreshItemInfo(data)
    if not data then
        if 'PetPanel' == self.curShowPanel then
            self:setUseButton(CHS[2500074], false)
        else
        self:setUseButton(CHS[2100188], false)
        end
        self:setLabelText("NameLabel", CHS[2100191], self:getControl("TimePanel", nil, "DownPanel_2"))
        self:setLabelText("TimeLabel", "", self:getControl("TimePanel", nil, "DownPanel_2"))
        self:setCtrlVisible("PricePanel", false, "DownPanel_2")
        self:setCtrlVisible("TimePanel", true, "DownPanel_2")
    else
        local text
        local itemName = string.isNilOrEmpty(data.alias) and data.name or data.alias
        if string.match(data.name, CHS[2100209]) then
            itemName = CHS[2100209]
        end

        if data.amount and data.amount > 0 then
            text = InventoryMgr:hasDress(data) and CHS[2100189] or ('PetPanel' == self.curShowPanel and CHS[2500074] or CHS[2100190])
            self:setLabelText("TimeLabel", InventoryMgr:isTimeLimitedItem(data) and string.format(CHS[2100192], gf:getServerDate('%Y-%m-%d %H:%M', data.deadline)) or CHS[2100183], self:getControl("TimePanel", nil, "DownPanel_2"))
            self:setCtrlVisible("PricePanel", false, "DownPanel_2")
            self:setCtrlVisible("TimePanel", true, "DownPanel_2")
        else
            text = CHS[2100193]
            local itemInfo = InventoryMgr:getItemInfoByName(data.name)
            if ITEM_CLASS.FASHION == itemInfo.item_class or itemInfo.item_class == ITEM_CLASS.WEDDING_CLOTHES then
                -- 时装
                local canBuy = data.coin and data.coin > 0 or false
                self:setCtrlVisible("PricePanel", canBuy, "DownPanel_2")
                self:setCtrlVisible("TimePanel", not canBuy, "DownPanel_2")
                self:setImagePlist("GoldCoinImage", DistMgr:curIsTestDist() and ResMgr.ui.small_reward_silver or ResMgr.ui.small_reward_glod, "DownPanel_2")
                if canBuy then
                    local cashText, fontColor = gf:getArtFontMoneyDesc(data.coin)
                    self:setNumImgForPanel(self:getControl("GoldCoinValuePanel", nil, "DownPanel_2"), fontColor, cashText, false, LOCATE_POSITION.MID, 23)
                    self:setLabelText("NameLabel", data.name, self:getControl("PricePanel", nil, "DownPanel_2"))
                else
                    local timePanel = self:getControl("TimePanel", nil, "DownPanel_2")
                    self:setLabelText("NameLabel", data.name, timePanel)
                    self:setLabelText("TimeLabel", itemInfo.custom_tips or CHS[2100194], timePanel)
                end
            elseif data.part then
                local canBuy = data.price and data.price > 0
                self:setCtrlVisible("PricePanel", canBuy, "DownPanel_2")
                self:setCtrlVisible("TimePanel", not canBuy, "DownPanel_2")
                self:setImagePlist("GoldCoinImage", DistMgr:curIsTestDist() and ResMgr.ui.small_reward_silver or ResMgr.ui.small_reward_glod, "DownPanel_2")
                if canBuy then
                    local cashText, fontColor = gf:getArtFontMoneyDesc(data.price)
                    self:setNumImgForPanel(self:getControl("GoldCoinValuePanel", nil, "DownPanel_2"), fontColor, cashText, false, LOCATE_POSITION.MID, 23)
                    self:setLabelText("NameLabel", data.name, self:getControl("PricePanel", nil, "DownPanel_2"))
                else
                    local timePanel = self:getControl("TimePanel", nil, "DownPanel_2")
                    self:setLabelText("NameLabel", data.name, timePanel)
                    self:setLabelText("TimeLabel", itemInfo.custom_tips or CHS[2100194], timePanel)
                end
            else
                -- 特效或跟随宠
                local canBuy = data.price and data.price > 0
                self:setCtrlVisible("PricePanel", canBuy, "DownPanel_2")
                self:setCtrlVisible("TimePanel", not canBuy, "DownPanel_2")

                self:setImagePlist("GoldCoinImage", DistMgr:curIsTestDist() and ResMgr.ui.small_reward_silver or ResMgr.ui.small_reward_glod, "DownPanel_2")
                if canBuy then
                    local cashText, fontColor = gf:getArtFontMoneyDesc(data.price)
                    self:setNumImgForPanel(self:getControl("GoldCoinValuePanel", nil, "DownPanel_2"), fontColor, cashText, false, LOCATE_POSITION.MID, 23)
                    self:setLabelText("NameLabel", data.name, self:getControl("PricePanel", nil, "DownPanel_2"))
                else
                    local timePanel = self:getControl("TimePanel", nil, "DownPanel_2")
                    self:setLabelText("NameLabel", data.name, timePanel)
                    self:setLabelText("TimeLabel", itemInfo.custom_tips or CHS[2100194], timePanel)
                end
            end
        end

        self:setUseButton(text, true)
        self:setLabelText("NameLabel", itemName, self:getControl("TimePanel", nil, "DownPanel_2"))
    end

    if self.curShowPanel ~= "EffectPanel" and self.curShowPanel ~= "PetPanel" and self.curShowPanel ~= "FashionPanel" then
        -- 非特效标签，该按钮只显示穿戴
        self:setUseButton(CHS[2100188], true)
    end
end

-- 刷新道具列表
function CustomDressDlg:refreshListView(data)
    if self.curShowPanel == "FashionPanel" then
        self:initListView("ShowListView", InventoryMgr:getDressData('fasion_store', self.isFemale and 2 or 1, nil, self.checkState), "FashionItemPanel", 6)
        if not self.selFashionItem then
            self:refreshItemInfo()
        end
    elseif self.curShowPanel == "CustomPanel" then
        self:initListView("ShowListView", InventoryMgr:getDressData('custom_store', self.isFemale and 2 or 1, self.checkPart, self.checkState), "CustomItemPanel", 6)
        if not self.parts or not self.parts[self.checkPart] then
            self:refreshItemInfo()
        end
    elseif self.curShowPanel == "EffectPanel" then
        self:initListView("ShowListView", data or InventoryMgr:getDressData('effect_store', nil, nil, self.checkState), "EffectItemPanel", 6)
        if not self.selMagicItem then
            self:refreshItemInfo()
        end
    elseif self.curShowPanel == "PetPanel" then
        self:initListView("ShowListView", data or InventoryMgr:getDressData('pet_store', nil, nil, self.checkState), "PetItemPanel", 6)
        if not self.selPetItem then
            self:refreshItemInfo()
        end
    end
end

-- 初始化列表数据
function CustomDressDlg:initListView(name, data, root, margin)
    local list = self:resetListView(name, margin, nil, root)
    local line = math.max(5, math.ceil(#data / 5))

    local panel
    for i = 1, line do
        panel = self.showPanel:clone()
        self:setPanelData(panel, data, (i - 1) * 5 + 1)
        list:pushBackCustomItem(panel)
    end
end

-- 设置道具列表单行道具数据
function CustomDressDlg:setPanelData(panel, data, start)
    local item
    for i = 1, 5 do
        item = self:getControl("ItemPanel_" .. tostring(i), nil, panel)
        self:setItemData(item, data[start + i - 1])
    end
end

function CustomDressDlg:checkName(name1, name2)
    if name1 == name2 then return true end
    local parent1 = InventoryMgr:getParentName(name1)
    local parent2 = InventoryMgr:getParentName(name2)

    if parent1 and parent2 and parent1 == parent2 then return true end
    if parent1 and name2 and parent1 == name2 then return true end
    if parent2 and name1 and name1 == parent2 then return true end

    return false
end

-- 设置道具列表道具数据
function CustomDressDlg:setItemData(item, data)
    self:setCtrlVisible("ItemImage", nil ~= data, item)
    self:setCtrlVisible("NoImage", nil ~= data and (not data.amount or data.amount <= 0), item)


    if data then
        -- 存在道具数据
        self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), item)
        gf:setItemImageSize(self:getControl("ItemImage", nil, item))
        item:setName(data.name)
        item.data = data

        -- if data.part and self.parts and self.parts[data.part] and self.parts[data.part].name == data.name then
        if 'CustomPanel' == self.curShowPanel and data.part and self.parts and self.parts[data.part] and self.parts[data.part] == data.name then
            -- 自定义道具，更新一下当前选中的部件
            self.choseImage:removeFromParent()
            item:addChild(self.choseImage)
            self.parts[data.part] = data.name
            self:refreshItemInfo(data)
        elseif ('FashionPanel' == self.curShowPanel and self:checkName(data.name, self.selFashionItem))
            or ('EffectPanel' == self.curShowPanel and self:checkName(data.name, self.selMagicItem))
            or ('PetPanel' == self.curShowPanel and self:checkName(data.name, self.selPetItem)) then
            self.choseImage:removeFromParent()
            item:addChild(self.choseImage)
            self:refreshItemInfo(data)
        end

        self:setImagePlist("BKImage", ResMgr.ui.bag_item_bg_img, item)
        self:setCtrlVisible("OwnImage", data.pos and data.pos >= EQUIP.FASION_START and data.pos <= EQUIP.FASIONG_END, item)
    else
        self:setImagePlist("BKImage", ResMgr.ui.bag_no_item_bg_img, item)
        self:setCtrlVisible("OwnImage", false, item)
    end

    -- 绑定事件
    self:bindTouchEndEventListener(item, self.onClickItemPanel)
end

-- 设置道具类型
function CustomDressDlg:setTypeCheck(root, checked)
    local downImage = self:getControl("DownImage", nil, self:getControl("TypeCheckBox", nil, root))
    if downImage then
        downImage:setFlippedY(not checked)
    end
end

-- 选择道具类型
function CustomDressDlg:bindTypeCheck(root, func)
    local downImage = self:getControl("DownImage", nil, self:getControl("TypeCheckBox", nil, root))
    self:setTypeCheck(root, false)
    self:bindListener("TypeCheckBox", function(dlg, sender, eventType)
        if downImage then
            self:setTypeCheck(root, downImage:isFlippedY())
        end

        if 'function' == type(func) then
            func(dlg, sender, not downImage:isFlippedY())
        end
    end, root)
end

function CustomDressDlg:getItemRawName(itemName)
    return InventoryMgr:getParentName(itemName) or itemName
end

-- 重置图标
-- 重置为身上穿戴的装备的形象
function CustomDressDlg:resetIcon()
    local gender = Me:queryBasicInt("gender")
    local showPanel = ('EffectPanel' == self.curShowPanel or 'PetPanel' == self.curShowPanel) and self.lastShowPanel or self.curShowPanel
    if 'FashionPanel' == showPanel then
        self.icon = nil
        local itemName = self.selFashionItem
        if not itemName and ((self.isFemale and 2 == gender) or (not self.isFemale and 1 == gender)) then
            -- 显示自己的形象
                local item = InventoryMgr:getItemByPos(EQUIP.FASION_DRESS)
                itemName = item and item.name
            end

            if itemName then
            self.icon = InventoryMgr:getFashionShapeIcon(itemName)
            end

        if not self.icon then
            -- 默认裸模形象
            local gender = self.isFemale and 2 or 1
            self.icon = gf:getIconByGenderAndPolar(gender, Me:queryBasicInt("polar"))
        end
        self.parts = nil
    elseif 'CustomPanel' == showPanel then
        self.icon = self.isFemale and 60001 or 61001
        local parts = {}
        local customItemInfo = require("cfg/CustomItem")
        if (self.isFemale and 2 == gender) or (not self.isFemale and 1 == gender) then
            --local invs = InventoryMgr:getCustomValue()
            local pos = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
            local itemInfo, nitem, custItem, itemName, inv
            for k, v in ipairs(pos) do
                if self.parts and self.parts[k] then
                    itemName = self.parts[k]
                else
                    inv = InventoryMgr:getItemByPos(v)
                    itemName = inv and inv.name
                end
                if itemName then
                    nitem = {}
                    itemInfo = InventoryMgr:getItemInfoByName(itemName)
                    custItem = customItemInfo[itemName]
                    nitem.part = itemInfo.part
                    nitem.gender = itemInfo.gender
                    nitem.partIndex = custItem.fasion_part
                    nitem.colorIndex = custItem.fasion_dye
                    parts[itemInfo.part] = nitem
                else
                    parts[k] = nil
                end
            end
        elseif self.parts then
            local itemName
            for k, v in pairs(self.parts) do
                itemName = v
                if itemName then
                    nitem = {}
                    itemInfo = InventoryMgr:getItemInfoByName(itemName)
                    custItem = customItemInfo[itemName]
                    nitem.part = itemInfo.part
                    nitem.gender = itemInfo.gender
                    nitem.partIndex = custItem.fasion_part
                    nitem.colorIndex = custItem.fasion_dye
                    parts[itemInfo.part] = nitem
                else
                    parts[k] = nil
                end
            end
        end
        self.partString = self:getPartString(parts)
        self.partColorString = self:getPartColorString(parts)
    end

    -- 重置特效
    self.magic = nil
    local itemName = self.selMagicItem
    if not itemName then
        local item = InventoryMgr:getItemByPos(EQUIP.FASION_BALDRIC)
        itemName = item and item.name
    end
    if itemName then
        itemName = self:getItemRawName(itemName)
        self.magic = FashionEffect[itemName] and FashionEffect[itemName].fasion_effect
    end

        self.followPet = nil
    itemName = self.selPetItem
    if not itemName then
        local item = InventoryMgr:getItemByPos(EQUIP.EQUIP_FOLLOW_PET )
        itemName = item and item.name
    end

    if itemName then
        itemName = self:getItemRawName(itemName)
        self.followPet = FollowPet[itemName] and FollowPet[itemName].effect_icon
    end
end

-- 刷新穿戴提示
function CustomDressDlg:refreshDressTip(panel, tip)
    self:setLabelText("TipsLabel", tip, self:getControl("TitlePanel", nil, panel))
end

-- 设置选择菜单面板可见性
function CustomDressDlg:showChoseMenuPanel(root, visible)
    self:setCtrlVisible("ChoseMenuPanel", visible, root)
end

-- 显示时装面板
function CustomDressDlg:showFashionDressPanel(visible)
    self:setCtrlVisible("FashionPanel", visible)
    self:setCtrlVisible("FashionItemPanel", visible)
    self:setCtrlVisible("FashionDressChoseImage", visible)
end

-- 显示自定义面板
function CustomDressDlg:showCustomDressPanel(visible)
    self:setCtrlVisible("CustomPanel", visible)
    self:setCtrlVisible("BackDecorationPanel", visible)
    self:setCtrlVisible("CustomItemPanel", visible)
    self:setCtrlVisible("CustomDressChosemage", visible)
end

-- 显示特效面板
function CustomDressDlg:showEffectDressPanel(visible)
    self:setCtrlVisible("EffectPanel", visible)
    self:setCtrlVisible("EffectItemPanel", visible)

    local dressLabel = InventoryMgr:getDressLabel()
    self:setCtrlVisible("SexPanel", not visible, "CommonPanel")
    self:setCtrlVisible("DownPanel", not visible and -1 ~= dressLabel, "CommonPanel")
end

-- 显示跟随宠物面板
function CustomDressDlg:showPetDressPanel(visible)
    self:setCtrlVisible("PetPanel", visible)
    self:setCtrlVisible("PetItemPanel", visible)

    local dressLabel = InventoryMgr:getDressLabel()
    self:setCtrlVisible("SexPanel", not visible, "CommonPanel")
    self:setCtrlVisible("DownPanel", not visible and - 1 ~= dressLabel, "CommonPanel")
end

-- 穿戴
function CustomDressDlg:doUseItem(data)
    if not data or not data.amount or data.amount <= 0 then
        -- 没有获得该道具，无法穿戴
        gf:ShowSmallTips(string.format(CHS[2100195], data.name))
        return
    end

    local itemInfo = InventoryMgr:getItemInfoByName(data.name)
    if not itemInfo or (itemInfo.gender and itemInfo.gender ~= Me:queryBasicInt("gender")) then
        -- 当前形象与性别不符
        if itemInfo.part then
            gf:ShowSmallTips(CHS[2200142])
        elseif itemInfo.item_class == ITEM_CLASS.FASHION then
            gf:ShowSmallTips(CHS[2200143])
        end
        return
    end

    self:beginBatchUpdate()
    gf:CmdToServer("CMD_FASION_CUSTOM_EQUIP", { equip_str = data.name })
end

-- 购买时装
function CustomDressDlg:buyFashion(data)
    if not data.coin or data.coin <= 0 then
        gf:ShowSmallTips(CHS[2100197])
        return
    end

    local totalMoney
    local coinType = CHS[3003176]
    if DistMgr:curIsTestDist() then
        -- 内测区可以使用银元宝
        totalMoney = Me:getTotalCoin()
        if Me:getSilverCoin() < 0 then totalMoney = Me:getGoldCoin() end
        coinType = CHS[3003177]
    else
        -- 公测区只能使用金元宝
        totalMoney = Me:getGoldCoin()
    end

    if totalMoney < data.coin then
        -- 元宝不足
        if DistMgr:curIsTestDist() then
            gf:askUserWhetherBuyCoin()
        else
            gf:askUserWhetherBuyCoin("gold_coin")
        end
    else
        gf:CmdToServer("CMD_FASION_CUSTOM_EQUIP_EX", { is_buy = 1, item_names = data.name })
            end
end

-- 购买自定义道具
function CustomDressDlg:buyCustom(data)
    if data.part and (not data.price or data.price <= 0) then
        -- 当前道具无法通过购买获得
        gf:ShowSmallTips(CHS[2100197])
        return
    end

    -- 计算价格
    local totalMoney
    local coinType = CHS[3003176]
    if DistMgr:curIsTestDist() then
        -- 内测区可以使用银元宝
        totalMoney = Me:getTotalCoin()
        if Me:getSilverCoin() < 0 then totalMoney = Me:getGoldCoin() end
        coinType = CHS[3003177]
    else
        -- 公测区可以使用金元宝
        totalMoney = Me:getGoldCoin()
    end

    if totalMoney < data.price then
        -- 元宝不够，购买元宝
        gf:askUserWhetherBuyCoin("gold_coin")
    else
        -- (其中#RNum2#n个以金元宝替代)
        local showMessage = CHS[3003178] .. CHS[2300025]
        local showExtra = CHS[3003179]

        if coinType ~= CHS[3003176] then
            if Me:getSilverCoin() >= data.price then
                showExtra = ""
            else
                -- 银元宝如果未负，则计算消耗的金元时，银元宝用0计算
                local realUseSilver = Me:queryInt("silver_coin")
                if realUseSilver < 0 then realUseSilver = 0 end
                showExtra = string.format(showExtra, (data.price - realUseSilver))
                coinType = CHS[3003177]
            end
        else
            showExtra = ""
            coinType = CHS[3003176]
        end

        showMessage = string.format(showMessage,
            data.price,
            coinType,
            showExtra,
            1,
            InventoryMgr:getUnit(data.name),
            data.name)

        -- 购买道具
        gf:confirm(showMessage, function()
            gf:CmdToServer('CMD_FASION_CUSTOM_BUY', { name = data.name })
        end)
    end
end

-- 购买特效道具
function CustomDressDlg:buyEffect(data)
    if not data.price or data.price <= 0 then
        -- 当前道具无法通过购买获得
        gf:ShowSmallTips(CHS[2100197])
        return
    end

    --[[
    -- 计算价格
    local totalMoney
    local coinType = CHS[3003176]
    if DistMgr:curIsTestDist() then
        -- 内测区可以使用银元宝
        totalMoney = Me:getTotalCoin()
        if Me:getSilverCoin() < 0 then totalMoney = Me:getGoldCoin() end
        coinType = CHS[3003177]
    else
        -- 公测区可以使用金元宝
        totalMoney = Me:getGoldCoin()
    end

    if totalMoney < data.price then
        -- 元宝不够，购买元宝
        gf:askUserWhetherBuyCoin("gold_coin")
    else
        -- (其中#RNum2#n个以金元宝替代)
        local showMessage = CHS[3003178] .. CHS[2300025]
        local showExtra = CHS[3003179]

        if coinType ~= CHS[3003176] then
            if Me:getSilverCoin() >= data.price then
                showExtra = ""
            else
                -- 银元宝如果未负，则计算消耗的金元时，银元宝用0计算
                local realUseSilver = Me:queryInt("silver_coin")
                if realUseSilver < 0 then realUseSilver = 0 end
                showExtra = string.format(showExtra, (data.price - realUseSilver))
                coinType = CHS[3003177]
            end
        else
            showExtra = ""
            coinType = CHS[3003176]
        end

        showMessage = string.format(showMessage,
            data.price,
            coinType,
            showExtra,
            1,
            InventoryMgr:getUnit(data.name),
            data.name)

        -- 购买道具
        gf:confirm(showMessage, function()
            self:beginBatchUpdate()
            gf:CmdToServer('CMD_FASION_CUSTOM_BUY_EFFECT', { item_name = data.name })
        end)
    end
    ]]

    self:beginBatchUpdate()
    gf:CmdToServer('CMD_FASION_CUSTOM_BUY_EFFECT', { item_name = data.name })
end

-- 购买
function CustomDressDlg:doBuyItem(data)
    -- 跨服区组中不可购买时装
    if not DistMgr:checkCrossDist() then return end

    local itemInfo = InventoryMgr:getItemInfoByName(data.name)
    if not itemInfo or (itemInfo.gender and itemInfo.gender ~= Me:queryBasicInt("gender")) then
        gf:ShowSmallTips(CHS[2100211])
        return
    end

    if ITEM_CLASS.FASHION == itemInfo.item_class then
        self:buyFashion(data)
    elseif data.part then
        self:buyCustom(data)
    elseif 'PetPanel' == self.curShowPanel then
        self:buyFollowPet(data)
    else
        --gf:ShowSmallTips(CHS[2100197])
        self:buyEffect(data)
    end
end

-- 购买特效道具
function CustomDressDlg:buyFollowPet(data)
    if not data.price or data.price <= 0 then
        -- 当前道具无法通过购买获得
        gf:ShowSmallTips(CHS[2000504])
        return
    end

    self:beginBatchUpdate()
    gf:CmdToServer('CMD_BUY_FASHION_PET', { name = data.name })
end

-- 穿戴按钮
function CustomDressDlg:onUseButton()
    local gender = self.isFemale and 2 or 1
    if 'EffectPanel' ~= self.curShowPanel and 'PetPanel'~= self.curShowPanel and 'FashionPanel' ~= self.curShowPanel then
        -- 检查外观预览
        self:checkPreviewCustom()
    else
        local item = self.choseImage:getParent()
        if not item then return end
        local data = item.data
        if data and data.amount and data.amount > 0 then
            if data.pos and data.pos <= EQUIP.FASIONG_END then
                self:beginBatchUpdate()
                gf:CmdToServer("CMD_FASION_CUSTOM_UNEQUIP", { pos = data.pos })
                if 'FashionPanel' == self.curShowPanel then
                    self.selFashionItem = nil
                elseif 'CustomPanel' == self.curShowPanel and self.parts and self.checkPart then
                    self.parts[self.checkPart] = nil
                elseif 'EffectPanel' == self.curShowPanel then
                    self.selMagicItem = nil
                elseif 'PetPanel' == self.curShowPanel then
                    self.selPetItem = nil
                end
            else
                self:doUseItem(data)
            end
        else
            self:doBuyItem(data)
        end
    end
end

-- 根据道具名称取消选中
function CustomDressDlg:cancleChooseItem(itemName)
    if self.selFashionItem == itemName then

        self.selFashionItem = nil
    end

    if self.selMagicItem == itemName then
        self.selMagicItem = nil
    end

    if self.selPetItem == itemName then
        self.selPetItem = nil
    end

    if self.parts then
        for key, name in pairs(self.parts) do
            if name == itemName then
                self.parts[key] = nil
            end
        end
    end
end


-- 预览外观
function CustomDressDlg:checkPreviewCustom()
    local gender = self.isFemale and 2 or 1
    if 'CustomPanel' == self.curShowPanel then
        -- 部件
        local parts = gf:deepCopy(self.parts) or {}
        local hasNotDress = false
        local p = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
        local selCou = 0
        local hasCou = 0
        local totalCou = #p
        for i = 2, totalCou do
            --  主部件从第二位开始判断
            local item = InventoryMgr:getItemByPos(p[i])

            if parts[i] then
                selCou = selCou + 1
                if not item or parts[i] ~= item.name then
                    hasNotDress = true
                end

                if self:hasItem(parts[i]) or (item and parts[i] == item.name) then
                    hasCou = hasCou + 1
                end
            elseif item and gender == Me:queryBasicInt("gender") then
                parts[i] = item.name
                selCou = selCou + 1
                hasCou = hasCou + 1
            end
        end

        local backDecorate = InventoryMgr:getItemByPos(p[1])
        local hasBackDecorate = false
        if parts[1] then
            -- 背饰是否穿戴特殊处理，因为背饰不参与主部件的计算
            if not backDecorate or backDecorate.name ~= parts[1] then
                hasNotDress = true
            end

            if self:hasItem(parts[1]) or (backDecorate and parts[1] == backDecorate.name) then
                hasBackDecorate = true
            end
        elseif backDecorate and gender == Me:queryBasicInt("gender") then
            parts[1] = backDecorate.name
            hasBackDecorate = true
        end

        if not hasNotDress then
            gf:ShowSmallTips(CHS[5430018])
            return
        end

        if selCou < totalCou - 1 then
            gf:ShowSmallTips(CHS[5430021])
            return
        end

        if hasCou == totalCou - 1 and (string.isNilOrEmpty(parts[1]) or hasBackDecorate) then
            -- 没有穿背饰，或者背饰已拥有
            self:doUseAllItems(parts)
        else
            DlgMgr:openDlgEx("CustomDressShowDlg", { data = parts, icon = self.icon, gender = gender, type = "part"})
        end
    end
end

-- 已拥有
function CustomDressDlg:hasItem(itemName)
    return StoreMgr:getFashionItemByName(itemName) or StoreMgr:getCustomItemByName(itemName)
end

function CustomDressDlg:doUseAllItems(items)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003663])
        return
    end

    local gender = self.isFemale and 2 or 1
    local genderMatch = gender == Me:queryBasicInt("gender")
    if not genderMatch then
        -- 当前形象与性别不符
        if 'CustomPanel' == self.curShowPanel then
            gf:ShowSmallTips(CHS[2200142])
        elseif 'FashionPanel' == self.curShowPanel  then
            gf:ShowSmallTips(CHS[2200143])
        end
        return
    end

    if string.isNilOrEmpty(items[1]) then
        items[1] = ""
    end

    self:beginBatchUpdate()
    gf:CmdToServer('CMD_FASION_CUSTOM_EQUIP_EX', { is_buy = 0, item_names = table.concat(items, "|")  })
end

-- 收藏柜按钮
function CustomDressDlg:onSaveButton()
    gf:CmdToServer("CMD_FASION_FAVORITE_VIEW")
end

-- 时装按钮
function CustomDressDlg:onFashionDressButton(sender, eventType)
    local dressLabel = InventoryMgr:getDressLabel()

    local function apply()
        self.curShowPanel = "FashionPanel"
        self:showFashionDressPanel(true)
        self:showCustomDressPanel(false)
        if self.lastShowPanel ~= "FashionPanel" then
            self.checkState = nil
            self.checkPart = nil
            self.parts = nil
            self.partString = nil
            self.partColorString = nil
            self.selFashionItem = nil
            self.selMagicItem = nil
            self.selPetItem = nil
            self:resetIcon()
            self:refreshListPanelText()
            self:refreshCommonPanel()
            self:refreshListView()
            self:beginBatchUpdate()
            gf:CmdToServer("CMD_FASION_CUSTOM_SWITCH", {fasion_label = 0})
        end
    end

    if Me:isInCombat() and sender then
        gf:ShowSmallTips(CHS[3003646])
        return
    end

    apply()
end

-- 自定义按钮
function CustomDressDlg:onCustomDressButton(sender, eventType)
    if -1 == dressLabel then return end
    local function apply()
        self.curShowPanel = "CustomPanel"
        self:showFashionDressPanel(false)
        self:showCustomDressPanel(true)
        if self.lastShowPanel ~= "CustomPanel" then
            self.checkState = nil
            self.parts = nil
            self.partString = nil
            self.partColorString = nil
            self.selFashionItem = nil
            self.selMagicItem = nil
            self.selPetItem = nil
            self.checkPart = 2
            self:resetIcon()
            self.partGroup:selectRadio(self.checkPart, true)
            self:refreshListPanelText()
            self:refreshCommonPanel()
            self:refreshListView()
            self:beginBatchUpdate()
            gf:CmdToServer("CMD_FASION_CUSTOM_SWITCH", {fasion_label = 1})
        end
    end

    if Me:isInCombat() and sender then
        gf:ShowSmallTips(CHS[3003646])
        return
    end

    apply()
end

-- 形象右转
function CustomDressDlg:onTurnRightButton()
    self.dir = self.dir - 2
    if self.dir < 0 then
        self.dir = 7
    end

    self:refreshCommonPanel()
end

-- 形象左转
function CustomDressDlg:onTurnLeftButton()
    self.dir = self.dir + 2
    if self.dir > 7 then
        self.dir = 1
    end

    self:refreshCommonPanel()
end

-- 选中道具
function CustomDressDlg:onClickItemPanel(sender)
    if self.choseImage:getParent() == sender then
        -- 取消选择
        self.choseImage:removeFromParent()
        local data = sender.data
        if 'CustomPanel' == self.curShowPanel then
            if self.parts then
                self.parts[self.checkPart] = nil
                self:resetIcon()
            end
        elseif 'FashionPanel' == self.curShowPanel then
            self.selFashionItem = nil
            self:resetIcon()
            self.parts = nil
        elseif 'EffectPanel' == self.curShowPanel then
            self.selMagicItem = nil
            self.magic = nil
            self:resetIcon()
        elseif 'PetPanel' == self.curShowPanel then
            self.selPetItem = nil
            self.followPet = nil
            self:resetIcon(true)
        end

        self:refreshCommonPanel()
        self:refreshItemInfo()
    else
        -- 选中新道具(可能是空格)
        self.choseImage:removeFromParent()
        sender:addChild(self.choseImage)

        local itemName = sender:getName()
        local data = sender.data
        if data then
            -- 有数据
            if 'CustomPanel' == self.curShowPanel then
                -- 部件
                -- self:resetIcon()
                if not self.parts then
                    self.parts = {}
                end
                self.parts[data.part] = itemName
                self:resetIcon()
            elseif 'FashionPanel' == self.curShowPanel then
                -- 时装
                self.icon = InventoryMgr:getFashionShapeIcon(itemName)
                self.selFashionItem = itemName
            elseif 'EffectPanel' == self.curShowPanel then
                local cfg = FashionEffect[itemName] or FashionEffect[InventoryMgr:getParentName(itemName)]
                self.magic = cfg and cfg.fasion_effect
                self.selMagicItem = itemName

                if COUPLR_EFFECT[itemName] then
                    gf:ShowSmallTips(string.format(CHS[5430019], itemName))
                end
            elseif 'PetPanel' == self.curShowPanel then
                local cfg = FollowPet[itemName] or FollowPet [InventoryMgr:getParentName(itemName)]
                self.followPet = cfg and cfg.effect_icon
                self.selPetItem = itemName
            end
        elseif 'CustomPanel' == self.curShowPanel and self.checkPart then
            -- 无数据，且是自定义道具
            if self.parts then
                self.parts[self.checkPart] = nil
            end
            self:resetIcon()
        elseif "FashionPanel" == self.curShowPanel then
            self.selFashionItem = nil
            self:resetIcon()
        elseif 'EffectPanel' == self.curShowPanel then
            -- 光效
            self.magic = nil
            self.selMagicItem = nil
            self:resetIcon()
        elseif 'PetPanel' == self.curShowPanel then
            -- 跟随宠物
            self.followPet = nil
            self.selPetItem = nil
            self:resetIcon()
        end

        self:refreshCommonPanel()
        self:refreshItemInfo(data)
    end
end

function CustomDressDlg:onFashionTypeCheck(sender, checked)
    self:setCtrlVisible("ChoseMenuPanel", checked, "FashionItemPanel")
end

function CustomDressDlg:onCustomTypeCheck(sender, checked)
    self:setCtrlVisible("ChoseMenuPanel", checked, "CustomItemPanel")
end

function CustomDressDlg:onEffectTypeCheck(sender, checked)
    self:setCtrlVisible("ChoseMenuPanel", checked, "EffectItemPanel")
end

function CustomDressDlg:onPetTypeCheck(sender, checked)
	self:setCtrlVisible("ChoseMenuPanel", checked, "PetItemPanel")
end

-- 效果开启
function CustomDressDlg:onEffectOpenButton(sender)
    if sender then
        local item = InventoryMgr:getItemByPos(EQUIP.FASION_BALDRIC)
        if not item then
            gf:ShowSmallTips(CHS[2200129])
            return
        end
    end

    if not self.hideEffect then
        self.hideEffect = true
        if sender then
            -- 按钮点击

            gf:CmdToServer("CMD_FASION_EFFECT_DISABLE", { disable = self.hideEffect and 1 or 0 })
        end
    end

    self:refreshCommonButton()
end

-- 效果关闭
function CustomDressDlg:onEffectCloseButton(sender)
    if sender then
        local item = InventoryMgr:getItemByPos(EQUIP.FASION_BALDRIC)
        if not item then
            gf:ShowSmallTips(CHS[2200129])
            return
        end
    end

    if self.hideEffect then
        self.hideEffect = nil
        if sender then
            -- 按钮点击
            gf:CmdToServer("CMD_FASION_EFFECT_DISABLE", { disable = self.hideEffect and 1 or 0 })
        end

    end

    self:refreshCommonButton()
end

-- 展示开启
function CustomDressDlg:onShowOpenButton(sender)
    if sender and self.showTips then
        gf:ShowSmallTips(self.showTips)
        return
    end

    self:refreshCommonButton()

    if sender then
        gf:CmdToServer("CMD_FASION_CUSTOM_DISABLE", { value = Me:isShowDress() and 1 or 0 })
    end
end

-- 展示关闭
function CustomDressDlg:onShowCloseButton(sender)
    if sender and self.showTips then
        gf:ShowSmallTips(self.showTips)
        return
    end

    self:refreshCommonButton()

    if sender then
        gf:CmdToServer("CMD_FASION_CUSTOM_DISABLE", { value = Me:isShowDress() and 1 or 0 })
    end
end

function CustomDressDlg:onResetButton()
    self.selFashionItem = nil
    self.selMagicItem = nil
    self.parts = nil
    self.selPetItem = nil
    self:resetIcon()
    self.choseImage:removeFromParent()
    self:refreshCommonPanel()
    self:refreshItemInfo()
end

function CustomDressDlg:onUpdate()
    if self.batchUpdate and self.batchUpdate > 0 then return end -- 等待批量操作完成

    if self.dirtyListView then
        self.dirtyListView = nil
        self:refreshListView()
    end

    if self.dirtyIcon then
        self.dirtyIcon = nil
        self:resetIcon()
    end

    if self.dirtyCommonPanel then
        self.dirtyCommonPanel = nil
        self:refreshCommonPanel()
    end

    if self.dirtyEffectButton then
        self.dirtyEffectButton = nil
        self:refreshEffectButton()
    end
end

function CustomDressDlg:clearParts()
    self.parts = nil
end

function CustomDressDlg:beginBatchUpdate()
    self.batchUpdate = (self.batchUpdate or 0) + 1
end

function CustomDressDlg:endBatchUpdate()
    if self.batchUpdate and self.batchUpdate > 0 then
        self.batchUpdate = self.batchUpdate - 1
    end
end

function CustomDressDlg:MSG_STORE(data)
            self.dirtyListView = true
            self.dirtyIcon = true
            self.dirtyCommonPanel = true
            self.dirtyEffectButton = true
end

function CustomDressDlg:MSG_INVENTORY(data)
    if 'EffectPanel' == self.curShowPanel or 'CustomPanel' == self.curShowPanel then
        self:resetIcon()
        self.dirtyIcon = true
    end

            self.dirtyListView = true
    self.dirtyIcon = true
            self.dirtyCommonPanel = true
            self.dirtyEffectButton = true

    if data[1] and data[1].pos and data[1].pos <= EQUIP.FASIONG_END and data[1].pos >= EQUIP.FASION_START then
        local customEquip = InventoryMgr:getCustomData()
        self:showEquipInfo('BackDecorationPanel', nil, customEquip, 1)
        self:showEquipInfo('HairPanel', 'CustomPanel', customEquip, 2)
        self:showEquipInfo('BodyPanel', 'CustomPanel', customEquip, 3)
        self:showEquipInfo('TrousersPanel', 'CustomPanel', customEquip, 4)
        self:showEquipInfo('WeaponPanel', 'CustomPanel', customEquip, 5)

        local fashionEquip = InventoryMgr:getFashionData()
        self:showEquipInfo('ItemPanel', 'FashionPanel', fashionEquip)

        local fashionEquip = InventoryMgr:getFashionData()
        self:showEquipInfo('ItemPanel', 'EffectPanel', fashionEquip, 2)

        local petItemEquip = InventoryMgr:getFollowPetData()
        self:showEquipInfo('ItemPanel', 'PetPanel', petItemEquip, 1)
    end
end

function CustomDressDlg:MSG_FASION_FAVORITE_LIST(data)
    if not DlgMgr:getDlgByName("CustomDressCollectDlg") then
        DlgMgr:openDlg("CustomDressCollectDlg")
    end
end

function CustomDressDlg:MSG_FASION_CUSTOM_LIST(data)
    self.dirtyListView = true
    self.dirtyIcon = true
    self.dirtyCommonPanel = true
end

function CustomDressDlg:MSG_FASION_EFFECT_LIST(data)
    self:MSG_FASION_CUSTOM_LIST(data)
end

function CustomDressDlg:MSG_FOLLOW_PET_VIEW(data)
    self:MSG_FASION_CUSTOM_LIST(data)
end

-- 使用收藏成功
function CustomDressDlg:MSG_FASION_FAVORITE_APPLY(data)
    self.lastShowPanel = nil
    if data.label == 1 then
        self:onCustomDressButton()
    else
        self:onFashionDressButton()
    end

    self:showEffectDressPanel(false)
    self.typeRaido:selectRadio(1, true)
    self.lastShowPanel = nil
end

function CustomDressDlg:MSG_UPDATE(data)
    self:refreshEffectButton()
    self:refreshShowButton()
end

function CustomDressDlg:MSG_UPDATE_APPEARANCE(data)
    self:resetIcon()
    self.dirtyCommonPanel = true
end

function CustomDressDlg:MSG_FASION_CUSTOM_END(data)
    self:endBatchUpdate()
end

function CustomDressDlg:MSG_FASION_CUSTOM_BEGIN(data)
    self:beginBatchUpdate()
end

return CustomDressDlg
