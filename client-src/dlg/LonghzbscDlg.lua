-- LonghzbscDlg.lua
-- Created by songcw Nov/28/2016
-- 龙争虎斗赛程界面

local LonghzbscDlg = Singleton("LonghzbscDlg", Dialog)

-- 悬浮Panel对应的按钮
local FLOAT_PANEL_BTN = {
    ["LevelPanel"] = "LevelButton",
    ["MatchTypePanel"] = "MatchTypeButton",
    ["MatchIndexPanel"] = "MatchIndexButton",
}

-- 向服务器请求的key值，分 等级、类别、场次
-- 等级key
local LEVEL_PANEL_KEY = {
    [1] = "60-79",   [2] = "80-89",   [3] = "90-99",   [4] = "100-109",
}

-- 赛程key
local WAR_SCHEDULE_PANEL_KEY = {
    [1] = LongZHDMgr.RACE_INDEX.SCORE,   [2] = LongZHDMgr.RACE_INDEX.FINAL,
}

-- 场次key
local INDEX_PANEL_KEY = {
    [1] = 1,   [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, 
}

-- 一二十四五六七八
local DEF_TEAM_NAME = {
    [1] = CHS[6000055],   [2] = CHS[6000056], [3] = CHS[6000057], [4] = CHS[6000058], [5] = CHS[6000059], [6] = CHS[6000060], [7] = CHS[6000061], [8] = CHS[6000062], 
}

function LonghzbscDlg:init()
    -- 初始化按钮
    self:initButton()
    
    -- 悬浮panel的点击事件             等级、赛制、场次
    self:bindFloatPanels()
    
    self:hookMsg("MSG_LH_GUESS_PLANS")
    self:hookMsg("MSG_LH_GUESS_TEAM_INFO")
end

-- 处理数据，若无相关数据则请求服务器，有则设置
function LonghzbscDlg:dealData()
    -- 获取数据
    local levelKey, typyKey, indexKey, key = self:getKey()
    
    local data = LongZHDMgr:getWarScheduleDataByKey(key)
    if data then
        -- 有数据则直接设置并且向服务器请求更新
        self:setData(data)
        LongZHDMgr:queryWarPlans(levelKey, typyKey, indexKey, data.last_ti)
    else
        self:setNoneData()
        LongZHDMgr:queryWarPlans(levelKey, typyKey, indexKey)
    end
end


-- 点击某个队伍
function LonghzbscDlg:onSelectTeam(sender, eventType)
    local camp_index = sender.camp_index
    local camp_type = sender.camp_type
    
    if not camp_index then return end
    local levelKey, typyKey, indexKey, key = self:getKey()
    LongZHDMgr:queryTeamInfo(levelKey, camp_type, camp_index)
end

-- 无数据时界面显示
function LonghzbscDlg:setNoneData()    
    for i = 1, 8 do
        local parentPanel = self:getControl("PointsracePanel_" .. i)
        self:setCleanSingleWarInfo(parentPanel, i)
    end
    
    -- 决赛
    self:setFinalNoData()
end

-- 决赛无数据
function LonghzbscDlg:setFinalNoData()
    local levelKey, typyKey, indexKey, key = self:getKey()

    -- 等级
    self:setLabelText("LevelLabel", levelKey .. CHS[3002256], "FinalsPanel")

    -- 时间
    local timeData = LongZHDMgr:getTimeData()
    if not timeData then
        self:setLabelText("TimeLabel", CHS[4400012], "FinalsPanel")
    else
        self:setLabelText("TimeLabel", timeData.final_race, "FinalsPanel")
    end
    
    -- 无数据
    local tempData = {["BHIndex"] = 1,["BHName"] = CHS[4300172],["QLIndex"] = 1,["QLName"] = CHS[4300173],["warRet"] = "none", cfg = 1}
    self:setSingleWarInfo(tempData, self:getControl("FinalsPanel"))
end

-- 设置数据
function LonghzbscDlg:setData(data)
    if data.race_index == LongZHDMgr.RACE_INDEX.SCORE then
        -- 积分赛
        for i = 1, 8 do
            local parentPanel = self:getControl("PointsracePanel_" .. i)
            self:setSingleWarInfo(data[i], parentPanel)
        end
    elseif data.race_index == LongZHDMgr.RACE_INDEX.FINAL then
        -- 决赛
        -- 无数据
        self:setFinalNoData()
        
        if not data[0] then
            -- 有数据,索引为 可能为1-8
            for i = 1, 8 do
                if data[i] then
                    self:setSingleWarInfo(data[i], self:getControl("FinalsPanel"))
                end
            end
            
        end 
    end
end

function LonghzbscDlg:getDefBaiHuIndex(i)
    local levelKey, typyKey, indexKey, key = self:getKey()
    local start = 8 - (indexKey - 1)
    local ret = start + i - 1
    if ret > 8 then ret = ret - 8 end
    
    return ret
end

-- 设置单挑对战信息,清空状态
function LonghzbscDlg:setCleanSingleWarInfo(panel, i)
    local qlPanel = self:getControl("DragonTeamPanel", nil, panel)
    local bhPanel = self:getControl("TigerTeamPanel", nil, panel)
    
    qlPanel.camp_index = nil
    qlPanel.camp_type = nil

    bhPanel.camp_index = nil
    bhPanel.camp_type = nil
    
    -- 设置队名
    self:setLabelText("TeamLabel", string.format(CHS[4300174], DEF_TEAM_NAME[i]), qlPanel)
    local bhIndex = self:getDefBaiHuIndex(i)
    self:setLabelText("TeamLabel", string.format(CHS[4300175], DEF_TEAM_NAME[bhIndex]), bhPanel)
    
    -- 设置编号
    self:setCtrlVisible("IndexImage_2", true, qlPanel)
    self:setCtrlVisible("IndexImage_2", true, bhPanel)
    self:setImage("IndexImage_2", LongZHDMgr:getIndexRes(i), qlPanel)
    self:setImage("IndexImage_2", LongZHDMgr:getIndexRes(bhIndex), bhPanel)
    
    self:setCtrlVisible("ResultImage", false, qlPanel)
    self:setCtrlVisible("ResultImage", false, bhPanel)
end

-- 设置单挑对战信息
function LonghzbscDlg:setSingleWarInfo(data, panel)
    local qlPanel = self:getControl("DragonTeamPanel", nil, panel)
    local bhPanel = self:getControl("TigerTeamPanel", nil, panel)
    
    qlPanel.camp_index = data.QLIndex
    qlPanel.camp_type = "camp_qinglong"
    self:bindTouchEndEventListener(qlPanel, self.onSelectTeam)
    
    bhPanel.camp_index = data.BHIndex
    bhPanel.camp_type = "camp_baihu"
    self:bindTouchEndEventListener(bhPanel, self.onSelectTeam)
    
    if data.cfg then
        qlPanel.camp_index = nil
        qlPanel.camp_type = nil
        bhPanel.camp_index = nil
        bhPanel.camp_type = nil
    end
    
    -- 设置队名
    self:setLabelText("TeamLabel", data.QLName, qlPanel)
    self:setLabelText("TeamLabel", data.BHName, bhPanel)
    
    -- 设置编号
    self:setCtrlVisible("IndexImage_2", true, qlPanel)
    self:setCtrlVisible("IndexImage_2", true, bhPanel)
    self:setImage("IndexImage_2", LongZHDMgr:getIndexRes(data.QLIndex), qlPanel)
    self:setImage("IndexImage_2", LongZHDMgr:getIndexRes(data.BHIndex), bhPanel)
    
    -- 胜负
    self:setCtrlVisible("ResultImage", true, qlPanel)
    self:setCtrlVisible("ResultImage", true, bhPanel)
    if data.warRet == "win_ql" then
        -- 青龙胜利         
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, qlPanel)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, bhPanel)
    elseif data.warRet == "win_bh" then
        -- 白虎胜利
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, qlPanel)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, bhPanel)
    elseif data.warRet == "draw" then
        -- 平局
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_draw, qlPanel)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_draw, bhPanel)
    elseif data.warRet == "none" or data.warRet == "" or data.warRet == nil then
        -- 没有结果
        self:setCtrlVisible("ResultImage", false, qlPanel)
        self:setCtrlVisible("ResultImage", false, bhPanel)
    end
