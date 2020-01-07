-- PetDressDlg.lua
-- Created by songcw Dec/05/2018
-- 宠物时装

local PetDressDlg = Singleton("PetDressDlg", Dialog)


-- 最低亲密要求
local MIN_INTIMACY = 500000

local PRICE = 5000000

-- ListView 间隔
local MAGIN = 6

function PetDressDlg:init()
    self:bindListener("ShowOpenButton", self.onShowOpenButton)
    self:bindListener("ShowCloseButton", self.onShowCloseButton)
    self:bindListener("TurnRightButton", self.onTurnRightButton)
    self:bindListener("TurnLeftButton", self.onTurnLeftButton)
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListViewListener("ShowListView", self.onSelectShowListView)

  --  self:bindFloatPanelListener("RulePanel")
    self:setCtrlEnabled("UseButton", false)

    local panel = self:getControl("DownPanel")
    self:setCtrlVisible("NameLabel", false, panel)
    self:setCtrlVisible("TimeLabel", false, panel)

    -- 右侧列表控件
    self.choseImage = self:retainCtrl("ChoseImage", nil, "PetItemPanel")
    self.showPanel = self:retainCtrl("ShowPanel_1", nil, self:getControl("ShowListView"))



    self.pet = DlgMgr:sendMsg("PetAttribDlg", "getCurrentPet")
    if not self.pet then self:onCloseButton() end
    self:refreshItemInfo()
    self:refreshShowButton()

    self.dir = 5
    self.icon = self.pet:getDlgIcon()
    self.lastChangeShowStateTime = 0


    self:setLabelText("NameLabel", self.pet:getShowName(), "NamePanel")

    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_FASION_CUSTOM_LIST")
    self:hookMsg("MSG_PET_ICON_UPDATED")
    self:hookMsg("MSG_SET_OWNER")

    self:MSG_FASION_CUSTOM_LIST()
end

function PetDressDlg:onUpdate()

    if self.dirtyListView then
        self.dirtyListView = nil
        self:refreshListView()
    end

    if self.dirtyIcon then
        self.dirtyIcon = nil
   --     self:resetIcon()
    end

    if self.dirtyCommonPanel then
        self.dirtyCommonPanel = nil
        self:refreshCommonPanel()
    end
end

