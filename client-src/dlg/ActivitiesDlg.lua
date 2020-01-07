-- ActivitiesDlg.lua
-- Created by zhengjh Mar/16/2015
-- 活动界面

local ActivitiesDlg = Singleton("ActivitiesDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local ActivityGotoCallFunc = require('mgr.activity/ActivityGotoCallFunc')

local LINE_SAPCE = 0
local SCROLLVIEW_CHILD_TAG = 999
local COLUNM = 2

-- 用于持久化的dailyCell节点（二维数组，第一维是活动的名称，第二维是tag）
ActivitiesDlg.dailyCells = {}

local CHECKBOX_TO_REWARD_TYPE = {
    ["ExpCheckBox"] = ACTIVITY_REWARD_TYPE.EXP,
    ["DaowuCheckBox"] = ACTIVITY_REWARD_TYPE.TAO_AND_MARTIAL,
    ["ItemCheckBox"] = ACTIVITY_REWARD_TYPE.ITEM,
    ["EquipmentCheckBox"] = ACTIVITY_REWARD_TYPE.EQUIP,
}

function ActivitiesDlg:init()
    self:bindListener("StatisticsButton", self.OnStatisticsButton)
    self:bindListener("PushButton", self.onPushButton)
    self:bindListener("WeekCalendarButton", self.onWeekCalendarButton)

    -- 设置互斥按钮
    self.rewardTypeGroup = RadioGroup.new()
    self.rewardTypeGroup:setItems(self, { "WholeCheckBox", "ExpCheckBox", "DaowuCheckBox", "ItemCheckBox",
        "EquipmentCheckBox" }, self.onRewardTypeCheckBox)

    self.dailyCell = self:getControl("DailyListViewPanel_1", Const.UIPanel)
    self.dailyCell:retain()
  --[[[  self.limitCell = self:getControl("LimitedListViewPanel1", Const.UIPanel)
    self.limitCell:retain()
    self.comingCell = self:getControl("ComingListViewPanel1", Const.UIPanel)
    self.comingCell:retain()]]
    self.activityTable = {}
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"DailyCheckBox", "LimitedCheckBox", "FestivalCheckBox", "WelfareCheckBox", "ComingCheckBox", "OtherCheckBox"}, self.OnSiwchTab)

    -- 记录一下原始状态各选项卡所处位置
    self.positionYList = {}
    local tabPanel = self:getControl("TabPanel")
    for i = 1, 6 do
        self.positionYList[i] = tabPanel:getChildByTag(i):getPositionY()
    end

    self:hookMsg("MSG_LIVENESS_INFO")
    self:hookMsg("MSG_LIVENESS_REWARDS")
    self:hookMsg("MSG_GENERAL_NOTIFY")

    ActivityMgr:CMD_ACTIVITY_LIST() -- 获取活动节日开始时间
    ActivityMgr:getActiviInfo() -- 获取活跃度

    self.radioGroup:selectRadio(1, self.OnSiwchTab)
    self.curBoxName = "DailyCheckBox"
    self:initTab()

    self.rewardTypeGroup:selectRadio(1, self.onRewardTypeCheckBox)

    self:MSG_LIVENESS_INFO()

    self.hasNotReceiveMsg = true  -- 用于标记是否收到了 MSG_LIVENESS_INFO
    self.initDoneWithMsg = false  -- 根据服务器数据初始化完成

    if Me:queryBasicInt("level") >= 100 and TaskMgr.baijiTaskStatus == nil then
        TaskMgr:requestBaijiTask()
    end
end

function ActivitiesDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_SEND_INIT_DATA_DONE == data.notify then
        if self.hasNotReceiveMsg then
            ActivityMgr:CMD_ACTIVITY_LIST() -- 获取活动节日开始时间
            ActivityMgr:getActiviInfo() -- 获取活跃度
        end
    end
end

function ActivitiesDlg:initTab()
    local positionYList = self.positionYList
    local tabPanel = self:getControl("TabPanel")
    local dataList= {}
    dataList[1] = ActivityMgr:getDailyActivity()
    dataList[2] = ActivityMgr:getLimitActivity()
    dataList[3] = ActivityMgr:getFestivalActivity()
    dataList[4] = ActivityMgr:getWelfareActivity()
    dataList[5] = ActivityMgr:getComingActivity()
    dataList[6] = ActivityMgr:getOhterActivityData()

    local showTabList = {}
    for i = 1, 6 do
        if #dataList[i] == 0 then
            tabPanel:getChildByTag(i):setVisible(false)
        else
            table.insert(showTabList, tabPanel:getChildByTag(i))
            tabPanel:getChildByTag(i):setVisible(true)
        end
    end

    for i = 1, #showTabList do
        showTabList[i]:setPositionY(positionYList[i])
    end

end

function ActivitiesDlg:MSG_LIVENESS_INFO(data)
    self.hasNotReceiveMsg = false
    self.activityTable = {}
    self:initTab()
    self:setActivityTabData(self.curBoxName, self.curRewardType)
    self.activityTable[self.curBoxName]:setVisible(true)
    self:initRewardPanel()

    if data then
        -- 更新服务器数据初始化完成标记
        self.initDoneWithMsg = true
    end
end

-- 活跃度领取奖励行为，刷新界面光效与底板信息
function ActivitiesDlg:MSG_LIVENESS_REWARDS()
    local rewardStatusTable = ActivityMgr:getRewardStatus() or {}
    local reward =  ActivityMgr:getActivityReward()

    for i = 1, #reward do
        local rewardPanel = self:getControl(string.format("RewardPanel%d",i), Const.UIPanel)
        local rewardItemPanel = self:getControl("RewardItemPanel", Const.UIPanel, rewardPanel)
        local key = reward[i]["activity"]

        if rewardStatusTable[key] and rewardStatusTable[key]["status"] == 1 then -- 已领取
            self:setCtrlVisible("CoverImage", true, rewardPanel)
            self:removeMagic(rewardItemPanel, Const.ARMATURE_MAGIC_TAG)
        elseif rewardStatusTable[key] and rewardStatusTable[key]["status"] == 2 then -- 可以领取
            self:setCtrlVisible("CoverImage", false, rewardPanel)
            -- lixh2 WDSY-21401 帧光效修改为粒子光效：活跃度物品栏环绕光效
            gf:createArmatureMagic(ResMgr.ArmatureMagic.item_around, rewardItemPanel, Const.ARMATURE_MAGIC_TAG)
        else
            self:setCtrlVisible("CoverImage", false, rewardPanel)
            self:removeMagic(rewardItemPanel, Const.ARMATURE_MAGIC_TAG)
        end
    end
end

function ActivitiesDlg:OnStatisticsButton(sender, eventType)
    if not DlgMgr.statisticsDlgRect then DlgMgr.statisticsDlgRect = self:getBoundingBoxInWorldSpace(sender) end

    if self:isOutLimitTime("requestLast", 2000) then
        self:setLastOperTime("requestLast", gfGetTickCount())
        gf:CmdToServer("CMD_REQUEST_DAILY_STATS", {})
    else
        gf:ShowSmallTips(CHS[7100388])
    end
end

function ActivitiesDlg:onPushButton(sender, eventType)
    DlgMgr:openDlg("SystemPushDlg")
end

function ActivitiesDlg:onWeekCalendarButton(sender, eventType)
    DlgMgr:openDlg("ActivitiesWeekCalendarDlg")
end

function ActivitiesDlg:onRewardTypeCheckBox(sender, eventType)
    local name = sender:getName()
    if name == self.curRewardType then return end

    self.curRewardType = CHECKBOX_TO_REWARD_TYPE[sender:getName()]
    self:setActivityTabData(self.curBoxName, self.curRewardType)
    self.activityTable[self.curBoxName]:setVisible(true)
end

function ActivitiesDlg:OnSiwchTab(sender, eventType)
    local name = sender:getName()
    if name == self.curBoxName then return end

    self.curBoxName = name
    for k,v in pairs(self.activityTable) do
        if v then
            v:setVisible(false)
        end
    end

    self:setActivityTabData(name, self.curRewardType)
        self.activityTable[name]:setVisible(true)
end

