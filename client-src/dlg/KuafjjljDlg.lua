-- KuafjjljDlg.lua
-- Created by huangzz Jan/02/2018
-- 跨服竞技历届界面

local KuafjjljDlg = Singleton("KuafjjljDlg", Dialog)

local MAXNUM_LISTVIEW = 5

local ZONES = {'A', 'B', 'C', 'D', 'E', 'F'} -- 赛区

function KuafjjljDlg:init()
    self:bindListener("NumberButton", self.onNumberButton)
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListener("BigPanel", self.onBigPanel)
    self:bindListener("MatchPanel", self.onMatchPanel, "UserScorePanel_1")
    self:bindListener("MatchPanel", self.onMatchPanel, "UserScorePanel_2")
    
    self:bindListener("NextPageButton", self.onNextPageButton)
    self:bindListener("LastPageButton", self.onLastPageButton)

    self:bindFloatPanelListener("NumberFloatPanel", "NumberButton", nil, function ()
        self:setFloatPanelVisibel(false)
    end)
    
    -- 赛区标签
    self.bigPanel = self:retainCtrl("BigPanel", "MatchTypeListView")
    self.chosenEffImage = self:retainCtrl("BChosenEffectImage", self.bigPanel)
    self.selectZone = 1  -- 默认选中A赛区
    
    -- 排行榜
    self.matchCtrls = {}
    self.matchCtrls[1] = {}
    self.matchCtrls[2] = {}
    self.rankListView = {}
    self.unitMatchPanel = {}
    self.chosenImage = {}
    self.unitMatchPanel[1] = self:retainCtrl("MatchPanel", "UserScorePanel_1")
    self.unitMatchPanel[2] = self:retainCtrl("MatchPanel", "UserScorePanel_2")
    self.rankListView[1] = self:resetListView("ListView", nil, nil, "UserScorePanel_1")
    self.rankListView[2] = self:resetListView("ListView", nil, nil, "UserScorePanel_2")
    self.chosenImage[1] = self:retainCtrl("ChosenEffectImage", self.unitMatchPanel[1])
    self.chosenImage[2] = self:retainCtrl("ChosenEffectImage", self.unitMatchPanel[2])
    self.rankData = {}
    self.loadNum = {1, 1}
    
    self:setCtrlVisible("UserScorePanel_1", true)
    self:setCtrlVisible("UserScorePanel_2", false)
    
    -- 届数
    self.seasonCtrls = {}
    self.selectButton = self:retainCtrl("SelectButton", "NumberFloatPanel")
    local seasonNum = KuafjjMgr:getSeasonTotalNum()
    self:initSeasonListView(seasonNum)
    self:setSelectSeason(seasonNum)
    
    -- 滚动加载
    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:setRankInfo(false, 1)
            self:setRankInfo(false, 2)
        end
    end, "UserScorePanel_1")
    
    -- 滚动加载
    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:setRankInfo(false, 1)
            self:setRankInfo(false, 2)
        end
    end, "UserScorePanel_2")
    
    self:hookMsg("MSG_CSC_RANK_DATA_TOP")
end

function KuafjjljDlg:onMatchPanel(sender)
    local tag = sender:getTag()
    self:selectMatchPanel(tag - 1)
end

-- 选中条目
function KuafjjljDlg:selectMatchPanel(index)
    local cell = self.rankListView[1]:getItem(index)
    self.chosenImage[1]:removeFromParent()
    cell:addChild(self.chosenImage[1])
    
    local cell = self.rankListView[2]:getItem(index)
    self.chosenImage[2]:removeFromParent()
    cell:addChild(self.chosenImage[2])
end

function KuafjjljDlg:unSelectMatchPanel()
    self.chosenImage[1]:removeFromParent()
    self.chosenImage[2]:removeFromParent()
end

-- 显示右边内容
function KuafjjljDlg:onNextPageButton()
    self:setCtrlVisible("UserScorePanel_1", false)
    self:setCtrlVisible("UserScorePanel_2", true)
    
    local percent = self:getCurScrollPercent("ListView", true, "UserScorePanel_1")
    local listView = self:getControl("ListView", nil, "UserScorePanel_2")
    listView:jumpToPercentVertical(percent)
end

-- 显示左边内容
function KuafjjljDlg:onLastPageButton()
    self:setCtrlVisible("UserScorePanel_1", true)
    self:setCtrlVisible("UserScorePanel_2", false)
    
    local percent = self:getCurScrollPercent("ListView", true, "UserScorePanel_2")
    local listView = self:getControl("ListView", nil, "UserScorePanel_1")
    listView:jumpToPercentVertical(percent)
