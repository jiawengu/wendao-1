-- WorldBossLifeDlg.lua
-- Created by huangzz Jan/24/2018
-- 世界BOSS 血量界面

local WorldBossLifeDlg = Singleton("WorldBossLifeDlg", Dialog)

-- 每种血条对应的图片
local LIFE_BAR = {
    [1] = {icon = ResMgr.ui.boss_life_bar_red},
    [2] = {icon = ResMgr.ui.boss_life_bar_yellow},
    [3] = {icon = ResMgr.ui.boss_life_bar_green},
    [4] = {icon = ResMgr.ui.boss_life_bar_blue},
    [5] = {icon = ResMgr.ui.boss_life_bar_purple},
}

function WorldBossLifeDlg:init()
    self:setFullScreen()
    self:bindListener("RankListButton", self.onRankListButton)
    
    self.bar = {}
    
    self:initLiftBar()
    
    local function func()
        WorldBossMgr:requestLifeData()
    end
    
    func()
    
    -- 10s 刷新一下血量 
    self:startSchedule(func, 10)
    
    DlgMgr:sendMsg("MissionDlg", "onShowMissionButton")
    
    self:hookMsg("MSG_WORLD_BOSS_LIFE")
end

function WorldBossLifeDlg:initLiftBar()
    local panel = self:getControl("LifePanel")
    local bar = self:getControl("ProgressBar", nil, panel)
    self.bar[2] = bar
    self.bar[1] = bar:clone()
    panel:addChild(self.bar[1], 2, 2)
end

function WorldBossLifeDlg:onRankListButton(sender, eventType)
    WorldBossMgr:requestRankData()
end

function WorldBossLifeDlg:setView(data)
    -- 名称
    -- self:setLabelText("BossNameLabel", data.name, "BossPanel")
    
    -- 剩余血量
    local totalNum = #LIFE_BAR
    local oneLife = data.total_life / totalNum       -- 单条血条满血的血量
    local num = math.floor(data.left_life / oneLife) -- 剩余几条满血条
    local lastLeftLife = data.left_life % oneLife    -- 当前显示血条的剩余血量
    
    if num == 0 then
        self.bar[2]:setPercent(0)
    else
        self.bar[2]:loadTexture(LIFE_BAR[num].icon)
        self.bar[2]:setPercent(100)
    end
    
    if lastLeftLife > 0 and num < #LIFE_BAR then
        self.bar[1]:loadTexture(LIFE_BAR[num + 1].icon)
        self.bar[1]:setPercent(math.floor(lastLeftLife / oneLife * 100))
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.S_FIGHT, num + 1, false, LOCATE_POSITION.MID, 25, "LifePanel")
    else
        self.bar[1]:setPercent(0)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.S_FIGHT, num, false, LOCATE_POSITION.MID, 25, "LifePanel")
    end
end

function WorldBossLifeDlg:MSG_WORLD_BOSS_LIFE(data)
    data.total_life = tonumber(data.max_life_str) or 0
    data.left_life = tonumber(data.life_str) or 0
    if data.total_life == 0 then
        data.total_life = #LIFE_BAR
    end
    
    self:setView(data)
end

function WorldBossLifeDlg:cleanup()
    self.bar = nil
    
    DlgMgr:sendMsg("MissionDlg", "onShowDialogButton")
end

return WorldBossLifeDlg
