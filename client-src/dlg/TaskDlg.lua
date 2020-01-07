-- TaskDlg.lua
-- Created by cheny Dec/05/2014
-- 任务信息界面

local TaskDlg = Singleton("TaskDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")
local ITEM_MARGIN = 7
local ITEM_HEIGHT = 49
local TEXT_MARGIN = 10
local TASK_CAN_DROP_ONLY_IN_CLIENT = {
    [CHS[7002219]] = true,
}

-- 放弃任务特殊提示语
local FANGQI_TIPS = {
    [CHS[4100959]] = CHS[4100963],
    [CHS[7120201]] = CHS[7120210],
}

function TaskDlg:init()
    self:bindListener("CancleButton", self.onFangqirenwuButton)
    self:bindListener("ForwardButton", self.onLijiqianwangButton)
    self:bindListener("HideButton", self.onHideCheckBox)

    self:hookMsg("MSG_TASK_PROMPT")

    self.tempItem = self:getControl("SingleTaskPanel", Const.UIPanel)
    self.tempItem:retain()
    self.tempItem:removeFromParent()
    self.listView = self:getControl("TaskListView", Const.UIListView)

    TaskMgr:tryToRefreshAllTask()
    self:initMissionList()
end

function TaskDlg:cleanup()
    self:releaseCloneCtrl("tempItem")
    self.currentTask = nil
    self.tip = nil
end

function TaskDlg:initTaskInfo()
    self:setCtrlVisible("DescribeInfoLabel", false)
    self:setCtrlVisible("CurrentlyNoteInfoLabel", false)
    self:setCtrlVisible("CancleButton", false)
    self:setTip("DescribeInfoPanel", "")
    self:setTip("CurrentlyNoteInfoPanel", "")
    self:updateLayout("DescribeInfoPanel")

    self.currentTask = nil
end

function TaskDlg:initMissionList()
    local list, size = self:resetListView("TaskListView", ITEM_MARGIN)
    list:removeAllItems()
    self.missionListSize = size
    local tasks = {}
    for name,task in pairs(TaskMgr.tasks) do
        if TaskMgr.hiddenTasks[task.task_type] then
            task.isHide = 1
        else
            task.isHide = 0
        end
        table.insert(tasks, task)
    end

    if #tasks == 0 then return end

    table.sort(tasks, function(l, r)
        if l.isHide < r.isHide then return true end
        if l.isHide > r.isHide then return false end
        if l.taskType < r.taskType then return true end
        if l.taskType > r.taskType then return false end
        if l.timeTemp > r.timeTemp then return true end
        if l.timeTemp < r.timeTemp then return false end
    end)

    local firstItem = nil
    local firstTask = nil
    for k, v in pairs(tasks) do
        -- 增加项
        local item = self:createTaskItem(v)
        list:pushBackCustomItem(item)
        if firstTask == nil and firstItem == nil then
            firstItem = item
            firstTask = v
        end

        if self.selcetTaskType == v["task_type"] then
            firstItem = item
            firstTask = v
        end
    end

    self.tempItem:removeFromParent()

    if firstTask ~= nil and firstItem ~= nil then
        self:procItem(firstItem, firstTask)
    else
        self:initTaskInfo()
    end
end

function TaskDlg:chooseTaskItemByTask(task)
    local list = self:getControl("TaskListView", Const.UIListView)
    local items = list:getItems()
    for i, panel in pairs(items) do
        if task.task_type == panel:getName() then
            self:procItem(panel, task, true)
        end
    end
end

function TaskDlg:createTaskItem(task)
    -- 可点击的按钮
    local newTaskItem = self.tempItem:clone()
    newTaskItem:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local taskInfo = TaskMgr:getTaskByName(sender:getName())
            if taskInfo then
                -- WDSY-24216通天塔任务数据可能在界面已经打开情况下被更新，所以优先用管理器中的任务数据
                self:procItem(newTaskItem, taskInfo, true)
            else
                self:procItem(newTaskItem, task, true)
            end
        end
    end)

    newTaskItem:setName(task.task_type)
    local taskName = self:getControl("TaskLabel", Const.UILabel, newTaskItem)
    taskName:setText(task.show_name)

    if TaskMgr.hiddenTasks[task.task_type] then
        self:setCtrlVisible("HideImage", true, newTaskItem)
    else
        self:setCtrlVisible("HideImage", false, newTaskItem)
    end

    return newTaskItem