function ActivitiesDlg:setActivityTabData(name, rewardType)
    local scrollview = nil
    local dataTable = {}
    local func = nil
    local cell = nil
    if name == "DailyCheckBox" then
        scrollview = self:getControl("DailyScrollView", Const.UIScrollView)
        dataTable = ActivityMgr:getDailyActivity(rewardType)
        func = self.setDailyCellInfo
        self.activityTable[name] = self:getControl("DailyPanel", Const.UIPanel)
    elseif name == "LimitedCheckBox" then
        scrollview = self:getControl("LimitedScrollView", Const.UIScrollView)
        dataTable = ActivityMgr:getLimitActivity(nil, nil, rewardType)
        func = self.setLimitCellInfo
        self.activityTable[name] = self:getControl("LimitedPanel", Const.UIPanel)
    elseif name == "FestivalCheckBox" then
        scrollview = self:getControl("FestivalScrollView", Const.UIScrollView)
        dataTable = ActivityMgr:getFestivalActivity(nil, rewardType)
        func = self.setFestivalCellInfo
        self.activityTable[name] = self:getControl("FestivalPanel", Const.UIPanel)
    elseif name == "WelfareCheckBox" then
        scrollview = self:getControl("WelfareScrollView", Const.UIScrollView)
        dataTable = ActivityMgr:getWelfareActivity(rewardType)
        func = self.setWelfareCellInfo
        self.activityTable[name] = self:getControl("WelfarePanel", Const.UIPanel)
    elseif name == "ComingCheckBox" then
        scrollview = self:getControl("ComingScrollView", Const.UIScrollView)
        dataTable = ActivityMgr:getComingActivity(rewardType)
        func = self.setComingCellInfo
        self.activityTable[name] = self:getControl("ComingPanel", Const.UIPanel)
    elseif name == "OtherCheckBox" then
        scrollview = self:getControl("OtherScrollView", Const.UIScrollView)
        dataTable = ActivityMgr:getOhterActivityData(rewardType)
        func = self.setOtherCellInfo
        self.activityTable[name] = self:getControl("OtherPanel", Const.UIPanel)
    end

    dataTable = self:filterLevel(dataTable)

    self:initScrollview(dataTable, scrollview, func, COLUNM)

end

function ActivitiesDlg:filterLevel(dataTable)

    local ret = {}
    for _, act in pairs(dataTable) do
        if act.showLevel and Me:queryBasicInt("level") < act.showLevel then
        else
            table.insert(ret, act)
        end
    end

    return ret
end

function ActivitiesDlg:removeDailyCellsFromParent(name)
    if not self.dailyCells then self.dailyCells = {} end
    if not self.dailyCells[name] then self.dailyCells[name] = {} end
    for key, value in pairs(self.dailyCells[name]) do
        self.dailyCells[name][key]:removeFromParent()
    end
end

function ActivitiesDlg:getDailyCellByTag(name, tag)
    if not self.dailyCells[name][tag] then
        self.dailyCells[name][tag] = self.dailyCell:clone()
        -- 持久化dailyCell，以免出现卡顿现象
        self.dailyCells[name][tag]:retain()

        return self.dailyCells[name][tag], false
    else
        return self.dailyCells[name][tag], true
    end
end

-- 初值列表数据
function ActivitiesDlg:initScrollview(data, scrollview, func, colunm)
    self:removeDailyCellsFromParent(self.curBoxName)
    scrollview:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local line = math.floor(#data /colunm)
    local left = #data %colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (self.dailyCell:getContentSize().height + LINE_SAPCE) - LINE_SAPCE

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm =colunm
        end

        for j = 1, curColunm do
            local index = j + (i - 1) * colunm
            local tag = data[index].index
            local cell, initDone = self:getDailyCellByTag(self.curBoxName, tag)
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (self.dailyCell:getContentSize().width)
            local y = totalHeight - (i - 1) * (self.dailyCell:getContentSize().height + LINE_SAPCE)
            cell:setPosition(x, y)
            cell:setTag(tag)
            contentLayer:addChild(cell)

            if not initDone or not self.initDoneWithMsg then
                -- cell 未初始化，或当前已收到服务器数据，但服务器数据还未用来刷新
            func(self, cell , data[index])
         end
    end
    end

    contentLayer:setContentSize(scrollview:getContentSize().width, totalHeight)

    if totalHeight < scrollview:getContentSize().height then
        contentLayer:setPositionY(scrollview:getContentSize().height  - totalHeight)
    end


    scrollview:addChild(contentLayer, 1, SCROLLVIEW_CHILD_TAG)
    scrollview:setInnerContainerSize(contentLayer:getContentSize())
end


function ActivitiesDlg:setDailyCellInfo(cell, data)

    self:setCellInfo(cell, data)

    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)            -- 前往按钮
    local statusImage = self:getControl("StatusImage", Const.UIImage, cell)      -- 已完成
    gotoBtn:setVisible(false)
    statusImage:setVisible(false)

    local dataTemp = data
    if dataTemp.name == CHS[3002189]  then
        self:setLabelText("Label_1", CHS[3002190], gotoBtn)
        self:setLabelText("Label_2", CHS[3002190], gotoBtn)
        gotoBtn:setVisible(true)
    elseif dataTemp.times == 0 then
        gotoBtn:setVisible(true)
    elseif ActivityMgr:isFinishActivity(dataTemp) then
        statusImage:setVisible(true)
    else
        gotoBtn:setVisible(true)
    end
end

function ActivitiesDlg:setOtherCellInfo(cell, data)
    self:setCellInfo(cell, data)
    local activiteTimePanel = self:getControl("ActiveTimePanel", Const.UIPanel, cell)
    local timeLabel = self:getControl("TimeLabel", Const.UILabel, activiteTimePanel, cell) -- 活动时间显示
    local leftLabel = self:getControl("LeftTimeValueLabel", Const.UILabel, cell)     -- 活动倒计时
    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)            -- 前往按钮
    local statusImage = self:getControl("StatusImage", Const.UIImage, cell)      -- 已完成
    activiteTimePanel:setVisible(false)
    timeLabel:setVisible(false)
    leftLabel:setVisible(false)
    gotoBtn:setVisible(false)
    statusImage:setVisible(false)

    if data["name"] == CHS[3002191] then
        gotoBtn:setVisible(true)
        self:setLabelText("Label_1", CHS[3002190], gotoBtn)
        self:setLabelText("Label_2", CHS[3002190], gotoBtn)
        timeLabel:setString(ActivityMgr:getDayText(data)..ActivityMgr:getTimeText(data))
        timeLabel:setVisible(true)

    elseif data.times == 0 then
        gotoBtn:setVisible(true)
    elseif ActivityMgr:isFinishActivity(data) then
            statusImage:setVisible(true)
    elseif data["name"] == CHS[6000108] or data["name"] == CHS[6000109] or data["name"] == CHS[6400005] or data["name"] == CHS[4010374] then
        activiteTimePanel:setVisible(true)
        timeLabel:setString(ActivityMgr:getDayText(data)..ActivityMgr:getTimeText(data))
        timeLabel:setVisible(true)
        else
            gotoBtn:setVisible(true)
        end
end

function ActivitiesDlg:setLimitCellInfo(cell, data)
    local tempData
    if data["actitiveDate"] == "10" then    -- 活动进行某个时间
        self:setDailyCellInfo(cell, data)
        return
    end

    if string.match(data.name, CHS[7001058]) and data["actitiveDate"] ~= "" then
        -- 周活动，某周随机出对应活动
        if ActivityMgr:isWeekActivityFinish(data) then
            -- 如果这周的该周活动结束，下一周周活动尚未选出，则活动名称显示为“【周】随机周活动”
            -- 由于会修改到data.name，而且此修改会影响到原始data数据，故copy一份数据用于setCellInfo
            tempData = gf:deepCopy(data)
            tempData.name = CHS[7001059]
        end
    end

    self:setCellInfo(cell, tempData or data)

    local activiteTimePanel = self:getControl("ActiveTimePanel", Const.UIPanel, cell)
    local timeLabel = self:getControl("TimeLabel", Const.UILabel, activiteTimePanel, cell) -- 活动时间显示
    local leftTimeBKImage = self:getControl("LeftTimeBKImage", Const.UIImage, cell)
    local leftLabel = self:getControl("LeftTimeValueLabel", Const.UILabel, cell)     -- 活动倒计时
    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)            -- 前往按钮
    local statusImage = self:getControl("StatusImage", Const.UIImage, cell)      -- 已完成
    activiteTimePanel:setVisible(false)
    timeLabel:setVisible(false)
    leftTimeBKImage:setVisible(false)
    leftLabel:setVisible(false)
    gotoBtn:setVisible(false)
    statusImage:setVisible(false)

    local curActivetyTable = ActivityMgr:isCurActivity(data)
    local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

    if ActivityMgr:isFinishActivity(data) then
        -- 已完成
        statusImage:setVisible(true)
    elseif curActivetyTable[1] == false then
        activiteTimePanel:setVisible(true)
        local timeStr = ActivityMgr:getDayText(data)..ActivityMgr:getTimeText(data)

        if data["name"] == CHS[3002192] then
            timeStr = CHS[3002193]
        end

        timeLabel:setString(timeStr)
        timeLabel:setVisible(true)
    else
        -- 处于活动期间
        local time = ActivityMgr:getLeftMin(curActivity)
        schedule(cell ,function()
            if time == 0 then return end
            time = time - 1
            leftLabel:setString(string.format(CHS[6000116], time))
        end, 60)

        gotoBtn:setVisible(true)
        leftLabel:setVisible(true)
        leftTimeBKImage:setVisible(true)
        leftLabel:setString(string.format(CHS[6000116], time))

        if data.notShowLeftTime then
            leftLabel:setVisible(false)
            leftTimeBKImage:setVisible(false)
        end
    end
end

