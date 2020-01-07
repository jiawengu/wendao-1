-- NewKuafzcjfDlg.lua
-- Created by songcw Jan/06/2019
-- 跨服战场2019 积分

local NewKuafzcjfDlg = Singleton("NewKuafzcjfDlg", Dialog)


-- 左侧一级菜单
local BIG_MENU = {CHS[4100709], CHS[4100710], CHS[4010314], CHS[4010315]}


local SMALL_MENU

local MENU_DISPALY_PANEL = {
    [CHS[4100709]] = "UserScorePanel",
    [CHS[4100710]] = "MatchScorePanel",
    [CHS[4010314]] = "MatchScorePanel",
    [CHS[4010315]] = "MatchScorePanel",
}

function NewKuafzcjfDlg:init(notQuery)
    self:bindListener("LevelButton", self.onLevelButton)
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListViewListener("LevelListView", self.onSelectLevelListView)
    self:bindListViewListener("MatchTypeListView", self.onSelectMatchTypeListView)
    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindListViewListener("ListView", self.onSelectListView)

    self.bigMenuPanel = self:retainCtrl("BigPanel")
    self.smallMenuPanel = self:retainCtrl("SPanel")
    self.unitMatchPanel = self:retainCtrl("MatchPanel", "UserScorePanel")

    self:setCtrlVisible("NoticePanel", false)

    if notQuery then
    else
      --  KuafzcMgr:queryJfRankTotalPlayers2019()
        KuafzcMgr:queryMatchScoreSimple2019()
    end

    SMALL_MENU = KuafzcMgr:getFJMenuData2019()

    local simData = KuafzcMgr:getJfSimpleData()
    -- 如果没有循环赛并且循环赛结束，一级菜单干掉循环赛
    if SMALL_MENU and not SMALL_MENU[CHS[4010318]] and simData and simData.group_end == 1 then
        BIG_MENU = {CHS[4100709], CHS[4010314], CHS[4010315]}
    else
        BIG_MENU = {CHS[4100709], CHS[4100710], CHS[4010314], CHS[4010315]}
    end

    if SMALL_MENU then
        self:setMenuList({name = "MatchTypeListView", margin = 5}, BIG_MENU, self.bigMenuPanel, SMALL_MENU, self.smallMenuPanel, self.onClickBigMenu, self.onClickSmallMenu, {one = CHS[4100709]})
    end

    self:hookMsg("MSG_CSML_CONTRIB_TOP_DATA")
    self:hookMsg("MSG_CSML_MATCH_DATA")
    self:hookMsg("MSG_CSML_MATCH_SIMPLE")
end

function NewKuafzcjfDlg:setRightPanelVisible(pName)
    self:setCtrlVisible("UserScorePanel", false)
    self:setCtrlVisible("MatchScorePanel", false)

    if MENU_DISPALY_PANEL[pName] then
        self:setCtrlVisible(MENU_DISPALY_PANEL[pName], true)
    end
end

function NewKuafzcjfDlg:onClickBigMenu(sender, eventType)
    self.queryMatchName = nil
    self.smallMenuName = nil

    self.bigMenuName = sender:getName()
    self:setRightPanelVisible(self.bigMenuName)

    local simData = KuafzcMgr:getJfSimpleData()
    if self.bigMenuName == CHS[4100709] then
        if self.personageData then
            self:MSG_CSML_CONTRIB_TOP_DATA(self.personageData)
        else
            local isOpen = false    -- 个人积分是否已经有了

            isOpen = (simData.has_total_top == 1)
            self:setCtrlVisible("UserScorePanel", isOpen)
            self:setCtrlVisible("NoticePanel", not isOpen)
            if not isOpen then
                self:setLabelText("InfoLabel1", CHS[4100727], "NoticePanel")          -- 当前尚未开始比赛
            else
                KuafzcMgr:queryJfRankTotalPlayers2019()
            end
        end
    else
        -- 晋级赛、淘汰赛没有数据
        if not SMALL_MENU[self.bigMenuName] then
            if simData.group_end == 0 then
                self:setLabelText("InfoLabel1", string.format(CHS[4010316], self.bigMenuName), "NoticePanel")    -- 当前尚未进入%s阶段
            else
                self:setLabelText("InfoLabel1", string.format(CHS[4010317], self.bigMenuName), "NoticePanel")    -- 本区组未能进入%s
            end

            self:setCtrlVisible("NoticePanel", true)
            self:setCtrlVisible("MatchScorePanel", false)
        else
            self:setCtrlVisible("NoticePanel", false)
        end
    end
