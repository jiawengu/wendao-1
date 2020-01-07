-- KuafsdwzDlg.lua
-- Created by huangzz Feb/17/2017
-- 跨服试道王者榜界面

local KuafsdwzDlg = Singleton("KuafsdwzDlg", Dialog)

local COMPETITION_AREA = {'A', 'B', 'C', 'D'} -- 赛区
local LEVEL_RANGE = {   -- 等级段
    [1] = {60, 79},
    [2] = {80, 89},
    [3] = {90, 99},
    [4] = {100, 109},
    [5] = {110, 119},
    [6] = {120, 129},
}

local MAXNUM_LISTVIEW = 5

function KuafsdwzDlg:init()
    self:bindListener("RankChoseButton", self.onRankChoseButton)
    self:bindListener("LevelChoseButton", self.onLevelChoseButton)
    self:bindListener("MonthLevelChoseButton", self.onLevelChoseButton)
    self:bindListener("AreaChoseButton", self.onAreaChoseButton)
    
    self:setCtrlVisible("IndexImage", false, "TeamPanel_1")
    self:setCtrlVisible("IndexImage", false, "TeamPanel_2")
    self:setCtrlVisible("IndexImage", false, "TeamPanel_3")
    
    self.levelCellPanel = self:retainCtrl("LevelCellPanel", "LevelListPanel")
    self.rankCellPanel = self:retainCtrl("RankCellPanel")
    self.areaCellPanel = self:retainCtrl("AreaCellPanel")
    self:retainCtrl("LevelCellPanel", "MonthLevelListPanel")
    
    self.listViewIsInit = false

    self.type = KFSD_TYPE.NORMAL
    self:setCtrlVisible("MonthTitlePanel", false)
    self:setCtrlVisible("TitlePanel", true)

    self:setDlgType()
    
    for i = 1, 10 do
        self:bindListener("TeamPanel_" .. i, self.onTeamPanel, "ListInfoPanel")
    end
    
    self:hookMsg("MSG_CS_SHIDAO_HISTORY")
    self:hookMsg("MSG_CS_SHIDAO_PLAN")
end

