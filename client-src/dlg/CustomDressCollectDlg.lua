-- CustomDressCollectDlg.lua
-- Created by sujl, Jan/2/2018
-- 收藏柜

local CustomDressCollectDlg = Singleton("CustomDressCollectDlg", Dialog)

local CustomItem = require("cfg/CustomItem")
local FashionEffect = DressMgr:getFashionEffect()

local WORD_LIMIT = 6

function CustomDressCollectDlg:init()
    self:bindListener("PlanPanel_1", self.onClickPlan, "PlanListView")
    self:bindListener("DeleteButton", self.onDeleteButton, "PlanShapePanel")
    self:bindListener("UseButton", self.onUseButton, "PlanShapePanel")
    self:bindListener("SaveButton", self.onSaveButton, "PlanShapePanel")
    self:bindListener("TurnLeftButton", self.onTurnLeftButton, "PlanShapePanel")
    self:bindListener("TurnRightButton", self.onTurnRightButton, "PlanShapePanel")
    self:bindListener("ChangeNameButton", self.onChangeNameButton, "PlanShapePanel")
    self:bindListener("SaveNameButton", self.onSaveNameButton, "NamePanel")

    local panel = "NamePanel"
    self:setCtrlVisible("DelButton", false, panel)
    self:setCtrlVisible("NameLabel", true, panel)
    self:setCtrlTouchEnabled("ResivePanel", false, panel)
    self:setCtrlVisible("ResivePanel", false, panel)
    self.editBox = self:createEditBox("ResivePanel", panel, nil, function(sender, type)
        if "ended" == type then
            local content = self.editBox:getText()
            self:setCtrlVisible("SaveNameButton", (0 ~= self.curSel and content ~= DressMgr:getFav(self.curSel).fav_name), "NamePanel")
            self:setLabelText("NameLabel", content, panel)
            self:setCtrlVisible("NameLabel", true, panel)
        elseif "changed" == type then
            if not self.editBox then return end
            local content = self.editBox:getText()
            local len = gf:getTextLength(content)
            if len > WORD_LIMIT * 2 then
                content = gf:subString(content, WORD_LIMIT * 2)
                self.editBox:setText(content)
                -- gf:ShowSmallTips(string.format(CHS[5400591], WORD_LIMIT))
                gf:ShowSmallTips(CHS[2100168])
            end

            if len == 0 then
                self:setCtrlVisible("DelButton", false, "InputPanel")
            else
                self:setCtrlVisible("DelButton", true,  "InputPanel")
            end
        elseif "began" == type then
           if gf:isIos() then
                self:setCtrlVisible("NameLabel", false, panel)
           end
        end
    end)

    self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox:setFont(CHS[3003794], 21)
    self.editBox:setFontColor(COLOR3.TEXT_DEFAULT)
    self.editBox:setMaxLength(150)
    self:setLabelText("NameLabel", CHS[2100169], panel)

    self.chosenEffect = self:retainCtrl("BChosenEffectImage", nil, self:getControl("PlanPlane_1", nil, "PlanListView"))
    self.planItem = self:retainCtrl("PlanPanel_1", nil, "PlanListView")

    self.dir = 5
    self:refreshListView()

    self:hookMsg("MSG_FASION_FAVORITE_LIST")
end

function CustomDressCollectDlg:cleanup()
    self.icon = nil
    self.dir = nil
    self.curSel = nil
end

function CustomDressCollectDlg:getCustomPart(name)
    --local itemInfo = InventoryMgr:getItemInfoByName(name)
    return CustomItem[name] and CustomItem[name].fasion_part or 0
end

-- 通过道具名获取时装
function CustomDressCollectDlg:getFashionItemByName(itemName, pos)
    if string.isNilOrEmpty(itemName) then return end

    local item
    item = StoreMgr:getFashionItemByName(itemName)
    if not item then
        item = InventoryMgr:getItemByPos(pos)
        if item and item.name ~= itemName then
            item = nil
        end
    end

    if not item then
        -- 可能超时被销毁了
        item = { name = itemName, deadline = -1 }
    end

    return item
