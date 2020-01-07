-- TaskCardDlg.lua
-- Created by zhengjh Mar/12/2015
-- 任务名片

local TaskCardDlg = Singleton("TaskCardDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function TaskCardDlg:init()
    self:bindListener("TaskCardDlg", self.onCloseButton)
    self:align(ccui.RelativeAlign.centerInParent )
    self.keyStr = nil

    local mainPanel = self:getControl("MainPanel")
    self.mainContnetSize = mainPanel:getContentSize()
    local taskIntrducePanel = self:getControl("TaskIntrducePanel")
    self.IntrducePanelContentSize = taskIntrducePanel:getContentSize()
    local taskDescPanel = self:getControl("TaskDescWordsPanel", Const.UIPanel)
    self.taskDescPanelContentSize = taskDescPanel:getContentSize()
end

-- task_type 任务标题
-- task_desc 任务介绍
-- task_prompt   当前提示
-- reward 任务奖励
-- 任务标题一定要有，其他三个字段没有默认到配表去取
-- keyStr 求助的字符串
function TaskCardDlg:setData(task, keyStr)
    self:bindListener("TaskCardDlg", self.onCloseButton)
    self:bindListener("HelpButton", self.onHelpButton)

    -- 任务标题
    local nameLabel = self:getControl("NameLabel", Const.UILabel)
    nameLabel:setString(task["show_name"])

    -- 任务介绍
    local taskDescPanel = self:getControl("TaskDescWordsPanel", Const.UIPanel)
    local rawHeight = self.taskDescPanelContentSize.height

    local desc = self:getTask(task, "task_desc")
    if desc and string.match(desc, "TIME_LEFT") then
        local leftTime = TaskMgr:getTaskTimeStr(task, true)
        desc = string.gsub(desc, "TIME_LEFT", leftTime)
    end

    self:setTaskText(taskDescPanel, desc)

    -- 自动调整任务介绍大小
    local offSet = taskDescPanel:getContentSize().height - rawHeight
    local taskIntrducePanel = self:getControl("TaskIntrducePanel")
    taskDescPanel:setContentSize(taskDescPanel:getContentSize().width, taskDescPanel:getContentSize().height)
    taskIntrducePanel:setContentSize(self.IntrducePanelContentSize.width, self.IntrducePanelContentSize.height + offSet)
    local mainPanel = self:getControl("MainPanel")
    mainPanel:setContentSize(self.mainContnetSize.width, self.mainContnetSize.height + offSet)

    -- 当前提示
    local curNotePanel = self:getControl("CurrentNotePanel")
    local curNotePanelHeight = curNotePanel:getContentSize().height
    local curNoteWordsPanel = self:getControl("CurNoteWordsPanel", Const.UILabel)
    local curNoteWordsPanelHeight = curNoteWordsPanel:getContentSize().height

    local promptStr = ""

    if string.match(task.task_prompt, "TIME_LEFT") then
        local leftTime = TaskMgr:getTaskTimeStr(task)
        promptStr = string.gsub(self:getTask(task, "task_prompt"), "TIME_LEFT", leftTime)
    else
        promptStr = self:getTask(task, "task_prompt")
    end

    if task.show_name == CHS[4101237] then
        promptStr = CHS[4200616]
    end

    self:setTaskText(curNoteWordsPanel, promptStr)

    -- 调整当前提示大小
    local offsetCurNotePanel = curNoteWordsPanel:getContentSize().height - curNoteWordsPanelHeight
    curNotePanel:setContentSize(curNotePanel:getContentSize().width, curNotePanel:getContentSize().height + offsetCurNotePanel)
    mainPanel:setContentSize(mainPanel:getContentSize().width, mainPanel:getContentSize().height + offsetCurNotePanel)

    if keyStr then
        self:setCtrlVisible("TaskBonusPanel", false)
        self:setCtrlVisible("HelpButton", true)
        local height = self:getControl("TaskBonusPanel"):getContentSize().height -  self:getControl("HelpButton"):getContentSize().height
        mainPanel:setContentSize(self.mainContnetSize.width, mainPanel:getContentSize().height - height)
        self.keyStr = keyStr
    else
        self:setCtrlVisible("TaskBonusPanel", true)
        self:setCtrlVisible("HelpButton", false)
    end

    -- 奖励
    self:setRewardInfo(task)

    self:updateLayout("MainPanel")
end

function TaskCardDlg:getTask(task, key)
    local taskInfo = TaskMgr:getTaskInfo(task["show_name"])
    local taskStr = ""

    if task[key] == nil then
        taskStr = taskInfo[key]
    else
        taskStr = task[key]
    end

    return taskStr
end

function TaskCardDlg:setTaskText(panel, text)
    panel:removeAllChildren()
    local lableText = CGAColorTextList:create()
    lableText:setFontSize(19)
    lableText:setContentSize(panel:getContentSize().width, 0)
    lableText:setString(text)
    lableText:setDefaultColor(COLOR3.LIGHT_WHITE.r, COLOR3.LIGHT_WHITE.g, COLOR3.LIGHT_WHITE.b)
    lableText:updateNow()
    local w, h = lableText:getRealSize()
    lableText:setPosition(0, h)
    lableText = tolua.cast(lableText, "cc.LayerColor")
    panel:addChild(tolua.cast(lableText, "cc.LayerColor"))
    panel:setContentSize(panel:getContentSize().width, h)

   --[[ local size = panel:getContentSize()
    local contentLayer = ccui.Layout:create()
    contentLayer:setContentSize(size.width, lableText:getContentSize().height)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(size)
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)

    if h < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - h)
    end
    contentLayer:addChild(lableText)
    panel:addChild(scroview)]]

