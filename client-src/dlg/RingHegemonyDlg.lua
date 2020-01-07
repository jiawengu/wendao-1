-- RingHegemonyDlg.lua
-- Created by songcw Sep/22/2016
-- 擂台争霸

local RingHegemonyDlg = Singleton("RingHegemonyDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local Bitset = require("core/Bitset")

local DISPLAY_RADIO = {"RankingCheckBox", "RankExplainCheckBox", "RuleCheckBox"}
local DISPLAY_PANEL = {
    ["RankingCheckBox"] = "RankingPanel",
    ["RankExplainCheckBox"] = "RankExplainPanel",
    ["RuleCheckBox"] = "RulePanel",
}

function RingHegemonyDlg:init()
    self:bindListener("DetailsButton", self.onDetailsButton)
    self:bindListener("BKPanel", self.onDetailsButton)
    
    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.LEITAI)
    
    self.displayType = nil    
    self.myRank = 0
    
    self.unitRankingInfoPanel = self:getControl("OneRowRankingListPanel")
    self.unitRankingInfoPanel:retain() 
    self.unitRankingInfoPanel:removeFromParent()
    
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, DISPLAY_RADIO, self.onCheckBoxClick)
    self.radioGroup:setSetlctByName("RankingCheckBox")
    self:onCheckBoxClick(self:getControl("RankingCheckBox"))
    
    self:setMyRingData()
    
    local scrollview = self:getControl("ScrollView")
    local infoPanel = self:getControl("LablePanel")
    scrollview:setInnerContainerSize(infoPanel:getContentSize())
    
    self:hookMsg('MSG_CHAR_INFO')
    self:hookMsg("MSG_COMPETE_TOURNAMENT_PREVIOUS_INFO")
end

function RingHegemonyDlg:cleanup()
    self:releaseCloneCtrl("unitRankingInfoPanel")
end

function RingHegemonyDlg:onCheckBoxClick(sender, eventType)
    self.displayType = sender:getName()
    self:setCtrlVisible("RankExplainPanel1", false)
    self:setCtrlVisible("RulePanel1", false)
    for checkBox, panel in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(panel, false)
    end
    
    if self.displayType == "RankExplainCheckBox" then
        if RingMgr:isNewRule() then
            self:setCtrlVisible("RankExplainPanel", true)
        else
            self:setCtrlVisible("RankExplainPanel1", true)
        end
    elseif self.displayType == "RuleCheckBox" then
        if RingMgr:isNewRule() then
            self:setCtrlVisible("RulePanel", true)
        else
            self:setCtrlVisible("RulePanel1", true)
        end
    else
        self:setCtrlVisible(DISPLAY_PANEL[self.displayType], true)
    end    
end

function RingHegemonyDlg:setMyRingData()
    local data = RingMgr:getRingData()
    local rankingPanel = self:getControl("RankingPanel")
    
    -- 当前赛季
    self:setLabelText("SeasonLabel", data.curSeason .. CHS[4100386])
    self:updateLayout("SeasonPanel", rankingPanel)
    
    local stage, level, nextScore = RingMgr:getStepAndLevelByScore(Me:queryBasicInt("ct_data/score"))
    
    -- 当前徽章
    self:setImage("SeasonImage", RingMgr:getResIcon(stage))
    
    -- 当前阶级
    self:setLabelText("RankStageLabel", RingMgr:getJobChs(stage, level), "StagePanel", RingMgr:getColor(stage))
    self:updateLayout("StagePanel", rankingPanel)
    
    -- 设置星星
    self:setStar(level, self:getControl("StarPanel"))
    
    -- 设置比赛数据（胜负场数）
    self:setMatchData(data)
    
    -- 积分进度条
    self:setScoreBar(data)
    
    -- 设置排行榜列表
    self:setRankingList(data)
    
    -- 设置我的排行
    self:setMyRank()
    
    -- 设置上一季排行
    self:setLastSeason(data)
