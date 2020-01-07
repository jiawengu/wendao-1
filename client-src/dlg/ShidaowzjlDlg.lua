-- ShidaowzjlDlg.lua
-- Created by liuhb Feb/29/2016
-- 试道王者奖励界面

local ShidaowzjlDlg = Singleton("ShidaowzjlDlg", Dialog)

local QMPK_STAGE_TO_ICON =
{
    ["kickout_64"] = ResMgr.ui.qmpk_stage_title_word9,
    ["kickout_32"] = ResMgr.ui.qmpk_stage_title_word1,
    ["kickout_16"] = ResMgr.ui.qmpk_stage_title_word2,
    ["kickout_8"]  = ResMgr.ui.qmpk_stage_title_word3,
    ["kickout_4"]  = ResMgr.ui.qmpk_stage_title_word4,
    ["final_4"]    = ResMgr.ui.qmpk_stage_title_word10,
    ["final_3"]    = ResMgr.ui.qmpk_stage_title_word5,
    ["final_2"]    = ResMgr.ui.qmpk_stage_title_word6,
    ["final_1"]    = ResMgr.ui.qmpk_stage_title_word7,
}

-- 相型对应的原画资源
local POLAR_RAW_PIC = {
    [POLAR.METAL..GENDER_TYPE.MALE]  = ResMgr.ui.metal_male_back,
    [POLAR.METAL..GENDER_TYPE.FEMALE] = ResMgr.ui.metal_female_back,
    [POLAR.WOOD..GENDER_TYPE.MALE] = ResMgr.ui.wood_male_back,
    [POLAR.WOOD..GENDER_TYPE.FEMALE] = ResMgr.ui.wood_female_back,
    [POLAR.WATER..GENDER_TYPE.MALE] = ResMgr.ui.water_male_back,
    [POLAR.WATER..GENDER_TYPE.FEMALE] = ResMgr.ui.water_female_back,
    [POLAR.FIRE..GENDER_TYPE.MALE] =  ResMgr.ui.fire_male_back,
    [POLAR.FIRE..GENDER_TYPE.FEMALE] = ResMgr.ui.fire_female_back,
    [POLAR.EARTH..GENDER_TYPE.MALE] =  ResMgr.ui.earth_male_back,
    [POLAR.EARTH..GENDER_TYPE.FEMALE] = ResMgr.ui.earth_female_back,

}

-- 人数对应的间隔
local NUM_DELTA = {
    [1] = 20,
    [2] = 20,
    [3] = 20,
    [4] = 10,
}

-- 名人争霸赛显示称谓图片
local MRZB_IMAGE = {
    [1]  = ResMgr.ui.mrzb_rank_1,    [2]   = ResMgr.ui.mrzb_rank_2,   [4]  = ResMgr.ui.mrzb_rank_4,
    [8]  = ResMgr.ui.mrzb_rank_8,    [16]  = ResMgr.ui.mrzb_rank_16,  [32] = ResMgr.ui.mrzb_rank_32,
    [64] = ResMgr.ui.mrzb_rank_64,   [128] = ResMgr.ui.mrzb_rank_128,
}

function ShidaowzjlDlg:init(shareType)
    self:bindListener("ContinueButton", self.onContinueButton)

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), shareType, nil, function()
        self:setCtrlVisible("ShareButton", false)
        self:setCtrlVisible("ContinueButton", false)
    end, function()
        self:setCtrlVisible("ShareButton", true)
        self:setCtrlVisible("ContinueButton", true)
    end)

    self.memberImage = self:getControl("MemberImage")
    self.memberImage:retain()
    self.memberImage:removeFromParent()

    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel")

    local meInfo = ShiDaoMgr:getMeShidwzInfo()
    local otherInfo = ShiDaoMgr:getOtherShidwzInfo()
    local count = ShiDaoMgr:getShidwzInfoCount()
    self:initView(meInfo, otherInfo, count)


    self:getControl("MainBodyPanel"):setContentSize(self:getWinSize())
