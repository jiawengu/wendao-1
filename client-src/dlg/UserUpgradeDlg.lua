-- UserUpgradeDlg.lua
-- Created by lixh Nov/8/2017
-- 角色飞升界面

local UserUpgradeDlg = Singleton("UserUpgradeDlg", Dialog)

-- 飞仙，飞魔对应Panel名称
local XIAN_MO_PANEL = {"XianPanel", "MoPanel"}

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

function UserUpgradeDlg:init()
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel", nil, true)
    self:bindListener("ColseButton", self.onCloseButton)
    self:bindListener("UpgradeButton", self.onUpgradeButton)
    self:bindListener("NoteButton", self.onNoteButton)

    self:setImage("ShapeImage", ROLE_UI_IMAGE[Me:queryBasicInt("polar") .. Me:queryBasicInt("gender")], "PlayerPanel")

    self:setDlgByType(Me:getChildType() == 1 and 1 or 2)

    self:hookMsg("MSG_ENTER_ROOM")
    self:hookMsg("MSG_CHAR_UPGRADE_COAGULATION")
end

-- 根据type设置界面类型
-- 元婴：type = 1 血婴：type = 2
function UserUpgradeDlg:setDlgByType(type)
    local panelName = XIAN_MO_PANEL[type]
    self:setCtrlVisible("XianPanel", panelName == "XianPanel")
    self:setCtrlVisible("MoPanel", panelName == "MoPanel")

    -- 5方向人物形象与光效
    local icon = nil
    if Me:queryBasicInt("suit_icon") ~= 0 and gf:isShowSuit() then
       icon = Me:queryBasicInt("suit_icon")
    else
        icon = Me:queryBasicInt('icon')
    end

    self:setPortrait("BKImage_2", icon, InventoryMgr:getMeUsingWeaponIcon(), panelName, nil, nil, nil, nil, Me:queryBasicInt("icon"))
    self:addUpgradeMagicToCtrl("BKImage_2", type == 1 and 3 or 4, panelName, true)

    self:setLabelText("ConfrimLabel1", panelName == "XianPanel" and CHS[7190112] or CHS[7190113], "UpgradeButton")
    self:setLabelText("ConfrimLabel2", panelName == "XianPanel" and CHS[7190112] or CHS[7190113], "UpgradeButton")
    self:setCtrlVisible("UpgradeButton", true)
end

function UserUpgradeDlg:onUpgradeButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 战斗中
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000281])
        return
    end

    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 1})
end

function UserUpgradeDlg:onNoteButton(sender, eventType)
    DlgMgr:openDlg("UserUpgradeRuleDlg")
end

function UserUpgradeDlg:onCloseButton()
    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
    Dialog.onCloseButton(self)
end

function UserUpgradeDlg:MSG_ENTER_ROOM()
    self:onCloseButton()
end

function UserUpgradeDlg:MSG_CHAR_UPGRADE_COAGULATION(data)
    -- 飞升成功动画
    local panel = self:getControl("PlayerPanel")
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.jieying.name, "Top06", panel, nil, nil, nil, nil, panel:getContentSize().height * 0.5 + 10, panel:getLocalZOrder() + 1)

    -- 隐藏飞升按钮
    self:setCtrlVisible("UpgradeButton", false)

    -- 正中角色形象光效
    local userImage = self:getControl("BKImage")
    if data and data.upgrade_type == CHILD_TYPE.UPGRADE_IMMORTAL then
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_immortal_top, userImage, Const.ARMATURE_MAGIC_TAG)
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_immortal_bottom, userImage, Const.ARMATURE_MAGIC_TAG + 1)
    elseif data and data.upgrade_type == CHILD_TYPE.UPGRADE_MAGIC then
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_magic_top, userImage, Const.ARMATURE_MAGIC_TAG)
        gf:createArmatureMagic(ResMgr.ArmatureMagic.upgrade_magic_bottom, userImage, Const.ARMATURE_MAGIC_TAG + 1)
    end
end

return UserUpgradeDlg