end

function NewKuafzcjfDlg:onClickSmallMenu(sender, eventType)
    self.smallMenuName = sender:getName()


    local data = KuafzcMgr:getMatchInfoByTitle(self.smallMenuName, self.bigMenuName)
    self.queryMatchName = data.match_name
    -- 设置右上方信息
    self:setWarInfo(data)

    --
    if self.warData and self.warData[self.queryMatchName] then
        self:MSG_CSML_MATCH_DATA(self.warData[self.queryMatchName])
    else
        KuafzcMgr:queryJfRankByName(self.queryMatchName)
    end
    --]]
end

function NewKuafzcjfDlg:setRankiInfo(data, panelName)
    local list = self:resetListView("ListView", nil, nil, panelName)
    local myData
    for i = 1, data.count do
        local panel = self.unitMatchPanel:clone()
        self:setUnitMathPanel(data.rankInfo[i], i, panel)
        list:pushBackCustomItem(panel)

        if data.rankInfo[i].gid == Me:queryBasic("gid") then
            myData = data.rankInfo[i]
        end
    end

    return myData
end

function NewKuafzcjfDlg:setUnitMathPanel(data, i, panel)
    if not data then
        data = {rank = "", name = "", level = "", polar = "", contrib = "", combat = ""}
    end

    -- 名次
    self:setLabelText("IndexLabel", data.rank, panel)

    -- 名称
    self:setLabelText("NameLabel", data.name, panel)

    -- 等级
    self:setLabelText("LevelLabel", data.level, panel)

    -- 相性
    if data.polar == "" then
        self:setLabelText("PolarLabel", "", panel)
    else
        self:setLabelText("PolarLabel", gf:getPolar(data.polar), panel)
    end

    -- 积分
    self:setLabelText("ScoreLabel", data.contrib, panel)

    self:setCtrlVisible("BackImage_2", i % 2 == 0, panel)
end

-- 右上角的战斗信息
function NewKuafzcjfDlg:setWarInfo(data)
    local panel = self:getControl("DistScorePanel")
    self:setLabelText("DistLabel_1", data.myDist, panel)
    self:setLabelText("DistLabel_2", data.opDist, panel)

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

    if data.myScore then
        self:setLabelText("ScoreLabel", string.format("%d : %d", data.myScore, data.opScore), panel)
    else
        self:setLabelText("ScoreLabel", "", panel)
    end

    local timePanel = self:getControl("TypePanel", nil, panel)
    self:setLabelText("Label", gf:getServerDate(CHS[4300031], data.start_time), panel)
end


function NewKuafzcjfDlg:onLevelButton(sender, eventType)
end

function NewKuafzcjfDlg:onSelectButton(sender, eventType)
end

function NewKuafzcjfDlg:onSelectLevelListView(sender, eventType)
end

function NewKuafzcjfDlg:onSelectMatchTypeListView(sender, eventType)
end

function NewKuafzcjfDlg:onSelectListView(sender, eventType)
end

function NewKuafzcjfDlg:onSelectListView(sender, eventType)
end

function NewKuafzcjfDlg:cleanup()
    self.personageData = nil
    self.warData = {}
end

function NewKuafzcjfDlg:MSG_CSML_CONTRIB_TOP_DATA(data)
    if data.count == 0 then return end
    self.personageData = data
    if self.bigMenuName ~= CHS[4100709] then return end

    self:setCtrlVisible("NoticePanel", false)
  --  self:setRightPanelVisible(self.bigMenuName)
    self:setRankiInfo(data, MENU_DISPALY_PANEL[self.bigMenuName])   -- "UserScorePanel"

    local myPanel = self:getControl("MyselfPanel", nil, MENU_DISPALY_PANEL[self.bigMenuName])

    if not data.myRankInfo[1] then

        local name = Me:queryBasic("name")
        if string.match(name, CHS[5400177]) then
            name = string.match(name, CHS[5400177])
        end

        local temp = {rank = CHS[5400351], name = name, level = Me:queryBasicInt("level"), polar = Me:queryBasicInt("polar"), contrib = CHS[5430030]}
        self:setUnitMathPanel(temp, 1, myPanel)
    else
        self:setUnitMathPanel(data.myRankInfo[1], 1, myPanel)
    end

end

