-- QuestionnaireDlg.lua
-- Created by songcw Sep/9/2016
-- 问卷

local QuestionnaireDlg = Singleton("QuestionnaireDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")
local RadioGroup = require("ctrl/RadioGroup")
local SliderPanel = require("ctrl/SliderPanel")

local LIST_MARGIN = 5       -- list控件间隔
local OPTION_MARGIN = 5     -- 选项间隔
local CHOICE_MARGIN = 7     -- 选择项间隔

local INPUT_MAX = 57

QuestionnaireDlg.beginTime = {}
QuestionnaireDlg.userTime = {}
QuestionnaireDlg.listContennerPos = {}


QuestionnaireDlg.questRelation = {}

-- 分支信息
-- QuestionnaireDlg.branchInfo[题码 .. 答案]，所选择的答案对应的分支题码
QuestionnaireDlg.branchInfo = {}

-- QuestionnaireDlg.questIsBranch[1] = true，则说明第一题是分支题，默认不显示
QuestionnaireDlg.questIsBranch = {}

-- 再次打开界面，需要显示的分支题
QuestionnaireDlg.initShowBranch = {}

-- 被删除的num
QuestionnaireDlg.removeTitleNum = {}

function QuestionnaireDlg:init()
    self:bindListener("Button", self.onButton)
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListViewListener("ListView", self.onSelectListView)

    self.radio = {}
    self.answer = {}
    self.allCtrl = {}

    self.branchInfo = {}
    self.questIsBranch = {}
    self.questRelation = {}
    self.removeTitleNum = {}
    self.initShowBranch = {}

    -- 克隆Panel初始化
    self:initClonePanel()

    self.listView = self:resetListView("ListView", LIST_MARGIN)
end

function QuestionnaireDlg:setData(data)
    self.id = data.id

    self.beginTime[self.id] = gf:getServerTime()
    self.userTime[self.id] = self.userTime[self.id] or 0

    -- 设置时间和奖励
    self:setDateInfo(data)
    self:setRewardInfo(data)
    self:initQuestList(data)
end

-- 遍历问题，将相关数据保存好
function QuestionnaireDlg:initData(data)
    for i = 1, data.question_count do
    -- ddddddddddddddddd
        local parsing = gf:split(data.questions[i], "|")
        local ret = {}
        ret.titleType = tonumber(parsing[1]) -- 1为单选，2多选
        ret.titleStr = parsing[2]
        ret.choicise = {}
        for j = 3, #parsing do
            if string.match(parsing[j], "<BRANCH:(.+)>") then
                -- 该答案下有分支
                local branch = string.match(parsing[j], "<BRANCH:(.+)>")
                local ans = string.gsub(parsing[j], "<BRANCH:(.+)>", "")

                self.branchInfo[i .. ans] = branch
   --             table.insert(ret.choicise, ans)

                local bQuest = gf:split(branch, ",")
                for _, ti in pairs(bQuest) do
                    self.questIsBranch[ti] = true

                    if not self.questRelation[i] then self.questRelation[i] = {} end
                    self.questRelation[i][ti] = true
                end

            end
        end


    end
end

