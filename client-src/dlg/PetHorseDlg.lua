-- PetHorseDlg.lua
-- Created by zhengjh Sep/28/2016
-- 坐骑界面

local PetHorseDlg = Singleton("PetHorseDlg", Dialog)
local DELAY_TIME = 1
local PRICE = 1766

local JINGYAN_DAN = {
    [1] = CHS[3001111],
    [2] = CHS[4200404],
}

local PET_ATTRIB_LIST = require(ResMgr:getCfgPath('PetAttribList.lua'))
local PET_ATTRIB_LIST_TEST = require(ResMgr:getCfgPath('PetAttribListTest.lua'))
local MOUNT_PET_EVERY_SPEED_LEVEL = 5

function PetHorseDlg:init()
    self:bindListener("ChangeButton", self.onChangeButton)
    self:bindListener("RenameButton", self.onRenameButton)
    self:bindListener("AddFenglingButton", self.onAddFenglingButton)
    self:blindLongPress("LockExp", self.onLockExpButtonLong, self.onLockExpButton)
    self:blindLongPress("UnlockExp", self.onLockExpButtonLong, self.onLockExpButton)
    self:bindListener("TameButton", self.onTameButton)
    self:bindListener("MixButton", self.onMixButton)
    self:bindListener("GoldRefillPanel", self.onGoldRefillPanel)
    self:bindListener("HideButton", self.onHideButton)
    self:bindListener("SeeButton", self.onSeeButton)
    self:bindListener("PhoenixButton", self.onPhoenixButton)
    self:bindListener("PetFunctionButton", self.onPetFunctionButton)
    self:bindListener("RuleButton", self.onRuleButton, "TipsPanel")

    self:bindListener("ShapePanel1", self.onShowCWJYDButton)
    self:bindListener("ShapePanel2", self.onShowGJCWJYDButton)

    DlgMgr:sendMsg("PetListChildDlg", "cleanSelectPetNo")

    -- 使用宠物经验丹相关
    local addExpPanel = self:getControl("AddExpPanel")
    local nomorPanel = self:getControl("UsePanel1", nil, addExpPanel)
    nomorPanel:setTag(1)
    self:bindPressForIntervalCallback('ReduceButton', 0.15, self.onSubOrAddNum, 'times', nomorPanel)
    self:bindPressForIntervalCallback('AddButton', 0.15, self.onSubOrAddNum, 'times', nomorPanel)

    local heightPanel = self:getControl("UsePanel2", nil, addExpPanel)
    heightPanel:setTag(2)
    self:bindPressForIntervalCallback('ReduceButton', 0.15, self.onSubOrAddNum, 'times', heightPanel)
    self:bindPressForIntervalCallback('AddButton', 0.15, self.onSubOrAddNum, 'times', heightPanel)

    self:bindListener("ConfirmButton", self.onConfirmButton, "AddExpPanel")
    self.useNumber1 = 0
    self.useNumber2 = 0
    self.clickNum = 0
    self.isAdd = 1

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.PETATTRIB, function()
        self:setCtrlVisible("PetFunctionPanel", false)
        ShareMgr:share(SHARE_FLAG.PETATTRIB)
    end)

    -- 补充经验
    self:bindListener("AddExpButton", function(dlg, sender, eventType)
        if not self.selectPet then return end

        if Me:queryInt("level") < 40 then
            gf:ShowSmallTips(CHS[4200409])
            return
        end

        self:showFastUsePanel("AddExpPanel")
    end)

    -- 购买所需元宝数量
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, PRICE, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "GoldRefillPanel")
    self:getControl("NumPanel", nil, "GoldRefillPanel"):setVisible(true)

    self:bindPanelEvent("AddExpPanel")

    self:bindListener("LimitedCheckBox", self.onLimitedCheckBox)

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("LimitedCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("LimitedCheckBox", false)
    end

    -- 忽略风灵丸的标记
    self.isIgnorChaojiTips = false

    -- 绑定属性悬浮框
    self:bindShowTipsByName("LevelPanel", "PetAttribPanel1")
    self:bindShowTipsByName("LevelPanel", "PetAttribPanel2")
    self:bindShowTipsByName("MoveSpeedPanel", "PetAttribPanel1")
    self:bindShowTipsByName("PhyPanel", "PetAttribPanel1")
    self:bindShowTipsByName("MagPanel", "PetAttribPanel1")
    self:bindShowTipsByName("DefencePanel", "PetAttribPanel1")
    self:bindShowTipsByName("AllAttriPanel", "PetAttribPanel1")
    self:bindShowTipsByName("FenglingTimePanel", "PetAttribPanel1")
    self:bindShowTipsByName("XianPanel", "PetAttribPanel1")
    self:bindShowTipsByName("MoPanel", "PetAttribPanel1")

    -- 绑定数字键盘
    self:bindNumInput("UsePanel1","AddExpPanel", nil, 1)
    self:bindNumInput("UsePanel2","AddExpPanel", self.isMeetPetLevel, 2)

    local pet = DlgMgr:sendMsg("PetListChildDlg","getCurrentPet")
    self:setPetInfo(pet)

    self:hookMsg("MSG_HIDE_MOUNT")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_UPDATE_APPEARANCE")
    self:hookMsg("MSG_INVENTORY")

    EventDispatcher:addEventListener("EVENT_DO_DRAG", self.onTouch, self)

    DlgMgr:sendMsg("PetListChildDlg", "refreshList")
end

function PetHorseDlg:onDlgOpened(list, dlgParam)
    if not list or #list <= 0 then return end
    local op = list[1]
    if 'useCFZH' == op then
        performWithDelay(self.root, function()
            self:onUseCFZH()
        end, 0)
    end
end

-- 使用彩凤之魂打开界面
-- 选中列表的第一只5阶以上的御灵
function PetHorseDlg:onUseCFZH()
    local list = DlgMgr:sendMsg("PetListChildDlg", "getControl", "PetListView")
    if not list then return end
    local items = list:getItems()
    for i, panel in pairs(items) do
        if panel.pet then
            if panel.pet:queryInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_YULING and panel.pet:queryInt("capacity_level") >= 5 then
                DlgMgr:sendMsg("PetListChildDlg", "selectPetId", panel.pet:getId())
                return
            end
        end
    end
end

function PetHorseDlg:isMeetPetLevel()
    if not self.selectPet then return true end
    if self.selectPet:queryInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200408])
        return true
    end
