-- VacationHomeworkDlg.lua
-- Created by lixh Nov/24 2017
-- 2018寒假作业界面

local VacationHomeworkDlg = Singleton("VacationHomeworkDlg", Dialog)

-- 作业科目对应标题图片
local TYPE_TO_TITLE_IMAGE = {
    [CHS[7100073]] = ResMgr.ui.vacation_homework_nous,      -- 常识
    [CHS[7100074]] = ResMgr.ui.vacation_homework_chinese,   -- 语文
    [CHS[7100075]] = ResMgr.ui.vacation_homework_math,      -- 数学
    [CHS[7100076]] = ResMgr.ui.vacation_homework_guess,     -- 猜谜
    [CHS[7100077]] = ResMgr.ui.vacation_homework_biology,   -- 生物
    [CHS[7100078]] = ResMgr.ui.vacation_homework_astronomy, -- 天文
    [CHS[7100079]] = ResMgr.ui.vacation_homework_geograpy,  -- 地理
    [CHS[7100080]] = ResMgr.ui.vacation_homework_chemistry, -- 化学
    [CHS[7100081]] = ResMgr.ui.vacation_homework_physical,  -- 物理
    [CHS[7100082]] = ResMgr.ui.vacation_homework_humanity,  -- 人文
}

-- 作业题号对应题号图片
local NUM_IMAGE = {
    ResMgr.ui.vacation_homework_num_one,    -- 寒假作业题目编号：大写一
    ResMgr.ui.vacation_homework_num_two,    -- 寒假作业题目编号：大写二
    ResMgr.ui.vacation_homework_num_three,  -- 寒假作业题目编号：大写三
    ResMgr.ui.vacation_homework_num_four,   -- 寒假作业题目编号：大写四
    ResMgr.ui.vacation_homework_num_five,   -- 寒假作业题目编号：大写五
    ResMgr.ui.vacation_homework_num_six,    -- 寒假作业题目编号：大写六
    ResMgr.ui.vacation_homework_num_seven,  -- 寒假作业题目编号：大写七
    ResMgr.ui.vacation_homework_num_eight,  -- 寒假作业题目编号：大写八
    ResMgr.ui.vacation_homework_num_nine,   -- 寒假作业题目编号：大写九
    ResMgr.ui.vacation_homework_num_ten,    -- 寒假作业题目编号：大写十
}

-- 选项
local NUM_TO_CHARACTER = {
    [1] = "A",
    [2] = "B",
    [3] = "C",
    [4] = "D",
}

local CHARACTER_TO_NUM = {
    ["A"] = 1,
    ["B"] = 2,
    ["C"] = 3,
    ["D"] = 4,
}

-- 填空题最多输入字符数：4个汉字
local MAX_CHARACTER_NUM = 8

-- 作业最大页数
local PAGE_NUM_MAX = 11

-- 完成作业最低需要包裹空格数量
local NEED_EMPTY_BAG_NUM = 2

function VacationHomeworkDlg:init()
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("ConfirmButton", self.onConfirmButton, "FillAnswerPanel")
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("ConfirmButton", self.onFinishButton, "LastPanel")

    self:bindListener("ChoiceButton1", self.onChoiceButton, "ChoiceAnswerPanel")
    self:bindListener("ChoiceButton2", self.onChoiceButton, "ChoiceAnswerPanel")
    self:bindListener("ChoiceButton3", self.onChoiceButton, "ChoiceAnswerPanel")
    self:bindListener("ChoiceButton4", self.onChoiceButton, "ChoiceAnswerPanel")

    self:bindListener("NumButton1", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton2", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton3", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton4", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton5", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton6", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton7", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton8", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton9", self.onNumTurnButton, "LastPanel")
    self:bindListener("NumButton10", self.onNumTurnButton, "LastPanel")

    self.subject = nil
    self.homework = nil
    self.unAnswerTable = {}
    self.answerInfo = {}
    self.pageIndex = 1

    self:setLabelText("TextLabel", "","FillAnswerPanel")
    self.blankInput = self:createEditBox("TextPanel", "FillAnswerPanel", nil, function(sender, type)
        self:setCtrlVisible("NoneLabel", false, "FillAnswerPanel")

        if type == "end" then
        elseif type == "changed" then
            local answer = self.blankInput:getText()
            local answerLength = gf:getTextLength(answer)

            -- 最多输入4个汉字
            if answerLength > MAX_CHARACTER_NUM then
                answer = gf:subString(answer, MAX_CHARACTER_NUM)
                self.blankInput:setText(answer)
                gf:ShowSmallTips(CHS[7100084])
            end
        end

        local answerLength = gf:getTextLength(self.blankInput:getText())
        self:setCtrlVisible("DelButton", answerLength > 0, "FillAnswerPanel")
        self:setCtrlVisible("NoneLabel", answerLength == 0, "FillAnswerPanel")
    end)
    self.blankInput:setLocalZOrder(2)
    self.blankInput:setFont(CHS[3003597], 19)
    self.blankInput:setFontColor(cc.c3b(76, 32, 0))
    self.blankInput:setText("")

    -- 输入文字居中显示
    local anwserInputLabel = self:getControl("TextPanel", nil, "FillAnswerPanel")
    gf:align(self.blankInput, anwserInputLabel:getContentSize(), ccui.RelativeAlign.centerInParent)
