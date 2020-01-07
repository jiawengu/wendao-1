-- KidRearingDlg.lua
-- Created by songcw Mar/06/2019
-- 娃娃抚养界面

local KidRearingDlg = Singleton("KidRearingDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 婴儿期CheckBox
local DLG_CHECKBOX = {
    "TakeCarePanelCheckBox",         -- 状态
    "SchedulingPanelCheckBox",         -- 资质
}

local OPER_CHECKBOX = {
    "CheckBox_1",         -- 喂养
    "CheckBox_2",         -- 清洁
    "CheckBox_3",         -- 娱乐
    "CheckBox_4",         -- 睡觉
    "CheckBox_5",         -- 其他
}

-- 日期checkBox
local DATE_CHECKBOX = {
    "DateCheckBox_1",       -- 今天
    "DateCheckBox_2",       -- 明天
}

local OPER_CONFIG = {
    -- fun_str 由于策划拼成多个label实现，部分颜色特殊，所以用表形式表现
    -- cost_200 -- 成熟度 <= 200的
    -- cost_20 -- 成熟度小于 200的
    ["CheckBox_1"] = {  -- 喂养
        {   -- 喂母乳
            chs = CHS[4101324],
            op_type = HomeChildMgr.FY_TYPE.WMR,
            fun_str = {CHS[4101325], "+25", CHS[4101326], "+5"},
            cost_200_str = {CHS[4101327], "+10"},
            cost_str = {CHS[4101327], "+5"},
            refresh_time = 8,
            desc_str = CHS[4101328],
            condition = {gender = GENDER_TYPE.FEMALE},
            cost_cash = 0,
        },

        {   -- 喂牛奶
            chs = CHS[4101329],
            op_type = HomeChildMgr.FY_TYPE.WNN,
            fun_str = {CHS[4101325], "+15"},
            cost_200_str = {CHS[4101327], "+5"},
            cost_str = {CHS[4101327], "+3"},
            refresh_time = 4,
            desc_str = CHS[4101330],
            cost_cash = 600000,
        },

        {   -- 喂菜肴
            chs = CHS[4101331],
            op_type = HomeChildMgr.FY_TYPE.WCY,
            fun_str = {CHS[4101332]},
            cost_200_str = {CHS[4101327], "+2"},
            cost_str = {CHS[4101327], "+1"},
            refresh_time = 2,
            desc_str = CHS[4101333],
        },
    },

    ["CheckBox_2"] = {  -- 清洁
        {   -- 沐浴
            chs = CHS[4101334],
            op_type = HomeChildMgr.FY_TYPE.MY,
            fun_str = {CHS[4101335], "+20"},
            cost_200_str = {CHS[4101327], "+7"},
            cost_str = {CHS[4101327], "+4"},
            refresh_time = 6,
            desc_str = CHS[4101336],
            cost_cash = 1000000,
        },

        {   -- 洗脸
            chs = CHS[4101337],
            op_type = HomeChildMgr.FY_TYPE.XL,
            fun_str = {CHS[4101335], "+15"},
            cost_200_str = {CHS[4101327], "+5"},
            cost_str = {CHS[4101327], "+3"},
            refresh_time = 4,
            desc_str = CHS[4101338],
            cost_cash = 600000,
        },
    },

    ["CheckBox_3"] = {  -- 娱乐
        {   -- 玩玩具
            chs = CHS[4101339],
            op_type = HomeChildMgr.FY_TYPE.WWJ,
            fun_str = {CHS[4101340], "+20"},
            cost_200_str = {CHS[4101327], "+7"},
            cost_str = {CHS[4101327], "+4"},
            refresh_time = 6,
            desc_str = CHS[4101341],
            cost_cash = 1000000,
        },

        {   -- 陪玩
            chs = CHS[4101342],
            op_type = HomeChildMgr.FY_TYPE.PW,
            fun_str = {CHS[4101340], "+15"},
            cost_200_str = {CHS[4101327], "+5"},
            cost_str = {CHS[4101327], "+3"},
            refresh_time = 4,
            desc_str = CHS[4101343],
            cost_cash = 600000,
        },
    },

    ["CheckBox_4"] = {  -- 睡觉
        {   -- 摇篮曲
            chs = CHS[4101344],
            op_type = HomeChildMgr.FY_TYPE.YLQ,
            fun_str = {CHS[4101327], "-100"},
            refresh_time = 8,
            desc_str = CHS[4101345],
            cost_cash = 600000,
        },

        {   -- 管家看护
            chs = CHS[4101346],
            op_type = HomeChildMgr.FY_TYPE.GJKH,
            fun_str = {CHS[4101327], "-100"},
            refresh_time = 8,
            desc_str = CHS[4101347],
            cost_cash = 1000000,
        },
    },

    ["CheckBox_5"] = {  -- 其他
        {   -- 人参果
            chs = CHS[4101348],
            op_type = HomeChildMgr.FY_TYPE.RSG,
            fun_str = {CHS[4101349], "+50"},
            refresh_time = 8,
            desc_str = CHS[4101350],
            cost_cash = 10000000,
        },

        {   -- 小儿灵
            chs = CHS[4101351],
            op_type = HomeChildMgr.FY_TYPE.XEL,
            fun_str = {CHS[4101352]},
            refresh_time = 4,
            desc_str = CHS[4101353],
            cost_cash = 5000000,
        },

        {   -- 拨浪鼓
            chs = CHS[4101354],
            op_type = HomeChildMgr.FY_TYPE.BLG,
            fun_str = {CHS[4101355], "+800"},
            refresh_time = 4,
            desc_str = CHS[4101356],
            cost_cash = 10000000,
        },
    },
}



local LIST_PANEL_POS_X = {
    left = 156, right = 466,
}

local SCHEDULE_INFO = {}

local MATURE_MAX = 1000

function KidRearingDlg:init(data)
    self:bindListener("InfoButton", self.onTakeCareInfoButton, "TakeCarePanel")
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("InfoButton", self.onSchduleInfoButton, "SchedulingPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("ModifyButton", self.onModifyButton)
    self:bindListener("HistoryButton", self.onHistoryButton)
    self:bindListener("IllPanel", self.onIllPanel)
    self:bindListViewListener("ListView", self.onSelectListView)

    self:bindListener("MoneyPanel", self.onMoneyButton, "TakeCarePanel")
    self:bindListener("MoneyPanel", self.onMoneyButton, "SchedulingPanel")

    self:bindListener("RulePanel", self.onCloseRulePanel, "TakeCarePanel")
    self:bindListener("RulePanel", self.onCloseRulePanel, "SchedulingPanel")

    self:bindFloatingEvent("RulePanel", "TakeCarePanel")
    self:bindFloatingEvent("RulePanel", "SchedulingPanel")
    self:bindFloatingEvent("ListPanel", "SchedulingPanel")

    self.data = data
    self.isFirstShowSchedule = true
    self.selectFyData = nil
    self.isReloadList = false
    self.forSelectName = nil
    self.buttonState = {DateCheckBox_1 = false, DateCheckBox_2 = false}   -- 确认行程或者修改行程
    self.modifySchedule = {DateCheckBox_1 = {}, DateCheckBox_2 = {}}
    self.refreashTime = gf:getServerTime()

    self.tipsCountForHeath = 0
    self.tipsCountForFatigue = 0

    self.addScheduleListOrgSize = self.addScheduleListOrgSize or self:getCtrlContentSize("ListView", "ListPanel")

    SCHEDULE_INFO = HomeChildMgr:getScheduleCfg()

    self:initForCtrl()

    self.unitPanel = self:retainCtrl("UnitPanel")
    local leftPanel = self:getControl("LeftPanel", nil, self.unitPanel)
    self:bindTouchEndEventListener(leftPanel, self.onSelectSchedulePanel)
    self:bindListener("IconPanel", self.onSelectSchedulePanel, leftPanel)

    local rightPanel = self:getControl("RightPanel", nil, self.unitPanel)
    self:bindTouchEndEventListener(rightPanel, self.onSelectSchedulePanel)
    self:bindListener("IconPanel", self.onSelectSchedulePanel, rightPanel)

  --  self:bindListener("LeftPanel", self.onSelectSchedulePanel, self.unitPanel)
  --  self:bindListener("RightPanel", self.onSelectSchedulePanel, self.unitPanel)
    self.selectScheduleImage = self:retainCtrl("ChosenEffectImage", self.unitPanel)
    self.unitPanelForSelect = self:retainCtrl("OneCasePanel")
    self:bindTouchEndEventListener(self.unitPanelForSelect, self.onAddSchedulePanel)


    self.opRadioGroup = RadioGroup.new()
    self.opRadioGroup:setItems(self, OPER_CHECKBOX, self.onOperCheckBox)
    self.opRadioGroup:setSetlctByName(OPER_CHECKBOX[1])

    self.dateRadioGroup = RadioGroup.new()
    self.dateRadioGroup:setItems(self, DATE_CHECKBOX, self.onDateCheckBox)
    self.dateRadioGroup:setSetlctByName(DATE_CHECKBOX[1])

    -- 标签页单选框
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, DLG_CHECKBOX, self.onDlgCheckBox, nil, nil, self.onPreDlgCheckBox)
    self.radioGroup:setSetlctByName(DLG_CHECKBOX[1])




    self:setTakeCareData(data)
    self:setScheduleData(data)

    -- self:hookMsg("MSG_CHILD_RAISE_INFO") 由于数据需要管理器转化下，所以不监听消息，由管理器处理后通知刷新
    self:hookMsg("MSG_CHILD_CHECK_SCHEDULE_RESULT")
    self:hookMsg("MSG_CHILD_CHECK_CHANGE_SCHEDULE_RET")
    self:hookMsg("MSG_CHILD_SCHEDULE")

end


function KidRearingDlg:onUpdate()
    if gf:getServerTime() - self.refreashTime >= 120 then

        self:isSameDay()

        gf:CmdToServer("CMD_CHILD_REQUEST_RAISE_INFO", {child_id = self.data.id, type = 1})
        self.refreashTime = gf:getServerTime()
    end
end

-- 初始化时一些控件
function KidRearingDlg:initForCtrl()
    -- 圆形
    for i = 1, 3 do
        local panel1 = self:getControl("ChoosePanel" .. i, nil, "TwoOptionPanel")
        local panel2 = self:getControl("ChoosePanel" .. i, nil, "ThreeOptionPanel")

        if panel1 then
            self:setCtrlVisible("ChosenImage", false, panel1)
            self:bindTouchEndEventListener(panel1, self.onClickCircle)
        end
        if panel2 then
            self:setCtrlVisible("ChosenImage", false, panel2)
            self:bindTouchEndEventListener(panel2, self.onClickCircle)
        end
    end
end

-- 重置行程列表
function KidRearingDlg:updateScheduleList(checkName, isReload, isFromServer)

    self.isReloadList = true
    local retData = self.data.ret.todayData
    if checkName == "DateCheckBox_2" then
        retData = self.data.ret.tomorrowData
    end

    local selectIdx = 0
    local list
    if not isReload then
        list = self:resetListView("ListView", 0, nil, "SchedulingChosePanel")
        local count = 6
        local idx = 0
        for i = 1, count do
            local panel = self.unitPanel:clone()
            local lPanel = self:getControl("LeftPanel", nil, panel)
            idx = idx + 1
            lPanel:setTag(idx)
            lPanel.forSelectName = checkName .. "LeftPanel" .. idx
            self:setCellSchedule(retData[idx], lPanel)

            if gf:getServerTime() > retData[idx].startTime then
                selectIdx = i
            end

            idx = idx + 1
            local rPanel = self:getControl("RightPanel", nil, panel)
            rPanel:setTag(idx)
            rPanel.forSelectName = checkName .. "RightPanel" .. idx
            self:setCellSchedule(retData[idx], rPanel)

            list:pushBackCustomItem(panel)

            if gf:getServerTime() < retData[idx].startTime then
                selectIdx = i
            end
        end
    else
        list = self:getControl("ListView", nil, "SchedulingChosePanel")
        local count = 6
        local idx = 0
        local items = list:getItems()
        for i = 1, #items do
            local panel = items[i]
            local lPanel = self:getControl("LeftPanel", nil, panel)
            idx = idx + 1
            lPanel.forSelectName = checkName .. "LeftPanel" .. idx
            self:setCellSchedule(retData[idx], lPanel)

            if gf:getServerTime() > retData[idx].startTime then
                selectIdx = i
            end

            idx = idx + 1
            local rPanel = self:getControl("RightPanel", nil, panel)
            rPanel.forSelectName = checkName .. "RightPanel" .. idx
            self:setCellSchedule(retData[idx], rPanel)

            if gf:getServerTime() > retData[idx].startTime then
                selectIdx = i
            end
        end
    end


    list:requestDoLayout()

    if not isFromServer then
        self:setListJumpItem(selectIdx)
        list:requestDoLayout()
    end

end

function KidRearingDlg:setCellSchedule(data, panel)
    panel.data = data

    if not data then
        local sss
    end

    if data.sch_type == HomeChildMgr.SCHE_TYPE.NONE then
        self:setImagePlist("IconImage", ResMgr.ui.touming, panel)
    else
        local info = HomeChildMgr:getScheduleCfg(data.sch_type)
        self:setImage("IconImage", info.icon, panel)
    end

    self:setCtrlVisible("NoneIconImage", data.sch_type == HomeChildMgr.SCHE_TYPE.NONE, panel)

    self:setLabelText("NameLabel", data.name, panel)
    self:setLabelText("TimeLabel", data.timeStr, panel)

    local completePanel = self:setCtrlVisible("TimePanel", false, panel)
    self:setCtrlEnabled("BackImage", true, panel)
    self:setCtrlEnabled("IconImage", true, panel)
    self:setCtrlEnabled("NoneIconImage", true, panel)
    panel.progressStage = 0
    if gf:getServerTime() - data.startTime >= 3600 then
        -- 已经完成的
        self:setCtrlEnabled("BackImage", false, panel)
        self:setCtrlEnabled("IconImage", false, panel)
        self:setCtrlEnabled("NoneIconImage", false, panel)
        panel.progressStage = 1
    else
        if gf:getServerTime() - data.startTime < 3600 and gf:getServerTime() - data.startTime > 0 then
            -- 正在进行
            panel.progressStage = 2

            if data.sch_type == HomeChildMgr.SCHE_TYPE.NONE then
                if completePanel then
                    completePanel:setVisible(true)
            --        self:setLabelText("NameLabel", "", panel)
                    self:setLabelText("TimeLabel", "", panel)
                    local hourglass = data.startTime + 3600
                    local startValue = (gf:getServerTime() - data.startTime) / 3600 * 100

                    self:setProgressBar("ProgressBar", startValue, 100, completePanel)
                    local per = math.floor( startValue )
                    self:setLabelText("ValueLabel", per .. "%", completePanel)
                    self:setLabelText("ValueLabel2", per .. "%", completePanel)
                end

            else
                if completePanel then
                    completePanel:setVisible(true)
                    local bar = self:getControl("ProgressBar", nil, completePanel)
                    bar:stopAllActions()
                    if data.sch_type ~= HomeChildMgr.SCHE_TYPE.NONE then
                        local hourglass = data.startTime + 3600
                        local startValue = (gf:getServerTime() - data.startTime) / 3600 * 100
                    -- self:setProgressBarByHourglass("ProgressBar", hourglass, startValue, nil, completePanel)
                        self:setProgressBar("ProgressBar", startValue, 100, completePanel)
                        local per = math.floor( startValue )
                        self:setLabelText("ValueLabel", per .. "%", completePanel)
                        self:setLabelText("ValueLabel2", per .. "%", completePanel)
                        self:setLabelText("TimeLabel", "", panel)
                    end
                end
            end



        else
            -- 未开始
			-- 如果有已经设置过（切换日期后），则设置上
            local modifyData = self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][panel:getTag()]
            if modifyData then
                self:setLabelText("NameLabel", SCHEDULE_INFO[modifyData.op_type].name, panel)
                if modifyData.op_type == 0 then
                    self:setImagePlist("IconImage", ResMgr.ui.touming, panel)
                    self:setCtrlVisible("NoneIconImage", true, panel)
                else
                    self:setImage("IconImage", HomeChildMgr:getScheduleCfg(modifyData.op_type).icon, panel)
                    self:setCtrlVisible("NoneIconImage", false, panel)
                end


            end
        end
    end

    local progressPanel = self:getControl("MoneyCostPanel", nil, panel)
    if progressPanel then
        local cash, color = gf:getArtFontMoneyDesc(data.cost)
        self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 23, progressPanel)
    end
