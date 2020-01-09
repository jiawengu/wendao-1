-- EquipmentUpgradeDlg.lua
-- Created by songcw Feb/4/2015
-- 装备改造

local UPGRADE_LEVEL_MAX = 12

local EquipmentUpgradeDlg = Singleton("EquipmentUpgradeDlg", Dialog)

function EquipmentUpgradeDlg:init()
    self:bindListener("CloseButton ", self.onCloseButton)
    self:bindListener("Upgrade5Button", self.onUpgrade5Button)
    self:bindListener("UpgradeButton", self.onUpgradeButton)
    self:bindListener("CostImage", self.onMaterial)

    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("MaxButton", self.onMaxButton)
    self:bindListener("CostImagePanel", self.onItemImage)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("InheritButton", self.onInheritButton)
    self:bindCheckBoxListener("BindCheckBox", self.onCheckBox)

    self:bindListener("GuideButton", self.onGuideButton)
    self:setCtrlVisible("GuideButton", EquipmentMgr:isShowGuideButton(self.name))

    -- 暂时屏蔽共鸣属性
    if DistMgr:needIgnoreGongming() then
        self:setCtrlVisible("Upgrade5Button", false)
        self:setLabelText("Label1", CHS[7120053], "GongmingButton")
        self:setLabelText("Label2", CHS[7120053], "GongmingButton")
        self:bindListener("GongmingButton", self.onUpgrade5Button)
    else
        self:setCtrlVisible("Upgrade5Button", true)
        self:bindListener("Upgrade5Button", self.onUpgrade5Button)
        self:bindListener("GongmingButton", self.onGongmingButton)
    end

    -- 初值化相应的列表
    EquipmentMgr:setTabList("EquipmentUpgradeDlg")

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_PRE_UPGRADE_EQUIP")

    self:hookMsg("MSG_GENERAL_NOTIFY")

    local node = self:getControl("BindCheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end
    self:onCheckBox(node, 2)
end

function EquipmentUpgradeDlg:onGuideButton()
    DlgMgr:openDlg("EquipReformGuideDlg")
end

function EquipmentUpgradeDlg:getSelectItemBox(clickItem)
    if clickItem == "BindCheckBox" then
        if self:isCheck("BindCheckBox") then
            return
        else
            return self:getBoundingBoxInWorldSpace(self:getControl("BindCheckBox"))
        end
    end
end

function EquipmentUpgradeDlg:initEquipInfo(equip)
    if self.pos ~= equip.pos  or not self.useItemNum then
        if equip.rebuild_level < 3 then
            self.useItemNum = 1
        else
            self.useItemNum = 2
        end
    end

    self.pos = equip.pos
    local color = InventoryMgr:getEquipmentNameColor(equip)
    local suit = EquipmentMgr:getEquipPolarChs(equip.suit_polar)
    if not suit then suit = "" else suit = "(" .. suit .. ")" end
    self:setLabelText("EquipmentNameLabel", equip.name .. suit, self.root, color)
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon))
    self:setItemImageSize("EquipmentImage")
    self:setUseItmeInfo()

    -- 装备悬浮框
    local equipImage = self:getControl("EquipmentImage")
    self:bindTouchEndEventListener(equipImage, self.showEquipmentInfo, equip.pos )

    self:updateLayout("EquipmentUpgradePanel")
end

function EquipmentUpgradeDlg:showEquipmentInfo(sender, eventType, pos)
    if not self.pos then return end
    local equipImage = self:getControl("EquipmentImage")
    local rect = self:getBoundingBoxInWorldSpace(equipImage)
    local equip = InventoryMgr:getItemByPos(pos)
    InventoryMgr:showEquipByEquipment(equip, rect, true)
end

