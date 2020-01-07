-- UserChangeUpgradeDlg.lua
-- Created by lixh Nov/16 2017
-- 仙魔转换界面

local UserChangeUpgradeDlg = Singleton("UserChangeUpgradeDlg", Dialog)

-- 角色创建时的图片
local ROLE_UI_IMAGE =
{
    [POLAR.METAL..GENDER_TYPE.MALE] = ResMgr.ui.metal_male_big_image,
    [POLAR.METAL..GENDER_TYPE.FEMALE] = ResMgr.ui.metal_female_big_image,
    [POLAR.WOOD..GENDER_TYPE.MALE] = ResMgr.ui.wood_male_big_image,
    [POLAR.WOOD..GENDER_TYPE.FEMALE] = ResMgr.ui.wood_female_big_image,
    [POLAR.WATER..GENDER_TYPE.MALE] = ResMgr.ui.water_male_big_image,
    [POLAR.WATER..GENDER_TYPE.FEMALE] = ResMgr.ui.water_female_big_image,
    [POLAR.FIRE..GENDER_TYPE.MALE] = ResMgr.ui.fire_male_big_image,
    [POLAR.FIRE..GENDER_TYPE.FEMALE] = ResMgr.ui.fire_female_big_image,
    [POLAR.EARTH..GENDER_TYPE.MALE] = ResMgr.ui.earth_male_big_image,
    [POLAR.EARTH..GENDER_TYPE.FEMALE] = ResMgr.ui.earth_female_big_image,
}

-- 仙魔转换消耗材料 天星石
local NEED_MATERIAL = {name = CHS[7100066], num = 3}

function UserChangeUpgradeDlg:init()
    self:setFullScreen()
    self:setCtrlFullClient("BKImage", "BKPanel", true)
    self:setCtrlFullClient("Panel_32", "BKPanel")
    self:bindListener("ColseButton", self.onCloseButton)
    self:bindListener("UpgradeButton", self.onUpgradeButton)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("TouchPanel", self.onSelectXianPanel, "XianUpgradeDescPanel")
    self:bindListener("TouchPanel", self.onSelectMoPanel, "MoUpgradeDescPanel")

    self.userMagicImage = self:getControl("BKImage")

    self.xianHaveImage = self:getControl("HaveImage", nil, "XianUpgradeDescPanel")
    self.xianPayPanel = self:getControl("PayPanel", nil, "XianUpgradeDescPanel")
    self.xianBackEffect = self:getControl("BKImage_2", nil, "XianUpgradeDescPanel")

    self.moHaveImage = self:getControl("HaveImage", nil, "MoUpgradeDescPanel")
    self.moPayPanel = self:getControl("PayPanel", nil, "MoUpgradeDescPanel")
    self.moBackEffect = self:getControl("BKImage_2", nil, "MoUpgradeDescPanel")

    self:setImage("ShapeImage", ROLE_UI_IMAGE[Me:queryBasicInt("polar") .. Me:queryBasicInt("gender")], "PlayerPanel")

    self.selectType = Me:getChildType() == 1 and CHILD_TYPE.UPGRADE_MAGIC or CHILD_TYPE.UPGRADE_IMMORTAL
    self:setXianMoPhoto(Me:getChildType() == 1 and CHILD_TYPE.UPGRADE_IMMORTAL or CHILD_TYPE.UPGRADE_MAGIC)
    self:setDlgByType(self.selectType)

    self:hookMsg("MSG_ENTER_ROOM")
    self:hookMsg("MSG_CHAR_UPGRADE_COAGULATION")
end

-- 初始化界面信息
function UserChangeUpgradeDlg:setDlgByType(type)
    self:addUpgradeMagicToCtrl("BabyPanel", CHILD_TYPE.UPGRADE_IMMORTAL, "XianUpgradeDescPanel", true)
    self:addUpgradeMagicToCtrl("BabyPanel", CHILD_TYPE.UPGRADE_MAGIC, "MoUpgradeDescPanel", true)
    local icon = nil
    if Me:queryBasicInt("suit_icon") ~= 0 and gf:isShowSuit() then
        icon = Me:queryBasicInt("suit_icon")
    else
        icon = Me:queryBasicInt('icon')
    end

    self:setPortrait("BabyPanel", icon, InventoryMgr:getMeUsingWeaponIcon(), "XianUpgradeDescPanel", nil, nil, nil, nil, Me:queryBasicInt("icon"), nil, 5)
    self:setPortrait("BabyPanel", icon, InventoryMgr:getMeUsingWeaponIcon(), "MoUpgradeDescPanel", nil, nil, nil, nil, Me:queryBasicInt("icon"), nil, 7)

    self:setMaterialPanel(self.xianPayPanel)
    self:setMaterialPanel(self.moPayPanel)

    self:selectXianMo(type)
end

-- 设置已成仙/已入魔图片
function UserChangeUpgradeDlg:setXianMoPhoto(type)
    self.xianHaveImage:setVisible(type == CHILD_TYPE.UPGRADE_IMMORTAL)
    self.xianPayPanel:setVisible(type == CHILD_TYPE.UPGRADE_MAGIC)
    self.moHaveImage:setVisible(type == CHILD_TYPE.UPGRADE_MAGIC)
    self.moPayPanel:setVisible(type == CHILD_TYPE.UPGRADE_IMMORTAL)
end