end

function KidRearingDlg:setAddCellSchedule(data, panel)
    panel.data = data
    self:setCtrlVisible("NoneIconImage", data.name == CHS[4101364], panel)

    self:setLabelText("NameLabel", data.name, panel)


    self:setImage("IconImage", data.icon, panel)
    self:setCtrlVisible("IconImage", true, panel)

    if data.isNeedServerData then
        local num1 = self.data.ret.completedToday[data.op_type] or 0
        local num2 = self.data.special_sch_data[data.op_type] and self.data.special_sch_data[data.op_type].cur_times or 0
        local completed = num1 + num2
        self:setLabelText("TimeLabel", string.format(data.desc, completed), panel)
    else
        self:setLabelText("TimeLabel", data.desc, panel)
    end

    local progressPanel = self:getControl("MoneyCostPanel", nil, panel)
    if progressPanel then
      --  local cash, color = gf:getArtFontMoneyDesc(data.cost)
    --    self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 23, progressPanel)


        if not data.cost or data.cost == 0 then
            self:setCtrlVisible("MoneyCostPanel", false, panel)
        else
            self:setCtrlVisible("MoneyCostPanel", true, panel)
            local cash, color = gf:getArtFontMoneyDesc(data.cost)
            self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.LEFT_TOP, 23, progressPanel)
        end

    end
