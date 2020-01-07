-- EquipmentRefiningAttributeDlg.lua
-- Created by songcw Api/22/2015
-- 装备炼化界面

local EquipmentRefiningAttributeDlg = Singleton("EquipmentRefiningAttributeDlg", Dialog)

local attrib_blue = 1
local attrib_pink = 2
local attrib_yellow = 3

function EquipmentRefiningAttributeDlg:init()
    self:bindListener("AllRefiningButton", self.onAllRefiningButton)
    self:bindListener("RefiningButton", self.onRefiningButton)

    self.barColor = self:getControl("ProgressBar"):getColor()

    self.labelColor = self:getControl("LevelLabel"):getColor()

    local crystalPanel = self:getControl("ItemPanel1")
    self:bindListener("ItemImage", self.onCrystalImage, crystalPanel)

    local pinkPanel = self:getControl("ItemPanel2")
    self:bindListener("ItemImage", self.onPinkImage, pinkPanel)

    self.haveAttPos = {}
    self.equipButton = self:getControl("EquipmentButton"):clone()
    self.equipButton:retain()
    self:getControl("EquipmentButton"):removeFromParent()

    self.attType = nil

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_DIALOG_OK")
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function EquipmentRefiningAttributeDlg:cleanup()
    self:releaseCloneCtrl("reformPanel")
end

function EquipmentRefiningAttributeDlg:setAttrib(attTab, attType, pos, tag)
    self.tag = tag or 1
    self.attTab = attTab
    self.attType = attType
    self.pos = pos
    self:setAttribDlgInfo()
    self:setExsitEuip()

    self:setDegreeAndMax(pos, self.attTab[self.tag].field, attType)
end