end

function TaskCardDlg:setRewardInfo(task)
    local rewardStr   = self:getTask(task, "reward")

    --[[rewardStr = "#C12#C#I金钱|金钱#r600#I#I代金券|代金券#I#I经验|任务经验#r6000#I#I潜能|潜能#I#I声望|声望#r400#I#I物品|一叶草%bind=1222#r3#I"..
    CHS[3004436] ]]
    local rewardPanel = self:getControl("BonusPanel", Const.UIPanel)
    rewardPanel:removeAllChildren()
    local rewardContainer  = RewardContainer.new(rewardStr, rewardPanel:getContentSize(), COLOR3.LIGHT_WHITE, self)
    rewardPanel:addChild(rewardContainer)

  --[[  local width = 0
    local height = 0

    for i = 1 ,#rewardList do
        local text = self:getTextList(rewardList[i])

        if i ~= #rewardList then
            text = text..CHS[6000084]
        end

        local lableText = CGAColorTextList:create()
        lableText:setFontSize(20)
        lableText:setContentSize(rewardPanel:getContentSize().width, 0)
        lableText:setString(text)
        lableText:updateNow()
        rewardPanel:addChild(tolua.cast(lableText, "cc.LayerColor"))
        local labelW, labelH = lableText:getRealSize()
        if width + labelW > rewardPanel:getContentSize().width then
            height = height + labelH
            lableText:setPosition(0, rewardPanel:getContentSize().height - height)
            width = labelW
        else
            lableText:setPosition(width, rewardPanel:getContentSize().height - height)
            width = width + labelW
        end
    end]]

end

function TaskCardDlg:onHelpButton()
    gf:CmdToServer("CMD_PARTY_HELP", {keyStr = self.keyStr})
end

function TaskCardDlg:addMagicIcon()
    self:addMagic("MagicPanel", ResMgr:getMagicDownIcon())
end

function TaskCardDlg:removeMagicIcon()
     self:removeMagic("MagicPanel", ResMgr:getMagicDownIcon())
end

return TaskCardDlg
