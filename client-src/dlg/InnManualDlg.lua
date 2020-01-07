-- InnManualDlg.lua
-- Created by lixh June/4/2018
-- 客栈手册界面

local InnManualDlg = Singleton("InnManualDlg", Dialog)

-- 客栈手册任务状态
local MANUAL_TASK_STATUS = InnMgr:getManualTaskStatus()

-- 客栈乞丐类型
local INN_BEGGAR_TYPE = InnMgr:getInnBeggarType()

-- 任务配置：名称，icon，描述
local TASK_CFG = {
    {name = CHS[7120114] ,iconPath = ResMgr.ui.inn_manual_task1, promote = CHS[7120122]}, --初次迎客
    {name = CHS[7120115] ,iconPath = ResMgr.ui.inn_manual_task2, promote = CHS[7120123]}, --初次招待
    {name = CHS[7120116] ,iconPath = ResMgr.ui.inn_manual_task3, promote = CHS[7120124]}, --扩展候客区
    {name = CHS[7120117] ,iconPath = ResMgr.ui.inn_manual_task4, promote = CHS[7120125]}, --宽阔的候客区
    {name = CHS[7120118] ,iconPath = ResMgr.ui.inn_manual_task5, promote = CHS[7120126]}, --购买桌椅
    {name = CHS[7120119] ,iconPath = ResMgr.ui.inn_manual_task6, promote = CHS[7120127]}, --扩展房间
    {name = CHS[7120120] ,iconPath = ResMgr.ui.inn_manual_task7, promote = CHS[7120128]}, --门庭若市
    {name = CHS[7120121] ,iconPath = ResMgr.ui.inn_manual_task8, promote = CHS[7120129]}, --升级桌椅
}

function InnManualDlg:init()
    self:bindListViewListener("TaskListView", self.onSelectTaskListView)

    self.taskCell = self:retainCtrl("ListPanel")
    self:refreshBasicInfo()
    self:refreshGuestSpeed()
    self:refreshManualInfo()

    self:hookMsg("MSG_INN_BASE_DATA")
    self:hookMsg("MSG_INN_WAITING_DATA")
    self:hookMsg("MSG_INN_TASK_DATA")

    InnMgr:hideOrShowInnMainDlg(false)
end

-- 刷新任务列表
function InnManualDlg:refreshManualInfo()
    local data = InnMgr:getManualData()
    if not data then return end

    -- 数据按 领取 > 未完成 > 已完成 排列，状态相同根据下标排列
    table.sort(data.list, function(l, r)
        if l.state < r.state then return true end
        if l.state > r.state then return false end
        if l.process == l.maxProcess and r.process ~= r.maxProcess then return true end
        if l.process ~= l.maxProcess and r.process == r.maxProcess then return false end
        if l.id < r.id then return true end
        if l.id > r.id then return false end
    end)

    local listView = self:resetListView("TaskListView", 3)
    for i = 1, data.count do
        local info = data.list[i]
        local item = self:setSingleItem(self.taskCell:clone(), info)
        listView:pushBackCustomItem(item)
    end
end

-- 设置单个任务信息
function InnManualDlg:setSingleItem(item, info)
    local cfg = TASK_CFG[info.id]
    item.id = info.id

    -- 图标
    self:setImage("HeadImage", cfg.iconPath, item)

    -- 名称
    self:setLabelText("TaskNameLabel", cfg.name, item)

    -- 完成次数
    self:setLabelText("CountLabel", "(" .. info.process .. "/" .. info.maxProcess .. ")", item)

    -- 描述
    self:setLabelText("DescribeLabel", cfg.promote, item)

    -- 奖励
    self:setLabelText("MoneyNumLabel", info.coin, item)

    -- 按钮状态
    local function onGetButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local id = sender.id
            gf:CmdToServer("CMD_INN_TASK_FETCH_BONUS", {id = id})
        end
    end

    self:setCtrlVisible("GetButton", false, item)
    self:setCtrlVisible("FinishImage", false, item)
    self:setCtrlVisible("UnfinishedImage", false, item)
    if info.state == MANUAL_TASK_STATUS.HAVE_GOT then
        -- 已完成
        self:setCtrlVisible("FinishImage", true, item)
    else
        if info.process < info.maxProcess then
            -- 未完成
            self:setCtrlVisible("UnfinishedImage", true, item)
        else
            -- 可领取
            self:setCtrlVisible("GetButton", true, item)
            local btn = self:getControl("GetButton", Const.UIButton, item)
            btn.id = info.id
            btn:addTouchEventListener(onGetButton)
        end
    end

    return item