function EquipmentUpgradeDlg:onReduceButton(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not self.pos or not equip or equip.rebuild_level < 3 then
        if self.useItemNum > 1 then
            self.useItemNum = self.useItemNum - 1
            self:setUseItmeInfo()
            self:setCost()
        else
            gf:ShowSmallTips(CHS[3002576])
        end
    else
        if self.useItemNum > 2 then
            self.useItemNum = self.useItemNum - 1
            self:setUseItmeInfo()
            self:setCost()
        else
            gf:ShowSmallTips(CHS[4000377])
        end
    end
end

function EquipmentUpgradeDlg:onAddButton(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then return end

    if equip.rebuild_level < 3 then
        gf:ShowSmallTips(CHS[3002577])
        return
    end

    if self.useItemNum < 6 then
        self.useItemNum = self.useItemNum + 1
        self:setUseItmeInfo()
        self:setCost()
    else
        gf:ShowSmallTips(CHS[3002578])
    end
end

function EquipmentUpgradeDlg:onMaxButton()
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then return end
    if equip.rebuild_level < 3 then
        gf:ShowSmallTips(CHS[3002577])
        return
    end

    self.useItemNum = 6
    self:setUseItmeInfo()
    self:setCost()
end

function EquipmentUpgradeDlg:setUseItmeInfo()
    local reduceButton = self:getControl("ReduceButton")
    local addButton = self:getControl("AddButton")
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not self.pos or not equip or equip.rebuild_level < 3 then
        gf:grayImageView(reduceButton)
        gf:grayImageView(addButton)
        self.useItemNum = 1
    else
        if self.useItemNum <= 2 then
            gf:grayImageView(reduceButton)
        else
            gf:resetImageView(reduceButton)
        end

        if self.useItemNum >= 6 then
            gf:grayImageView(addButton)
        else
            gf:resetImageView(addButton)
        end
    end

    -- 数量
    local numberPanel = self:getControl("NumPanel")
    local numLabel = self:getControl("NumLabel", Const.UILabel, numberPanel)
    numLabel:setString(self.useItemNum)
    local numLabel1 = self:getControl("NumLabel_1", Const.UILabel, numberPanel)
    numLabel1:setString(self.useItemNum)
end

-- 显示道具信息
function EquipmentUpgradeDlg:onItemImage(sender, eventType)
    local item = self:getControl("CostImagePanel", Const.UIImage)
    local rect = self:getBoundingBoxInWorldSpace(item)
    InventoryMgr:showBasicMessageDlg(self.itemName, rect)
end


function EquipmentUpgradeDlg:onInheritButton(sender, eventType)
    if not self.pos then
        gf:ShowSmallTips(CHS[4101139])
        return
    end

    --  容错检测下
    local equip = InventoryMgr:getItemByPos(self.pos)
    if equip.item_type ~= ITEM_TYPE.EQUIPMENT then return end

            -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

        -- 角色等级达到#R70级#n后开放改造继承功能。
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200158])
        return
    end

        -- 限时装备不可进行此操作。
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[4101130])
        return
    end

        -- 永久限制交易装备无法进行改造继承。
    if InventoryMgr:isLimitedItemForever(equip) then
        gf:ShowSmallTips(CHS[4101131])
        return
    end

    if equip.req_level < 70 then
        gf:ShowSmallTips(CHS[4101132])
        return
    end



    local attrib = EquipmentMgr:getAttrib(equip.pos, 1)
    local rebuildLevel = equip.rebuild_level or 0



    if #attrib < 3 and rebuildLevel == 0 then
        gf:ShowSmallTips(CHS[4101119])
        return
    end

    local gAttrib = EquipmentMgr:getAttrib(equip.pos, 4)
    if #gAttrib < 1 then
        gf:ShowSmallTips(CHS[4101119])
        return
    end

    -- 改造等级限制
    if rebuildLevel > 5 then
        gf:ShowSmallTips(CHS[4200529])  -- 改造等级超过5级的装备无法作为主装备进行改造继承。
        return
    end

    if GameMgr.inCombat and self.pos <= 10 then
        gf:ShowSmallTips(CHS[4101133])
        return
    end

    local dlg = DlgMgr:openDlg("EquipmentInheritDlg")
    dlg:setData(equip)
end

function EquipmentUpgradeDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200592], two = CHS[4200592], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end


function EquipmentUpgradeDlg:isWeapon()
    if not self.pos then return false end
    local equip = InventoryMgr:getItemByPos(self.pos)
    if nil == equip then return false end
    if EQUIP_TYPE.WEAPON == equip.equip_type then
        return true
    else
        return false
    end
end

function EquipmentUpgradeDlg:updateRedDot()
    -- local dlg = DlgMgr:openDlg("EquipmentChildDlg", true)

    -- 添加小红点
    local equips = RedDotMgr:getRedDotList("EquipmentUpgrade")
    DlgMgr:sendMsg("EquipmentChildDlg", "setDlgType", "EquipmentUpgradeDlg")
    DlgMgr:sendMsg("EquipmentChildDlg", "removeAllEquipRedDot")
    DlgMgr:sendMsg("EquipmentChildDlg", "setEquipRedDot", equips)

    RedDotMgr:removeOneRedDot("EquipmentTabDlg", "EquipmentUpgradeDlgCheckBox")
end