end

function KidRearingDlg:onClickCircle(sender, eventType)

    self.selectFyData = sender.data

    -- 隐藏、显示选中
    local panel = sender:getParent()
    for i = 1, 3 do
        local panelName = "ChoosePanel" .. i
        local circlePanel = self:getControl(panelName, nil, panel)
        if circlePanel then
            self:setCtrlVisible("ChosenImage", panelName == sender:getName(), circlePanel)
        end
    end

    -- 设置数据
    self:setOptionInfo(sender.data)
end


function KidRearingDlg:onCloseRulePanel(sender, eventType)
   sender:setVisible(false)
end

function KidRearingDlg:onMoneyButton(sender, eventType)
   DlgMgr:openDlgEx("ChildStoreMoneyDlg", self.data)
end

-- 设置抚养标签页
function KidRearingDlg:onPreDlgCheckBox(sender, eventType)
    if "SchedulingPanelCheckBox" == sender:getName() then
        -- 成熟度不满200，无法切换
        if self.data.mature < 200 then
            gf:ShowSmallTips(CHS[4101357])
            return
        end
    end

    return true
end

-- 对话框check
function KidRearingDlg:onDlgCheckBox(sender, eventType)
    self:setCtrlVisible("TakeCarePanel", sender:getName() == "TakeCarePanelCheckBox")
    self:setCtrlVisible("SchedulingPanel", sender:getName() == "SchedulingPanelCheckBox")

    if sender:getName() == "SchedulingPanelCheckBox" then
        self:setLabelText("TextLabel", gf:getServerDate("%Y.%m.%d", gf:getServerTime()), "DateCheckBox_1")
        self:getControl("DateCheckBox_1").openTime = self:getZeroClockTime(gf:getServerTime())
        self:setLabelText("TextLabel", gf:getServerDate("%Y.%m.%d", gf:getServerTime() + 86400), "DateCheckBox_2")
        self:getControl("DateCheckBox_2").openTime = self:getZeroClockTime(gf:getServerTime()) + 60 * 60 * 24
    end

    for k , v in pairs(DLG_CHECKBOX) do
        local checkBox = self:getControl(v)
        if sender:getName() == v then
            self:setCtrlVisible("ChosenLabel_1", true, checkBox)
            self:setCtrlVisible("ChosenLabel_2", true, checkBox)
            self:setCtrlVisible("UnChosenLabel_1", false, checkBox)
            self:setCtrlVisible("UnChosenLabel_2", false, checkBox)
        else
            self:setCtrlVisible("ChosenLabel_1", false, checkBox)
            self:setCtrlVisible("ChosenLabel_2", false, checkBox)
            self:setCtrlVisible("UnChosenLabel_1", true, checkBox)
            self:setCtrlVisible("UnChosenLabel_2", true, checkBox)
        end
    end


    self:onDateCheckBox(self.dateRadioGroup:getSelectedRadio())

    if sender:getName() == "SchedulingPanelCheckBox" then
        self.isFirstShowSchedule = false

        if gf:getServerTime() >= self:getControl("DateCheckBox_1").openTime + 21 * 3600 then
            self.dateRadioGroup:selectRadio(2)
        else
        end
    end

    if not self:isSameDay() then return end
