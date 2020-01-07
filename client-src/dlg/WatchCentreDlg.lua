-- WatchCentreDlg.lua
-- Created by songcw Feb/06/2017
-- 观战中心界面

local WatchCentreDlg = Singleton("WatchCentreDlg", Dialog)

local COLUMN = 2        -- 全部比赛面板，每行的个数

local LISTVIEW_MARGIN = 0

local PAGE_FOR_COMBAT_COUNT = 10    -- 每次加载个数

local REFRESH_TIME = 5 * 1000 -- 刷新按钮时间间隔

-- 观战单个比赛控件高度
local CELL_HEIGHT = 190

-- 特殊赛事在所有赛事下方，按文档顺序陪，初始化时会根据是否有赛事数据进行显示的判断
local WAR_TYPE = {
    CHS[4100453],   -- 所有赛事
    CHS[4101015],   -- 名人争霸赛(特殊赛事)
    CHS[7002193],   -- 全民PK赛(特殊赛事)
    CHS[4300219],
    CHS[3003208],   -- 帮战
 --   CHS[4100450],   -- 跨服帮战
    CHS[4100451],   -- 试道大会
    CHS[4100452],   -- 跨服试道大会
    CHS[4100704],   -- 跨服战场
    CHS[5400341],   -- 跨服竞技
}

local MINGRZB_MATCH_TYPE = WatchCenterMgr:getMingrzbCombatTypeCfg()
local QUANMPK_MATCH_TYPE = WatchCenterMgr:getQuanmpkCombatTypeCfg()

local m_combatType = ""

