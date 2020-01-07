-- PartyFeedMonsterDlg.lua
-- Created by huangzz Sep/05/2017
-- 培育巨兽界面

local PartyFeedMonsterDlg = Singleton("PartyFeedMonsterDlg", Dialog)

local SATGE_INFO = {
    [1] = {growth = 100},
    [2] = {growth = 120},
    [3] = {growth = 180},
    [4] = {growth = 240},
}

-- 不同成长度对应巨兽形象
local PET_INFO = {
    [1] = {growth = 0, icon = 51518, numIcon = ResMgr.ui.chinese_num1},
    [2] = {growth = 100, icon = 51520, numIcon = ResMgr.ui.chinese_num2},
    [3] = {growth = 220, icon = 51521, numIcon = ResMgr.ui.chinese_num3},
    [4] = {growth = 400, icon = 51523, numIcon = ResMgr.ui.chinese_num4},
    [5] = {growth = 640, icon = 06600, numIcon = ResMgr.ui.chinese_num5},
}

local TASK_INFO = {
    [CHS[5400240]] = {icon = ResMgr.ui.pyjs_feed_grass},
    [CHS[5400241]] = {icon = ResMgr.ui.pyjs_yizhixunlian},
    [CHS[5400242]] = {icon = ResMgr.ui.pyjs_zhandouxunlian},
    [CHS[5400243]] = {icon = ResMgr.ui.pyjs_xuexijishu},
    [CHS[5400244]] = {icon = ResMgr.ui.pyjs_yunqiceshi},
    [CHS[5400245]] = {icon = ResMgr.ui.pyjs_suduxunlian},
}

function PartyFeedMonsterDlg:init(type)
    for i = 1, 3 do
        self:bindListener("ChoiceButton" .. i, self.onChoiceButton)
    end
    
    for i = 1, 4 do
        local panelName = "TaskPanel" .. i
        self:bindListener("GetButton", self.onGetButton, panelName)
        self:bindListener("GoButton", self.onGoButton, panelName)
        self:bindListener("DoneButton", self.onDoneButton, panelName)
    end
    
    self.curHasTask = nil

    self:bindListener("InfoButton", self.onInfoButton)
    
    self:hookMsg("MSG_PARTY_PYJS_ATTRIBS")
    self:hookMsg("MSG_PARTY_PYJS_STAGE_DATA")
end

-- 设置显示类型
function PartyFeedMonsterDlg:setViewType(type)
    if type == 1 then
        -- 选择培育巨兽属性
        self:setCtrlVisible("ChooseAttriPanel", true, "RightPanel")
        self:setCtrlVisible("FeedPanel", false, "RightPanel")
        self:setCtrlVisible("InfoLabel", true, "DownPanel")
        self:setCtrlVisible("InfoLabelPanel", false, "DownPanel")
        self:setCtrlVisible("SubTitleLabel1", true, "SubTitlePanel")
        self:setCtrlVisible("SubTitleLabel2", false, "SubTitlePanel")
    else
        -- 培育巨兽状态
        self:setCtrlVisible("ChooseAttriPanel", false, "RightPanel")
        self:setCtrlVisible("FeedPanel", true, "RightPanel")
        self:setCtrlVisible("InfoLabel", false, "DownPanel")
        self:setCtrlVisible("InfoLabelPanel", true, "DownPanel")
        self:setCtrlVisible("SubTitleLabel1", false, "SubTitlePanel")
        self:setCtrlVisible("SubTitleLabel2", true, "SubTitlePanel")
    end
end

-- 本阶段培育倒计时
function PartyFeedMonsterDlg:setStageDownTime(time)
    self:setLabelText("TimeLabel2", string.format(CHS[4200423], time), "TimePanel")
end

-- 选择培育倒计时
function PartyFeedMonsterDlg:setChooseDownTime(time)
    self:setLabelText("TitleLabel2", time, "ChooseAttriPanel")
end

function PartyFeedMonsterDlg:getChooseAttriName(type)
    if type == "life" then
        return CHS[3000103]
    elseif type == "phy_power" then
        return CHS[3004401]
    elseif type == "mag_power" then
        return CHS[3004402]
    elseif type == "speed" then
        return CHS[3004403]
    elseif type == "tao" then
        return CHS[3000049]
    end