-- 设置当前装备
function EquipmentUpgradeDlg:setInfoByPos(inventory)
    if not inventory then
        self:clearPanel()
        return
    end
    self:setCtrlVisible("FrameImage", true, "EquipmentImagePanel")
    if self.pos ~= inventory then self.isUpgradeCD = false end
    self:updateDlg(inventory)

    -- 如果当前选择的pos下一级信息已经存在,并且一键是否一致，是否重新想服务器发送消息
  --[[  if EquipmentMgr.equipUpgradeData[self.pos] ~= nil then
        self:updateDlg(inventory)
        return
    end]]
    local equip = InventoryMgr:getItemByPos(inventory)
    if not equip then return end
    if equip.rebuild_level == 12 then
        EquipmentMgr.equipUpgradeData[inventory] = equip
        self:MSG_PRE_UPGRADE_EQUIP()
        return
    end

    gf:CmdToServer("CMD_PRE_UPGRADE_EQUIP", {
        pos = self.pos,
        type = Const.UPGRADE_EQUIP_UPGRADE,
        para = 1
    })
end

-- 设置装备图标
function EquipmentUpgradeDlg:setEquipIconAndText(equip)
    if equip == nil then
        self:setImagePlist("EquipmentImage", ResMgr.ui.touming)
        self:setLabelText("EquipmentNameLabel", "")
        return
    end
    -- 装备基本信息：图标、名称、等级
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon))
    self:setItemImageSize("EquipmentImage")
    self:setLabelText("EquipmentNameLabel", equip.name)
    self:updateLayout("EquipmentUpgradePanel")
end

-- 更新界面信息
function EquipmentUpgradeDlg:updateDlg(pos)
    local inventory = InventoryMgr:getItemByPos(pos)
    if nil == inventory then
        self:setCtrlVisible("NoneEquipImage", true)
        self:setCtrlVisible("FrameImage", false, "EquipmentImagePanel")
        return
    end

    self:setCtrlVisible("NoneEquipImage", false)
    -- 设置图标和文本
    self:initEquipInfo(inventory)

    -- 设置装备信息
    self:setEquipment()

    -- 设置消耗信息
    self:setCost()

    RedDotMgr:removeOneRedDot("EquipmentTabDlg", "EquipmentUpgradeDlgCheckBox")
end

function EquipmentUpgradeDlg:setEquipment()
    local inventory = InventoryMgr:getItemByPos(self.pos)
    if nil == inventory then return end

    -- 当前装备和next装备
    self:setEquipInfo(inventory, "OldEquipmentPanel")
    self:setEquipInfo(EquipmentMgr.equipUpgradeData[self.pos], "NewEquipmentPanel")
end

-- 清除rootName对应改造内容
function EquipmentUpgradeDlg:clearContent(rootName)
    local root = self:getControl(rootName)
    if not root then return end
    self:setLabelText("UpgradeLevelLabel", "", root)
    self:setLabelText("EquipmentAttributeNameLabel1", "", root)
    self:setLabelText("EquipmentAttributeValueLabel1",  "", root)
    self:setLabelText("AllAttributeLabel", "", root)
    self:setLabelText("AllAttributeValueLabel",  "", root)
    self:setLabelText("GongmingAttributeLabel", "", root)
    self:setLabelText("GongmingAttributeValueLabel", "", root)
end