function ActivitiesDlg:setComingCellInfo(cell, data)
	self:setCellInfo(cell, data)

    local activiteTimePanel = self:getControl("ActiveTimePanel", Const.UIPanel, cell)
    local timeLabel = self:getControl("TimeLabel", Const.UILabel, activiteTimePanel, cell) -- 活动时间显示
    local leftTimeBKImage = self:getControl("LeftTimeBKImage", Const.UIImage, cell)
    leftTimeBKImage:setVisible(false)
    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)            -- 前往按钮
    gotoBtn:setVisible(false)

	--local lelveLabel = self:getControl("StatusLabel", Const.UILabel, cell)
    self:setCtrlVisible("ClockImage", false, activiteTimePanel)
    timeLabel:setString(string.format(CHS[6000117],data["level"]))
    timeLabel:setVisible(true)
    activiteTimePanel:setVisible(true)
end

function ActivitiesDlg:setFestivalCellInfo(cell, data)
    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)            -- 前往按钮
    local activiteTimePanel = self:getControl("ActiveTimePanel", Const.UIPanel, cell)
    gotoBtn:setVisible(false)
    activiteTimePanel:setVisible(false)

    if ActivityMgr:isFestivalStart(data["activityTime"][1][1]) then -- 处于活动时间
        if data["name"] == CHS[6200075] then -- 全服红包(特殊处理，进行是某个时间段)
            if data["goingTime"] and ActivityMgr:getActivityIsCurTime(data["goingTime"], ActivityMgr:getActivityNewTime(data["name"])) then
                self:setDailyCellInfo(cell, data)
            else
                self:setCellInfo(cell, data)
                self:setLabelText("Label_1", CHS[3002190], gotoBtn)
                self:setLabelText("Label_2", CHS[3002190], gotoBtn)
                gotoBtn:setVisible(true)
            end
        elseif data["name"] == CHS[7002140] then
            self:setCellInfo(cell, data)
            self:setLabelText("Label_1", CHS[3002190], gotoBtn)
            self:setLabelText("Label_2", CHS[3002190], gotoBtn)
            gotoBtn:setVisible(true)
        elseif data["name"] == CHS[7002097] then
            -- 善财仙童（特殊处理）
            local function func()
                if data["goingTime"] and ActivityMgr:getActivityIsCurTime(data["goingTime"], ActivityMgr:getActivityNewTime(data["name"])) then
                    self:setDailyCellInfo(cell, data)
                else
                    self:setCellInfo(cell, data)
                    local timeLabel = self:getControl("TimeLabel", Const.UILabel, activiteTimePanel, cell) -- 活动时间显示
                    activiteTimePanel:setVisible(true)
                    local nextTimeStr
                    local time = gf:getServerTime()
                    local timeList = gf:getServerDate("*t", time)
                    if timeList.hour == 23 then
                        -- 特殊处理一下23：05-23:59点的下一开启时间（由于下一开启时间为00:00）
                        nextTimeStr = "00:00"
                    else
                        nextTimeStr = ActivityMgr:getNearlyTime({activityTime = data["goingTime"]})
                    end

                    timeLabel:setString(nextTimeStr .. CHS[4000269])
                end
            end

            func()

            cell:stopAllActions()
            schedule(cell, function()
                func()
            end, 1)
        else
            self:setDailyCellInfo(cell, data)
        end
    else
        self:setCellInfo(cell, data)
        local timeLabel = self:getControl("TimeLabel", Const.UILabel, activiteTimePanel, cell) -- 活动时间显示
        activiteTimePanel:setVisible(true)
        self:setCtrlVisible("ClockImage", false, activiteTimePanel)
        timeLabel:setString(CHS[3004424])
    end
end

function ActivitiesDlg:setWelfareCellInfo(cell, data)
    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)            -- 前往按钮
    local activiteTimePanel = self:getControl("ActiveTimePanel", Const.UIPanel, cell)
    gotoBtn:setVisible(false)
    activiteTimePanel:setVisible(false)

    if ActivityMgr:isFestivalStart(data["activityTime"][1][1]) then -- 处于活动时间
        if data["name"] == CHS[6200075] then -- 全服红包(特殊处理，进行是某个时间段)
            if data["goingTime"] and ActivityMgr:getActivityIsCurTime(data["goingTime"], ActivityMgr:getActivityNewTime(data["name"])) then
                self:setDailyCellInfo(cell, data)
            else
                self:setCellInfo(cell, data)
                self:setLabelText("Label_1", CHS[3002190], gotoBtn)
                self:setLabelText("Label_2", CHS[3002190], gotoBtn)
                gotoBtn:setVisible(true)
            end
        else
            self:setDailyCellInfo(cell, data)
        end
    else
        self:setCellInfo(cell, data)
        local timeLabel = self:getControl("TimeLabel", Const.UILabel, activiteTimePanel, cell) -- 活动时间显示
        activiteTimePanel:setVisible(true)
        self:setCtrlVisible("ClockImage", false, activiteTimePanel)
        timeLabel:setString(CHS[3004424])
    end
end

local function touchCell(sender, eventType)
    local data = sender.data
    if not data then
        return
    end

    if ccui.TouchEventType.ended == eventType then
        if data and data.name and data.name == CHS[7001059] then
            gf:ShowSmallTips(CHS[7001060])
            return
        end

        local dlg = DlgMgr:openDlg("ActivitiesInfoFFDlg")
        dlg:setData(data, false)
    end
end