end

-- 刷新基本信息
function InnManualDlg:refreshBasicInfo()
    local baseData = InnMgr:getBaseData()
    if not baseData then return end

    self:refreshCoinNum(baseData.tongCoin)
    self:refreshDeluxe(baseData.deluxe)
    self:refreshUnitTongCoin(baseData.unitTongCoin)
    self:refreshLevelAndExp(baseData.level, baseData.exp, baseData.expToNext)
end

-- 刷新喜来通宝数量
function InnManualDlg:refreshCoinNum(tongCoin)
    local str = gf:getArtFontMoneyDesc(tongCoin or 0)
    local root = self:getControl("MoneyPanel", nil, "ResourceInfoPanel")
    self:setLabelText("NumLabel", str, root)
end

-- 刷新客栈豪华度
function InnManualDlg:refreshDeluxe(deluxe)
    local str = gf:getArtFontMoneyDesc(deluxe or 0)
    self:setLabelText("NumLabel", str, "DeluxePanel")
end

-- 刷新单个客人消费通宝数量
function InnManualDlg:refreshUnitTongCoin(tCoin)
    local str = gf:getArtFontMoneyDesc(tCoin or 0)
    self:setLabelText("NumLabel", string.format(CHS[7190195], str), "UnitIncomePanel")
end

-- 刷新客栈等级与经验
function InnManualDlg:refreshLevelAndExp(level, exp, expToNext)
    local root = self:getControl("LevelPanel", nil, "ResourceInfoPanel")

    if expToNext == 0 then
        -- 满级
        self:setCtrlVisible("MaxNumLabel", true, root)
        self:setCtrlVisible("NumLabel", false, root)
        self:setCtrlVisible("ProgressPanel", false, root)
        self:setLabelText("MaxNumLabel", string.format(CHS[7190184], level), root)
    else
        self:setCtrlVisible("MaxNumLabel", false, root)
        self:setCtrlVisible("NumLabel", true, root)
        self:setCtrlVisible("ProgressPanel", true, root)
        self:setLabelText("NumLabel", string.format(CHS[7190184], level), root)
        self:setProgressBar("ProgressBar", exp, expToNext, root)
    end
end

-- 刷新候客速度信息
function InnManualDlg:refreshGuestSpeed()
    local root = self:getControl("UnitTimePanel", nil, "ResourceInfoPanel")
    local waitData = InnMgr:getWaitData()
    if not waitData then return end

    local color = COLOR3.WHITE
    local beggerEventType = InnMgr:getInnBeggarEventType()
    if beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_BE then
        -- 乞丐报恩
        color = COLOR3.GREEN
    elseif beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_NS then
        -- 乞丐闹事
        color = COLOR3.RED
    end

    local minute = math.floor(waitData.waitTime / 60)
    local second = math.floor(waitData.waitTime % 60)

    self:setLabelText("NumLabel", string.format(CHS[7190188], minute, second), root, color)
end

function InnManualDlg:onSelectTaskListView(sender, eventType)
end

function InnManualDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    InnMgr:hideOrShowInnMainDlg(true)
end

-- 基础数据刷新了
function InnManualDlg:MSG_INN_BASE_DATA()
    self:refreshBasicInfo()
end

-- 候客区数据刷新了
function InnManualDlg:MSG_INN_WAITING_DATA()
    self:refreshGuestSpeed()
end

-- 任务数据刷新了
function InnManualDlg:MSG_INN_TASK_DATA()
    self:refreshManualInfo()
end

return InnManualDlg