function EquipmentUpgradeDlg:setEquipInfo(equip, rootName)
    local root = self:getControl(rootName)
    self:clearContent(rootName)

    local basePower, scalePower, scoreEquip
    if rootName == "NewEquipmentPanel"  then
        if not equip then return end

        -- X改
        local oldEquip = InventoryMgr:getItemByPos(self.pos)
        if nil == oldEquip then return end
        self:setLabelText("UpgradeLevelLabel", string.format(CHS[3002579], oldEquip.rebuild_level + 1), root, COLOR3.TEXT_DEFAULT)

        if self:isWeapon() then
            self:setLabelText("EquipmentAttributeNameLabel1", CHS[3002580], root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("EquipmentAttributeValueLabel1",  equip.extra.phy_power_10 or 0 , root, COLOR3.GREEN)

            self:setLabelText("AllAttributeLabel", CHS[3002581], root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("AllAttributeValueLabel",  equip.extra.all_attrib_10 or 0, root, COLOR3.GREEN)
        else
            self:setLabelText("EquipmentAttributeNameLabel1", CHS[3002582], root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("EquipmentAttributeValueLabel1", equip.extra.def_10 or 0, root, COLOR3.GREEN)

            self:setLabelText("AllAttributeLabel", CHS[3002583], root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("AllAttributeValueLabel", equip.extra.max_life_10 or 0, root, COLOR3.GREEN)
        end

        if oldEquip.rebuild_level == UPGRADE_LEVEL_MAX then
            -- 如果装备已经最大等级       CHS[4000102]：已达上限
            self:setLabelText("UpgradeLevelLabel", CHS[4000102], root, COLOR3.RED)
            self:setLabelText("EquipmentAttributeValueLabel1", "", root)
            self:setLabelText("EquipmentAttributeNameLabel1", CHS[4000102], root, COLOR3.RED)
            local allAttributeLabelText = self:getLabelText("AllAttributeLabel", root)
            if allAttributeLabelText ~= "" and allAttributeLabelText ~= CHS[7190139] then
                self:setLabelText("AllAttributeLabel", CHS[4000102], root, COLOR3.RED)
                self:setLabelText("AllAttributeValueLabel", "", root)
            end
        end
    else
        if not equip then return end
        -- X改
        self:setLabelText("UpgradeLevelLabel", string.format(CHS[3002579], equip.rebuild_level), root)

        -- 进度
        local completionLabel = self:getControl("UpgradeCompletionLabel", Const.UILabel)

        if not equip["degree_32"] then
            completionLabel:setString("")
        else
            local degree = math.floor(equip["degree_32"] / 100) *100 / 1000000
            if degree == 0 then
                completionLabel:setString("")
            else
                completionLabel:setString(string.format("(+%0.4f%%)", degree))
            end
        end

        if self:isWeapon() then
            self:setLabelText("EquipmentAttributeNameLabel1", CHS[3002580], root)
            self:setLabelText("EquipmentAttributeValueLabel1", equip.extra.phy_power_10 or 0, root)

            self:setLabelText("AllAttributeLabel", CHS[3002581], root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("AllAttributeValueLabel", equip.extra.all_attrib_10 or 0, root, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("EquipmentAttributeNameLabel1", CHS[3002582], root)
            self:setLabelText("EquipmentAttributeValueLabel1", equip.extra.def_10 or 0, root)

            self:setLabelText("AllAttributeLabel", CHS[3002583], root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("AllAttributeValueLabel", equip.extra.max_life_10 or 0, root, COLOR3.TEXT_DEFAULT)
        end
    end

    -- 设置共鸣属性
    self:setCtrlVisible("GongmingAttributeLabel", true, root)
    self:setCtrlVisible("GongmingAttributeValueLabel", true, root)
    self:setCtrlVisible("Label_4", true, "ArrowPanel")
    self:setCtrlVisible("Label_3", true, "ArrowPanel")
    local resonance = EquipmentMgr:getEquipPre(equip, Const.FIELDS_RESONANCE)
    if resonance then
        local name = EquipmentMgr:getAttribChsOrEng(resonance.field)
        local str = resonance.value .. EquipmentMgr:getPercentSymbolByField(resonance.field)
        local color = rootName == "NewEquipmentPanel" and COLOR3.GREEN or COLOR3.TEXT_DEFAULT
        if rootName == "NewEquipmentPanel" and equip.rebuild_level == UPGRADE_LEVEL_MAX then
            self:setLabelText("GongmingAttributeLabel", CHS[4000102], root, COLOR3.RED)
            self:setLabelText("GongmingAttributeValueLabel", "", root, color)
        else
            self:setLabelText("GongmingAttributeLabel", string.format(CHS[7190138], name), root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("GongmingAttributeValueLabel", str, root, color)
        end
    else
        if rootName == "NewEquipmentPanel" then
            self:setLabelText("GongmingAttributeLabel", CHS[7190139], root, COLOR3.GRAY)
            self:setLabelText("GongmingAttributeValueLabel", "", root, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("GongmingAttributeLabel", "", root, COLOR3.TEXT_DEFAULT)
            self:setLabelText("GongmingAttributeValueLabel", CHS[7190139], root, COLOR3.GRAY)
        end
    end

    -- 在第2条属性为空或都为0时，策划要求将第3条属性(共鸣属性)移上来
    -- 由于移动Label相关操作较复杂，采用方案：隐藏第3条属性相关控件，然后将第3条属性内容复制到第2条中
    if self:notHaveSecondAttrib()then
        self:setCtrlVisible("GongmingAttributeLabel", false, "OldEquipmentPanel")
        self:setCtrlVisible("GongmingAttributeValueLabel", false, "OldEquipmentPanel")
        self:setCtrlVisible("Label_4", false, "ArrowPanel")
        self:setCtrlVisible("GongmingAttributeLabel", false, "NewEquipmentPanel")
        self:setCtrlVisible("GongmingAttributeValueLabel", false, "NewEquipmentPanel")

        local oldGongmingName = self:getLabelText("GongmingAttributeLabel", "OldEquipmentPanel")
        self:setLabelText("AllAttributeLabel", oldGongmingName, "OldEquipmentPanel", COLOR3.TEXT_DEFAULT)

        local oldGongmingValue = self:getLabelText("GongmingAttributeValueLabel", "OldEquipmentPanel")
        if oldGongmingValue == CHS[7190139] then
            self:setLabelText("AllAttributeValueLabel", oldGongmingValue, "OldEquipmentPanel", COLOR3.GRAY)
        else
            self:setLabelText("AllAttributeValueLabel", oldGongmingValue, "OldEquipmentPanel", COLOR3.TEXT_DEFAULT)
        end

        local newGongmingValue = self:getLabelText("GongmingAttributeValueLabel", "NewEquipmentPanel")
        self:setLabelText("AllAttributeValueLabel", newGongmingValue, "NewEquipmentPanel", COLOR3.GREEN)

        local newGongmingName = self:getLabelText("GongmingAttributeLabel", "NewEquipmentPanel")
        if newGongmingName == CHS[7190139] then
            self:setLabelText("AllAttributeLabel", newGongmingName, "NewEquipmentPanel", COLOR3.GRAY)
        else
            self:setLabelText("AllAttributeLabel", newGongmingName, "NewEquipmentPanel", COLOR3.TEXT_DEFAULT)
        end
    elseif rootName == "NewEquipmentPanel" then
        -- 复原old属性
        local oldEquip = InventoryMgr:getItemByPos(self.pos)
        if oldEquip then
            self:setEquipInfo(oldEquip, "OldEquipmentPanel")
        end
    end

    -- 暂时屏蔽共鸣属性
    if DistMgr:needIgnoreGongming() then
        self:setCtrlVisible("GongmingAttributeLabel", false, "OldEquipmentPanel")
        self:setCtrlVisible("GongmingAttributeValueLabel", false, "OldEquipmentPanel")
        self:setCtrlVisible("Label_4", false, "ArrowPanel")
        self:setCtrlVisible("GongmingAttributeLabel", false, "NewEquipmentPanel")
        self:setCtrlVisible("GongmingAttributeValueLabel", false, "NewEquipmentPanel")

        -- 第2条属性也可能为共鸣属性
        local oldAllAttribText = self:getLabelText("AllAttributeValueLabel", "OldEquipmentPanel")
        if oldAllAttribText == CHS[7190139] then
            self:setLabelText("AllAttributeValueLabel", "", "OldEquipmentPanel")
            self:setCtrlVisible("Label_3", false, "ArrowPanel")
        end

        local newAllAttribText = self:getLabelText("AllAttributeLabel", "NewEquipmentPanel")
        if newAllAttribText == CHS[7190139] then
            self:setLabelText("AllAttributeLabel", "", "NewEquipmentPanel")
            self:setCtrlVisible("Label_3", false, "ArrowPanel")
        end
    end

    self:updateLayout("EquipmentUpgradePanel")
    self:updateLayout("OldEquipmentPanel")
    self:updateLayout("NewEquipmentPanel")
end

-- 是否，当前与改造后装备都没有第2条属性
function EquipmentUpgradeDlg:notHaveSecondAttrib()
    local curEquip = InventoryMgr:getItemByPos(self.pos)
    local preEquip = EquipmentMgr.equipUpgradeData[self.pos]
    if not curEquip or not preEquip then return false end

    if EQUIP_TYPE.WEAPON == curEquip.equip_type then
        if (not curEquip.extra.all_attrib_10 or curEquip.extra.all_attrib_10 == 0) and
            (not preEquip.extra.all_attrib_10 or preEquip.extra.all_attrib_10 == 0) then
            return true
        end
    else
        if (not curEquip.extra.max_life_10 or curEquip.extra.max_life_10 == 0) and
            (not preEquip.extra.max_life_10 or preEquip.extra.max_life_10 == 0) then
            return true
        end
    end

    return false
end

function EquipmentUpgradeDlg:setCost()
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then return end
    local costCash = EquipmentMgr:getUpgradeCost(equip.req_level)
   -- if not EquipmentMgr.equipUpgradeCost[self.pos] then return end
    -- 图片       灵石消耗        CHS[4000103]：超级灵石       CHS[4000104]：超级晶石
    local icon
    local amount
    if self:isWeapon() then
        icon = InventoryMgr:getIconByName(CHS[4000103])
        local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002584], self:isCheck("BindCheckBox"))
        local amountMini = InventoryMgr:getMiniBylevel(CHS[3002585], equip.req_level, self:isCheck("BindCheckBox"))
        amount = amountSuper + amountMini
        self:setLabelText("CostItemLabel", CHS[4000103])
    else
        icon = InventoryMgr:getIconByName(CHS[4000104])
        local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002586], self:isCheck("BindCheckBox"))
        local amountMini = InventoryMgr:getMiniBylevel(CHS[3002587], equip.req_level, self:isCheck("BindCheckBox"))
        amount = amountSuper + amountMini
        self:setLabelText("CostItemLabel", CHS[4000104])
    end

    if amount > 999 then amount = "*" end
    self:setImage("CostImage", ResMgr:getItemIconPath(icon))
    self:setItemImageSize("CostImage")
    local imgCtrl = self:getControl("CostImage")
    imgCtrl.isWeapon = self:isWeapon()

    if tonumber(amount) and amount < self.useItemNum then
        self:setNumImgForPanel("HaveItemPanel", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    else
        self:setNumImgForPanel("HaveItemPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    end

    local moneyStr, fontColor = gf:getArtFontMoneyDesc(costCash)
    self:setNumImgForPanel("CostMoneyPanel", fontColor, moneyStr, false, LOCATE_POSITION.CENTER, 23)
    local meMoneyStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", meFontColor, meMoneyStr, false, LOCATE_POSITION.CENTER, 23)
end

function EquipmentUpgradeDlg:clearPanel()
    self:setCtrlVisible("NoneEquipImage", true)
    self:setCtrlVisible("FrameImage", false, "EquipmentImagePanel")

    self.useItemNum = 1
    self:setUseItmeInfo()
    self.itemName = CHS[4000103]
    local icon = InventoryMgr:getIconByName(self.itemName )
    local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(self.itemName, self:isCheck("BindCheckBox"))
    local amountMini = InventoryMgr:getMiniBylevel(CHS[3002585], 0, self:isCheck("BindCheckBox"))
    local amount = amountSuper + amountMini
    self:setLabelText("CostItemLabel", self.itemName )

    if amount > 999 then amount = "*" end
        self:setImage("CostImage", ResMgr:getItemIconPath(icon))
        self:setItemImageSize("CostImage")

    if amount ==0 then
        self:setNumImgForPanel("HaveItemPanel", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    else
        self:setNumImgForPanel("HaveItemPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    end


    local root = self:getControl("NewEquipmentPanel")
    self:setLabelText("EquipmentAttributeNameLabel1", "", root)
    self:setLabelText("EquipmentAttributeValueLabel1", "", root)
    self:setLabelText("AllAttributeLabel", "", root)
    self:setLabelText("AllAttributeValueLabel", "", root)
    self:setLabelText("UpgradeLevelLabel", "", root)

    root = self:getControl("OldEquipmentPanel")
    self:setLabelText("EquipmentAttributeNameLabel1", "", root)
    self:setLabelText("EquipmentAttributeValueLabel1", "", root)
    self:setLabelText("AllAttributeLabel", "", root)
    self:setLabelText("AllAttributeValueLabel", "", root)
    self:setLabelText("UpgradeLevelLabel", "", root)
    self:setLabelText("UpgradeCompletionLabel", "", root)

    local moneyStr, fontColor = gf:getArtFontMoneyDesc(0)
    self:setNumImgForPanel("CostMoneyPanel", fontColor, moneyStr, false, LOCATE_POSITION.CENTER, 23)

    local meMoneyStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", meFontColor, meMoneyStr, false, LOCATE_POSITION.CENTER, 23)
end

function EquipmentUpgradeDlg:setProssBar(isBarAction)
    local equip = InventoryMgr:getItemByPos(self.pos)
    local level = equip.rebuild_level
    -- 完成度和一键进化
    local degree = equip.rebuild_degree
    local total = self:getUpgradeMaxByLevel(level)

    if self.isUpgradeCD and degree == 0 then
        -- 进度为0代表等级加1，数值先变化成100％
        self:setLabelText("ProgressLabel", string.format("%d/%d", self.lastCount or total, self.lastCount or total), nil, COLOR3.TEXT_DEFAULT)
    end

    local function setBarLabel()
        if equip.rebuild_level == UPGRADE_LEVEL_MAX then
            self:setLabelText("ProgressLabel", CHS[3002588], nil, COLOR3.RED)
            self:setProgressBar("EquipmentProgressBar", 1, 1)
        else
            self:setLabelText("ProgressLabel", string.format("%d/%d", degree, total), nil, COLOR3.TEXT_DEFAULT)
            self:setProgressBar("EquipmentProgressBar", degree, total)
        end

        self.isUpgradeCD = false
        self.lastCount = total
    end
    self:setProgressBar("EquipmentProgressBar", degree, total, nil, nil, isBarAction, setBarLabel)
end

-- 检查是否够一次
function EquipmentUpgradeDlg:checkOnceEvolve(noTip)
    local cash, items
    if EquipmentMgr.equipUpgradeCost[self.pos] then
        cash = EquipmentMgr.equipUpgradeCost[self.pos].cash
        if self.pos == EQUIP.WEAPON then
            items = {[CHS[3002584]] = EquipmentMgr.equipUpgradeCost[self.pos].num1}
        else
            items = {[CHS[3002586]] = EquipmentMgr.equipUpgradeCost[self.pos].num1}
        end
    end

    cash = cash or 0
    items = items or {}

    if not gf:checkCostIsEnough(cash, items, noTip) then
        return false
    end
    return true
end

function EquipmentUpgradeDlg:onUpgrade5Button(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.pos == nil then
        gf:ShowSmallTips(CHS[3002590])
        return
    end

    local equip = InventoryMgr:getItemByPos(self.pos)
    if nil == equip then return end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if GameMgr.inCombat and self.pos <= 10 then
        gf:ShowSmallTips(CHS[4100313])
        return
    end

    if equip.rebuild_level <= 4 then
        gf:ShowSmallTips(CHS[3002591])
    elseif equip.rebuild_level >= 12 then
        gf:ShowSmallTips(CHS[3002592])
    else
        local dlg = DlgMgr:openDlg("EquipmentOneClickUpgradeDlg")
        dlg:setData(self.pos)
    end



 --[[   if self.isUpgradeCD then return end
    if not self:checkOnceEvolve(true) then
    -- 一键进化要是不足一次，提示一键剩余
        -- 完成度和一键进化
        local equip = InventoryMgr:getItemByPos(self.pos)
        local degree = equip.rebuild_degree
        local total = self:getUpgradeMaxByLevel(equip.rebuild_level)
        local count = total - degree
        local cash, items
        if EquipmentMgr.equipUpgradeCost[self.pos] then
            cash = EquipmentMgr.equipUpgradeCost[self.pos].cash * count
            if self.pos == EQUIP.WEAPON then
                items = {[ CHS[3004432] ] = EquipmentMgr.equipUpgradeCost[self.pos].num1 * count}
            else
                items = {[ CHS[3001100] ] = EquipmentMgr.equipUpgradeCost[self.pos].num1 * count}
            end
        end

        cash = cash or 0
        items = items or {}

        gf:checkCostIsEnough(cash,items)
        return
    end

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = self.pos,
        type = Const.UPGRADE_EQUIP_UPGRADE,
        para = 9999
    })

    self.isUpgradeCD = true]]
end

function EquipmentUpgradeDlg:onUpgradeButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.pos == nil then
        gf:ShowSmallTips(CHS[3002590])
        return
    end

    local equip = InventoryMgr:getItemByPos(self.pos)
    if nil == equip then return end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if GameMgr.inCombat and self.pos <= 10 then
        gf:ShowSmallTips(CHS[4100313])
        return
    end

    if equip.rebuild_level >= 12 then
        gf:ShowSmallTips(CHS[3002592])
        return
    end
    local costCash = EquipmentMgr:getUpgradeCost(equip.req_level)
    local amount = 0
    local item
    local blindNum = 0
    if self:isWeapon() then
        item = CHS[3002584]
        local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002584], self:isCheck("BindCheckBox"))
        local amountMini = InventoryMgr:getMiniBylevel(CHS[3002585], equip.req_level, self:isCheck("BindCheckBox"))
        amount = amountSuper + amountMini
        blindNum = InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002585], equip.req_level) + InventoryMgr:getAmountByNameForeverBind(CHS[3002584])
    else
        item = CHS[3002586]
        local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002586], self:isCheck("BindCheckBox"))
        local amountMini = InventoryMgr:getMiniBylevel(CHS[3002587], equip.req_level, self:isCheck("BindCheckBox"))
        amount = amountSuper + amountMini
        blindNum = InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002587], equip.req_level) + InventoryMgr:getAmountByNameForeverBind(CHS[3002586])
    end

    if amount < self.useItemNum then
        gf:askUserWhetherBuyItem({[item] = self.useItemNum - amount})
        return
    end

    local ownCash = Me:queryInt("cash")
    if ownCash < costCash then
        gf:askUserWhetherBuyCash(costCash - ownCash)
        return
    end

    if self:isCheck("BindCheckBox") and blindNum ~= 0  then
        local str, day = gf:converToLimitedTimeDay(equip.gift)
        if  InventoryMgr:isLimitedItemForever(equip) or day > Const.LIMIT_TIPS_DAY then
            -- 永久限制交易道具
            EquipmentMgr:cmdUpgradeEquip(self.pos, string.format("%d_%d", self.useItemNum, 1))
        else
            local days
            if self.useItemNum > blindNum then
                days = blindNum * 10
            else
                days = self.useItemNum * 10
            end

            local curInventory = self.pos
            local useItemNum = self.useItemNum
            gf:confirm(string.format(CHS[3002593], days), function()
                EquipmentMgr:cmdUpgradeEquip(curInventory, string.format("%d_%d", useItemNum, 1))
            end)
        end

    else
        EquipmentMgr:cmdUpgradeEquip(self.pos, string.format("%d_%d", self.useItemNum, 0))
    end

