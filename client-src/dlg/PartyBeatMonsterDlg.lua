-- PartyBeatMonsterDlg.lua
-- Created by songcw Sep/6/2017
-- 帮派活动-挑战巨兽

local PartyBeatMonsterDlg = Singleton("PartyBeatMonsterDlg", Dialog)

local PAGE_MAX_COUNT = 12

function PartyBeatMonsterDlg:init()
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("BeatButton", self.onBeatButton)
    self:bindCheckBoxListener("OwnTeamCheckBox", self.onCheckBox)
    self:bindListViewListener("RankingListView", self.onSelectRankingListView)

    self.unitPlayerPanel = self:retainCtrl("MyRankingPanel1")
    self.unitNewsPanel = self:retainCtrl("NewsLabelPanel")

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("OwnTeamCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("OwnTeamCheckBox", false)
    end
    self.data = nil

    self.openTime = gfGetTickCount()

    -- 滚动加载
    self:bindListViewByPageLoad("RankingListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:setPlayersContribution()
        end
    end)


    self:hookMsg("MSG_PARTY_TZJS_INFO")
end

function PartyBeatMonsterDlg:onUpdate()

    if gfGetTickCount() - self.openTime > 30 * 1000 then
        PartyMgr:refreashTZJS()
        self.openTime = gfGetTickCount()
    end

    if not self.data then return end

    -- 剩余时间
    if gf:getServerTime() <= self.data.start_time_chanllenge then
        -- 准备时间
        local left = math.ceil((self.data.start_time_chanllenge - gf:getServerTime()) / 60)
        self:setLabelText("TimeLabel1", string.format(CHS[4100790], left), "TimePanel")
    elseif gf:getServerTime() > self.data.start_time_chanllenge and gf:getServerTime() <= self.data.end_time_chanllenge then
        -- 挑战时间
        local left = math.ceil((self.data.end_time_chanllenge - gf:getServerTime()) / 60)
        self:setLabelText("TimeLabel1", string.format(CHS[4100791], left), "TimePanel")
    else
        -- 结束时间
        self:setLabelText("TimeLabel1", CHS[4100792], "TimePanel")

        self:setCtrlVisible("EndImage", true)

        gf:grayImageView(self:getControl("BeatButton"))
    end

    -- 保护时间
    local pLeftTime = math.max(0, self.data.end_time_protect - gf:getServerTime())
    self:setLabelText("TimeLabel2", string.format(CHS[4200423], pLeftTime), "ProtectTimePanel")
    if pLeftTime <= 0 then
        self:setCtrlVisible("ProtectTimePanel", false)
    end
end

function PartyBeatMonsterDlg:setUnitPanel(data, rank, panel)
    if not rank or data.contrib <= 0 then
        self:setLabelText("AttributeLabel1", CHS[4100388], panel)
    else
        self:setLabelText("AttributeLabel1", rank, panel)
        self:setCtrlVisible("BackImage2", rank % 2 == 1, panel)
    end

    self:setLabelText("AttributeLabel2", data.name, panel)

    self:setLabelText("AttributeLabel3", data.contrib, panel)
end

-- 设置贡献度排名
function PartyBeatMonsterDlg:setPlayersContribution(isReset)

    local list
    local data = self.data.playersInfo
    if isReset then
        list = self:resetListView("RankingListView")
        self.loadNum = 1
        if not data or not next(data) then
            self:setCtrlVisible("NoticePanel", true)
            return
        end
    else
        list = self:getControl("RankingListView")
    end

    self:setCtrlVisible("NoticePanel", false)

    local myRankInfo = self.data.myRinkInfo
    local myRank = self.data.myRank

    local loadNum = self.loadNum
    if loadNum > #data then
        return
    end

    for i = 1, PAGE_MAX_COUNT do
        if data[loadNum]  then
            if data[i].contrib > 0 then
                local panel = self.unitPlayerPanel:clone()
                panel.userInfo = data[loadNum]
                self:setUnitPanel(data[loadNum], loadNum, panel)
                list:pushBackCustomItem(panel)
            end
            loadNum = loadNum + 1
        end
    end
    self.loadNum = loadNum

    if myRankInfo then
        self:setUnitPanel(myRankInfo, myRank, self:getControl("MyRankingPanel"))
    end

    if #list:getItems() == 0 then
        self:setCtrlVisible("NoticePanel", true)
    end

    list:doLayout()
    list:refreshView()
end

-- 设置界面右侧信息
function PartyBeatMonsterDlg:setRightInfo(data)
    -- 形象
    self:setPortrait("IconPanel", 6600, 0, self.root, true, nil, nil, cc.p(0, -36))

    -- 进度条
    self:setProgressBar("LifeProgressBar", data.life, data.max_life)
    local proStr = string.format("%d/%d(%d%%)", data.life, data.max_life, math.ceil((data.life / data.max_life) * 100))
    self:setLabelText("ValueLabel1", proStr, "LifeProgressBar")
    self:setLabelText("ValueLabel2", proStr, "LifeProgressBar")

    -- 培育
    self:setLabelText("AttriLabel2", data.py_life, "AttriPanel1")
    self:setLabelText("AttriLabel2", data.py_phy_power, "AttriPanel2")
    self:setLabelText("AttriLabel2", data.py_mag_power, "AttriPanel3")
    self:setLabelText("AttriLabel2", data.py_speed, "AttriPanel4")
    self:setLabelText("AttriLabel2", data.py_tao, "AttriPanel5")
    self:setLabelText("AttriLabel2", string.format("%d(%d%%)", data.growth, math.floor(data.growth / data.grow_dest * 100)), "AttriPanel6")

    self:setNews(data.newsInfo)
end

-- 设置战报
function PartyBeatMonsterDlg:setNews(data)
    local list = self:resetListView("NewsListView")

    if not data or not next(data) then
        self:setCtrlVisible("NoneLabel", true)
        return
    end

    self:setCtrlVisible("NoneLabel", false)

    for i = 1, #data do
        if self:isCheck("OwnTeamCheckBox") then
            -- 只显示我的队伍
            if data[i].isMyTeam == 1 then
                local panel = self.unitNewsPanel:clone()
                self:setUnitNewsPanel(data[i], panel)
                list:pushBackCustomItem(panel)
            end
        else
            -- 显示全部
            local panel = self.unitNewsPanel:clone()
            self:setUnitNewsPanel(data[i], panel)
            list:pushBackCustomItem(panel)
        end
    end

    if #list:getItems() == 0 then
        self:setCtrlVisible("NoneLabel", true)
    end
end

function PartyBeatMonsterDlg:setUnitNewsPanel(data, panel)
    local beforeTime = gf:getServerTime() - data.end_time
    local mTime = math.ceil(beforeTime / 60)
    self:setLabelText("InfoLabel", string.format(CHS[4100700], mTime), panel)

    local str = string.format(CHS[4100793], data.name, data.damage, data.contribution)
    if data.isMyTeam == 1 then
        str = string.format(CHS[4100794], data.damage, data.contribution)
    end

    self:setColorText(str, self:getControl("InfoLabePanel", nil, panel))
end


function PartyBeatMonsterDlg:setColorText(task_prompt, cell)
    cell:removeAllChildren()
    local content = cell:getContentSize()
    local lableText = CGAColorTextList:create(true)
    lableText:setFontSize(20)
    lableText:setString(task_prompt)
    lableText:setContentSize(content.width, 0)
    lableText:setDefaultColor(COLOR3.WHITE.r, COLOR3.WHITE.g, COLOR3.WHITE.b)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    local layerColor = tolua.cast(lableText, "cc.LayerColor")
    cell:addChild(layerColor)
    layerColor:setAnchorPoint(0.5, 0.5)
    layerColor:setPosition(content.width / 2, content.height / 2)
end

function PartyBeatMonsterDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    if not self.data then return end
    self:setNews(self.data.newsInfo)
end

function PartyBeatMonsterDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PartyBeatMonsterRuleDlg")
end

function PartyBeatMonsterDlg:onBeatButton(sender, eventType)

    if not self.data then return end

    if gf:getServerTime() > self.data.end_time_active then
        self:onCloseButton()
    end

    PartyMgr:changllengeNPJS()

end

function PartyBeatMonsterDlg:onSelectRankingListView(sender, eventType)
end

function PartyBeatMonsterDlg:MSG_PARTY_TZJS_INFO(data)

    self.data = data--data.playersInfo
    self:setPlayersContribution(true)

    self:setRightInfo(data)



    self.openTime = gfGetTickCount()
end

return PartyBeatMonsterDlg