end

function ShidaowzjlDlg:cleanup()
    self:releaseCloneCtrl("memberImage")
end

-- 设置奖励标题
function ShidaowzjlDlg:setTitle(type, data)
    self:setCtrlVisible("WangzImage", false)
    self:setCtrlVisible("KuafwzImage_1", false)
    self:setCtrlVisible("KuafwzImage_2", false)
    self:setCtrlVisible("KuafwzImage_3", false)
    self:setCtrlVisible("KuafwzImage_4", false)
    self:setCtrlVisible("KuafwzPanel", false)
    self:setCtrlVisible("QuanmPKPanel", false)
    self:setCtrlVisible("MingrzbPanel", false)

    if type == 1 then
        -- 跨服试道
        self:setCtrlVisible("KuafwzPanel", true)
        self:setCtrlVisible("KuafwzImage_1", true)
        if data.rank == 1 then
            self:setCtrlVisible("KuafwzImage_3", true)
        elseif data.rank == 2 then
            self:setCtrlVisible("KuafwzImage_2", true)
        else
            self:setCtrlVisible("KuafwzImage_4", true)
        end
    elseif type == 2 then
        -- 全民PK
        self:setCtrlVisible("QuanmPKPanel", true)
        self:setCtrlVisible("QuanmPKImage_1", true)
        self:setCtrlVisible("QuanmPKImage_2", true)
        local image = self:getControl("QuanmPKImage_2")
        image:loadTexture(QMPK_STAGE_TO_ICON[data.stage])
    elseif type == 3 then
        self:setCtrlVisible("MingrzbPanel", true)

        local meInfo = ShiDaoMgr:getMeMRZBInfo()
        local otherInfo = ShiDaoMgr:getOtherMRZBInfo()
        local count = ShiDaoMgr:getMRZBInfoCount()
        self:initView(meInfo, otherInfo, count)
        self:setImage("MingrzbImage_2", MRZB_IMAGE[data.bonus_type])
    else
        -- 试道王者
        self:setCtrlVisible("WangzImage", true)
    end
end

-- 初始化界面
function ShidaowzjlDlg:initView(meInfo, otherInfo, count)
    local panel = self:getControl("MembersPanel")
    panel:setVisible(true)

    if not meInfo or not otherInfo then return end

    assert(#otherInfo < 5)
    local contentSize = self.memberImage:getContentSize()
    local winSize = self:getWinSize()
    panel:setContentSize(cc.size(winSize.width, panel:getContentSize().height))

    local posX = winSize.width / 2
    if 0 == count % 2 then
        posX = posX - contentSize.width / 2
    end

    -- 自己在中间
    -- 先创建自己的数据
    local meImage = self:createPanel(meInfo)
    meImage:setPositionX(posX)
    panel:addChild(meImage)

    -- 然后创建别人的数据
    local size = #otherInfo
    for i = 1, size do
        local otherImage = self:createPanel(otherInfo[i])
        panel:addChild(otherImage)
        local pos = i - math.floor(size / 2)
        local delta = NUM_DELTA[size]
        if pos <= 0 then
            pos = pos - 1
        end

        otherImage:setPositionX(posX + (pos * contentSize.width + delta * pos))
    end
end

-- 创建一个panel
function ShidaowzjlDlg:createPanel(info)
    local image = self.memberImage:clone()

    -- 等级
    self:setLabelText("LevelLabel", info["level"], image)

    -- 名字
    self:setLabelText("NameLabel_1", gf:getRealName(info["name"]), image)
    self:setLabelText("NameLabel_2", gf:getRealName(info["name"]), image)

    local gender = gf:getGenderByIcon(info.icon)
    local key = info.polar .. gender
    -- 图片
    image:loadTexture(POLAR_RAW_PIC[key])

    return image
end

function ShidaowzjlDlg:onContinueButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

return ShidaowzjlDlg