end

function EquipmentUpgradeDlg:onGongmingButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:getLevel() < EquipmentMgr:getEquipGongmingPlayerLevel() then
        gf:ShowSmallTips(CHS[7190130])
        return
    end

    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then
        gf:ShowSmallTips(CHS[7190131])
        return
    end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if equip.req_level < EquipmentMgr:getEquipGongmingPlayerLevel() then
        gf:ShowSmallTips(CHS[7190132])
        return
    end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(equip.pos) then
        gf:ShowSmallTips(CHS[7190133])
        return
    end

    -- 改造等级限制
    if equip.rebuild_level and tonumber(equip.rebuild_level) <= 3 or equip.color ~= CHS[3002403] then
        gf:ShowSmallTips(CHS[7190134])
        return
    end

    local dlg = DlgMgr:openDlg("EquipmentRefiningGongmingDlg")
    dlg:setInfoByPos(equip.pos)
end

function EquipmentUpgradeDlg:onMaterial(sender, eventType)
    -- CHS[4000103]：超级灵石       CHS[4000104]：超级晶石
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local imgCtrl = self:getControl("CostImage")
    local isWeapon = imgCtrl.isWeapon
    if isWeapon or not self.pos  then
        InventoryMgr:showBasicMessageDlg(CHS[4000103], rect)
    else
        InventoryMgr:showBasicMessageDlg(CHS[4000104], rect)
    end