end

function PetHorseDlg:onShowCWJYDButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3001111], rect)
end

function PetHorseDlg:onShowGJCWJYDButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[4200404], rect)
end


function PetHorseDlg:cleanup()
    self.selectPet = nil

    DlgMgr:sendMsg("PetListChildDlg", "setSelectPet", 0)
    EventDispatcher:removeEventListener("EVENT_DO_DRAG", self.onTouch, self)
end

function PetHorseDlg:onLimitedCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
        gf:ShowSmallTips(CHS[6000525])
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    self:showFastUsePanel("AddFenglingPanel")
end

function PetHorseDlg:onSubOrAddNum(ctrlName, times, sender)

    if sender:getParent():getTag() == 2 and self.selectPet:getLevel() < 70 then
        gf:ShowSmallTips(CHS[4200408])
        return
    end

    if times == 1 then
        self.clickNum = self.clickNum  + 1  -- 点击次数，不包括长按
    elseif self.clickNum < 4 then
        self.clickNum = 0
    end

    if ctrlName == "AddButton" then
        if self.isAdd == 0 then
            self.clickNum = 1
            self.isAdd = 1
        end

        self:onAddButton(sender)
    elseif ctrlName == "ReduceButton" then
        if self.isAdd == 1 then
            self.clickNum = 1
            self.isAdd = 0
        end

        self:onReduceButton(sender)
    end

end

-- 点击减号按钮
function PetHorseDlg:onReduceButton(sender, eventType)
    if not self.selectPet then
        return
    end

    if not sender then return end
    local tag = sender:getParent():getTag()

    if self["useNumber" .. tag] <= 0 then
        return
    else
        self["useNumber" .. tag] = self["useNumber" .. tag] - 1
    end

    if self.clickNum == 3 then
        gf:ShowSmallTips(CHS[7000130])
        self.clickNum = 0
    end

    self:initAddExpFastUsePanel()
end

-- 点击加号按钮
function PetHorseDlg:onAddButton(sender, eventType)
    if not self.selectPet then
        return
    end

    if not sender then return end
    local tag = sender:getParent():getTag()

    local previewLevel, previewPercent = self:getPreviewLevelByUseNumber(self.useNumber1, self.useNumber2)
    if previewLevel >= self.selectPet:getMaxLevel() then
        gf:ShowSmallTips(CHS[7000132])
        return
    end

    if self["useNumber" .. tag] >= InventoryMgr:getAmountByNameIsForeverBind(JINGYAN_DAN[tag], true) then
        gf:ShowSmallTips(CHS[7000131])
        return
    else
        self["useNumber" .. tag] = self["useNumber" .. tag] + 1
    end

    if self.clickNum == 3 then
        gf:ShowSmallTips(CHS[7000130])
        self.clickNum = 0
    end

    self:initAddExpFastUsePanel()
end

-- 根据“宠物升级所需经验数值”、“宠物经验丹在宠物处于不同等级下的经验提升数值”配表，计算使用一定数量经验丹的预览等级
function PetHorseDlg:getPreviewLevelByUseNumber(useNumber, heightUseNumber)
    if not self.selectPet then
        return
    end

    local level = self.selectPet:queryBasicInt("level")
    local exp = self.selectPet:queryBasicInt("exp")
    local petAttribList

    -- 内测区组与公测区组使用不同的配表，因为升级经验有差异
    if DistMgr:curIsTestDist() then
        petAttribList = PET_ATTRIB_LIST_TEST
    else
        petAttribList = PET_ATTRIB_LIST
    end

    for i= 1, useNumber do
        exp = exp + petAttribList[level].jingyandan_exp
        while exp >= petAttribList[level].exp do
            exp = exp - petAttribList[level].exp
            level = level + 1
            if level > self.selectPet:getMaxLevel() then  -- 容错处理：防止取当前经验配表没有的数值而导致报错，非策划设定
                return level, 0
            end
        end
    end

    for i= 1, heightUseNumber do
        exp = exp + petAttribList[level].gaoji_jingyandan_exp
        while exp >= petAttribList[level].exp do
            exp = exp - petAttribList[level].exp
            level = level + 1
            if level > self.selectPet:getMaxLevel() then  -- 容错处理：防止取当前经验配表没有的数值而导致报错，非策划设定
                return level, 0
            end
        end
    end

    local expPercent = math.floor(exp / petAttribList[level].exp * 100)
    return level, expPercent
end

function PetHorseDlg:updateAddExpPanel()
    if not self.selectPet then
        return
    end

    -- 如果拥有经验丹数量为0或者宠物等级已经大于等于玩家等级，则经验丹使用数量置为0
    local amount = InventoryMgr:getAmountByNameIsForeverBind(CHS[3003330], true)
    if amount == 0 or self.selectPet:getLevel() >= self.selectPet:getMaxLevel() then
        self.useNumber = 0
    end

    local previewLevel, previewPercent = self:getPreviewLevelByUseNumber(self.useNumber)
    -- 更新使用数量
    self:setLabelText("NumLabel", tostring(self.useNumber), "AddExpPanel")

    -- 更新最大等级
    self:setLabelText("MaxLevelLabel_1", self.selectPet:getMaxLevel(), "AddExpPanel")

    -- 更新预览等级
    self:setLabelText("NowLevelLabel_1", string.format(CHS[7000133], previewLevel, previewPercent), "AddExpPanel")

    -- 更新宠物经验丹数量
    if amount == 0 then
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.RED, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "AddExpPanel")
    else
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "AddExpPanel")
    end
end

