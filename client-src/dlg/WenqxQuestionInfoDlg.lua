-- WenqxQuestionInfoDlg.lua
-- Created by songcw Jan/25/2019
-- 文曲星答题界面

local WenqxQuestionInfoDlg = Singleton("WenqxQuestionInfoDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOS = {
    "CheckBox1",
    "CheckBox2",
    "CheckBox3",
    "CheckBox4",
}

local MAX_LEFT_TIME = 30

function WenqxQuestionInfoDlg:init(data)
    self:bindListener("SubmitButton", self.onSubmitButton)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOS, self.onCheckBox)


    self.data = data

    self:setHourglass(math.min( MAX_LEFT_TIME, data.end_time - gf:getServerTime()))

    self:setLabelText("QuestionLabel", data.question)

        -- 设置答案
    for i = 1, 4 do
        local panel = self:getControl("OptionPanel_" .. i)
        if data.answers[i] then
            self:setLabelText("OptionContentLabel", data.answers[i].text, panel)
            panel:setVisible(true)
        else
            panel:setVisible(false)
        end
    end
end

function WenqxQuestionInfoDlg:setHourglass(time)
    -- 开始180s倒计时
    local startTime = gf:getServerTime()
    local elapse = 0

    self:setLabelText("Label_1", tostring(time), "TimePanel")
    if self.timerId then
        gf:Unschedule(self.timerId)
    end
    self.timerId = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - startTime)

        self:setLabelText("Label_1", tostring(math.max(0, time - elapse)), "TimePanel")

        if math.max(0, time - elapse) == 0 then
        end
    end, 1);

    local function hourglassCallBack(parameters)
        if self.timerId then
            gf:Unschedule(self.timerId)
            self.timerId = nil
        end
    end
end


function WenqxQuestionInfoDlg:onCheckBox(sender, eventType)
--    gf:ShowSmallTips(self.radioGroup:getSelectedRadioIndex())
end

function WenqxQuestionInfoDlg:onSubmitButton(sender, eventType)
    if not self.radioGroup:getSelectedRadioIndex() then
        gf:ShowSmallTips(CHS[4010386])
        return
    end
    gf:CmdToServer("CMD_WQX_HELP_ANSWER_QUESTION", {char_gid = self.data.char_gid, help_id = self.data.help_id, select_index = self.radioGroup:getSelectedRadioIndex()})
    self:onCloseButton()
end

return WenqxQuestionInfoDlg