end


-- 按钮增加key字段，设置按钮的key值
function LonghzbscDlg:setButtonKey(btnName, key)
    local btn = self:getControl(btnName)
    if btn then btn.key = key end
end

-- 获取查询数据的key值
function LonghzbscDlg:getKey()
    local levelKey = self:getControl("LevelButton").key
    local typyKey = self:getControl("MatchTypeButton").key
    local indexKey = self:getControl("MatchIndexButton").key
    
    return levelKey, typyKey, indexKey, levelKey .. typyKey .. indexKey
end

-- 获取自身所在的等级段
function LonghzbscDlg:setDefLevelButton()
    local def = 1
    if Me:getLevel() < 80 then
        def = 1 
    elseif Me:getLevel() < 90 then
        def = 2
    elseif Me:getLevel() < 100 then
        def = 3 
    elseif Me:getLevel() < 109 then
        def = 4 
    end
    
    self:onSelectLevelButton(self:getControl("LevelCheckBox_" .. def))
end

-- 初始化按钮点击事件
function LonghzbscDlg:initButton()
    -- 等级、选择等级
    self:bindListener("LevelButton", self.onLevelButton)   
    -- 设置默认查询的key值 
    self:setButtonKey("LevelButton", LEVEL_PANEL_KEY[1])
    for i = 1, 4 do
        local btn = self:getControl("LevelCheckBox_" .. i)
        btn:setTag(i)
        btn.key = LEVEL_PANEL_KEY[i]
        -- 事件监听
        self:bindTouchEndEventListener(btn, self.onSelectLevelButton)
    end

    -- 赛制、选择赛制
    self:bindListener("MatchTypeButton", self.onMatchTypeButton)
    -- 设置默认查询的key值 
    self:setButtonKey("MatchTypeButton", WAR_SCHEDULE_PANEL_KEY[1])
    for i = 1, 2 do
        local btn = self:getControl("MatchTypeCheckBox_" .. i)
        btn:setTag(i)
        btn.key = WAR_SCHEDULE_PANEL_KEY[i]
        -- 事件监听
        self:bindTouchEndEventListener(btn, self.onSelectMatchTypeButton)
    end

    -- 场次，选择场次
    self:bindListener("MatchIndexButton", self.onMatchIndexButton)
    -- 设置默认查询的key值 
    self:setButtonKey("MatchIndexButton", INDEX_PANEL_KEY[1])
    for i = 1, 8 do
        local btn = self:getControl("MatchIndexCheckBox_" .. i)
        btn:setTag(i)
        btn.key = INDEX_PANEL_KEY[i]
        -- 事件监听
        self:bindTouchEndEventListener(btn, self.onSelectMatchIndexButton)
    end
    
    self:setDefLevelButton()