function QuestionnaireDlg:initQuestList(data)

    self:initData(data)

    local idx = 0
    local bNo = 0
    local sNo = 0
    for i = 1, data.question_count do
        idx = idx + 1
        if self.questIsBranch[tostring(idx)] then
            if self.initShowBranch[tostring(idx)] then
            -- 是分支
                sNo = sNo + 1
            end
        else
            -- 主题目
            bNo = bNo + 1
            sNo = 0
        end

        -- 分支题目，默认隐藏
        local hasAns = QuestionMgr.answer[self.id] and not QuestionMgr.answer[self.id][i]
        if self.questIsBranch[tostring(i)] and not self.initShowBranch[tostring(i)] then

        else
            local titilPanel = self.choiceUnitPanel:clone()
            local str = bNo .. "、"
            if sNo ~= 0 then
                str = string.format( "%d(%d)、", bNo, sNo)
            end
            self:setUnitChoicePanel(data.questions[i], titilPanel, i, data.question_count, nil, str)
            self.listView:pushBackCustomItem(titilPanel)
        end
    end

    self.listView:pushBackCustomItem(self.submitPanel)

    if self.listContennerPos[self.id] then
        performWithDelay(self.root, function ()
            self.listView:getInnerContainer():setPositionY(self.listContennerPos[self.id])
        end, 0)
    end

    local slierPanel = self:getControl("SliderPanel")
    local slider = SliderPanel.new(slierPanel:getContentSize(), self.listView)
    slierPanel:addChild(slider)

    local function listener(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType then
            slider:scrolling()
        end
    end

    self.listView:addScrollViewEventListener(listener)

    self:refreashComplete()
end

function QuestionnaireDlg:parsingTitle(data, questNum)
    local parsing = gf:split(data, "|")
    local ret = {}
    ret.titleType = tonumber(parsing[1]) -- 1为单选，2多选
    ret.titleStr = parsing[2]
    ret.choicise = {}
    for i = 3, #parsing do
        local limitNum = string.match(parsing[i],"MAX_ANSWER_NUM:(%d)")
        if limitNum then
            ret.limitNum = tonumber(limitNum)
        else
            if string.match(parsing[i], "<BRANCH:(.+)>") then
                -- 该答案下有分支
                local branch = string.match(parsing[i], "<BRANCH:(.+)>")
                local ans = string.gsub(parsing[i], "<BRANCH:(.+)>", "")

      --          self.branchInfo[questNum .. ans] = branch
                table.insert(ret.choicise, ans)

                local bQuest = gf:split(branch, ",")
                for _, ti in pairs(bQuest) do
          --          self.questIsBranch[ti] = true

          --          if not self.questRelation[questNum] then self.questRelation[questNum] = {} end
          --          self.questRelation[questNum][ti] = true
                end
            else
                table.insert(ret.choicise, parsing[i])
            end
        end
    end

    return ret
end

function QuestionnaireDlg:getOptionHeight(data)
    local height = 0
    local choiceHeight = self.optionUnitPanel:getContentSize().height
    for i = 1, #data do
        local content = data[i]
        if string.match(content, "INPUT") then
        -- 输入框
            height = self.inputUnitPanel:getContentSize().height + height + OPTION_MARGIN * 2
        else
            height = height + choiceHeight + CHOICE_MARGIN
        end
    end

    return height
end

function QuestionnaireDlg:setUnitChoicePanel(data, root, index, max, isChechChild, titleNoStr)
    local ret
    root:setTag(index)
    local titleData = self:parsingTitle(data, index)
    local titleCtrl = self:getControl("QuestionPanel", nil, root)
    local numStr = titleNoStr--string.format("#R(%d/%d)#n", index, max)
    local titleHeight = self:setTitleContent(numStr .. titleData.titleStr, titleCtrl, COLOR3.TEXT_DEFAULT)
    local optionHeight = self:getOptionHeight(titleData.choicise)
    local totalHeight = titleHeight + optionHeight
    root:setContentSize(root:getContentSize().width, totalHeight)
    titleCtrl:setPosition(0, totalHeight - titleHeight)
    local posY = totalHeight - titleHeight
    local checkCtrl = {} -- check

    self.answer[index] = {}
    self.allCtrl[index] = {}

    for i = 1, #titleData.choicise do
        local content = titleData.choicise[i]
        if string.match(content, "INPUT") then
            -- 输入框
            local inputUnitPanel = self.inputUnitPanel:clone()
            self:setLabelText("OptionLabel", string.sub(content, string.len("INPUT:") + 1, -1), inputUnitPanel)
            inputUnitPanel:setPosition(35, posY - inputUnitPanel:getContentSize().height - 10)
            posY = posY - inputUnitPanel:getContentSize().height - OPTION_MARGIN * 2
            local ctrl = self:getControl("TextField", nil, inputUnitPanel)
            self:bindEditFieldForSafe(inputUnitPanel, INPUT_MAX, "CleanFieldButton", nil, function(self, sender, eventType)
                --[[ 
                if ccui.TextFiledEventType.detach_with_ime == eventType then
                    -- 失去焦点时
                    self:refreshAnswer()
                    QuestionMgr:setAnswer(self.answer, self.id)
                end
                --]]
                -- 修改为有事件就更新
                self:refreshAnswer()
                QuestionMgr:setAnswer(self.answer, self.id)
            end, true)
            self:bindListener("CleanFieldButton", function (self, sender)
                ctrl:setText("")
                sender:setVisible(false)
                self:refreshAnswer()
                QuestionMgr:setAnswer(self.answer, self.id)
            end, inputUnitPanel)
            root:addChild(inputUnitPanel)
            ctrl.bigIndex = index
            ctrl.smallIndex = i
            if QuestionMgr.answer[self.id] and next(QuestionMgr.answer[self.id]) and QuestionMgr.answer[self.id][index] and QuestionMgr.answer[self.id][index][i] then
                ctrl:setText(QuestionMgr.answer[self.id][index][i].value)
                if QuestionMgr.answer[self.id][index][i].value ~= "" then
                    self:setCtrlVisible("CleanFieldButton", true, inputUnitPanel)
                end
            end
            table.insert(self.answer[index], {value = ctrl:getStringValue(), ctrlType = "input"})
            table.insert(self.allCtrl[index], ctrl)
        else
            local optionPanel = self.optionUnitPanel:clone()
            self:setLabelText("OptionContentLabel", content, optionPanel)
            optionPanel:setPosition(35, posY - optionPanel:getContentSize().height - CHOICE_MARGIN)
            posY = posY - optionPanel:getContentSize().height - CHOICE_MARGIN
            root:addChild(optionPanel)
            local checkBox = self:getControl("CheckBox", nil, optionPanel)
            checkBox.bigIndex = index
            checkBox.smallIndex = i
            table.insert(checkCtrl, checkBox)

            if QuestionMgr.answer[self.id] and next(QuestionMgr.answer[self.id]) and QuestionMgr.answer[self.id][index] and QuestionMgr.answer[self.id][index][i] then
                checkBox:setSelectedState(QuestionMgr.answer[self.id][index][i].value == "1")

                if QuestionMgr.answer[self.id][index][i].value == "1" and self.branchInfo[index .. content] then
                    local numStr = self.branchInfo[index .. content]
                    local numTab = gf:split(numStr, ",")
                    for _, num in pairs(numTab) do
                        self.initShowBranch[num] = true
                    end
                    --self.initShowBranch
                    --[[
                    if self.branchInfo[index .. QuestionMgr.answer[self.id][index][i].content] then
                        local numTab = gf:split(self.branchInfo[index .. QuestionMgr.answer[self.id][index][i].content], ",")
                        -- 新增的
                        for i, num in pairs(numTab) do
                            num = tonumber(num)
                            cur = cur + 1
                            local titilPanel = self.choiceUnitPanel:clone()
                            self:setUnitChoicePanel(QuestionMgr.questionData.questions[num], titilPanel, num, QuestionMgr.questionData.question_count)
                            self.listView:insertCustomItem(titilPanel, cur)
                        end
                    end
                    --]]

                    --
                    if isChechChild then
                        ret = index .. content
                    end
--]]

                end

            end

            if checkBox:getSelectedState() then
                table.insert(self.answer[index], {value = "1", ctrlType = "CheckBox", content = content})
            else
                table.insert(self.answer[index], {value = "0", ctrlType = "CheckBox", content = content})
            end
            checkBox.title = content

    --        self:bindCheckBoxWidgetListener(checkBox, func)

            table.insert(self.allCtrl[index], checkBox)
        end
    end

    if next(checkCtrl) then
        if titleData.titleType == 1 then
            -- 单选
            self.radio[index] = RadioGroup.new()
            self.radio[index]:setItems(self, checkCtrl, self.onCheckBoxClick)
        else
            -- 多选
            for i, chCtl in pairs(checkCtrl) do
                self:bindTouchEndEventListener(chCtl, self.onCheckBoxClick)
                chCtl.limitNum = titleData.limitNum
            end
        end
    end

    root:requestDoLayout()

    return ret