end

function KidRearingDlg:onOperCheckBox(sender, eventType, noDefSelect)
    local key = sender:getName()
    self:setCtrlVisible("TwoOptionPanel", #OPER_CONFIG[key] == 2)
    self:setCtrlVisible("ThreeOptionPanel", #OPER_CONFIG[key] == 3)

    local panelName = #OPER_CONFIG[key] == 2 and "TwoOptionPanel" or "ThreeOptionPanel"
    self:setOptionCirclePanel(OPER_CONFIG[key], panelName, noDefSelect)
end



function KidRearingDlg:onAddSchedulePanel(sender, eventType)

    local panel = self.selectScheduleImage:getParent()
    if not panel then return end    -- 正常不会出现该情况

    local maxTime = self.data.ret.arrangedCount



    -- 检查下已安排的是否已经取消了
    for _, temp in pairs(self.data.ret.todayData) do
        local modifyData = self.modifySchedule["DateCheckBox_1"][_]
        if modifyData and temp.sch_type ~= modifyData.op_type then
            -- 已经安排的行程被修改了
            if temp.sch_type == HomeChildMgr.SCHE_TYPE.NONE then
                maxTime = maxTime + 1
            elseif modifyData.op_type == HomeChildMgr.SCHE_TYPE.NONE then
                maxTime = maxTime - 1
            end
        end
    end

    for _, temp in pairs(self.data.ret.tomorrowData) do
        local modifyData = self.modifySchedule["DateCheckBox_2"][_]
        if modifyData and temp.sch_type ~= modifyData.op_type then
            -- 已经安排的行程被修改了
            if temp.sch_type == HomeChildMgr.SCHE_TYPE.NONE then
                maxTime = maxTime + 1
            elseif modifyData.op_type == HomeChildMgr.SCHE_TYPE.NONE then
                maxTime = maxTime - 1
            end
        end
    end


    if not self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][panel:getTag()] then
        if panel.data.name == CHS[4101358] then
            maxTime = maxTime + 1
        else
            maxTime = maxTime - 1
        end
    end

    if self.data.mature > 500 and maxTime > 100 then
        gf:ShowSmallTips(CHS[4101366])          -- 当前阶段只可进行100次的行程，目前安排次数已达上限。
        return
    end

    --!!!!
--[[
    [LUA-print] DEBUG :
[LUA-print] DEBUG : { order=1, op_type=1, icon=ui/Icon2582.png, desc=迈开小腿走
起来，提升成长度, czd_max=500, template=#Y%s#n迈着小脚丫一步一步地学起了走路，疲
劳度#R+3#n，成长度#G+%s#n, name=学走路, cost=1000000,  }

]]
    local data = self.data

    if HomeChildMgr:getScheduleMax(sender.data.op_type) then
        -- 需要计算最大值
        local completedCount = 0
        if data.special_sch_data[sender.data.op_type] and data.special_sch_data[sender.data.op_type].cur_times then
            completedCount = data.special_sch_data[sender.data.op_type].cur_times
        end
        local arrangeCount = 0
        for i = 1, data.today_sch_count do
            local info = data.today_sch_data[i]
            if info.sch_type == sender.data.op_type and info.isClose ~= 2 then
                arrangeCount = arrangeCount + 1
            end

            -- 个数都一样，明天的一起算
            local info = data.tomorrow_sch_data[i]
            if info.sch_type == sender.data.op_type and info.isClose ~= 2 then
                arrangeCount = arrangeCount + 1
            end
        end

        for _, info in pairs(self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()]) do
            if info.op_type == sender.data.op_type then
                arrangeCount = arrangeCount + 1
            end
        end

    --    Log:D("一共" .. (completedCount + arrangeCount))

        if completedCount + arrangeCount  >= HomeChildMgr:getScheduleMax(sender.data.op_type) then
            gf:ShowSmallTips(CHS[4101483])
            ChatMgr:sendMiscMsg(CHS[4101483])
            return
        end
    end


    if sender.data.op_type == HomeChildMgr.SCHE_TYPE.NONE then
        gf:ShowSmallTips(CHS[4101484])

    end

    if data.health <= 60 and self.tipsCountForHeath < 3 then
        gf:ShowSmallTips(string.format(CHS[4101485], data.name))
        self.tipsCountForHeath = self.tipsCountForHeath + 1
    end

    if data.fatigue >= 60 and self.tipsCountForFatigue < 3 then
        gf:ShowSmallTips(string.format(CHS[4101486], data.name))
        self.tipsCountForFatigue = self.tipsCountForFatigue + 1
    end


    self:modifyDisplaySchedule(sender.data, panel)

    self:setCtrlVisible("ListPanel", false)
end

function KidRearingDlg:modifyDisplaySchedule(data, toPanel)

    if data.op_type == HomeChildMgr.SCHE_TYPE.NONE then
        self:setImagePlist("IconImage", ResMgr.ui.touming, toPanel)
    else
        self:setImage("IconImage", data.icon, toPanel)
    end

    self:setCtrlVisible("NoneIconImage", false, toPanel)

    local tag = toPanel:getTag()
    if not data.op_type then
        self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][tag] = {startTime = toPanel.data.startTime, op_type = HomeChildMgr.SCHE_TYPE.NONE}
        self:setLabelText("NameLabel", CHS[4101358], toPanel)
        self:setCtrlVisible("NoneIconImage", true, toPanel)
        self:setImagePlist("IconImage", ResMgr.ui.touming, toPanel)
    else
        self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][tag] = {startTime = toPanel.data.startTime, op_type = data.op_type}
        self:setLabelText("NameLabel", data.name, toPanel)
    end