-- 设置宠物
function PetHorseDlg:setPetInfo(pet)
    self.selectPet = pet

    if not pet or not PetMgr:isMountPet(pet) then
        self:resetData()
        return
    end

    self:setCtrlOnlyEnabled("ShareButton", true)
    self:setCtrlVisible("TipsPanel", false)
    self:setCtrlVisible("HorseOperatePanel", true)
    self:setCtrlVisible("ExpPanel", true)
    self:setCtrlVisible("HorseShapePanel", true)

    self:setLabelText("NameLabel", pet:getShowName())

    -- 设置经验锁定
    local lock = self.selectPet:queryBasicInt("lock_exp")

    if lock == 0 then
        self:setCtrlVisible("UnlockExp", true)
        self:setCtrlVisible("LockExp", false)
    else
        self:setCtrlVisible("UnlockExp", false)
        self:setCtrlVisible("LockExp", true)
    end

    -- 设置经验
    local exp = pet:queryInt("exp")
    local exp_to_next_level = pet:queryInt("exp_to_next_level")
    local percent = exp / exp_to_next_level * 100
    local percent = math.floor(exp * 100 / exp_to_next_level)
    self:setLabelText("ExpValueLabel", string.format("%d/%d(%d%%)", exp, exp_to_next_level, percent))
    self:setLabelText("ExpValueLabel_1", string.format("%d/%d(%d%%)", exp, exp_to_next_level, percent))
    self:setProgressBar("ExpProgressBar", exp, exp_to_next_level)

    -- 宠物标志小图标
    self:setPetLogoPanel(pet)

    self:updatePetSoul(pet)

    -- 设置形象
    local icon = PetMgr:getYulingIcon(self.selectPet:getIcon(nil, nil, true))
    local petIcon = 0
    local weapon = 0
    local orgIcon = 0

    if PetMgr:petHasTopLayer(icon) then
        -- 上层模型按武器的方式加载，对应的编号为 1
        weapon = 1
        orgIcon = icon
    end

    self:setPortraitByArgList(
        {
            panelName = "IconPanel",
            icon = icon,
            weapon = weapon,
            root = self.root,
            showActionByClick = "walk",
            action = nil,
            clickCb = nil,
            offPos = cc.p(0, -36),
            orgIcon = orgIcon,
            syncLoad = nil,
            dir = nil,
            petIcon = petIcon,
        })
    self:setCtrlEnabled("IconPanel", true)

    -- 交易信息
    if PetMgr:isTimeLimitedPet(self.selectPet) then  -- 限时宠物
        local timeLimitStr = PetMgr:convertLimitTimeToStr(self.selectPet:queryBasicInt("deadline"))
        self:setLabelText("UntradeLabel", CHS[7000083])
        self:setLabelText("TimeLimitLabel", timeLimitStr)
    elseif PetMgr:isLimitedPet(self.selectPet) then  -- 限制交易宠物
        local limitDesr, day = gf:converToLimitedTimeDay(self.selectPet:queryInt("gift"))
        self:setLabelText("UntradeLabel", limitDesr)
        self:setLabelText("TimeLimitLabel", "")
    else
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
    end

    -- 精怪 御灵
    local mount_type = pet:queryInt("mount_type")

    if MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == mount_type then
        -- 精怪
        self:setCtrlVisible("PetAttribPanel1", false)
        self:setCtrlVisible("PetAttribPanel2", true)

        -- 驯化
        self:setLabelText("Label_1", CHS[6000523], "TameButton")
        self:setLabelText("Label", CHS[6000523], "TameButton")

        -- 能力阶位
        self:setLabelText("LevelValueLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(self.selectPet)), "PetAttribPanel2")
        self:setCtrlVisible("HideButton", false)
        self:setCtrlVisible("SeeButton", false)
        self:setCtrlVisible("InfoPanel", false, "HorseShapePanel")
    elseif MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type then
        -- 御灵
        self:setCtrlVisible("PetAttribPanel1", true)
        self:setCtrlVisible("PetAttribPanel2", false)
        self:setYulingAttrib()

        if PetMgr:isRidePet(self.selectPet:getId()) then -- 是骑乘
            -- 休息按钮
            self:setLabelText("Label_1", CHS[6000533], "TameButton")
            self:setLabelText("Label", CHS[6000533], "TameButton")
        else
            -- 骑乘按钮
            self:setLabelText("Label_1", CHS[6000534], "TameButton")
            self:setLabelText("Label", CHS[6000534], "TameButton")
        end

        local isHide = self.selectPet:queryInt("hide_mount")

        local icon = PetMgr:getYulingIcon(self.selectPet:getIcon(nil, nil, true))
        local petIcon = 0
        local weapon = 0
        local orgIcon = 0

        if PetMgr:petHasTopLayer(icon) then
            -- 上层模型按武器的方式加载，对应的编号为 1
            weapon = 1
            orgIcon = icon
        end

        if PetMgr:isRidePet(self.selectPet:getId()) then
            -- 只有骑乘了当前坐骑，才显示隐藏/显示坐骑的按钮
            if isHide == 1 then
                self:setCtrlVisible("HideButton", false)
                self:setCtrlVisible("SeeButton", true)
            else
                self:setCtrlVisible("HideButton", true)
                self:setCtrlVisible("SeeButton", false)
            end
        else
            self:setCtrlVisible("HideButton", false)
            self:setCtrlVisible("SeeButton", false)
        end

        -- 只要玩家骑乘了当前御灵，形象就会显示为当前玩家骑乘该御灵
        if PetMgr:isRidePet(self.selectPet:getId()) then
            if Me:getRideIcon() > 0 then
--                icon = Me:getIcon()
--                petIcon = Me:getRideIcon()
                local yulingIcon = icon
                icon = PetMgr:getMountIcon(Me:queryBasicInt("org_icon"), yulingIcon)
                petIcon = yulingIcon
            else
                local yulingIcon = icon
                icon = PetMgr:getMountIcon(Me:queryBasicInt("org_icon"), yulingIcon)
                petIcon = yulingIcon
            end

            weapon = 0
            orgIcon = 0
        end

        self:setPortraitByArgList(
            {
                panelName = "IconPanel",
                icon = icon,
                weapon = weapon,
                root = self.root,
                showActionByClick = "walk",
                action = nil,
                clickCb = nil,
                offPos = cc.p(0, -36),
                orgIcon = orgIcon,
                syncLoad = nil,
                dir = nil,
                petIcon = petIcon,
            })
    end

    -- 设置类型
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    self:updateFastUsePanel()

    -- 切换宠物时重置使用经验丹数量，并更新经验丹使用界面
    self.useNumber1 = 0
    self.useNumber2 = 0
    self:initAddExpFastUsePanel()
end

function PetHorseDlg:updatePetSoul(pet)
    local visible = pet:queryInt("capacity_level") >= 5
    self:setCtrlVisible("PhoenixButton", visible)
    self:setCtrlVisible("PhoenixImage", visible)
    self:setCtrlVisible("PhoenixBKImage", visible)
    if pet then
        self:setCtrlEnabled("PhoenixButton", PetMgr:isCFZHStatus(pet), nil, true, true)
    end
end

function PetHorseDlg:setYulingAttrib()
    -- 能力阶位
    self:setLabelText("LevelValueLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(self.selectPet)), "PetAttribPanel1")

    -- 风灵丸时间
    local day = PetMgr:getFenghuaDay(self.selectPet)
    local color = COLOR3.TEXT_DEFAULT

    if day == 0 then
        self:setLabelText("FenglingTimeValueLabel", string.format(CHS[34050], day), nil, COLOR3.RED)
        color = COLOR3.GRAY
    else
        self:setLabelText("FenglingTimeValueLabel", string.format(CHS[34050], day), nil, COLOR3.TEXT_DEFAULT)
    end

    if day < 5 then
        self:setCtrlVisible("InfoPanel", true, "HorseShapePanel")
    else
        self:setCtrlVisible("InfoPanel", false, "HorseShapePanel")
    end

    -- 移动速度
    -- 速度的级数和速度百分比是5倍关系
    local speed = math.floor(self.selectPet:queryInt("mount_attrib/move_speed") / MOUNT_PET_EVERY_SPEED_LEVEL)
    local capactityLevel = self.selectPet:queryInt("capacity_level")
    if speed == capactityLevel then
        self:setLabelText("MoveSpeedValueLabel", string.format(CHS[3003355], speed), nil, color)
    else
        self:setLabelText("MoveSpeedValueLabel", string.format(CHS[3003355], speed), nil, COLOR3.RED)
    end

    local ride_attrib = self.selectPet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
    if not ride_attrib or  type(ride_attrib) ~= 'table' then return end

    -- 主人攻击
    local phy_power = ride_attrib.phy_power
    self:setLabelText("PhyValueLabel", "+" .. phy_power, nil, color)

    -- 主人法攻
    local mag_power = ride_attrib.mag_power
    self:setLabelText("MagValueLabel", "+" .. mag_power, nil, color)

    -- 主人防御
    local def = ride_attrib.def
    self:setLabelText("DefenceValueLabel", "+" .. def, nil, color)

    -- 主任所有属性
    local all_attribute = ride_attrib.all_attrib
    self:setLabelText("AllAttriValueLabel", "+" .. all_attribute, nil, color)


    -- 主人仙魔点， 如果未完成飞升相关，则需要置灰
    if not Me:isFlyToXianMo() then
        color = COLOR3.GRAY
    end
    local xianPoint = ride_attrib.upgrade_immortal or 0
    self:setLabelText("XianValueLabel", "+" .. xianPoint, nil, color)
    local moPoint = ride_attrib.upgrade_magic or 0
    self:setLabelText("MoValueLabel", "+" .. moPoint, nil, color)

    self:updateLayout("LevelPanel")
    self:updateLayout("MoveSpeedPanel")
    self:updateLayout("PhyPanel")
    self:updateLayout("MagPanel")
    self:updateLayout("DefencePanel")
    self:updateLayout("AllAttriPanel")
    self:updateLayout("FenglingTimePanel")
end

function PetHorseDlg:onChangeButton(sender, eventType)
    PetMgr:changeMount(self.selectPet)
end

function PetHorseDlg:onRenameButton(sender, eventType)
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        return
    end

    if self.selectPet == nil then return end

    local dlg = DlgMgr:openDlg("RenamePetDlg")
    dlg:setPet(self.selectPet)

    self:setCtrlVisible("PetFunctionPanel", false)
end

function PetHorseDlg:onAddFenglingButton(sender, eventType)
    if not self.selectPet then return end

    -- 如果是限时宠物
    if PetMgr:isTimeLimitedPet(self.selectPet) then
        gf:ShowSmallTips(CHS[6000565])
        return
    end

    local speed = math.floor(self.selectPet:queryInt("mount_attrib/move_speed") / MOUNT_PET_EVERY_SPEED_LEVEL)
    if PetMgr:getFenghuaDay(self.selectPet) >= 94
        and speed >= PetMgr:getMountMaxRank(self.selectPet) then
        gf:ShowSmallTips(CHS[6000538])
        return
    end

    self:showFastUsePanel("AddFenglingPanel")
end

function PetHorseDlg:onLockExpButton(sender, eventType)
    if not self.selectPet then return end
    local lock = self.selectPet:queryBasicInt("lock_exp")
    if lock == 0 then
        local moneyStr = gf:getMoneyDesc(5000000)
        local confirmDlg = gf:confirm(string.format(CHS[3003342], Const.PLAYER_MAX_LEVEL, moneyStr),
            function()
                self:onLockExpConfirm()
            end)
        confirmDlg:setConfirmText(CHS[7000000])
    else
        self:onLockExpConfirm()
    end
end

function PetHorseDlg:onLockExpButtonLong(sender, eventType)
end

function PetHorseDlg:onLockExpConfirmCb1(money)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.selectPet:queryInt("level") >= Const.PLAYER_MAX_LEVEL then
        gf:ShowSmallTips(string.format(CHS[3003345], self.selectPet:queryBasic("name")))
        return
    end

    if Me:getVipType() == 0 then
        gf:ShowSmallTips(CHS[3003346])
        return
    end

    if PetMgr:isFeedStatus(self.selectPet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    end

    if gf:checkCostIsEnough(money) then
        -- 安全锁判断
        if self:checkSafeLockRelease("onLockExpConfirmCb1", money) then
            return
        end
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_LOCK_EXP, self.selectPet:queryBasicInt("id"), 1)
    end
end

function PetHorseDlg:onLockExpConfirmCb2(money)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if gf:checkCostIsEnough(money) then
        -- 安全锁判断
        if self:checkSafeLockRelease("onLockExpConfirmCb2", money) then
            return
        end

        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_LOCK_EXP, self.selectPet:queryBasicInt("id"), 0)
    end
end

function PetHorseDlg:onLockExpConfirm()
    if not self.selectPet then return end
    local lock = self.selectPet:queryBasicInt("lock_exp")
    local money = 0
    if lock == 0 then
        money = 5000000
        local moneyStr = gf:getMoneyDesc(money)
        gf:confirm(string.format(CHS[3003344], moneyStr), function()
        self:onLockExpConfirmCb1(money)
        end)
    else
        money = 3200000
        local moneyStr = gf:getMoneyDesc(money)
        gf:confirm(string.format(CHS[3003347], moneyStr), function()
            self:onLockExpConfirmCb2(money)
        end)
    end
end

function PetHorseDlg:setPetLogoPanel(pet)
    self:bindListener("PetLogoPanel", self.onPetLogoPanel)
    PetMgr:setPetLogo(self, pet)
end

function PetHorseDlg:onPetLogoPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("PetIdentificationDlg")
    dlg:setData(self.selectPet)
    local dlgSize = dlg.root:getContentSize()
    dlgSize.height = dlgSize.height * Const.UI_SCALE
    local posX = rect.x + rect.width - (50 * Const.UI_SCALE)
    local posY = rect.y - dlgSize.height
    dlg.root:setAnchorPoint(0,0)
    dlg:setPosition(cc.p(posX, posY))
end


function PetHorseDlg:checkCanUseItem(name)
    if not self.selectPet then return false end

    if name == CHS[3003330] then
        if Me:queryInt("level") < 40 then
            gf:ShowSmallTips(CHS[3003348])
            return false
        end

        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3003333])
            return false
        end

        if self.selectPet:queryInt("rank") == Const.PET_RANK_WILD then
            gf:ShowSmallTips(CHS[3003349])
            return false
        end

        if self.selectPet:queryInt("level") >= Me:queryInt("level") then
            gf:ShowSmallTips(CHS[3003350])
            return false
        end

        if self.selectPet:queryInt("level") >= self.selectPet:getMaxLevel() then
            -- 若玩家喂养宠物超过当前宠物可达到的最高等级
            gf:ShowSmallTips(CHS[5000269])
            return false
        end

        if self.useNumber1 == 0 and self.useNumber2 == 0 then
            gf:ShowSmallTips(CHS[7000134])
            return false
        end

        if self.selectPet:queryBasicInt("lock_exp") ~= 0 then
            gf:ShowSmallTips(CHS[3003351])
            return false
        end

        return true
    elseif name == CHS[6000522] then -- 风灵丸

        -- 如果是限时宠物
        if PetMgr:isTimeLimitedPet(self.selectPet) then
            gf:ShowSmallTips(CHS[6000565])
            return false
        end

        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return false
        end

        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3003333])
            return false
        end

        return true
    end

    return false