end

-- 创建赛区列表
function KuafjjljDlg:initZoneListView()
    local listView = self:getControl("MatchTypeListView")
    listView:removeAllChildren()
    local cou = KuafjjMgr:getZoneCount(self.selectSeason)
    if not cou then
        return
    end
    
    for i = 1, cou do
        local cell = self.bigPanel:clone()
        cell:setTag(i)
        cell:setName(ZONES[i])
        self:setLabelText("Label", CHS[5400027] .. " " .. ZONES[i], cell)
        listView:pushBackCustomItem(cell)
    end
end

function KuafjjljDlg:getSeasonCell(num)
    if self.seasonCtrls[num] then
        return self.seasonCtrls[num]
    else
        local cell = self.selectButton:clone()
        cell:retain()
        cell:setTag(num)
        self:setCellInfo(cell, num)
        self.seasonCtrls[num] = cell
        return cell
    end
end

-- 创建届列表
function KuafjjljDlg:initSeasonListView(cou)
    local listView = self:resetListView("LevelListView", 5)
    self:stopSchedule(self.scheduleId)
    self.scheduleId = nil

    local loadNum = 1
    local function func()
        for i = 1, 5 do
            if loadNum > cou then
                self:stopSchedule(self.scheduleId)
                self.scheduleId = nil
                return
            end
            
            local cell = self:getSeasonCell(loadNum)
            listView:pushBackCustomItem(cell)
            
            loadNum = loadNum + 1
        end
    end
    
    func()
    
    self.scheduleId = self:startSchedule(func, 0.3)

    -- 调整 listView 长度
    local panelSize = self.selectButton:getContentSize()
    local parentPanel = listView:getParent()
    local realCou = cou
    if realCou <= 5 then
        parentPanel:setContentSize(parentPanel:getContentSize().width, (panelSize.height + 5) * realCou + 19)
        listView:setContentSize(listView:getContentSize().width, (panelSize.height + 5) * realCou)
    else
        parentPanel:setContentSize(parentPanel:getContentSize().width, (panelSize.height + 5) * MAXNUM_LISTVIEW + 19)
        listView:setContentSize(listView:getContentSize().width, (panelSize.height + 5) * MAXNUM_LISTVIEW)
    end

    self.root:requestDoLayout()
end

-- 显示第 n 届
function KuafjjljDlg:setCellInfo(cell, num)
    cell:setTitleText(string.format(CHS[5400353], num))
end

function KuafjjljDlg:onNumberButton(sender, eventType)
    self:setFloatPanelVisibel(not self:getCtrlVisible("NumberFloatPanel"))
end

function KuafjjljDlg:setFloatPanelVisibel(isVisible)
    self:setCtrlVisible("NumberFloatPanel", isVisible)
    
    self:setCtrlVisible("ExpandImage", not isVisible)
    self:setCtrlVisible("ShrinkImage", isVisible)
end

function KuafjjljDlg:setSelectSeason(tag)
    -- 显示选中的届数
    local button = self:getControl("NumberButton")
    KuafjjljDlg:setCellInfo(button, tag)
    
    self.selectSeason = tag

    self:setFloatPanelVisibel(false)
    
    self:initZoneListView()
    
    if self.selectZone then
        local listView = self:getControl("MatchTypeListView")
        local panel = listView:getChildByTag(self.selectZone)
        if panel then
            self:onBigPanel(panel)
        else
            self.selectZone = 1
            panel = listView:getChildByTag(self.selectZone)
            if panel then
                self:onBigPanel(panel)
            end
        end
    end
end

-- 选中届数
function KuafjjljDlg:onSelectButton(sender, eventType)
    local tag = sender:getTag()
    self:setSelectSeason(tag)
end

-- 选择赛区
function KuafjjljDlg:onBigPanel(sender, eventType)
    self.chosenEffImage:removeFromParent()
    sender:addChild(self.chosenEffImage)
    
    self.selectZone = sender:getTag()
    
    if self.rankData[self.selectSeason] and self.rankData[self.selectSeason][self.selectZone] then
        self:MSG_CSC_RANK_DATA_TOP(self.rankData[self.selectSeason][self.selectZone])
    else
        KuafjjMgr:requestZoneRankData(self.selectSeason, self.selectZone)
    end
end