end

function KidRearingDlg:onSelectSchedulePanel(sender, eventType)
    self.selectScheduleImage:removeFromParent()

    if sender:getName() == "IconPanel" then
        self.forSelectName = sender:getParent().forSelectName
        sender:getParent():addChild(self.selectScheduleImage)
        self:onSelectSchedulePanelIcon(sender)
    else
        self.forSelectName = sender.forSelectName
        sender:addChild(self.selectScheduleImage)
        local panel = self:getControl("IconPanel", nil, sender)
        self:onSelectSchedulePanelIcon(panel)
    end
end

function KidRearingDlg:getCookies()
    if self.dateRadioGroup:getSelectedRadioIndex() == 1 then
        -- 今天的cookies
        return self.data.today_sch_cookie
    else
        -- 明天的
        return self.data.tomorrow_sch_cookie
    end
end

function KidRearingDlg:onSelectSchedulePanelIcon(sender, eventType)

    local cellPanel = sender:getParent()
   -- self:onSelectSchedulePanel(cellPanel)

    if cellPanel.progressStage == 1 then
        return
    end


    if cellPanel.progressStage == 2 then
        if cellPanel.data.sch_type == HomeChildMgr.SCHE_TYPE.NONE then
            gf:ShowSmallTips(CHS[4101477])   -- 该行程时间已开始，无法安排。
        else
            gf:ShowSmallTips(CHS[4101460])   -- 当前已有行程正在进行中，无法更改。
        end
        return
    end

    if self.data.mature == MATURE_MAX then
        gf:ShowSmallTips(CHS[4101359])  -- 该娃娃成长度已满，无需进行行程安排。
        return
    end

    if self:getCtrlVisible("ModifyButton") then
        gf:ShowSmallTips(CHS[4101360])  -- 该娃娃成长度已满，无需进行行程安排。
         return
    end

    local cmdData = cellPanel.data

    local panel = self:getControl("ListPanel")
    if panel:isVisible() then
        return
    end

    local data = {child_id = self.data.id, start_time = cmdData.startTime, op_type = cmdData.sch_type, cookie = self:getCookies(), para = self.forSelectName}
    gf:CmdToServer("CMD_CHILD_CHECK_SET_SCHEDULE", data)
end

function KidRearingDlg:setToBeSelectSchedule(isAddRemove)
    local selectPanel = self.selectScheduleImage:getParent()
    if not selectPanel then return end

    local list = self:resetListView("ListView", 0, nil, "ListPanel")
    local ret = self:getToBeSelectList(isAddRemove)
    for i = 1, #ret do
        local panel = self.unitPanelForSelect:clone()
        self:setAddCellSchedule(ret[i], panel)
        list:pushBackCustomItem(panel)
    end

    if #ret > 4 then
        list:setContentSize(self.addScheduleListOrgSize)
        self:setCtrlContentSize("BackImage", 390 ,self.addScheduleListOrgSize.height + 21, "ListPanel")
        self:setCtrlContentSize("ListPanel", 390 ,self.addScheduleListOrgSize.height + 21)
    else
        local h = self.unitPanelForSelect:getContentSize().height * 4
        list:setContentSize(self.addScheduleListOrgSize.width, h)
        self:setCtrlContentSize("BackImage", 390 , h + 21, "ListPanel")
        self:setCtrlContentSize("ListPanel", 390 , h + 21)
    end
end

function KidRearingDlg:onDateCheckBox(sender, eventType, isFromServer)

    if not isFromServer then
        self.selectScheduleImage:removeFromParent()
    end
    self:updateScheduleList(sender:getName(), self.isReloadList, isFromServer)
--self.buttonState = {DateCheckBox_1 = false, DateCheckBox_2 = false}   -- 确认行程或者修改行程

    self:updateScheduleButton()
    if not self:isSameDay() then return end
end

function KidRearingDlg:updateScheduleButton()
    local sender = self.dateRadioGroup:getSelectedRadio()
    local isShowConfirm = false
    if sender:getName() == "DateCheckBox_1" then
        if self.data.today_sch_cookie == 0 or self.buttonState.DateCheckBox_1 then
            isShowConfirm = true

        end
    else
        if self.data.tomorrow_sch_cookie == 0 or self.buttonState.DateCheckBox_2 then
            isShowConfirm = true
        end
    end
    self:setCtrlVisible("ModifyButton", not isShowConfirm)
    self:setCtrlVisible("ConfirmButton", isShowConfirm)
end


