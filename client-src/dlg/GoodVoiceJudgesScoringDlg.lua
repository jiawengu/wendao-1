-- GoodVoiceJudgesScoringDlg.lua
-- Created by
--

local GoodVoiceJudgesScoringDlg = Singleton("GoodVoiceJudgesScoringDlg", Dialog)

local MESSAGE_LIMINT = 100

function GoodVoiceJudgesScoringDlg:init(data)
    self:bindListener("SubmissionButton", self.onSubmissionButton)
    self:bindListener("DelButton", self.onDelButton)

    self:bindEditFieldForSafe("MessageInputPanel", MESSAGE_LIMINT, "DelButton", cc.TEXT_ALIGNMENT_LEFT, nil, true)

    for i = 1, 6 do
        local panel = self:getControl("NumPanel" .. i)
        panel:setTag(i - 1)
        self:setCtrlVisible("BKImage2", false, panel)

        self:bindTouchEndEventListener(panel, self.onScoreButton)

        self:setNumImgForPanel(panel, ART_FONT_COLOR.YELLOW, i - 1, nil, LOCATE_POSITION.MID, 27)
    end

    self.selectScore = nil
    self.data = data

    self:setLabelText("NameLabel", string.format( CHS[4200688], data.name), "MainPanel")

    if data.score >= 0 then
        self:onScoreButton(self:getControl("NumPanel" .. (data.score + 1)))
    end

    if data.comment ~= "" then
        self:setInputText("TextField", data.comment, "MessageInputPanel")
        self:setCtrlVisible("DefaultLabel", false, "MessageInputPanel")
    end
end

function GoodVoiceJudgesScoringDlg:onScoreButton(sender, eventType)
    for i = 1, 6 do
        local panel = self:getControl("NumPanel" .. i)
        self:setCtrlVisible("BKImage2", false, panel)
    end

    self.selectScore = sender:getTag()
    self:setCtrlVisible("BKImage2", true, sender)
end

function GoodVoiceJudgesScoringDlg:onSubmissionButton(sender, eventType)

    if not self.selectScore then
        gf:ShowSmallTips(CHS[4200671])
        return
    end


    local desc = self:getInputText("TextField", "MessageInputPanel")
    if desc == "" then
        gf:ShowSmallTips(CHS[4200672])
        return
    end


    local nameText, haveBadName = gf:filtText(desc)
    if haveBadName then
        self:setInputText("TextField", nameText, "MessageInputPanel")
        return
    end

    gf:CmdToServer("CMD_GOOD_VOICE_JUDGE_GIVE_SCORE", {voice_id = self.data.id, score = self.selectScore, comment = desc})

    self:onCloseButton()
end

function GoodVoiceJudgesScoringDlg:onDelButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, parentPanel)
end

return GoodVoiceJudgesScoringDlg
