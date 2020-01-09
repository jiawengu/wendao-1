-- PetFuseDlg.lua
-- Created by sujl, Oct/19/2016
-- 骑宠融合界面

local RadioGroup = require "ctrl/RadioGroup"

local PetFuseDlg = Singleton("PetFuseDlg", Dialog)

local MORPH = { "life", "mana", "speed", "phy", "mag"}

function PetFuseDlg:init()
    self:bindListener("BKPanel", self.onBKPanel)
    self:bindListener("FuseButton", self.onFuseButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("MaterialImage", self.onMaterialImage, "MaterialPanel")

    for i = 1, 3 do
        local panelName = "HeadPanel" .. i

        self:bindListener(panelName, function(dlg, sender, eventType)
            self:selectOtherPet(sender:getName())
        end)
    end

    self:setCheck("BindCheckBox", not InventoryMgr.UseLimitItemDlgs[self.name] or InventoryMgr.UseLimitItemDlgs[self.name] == 1, "MaterialPanel")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"CheckBox_1", "CheckBox_2"}, self.onDeputyCheck, "DeputyPanel")

    -- 宠物
    self.singlePetPanel = self:getControl("SinglePetPanel", Const.UIPanel, "PetListView")
    self.singlePetPanel:setVisible(true)
    self.singlePetPanel:retain()
    self.singlePetPanel:removeFromParent()

    -- 道具
    self.singleItemPanel = self:getControl("SinglePetPanel", Const.UIPanel, "ItemListView")
    self.singleItemPanel:setVisible(true)
    self.singleItemPanel:retain()
    self.singleItemPanel:removeFromParent()

    -- 初始化道具
    self.itemUseCount = 1
    self:setItemInfo("MaterialPanel")
    self:blindPress("WizAddButton")
    self:blindPress("ReduceButton")
    self:bindNumInput("NumberFrameImage", "MaterialPanel", function() end)
    self:bindCheckBoxListener("BindCheckBox", self.onBindCheckBox, "MaterialPanel")

    self:setCtrlVisible("AttriPanel", true)
    self:setCtrlVisible("DeputyPanel", false)

    self:hookMsg("MSG_QUERY_MOUNT_MERGE_RATE")
    self:hookMsg("MSG_PREVIEW_MOUNT_ATTRIB")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_SET_CURRENT_PET")
    self:hookMsg("MSG_SET_CURRENT_MOUNT")
end

function PetFuseDlg:cleanup()
    self.selectPet = nil
    self.selectPets = nil

    if self.singlePetPanel then
        self.singlePetPanel:release()
        self.singlePetPanel = nil
    end

    if self.singleItemPanel then
        self.singleItemPanel:release()
        self.singleItemPanel = nil
    end
end

function PetFuseDlg:refreshRate()
    if not self.selectPets then return end
    local pets = {}
    local items = {}
    local pet, item

    if self.selectPets then
        for _, v in pairs(self.selectPets) do
            pet = PetMgr:getPetById(v)
            if pet then
                table.insert(pets, pet:queryBasicInt("no"))
            else
                item = InventoryMgr:getItemByPos(v)
                if item then
                    table.insert(items, item.pos)
                end
            end
        end
    end

    if #pets + #items < 3 then return end
    if not self.selectPet then return end

    -- 请求成功率
    local data = {
        main_pet_no = self.selectPet:queryBasicInt("no"),
        pets_no = table.concat(pets, "|"),
        items_no = table.concat(items, "|"),
        cost_num = self.itemUseCount,
    }

    gf:CmdToServer('CMD_QUERY_MOUNT_MERGE_RATE', data)
end

function PetFuseDlg:setItemInfo(panelName)
    local panel = self:getControl(panelName)
    local itemName = CHS[2000128]
    local icon = InventoryMgr:getIconByName(itemName)
    self:setImage("MaterialImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("MaterialImage", panel)

    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, self:isUseLimitedItem())

    self:setNumImgForPanel("MaterialImage", amount >= self.itemUseCount and ART_FONT_COLOR.NORMAL_TEXT or ART_FONT_COLOR.RED, amount > 999 and "*" or amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 25, panel)
    --self:setNumImgForPanel("NumberFrameImage", ART_FONT_COLOR.NORMAL_TEXT, self.itemUseCount, false, LOCATE_POSITION.MID, 25, panel)
    self:setLabelText("NumLabel", self.itemUseCount, self:getControl("NumberFrameImage", Const.UIPanel, panel))
    self:updateLayout("Panel", panel)

    self:setCtrlEnabled("ReduceButton", self.itemUseCount > 1, panel, true)
    self:setCtrlEnabled("WizAddButton", self.itemUseCount < 3, panel, true)

    self:refreshRate()
