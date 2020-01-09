-- UserCardDlg.lua
-- Created by zhengjh 26/Dec/2015
-- 角色名片

local UserCardDlg = Singleton("UserCardDlg", Dialog)

local LIGHT_EFFECTS = require("cfg/LightEffect")

-- 相型对应的中文类别信息
local POLAR_TO_CHS = {
    [POLAR.METAL]     = CHS[3000253], -- 金系
    [POLAR.WOOD]      = CHS[3000256], -- 木系
    [POLAR.WATER]     = CHS[3000259], -- 水系
    [POLAR.FIRE]      = CHS[3000261], -- 火系
    [POLAR.EARTH]     = CHS[3000263], -- 土系
}

-- name 名字
-- "level" 等级
-- "max_life" 气血
-- "max_mana"  法力
-- "phy_power"  物伤
-- "mag_power"  法伤
-- "speed"  速度
-- "def"   防御
-- "tao" 道行
-- "tao_ex"
-- "icon"  默认ICON
-- "suit_icon" 套装ICON
--  weapon_icon
function UserCardDlg:init()
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("TaoButton", self.onTaoButton)

    self:bindFloatPanelListener("TaoOtherPanel")
end

function UserCardDlg:onTaoButton()
    self:setCtrlVisible("TaoOtherPanel", true)
end

function UserCardDlg:setCharInfo(data)
    self:setLabelText("NameValueLabel", gf:getRealName(data.name))

    -- 门派，相性
    self:setLabelText("PolarValueLabel", POLAR_TO_CHS[data.polar])

    -- 真身等级
    self:setLabelText("LevelValueLabel", string.format(CHS[7120028], data.level))

    if data["upgrade/level"] == 0 then
        self:setLabelText("BabyLabel", CHS[7120029])
        self:setLabelText("BabyValueLabel", CHS[7120031])
    else
        if CHS[4100561] == gf:getChildName(data["upgrade/type"]) then
            self:setLabelText("BabyLabel", CHS[7120030])
        else
            self:setLabelText("BabyLabel", CHS[7120029])
        end

        self:setLabelText("BabyValueLabel", string.format(CHS[7120028], data["upgrade/level"]))
    end

    -- 内丹修炼
    self:setLabelText("InnerValueLabel", CHS[7120047], "InnerPanel")
    if InnerAlchemyMgr:isInnerAlchemyOpen(data["upgrade/level"], data["upgrade/type"]) then
        local danState = tonumber(data["dan_data/state"])
        local danStage = tonumber(data["dan_data/stage"])
        if danState and danStage and danState > 0 and danStage > 0 then
            self:setLabelText("InnerValueLabel", string.format(CHS[7120048], InnerAlchemyMgr:getAlchemyState(danState), InnerAlchemyMgr:getAlchemyStage(danStage)), "InnerPanel")
        end
    end

    self:setLabelText("LifeValueLabel", data.max_life)
    self:setLabelText("ManaValueLabel", data.max_mana)
    self:setLabelText("PhyValueLabel", data.phy_power)
    self:setLabelText("SpeedValueLabel", data.speed)
    self:setLabelText("MagValueLabel", data.mag_power)
    self:setLabelText("DefenceValueLabel", data.def)
    self:setLabelText("TaoValueLabel", gf:getTaoStr(data.tao, data.tao_ex or 0))
    self:setLabelText("IDLabel", gf:getShowId(data.gid))

    -- 
    self:setLabelText("Label2", gf:getTaoStr(data.mon_tao or 0, data.mon_tao_ex), "MonthTaoPanel")
    self:setLabelText("Label2", gf:getTaoStr(data.last_mon_tao or 0, data.last_mon_tao_ex), "MonthTaoPanel_1")

    local step, level = RingMgr:getStepAndLevelByScore(data["ct_data/score"])
    local color = RingMgr:getColor(step)
    if step == 1 then color = cc.c3b(128, 128, 128) end -- 特殊要求这个界面新手显示这个颜色
    self:setLabelText("RankingLabel_1", RingMgr:getJobChs(step, level), nil, color)
    self:setLabelText("RankingLabel_bk", RingMgr:getJobChs(step, level))

    self:updateLayout("IDPanel")

    -- 设置角色形象
    local icon = data.icon
    if data.special_icon and data.special_icon ~= 0 then
        icon = data.special_icon
    elseif data.suit_icon and data.suit_icon ~= 0 then
        icon = data.suit_icon
    end

    local weaponIcon = data.weapon_icon
    if data.special_icon and data.special_icon ~= 0 then
        -- 变身情况下不需要显示武器
        weaponIcon = 0
    end

    self:setPortrait("UserIconPanel", icon, weaponIcon, self.root, true, nil, nil, nil, data.icon, nil, nil, nil, nil, data.part_index, data.part_color_index)
    self:setPortrait("UserIconPanel", data.follow_icon, 0, self.root, nil, nil, nil, cc.p(-35, -55), 0, nil, nil, Dialog.TAG_PORTRAIT1)
    if data.follow_icon ~= 0 then
        local acts = gf:getAllActionByIcon(data.follow_icon, {[Const.SA_STAND] = true, [Const.SA_DIE] = true})
        self:displayPlayActions("UserIconPanel", nil, cc.p(-35, -55), Dialog.TAG_PORTRAIT1, acts)
    end

    -- 仙魔图片
    self:removeUpgradeMagicToCtrl("UserIconPanel")
    if data["upgrade/type"] and (data["upgrade/type"] == CHILD_TYPE.UPGRADE_MAGIC or data["upgrade/type"] == CHILD_TYPE.UPGRADE_IMMORTAL) then
        self:setCtrlVisible("UnUpgradeBKImage", false)
        self:setCtrlVisible("MoBKPanel", data["upgrade/type"] == CHILD_TYPE.UPGRADE_MAGIC)
        self:setCtrlVisible("XianBKPanel", data["upgrade/type"] == CHILD_TYPE.UPGRADE_IMMORTAL)
    else
        self:setCtrlVisible("UnUpgradeBKImage", true)
        self:setCtrlVisible("MoBKPanel", false)
        self:setCtrlVisible("XianBKPanel", false)
    end

    if data.light_effect then
        local followMagic
        for i = 1, #data.light_effect do
            local magic = LIGHT_EFFECTS[gf:tryConvertMagicKey(data.light_effect[i], icon)]
            if not magic.follow_dis then
                self:addMagicToCtrl("UserIconPanel", magic.icon, self.root, magic.pos, 5, magic.extraPara)
            else
                followMagic = magic
            end
        end

        if followMagic then
            self:displayPlayActions("UserIconPanel", nil, nil, Dialog.TAG_PORTRAIT, { Const.SA_WALK }, function(act)
                if Const.SA_WALK == act then
                    self:addMagicToCtrl("UserIconPanel", followMagic.icon, self.root, followMagic.pos, 5, followMagic.extraPara)
                else
                    self:removeMagicFromCtrl("UserIconPanel", followMagic.icon, self.root)
                end
            end)
        end
    end
end

function UserCardDlg:onRightButton(sender, eventType)
    DlgMgr:sendMsg("TeamEnlistDlg", "getNextUserCard")
end

function UserCardDlg:onLeftButton(sender, eventType)
    DlgMgr:sendMsg("TeamEnlistDlg", "getLastUserCard")
end

return UserCardDlg