end

function TaskDlg:cancelSelect()
    local list = self:getControl("TaskListView", Const.UIListView)
    local items = list:getItems()
    for _, v in pairs(items) do
        v:setColor(COLOR3.YELLOW)
    end
end

function TaskDlg:procItem(item, task, refresh)
    if not task or not item then return end

    if self.lastSelectTaskType ~= task["task_type"] then
        -- 如果是同一个任务的状态刷新，则不清掉self.tip保存的数据；否则清除
        self.tip = nil
    end

    self.lastSelectTaskType = task["task_type"]

    if refresh then
        TaskMgr:tryToRefreshTask(task["task_type"])
    end

    -- 如果task_prompt中有 "TIME_LEFT"，则需要一直刷新
    local str = ""
    local descStr = ""
    local timeTemp = gfGetTickCount()
    item:stopAllActions()

    if string.match(task.task_prompt, "TIME_LEFT") or string.match(task.task_desc, "TIME_LEFT") then
        local leftTime = TaskMgr:getTaskTimeStr(task)
        str = string.gsub(task.task_prompt, "TIME_LEFT", leftTime)

        local leftTime = TaskMgr:getTaskTimeStr(task, true)
        descStr = string.gsub(task.task_desc, "TIME_LEFT", leftTime)

        performWithDelay(item, function ()
            if self.currentTask and self.currentTask.task_type == task.task_type then
                self:procItem(item, task)
            end

        end, TaskMgr:getTaskDelayTime(task))
    else
        str = task.task_prompt
        descStr = task.task_desc
    end

    if task.attrib:isSet(TASK.TASK_ATTRIB_DESC_APPEND_LOG) then
        descStr = descStr .. "\n" .. str .. "。"
    end


    -- 显示选中特效
    local items = self.listView:getItems()

    for _, v in pairs(items) do
        self:setCtrlVisible("ChosenEffectImage", false, v)
    end

    self:setCtrlVisible("ChosenEffectImage", true, item)

    if not TaskMgr.hiddenTasks or not next(TaskMgr.hiddenTasks) then
        TaskMgr:loadHideTask()
    end

    if TaskMgr.hiddenTasks[task.task_type] then
        TaskDlg:setHideButton(true)
        self:setCtrlVisible("HideImage", true, item)
    else
        TaskDlg:setHideButton(false)
        self:setCtrlVisible("HideImage", false, item)
    end

    -- 设置任务提示
    self:setCtrlVisible("CancleButton", task.attrib:isSet(TASK.ATTRIB_DROP_FLAG))

    -- 有些任务服务器发送的任务属性是不可放弃的，但客户端需要显示放弃按钮供玩家点击（不可直接放弃），
    -- 点击后可执行相关操作（例如寻路到某个NPC处执行放弃任务的逻辑等）
    if task.task_type and TASK_CAN_DROP_ONLY_IN_CLIENT[task.task_type] then
        self:setCtrlVisible("CancleButton", true)
    end

    self:setTip("DescribeInfoPanel", descStr)
    self:setTip("CurrentlyNoteInfoPanel", str)
    self:updateLayout("DescribeInfoPanel")
    self:updateLayout("CurrentlyNoteInfoPanel")

    self.currentTask = task

    self:setCtrlVisible("BonusScrollView", false)
    self:setCtrlVisible("BonusPanel", false)

    -- 测试WDSY-26705,变身卡开启下面代码，测试变身卡，还需要点击变身卡任务
    -- task.reward = "#T啊哈哈#T#C变身效果#C#B抗遗忘 +8%#n、#B抗法术 +4%#n、#B抗木 +5%#n、#B抗水 +5%#n、#B抗火 +4%#n、#B物理连击率 +16%#n、#B物理连击数 +2#n、#B气血 +5%#n、#B物伤 +7%#n#C阵法效果#C#B物伤"

    --  测试WDSY-26705，普通一个任务
    -- task.reward = "#T呀哈哈#T#I经验|人物经验宠物经验#I#I潜能|潜能#I#I代金券|代金券#I"
    local rewardsTitle, rewardContent = string.match(task.reward, "#T(.+)#T(.+)")

    if rewardsTitle then
        rewardContent = rewardContent
    else
        rewardContent = task.reward
    end



    -- 显示任务奖励还是附加效果
    if task.attrib:isSet(TASK.TASK_ATTRIB_ATTACH_EFFECT) then
        self:setLabelText("BonusTitleLabel_1", rewardsTitle or CHS[4200459])
        self:setLabelText("BonusTitleLabel_2", rewardsTitle or CHS[4200459])

        self:setCtrlVisible("BonusScrollView", true)
        local innerLayer = self:getControl("ScrollPanel")
        local scroview = self:getControl("BonusScrollView")
        innerLayer:setContentSize(scroview:getContentSize())
        if #gf:split(rewardContent, "、") == 1 then
            -- 如果分隔符处理完，只有1个时，则显示在ScrolLPanel
            local str = ""
            if string.match(rewardContent, "#C") then
                -- 有#C的需要换行、缩进
                str = self:parseReward(rewardContent)
            else
                -- 没有#c的缩进，不然  任务美味佳肴，一个属性和两个属性表现不一致
                str = "    " .. rewardContent
            end

            self:setColorText(str, "ScrollPanel")
            local h1 = self:setColorText("", "LeftPanel")
            local h2 = self:setColorText("", "RightPanel")
        else
            local left, right = self:parseReward(rewardContent)
            local h1 = self:setColorText(left, "LeftPanel")
            local h2 = self:setColorText(right, "RightPanel")
            self:setColorText("", "ScrollPanel")


            innerLayer:setContentSize(scroview:getContentSize().width, math.max(h1, h2, scroview:getContentSize().height))
        end

        local scroview = self:getControl("BonusScrollView")
        scroview:setDirection(ccui.ScrollViewDir.vertical)
        scroview:setInnerContainerSize(innerLayer:getContentSize())
        scroview:setTouchEnabled(true)
        scroview:requestDoLayout()
    else
        self:setCtrlVisible("BonusPanel", true)
        self:setLabelText("BonusTitleLabel_1", rewardsTitle or CHS[4200460])
        self:setLabelText("BonusTitleLabel_2", rewardsTitle or CHS[4200460])

        local rewardPanel = self:getControl("BonusPanel", Const.UIPanel)
        rewardPanel:removeAllChildren()
        local rewardStr = rewardContent == "" and CHS[5000059] or rewardContent
        local rewardContainer  = RewardContainer.new(rewardStr, rewardPanel:getContentSize())
        rewardPanel:addChild(rewardContainer)
    end

    -- 隐藏点击无响应信息的“前往”按钮
    local textCtrl = CGAColorTextList:create()
    textCtrl:setString(task.task_prompt)
    local csType = textCtrl:getCsType()
    if csType == CONST_DATA.CS_TYPE_ZOOM
        or csType == CONST_DATA.CS_TYPE_NPC
        or csType == CONST_DATA.CS_TYPE_CARD
        or csType == CONST_DATA.CS_TYPE_TEAM
        or csType == CONST_DATA.CS_TYPE_CALL
        or csType == CONST_DATA.CS_TYPE_DLG then
        self:setCtrlVisible("ForwardButton", true)
    else
        self:setCtrlVisible("ForwardButton", false)
    end

    if task["task_type"] == CHS[4101491] or
        task["task_type"] == CHS[4101490] or
        task["task_type"] == CHS[4101493] or
        task["task_type"] == CHS[4101492] then
            self:setCtrlVisible("ForwardButton", true)
    end

    self.selcetTaskType = task["task_type"]
