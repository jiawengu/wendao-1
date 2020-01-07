-- PetHorseTameDlg.lua
-- Created by yangym Oct/27/2016
-- 驯化精怪界面

local PetHorseTameDlg = Singleton("PetHorseTameDlg", Dialog)

-- 驯化精怪所需道具列表
local ITEM_LIST = {
    CHS[6000508],    -- 拘首环
    CHS[6000512],    -- 控心玉
    CHS[6000511],    -- 定鞍石
    CHS[6000510],    -- 驱力刺
    CHS[6000509],    -- 困灵砂
}

function PetHorseTameDlg:init()
    self:bindListener("BindCheckBox", self.onCheckBox)
    self:bindListener("TameButton", self.onSubmitButton)

    self.selectPet = nil

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end

    self:setBasicInfo()

    self:hookMsg("MSG_INVENTORY")
end

function PetHorseTameDlg:MSG_INVENTORY(data)
    self:updateItemAmount()
end

function PetHorseTameDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    self:updateItemAmount()
end

function PetHorseTameDlg:setSelectPet(pet)
    self.selectPet = pet
end

function PetHorseTameDlg:setBasicInfo()
    -- 加号绑定事件
    local petIconPanel = self:getControl("PetIconPanel")
    petIconPanel:setTouchEnabled(true)
    local function petListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local dlg = DlgMgr:openDlg("SubmitPetDlg")
            local pets = PetMgr:getOrderPets()
            local mountPets = {}
            for i = 1, #pets do
                if MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == pets[i]:queryInt("mount_type") then
                    table.insert(mountPets, pets[i])
                end
            end

            dlg:setSubmintPet(mountPets, "jingguai")
        end
    end

    petIconPanel:addTouchEventListener(petListener)

    -- 初始化各物品图像、点击事件绑定
    for i = 1, #ITEM_LIST do
        local imagePath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(ITEM_LIST[i]))
        self:setImage("ItemImage", imagePath, "ItemPanel" .. tostring(i))
        self:setItemImageSize("ItemImage", "ItemPanel" .. tostring(i))

        local item = InventoryMgr:getItemInfoByName(ITEM_LIST[i])
        item.name = ITEM_LIST[i]
        local function itemListener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local dlg = DlgMgr:openDlg("ItemInfoDlg")
                local rect = self:getBoundingBoxInWorldSpace(sender)
                dlg:setInfoFormCard(item)
                dlg:setFloatingFramePos(rect)
            end
        end

        self:getControl("ItemPanel" .. tostring(i)):addTouchEventListener(itemListener)
    end

    -- 设置物品个数相关信息
    self:updateItemAmount()
end

function PetHorseTameDlg:updateItemAmount()
    local isLimit = self:isCheck("BindCheckBox")
    for i = 1, #ITEM_LIST do
        local num = InventoryMgr:getAmountByNameIsForeverBind(ITEM_LIST[i], self:isCheck("BindCheckBox"))

        if 0 == num then
            self:setLabelText("NumLabel1", "0", "ItemPanel" .. tostring(i), COLOR3.RED)
        elseif 999 < num then
            self:setLabelText("NumLabel1", "*", "ItemPanel" .. tostring(i), COLOR3.WHITE)
        elseif 999 >= num then
            self:setLabelText("NumLabel1", num, "ItemPanel" .. tostring(i), COLOR3.WHITE)
        end
    end
end

function PetHorseTameDlg:refreshBasicInfo(pet)
    self.selectPet = pet

    -- 初始化精怪头像
    local portrait = self.selectPet:queryBasicInt("portrait")
    self:setImage("PetImage", ResMgr:getSmallPortrait(portrait), "PetIconPanel")
    self:setItemImageSize("PetImage", "PetIconPanel")

    local level = self.selectPet:queryBasicInt("level")
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false,
        LOCATE_POSITION.CENTER, 19, "PetIconPanel")

    self:getControl("AddImage", nil, "PetIconPanel"):setVisible(false)

    -- 更新属性预览

    -- 精怪名字
    self:setLabelText("PetNameLabel", self.selectPet:queryBasic("name"), "PetNamePanel")

    -- 速度（直接使用精怪阶位）
    local speed = self.selectPet:queryInt("capacity_level")
    self:setLabelText("MoveSpeedValueLabel", string.format(CHS[3003355], speed), nil)

    local ride_attrib = self.selectPet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)

    -- 主人攻击
    local phy_power = ride_attrib.phy_power
    self:setLabelText("PhyValueLabel", "+" .. phy_power, nil)

    -- 主人法攻
    local mag_power = ride_attrib.mag_power
    self:setLabelText("MagValueLabel", "+" .. mag_power, nil)

    -- 主人防御
    local def = ride_attrib.def
    self:setLabelText("DefenceValueLabel", "+" .. def, nil)

    -- 主人所有属性
    local all_attribute = ride_attrib.all_attrib
    self:setLabelText("AllAttriValueLabel", "+" .. all_attribute, nil)
end

function PetHorseTameDlg:onSubmitButton()

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002470])
        return
    end

    if not self.selectPet then
        gf:ShowSmallTips(CHS[7000098])
        return
    end

    if PetMgr:isPetTimeOut(self.selectPet) then
        gf:ShowSmallTips(CHS[7000099])
        self:close()
        return
    end

    -- 若要驯化限时的精怪，会给出提示
    if PetMgr:isTimeLimitedPet(self.selectPet) then
        gf:confirm(CHS[7000097], function()
            self:useItem()
        end)
    else
        self:useItem()
    end
end

function PetHorseTameDlg:useItem()
    -- 道具是否充足
    for i = 1, #ITEM_LIST do
        local num = InventoryMgr:getAmountByNameIsForeverBind(ITEM_LIST[i], self:isCheck("BindCheckBox"))
        if num == 0 then
            gf:askUserWhetherBuyItem(ITEM_LIST[i])
            return
        end
    end

    -- 安全锁
    if self:checkSafeLockRelease("useItem") then
        return
    end

    local countDays = 0
    local data = {}

    data.petNum = 1
    data.itemNum = #ITEM_LIST

    data.petList = {}
    data.petList[1] = self.selectPet:queryBasicInt("id")

    data.itemList = {}
    for i = 1, #ITEM_LIST do
        local item = InventoryMgr:getPriorityUseInventoryByName(ITEM_LIST[i], self:isCheck("BindCheckBox"))
        if InventoryMgr:isLimitedItemForever(item) then
            countDays = countDays + 10
        end

        data.itemList[i] = item.item_unique
    end

    -- 如果使用了永久限制交易道具，且宠物不是永久限制交易的，则会弹出确认框
    if countDays == 0 or PetMgr:isLimitedForeverPet(self.selectPet) then
        gf:CmdToServer("CMD_SUBMIT_MULTI_ITEM",data)
        self:close()
    else
        gf:confirm(string.format(CHS[3004113], countDays), function()
            gf:CmdToServer("CMD_SUBMIT_MULTI_ITEM",data)
            self:close()
        end)
    end
end

return PetHorseTameDlg