function EquipmentRefiningAttributeDlg:setAttribByItem(item)

    self.tag = 1
    self.attTab = {}
    self.attType = 1
    self.pos = nil

    -- 判断水晶类型
    local itemName = item.name
    local pos = gf:findStrByByte(itemName, CHS[3002481])
    if pos ~= nil then
        itemName = string.sub(itemName, 1, pos - 1)
    end
    if itemName == CHS[4000064] then
        self.attType = attrib_blue
        for key, value in pairs(item.extra) do
            local blue_tag = "_" .. Const.FIELDS_EXTRA1
            local last = gf:findStrByByte(key, blue_tag)
            if last ~= nil then
                table.insert(self.attTab, {field = string.sub(key, 1, last - 1)})
            end
        end
    elseif itemName == CHS[4000078] then
        self.attType = attrib_pink
        local fieldName = string.sub(item.name, pos + 2, -1)
        table.insert(self.attTab, {field = EquipmentMgr:getAttribChsOrEng(fieldName)})
    elseif itemName == CHS[4000105] then
        self.attType = attrib_yellow
        local attStr = ""
        if not self.pos or self.pos == EQUIP_TYPE.WEAPON then
            -- CHS[4000031]:所有相性
            attStr = CHS[4000031]
        else
            -- CHS[4000048]:所有属性
            attStr = CHS[4000048]
        end
        self.attTab[#self.attTab + 1] = {field = EquipmentMgr:getAttribChsOrEng(attStr)}
    end

    if #self.attTab == 0 then self:onCloseButton() return end
    -- 选择装备
    self:isExsitAttByName(self.attTab[self.tag].field)
    self:setExsitEuip()
end

function EquipmentRefiningAttributeDlg:setAttribDlgInfo()
    if self.attType == attrib_pink then
        local panel = self:getControl("RefiningPanel")
        self:setLabelText("TitleLabel", CHS[4000344], panel)
    elseif self.attType == attrib_yellow then
        local panel = self:getControl("RefiningPanel")
        self:setLabelText("TitleLabel", CHS[4000345], panel)
        local equip = InventoryMgr:getItemByPos(self.pos)
        local attStr
        if equip.equip_type == EQUIP_TYPE.WEAPON then
            -- CHS[4000031]:所有相性
            attStr = CHS[4000031]
        else
            -- CHS[4000048]:所有属性
            attStr = CHS[4000048]
        end
        if self.attTab[self.tag] == nil then
            self.attTab[self.tag] = {["field"] = EquipmentMgr:getAttribChsOrEng(attStr), ["value"] = 0}
            self:setButtonText("RefiningButton", CHS[4000065])
        end
    end

    -- 选择装备
    self:isExsitAttByName(self.attTab[self.tag].field)

    self:setRefiningInfo(self.attTab[self.tag].field, self.pos, self.attType)
end

function EquipmentRefiningAttributeDlg:setRefiningInfo(field, pos, attType)
    if not field or not pos or not attType then return end
    -- 属性
    local equip = InventoryMgr:getItemByPos(pos)
    local value1, value2 = self:getValueByField(pos, field, attType)
    value2 = value2 or value1

    local attChs = EquipmentMgr:getAttribChsOrEng(field)
    self:setLabelText("AttributeLabel", attChs .. value1 .. " -> " .. value2)

    -- 耗材水晶
    local crystaPanel = self:getControl("ItemPanel1")
    self:setCtrlVisible("LevelLabel", false ,crystaPanel)
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4000078])), crystaPanel)
    local crystaCount
    if attType == attrib_blue then
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4000064])), crystaPanel)
        crystaCount = InventoryMgr:getAmountByName(CHS[4000064] .. CHS[3002481] .. EquipmentMgr:getAttribChsOrEng(field))
    elseif attType == attrib_pink then
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4000078])), crystaPanel)
        local crystaName = EquipmentMgr:getAttribChsOrEng(field)
        if crystaName == CHS[3002482] then crystaName = CHS[3002483] end
        crystaCount = InventoryMgr:getAmountByName(CHS[4000078] .. CHS[3002481] .. crystaName)
    elseif attType == attrib_yellow then
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4000105])), crystaPanel)
        crystaCount = InventoryMgr:getAmountByName(CHS[4000105])
    end
    
    self:setItemImageSize("ItemImage", crystaPanel)
    if crystaCount > 999 then crystaCount = "*" end
    if crystaCount == 0 then
        self:setLabelText("OwnNumberLabel", crystaCount or "", crystaPanel, COLOR3.RED)
    else
        self:setLabelText("OwnNumberLabel", crystaCount or "", crystaPanel, self.labelColor)
    end
    self:setLabelText("CostNumberLabel", "/1", crystaPanel, self.labelColor)

    -- 耗材粉材
    local pinkPanel = self:getControl("ItemPanel2")
    local polar = Me:queryBasicInt("polar")
    local materialName = EquipmentMgr:getMeNeedPinkMaterialName()
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(materialName)), pinkPanel)
    self:setItemImageSize("ItemImage", pinkPanel)
    
    local materialLevel = EquipmentMgr:getMaterialLevelByEquipLevel(equip.req_level)
    local materialCount = InventoryMgr:getAmountByNameLevel(materialName,materialLevel)
    if materialCount > 999 then materialCount = "*" end
    self:setLabelText("LevelLabel", materialLevel, pinkPanel, self.labelColor)
    if materialCount == 0 then
        self:setLabelText("OwnNumberLabel", materialCount or "", pinkPanel, COLOR3.RED)
    else
        self:setLabelText("OwnNumberLabel", materialCount or "", pinkPanel, self.labelColor)
    end

    self:setLabelText("CostNumberLabel", "/1", pinkPanel, self.labelColor)

    -- 按钮
    if attType == attrib_yellow then
        if self:isActiveAtt(pos, field, attType) then
            self:setButtonText("RefiningButton", CHS[4000083])
        else
            self:setButtonText("RefiningButton", CHS[4000065])
        end
    else
        self:setButtonText("RefiningButton", CHS[4000083])
    end
end