function NewKuafzcjfDlg:MSG_CSML_MATCH_DATA(data)

    if not self.warData then self.warData = {} end
    self.warData[data.name or data.match_name] = data

    if self.queryMatchName ~= data.name then return end

    self:setRightPanelVisible(self.bigMenuName)

    local myData = self:setRankiInfo(data, MENU_DISPALY_PANEL[self.bigMenuName])      -- MatchScorePanel

    if not myData and data.count > 0 then
        local name = Me:queryBasic("name")
        if string.match(name, CHS[5400177]) then
            name = string.match(name, CHS[5400177])
        end
        myData = {rank = CHS[5400351], name = name, level = Me:queryBasicInt("level"), polar = Me:queryBasicInt("polar"), contrib = CHS[5430030]}
    end

    local myPanel = self:getControl("MyselfPanel", nil, MENU_DISPALY_PANEL[self.bigMenuName])
    self:setUnitMathPanel(myData, 1, myPanel)

    --self:setWarInfo(data)
end

function NewKuafzcjfDlg:MSG_CSML_MATCH_SIMPLE(data)
--
    SMALL_MENU = KuafzcMgr:getFJMenuData2019()

    if SMALL_MENU then
        self:setMenuList({name = "MatchTypeListView", margin = 5}, BIG_MENU, self.bigMenuPanel, SMALL_MENU, self.smallMenuPanel, self.onClickBigMenu, self.onClickSmallMenu, {one = CHS[4100709]})
    end
end

function NewKuafzcjfDlg:paraData(data)
    local distArr = gf:split(data.match_name, " VS ")
    local scoreArr = gf:split(data.score, ":")
    local pointArr = gf:split(data.point, ":")
    local title = ""
    local myDist, opDist
    local myScore, opScore
    local myRet = 0
    if data.dist == distArr[1] then
        title = string.format(CHS[4100722], distArr[2])
        myDist = distArr[1]
        opDist = distArr[2]
        myScore = tonumber(scoreArr[1])
        opScore = tonumber(scoreArr[2])
        if pointArr == "" then
            if tonumber(pointArr[1]) > tonumber(pointArr[2]) then
                myRet = 1
            elseif tonumber(pointArr[1]) < tonumber(pointArr[2]) then
                myRet = 2
            elseif tonumber(pointArr[1]) == tonumber(pointArr[2]) then
                myRet = 3
            end
        else
            myRet = 0
        end
    else
        title = string.format(CHS[4100722], distArr[1])
        myDist = distArr[2]
        opDist = distArr[1]
        myScore = tonumber(scoreArr[2])
        opScore = tonumber(scoreArr[1])
        if pointArr == "" then
            if tonumber(pointArr[1]) > tonumber(pointArr[2]) then
                myRet = 2
            elseif tonumber(pointArr[1]) < tonumber(pointArr[2]) then
                myRet = 1
            elseif tonumber(pointArr[1]) == tonumber(pointArr[2]) then
                myRet = 3
            end
        else
            myRet = 0
        end
    end

    return {title = title, match_name = data.match_name, myDist = myDist, opDist = opDist,
        myScore = myScore, opScore = opScore, start_time = data.start_time, myRet = myRet}
end

-- 只用于楼兰城NPC打开

function NewKuafzcjfDlg:setData(data)
    local isGroup = data.round <= data.group_round
    local list = self:resetListView("MatchTypeListView", 4)
    self:setCtrlEnabled("LevelButton", false)

    local btn = self.bigMenuPanel:clone()
    if isGroup then
        self:setLabelText("Label", BIG_MENU[2], btn)
        self.bigMenuName = BIG_MENU[2]
    else
        if data.round == data.total_round then
            self:setLabelText("Label", BIG_MENU[4], btn)
            self.bigMenuName = BIG_MENU[4]
        else
            self:setLabelText("Label", BIG_MENU[3], btn)
            self.bigMenuName = BIG_MENU[3]
        end
    end
    self:setCtrlVisible("BChosenEffectImage", true, btn)
    btn:setEnabled(false)
    list:pushBackCustomItem(btn)

    local ret = self:paraData(data)
    local smallMenu = self.smallMenuPanel:clone()
    self:setLabelText("Label", ret.title, smallMenu)
    smallMenu:setEnabled(false)
    list:pushBackCustomItem(smallMenu)
    -- 增加光效
    self:setCtrlVisible("SChosenEffectImage", true, smallMenu)

    -- 比赛信息
    self:setWarInfo(ret)
    self.smallMenuName = ret.match_name


    self:MSG_CSML_MATCH_DATA(data, true)

    self:setCtrlVisible("NoticePanel", false)
    self:setCtrlVisible("MatchScorePanel", true)
end


return NewKuafzcjfDlg
