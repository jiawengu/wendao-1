-- KuafjjjfDlg.lua
-- Created by huangzz Jan/02/2018
-- 跨服竞技积分界面


local KuafjjjfDlg = Singleton("KuafjjjfDlg", Dialog)

local STAGE_STR = {
    CHS[5400350],
    CHS[5400374],
    CHS[5400373],
    CHS[5400372],
    CHS[5400371],
    CHS[5400370],
    CHS[5400369],
}

function KuafjjjfDlg:init()
    self:bindListener("MatchPanel", self.onMatchPanel, "UserScorePanel_1")
    self:bindListener("MatchPanel", self.onMatchPanel, "UserScorePanel_2")
    self:bindListener("NextPageButton", self.onNextPageButton)
    self:bindListener("LastPageButton", self.onLastPageButton)
    
    self.rankData = {}
    
    self.curShowPage = 1
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
    self.loadNum = {1, 1}
    
    self:setCtrlVisible("UserScorePanel_1", true)
    self:setCtrlVisible("UserScorePanel_2", false)
    
    -- 请求总榜数据
    KuafjjMgr:requestZoneRankData()
    
    -- 请求所有段位数据
    KuafjjMgr:requestStageRankData()
    
    self:initRankType()
    
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
    self:hookMsg("MSG_CSC_RANK_DATA_STAGE")
    self:hookMsg("MSG_CSC_RANK_DATA_TOP_COMPETE")
    self:hookMsg("MSG_CSC_RANK_DATA_STAGE_COMPETE")
end

function KuafjjjfDlg:onMatchPanel(sender)
    local tag = sender:getTag()
    self:selectMatchPanel(tag - 1)
end

-- 选中条目
function KuafjjjfDlg:selectMatchPanel(index)
    local cell = self.rankListView[1]:getItem(index)
    self.chosenImage[1]:removeFromParent()
    cell:addChild(self.chosenImage[1])

    local cell = self.rankListView[2]:getItem(index)
    self.chosenImage[2]:removeFromParent()
    cell:addChild(self.chosenImage[2])
end

function KuafjjjfDlg:unSelectMatchPanel()
    self.chosenImage[1]:removeFromParent()
    self.chosenImage[2]:removeFromParent()
end

-- 显示右边内容
function KuafjjjfDlg:onNextPageButton()
    self:setCtrlVisible("UserScorePanel_1", false)
    self:setCtrlVisible("UserScorePanel_2", true)

    local percent = self:getCurScrollPercent("ListView", true, "UserScorePanel_1")
    local listView = self:getControl("ListView", nil, "UserScorePanel_2")
    listView:jumpToPercentVertical(percent)
end

-- 显示左边内容
function KuafjjjfDlg:onLastPageButton()
    self:setCtrlVisible("UserScorePanel_1", true)
    self:setCtrlVisible("UserScorePanel_2", false)

    local percent = self:getCurScrollPercent("ListView", true, "UserScorePanel_2")
    local listView = self:getControl("ListView", nil, "UserScorePanel_1")
    listView:jumpToPercentVertical(percent)
end

function KuafjjjfDlg:initRankType()
    for i = 1, 7 do
        local cell = self:getControl("TypePanel_" .. i)
        self:setCtrlVisible("BChosenEffectImage", false, cell)
        local str = self:getControl("Label", nil, cell):getString()
        str = string.gsub(str, " ", "")
        if i > 1 then
            cell:setTag(9 - i)
        else
            cell:setTag(1)
        end
        
        self:bindTouchEndEventListener(cell, self.onSelectType)
        
        if i == 1 then
            -- 默认选中第一个标签
            self:onSelectType(cell)
        end
    end
end

function KuafjjjfDlg:onSelectType(sender, eventType)
    if self.selectTypeCtrl == sender then
        return
    end
    
    if self.selectTypeCtrl then
        self:setCtrlVisible("BChosenEffectImage", false, self.selectTypeCtrl)
    end

    self.selectTypeCtrl = sender
    self.selectStage = sender:getTag()
    self:setCtrlVisible("BChosenEffectImage", true, sender)
    

    if self.rankData and self.rankData[self.selectStage] then
        -- 显示排行榜数据
        self:setRankInfo(true, 1)
        self:setRankInfo(true, 2)
        
        self:setMyData()
    end    
end

function KuafjjjfDlg:setUnitMathPanel(data, i, panel, page)
    if not data then
        return
    end

    -- 名次
    if panel:getName() == "MyselfPanel" then
        self:setLabelText("NoteLabel", "", panel)
        self:setLabelText("IndexLabel", "", panel)
        if data.stage == self.selectStage then
            self:setLabelText("IndexLabel", data.rank, panel)
        elseif self.selectStage == 1 then
            self:setLabelText("IndexLabel", CHS[5400351], panel)
        else
            if data.stage and data.stage ~= 1 then
                self:setLabelText("NoteLabel", string.format(CHS[5400412], STAGE_STR[data.stage]), panel)
                data = {}
            else
                self:setLabelText("NoteLabel", CHS[5400411], panel)
                data = {}
            end
        end
    else
        self:setLabelText("IndexLabel", data.rank or "", panel)
    end
    
    -- 名称
    self:setLabelText("NameLabel", data.name or "", panel)

    -- 等级
    self:setLabelText("LevelLabel", data.level or "", panel)

    if page == 1 then
        -- 相性
        if not data.polar then
            self:setLabelText("PolarLabel", "", panel)
        else
            self:setLabelText("PolarLabel", gf:getPolar(data.polar), panel)
        end

        -- 积分
        self:setLabelText("ScoreLabel", data.contrib or "", panel)
        
        -- 区组
        self:setLabelText("DistLabel", data.dist_name or "", panel)
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

