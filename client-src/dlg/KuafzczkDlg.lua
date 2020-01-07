-- KuafzczkDlg.lua
-- Created by songcw Aug/7/2017
-- 跨服战场，战况

local KuafzczkDlg = Singleton("KuafzczkDlg", Dialog)

function KuafzczkDlg:init()
end

function KuafzczkDlg:setData(data)
    for i = 1, 7 do
        local panel = self:getControl("MatchPanel_" .. i)
        self:setUnitWarInfoPanel(data[i], panel)
    end
end

function KuafzczkDlg:setUnitWarInfoPanel(data, panel)
    if not data then
        data = {start_time = 0, myDist = "", myRet = 0, score = "", enemyDist = ""}
    end


	-- 时间
    if data.start_time == 0 then
        self:setLabelText("TimeLabel", "", panel)
	else
        self:setLabelText("TimeLabel", gf:getServerDate(CHS[4300031], data.start_time), panel)
    end
    
    -- 我的区组
    self:setLabelText("DistLabel_1", data.myDist, panel)
    
    if data.myRet == 1 then
        self:setImagePlist("ResultImage_1", ResMgr.ui.party_war_win, panel)
        self:setImagePlist("ResultImage_2", ResMgr.ui.party_war_lose, panel)
    elseif data.myRet == 2 then
        self:setImagePlist("ResultImage_1", ResMgr.ui.party_war_lose, panel)
        self:setImagePlist("ResultImage_2", ResMgr.ui.party_war_win, panel)
    elseif data.myRet == 3 then
        self:setImagePlist("ResultImage_1", ResMgr.ui.party_war_draw, panel)
        self:setImagePlist("ResultImage_2", ResMgr.ui.party_war_draw, panel)
    else
        self:setImagePlist("ResultImage_1", ResMgr.ui.touming, panel)
        self:setImagePlist("ResultImage_2", ResMgr.ui.touming, panel)
    end
    
    -- 积分
    self:setLabelText("ScoreLabel", data.score, panel)
    
    -- 对方区组
    self:setLabelText("DistLabel_2", data.enemyDist, panel)
end

return KuafzczkDlg
