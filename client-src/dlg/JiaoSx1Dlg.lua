-- JiaoSx1Dlg.lua
-- Created by songcw Mar/05/2018
-- 2018教师节答题

local JiaoSx1Dlg = Singleton("JiaoSx1Dlg", Dialog)

function JiaoSx1Dlg:init()
    for i = 1, 4 do
        local btn = self:getControl("Button_" .. i)
        btn:setTag(i)
        self:bindListener("Button_" .. i, self.onButton)
    end

    self.data = nil
    self.endTime = nil
    self.isLock = false

    self:hookMsg("MSG_TEACHER_2018_GAME_S6_END")
end

function JiaoSx1Dlg:onUpdate()
    if not self.endTime then return end

    -- 倒计时
    local sec = math.ceil( (self.endTime - gfGetTickCount()) / 1000 )
    if sec > 10 then
        self:setLabelText("TimeLabel", string.format( CHS[4200423],  sec), nil, COLOR3.GREEN)
    else
        self:setLabelText("TimeLabel", string.format( CHS[4200423],  sec), nil, COLOR3.RED)
    end

    -- 结束关闭
    if sec <= 0 then
        self:onCloseButton()
    end
end

function JiaoSx1Dlg:setData(data)
    self.data = data

    --if not self.endTime then
        self.endTime = math.min( gfGetTickCount() + (data.end_ti - gf:getServerTime()) * 1000, gfGetTickCount() + 30 * 1000)
    --end

    -- 题目
    self:setLabelText("QuestionLabel", data.question)

    -- 选项
    local i = 0
    for selectText, _ in pairs(data.select) do
        i = i + 1
        local bth = self:getControl("Button_" .. i)
        bth.selectText = selectText
        self:setLabelText("AnswerLabel", selectText, "Button_" .. i)
    end
end

function JiaoSx1Dlg:onButton(sender, eventType)
    if not self.data then return end
    if self.isLock then return end
    gf:CmdToServer("CMD_TEACHER_2018_GAME_S6_SELECT", {answer = self.data.select[sender.selectText]})
    self.isLock = true

    for i = 1, 4 do

        self:setCtrlVisible("ChosenImage", i == sender:getTag(), "Button_" .. i)
    --
        if i ~= sender:getTag() then
            self:setCtrlEnabled("Button_" .. i, false)
        end
        --]]
    end

    self:setCtrlVisible("PromptPanel", true)
end

function JiaoSx1Dlg:MSG_TEACHER_2018_GAME_S6_END(sender, eventType)
    self:onCloseButton()
end

return JiaoSx1Dlg