end

-- 设置上一赛季排名
function RingHegemonyDlg:setLastSeason(data)
    local panel = self:getControl("DetailsPanel")
    
    local stage, level = RingMgr:getStepAndLevelByScore(data.prev_score)
    local jobStr = RingMgr:getJobChs(stage, level)
    self:setLabelText("LastRankLabel", jobStr, panel)
    
    self:setLabelText("LastLeaderboardLabel", data.prev_score, panel)
    
    if data.prev_rank == 0 then
        self:setLabelText("LastBonusLabel", CHS[4100387], panel)
    else
        self:setLabelText("LastBonusLabel", data.prev_rank, panel)
    end
end

-- 设置排名列表
function RingHegemonyDlg:setRankingList(data)
    self:resetListView("RankingListView")
    local rankingInfo = data.curRanking
    self:pushData(rankingInfo)
end

-- 设置我的排行
function RingHegemonyDlg:setMyRank()
    local trophy = {[1] = "OneImage", [2] = "TwoImage", [3] = "ThreeImage"}

    local panel = self:getControl("MyRankingListPanel")
    for _, ctrlName in pairs(trophy) do        
        self:setCtrlVisible(trophy[_], false, panel)
    end
    local myRanl = Me:queryBasicInt("ct_data/top_rank")
    -- 排行
    if myRanl == 0 or myRanl > 5000 then
        self:setLabelText("BonusLabel", CHS[4100388], panel)
    else
        if trophy[myRanl] then
            self:setCtrlVisible(trophy[myRanl], true, panel)
        else
            self:setLabelText("BonusLabel", myRanl,panel )
        end        
    end
    
    -- 名称
    self:setLabelText("NameLabel", Me:getShowName(), panel)
    
    -- 等级
    self:setLabelText("LevelLabel", Me:queryBasic("level"), panel)

    -- 相性
    self:setLabelText("PolarLabel", gf:getPolar(Me:queryBasicInt("polar")), panel)

    -- 积分
    self:setLabelText("LeaderboardLabel", Me:queryBasicInt("ct_data/score"), panel)
    
    local step, curLevel = RingMgr:getStepAndLevelByScore(Me:queryBasicInt("ct_data/score"))
    
    -- 徽章  
    self:setImage("SeasonImage", RingMgr:getResIcon(step), panel)
    
    -- 星星
    self:setStar(curLevel, self:getControl("RankStatisticsPanel", Const.UIPanel, panel))
end

-- 按列表加入listView
function RingHegemonyDlg:pushData(listInfo)
    local listCtrl = self:getControl("RankingListView")
    for i = 1,#listInfo do
        local panel = self.unitRankingInfoPanel:clone()
        if listInfo[i].name == Me:getName() then self.myRank = i end
        self:setUnitRankingInfo(listInfo[i], panel)
        listCtrl:pushBackCustomItem(panel)
    end
end

-- 设置列表单条数据
function RingHegemonyDlg:setUnitRankingInfo(data, panel)
    local listCtrl = self:getControl("RankingListView")
    
    local count = #listCtrl:getItems()
    self:setCtrlVisible("BackImage_2", (count + 1) % 2 == 0, panel)

    -- 名次
    if data.rank == 1 then
        self:setCtrlVisible("OneImage", true, panel)
    elseif data.rank == 2 then
        self:setCtrlVisible("TwoImage", true, panel)
    elseif data.rank == 3 then
        self:setCtrlVisible("ThreeImage", true, panel)
    else
        self:setLabelText("BonusLabel", data.rank, panel)
    end
    
    -- 名称
    self:setLabelText("NameLabel", gf:getRealName(data.name), panel)
    
    -- 等级
    self:setLabelText("LevelLabel", data.level, panel)
    
    -- 相性
    self:setLabelText("PolarLabel", gf:getPolar(data.polar), panel)
    
    -- 积分
    self:setLabelText("LeaderboardLabel", data.score, panel)
    
    local stage, level = RingMgr:getStepAndLevelByScore(data.score)
    
    -- 徽章
    self:setImage("SeasonImage", RingMgr:getResIcon(stage), panel)
    
    -- 星星
    self:setStar(level, self:getControl("RankStatisticsPanel", Const.UIPanel, panel))
    
    panel.data = data
    self:bindTouchEndEventListener(panel, self.clickPlayer)