-- 刷新道具列表
function PetDressDlg:refreshListView(isRefresh)
    local data1 = InventoryMgr:getPetDressData('fasion_store', Me:queryBasicInt("gender"), nil, 1)
    local data2 = InventoryMgr:getPetDressData('fasion_store', Me:queryBasicInt("gender") == 1 and 2 or 1, nil, 1)

    local data = {}
    for _, info in pairs(data1) do
        if not string.match(info.name, CHS[4010286]) then
            table.insert( data,  info)
        end
    end

    for _, info in pairs(data2) do
        if not string.match(info.name, CHS[4010286]) then
            table.insert( data,  info)
        end
    end

    local panel = self:getControl("DownPanel")
    self:setCtrlVisible("NameLabel", true, panel)
    self:setCtrlVisible("TimeLabel", true, panel)

    if isRefresh then
        local list = self:getControl("ShowListView")
        local items = list:getItems()
        for i, panel in pairs(items) do
            self:setPanelData(panel, data, (i - 1) * 4 + 1)
        end
    else
        self:refreshItemInfo()
        local defSelectIndex = 0
        if #data == 0 then

        else
            local list = self:resetListView("ShowListView", MAGIN)
            local line = math.floor((#data - 1) / 4) + 1

            line = math.max( 4,  line)

            local panel
            for i = 1, line do
                panel = self.showPanel:clone()
                if self:setPanelData(panel, data, (i - 1) * 4 + 1) then
                    defSelectIndex = i
                end
                list:pushBackCustomItem(panel)
            end
        end

        if defSelectIndex ~= 0 then
            performWithDelay(self.root, function ()
                    self:setListInnerPosByIndex("ShowListView", defSelectIndex)
            end, 0)
        end


    end

    self:setCtrlVisible("ShowListView", #data ~= 0)
    self:setCtrlVisible("EmptyPanel", #data == 0)
end

-- 设置道具列表单行道具数据
function PetDressDlg:setPanelData(panel, data, start)
    local item
    local isDefSelect
    for i = 1, 4 do
        item = self:getControl("ItemPanel_" .. tostring(i), nil, panel)
        if self:setItemData(item, data[start + i - 1], i) then
            isDefSelect = true
        end
    end

    return isDefSelect
end

-- 设置道具列表道具数据
function PetDressDlg:setItemData(item, data, tag)
    self:setCtrlVisible("ItemImage", nil ~= data, item)
    self:setCtrlVisible("NoImage", nil ~= data and (not data.amount or data.amount <= 0), item)

    self:setCtrlVisible("OwnImage", false, item)
    self:setCtrlVisible("UseImage", false, item)

    local isDefSelect = false

    if data then
        -- 存在道具数据
        self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), item)
        gf:setItemImageSize(self:getControl("ItemImage", nil, item))

        item:setTag(tag)
       -- item:setName(data.name)
        item.name = data.name
        item.data = data

        self:setImagePlist("BKImage", ResMgr.ui.bag_item_bg_img, item)

        local icon = InventoryMgr:getFashionShapeIcon(data.name)
        local petFasionInfo = self:getOtherFasionInfo()
        if petFasionInfo[icon] then
            if petFasionInfo[icon] == self.pet:queryBasicInt("no")  then
            self:setCtrlVisible("OwnImage", true, item)

            else
                self:setCtrlVisible("UseImage", true, item)
            end
        end

        if not self.choseImage:getParent() and self.pet:queryBasicInt("fasion_id") ~= 0 and self.pet:queryBasicInt("fasion_id") == icon then
            self:onClickItemPanel(item)
            self:refreshItemInfo(data)
            isDefSelect = true
        end

    else
        self:setImagePlist("BKImage", ResMgr.ui.bag_no_item_bg_img, item)

    end

    -- 绑定事件
    self:bindTouchEndEventListener(item, self.onClickItemPanel)

    return isDefSelect
end

function PetDressDlg:onClickItemPanel(sender)
    local data = sender.data
    if not data then return end
    local panel = self:getControl("DownPanel")
    self:setCtrlVisible("NameLabel", true, panel)
    self:setCtrlVisible("TimeLabel", true, panel)
    if self.choseImage:getParent() == sender then
        -- 取消选择
        self.choseImage:removeFromParent()

        self:resetIcon()
        self:refreshCommonPanel()
        self:refreshItemInfo()
    else
        -- 选中新道具(可能是空格)
        self.choseImage:removeFromParent()
        sender:addChild(self.choseImage)

        self.dir = 5

        local itemName = sender.name
        if data then
            self:resetIcon(itemName)
            self:refreshCommonPanel()
        end
        self:refreshItemInfo(data)
    end
end

-- 重置图标
-- 重置为身上穿戴的装备的形象
function PetDressDlg:resetIcon(itemName)
    self.icon = InventoryMgr:getFashionShapeIcon(itemName)
end


-- 刷新道具信息，主要指右侧选中按钮后的效果
function PetDressDlg:refreshItemInfo(data)
    local panel = self:getControl("DownPanel")

    if not data then
        local text = self.pet:queryBasicInt("fasion_id") ~= 0 and CHS[4010287] or CHS[4010288]
        self:setUseButton(text, false)

        self:setLabelText("NameLabel", CHS[2100191], panel)
        self:setLabelText("TimeLabel", "", panel)
        self:setCtrlVisible("PricePanel", false, panel)
        self:setCtrlVisible("TimePanel", true, panel)
    else
        local itemName = string.isNilOrEmpty(data.alias) and data.name or data.alias
        local icon = InventoryMgr:getFashionShapeIcon(data.name)
        local text = self.pet:queryBasicInt("fasion_id") == icon and CHS[4010287] or CHS[4010288]

        if string.match(data.name, CHS[2100209]) then
            itemName = CHS[2100209]
        end

        if data.amount and data.amount > 0 then
            self:setLabelText("TimeLabel", InventoryMgr:isTimeLimitedItem(data) and string.format(CHS[2100192], gf:getServerDate('%Y-%m-%d %H:%M', data.deadline)) or CHS[2100183], panel)
            self:setCtrlVisible("PricePanel", false, panel)
            self:setCtrlVisible("TimePanel", true, panel)
            self:setUseButton(text, true)
        else
            self:setUseButton(text, false)
        end
        self:setLabelText("NameLabel", itemName, panel)
    end
end

-- 设置使用按钮文本及状态
function PetDressDlg:setUseButton(name, abled)
    self:setLabelText("Label_1", name, "UseButton")
    self:setLabelText("Label_2", name, "UseButton")
    self:setCtrlEnabled("UseButton", abled)
end

-- 形象右转
function PetDressDlg:onTurnRightButton()
    self.dir = self.dir - 2
    if self.dir < 0 then
        self.dir = 7
    end

    self:refreshCommonPanel()
end

-- 形象左转
function PetDressDlg:onTurnLeftButton()
    self.dir = self.dir + 2
    if self.dir > 7 then
        self.dir = 1
    end

    self:refreshCommonPanel()
end

function PetDressDlg:getFasionIconByPet(pet)
    if pet:queryBasicInt("fasion_id") ~= 0 then
        return pet:queryBasicInt("fasion_id")
    end

    return pet:queryBasicInt("icon")
end


function PetDressDlg:refreshCommonPanel()
    local argList = {
        panelName = "UserPanel",
        icon = self.icon or self.pet:getDlgIcon(),
        weapon = 0,
        root = nil,
        action = nil,
        clickCb = nil,
        offPos = nil,
        orgIcon = nil,
        syncLoad = nil,
        dir = self.dir,
        pTag = nil,
        extend = nil,
        partIndex = nil,
        partColorIndex = nil,
    }

    self:setPortraitByArgList(argList)
end

function PetDressDlg:getBHTips(data)
    local tips1 = string.format( CHS[4010277], gf:getMoneyDesc(PRICE), self.pet:getShowName())
    local petFasionInfo = self:getOtherFasionInfo()
    local icon = InventoryMgr:getFashionShapeIcon(data.name)


    local tips2 = ""
    for _, pet in pairs(PetMgr.pets) do
        if pet:queryBasicInt("fasion_id") ~= 0 and pet:queryBasicInt("fasion_id") == icon and petFasionInfo[icon] then
            local oPet = PetMgr:getPetByNo(petFasionInfo[icon])
            if not oPet then return "" end
            tips2 = string.format( CHS[4010278], oPet:getShowName())
        end
    end

    local tips3 = ""
    if self.pet:queryBasicInt("fasion_id") ~= 0 and self.pet:queryBasicInt("fasion_id") ~= icon then
        if tips2 == "" then
            tips3 = string.format(CHS[4010279], InventoryMgr:getFashionShapeIcon(self.pet:queryBasicInt("fasion_id")))
        else
            tips3 = "，" .. string.format(CHS[4010280], InventoryMgr:getFashionShapeIcon(self.pet:queryBasicInt("fasion_id")))
        end
    end

    local tips4 = CHS[4010281]

    local tips = tips1 .. tips2 .. tips3 .. tips4
    return tips
end

function PetDressDlg:configStep(step, data)
    local petFasionInfo = self:getOtherFasionInfo()
    local icon = InventoryMgr:getFashionShapeIcon(data.name)
    if step == 1 then
        for _, pet in pairs(PetMgr.pets) do
            if pet:queryBasicInt("fasion_id") ~= 0 and pet:queryBasicInt("fasion_id") == icon and petFasionInfo[icon] then
                local oPet = PetMgr:getPetByNo(petFasionInfo[icon])
                if not oPet then return "" end
                local tips = string.format(CHS[4010282], oPet:getShowName())
                gf:confirm(tips, function ()
                    self:configStep(2, data)
                end, nil, nil, nil, nil, nil, nil, "PetDressTabDlg")
                return
            end
        end

        self:configStep(2, data)
        return
    elseif step == 2 then
        if self.pet:queryBasicInt("fasion_id") ~= 0 and self.pet:queryBasicInt("fasion_id") ~= icon then
            local tips = string.format(CHS[4010283], InventoryMgr:getFashionShapeIcon(self.pet:queryBasicInt("fasion_id")))
            gf:confirm(tips, function ()
                self:configStep(3, data)
            end, nil, nil, nil, nil, nil, nil, "PetDressTabDlg")
            return
        end

        self:configStep(3, data)
        return
    elseif step == 3 then
        local tips = string.format(CHS[4010284], gf:getMoneyDesc(PRICE), self.pet:getShowName())
        gf:confirm(tips, function ()
            self:configStep(4, data)
        end, nil, nil, nil, nil, nil, nil, "PetDressTabDlg")
        return
    elseif step == 4 then
            gf:CmdToServer("CMD_UPGRADE_PET", {
                type = "pet_fasion",
                no = self.pet:queryBasicInt("no"),
                other_pet = "",
                cost_type = tostring(data.pos),
                ids = ""
            })
    end
end

-- 变化人形
function PetDressDlg:onBHRXButton(data)

    local intimacy = self.pet:queryInt("intimacy")
    if intimacy < MIN_INTIMACY then
        gf:ShowSmallTips(CHS[4010272])
        return
    end

    -- 战斗中不可进行此操作。
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[4000223])
        return
    end

    -- 当前宠物为限时宠物，不可进行此操作。
    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[4010269])
        return
    end

    -- 当前宠物为#R野生宠物#n，不可进行此操作。
    if self.pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4010270])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBHRXButton", data) then
        return
    end

    self:configStep(1, data)