end

-- 获取最大完成度
function EquipmentUpgradeDlg:getUpgradeMaxByLevel(level)
    local next = level + 1
    if next > UPGRADE_LEVEL_MAX then next = UPGRADE_LEVEL_MAX end

    if next < 36 then
        return 1
    elseif next < 41 then
        return 2
    elseif next < 46 then
        return 3
    elseif next < 51 then
        return 4
    elseif next < 61 then
        return 8
    elseif next < 71 then
        return 16
    elseif next < 81 then
        return 40
    elseif next < 91 then
        return 80
    elseif next < 101 then
        return 120
    elseif next < 111 then
        return 240
    elseif next < 121 then
        return 480
    end
end

-- 获取亮星星资源
function EquipmentUpgradeDlg:getBrightStar()
    return string.format(ResMgr.ui.evolve_star_compelete)
end

-- 获取亮星星资源
function EquipmentUpgradeDlg:getGrayStar()
    return string.format(ResMgr.ui.evolve_star_gray)
end

function EquipmentUpgradeDlg:MSG_UPDATE(data)
    self:setCost()
    RedDotMgr:removeOneRedDot("EquipmentTabDlg", "EquipmentUpgradeDlgCheckBox")
end

function EquipmentUpgradeDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    RedDotMgr:removeOneRedDot("EquipmentTabDlg", "EquipmentUpgradeDlgCheckBox")

    self:setCost()
    if self.pos and data[1].pos == self.pos then
        local equip = InventoryMgr:getItemByPos(self.pos)



        if not equip or equip.item_type ~= ITEM_TYPE.EQUIPMENT then
            self.pos = nil
            -- 刷新图标
            self:setEquipIconAndText()
            return
        end



        -- 刷新进度条
      --  self:setProssBar(true)
        if equip.rebuild_level == 3 then
            -- 由2改3
            self.useItemNum = 2
            self:setUseItmeInfo()
        end

        -- 刷新当前装备
        self:setEquipInfo(equip, "OldEquipmentPanel")

        if equip.rebuild_level == UPGRADE_LEVEL_MAX then
            self:setEquipInfo(EquipmentMgr.equipUpgradeData[self.pos], "NewEquipmentPanel")
        end
    end
end

function EquipmentUpgradeDlg:MSG_PRE_UPGRADE_EQUIP(data)
    self:setEquipInfo(EquipmentMgr.equipUpgradeData[self.pos], "NewEquipmentPanel")
    self:setCost()
end


function EquipmentUpgradeDlg:onCheckBox(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    if not equip then
        self:clearPanel()
        return
    end
    self:setCost()
end

function EquipmentUpgradeDlg:cleanup()
    self.pos = nil
end

function EquipmentUpgradeDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_UPGRADE_INHERIT_OK == data.notify  then
        if self.pos then
            self:setInfoByPos(self.pos)
        end
    end
end

function EquipmentUpgradeDlg:youMustGiveMeOneNotify(param)
    if "limitEquip" == param then
        local equip = InventoryMgr:getItemByPos(self.pos)
        local str, day = gf:converToLimitedTimeDay(equip.gift)
        if InventoryMgr:isLimitedItemForever(equip) or day > Const.LIMIT_TIPS_DAY then
            GuideMgr:youCanDoIt(self.name, "")
        else
            GuideMgr:youCanDoIt(self.name, param)
        end
    else
        GuideMgr:youCanDoIt(self.name, param)
    end
end

return EquipmentUpgradeDlg