end

-- 显示字符串
function TaskDlg:setColorText(str, panelName)
    local marginX = 0
    local marginY = 0
    local root = self.root
    local fontSize = 20
    local defColor =  COLOR3.TEXT_DEFAULT

    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    panel:removeChildByName("CGAColorTextList")

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width - 2 * marginX, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)

    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()

    textCtrl:setPosition(marginX, panel:getContentSize().height)

    local textPanel = tolua.cast(textCtrl, "cc.LayerColor")
    textPanel:setName("CGAColorTextList")
    panel:addChild(textPanel)
    local panelHeight = textH + 2 * marginY
   -- panel:setContentSize(size.width, panelHeight)
    return panelHeight, size.height
end


function TaskDlg:parseReward(reward)
    if string.match(reward, "#C") then
        local strTab = gf:split(reward, "#C")
        local titleTab = {}
        local contentTab = {}
        local title
        for i = 1, #strTab do
            if i % 2 == 0 then
                table.insert(titleTab, strTab[i])
                title = strTab[i]
            else
                if title and not contentTab[title] then
                    contentTab[title] = {}
                end
                if contentTab[title] then
                    table.insert(contentTab[title], strTab[i])
                end
            end
        end

        local retLeft = ""
        local retRight = ""
        for i, title in pairs(titleTab) do
            -- 把标题插入左右两边，右边为 "#C#C"
            if retLeft ~= "" then retLeft = retLeft .. "\n" end
            if retRight ~= "" then retRight = retRight .. "\n" end

            retLeft = retLeft .. title
            if i > 1 then
                retRight = retRight .. "\n"
            else
                retRight = retRight
            end

            local content = contentTab[title][1]
            local attribTab = gf:split(content, "、")
            for i, attStr in pairs(attribTab) do
                if i % 2 == 1 then
                    retLeft = retLeft .. "\n    " .. attStr
                else
                    retRight = retRight .. "\n" .. attStr
                end
            end

            -- 单数，右边的需要填充一个
            if #attribTab % 2 == 1 then
                retRight = retRight .. "\n"
            end
        end

        return retLeft, retRight
    else
        local retLeft = ""
        local retRight = ""
        local attribTab = gf:split(reward, "、")
        for i, attStr in pairs(attribTab) do
            if i % 2 == 1 then

                if retLeft ~= "" then
                    retLeft = retLeft .. "\n    " .. attStr
                else
                    retLeft = "    " .. attStr
                end


            else
                if retRight ~= "" then
                    retRight = retRight .. "\n" .. attStr
                else
                    retRight = attStr
                end
            end
        end

        -- 单数，右边的需要填充一个
        if #attribTab % 2 == 1 then
            retRight = retRight .. "\n"
        end

        return retLeft, retRight
    end