end


function PetHorseDlg:feedPetByIsLimitItem(name, pet, para, para2, isUseLimitItem)
    gf:CmdToServer("CMD_APPLY_CHONGWU_JINGYANDAN", { no = pet:queryBasicInt("no"), num1 = tonumber(para), num2 = tonumber(para2)})
end

-- 宠物经验丹使用
function PetHorseDlg:onConfirmButton()
    if not self.selectPet then
        return
    end

    local itemName = CHS[3003330]  -- 宠物经验丹
    if self:checkCanUseItem(itemName) then

        -- 批量使用宠物经验丹
        self:feedPetByIsLimitItem(itemName, self.selectPet, tostring(self.useNumber1), tostring(self.useNumber2), true)

        self.useNumber1 = 0
        self.useNumber2 = 0
        self:initAddExpFastUsePanel()
    end
end

-- 更新单条悬浮框
function PetHorseDlg:updateOneFastUsePanel(panel, itemName, key)
    if not self.selectPet then
        return
    end

    local isUseLimited = false
    if self:isCheck("LimitedCheckBox", panel) or string.match(itemName, CHS[3003330]) then
        isUseLimited = true
    else
        isUseLimited = false
    end

    local tempPanel = self:getControl(key, Const.UIPanel, panel)
    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
    self:setCtrlVisible("NumPanel", true, tempPanel)

    if amount == 0 then
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.RED, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, tempPanel)
    else
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, tempPanel)
    end

    --[[
    if itemName == CHS[3003330] then
        self:setLabelText("DescLabel", "+" .. math.floor(Formula:getDayExp(self.selectPet:queryInt("level")) / 20) .. CHS[3003332], tempPanel)
    end
    --]]

    return isUseLimited
