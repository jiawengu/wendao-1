-- KuafzcjfDlg.lua
-- Created by songcw Aug/7/2017
-- 跨服战场，积分

local KuafzcjfDlg = Singleton("KuafzcjfDlg", Dialog)

local LIST_MARGIN_FLOAT = 8
local LIST_MARGIN_MENU = 5

--                 个人总积分          循环赛                        淘汰赛
local BIG_MENU = {CHS[4100709], CHS[4100710], CHS[4100711]}
local MENU_DISPALY_PANEL = {
    [CHS[4100709]] = "UserScorePanel",
    [CHS[4100710]] = "MatchScorePanel",
    [CHS[4100711]] = "MatchScorePanel",
}


function KuafzcjfDlg:init(notQuery)
    self:bindListener("LevelButton", self.onLevelButton)

    -- 等级悬浮框相关
    self.selectButton = self:retainCtrl("SelectButton")
    self:bindTouchEndEventListener(self.selectButton, self.onSelectFloatButton)
    self.sessionPanelSize = self.sessionPanelSize or self:getControl("LevelFloatPanel"):getContentSize()
    self.sessionListSize = self.sessionListSize or self:getControl("LevelListView"):getContentSize()

    -- 左侧菜单列表
    self.bigPanel = self:retainCtrl("BigPanel")    
    self.selectBigEff = self:retainCtrl("BChosenEffectImage", self.bigPanel)
    self:bindTouchEndEventListener(self.bigPanel, self.onSelectBigMenuButton)
    self.smallPanel = self:retainCtrl("SPanel")
    self.selectSmallEff = self:retainCtrl("SChosenEffectImage", self.smallPanel)
    self:bindTouchEndEventListener(self.smallPanel, self.onSelectSmallMenuButton)
    
    self.unitMatchPanel = self:retainCtrl("MatchPanel", "UserScorePanel")    
    
    if notQuery then    
    else
        KuafzcMgr:queryMatchScoreSimple()
    end 

    -- 悬浮
    self:bindFloatPanelListener("LevelFloatPanel", nil, nil, function ()
        self:setExpandState("LevelButton", false)
    end)

    -- 按钮菜单初始化
    self:initMenu()

    self:hookMsg("MSG_CSL_MATCH_SIMPLE")
    self:hookMsg("MSG_CSL_CONTRIB_TOP_DATA")
    self:hookMsg("MSG_CSL_MATCH_DATA")       
end

function KuafzcjfDlg:cleanup() 
    KuafzcMgr:cleanupForJFData()
    
    self.level = nil
    self.personageData = nil
    self.warData = {}
    self.oneMenu = nil
    self.twoMenu = nil
end

-- 初始化左侧菜单
function KuafzcjfDlg:initMenu() 
    local list = self:resetListView("MatchTypeListView", LIST_MARGIN_MENU)
    for i = 1, #BIG_MENU do
        local btn = self.bigPanel:clone()
        btn:setTag(i * 100)
        btn:setName(BIG_MENU[i])
        self:setLabelText("Label", BIG_MENU[i], btn)
        list:pushBackCustomItem(btn)
    end   
end

-- 增加大项菜单光效光效
function KuafzcjfDlg:addEffBigMenu(sender) 
    self.selectBigEff:removeFromParent()
    sender:addChild(self.selectBigEff)
end

function KuafzcjfDlg:addEffSmallMenu(sender) 
    self.selectSmallEff:removeFromParent()
    sender:addChild(self.selectSmallEff)
end

-- 1 显示向下，2向上，其他全部隐藏
function KuafzcjfDlg:setArrow(state, sender) 
    if state == 1 then
        self:setCtrlVisible("DownArrowImage", true, sender)
        self:setCtrlVisible("UpArrowImage", false, sender)
    elseif state == 2 then
        self:setCtrlVisible("DownArrowImage", false, sender)
        self:setCtrlVisible("UpArrowImage", true, sender)
    else
        self:setCtrlVisible("DownArrowImage", false, sender)
        self:setCtrlVisible("UpArrowImage", false, sender)
    end
end