end

function QuestionnaireDlg:onCheckBoxClick(sender, eventType)

    local bigIndex = sender.bigIndex
    local smallIndex = sender.smallIndex
    local limitNum = sender.limitNum
    local chNum = 0

    -- 计算多选题已选中的个数
    for i = 1, #self.answer[bigIndex] do
        if self.answer[bigIndex][i].value == "1" and i ~= smallIndex then
            chNum = chNum + 1
        end
    end

    if limitNum and chNum >= limitNum then
        -- 多选题限制选中个数
        sender:setSelectedState(false)
        gf:ShowSmallTips(string.format(CHS[5420156], limitNum))
    end

    self:refreshAnswer()
    QuestionMgr:setAnswer(self.answer, self.id)
    -- 如果该题，有分支
    if self.questRelation[bigIndex] then
        -- 删除其他的
        for i, num in pairs(self.questRelation[bigIndex]) do

            -- 如果嵌套的，需要处理
            if self.questRelation[tonumber(i)] then
                for j, valu in pairs(self.questRelation[tonumber(i)]) do
                    self.listView:removeChildByTag(tonumber(j))
                    self.removeTitleNum[tonumber(j)] = true
                end
            end

            self.listView:removeChildByTag(tonumber(i))
            self.removeTitleNum[tonumber(i)] = true
        end
        local cur = self.listView:getIndex(sender:getParent():getParent())

        local numTab = gf:split(self.branchInfo[bigIndex .. sender.title], ",")

        local sTitleNum = 0
        
        if numTab then
            -- 新增的
            for i, num in pairs(numTab) do
                num = tonumber(num)
                cur = cur + 1
                sTitleNum = sTitleNum + 1
                local titleStr = string.format( "%d(%d)、", bigIndex, sTitleNum)
                local titilPanel = self.choiceUnitPanel:clone()
                local branchData = self:setUnitChoicePanel(QuestionMgr.questionData.questions[num], titilPanel, num, QuestionMgr.questionData.question_count, true, titleStr)
                self.listView:insertCustomItem(titilPanel, cur)
                self.removeTitleNum[num] = false

                if branchData then
                    local numTab = gf:split(self.branchInfo[branchData], ",")
                    -- 新增的
                    for j, k in pairs(numTab) do
                        k = tonumber(k)
                        local titilPanel = self.choiceUnitPanel:clone()
                        sTitleNum = sTitleNum + 1
                        local titleStr = string.format( "%d(%d)、", bigIndex, sTitleNum)
                        self:setUnitChoicePanel(QuestionMgr.questionData.questions[k], titilPanel, k, QuestionMgr.questionData.question_count, nil, titleStr)
                        self.listView:insertCustomItem(titilPanel, cur + 1)
                        self.removeTitleNum[k] = false
                    end
                end
            end
        end
        

        self:refreshAnswer()
    else
    end