-- 设置材料消耗(天星石)
function UserChangeUpgradeDlg:setMaterialPanel(root)
    local panel = self:getControl("ItemImagePanel1", nil, root)
    panel.data = NEED_MATERIAL
    self:setImage("ItemImage", ResMgr:getIconPathByName(NEED_MATERIAL.name), panel)

    local amount = InventoryMgr:getAmountByName(NEED_MATERIAL.name)
    if amount < NEED_MATERIAL.num then
        self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
    else
        self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
    end

    local needStr = "/" .. NEED_MATERIAL.num
    self:setNumImgForPanel("NumberPanel2", ART_FONT_COLOR.NORMAL_TEXT, needStr, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    self:bindTouchEndEventListener(panel, self.onMaterialPanel)
end

-- 材料悬浮框
function UserChangeUpgradeDlg:onMaterialPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    if sender.data then
        InventoryMgr:showBasicMessageDlg(sender.data.name, rect)
    end
end

-- 添加人物大仙魔光效
function UserChangeUpgradeDlg:addMiddlePlayerMagic(type)
    self.userMagicImage:removeChildByTag(Const.ARMATURE_MAGIC_TAG)
    self.userMagicImage:removeChildByTag(Const.ARMATURE_MAGIC_TAG + 1)

    if type == CHILD_TYPE.UPGRADE_IMMORTAL then
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_immortal_top, self.userMagicImage, Const.ARMATURE_MAGIC_TAG)
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_immortal_bottom, self.userMagicImage, Const.ARMATURE_MAGIC_TAG + 1)
    elseif type == CHILD_TYPE.UPGRADE_MAGIC then
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_magic_top, self.userMagicImage, Const.ARMATURE_MAGIC_TAG)
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_magic_bottom, self.userMagicImage, Const.ARMATURE_MAGIC_TAG + 1)
    end
end

-- 选择仙魔状态 type == 3 仙  type == 4 魔
function UserChangeUpgradeDlg:selectXianMo(type)
    self:addMiddlePlayerMagic(type)
    local str = ""

    if type == CHILD_TYPE.UPGRADE_IMMORTAL then
        -- 弃魔从仙
        str = string.format(CHS[7100063], CHS[7100065], CHS[7100064])
        self.xianBackEffect:setVisible(true)
        self.moBackEffect:setVisible(false)
    elseif type == CHILD_TYPE.UPGRADE_MAGIC then
        -- 弃仙从魔
        str = string.format(CHS[7100063], CHS[7100064], CHS[7100065])
        self.xianBackEffect:setVisible(false)
        self.moBackEffect:setVisible(true)
    end

    self:setLabelText("ConfrimLabel1", str, "UpgradeButton")
    self:setLabelText("ConfrimLabel2", str, "UpgradeButton")
end

function UserChangeUpgradeDlg:onSelectXianPanel(sender, eventType)
    if self.selectType and self.selectType == CHILD_TYPE.UPGRADE_IMMORTAL then
        return
    end

    self.selectType = CHILD_TYPE.UPGRADE_IMMORTAL
    self:selectXianMo(self.selectType)
end

function UserChangeUpgradeDlg:onSelectMoPanel(sender, eventType)
    if self.selectType and self.selectType == CHILD_TYPE.UPGRADE_MAGIC then
        return
    end

    self.selectType = CHILD_TYPE.UPGRADE_MAGIC
    self:selectXianMo(self.selectType)
end

function UserChangeUpgradeDlg:onCloseButton(sender, eventType)
    Dialog.onCloseButton(self)
end

function UserChangeUpgradeDlg:onUpgradeButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003663])
        return
    end

    -- 真身状态，才能完成仙魔的转换
    if not Me:isRealBody() then
        gf:ShowSmallTips(CHS[7100067])
        return
    end

    local meUpgradeType = Me:getChildType() == 1 and CHILD_TYPE.UPGRADE_IMMORTAL or CHILD_TYPE.UPGRADE_MAGIC

    -- 你当前已飞升成仙
    if self.selectType == meUpgradeType and meUpgradeType == CHILD_TYPE.UPGRADE_IMMORTAL then
        gf:ShowSmallTips(string.format(CHS[7100068], CHS[7100064]))
        return
    end

    -- 你当前已飞升成魔
    if self.selectType == meUpgradeType and meUpgradeType == CHILD_TYPE.UPGRADE_MAGIC then
        gf:ShowSmallTips(string.format(CHS[7100068], CHS[7100065]))
        return
    end

    -- 你携带的天星石数量不足
    if InventoryMgr:getAmountByName(NEED_MATERIAL.name) < NEED_MATERIAL.num then
        gf:ShowSmallTips(CHS[7100069])
        return
    end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        return
    end

    DlgMgr:openDlgEx("CheckChangeXianMoDlg",{type = self.selectType, material = NEED_MATERIAL})
end

function UserChangeUpgradeDlg:onNoteButton(sender, eventType)
    DlgMgr:openDlg("UserUpgradeChangeRuleDlg")
end

function UserChangeUpgradeDlg:MSG_ENTER_ROOM()
    self:onCloseButton()
end

function UserChangeUpgradeDlg:MSG_CHAR_UPGRADE_COAGULATION(data)
    if not data or not data.upgrade_type then
        return
    end

    -- 转换成功动画
    local panel = self:getControl("PlayerPanel")
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.jieying.name, "Top07", panel, nil, nil, nil, nil, panel:getContentSize().height * 0.5 + 10, 10)

    -- 隐藏飞升按钮
    self:setCtrlVisible("UpgradeButton", false)

    -- 刷新界面信息
    self:setDlgByType(data.upgrade_type)
    self:setXianMoPhoto(data.upgrade_type)
end

return UserChangeUpgradeDlg