end

-- 设置悬浮Panel状态，并且相关按钮箭头设置
function LonghzbscDlg:setFloatVisible(ctrlName, isVisible)
    self:setCtrlVisible(ctrlName, isVisible)
    self:setCtrlVisible("ExpandImage", not isVisible, FLOAT_PANEL_BTN[ctrlName])
    self:setCtrlVisible("ShrinkImage", isVisible, FLOAT_PANEL_BTN[ctrlName])
end

-- 选择具体某个等级段
function LonghzbscDlg:onSelectLevelButton(sender, eventType)
    -- 设置显示的字符串
    local str = sender:getTitleText()
    self:setButtonText("LevelButton", str)
    
    -- 隐藏选择等级的悬浮Panel
    self:setFloatVisible("LevelPanel", false)
    
    -- 设置查询的key值 
    local tag = sender:getTag()
    self:setButtonKey("LevelButton", LEVEL_PANEL_KEY[tag])
    
    -- 处理数据，若无相关数据则请求服务器，有则设置
    self:dealData()
end

-- 选择具体某个赛制
function LonghzbscDlg:onSelectMatchTypeButton(sender, eventType)
    -- 设置显示的字符串
    local str = sender:getTitleText()
    self:setButtonText("MatchTypeButton", str)

    -- 隐藏选择赛制的悬浮Panel
    self:setFloatVisible("MatchTypePanel", false)
    
    -- 显示相关赛制的控件
    self:setDisplayMatchType(str)
    
    -- 设置查询的key值 
    local tag = sender:getTag()
    self:setButtonKey("MatchTypeButton", WAR_SCHEDULE_PANEL_KEY[tag])
    
    -- 处理数据，若无相关数据则请求服务器，有则设置
    self:dealData()