function KidRearingDlg:setTimeForFy(endTi, panel)
    if not endTi or endTi <= 0 then
        self:setLabelText("TimeLabel1", "", panel)
        self:setLabelText("TimeLabel2", "", panel)
        return
    end

    if endTi < 60 then
        self:setLabelText("TimeLabel1", CHS[4010433], panel)
        self:setLabelText("TimeLabel2", CHS[4010433], panel)
    else
        endTi = math.max(0, endTi)
        local h = math.floor( endTi / 3600 )
        local m = math.floor( (endTi % 3600) / 60 )
        self:setLabelText("TimeLabel1", string.format( "%02d:%02d", h, m), panel)
        self:setLabelText("TimeLabel2", string.format( "%02d:%02d", h, m), panel)
    end
end

-- 设置圆形数据
function KidRearingDlg:setOptionCirclePanel(cfg, panelName, noDefSelect)
    local fyData = self.data.fy_data
    local fPanel = self:getControl(panelName)
    for i = 1, 3 do
        local panel = self:getControl("ChoosePanel" .. i, nil, fPanel)
        if panel and cfg[i] then
            -- 移除定时器
            panel:stopAllActions()

            -- 删除扇形倒计时表现
            local timer = panel:getChildByName("ProgressTimer")
            if timer then timer:removeFromParent() end

            self:setCtrlVisible("CDImage", false, panel)

            -- 设置倒计时为空字符串
            self:setTimeForFy(nil, panel)

            -- 操作名称
            self:setLabelText("NameLabel", cfg[i].chs, panel)

            local info = HomeChildMgr:getFuyangCfg(cfg[i].op_type)
            self:setImage("IconImage", info.icon, panel)

            -- 判断是否需要定时器
            for _, uData in pairs(fyData) do
                if uData.op_type == cfg[i].op_type and gf:getServerTime() < uData.cd_end_time then
                    local leftTime = uData.cd_end_time - gf:getServerTime()
                    local percent = leftTime / (cfg[i].refresh_time * 3600)
                    -- 创建扇形定时器
                    self:createCircleTimer(percent, leftTime, panel)

                    self:setTimeForFy(leftTime, panel)
                    -- 创建label定时显示倒计时，不需要频繁刷新，暂定6s
                    schedule(panel, function ()
                        local leftTime = uData.cd_end_time - gf:getServerTime()
                        self:setTimeForFy(leftTime, panel)
                    end, 6)
                end
            end

            panel.data = cfg[i]
            if i == 1 and not noDefSelect then
                self:onClickCircle(panel)
            end
        end
    end
end

-- 设置具体行为数据
function KidRearingDlg:setOptionInfo(data)
    local panel = self:getControl("OptionInfoPanel")

    -- 功效
    local effPanel = self:getControl("EffectPanel1", nil, panel)
    for i = 1, 2 do
        local idx = (i - 1) * 2 + 1
        self:setLabelText("NameLabel" .. i, data.fun_str[idx] or "", effPanel)
        idx = idx + 1
        self:setLabelText("NumLabel" .. i, data.fun_str[idx] or "", effPanel)
    end

    -- 疲劳
    local effPanel2 = self:getControl("EffectPanel2", nil, panel)
    local cost
    if self.data.mature <= 200 then

        cost = data.cost_200_str
    else

        cost = data.cost_str
    end
    if not cost then cost = {} end
    self:setLabelText("NameLabel", cost[1] or "", effPanel2)
    self:setLabelText("NumLabel", cost[2] or "", effPanel2)

    -- CD
    self:setLabelText("CDLabel", string.format(CHS[4101361], data.refresh_time), panel)

    -- 描述
    self:setLabelText("DescribeLabel", data.desc_str, panel)

    if not data.cost_cash or data.cost_cash == 0 then
        self:setCtrlVisible("MoneyCostPanel", false, panel)
    else
        self:setCtrlVisible("MoneyCostPanel", true, panel)
        local cash, color = gf:getArtFontMoneyDesc(data.cost_cash or 0)
        self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 23, panel)
    end
end

-- 设置抚养标签页
function KidRearingDlg:setTakeCareData(data)

    self:setTakeCareLeftInfo(data)

end

-- 设置抚养标签页左侧信息
function KidRearingDlg:setTakeCareLeftInfo(data)
    local ztPanel = self:getControl("InformationPanel", nil, "TakeCarePanel")       -- 状态Panel
    HomeChildMgr:setChildZT(data, ztPanel, self)
    self:updateBabyMoney()
end

function KidRearingDlg:updateBabyMoney()
    local money = self.data.money
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 23, "TakeCarePanel")
    self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 23, "SchedulingPanel")

    local gender = self.data.gender
    local panel1 = self:getControl("ChildMoneyPanel", nil, "TakeCarePanel")
    self:setLabelText("InfoLabel", gender == GENDER_TYPE.MALE and CHS[4101362] or CHS[4101363], panel1)

    local panel2 = self:getControl("ChildMoneyPanel", nil, "SchedulingPanel")
    self:setLabelText("InfoLabel", gender == GENDER_TYPE.MALE and CHS[4101362] or CHS[4101363], panel2)
end

-- 设置行程界面数据
function KidRearingDlg:setScheduleData(data)
    local zzPanel = self:getControl("InformationPanel", nil, "SchedulingPanel")       -- 资质Panel
    HomeChildMgr:setChildZZ(data, zzPanel, self)
end


-- 设置进度条
function KidRearingDlg:setProgressBarForSelf(name, cur, max, root)
    local bar = self:setProgressBar(name, cur, max, root)
    self:setLabelText("ValueLabel", string.format( "%d/%d", cur, max), root)
    self:setLabelText("ValueLabel2", string.format( "%d/%d", cur, max), root)

    self:setLabelText("ProgressLabel_1", string.format( "%d/%d", cur, max), root)
    self:setLabelText("ProgressLabel_2", string.format( "%d/%d", cur, max), root)
end

function KidRearingDlg:onTakeCareInfoButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true, "TakeCarePanel")
end

function KidRearingDlg:onStartButton(sender, eventType)
    if not self.selectFyData then return end

    if self.selectFyData.op_type == HomeChildMgr.FY_TYPE.WCY then
        local amount = InventoryMgr:getItemByClass(ITEM_CLASS.CAIYAO)
        if #amount <= 0 then
            gf:ShowSmallTips(CHS[4101461])  -- 当前包裹中并无任何居所菜肴。
            return
        end

        local dlg = DlgMgr:openDlg("SubmitMultiItemDlg")
        local data = {child_id = self.data.id, fy_type = self.selectFyData.op_type, fy_para = ""}
        dlg:setDataForWaWaFuY(data)
    else
        gf:CmdToServer("CMD_CHILD_RAISE", {child_id = self.data.id, fy_type = self.selectFyData.op_type, fy_para = ""})
    end
