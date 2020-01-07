-- QuanmPK2fxDlg.lua
-- Created by lixh Jul/16/2018
-- 全民PK赛第2版 分享界面

local QuanmPK2fxDlg = Singleton("QuanmPK2fxDlg", Dialog)

-- 淘汰赛标题
local TITLE_CFG = {
    ["kickout_64"] = ResMgr.ui.qmpk_taotai_128,
    ["kickout_32"] = ResMgr.ui.qmpk_taotai_64,
    ["kickout_16"] = ResMgr.ui.qmpk_taotai_32,
    ["kickout_8"]  = ResMgr.ui.qmpk_taotai_16,
    ["kickout_4"]  = ResMgr.ui.qmpk_taotai_8,
    ["kickout_2"]  = ResMgr.ui.qmpk_taotai_4,
    ["final_4"]    = ResMgr.ui.qmpk_taotai_3,
    ["final_3"]    = ResMgr.ui.qmpk_taotai_2,
    ["final_2"]    = ResMgr.ui.qmpk_taotai_1,
    ["final_1"]    = ResMgr.ui.qmpk_taotai_0,
}

-- 总决赛结束后标题
local CHENGWEI_CFG = {
    ["kickout_64"] = ResMgr.ui.qmpk_title_yxhj,
    ["kickout_32"] = ResMgr.ui.qmpk_title_rhzs,
    ["kickout_16"] = ResMgr.ui.qmpk_title_rzzl,
    ["kickout_8"]  = ResMgr.ui.qmpk_title_fhxl,
    ["kickout_4"]  = ResMgr.ui.qmpk_title_dxst,
    -- 没有["kickout_2"]
    ["final_4"]    = ResMgr.ui.qmpk_title_yrdq,
    ["final_3"]    = ResMgr.ui.qmpk_title_wfmd,
    ["final_2"]    = ResMgr.ui.qmpk_title_bsgs,
    ["final_1"]    = ResMgr.ui.qmpk_title_txwd,
}

-- 角色形象
local QMPK_ROLE_UI_IMAGE =
{
    [6001] = ResMgr.ui.qmpk_metal_male,
    [7001] = ResMgr.ui.qmpk_metal_female,
    [7002] = ResMgr.ui.qmpk_wood_male,
    [6002] = ResMgr.ui.qmpk_wood_female,
    [7003] = ResMgr.ui.qmpk_water_male,
    [6003] = ResMgr.ui.qmpk_water_female,
    [6004] = ResMgr.ui.qmpk_fire_male,
    [7004] = ResMgr.ui.qmpk_fire_female,
    [6005] = ResMgr.ui.qmpk_earth_male,
    [7005] = ResMgr.ui.qmpk_earth_female,
}

function QuanmPK2fxDlg:init()
    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.QUANMINPK, nil, function()
        self:setCtrlVisible("ShareButton", false)
    end, function()
        self:setCtrlVisible("ShareButton", true)
    end)

    QuanminPK2Mgr:requestQmpkMyData()
end

function QuanmPK2fxDlg:setData()
    local data = QuanminPK2Mgr:getMyData()
    if not data then return end

    -- 标题
    local titleRoot = self:getControl("MainBodyPanel")
    self:setCtrlVisible("TitlePanel_1", false, titleRoot)
    self:setCtrlVisible("TitlePanel_2", false, titleRoot)
    if gf:getServerTime() >= data.bonusTime and CHENGWEI_CFG[data.curResult] then
        -- 已经过了奖励时间，则结果显示称谓
        self:setCtrlVisible("TitlePanel_2", true, titleRoot)
        local titlePanel2 = self:getControl("TitlePanel_2", Const.UIPanel, titleRoot)
        self:setImage("TitleImage", CHENGWEI_CFG[data.curResult], titlePanel2)
    else
        if TITLE_CFG[data.curResult] then
            self:setCtrlVisible("TitlePanel_2", true, titleRoot)
            local titlePanel2 = self:getControl("TitlePanel_2", Const.UIPanel, titleRoot)
            self:setImage("TitleImage", TITLE_CFG[data.curResult], titlePanel2)
        else
            self:setCtrlVisible("TitlePanel_1", true, titleRoot)
            local scoreLabel = self:getControl("AtlasLabel0002", Const.UIAtlasLabel)
            scoreLabel:setString(data.score)
        end
    end

    -- 玩家队伍形象
    for i = 1, 5 do
        local info = data.list[i]
        if info then
            self:setCtrlVisible("PlayerPanel_" .. i, true)
            local root = self:getControl("PlayerPanel_" .. i, Const.UIPanel)
            self:setLabelText("LevelLabel", info.level, root)
            self:setLabelText("NameLabel", info.name, root)
            self:setImage("PortraitImage", QMPK_ROLE_UI_IMAGE[info.icon], root)
        else
            self:setCtrlVisible("PlayerPanel_" .. i, false)
        end
    end
end

return QuanmPK2fxDlg
