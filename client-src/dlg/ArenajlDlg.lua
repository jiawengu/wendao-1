-- ArenajlDlg.lua
-- Created by songcw Sep/25/2016
-- 擂台分享

local ArenajlDlg = Singleton("ArenajlDlg", Dialog)

function ArenajlDlg:init()
    self:setCtrlFullClient("Image_25", "Panel_24")
    self:setImage("Image_26", ResMgr:getUserDlgPolarBgImg(Me:queryBasicInt("polar"), Me:queryBasicInt("gender")))

    local stage, level = RingMgr:getStepAndLevelByScore(Me:queryBasicInt("ct_data/score"))
    self:setImage("SeasonImage", RingMgr:getResIcon(stage))

    -- 设置星星
    self:setStar(level, self:getControl("StarPanel"))

    self:setLabelText("RankLabel1", RingMgr:getJobChs(stage, level))
end

-- 根据等级设置星星
function ArenajlDlg:setStar(level, panel)
    for i = 1, 3 do
        self:setCtrlVisible("StarImage_" .. i, (level >= i), panel)
        self:setCtrlVisible("NoneStarImage_" .. i, (level < i), panel)
    end
end

return ArenajlDlg