end


function QuestionnaireDlg:refreashComplete()

    performWithDelay(self.root, function ( )
        local data = QuestionMgr.questionData
        local completedCount = 0
        local flag = {}

        if QuestionMgr.answer[self.id] then
            local items = self.listView:getItems()
            for _, panel in pairs(items) do
                local tag = panel:getTag()
                if QuestionMgr.answer[self.id][tag] then

                    for __, answer in pairs(QuestionMgr.answer[self.id][tag]) do
                        if answer.ctrlType == "CheckBox" and answer.value ~= "0" and not flag[tag] then
                            --
                            flag[tag] = true
                            completedCount = completedCount + 1
                        elseif answer.ctrlType == "input" and answer.value ~= "" and not flag[tag] then
                            flag[tag] = true
                            completedCount = completedCount + 1
                        end
                    end

                end
            end
        end





        self:setLabelText("Label_2", completedCount, "ProcessPanel")
        self:setLabelText("Label_4", #self.listView:getItems() - 1, "ProcessPanel")
    end)


end


function QuestionnaireDlg:setTitleContent(title, panel, defaultColor)
    panel:removeChildByTag(766)
    local textCtrl = CGAColorTextList:create()
    if defaultColor then textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b) end
    textCtrl:setFontSize(19)
    textCtrl:setString(title)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    panel:setContentSize(panel:getContentSize().width, textH + 6)
    local image = self:getControl("BKImage", nil, panel)
    if image then
        image:setContentSize(panel:getContentSize().width, textH + 6)
        image:setPosition(panel:getContentSize().width * 0.5, (textH + 6) * 0.5)
    end
    --textCtrl:setPosition((panel:getContentSize().width - textW) * 0.5,textH + 3)
    textCtrl:setPosition(5,textH + 3)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"), 1, 766)

    return textH + 6
end

function QuestionnaireDlg:refreshAnswer()
    local max = 0
    for i, ctrls in pairs(self.allCtrl) do
        max = math.max(i, max)
        if self.removeTitleNum[i] then
        else
            for j, ctrl in pairs(ctrls) do
                if not self.listView:getChildByTag(i) and QuestionMgr.answer[self.id] and QuestionMgr.answer[self.id][i] and QuestionMgr.answer[self.id][i][j] then
                    -- 未显示的分支题，需要从管理器获取
                    self.answer[i][j].value = QuestionMgr.answer[self.id][i][j].value
                    self.answer[i][j].ctrlType = QuestionMgr.answer[self.id][i][j].ctrlType
                else
                    if ctrl:getName() == "CheckBox" then
                        if ctrl:getSelectedState() then
                            self.answer[i][j].value = "1"
                        else
                            self.answer[i][j].value = "0"
                        end
                    else
                        self.answer[i][j].value = ctrl:getStringValue()
                    end

                end

            end
        end
    end

    for i = 1, max do
        if not self.allCtrl[i] then
            if QuestionMgr.answer[self.id] and QuestionMgr.answer[self.id][i] then
                -- 未显示的分支题，需要从管理器获取
                self.answer[i] = {}
                for j, info in pairs(QuestionMgr.answer[self.id][i]) do
                    self.answer[i][j] = {}
                    self.answer[i][j].value = info.value
                    self.answer[i][j].ctrlType = info.ctrlType
                end
            end
        end
    end

    self:refreashComplete()