function KuafzcjfDlg:addSecondMenu(sender) 
    local list = self:getControl("MatchTypeListView")
    local secondData = KuafzcMgr:getJfSecondMenu(sender:getName())
    local secondMenu = secondData[self.level .. "|" .. sender:getName()]
    
    sender.secondMenu = secondMenu
    
    if not secondMenu or secondMenu.count == 0 then 
        if self.oneMenu == CHS[4100711] then    -- 淘汰赛
            if secondMenu.group_end == 0 then
                self:setLabelText("InfoLabel1", CHS[4200443], "NoticePanel")  
            else
                self:setLabelText("InfoLabel1", CHS[4100725], "NoticePanel")  
            end
            self:setCtrlVisible("NoticePanel", true)
            self:setCtrlVisible("MatchScorePanel", false)
        elseif self.oneMenu == CHS[4100710] then
            
        end    
        
        self:setArrow(3, sender)
        return 
    end
    
    sender.isExp = true
    self:setArrow(2, sender)
    for i = 1, secondMenu.count do
        local smallMenu = self.smallPanel:clone()
        smallMenu.data = secondMenu[i]
        self:setLabelText("Label", secondMenu[i].title, smallMenu)
        smallMenu:setName(secondMenu[i].match_name)
        list:insertCustomItem(smallMenu, math.floor(sender:getTag() / 100) + i - 1)
        
        if self.twoMenu == nil then
            self:onSelectSmallMenuButton(smallMenu)
            if self.oneMenu == CHS[4100711] then    -- 淘汰赛
                local isOpen = self:isOpenedWar(self.twoMenu, CHS[4100711])
                if not isOpen then
                    self:setLabelText("InfoLabel1", CHS[4200443], "NoticePanel")  
                    self:setCtrlVisible("NoticePanel", not isOpen)
                    self:setCtrlVisible(MENU_DISPALY_PANEL[self.oneMenu], isOpen)
                end
            end    
        end
    end
end