function ActivitiesDlg:setCellInfo(cell, data)
    cell.data = data

    -- 活动标题
    local title = self:getControl("TitleLabel", Const.UILabel, cell)
    local name = data["name"]
    if data["showName"] then
        name = data["showName"]
    end

    if string.match(name, "Month") then
        local activityTime = ActivityMgr:getActivityStartTimeByMainType(data.mainType)
        local activityStartTime = activityTime.startTime
        local m = tonumber(gf:getServerDate("%m", activityStartTime - Const.FIVE_HOURS))
        local newActName = string.gsub(name, "Month", gf:changeNumber(m))
        title:setString(newActName)
    else
        title:setString(name)
    end

    -- 活动图片
    local imagePanel = self:getControl("ImagePanel", Const.UIPanel, cell)
    local image = self:getControl("Image", Const.UIImage, imagePanel)

    -- 双倍标记
    self:setCtrlVisible("DoubleImage", ActivityMgr:isDoubleActive(data), cell)

    local path = ResMgr.ui.small_cash  -- 没有资源用金币替代
    if data["name"] == CHS[6000255]     -- 天降宝盒
        or data["name"] == CHS[7000125]     -- 欢乐宝箱
        or data["name"] == CHS[2000192]     -- 幸运折扣券
        or data["name"] == CHS[5420071]     -- 【情人节】婚礼折扣
        or data["name"] == CHS[7002160]     -- 女娲宝箱
        or data["name"] == CHS[5400063]     -- 周年庆-五行送福
    then
        -- 宠物召唤令图标
        path = ResMgr:getItemIconPath(data["icon"])
        image:loadTexture(path, ccui.TextureResType.localType)
        gf:setItemImageSize(image)
    else
        if data.itemName then
            image:loadTexture(ResMgr:getItemIconPath(InventoryMgr:getIconByName(data.itemName)))
        else
            image:loadTexture(data["icon"], ccui.TextureResType.plistType)
    end
    end

    cell:addTouchEventListener(touchCell)

    local numberLabel = self:getControl("ProgressNumLabel", Const.UILabel, cell)

    -- 次数
    if data["times"] == -1 then
        numberLabel:setString(CHS[6000115])
    elseif data["times"] == 0 then
        -- 可进行次数为0时，隐藏
        numberLabel:setVisible(false)
        self:setCtrlVisible("ActivityLabel", false, cell)
        self:setCtrlVisible("ProgressLabel", false, cell)
        self:setCtrlVisible("ActivityTextLabel", false, cell)
    else
        local thisTimes = ActivityMgr:getActivityCurTimes(data["name"])
        if thisTimes > data["times"] then
            thisTimes = data["times"]
        end
        if data["name"] == CHS[3002195] then
            numberLabel:setString(string.format("%d/%d", thisTimes, data["times"] + ActivityMgr.partyTaskAdd))
        else
            numberLabel:setString(string.format("%d/%d", thisTimes, data["times"]))
        end
    end

    -- 活跃度
    local activityCurTimes = ActivityMgr:getActivityValue(data["name"])

    if activityCurTimes > data["activeLimit"] then
        activityCurTimes = data["activeLimit"]
    end

    if data["activeLimit"] <= 0 then
        self:setLabelText("ActivityLabel", CHS[5000059], cell)
    else
        self:setLabelText("ActivityLabel", string.format("%d/%d", activityCurTimes, data["activeLimit"]), cell)
    end

    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)
  --[[local curActivetyTable = ActivityMgr:isCurActivity(data)
    local curActivity = data["activityTime"][curActivetyTable[2] -- 当前时间段的活动
    local function gotoPalce()
        if data["name"] == CHS[6000106]  then       -- 师门任务
            local  npcName = gf:getPolarNPC(tonumber(Me:queryBasic("polar")))
            AutoWalkMgr:beginAutoWalk(gf:findDest(string.format("#P%s#P",npcName)))
        elseif data["name"] == CHS[6000107]  then   -- 帮派日常挑战
            AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
        else
            if curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                DlgMgr:openDlg(curActivity[3])
            end
        end
        self:onCloseButton()
    end]]

   --[[ local function gotoFunc(sender, type)
        if ccui.TouchEventType.ended == type then
            -- GM处于监听状态下
            if GMMgr:isStaticMode() then
                gf:ShowSmallTips(CHS[3002196])
                return
            end

            -- 处于禁闭状态
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
            elseif GameMgr.inCombat then
                gf:ShowSmallTips(CHS[3002197])
                return
            end
            self:onGotoBtn(data)
            if self:getLabelText("Label_1", gotoBtn) == CHS[3002198] then
                self:onCloseButton()
            end
        end
    end

    gotoBtn:addTouchEventListener(gotoFunc)]]

    self:bindTouchEndEventListener(gotoBtn, self.gotoFunc, data)

    if data["name"] == CHS[6000106] then
        local rect = self:getBoundingBoxInWorldSpace(gotoBtn)
        self.rect = rect
    end

end

function ActivitiesDlg:gotoFunc(sender, type, data)
    if GMMgr:isStaticMode() then
        gf:ShowSmallTips(CHS[3002196])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    elseif GameMgr.inCombat
          and self:getLabelText("Label_1", sender) == CHS[3002198]
          and not data["canGotoInCombat"] then
        gf:ShowSmallTips(CHS[3002197])
        return
    end

    self:onGotoBtn(data)

    -- 部分活动的前往按钮响应不需要关闭活动界面
    if self:getLabelText("Label_1", sender) == CHS[3002198]
          and not data["notClsoeDlgWhenGoto"] then
        self:onCloseButton()
    end
end


-- 处理前往按钮功能
function ActivitiesDlg:onGotoBtn(data)

    -- 有些任务，在不同任务状态，要给予不同的提示
    local task = TaskMgr:getTaskByName(data["name"])
    if task then
        DlgMgr:sendMsg("MissionDlg", "specialToDo", task)
    end


    local decStr = ""
	if data["name"] == CHS[6000106] then -- 师门任务
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3002199])
        else
            if TaskMgr:getSMTask() then
                decStr = TaskMgr:getSMTask()
            else
                local npcName = gf:getPolarNPC(tonumber(Me:queryBasic("polar")))
                decStr = string.format(CHS[3002200],npcName)
            end

            local dest = gf:findDest(decStr)

            if dest then
                AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
            else
                -- 解析打开对话框
            local tempStr = string.match(decStr, "#@.+#@")
                if tempStr then
                    -- 解析#@道具名|FastUseItemDlg=道具名
                tempStr = string.match(decStr, "|.+=.+")
                end
                if tempStr then
                    tempStr = string.sub(tempStr,2)
                    tempStr = string.sub(tempStr, 1, -3)
                    DlgMgr:openDlgWithParam(tempStr)
                end
            end
        end
    elseif data["name"] == CHS[3000728]
            or data["name"] == CHS[6400025]
            or data["name"] == CHS[6400001]
            or data["name"] == CHS[5450332]
            or data["name"] == CHS[5450336] then -- 试道  3000728
        if MapMgr:isInShiDao() then
            gf:ShowSmallTips(CHS[3002201])
        else
            decStr = CHS[3002202]
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        end
    elseif string.match(data["name"], CHS[7002107]) then -- 化妆舞会
        if MapMgr:getCurrentMapId() == 38010 then
            gf:ShowSmallTips(CHS[7002111])
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7002112]))
        end
    elseif string.match(data["name"], CHS[7002122]) then -- 百兽之王
        if MapMgr:getCurrentMapId() == 38011 then
            gf:ShowSmallTips(CHS[7002127])
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7002124]))
        end
    elseif string.match(data["name"], CHS[2200031]) then -- 矿石大战
        if MapMgr:isInOreWars() then
            gf:ShowSmallTips(CHS[7002233])
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7002234]))
        end
    elseif data["name"] == CHS[3002203] then    -- 通天塔
        if TaskMgr:getTongtianTowerTask() then
            decStr = TaskMgr:getTongtianTowerTask()
            TaskMgr:setIsAutoChallengeTongtian(true)
        else
            decStr = CHS[3002204]
        end

        local beidouNpc = CharMgr:getCharByName(CHS[4200636])
        if MapMgr:isInMapByName(CHS[4010293]) and beidouNpc and not beidouNpc.visible and CharMgr:getCharByName(CHS[4010302]) then
            -- 通天塔神秘房间变戏法该条件下特殊处理
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4200637]))
        else
        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        end
    elseif data["name"] == CHS[3002205] then    -- 助人为乐
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3002206])
        else
            if TaskMgr:getZhuRenWeiLeTask() then
                decStr = TaskMgr:getZhuRenWeiLeTask()
            elseif Me:queryBasicInt("level") >= 70 and Me:isVip() then
                decStr = CHS[2200067]
            else
                decStr = CHS[3002207]
            end
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data["name"] == CHS[3002208] then    -- 副本
        if TaskMgr:getFuBenTask(true) then
            decStr = TaskMgr:getFuBenTask()
        else
            decStr = CHS[3002209]
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data["name"] == CHS[3002210]  then   -- 帮派日常挑战
        if Me:queryBasic("party/name") == "" then
            gf:ShowSmallTips(CHS[3002211])
        else
            if ActivityMgr:isFinishActivity(data) then
                gf:ShowSmallTips(string.format(CHS[3002212], data.times))
            else
                if TaskMgr:getPartyChallengeTask() then
                    decStr = TaskMgr:getPartyChallengeTask()
                elseif Me:queryBasicInt("level") >= 70 and Me:isVip() then
                    decStr = CHS[2200068]
                else
                    decStr = CHS[3002213]
                end
            end
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data["name"] == CHS[3002195] then    -- 帮派任务
        if Me:queryBasic("party/name") == "" then
            gf:ShowSmallTips(CHS[3002211])
        else
            if ActivityMgr:isFinishActivity(data) then
                gf:ShowSmallTips(string.format(CHS[3002214], data.times))
            else
                if TaskMgr:getPartyTask() then
                    decStr = TaskMgr:getPartyTask()
                else
                    decStr = CHS[3002215]
                end
            end
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data["name"] == CHS[3002216] then -- 镖行万里
        local curActivetyTable = ActivityMgr:isCurActivity(data)
        local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

        if  curActivetyTable[1] == false then
            decStr = CHS[5410229]
        else
            if TaskMgr:getBiaoXingWanLiTask() then
                decStr = TaskMgr:getBiaoXingWanLiTask()
            else
                decStr = CHS[3002218]     -- 【押镖】领取押送镖银任务
            end
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data["name"] == CHS[3002219] then -- 除暴任务
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3002220])
        else
            if TaskMgr:getCBTask() then
                decStr = TaskMgr:getCBTask()
            else
                decStr = CHS[3002221]
            end

            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        end
    elseif data["name"] == CHS[4100328] then -- 修行
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3002223])
        else
            if TaskMgr:getXXTask() then
                decStr = TaskMgr:getXXTask()
                AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
            else
                local curActivetyTable = ActivityMgr:isCurActivity(data)
                local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

                if curActivity[2] == "npc" then
                    AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
                elseif curActivity[2] == "dlg" then
                    DlgMgr:openDlg(curActivity[3])
                end
            end
        end
    elseif data["name"] == CHS[4100329] then    -- 【修炼】十绝阵
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3002223])
        else
            if TaskMgr:getSJZTask() then
                decStr = TaskMgr:getSJZTask()
                AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
            else
                local curActivetyTable = ActivityMgr:isCurActivity(data)
                local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

                if curActivity[2] == "npc" then
                    AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
                elseif curActivity[2] == "dlg" then
                    DlgMgr:openDlg(curActivity[3])
                end
            end
        end
    elseif data["name"] == CHS[3002191] then    -- 铲除妖王
        local dlg = DlgMgr:openDlg("ActivitiesSeeDlg")
        dlg:setActiveInfo(data["name"])
    elseif data["name"] == CHS[3002224] then    -- 挑战掌门
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3002225])
        else
            local mPolar = Me:queryBasicInt("polar")
            local dest = string.format(CHS[3002226], gf:getPolarLeader(mPolar))
            AutoWalkMgr:beginAutoWalk(gf:findDest(dest))
        end
    elseif data["name"] == CHS[3002227] then    -- 八仙梦境
        if TaskMgr:getTaskByName(data["name"]) then
            decStr = TaskMgr:getTaskByName(data["name"]).task_prompt
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

            if curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                DlgMgr:openDlg(curActivity[3])
            end
        end
    elseif data["name"] == CHS[3002189] then    -- 地图守护神
        DlgMgr:openDlg("MapGuardianDlg")
    elseif data["name"] == CHS[3002192] then    -- 悬赏任务
        if TaskMgr:getXuanShangTask() then
            -- 有悬赏任务的情况下，寻路由服务器处理
            gf:CmdToServer("CMD_START_XS_AUTO_WALK", {})
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[3002228])) -- 仙界神捕
        end
    elseif data["name"] == CHS[3004425] then    -- 【劳动节】清除杂草
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3004426])
        else
        local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动
            decStr = curActivity[3]
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        end
    elseif data["name"] == CHS[3004427] then    -- 【劳动节】教训懒鬼
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3004428])
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动
            decStr = curActivity[3]
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        end
    elseif data["name"] == CHS[3004429] then    -- 【劳动节】击退鬼王
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[3004430])
        else
            if not TaskMgr:getTaskByName(data["name"]) then
                gf:ShowSmallTips(CHS[3004431])
            else
                local curActivetyTable = ActivityMgr:isCurActivity(data)
                local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动
                decStr = curActivity[3]
            end

            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        end
    elseif data["name"] == CHS[6000216] then -- 天降鸿福
        if data["level"] > tonumber(Me:queryBasic("level")) then
            gf:ShowSmallTips(string.format(CHS[6000259], data["level"]))
            return
        end

        local data = {}
        data.url = "http://wechat.leiting.com/weixin/wd/201604/card/"
        data.title = CHS[6000223]
        data.desc = CHS[6000224]
        data.thumbPath = cc.FileUtils:getInstance():fullPathForFilename("noencrypt/ShareReward.png")
        data.needNotifyServer = true
        local dlg = DlgMgr:openDlg("ShareDlg")
        dlg:setShareType(SHARE_TYPE_CONFIG.SHARE_URL)
        dlg:setCurShareData(data)
    elseif data["name"] == CHS[6000274] then -- 同甘共苦
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(CHS[6000277])
        else
            if TaskMgr:getTaskByName(data["name"]) then
            decStr = TaskMgr:getTaskByName(data["name"]).task_prompt
            else
                decStr = CHS[2200022]
            end

            local autoWalkInfo = gf:findDest(decStr)
            if "$1" == autoWalkInfo.action and PracticeMgr:getIsUseExorcism() then
                gf:confirm(CHS[3003133], function()
                    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end, function()
                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end)

                return
            end

            AutoWalkMgr:beginAutoWalk(autoWalkInfo)
        end
    elseif data["name"] == CHS[6000255] then    -- 天降宝盒
        if data["level"] > tonumber(Me:queryBasic("level")) then
            gf:ShowSmallTips(string.format(CHS[6000259], data["level"]))
   			 else
            gf:ShowSmallTips(CHS[6000256])
        end
    elseif data["name"] == CHS[6000387] then -- 降服恶鬼
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
    elseif data["name"] == CHS[4100285] then -- 随机经验翻倍
        local name = self.radioGroup:getSelectedRadioName()
        local actData = nil
        actData = self:getActiveByName()
        if not actData then return end
        if Me:getLevel() < actData.level then
            gf:ShowSmallTips(string.format(CHS[4200167], actData.name, actData.level))
            return
        end
        self:onGotoBtn(actData)

    elseif data["name"] == CHS[6000394] then -- 它的愿望

        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
    elseif data["name"] == CHS[6400081] then -- 升级狂欢
            gf:ShowSmallTips(CHS[6600002])
    elseif data["name"] == CHS[6000403] then -- 【教师节】师尊问答
        local npcName = gf:getPolarNPC(tonumber(Me:queryBasic("polar")))
        local decStr = string.format(CHS[6000407], npcName)
        local dest = gf:findDest(decStr)
        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data["name"] == CHS[6000409] then -- 教师节】夺回祝福
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
    elseif data["name"] == CHS[4200175] or data["name"] == CHS[4200178] then -- 【中秋节】月饼寻踪 \ 铲除魅妖
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
    elseif data["name"] == CHS[6200058] or data["name"] == CHS[6200061] or data["name"] == CHS[6200064] then -- 【国庆节】扬我军威 / 【国庆节】倾力相助/【国庆节】协助总兵
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
    elseif data["name"] == CHS[6200067] or data["name"] == CHS[6200071] then -- 【重阳节】菊酒祈寿 /【重庆节】百岁祈福
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
    elseif data["name"] == CHS[4300102] then    -- 【国庆节】国庆礼包
        local holidayData = GiftMgr:getWelfareData()
        if not holidayData or holidayData.holidayCount < 0 then return end

        if Me:queryBasicInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

            if curActivity[2] == "dlg" then
                GiftMgr:openGiftDlg(curActivity[3])
            end
        end
    elseif string.match(data["name"], CHS[4300117]) then -- 【光棍节】
        if Me:queryBasicInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
            return
        end

        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

            if curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                GiftMgr:openGiftDlg(curActivity[3])
        end
        end
    elseif data["name"] == CHS[4100871] then -- ""【元旦节】好运鉴宝""
        if Me:getLevel() < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            local task = TaskMgr:getTaskByName(data["name"])
            if task then
                local textCtrl = CGAColorTextList:create()
                textCtrl:setString(task.task_prompt)
                gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
            else
                gf:ShowSmallTips(CHS[4100875])
            end
        end
    elseif data["name"] == CHS[4101164] then -- "【元旦】好运鉴宝"
        if Me:getLevel() < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            local task = TaskMgr:getTaskByName(data["name"])
            if task then
                local textCtrl = CGAColorTextList:create()
                textCtrl:setString(task.task_prompt)
                gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
            else
            gf:ShowSmallTips(CHS[4101165])
            end
        end
    elseif string.match(data["name"], CHS[5000244]) then -- 【元旦节】
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
    elseif data["name"] == CHS[6200075] then -- 全服红包
        if data["goingTime"] and ActivityMgr:getActivityIsCurTime(data["goingTime"], ActivityMgr:getActivityNewTime(data["name"])) then
            local line = math.random(1, 6)
            local _, id = DistMgr:getServerShowName(GameMgr:getServerName())

            local dsetStr = ""
            local openLineMaxNum = tonumber(ActivityMgr:getActivityExtraInfo("quanfu_hongbao"))
            if tonumber(id) and tonumber(id) >= 1 and tonumber(id) <= openLineMaxNum then
                -- 在开启线路内，无需换线
                dsetStr = CHS[6200085]
                AutoWalkMgr:beginAutoWalk(gf:findDest(dsetStr))
            else
                gf:ShowSmallTips(string.format(CHS[6200091], openLineMaxNum))
            end

        else
            DlgMgr:openDlg("SystemRedbagRecordDlg")
        end
    elseif data["name"] == CHS[7002097] then -- 善财仙童
        if data["goingTime"] and ActivityMgr:getActivityIsCurTime(data["goingTime"], ActivityMgr:getActivityNewTime(data["name"])) then
            local _, id = DistMgr:getServerShowName(GameMgr:getServerName())
            local idInt = tonumber(id)


            if DistMgr:curIsTestDist() or (not DistMgr:curIsTestDist() and idInt and idInt % 2 == 1 ) then
                local dsetStr = CHS[6200085]
                AutoWalkMgr:beginAutoWalk(gf:findDest(dsetStr))
            else
                gf:ShowSmallTips(CHS[7003028])
            end
        end
    elseif data["name"] == CHS[7000125] then  -- 欢乐宝箱
        if Me:queryBasicInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            gf:ShowSmallTips(CHS[7000128])
        end
    elseif data["name"] == CHS[5400000] then  -- 法宝任务
        if ActivityMgr:isFinishActivity(data) then
            gf:ShowSmallTips(string.format(CHS[3002212], data.times))
        else
            decStr = TaskMgr:getFaBaoTask()
            if decStr then
                local textCtrl = CGAColorTextList:create()
                textCtrl:setString(decStr)
                gf:onCGAColorText(textCtrl)
            else
                decStr = CHS[5400003]
                AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
            end
        end
    elseif data["name"] == CHS[7000163] or data["name"] == CHS[7000169] then -- 【圣诞】赶走捣蛋鬼 /【圣诞】圣诞大作战
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        elseif data["name"] == CHS[7000169] then -- 【圣诞】装饰圣诞树
            task = TaskMgr:getTaskByName(CHS[7000177])
            if task then -- 任务可能已经过期被移除了，增加判断
                AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
            end
        end
    elseif data["name"] == CHS[2000192] then -- 幸运折扣券
        if Me:queryBasicInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            gf:ShowSmallTips(CHS[2000195])
        end
    elseif string.match(data["name"], CHS[5410007]) then -- 【寒假】
        if Me:getLevel() < data.level then
            gf:ShowSmallTips(string.format(CHS[6000259], data.level))
        elseif data["name"] == CHS[5410016] then   -- 【寒假】刮刮乐
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

            if curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                GiftMgr:openGiftDlg(curActivity[3])
            end
        else
            local task = TaskMgr:getTaskByName(data["name"])
            if task then
            --    DlgMgr:sendMsg("MissionDlg", "specialToDo", task)
                gf:doActionByColorText(task.task_prompt, task)
            end
        end
    elseif string.match(data["name"], CHS[5420074]) then  -- 【情人节】
        if data["name"] == CHS[5420071] then   -- 【情人节】婚礼折扣
            if Me:queryInt("level") < 40 then
                gf:ShowSmallTips(CHS[5420075])
            else
                gf:ShowSmallTips(CHS[5420076])
            end
        elseif data["needLevelTip"] and data["level"] > Me:getLevel() then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            local task = TaskMgr:getTaskByName(data["name"])
            if task then
                gf:doActionByColorText(task.task_prompt, task)
            end
        end
    elseif data.name == CHS[7000278] then   --修法任务
        local task = TaskMgr:getTaskByName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        elseif Me:queryBasicInt("level") >= 70 and Me:isVip() then
            decStr = CHS[2200069]
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        else
            local curActivityTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivityTable[2]]
            AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
        end
    elseif string.match(data["name"], CHS[7003005]) then -- 【植树节】
        if Me:getLevel() < data["level"] then
            gf:ShowSmallTips(string.format(CHS[6000259], data["level"]))
        else
            local task = TaskMgr:getTaskByName(data["name"])

            if task then
                if task.show_name == CHS[5450080] and string.match(task.task_prompt, CHS[5450085]) then
                    CharMgr:talkToMyTMNpc()
                else
                    local textCtrl = CGAColorTextList:create()
                    textCtrl:setString(task.task_prompt)
                    gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
                end
            end
        end
    elseif data["name"] == CHS[2200018] then        -- QQ会员特权礼包
        if ActivityMgr.qqLinkAddr then
            gf:confirm(CHS[5420150], function ()
                ActivityMgr:openQQLink()
                ActivityMgr:cmdClickQQGiftButton(2)
            end)
        end
    elseif string.match(data["name"], CHS[7002083]) then  -- 武学历练
        local task = TaskMgr:getTaskByName(CHS[7002083])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        else
            local curActivityTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivityTable[2]]
            AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
        end

    elseif string.match(data["name"], CHS[3001754]) then  -- 八仙梦境
        local task = TaskMgr:getTaskByName(CHS[3001754])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        else
            local curActivityTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivityTable[2]]
            AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
        end
    elseif data["name"] == CHS[5400047] then  -- 萝卜桃子大收集
        local task = TaskMgr:getTaskByName(CHS[2200039])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        else
            local curActivityTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivityTable[2]]
            AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
        end
    elseif data["name"] == CHS[5400043] then  -- 【劳动节】能者多劳
        local task = TaskMgr:getTaskByName(CHS[5400050])
        if task and string.match(task.task_prompt, CHS[3000844]) then
            gf:doActionByColorText(task.task_prompt, task)
        else
            gf:ShowSmallTips(CHS[5400053])
        end
    elseif data["name"] == CHS[7002140] then  -- 周年庆-掉落翻倍
        DlgMgr:openDlg("DropDoubleDlg")
    elseif data["name"] == CHS[7002150] then  -- 冲榜大赛
        if Me:getLevel() < 10 then
            gf:ShowSmallTips(string.format(CHS[6000259], 10))
        elseif not GuideMgr:isIconExist(10) then
            gf:ShowSmallTips(CHS[7002151])
        else
            DlgMgr:openDlg("RankingListDlg")
        end
    elseif data["name"] == CHS[7002154] then  -- 活跃抽大奖
        if Me:getLevel() < 35 then
           gf:ShowSmallTips(string.format(CHS[6000259], 35))
        else
            GiftMgr:openGiftDlg("ActiveDrawDlg")
        end
    elseif data["name"] == CHS[7002157] then  -- 位列仙班·打折
        DlgMgr:openDlg("OnlineMallVIPDlg")
    elseif data["name"] == CHS[7002160] then  -- 女娲宝箱
        OnlineMallMgr:openOnlineMall("OnlineMallDlg", nil, { [CHS[7002160]] = 1 })
    elseif data["name"] == CHS[7002163] then  -- 充值积分
        GiftMgr:openGiftDlg("ChargePointDlg")
    elseif data["name"] == CHS[7001055] then -- 消费积分
        GiftMgr:openGiftDlg("ChargePointDlg")
    elseif data["name"] == CHS[7003049] then -- 活跃送会员
        GiftMgr:openGiftDlg("ActiveVIPDlg")
    elseif data["name"] == CHS[7190370] then  -- 周年庆-周年礼包
        if Me:queryInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
            return
        end
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

            if curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                DlgMgr:openDlg(curActivity[3])
            end
        end
    elseif data["name"] == CHS[5400063] then  -- 周年庆-五行送福
        if Me:queryInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            gf:ShowSmallTips(CHS[5400062])
        end
    elseif data["name"] == CHS[5410037] then  -- 周年庆-招福宝树
        if Me:queryInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            local curActivityTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivityTable[2]]
            DlgMgr:openDlg(curActivity[3])
        end
    elseif data["name"] == CHS[7002194] then -- 须弥秘境
        if Me:getLevel() < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            local task = TaskMgr:getTaskByName(CHS[7002197])
            if task then
                gf:doActionByColorText(task.task_prompt, task)
            end
        end
    elseif data["name"] == CHS[2100059] then   -- 勇闯万妖窟
        if Me:getLevel() < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        elseif MapMgr:isInWyk() then
            gf:ShowSmallTips(CHS[2100058])
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2100042]))
        end
    elseif data["name"] == CHS[2200027] then -- 异族入侵
        if MapMgr:isInYzrq() then
            local desc = TaskMgr:getFuBenTask()
            local task = TaskMgr:getFuBenTaskData()
            gf:doActionByColorText(desc, task)
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2100073]))
        end
    elseif data["name"] == CHS[4200333] then -- 召回道友
        -- 等级判断
        if Me:queryInt("level") < 70 then
            gf:ShowSmallTips(CHS[4200334])
            return
        end

        GiftMgr:setLastIndex("WelfareButton14")
        local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
        dlg:onGiftsButton(dlg:getControl("GiftsButton"))
    elseif data["name"] == CHS[7003052] then
        -- 粽仙试炼
        if Me:getLevel() < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
        else
            if MapMgr:isInZongXianLou() then
                local tip = TaskMgr:getZongXianAutoWalkTip()
                if tip then
                    AutoWalkMgr:beginAutoWalk(gf:findDest(tip))
                end
            else
                local task = TaskMgr:getTaskByName(CHS[7003067])
                if task then
                    gf:doActionByColorText(task.task_prompt, task)
                end
            end
        end
    elseif data["name"] == CHS[2100075] then -- 儿童节-多彩泡泡
        local task = TaskMgr:getTaskByName(CHS[2100076])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[7003073] then -- 限时特惠
        OnlineMallMgr:openOnlineMall("OnlineMallDlg", nil, { [""] = 1 })
    elseif data["name"] == CHS[4300236] then -- "Month月首充礼包"
        local timeData = ActivityMgr:getActivityStartTimeByMainType(data["mainType"])
        if timeData then
            if gf:getServerTime() > timeData.endTime then
                --gf:ShowSmallTips(CHS[4300239])
                 GiftMgr:openGiftDlg("ChargeGiftPerMonthDlg")
            else
                GiftMgr:openGiftDlg("ChargeGiftPerMonthDlg")
            end
        end
    elseif data["name"] == CHS[4300244] then -- "实名认证礼包"
        if (Me.bindData and Me.bindData.isBindName) then
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300248]))
        else
            DlgMgr:openDlg("SystemAccManageDlg")
        end
    elseif data["name"] == CHS[5420168] then -- "迎新抽奖"
        GiftMgr:openGiftDlg("WelcomNewDlg")
    elseif data["name"] == CHS[5400073] then -- "【七夕节】千里相会"
        local task = TaskMgr:getTaskByName(CHS[5400073])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[5400087] then -- 【中元节】度化游魂
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        else
            gf:ShowSmallTips(CHS[5410107])
        end
    elseif data["name"] == CHS[2000343] then -- 【教师节】捉拿贼人
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[2000357] then -- "【教师节】门派切磋"
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[2000363] then -- "【中元节】金光神咒"
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[5400095] then -- "【国庆节】厉兵秣马"
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[5400104] then -- "【中秋节】猜灯谜"
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[5400120] then -- "【中秋节】接月饼"
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[7100036] then -- "【重阳节】重阳宴席"
        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, { task_type = task.task_type, task_prompt = task.task_prompt })
        end
    elseif data["name"] == CHS[5450021] then -- "【万圣节】万圣节糖果"
        if Me:queryInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
            return
        end

        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[5450022] then -- "【万圣节】万圣节小捣蛋鬼"
        if Me:queryInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
            return
        end

        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, { task_type = task.task_type, task_prompt = task.task_prompt })
        end
    elseif data["name"] == CHS[7100051] then -- "【元旦节】罗盘寻踪"
        if Me:queryInt("level") < 30 then
            gf:ShowSmallTips(string.format(CHS[6000259], 30))
            return
        end

        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, { task_type = task.task_type, task_prompt = task.task_prompt })
        end
    elseif data["name"] == CHS[4100728] then -- "【居所】材料收集"
        if Me:queryBasic("house/id") == "" then
            DlgMgr:sendMsg("GameFunctionDlg", "onHomeButton")
            return
        end

        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

            if curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                DlgMgr:openDlg(curActivity[3])
            end
        end
    elseif data["name"] == CHS[6400041] then -- "强帮之道"
        if Me:queryBasic("party/name") == "" then
            gf:ShowSmallTips(CHS[3002211])
            return
        end

        local task = TaskMgr:getTaskByShowName(data["name"])
        if task then
            gf:doActionByColorText(task.task_prompt, task)
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动

            if curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                DlgMgr:openDlg(curActivity[3])
            end
        end
    elseif data["name"] == CHS[4100704] then -- "跨服战场"
        if KuafzcMgr:isKFZCJournalist() then
            gf:ShowSmallTips(CHS[4300281])
    	else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300282]))
        end
    elseif data["name"] == CHS[4010310] then -- "月跨服战场"
        if KuafzcMgr:isKFZCJournalist() then
            gf:ShowSmallTips(CHS[4300281])
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4010388]))
        end
    elseif data["name"] == CHS[5410206] then -- 水岚之缘-剧情
        DlgMgr:openDlg("BridgeTaskDlg")
    elseif data["name"] == CHS[5420240] then -- 星宿妖王翻倍
        gf:ShowSmallTips(CHS[5420241])
    elseif data["name"] == CHS[5420244] then -- 活跃登录礼包
        GiftMgr:openGiftDlg("ActiveLoginRewardDlg")
    elseif data["name"] == CHS[2200095] then   -- 合服促登录礼包
        if Me:getLevel() < GiftMgr:getMergerLoginGiftLimitLevel() then
            gf:ShowSmallTips(CHS[2200114])
        else
            GiftMgr:openGiftDlg("MergeLoginGiftDlg")
        end
    elseif data["name"] == CHS[2200098] then -- 合服活跃大礼
        if Me:getLevel() < 70 then
            gf:ShowSmallTips(CHS[2200114])
        else
            GiftMgr:openGiftDlg("CombinedServiceTaskDlg")
        end
    elseif data["name"] == CHS[5400448] then -- 【周年庆】驯养灵猫
        local task = TaskMgr:getTaskByName(CHS[5400448])
        if data["level"] > Me:getLevel() then
            gf:ShowSmallTips(string.format(CHS[6000259], data["level"]))
        elseif not task then
            gf:ShowSmallTips(CHS[5400518])
        elseif string.match(task.task_prompt, CHS[5400517]) then
            if Me:isInCombat() then
                gf:ShowSmallTips(CHS[3003913])
            elseif Me:isLookOn() then
                gf:ShowSmallTips(CHS[3003914])
            else
            gf:ShowSmallTips(CHS[5400519])
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5400520]))
            end
        else
            AnniversaryMgr:tryOpenLingMaoDlg()
        end
    elseif data["name"] == CHS[7100202] then -- 【周年庆】周年分享
        if data["level"] > tonumber(Me:queryBasic("level")) then
            gf:ShowSmallTips(string.format(CHS[6000259], data["level"]))
            return
        end

        -- 周年分享改为分享截图
        ShareMgr:share(SHARE_FLAG.ZHOUNIANQING, nil, nil, 2)
        ShareMgr.needNotifyServer = true
    elseif data["needLevelTip"] and data["level"] > Me:getLevel() then
        gf:ShowSmallTips(string.format(CHS[6000259], data["level"]))
    elseif data["name"] == CHS[4010012] then -- 夫妻任务
        if ActivityMgr:getActivityCurTimes(CHS[4010012]) >= 1 then
            -- 若角色今日已完成1次夫妻任务，点击后弹出提示
            gf:ShowSmallTips(CHS[4010017])
            return
        elseif not MarryMgr:isMarried() then
            -- 若角色目前并无婚姻关系，点击后弹出提示
            gf:ShowSmallTips(CHS[4010018])
            return
        elseif not TaskMgr:getMarryTask() then
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动
            AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
        else
            local task = TaskMgr:getMarryTask()
            gf:doActionByColorText(task.task_prompt, task)
        end
    elseif data["name"] == CHS[4010027] then -- 证道殿

        if MapMgr:isInMapByName(CHS[4010027]) then
            gf:ShowSmallTips(CHS[4101085])
        else
            local str = string.format(CHS[4010033], gf:getPolar(Me:queryInt("polar")))
            AutoWalkMgr:beginAutoWalk(gf:findDest(str))
        end
    elseif data["name"] == CHS[4010082] then -- 英雄会
        local str = string.format("#P%d#P", math.floor(Me:queryInt("level") / 10) * 10)
        AutoWalkMgr:beginAutoWalk(gf:findDest(str))
    elseif data["name"] == CHS[4200709] then --  养育任务
        local count = HomeChildMgr:getChildenCount()
        if not count then
            -- 数据没有收到，正常情况由于延迟，不给提示和反应
            return false
        elseif count <= 0 then
            gf:ShowSmallTips(CHS[4010394])  -- 你尚未拥有娃娃或天地灵石，可找#R风月谷#n的#Y送子娘娘#n了解如何获得娃娃。
            return false
        end
        local kidId = HomeChildMgr:isHasETQchild()
        if not kidId then
            gf:ShowSmallTips(CHS[4200714])
            return
        end

        DlgMgr:openDlgEx("KidInfoDlg", {selectId = kidId})
    elseif data["name"] == CHS[7190182] then --  喜来客栈
        if not InnMgr:hadBoughtInn() then
            gf:confirm(CHS[7120078], function()
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7120079]))
            end)
        else
            if CHS[7190182] == MapMgr:getCurrentMapName() then
                -- 已经在此地图内了
                gf:ShowSmallTips(CHS[7120075])
            else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7100255]))
        end
        end
    elseif data["needLevelTip"] and data["level"] > Me:getLevel() then
        gf:ShowSmallTips(string.format(CHS[6000259], data["level"]))
    else
        -- 后面为通用处理
        local task = TaskMgr:getTaskByName(data["name"])
        if not task then
            -- 一般任务存在时，通过name就能获取到任务，当没有获取到任务时，再通过 getTaskByShowName 获取
            task = TaskMgr:getTaskByShowName(data["name"])
        end

        if task then
            if data["goToBtnSameAsTaskPanel"] then
                local textCtrl = CGAColorTextList:create()
                textCtrl:setString(task.task_prompt)
                gf:onCGAColorText(textCtrl, nil, { task_type = task.task_type, task_prompt = task.task_prompt, task_extra_para = task.task_extra_para })
            else
                gf:doActionByColorText(task.task_prompt, task)
            end
        else
            local curActivetyTable = ActivityMgr:isCurActivity(data)
            local curActivity = data["activityTime"][curActivetyTable[2]]  -- 当前时间段的活动
            if curActivity[2] == "func" and ActivityGotoCallFunc[data["name"]] then
                ActivityGotoCallFunc[data["name"]](data)
            elseif curActivity[2] == "npc" then
                AutoWalkMgr:beginAutoWalk(gf:findDest(curActivity[3]))
            elseif curActivity[2] == "dlg" then
                DlgMgr:openDlg(curActivity[3])
            elseif curActivity[2] == "giftDlg" then
                GiftMgr:openGiftDlg(curActivity[3])
            elseif curActivity[2] == "tips" then
                gf:ShowSmallTips(curActivity[3])
            elseif curActivity[2] == "cmd" then
                if curActivity[4] then
                    gf:confirm(curActivity[4], function()
                gf:CmdToServer(curActivity[3], {})
                    end)
                else
                    gf:CmdToServer(curActivity[3], {})
                end
            end
        end
    end

    --  记录点击次数
    RecordLogMgr:addClickAction("clickgotobutton", data["name"])