end

function PartyFeedMonsterDlg:getPetIcon(growth)
    for i = #PET_INFO, 1, -1 do
        if PET_INFO[i].growth <= growth or i == 1 then
            return PET_INFO[i].icon, PET_INFO[i].numIcon
        end
    end
end

function PartyFeedMonsterDlg:setCommonView(data)
    -- 各属性培育次数
    for i = 1, #data.breeds do
        local num = data.breeds[i]
        local panel = self:getControl("AttriPanel" .. i, nil, "InfoPanel")
        self:setLabelText("AttriLabel2", num .. CHS[5400201], panel)
    end
    
    -- 巨兽形象
    local icon, numIcon = self:getPetIcon(data.grow_value or 0)
    self:setPortrait("IconPanel", icon, 0, self.root, nil, nil, nil, cc.p(0, -36))
    
    self:setImage("LevelImage1", numIcon, "InfoPanel")
    
    -- 巨兽成长度
    self:setLabelText("ValueLabel1", data.grow_value .. "(" .. data.grow_percent .. "%)", "ProgressPanel")
    local bar = self:getControl("activityProgressBar")
    if data.grow_percent > 100 then
        bar:setPercent(100)
    else
        bar:setPercent(data.grow_percent)
    end
    
    -- 贡献度
    self:setLabelText("TimeLabel2", (data.contribution or 0) .. CHS[3000017], "ConPanel")
    
    self:setLabelText("TitleLabel", CHS[5400236] .. gf:changeNumber(data.stage))
end

-- 未选择属性时的显示
function PartyFeedMonsterDlg:setChooseAttriView(data)
    self:stopSchedule(self.sechdule)
    local curTime = gf:getServerTime()
    local chooseTime = math.max(data.choose_end_time - curTime, 0)
    local stageTime = math.max(data.stage_end_time - curTime, 0)
    local function downTime()
        if chooseTime >= 0 then
            self:setChooseDownTime(chooseTime)
            chooseTime = chooseTime - 1
        end
        
        if stageTime >= 0 then
            self:setStageDownTime(stageTime)
            stageTime = stageTime - 1
        end
        
        if chooseTime < 0 and stageTime < 0 then
            self:stopSchedule(self.sechdule)
        end
    end
    
    downTime()
    self.sechdule = self:startSchedule(downTime, 1)
    
    for i = 1, #data.chooseAttris do
        local button = self:getControl("ChoiceButton" .. i, nil, "ChooseAttriPanel")
        button.attrib = data.chooseAttris[i]
        self:setLabelText("Label", CHS[5400231] .. self:getChooseAttriName(data.chooseAttris[i]), button)
    end
    
    self:setCommonView(data)
    self:setViewType(1)
end

-- 培育巨兽的显示
function PartyFeedMonsterDlg:setBreedView(data)
    self:stopSchedule(self.sechdule)
    local curTime = gf:getServerTime()
    local stageTime = math.max(data.stage_end_time - curTime, 0)
    local function downTime()
        if stageTime >= 0 then
            self:setStageDownTime(stageTime)
            stageTime = stageTime - 1
        elseif stageTime < 0 then
            gf:CmdToServer("CMD_REQUEST_PARTY_PYJS_INFO", {})
            self:stopSchedule(self.sechdule)
        end
    end
    
    if stageTime ~= 0 then
        downTime()
    else
        self:setStageDownTime(0)
    end
    
    self.sechdule = self:startSchedule(downTime, 1)
    
    self.curHasTask = nil
    
    -- 任务
    for i = 1, 4 do
        local panel = self:getControl("TaskPanel" .. i, nil, "FeedPanel")
        if data.tasks[i] then
            panel:setVisible(true)
            self:setOneTaskPanel(data.tasks[i], panel)
        else
            panel:setVisible(false)
        end
    end
    
    -- 提示
    self:setLabelText("InfoLabe2", SATGE_INFO[data.stage].growth, "InfoLabelPanel")
    self:setLabelText("InfoLabe3", string.format(CHS[5400239], tostring(self.minMulti)), "InfoLabelPanel")
    
    self:setCommonView(data)
    self:setViewType(2)