function KuafsdwzDlg:initListView(ctrlName, panel, data)
    local listView = self:getControl(ctrlName)
    listView:removeAllChildren()
    listView:setClippingEnabled(true)
    listView:setBounceEnabled(true)

    local cou = #data
    for i = 1, cou do
        local cell = panel:clone()
        cell:setTag(i)
        self:setCellInfo(cell, data[i])

        local function func(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onSelectListView(sender)
            end
        end
        cell:addTouchEventListener(func)
        self:setCtrlVisible("ChoseImage", false, cell)
        cell:setTouchEnabled(true)
        listView:pushBackCustomItem(cell)
    end

    -- 调整 listView 长度
    local panelSize = panel:getContentSize()
    local parentPanel = listView:getParent()
    if cou <= 5 then
        parentPanel:setContentSize(parentPanel:getContentSize().width, (panelSize.height + 5) * cou + 19)
        listView:setContentSize(listView:getContentSize().width, (panelSize.height + 5) * cou)
    else
        parentPanel:setContentSize(parentPanel:getContentSize().width, (panelSize.height + 5) * MAXNUM_LISTVIEW + 19)
        listView:setContentSize(listView:getContentSize().width, (panelSize.height + 5) * MAXNUM_LISTVIEW)
    end
    
    self.root:requestDoLayout()
end

function KuafsdwzDlg:resetListView(ctrlName, data, checkInfo)
    local listView = self:getControl(ctrlName)

    local cou = #data
    local tag = 0
    for i = 1, cou do
        local cell = listView:getChildByTag(i)
        
        if (ctrlName == "LevelListView" and checkInfo[data[i][1] .. "-" .. data[i][2]])
           or (ctrlName == "AreaListView" and checkInfo[data[i]]) then
            cell:setTouchEnabled(true)
            self:setCtrlVisible("ChoseImage", false, cell)
            gf:resetImageView(self:getControl("ChoseImage", nil, cell))
            
            -- 等级段默认选择最大的（有数据的）
            if ctrlName == "LevelListView" then
                tag = i
            end
            
            -- 赛区默认选编号最低的（有数据的）
            if ctrlName == "AreaListView" and tag == 0 then
                tag = i
            end
        else
            -- 未开启的赛区或等级段选项置灰
            cell:setTouchEnabled(false)
            self:setCtrlVisible("ChoseImage", true, cell)
            gf:grayImageView(self:getControl("ChoseImage", nil, cell))
        end
    end
    
    local listView = self:getControl(ctrlName)
    local chosePanel = listView:getChildByTag(tag)
    if chosePanel then
        self:onSelectListView(chosePanel)
    end
end

function KuafsdwzDlg:setCellInfo(cell, data)
    if cell:getName() == "RankCellPanel" then
        self:setLabelText("NameLabel", string.format(CHS[5400032], data.session), cell)
    elseif cell:getName() == "LevelCellPanel" then
        self:setLabelText("NameLabel", data[1] .. " - " .. data[2] .. CHS[5300006], cell)
    else
        self:setLabelText("NameLabel", CHS[5400027] .. " " .. data, cell)
    end
end

function KuafsdwzDlg:onSelectListView(sender)
    local tag = sender:getTag()
    if sender:getName() == "RankCellPanel" then
        if self.curSelectRand then
            local list = self:getControl("RankListView")
            local panel = list:getChildByTag(self.curSelectRand)
            self:setCtrlVisible("ChoseImage", false, panel)
        end
        
        self.curSelectRand = tag
        self:setCtrlVisible("RankListPanel", false)
        self:setLabelText("RankLabel", string.format(CHS[5400032], self.kuafsdMenuInfo[tag].session), "RankChoseButton")
        
        -- 重选届数后，要刷新等级段显示（未开启的置灰）
        self.curSelectLevel = nil
        self:resetListView("LevelListView", LEVEL_RANGE, self.kuafsdMenuInfo[tag])
    elseif sender:getName() == "LevelCellPanel" then
        if self.curSelectLevel then
            local list = self:getControl("LevelListView")
            local panel = list:getChildByTag(self.curSelectLevel)
            self:setCtrlVisible("ChoseImage", false, panel)
        end
        
        local showStr = LEVEL_RANGE[tag][1] .. " - " .. LEVEL_RANGE[tag][2] .. CHS[5300006]
        self.curSelectLevel = tag
        self:setCtrlVisible("LevelListPanel", false)
        self:setLabelText("RankLabel", showStr, "LevelChoseButton")
        
        -- 重选等级段后，要刷新赛区显示（未开启的置灰）
        self.curSelectArea = nil
        if self.type == KFSD_TYPE.NORMAL then
            self:resetListView("AreaListView", COMPETITION_AREA, self.kuafsdMenuInfo[self.curSelectRand][LEVEL_RANGE[tag][1] .. "-" .. LEVEL_RANGE[tag][2]])
        else
            -- 月试道没有赛区分类，直接请求数据
            local levelStr = LEVEL_RANGE[tag][1] .. "-" .. LEVEL_RANGE[tag][2]
            if not self.kuafsdRandInfo 
                or self.kuafsdRandInfo.session ~= self.kuafsdMenuInfo[self.curSelectRand].session
                or self.kuafsdRandInfo.levelRange ~= levelStr then
                gf:CmdToServer("CMD_REQUEST_CS_SHIDAO_HISTORY", {
                    type = KFSD_TYPE.MONTH,
                    session = self.kuafsdMenuInfo[self.curSelectRand].session, 
                    levelRange = levelStr,
                    area = ''
                })
            end
        end
    else
        if self.curSelectArea then
            local list = self:getControl("AreaListView")
            local panel = list:getChildByTag(self.curSelectArea)
            self:setCtrlVisible("ChoseImage", false, panel)
        end

        self.curSelectArea = tag
        self:setCtrlVisible("AreaListPanel", false)
        self:setLabelText("RankLabel", CHS[5400027] .. " " .. COMPETITION_AREA[self.curSelectArea], "AreaChoseButton")
    
            
        gf:CmdToServer("CMD_REQUEST_CS_SHIDAO_HISTORY", {
            type = KFSD_TYPE.NORMAL,
            session = self.kuafsdMenuInfo[self.curSelectRand].session, 
            levelRange = LEVEL_RANGE[self.curSelectLevel][1] .. "-" .. LEVEL_RANGE[self.curSelectLevel][2],
            area = COMPETITION_AREA[self.curSelectArea]
        })
        
        DlgMgr:openDlg("WaitDlg")
    end
    
    self:setCtrlVisible("ChoseImage", true, sender)
end

function KuafsdwzDlg:resetFlip()
    self:setCtrlFlip("Image1", nil, false, "RankChoseButton")
    self:setCtrlFlip("Image1", nil, false, "LevelChoseButton")
    self:setCtrlFlip("Image1", nil, false, "AreaChoseButton")
end

function KuafsdwzDlg:onRankChoseButton(sender, eventType)
    if not self.listViewIsInit then
        return
    end
    
    local ctrl = self:getControl("RankListPanel")
    self:setCtrlVisible("RankListPanel", not ctrl:isVisible())
    self:setCtrlVisible("AreaListPanel", false)
    self:setCtrlVisible("LevelListPanel", false)

    self:resetFlip()
    self:setCtrlFlip("Image1", nil, not ctrl:isVisible(), sender)
end

function KuafsdwzDlg:onLevelChoseButton(sender, eventType)
    if not self.listViewIsInit then
        return
    end
    
    local ctrl = self:getControl("LevelListPanel")
    self:setCtrlVisible("LevelListPanel", not ctrl:isVisible())
    self:setCtrlVisible("RankListPanel", false)
    self:setCtrlVisible("AreaListPanel", false)

    self:resetFlip()
    self:setCtrlFlip("Image1", nil, not ctrl:isVisible(), sender)
end

function KuafsdwzDlg:onAreaChoseButton(sender, eventType)
    if not self.listViewIsInit then
        return
    end

    local ctrl = self:getControl("AreaListPanel")
    self:setCtrlVisible("AreaListPanel", not ctrl:isVisible())
    self:setCtrlVisible("RankListPanel", false)
    self:setCtrlVisible("LevelListPanel", false)

    self:resetFlip()
    self:setCtrlFlip("Image1", nil, not ctrl:isVisible(), sender)
end

-- 显示队伍成员
function KuafsdwzDlg:onTeamPanel(sender, eventType)
    local tag = string.match(sender:getName(), "(%d+)")
    tag = tonumber(tag)
    if tag and self.kuafsdRandInfo and self.kuafsdRandInfo[tag] then
        local dlg = DlgMgr:openDlg("LonghzbTeamInfoDlg")
        local data = {}
        data.teamInfo = {}
        data.teamName = self.kuafsdRandInfo[tag].dist_name .. "-" .. self.kuafsdRandInfo[tag].leader_name
        for i = 1, self.kuafsdRandInfo[tag].member_count do
            local member = {}
            member.name = self.kuafsdRandInfo[tag][i]["name"]
            member.icon = self.kuafsdRandInfo[tag][i]["icon"]
            member.level = self.kuafsdRandInfo[tag][i]["level"]
            member.polar = self.kuafsdRandInfo[tag][i]["polar"]
            table.insert(data.teamInfo, member)
        end
        
        dlg:setData(data, 2)
    end
end

function KuafsdwzDlg:MSG_CS_SHIDAO_HISTORY(data)
    self.kuafsdRandInfo = data
    
    -- 显示各个队伍排名信息
    for i = 1, data.count do
        local panel = self:getControl("TeamPanel_" .. i, nil, "ListInfoPanel")
        if i <= 3 then
            self:setCtrlVisible("IndexImage", true, panel)
        end
        
        if i > 3 then
            self:setLabelText("IndexLabel", i, panel)
        end
        
        self:setLabelText("ScoreLabel", data[i].score, panel)
        self:setLabelText("DistLabel", data[i].dist_name, panel)
        self:setLabelText("LeaderLabel", data[i].leader_name, panel)
    end
    
    -- 清空显示
    for i = data.count + 1, 10 do
        local panel = self:getControl("TeamPanel_" .. i, nil, "ListInfoPanel")
        if i <= 3 then
            self:setCtrlVisible("IndexImage", false, panel)
        end
        
        self:setLabelText("IndexLabel", "", panel)
        self:setLabelText("ScoreLabel", "", panel)
        self:setLabelText("DistLabel", "", panel)
        self:setLabelText("LeaderLabel", "", panel)
    end
    
    DlgMgr:closeDlg("WaitDlg")

    if data.type == KFSD_TYPE.MONTH and not self.listViewIsInit then
        -- 月道行试道不会发 MSG_CS_SHIDAO_PLAN，自己造数据
        local sData = {}
        sData.maxSession = data.session -- 最大届数
        sData.count = math.min(20, data.session) -- 几届
        for i = 1, sData.count do
            local sessionInfo = {}
            sessionInfo.session = i + math.max(0, data.session - 20) -- 届
            sessionInfo.count = #LEVEL_RANGE -- 多少个等级段
            for j = 1, sessionInfo.count do
                local levelInfo = {}
                levelInfo.levelRange = LEVEL_RANGE[j][1] .. "-" .. LEVEL_RANGE[j][2] -- 等级段
                levelInfo.count = 0
                sessionInfo[levelInfo.levelRange] = levelInfo
            end

            table.insert(sData, sessionInfo)
        end

        self:MSG_CS_SHIDAO_PLAN(sData)
    end
end

function KuafsdwzDlg:MSG_CS_SHIDAO_PLAN(data)    
    self.kuafsdMenuInfo = data

    if data.count == 0 then
        return
    end
    
    table.sort(self.kuafsdMenuInfo, function(l, r)
        if l.session < r.session then return true end
    end)
    
    -- 初始化菜单
    self:initListView("RankListView", self.rankCellPanel, data)
    self:initListView("LevelListView", self.levelCellPanel, LEVEL_RANGE)
    self:initListView("AreaListView", self.areaCellPanel, COMPETITION_AREA)

    -- 默认选项
    local listView = self:getControl("RankListView")
    local chosePanel = listView:getChildByTag(#self.kuafsdMenuInfo)
    self:onSelectListView(chosePanel)
    
    self.listViewIsInit = true
    
    DlgMgr:closeDlg("WaitDlg")
end

function KuafsdwzDlg:setDlgType()
    if DlgMgr:sendMsg("KuafsdTabDlg", "isMonthTaoKFSD") then
        -- 月道行跨服试道
        self:setCtrlVisible("AreaChoseButton", false)

        local levelBtn = self:getControl("LevelChoseButton")
        levelBtn:removeFromParent()
        local levelPanel = self:getControl("LevelListPanel")
        levelPanel:removeFromParent()

        local levelBtn = self:getControl("MonthLevelChoseButton")
        levelBtn:setName("LevelChoseButton")
        levelBtn:setVisible(true)
        local levelPanel = self:getControl("MonthLevelListPanel")
        levelPanel:setName("LevelListPanel")

        self:setImage("MiddleTitleImage_1", ResMgr.ui.month_tao_kuafsd_title)

        self.type = KFSD_TYPE.MONTH
    else
        self:setCtrlVisible("MonthLevelChoseButton", false)
        self:setImage("MiddleTitleImage_1", ResMgr.ui.kuafsd_title)
        self.type = KFSD_TYPE.NORMAL
    end
end

function KuafsdwzDlg:cleanup()
end

return KuafsdwzDlg
