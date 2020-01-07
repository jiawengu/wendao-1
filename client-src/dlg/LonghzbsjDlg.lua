-- LonghzbsjDlg.lua
-- Created by songcw Nov/28/2016
-- 龙争虎斗时间

local LonghzbsjDlg = Singleton("LonghzbsjDlg", Dialog)

function LonghzbsjDlg:init() 
    -- 获取时间数据
    local data = LongZHDMgr:getTimeData()
    if data then        
        self:setData(data)
        -- 向服务器请求数据 更新
        LongZHDMgr:queryTimeInfo(data.last_ti)
    else
        -- 向服务器请求数据
        LongZHDMgr:queryTimeInfo(0)
    end
    
    self:hookMsg("MSG_LH_GUESS_RACE_INFO")
end

-- 设置数据
function LonghzbsjDlg:setData(data)
    
    -- 界面左上青龙白虎阵营八强选拔赛
    self:setEightInfo(data)
    
    -- 界面左下青龙白虎积分赛
    self:setScoreFightInfo(data)
    
    -- 界面右侧巅峰决赛
    self:setFinalFightInfo(data)
end

-- 界面左上青龙白虎阵营八强选拔赛
function LonghzbsjDlg:setEightInfo(data)
    local panel = self:getControl("TryoutsPanel")
    
    -- 青龙
    self:setLabelText("DragonLabel_2", data.qinglong_seeding_race, panel)
    
    -- 白虎
    self:setLabelText("TigerLabel_2", data.baihu_seeding_race, panel)
    
    -- 刷新panel
    panel:requestDoLayout()
end

-- 界面左下青龙白虎积分赛
function LonghzbsjDlg:setScoreFightInfo(data)
    local panel = self:getControl("PointsracePanel")

    -- 第一至第八场积分赛
    for i = 1, 8 do
        self:setLabelText("ScoreFightTimeLabel_" .. i, data["score_race_day_" .. i], panel)
    end

    -- 刷新panel
    panel:requestDoLayout()
end

-- 界面右侧巅峰决赛
function LonghzbsjDlg:setFinalFightInfo(data)
    local panel = self:getControl("FinalsPanel")

    -- 公布各队积分时间
    self:setLabelText("FristLabel_2", data.race_score_show, panel)

    -- 公布获胜阵营时间
    self:setLabelText("SecondLabel_2", data.win_camp_public, panel)

    -- 公布决战队伍时间
    self:setLabelText("ThirdLabel_2", data.win_final_public, panel)

    -- 公布道王巅峰对决时间
    self:setLabelText("FourthLabel_2", data.final_race, panel)

    -- 刷新panel
    panel:requestDoLayout()
end

-- 设置数据
function LonghzbsjDlg:MSG_LH_GUESS_RACE_INFO(data)
    self:setData(data)
end

return LonghzbsjDlg
