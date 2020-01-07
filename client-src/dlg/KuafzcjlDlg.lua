-- KuafzcjlDlg.lua
-- Created by
--

local KuafzcjlDlg = Singleton("KuafzcjlDlg", Dialog)

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

function KuafzcjlDlg:init()
    self:setCtrlFullClientEx("BKPanel")
    self:bindListener("ContinueButton", self.onCloseButton)

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.KFZCJL, nil, function()
        self:setCtrlVisible("ShareButton", false)
        self:setCtrlVisible("ContinueButton", false)
    end, function()
        self:setCtrlVisible("ShareButton", true)
        self:setCtrlVisible("ContinueButton", true)
    end)
end


function KuafzcjlDlg:setData(data)

    if string.match(data.title, CHS[4100703]) then    -- 王者无敌
        self:setCtrlVisible("KuafzcImage_2", true)
    elseif string.match(data.title, CHS[4100705]) then  -- 万人之上
        self:setCtrlVisible("KuafzcImage_3", true)
    elseif string.match(data.title, CHS[4100706]) then  -- 名列三甲
        self:setCtrlVisible("KuafzcImage_4", true)
    elseif string.match(data.title, CHS[4100707]) then  -- 中流砥柱
        self:setCtrlVisible("KuafzcImage_5", true)
    end

    self:setLabelText("LevelValueLabel", Me:queryBasicInt("level"))

    self:setLabelText("TaoLabel", gf:getTaoStr(Me:queryInt("tao"), Me:queryInt("tao_ex")))

    self:setLabelText("ContribValueLabel", data.contrib)

    self:setLabelText("SortLabel", string.format(CHS[4200438], gf:changeNumber(data.rank)))

    local key = Me:queryBasicInt("polar") .. Me:queryBasicInt("gender")
    self:setImage("BabyImage1", ROLE_UI_IMAGE[Me:queryBasicInt("polar") .. Me:queryBasicInt("gender")])

end


function KuafzcjlDlg:onShareButton(sender, eventType)
end

return KuafzcjlDlg