end

function PetHorseDlg:checkLimitedTip()
    if self.curItemName == CHS[6000522] then
        if self.curIsUseLimited and not self.isIgnorFenglingwan then
            self.isIgnorFenglingwan = true
        end
    end
end

function PetHorseDlg:onUpdate(dt)
    if self.isLongPress then
        -- todo
        if not self.curDelay then
            self.curDelay = 0
        end

        self.curDelay = self.curDelay + (1 / Const.FPS)

        if self.curDelay >= DELAY_TIME then
            self.curDelay = self.curDelay - DELAY_TIME
            if self:checkCanUseItem(self.curItemName) then
                local item = InventoryMgr:getPriorityUseInventoryByName(self.curItemName, self.curIsUseLimited)
                if not item then
                    self:needItemOperate(self.curItemName)
                    return
                end

                local pos = item.pos

                local itemTemp = InventoryMgr:getItemByPos(pos)

                -- 安全锁判断
                if SafeLockMgr:isToBeRelease(itemTemp) then
                    return
                end

                local isNeedShow = true

                if self.curItemName == CHS[6000522] then
                    if self.curIsUseLimited and not self.isIgnorFenglingwan then

                    else
                        isNeedShow = false
                    end
                else
                    isNeedShow = false
                end

                if isNeedShow then
                    InventoryMgr:feedPetByIsLimitItem(self.curItemName, self.selectPet, "", self.curIsUseLimited)
                else
                    local items = InventoryMgr:getItemByName(self.curItemName, not self.curIsUseLimited)
                    gf:CmdToServer("CMD_FEED_PET", { no = self.selectPet:queryBasicInt("no"), pos = item.pos, para = ""})
                end
            else
                self:closeFastUsePanel()
                self.isLongPress = false
            end

        end

    end