end

function TaskDlg:setHideButton(isHide)
    if isHide then
        self:setLabelText("OpenLabel1", CHS[4200461])
        self:setLabelText("OpenLabel2", CHS[4200461])
    else
        self:setLabelText("OpenLabel1", CHS[4200462])
        self:setLabelText("OpenLabel2", CHS[4200462])
    end
end

function TaskDlg:setTip(panelName, info)
    if not self.tip then
        self.tip = {}
    end

    if self.tip[panelName] then
        -- 不需要每次都重新创建CGAColorTextList，如果是同一个任务界面的状态刷新，则直接setString即可
        self.tip[panelName]:setString(info)
        self.tip[panelName]:updateNow()
        return
    end

    local panel = self:getControl(panelName)
    local size = panel:getContentSize()
    panel:removeAllChildren()

    self.tip[panelName] = CGAColorTextList:create()
    local tip = self.tip[panelName]

    if tip.setPunctTypesetting then
        tip:setPunctTypesetting(true)
    end
    tip:setFontSize(21)
    tip:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    tip:setContentSize(size.width - TEXT_MARGIN * 2, 0)
    tip:setString(info)
    tip:updateNow()
    local w, h = tip:getRealSize()
    tip = tolua.cast(tip, "cc.LayerColor")
    tip:setPosition(TEXT_MARGIN, h)
    --panel:addChild(tip)


    local contentLayer = ccui.Layout:create()
    contentLayer:setContentSize(size.width, tip:getContentSize().height)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(size)
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)

    if h < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - h)
    end
    contentLayer:addChild(tip)
    panel:addChild(scroview)