end

function ActivitiesDlg:getActiveByName()
    local function getAct(data)
        for i = 1, #data do
            if ActivityMgr.doubleActvies[CHS[4100285]] and ActivityMgr.doubleActvies[CHS[4100285]][data[i].name] then
                return data[i]
            end
        end

        return nil
    end

    local data = ActivityMgr:getDailyActivity()
    local destAct = getAct(data)
    if destAct then return destAct end

    data = ActivityMgr:getLimitActivity()
    destAct = getAct(data)
    if destAct then return destAct end

    data = ActivityMgr:getFestivalActivity()
    destAct = getAct(data)
    if destAct then return destAct end

    data = ActivityMgr:getComingActivity()
    destAct = getAct(data)
    if destAct then return destAct end

    data = ActivityMgr:getOhterActivityData()
    destAct = getAct(data)
    if destAct then return destAct end

    data = ActivityMgr:getWelfareActivity()
    destAct = getAct(data)
    if destAct then return destAct end

    return nil
end

-- 活跃度奖励
function ActivitiesDlg:initRewardPanel()

    local rewardStatusTable = ActivityMgr:getRewardStatus() or {}
    local reward =  ActivityMgr:getActivityReward()

    -- 设置进度条
    local curValue = math.floor(ActivityMgr:getAllActivity())
    self:setProgressBar("activityProgressBar", curValue, 106)
    local activeValueImage = self:getControl("ActiveValueImage")
    self:setLabelText("Label_1", curValue, activeValueImage)
    self:setLabelText("Label_2", curValue, activeValueImage)
    local activeProgress = self:getControl("activityProgressBar")
    local posx
    if curValue > 106 then
        posx = activeProgress:getContentSize().width * (106 / 106)
    else
        posx = activeProgress:getContentSize().width * (curValue / 106)
    end
    activeValueImage:setPositionX(posx)

    for i = 1, #reward do
        local rewardPanel = self:getControl(string.format("RewardPanel%d",i), Const.UIPanel)
        local rewardItemPanel = self:getControl("RewardItemPanel", Const.UIPanel, rewardPanel)
        local image = self:getControl("BonusImage", Const.UIImage, rewardPanel)
        rewardItemPanel:setTag(i)
        local key = reward[i]["activity"]
        if reward[i]["icon"] then
            local path = ResMgr:getItemIconPath(reward[i]["icon"])
            image:loadTexture(path)
            gf:setItemImageSize(image)
        else
            -- “活跃度宝箱”无Icon属性，区分后设置“活跃度宝箱”图标
            image:loadTexture(ResMgr.ui.item_common, ccui.TextureResType.plistType)
        end

        if rewardStatusTable[key] and rewardStatusTable[key]["status"] == 1 then -- 已领取
            self:setCtrlVisible("CoverImage", true, rewardPanel)
            self:removeMagic(rewardItemPanel, Const.ARMATURE_MAGIC_TAG)
        elseif rewardStatusTable[key] and rewardStatusTable[key]["status"] == 2 then -- 可以领取
            self:setCtrlVisible("CoverImage", false, rewardPanel)
            -- lixh2 WDSY-21401 帧光效修改为粒子光效：活跃度物品栏环绕光效
            gf:createArmatureMagic(ResMgr.ArmatureMagic.item_around, rewardItemPanel, Const.ARMATURE_MAGIC_TAG)
        else
            self:setCtrlVisible("CoverImage", false, rewardPanel)
            self:removeMagic(rewardItemPanel, Const.ARMATURE_MAGIC_TAG)
        end

        -- 为活跃度奖励图标添加永久限制交易标志(除银元宝、活跃度宝箱外)
        if reward[i]["icon"] and
            ResMgr:getItemIconPath(reward[i]["icon"]) == ResMgr.ui.yinyuanbao then

        elseif not reward[i]["icon"] then

        else
            InventoryMgr:addLogoBinding(image)
        end

        local function showItemInfo(sender, type)
            if ccui.TouchEventType.ended == type then
           --     local dlg = DlgMgr:openDlg("ActivitiesInfoFFDlg")
           --     dlg:setData(reward[i]["reward"], true)
                if not DistMgr:checkCrossDist() then return end
                if rewardStatusTable[key] and rewardStatusTable[key]["status"] == 2 then
                    -- 领取奖励
                    ActivityMgr:getReward(key)

                    self:removeMagic(rewardItemPanel, Const.ARMATURE_MAGIC_TAG)
                else
                local rect = self:getBoundingBoxInWorldSpace(rewardItemPanel)
                local pos = gf:findStrByByte(reward[i]["reward"], "X")
                local itemName = ""
                if not pos then
                    InventoryMgr:showBasicMessageDlg(reward[i]["reward"], rect)
                else
                    itemName = string.sub(reward[i]["reward"], 1, pos - 1)
                    local count = string.sub(reward[i]["reward"], pos + 1, -1)
                    if DistMgr:isTestDist(GameMgr.dist) and reward[i]["testDistReward"] then
                        count = string.sub(reward[i]["testDistReward"], pos + 1, -1)
                    end
                    local item = {}
                    if itemName == CHS[6000080] or itemName == CHS[6000042] then
                        item["Icon"] = InventoryMgr:getIconByName(itemName)
                        item["name"] = itemName
                        item["extra"] = nil
                        item["desc2"] = string.format(InventoryMgr:getDescript(itemName), count).."\n"
                        item["isShowDesc"] = 0
                        InventoryMgr:showBasicMessageByItem(item, rect)
                    else
                        InventoryMgr:showBasicMessageDlg(itemName, rect)
                    end
                end
                end
            end
        end

        rewardItemPanel:addTouchEventListener(showItemInfo)
    end