end

-- 点击排名
function RingHegemonyDlg:clickPlayer(sender)
    local info = sender.data
 
    -- 个人排行需要显示弹出菜单
    if info.name == Me:getName() then
        -- 点击的是玩家自己，不用弹菜单
        return
    end

    self.menuInfo = { CHS[3000056], CHS[3000057] }

    if not (FriendMgr:isBlackByGId(info.gid) or FriendMgr:hasFriend(info.gid)) then
        -- 不在黑名单中也不在好友列表中，添加“加为好友”菜单项
        self.menuInfo[3] = CHS[3000058]
    end

    self.menuInfo.char = info.name
    self.menuInfo.gid = info.gid
    self.menuInfo.icon = info.icon
    self.menuInfo.level = info.level or 0

    -- 弹出菜单
    self:popupMenus(self.menuInfo)
end

-- 设置点击排行榜列表项中的菜单的响应事件
function RingHegemonyDlg:onClickMenu(idx)
    if not self.menuInfo then return end

    local menu = self.menuInfo[idx]
    if menu == CHS[3000056] then
        -- 查看装备
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, self.menuInfo.gid)
    elseif menu == CHS[3000057] then
        -- 交流
        FriendMgr:communicat(self.menuInfo.char, self.menuInfo.gid, self.menuInfo.icon, self.menuInfo.level)
        self.menuInfo = nil
    elseif menu == CHS[3000058] then
        -- 发送数据请求
        FriendMgr:requestCharMenuInfo(self.menuInfo.gid)
        return
    end

    self:closeMenuDlg()
end

-- 积分进度条
function RingHegemonyDlg:setScoreBar(data)
    local score = Me:queryBasicInt("ct_data/score")
    local stage, level, nextScore = RingMgr:getStepAndLevelByScore(score)
    self:setProgressBar("ExpProgressBar", score, nextScore)
    self:setLabelText("ExpvalueLabel", score .. "/" .. nextScore)
    self:updateLayout("ExpProgressBarPanel")
end

-- 设置比赛数据
function RingHegemonyDlg:setMatchData(data)
    -- 胜利次数
    self:setLabelText("WinValueLabel", data.winTimes)
    self:updateLayout("WinValuePanel")
    
    -- 负场
    self:setLabelText("FailValueLabel", data.loseTimes)
    self:updateLayout("FailValuePanel")
    
    -- 逃跑
    self:setLabelText("TieValueLabel", data.escapeTimes)
    self:updateLayout("TieValuePanel")
    
    -- 胜率
    self:setLabelText("ProbabilityValueLabel", data.winRate .. "%")
    self:updateLayout("ProbabilityValuePanel")
end

-- 根据等级设置星星
function RingHegemonyDlg:setStar(level, panel)
    
    for i = 1, 3 do    
        self:setCtrlVisible("StarImage_" .. i, (level >= i), panel)
        self:setCtrlVisible("NoneStarImage_" .. i, (level < i), panel)      
    end
end

function RingHegemonyDlg:onDetailsButton(sender, eventType)
    local panel = self:getControl("DetailsPanel")
    if sender:getName() == "BKPanel" then
        panel:setVisible(false)
    else
        panel:setVisible(not panel:isVisible())
    end
end

function RingHegemonyDlg:MSG_CHAR_INFO(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.gid then return end

    self:closeMenuDlg()

    -- 尝试加为好友
    FriendMgr:tryToAddFriend(data.name, data.gid, Bitset.new(data.setting_flag))
end

return RingHegemonyDlg