end

-- 通过道具名获取自定义部件
function CustomDressCollectDlg:getCustomItemByName(itemName, pos)
    if string.isNilOrEmpty(itemName) then return end

    local item
    item = StoreMgr:getCustomItemByName(itemName)
    if not item then
        item = InventoryMgr:getItemByPos(pos)
        if item and item.name ~= itemName then
            item = nil
        end
    end

    if not item then
        -- 可能超时被销毁了
        item = { name = itemName, deadline = -1 }
    end

    return item
end

-- 通过道具名获取特效
function CustomDressCollectDlg:getEffectItemByName(itemName, pos)
    if string.isNilOrEmpty(itemName) then return end

    local item
    item = StoreMgr:getEffectItemByName(itemName)
    if not item then
        item = InventoryMgr:getItemByPos(pos)
        if item and item.name ~= itemName then
            item = nil
        end
    end

    if not item then
        -- 可能超时被销毁了
        item = { name = itemName, deadline = -1 }
    end

    return item
end

-- 刷新道具图标
function CustomDressCollectDlg:refreshItemIcon()
    local effectItem
    if 0 ~= self.curSel then
        local fav = DressMgr:getFav(self.curSel)
        if fav then
            local plan = fav.fav_plan
            local t = gf:split(plan, ":")
            self.gender = tonumber(t[1])
            local t1 = gf:split(t[3], "|")
            if t and t1 then
                if 2 == #t1 then
                    -- 时装
                    local fashionItem = self:getFashionItemByName(t1[1], EQUIP.FASION_DRESS)
                    local magicItem = self:getEffectItemByName(t1[2], EQUIP.FASION_BALDRIC)
                    effectItem = magicItem
                    self:setCtrlVisible("FashionPanel", true, "PlanShapePanel")
                    self:setCtrlVisible("CustomPanel", false, "PlanShapePanel")

                    local panel
                    panel = self:getControl("FashionPanel1", nil, "FashionPanel")
                    self:setImage("ItemImage", fashionItem and ResMgr:getItemIconPath(InventoryMgr:getIconByName(fashionItem.name)) or ResMgr.ui.equip_armor_img, panel)
                    self:setPanelPlist("FashionPanel1", fashionItem and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "FashionPanel")

                    self:setCtrlVisible("ExpireImage", fashionItem and InventoryMgr:isItemTimeout(fashionItem), panel)
                    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))

                elseif 5 == #t1 or 6 == #t1 then
                    -- 自定义
                    local backItem = self:getCustomItemByName(t1[6], EQUIP.FASION_BACK)
                    local hairItem = self:getCustomItemByName(t1[1], EQUIP.FASION_HAIR)
                    local bodyItem = self:getCustomItemByName(t1[2], EQUIP.FASION_UPPER)
                    local trousersItem = self:getCustomItemByName(t1[3], EQUIP.FASION_LOWER)
                    local weaponItem = self:getCustomItemByName(t1[4], EQUIP.FASION_ARMS)
                    local magicItem = self:getEffectItemByName(t1[5], EQUIP.FASION_BALDRIC)

                    self.icon = 2 == tonumber(t[1]) and 60001 or 610001

                    effectItem = magicItem

                    self:setCtrlVisible("FashionPanel", false, "PlanShapePanel")
                    self:setCtrlVisible("CustomPanel", true, "PlanShapePanel")

                    local panel
                    panel = self:getControl("BackDecorationPanel", nil, "CustomPanel")
                    self:setImage("ItemImage", backItem and ResMgr:getItemIconPath(InventoryMgr:getIconByName(backItem.name)) or ResMgr.ui.equip_back_img, panel)
                    self:setCtrlVisible("ExpireImage", backItem and InventoryMgr:isItemTimeout(backItem), panel)
                    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
                    self:setPanelPlist("BackDecorationPanel", backItem and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

                    panel = self:getControl("HairPanel", nil, "CustomPanel")
                    self:setImage("ItemImage", hairItem and ResMgr:getItemIconPath(InventoryMgr:getIconByName(hairItem.name)) or ResMgr.ui.equip_hair_img, panel)
                    self:setCtrlVisible("ExpireImage", hairItem and InventoryMgr:isItemTimeout(hairItem), panel)
                    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
                    self:setPanelPlist("HairPanel", hairItem and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

                    panel = self:getControl("BodyPanel", nil, "CustomPanel")
                    self:setImage("ItemImage", bodyItem and ResMgr:getItemIconPath(InventoryMgr:getIconByName(bodyItem.name)) or ResMgr.ui.equip_upper_img, panel)
                    self:setCtrlVisible("ExpireImage", bodyItem and InventoryMgr:isItemTimeout(bodyItem), panel)
                    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
                    self:setPanelPlist("BodyPanel", bodyItem and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

                    panel = self:getControl("TrousersPanel", nil, "CustomPanel")
                    self:setImage("ItemImage", trousersItem and ResMgr:getItemIconPath(InventoryMgr:getIconByName(trousersItem.name)) or ResMgr.ui.equip_lower_img, panel)
                    self:setCtrlVisible("ExpireImage", trousersItem and InventoryMgr:isItemTimeout(trousersItem), panel)
                    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
                    self:setPanelPlist("TrousersPanel", trousersItem and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

                    panel = self:getControl("WeaponPanel", nil, "CustomPanel")
                    self:setImage("ItemImage", weaponItem and ResMgr:getItemIconPath(InventoryMgr:getIconByName(weaponItem.name)) or ResMgr.ui.equip_arms_img, panel)
                    self:setCtrlVisible("ExpireImage", weaponItem and InventoryMgr:isItemTimeout(weaponItem), panel)
                    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
                    self:setPanelPlist("WeaponPanel", weaponItem and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")
                end
            end
        end
    else
        -- 从本地数据读取
        local magicItem = InventoryMgr:getItemByPos(EQUIP.FASION_BALDRIC)
        local fashionItem = InventoryMgr:getItemByPos(EQUIP.FASION_DRESS)
        self.gender = Me:queryBasic("gender")
        effectItem = magicItem
        local dressLabel = InventoryMgr:getDressLabel()
        if 0 == dressLabel or -1 == dressLabel then
            self:setCtrlVisible("FashionPanel", true, "PlanShapePanel")
            self:setCtrlVisible("CustomPanel", false, "PlanShapePanel")

            local panel
            panel = self:getControl("FashionPanel1", nil, "FashionPanel")
            self:setImage("ItemImage", fashionItem and ResMgr:getItemIconPath(InventoryMgr:getIconByName(fashionItem.name)) or ResMgr.ui.equip_armor_img, panel)
            self:setCtrlVisible("ExpireImage", fashionItem and InventoryMgr:isItemTimeout(fashionItem), panel)
            gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
            self:setPanelPlist("FashionPanel1", fashionItem and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, panel)
        else
            local t = {}
            local p = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
            local i
            for k, v in ipairs(p) do
                i = InventoryMgr:getItemByPos(v)
                t[k] = i
            end
            self:setCtrlVisible("FashionPanel", false, "PlanShapePanel")
            self:setCtrlVisible("CustomPanel", true, "PlanShapePanel")

            local panel, itemName
            panel = self:getControl("BackDecorationPanel", nil, "CustomPanel")
            itemName = t[1] and t[1].name
            self:setImage("ItemImage", string.isNilOrEmpty(itemName) and ResMgr.ui.equip_back_img or ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName)), panel)
            self:setCtrlVisible("ExpireImage", t[1] and InventoryMgr:isItemTimeout(t[1]), panel)
            gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
            self:setPanelPlist("BackDecorationPanel", not string.isNilOrEmpty(itemName) and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

            panel = self:getControl("HairPanel", nil, "CustomPanel")
            itemName = t[2] and t[2].name
            self:setImage("ItemImage", string.isNilOrEmpty(itemName) and ResMgr.ui.equip_hair_img or ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName)), panel)
            self:setCtrlVisible("ExpireImage", t[2] and InventoryMgr:isItemTimeout(t[2]), panel)
            gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
            self:setPanelPlist("HairPanel", not string.isNilOrEmpty(itemName) and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

            panel = self:getControl("BodyPanel", nil, "CustomPanel")
            itemName = t[3] and t[3].name
            self:setImage("ItemImage", string.isNilOrEmpty(itemName) and ResMgr.ui.equip_upper_img or ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName)), panel)
            self:setCtrlVisible("ExpireImage", t[3] and InventoryMgr:isItemTimeout(t[3]), panel)
            gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
            self:setPanelPlist("BodyPanel", not string.isNilOrEmpty(itemName) and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

            panel = self:getControl("TrousersPanel", nil, "CustomPanel")
            itemName = t[4] and t[4].name
            self:setImage("ItemImage", string.isNilOrEmpty(itemName) and ResMgr.ui.equip_lower_img or ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName)), panel)
            self:setCtrlVisible("ExpireImage", t[4] and InventoryMgr:isItemTimeout(t[4]), panel)
            gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
            self:setPanelPlist("TrousersPanel", not string.isNilOrEmpty(itemName) and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")

            panel = self:getControl("WeaponPanel", nil, "CustomPanel")
            itemName = t[5] and t[5].name
            self:setImage("ItemImage", string.isNilOrEmpty(itemName) and ResMgr.ui.equip_arms_img or ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName)), panel)
            self:setCtrlVisible("ExpireImage", t[5] and InventoryMgr:isItemTimeout(t[5]), panel)
            gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
            self:setPanelPlist("WeaponPanel", not string.isNilOrEmpty(itemName) and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, "CustomPanel")
        end
    end

    -- 光效道具
    local panel = self:getControl("EffectPanel1", nil, "EffectPanel")
    local effectItemName = effectItem and effectItem.name
    self:setImage("ItemImage", string.isNilOrEmpty(effectItemName) and ResMgr.ui.equip_yupei_img or ResMgr:getItemIconPath(InventoryMgr:getIconByName(effectItemName)), panel)
    self:setCtrlVisible("ExpireImage", effectItem and InventoryMgr:isItemTimeout(effectItem), panel)
    gf:setItemImageSize(self:getControl("ItemImage", nil, panel))
    self:setPanelPlist("EffectPanel1", not string.isNilOrEmpty(effectItemName) and ResMgr.ui.bag_item_bg_img or ResMgr.ui.bag_no_item_bg_img, panel)