end

function ActivitiesDlg:cleanup()
    if self.dailyCell then
        self.dailyCell:release()
        self.dailyCell = nil
    end

    if self.limitCell then
        self.limitCell:release()
        self.limitCell = nil
    end

    if self.comingCell then
        self.comingCell:release()
        self.comingCell = nil
    end

    if self.dailyCells then
        for name, _ in pairs(self.dailyCells) do
            self:removeDailyCellsFromParent(name)
            for tag, __ in pairs(self.dailyCells[name]) do
                self.dailyCells[name][tag]:release()
                self.dailyCells[name][tag] = nil
            end
            self.dailyCells[name] = nil
        end
        self.dailyCells = nil
    end

    self.curRewardType = nil
end

function ActivitiesDlg:getSelectItemBox(type)

    local scrollview = self:getControl("DailyScrollView", Const.UIScrollView)
    local panel = scrollview:getChildByTag(SCROLLVIEW_CHILD_TAG):getChildByTag(1)
    local btn = self:getControl("GoButton", nil, panel)

    return self:getBoundingBoxInWorldSpace(btn)
end

-- 滑到某个活动，如果滑动距离足够活动会在最顶部
function ActivitiesDlg:scrollToOneActivity(scrollview, tag, data)
    local contentLayer = scrollview:getChildByTag(SCROLLVIEW_CHILD_TAG)
    local cell = contentLayer:getChildByTag(data.index)

    if not cell then
        return
    end

    local scrollSize = scrollview:getContentSize()
    local scrollInnerSize = contentLayer:getContentSize()
    local canScrollHeight = scrollInnerSize.height - scrollSize.height
    local line = math.floor((tag - 1) / COLUNM)

    local scrollTime = 0.05 *line
    if line > 0 and canScrollHeight > 0 then
        local scrollHeight = line * (cell:getContentSize().height + LINE_SAPCE)
        if scrollHeight > canScrollHeight then
            scrollHeight = canScrollHeight
        end

        local percent = scrollHeight / canScrollHeight * 100
        scrollview:scrollToPercentVertical(percent, scrollTime, false)
    end

    -- 冻屏
    gf:frozenScreen((scrollTime + 0.15) * 1000)

    -- 弹出活动悬浮框
    performWithDelay(self.root ,function ()
        cell.data = data
        touchCell(cell, ccui.TouchEventType.ended)
    end, scrollTime + 0.15)