function EquipmentRefiningAttributeDlg:setDegreeAndMax(pos, field, attType, isAction)
    pos = pos or self.pos
    field = field or self.attTab[self.tag].field
    attType = attType or self.attType

    local level
    local cur
    if attType == attrib_blue then
        level = EquipmentMgr.equipBlueData[pos].extra[string.format("%s_%d", field, Const.PROP_LEVEL)] or 0
        cur = EquipmentMgr.equipBlueData[pos].extra[string.format("%s_%d", field, Const.PROP_DEGREE)] or 0
    elseif attType == attrib_pink then
        level = EquipmentMgr.equipPinkData[pos].extra[string.format("%s_%d", field, Const.PROP_LEVEL)] or 0
        cur = EquipmentMgr.equipPinkData[pos].extra[string.format("%s_%d", field, Const.PROP_DEGREE)] or 0
    elseif attType == attrib_yellow then
        level = EquipmentMgr.equipYellowData[pos].extra[string.format("%s_%d", field, Const.PROP_LEVEL)] or 0
        cur = EquipmentMgr.equipYellowData[pos].extra[string.format("%s_%d", field, Const.PROP_DEGREE)] or 0
    end

    local max = self:getMaxCountCrysta(EquipmentMgr:getAttribsTabByName(EquipmentMgr:getAttribChsOrEng(field) .. CHS[4000077]), level)

    if cur == max then
        self:setProgressBar("ProgressBar", cur, max, nil, COLOR3.YELLOW)
        self:setLabelText("ProgressLabel", CHS[4000102], nil, COLOR3.RED)
    else
        if self.isUpgradeCD and cur == 0 then
            -- 进度为0代表等级加1，数值先变化成100％
            self:setLabelText("ProgressLabel", string.format("%d/%d", self.lastCount or max, self.lastCount or max))
        end

        local function setBarLabel()
            self:setLabelText("ProgressLabel", string.format("%d/%d", cur, max))
            self:setProgressBar("ProgressBar", cur, max, nil, self.barColor)
            self.isUpgradeCD = false
            self.lastCount = max
        end

        self:setProgressBar("ProgressBar", cur, max, nil, self.barColor, isAction, setBarLabel)
    end
end

-- 获取当前强化次数需要耗费黑水晶的数量     strMax：可强化多少次      strCur：当前强化次数
function EquipmentRefiningAttributeDlg:getMaxCountCrysta(strMax, strCur)
    if strCur == nil then return end

    strCur = strCur + 1
    if strCur >= strMax then strCur = strMax end

    if strMax == 4 then
        -- 可强化4次
        -- 黄水晶和其他不一样
        if self.attType == attrib_yellow then
            if strCur < 1 then
                return 1
            elseif strCur == 1 then
                return 10
            elseif strCur == 2 then
                return 30
            elseif strCur == 3 then
                return 60
            elseif strCur == 4 then
                return 100
            end
        end

        if strCur < 1 then
            return 1
        elseif strCur >= 1 then
            return strCur * 10
        end
    elseif strMax == 9 then
        -- 可强化9次
        return 1 + strCur * 2
    elseif strMax == 11 then
        -- 可强化11次
        if strCur < 6 then
            return strCur + 1
        elseif strCur >= 6 then
            return ((strCur - 6) * 2 + 8)
        end
    elseif strMax == 14 then
        -- 可强化14次
        if strCur < 4 then
            return (math.floor(strCur / 2) + 1)
        elseif strCur >= 4 then
            return strCur - 1
        end
    elseif strMax == 16 then
        -- 可强化16次
        -- 黄水晶不一样
        if self.attType == attrib_yellow then
            if strCur < 1 then
                return 1
            elseif strCur < 6 then
                return 2 * math.floor(strCur / 3 + 1)
            elseif strCur >= 6 then
                return 2 * (strCur - 3)
            end
        end

        if strCur < 6 then
            return (math.floor(strCur / 3) + 1)
        elseif strCur >= 6 then
            return strCur - 3
        end
    elseif strMax == 19 then
        -- 可强化19次
        if strCur < 6 then
            return math.floor(strCur / 3 + 1)
        elseif strCur >= 6 and strCur < 16 then
            return math.floor((strCur - 6) / 2 ) + 3
        elseif strCur >=16 and strCur < 19 then
            return ((strCur - 16)) + 8
        end
    elseif strMax == 29 then
        -- 可强化29次
        return math.floor(strCur / 5) + 1
    end
end

function EquipmentRefiningAttributeDlg:isActiveAtt(pos, field, attType)
    local equip = InventoryMgr:getItemByPos(pos)
    if attType == attrib_blue then
        local blueStr = string.format("%s_%d", field, Const.FIELDS_EXTRA1)
        if equip.extra[blueStr] ~= nil and field ~= "phy_power" and field ~= "mag_power" then
            return true
        end
    elseif attType == attrib_pink then
        local pinkStr = string.format("%s_%d", field, Const.FIELDS_EXTRA2)
        if equip.extra[pinkStr] ~= nil then
            return true
        end
    elseif attType == attrib_yellow then
        local yellowStr = string.format("%s_%d", field, Const.FIELDS_PROP3)
        if equip.extra[yellowStr] and equip.extra[yellowStr] > 0 then
            return true
        end
    end

    return false