end

-- 数字键盘插入数字
function PetFuseDlg:insertNumber(num)
    local itemName = CHS[2000128]
    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, self:isUseLimitedItem())
    if num < 1 or num > 3 then return end
    self.itemUseCount = num
    self:setItemInfo("MaterialPanel")
end

function PetFuseDlg:isUseLimitedItem()
    local panel = self:getControl("SelectPanel", Const.UIPanel, "MaterialPanel")
    return self:isCheck("BindCheckBox", panel)
end

function PetFuseDlg:blindPress(name)
    local widget = self:getControl(name, nil, "MaterialPanel")

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local clickBtn = sender:getName()
            if clickBtn == "WizAddButton" then
                self:onAddButton()
            elseif clickBtn == "ReduceButton" then
                self:onReduceButton()
            end
        end
    end

    widget:addTouchEventListener(listener)
end

function PetFuseDlg:setPetInfo(pet)
    if not pet then self:resetPet() return end
    self.selectPet = pet

    -- 设置标题
    local rawCapactiyLevel = PetMgr:getMountRawRank(pet)
    local capacityLevel = pet:queryBasicInt("capacity_level")
    if rawCapactiyLevel >= 2 and rawCapactiyLevel <= 4 then
        -- 低阶融合
        self:setTitle(CHS[2000129])
        if capacityLevel >= 5 then
            self:setPetFuseFullInfo(pet)
        else
            self:setCtrlVisible("FuseLabel", false, "AttriPanel")
            self:setCtrlVisible("ProgressPanel", false, "AttriPanel")
            gf:CmdToServer('CMD_PREVIEW_MOUNT_ATTRIB', { pet_no = pet:queryBasicInt("no"), target_level = capacityLevel + 1 })
        end

        self:setCtrlVisible("MarkPanel_3", pet:queryBasicInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI, "AttriPanel")
        self:setCtrlVisible("MarkPanel_2", pet:queryBasicInt("mount_type") ~= MOUNT_TYPE.MOUNT_TYPE_JINGGUAI, "AttriPanel")
        self:setCtrlVisible("MarkPanel_1", false, "AttriPanel")

    elseif rawCapactiyLevel >= 5 then
        -- 高阶融合
        self:setTitle(CHS[2000130])
        if capacityLevel >= rawCapactiyLevel + 1 then
            self:setPetFuseFullInfo(pet)
        else
            self:setCtrlVisible("FuseLabel", true, "AttriPanel")
            self:setCtrlVisible("ProgressPanel", true, "AttriPanel")
            gf:CmdToServer('CMD_PREVIEW_MOUNT_ATTRIB', { pet_no = pet:queryBasicInt("no"), target_level = capacityLevel + 1 })
        end

        self:setCtrlVisible("MarkPanel_1", pet:queryBasicInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI, "AttriPanel")
    end

    -- 设置宠物头像
    local petImage = self:getControl("PetImage", Const.UIImage, "MainPetPanel")
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:loadTexture(path)
    self:setItemImageSize("PetImage", "MainPetPanel")

    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("LogoImage", polarPath, "MainPetPanel")

    -- 设置宠物等级
    local level  = pet:queryBasicInt("level")
    self:setNumImgForPanel("MainPetPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 25, "PetPanel")
end

function PetFuseDlg:setPetFuseFullInfo(pet)
    self:setCtrlVisible("AttribPanel", false, "AttriPanel")
    self:setCtrlVisible("AttribPanel_1", true, "AttriPanel")
    self:setCtrlVisible("MaxImage", true, "FusePanel")
    self:setCtrlVisible("MaterialPanel", false, "FusePanel")
    self:setCtrlVisible("FuseButton", false)
    self:setCtrlVisible("ConfirmButton", true)

    for i = 1, 3 do
        self:setCtrlVisible("HeadPanel" .. tostring(i), false)
    end

    local ride_attrib = pet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
    if not ride_attrib or  type(ride_attrib) ~= 'table' then return end

    local panel = self:getControl("MainPetAttribPanel", Const.UIPanel, "AttribPanel_1")

    self:setLabelText("RateNumLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(pet)), "MainPetPanel")

    -- 阶位
    local mountLevel = pet:queryInt("capacity_level")
    self:setLabelText("RankLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(pet)), panel)

    -- 风灵丸时间
    local day = PetMgr:getFenghuaDay(self.selectPet)
    local color1 = COLOR3.TEXT_DEFAULT
    local color2 = COLOR3.GREEN

    if day == 0 or pet:queryBasicInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI then
        color1 = COLOR3.GRAY
        color2 = COLOR3.GRAY
    end

    -- 移速上限
    local speed = math.floor(pet:queryInt("capacity_level"))
    self:setLabelText("SpeedLvLabel", string.format(CHS[2000131], speed), panel, color1)

    -- 主人物攻
    self:setLabelText("PhysicalPowerLabel", string.format("+%d", ride_attrib.phy_power), panel, color1)

    -- 主人法攻
    self:setLabelText("MagicPowerLabel", string.format("+%d", ride_attrib.mag_power), panel, color1)

    -- 主人防御
    self:setLabelText("DefenceLabel", string.format("+%d", ride_attrib.def), panel, color1)

    -- 主人所有属性
    self:setLabelText("AllAttribLabel", string.format("+%d", ride_attrib.all_attrib), panel, color1)
end

function PetFuseDlg:setPetFuseInfo(pet, data)
    self:setCtrlVisible("AttribPanel", true, "AttriPanel")
    self:setCtrlVisible("AttribPanel_1", false, "AttriPanel")

    local ride_attrib = pet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
    if not ride_attrib or  type(ride_attrib) ~= 'table' then return end

    local panel1 = self:getControl("MainPetAttribPanel", Const.UIPanel, "AttribPanel")
    local panel2 = self:getControl("MainPetFuseAttribPanel", Const.UIPanel, "AttribPanel")

    -- 阶位
    local mountLevel = pet:queryInt("capacity_level")
    self:setLabelText("RankLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(pet)), panel1)
    self:setLabelText("RankLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(pet, mountLevel + 1)), panel2)

    -- 风灵丸时间
    local day = PetMgr:getFenghuaDay(self.selectPet)
    local color1 = COLOR3.TEXT_DEFAULT
    local color2 = COLOR3.GREEN

    if day == 0 or pet:queryBasicInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI then
        color1 = COLOR3.GRAY
        color2 = COLOR3.GRAY
    end

    -- 移速上限
    local speed = math.floor(pet:queryInt("capacity_level"))
    self:setLabelText("SpeedLvLabel", string.format(CHS[2000131], speed), panel1, color1)
    self:setLabelText("SpeedLvLabel", string.format(CHS[2000131], math.floor(data.speed / 5)), panel2, color2)

    -- 主人物攻
    self:setLabelText("PhysicalPowerLabel", string.format("+%d", ride_attrib.phy_power), panel1, color1)
    self:setLabelText("PhysicalPowerLabel", string.format("+%d", data.phy_power), panel2, color2)

    -- 主人法攻
    self:setLabelText("MagicPowerLabel", string.format("+%d", ride_attrib.mag_power), panel1, color1)
    self:setLabelText("MagicPowerLabel", string.format("+%d", data.mag_power), panel2, color2)

    -- 主人防御
    self:setLabelText("DefenceLabel", string.format("+%d", ride_attrib.def), panel1, color1)
    self:setLabelText("DefenceLabel", string.format("+%d", data.def), panel2, color2)

    -- 主人所有属性
    self:setLabelText("AllAttribLabel", string.format("+%d", ride_attrib.all_attrib), panel1, color1)
    self:setLabelText("AllAttribLabel", string.format("+%d", data.all_attrib), panel2, color2)

    -- 融合度
    local merge_rate = pet:queryBasicInt("merge_rate")
    self:setProgressBar("ProgressBar", merge_rate / 1000000, 1, "AttribPanel")
    self:setLabelText("ProgressLabel_1", string.format("%.02f%%", merge_rate / 10000), "AttribPanel")
    self:setLabelText("ProgressLabel_2", string.format("%.02f%%", merge_rate / 10000), "AttribPanel")
end

function PetFuseDlg:setTitle(title)
    self:setLabelText("TitleLabel_1", title, "MiddleTitleImage")
    self:setLabelText("TitleLabel_2", title, "MiddleTitleImage")
end

function PetFuseDlg:resetOtherPets()
    local ctlName
    for i = 1, 3 do
        ctlName = "HeadPanel" .. i
        self:resetHeadPanel(ctlName)
    end
end

function PetFuseDlg:resetHeadPanel(panelName)
     -- 设置宠物头像
    self:setCtrlVisible("PetImage", false, panelName)

    -- 设置宠物相性
    self:setCtrlVisible("LogoImage", false, panelName)

    -- 设置宠物等级
    self:getControl("PetImage", Const.UIPanel, panelName):removeAllChildren()

    self:setCtrlVisible("NoneImage", true, panelName)
    self:setCtrlVisible("PetImagePanel", false, panelName)

    -- 宠物阶数
    self:setLabelText("SelectLabel", CHS[2000132], self:getControl("SelectPanel", Const.UIPanel, panelName))

    -- 取消选中标志
    self:setCtrlVisible("ChosenEffectImage", false, panelName)
end

-- 刷新宠物列表
function PetFuseDlg:refreshPetList()
    local otherPets = {}
    if self.selectPets then
        for _, v in pairs(self.selectPets) do
            if PetMgr:getPetById(v) then
                otherPets[v] = v
            end
        end
    end

    self:initPetList(self.selectPet:queryBasicInt("id"), otherPets)
end

-- 刷新道具列表
function PetFuseDlg:refreshItemList()
    local otherItems = {}
    if self.selectPets then
        for _, v in pairs(self.selectPets) do
            if InventoryMgr:getItemByPos(v) then
                if otherItems[v] then
                    otherItems[v] = otherItems[v] + 1
                else
                    otherItems[v] = 1
                end
            end
        end
    end

    self:initItemList(self.selectPet:queryBasicInt("id"), otherItems)
end

function PetFuseDlg:refreshOtherItem(senderName)
    if not self.selectPets then return end
    local pos = self.selectPets[senderName]

    local item = InventoryMgr:getItemByPos(pos)
    if not item then return end

    local petImage = self:getControl("PetImage", Const.UIImage, senderName)
    local path = ResMgr:getItemIconPath(item.icon)
    petImage:setVisible(true)
    petImage:loadTexture(path)
    self:setItemImageSize("PetImage", senderName)

    self:setCtrlVisible("NoneImage", false, senderName)
    self:setCtrlVisible("PetImagePanel", true, senderName)
    self:setCtrlVisible("LogoImage", false, senderName)

    local tag = LOCATE_POSITION.LEFT_TOP * 999
    local numImg = petImage:getChildByTag(tag)
    if numImg then numImg:removeFromParent(true) end

    -- 宠物阶数
    self:setLabelText("SelectLabel", item.name, self:getControl("SelectPanel", Const.UIPanel, senderName))

    self:refreshRate()
end

function PetFuseDlg:refreshOtherPet(senderName)
    if not self.selectPets then return end
    local petId = self.selectPets[senderName]
    local pet = PetMgr:getPetById(petId)
    if not pet then return end

    -- 设置宠物头像
    local petImage = self:getControl("PetImage", Const.UIImage, senderName)
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:setVisible(true)
    petImage:loadTexture(path)
    self:setItemImageSize("PetImage", senderName)

    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setCtrlVisible("LogoImage", true, senderName)
    self:setImagePlist("LogoImage", polarPath, senderName)

    -- 设置宠物等级
    local level  = pet:queryBasicInt("level")
    self:setNumImgForPanel("PetImage", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 25, senderName)

    self:setCtrlVisible("NoneImage", false, senderName)
    self:setCtrlVisible("PetImagePanel", true, senderName)

    -- 宠物阶数
    self:setLabelText("SelectLabel", string.format(CHS[7001005], PetMgr:getMountRankStr(pet), gf:getPetRankDesc(pet)), self:getControl("SelectPanel", Const.UIPanel, senderName))

    self:refreshRate()
end

function PetFuseDlg:selectOtherPet(sender)
    self.curSelectSender = sender

    self:setCtrlVisible("AttriPanel", false, "FusePanel")
    self:setCtrlVisible("DeputyPanel", true, "FusePanel")

    for i = 1, 3 do
        local panelName = "HeadPanel" .. i
        self:setCtrlVisible("ChosenEffectImage", panelName == sender, panelName)
    end

    self.radioGroup:selectRadio(self.radioGroup:getSelectedRadioIndex() or 1)
end

function PetFuseDlg:doNextOtherPet()
    local cur = tonumber(string.match(self.curSelectSender, "HeadPanel(%d)"))
    local ctrlName
    local index = cur

    repeat
        index = (index + 1) % 3
        if 0 == index then index = 3 end
        ctrlName = string.format("HeadPanel%d", index)
    until index == cur or nil == self.selectPets[ctrlName]

    self:selectOtherPet(ctrlName)
end

function PetFuseDlg:onSelectOtherPets(senderName, petId)
    if not self.selectPets then self.selectPets = {} end
    self.selectPets[senderName] = petId
    self:refreshOtherPet(senderName)

    self:doNextOtherPet()
end

function PetFuseDlg:onSelectOtherItem(senderName, petId)
    if not self.selectPets then self.selectPets = {} end
    self.selectPets[senderName] = petId
    self:refreshOtherItem(senderName)

    self:doNextOtherPet()
end

-- 初始化道具
function PetFuseDlg:initItemList(mainPetId, otherItems)
    local list, size = self:resetListView("ItemListView", 0)

    local allItems = InventoryMgr:getPetConvertItems()

    table.sort(allItems, function(l, r)
        if l.name < r.name then return true end
        if r.name < l.name then return false end

        if 2 == l.gift and 2 ~= r.gift then return true end
        if 2 == r.gift and 2 ~= l.gift then return false end

        return l.gift < r.gift
    end)

    local items = {}

    local name, gift, key, pos
    local cnt = 0
    for i = 1, #allItems do
        pos = allItems[i].pos
        if not otherItems[pos] or allItems[i].amount > otherItems[pos] then
            local item = {}

            -- 复制数据
            for k, v in pairs(allItems[i]) do
                item[k] = v
            end

            item.amount = math.max(item.amount - (otherItems[pos] or 0))
            name = item.name
            gift = item.gift
            key = string.format("%s/%s", name, 2 == item.gift and tostring(gift) or tostring(0))
            if not items[key] then
                items[key] = {}
            end

            table.insert(items[key], item)
            cnt = cnt + 1
        end
    end

    if cnt <= 0 then
        self:setCtrlVisible("TextPanel", true, "ItemPanle")
        return
    end

    self:setCtrlVisible("TextPanel", false, "ItemPanle")

    if items[CHS[2100021]] then
        list:pushBackCustomItem(self:createItemItem(CHS[2100020], 12002, true, items[CHS[2100021]]))
    end

    if items[CHS[2100022]] then
        list:pushBackCustomItem(self:createItemItem(CHS[2100020], 12002, false, items[CHS[2100022]]))
    end

    if items[CHS[2100024]] then
        list:pushBackCustomItem(self:createItemItem(CHS[2100023], 12003, true, items[CHS[2100024]]))
    end

    if items[CHS[2100025]] then
        list:pushBackCustomItem(self:createItemItem(CHS[2100023], 12003, false, items[CHS[2100025]]))
    end

    if items[CHS[2100027]] then
        list:pushBackCustomItem(self:createItemItem(CHS[2100026], 12004, true, items[CHS[2100027]]))
    end

    if items[CHS[2100028]] then
        list:pushBackCustomItem(self:createItemItem(CHS[2100026], 12004, false, items[CHS[2100028]]))
    end
end

-- 创建道具项
function PetFuseDlg:createItemItem(name, icon, gift, items)
    local itemPanel = self.singleItemPanel:clone()
    self:setLabelText("NameLabel", name, itemPanel)

     local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onSelectOtherItem(self.curSelectSender, items[1].pos)
        end
    end
    itemPanel:addTouchEventListener(selectPet)

    local function showItemInfo(sender, eventType)
        -- 显示道具悬浮
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showBasicMessageDlg(name, rect)
    end

    local itemImage = self:getControl("GuardImage", Const.UIImage, itemPanel)
    local path = ResMgr:getItemIconPath(icon)
    itemImage:loadTexture(path)
    self:setItemImageSize("GuardImage", itemPanel)
    itemImage:addTouchEventListener(showItemInfo)

    local num = 0
    if items and #items > 0 then
        for i = 1, #items do
            num = num + items[i].amount
        end
    end
    self:setNumImgForPanel(itemImage, ART_FONT_COLOR.NORMAL_TEXT, num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)

    if gift then
        InventoryMgr:addLogoBinding(itemImage)
    end

    return itemPanel
end

-- 初始化宠物
function PetFuseDlg:initPetList(mainPetId, otherPets)
    local pets = {}

    local list, size = self:resetListView("PetListView", 0)

    local mount_type, capactiyLevel
    for k, v in pairs(PetMgr.pets) do
        mount_type = v:queryInt("mount_type")
        capactiyLevel = v:queryBasicInt("capacity_level")
        if k ~= mainPetId
            and (MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == mount_type or MOUNT_TYPE.MOUNT_TYPE_YULING ==  mount_type)
            and v:queryBasicInt("deadline") <= 0
            and capactiyLevel >= 2 and capactiyLevel <= 4
            and not otherPets[v:queryBasicInt("id")]
            then
            table.insert(pets, v)
        end
    end

    if #pets <= 0 then
        self:setCtrlVisible("TextPanel", true, "PetPanel")
        return
    end

    self:setCtrlVisible("TextPanel", false, "PetPanel")

    -- 排序
    table.sort(pets, function(l, r) return self:compareMountPet(l, r) end)

    if not pets or #pets <= 0 then
        self:setCtrlVisible("ConfirmButton", true)
        self:setCtrlVisible("SubmitButton", false)
        self:setCtrlVisible("NonePanel", true)
        self:setCtrlVisible("PetItemPanel", false, "PetInfoPanel")
        self:setCtrlVisible("InfoPanel_1", false, "PetInfoPanel")
        self:setCtrlVisible("InfoPanel_2", false, "PetInfoPanel")
    else
        self:setCtrlVisible("ConfirmButton", false)
        self:setCtrlVisible("SubmitButton", true)
        self:setCtrlVisible("NonePanel", false)
        self:setCtrlVisible("PetItemPanel", true, "PetInfoPanel")
        self:setCtrlVisible("InfoPanel_1", true, "PetInfoPanel")
        self:setCtrlVisible("InfoPanel_2", false, "PetInfoPanel")
    end

    for i, v in ipairs(pets) do
        -- 增加项
        list:pushBackCustomItem(self:createPetItem(v, false, otherPets))
    end
end

-- 创建宠物项
function PetFuseDlg:createPetItem(pet, select, otherPets)
    local pet_status = pet:queryInt("pet_status")
    local petPanel = self.singlePetPanel:clone()
    petPanel:setTag(pet:queryBasicInt("id"))
    local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then

            local curSelectPetId = sender.pet:queryBasicInt("id")

            local pet = PetMgr:getPetById(curSelectPetId)

            local nGodBookCount = pet:queryBasicInt('god_book_skill_count')
            if nGodBookCount and nGodBookCount >= 1 then
                gf:ShowSmallTips(CHS[2100029])
                return
            end

            if gf:isExpensive(pet, true) then
                gf:ShowSmallTips(CHS[2100030])
                return
            end

            local pet_status = pet:queryInt("pet_status")
            local petId = pet:queryBasicInt("id")
            if 1 == pet_status then
                gf:confirm(CHS[2000140], function()
                    gf:CmdToServer("CMD_SELECT_CURRENT_PET", {
                        id = petId,
                        pet_status = 0,
                    })
                end, function() end)
                return
            elseif 2 == pet_status then
                gf:confirm(CHS[2000141], function()
                    gf:CmdToServer("CMD_SELECT_CURRENT_PET", {
                        id = petId,
                        pet_status = 0,
                    })
                end, function() end)
                return
            elseif PetMgr:isRidePet(pet:queryBasicInt("id")) then
                gf:confirm(CHS[2000142], function()
                    gf:CmdToServer("CMD_SELECT_CURRENT_MOUNT", {pet_id = 0})
                end, function() end)
                return
            end

            local times = 0
            for _, v in ipairs(MORPH) do
                local fieldTimes = string.format("morph_%s_times", v)
                times = times + pet:queryBasicInt(fieldTimes)
            end

            local isMorphed = PetMgr:isMorphed(pet)
            local isDevelop = PetMgr:getPetDevelopLevel(pet) > 0
            local isHaveGodSkill = PetMgr:isHaveGodSkill(pet)
            local enchant = pet:queryBasicInt("enchant")
            local isEnchant = 1 == enchant or 2 == enchant

            local strs = {}
            if isMorphed then
                table.insert(strs, CHS[2100013])
            end

            if isDevelop then
                table.insert(strs, CHS[2100014])
            end

            if isEnchant then
                table.insert(strs, CHS[2100015])
            end

            if isHaveGodSkill then
                table.insert(strs, CHS[2100016])
            end

            if #strs > 0 then
                gf:confirm(string.format(CHS[2100018], table.concat(strs, CHS[2100019])), function()
                    self:onSelectOtherPets(self.curSelectSender, curSelectPetId)
                end, function() end)
            else
                self:onSelectOtherPets(self.curSelectSender, curSelectPetId)
            end
        end
    end
    petPanel:addTouchEventListener(selectPet)
    petPanel.pet = pet
    local petImage = self:getControl("GuardImage", Const.UIImage, petPanel)
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:loadTexture(path)
    self:setItemImageSize("GuardImage", petPanel)

    -- 宠物名字
    local mount_type = pet:queryInt("mount_type")
    local petNameLabel = self:getControl("NameLabel", Const.UILabel, petPanel)
    local petName = pet:getShowName()
    petName = petName .. "(" .. gf:getPetRankDesc(pet) .. ")"
    petNameLabel:setString(petName)

    -- 宠物等级
    local petLevel = pet:queryBasicInt("level")
    local levelStr = string.format("LV. %-2d   " .. CHS[6000532], petLevel, PetMgr:getMountRankStr(pet))
    local petLevelValueLabel = self:getControl("LevelLabel", Const.UILabel, petPanel)
    petLevelValueLabel:setString(levelStr)

    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("LogoImage", polarPath, petPanel)

    local statusImg = self:getControl("StatusImage", Const.UIImage, petPanel)
    statusImg:setVisible(false)

    if pet_status == 1 then
        -- 参战
        statusImg:setVisible(true)
        petNameLabel:setColor(COLOR3.GREEN)
        petLevelValueLabel:setColor(COLOR3.GREEN)
        statusImg:loadTexture(ResMgr.ui.canzhan_flag)

    elseif pet_status == 2 then
        -- 掠阵
        petNameLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        if 1 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            statusImg:loadTexture(ResMgr.ui.gongtong_flag_new)
        else
            statusImg:loadTexture(ResMgr.ui.luezhen_flag)
        end
        statusImg:setVisible(true)
    elseif PetMgr:isRidePet(pet:getId()) then -- 骑乘状态
        statusImg:loadTexture(ResMgr.ui.ride_flag)

        if 2 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            statusImg:loadTexture(ResMgr.ui.gongtong_flag_new)
        end
        statusImg:setVisible(true)
    end

    self:bindListener("InfoButton", function(dlg, sender, eventType)
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet, true)
    end, petPanel)

    return petPanel
end

function PetFuseDlg:compareMountPet(l, r)
    -- 骑乘在最后
    if PetMgr:isRidePet(l:getId()) then return false end
    if PetMgr:isRidePet(r:getId()) then return true end

    -- 掠阵其次
    if 2 == l:queryInt("pet_status") then return false end
    if 2 == r:queryInt("pet_status") then return true end

    -- 掠阵其次
    if 1 == l:queryInt("pet_status") then return false end
    if 1 == r:queryInt("pet_status") then return true end

    -- 骑宠在前
    if PetMgr:isMountPet(l) and not PetMgr:isMountPet(r) then return true end
    if PetMgr:isMountPet(r) and not PetMgr:isMountPet(l) then return false end

    if self.otherPets then
        if self.otherPets[l:getId()] and not self.otherPets[r:getId()] then return false end
        if not self.otherPets[l:getId()] and self.otherPets[r:getId()] then return true end
    end

    if l:queryInt("capacity_level") > r:queryInt("capacity_level") then return false
    elseif l:queryInt("capacity_level") < r:queryInt("capacity_level") then return true
    end

    if l:queryInt("intimacy") > r:queryInt("intimacy") then return false
    elseif l:queryInt("intimacy") < r:queryInt("intimacy") then return true
    end

    local leftRawName = l:queryBasic("raw_name")
    local rightRawName = l:queryBasic("raw_name")
    local leftPetCft = PetMgr:getPetCfg(leftRawName)
    local rightPetCfg = PetMgr:getPetCfg(rightRawName)
    local leftOrder = leftPetCft.order or 0
    local rightOrder = rightPetCfg.order or 0
    if leftOrder < rightOrder then return true
    elseif leftOrder > rightOrder then return false
    end

    if l:queryInt("shape") > r:queryInt("shape") then return true
    elseif l:queryInt("shape") < r:queryInt("shape") then return false
    end

    if l:queryInt("level") > r:queryInt("level") then return true
    elseif l:queryInt("level") < r:queryInt("level") then return false
    end

    if l:getName() < r:getName() then
        return true
    else
        return false
    end
end

function PetFuseDlg:onBKPanel(sender, eventType)
    self:setCtrlVisible("AttriPanel", true, "FusePanel")
    self:setCtrlVisible("DeputyPanel", false, "FusePanel")
end

function PetFuseDlg:onFuseButton(sender, eventType)
    if not self.selectPet then return end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000133])
        return
    end

    local pets = {}
    local items = {}
    local pet
    local pet_status
    local ex -- 异常状态：参战、掠阵、骑乘
    local limit
    local itemIds = {}

    if self.selectPets then
        for _, v in pairs(self.selectPets) do
            pet = PetMgr:getPetById(v)
            if pet then
                pet_status = pet:queryBasicInt('pet_status')
                if not isException then
                    if 1 == pet_status then ex = 1
                    elseif 2 == pet_status then ex = 2
                    elseif PetMgr:isRidePet(v) then ex = 3
                    end
                end
                if not limit and PetMgr:isTimeLimitedPet(pet) then
                    limit = true
                end
                table.insert(pets, pet:queryBasicInt("no"))
            else
                local item = InventoryMgr:getItemByPos(v)
                if item then
                    table.insert(items, v)
                    table.insert(itemIds, item.item_unique)
                end
            end
        end
    end

    if #pets + #items < 3 then
        gf:ShowSmallTips(CHS[2000134])
        return
    end

    local mount_type = self.selectPet:queryInt("mount_type")
    if mount_type ~= MOUNT_TYPE.MOUNT_TYPE_YULING and mount_type ~= MOUNT_TYPE.MOUNT_TYPE_JINGGUAI then
        gf:ShowSmallTips(CHS[2000146])
        DlgMgr:closeDlg(self.name)
        return
    end

    local rawCapactiyLevel = PetMgr:getMountRawRank(self.selectPet)
    local capacityLevel = self.selectPet:queryBasicInt("capacity_level")
    if (rawCapactiyLevel < 5 and capacityLevel >= 5) or (rawCapactiyLevel >= 5 and capacityLevel >= rawCapactiyLevel + 1) then
        gf:ShowSmallTips(CHS[2000147])
        DlgMgr:closeDlg(self.name)
        return
    end

    if PetMgr:isTimeLimitedPet(self.selectPet) then
        gf:ShowSmallTips(CHS[2000148])
        DlgMgr:closeDlg(self.name)
        return
    end

    if ex then
        if 1 == ex then
            gf:ShowSmallTips(CHS[2000149])
        elseif 2 == ex then
            gf:ShowSmallTips(CHS[2000150])
        elseif 3 == ex then
            gf:ShowSmallTips(CHS[2000151])
        end
        DlgMgr:closeDlg(self.name)
        return
    end


    if limit then
        gf:ShowSmallTips(CHS[2000152])
        DlgMgr:closeDlg(self.name)
        return
    end

    -- 安全锁
    if self:checkSafeLockRelease("onFuseButton", sender, eventType) then return end

    PetMgr:doPetFuse(self.selectPet:queryBasicInt("id"), pets, items, itemIds, self.itemUseCount, self:isUseLimitedItem())
end

function PetFuseDlg:onConfirmButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function PetFuseDlg:onMaterialImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[2000128], rect)
end

function PetFuseDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PetFuseRuleDlg")
end

function PetFuseDlg:onReduceButton()
    if self.itemUseCount <= 1 then gf:ShowSmallTips(CHS[2000135]) return end
    self:insertNumber(self.itemUseCount - 1)
end

function PetFuseDlg:onAddButton()
    local itemName = CHS[2000128]
    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, self:isUseLimitedItem())
    if self.itemUseCount >= 3 then gf:ShowSmallTips(CHS[2000136]) return end
    self:insertNumber(self.itemUseCount + 1)