end

function ActivitiesDlg:onDlgOpened(list, param)
    if not list then
        return
    end

    local scrollview
    local activityData
    if list[1] == CHS[5420151] then
        self:OnSiwchTab(self:getControl("DailyCheckBox"))
        self:setCheck("DailyCheckBox", true)
        self:setCheck("LimitedCheckBox", false)
        self:setCheck("FestivalCheckBox", false)
        self:setCheck("ComingCheckBox", false)
        self:setCheck("OtherCheckBox", false)
        scrollview = self:getControl("DailyScrollView", Const.UIScrollView)
        activityData = ActivityMgr:getDailyActivity()
    elseif list[1] == CHS[3002230] then
        self:OnSiwchTab(self:getControl("LimitedCheckBox"))
        self:setCheck("LimitedCheckBox", true)
        self:setCheck("DailyCheckBox", false)
        self:setCheck("FestivalCheckBox", false)
        self:setCheck("ComingCheckBox", false)
        self:setCheck("OtherCheckBox", false)
        scrollview = self:getControl("LimitedScrollView", Const.UIScrollView)
        activityData = ActivityMgr:getLimitActivity()
    elseif list[1] == CHS[5420152] then -- 节日活动
        self:OnSiwchTab(self:getControl("FestivalCheckBox"))
        self:setCheck("FestivalCheckBox", true)
        self:setCheck("DailyCheckBox", false)
        self:setCheck("LimitedCheckBox", false)
        self:setCheck("ComingCheckBox", false)
        self:setCheck("OtherCheckBox", false)
        scrollview = self:getControl("FestivalScrollView", Const.UIScrollView)
        activityData = ActivityMgr:getFestivalActivity()
    elseif list[1] == CHS[5420153] then
        self:OnSiwchTab(self:getControl("ComingCheckBox"))
        self:setCheck("ComingCheckBox", true)
        self:setCheck("DailyCheckBox", false)
        self:setCheck("FestivalCheckBox", false)
        self:setCheck("LimitedCheckBox", false)
        self:setCheck("OtherCheckBox", false)
        scrollview = self:getControl("ComingScrollView", Const.UIScrollView)
        activityData = ActivityMgr:getComingActivity()
    elseif list[1] == CHS[6400009] or list[1] == CHS[4100813] then
        self:OnSiwchTab(self:getControl("OtherCheckBox"))
        self:setCheck("OtherCheckBox", true)
        self:setCheck("DailyCheckBox", false)
        self:setCheck("FestivalCheckBox", false)
        self:setCheck("ComingCheckBox", false)
        self:setCheck("LimitedCheckBox", false)
        scrollview = self:getControl("OtherScrollView", Const.UIScrollView)
        activityData = ActivityMgr:getOhterActivityData()
    end

    if not scrollview then
        return
    end

    if list[2] then
        for key, v in pairs(activityData) do
            if activityData[key].name == list[2] then
                self:scrollToOneActivity(scrollview, key, activityData[key])
                return
            end
        end
    end
end

return ActivitiesDlg
