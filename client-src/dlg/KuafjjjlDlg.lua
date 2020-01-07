-- KuafjjjlDlg.lua
-- Created by haungzz Jan/05/2018
-- 跨服竞技奖励界面

local KuafjjjlDlg = Singleton("KuafjjjlDlg", Dialog)


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

function KuafjjjlDlg:init()
    self:bindListener("ContinueButton", self.onCloseButton)
    self:setCtrlFullClientEx("BKPanel")

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.KFJJJL, nil, function()
        self:setCtrlVisible("ShareButton", false)
        self:setCtrlVisible("ContinueButton", false)
    end, function()
        self:setCtrlVisible("ShareButton", true)
        self:setCtrlVisible("ContinueButton", true)
    end)
end

function KuafjjjlDlg:setData(data)
    self:setLabelText("TaoLabel", gf:getTaoStr(Me:queryInt("tao"), 0))

    self:setLabelText("SortLabel", string.format(CHS[5400365], gf:changeNumber(data.rank)))

    local key = Me:queryBasicInt("polar") .. Me:queryBasicInt("gender")
    self:setImage("BabyImage1", ROLE_UI_IMAGE[Me:queryBasicInt("polar") .. Me:queryBasicInt("gender")])
end

return KuafjjjlDlg