end

-- 设置时间
function QuestionnaireDlg:setDateInfo(data)
    local startDate = data.start_time
    self:setLabelText("StartTimeLabel", gf:getServerDate(CHS[4100331], startDate))

    local endDate = data.end_time
    self:setLabelText("EndTimeLabel", gf:getServerDate(CHS[4100331], endDate))

    --self:setLabelText("NameLabel", data.name, "ProcessPanel")
    self:setLabelText("TitleLabel_1", data.name)
    self:setLabelText("TitleLabel_2", data.name)

    self:updateLayout("ProcessPanel")
end

-- 设置奖励
function QuestionnaireDlg:setRewardInfo(data)
    local reward = data.bonus_desc
    local rewardPanel = self:getControl("WelfareImagePanel")
    rewardPanel:removeAllChildren(true)
    local rewardContainer  = RewardContainer.new(reward, rewardPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(0, rewardPanel:getContentSize().height / 2)
    rewardPanel:addChild(rewardContainer)
end

function QuestionnaireDlg:onButton(sender, eventType)
end

function QuestionnaireDlg:onCleanFieldButton(sender, eventType)
end

function QuestionnaireDlg:onSubmitButton(sender, eventType)
    self.userTime[self.id] = self.userTime[self.id] or 0
    self.userTime[self.id] = self.userTime[self.id] + gf:getServerTime() - self.beginTime[self.id]
    self:refreshAnswer()

    -- 检测一下答题条件是否满足
    for i, ctrls in pairs(self.answer) do
        if self.listView:getChildByTag(i) then
            local isNot = true
            for j, ctrl in pairs(ctrls) do
                if ctrl.ctrlType == "CheckBox" then
                    if ctrl.value == "1" then
                        isNot = false
                    end
                else
                    if ctrl.value ~= "" then
                        isNot = false
                    end
                end
            end
            if isNot then
                gf:ShowSmallTips(CHS[4100330])
                return
            end
        end
    end

    -- 将分支的答案排除
    for i, ctrls in pairs(self.answer) do
        if self.listView:getChildByTag(i) then
        else
            self.answer[i] = nil
        end
    end

    QuestionMgr:setAnswer(self.answer, self.id)
    QuestionMgr:subMitAnswer(self.userTime[self.id], self.id)

    self.isSub = true
    QuestionMgr:setAnswer(nil, self.id)
    self:onCloseButton()
end

function QuestionnaireDlg:onSelectListView(sender, eventType)
end

function QuestionnaireDlg:initClonePanel()
    -- 单选、多选选项的panel
    self.optionUnitPanel = self:getControl("OptionPanel")
    self.optionUnitPanel:removeFromParent()
    self.optionUnitPanel:retain()

    -- 单选、多选题Panel
    self.choiceUnitPanel = self:getControl("ChoiceQuestionPanel")
    self.choiceUnitPanel:removeFromParent()
    self.choiceUnitPanel:retain()

    -- 填空题Panel
    self.fillUnitPanel = self:getControl("FillQuestionPanel")
    self.fillUnitPanel:removeFromParent()
    self.fillUnitPanel:retain()

    -- 输入框
    self.inputUnitPanel = self:getControl("InputPanel")
    self.inputUnitPanel:removeFromParent()
    self.inputUnitPanel:retain()

    -- 提交
    self.submitPanel = self:getControl("SubmitPanel")
    self.submitPanel:removeFromParent()
    self.submitPanel:retain()
end

function QuestionnaireDlg:cleanup()
    self:releaseCloneCtrl("optionUnitPanel")
    self:releaseCloneCtrl("choiceUnitPanel")
    self:releaseCloneCtrl("fillUnitPanel")
    self:releaseCloneCtrl("inputUnitPanel")
    self:releaseCloneCtrl("submitPanel")

    if not self.isSub then
        self.userTime[self.id] = self.userTime[self.id] + gf:getServerTime() - self.beginTime[self.id]
        self.listContennerPos[self.id] = self.listView:getInnerContainer():getPositionY()

        self:refreshAnswer()
        QuestionMgr:setAnswer(self.answer, self.id)
    else
        self.userTime[self.id] = 0
        self.listContennerPos[self.id] = nil
    end

	self.isSub = nil
end

return QuestionnaireDlg