end

function CustomDressCollectDlg:refreshPortrait(resetDir)
    if resetDir then self.dir = 5 end
    local icon, parts, colors, magic, gender
    gender = Me:queryBasicInt("gender")
    if 0 ~= self.curSel then
        local fav = DressMgr:getFav(self.curSel)
        if fav then
            local plan = fav.fav_plan
            local t = gf:split(plan, ":")
            local t1 = gf:split(t[3], "|")
            if t then
                if 2 == #t1 then
                    -- 时装
                    icon = InventoryMgr:getFashionShapeIcon(t1[1])
                    magic = FashionEffect[t1[2]] and FashionEffect[t1[2]].fasion_effect or 0
                    parts = nil
                    colors = nil
                elseif 5 == #t1 or 6 == #t1  then
                    local backItem = t1[6]
                    local hairItem = t1[1]
                    local bodyItem = t1[2]
                    local trousersItem = t1[3]
                    local weaponItem = t1[4]
                    magic = FashionEffect[t1[5]] and FashionEffect[t1[5]].fasion_effect or 0

                    icon = 1 == tonumber(t[1]) and 61001 or 60001
                    parts = gf:makePartString(self:getCustomPart(backItem), self:getCustomPart(hairItem),
                        self:getCustomPart(bodyItem), self:getCustomPart(trousersItem), self:getCustomPart(weaponItem))
                    colors = gf:makePartColorString(0, CustomItem[backItem] and CustomItem[backItem].fasion_dye or 0, CustomItem[hairItem] and CustomItem[hairItem].fasion_dye or 0,
                        CustomItem[bodyItem] and CustomItem[bodyItem].fasion_dye or 0, CustomItem[trousersItem] and CustomItem[trousersItem].fasion_dye or 0,
                        CustomItem[weaponItem] and CustomItem[weaponItem].fasion_dye or 0)
                end
            end
        end
    end

    if not icon then
        -- 从本地数据读取
        local magicItem = InventoryMgr:getItemByPos(EQUIP.FASION_BALDRIC)
        local fashionItem = InventoryMgr:getItemByPos(EQUIP.FASION_DRESS)
        local magicItemName = magicItem and magicItem.name or ""
        magic = FashionEffect[magicItemName] and FashionEffect[magicItemName].fasion_effect or 0
        local dressLabel = InventoryMgr:getDressLabel()
        if 0 == dressLabel or -1 == dressLabel then
            if fashionItem then
                icon = InventoryMgr:getFashionShapeIcon(fashionItem.name)
            end
            if not icon then
                -- 默认裸模形象
                icon = gf:getIconByGenderAndPolar(Me:queryBasicInt("gender"), Me:queryBasicInt("polar"))
            end
            parts = nil
            colors = nil
        else
            local t = {}
            local p = {EQUIP.FASION_BACK, EQUIP.FASION_HAIR, EQUIP.FASION_UPPER, EQUIP.FASION_LOWER, EQUIP.FASION_ARMS}
            local i
            for k, v in ipairs(p) do
                i = InventoryMgr:getItemByPos(v)
                t[k] = i and i.name or ""
            end

            icon = 1 == Me:queryBasicInt("gender") and 61001 or 60001
            parts = gf:makePartString(self:getCustomPart(t[1]), self:getCustomPart(t[2]),
                self:getCustomPart(t[3]), self:getCustomPart(t[4]) ,self:getCustomPart(t[5]))
            colors = gf:makePartColorString(0, CustomItem[t[1]] and CustomItem[t[1]].fasion_dye or 0,
                CustomItem[t[2]] and CustomItem[t[2]].fasion_dye or 0, CustomItem[t[3]] and CustomItem[t[3]].fasion_dye or 0,
                CustomItem[t[4]] and CustomItem[t[4]].fasion_dye or 0, CustomItem[t[5]] and CustomItem[t[5]].fasion_dye or 0)
        end
    end

    local panel = self:getControl("PlanPanel", nil, "PlanShapePanel")
    local argList = {
        panelName = "UserPanel",
        icon = icon,
        weapon = 0,
        root = panel,
        action = nil,
        clickCb = nil,
        offPos = nil,
        orgIcon = gf:getIconByGenderAndPolar(gender, Me:queryBasicInt("polar")),
        syncLoad = nil,
        dir = self.dir,
        pTag = nil,
        extend = nil,
        partIndex = parts,
        partColorIndex = colors,
    }

    local charAction = self:setPortraitByArgList(argList)

    local userPanel = self:getControl("UserPanel", nil, panel)
    if userPanel.effect then
        self:removeLoopMagicFromCtrl("UserPanel", userPanel.effect, panel)
    end

    local isFollowEffect
    if magic and 0 ~= magic then
        local lightEffects = require("cfg/LightEffect")
        local showMagic = lightEffects[magic]
        local size = userPanel:getContentSize()
        local pos = cc.p(charAction:getPosition())
        if 2 == showMagic.pos then
            local x, y = charAction:getWaistOffset()
            pos = cc.p(pos.x + x, pos.y + y)
        elseif 3 == showMagic.pos then
            local x, y = charAction:getHeadOffset()
            pos = cc.p(pos.x + x, pos.y + y)
        else
            pos = cc.p(pos.x, pos.y)
        end
        self:addMagicToCtrl("UserPanel", showMagic.icon, panel, pos, self.dir)
        userPanel.effect = showMagic.icon
        isFollowEffect = showMagic.follow_dis and showMagic.follow_dis > 0 or false
    else
        userPanel.effect = nil
    end

    if isFollowEffect then
        charAction:setAction(Const.SA_WALK)
    else
        self:displayPlayActions("UserPanel", nil, -36)
    end
    self.icon = icon