function WatchCentreDlg:init()
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("ChoseButton", self.onChoseButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    
    -- 搜索
    self:bindEditFieldForSafe("SearchPanel", 6, "CleanFieldButton", nil, nil, true)
    
    -- 初始化克隆
    self:initRetainPanels()
    
    -- 界面内，悬浮框
    self:bindFloatPanelListener("SreenPanel", "ChoseButton")
    
    self.selectCombatId = nil
    self.startNum       = 1
    self.isSearch = false
    
    -- 右下listView菜单初始化
    self:menuInit()  
    
    -- 滚动加载
    self:bindListViewByPageLoad("CombatsListView", "TouchPanel", function(dlg, percent)
        if percent > 100 and not self.isSearch and m_combatType ~= CHS[4300219] then
            -- 加载
            self:pushCombat()
        end
    end, "ListPanel")
end

-- 初始化克隆
function WatchCentreDlg:initRetainPanels()
    self.matchPanel = self:retainCtrl("CombatPanel")
    self.specailMatchPanel = self:retainCtrl("CombatPanel_2")
    self.specialTitlePanel = self:retainCtrl("TitleBigPanel")
    self.warTypePanel = self:retainCtrl("ScreenNameButton")

    self.menuPanel = self:retainCtrl("BigPanel")
    self.selectImage = self:retainCtrl("BChosenEffectImage_1", self.menuPanel)
    self.specialSelectImage = self:retainCtrl("BChosenEffectImage_2", self.menuPanel)
    self.arrowImage = self:retainCtrl("UpArrowImage", self.menuPanel)

    self:bindTouchEndEventListener(self.menuPanel, self.onMenuButton) 
end

-- 清理资源
function WatchCentreDlg:cleanup()
end

-- 界面右下          赛事类型选择设置初始化
function WatchCentreDlg:menuInit()
    local list = self:resetListView("CategoryListView", 0, ccui.ListViewGravity.centerHorizontal)
    
    for i = 1, #WAR_TYPE do
        local isSpecial = WatchCenterMgr:isSpecialMatch(WAR_TYPE[i])
        if not isSpecial or WatchCenterMgr:canShowSpecailMatch(WAR_TYPE[i]) then
            -- 特殊赛事，只在有比赛数据时显示
            local panel = self.menuPanel:clone()
            panel:setName(WAR_TYPE[i])
            self:setLabelText("Label", WAR_TYPE[i], panel)
            self:setCtrlVisible("BackImage_1", not isSpecial, panel)
            self:setCtrlVisible("BackImage_2", isSpecial, panel)

            list:pushBackCustomItem(panel)
        end
    end    

    local panel = list:getItems()[1]
    if panel then self:onMenuButton(panel) end
end

-- 增加combat进大厅列表
function WatchCentreDlg:pushCombat(data)
    local combatType = self:getCurCombatType()
    if combatType == CHS[4101015] or combatType == CHS[7002193] then
        -- 名人争霸赛、全民PK(特殊赛事)，走自己逻辑
        self:pushSpecialCombat(data)
        return    
    end

    if not data then
        data = WatchCenterMgr:getCombatsByIndex(self.startNum, PAGE_FOR_COMBAT_COUNT, self:getCurCombatType())
    end
    
    if not data or not next(data) then return end

    local list = self:getControl("CombatsListView")
    local amount = #data
    local low = math.ceil(amount / COLUMN)
    for i = 1, low do
        local panel = self.matchPanel:clone()
        
        local key1 = (i - 1) * COLUMN + 1
        local combat1 = self:getControl("MatchPanel1", nil, panel)
        self:setUnitWatchInfo(combat1, data[key1])
        
        local key2 = (i - 1) * COLUMN + 2
        local combat2 = self:getControl("MatchPanel2", nil, panel)
        self:setUnitWatchInfo(combat2, data[key2])       
        
        list:pushBackCustomItem(panel)
    end
    
    list:doLayout()
    
    self.startNum = self.startNum + amount
end

-- 增加特殊赛事比赛进大厅列表
function WatchCentreDlg:pushSpecialCombat(pushData)
    local data = pushData
    local curType = self:getCurCombatType()
    if not pushData then
        local subType = MINGRZB_MATCH_TYPE
        if curType == CHS[7002193] then
            subType = QUANMPK_MATCH_TYPE
        end

        if self.startNum > #subType then return end

        -- 特殊赛事，控件高度不一，滑动效果不好，策划要求一次全加进来
        for i = 1, #subType do
            local subType = subType[i]
            data = WatchCenterMgr:getSpecialCombat(curType, subType)
            if data and next(data) then
                self:pushSpecialCombat(data)
            end
        end

        -- 全部比赛结果加载完，将开始标记设置为结束标记
        self.startNum = #subType + 1
        return
    end

    if not data or not next(data) then return end

    local list = self:getControl("CombatsListView")

    -- 设置大标题
    local bigTitlePanel = self.specialTitlePanel:clone()
    self:setLabelText("TitleName", CHS[7150066] .. data[1][1].combat_sub_type, bigTitlePanel)
    if curType == CHS[7002193] then
        self:setLabelText("TitleName", CHS[7120144] .. data[1][1].combat_sub_type, bigTitlePanel)
    end

    list:pushBackCustomItem(bigTitlePanel)

    -- 设置战斗信息
    for i = 1, #data do
        local panel = self.specailMatchPanel:clone()
        self:setSpecailCombatUnitInfo(panel, data[i])
        list:pushBackCustomItem(panel)
    end

    list:requestRefreshView()

    self.startNum = self.startNum + 1
end

-- 设置单个比赛信息
function WatchCentreDlg:setSpecailCombatUnitInfo(panel, data)
    -- 设置小标题
    local smallTitlePanel = self:getControl("TitleSmallPanel", nil, panel)
    self:setLabelText("PlayerNameLabel1", data[1].att_dist .. "-" .. data[1].att_name, smallTitlePanel)
    self:setLabelText("PlayerNameLabel2", data[1].def_dist .. "-" .. data[1].def_name, smallTitlePanel)

    -- 设置战斗信息
    local row = math.ceil(#data / 2)
    for i = 1, #data do
        local cell = self:getControl("MatchPanel" .. i, nil, panel)
        self:setUnitWatchInfo(cell, data[i])
    end

    for i = #data + 1, 5 do
        local unUseCell = self:getControl("MatchPanel" .. i, nil, panel)
        unUseCell:removeFromParent()
    end

    local sz = panel:getContentSize()
    local bkImage1 = self:getControl("BKImage1", nil, panel)
    local bkImageSz1 = bkImage1:getContentSize()
    local bkImage2 = self:getControl("BKImage2", nil, panel)
    local bkImageSz2 = bkImage2:getContentSize()

    local minusHeight = (3 - row) * CELL_HEIGHT
    local bkImageMargin = (3 - row) * 4
    panel:setContentSize(sz.width, sz.height - minusHeight)
    bkImage1:setContentSize(bkImageSz1.width, bkImageSz1.height - minusHeight + bkImageMargin)
    bkImage2:setContentSize(bkImageSz2.width, bkImageSz2.height - minusHeight + bkImageMargin)

    panel:requestDoLayout()
end

-- 设置观看比赛信息
function WatchCentreDlg:setWatchsInfo()
    local list = self:resetListView("CombatsListView", LISTVIEW_MARGIN, ccui.ListViewGravity.centerHorizontal)
    self.startNum = 1    
    self.isSearch = false

    local combats = WatchCenterMgr:getCombats()
    if not combats or not next(combats) or combats.count == 0 then
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    self:pushCombat()
end

-- 设置单个比赛信息
function WatchCentreDlg:setUnitWatchInfo(cell, data)  
    if not data then         
        cell:setVisible(false)
        return 
    end
   
    -- 比赛名称
    self:setLabelText("MatchNameLabel", data.combat_type, cell)
    
    -- 时间
    self:setLabelText("TimeLabel", gf:getServerDate("%Y-%m-%d %H:%M", data.start_time), cell)
    
    -- 比赛玩家
    self:setLabelText("PlayerNameLabel1", gf:getRealName(data.att_name), cell)
    self:setLabelText("PlayerNameLabel2", gf:getRealName(data.def_name), cell)
    
    -- 观看次数
    self:setLabelText("NumLabel", data.view_times, cell)
    
    -- 回合数
    if data.combat_play_type == 1 then
        self:setLabelText("RoundLabel", "", cell)
    else
        self:setLabelText("RoundLabel", data.total_round .. CHS[4100449], cell)
    end
    
    local icon = WatchCenterMgr:getWatchIconAndName(data.combat_type)
    self:setImage("MatchImage", icon, cell)
    
    -- 比赛类型
    if data.combat_play_type == 1 then
        self:setLabelText("MatchTypeLabel", CHS[4100447], cell)
    else
        self:setLabelText("MatchTypeLabel", CHS[4100448], cell)
    end
    self:setImage("PlayNumImage", WatchCenterMgr:getWatchIconForPlayType(data.combat_play_type), cell)    
    
    
    -- 事件监听
    cell.data = data
    self:bindTouchEndEventListener(cell, self.onSelectWar)
end

function WatchCentreDlg:onSelectMenuByName(name)
  --  if m_combatType ~= name then return end
    local sender = self:getControl(name)
    if sender then
        self:onMenuButton(sender)
    end
end

-- 点击某个战斗
function WatchCentreDlg:onSelectWar(sender, eventType)
    local data = sender.data    
    WatchCenterMgr:queryWatchCombatById(data.combat_id)
    self.selectCombatId = data.combat_id
end

function WatchCentreDlg:getCurCombatType()
        
    return m_combatType
end

-- 查询
function WatchCentreDlg:onSearchButton(sender, eventType)
    local conditionStr = self:getInputText("TextField")    
    local combat_type = self:getCurCombatType()

    if conditionStr == "" then
        gf:ShowSmallTips(CHS[4100454])
        return
    end

    self.isSearch = true
    local list = self:resetListView("CombatsListView", LISTVIEW_MARGIN, ccui.ListViewGravity.centerHorizontal)

    if combat_type == CHS[4101015] or combat_type == CHS[7002193] then
        -- 策划要求名人争霸赛比赛结果一次全搜索出来
        local subType = MINGRZB_MATCH_TYPE
        if combat_type == CHS[7002193] then
            subType = QUANMPK_MATCH_TYPE
        end

        local insertFlag = false
        self.startNum = 1
        for i = 1, #subType do
            local subTypeData = WatchCenterMgr:getSpecialCombat(subType[i], conditionStr)
            if subTypeData and next(subTypeData) then
                insertFlag = true
                self:pushCombat(subTypeData)
            end
        end

        -- 全部比赛结果加载完，将开始标记设置为结束标记
        self.startNum = #subType + 1

        if not insertFlag then
            gf:ShowSmallTips(CHS[4100455])
            return
        end
    else
        local retData = WatchCenterMgr:getDataByCaptainAndCombatType(conditionStr, combat_type)
        if not retData or not next(retData) then
            gf:ShowSmallTips(CHS[4100455])

            return
        end

        self:pushCombat(retData)
    end
end

-- 清除field控件的字符串
function WatchCentreDlg:onCleanFieldButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    sender:setVisible(false)

    self:setCtrlVisible("DefaultLabel", true, parentPanel)
    self:setWatchsInfo()
end

function WatchCentreDlg:onMenuButton(sender, eventType)
    m_combatType = self:getLabelText("Label", sender)
    self.selectImage:removeFromParent()
    self.specialSelectImage:removeFromParent()

    if WatchCenterMgr:isSpecialMatch(m_combatType) then
        sender:addChild(self.specialSelectImage)
    else
        sender:addChild(self.selectImage)
    end

    self.arrowImage:removeFromParent()
    sender:addChild(self.arrowImage)

    self:setWatchsInfo()
end

function WatchCentreDlg:selectWatchType(watchType)
    local listView = self:getControl("CategoryListView")
    for k, v in pairs(listView:getChildren()) do
        if watchType == self:getLabelText("Label", v) then
            self:onMenuButton(v, 2)
            break
        end
    end
end

function WatchCentreDlg:onChoseButton(sender, eventType)
    local floatPanel = self:getControl("SreenPanel")
    floatPanel:setVisible(not floatPanel:isVisible())
end

-- 点击刷新按钮
function WatchCentreDlg:onRefreshButton(sender, eventType)
    WatchCenterMgr:queryWatchCombats()
    WatchCenterMgr:setIsRefreshData(true)
end

return WatchCentreDlg
