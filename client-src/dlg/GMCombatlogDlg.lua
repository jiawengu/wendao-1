-- GMCombatlogDlg.lua
-- Created by haungzz Jan/30/2018
-- 战斗记录查询界面

local GMCombatlogDlg = Singleton("GMCombatlogDlg", Dialog)


local TEXTFIELDS_INFO = {
    {len = 10, panelName = "ActivityNamePanel"},
    {len = 10, panelName = "PlayerGIDPanel"},
    {len = 10, panelName = "ZoneNamePanel"},
    {len = 2, panelName = "YearPanel1"},
    {len = 1, panelName = "MonthPanel1"},
    {len = 1, panelName = "DayPanel1"},
    {len = 2, panelName = "YearPanel2"},
    {len = 1, panelName = "MonthPanel2"},
    {len = 1, panelName = "DayPanel2"},
}

function GMCombatlogDlg:init()
    self:bindListener("PlayButton", self.onPlayButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("ChoiceCheckBox", self.onChoiceCheckBox)
    -- self:bindListViewListener("VideoListView", self.onSelectVideoListView)
    
    self.selectBox = nil
    self.loadNum = 1
    
    self.videoPanel = self:retainCtrl("VideoPanel")
    self:resetListView("VideoListView")
    
    -- 滚动加载
    self:bindListViewByPageLoad("VideoListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:setListView()
        end
    end, "ResultPanel")
    
    self.inputCtrls = {}
    for i = 1, #TEXTFIELDS_INFO do
        local info = TEXTFIELDS_INFO[i]
        self:bindEditFieldForSafe(info.panelName, info.len, nil, nil)
        
        local textCtrl = self:getControl("TextField", nil, info.panelName)
        self.inputCtrls[i] = textCtrl
    end
    
    
    self:setDefaultTime()
    
    self:hookMsg("MSG_ADMIN_BROADCAST_COMBAT_LIST")
end

function GMCombatlogDlg:setDefaultTime()
    local endTime = gf:getServerTime()
    local startTime = endTime - 6 * 24 * 60 * 60
    
    local temp = gf:getServerDate("*t", startTime)
    self:setText(4, temp["year"])
    self:setText(5, temp["month"])
    self:setText(6, temp["day"])
    
    local temp = gf:getServerDate("*t", endTime)
    self:setText(7, temp["year"])
    self:setText(8, temp["month"])
    self:setText(9, temp["day"])
end

function GMCombatlogDlg:getText(index)
    if not self.inputCtrls[index] then
        return ""
    end

    return self.inputCtrls[index]:getStringValue() or ""
end

function GMCombatlogDlg:setText(index, str)
    if not self.inputCtrls[index] then
        return
    end

    return self.inputCtrls[index]:setText(str or "")
end

-- 获取输入框的活动名
function GMCombatlogDlg:getActivityName()
    return self:getText(1)
end

-- 获取输入框的玩家名字或Gid
function GMCombatlogDlg:getPlayerNameOrGid()
    return self:getText(2)
end

-- 获取输入框的区组名
function GMCombatlogDlg:getZoneName()
    return self:getText(3)
end

-- 获取输入框的查询时间
function GMCombatlogDlg:getTimeRange()
    local year = tonumber(self:getText(4))
    local month = tonumber(self:getText(5))
    local day = tonumber(self:getText(6))
    
    if string.isNilOrEmpty(year) 
        or string.isNilOrEmpty(month)
        or string.isNilOrEmpty(day)
        or not gf:checkTimeLegal(year, month, day) then
        return -1, -1
    end
    
    local minTime = os.time{
        year = year, 
        month = month, 
        day = day, 
        hour = 0, 
        min = 0, 
        sec = 0
    }
    
    local year = tonumber(self:getText(7))
    local month = tonumber(self:getText(8))
    local day = tonumber(self:getText(9))
    
    if string.isNilOrEmpty(year) 
        or string.isNilOrEmpty(month)
        or string.isNilOrEmpty(day)
        or not gf:checkTimeLegal(year, month, day) then
        return -1, -1
    end
    
    local maxTime = os.time{
        year = year, 
        month = month,
        day = day, 
        hour = 23, 
        min = 59, 
        sec = 59}
    
    return minTime or -1, maxTime or -1
end

function GMCombatlogDlg:checkAllEmpty()
    for i = 1, #TEXTFIELDS_INFO do
        if self:getText(i) ~= "" then
            return false
        end
    end
    
    return true
end

function GMCombatlogDlg:onChoiceCheckBox(sender, eventType)
    if self.selectBox == sender then
        self.selectBox:setSelectedState(false)
        self.selectBox = nil
        return
    end
    
    if self.selectBox then
        self.selectBox:setSelectedState(false)
    end

    self.selectBox = sender
end

function GMCombatlogDlg:setListView(isReset)
    if not self.data then
        return
    end

    local data = self.data
    local listView = self:getControl("VideoListView")
    if isReset then
        self:clearAllVideo()
    end

    local loadNum = self.loadNum
    if loadNum > data.count then
        return
    end
    
    local ONE_LOAD_NUM = 10
    for i = 1, ONE_LOAD_NUM do
        if data[loadNum] then
            local cell = self.videoPanel:clone()
            self:setOnePanel(data[loadNum], loadNum, cell)
            listView:pushBackCustomItem(cell)

            loadNum = loadNum + 1
        end
    end

    listView:doLayout()
    listView:refreshView()
    self.loadNum = loadNum
end

function GMCombatlogDlg:setOnePanel(data, tag, cell)
    self:setLabelText("ZoneNameLabel", data.dist or "", cell)
    
    self:setLabelText("PlayerNameLabel", data.atk_name or "", cell)
        
    self:setLabelText("ActivityLabel", data.combat_type or "", cell)
    
    self:setLabelText("TimeLabel", gf:getServerDate(CHS[5410193], data.time), cell)
    
    cell.combat_id = data.combat_id
end

function GMCombatlogDlg:onPlayButton(sender, eventType)
    if not self.selectBox then
        gf:ShowSmallTips(CHS[5420266])
        return
    end
    
    local parent = self.selectBox:getParent()
    
    if parent.combat_id then
        WatchCenterMgr:setNotShowShareAndBarrage(parent.combat_id)
        gf:CmdToServer("CMD_ADMIN_REQUEST_LOOKON_GDDB_COMBAT", {combat_id = parent.combat_id})
    end
end

function GMCombatlogDlg:onCancelButton(sender, eventType)
    gf:confirm(CHS[5420279], function()
        if DlgMgr:isDlgOpened("GMCombatlogDlg") then
            for i = 1, 9 do
                self:setText(i, "")
            end
            
            self:clearAllVideo()
            self.data = nil
        end
    end)
end

function GMCombatlogDlg:clearAllVideo()
    local listView = self:getControl("VideoListView")
    listView:removeAllItems()
    self.selectBox = nil
    self.loadNum = 1
end

function GMCombatlogDlg:onSearchButton(sender, eventType)
    local activityName = self:getActivityName()
    local playerStr = self:getPlayerNameOrGid()
    local zoneName = self:getZoneName()
    local minTime, maxTime = self:getTimeRange()
    
    if self:checkAllEmpty() then
        gf:ShowSmallTips(CHS[5420264])
        return
    end
    
    if minTime < 0 or minTime > maxTime then
        gf:ShowSmallTips(CHS[5420265])
        return
    end

    gf:CmdToServer("CMD_ADMIN_BROADCAST_COMBAT_LIST", {
        dist = zoneName,
        combat_type = activityName,
        name_or_gid = playerStr,
        begin_time = minTime,
        end_time = maxTime
    })
end

function GMCombatlogDlg:MSG_ADMIN_BROADCAST_COMBAT_LIST(data)
    self.data = data
    
    table.sort(self.data, function(l, r) 
        if l.time > r.time then return true end
        
        return false
    end)
    
    self:setListView(true)
end

return GMCombatlogDlg