end

function PetHorseDlg:needItemOperate(itemName)
    if itemName == CHS[6000522] then -- 风灵丸
        gf:askUserWhetherBuyItem(itemName)
    elseif itemName == CHS[3003330] then
        gf:ShowSmallTips(CHS[3003354])
    end
end

function PetHorseDlg:bindPanelEvent(name)
    local panel = self:getControl(name, Const.UIPanel)
    if not panel then return end

    local function checkVisible()
        local node3 = self:getControl("AddExpPanel", Const.UIPanel)
        local node1 = self:getControl("AddFenglingPanel")

        if node1:isVisible() then
            return node1
        end

        if node3:isVisible() then
            return node3
        end

        return nil
    end

    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d, name:%s", touchPos.x, touchPos.y, event:getCurrentTarget():getName())
        local panel = checkVisible()

        if not panel or not panel:isVisible() then
            return false
        end

        touchPos = panel:getParent():convertToNodeSpace(touchPos)
        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        self:closeFastUsePanel()
        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        return true
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function PetHorseDlg:closeFastUsePanel()
    self:setCtrlVisible("AddFenglingPanel", false)
    self:setCtrlVisible("AddExpPanel", false)
    if self.curTempPanel then
        self:setCtrlVisible("ChosenEffectImage", false, self.curTempPanel)
    end

    self.useNumber = 1
    self.useNumber2 = 1
    self.curTempPanel = nil
end

function PetHorseDlg:updateFastUsePanel()
    self:updateOneFastUsePanel("AddFenglingPanel", CHS[6000522], "UseFenglingPanel")
    self:updateOneFastUsePanel("AddExpPanel", CHS[3003330], "AddExpPanel")
end

function PetHorseDlg:initAddExpFastUsePanel()
    local items = {["ShapePanel1"] = CHS[3003330], ["ShapePanel2"] = CHS[4200404]}
    if not self.selectPet then return end
    local panel = self:getControl("AddExpPanel", Const.UIPanel)

    local isUseLimited = false
    for key, itemName in pairs(items) do
    isUseLimited = self:updateOneFastUsePanel(panel, itemName, key)

        -- 设置img
        local tempPanel = self:getControl(key, Const.UIPanel, panel)
        self:setImage("GuardImage", InventoryMgr:getIconFileByName(itemName), tempPanel)
        self:setItemImageSize("GuardImage", tempPanel)
        self:setLabelText("NameLabel", itemName, tempPanel)
        self:setCtrlVisible("ChosenEffectImage", false, tempPanel)

        local numPanel = {[CHS[3003330]] = 1, [CHS[4200404]] = 2}
        local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, true)
        if amount == 0 or self.selectPet:getLevel() >= self.selectPet:getMaxLevel() or self.selectPet:getLevel() >= Me:getLevel() then
        self["useNumber" .. numPanel[itemName]] = 0
            end

        if itemName == CHS[4200404] and self.selectPet:getLevel() < 70 then
        self.useNumber2 = 0
            end

        -- 更新使用数量
        local numberPanel = self:getControl("UsePanel" .. numPanel[itemName], nil, panel)
        self:setLabelText("NumLabel",  self["useNumber" .. numPanel[itemName]], numberPanel)

        local previewLevel, previewPercent = self:getPreviewLevelByUseNumber(self.useNumber1, self.useNumber2)


        -- 更新最大等级
        self:setLabelText("MaxLevelLabel_1", self.selectPet:getMaxLevel(), panel)

        -- 更新预览等级
        self:setLabelText("NowLevelLabel_1", string.format(CHS[7000133], previewLevel, previewPercent), panel)

    end
end

function PetHorseDlg:initFastUsePanel(itemNames, addPanelName)
    if not self.selectPet then return end
    local panel = self:getControl(addPanelName, Const.UIPanel)
    local items = {}
    local isUseLimited = false

    self.curTempPanel = nil

    for key, itemName in pairs(itemNames) do
        isUseLimited = self:updateOneFastUsePanel(panel, itemName, key)

        -- 设置img
        local tempPanel = self:getControl(key, Const.UIPanel, panel)
        self:setImage("GuardImage", InventoryMgr:getIconFileByName(itemName), tempPanel)
        self:setItemImageSize("GuardImage", tempPanel)
        self:setLabelText("NameLabel", itemName, tempPanel)
        self:setCtrlVisible("ChosenEffectImage", false, tempPanel)

        -- 宠物经验丹
        if itemName == CHS[3003330] then
            self:updateAddExpPanel()
            break
        end

        self:blindLongPress(key,
            function(dlg, sender, eventTye)
                -- 取消上次选中
                if self.curTempPanel and self.curTempPanel ~= tempPanel then
                    self:setCtrlVisible("ChosenEffectImage", false, self.curTempPanel)
                end

                self.curDelay = 0
                self.isLongPress = true
                self.curItemName = itemName
                self.curIsUseLimited = isUseLimited
                self.curTempPanel = tempPanel
                self:setCtrlVisible("ChosenEffectImage", true, self.curTempPanel)
            end,

            function(dlg, sender, eventType)
                if self.isLongPress then
                    self.isLongPress = false
                    return
                end

                if not sender:getParent():isVisible() then
                    return
                end

                if self.curTempPanel and self.curTempPanel ~= tempPanel then
                    self:setCtrlVisible("ChosenEffectImage", false, self.curTempPanel)
                end

                self.curTempPanel = tempPanel
                self:setCtrlVisible("ChosenEffectImage", true, tempPanel)
                if self:checkCanUseItem(itemName) then
                    local pos = InventoryMgr:getItemPosByName(itemName)
                    InventoryMgr:feedPetByIsLimitItem(itemName, self.selectPet, "", isUseLimited)
                else
                    self:closeFastUsePanel()
                    self.isLongPress = false
                end
            end,
            panel, true, function ()
                self.isLongPress = false
            end)
    end