end

function CustomDressCollectDlg:refreshListView()
    local list = self:resetListView("PlanListView", 4, nil, "PlanListPanel")
    local datas = DressMgr:getFavs() or {}
    local allDatas = {}

    if #datas < 10 then
        local newData = { fav_name = CHS[2100170], fav_no = 0 }
        table.insert(allDatas, newData)
    end

    for i = 1, #datas do
        table.insert(allDatas, datas[i])
    end

    local panel
    local selIndex = 0
    for i = 1, #allDatas do
        panel = self.planItem:clone()
        self:setPlanValue(panel, allDatas[i])
        if self.curSel and self.curSel == allDatas[i].fav_no then
            selIndex = i - 1
        end
        list:pushBackCustomItem(panel)
    end

    self:onClickPlan(list:getItem(selIndex))

    self:setLabelText("PetNumberLabel", string.format(CHS[2100171], #datas), "PLanNumberPanel")
end

function CustomDressCollectDlg:refreshButtonState()
    self:setCtrlVisible("SaveNameButton", false, "NamePanel")
    self:setCtrlVisible("DeleteButton", 0 ~= self.curSel, "PlanShapePanel")
    self:setCtrlVisible("SaveButton", 0 == self.curSel, "PlanShapePanel")
    self:setCtrlVisible("UseButton", 0 ~= self.curSel, "PlanShapePanel")
end

function CustomDressCollectDlg:setPlanValue(panel, data)
    panel:setName(tostring(data.fav_no))
    panel.index = data.fav_no
    self:setLabelText("Label", data.fav_name, panel)
end

function CustomDressCollectDlg:onClickPlan(sender)
    self.chosenEffect:removeFromParent()
    sender:addChild(self.chosenEffect)

    self.curSel = sender.index or 0
    if 0 == self.curSel then
        self.editBox:setText("")
        self:setLabelText("NameLabel", CHS[2100169], "NamePanel")
    else
        local fav = DressMgr:getFav(self.curSel)
        self.editBox:setText(fav.fav_name)
        self:setLabelText("NameLabel", fav.fav_name, "NamePanel")
    end
    self:refreshPortrait(true)
    self:refreshItemIcon()
    self:refreshButtonState()
end

function CustomDressCollectDlg:onDeleteButton()
    gf:confirm(CHS[2100172], function()
        gf:CmdToServer("CMD_FASION_FAVORITE_DEL", { fav_id = self.curSel })
    end)
end

function CustomDressCollectDlg:onUseButton()
    if 0 == self.curSel then
        return
    end

    gf:CmdToServer("CMD_FASION_FAVORITE_APPLY", { fav_id = self.curSel })
end

function CustomDressCollectDlg:onSaveButton()
    local content = self.editBox:getText()
    if string.isNilOrEmpty(content) then
        gf:ShowSmallTips(CHS[2100173])
        return
    end
    local _, fitStr = gf:filtText(content)
    if fitStr then
        return
    end
    gf:CmdToServer("CMD_FASION_FAVORITE_ADD", { fav_name = content })
end

function CustomDressCollectDlg:onTurnLeftButton()
    self.dir = self.dir + 2
    if self.dir > 7 then
        self.dir = 1
    end

    self:refreshPortrait()
end

function CustomDressCollectDlg:onTurnRightButton()
    self.dir = self.dir - 2
    if self.dir < 0 then
        self.dir = 7
    end

    self:refreshPortrait()
end

function CustomDressCollectDlg:onChangeNameButton()
    self.editBox:openKeyboard()
end

function CustomDressCollectDlg:onSaveNameButton()
    if 0 == self.curSel then return end

    local content = self.editBox:getText()
    if string.isNilOrEmpty(content) then
        gf:ShowSmallTips(CHS[2100173])
        return
    end
    local _, fitStr = gf:filtText(content)
    if fitStr then
        return
    end

    gf:CmdToServer("CMD_FASION_FAVORITE_RENAME", { fav_id = self.curSel, new_name = content })
end

function CustomDressCollectDlg:MSG_FASION_FAVORITE_LIST(data)
    self:refreshListView()
end

return CustomDressCollectDlg