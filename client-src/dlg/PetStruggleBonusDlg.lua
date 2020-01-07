-- PetStruggleBonusDlg.lua
-- Created by huangzz Sep/20/2017
-- 斗宠大会奖励界面

local PetStruggleBonusDlg = Singleton("PetStruggleBonusDlg", Dialog)

local PET_POLAR_BG = {
    [POLAR.METAL] = ResMgr.ui.dcdh_reward_bg_metal,
    [POLAR.WOOD] = ResMgr.ui.dcdh_reward_bg_wood,
    [POLAR.WATER] = ResMgr.ui.dcdh_reward_bg_water,
    [POLAR.FIRE] = ResMgr.ui.dcdh_reward_bg_fire,
    [POLAR.EARTH] = ResMgr.ui.dcdh_reward_bg_earth,
}

function PetStruggleBonusDlg:init(data)
    self:setCtrlFullClient("BackImage_1", "BackPanel", true)
    self:bindListener("ContinueButton", self.onCloseButton)

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.DCDHJL, nil, function()
        self:setCtrlVisible("ShareButton", false)
        self:setCtrlVisible("ContinueButton", false)
    end, function()
        self:setCtrlVisible("ShareButton", true)
        self:setCtrlVisible("ContinueButton", true)
    end)

    self.memberImage = self:retainCtrl("MemberImage")

    self:initListPanel(data)
end

function PetStruggleBonusDlg:initListPanel(data)
    if not data then return end
    local cou = #data
    local size = self.memberImage:getContentSize()
    local panel = self:getControl("MembersPanel")
    local panelSize = panel:getContentSize()
    local beginX = panelSize.width / 2 - (size.width + 1) * (cou - 1) / 2

    for i = 1, cou do
        local cell = self.memberImage:clone()
        cell:setPositionX(beginX + (i - 1) * (size.width + 1))
        self:setOneRewardPanel(data[i], cell)
        panel:addChild(cell)
    end

    -- 赛季
    local str = CHS[5400295] .. self:getRankStr(data.rank)
    self:setLabelText("Label", data.seasonStr .. "  " .. CHS[4100386] .. "    " .. str, "RankPanel")

    -- 称谓
    if data.rank <= 3 then
        self:setCtrlVisible("KuafwzImage_2", true)
        self:setCtrlVisible("KuafwzImage_3", false)
        self:setCtrlVisible("KuafwzImage_4", false)
    elseif data.rank <= 10 then
        self:setCtrlVisible("KuafwzImage_2", false)
        self:setCtrlVisible("KuafwzImage_3", true)
        self:setCtrlVisible("KuafwzImage_4", false)
    else
        self:setCtrlVisible("KuafwzImage_2", false)
        self:setCtrlVisible("KuafwzImage_3", false)
        self:setCtrlVisible("KuafwzImage_4", true)
    end
end

function PetStruggleBonusDlg:getRankStr(rank)
    if rank <= 10 then
        return gf:changeNumber(rank)
    else
        local num = rank % 10
        if num == 0 then
            return gf:changeNumber(math.floor(rank / 10)) .. CHS[6000064]
        else
            return gf:changeNumber(math.floor(rank / 10)) .. CHS[6000064] .. gf:changeNumber(num)
        end
    end
end

function PetStruggleBonusDlg:setOneRewardPanel(data, cell)
    -- 背景
    local iconPath = PET_POLAR_BG[data.polar]
    if iconPath then
        cell:loadTexture(iconPath)
    else
        cell:loadTexture(ResMgr.ui.dcdh_reward_bg_none)
    end

    -- 形象
    local shape = self:getControl("ShapePanel", nil, cell)
    local img = ccui.ImageView:create(ResMgr:getBigPortrait(data.icon))
    img:setPosition(shape:getContentSize().width / 2, 0)
    img:setAnchorPoint(0.5, 0)
    shape:addChild(img)

    -- 等级
    self:setLabelText("LevelLabel_2", data.level, cell)

    -- 名字
    self:setLabelText("NameLabel_1", data.name, cell)
    self:setLabelText("NameLabel_2", data.name, cell)

    -- 武学
    local martialStr = CHS[5410085] .. " " .. data.martial
    self:setLabelText("MartialLabel_1", martialStr, cell)
    self:setLabelText("MartialLabel_2", martialStr, cell)
end

return PetStruggleBonusDlg
