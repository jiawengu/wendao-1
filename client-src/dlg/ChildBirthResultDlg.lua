-- ChildBirthResultDlg.lua
-- Created by songcw Mar/02/2019
-- 娃娃生产结果界面

local ChildBirthResultDlg = Singleton("ChildBirthResultDlg", Dialog)

function ChildBirthResultDlg:init(data)
    self:bindListener("ContinueButton", self.onContinueButton)
    self:setCtrlFullClientEx("BKPanel")

    self:setCtrlVisible("SuccessPanel", data.result == 1)
    self:setCtrlVisible("FailPanel", data.result == 0)

    self.data = data
    self.angel = 0

    self.rotationImage = self:getControl("RotationImage")
end

function ChildBirthResultDlg:onUpdate()
    
    self.angel = self.angel + 0.8
    self.rotationImage:setRotation(self.angel)
end

function ChildBirthResultDlg:onContinueButton(sender, eventType)
    if self.data.id ~= "" then
        GuideMgr:MSG_PLAY_INSTRUCTION({guideId = 80})
        DlgMgr:getDlgByName("GameFunctionDlg"):getControl("KidButton").id = self.data.id
    end
    self:onCloseButton()
end

return ChildBirthResultDlg
