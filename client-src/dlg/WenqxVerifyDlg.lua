-- WenqxVerifyDlg.lua
-- Created by songcw Jan/25/2019
-- 文曲星答题界面

local WenqxVerifyDlg = Singleton("WenqxVerifyDlg", Dialog)

local MAX_LEFT_TIME = 30

function WenqxVerifyDlg:init(data)
    self:bindListener("ChoiceButton1", self.onChoiceButton)
    self:bindListener("ChoiceButton2", self.onChoiceButton)
    self:bindListener("ChoiceButton3", self.onChoiceButton)
    self:bindListener("ChoiceButton4", self.onChoiceButton)

    self:initChoice()

    self.isSelect = false
    self.isLock = false
    self:setData(data)

    self:hookMsg("MSG_WQX_QUESTION_DATA")
    self:hookMsg("MSG_WQX_STAGE_RESULT")
end

function WenqxVerifyDlg:initChoice()
    for i = 1, 4 do
        local panel = self:getControl("ChoiceButton" .. i)
        panel:setTag(i)
        self:setLabelText("Label", "", panel)
        self:setCtrlVisible("Label", true, panel)
        self:setCtrlVisible("RightImage", false, panel)
        self:setCtrlVisible("WrongImage", false, panel)
    end
end

function WenqxVerifyDlg:onChoiceButton(sender, eventType)

    if self.isLock then return end

    local tag = sender:getTag()
    self:setCtrlVisible("ChosenImage", true, sender)

    local answer = gfDecrypt(self.data.ret, "wenqx")
    local tab = gf:split(answer, ",")
    answer = tonumber(tab[2])
    self:setCtrlVisible("RightImage", answer == tag, sender)
    self:setCtrlVisible("WrongImage", answer ~= tag, sender)
    self:setCtrlEnabled(sender:getName(), false)

    self.isLock = true

    gf:CmdToServer("CMD_WQX_ANSWER_QUESTION", {stage = self.data.stage, question_no = self.data.question_no, answer = self.data.answers[tag].text})
    performWithDelay(sender, function ()
        -- body
        gf:CmdToServer("CMD_WQX_FINISH_QUESTION", {stage = self.data.stage, question_no = self.data.question_no})
    end, 0.5)
end

function WenqxVerifyDlg:setData(data)

    self.data = data

    self:setLabelText("NameLabel", "", "InfoPanel")
    local len = string.len(data.question)
    if len % 3 ~= 0 then
        self:setLabelText("NameLabel", data.question , "InfoPanel")
    else
        local width = 40 * len / 3
        local panel = self:getControl("InfoPanel")
        for i = 1, 25 do
            local label = panel:getChildByName("label" .. i)
            if label then
                label:removeFromParent()
            end
        end
        local size = panel:getContentSize()
        local startX = (size.width - width) * 0.5 + 15
   --     gf:ShowSmallTips(startX)
        local y = (size.height) * 0.5
        local idx = 0
        for i = 1, len, 3 do
            idx = idx + 1
            local zi = string.sub(data.question, i, i + 2)
            local label = ccui.Text:create()
            label:setFontSize(30)
            label:setString(zi)
            label:setColor(COLOR3.TEXT_DEFAULT)
            label:setScale(math.random(800, 1400) / 1000, math.random(800, 1400) / 1000)
            label:setRotation(math.random(-45, 45))
            label:setPosition(startX + (idx - 1) * 40, y)
            label:setName("label" .. idx)
           -- gf:ShowSmallTips( "x :" .. (startX + (idx - 1) * 40 * ) .. "      y :" .. y )
            panel:addChild(label)
        end
    end



     for i = 1, 4 do
        local panel = self:getControl("ChoiceButton" .. i)
        panel:setTag(i)
        self:setLabelText("Label", data.answers[i].text, panel)
        self:setCtrlEnabled("ChoiceButton" .. i, true)


        self:setCtrlVisible("ChosenImage", false, panel)
        self:setCtrlVisible("RightImage", false, panel)
        self:setCtrlVisible("WrongImage", false, panel)
    end

    self:setHourglass(math.min( MAX_LEFT_TIME, data.end_time - gf:getServerTime()))
end

function WenqxVerifyDlg:cleanup()
    gf:CmdToServer("CMD_WQX_CLOSE_DLG", {stage = "verify"})

    if self.timerId then
        gf:Unschedule(self.timerId)
        self.timerId = nil
    end
end

function WenqxVerifyDlg:setHourglass(time)
    -- 开始180s倒计时
    local startTime = gf:getServerTime()
    local elapse = 0


    self:setLabelText("LeftTimeLabel", tostring(time) .. "秒", "TimePanel")
    if self.timerId then
        gf:Unschedule(self.timerId)
    end
    self.timerId = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - startTime)

        self:setLabelText("LeftTimeLabel", tostring(math.max(0, time - elapse)) .. "秒", "TimePanel")

        -- 验证阶段第二题，倒计时结束才关闭界面
        if math.max(0, time - elapse) == 0 and self.data.question_no == 2 then
            self:onCloseButton()
        end
    end, 1);

    local function hourglassCallBack(parameters)
        if self.timerId then
            gf:Unschedule(self.timerId)
            self.timerId = nil
            if not self.isLock then
                gf:CmdToServer("CMD_WQX_ANSWER_QUESTION", {stage = self.data.stage, question_no = self.data.question_no, answer = ""})
            end
        end

    end
    local bar = self:getControl("ProgressBar", nil, "TimePanel")
    if bar then
        bar:stopAllActions()
        local percent = time / MAX_LEFT_TIME * 100

        if percent > 0 then
            self:setProgressBarByHourglass("ProgressBar", MAX_LEFT_TIME * 1000, percent, hourglassCallBack, "TimePanel", true)
        else
            hourglassCallBack()
        end
    end
end

function WenqxVerifyDlg:MSG_WQX_STAGE_RESULT(data)
    self:onCloseButton()
end

function WenqxVerifyDlg:MSG_WQX_QUESTION_DATA(data)
    if data.stage ~= "verify" then
        self:onCloseButton()
        return
    end
    self.isLock = false
    self:setData(data)
end


return WenqxVerifyDlg