end

function PetHorseDlg:showFastUsePanel(name)
    self:setCtrlVisible("AddFenglingPanel", false)
    self:setCtrlVisible("AddExpPanel", false)


    self:setCtrlVisible(name, true)
    if name == "AddFenglingPanel" then
        self:initFastUsePanel({["UseFenglingPanel"]= CHS[6000522]}, "AddFenglingPanel")
    elseif name == "AddExpPanel" then
        self:initAddExpFastUsePanel()
        --self:initFastUsePanel({["AddExpPanel"] = CHS[3003330]}, "AddExpPanel")
    end
end

-- 元宝补充
function PetHorseDlg:onGoldRefillPanel(sender, evventType)
    if not self.selectPet then return end

    if self.curTempPanel and self.curTempPanel ~= sender then
        self:setCtrlVisible("ChosenEffectImage", false, self.curTempPanel)
    end

    self.curTempPanel = sender
    self:setCtrlVisible("ChosenEffectImage", true, sender)

    -- 如果是限时宠物
    if PetMgr:isTimeLimitedPet(self.selectPet) then
        gf:ShowSmallTips(CHS[6000565])
        self:closeFastUsePanel()
        return false
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        self:closeFastUsePanel()
        return false
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        self:closeFastUsePanel()
        return false
    end

    if PetMgr:getFenghuaDay(self.selectPet) >= 5 then
        gf:ShowSmallTips(CHS[6000557])
        return true
    end

    local dlg = DlgMgr:openDlg("PetHorseBuyFenglingDlg")
    dlg:setPetNo(self.selectPet:queryInt("no"))
end

function PetHorseDlg:onTameButton(sender, eventType)
    local effect = sender:getChildByTag(ResMgr.magic.yuhua_btn)
    if effect then
        effect:removeFromParent()
        effect = nil
    end

    if not self.selectPet then return end

    local mount_type = self.selectPet:queryInt("mount_type")

    if MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == mount_type then
        -- 精怪
        gf:confirm(CHS[6000524], function ()
            local dest = gf:findDest(CHS[6000517])
            DlgMgr:closeDlg(self.name)
            AutoWalkMgr:beginAutoWalk(dest)
        end)
    elseif MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type then
        -- 御灵

        if PetMgr:isRidePet(self.selectPet:getId()) then -- 是骑乘
            if Me:isInCombat() then
                gf:ShowSmallTips(CHS[3003333])
                return false
            end

            gf:CmdToServer("CMD_SELECT_CURRENT_MOUNT", {pet_id = 0})

        else
            if Me:isInCombat() then
                gf:ShowSmallTips(CHS[3003333])
                return false
            end

            local pet_status = self.selectPet:queryInt("pet_status")

            if pet_status == 1 then
                -- 参战
                gf:ShowSmallTips(CHS[6000535])
                return
            elseif pet_status == 2 then
                -- 掠阵
                gf:ShowSmallTips(CHS[6000536])
                return
            end

            local limitLevel = 15
            if self.selectPet:queryInt("level") > Me:queryInt("level") + limitLevel then
                gf:ShowSmallTips(string.format(CHS[6000537], limitLevel))
                return
            end

            gf:CmdToServer("CMD_SELECT_CURRENT_MOUNT", {pet_id = self.selectPet:getId()})
        end
    end
end

-- 绑定提示框
function PetHorseDlg:bindShowTipsByName(ctrlName, root)
    local panel = self:getControl(ctrlName, Const.UIPanel, root)

    panel:addTouchEventListener(function(sender, eventType)

            if eventType == ccui.TouchEventType.began then
                local name = sender:getName()
                local tips = nil
                if name == "LevelPanel" then
                    tips = CHS[2000161]
                elseif name == "MoveSpeedPanel" then
                    tips = CHS[6000539]
                elseif name == "PhyPanel" then
                    tips = CHS[6000540]
                elseif name == "MagPanel" then
                    tips = CHS[6000541]
                elseif name == "DefencePanel" then
                    tips = CHS[6000542]
                elseif name == "AllAttriPanel" then
                    tips = CHS[6000543]
                elseif name == "FenglingTimePanel" then
                    tips = CHS[7001018]
                elseif name == "XianPanel" then
                    tips = CHS[4100899]
                elseif name == "MoPanel" then
                    tips = CHS[4100900]
                end

                if tips then
                    gf:showTipInfo(tips, sender)
                end

                self:getControl("TouchImage", Const.UIImage, sender):setVisible(true)
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.canceled then
                self:getControl("TouchImage", Const.UIImage, sender):setVisible(false)
            elseif eventType == ccui.TouchEventType.ended then
                self:getControl("TouchImage", Const.UIImage, sender):setVisible(false)
            end

    end)
end

function PetHorseDlg:resetData()
    self:setCtrlVisible("PetAttribPanel1", false)
    self:setCtrlVisible("PetAttribPanel2", false)
    self:getControl("IconPanel"):removeAllChildren()
    self:getControl("PetLogoPanel"):removeAllChildren()
    self:setCtrlEnabled("IconPanel", false)
    self:setCtrlOnlyEnabled("ShareButton", false)
    self:setLabelText("PetPolarLabel", "")
    self:setCtrlVisible("HideButton", false)
    self:setCtrlVisible("SeeButton", false)
    self:setCtrlVisible("SuffixImage", false)
    self:setLabelText("ExpValueLabel", "")
    self:setLabelText("ExpValueLabel_1", "")
    self:setProgressBar("ExpProgressBar", 0, 1)
    self:setLabelText("NameLabel", "")
    self:setCtrlVisible("UnlockExp", true)
    self:setCtrlVisible("LockExp", false)
    self:setCtrlVisible("PhoenixButton", false)
    self:setCtrlVisible("PhoenixImage", false)
    self:setCtrlVisible("PhoenixBKImage", false)

    self:setCtrlVisible("HorseOperatePanel", false)
    self:setCtrlVisible("ExpPanel", false)
    self:setCtrlVisible("HorseShapePanel", false)
    self:setCtrlVisible("TipsPanel", true)

    self:updateLayout("ExpPanel")