end

function KidRearingDlg:createCircleTimer(percent, leftTime, panel)
    percent = percent * 100

    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(ResMgr.ui.wawa_circle_progressTimer))
    progressTimer:setReverseDirection(true)
    panel:addChild(progressTimer, 3)
    progressTimer:setName("ProgressTimer")

    local size = panel:getContentSize()
    progressTimer:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
   -- progressTimer:setLocalZOrder(15)
    progressTimer:setPercentage(percent)
    local progressTo = cc.ProgressTo:create(leftTime, 0)
    local endAction = cc.CallFunc:create(function()
        progressTimer:removeFromParent()
    end)

    progressTimer:runAction(cc.Sequence:create(progressTo, endAction))
end

function KidRearingDlg:onSchduleInfoButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true, "SchedulingPanel")
end

function KidRearingDlg:isSameDay()
        -- 如果开启和设置不是同一天，则请求数据
    if not gf:isSameDay(self.refreashTime, gf:getServerTime()) then
        gf:ShowSmallTips(CHS[4101458])
        self.refreashTime = gf:getServerTime()
        gf:CmdToServer("CMD_CHILD_REQUEST_RAISE_INFO", {child_id = self.data.id, type = 1})
        gf:frozenScreen(3000)

        self:onDlgCheckBox(self:getControl("SchedulingPanelCheckBox"))
        self.dateRadioGroup:selectRadio(1)
        self.modifySchedule["DateCheckBox_1"] = self.modifySchedule["DateCheckBox_2"]
        self.modifySchedule["DateCheckBox_2"] = {}

        self.buttonState["DateCheckBox_1"] = self.buttonState["DateCheckBox_2"]
        self.buttonState["DateCheckBox_2"] = {}

        self:setListJumpItem(0)
        return false
    end

    return true
end

function KidRearingDlg:onConfirmButton(sender, eventType)


    if not self:isSameDay() then return end


--    self:checkServerDara(self.data)

    local id = self.data.id
    local cookie = self:getCookies()
    local count = 0
    local data = {child_id = id, cookie = cookie}
    local tips = ""
    for _, info in pairs(self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()]) do

        if gf:getServerTime() >= info.startTime then
            tips = CHS[4101459]-- "部分行程已开始进行，无法修改。"
            self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][_] = nil
        else
            count = count + 1
            data[count] = {}
            data[count].startTime = info.startTime
            data[count].sch_type = info.op_type
        end
    end
    data.count = count

    if tips ~= "" then
        gf:ShowSmallTips(tips)
        self:onDateCheckBox(self.dateRadioGroup:getSelectedRadio(), nil, true)
        return
    end

    if count == 0 then
        data.time = self.dateRadioGroup:getSelectedRadio().openTime
    else
        data.time = 0
    end

    gf:CmdToServer("CMD_CHILD_SET_SCHEDULE_LIST", data)
--    self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()] = {}
end

function KidRearingDlg:onModifyButton(sender, eventType)
    if not self:isSameDay() then return end
    local radio = self.dateRadioGroup:getSelectedRadio()
    local radioTime = radio.openTime
    local cookie = radio:getName() == "DateCheckBox_1" and self.data.today_sch_cookie or self.data.tomorrow_sch_cookie

    local data = {child_id = self.data.id, record_time = radioTime, cookie = cookie}
    gf:CmdToServer("CMD_CHILD_CHECK_CHANGE_SCHEDULE", data)
end

function KidRearingDlg:onHistoryButton(sender, eventType)
    gf:CmdToServer("CMD_CHILD_REQUEST_SCHEDULE", {child_id = self.data.id})
end


function KidRearingDlg:onIllPanel(sender, eventType)
    gf:showTipInfo(CHS[4010434], sender)
end


function KidRearingDlg:onSelectListView(sender, eventType)
end

-- czd 成长度
-- isRemove 是否需要移除项
function KidRearingDlg:getToBeSelectList(isRemove)
    local ret = {}
    local mature = self.data.mature
    for _, info in pairs(SCHEDULE_INFO) do
        info.op_type = _
        if info.czd_mix and mature >= info.czd_mix then
            table.insert( ret, info )
        end

        if info.czd_max and mature < info.czd_max then
            table.insert( ret, info )
        end
    end

    table.sort( ret, function(l, r)
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    if isRemove then
        table.insert( ret, {name = CHS[4101364], desc = CHS[4101365], cost = 0} )
    end

    return ret
end

function KidRearingDlg:MSG_CHILD_CHECK_SCHEDULE_RESULT(data)
    if data.para ~= self.forSelectName then return end
    if data.result ~= 1 then return end

    local cellPanel
    local list = self:getControl("ListView", nil, "SchedulingChosePanel")
    local items = list:getItems()
    for i = 1, #items do
        local panel = items[i]
        local lPanel = self:getControl("LeftPanel", nil, panel)
        if self.forSelectName == lPanel.forSelectName then
            cellPanel = lPanel
        end

        local rPanel = self:getControl("RightPanel", nil, panel)
        if self.forSelectName == rPanel.forSelectName then
            cellPanel = rPanel
        end
    end
    if not cellPanel then return end

--[[
        gf:PrintMap(cellPanel.data)
    [LUA-print] DEBUG : { startTime=1552089600, showDesc=, timeStr=08点00分~59分, na
    me=未安排, sch_type=0,  }
]]

    local panel = self:getControl("ListPanel")
    local isLeft = string.match(cellPanel:getName(), "Left") and true or false
    if isLeft then
        panel:setPositionX(LIST_PANEL_POS_X["right"])
    else
        panel:setPositionX(LIST_PANEL_POS_X["left"])
    end
    panel:setVisible(true)

    local isAddRemove = cellPanel.data.sch_type ~= HomeChildMgr.SCHE_TYPE.NONE or (self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][cellPanel:getTag()] and self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][cellPanel:getTag()].op_type ~= HomeChildMgr.SCHE_TYPE.NONE)
    self:setToBeSelectSchedule(isAddRemove)
end

