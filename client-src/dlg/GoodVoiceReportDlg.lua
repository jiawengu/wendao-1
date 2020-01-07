-- GoodVoiceReportDlg.lua
-- Created by
--

local GoodVoiceReportDlg = Singleton("GoodVoiceReportDlg", Dialog)

local LIMIT = 20

function GoodVoiceReportDlg:init()
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("ReportButton", self.onReportButton)

    self:bindListener("ButtonPanel1", self.onReportForTalk)
    self:bindListener("ButtonPanel2", self.onReportForVoice)

    self.selectImage = self:retainCtrl("Image1")

    self.reportType = nil

    self:bindEditFieldForSafe("ReasonInputPanel", LIMIT, "DelButton", cc.TEXT_ALIGNMENT_LEFT, nil, 120)
end


function GoodVoiceReportDlg:onDlgOpened(list, param)
    self.voice_id = param
end

-- 言论违规
function GoodVoiceReportDlg:onReportForTalk(sender, eventType)
    self:setLabelText("DefaultLabel", CHS[4400046], "ReasonInputPanel")
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)

    self.reportType = CHS[4200677]
end


-- 声音
function GoodVoiceReportDlg:onReportForVoice(sender, eventType)

    self:setLabelText("DefaultLabel", CHS[4400047], "ReasonInputPanel")

    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)

    self.reportType = CHS[4200678]
end

function GoodVoiceReportDlg:onDelButton(sender, eventType)
    self:setInputText("TextField", "")
    self:setCtrlVisible("DefaultLabel", true)
    self:setCtrlVisible("CleanTextButton", false)
end

function GoodVoiceReportDlg:onReportButton(sender, eventType)
    if not self.reportType then
        gf:ShowSmallTips(CHS[4200679])
        return
    end

    local code = self:getInputText("TextField", "ReasonInputPanel")
    if code == "" then
    end

    local reason = self.reportType .. ":" .. code

    gf:CmdToServer("CMD_GOOD_VOICE_REPORT", {voice_id = self.voice_id, reason = reason, rp_type = 3})
    self:onCloseButton()
end

return GoodVoiceReportDlg
