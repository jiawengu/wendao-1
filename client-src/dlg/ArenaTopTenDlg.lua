-- ArenaTopTenDlg.lua
-- Created by songcw Sep/23/2016
-- 十强界面

local ArenaTopTenDlg = Singleton("ArenaTopTenDlg", Dialog)

local YEAR_MAGIN = 5
local SEASON_MAGIN = 5

function ArenaTopTenDlg:init()
    self:bindListener("ChoseButton", self.onChoseButton) 
    
    
    self.unitYearPanel = self:retainCtrl("YearCellPanel")
    self:bindTouchEndEventListener(self.unitYearPanel, self.onChoseYearPanel)
    
    self.unitBigPanel = self:retainCtrl("BigPanel")    
    self.unitBigSelectImage = self:retainCtrl("BChosenEffectImage", self.unitBigPanel)
    self:bindTouchEndEventListener(self.unitBigPanel, self.onChoseSeasonPanel)
    
    self.unitRankPanel = self:retainCtrl("OneRowRankingListPanel")
    self.unitRankSelectImage = self:retainCtrl("ChosenEffectImage", self.unitRankPanel)
    self:bindTouchEndEventListener(self.unitRankPanel, self.onChoseWinnerPanel)
    
    self.yearPanel = self:getControl("YearListPanel")
    self.yearPanelSize = self.yearPanel:getContentSize()
    
    self.selectSeason = nil
    self:hookMsg("MSG_COMPETE_TOURNAMENT_TOP_USER_INFO")
    
    self:setData()
end


-- 设置界面数据
function ArenaTopTenDlg:setData()
    local data = RingMgr:getSeasonTitleData()
    self:setYearList(data)
end

-- 设置年度
function ArenaTopTenDlg:setYearList(data)
    local yearList = self:resetListView("YearListView", YEAR_MAGIN, ccui.ListViewGravity.centerHorizontal)
    local yearPanel = self:getControl("YearListPanel")
    local count = data.startYear - data.endYear + 1
    
    -- 自适应高度
    local size = {width = self.yearPanelSize.width, height = 0}
    local maxDisplayCount = 5
    if count > maxDisplayCount then 
        size.height = self.yearPanelSize.height + (self.unitYearPanel:getContentSize().height + YEAR_MAGIN) * (maxDisplayCount - 1)
    else
        size.height = self.yearPanelSize.height + (self.unitYearPanel:getContentSize().height + YEAR_MAGIN) * (count - 1)
    end    
    yearPanel:setContentSize(size)
    yearList:setContentSize(size.width, size.height - 20)
    
    -- 设置年度列表
    for i = data.startYear, data.endYear, -1 do
        local panel = self.unitYearPanel:clone()
        self:setLabelText("NameLabel", i .. "年度", panel)
        panel.year = i .. "年度"
        panel.data = data[i]
        yearList:pushBackCustomItem(panel)
    end    
    
    -- 如果没有选择，默认选择第一个
    local item = yearList:getItem(0)
    if item then self:onChoseYearPanel(item) end    
    
    -- 刷新
    yearPanel:requestDoLayout()
    yearList:requestDoLayout()
end

-- 点击选择年度按钮
function ArenaTopTenDlg:onChoseButton(sender, eventType)
    local panel = self:getControl("YearListPanel")
    panel:setVisible(not panel:isVisible())
end

-- 点击某个年度
function ArenaTopTenDlg:onChoseYearPanel(sender, eventType)
    self:setLabelText("TitleNameLabel", sender.year, "ChoseButton")
    
    -- 设置季度列表
    self:setSeasonList(sender.data)
    
    -- 隐藏面板
    self:setCtrlVisible("YearListPanel", false)    
end

-- 设置季度列表
function ArenaTopTenDlg:setSeasonList(data)
    local seasonList = self:resetListView("SeasonListView", SEASON_MAGIN, ccui.ListViewGravity.centerHorizontal)
    for i = 1, #data do
        local panel = self.unitBigPanel:clone()
        self:setLabelText("TimeLabel", string.format("%s月%s日赛季", data[i].month, data[i].day), panel)
        panel.data = data[i].seasonData
        seasonList:pushBackCustomItem(panel)
    end    
    
    -- 如果没有选择，默认选择第一个
    local item = seasonList:getItem(0)
    if item then self:onChoseSeasonPanel(item) end  