end

function EquipmentRefiningAttributeDlg:getValueByField(pos, field, attType)
    if attType == attrib_blue then
        local curValue = EquipmentMgr.equipBlueData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE)]
        local nextValue = EquipmentMgr.equipBlueData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE_NEXT)]
        return curValue, nextValue
    elseif attType == attrib_pink then
        local curValue = EquipmentMgr.equipPinkData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE)]
        local nextValue = EquipmentMgr.equipPinkData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE_NEXT)]
        return curValue, nextValue
    elseif attType == attrib_yellow then
        local curValue = EquipmentMgr.equipYellowData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE)]
        local nextValue = EquipmentMgr.equipYellowData[pos].extra[string.format("%s_%d", field, Const.PROP_VALUE_NEXT)]
        return curValue, nextValue
    end
end

function EquipmentRefiningAttributeDlg:setExsitEuip()
    local ChooseListView = self:resetListView("ChooseListView")
    for _,equip in pairs(self.haveAttPos) do
        local equipButton = self.equipButton:clone()
        equipButton:setTitleText(tostring(equip.str))
        self:setCtrlVisible("ChosenEffectImage", false, equipButton)
        self:bindTouchEndEventListener(equipButton, self.chooseEquip)
        ChooseListView:pushBackCustomItem(equipButton)
        equipButton:setTag(equip.pos)
        if equip.pos == self.pos or self.pos == nil then self:chooseEquip(equipButton) end
    end
end

function EquipmentRefiningAttributeDlg:isExsitAttByName(field)
    self.haveAttPos = {}
    if self.attType ~= attrib_yellow then
        self:traverseTab(CHS[4000058], EQUIP.WEAPON, field)
        self:traverseTab(CHS[4000060], EQUIP.HELMET, field)
        self:traverseTab(CHS[4000059], EQUIP.ARMOR, field)
        self:traverseTab(CHS[4000061], EQUIP.BOOT, field)
    else
        self.haveAttPos[#self.haveAttPos + 1] = {str =  CHS[4000058], pos = EQUIP_TYPE.WEAPON}
        self.haveAttPos[#self.haveAttPos + 1] = {str =  CHS[4000060], pos = EQUIP_TYPE.HELMET}
        self.haveAttPos[#self.haveAttPos + 1] = {str =  CHS[4000059], pos = EQUIP_TYPE.ARMOR}
        self.haveAttPos[#self.haveAttPos + 1] = {str =  CHS[4000061], pos = EQUIP_TYPE.BOOT}
    end
end

function EquipmentRefiningAttributeDlg:traverseTab(str, pos, field)
    for _,att in pairs(EquipmentMgr:getAttribsTabByName(str)) do
        if att.field == field then
            self.haveAttPos[#self.haveAttPos + 1] = {str = str, pos = pos}
        end
    end
end

function EquipmentRefiningAttributeDlg:chooseEquip(sender, eventType)
    self.isUpgradeCD = false
    local ChooseListPanel = self:getControl("ChooseListView")
    local equipPanels = ChooseListPanel:getItems()
    for _,equipButton in pairs(equipPanels) do

        self:setCtrlVisible("ChosenEffectImage", false, equipButton)
    end

    self:setCtrlVisible("ChosenEffectImage", true, sender)
    self.pos = sender:getTag() or 1
    local text = sender:getTitleText()

    if self.attType == attrib_blue then
        if EquipmentMgr.equipBlueData[self.pos] == nil then
            gf:CmdToServer("CMD_PRE_UPGRADE_EQUIP", {
                pos = self.pos or EQUIP.WEAPON,
                type = Const.UPGRADE_EQUIP_REFINE_BLUE,
            })

            return
        end
    elseif self.attType == attrib_pink then
        -- 粉属性
        if EquipmentMgr.equipPinkData[self.pos] == nil then
            gf:CmdToServer("CMD_PRE_UPGRADE_EQUIP", {
                pos = self.pos or EQUIP.WEAPON,
                type = Const.UPGRADE_EQUIP_REFINE_PINK,
            })

            return
        end
    elseif self.attType == attrib_yellow then
        -- 黄属性
        if EquipmentMgr.equipYellowData[self.pos] == nil then
            gf:CmdToServer("CMD_PRE_UPGRADE_EQUIP", {
                pos = self.pos or EQUIP.WEAPON,
                type = Const.UPGRADE_EQUIP_REFINE_YELLOW,
                para = tostring(0)
            })

            return
        end
    end

    if self.attType == attrib_yellow then

        if self.pos == EQUIP_TYPE.WEAPON then
            -- CHS[4000031]:所有相性
            self.attTab[self.tag].field = EquipmentMgr:getAttribChsOrEng(CHS[4000031])
            self.attTab[self.tag].value = 0
        else
            -- CHS[4000048]:所有属性
            self.attTab[self.tag].field = EquipmentMgr:getAttribChsOrEng(CHS[4000048])
            self.attTab[self.tag].value = 0
        end
    end

    self:setDegreeAndMax(self.pos, self.attTab[self.tag].field, self.attType)
    self:setRefiningInfo(self.attTab[self.tag].field, self.pos, self.attType)
end

function EquipmentRefiningAttributeDlg:onAllRefiningButton(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002484])
        return
    end

    if self.attType == attrib_blue then
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.pos,
            type = Const.UPGRADE_EQUIP_REFINE_BLUE_ALL,
            para = self.attTab[self.tag].field
        })
    elseif self.attType == attrib_pink then
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.pos,
            type = Const.UPGRADE_EQUIP_REFINE_PINK_ALL,
            para = self.attTab[self.tag].field
        })
    elseif self.attType == attrib_yellow then
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.pos,
            type = Const.UPGRADE_EQUIP_REFINE_YELLOW_ALL,
            para = self.attTab[self.tag].field
        })
    end