-- 收起所有二级菜单
function KuafzcjfDlg:removeAllSecondMenu() 
    local list = self:getControl("MatchTypeListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel:getTag() % 100 ~= 0 then
            list:removeChild(panel)
        else
            if not panel.secondMenu or panel.secondMenu.count == 0 then
                self:setArrow(3, panel)
            else
                self:setArrow(1, panel)
            end
            panel.isExp = false
        end
    end  
    
    list:requestRefreshView()
end

function KuafzcjfDlg:setWarInfo(data)
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

-- 点击二级菜单
function KuafzcjfDlg:onSelectSmallMenuButton(sender, eventType)
    if sender.notTouch then return end
    
    -- 增加光效 
    self:addEffSmallMenu(sender)
    
    self.twoMenu = sender:getName()
    
    -- 设置右上方信息
    self:setWarInfo(sender.data)
    
    if self.warData and self.warData[self.twoMenu] then
        self:MSG_CSL_MATCH_DATA(self.warData[self.twoMenu])
    else
        KuafzcMgr:queryJfRankByLvAndName(self.level, sender:getName())
    end    
end

-- 点击大项菜单
function KuafzcjfDlg:onSelectBigMenuButton(sender, eventType)
    if sender.notTouch then return end

    if self.oneMenu == sender:getName() and sender.isExp then
        -- 先删除所有二级菜单
        self:removeAllSecondMenu()
        return
    end
    
    self.oneMenu = sender:getName()

    self:setCtrlVisible("UserScorePanel", self.oneMenu == CHS[4100709])
    self:setCtrlVisible("MatchScorePanel", self.oneMenu ~= CHS[4100709])
    self:setCtrlVisible("NoticePanel", false)    
    
    self.twoMenu = nil

    -- 增加光效 
    self:addEffBigMenu(sender)
    
    -- 先删除所有二级菜单
    self:removeAllSecondMenu()
    
    -- 若有二级菜单，增加
    self:addSecondMenu(sender)
    
    -- 个人总积分
    if sender:getName() == CHS[4100709] then  
        if self.personageData then
            self:MSG_CSL_CONTRIB_TOP_DATA(self.personageData)
        else              
            local isOpen = false    -- 个人积分是否已经有了
            local simData = KuafzcMgr:getJfSimpleData()
            for i = 1, simData.level_section_count do
                local data = simData.levelRangeInfo[i]
                if data.level_min == self.level then
                    isOpen = (data.has_total_top == 1)
                end
            end
            
            self:setCtrlVisible("UserScorePanel", isOpen)
            self:setCtrlVisible("NoticePanel", not isOpen)
            if not isOpen then
                self:setLabelText("InfoLabel1", CHS[4100727], "NoticePanel")          -- 当前尚未开始比赛
            else
                KuafzcMgr:queryJfRankTotalPlayers(self.level)
            end
        end                
    end
end

-- 点击悬浮框中的按钮
function KuafzcjfDlg:onSelectFloatButton(sender, eventType) 
    local btn = self:getControl("LevelButton")    
    btn:setTitleText(sender:getTitleText())
    self:setExpandState("LevelButton", false)    
    self:setCtrlVisible("LevelFloatPanel", false)
    
    self.level = sender:getTag()
end

function KuafzcjfDlg:setExpandState(panelName, state)
    local panel = panelName
    if type(panelName) == "string" then
        panel = self:getControl(panelName)
    end

    self:setCtrlVisible("ShrinkImage", state, panel)
    self:setCtrlVisible("ExpandImage", not state, panel)
end

function KuafzcjfDlg:onLevelButton(sender, eventType)
    local data = KuafzcMgr:getJfSimpleData()
    if not data then return end     -- 数据没有到，点也不给你响应
    self:setCtrlVisible("LevelFloatPanel", true)    
    self:setExpandState(sender, true)
end

-- 设置level悬浮框
function KuafzcjfDlg:setLevelPanel(data)
    local list, size = self:resetListView("LevelListView", LIST_MARGIN_FLOAT, ccui.ListViewGravity.centerHorizontal)
    for i = 1, data.level_section_count do
        local btn = self.selectButton:clone()
        btn:setTag(data.levelRangeInfo[i].level_min)
        if data.levelRangeInfo[i].level_max == 0 then
            btn:setTitleText(string.format(CHS[6000113], data.levelRangeInfo[i].level_min))
        else
            btn:setTitleText(string.format(CHS[4100712], data.levelRangeInfo[i].level_min, data.levelRangeInfo[i].level_max))
        end
        list:pushBackCustomItem(btn)
        
        if not self.level then
            self:onSelectFloatButton(btn)
        end
    end    

    local panel = self:getControl("LevelFloatPanel")
    self:setFloatContentSize(panel, list, data.level_section_count)
end

function KuafzcjfDlg:setFloatContentSize(panel, list, count)
    -- 策划反复无常，先说最小尺寸为2的，现在要兼容1
    if count < 2 then 
        local addHeight = (self.selectButton:getContentSize().height + LIST_MARGIN_FLOAT) -- LIST_MARGIN
        panel:setContentSize(self.sessionPanelSize.width, self.sessionPanelSize.height - addHeight)
        list:setContentSize(self.sessionListSize.width, self.sessionListSize.height - addHeight)
    elseif count == 2 then
        panel:setContentSize(self.sessionPanelSize)
        list:setContentSize(self.sessionListSize)
    else
        local maxCount = math.min(5, count)
        local addHeight = (maxCount - 2) * (self.selectButton:getContentSize().height + LIST_MARGIN_FLOAT) -- LIST_MARGIN
        panel:setContentSize(self.sessionPanelSize.width, self.sessionPanelSize.height + addHeight)
        list:setContentSize(self.sessionListSize.width, self.sessionListSize.height + addHeight)
    end
    
    panel:requestDoLayout()
    self:updateLayout("MainBodyPanel")
end

function KuafzcjfDlg:MSG_CSL_MATCH_SIMPLE(data)
    self:setLevelPanel(data)
    
    self:onSelectBigMenuButton(self:getControl(CHS[4100709]))
    
    --
    local list = self:getControl("MatchTypeListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel:getTag() % 100 ~= 0 then
        else
            local secondData = KuafzcMgr:getJfSecondMenu(panel:getName())
            local secondMenu = secondData[self.level .. "|" .. panel:getName()]
            if not secondMenu or secondMenu.count == 0 then
                self:setArrow(3, panel)
            else
                self:setArrow(1, panel)
            end
            panel.secondMenu = secondMenu
        end
    end  

    list:requestRefreshView()
end

function KuafzcjfDlg:setUnitMathPanel(data, i, panel)
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

    -- 战斗次数
    self:setLabelText("CombatTimeLabel", data.combat, panel)

    -- 胜率
    if data.combat == "" then
        self:setLabelText("WinRateLabel", "", panel)
    elseif data.combat == 0 or data.win == 0 then
        self:setLabelText("WinRateLabel", "0%", panel)
    else
        local rate = data.win / data.combat * 100        
        self:setLabelText("WinRateLabel", string.format("%.1f%%", rate), panel)
    end
    
    self:setCtrlVisible("BackImage_2", i % 2 == 0, panel)
end


function KuafzcjfDlg:setRankiInfo(data, panelName)
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

function KuafzcjfDlg:MSG_CSL_CONTRIB_TOP_DATA(data)
    self.personageData = data
    if self.oneMenu ~= CHS[4100709] then return end
    
    self:setRankiInfo(data, MENU_DISPALY_PANEL[self.oneMenu])   -- "UserScorePanel"
    
    local myPanel = self:getControl("MyselfPanel", nil, MENU_DISPALY_PANEL[self.oneMenu])
    self:setUnitMathPanel(data.myRankInfo[1], 1, myPanel)
end

function KuafzcjfDlg:MSG_CSL_MATCH_DATA(data, isInWar)
    if not self.warData then self.warData = {} end
    self.warData[data.name or data.match_name] = data
    
    -- 一级菜单不一致，无效
    if self.oneMenu == CHS[4100709] then return end
    
    -- 二级菜单不一致，无效
    local secondMenu = data.name or data.match_name
    if secondMenu ~= self.twoMenu then return end

    local myData = self:setRankiInfo(data, MENU_DISPALY_PANEL[self.oneMenu])      -- MatchScorePanel
    
    local myPanel = self:getControl("MyselfPanel", nil, MENU_DISPALY_PANEL[self.oneMenu])
    self:setUnitMathPanel(myData, 1, myPanel)    
    
    if not isInWar then
        if self.oneMenu == BIG_MENU[2] then
            self:setLabelText("InfoLabel1", CHS[4100726], "NoticePanel")        -- 本场比赛尚未开始
            
            -- 判断本场比赛是未开始，还是都没有人进入比赛而没有数据
            local isOpen = self:isOpenedWar(secondMenu, BIG_MENU[2])
            self:setCtrlVisible("NoticePanel", not isOpen)
            self:setCtrlVisible(MENU_DISPALY_PANEL[self.oneMenu], isOpen)
        else
        --    
            local isOpen = self:isOpenedWar(self.twoMenu, CHS[4100711])
            if not isOpen then
                self:setLabelText("InfoLabel1", CHS[4200443], "NoticePanel")  
                self:setCtrlVisible("NoticePanel", not isOpen)
                self:setCtrlVisible(MENU_DISPALY_PANEL[self.oneMenu], isOpen)
            else
                self:setLabelText("InfoLabel1", CHS[4100725], "NoticePanel")        -- 本区组未能进入淘汰赛
            end
        end
    end
end

-- 该比赛是否开始
function KuafzcjfDlg:isOpenedWar(matchName, menu)
    local groData = KuafzcMgr:getJfSecondMenu(menu)
    local ret = groData[self.level .. "|" .. menu]
    if ret then
        for i = 1, ret.count do
            if matchName == ret[i].match_name then
                return gf:getServerTime() >= ret[i].start_time
            end
        end
    end
end

function KuafzcjfDlg:paraData(data)
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
function KuafzcjfDlg:setData(data)
    local isGroup = data.round <= data.group_round    
    local list = self:resetListView("MatchTypeListView", LIST_MARGIN_MENU)
    self:setCtrlEnabled("LevelButton", false)

    local btn = self.bigPanel:clone()
    btn.notTouch = true
    if isGroup then
        self:setLabelText("Label", BIG_MENU[2], btn)
        self.oneMenu = BIG_MENU[2]
    else
        self:setLabelText("Label", BIG_MENU[3], btn)
        self.oneMenu = BIG_MENU[3]
    end
    self:addEffBigMenu(btn)
    list:pushBackCustomItem(btn)
    
    local ret = self:paraData(data)
    local smallMenu = self.smallPanel:clone()
    smallMenu.notTouch = true
    self:setLabelText("Label", ret.title, smallMenu)
    list:pushBackCustomItem(smallMenu)
    -- 增加光效 
    self:addEffSmallMenu(smallMenu)
    
    -- 比赛信息
    self:setWarInfo(ret)
    self.twoMenu = ret.match_name
    -- 等级段
    local btn = self:getControl("LevelButton")    
    if data.level_max == 0 then
        btn:setTitleText(string.format(CHS[6000113], data.level_min))
    else
        btn:setTitleText(string.format(CHS[4100712], data.level_min, data.level_max))
    end
    
    self:MSG_CSL_MATCH_DATA(data, true)
    
    self:setCtrlVisible("NoticePanel", false)
    self:setCtrlVisible("MatchScorePanel", true)
end

return KuafzcjfDlg