end

-- 设置界面信息
function VacationHomeworkDlg:setData(data)
    self.answerInfo = data.answer
    self.homework = data.question
    self.subject = data.type

    -- 标题
    self:setTitle(self.subject)

    for i = 1, #self.answerInfo do
        if self.answerInfo[i]  == "" then
            self:setPage(i)
            return
        end
    end

    self:setPage(PAGE_NUM_MAX)
end

-- 跳转页面
function VacationHomeworkDlg:setPage(index)
    self.pageIndex = index

    if self.pageIndex and self.pageIndex < PAGE_NUM_MAX then
        self:setHomework(self.pageIndex)
    else
        self:setLastPage()
    end
end

-- 设置第最后一页
function VacationHomeworkDlg:setLastPage()
    self:setCtrlVisible("TitlePanel1", false, "BKPanel")
    self:setCtrlVisible("TitlePanel2", true, "BKPanel")
    self:setCtrlVisible("ProblemPanel", false, "MainPanel")
    self:setCtrlVisible("ChoiceAnswerPanel", false, "MainPanel")
    self:setCtrlVisible("FillAnswerPanel", false, "MainPanel")
    self:setCtrlVisible("LastPanel", true, "MainPanel")

    for i = 1, PAGE_NUM_MAX - 1 do
        self:setCtrlVisible("DoneImage", false, "NumButton" .. i)
    end

    -- 未作答与已作答
    self.unAnswerTable = {}
    for k,v in pairs(self.answerInfo) do
        if v and v ~= "" then
            self:setCtrlVisible("DoneImage", true, "NumButton" .. k)
        else
            table.insert(self.unAnswerTable, k)
        end
    end

    table.sort(self.unAnswerTable, function(l, r)
    	if l < r then return true
    	else return false end
    end)

    if #self.unAnswerTable > 0 then
        self:setLabelText("TextLabel1", string.format(CHS[7100085], #self.unAnswerTable), "LastPanel")
    end

    self:setCtrlVisible("TextLabel1", #self.unAnswerTable > 0, "LastPanel")
    self:setCtrlVisible("TextLabel2", #self.unAnswerTable == 0, "LastPanel")
end

-- 答题最后一页：跳转答题响应
function VacationHomeworkDlg:onNumTurnButton(sender, eventType)
    local panelName = sender:getName()
    self.pageIndex = tonumber(string.match(panelName, "NumButton(.+)"))
    self:setHomework(self.pageIndex)
end

-- 设置作业标题
function VacationHomeworkDlg:setTitle(subject)
    local imagePath = TYPE_TO_TITLE_IMAGE[subject]
    if imagePath then
        self:setImage("SubjectImage", imagePath, "BKPanel")
    end
end

-- 设置题目序号
function VacationHomeworkDlg:setHomeworkNum(index)
    local imagePath = NUM_IMAGE[index]
    if imagePath then
        self:setImage("NumImage", imagePath, "TitlePanel1")
    end
end

-- 设置当前页面
function VacationHomeworkDlg:setHomework(index)
    self:setCtrlVisible("TitlePanel1", true, "BKPanel")
    self:setCtrlVisible("TitlePanel2", false, "BKPanel")
    self:setCtrlVisible("ProblemPanel", true, "MainPanel")
    self:setCtrlVisible("LastPanel", false, "MainPanel")

    local homework = self.homework[index]

    -- 序号
    self:setHomeworkNum(index)

    -- 题目
    self:setLabelText("TextLabel", homework.describe, "ProblemPanel")

    -- 选项或填空
    if homework.type == "choice" then
        local choiseDescribe = {homework.choice1, homework.choice2, homework.choice3, homework.choice4}
        for i = 1, 4 do
            local choisePaneli = self:getControl("ChoiceButton" .. i, nil, "ChoiceAnswerPanel")
            self:setLabelText("TextLabel", string.format(CHS[7100083], i, choiseDescribe[i]), choisePaneli)
        end

        -- 刷新选中效果
        self:choiceNum(self.answerInfo[index])

        self:setCtrlVisible("ChoiceAnswerPanel", true, "MainPanel")
        self:setCtrlVisible("FillAnswerPanel", false, "MainPanel")
    else
        if self.answerInfo[index] == "" then
            self:setCtrlVisible("TextLabel", false, "FillAnswerPanel")
            self:setCtrlVisible("NoneLabel", true, "FillAnswerPanel")
            self.blankInput:setText("")
        else
            self:setCtrlVisible("TextLabel", true, "FillAnswerPanel")
            self:setCtrlVisible("NoneLabel", false, "FillAnswerPanel")
            self:setCtrlVisible("DelButton", true, "FillAnswerPanel")
            self.blankInput:setText(self.answerInfo[index])
        end

        self:setCtrlVisible("DelButton", gf:getTextLength(self.blankInput:getText()) > 0, "FillAnswerPanel")

        self:setCtrlVisible("ChoiceAnswerPanel", false, "MainPanel")
        self:setCtrlVisible("FillAnswerPanel", true, "MainPanel")
    end
end

-- 选择题响应
function VacationHomeworkDlg:onChoiceButton(sender, eventType)
    local panelName = sender:getName()
    local index = tonumber(string.match(panelName, "ChoiceButton(.+)"))
    self:choiceNum(index)

    -- 选择题选完自动跳转到下一页
    self:onRightButton()
end

-- 选择选项1,2,3,4选中效果，同时
function VacationHomeworkDlg:choiceNum(num)
    for i = 1, 4 do
        self:setCtrlVisible("SelectedBKImage", false, "ChoiceButton" .. i)
    end

    if num ~= "" then
        if NUM_TO_CHARACTER[num] then
            self:setCtrlVisible("SelectedBKImage", true, "ChoiceButton" .. num)
            self.answerInfo[self.pageIndex] = NUM_TO_CHARACTER[num]
        else
            self:setCtrlVisible("SelectedBKImage", true, "ChoiceButton" .. CHARACTER_TO_NUM[num])
            self.answerInfo[self.pageIndex] = num
        end

        -- 保存当前作业作答情况
        self:sendAnswerToServer("going")
    end
end

-- 填空题清空答案
function VacationHomeworkDlg:onDelButton(sender, eventType)
    self:setCtrlVisible("DelButton", false, "FillAnswerPanel")
    self.blankInput:setText("")
    self:setCtrlVisible("NoneLabel", true, "FillAnswerPanel")
end

function VacationHomeworkDlg:onFinishButton(sender, eventType)
    if #self.unAnswerTable > 0 then
        -- 有未完成的题目
        local str = ""
        for i = 1, #self.unAnswerTable do
            str = str .. self.unAnswerTable[i]

            if i < #self.unAnswerTable then
                str = str .. "、"
            end
        end

        gf:confirm(string.format(CHS[7100088], str), function()
            if InventoryMgr:getEmptyPosCount() < NEED_EMPTY_BAG_NUM then
                -- 包裹数量不足
                gf:ShowSmallTips(string.format(CHS[7100087], NEED_EMPTY_BAG_NUM))
                return
            end

        	-- 发消息作答情况
            self:sendAnswerToServer("finish")
        end)
    else
        -- 已完成所有题目
        gf:confirm(CHS[7100089], function()
            if InventoryMgr:getEmptyPosCount() < NEED_EMPTY_BAG_NUM then
                -- 包裹数量不足
                gf:ShowSmallTips(string.format(CHS[7100087], NEED_EMPTY_BAG_NUM))
                return
            end

            -- 发消息作答情况
            self:sendAnswerToServer("finish")
        end)
    end

end

-- 发送作答给服务器
function VacationHomeworkDlg:sendAnswerToServer(type)
    local str = ""
    for i = 1, #self.answerInfo do
        str = str .. self.answerInfo[i]
        if i < PAGE_NUM_MAX - 1 then
            str = str .. "\t"
        end
    end

    gf:CmdToServer("CMD_WINTER_2018_HJZY", {type = self.subject, answer = str, opType = type})
end

function VacationHomeworkDlg:onConfirmButton(sender, eventType)
    -- 填空题特殊处理，确认，需要保存答案
    if self.homework[self.pageIndex] and self.homework[self.pageIndex].type == "fill" then
        self.answerInfo[self.pageIndex] = string.trim(self.blankInput:getText())

        -- 保存当前作业作答情况
        self:sendAnswerToServer("going")
    end

    self:setPage(self.pageIndex + 1)
end

function VacationHomeworkDlg:onLeftButton(sender, eventType)
    if self.pageIndex == 1 then
        gf:ShowSmallTips(CHS[7100090])
        return
    end

    -- 填空题特殊处理，上一页，需要保存答案
    if self.homework[self.pageIndex] and self.homework[self.pageIndex].type == "fill" then
        self.answerInfo[self.pageIndex] = string.trim(self.blankInput:getText())

        -- 保存当前作业作答情况
        self:sendAnswerToServer("going")
    end

    self:setPage(self.pageIndex - 1)
end

function VacationHomeworkDlg:onRightButton(sender, eventType)
    if self.pageIndex == PAGE_NUM_MAX then
        gf:ShowSmallTips(CHS[7100091])
        return
    end

    -- 填空题特殊处理，下一页，需要保存答案
    if self.homework[self.pageIndex] and self.homework[self.pageIndex].type == "fill" then
        self.answerInfo[self.pageIndex] = string.trim(self.blankInput:getText())

        -- 保存当前作业作答情况
        self:sendAnswerToServer("going")
    end

    self:setPage(self.pageIndex + 1)
end

-- 重载关闭界面函数
function VacationHomeworkDlg:onCloseButton(sender, eventType)
    -- 发消息作答情况
    self:sendAnswerToServer("close")
    Dialog.onCloseButton(self)
end

return VacationHomeworkDlg