end

function PetDressDlg:onUseButton(sender, eventType)
    local item = self.choseImage:getParent()
    if not item then return end

    if self:getLabelText("Label_1", sender) == CHS[4010287] then
        -- 战斗中不可进行此操作。
        if GameMgr.inCombat then
            gf:ShowSmallTips(CHS[4000223])
            return
        end

        -- 解除变幻
        gf:confirm(CHS[4101306], function ()
            gf:CmdToServer("CMD_UPGRADE_PET", {
                type = "pet_fasion",
                no = self.pet:queryBasicInt("no"),
                other_pet = "",
                cost_type = tostring(0),
                ids = ""
            })
        end)
    else
        self:onBHRXButton(item.data)
    end
end

function PetDressDlg:refreshShowButton()
    local isShow = false
    if self.pet then
        isShow = true
    end

    if not isShow or self.pet:queryBasicInt("fasion_id") == 0 then
        self:setCtrlVisible("ShowOpenButton", false)
        self:setCtrlVisible("ShowCloseButton", false)
        return
    end

    self:setCtrlVisible("ShowOpenButton", self.pet:queryBasicInt("fasion_visible") ~= 0)
    self:setCtrlVisible("ShowCloseButton", self.pet:queryBasicInt("fasion_visible") == 0)
end