end

function TaskDlg:onFangqirenwuButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003719])
        return
    end

    if self.currentTask  then
        local taskInfo = TaskMgr:getTaskInfo(self.currentTask.task_type)
        local removeTip = ""
        if taskInfo and taskInfo.removeInfo then
            removeTip = taskInfo.removeInfo
        else
            if self.currentTask.task_type == CHS[3003720] then
                removeTip = CHS[3003721]
            else
                removeTip = string.format(CHS[3003722], self.currentTask.show_name or self.currentTask.task_type)
            end
        end

        local curTask = self.currentTask -- 缓存变量，服务器延时返回或进入战斗都会导致self.currentTask被清空
        if self.currentTask.task_type == CHS[3003723] then -- 通天塔
            gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
        elseif self.currentTask.task_type == CHS[4200387] then -- 法宝任务
            gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
        elseif self.currentTask.task_type == CHS[4200010] then -- 千变万化
            gf:confirm(CHS[4200011], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[4300010] then  -- 南荒巫术
            gf:confirm(CHS[4300012], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[4200094] then
            gf:confirm(CHS[4200095], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = self.currentTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[6400046] then  -- 强帮之道
            gf:confirm(CHS[5410019], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[2200039] then  -- 萝卜桃子大收集
            gf:confirm(CHS[5410033], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[7002219] then -- 结拜任务
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7003047]))
        elseif self.currentTask.task_type == CHS[4200364] then  -- 宠物飞升
            gf:confirm(CHS[4200363], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[4200383] then  -- 九曲玲珑变身
            gf:confirm(CHS[4200384], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[4200445] then  -- 美味佳肴
            gf:confirm(CHS[2000407], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif self.currentTask.task_type == CHS[4100728] then  -- 【居所】材料收集
            local fetchTime = tonumber(self.currentTask.task_extra_para) or 0
            local tips = CHS[4100731]   -- 你今日已经领取过【居所】材料收集任务，放弃任务今日将无法再次领取，是否确认？
            if not gf:isSameDay5(gf:getServerTime(), fetchTime) then
                tips = CHS[4200444] -- 你今日还未领取过【居所】材料收集任务，放弃任务后仍可#R重新领取#n，是否确认？",
            end
            gf:confirm(tips, function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        elseif string.match(self.currentTask.task_type, CHS[7190254]) then  -- 探案
            if MapMgr:isInTanAnMxza() then
                gf:ShowSmallTips(CHS[7190295])
                return
            end

            gf:confirm(CHS[7190281], function()
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end)
        else
            --  放弃任务特殊提示语可以放 FANGQI_TIPS 表中，by songcw
            if FANGQI_TIPS[self.currentTask.task_type] or not string.isNilOrEmpty(removeTip) then
                gf:confirm(FANGQI_TIPS[self.currentTask.task_type] or removeTip, function()
                    gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
                end)
            else
                gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.DROP_TASK, para1 = curTask.task_type, para2=''})
            end
        end

    end
end

function TaskDlg:onHideCheckBox(sender, eventType)
    if nil == self.currentTask then return end



    if self:getLabelText("OpenLabel1") == "显示任务" then
        TaskDlg:setHideButton(false)
        TaskMgr.hiddenTasks[self.currentTask.task_type] = nil
        TaskMgr:setTheFitstDisplayTask(self.currentTask.task_type)
        DlgMgr:sendMsg("MissionDlg", "MSG_TASK_PROMPT")
    else
        TaskDlg:setHideButton(true)
        TaskMgr.hiddenTasks[self.currentTask.task_type] = self.currentTask.task_prompt
        DlgMgr:sendMsg("MissionDlg", "removeTask", self.currentTask)
        gf:ShowSmallTips(CHS[4300060])
    end

    TaskMgr:saveHideTask()

    local list = self:getControl("TaskListView")
    local items = list:getItems()
    for i, panel in pairs(items) do
        if panel:getName() == self.currentTask.task_type then
            self:setCtrlVisible("HideImage", self:getLabelText("OpenLabel1") == "显示任务", panel)
        end
    end
--[[
    performWithDelay(self.root, function ()
        if sender:getSelectedState() then
            TaskMgr.hiddenTasks[self.currentTask.task_type] = self.currentTask.task_prompt
            DlgMgr:sendMsg("MissionDlg", "removeTask", self.currentTask)
            gf:ShowSmallTips(CHS[4300060])
        else
            TaskMgr.hiddenTasks[self.currentTask.task_type] = nil
            TaskMgr:setTheFitstDisplayTask(self.currentTask.task_type)
            DlgMgr:sendMsg("MissionDlg", "MSG_TASK_PROMPT")
        end

        TaskMgr:saveHideTask()

        local list = self:getControl("TaskListView")
        local items = list:getItems()
        for i, panel in pairs(items) do
            if panel:getName() == self.currentTask.task_type then
                self:setCtrlVisible("HideImage", sender:getSelectedState(), panel)
            end
        end
    end, 0)
    --]]
end

function TaskDlg:onLijiqianwangButton(sender, eventType)
    if nil == self.currentTask then return end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003724])
        return
    elseif Me:isLookOn() then
        gf:ShowSmallTips(CHS[3003725])
        return
    end

    local task = self.currentTask

    local function func()
        -- 点击后关闭任务界面
        local textCtrl = CGAColorTextList:create()
        textCtrl:setString(self.currentTask.task_prompt)

        local csType = textCtrl:getCsType()
        if csType == CONST_DATA.CS_TYPE_DLG or csType == CONST_DATA.CS_TYPE_CALL then
            gf:onCGAColorText(textCtrl, sender)
            DlgMgr:closeDlg(self.name)
        else
            local ret = TaskMgr:checkCanGotoTask(textCtrl, self.currentTask)
            if ret.result then
                local newData = PartyWarMgr:getNewPartyWarData()
                -- 安全区处理
                if GameMgr:isInPartyWar() and newData and newData.is_security == 0 then
                    gf:ShowSmallTips(CHS[4100780])
                else
                    -- 验证通过
                    local beidouNpc = CharMgr:getCharByName(CHS[4200636])
                    if MapMgr:isInMapByName(CHS[4010293]) and beidouNpc and not beidouNpc.visible and CharMgr:getCharByName(CHS[4010302]) then
                        -- 通天塔神秘房间变戏法该条件下特殊处理
                        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4200637]))
                    else
                        AutoWalkMgr:setNextDest(ret.autoWalkInfo)
                end
            end
            end

            StateShudMgr:tryChangeToShuad(self.currentTask.task_type)

            if not ret.notCloseTaskDlg then
                DlgMgr:closeDlg(self.name)
            end
        end
    end

    if (CHS[7002289] == task.task_type or CHS[7002290] == task.task_type)  --  地劫第九劫/地劫第十劫
        and "$1" == gf:findDest(task.task_prompt).action
        and PracticeMgr:getIsUseExorcism() then
        gf:confirm(CHS[3003133], function()
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
            func()
        end, function()
            func()
        end)

        return
    end

    func()
end

function TaskDlg:MSG_TASK_PROMPT(data)
    local task = data[1]
    local list = self:getControl("TaskListView", Const.UIListView)
    local items = list:getItems()
    local isReset = false
    for i, panel in pairs(items) do
        if task.task_type == panel:getName() and string.len(task.task_prompt) ~= 0 then
            isReset = true
            if self.selcetTaskType == task["task_type"] then
                self:procItem(panel, task)
            end
        end
    end

    if not isReset then
        TaskMgr:tryToRefreshAllTask()
        self:initMissionList()
    end
end

return TaskDlg