end

function EquipmentRefiningAttributeDlg:onRefiningButton(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002484])
        return
    end

    if self.isUpgradeCD then return end
    self.isUpgradeCD = true

    if self.attType == attrib_blue then
        -- 修改的属性tag
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.pos,
            type = Const.UPGRADE_EQUIP_REFINE_BLUE,
            para = self.attTab[self.tag].field
        })
    elseif self.attType == attrib_pink then
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.pos,
            type = Const.UPGRADE_EQUIP_REFINE_PINK,
            para = self.attTab[self.tag].field
        })
    elseif self.attType == attrib_yellow then
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.pos,
            type = Const.UPGRADE_EQUIP_REFINE_YELLOW,
            para = tostring(self.attTab[self.tag].field)
        })
    end
end

function EquipmentRefiningAttributeDlg:onCrystalImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local itemName = ""

    if self.attType == attrib_blue then
        itemName = CHS[4000064] .. CHS[3002481] .. EquipmentMgr:getAttribChsOrEng(self.attTab[self.tag].field)
    elseif self.attType == attrib_pink then
        itemName = CHS[4000078] .. CHS[3002481] .. EquipmentMgr:getAttribChsOrEng(self.attTab[self.tag].field)
    elseif self.attType == attrib_yellow then
        itemName = CHS[4000105]
    end

    if itemName == "" then return end
    InventoryMgr:showBasicMessageDlg(itemName, rect)
end

function EquipmentRefiningAttributeDlg:onPinkImage(sender, eventType)
    local materialName = EquipmentMgr:getMeNeedPinkMaterialName()
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(materialName, rect)
end

function EquipmentRefiningAttributeDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    if self.pos and data[1].pos == self.pos then
        self:setDegreeAndMax(self.pos, self.attTab[self.tag].field, self.attType, true)

        self:setRefiningInfo(self.attTab[self.tag].field, self.pos, self.attType)
    end
end

function EquipmentRefiningAttributeDlg:MSG_DIALOG_OK(data)
    self.isUpgradeCD = false
end

function EquipmentRefiningAttributeDlg:MSG_GENERAL_NOTIFY(data)
    self.isUpgradeCD = false
end
return EquipmentRefiningAttributeDlg