function KidRearingDlg:checkServerDara(data)
    -- 还要串改服务器的数据
    for i = 1, 12 do
        if data.today_sch_data[i].start_time > gf:getServerTime() and data.mature >= 500 then
            if data.today_sch_data[i].sch_type > HomeChildMgr.SCHE_TYPE.NONE and data.today_sch_data[i].sch_type <= HomeChildMgr.SCHE_TYPE.TGY then
                local info = self.modifySchedule.DateCheckBox_1[i]
                if info and (info.op_type > HomeChildMgr.SCHE_TYPE.NONE and info.op_type <= HomeChildMgr.SCHE_TYPE.TGY) then
                    self.modifySchedule.DateCheckBox_1[i] = {startTime = data.today_sch_data[i].start_time, op_type = HomeChildMgr.SCHE_TYPE.NONE}
                end
            end
        end

        if data.tomorrow_sch_data[i].start_time > gf:getServerTime() and data.mature >= 500 then
            if data.tomorrow_sch_data[i].sch_type > HomeChildMgr.SCHE_TYPE.NONE and data.today_sch_data[i].sch_type <= HomeChildMgr.SCHE_TYPE.TGY then
                local info = self.modifySchedule.DateCheckBox_2[i]
                if info and (info.op_type > HomeChildMgr.SCHE_TYPE.NONE and info.op_type <= HomeChildMgr.SCHE_TYPE.TGY) then
                    self.modifySchedule.DateCheckBox_2[i] = {startTime = data.tomorrow_sch_data[i].start_time, op_type = HomeChildMgr.SCHE_TYPE.NONE}
                end
            end
        end
    end
end

function KidRearingDlg:MSG_CHILD_RAISE_INFO(data)
    gf:unfrozenScreen()

    if self.data.today_sch_cookie ~= data.today_sch_cookie then
        self.buttonState.DateCheckBox_1 = false-- = {DateCheckBox_1 = false, DateCheckBox_2 = false}   -- 确认行程或者修改行程
    end

    if self.data.tomorrow_sch_cookie ~= data.tomorrow_sch_cookie then
        self.buttonState.DateCheckBox_2 = false-- = {DateCheckBox_1 = false, DateCheckBox_2 = false}   -- 确认行程或者修改行程
    end

    -- 检测是否满足行程
    if data.mature >= 500 then
    --self.modifySchedule[self.dateRadioGroup:getSelectedRadioName()][tag] = {startTime = toPanel.data.startTime, op_type = HomeChildMgr.SCHE_TYPE.NONE}
        for _, info in pairs(self.modifySchedule.DateCheckBox_1) do
            if info.op_type ~= HomeChildMgr.SCHE_TYPE.NONE and info.op_type <= HomeChildMgr.SCHE_TYPE.TGY then
                self.modifySchedule.DateCheckBox_1[_] = nil
            end
        end

        for _, info in pairs(self.modifySchedule.DateCheckBox_2) do
            if info.op_type ~= HomeChildMgr.SCHE_TYPE.NONE and info.op_type <= HomeChildMgr.SCHE_TYPE.TGY then
                self.modifySchedule.DateCheckBox_2[_] = nil
            end
        end


    end

    -- 检测服务器行程是否合法，不合法替换成
    if data.para == "check" then
        self:checkServerDara(data)
    end

    self.data = data

    if data.update_time > 1 then

        if self:getControl("DateCheckBox_1").openTime == data.update_time then
            self.modifySchedule.DateCheckBox_1 = {}
        end

        if self:getControl("DateCheckBox_2").openTime == data.update_time then
            self.modifySchedule.DateCheckBox_2 = {}
        end


    end



    self:updateScheduleButton()
    self:setTakeCareData(data)
    self:setScheduleData(data)
    self:onDateCheckBox(self.dateRadioGroup:getSelectedRadio(), nil, true)
    self:onOperCheckBox(self.opRadioGroup:getSelectedRadio(), nil, true)
end

function KidRearingDlg:getZeroClockTime(ti)
    local y = tonumber(os.date("%Y", ti))
    local m = tonumber(os.date("%m", ti))
    local d = tonumber(os.date("%d", ti))
    local bt = os.time({ year = y, month = m, day = d, hour = 0, min = 0, sec = 0 })
    return bt
end


function KidRearingDlg:MSG_CHILD_CHECK_CHANGE_SCHEDULE_RET(data)
    if data.id ~= self.data.id then return end
    if data.isCanModify ~= 1 then return end

    for _, ctrlName in pairs(DATE_CHECKBOX) do
        local ctrl = self:getControl(ctrlName)
        if ctrl.openTime == data.record_time then
            self.buttonState[ctrlName] = true
        end
    end

    -- 更新按钮状态
    local radio = self.dateRadioGroup:getSelectedRadio()
    if data.record_time == radio.openTime then
        self:updateScheduleButton()
    end
end

function KidRearingDlg:MSG_CHILD_SCHEDULE(data)
    if data.id ~= self.data.id then return end
    local dlg = DlgMgr:openDlgEx("KidScheduleRecordDlg")
    dlg:setData(data, SCHEDULE_INFO)
end

function KidRearingDlg:updateMoney(data)
    if data.id == self.data.id then
        self.data.money = data.money
        self:updateBabyMoney()
    end
end

function KidRearingDlg:bindFloatingEvent(crtlName, root)
    local panel = self:getControl(crtlName, nil, root)
    if not panel then
        return
    end

    panel:setVisible(false)
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        --Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        if not panel:isVisible() then
            return false
        end

        return true
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local box = panel:getBoundingBox()
        if panel:isVisible() then
            performWithDelay(self.root, function ()
                panel:setVisible(false)
            end)
        end
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 跳转listView当前最后一个显示的item为指定index的item
function KidRearingDlg:setListJumpItem(index)
    local listView = self:getControl("ListView", nil, "SchedulingChosePanel")
    index = math.max( 1, index)

    if self.isFirstShowSchedule then
        performWithDelay(listView, function ()
            -- 长度固定，直接写死好了，就不用管延迟或者七七八八的
            local positionY = -200 + (index - 1) * 95
            positionY = math.min(positionY, 0)

            local innerContainer = listView:getInnerContainer()
            innerContainer:setPositionY(positionY)
        end, 0.01)
    else
        -- 长度固定，直接写死好了，就不用管延迟或者七七八八的
        local positionY = -200 + (index - 1) * 95
        positionY = math.min(positionY, 0)

        local innerContainer = listView:getInnerContainer()
        innerContainer:setPositionY(positionY)
    end
end


return KidRearingDlg