end

-- 增加季度选择光效
function ArenaTopTenDlg:addSeasonSelectImage(sender)
    self.unitBigSelectImage:removeFromParent()
    sender:addChild(self.unitBigSelectImage)
end

-- 点击某个季度
function ArenaTopTenDlg:onChoseSeasonPanel(sender, eventType)
    -- 选择光效
    self:addSeasonSelectImage(sender)

    local data = RingMgr:getTenWinnerData()
    
    self.selectSeason = sender.data
    
    if data and data[self.selectSeason] then
        -- 设置十强列表
        self:setTenWinnerList(data[self.selectSeason])
    else
        RingMgr:questTenWinner(self.selectSeason)
    end
end

-- 设置十强列表
function ArenaTopTenDlg:setTenWinnerList(data)
    local tenWinnerList = self:resetListView("TenListView", 0, ccui.ListViewGravity.centerHorizontal)
    for i = 1, #data do
        local panel = self.unitRankPanel:clone()
        self:setWinnerData(data[i], panel, i)
        panel.data = data[i]
        tenWinnerList:pushBackCustomItem(panel)
    end    
    
    -- 如果没有选择，默认选择第一个
    local item = tenWinnerList:getItem(0)
    if item then self:onChoseWinnerPanel(item) end  
end

function ArenaTopTenDlg:setWinnerData(data, panel, index)
    -- 排名
    if index == 1 then
        self:setCtrlVisible("OneImage", true, panel)
    elseif index == 2 then
        self:setCtrlVisible("TwoImage", true, panel)
    elseif index == 3 then
        self:setCtrlVisible("ThreeImage", true, panel)
    else
        self:setLabelText("BonusLabel", index, panel)
    end
    
    -- 间隔色
    self:setCtrlVisible("BackImage_2", index % 2 == 0, panel)
    
    -- 名称
    self:setLabelText("NameLabel", data.name, panel)
    
    -- 等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- icon
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), panel)
    self:setItemImageSize("PortraitImage", panel)
    
    -- 名称
    self:setLabelText("LeaderboardLabel", data.score, panel)    
    
    local stage, level = RingMgr:getStepAndLevelByScore(data.score)
    -- 徽章
    self:setImage("SeasonImage", RingMgr:getResIcon(stage), panel)
    -- 星星
    self:setStar(level,panel)
end

-- 增加季度选择光效
function ArenaTopTenDlg:addWinnerSelectImage(sender)
    self.unitRankSelectImage:removeFromParent()
    sender:addChild(self.unitRankSelectImage)
end

-- 点击十强玩家
function ArenaTopTenDlg:onChoseWinnerPanel(sender, eventType)
    -- 选择光效
    self:addWinnerSelectImage(sender)

    -- 设置十强列表
    self:setWinnerInfo(sender.data)
end

-- 设置右侧信息
function ArenaTopTenDlg:setWinnerInfo(data)
    -- 形象
    self:setPortrait("PlayerBodyPanel", data.icon, data.weaponIcon)
    
    -- 仙魔光效
    if data["upgrade/type"] then
        self:addUpgradeMagicToCtrl("PlayerBodyPanel", data["upgrade/type"], nil, true)
    end
    
    local stage, level = RingMgr:getStepAndLevelByScore(data.score)
    -- 徽章
    self:setImage("ShapeSeasonImage", RingMgr:getResIcon(stage))
    
    -- 星星
    self:setStar(level, self:getControl("ShapeStarPanel"))    
    
    -- 当前阶级
    self:setLabelText("RankLabel1", RingMgr:getJobChs(stage, level), "StagePanel", RingMgr:getColor(data.curStage))
    self:updateLayout("StagePanel")
end

-- 根据等级设置星星
function ArenaTopTenDlg:setStar(level, panel)
    for i = 1, 3 do    
        self:setCtrlVisible("StarImage_" .. i, (level >= i), panel)
        self:setCtrlVisible("NoneStarImage_" .. i, (level < i), panel)      
    end
end

function ArenaTopTenDlg:MSG_COMPETE_TOURNAMENT_TOP_USER_INFO(data)
    if self.selectSeason == data.season then
        local data = RingMgr:getTenWinnerData()
        self:setTenWinnerList(data[self.selectSeason])
    end
end

return ArenaTopTenDlg