end

function LonghzbscDlg:setDisplayMatchType(matchType)
    -- 积分赛的panel
    self:setCtrlVisible("PointsracePanel", matchType == CHS[4300176])  -- 4300176:积分赛
    
    -- 决赛的panel
    self:setCtrlVisible("FinalsPanel", matchType ~= CHS[4300176])
    
    -- 场次选择
    self:setCtrlVisible("MatchIndexButton", matchType == CHS[4300176])
end

-- 选择具体某个场次
function LonghzbscDlg:onSelectMatchIndexButton(sender, eventType)
    -- 设置显示的字符串
    local str = sender:getTitleText()
    self:setButtonText("MatchIndexButton", str)

    -- 隐藏选择场次的悬浮Panel
    self:setFloatVisible("MatchIndexPanel", false)
    
    -- 设置查询的key值 
    local tag = sender:getTag()
    self:setButtonKey("MatchIndexButton", INDEX_PANEL_KEY[tag])
    
    -- 处理数据，若无相关数据则请求服务器，有则设置
    self:dealData()
end

-- 界面内的悬浮panel，点击其他地方隐藏,该界面有3个悬浮panel，所以不用 Dialog:bindFloatPanelListener(panelName)
function LonghzbscDlg:bindFloatPanels()
    -- 创建点击层
    local bkPanel = self:getControl("BKPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())

    -- 点击事件
    local ctrlNames = {"LevelPanel", "MatchTypePanel", "MatchIndexPanel"}
    local  function touch(touch, event)    
        local isCutClick = false
        for name, btnName in pairs(FLOAT_PANEL_BTN) do
            local panel = self:getControl(name)
            local rect = self:getBoundingBoxInWorldSpace(panel)
            local toPos = touch:getLocation()
            
            -- 在panel外，则隐藏该悬浮panel
            if not cc.rectContainsPoint(rect, toPos) and panel:isVisible() then
                self:setFloatVisible(name, false)
            end
        end
    
        -- 返回穿透类型
        return isCutClick
    end

    -- add and 绑定点击事件
    self.root:addChild(layout, 100, 1)
    gf:bindTouchListener(layout, touch)
end

-- 点击显示等级选择按钮
function LonghzbscDlg:onLevelButton(sender, eventType)
    local isVisible = self:getCtrlVisible("LevelPanel")    
    self:setFloatVisible("LevelPanel", not isVisible)
end

-- 点击显示选择赛制按钮
function LonghzbscDlg:onMatchTypeButton(sender, eventType)
    local isVisible = self:getCtrlVisible("MatchTypePanel")    
    self:setFloatVisible("MatchTypePanel", not isVisible)
end

-- 点击显示选择场次按钮
function LonghzbscDlg:onMatchIndexButton(sender, eventType)
    local isVisible = self:getCtrlVisible("MatchIndexPanel")    
    self:setFloatVisible("MatchIndexPanel", not isVisible)
end

-- 场次信息
function LonghzbscDlg:MSG_LH_GUESS_PLANS(data)
    local levelKey, typyKey, indexKey, key = self:getKey()
    -- 当等级段、赛程、场次一致则显示
    if levelKey == data.race_name and typyKey == data.race_index and indexKey == data.day then
        self:setData(data)
    end
end

-- 打开队伍信息
function LonghzbscDlg:MSG_LH_GUESS_TEAM_INFO(data)
    local dlg = DlgMgr:openDlg("LonghzbTeamInfoDlg")
    dlg:setData(data)
end

return LonghzbscDlg