function KuafjjjfDlg:getOneMatchCell(num, page)
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

function KuafjjjfDlg:setRankInfo(isReset, page)
    if not self.rankData[self.selectStage] then
        return
    end
    
    local data = self.rankData[self.selectStage]
    
    if data.count <= 0 then
        self:setCtrlVisible("ListView", false, "UserScorePanel_1")
        self:setCtrlVisible("ListView", false, "UserScorePanel_2")
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("ListView", true, "UserScorePanel_1")
        self:setCtrlVisible("ListView", true, "UserScorePanel_2")
        self:setCtrlVisible("NoticePanel", false)
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

function KuafjjjfDlg:MSG_CSC_RANK_DATA_TOP(data)
    data.stage = 1
    self.rankData[1] = data

    if self.selectStage == 1 then 
        self:setRankInfo(true, 1)
        self:setRankInfo(true, 2)
    end
    
    if data.count <= 0 then
        -- 总榜没有数据时，不显示自己的信息
        return
    end
    
    local myGid = Me:queryBasic("gid")
    for i = 1, data.count do
        if myGid == data.rankInfo[i].gid then
            self.rankData["myDataInAll"] = data.rankInfo[i]
            self.rankData["myDataInAll"].stage = 1
            break
        end
    end
    
    if not self.rankData["myDataInAll"] then
        self.rankData["myDataInAll"] = {}
    end
    
    self:setMyData()
end

function KuafjjjfDlg:MSG_CSC_RANK_DATA_STAGE(data)
    local myGid = Me:queryBasic("gid")
    for i = 2, data.stage_count do
        self.rankData[i] = data[i]
        
        for j = 1, data[i].count do
            if myGid == data[i].rankInfo[j].gid then
                self.rankData["myDataInStage"] = data[i].rankInfo[j]
                self.rankData["myDataInStage"].stage = i
                break
            end
        end
    end
    
        
    if not self.rankData["myDataInStage"] then
        self.rankData["myDataInStage"] = {}
    end

    if self.selectStage > 1 then 
        -- 1 为总榜，在 MSG_CSC_RANK_DATA_TOP 获取
        self:setRankInfo(true, 1)
        self:setRankInfo(true, 2)
    end
    
    self:setMyData()
end

function KuafjjjfDlg:MSG_CSC_RANK_DATA_TOP_COMPETE(data)
    local name, distName = gf:getRealNameAndFlag(Me:queryBasic("name"))
    KuafjjMgr:setMyRankDataThisSeason({
        dist_name = distName or "",
        gid = Me:queryBasic("gid"),          -- 玩家 gid
        name = name,                         -- 玩家名称
        level = Me:getLevel(),               -- 玩家等级
        contrib = data.myData.contrib,       -- 玩家积分
        combat = data.myData.combat,         -- 战斗次数
        win = data.myData.win,               -- 战斗胜利次数
        polar = Me:queryBasicInt("polar"),   -- 玩家相性
    })
    
    data.myData = nil
    self:MSG_CSC_RANK_DATA_TOP(data)
end

function KuafjjjfDlg:MSG_CSC_RANK_DATA_STAGE_COMPETE(data)
    self:MSG_CSC_RANK_DATA_STAGE(data)
end

-- 设置玩家自己的信息
function KuafjjjfDlg:setMyData()
    if not self.rankData["myDataInAll"] or not self.rankData["myDataInStage"] then
        return
    end
    
    local data = {}
    if self.selectStage == 1 then
        if next(self.rankData["myDataInAll"]) then
            data = self.rankData["myDataInAll"]
        else
            data = KuafjjMgr:getMyRankDataThisSeason() or {}
        end
    else
        data = self.rankData["myDataInStage"]
    end
    
    local myPanel = self:getControl("MyselfPanel", nil, "UserScorePanel_1")
    self:setUnitMathPanel(data, 1, myPanel, 1)
    
    local myPanel = self:getControl("MyselfPanel", nil, "UserScorePanel_2")
    self:setUnitMathPanel(data, 1, myPanel, 2)
end

function KuafjjjfDlg:cleanup()
    self.rankData = nil
    self.selectStage = nil
    self.selectTypeCtrl = nil
    
    if self.matchCtrls then
        for i = 1, 2 do
            for _, v in pairs(self.matchCtrls[i]) do
                v:release()
            end
        end
    end

    self.matchCtrls = nil
end

return KuafjjjfDlg