function KuafjjljDlg:setUnitMathPanel(data, i, panel, page)
    if not data then
        return
    end
    
    --[[if panel:getName() == "MyselfPanel" then
        if not next(data) then
            self:setLabelText("NoteLabel", CHS[5400414], panel)
        else
            self:setLabelText("NoteLabel", "", panel)
        end
    end]]

    -- 名次
    self:setLabelText("IndexLabel", data.rank or "", panel)

    -- 名称
    self:setLabelText("NameLabel", data.name or "", panel)

    -- 等级
    self:setLabelText("LevelLabel", data.level or "", panel)
    
    if page == 1 then
        -- 区组
        self:setLabelText("DistLabel", data.dist_name or "", panel)
        
        -- 相性
        if not data.polar then
            self:setLabelText("PolarLabel", "", panel)
        else
            self:setLabelText("PolarLabel", gf:getPolar(data.polar), panel)
        end

        -- 积分
        self:setLabelText("ScoreLabel", data.contrib or "", panel)
    else
        -- 段位
        self:setLabelText("TitleLabel", KuafjjMgr:getStageStrByScore(data.contrib) or "", panel)
        
        -- 战斗次数
        self:setLabelText("CombatTimeLabel", data.combat or "", panel)
    
        -- 胜率
        if not data.combat then
            self:setLabelText("WinRateLabel", "", panel)
        elseif data.combat == 0 or data.win == 0 then
            self:setLabelText("WinRateLabel", "0%", panel)
        else
            local rate = data.win / data.combat * 100        
            self:setLabelText("WinRateLabel", string.format("%.1f%%", rate), panel)
        end
    end

    self:setCtrlVisible("BackImage_2", i % 2 == 0, panel)
end

function KuafjjljDlg:getOneMatchCell(num, page)
    if self.matchCtrls[page][num] then
        return self.matchCtrls[page][num]
    else
        local cell = self.unitMatchPanel[page]:clone()
        cell:retain()
        cell:setTag(num)
        self.matchCtrls[page][num] = cell
        return cell
    end
end

function KuafjjljDlg:setRankInfo(isReset, page)
    if not self.rankData[self.selectSeason] or not self.rankData[self.selectSeason][self.selectZone] then
        return
    end
    
    local data = self.rankData[self.selectSeason][self.selectZone]
    if data.count == 0 then
        return
    end
    
    local list = self.rankListView[page]
    if isReset then
        list:removeAllItems()
        self:unSelectMatchPanel()
        self.loadNum[page] = 1
    end
    
    local loadNum = self.loadNum[page]
    for i = 1, 10 do
        if data.rankInfo[loadNum] then
            local cell = self:getOneMatchCell(loadNum, page)
            self:setUnitMathPanel(data.rankInfo[loadNum], loadNum, cell, page)
            list:pushBackCustomItem(cell)

            loadNum = loadNum + 1
        end
    end

    list:doLayout()
    list:refreshView()
    self.loadNum[page] = loadNum
end

function KuafjjljDlg:MSG_CSC_RANK_DATA_TOP(data)
    if not self.rankData[data.season] then
        self.rankData[data.season] = {}
    end
    
    self.rankData[data.season][data.zone] = data
    
    -- 与选中的标签对不上不做处理
    if data.zone ~= self.selectZone or data.season ~= self.selectSeason then return end
    
    if data.count == 0 then
        self:setCtrlVisible("ListView", false, "UserScorePanel_1")
        self:setCtrlVisible("ListView", false, "UserScorePanel_2")
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("ListView", true, "UserScorePanel_1")
        self:setCtrlVisible("ListView", true, "UserScorePanel_2")
        self:setCtrlVisible("NoticePanel", false)
    end

    -- 显示排行榜数据
    self:setRankInfo(true, 1)
    self:setRankInfo(true, 2)
    
    --[[ 显示玩家自己的数据
    local myGid = Me:queryBasic("gid")
    local myData = {}
    for i = 1, data.count do
        if myGid == data.rankInfo[i].gid then
            myData = data.rankInfo[i]
            break
        end
    end

    local myPanel = self:getControl("MyselfPanel")
    self:setUnitMathPanel(myData, 1, myPanel)]]
end

function KuafjjljDlg:cleanup()
    self.rankData = nil
    
    if self.seasonCtrls then
        for _, v in pairs(self.seasonCtrls) do
            v:release()
        end
    end
    
    self.seasonCtrls = nil
    self.scheduleId = nil
    
    if self.matchCtrls then
        for i = 1, 2 do
            for _, v in pairs(self.matchCtrls[i]) do
                v:release()
            end
        end
    end

    self.matchCtrls = nil
end

return KuafjjljDlg