end

function PartyFeedMonsterDlg:setOneTaskPanel(data, cell)
    -- 任务名
    self:setLabelText("NameLabel", string.match(data.name, CHS[5400246] .. "(.+)"), cell)
    
    -- 图标
    self:setImage("GoodsImage", TASK_INFO[data.name].icon or "", cell)
    
    -- 次数
    self:setLabelText("NumLabel1", data.com_count .. "/" .. data.total_count, cell)
    if data.com_count >= data.total_count then
        self:setCtrlVisible("NumLabel2", true, cell)
        self:setCtrlVisible("NumLabel3", false, cell)
        
        local multi = math.floor((data.com_count / data.total_count) * 10) / 10
        self:setLabelText("NumLabel2", string.format(CHS[5400238], tostring(multi)), cell)
        if self.minMulti then
            self.minMulti = math.min(self.minMulti, multi)
        else
            self.minMulti = multi
        end
    else
        self:setCtrlVisible("NumLabel2", false, cell)
        self:setCtrlVisible("NumLabel3", true, cell)
        self:setLabelText("NumLabel2", "", cell)
        self.minMulti = 1
    end
    
    local buttonPanel = self:getControl("ButtonPanel", nil, cell)
    buttonPanel.name = data.name
    
    -- 状态
    if data.status == 0 then
        -- 未领取
        self:setCtrlVisible("GetButton", true, cell)
        self:setCtrlVisible("GoButton", false, cell)
        self:setCtrlVisible("DoneButton", false, cell)
    elseif data.status == 1 then
        -- 已领取
        self:setCtrlVisible("GetButton", false, cell)
        self:setCtrlVisible("GoButton", true, cell)
        self:setCtrlVisible("DoneButton", false, cell)
        self.curHasTask = data.name
    elseif data.status == 2 then
        -- 已完成
        self:setCtrlVisible("GetButton", false, cell)
        self:setCtrlVisible("GoButton", false, cell)
        self:setCtrlVisible("DoneButton", true, cell)
        self.curHasTask = data.name
    end
end

function PartyFeedMonsterDlg:onChoiceButton(sender, eventType)
    if not sender.attrib then
        return
    end
    
    -- 若当前角色不是帮主或副帮主，则弹出如下不可选提示
    if not PartyMgr:canApplyAndPro() then
        gf:ShowSmallTips(CHS[5400247])
        return
    end


    gf:confirm(string.format(CHS[5400248], self:getChooseAttriName(sender.attrib)), function()
        PartyMgr:requestChoosePYJSAttrib(sender.attrib)
    end)
end

function PartyFeedMonsterDlg:onGetButton(sender, eventType)
    local parent = sender:getParent()
    if not parent.name then
        return
    end
    
    if self.curHasTask then
        gf:confirm(string.format(CHS[5400250], self.curHasTask, parent.name), function() 
            PartyMgr:requestFetchPYJSTask(parent.name)
        end)
    else
        PartyMgr:requestFetchPYJSTask(parent.name)
    end
end

function PartyFeedMonsterDlg:onGoButton(sender, eventType)
    local parent = sender:getParent()
    if parent.name then
        local task = TaskMgr:getTaskByShowName(parent.name)
        if task then
            gf:doActionByColorText(task.task_prompt, task)
            self:close()
        end
    end
end

function PartyFeedMonsterDlg:onDoneButton(sender, eventType)
    local parent = sender:getParent()
    if not parent.name then
        return
    end
    
    PartyMgr:requestFinishPYJSTask(parent.name)
end

function PartyFeedMonsterDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PartyFeedMonsterRuleDlg")
end

function PartyFeedMonsterDlg:MSG_PARTY_PYJS_ATTRIBS(data)
    if not data then
        return
    end
    
    self.minMulti = nil
    
    self:setChooseAttriView(data)
end

function PartyFeedMonsterDlg:MSG_PARTY_PYJS_STAGE_DATA(data)
    if not data then
        return
    end
    
    self.minMulti = nil
    
    self:setBreedView(data)
end

function PartyFeedMonsterDlg:cleanup()
    DlgMgr:closeDlg("PartyFeedMonsterRuleDlg")
end

return PartyFeedMonsterDlg