end

function PetFuseDlg:onBindCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    self:setItemInfo("MaterialPanel")
end

function PetFuseDlg:onDeputyCheck(sender, eventType)
    local senderName = sender:getName()
    if 'CheckBox_1' == senderName then
        self:setCtrlVisible('PetPanel', true, 'DeputyPanel')
        self:setCtrlVisible('ItemPanle', false, 'DeputyPanel')

        self:refreshPetList()
    elseif 'CheckBox_2' == senderName then
        self:setCtrlVisible('PetPanel', false, 'DeputyPanel')
        self:setCtrlVisible('ItemPanle', true, 'DeputyPanel')

        self:refreshItemList()
    end
end

function PetFuseDlg:MSG_QUERY_MOUNT_MERGE_RATE(data)
    if self.selectPet then
        local rawCapactiyLevel = PetMgr:getMountRawRank(self.selectPet)
        local capacityLevel = self.selectPet:queryBasicInt("capacity_level")
        if rawCapactiyLevel >= 2 and rawCapactiyLevel <= 4 and capacityLevel >= 5 then return end
        if rawCapactiyLevel >= 5 and capacityLevel >= rawCapactiyLevel + 1 then return end
    end
    self:setLabelText("RateNumLabel", string.format(CHS[2000137], data.rate / 10000), "MainPetPanel")
end

function PetFuseDlg:MSG_PREVIEW_MOUNT_ATTRIB(data)
    self:setPetFuseInfo(self.selectPet, data)
end

function PetFuseDlg:MSG_GENERAL_NOTIFY(data)
    local notify = data.notify
    if NOTIFY.NOTIFY_MOUNT_MERGE_RESULT ~= notify then return end

    -- 重置界面
    self.selectPets = nil
    self:setLabelText("RateNumLabel", CHS[2000138], "MainPetPanel")
    self:setPetInfo(self.selectPet)
    self:setItemInfo("MaterialPanel")
    self:resetOtherPets()
    self:onBKPanel()
end

function PetFuseDlg:MSG_INVENTORY(data)
    self:setItemInfo("MaterialPanel")
end

function PetFuseDlg:MSG_SET_CURRENT_PET(data)
    self:refreshPetList()
end

function PetFuseDlg:MSG_SET_CURRENT_MOUNT(data)
    self:refreshPetList()
end

return PetFuseDlg