end

function PetHorseDlg:onHideButton()
    if not self.selectPet then return end
    gf:CmdToServer("CMD_HIDE_MOUNT", {petId = self.selectPet:getId(), isHide = 1})
end

function PetHorseDlg:onSeeButton()
    if not self.selectPet then return end
    gf:CmdToServer("CMD_HIDE_MOUNT", {petId = self.selectPet:getId(), isHide = 0})
end

function PetHorseDlg:onPhoenixButton(sender)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[2500067], rect, false, { petId = self.selectPet:getId()})
end

function PetHorseDlg:onPetFunctionButton(sender, eventType)
    local panel = self:getControl("PetFunctionPanel")
    panel:setVisible(not panel:isVisible())
end

function PetHorseDlg:onRuleButton(sender)
    DlgMgr:openDlg("PetHorseTipsDlg")
end

function PetHorseDlg:onTouch(eventCode)
    local panel = self:getControl("PetFunctionPanel")
    if not panel:isVisible() then return end
    if eventCode == cc.EventCode.BEGAN then
        local touchPos = GameMgr.curTouchPos
        local rect = self:getBoundingBoxInWorldSpace(panel)
        if not cc.rectContainsPoint(rect, touchPos) then
            panel:setVisible(false)
        end
    end
end

function PetHorseDlg:MSG_HIDE_MOUNT(data)
    if not self.selectPet or self.selectPet:getId() ~= data.petId then return end
    if PetMgr:isRidePet(self.selectPet:getId()) then
        if data.isHide == 1 then
            self:setCtrlVisible("HideButton", false)
            self:setCtrlVisible("SeeButton", true)
        else
            self:setCtrlVisible("HideButton", true)
            self:setCtrlVisible("SeeButton", false)
        end
    else
        self:setCtrlVisible("HideButton", false)
        self:setCtrlVisible("SeeButton", false)
    end
end

function PetHorseDlg:MSG_UPDATE_PETS(data)
    if not self.selectPet then
        return
    end

    if data.id == self.selectPet:queryBasicInt('id') and 0 == pet:queryBasicInt('no') then
        -- 移除宠物
        self.selectPet = nil
    end

    self:updateFastUsePanel()
    self:updatePetSoul(self.selectPet)
end

function PetHorseDlg:MSG_UPDATE_APPEARANCE(data)
    self:setPetInfo(self.selectPet)
end

-- 更新
function PetHorseDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    if self.curTempPanel and data[1].name == CHS[6000522] then
        self:updateFastUsePanel()
    end
end

function PetHorseDlg:onMixButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.selectPet then
        return
    end

        -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 显示宠物，给出提示
    if self.selectPet and PetMgr:isTimeLimitedPet(self.selectPet) then
        gf:ShowSmallTips(CHS[2000145])
        return
    end

    local dlg = DlgMgr:openDlg("PetFuseDlg")
    if dlg then
        dlg:setPetInfo(self.selectPet)
    end
end

function PetHorseDlg:getMaxUseNumber(key)
    if not self.selectPet then
        return
    end

    local level = self.selectPet:queryBasicInt("level")
    local maxLevel = self.selectPet:getMaxLevel()
    local exp = self.selectPet:queryBasicInt("exp")
    local petAttribList
    local canUseNumber = InventoryMgr:getAmountByNameIsForeverBind(JINGYAN_DAN[key], true) or 0

    if level >= maxLevel then return 0 end

    -- 内测区组与公测区组使用不同的配表，因为升级经验有差异
    if DistMgr:curIsTestDist() then
        petAttribList = PET_ATTRIB_LIST_TEST
    else
        petAttribList = PET_ATTRIB_LIST
    end

    if key ~= 2 then
    for i= 1, canUseNumber do
        exp = exp + petAttribList[level].jingyandan_exp
        while exp >= petAttribList[level].exp do
            exp = exp - petAttribList[level].exp
            level = level + 1
            if level >= maxLevel then
                return i
            end
        end
    end
    else
        for i= 1, canUseNumber do
            exp = exp + petAttribList[level].gaoji_jingyandan_exp
            while exp >= petAttribList[level].exp do
                exp = exp - petAttribList[level].exp
                level = level + 1
                if level >= maxLevel then
                    return i
                end
            end
        end
    end

    return canUseNumber
end

-- 数字键盘插入数字
function PetHorseDlg:insertNumber(num, key)
    local count = num

    if count < 0 then
        count = 0
    end

    local maxUseNumber = self:getMaxUseNumber(key) or 0

    if maxUseNumber < count then
        if maxUseNumber == InventoryMgr:getAmountByNameIsForeverBind(JINGYAN_DAN[key], true) then
            gf:ShowSmallTips(CHS[5420007])
        else
            gf:ShowSmallTips(CHS[5420008])
        end

        count = maxUseNumber
    end

    self["useNumber" .. key] = count
    self:initAddExpFastUsePanel()

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(count)
    end
end

function PetHorseDlg:addTameButtonMagic()
    local btn = self:getControl("TameButton")
    local effect = btn:getChildByTag(ResMgr.magic.yuhua_btn)
    if not effect then
        local effect = gf:createLoopMagic(ResMgr.magic.yuhua_btn, nil, {blendMode = "add"})
        effect:setScale(0.96, 1.04)
        effect:setAnchorPoint(0.5, 0.5)
        effect:setPosition(btn:getContentSize().width / 2,btn:getContentSize().height / 2)
        btn:addChild(effect, 1, ResMgr.magic.yuhua_btn)
    end
end

return PetHorseDlg