function PetDressDlg:onShowOpenButton(sender, eventType)

    if gfGetTickCount() - self.lastChangeShowStateTime <= 5000 then
        gf:ShowSmallTips(CHS[4100573])
        return
    end

    self.lastChangeShowStateTime = gfGetTickCount()

    gf:CmdToServer("CMD_SET_PET_FASION_VISIBLE", {
        no = self.pet:queryBasicInt("no"),
        visible = 0,
    })
end

function PetDressDlg:onShowCloseButton(sender, eventType)

    if gfGetTickCount() - self.lastChangeShowStateTime <= 5000 then
        gf:ShowSmallTips(CHS[4100573])
        return
    end

    self.lastChangeShowStateTime = gfGetTickCount()

    gf:CmdToServer("CMD_SET_PET_FASION_VISIBLE", {
        no = self.pet:queryBasicInt("no"),
        visible = 1,
    })
end



function PetDressDlg:onRuleButton(sender, eventType)

    self:setCtrlVisible("RulePanel", true)
end

function PetDressDlg:onSelectShowListView(sender, eventType)
end

function PetDressDlg:MSG_FASION_CUSTOM_LIST(data)
    self.dirtyListView = true
    self.dirtyIcon = true
    self.dirtyCommonPanel = true
end

function PetDressDlg:MSG_STORE(data)
            self.dirtyListView = true
            self.dirtyIcon = true
            self.dirtyCommonPanel = true
      --      self.dirtyEffectButton = true
end

function PetDressDlg:getOtherFasionInfo()
    local ret = {}
    for _, pet in pairs(PetMgr.pets) do
        if pet:queryBasicInt("fasion_id") ~= 0 then
            ret[pet:queryBasicInt("fasion_id")] = pet:queryBasicInt("no")
        end
    end

    return ret
end

function PetDressDlg:MSG_PET_ICON_UPDATED(data)

        self.dirtyIcon = true
        self.dirtyCommonPanel = true

        self.pet = DlgMgr:sendMsg("PetAttribDlg", "getCurrentPet")
        if not self.pet then self:onCloseButton() end
        self:setLabelText("NameLabel", self.pet:getShowName(), "NamePanel")

        self:refreshListView(true)
        --self:MSG_PET_ICON_UPDATED()

        if "unequip_fasion" == data.action then
            -- 解除变幻
            if self.choseImage:getParent() then
                self:onClickItemPanel(self.choseImage:getParent())
            end
        elseif "equip_fasion" == data.action then

            if self.choseImage:getParent() then
                self.icon = nil
                self:refreshItemInfo(self.choseImage:getParent().data)
            end
        elseif "pet_fasion_visible" == data.action then
            if self.choseImage:getParent() then
                self.icon = InventoryMgr:getFashionShapeIcon(self.choseImage:getParent().name)
                self:refreshItemInfo(self.choseImage:getParent().data)
            end
        end

        self:refreshShowButton()
end


function PetDressDlg:MSG_SET_OWNER(data)
    if not self.pet then self:onCloseButton() end
    local ownerId = data.owner_id
    if ownerId < 0 then
        self:onCloseButton()
        return
    end

    local id = data.id
    if id < 0 then
        self:onCloseButton()
        return
    end

    if (0 == ownerId or ownerId ~= Me:getId()) and id == self.pet:getId() then
        self:onCloseButton()
        return
    end

end

function PetDressDlg:MSG_OPERATE_RESULT(data)
    if data.flag == 1 and data.opType == "jiecbhrx" then

        if self.choseImage:getParent() then
            self.icon = InventoryMgr:getFashionShapeIcon(self.choseImage:getParent().name)
        else
            self.icon = self.pet:getDlgIcon()
        end


        self:MSG_PET_ICON_UPDATED()
        self:refreshItemInfo()
    end
end


return PetDressDlg
