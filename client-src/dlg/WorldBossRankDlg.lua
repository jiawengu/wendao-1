-- WorldBossRankDlg.lua
-- Created by  huangzz Jan/24/2018
-- 世界BOSS 伤害排行界面

local WorldBossRankDlg = Singleton("WorldBossRankDlg", Dialog)

local ONE_LOAD_NUM = 20  -- 滑动框每次加载 10 条

function WorldBossRankDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("MyRankingPanel1", self.onRankingPanel)
    
    self.rankPanel = self:retainCtrl("MyRankingPanel1")
    
    self.chosenImage = self:retainCtrl("SelectedImage", self.rankPanel)
    
    self.rankCtrls = {}
    self.data = nil
    
    -- 滚动加载
    self:bindListViewByPageLoad("RankingListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:setListView()
        end
    end, "RankingPanel")
    
    self:hookMsg("MSG_WORLD_BOSS_RANK")
end

function WorldBossRankDlg:onRankingPanel(sender)
    self.chosenImage:removeFromParent()
    sender:addChild(self.chosenImage)
end

function WorldBossRankDlg:getDistCell(num)
    if self.rankCtrls[num] then
        return self.rankCtrls[num]
    else
        local cell = self.rankPanel:clone()
        cell:retain()
        cell:setTag(num)
        self.rankCtrls[num] = cell
        return cell
    end
end

function WorldBossRankDlg:setListView(isReset)
    if not self.data then
        return
    end

    local data = self.data
    if data.count == 0 then
        self:setCtrlVisible("RankingListView", false)
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("RankingListView", true)
        self:setCtrlVisible("NoticePanel", false)
    end

    local listView
    if isReset then
        listView = self:resetListView("RankingListView")
        self.chosenImage:removeFromParent()
        self.loadNum = 1
    else
        listView = self:getControl("RankingListView")
    end

    local loadNum = self.loadNum
    if loadNum > data.count then
        return
    end

    for i = 1, ONE_LOAD_NUM do
        if data[loadNum] then
            local cell = self:getDistCell(loadNum)
            self:setOneRankPanel(data[loadNum], loadNum, cell)
            listView:pushBackCustomItem(cell)

            loadNum = loadNum + 1
        end
    end

    listView:doLayout()
    listView:refreshView()
    self.loadNum = loadNum
end

function WorldBossRankDlg:setOneRankPanel(data, i, cell)
    self:setCtrlVisible("BackImage2", i % 2 == 0, cell)
    
    if data.rank == -1 then
        self:setLabelText("AttributeLabel1", CHS[5400435], cell)
    else
        self:setLabelText("AttributeLabel1", data.rank or "", cell)
    end
    
    self:setLabelText("AttributeLabel2", data.name or "", cell)
    self:setLabelText("AttributeLabel3", data.damage or "", cell)
end

function WorldBossRankDlg:onConfirmButton(sender, eventType)
    WorldBossMgr:requestRankData()
end

function WorldBossRankDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("WorldBossRuleDlg")
end

function WorldBossRankDlg:MSG_WORLD_BOSS_RANK(data)
    self.data = data
    
    -- 最后一条为玩家数据
    local myData = data[data.count]
    data[data.count] = nil
    data.count = data.count - 1

    self:setListView(true)
    
    if data.count > 0 then
        self:setOneRankPanel(myData, 1, self:getControl("MyRankingPanel"))
    else
        self:setOneRankPanel({}, 1, self:getControl("MyRankingPanel"))
    end
end

function WorldBossRankDlg:cleanup()
    if self.rankCtrls then
        for _, v in pairs(self.rankCtrls) do
            v:release()
        end
    end

    self.rankCtrls = nil
    self.data = nil
end

return WorldBossRankDlg
